# 📎 Apéndice A09 — Kubernetes para el dev de front

> Tutorial Angular 8 — Laboratorio clínico · Consulta rápida · **3h**
> Usado por: Fases 13, 14 · Versión cubierta: API de Kubernetes **`v1`**, **`apps/v1`** y **`networking.k8s.io/v1`** — estables desde 2017-2018 y lo único que de verdad no envejece
> Herramientas: las mismas que fija la **Fase 14 §5** — kind `v0.20.0`, `kindest/node:v1.27.3`, kubectl `v1.27.x`, ingress-nginx `controller-v1.8.2`
> Estado: Base

**Esto no se lee de corrido.** Es material de consulta: se entra por el índice buscando algo concreto y se sale. Resuelve la situación en la que un dev de front se queda más ciego de todo el curso: **te pasan un YAML que no escribiste, o un mensaje que dice que tu pod está en `CrashLoopBackOff`, y no hay consola del navegador ni pestaña Network donde mirar.**

Este apéndice asume que tienes, como mucho, **acceso de lectura** al cluster. Cada comando va etiquetado: 👁️ **solo lee** —lo puedes correr sin miedo, con el jefe mirando— y ✍️ **modifica el cluster** —eso tiene dueño, y probablemente no eres tú—. Si no tienes acceso ninguno, el apéndice sigue sirviendo: las secciones 1, 2, 4, 5 y 7 son de lectura de manifiestos y de traducción de mensajes ajenos, que es la mitad del trabajo real.

**Qué queda fuera:** qué *es* cada objeto explicado en prosa, con el porqué de que exista —eso lo hace la **Fase 14 §4** y lo hace bien; acá se lee un objeto, no se aprende—; el montaje del cluster local con kind, el rolling update y el experimento del ConfigMap montado como volumen (**Fase 14 §5 y §6**); la imagen, el `entrypoint.sh` y el `nginx.conf` que se despliegan (**Fase 13 §5**); y **la administración del cluster** en cualquiera de sus formas —crear namespaces, dar permisos, tocar nodos, instalar controllers—, que es otro oficio con gente cuyo trabajo es ese. Helm y Kustomize aparecen en tres líneas de §4 y no se enseñan.

---

## Índice

- [1. El mapa en una página](#1-el-mapa-en-una-página)
- [2. Leer un manifiesto que no escribiste](#2-leer-un-manifiesto-que-no-escribiste)
- [3. Qué le pasa a tu imagen después del `docker build`](#3-qué-le-pasa-a-tu-imagen-después-del-docker-build)
- [4. El vocabulario completo, una línea por objeto](#4-el-vocabulario-completo-una-línea-por-objeto)
- [5. ConfigMap y Secret: por qué un Secret no es un secreto](#5-configmap-y-secret-por-qué-un-secret-no-es-un-secreto)
- [6. La caja de herramientas: qué pregunta responde cada comando](#6-la-caja-de-herramientas-qué-pregunta-responde-cada-comando)
- [7. Estados de un pod, traducidos](#7-estados-de-un-pod-traducidos)
- [8. ⚠️ Antes de acercarte al cluster real](#8-️-antes-de-acercarte-al-cluster-real)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios (8)](#-ejercicios-8)

---

## 1. El mapa en una página

Lo que te van a pasar es una carpeta con cuatro o cinco archivos YAML, o un solo archivo con varios objetos separados por `---`. Esto es lo que hay dentro y cómo se conectan entre sí:

```
                        ┌──────────────────────────────────────────┐
   navegador ──────────>│ Ingress        host: lab.local           │  la puerta de entrada
   (fuera del cluster)  │   └── backend: service lab-frontend:80   │
                        └────────────────────┬─────────────────────┘
                                             │ por NOMBRE de Service
                        ┌────────────────────▼─────────────────────┐
                        │ Service        selector: app=lab-frontend│  el nombre estable
                        └────────────────────┬─────────────────────┘
                                             │ por LABEL, no por nombre de pod
                        ┌────────────────────▼─────────────────────┐
                        │ Deployment     replicas: 2               │  el estado deseado
                        │   └── template.labels: app=lab-frontend  │
                        │       envFrom: configMapRef ─────────────┼──> ConfigMap
                        └────────────────────┬─────────────────────┘        Secret
                                             │ crea y vigila
                              ┌──────────────▼──────────────┐
                              │ Pod    Pod   (desechables)  │  lo que de verdad corre
                              └─────────────────────────────┘
```

> 🧠 **La regla que ordena la lectura de cualquier YAML:** los objetos **no se referencian por nombre de pod, se referencian por etiqueta**. El Ingress apunta al Service por su nombre; el Service apunta a los pods por su `selector`; el Deployment reconoce sus pods por su `matchLabels`. Las dos flechas de abajo son etiquetas que tienen que **coincidir carácter por carácter**, y cuando no coinciden nadie da error: simplemente no pasa nada. Ese "no pasa nada" silencioso es el 80% de los ratos perdidos de esta capa.

Y el orden en que se leen, que no es el orden en que están en la carpeta: **empieza por el Deployment** —ahí está tu imagen y tu configuración—, sigue por el Service —¿su selector coincide con las labels del Deployment?—, y termina por el Ingress —¿apunta al Service correcto, en el puerto correcto?—. El ConfigMap y el Secret se leen cuando ya sabes quién los consume.

---

## 2. Leer un manifiesto que no escribiste

La **Fase 14 §5** escribe estos manifiestos desde cero y explica cada decisión. Esta sección es la operación inversa y mucho más frecuente: alguien te pasa uno hecho y tienes que responder algo sobre él en diez minutos.

De todo el YAML, **seis campos deciden si tu aplicación funciona**. El resto es contexto.

```yaml
apiVersion: apps/v1
kind: Deployment                    # ① QUE ES esto. Se lee primero, siempre
metadata:
  name: lab-frontend
  namespace: lab-frontend           # ② DONDE vive. Sin -n, kubectl mira otro sitio
spec:
  replicas: 2
  selector:
    matchLabels:
      app: lab-frontend             # ③ tiene que coincidir con template.labels
  template:
    metadata:
      labels:
        app: lab-frontend           # ③ ...y con el selector del Service
    spec:
      containers:
        - name: web
          image: lab-frontend:1.0.0 # ④ QUÉ versión corre. Ojo con :latest (§3)
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 80     # ⑤ donde escucha. Debe casar con targetPort
          envFrom:
            - configMapRef:
                name: lab-frontend-config   # ⑥ DE DÓNDE sale la configuración
```

**① `kind` — qué es.** Un archivo con `kind: Deployment` describe algo que corre; uno con `kind: Service` describe cómo se le habla; uno con `kind: ConfigMap` no corre nada, solo guarda datos. Si el YAML tiene varios objetos separados por `---`, léelos como archivos distintos que casualmente viajan juntos.

**② `metadata.namespace` — dónde vive.** Un namespace es una carpeta lógica del cluster. Si el objeto declara uno y tú corres `kubectl get pods` sin `-n`, estás mirando el namespace `default` y **no vas a ver nada**, lo que se siente exactamente igual que "el despliegue falló". Es el error número uno de quien llega de fuera.

**③ Las etiquetas — el pegamento invisible.** `selector.matchLabels` del Deployment, `template.metadata.labels` del pod y `selector` del Service tienen que decir lo mismo. Un typo entre ellos produce pods `Running` y una página que no carga, sin un solo error (**Fase 14 §6, error 2**).

**④ `image` — qué versión corre.** El campo más importante del archivo y el que más mentiras esconde (§3).

**⑤ `containerPort` y `targetPort`** — el puerto donde escucha el proceso dentro del contenedor, y el que el Service usa para alcanzarlo. Si el Service dice `targetPort: 8080` y tu nginx escucha en el 80, el Service tiene endpoints y ninguno responde.

**⑥ `envFrom` / `env` — de dónde sale la configuración.** Es el puente entre la Fase 13 y el cluster: las claves del ConfigMap llegan como variables de entorno, y el `entrypoint.sh` las lee sin enterarse de que hoy vienen de Kubernetes.

> 💡 **El campo que más se busca y menos se encuentra: la ruta de la salud.** Si el manifiesto tiene `livenessProbe` o `readinessProbe`, ahí está escrito qué URL considera el cluster que significa "esta aplicación está viva". Cuando un pod se reinicia solo cada dos minutos sin errores en los logs, esa ruta es lo primero que hay que mirar: puede estar apuntando a algo que tu SPA no sirve. El proyecto del curso no las tiene (💸 declarada en la **Fase 14 §5.5**), pero el cluster real de la empresa casi seguro sí.

> ⚠️ **Si lo que te pasaron es un chart de Helm o una carpeta de Kustomize, no estás viendo otra cosa: estás viendo estos mismos objetos con plantillas encima.** En Helm los valores viven en un `values.yaml` y el YAML real solo existe después de renderizarlo; puedes verlo con `helm template .` sin instalar nada. En Kustomize, un `kustomization.yaml` compone una base con parches por ambiente y `kubectl kustomize .` te muestra el resultado. En los dos casos, **pide el YAML renderizado** antes de discutir sobre un campo: discutir sobre una plantilla es discutir sobre algo que nadie ha visto.

---

## 3. Qué le pasa a tu imagen después del `docker build`

La **Fase 14** resuelve esto con `kind load`, que copia la imagen de tu Docker al nodo. Funciona, es cómodo y **no existe en la empresa**. Esta sección es el camino real, que es el que vas a tener que explicar cuando alguien pregunte por qué su cambio no aparece desplegado.

```
tu maquina                      registry corporativo              cluster
──────────                      ────────────────────              ───────
docker build -t \                                                 Deployment pide
  registry.interno/lab/         ┌──────────────────┐              registry.interno/
  frontend:1.4.0 .   ──push──>  │ lab/frontend     │  ──pull──>   lab/frontend:1.4.0
                                │  :1.4.0          │                    │
                                │  @sha256:9c4f... │              kubelet la baja
                                └──────────────────┘              y arranca el pod
                                        ▲
                              imagePullSecrets: el cluster
                              necesita credenciales para entrar
```

Tres cosas que hay que saber y ninguna es obvia:

**El nombre completo de una imagen tiene cuatro partes** y casi nunca se escriben todas: `registry.interno/lab/frontend:1.4.0`. Si no hay registry al principio, se asume Docker Hub — y por eso una imagen llamada `lab-frontend:1.0.0` a secas, en un cluster real, se busca en internet y no se encuentra jamás.

**El tag miente; el digest no.** Un tag es una etiqueta movible: `1.4.0` puede apuntar hoy a una imagen y mañana a otra si alguien reconstruyó y volvió a publicar con el mismo número. El **digest** (`@sha256:...`) es el contenido y no se puede falsificar. Cuando alguien jure que desplegó tu arreglo y tú no lo veas, la pregunta correcta no es qué tag corre, es **qué digest**:

```bash
# 👁️ Que imagen esta corriendo DE VERDAD, con su digest. Si el digest no
# cambio entre dos despliegues, no se despliego nada, aunque el tag sea otro.
kubectl get pods -n lab-frontend -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.containerStatuses[*].imageID}{"\n"}{end}'
```

**`:latest` es una trampa doble.** Primero, no sabes qué es: dos pods creados con una hora de diferencia pueden estar corriendo builds distintos. Segundo, cambia el comportamiento del cluster: con `:latest`, la política de descarga por defecto pasa a `Always`, así que el nodo sale a buscar la imagen aunque ya la tenga. Es la causa de que `kind load` no sirva de nada (**Fase 14 §4**) y, en el cluster real, de que un pod no arranque por un registry momentáneamente caído. **Etiqueta siempre con versión explícita.**

### El registry local, si quieres acercar kind a la realidad

`kind load` te ahorra el registry y a cambio te esconde la mitad del problema: las credenciales, el nombre completo de la imagen, el `push`. kind documenta cómo levantar un **registry local** —un contenedor más, conectado a la red del cluster— para que el ciclo sea `build → push → pull` igual que en la empresa. Es la forma más barata de reproducir un `ImagePullBackOff` por credenciales antes de encontrártelo en serio. El procedimiento está en las Referencias; el concepto que te llevas es este: **si el pod no encuentra la imagen, la pregunta nunca es qué YAML está mal, es si la imagen llegó al sitio donde el cluster la busca.**

> ⚠️ **`imagePullSecrets` es la pieza que no se ve.** Un registry corporativo pide credenciales, y el cluster las lleva en un Secret de tipo `kubernetes.io/dockerconfigjson` referenciado desde el Deployment o desde la ServiceAccount del namespace. Cuando tu imagen existe, el nombre está bien escrito y aun así el pod dice `ImagePullBackOff`, el `describe` suele traer un `unauthorized` o un `no basic auth credentials`: eso no lo arreglas tú, lo arregla quien administra el namespace.

---

## 4. El vocabulario completo, una línea por objeto

Para reconocerlos en una reunión y no perder el hilo. Los cinco primeros son los de la **Fase 14 §4**, que los explica de verdad; el resto están acá porque aparecen en conversaciones y en manifiestos ajenos.

**Los que ya conoces**

- **Pod** — lo que corre. Uno o más contenedores que comparten red y ciclo de vida. Desechable por diseño: nunca le hables por su nombre.
- **Deployment** — el estado deseado: *"quiero N pods con esta imagen"*. Tú no arrancas pods, declaras esto.
- **ReplicaSet** — la capa intermedia que el Deployment crea y que hace posible el rolling update. Lo vas a ver en `kubectl get all` y lo vas a ignorar el 99% del tiempo; el 1% restante es cuando quedan dos, uno viejo y uno nuevo, y ahí te está contando que una actualización se quedó a medias.
- **Service** — el nombre estable que reparte tráfico entre los pods que coinciden con una etiqueta.
- **Ingress** — la regla de entrada desde fuera: *"lo que llegue a este host, mándalo a este Service"*. Necesita un **ingress controller** que la ejecute, que en este proyecto es otro nginx (**Fase 14 §4**).
- **ConfigMap** — pares clave-valor con la configuración. Nunca secretos (§5).

**Los que vas a oír nombrar**

- **Namespace** — la carpeta lógica del cluster. Casi siempre hay uno por equipo o por ambiente, y es el `-n` de todos los comandos.
- **Secret** — como un ConfigMap pero para credenciales, y con menos protección de la que su nombre promete (§5).
- **ServiceAccount** — la identidad con la que corre un pod dentro del cluster. Importa cuando algo del pod habla con la API de Kubernetes, cosa que un front no hace.
- **PersistentVolumeClaim (PVC)** — una petición de disco que sobrevive al pod. Un front que solo sirve archivos estáticos no necesita ninguno; si ves uno en tu namespace, probablemente es de la base de datos del vecino.
- **Job** y **CronJob** — algo que corre hasta terminar, una vez o según un horario. Migraciones, reportes nocturnos, limpiezas.
- **DaemonSet** — un pod en cada nodo. Casi siempre es infraestructura ajena: recolectores de logs, agentes de métricas.
- **StatefulSet** — como un Deployment pero con identidad y disco estables por réplica. Bases de datos y colas. Si tu front está en un StatefulSet, alguien se equivocó.
- **HorizontalPodAutoscaler (HPA)** — sube y baja el número de réplicas según una métrica. Explica por qué a veces hay tres pods y a veces siete sin que nadie haya tocado nada.
- **NetworkPolicy** — reglas de quién puede hablarle a quién dentro del cluster. Es la respuesta cuando dos pods que "deberían" verse no se ven.
- **RBAC (`Role`, `RoleBinding`)** — quién puede hacer qué. Es lo que decide si tu `kubectl get pods` responde o te dice `Forbidden`.
- **Helm / Kustomize** — no son objetos, son formas de generar estos objetos. Un chart es una plantilla; un `kustomization.yaml` es una base con parches por ambiente. Lo que se aplica al cluster, al final, es siempre YAML como el de §2.

> 🧭 **Cómo saber qué existe en tu namespace sin conocer el vocabulario:** `kubectl get all -n <namespace>` 👁️ lista lo más común de una sola vez. Le falta lo que no cuenta como "carga de trabajo" —ConfigMaps, Secrets, Ingress, PVCs—, así que la segunda pasada es `kubectl get ingress,configmap,secret,pvc -n <namespace>` 👁️.

---

## 5. ConfigMap y Secret: por qué un Secret no es un secreto

La lección de la Fase 13 —**la configuración vive fuera de la imagen**— tiene su forma canónica en dos objetos que se parecen y no se comportan igual.

### El ConfigMap, en dos formas

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: lab-frontend-config
  namespace: lab-frontend
data:
  # Cada clave puede llegar al contenedor como variable de entorno (envFrom),
  # que es como lo consume el entrypoint.sh de la Fase 13.
  API_URL: "http://localhost:3000"
  ENVIRONMENT_NAME: "uat"
```

La otra forma es guardar un archivo entero como valor y montarlo como volumen. Suena mejor y en este proyecto **rompe el arranque**: el `entrypoint.sh` escribe sobre esa misma ruta y los volúmenes de ConfigMap se montan de solo lectura. Está desarrollado como experimento forense en la **Fase 14 §6**, y es de las cosas más transferibles del curso: *antes de montarle un volumen a una imagen ajena, pregunta si esa imagen escribe algo al arrancar y dónde*.

### El Secret, y el detalle que hay que saber

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: lab-frontend-secrets
  namespace: lab-frontend
type: Opaque
data:
  # OJO: esto NO está cifrado. Es base64, que es una codificación, no un
  # método de protección: cualquiera con permiso de lectura lo revierte en un
  # segundo con el comando de abajo. El base64 esta ahi para poder guardar
  # bytes binarios en YAML, no para esconder nada.
  API_TOKEN: c3VwZXItc2VjcmV0LXRva2Vu
```

```bash
# 👁️ Leer un Secret concreto y decodificarlo. Funciona con cualquier acceso de
# lectura sobre el namespace: eso es exactamente el punto de esta sección.
kubectl get secret lab-frontend-secrets -n lab-frontend \
  -o jsonpath='{.data.API_TOKEN}' | base64 -d

# 👁️ Ver que claves tiene sin revelar los valores. Es lo que se puede pegar en
# un ticket: los nombres, nunca el contenido.
kubectl get secret lab-frontend-secrets -n lab-frontend -o jsonpath='{.data}' | tr ',' '\n'
```

**Los tres tipos que te vas a encontrar.** `Opaque` es el genérico, pares clave-valor cualesquiera. `kubernetes.io/dockerconfigjson` guarda las credenciales del registry y es el que consume `imagePullSecrets` (§3). `kubernetes.io/tls` guarda el certificado y la clave de un dominio, y es el que referencia un Ingress cuando sirve HTTPS.

**Cómo llega a tu contenedor**, que importa para diagnosticar: como **variable de entorno** (`envFrom: secretRef` o `env.valueFrom.secretKeyRef`), y entonces se ve con un `env` dentro del pod y aparece en cualquier volcado de entorno que hagas en un log; o como **volumen**, y entonces cada clave es un archivo dentro de una carpeta y no aparece en el entorno. La segunda forma tiene una propiedad útil: si el Secret cambia, el archivo montado se actualiza solo al cabo de un rato, mientras que una variable de entorno **se lee al arrancar y no se entera nunca más** —que es exactamente el error 4 de la **Fase 14 §6** aplicado a credenciales.

**Qué protege un Secret de verdad.** Tres cosas y ninguna es el base64: que los permisos de RBAC se puedan dar por separado —alguien puede tener permiso de leer ConfigMaps y no Secrets—, que no se imprima por accidente en salidas donde sí aparecen los ConfigMaps, y que el cluster *puede* estar configurado para cifrarlos en reposo en etcd, si quien lo administra lo activó. Ninguna de las tres depende de ti.

> ⚠️ **Higiene, en cuatro reglas que valen más que toda la sección.** **(1)** Nunca pegues la salida decodificada de un Secret en un ticket, un canal de chat o una captura: acabas de publicar la credencial en un sitio que se indexa y se conserva. Pega los **nombres** de las claves. **(2)** Nunca metas una credencial en un ConfigMap "porque total, es interno": los ConfigMaps se leen con permisos más laxos y salen enteros en cualquier `describe`. **(3)** Nunca hornees una credencial en la imagen: queda en una capa, y una capa es un archivo que cualquiera con acceso al registry puede descomprimir. **(4)** Si crees que una credencial se filtró, no la borres del chat: pídele a quien administra que la **rote**. Un secreto expuesto no se desexpone.

> 🧭 **Y la regla que solo aplica a un front, que es la más importante de todas.** Todo lo que termina en `config.json` **llega al navegador del usuario** y se lee con `Ctrl+U` o abriendo la pestaña Network. Da igual que haya viajado dentro de un Secret de Kubernetes con RBAC y cifrado en reposo: en el momento en que el `entrypoint.sh` lo escribe en un archivo que sirve nginx, es público. **En la configuración de una SPA no hay secretos, solo hay valores.** Si alguien te pide "meter la API key en el Secret para que el front la use", la respuesta correcta no es cómo hacerlo: es que ese diseño no protege nada y la llamada tiene que pasar por un backend.

---

## 6. La caja de herramientas: qué pregunta responde cada comando

Lo primero, antes que cualquier otra cosa:

```bash
# 👁️ ¿A QUÉ CLUSTER le estoy hablando? Es la primera línea que se escribe
# siempre. Un kubectl apuntando al contexto equivocado es la forma más rápida
# de tener un mal día. Ver §8.
kubectl config current-context

# 👁️ Todos los contextos configurados, con una estrella en el activo.
kubectl config get-contexts

# 👁️ ¿Tengo permiso para lo que voy a intentar? Responde yes o no, sin hacerlo.
kubectl auth can-i get pods -n lab-frontend
kubectl auth can-i delete deployment -n lab-frontend
```

Y la tabla, que es lo que se consulta con prisa:

| Pregunta | Comando | |
|---|---|---|
| ¿Qué hay corriendo y en qué estado? | `kubectl get pods -n lab-frontend` | 👁️ |
| ¿En qué nodo y con qué IP? | `kubectl get pods -n lab-frontend -o wide` | 👁️ |
| ¿Y ahora? (se queda mirando) | `kubectl get pods -n lab-frontend -w` | 👁️ |
| **¿Pudo el cluster hacer su trabajo?** | `kubectl describe pod <pod> -n lab-frontend` | 👁️ |
| **¿Qué dijo el proceso antes de morir?** | `kubectl logs <pod> -n lab-frontend --previous` | 👁️ |
| ¿Qué está diciendo ahora? | `kubectl logs -f <pod> -n lab-frontend --tail=50` | 👁️ |
| Los logs de todas las réplicas a la vez | `kubectl logs -l app=lab-frontend -n lab-frontend --tail=20` | 👁️ |
| ¿Qué pasó últimamente en el namespace? | `kubectl get events -n lab-frontend --sort-by=.lastTimestamp` | 👁️ |
| ¿El Service llega a algún pod? | `kubectl get endpoints -n lab-frontend` | 👁️ |
| ¿Qué imagen corre de verdad? | `kubectl get pod <pod> -n lab-frontend -o jsonpath='{..imageID}'` | 👁️ |
| El manifiesto tal como quedó en el cluster | `kubectl get deployment lab-frontend -n lab-frontend -o yaml` | 👁️ |
| ¿Cuánta memoria y CPU consume? | `kubectl top pod -n lab-frontend` | 👁️ |
| Probar la aplicación saltándose el Ingress | `kubectl port-forward -n lab-frontend service/lab-frontend 8080:80` | 👁️ |
| Mirar dentro del contenedor | `kubectl exec -it <pod> -n lab-frontend -- sh` | 👁️ * |
| Reiniciar los pods para que relean el ConfigMap | `kubectl rollout restart deployment/lab-frontend -n lab-frontend` | ✍️ |
| Ver cómo va una actualización | `kubectl rollout status deployment/lab-frontend -n lab-frontend` | 👁️ |
| Volver a la versión anterior | `kubectl rollout undo deployment/lab-frontend -n lab-frontend` | ✍️ |
| Aplicar un manifiesto | `kubectl apply -f k8s/` | ✍️ |

\* `exec` no modifica ningún objeto del cluster, pero **sí puede modificar el contenedor**: lo que escribas ahí dentro es real hasta que el pod muera. Entra a mirar, no a arreglar.

**Los cuatro que valen por todos los demás.** `describe` te dice lo que el **cluster** piensa del pod —si consiguió la imagen, si el nodo tenía sitio, cuántas veces lo reinició— y su sección **Events**, al final, es lo primero que hay que leer. `logs --previous` te da la salida del **contenedor muerto**, que sin ese flag no ves nunca en un `CrashLoopBackOff`. `get endpoints` responde en una línea si el Service alcanza algún pod, que es la frontera entre "problema de aplicación" y "problema de etiquetas". Y `port-forward` **bisecciona**: si por el túnel la aplicación responde, todo lo que está de ahí hacia dentro funciona y el problema es del Ingress hacia fuera.

> 💡 **Cómo pedir ayuda sin quedar mal.** Si no tienes acceso, pide exactamente esto: *"¿me pasas el `describe` del pod y los `logs --previous`?"*. Estás pidiendo dos cosas concretas y de solo lectura, y quien opere el cluster va a notar que sabes qué preguntar. Pedir "¿me miras qué pasa?" produce una captura de `get pods` que no dice nada.

---

## 7. Estados de un pod, traducidos

> 🕵️ **Qué comando contesta qué pregunta** —`describe` si nunca llegó a `Running`, `logs --previous` si arrancó y murió— está desarrollado en [`forense-fase-14.md`](forense-fase-14.md).

Lo que un dev de front recibe casi nunca es un YAML: es un estado copiado en un mensaje de chat. Esta sección lo traduce.

Cada estado va con lo que significa, lo que **no** significa —que es donde se
pierde la gente— y dónde se mira.

**`Pending`**

Qué significa: ningún nodo lo ha aceptado todavía.
Qué no significa: que tu aplicación falle. Aún no ha arrancado.
Dónde miras: `describe`, sección Events. Suele ser que no hay recursos, que falta
un volumen, o que hay reglas de ubicación que ningún nodo cumple.

**`ContainerCreating`**

Qué significa: el nodo lo aceptó y está preparándolo.
Qué no significa: nada malo, si dura segundos.
Dónde miras: si dura minutos, está bajando la imagen o esperando un volumen.

**`ErrImagePull` / `ImagePullBackOff`**

Qué significa: no pudo traer la imagen.
Qué no significa: que la imagen no exista. Puede ser el nombre, el tag o las
credenciales (§3).
Dónde miras: `describe`, Events — ahí sale el `unauthorized` si es de permisos.

**`CrashLoopBackOff`**

Qué significa: se murió varias veces y el cluster espera antes de reintentar.
Qué no significa: **no es un diagnóstico.** Describe lo que hace el cluster, no
por qué.
Dónde miras: `logs --previous`, siempre.

**`Error`**

Qué significa: el contenedor terminó con código distinto de cero.
Qué no significa: que la culpa sea del cluster.
Dónde miras: `logs --previous`.

**`OOMKilled`** *(aparece en `describe`, bajo `Last State`)*

Qué significa: superó el límite de memoria y lo mataron.
Qué no significa: que tu aplicación tenga una fuga. Puede ser un `limits`
demasiado bajo, que es más frecuente.
Dónde miras: `describe` → `Last State: Terminated, Reason: OOMKilled`.

**`Running` pero `0/1` en READY**

Qué significa: corre y **no** pasa la `readinessProbe`.
Qué no significa: que esté sirviendo tráfico. El Service no le manda nada
mientras esté así.
Dónde miras: la ruta de la probe en el manifiesto (§2). Es el caso donde el
manifiesto ajeno responde la pregunta.

**`Completed`**

Qué significa: el proceso terminó bien y no volvió a arrancar.
Qué no significa: un fallo — salvo que sea un servidor web, y entonces terminar
**es** el fallo. Es lo que le pasa a un nginx lanzado sin `daemon off`.
Dónde miras: `logs`.

**`Evicted`**

Qué significa: el nodo se quedó sin recursos y lo desalojó.
Qué no significa: un problema de tu imagen.
Dónde miras: `describe`, y después a quien opere el cluster: no es tuyo.

**`Terminating` que no termina**

Qué significa: está esperando a cerrar, o a que se libere algo.
Qué no significa: que tu proceso esté colgado, necesariamente.
Dónde miras: `describe`. Suele ser un finalizador pendiente o un cierre lento.

**Los códigos de salida que aparecen en `describe`:** `0` terminó bien, `1` error genérico de la aplicación, `137` lo mataron con SIGKILL —casi siempre OOM—, `143` recibió SIGTERM y se cerró, `126`/`127` no pudo ejecutar el comando de arranque. Y uno que en este curso tiene nombre propio: si los logs dicen **`exec format error`**, la imagen es de otra arquitectura que el nodo —el caso de Apple Silicon de la **Fase 14 §5.1**—, y el mensaje no menciona la palabra arquitectura por ningún lado.

> 🧠 **La mentira que te va a contar la pantalla:** `CrashLoopBackOff` parece una causa y es un comportamiento. Significa literalmente *"esto se murió varias veces, voy a esperar un poco antes de volver a intentarlo"*. La causa está siempre una capa más abajo: en los Events del `describe`, o en los logs del contenedor **anterior**. Quien te lo reporta cree que te está dando un diagnóstico; te está dando un síntoma.

---

## 8. ⚠️ Antes de acercarte al cluster real

Esta sección es obligatoria y es la razón por la que este apéndice existe. Tres documentos del curso —**Fase 13 §5.6**, **Fase 14 §5.5** y el cierre de la **Fase 14**— dejan su advertencia apuntando acá.

**Lo que probaste en kind es un Kubernetes permisivo.** kind no aplica políticas de seguridad por defecto: tu pod corrió como root, escuchando en el puerto 80, con el sistema de archivos escribible, y nadie se quejó. **De ahí no se sigue que funcione en la empresa.** Un cluster corporativo suele aplicar los **Pod Security Standards** en nivel `baseline` o `restricted` —que reemplazaron a las PodSecurityPolicy, retiradas en Kubernetes 1.25— y esos niveles rechazan cosas que tu imagen hace hoy.

**Las cuatro que rompen esta imagen concreta**, en orden de probabilidad:

- **`runAsNonRoot: true`.** La imagen de la Fase 13 parte de `nginx:stable-alpine`, que corre como root. Con esta política, el pod **ni siquiera arranca**: el cluster lo rechaza antes, con un mensaje sobre el usuario y no sobre nginx.
- **Puertos por debajo de 1024.** Un proceso sin privilegios no puede escuchar en el 80. La salida habitual es la imagen `nginxinc/nginx-unprivileged`, que escucha en el **8080** — y eso te obliga a cambiar tres cosas a la vez: el `EXPOSE` del Dockerfile, el `listen` del `nginx.conf` y el `containerPort` del Deployment, más el `targetPort` del Service. Es el ejercicio 28 de la **Fase 13**.
- **`readOnlyRootFilesystem: true`.** Aquí es donde duele: el `entrypoint.sh` de la Fase 13 **escribe** `config.json` al arrancar, y con el sistema de archivos de solo lectura eso falla con `Read-only file system`, el `set -e` corta y el contenedor muere antes de servir un byte. Es exactamente el fallo del experimento forense de la **Fase 14 §6**, con otra causa y el mismo síntoma. La salida es montar un `emptyDir` escribible sobre la carpeta donde escribe —y nginx además necesita escribir en su caché y en su directorio de ejecución.
- **Cuotas de recursos.** Un namespace con `ResourceQuota` puede rechazar un pod que no declare `resources.requests`. Tu Deployment no los declara (💸 **Fase 14 §5.5**), así que en ese cluster no se admite y el mensaje habla de la cuota, no de tu YAML.

**Y dos formas de estropear el día que no tienen nada que ver con la imagen.** La primera: **el contexto equivocado.** `kubectl` recuerda el último cluster al que apuntaste, y un `apply` o un `delete` escrito con confianza en la terminal equivocada es la anécdota que todo el mundo tiene. Escribe `kubectl config current-context` **antes** de cualquier comando ✍️, sin excepción, aunque estés seguro. La segunda: **editar en caliente.** Un `kubectl edit` o un `kubectl scale` sobre el cluster real desaparece en el siguiente despliegue del pipeline, porque el estado deseado vive en el repositorio de manifiestos y no en lo que tú escribiste. Peor todavía: entre tanto, nadie sabe por qué el cluster no coincide con el repositorio.

> 🧭 **La regla, y con esto cierra el apéndice.** El cluster de la empresa tiene particularidades que ningún libro cubre —políticas propias, un registry con sus credenciales, namespaces con cuotas, redes con reglas, y decisiones que se tomaron por razones que no están escritas—. **Antes de improvisar sobre él, pregunta al equipo de plataforma.** No es cortesía ni jerarquía: es que la mitad de lo que necesitas saber no está en la documentación de Kubernetes sino en la cabeza de esa gente, y una pregunta de dos minutos ahorra una tarde de todos. Lo que sí puedes llevar a esa conversación —y es mucho— es el vocabulario de §4, la lectura del manifiesto de §2 y los dos comandos de §6 que hacen las preguntas correctas.

---

## 🧭 Cuándo usar qué

| Situación | Qué haces | Por qué |
|---|---|---|
| Te pasan un YAML y tienes que opinar en diez minutos | Los seis campos de §2, en ese orden | El resto es contexto |
| Te pasan un chart de Helm | Pide el YAML renderizado (`helm template`) | Discutir una plantilla es discutir algo que nadie vio |
| "Tu pod está en `CrashLoopBackOff`" | `describe` y `logs --previous` (§6, §7) | El estado es un síntoma, no una causa |
| "El pod no encuentra la imagen" | ¿Llegó la imagen al registry que el cluster mira? (§3) | Casi nunca es el YAML |
| "Desplegué tu arreglo" y no lo ves | Compara **digests**, no tags (§3) | El tag se puede mover; el digest no |
| Los pods están `Running` y la página no carga | `kubectl get endpoints` (§6) | Sin endpoints es un problema de etiquetas, no de red |
| La página carga por `port-forward` y no por el host | El problema está del Ingress hacia fuera | `port-forward` bisecciona en diez segundos |
| Cambiaste el ConfigMap y nada cambió | `rollout restart` ✍️, o pídelo (§5) | Las variables de entorno se leen al arrancar |
| El pod se reinicia solo, sin errores en logs | La ruta de la `readinessProbe`/`livenessProbe` (§2) | Puede apuntar a algo que tu SPA no sirve |
| Necesitas una credencial en el front | **No.** Rediseñar: eso pasa por un backend (§5) | Lo que llega al navegador es público |
| Vas a correr algo que escribe (✍️) | `kubectl config current-context` primero (§8) | El contexto equivocado es el error caro |
| Te piden desplegar en el cluster real | Preguntar a plataforma (§8) | Lo que kind permitió, el cluster real puede rechazarlo |

---

## ⚠️ Advertencias

**Lo que funcionó en kind no prueba que funcione en el cluster real.** kind es permisivo por defecto y el cluster corporativo probablemente no lo es: root, puerto 80 y sistema de archivos escribible son tres suposiciones de tu imagen que ese cluster puede rechazar (§8). "Ya lo probé en Kubernetes" es una frase que hay que decir con el apellido: *en un Kubernetes permisivo*.

**Un Secret no está cifrado, está codificado.** Base64 se revierte en un segundo con acceso de lectura al namespace. Y en un front, además, todo lo que acaba en `config.json` es público por definición (§5).

**Un estado de pod no es un diagnóstico.** `CrashLoopBackOff`, `Pending` e `ImagePullBackOff` describen lo que el cluster está haciendo, no por qué. La causa está siempre en los Events del `describe` o en los logs del contenedor anterior (§7).

**Los objetos no se conectan por nombre, se conectan por etiqueta.** Y una etiqueta que no coincide no produce error: produce silencio. Pods `Running`, Service sin endpoints, página que no carga y cero mensajes en ningún lado (§1).

**El contexto de `kubectl` es persistente y no te avisa.** Recuerda el último cluster al que apuntaste, incluso entre sesiones de terminal. Antes de cualquier comando que escriba, comprueba dónde estás parado (§6, §8).

**Los cambios en caliente se pierden y confunden.** Un `edit` o un `scale` a mano sobre el cluster real desaparece en el siguiente despliegue del pipeline, y mientras tanto nadie entiende por qué el cluster no coincide con el repositorio. El estado deseado vive en los manifiestos.

**Y la que gobierna a todas: pregunta antes de improvisar sobre el cluster real.** El equipo de plataforma sabe cosas del ambiente que no están escritas en ninguna documentación, y esa conversación de dos minutos es la diferencia entre un despliegue y un incidente (§8).

---

## 📚 Referencias

- https://kubernetes.io/docs/concepts/workloads/pods/ — qué es un Pod y por qué es desechable. Es el concepto que sostiene todo lo demás.
- https://kubernetes.io/docs/concepts/workloads/controllers/deployment/ — Deployment, ReplicaSet y la mecánica del rolling update.
- https://kubernetes.io/docs/concepts/services-networking/service/ — Service, selectores y endpoints. La sección de selectores es la que corresponde al error más silencioso de §1.
- https://kubernetes.io/docs/concepts/services-networking/ingress/ — Ingress y por qué necesita un controller que lo ejecute.
- https://kubernetes.io/docs/concepts/configuration/configmap/ — ConfigMap, con la advertencia oficial de que no es sitio para secretos y la nota sobre montajes de solo lectura.
- https://kubernetes.io/docs/concepts/configuration/secret/ — Secret, sus tipos, y la frase que conviene citar en una reunión: los Secrets se guardan **sin cifrar** en el almacén de la API salvo que quien administre el cluster habilite el cifrado en reposo (§5).
- https://kubernetes.io/docs/concepts/security/pod-security-standards/ — los niveles `privileged`, `baseline` y `restricted`. Es lo que aplica el cluster real y lo que kind no aplica (§8).
- https://kubernetes.io/docs/tasks/debug/debug-application/debug-running-pod/ — `describe`, `logs`, `logs --previous` y `exec`. La página que hay que tener abierta cuando un pod no arranca.
- https://kubernetes.io/docs/reference/kubectl/quick-reference/ — la chuleta oficial de `kubectl`. Es la que reemplaza a la tabla de §6 cuando necesitas algo que no está.
- https://kubernetes.io/docs/concepts/containers/images/ — nombres de imagen, tags, digests y `imagePullPolicy`. El respaldo de §3.
- https://kind.sigs.k8s.io/docs/user/local-registry/ — el registry local para kind, que acerca el ejercicio al ciclo `build → push → pull` de la empresa (§3).
- https://kubernetes.io/docs/reference/access-authn-authz/rbac/ — RBAC, por si te preguntas por qué un comando te responde `Forbidden`.

> ⚠️ A diferencia del resto del curso, acá los enlaces apuntan a documentación **viva** de un proyecto que publica una versión menor cada pocos meses: los detalles de comandos y banderas envejecen. Lo que no se mueve son los objetos —Pod, Deployment, Service, ConfigMap, Secret, Ingress—, estables desde 2017-2018, y las preguntas de §6 y §7. Si un comando de este apéndice falla, sospecha primero de la versión de tu `kubectl` contra la del cluster: una versión menor de diferencia es tolerable, dos no.

**Orden de lectura sugerido:** si te acaban de pasar un YAML, §2 y nada más. Si te acaban de decir que tu pod no arranca, §7 para traducir el estado y §6 para saber qué pedir. Si vas a acercarte al cluster real por primera vez, **§8 completo antes de tocar nada**, y después la página de Pod Security Standards.

---

## 🧪 Ejercicios (8)

Cortos y de consulta. Los seis primeros corren contra el kind local de la **Fase 14**; los dos últimos son de lectura y se pueden hacer con cualquier YAML que te pasen. **Ninguno se hace contra el cluster de la empresa.**

1. Con el cluster de la Fase 14 levantado, escribe `kubectl get pods` **sin** `-n lab-frontend` y anota qué ves. Después con `-n`. Explica en una línea qué namespace estabas mirando la primera vez y por qué esa salida vacía se parece tanto a un despliegue fallido (§2).
2. Averigua con qué **digest** están corriendo tus pods usando el `jsonpath` de §3. Reconstruye la imagen cambiando una sola línea del `nginx.conf`, vuelve a etiquetarla con el **mismo** tag `1.0.0`, cárgala con `kind load` y anota si el digest de los pods cambió. Explica qué acabas de demostrar sobre confiar en los tags (§3).
3. Crea un Secret `Opaque` con una clave inventada, móntalo en el Deployment con `envFrom` y recupéralo decodificado con el comando de §5. Después entra al pod con `kubectl exec ... -- env` y encuéntralo también ahí. Anota los dos sitios desde los que se pudo leer y quién necesita qué permiso para cada uno.
4. Rompe el `selector` del Service cambiando `app: lab-frontend` por `app: lab-front`. Aplica y comprueba: los pods siguen `Running`, la página no carga y **no hay ningún error en ninguna parte**. Localízalo con `kubectl get endpoints` y escribe en tres líneas la regla general que te habría ahorrado el rato (§1, §6).
5. Provoca un `CrashLoopBackOff` a propósito: cambia el `command` del contenedor por algo que falle al instante, o monta el ConfigMap como volumen sobre `config.json` como hace la Fase 14 §6. Después, **sin leer la explicación**, llega a la causa usando solo `describe` y `logs --previous`, y anota qué te dio exactamente cada uno de los dos (§7).
6. Corre `kubectl get events -n lab-frontend --sort-by=.lastTimestamp` justo después de un `rollout restart` y lee la secuencia completa: qué se creó, qué se terminó y en qué orden. Compárala con lo que muestra `kubectl get pods -w` en paralelo y anota qué información te da cada vista que la otra no (§6).
7. Toma el `deployment.yaml` de la Fase 14 y localiza los seis campos de §2 sin mirar la sección. Después escribe qué pasaría, exactamente, si cada uno estuviera mal: qué síntoma produciría y con qué comando lo detectarías. Seis campos, seis síntomas, seis comandos.
8. Te llega este mensaje en un canal: *"el pod de tu front lleva media hora en `Pending` en el namespace de UAT"*. Escribe la respuesta que mandarías: qué dos cosas pides, en qué orden, y por qué `Pending` te dice que el problema **no** está en tu imagen ni en tu código (§7, §8). Máximo cinco líneas — el ejercicio es la brevedad.


> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida: el código que
> explica lo escriben las fases, y un tag que no apunta a un cambio no marca
> nada. Lo que salga de leerlo se commitea con el prefijo de la fase desde la
> que llegaste (`f13: …`), para que su `git log --oneline --grep '^f13'`
> siga completo. Y si un ejercicio produjo una medición, el número va en el
> mensaje de un tag anotado (`ej/a09/3`), que es donde no se pierde. La
> convención completa —tags de fase, de ejercicio y de incidente— está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

- **El nivel de acceso real del equipo.** Este apéndice está escrito para un dev con **acceso de lectura** al cluster, marcando 👁️ y ✍️ cada comando. Si resulta que el equipo solo entrega el artefacto y no toca `kubectl`, §6 sobra y §2 y §7 se vuelven el centro; si resulta que despliega, falta un capítulo de "cómo no romper nada". Era el pendiente *"Acceso al cluster"* de `propuesta-fases-y-alcance.md` §8 y queda cerrado con esta decisión, revisable cuando alguien confirme el permiso real.
- **La imagen non-root, resuelta de verdad.** §8 explica qué rompe y por qué —usuario, puerto, sistema de archivos de solo lectura—, y el **ejercicio 28 de la Fase 13** pide hacerlo. Lo que nadie ha hecho todavía es dejar el `Dockerfile`, el `nginx.conf` y el Deployment ya migrados a `nginx-unprivileged` en el 8080 con su `emptyDir`. Es media tarde de trabajo y ahorraría el primer incidente de despliegue real → decisión de proyecto, o ejercicio 🔥 desarrollado en la **Fase 13**.
- **Probes y `resources` para esta imagen concreta.** La 💸 de la **Fase 14 §5.5** sigue sin pagarse, y §8 explica que una `ResourceQuota` puede rechazar el pod por eso. Qué ruta debería usar la `readinessProbe` de una SPA servida por nginx —y por qué `/index.html` y no `/`— da para media sección de un futuro Track B de operación.
- 🪦 **Cerrados al escribir este apéndice.** El **registry local con kind**, que la **Fase 14** ofrecía a "un ejercicio 🔥 o una sección corta de A09", quedó en §3. Y la advertencia obligatoria sobre el cluster real —delegada explícitamente por la **Fase 13 §5.6**, la **Fase 14 §5.5** y el cierre de la **Fase 14**— es la §8 completa.
