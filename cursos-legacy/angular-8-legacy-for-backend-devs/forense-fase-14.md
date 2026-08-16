# 🕵️ Forense Fase 14 — El pod que no arranca 🔥

> Pieza forense de la [**Fase 14 — Ambiente "casi prod" con kind**](./14-casi-prod-kind.md) 🔥 · Recorrido: ~40 min · [Índice del track](./forense-master.md)
> Herramientas: `kubectl get` · `kubectl describe` (Events) · `kubectl logs --previous` · `kubectl get endpoints`
> Síntoma que cubre: un contenedor que nunca llega a servir nada, sin consola, sin Network y sin nada de lo aprendido en trece fases.

Ésta es la situación en la que un dev de front se queda más ciego. No hay consola del navegador, no hay pestaña Network, no hay Redux DevTools: el proceso muere antes de aceptar la primera petición. Sólo hay dos comandos que contestan **dos preguntas distintas**, y confundirlas es lo que convierte veinte minutos en una tarde.

> 🔥 Pieza opcional, igual que su fase. No ocupa calendario y todos sus comandos van marcados 👁️ **solo lee** o ✍️ **modifica**, con la convención del [**Apéndice A09**](./a09-kubernetes.md): con acceso de lectura puedes recorrerla entera menos el paso 6.

---

## 🎫 El ticket

> *"Subí el cambio al cluster y la página no carga. Los pods dicen `CrashLoopBackOff`. Ya reinicié dos veces."*

**Reportado por:** un compañero del equipo
**Ambiente:** el cluster local de kind

`CrashLoopBackOff` **no es un diagnóstico**, y ése es el primer malentendido que hay que deshacer. Significa literalmente *"esto se murió varias veces y voy a esperar un poco antes de volver a intentarlo"*: describe el comportamiento del cluster, no la causa. La causa está siempre una capa más abajo.

---

## 🧭 La ruta

Seis pasos. El primero clasifica el fallo en una de tres familias, y **de esa clasificación depende cuál de los dos comandos caros usar**. Los pasos 2 a 4 son las tres ramas; el 5 es para cuando el pod sí corre y la página igual no carga; el 6 es el único que modifica algo.

### Paso 1 — Clasificar antes de investigar

```bash
# 👁️
kubectl get pods -n lab-frontend
```

```
NAME                            READY   STATUS             RESTARTS   AGE
lab-frontend-6d4b8c9f77-2xk4p   0/1     CrashLoopBackOff   5          3m
lab-frontend-6d4b8c9f77-9wzqn   0/1     CrashLoopBackOff   5          3m
```

**Qué descarta.** La columna `STATUS` reparte el trabajo en tres familias que no comparten herramienta:

| Estado | Qué significa | Con qué se persigue |
|---|---|---|
| `Pending` | nunca se programó en un nodo | `describe` → Events |
| `ImagePullBackOff` / `ErrImagePull` | no consiguió la imagen | `describe` → Events |
| `CrashLoopBackOff` | **arrancó y murió** | `logs --previous` |
| `Running` y la página no carga | el proceso vive; el problema es de red | `get endpoints` |

Y la regla que resume la tabla, que es lo único que hay que memorizar de esta pieza:

> 🧭 **`describe` si nunca llegó a `Running`; `logs --previous` si arrancó y murió.** El primero contesta *"¿el cluster pudo hacer su trabajo?"*. El segundo, *"¿qué dijo el proceso antes de morir?"*.

La columna `RESTARTS` confirma la clasificación: cinco reinicios significan que el contenedor **sí arrancó** cinco veces. Un pod que nunca consiguió la imagen no reinicia nada.

### Paso 2 — Rama A: nunca llegó a arrancar

```bash
# 👁️
kubectl describe pod lab-frontend-6d4b8c9f77-2xk4p -n lab-frontend
```

Sáltate las tres pantallas de metadatos y ve **al final**, a la sección `Events`. Es la primera que hay que leer y casi nadie lo hace:

```
Events:
  Type     Reason     Age                 From     Message
  ----     ------     ----                ----     -------
  Normal   Scheduled  2m                  default  Successfully assigned lab-frontend/…
  Normal   Pulling    2m                  kubelet  Pulling image "lab-frontend:1.0.0"
  Warning  Failed     2m                  kubelet  Failed to pull image "lab-frontend:1.0.0":
                                                   rpc error: … not found
  Warning  Failed     2m                  kubelet  Error: ErrImagePull
  Normal   BackOff    1m (x6 over 2m)     kubelet  Back-off pulling image "lab-frontend:1.0.0"
```

**Qué descarta.** El cluster salió a **buscar** la imagen, y ése es el hallazgo: no la tenía en el nodo. Dos causas y las dos son de esta fase:

- **No se cargó.** `kind load docker-image` copia la imagen de tu Docker al nodo, y es un atajo que sólo existe en kind. Compruébalo en el nodo, no en tu máquina: `docker images` te dice lo que tienes tú, no lo que tiene el cluster.

```bash
# 👁️ Lo que el nodo de kind tiene de verdad.
docker exec -it lab-cluster-control-plane crictl images | grep lab-frontend
```

- **La política la obliga a salir igual.** Con el tag `:latest`, la política por defecto es `Always`: sale a buscarla aunque esté en el nodo, y `kind load` no sirve de nada. Por eso el manifiesto lleva un tag versionado **y** `imagePullPolicy: IfNotPresent`.

Y si el estado era `Pending`, los Events dicen otra cosa —falta de recursos, un `nodeSelector` que no casa— y se lee igual: el evento nombra el motivo.

> 🧭 **El patrón:** cuando un pod no arranca por la imagen, la pregunta nunca es *"¿qué está mal en mi YAML?"* sino *"¿la imagen está en el sitio donde el cluster la busca?"*. En kind ese sitio es el nodo y se llena con `kind load`; en la empresa es el registry y se llena con `docker push`. Misma pregunta, dos respuestas.

### Paso 3 — Rama B: arrancó y murió

Acá está el comando que casi todo el mundo usa mal:

```bash
# 👁️ El contenedor de AHORA, que lleva dos segundos de vida.
kubectl logs lab-frontend-6d4b8c9f77-2xk4p -n lab-frontend
```

```
(sin salida)
```

**Qué descarta.** Nada, y ésa es la trampa. En un `CrashLoopBackOff`, `kubectl logs` te da el intento **actual**, que puede llevar dos segundos de vida y no haber escrito todavía —o estar en pleno *back-off*, sin contenedor vivo—. De ahí sale la conclusión equivocada más común de esta fase: *"el contenedor no dice nada"*.

El mensaje que buscas está en el contenedor **muerto**:

```bash
# 👁️ La salida del contenedor anterior, el que ya murió.
kubectl logs lab-frontend-6d4b8c9f77-2xk4p -n lab-frontend --previous
```

```
/entrypoint.sh: line 22: can't create /usr/share/nginx/html/assets/config.json: Read-only file system
```

**Qué descarta.** Todo lo demás. El diagnóstico está cerrado y no menciona ni al ConfigMap ni al volumen, que es exactamente lo que lo hace difícil: el `entrypoint.sh` escribe el `config.json` al arrancar, el volumen montado sobre esa ruta es de sólo lectura, la redirección falla, el `set -e` de la primera línea corta la ejecución, nunca se llega al `exec nginx`, y el contenedor muere antes de servir un byte.

Con los dos comandos juntos la historia se lee entera: el `describe` te dice que reinició cinco veces, el `logs --previous` te dice por qué.

### Paso 4 — Cerrar el círculo con la Fase 13

Si el mensaje anterior habla del `config.json`, la causa raíz vive en la fase anterior y conviene reconocerla como tal:

```bash
# 👁️ ¿Que monta este pod, y donde?
kubectl get pod lab-frontend-6d4b8c9f77-2xk4p -n lab-frontend -o yaml | grep -A6 volumeMounts
```

```yaml
volumeMounts:
  - name: config-volume
    mountPath: /usr/share/nginx/html/assets/config.json
    subPath: config.json
```

**Qué descarta.** Confirma la incompatibilidad y la nombra: **un contenedor que escribe en el arranque y un volumen de sólo lectura sobre esa misma ruta**. El fix es volver al Deployment con `envFrom`, que es como la fase lo deja: el ConfigMap alimenta variables de entorno, y el entrypoint escribe el archivo él mismo.

### Paso 5 — El pod corre y la página igual no carga

Otra familia, otro comando. Si `kubectl get pods` dice `Running` y `http://lab.local` no responde:

```bash
# 👁️
kubectl get endpoints -n lab-frontend
```

```
NAME           ENDPOINTS   AGE
lab-frontend   <none>      6m
```

**Qué descarta.** `ENDPOINTS: <none>` con pods `Running` significa que el Service no encuentra a quién mandarle el tráfico, y eso es **siempre** un problema de etiquetas: el `selector` del Service no coincide con las labels de los pods. Nunca es de red.

```bash
# 👁️ Las dos mitades que tienen que coincidir, una debajo de la otra.
kubectl get svc lab-frontend -n lab-frontend -o jsonpath='{.spec.selector}'
kubectl get pods -n lab-frontend --show-labels
```

Y si los endpoints **sí** están y la página sigue sin cargar, bisecta antes de mirar el Ingress:

```bash
# 👁️ Salta el Ingress por completo: habla directo con el Service.
kubectl port-forward svc/lab-frontend 8080:80 -n lab-frontend
```

**Qué descarta.** Si `http://localhost:8080` responde, todo lo que hay del Service hacia adentro está bien y el problema vive del Ingress hacia fuera: la línea en el archivo de hosts, el ingress controller que no está `Running`, o un cluster creado sin los `extraPortMappings`. Si no responde, el problema está adentro y el Ingress no tiene nada que ver. **Un `port-forward` es el bisector más barato del cluster.**

### Paso 6 — ✍️ Cuando el pod está sano y la configuración es vieja

Un solo caso, y es de los que más desconciertan: cambiaste el ConfigMap, `kubectl apply` salió bien, y la aplicación sigue igual.

```bash
# 👁️ El ConfigMap tiene el valor nuevo.
kubectl get configmap lab-frontend-config -n lab-frontend -o yaml

# 👁️ Y el pod sigue con el viejo, porque lo leyo al arrancar.
kubectl exec -it lab-frontend-6d4b8c9f77-2xk4p -n lab-frontend -- cat /usr/share/nginx/html/assets/config.json
```

**Qué descarta.** Las variables de entorno se leen **una vez, al arrancar el proceso**. Un ConfigMap actualizado no reinicia nada por su cuenta, y por eso el pod sigue sirviendo la configuración anterior sin que nada falle:

```bash
# ✍️ El único paso de esta pieza que modifica el cluster.
kubectl rollout restart deployment/lab-frontend -n lab-frontend
```

Es la misma lección de la Fase 13 con otro envoltorio: **la configuración entra en el arranque**, y cambiarla sin reiniciar no cambia nada.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Causa | Con qué comando |
|---|---|---|
| `ImagePullBackOff` con la imagen en tu Docker | el nodo no la tiene, o la política la obliga a salir | `describe` → Events; `crictl images` en el nodo |
| `CrashLoopBackOff` con `RESTARTS` subiendo | el contenedor arranca y muere | `logs --previous` |
| `kubectl logs` sin salida en un `CrashLoopBackOff` | te dio el intento actual, que no ha escrito nada | añade `--previous` |
| `Read-only file system` en el entrypoint | volumen de sólo lectura sobre una ruta que se escribe | los `volumeMounts` del pod |
| `Pending` para siempre | nunca se programó | `describe` → Events |
| `Running` y la página no responde | el Service no tiene a quién mandar tráfico | `get endpoints` |
| `ENDPOINTS: <none>` | el selector no coincide con las labels | `svc -o jsonpath` contra `pods --show-labels` |
| `port-forward` funciona y `lab.local` no | el problema está del Ingress hacia fuera | hosts, ingress controller, `extraPortMappings` |
| El ConfigMap cambió y la aplicación no | las variables se leen al arrancar | `rollout restart` |
| `kubectl apply` rechaza el ConfigMap por un tipo | un valor sin comillas: `true` se volvió booleano | el YAML del ConfigMap |
| Un pod que muere sin logs, en un Mac con chip M | casi siempre una imagen amd64 | [**A12**](./a12-arm64-m1.md) §6 |

---

## ⚰️ Los callejones

**"`CrashLoopBackOff` es el error."** Es el estado del cluster, no la causa: significa que algo se murió varias veces y que Kubernetes está esperando antes de reintentar. Tratarlo como diagnóstico —buscarlo en internet, cambiar el YAML a ver si mejora— es la forma más común de perder una tarde en esta fase.

**"El contenedor no dice nada."** Casi siempre sí dice, y en el contenedor anterior. Sin `--previous` estás leyendo un proceso que lleva dos segundos de vida o que ni siquiera existe todavía.

**"Reinicio otra vez a ver si arranca."** Kubernetes ya está reiniciando: eso es lo que significa el `RESTARTS: 5`. Reiniciar a mano no añade información y sí destruye la que había — en particular, puede llevarse por delante el contenedor anterior cuyo log ibas a leer.

**"Es un problema de red del cluster."** Un Service sin endpoints es de etiquetas, siempre. Y si los endpoints están, el `port-forward` del paso 5 te dice en treinta segundos de qué lado del Ingress está el problema, sin tocar una sola configuración de red.

**"Montemos el `config.json` desde un ConfigMap, que es lo correcto."** Es lo primero que intenta cualquiera que ya conoce Kubernetes, y suena impecable — pero esta imagen **escribe** ese archivo al arrancar. La pregunta que hay que hacerse antes de montar nada sobre una imagen ajena es *"¿esto escribe algo al arrancar, y dónde?"*, y acá la respuesta está en tres líneas de un `entrypoint.sh` que escribiste tú mismo hace una fase.

---

## 🧨 Deshacer

El recorrido deja el cluster tocado si aplicaste el montaje del ConfigMap:

```bash
# ✍️ Volver al Deployment de la fase, el de envFrom.
kubectl apply -f k8s/deployment.yaml

# 👁️ Y confirmar que los pods vuelven a estar Running.
kubectl get pods -n lab-frontend
```

Un `port-forward` queda corriendo en primer plano hasta que lo cortas con `Ctrl+C`; si abriste varios en pestañas distintas, ciérralos todos o el puerto 8080 seguirá ocupado la próxima vez y el error que verás no hablará de esto.

Y si el cluster entero quedó en un estado que no entiendes, borrarlo y crearlo de nuevo cuesta un minuto y es una respuesta legítima **acá y sólo acá**: `kind delete cluster --name lab-cluster`. En un cluster compartido no existe ese botón, y conviene tenerlo presente mientras se disfruta del atajo.

---

## 🧠 El patrón transferible

> **"No arranca" y "arrancó y se murió" son dos investigaciones distintas, y la columna de estado te dice cuál es.** Antes de escribir un comando caro, clasifica: si el proceso nunca llegó a correr, pregúntale a la plataforma qué le impidió hacerlo; si corrió y murió, pregúntale al proceso qué dijo antes de morir. Vale igual para un pod, para un servicio de systemd o para un job de un pipeline: la plataforma y el proceso son dos testigos distintos y cada uno sabe la mitad.

Y el segundo, que es la deuda oculta de heredar una imagen ajena: **un contenedor que escribe en el arranque y un volumen de sólo lectura sobre esa ruta son incompatibles, y el error que produce esa incompatibilidad no menciona ni al volumen ni al ConfigMap.** Antes de montar cualquier cosa sobre una imagen que no escribiste, la pregunta es qué escribe esa imagen al arrancar y dónde.

**Incidentes del cuaderno que usan esta ruta:** ninguno — la Fase 14 es 🔥 opcional y no reserva IDs. Lo más cercano es el **19**, que es la misma lección de configuración un piso más abajo, sin cluster de por medio.
**Amplía:** el [**Apéndice A09**](./a09-kubernetes.md) para el vocabulario de objetos de Kubernetes y la convención 👁️/✍️, el [**A12**](./a12-arm64-m1.md) para las imágenes de arquitectura equivocada en Apple Silicon, y [`forense-fase-13.md`](./forense-fase-13.md) para la causa raíz de casi todo lo que falla acá, que vive una fase más atrás.
