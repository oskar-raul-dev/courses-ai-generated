# 🕵️ Forense Fase 14 — 🔥 "El pod no arranca"

> Pieza forense de la **Fase 14 — Ambiente "casi prod" con kind** · Recorrido: ~40 min
> Herramientas: `kubectl describe` · `kubectl logs --previous` · `crictl images` · `kubectl get events`
> 🔥 **Opcional — esta pieza pertenece a una fase opcional.** Si no hiciste la Fase 14, no la necesitas.
> Síntoma que cubre: una aplicación que funcionaba en un contenedor y no arranca en el cluster, con un estado que no explica nada.

En un contenedor suelto, cuando algo falla, lo ves. En un cluster hay una capa entre tú y el proceso, y esa capa tiene **su propia versión de la historia**. Toda esta pieza es saber a cuál de las dos preguntarle primero.

La fase resume la regla. Aquí están los tickets literales y la salida de cada comando.

---

## 🎫 Ticket A — el que no llega a arrancar

> *"Apliqué el Deployment y el pod dice `ImagePullBackOff`. La imagen existe, la acabo de construir, `docker images` la lista."*

**Reportado por:** tú, la primera vez que usas kind · **Ambiente:** local

## 🎫 Ticket B — el que arranca y se muere

> *"El pod entra en `CrashLoopBackOff` y `kubectl logs` no dice nada útil. `kubectl describe` tampoco explica por qué."*

**Reportado por:** tú, media hora después · **Ambiente:** local, y en un Mac con chip M

---

## 🧭 La regla que ordena la pieza

**`kubectl describe pod` cuenta lo que le pasó al pod desde fuera** — si se pudo planificar, si la imagen se pudo obtener, si el contenedor arrancó, cuántas veces se reinició. Sus **eventos**, al final de la salida, son lo primero que hay que leer.

**`kubectl logs` cuenta lo que dijo el proceso desde dentro.** Existe **sólo si el contenedor llegó a arrancar.**

De ahí sale el orden, y es toda la regla:

> 🧭 **Si el pod nunca llegó a `Running`, empieza por `describe`. Si arrancó y se murió, empieza por `logs --previous`.** Y el estado te dice cuál es cuál.

```bash
kubectl get pods
# NAME                        READY   STATUS             RESTARTS   AGE
# certcore-7d4b8f9c5-x2klm    0/1     ImagePullBackOff   0          45s
```

---

## 🧭 Ruta A — `ImagePullBackOff` con la imagen delante

### Paso 1 — Los eventos, que están al final de `describe`

```bash
kubectl describe pod certcore-7d4b8f9c5-x2klm | tail -12
```

```
Events:
  Type     Reason     Age                From               Message
  ----     ------     ----               ----               -------
  Normal   Scheduled  50s                default-scheduler  Successfully assigned default/certcore-… to certcore-control-plane
  Normal   Pulling    49s                kubelet            Pulling image "certcore:fase-13"
  Warning  Failed     47s                kubelet            Failed to pull image "certcore:fase-13": rpc error: code = NotFound
                                                            desc = failed to pull and unpack image "docker.io/library/certcore:fase-13":
                                                            failed to resolve reference: docker.io/library/certcore:fase-13: not found
  Warning  Failed     47s                kubelet            Error: ErrImagePull
  Normal   BackOff    12s (x3 over 46s)  kubelet            Back-off pulling image "certcore:fase-13"
```

**Qué descarta.** Fíjate en `docker.io/library/certcore:fase-13`. **El kubelet salió a internet a buscarla.** No es que no encuentre la imagen: es que no la encuentra **donde busca**, y busca en un registro público porque no la tiene en su propio almacén.

### Paso 2 — El almacén del nodo no es el tuyo

```bash
# Tu almacén:
docker images | grep certcore
# certcore   fase-13   9f2c4b1e7a8d   2 hours ago   48.3MB

# El del nodo, que es otro contenedor con su propio almacén:
docker exec certcore-control-plane crictl images | grep certcore
# (nada)
```

**Ésa es la explicación entera.** kind corre el cluster **dentro de un contenedor**, con su propio almacén de imágenes, y ese almacén no es el de tu demonio de Docker.

```bash
# La solución, si tienes un demonio de Docker escuchando:
kind load docker-image --name certcore certcore:fase-13

# La universal, que funciona con Podman o con Colima en cualquier configuración,
# porque no depende de quién guarde la imagen sino de un archivo:
docker save certcore:fase-13 -o /tmp/certcore.tar
kind load image-archive --name certcore /tmp/certcore.tar

# Y la comprobación, que es lo que convierte esto en conocimiento:
docker exec certcore-control-plane crictl images | grep certcore
# docker.io/library/certcore   fase-13   9f2c4b1e7a8d   48.3MB
```

**Qué descarta.** Si `crictl images` no la muestra, el diagnóstico termina aquí: la imagen nunca llegó al nodo y cargarla lo resuelve. Si **sí la muestra y el pod sigue en `ImagePullBackOff`**, eso descarta el almacén y deja una sola causa posible, que es la del **Paso 3**: el nodo está intentando descargarla aunque la tenga.

### Paso 3 — El `:latest` que empeora el mismo problema

```bash
kubectl get pod certcore-… -o yaml | grep imagePullPolicy
# imagePullPolicy: Always
```

**Nadie escribió esa línea.** Kubernetes usa `IfNotPresent` para tags normales y **`Always` para `:latest`**. Con `certcore:latest`, el nodo intenta descargar la imagen aunque ya la tenga cargada — y en kind, donde no hay registro, eso es `ErrImagePull` **con la imagen delante y cargada**.

Es la causa raíz más desconcertante de esta ruta, y desaparece sola en cuanto la imagen tiene un tag de verdad.

**Qué descarta.** Si el tag es `:latest`, el bug está localizado y basta con ponerle uno de verdad. **Si ya tiene un tag normal** y el `imagePullPolicy` dice `IfNotPresent`, eso descarta la política y descarta el almacén del Paso 2: no es un problema de kind, y la ruta se agota aquí. Lo que queda es el **Paso 4**, que ya no es diagnóstico sino las tres preguntas con las que se abre el ticket en un cluster que no administras tú.

### Paso 4 — Lo mismo, en el cluster de tu empresa

En un cluster real no hay `kind load`. Hay un registro con autenticación, y las tres preguntas son:

1. **¿Está empujada al registro correcto?** — `docker push` y el nombre completo con el host del registro.
2. **¿El nodo llega a ese registro por red?** — políticas de red, proxies, cortafuegos.
3. **¿El namespace tiene el `imagePullSecret`?** — sin él, el kubelet no se puede autenticar y el evento dice `unauthorized`, que es un mensaje distinto del de arriba.

Con esas tres preguntas ya puedes abrir el ticket bien, y eso es lo que esta ruta entrena. **A09** §1 lo desarrolla.


**Aquí termina la ruta A.** En tu cluster de kind el bug está localizado en el Paso 2 o en el Paso 3; en el de tu empresa, lo que esta ruta te deja no es el fix sino **las tres preguntas con las que se abre el ticket bien**, que es lo máximo que puede darte una pieza sobre un cluster que no administras.

---

## 🧭 Ruta B — `CrashLoopBackOff`

### Paso 1 — El estado ya te dijo por dónde empezar

```bash
kubectl get pods
# NAME                        READY   STATUS             RESTARTS      AGE
# certcore-7d4b8f9c5-x2klm    0/1     CrashLoopBackOff   4 (32s ago)   2m
```

`RESTARTS 4` significa que **arrancó cuatro veces y se murió cuatro veces**. Arrancó: hay logs. Y el cluster está esperando cada vez más entre intentos, que es lo que significa el `BackOff`.

**Qué descarta.** Que haya reinicios descarta la ruta A entera: la imagen se descargó y el contenedor llegó a ejecutarse, así que no es un problema de registro ni de almacén. Y como arrancó, **hay algo escrito**: el **Paso 2** va a por los logs. Si `RESTARTS` fuera `0` y el estado no fuera `CrashLoopBackOff`, esta ruta no es la tuya.

### Paso 2 — `--previous`, que es la mitad del valor de esta pieza

```bash
kubectl logs certcore-7d4b8f9c5-x2klm
```

```
(vacío, o dos líneas de arranque)
```

```bash
kubectl logs certcore-7d4b8f9c5-x2klm --previous
```

```
/docker-entrypoint.sh: /docker-entrypoint.d/40-certcore-config.sh: line 12:
  can't create /usr/share/nginx/html/assets/config.json: Permission denied
nginx: [emerg] bind() to 0.0.0.0:80 failed (13: Permission denied)
```

**Qué descarta.** El primer comando muestra **el intento actual**, que puede llevar dos segundos de vida y no haber llegado todavía al error. El mensaje que buscas está en el anterior, y `--previous` es la única forma de verlo.

Y lo que dice ese log es el cierre del curso: **el contenedor no puede escribir donde escribe ni escuchar en el puerto 80**, porque una política de seguridad lo obliga a correr sin privilegios. Es la 💸 que la Fase 13 dejó abierta, y su arreglo completo —imagen `nginx-unprivileged`, puerto 8080, Deployment y Service ajustados— está en **A09** §8.

### Paso 3 — El caso sin logs, que en un Mac con chip M es casi siempre el mismo

```bash
kubectl logs certcore-… --previous
# (vacío)

kubectl describe pod certcore-… | grep -A3 "Last State"
```

```
    Last State:     Terminated
      Reason:       Error
      Exit Code:    1
```

Logs vacíos, código de salida 1, y ninguna explicación. En un Mac con Apple Silicon, **eso es casi siempre una imagen amd64 en un nodo arm64**:

```bash
docker image inspect certcore:fase-13 --format '{{.Architecture}}'
# amd64          ← y tu nodo es arm64
```

El proceso no llega a ejecutarse, así que no escribe nada. Es un segundo de comprobación y descarta la causa más desconcertante del capítulo. El diagnóstico completo está en **A12** §6.

**Qué descarta.** Si la arquitectura de la imagen no es la del nodo, ahí termina la búsqueda y el resto de la ruta sobra. Si coinciden, descarta la arquitectura y quedan dos posibilidades, las dos del **Paso 4**: que el pod ya se reciclara y sus logs se fueran con él, o que nunca escribiera nada por otro motivo.

### Paso 4 — Cuando el pod ya se recicló y no queda nada

```bash
# Todos los eventos del namespace, en orden. Cuando no sabes ni qué pod mirar:
kubectl get events --sort-by=.lastTimestamp | tail -20
```

```
2m    Warning   Failed      pod/certcore-…    Error: failed to start container
1m    Normal    Pulled      pod/certcore-…    Container image already present on machine
58s   Warning   BackOff     pod/certcore-…    Back-off restarting failed container
```

Y el recurso final, cuando el contenedor se muere antes de que puedas escribir nada dentro:

```bash
# Sustituye el arranque por un `sleep` y te deja una shell dentro de una imagen
# que de otro modo no dura lo suficiente para investigarla.
kubectl run debug --rm -it --image=certcore:fase-13 --command -- sh
```

> ⚠️ **Los logs de un pod borrado no existen.** Si el Deployment lo recrea, el anterior se fue y sus logs con él. En un cluster real eso lo resuelve un agregador —Loki, ELK, CloudWatch, el que tenga tu empresa— y **preguntar cuál es** debería ser de las primeras cosas que hagas al llegar a un equipo. Sin agregador, cada diagnóstico es una carrera contra el reinicio.


**Aquí termina la ruta B.** O tienes los logs del arranque anterior, o sabes que no existen y por qué. Las dos son respuestas: la segunda convierte el ticket en una pregunta para plataforma —*¿qué agregador tenemos?*— en vez de en una búsqueda que no puede terminar.

---

## 🩺 Diagnóstico por síntoma

| Estado | Qué significa | Por dónde empiezas |
|---|---|---|
| `Pending` | el cluster no lo ha colocado | `describe`: recursos o restricciones |
| `ContainerCreating` (más de un minuto) | bajando imagen o montando volúmenes | `describe` |
| `ErrImagePull` / `ImagePullBackOff` | no consiguió la imagen | ruta A |
| `ImagePullBackOff` con `imagePullPolicy: Always` | es el `:latest` | ruta A, paso 3 |
| `Running` con `READY 0/1` | arrancó y su probe no pasa | el endpoint de la probe |
| `CrashLoopBackOff` con logs | arrancó y se murió | `logs --previous` |
| `CrashLoopBackOff` **sin** logs, en Mac M | arquitectura de la imagen | `docker image inspect --format '{{.Architecture}}'` |
| `Permission denied` en el 80 o en `html/` | no puede correr como root | **A09** §8 |
| `Completed` en un Deployment | tu proceso no se queda vivo | el `CMD` de la imagen |
| El ConfigMap cambió y el pod no | se lee al arrancar | `kubectl rollout restart` |

---

## ⚰️ Los callejones

**"La imagen no existe."** Existe: `docker images` la lista. Lo que no existe es **en el almacén del nodo**, y son dos almacenes distintos. Confundirlos es el tropiezo universal de kind, y la frase que lo resuelve es la de la fase: *una imagen que existe en tu máquina no existe en ningún otro sitio hasta que alguien la mueve.*

**"Es un problema del manifiesto."** Casi nunca cuando el pod llegó a crearse: un manifiesto mal formado falla en el `kubectl apply`, no después. Si el pod existe y está en `CrashLoopBackOff`, el manifiesto era válido y el problema es del contenedor.

**"Voy a borrar el pod para que se reinicie limpio."** Es la reacción natural y **destruye la evidencia**: con el pod se van sus logs anteriores, que son exactamente lo que ibas a leer con `--previous`. Lee primero, borra después. Y si el Deployment lo va a recrear igual, borrarlo no cambia nada más que tu capacidad de investigar.

**"En Docker funcionaba."** Es un dato valiosísimo, no un callejón: significa que la imagen es correcta y que lo que cambió es el **entorno de ejecución** — la política de seguridad, el usuario, el sistema de archivos de sólo lectura, los recursos. Todo eso vive en el manifiesto, no en la imagen.

---

## 🧨 Deshacer

```bash
# Lo aplicado en el cluster:
kubectl delete -f k8s/

# Y el cluster entero, si quieres empezar de cero:
kind delete cluster --name certcore
```

Si probaste el paso 3 de la ruta A etiquetando la imagen como `:latest`, **quítala** (`docker rmi certcore:latest`): una imagen `:latest` en tu almacén va a reaparecer en la siguiente investigación con el mismo `imagePullPolicy` puesto y sin que la relaciones.

Y el `/tmp/certcore.tar` del `docker save`, si lo generaste.

---

## 🧠 El patrón transferible

> **En un cluster hay dos narradores y cuentan cosas distintas.** `describe` cuenta lo que el cluster hizo con tu pod; `logs` cuenta lo que tu proceso dijo. Preguntarle al equivocado es la mitad del tiempo perdido en Kubernetes, y el estado del pod te dice cuál es cuál sin ambigüedad.

Y el segundo, que es el que vale fuera de este curso: **`--previous` no es una bandera avanzada, es la bandera por defecto de cualquier `CrashLoopBackOff`.** El intento que estás mirando todavía no ha fallado; el que te lo va a explicar ya murió. Quien no conoce esa bandera concluye que "los logs no dicen nada" y se pone a adivinar.

**Incidentes del cuaderno que usan esta ruta:** ninguno directamente — la Fase 14 es opcional y el cuaderno no depende de ella. Pero el ticket B es el final del hilo que empieza en el incidente 19.
**Amplía:** **A09** §5 a §8 para la caja de herramientas, los estados de pod y la advertencia sobre el cluster real, **A12** §6 para el diagnóstico por síntoma en Apple Silicon, y `forense-fase-13.md` para cuando el mismo despliegue vive en un contenedor suelto.
