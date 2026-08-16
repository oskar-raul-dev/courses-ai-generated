# 🔥 Fase 14 — Ambiente "casi prod" con kind

> Tutorial Angular 8 — Laboratorio clínico · Fase 14 de 14 · **🔥 Opcional · sin horas**
> Depende de: Fase 13 · Habilita: cierre del curso
> Apéndices de apoyo: [A09 (Kubernetes para el dev de front)](./a09-kubernetes.md) · [A03 (Node y npm)](./a03-node-npm.md) · [A12 (dependencias en arm64)](./a12-arm64-m1.md) · [A13 (Docker + Colima en Apple Silicon)](./a13-docker-colima.md) · [Incidentes asociados](./cuaderno-incidentes.md): —

> 🔥 **Esta fase no es requisito del onboarding.** No ocupa horas del calendario y el líder la asigna a quien tenga interés en ver su imagen corriendo en un cluster de verdad. Si la saltas, el curso está completo igual: la Fase 13 cerró el Track A.

---

## 🎯 1. Propósito

Terminaste la Fase 13 con una imagen que se comporta como el ambiente que le toque según lo que le inyectes al arrancar. La probaste con `docker run -e API_URL=...` y viste el `config.json` cambiar sin recompilar. Perfecto. Pero en la empresa nadie levanta esa imagen con `docker run`: la levanta Kubernetes, con un YAML que escribió otra persona, en un nodo que no es tu máquina, y cuando algo falla lo que recibes no es una consola sino un pod en `CrashLoopBackOff` y un canal de Teams preguntando qué pasó.

Esta fase cierra esa brecha con la mínima ceremonia posible. Vas a levantar un Kubernetes local con **kind**, meterle **la imagen de la Fase 13 sin tocarle una línea**, y verla correr detrás de un Service y un Ingress, alimentada por un ConfigMap en vez de por un `-e`. No vas a aprender a operar un cluster —eso es otro oficio— sino a **reconocer las cinco piezas** que aparecen en cualquier YAML que te pasen y a saber dónde mirar cuando tu imagen no arranca.

La frase que quiero que te lleves es esta: *lo que se despliega no es tu código, es tu imagen; y lo que decide a qué ambiente pertenece no está adentro de la imagen, está afuera.* La Fase 13 te lo demostró con una variable de entorno. Esta te lo demuestra con un objeto del cluster.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `kind get clusters` responde `lab-cluster` y `kubectl get nodes` muestra un nodo en estado `Ready`.
- [ ] `kubectl get pods -n lab-frontend` muestra **dos** pods `Running`, corriendo la imagen `lab-frontend:1.0.0` que cargaste desde tu máquina —no una descargada de ningún registry, porque esa imagen no existe en ningún registry—.
- [ ] Abres `http://lab.local` en el navegador, filtras `config.json` en la pestaña Network, y ves el `apiUrl` que escribiste en el **ConfigMap**. La misma imagen de la Fase 13, alimentada por otro mecanismo, sin recompilar.
- [ ] `kubectl set image deployment/lab-frontend web=lab-frontend:1.1.0 -n lab-frontend` reemplaza los pods **de uno en uno**, y mientras corre `kubectl rollout status` la aplicación sigue respondiendo en el navegador. Después `kubectl rollout undo` te devuelve a la versión anterior.
- [ ] Provocaste a propósito un pod que no arranca y lo diagnosticaste sin adivinar: `kubectl describe pod` para el evento, `kubectl logs --previous` para el mensaje del contenedor muerto. Puedes decir en una frase qué información te dio cada uno.
- [ ] Puedes nombrar, sin mirar, qué hace cada uno de los cinco objetos que aplicaste y por qué el Service no sobra aunque el pod tenga IP.

---

## 🚫 3. Qué NO entra todavía

- El **cluster real de la empresa**. Todo lo de acá corre contra un kind local y desechable. Contra el cluster de verdad no se improvisa: la advertencia completa —qué rechaza un cluster con Pod Security Standards, qué rompe de esta imagen y a quién preguntar— está en el **Apéndice A09 §8**.
- **Helm, Kustomize y operadores** → **fuera de alcance del curso**. Acá los manifiestos son YAML plano aplicado con `kubectl apply -f`. Cuando en la empresa te muestren un chart de Helm, lo que estás viendo son estos mismos objetos con plantillas encima.
- **Probes de liveness y readiness, `resources.limits` y `requests`** → 💸 deuda intencional declarada en §5.5. No se pagan acá.
- **Secrets, RBAC, NetworkPolicies, autoescalado, volúmenes persistentes** → **Apéndice A09 §4** para el vocabulario y **§5** para el detalle de Secrets (incluido por qué base64 no protege nada); la operación real, fuera de alcance.
- **Publicar la imagen en un registry** y que el cluster la descargue. Acá la imagen viaja de tu Docker al nodo de kind con `kind load`, que es un atajo que solo existe en kind. En el cluster real hay un registry de por medio y esa diferencia importa; se nombra en §4 y no se resuelve acá.
- **Meter json-server dentro del cluster.** El mock sigue corriendo en tu máquina, y en §4 vas a ver por qué eso no es una simplificación sino lo correcto.
- **CI/CD** —que alguien aplique estos manifiestos automáticamente en cada push— → fuera de alcance del curso.

---

## 🧠 4. Concepto mínimo

### El problema antes que la herramienta

Tienes una imagen y quieres que corra en algún lado que no sea tu portátil. Si lo pensaras desde cero, la lista de cosas que hacen falta te saldría sola: alguien tiene que **arrancar el contenedor** en alguna máquina; alguien tiene que **volver a arrancarlo** si se cae; si esperas más tráfico del que aguanta uno, alguien tiene que arrancar **varios** y repartir las peticiones; y como esos varios van naciendo y muriendo con IPs distintas, hace falta **un nombre estable** al que dirigirse. Y como la imagen es la misma en todos los ambientes, hace falta un lugar **fuera de la imagen** donde vivan los valores que cambian.

Kubernetes es una respuesta a esa lista, y cada elemento de la lista tiene un objeto con nombre propio. No hay magia; hay vocabulario. Eso es lo único que esta fase te pide aprender.

### Las cinco piezas, en el orden en que las vas a necesitar

Un **Pod** es la unidad mínima que Kubernetes sabe arrancar: uno o más contenedores que comparten red y ciclo de vida. En nuestro caso, un pod es un contenedor de nginx sirviendo tu `dist`. Los pods son **desechables por diseño**: nacen, mueren, y cuando vuelven tienen otra IP y otro nombre. Nunca le hablas a un pod por su nombre, igual que nunca guardarías el número de un empleado temporal como si fuera el teléfono de la empresa.

Un **Deployment** es la declaración de lo que quieres que exista: *"quiero dos pods con esta imagen y esta configuración"*. Tú no arrancas pods; declaras un Deployment y el cluster se ocupa de que el número coincida. Si matas un pod a mano, aparece otro en segundos. Esta es la diferencia mental más grande con `docker run`: en Docker das órdenes, en Kubernetes describes un estado deseado y el cluster trabaja para alcanzarlo. Entre el Deployment y los pods hay una capa intermedia, el **ReplicaSet**, que es la que hace posible el rolling update: al cambiar la imagen, el Deployment crea un ReplicaSet nuevo y va moviendo pods del viejo al nuevo de a poco. Vas a verlo con tus ojos en §5.9.

Un **Service** es el nombre estable que le falta a los pods. Es una dirección interna del cluster que reparte el tráfico entre todos los pods que coincidan con una etiqueta. Los pods cambian; el Service no. Cuando en §5.6 te preguntes por qué no le hablas directo al pod si tiene IP, la respuesta es: porque esa IP tiene la vida de un pod, y los pods duran lo que duran.

Un **ConfigMap** es un objeto del cluster que guarda pares clave-valor. Es donde vive `API_URL` ahora que ya no vive en un `-e` de tu terminal. Lo importante no es el objeto sino lo que representa: **la configuración es un objeto del cluster, no un contenido de la imagen**, que es exactamente la lección de la Fase 13 vista desde el otro lado del despliegue.

Un **Ingress** es la puerta de entrada desde fuera del cluster: una regla que dice *"lo que llegue al host `lab.local` mándalo a este Service"*. Detrás del Ingress hay un **ingress controller**, que en nuestro caso es —y esto confunde a todo el mundo la primera vez— **otro nginx**. Habrá dos nginx en juego: el ingress controller, que decide a qué Service va cada petición, y el nginx de tu imagen, el de la Fase 13, que sirve los archivos y hace el `try_files`. Son procesos distintos, en contenedores distintos, con configuraciones distintas. Cuando algo falle, la primera pregunta útil es *"¿cuál de los dos nginx me está contestando?"*.

### El tropiezo que tiene todo el mundo: el nodo no ve tus imágenes

Este merece su propio párrafo porque te va a pasar, y porque es la primera cosa que enseña de verdad cómo funciona esto.

Tu imagen `lab-frontend:1.0.0` está en el daemon de Docker de tu máquina. El nodo de kind es **otro contenedor**, con su propio runtime adentro, y ese runtime no tiene ninguna forma de mirar dentro del tuyo. Así que cuando apliques un Deployment que pide `lab-frontend:1.0.0`, el cluster hará lo único que sabe hacer: salir a buscarla a un registry, no encontrarla, y dejarte el pod en `ErrImagePull` primero y `ImagePullBackOff` después.

kind resuelve esto con `kind load docker-image`, que copia la imagen de tu Docker al nodo. Es un atajo que **solo existe en kind**; en el cluster real hay un registry corporativo y tu imagen tiene que estar publicada ahí antes de que ningún Deployment pueda pedirla. Vale la pena que lo tengas claro desde ahora: si algún día alguien dice *"el pod no encuentra la imagen"*, la pregunta no es qué YAML está mal, es **si la imagen llegó al sitio donde el cluster la busca**.

Y hay un segundo detalle que se cuela en el mismo error: si tu imagen lleva el tag `latest`, la política de descarga por defecto de Kubernetes es `Always` —salir a buscarla siempre, aunque ya esté en el nodo—, y entonces `kind load` no te sirve de nada. Por eso vamos a etiquetar con versiones explícitas y a poner `imagePullPolicy: IfNotPresent`.

### El pod no llama al API; el navegador sí

Esta la vas a agradecer, porque es la trampa que se lleva a más gente que viene de backend.

Cuando configuras `API_URL=http://localhost:3000`, el instinto de backend dice: *"pero `localhost` dentro del pod es el pod, no mi máquina; esto no puede funcionar"*. Y es un razonamiento impecable... para un backend. Acá está equivocado, porque **el pod nunca llama al API**. El pod sirve archivos estáticos y se calla. El que hace las peticiones al `apiUrl` es el **navegador de quien abre la aplicación**, y su `localhost` es tu máquina, donde json-server sigue corriendo tan tranquilo desde la Fase 4.

Es decir: `http://localhost:3000` es el valor **correcto**, y `http://host.docker.internal:3000` —que es lo que te va a pedir el cuerpo escribir— es el error. Guárdate la regla general, porque aplica a cualquier front en contenedor: **la configuración de una SPA se resuelve en el navegador del usuario, no en el pod**, así que las direcciones que pongas en el `config.json` tienen que ser alcanzables desde el navegador, no desde el cluster.

> 📝 **Nota de época — al revés que todo el curso.** Todo lo demás en este tutorial está congelado en 2019 a propósito. Esta fase no: kind y Kubernetes son herramientas vivas y las versiones que fijo abajo envejecen en meses, no en años. Aquí sí quiero que uses lo que tengas instalado y verifiques contra la documentación actual. Los cinco objetos que aprendes —Pod, Deployment, Service, ConfigMap, Ingress— llevan estables desde 2017 y no se van a mover; los números de versión y las URLs de los manifiestos, sí.

---

## 💻 5. Código mínimo con comentarios

Todos los manifiestos viven en una carpeta `k8s/` en la raíz del proyecto, junto al `Dockerfile` de la Fase 13. Cinco archivos y ninguna herramienta más que `kubectl`.

**Versiones con las que está escrita esta fase** —verifícalas, no las heredes de memoria—:

- **kind** `v0.20.0`
- Imagen de nodo **`kindest/node:v1.27.3`**
- **kubectl** `v1.27.x` (una versión menor de diferencia con el cluster es tolerable; dos, no)
- **ingress-nginx** `controller-v1.8.2`, manifiesto del proveedor `kind`
- Cualquier runtime de contenedores que ya tengas: Docker Desktop, Colima o Podman. kind no se ata a ninguno. En Apple Silicon, **el nodo hereda la arquitectura de la máquina virtual de tu runtime**, así que la imagen tiene que construirse para esa misma arquitectura: el **Apéndice A13 §7** explica cómo se elige al construir y el **§1** cómo se decide el perfil.

### 5.1 El punto de partida: la imagen de la Fase 13, intacta

No hay archivo nuevo acá. Hay una promesa que se cumple: **la imagen no se toca**. El `Dockerfile`, el `nginx.conf` y el `entrypoint.sh` de la Fase 13 se quedan exactamente como están, y todo lo que sigue trabaja alrededor de ellos.

Lo único que cambia es que ahora la etiquetamos con una versión explícita, porque en §5.9 vamos a necesitar dos imágenes distinguibles:

```bash
# Construimos igual que en la Fase 13, pero con un tag versionado. Nada de
# :latest: con latest, Kubernetes intenta descargar la imagen siempre y el
# kind load de más abajo no sirve de nada. Ver §5.5.
docker build -t lab-frontend:1.0.0 .
```

> ⚠️ **Apple Silicon.** kind corre el nodo sobre tu mismo runtime, así que el nodo es de la arquitectura de tu máquina. Si construiste la imagen para `amd64` estando en un Mac con chip M —o al revés—, el pod arranca, muere al instante y queda en `CrashLoopBackOff`, y el mensaje que vas a encontrar en los logs es `exec format error`, que no menciona la palabra "arquitectura" por ningún lado. Construye en nativo o revisa el **Apéndice A13 (Docker + Colima en Apple Silicon)**; si además tienes dependencias que no compilan en arm64, el **Apéndice A12** es el que necesitas — y su §1 es la primera parada, porque en una máquina con chip M la arquitectura de tu Node no es necesariamente la de tu procesador.

### 5.2 `k8s/kind-cluster.yaml` — el cluster, decidido antes de crearlo

```yaml
# k8s/kind-cluster.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    # El ingress controller solo se instala en nodos que lleven esta etiqueta.
    # Es el contrato que espera el manifiesto oficial de ingress-nginx para kind:
    # sin esta línea, el controller queda Pending para siempre y el síntoma es
    # "aplique el Ingress y no pasa nada", que no apunta a ningun lado.
    kubeadmConfigPatches:
      - |
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
    # Sin esto, el puerto 80 del nodo no se asoma a tu máquina y lab.local no
    # resuelve a nada. Es el equivalente al -p 8080:80 del docker run de la
    # Fase 13, pero a nivel de cluster.
    extraPortMappings:
      - containerPort: 80
        hostPort: 80
        protocol: TCP
      - containerPort: 443
        hostPort: 443
        protocol: TCP
```

**Detalles con intención:**

- Esta configuración **solo se puede aplicar al crear el cluster**. Ni la etiqueta del nodo ni el mapeo de puertos se pueden añadir después: si te olvidas, la única salida es borrar el cluster y crearlo de nuevo. Por eso este archivo va primero y no en medio.
- Un solo nodo `control-plane`. Un cluster multinodo en kind es posible y no aporta nada a lo que se enseña acá.
- Si el puerto 80 de tu máquina ya está ocupado —te lo dirá `kind create cluster` con un error de bind—, cambia el `hostPort` a `8080` y usa `http://lab.local:8080` en el resto de la fase.

### 5.3 Crear el cluster y meterle la imagen

```bash
# 1. El cluster. Tarda un minuto largo la primera vez: se descarga la imagen
#    del nodo, que pesa cerca de 1 GB.
kind create cluster --name lab-cluster --config k8s/kind-cluster.yaml

# 2. Confirmamos que kubectl esta apuntando al cluster correcto. kind cambia el
#    contexto activo por ti, y ese cambio silencioso es una fuente clasica de
#    "aplique el YAML y no aparece en ningun lado": lo aplicaste en otro cluster.
kubectl config current-context   # debe decir: kind-lab-cluster
kubectl get nodes                # un nodo, en estado Ready

# 3. El namespace donde vive todo lo nuestro. Un namespace es una carpeta
#    logica: separa nuestros objetos de los del sistema y del ingress controller.
kubectl create namespace lab-frontend

# 4. EL PASO QUE TODO EL MUNDO OLVIDA: copiar la imagen de tu Docker al nodo.
#    Sin esto, el pod queda en ErrImagePull y luego en ImagePullBackOff.
kind load docker-image lab-frontend:1.0.0 --name lab-cluster

# 5. Verificación honesta: preguntarle al nodo qué imágenes tiene.
docker exec -it lab-cluster-control-plane crictl images | grep lab-frontend
```

**El patrón a memorizar:** cuando un pod no arranca por la imagen, la pregunta nunca es *"¿qué está mal en mi YAML?"* sino *"¿la imagen está en el sitio donde el cluster la busca?"*. En kind ese sitio es el nodo y se llena con `kind load`. En el cluster real ese sitio es el registry corporativo y se llena con `docker push`. Es la misma pregunta con dos respuestas.

### 5.4 `k8s/configmap.yaml` — la configuración como objeto del cluster

```yaml
# k8s/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: lab-frontend-config
  namespace: lab-frontend
data:
  # Exactamente las tres variables que el entrypoint.sh de la Fase 13 espera.
  # Ni una más, ni con otro nombre: el contrato lo fijó la imagen y aquí solo
  # lo cumplimos. Si mañana la imagen aprende una cuarta variable, se añade
  # aquí y no se recompila nada.
  API_URL: "http://localhost:3000"
  ENVIRONMENT_NAME: "kind-local"
  FEATURE_DELIVERY_PDF: "true"
```

**Detalles con intención:**

- `API_URL` apunta a `localhost` **a propósito**, y no es un descuido de quien escribe desde su máquina. Repasa §4: el que hace la petición es el navegador, y su `localhost` es tu máquina, donde corre json-server. Poner `host.docker.internal` acá rompe la aplicación y es el ejercicio 9.
- `FEATURE_DELIVERY_PDF` va **entre comillas**. Los valores de un ConfigMap son cadenas siempre; sin comillas, el parser de YAML convierte `true` en booleano y `kubectl apply` te rechaza el manifiesto con un error de tipo que no dice "ponle comillas". El `envsubst` del `entrypoint.sh` lo escribirá sin comillas en el JSON, que es donde sí tiene que ser booleano.
- `ENVIRONMENT_NAME: kind-local` es deliberado: cuando alguien mire los logs de arranque del pod y lea `[entrypoint] config generada para ambiente: kind-local`, sabrá en un segundo que está mirando el cluster de juguete y no UAT. La línea de log que dejaste en la Fase 13 empieza a pagar aquí.

> ⚠️ **Un ConfigMap no es un lugar seguro.** Su contenido se guarda en claro y lo lee cualquiera con permiso sobre el namespace. Para eso está el objeto `Secret`, que tampoco cifra gran cosa por defecto pero al menos separa lo sensible en otro sitio. Acá no hay nada sensible —una URL y un flag— así que ConfigMap es lo correcto. El día que alguien proponga meter una credencial en uno de estos, la respuesta es no; el vocabulario completo está en el **Apéndice A09**.

### 5.5 `k8s/deployment.yaml` — el estado deseado

```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lab-frontend
  namespace: lab-frontend
spec:
  # Dos replicas para poder ver el rolling update de a pares en §5.9. Con una
  # sola, la actualización es un parpadeo y no se ve nada.
  replicas: 2
  selector:
    # Como el Deployment reconoce cuales pods son suyos. Tiene que coincidir
    # con las labels de la plantilla de abajo; si no coinciden, kubectl rechaza
    # el manifiesto (y menos mal, porque el síntoma en caliente sería peor).
    matchLabels:
      app: lab-frontend
  template:
    metadata:
      labels:
        app: lab-frontend
    spec:
      containers:
        - name: web
          image: lab-frontend:1.0.0
          # IfNotPresent: usa la imagen que ya esta en el nodo y no salga a
          # buscarla. Es OBLIGATORIO con kind load. Con el tag :latest el
          # default sería Always y el pod moriría en ImagePullBackOff con la
          # imagen ahi mismo, delante de sus narices.
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 80
          # Aquí pasa lo importante de toda la fase: las claves del ConfigMap
          # entran como variables de entorno del contenedor. El entrypoint.sh
          # de la Fase 13 las lee tal cual, sin enterarse de que hoy vienen de
          # Kubernetes y ayer venian de un -e en tu terminal. La imagen no
          # sabe donde corre, y esa ignorancia es exactamente el objetivo.
          envFrom:
            - configMapRef:
                name: lab-frontend-config
```

**💸 Deuda técnica intencional.** Este Deployment no tiene `livenessProbe`, ni `readinessProbe`, ni `resources.requests`, ni `resources.limits`. Lo correcto en un cluster real es que los cuatro existan: sin `readinessProbe`, el Service manda tráfico a pods que todavía no terminaron de arrancar y los usuarios ven errores durante cada despliegue; sin `resources`, el planificador no sabe cuánto pesa tu pod y lo coloca donde no cabe. **En Track A no se paga**, porque el objetivo de esta fase es que reconozcas las cinco piezas y sepas diagnosticar un arranque fallido, no que aprendas a poner un servicio en producción. Los valores correctos dependen del cluster real y los fija quien lo opera, no tú.

> ⚠️ **Este pod corre como root y a kind no le importa. Al cluster real, probablemente sí.** En la Fase 13 te advertí que la imagen usa `nginx:stable-alpine` como root y escucha en el puerto 80, y que el cluster de la empresa puede tenerlo prohibido. kind no aplica ninguna política de seguridad por defecto, así que aquí arranca sin quejarse. **No concluyas "ya lo probé en Kubernetes y funciona":** lo probaste en un Kubernetes permisivo. Esto es justamente lo que un ambiente "casi prod" **no** reproduce, y por eso el nombre de esta fase lleva "casi". La solución y a quién preguntar están en el cierre del **Apéndice A09**.

Aplicado y verificado:

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml

# -w se queda mirando: veras los pods pasar por Pending, ContainerCreating y
# Running. Ctrl+C para salir.
kubectl get pods -n lab-frontend -w

# La línea del entrypoint de la Fase 13, ahora en los logs del cluster.
# Confirma a que ambiente arranco esto sin abrir el navegador.
kubectl logs -n lab-frontend -l app=lab-frontend --tail=5
```

### 5.6 `k8s/service.yaml` — el nombre estable

```yaml
# k8s/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: lab-frontend
  namespace: lab-frontend
spec:
  # ClusterIP: visible solo dentro del cluster. La puerta de entrada desde
  # fuera la abre el Ingress de §5.7, no este objeto.
  type: ClusterIP
  # A que pods reparte. Es la misma label del Deployment: el Service no sabe
  # nada de Deployments, solo busca pods que lleven esta etiqueta. Por eso un
  # typo aquí da un Service con cero endpoints y una página que no carga sin
  # ningun error visible. Se diagnostica con kubectl get endpoints.
  selector:
    app: lab-frontend
  ports:
    - name: http
      # El puerto por el que se le habla al Service.
      port: 80
      # El puerto donde escucha el contenedor: el 80 de nginx de la Fase 13.
      targetPort: 80
```

Antes de montar el Ingress, verifica que la aplicación responde. `port-forward` abre un túnel directo entre tu máquina y el Service, saltándose todo lo demás:

```bash
kubectl apply -f k8s/service.yaml
kubectl port-forward -n lab-frontend service/lab-frontend 8080:80
```

Abre `http://localhost:8080` y navega. Si ves la aplicación, tu imagen, tu Deployment y tu Service están bien, y cualquier cosa que falle después es del Ingress. **Esta es la herramienta de bisección más útil de la fase:** cuando `lab.local` no cargue, `port-forward` te dice en diez segundos de qué lado del Ingress está el problema. Ctrl+C para cerrar el túnel.

### 5.7 `k8s/ingress.yaml` — la puerta de entrada

Primero el controller, que es quien hace el trabajo. El Ingress sin controller es un papel sin nadie que lo lea:

```bash
# El manifiesto oficial de ingress-nginx para kind. Verifica la versión actual
# en la documentación: esta URL apunta a un tag fijo a propósito, para que la
# fase siga funcionando cuando el manifiesto de arriba cambie.
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/kind/deploy.yaml

# Esperamos a que el controller este listo. Sin esta espera, el Ingress que
# aplicas a continuación se queda sin dirección asignada y parece roto cuando
# solo esta llegando temprano.
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s
```

```yaml
# k8s/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: lab-frontend
  namespace: lab-frontend
spec:
  # Cual controller atiende esta regla. En un cluster puede haber varios
  # (uno interno, uno publico); "nginx" es el que instala el manifiesto de
  # arriba. Omitirlo en un cluster con varios es pedir una loteria.
  ingressClassName: nginx
  rules:
    - host: lab.local
      http:
        paths:
          - path: /
            # Prefix y no Exact: la SPA tiene rutas profundas (/patients/42) y
            # todas tienen que llegar al mismo Service, que es donde el nginx
            # de tu imagen hace el try_files de la Fase 13. Con Exact solo
            # entraria la raiz y cualquier ruta profunda daria 404 del ingress:
            # el mismo síntoma del incidente 20, pero un nginx más arriba.
            pathType: Prefix
            backend:
              service:
                name: lab-frontend
                port:
                  number: 80
```

`lab.local` no existe para nadie. Hay que decírselo a tu máquina, añadiendo una línea al archivo de hosts —`/etc/hosts` en macOS y Linux, `C:\Windows\System32\drivers\etc\hosts` en Windows, y en los tres casos hace falta permiso de administrador—:

```
127.0.0.1   lab.local
```

```bash
kubectl apply -f k8s/ingress.yaml
kubectl get ingress -n lab-frontend
```

> ⚠️ **Los dos nginx.** A partir de acá hay dos en juego y confundirlos cuesta horas. El **ingress controller** decide a qué Service va cada petición y su configuración son las reglas del Ingress. El **nginx de tu imagen** sirve los archivos y hace el `try_files`; su configuración es el `nginx.conf` de la Fase 13. Un 404 puede venir de cualquiera de los dos y se distinguen por el cuerpo de la respuesta: el del controller trae una página que dice `nginx` a secas, el tuyo devuelve tu `index.html`. Cuando dudes, `port-forward` se salta el controller y te lo aclara.

### 5.8 Prueba de fuego

Abre `http://lab.local` en el navegador. Deberías ver la aplicación del laboratorio, con su login, su listado de pacientes y todo lo que construiste en trece fases.

Ahora la parte que importa. Abre la pestaña Network, filtra por `config.json` y mira la respuesta:

```json
{
  "apiUrl": "http://localhost:3000",
  "environmentName": "kind-local",
  "features": {
    "deliveryPdfEnabled": true
  }
}
```

Ese archivo no existía en la imagen. Lo escribió el `entrypoint.sh` de la Fase 13 en el arranque del pod, con valores que vinieron de un objeto del cluster que puedes editar con `kubectl` sin recompilar nada. **La imagen es byte por byte la misma que corriste con `docker run` en la Fase 13** —puedes verificarlo comparando el digest con `docker images --digests`—; lo único que cambió es de dónde salieron tres cadenas de texto.

Comprueba también que las rutas profundas sobreviven a un F5: entra a un paciente, recarga en `http://lab.local/patients/42/orders`, y confirma que la aplicación se vuelve a montar ahí. Si funciona, el `pathType: Prefix` del Ingress y el `try_files` de tu `nginx.conf` están colaborando bien, cada uno en su capa.

### 5.9 Rolling update: cambiar la versión sin que nadie lo note

Haz un cambio visible en la aplicación —el ejercicio 5 propone uno concreto— y construye una versión nueva:

```bash
docker build -t lab-frontend:1.1.0 .
kind load docker-image lab-frontend:1.1.0 --name lab-cluster
```

En una terminal, deja mirando el reemplazo. En otra, dispáralo:

```bash
# Terminal 1: el rollout en vivo, pod por pod.
kubectl rollout status deployment/lab-frontend -n lab-frontend -w

# Terminal 2: cambiar la imagen del contenedor "web" del Deployment.
kubectl set image deployment/lab-frontend web=lab-frontend:1.1.0 -n lab-frontend
```

Mientras corre, recarga `http://lab.local` varias veces. **No se cae.** El Deployment crea un ReplicaSet nuevo, levanta un pod con la versión nueva, espera a que esté listo, retira uno viejo, y repite. Con dos réplicas siempre hay al menos una atendiendo. Eso es un rolling update, y es la razón por la que el Deployment existe en vez de que arranques pods a mano.

Si te arrepientes:

```bash
# El historial de versiones del Deployment.
kubectl rollout history deployment/lab-frontend -n lab-frontend

# Volver a la anterior. Es el mismo mecanismo al reves: otro rolling update.
kubectl rollout undo deployment/lab-frontend -n lab-frontend
```

**Y ahora la trampa que se lleva a todo el mundo.** Edita el `API_URL` del ConfigMap y aplícalo:

```bash
kubectl apply -f k8s/configmap.yaml
```

Recarga el navegador y mira el `config.json`. **Sigue diciendo lo de antes.** No es un caché ni un error tuyo: las variables de entorno se leen **una vez, al arrancar el contenedor**, y el `entrypoint.sh` escribió el `config.json` en ese instante y no volvió a mirar. Cambiar el ConfigMap no toca a los pods que ya están corriendo. Hay que reemplazarlos:

```bash
# Reinicia los pods de forma escalonada, igual que un cambio de imagen.
kubectl rollout restart deployment/lab-frontend -n lab-frontend
```

**El patrón a memorizar:** *cambiar la configuración no despliega nada*. Es exactamente el mismo error de la Fase 13 con otra cara: allá era un `config.json` cacheado por el navegador, acá es un ConfigMap que los pods leyeron hace tres días. En los dos casos el síntoma es el mismo —la aplicación usa un valor viejo sin un solo error en consola— y en los dos casos la primera pregunta es *"¿esto llegó a arrancar de nuevo después del cambio?"*.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. `ImagePullBackOff` con la imagen construida en tu máquina.**
*Síntoma:* el pod nunca pasa de `ErrImagePull` / `ImagePullBackOff`, y `docker images` te confirma que la imagen existe. *Causa:* el nodo de kind no ve tu daemon de Docker, o tu imagen usa `:latest` y `imagePullPolicy` quedó en `Always`. *Fix mínimo:* `kind load docker-image lab-frontend:1.0.0 --name lab-cluster` y comprueba que el manifiesto lleva un tag versionado más `imagePullPolicy: IfNotPresent`. *Lo correcto en la empresa* es publicar la imagen en el registry corporativo; `kind load` no existe allá.

**2. La página no carga y el Service tiene cero endpoints.**
*Síntoma:* los pods están `Running` pero `http://lab.local` no responde, o `port-forward` conecta y devuelve error de conexión. *Causa:* el `selector` del Service no coincide con las labels de los pods —un typo en `app: lab-frontend`—. *Fix mínimo:* `kubectl get endpoints -n lab-frontend`; si la columna `ENDPOINTS` dice `<none>`, el selector está mal. Corrige la etiqueta y vuelve a aplicar. *El diagnóstico transferible:* un Service sin endpoints es siempre un problema de etiquetas, nunca de red.

**3. El Ingress existe pero `lab.local` no llega a ningún lado.**
*Síntoma:* `kubectl get ingress` muestra el objeto, y el navegador da "no se puede acceder al sitio" o un 404 de un nginx que no es el tuyo. *Causa:* tres candidatos, en este orden de probabilidad: falta la línea en el archivo de hosts; el ingress controller no está `Running`; o el cluster se creó sin los `extraPortMappings` de §5.2. *Fix mínimo:* `ping lab.local` para lo primero, `kubectl get pods -n ingress-nginx` para lo segundo, y para lo tercero no hay fix —hay que borrar el cluster y crearlo con el config correcto—. *Bisección:* si `port-forward` sí funciona, el problema está del Ingress hacia fuera y puedes ignorar todo lo demás.

**4. Cambié el ConfigMap y la aplicación sigue igual.**
*Síntoma:* el `config.json` servido no refleja el valor nuevo. *Causa:* los pods leyeron las variables al arrancar y nadie los reinició. *Fix mínimo:* `kubectl rollout restart deployment/lab-frontend -n lab-frontend`. *Lo correcto* en un despliegue serio es que el pipeline añada al Deployment una anotación con el hash del ConfigMap, de forma que cualquier cambio de configuración provoque un rollout automático; eso es material de CI/CD y está fuera de alcance.

### Pieza forense de esta fase

Lo que se depura acá es un pod que **no arranca**, que es la situación en la que un dev de front se queda más ciego: no hay consola del navegador, no hay Network, no hay nada de lo que aprendiste a usar en trece fases. Solo hay dos comandos, y hacen cosas distintas:

- **`kubectl describe pod <nombre> -n lab-frontend`** te cuenta lo que Kubernetes piensa del pod: si consiguió la imagen, si el nodo tenía sitio, cuántas veces lo reinició, y sobre todo la sección **Events** al final, que es la primera que hay que leer. Responde *"¿el cluster pudo hacer su trabajo?"*.
- **`kubectl logs <nombre> -n lab-frontend --previous`** te da la salida del contenedor **muerto**, no la del que está arrancando ahora. Responde *"¿qué dijo el proceso antes de morir?"*. Sin `--previous`, en un `CrashLoopBackOff` te va a devolver los logs de un contenedor que todavía no ha escrito nada y vas a concluir, equivocadamente, que el contenedor no dice nada.

**La mentira que te va a contar la pantalla:** `kubectl get pods` muestra `CrashLoopBackOff` y parece un diagnóstico. No lo es. `CrashLoopBackOff` significa literalmente *"esto se murió varias veces y voy a esperar un poco antes de volver a intentarlo"*: describe el comportamiento del cluster, no la causa. La causa está siempre una capa más abajo, en los eventos o en los logs del contenedor anterior.

#### 🧨 Rompe a propósito: el ConfigMap montado como volumen

Este es el experimento de la fase, y no es artificial: es lo primero que intenta cualquiera que ya conoce Kubernetes y quiere montar la configuración "como se debe".

La idea suena impecable: en vez de pasar variables de entorno, montar el `config.json` completo desde un ConfigMap directamente sobre la ruta donde la aplicación lo busca. Crea un ConfigMap con el JSON entero y añade el montaje al Deployment:

```yaml
# Solo el fragmento que cambia dentro de spec.template.spec del Deployment.
# NO lo dejes aplicado: esto se aplica, se observa, y se revierte.
      containers:
        - name: web
          image: lab-frontend:1.0.0
          imagePullPolicy: IfNotPresent
          volumeMounts:
            # subPath para reemplazar un único archivo y no toda la carpeta
            # assets, que se llevaria por delante los iconos y los diccionarios
            # de i18n de la Fase 2.
            - name: config-volume
              mountPath: /usr/share/nginx/html/assets/config.json
              subPath: config.json
      volumes:
        - name: config-volume
          configMap:
            name: lab-frontend-json
```

Aplícalo y mira qué pasa. **El pod entra en `CrashLoopBackOff`** y la aplicación desaparece.

Ahora diagnostícalo antes de seguir leyendo: `describe` primero, `logs --previous` después.

Lo que vas a encontrar es que el `entrypoint.sh` de la Fase 13 hace `envsubst ... > "$TARGET"`, donde `$TARGET` es exactamente el archivo que acabas de montar. **Los volúmenes de ConfigMap se montan como solo lectura**, así que la redirección falla con `Read-only file system`, el `set -e` de la primera línea del script corta la ejecución, el script termina con código distinto de cero, nunca se llega al `exec nginx`, y el contenedor muere antes de servir un solo byte. El `describe` te dice que reinició cinco veces; el `logs --previous` te dice por qué.

**El patrón a memorizar:** un contenedor que escribe en el arranque y un volumen de solo lectura sobre esa misma ruta son incompatibles, y el error que produce esa incompatibilidad no menciona ni al ConfigMap ni al volumen. Cuando heredes una imagen ajena, la pregunta antes de montarle nada encima es *"¿esta imagen escribe algo al arrancar, y dónde?"*. Aquí la respuesta está en tres líneas del `entrypoint.sh` que escribiste tú mismo hace una fase.

Revierte al Deployment de §5.5 —el de `envFrom`— y confirma con `kubectl get pods` que vuelven a estar `Running`.

> Esta técnica se desarrolla completa, con la salida transcrita y el árbol de decisión para pods que no arrancan, en [`forense-fase-14.md`](./forense-fase-14.md).

---

## 🧪 7. Ejercicios (15)

Menos que en el resto del curso, y es a propósito: esta fase es 🔥 opcional y no ocupa horas del calendario. Cinco de los quince son de diagnóstico. Todos corren contra tu kind local; **ninguno se hace contra el cluster de la empresa**.

**🟢 Fácil (1–4)**

1. Crea el cluster con `k8s/kind-cluster.yaml` y confirma con `kubectl get nodes` que hay un nodo `Ready` y con `kubectl config current-context` que estás apuntando a `kind-lab-cluster`. Después ejecuta `kind delete cluster --name lab-cluster` y vuelve a crearlo: quiero que el cluster te resulte desechable desde el primer minuto.
2. Aplica los cuatro manifiestos y consigue ver la aplicación en `http://lab.local`. Anota cuánto tardaste y en qué paso te trabaste; ese paso es el que vas a olvidar dentro de seis meses.
3. Cambia `ENVIRONMENT_NAME` a `demo-laboratorio` en el ConfigMap, aplica, reinicia el Deployment y confirma el valor nuevo en dos sitios distintos: los logs del pod (`kubectl logs`) y el `config.json` en la pestaña Network.
4. Sube `replicas` a 4, aplica, y usa `kubectl get pods -o wide -n lab-frontend` para ver los cuatro pods con sus IPs. Después mata uno con `kubectl delete pod <nombre>` y observa cuánto tarda en aparecer el reemplazo. Explica en una frase por qué apareció.

**🟡 Intermedio (5–8)**

5. Cambia la clave de i18n del título de la pantalla de listado de pacientes en los tres diccionarios, construye `lab-frontend:1.1.0`, cárgala con `kind load` y haz el rolling update. Mientras corre, recarga el navegador cada segundo y confirma que en ningún momento ves un error. Después vuelve atrás con `rollout undo` y verifica que el título viejo regresó.
6. Apaga json-server en tu máquina y recarga `http://lab.local`. La aplicación tiene que seguir cargando —los archivos estáticos los sirve el pod— pero el listado de pacientes debe mostrar el error con botón de reintento de la Fase 4. Explica por escrito por qué el pod sigue `Running` con el API caído: qué sabe el pod del API, exactamente.
7. Escribe un `k8s/README.md` de media página con el orden exacto de comandos para levantar todo desde cero en una máquina nueva, incluida la línea del archivo de hosts. Pruébalo borrando el cluster y siguiendo tus propias instrucciones sin improvisar. Si tuviste que improvisar, el documento está mal, no tu memoria.
8. Añade una segunda regla al Ingress para que el host `laboratorio.local` sirva la misma aplicación, y comprueba que los dos hosts funcionan. Explica por qué un solo Service basta para dos hosts.

**🟠 Difícil (9–12)**

9. 🔬 *Diagnóstico.* Cambia `API_URL` a `http://host.docker.internal:3000`, aplica y reinicia. La aplicación carga pero ningún dato del laboratorio aparece. Reproduce el fallo, localiza en qué capa está —pod, Service, Ingress, navegador o mock— y explica por qué `localhost` era el valor correcto y este no. Tu respuesta tiene que mencionar quién hace la petición HTTP.
10. 🔬 *Diagnóstico.* Recibes un Deployment donde el `selector.matchLabels` dice `app: lab-frontend` y las labels de la plantilla del pod dicen `app: labfrontend`. Los pods están `Running` y la página no carga. Localiza el fallo usando `kubectl get endpoints` y escribe la regla general de tres líneas que te habría ahorrado el rato.
11. 🔬 *Diagnóstico.* Ejecuta el experimento de §6 —el ConfigMap montado como volumen— sin volver a leer la explicación. Llega a la causa raíz solo con `describe` y `logs --previous`, y escribe el post-mortem en cuatro líneas: síntoma, qué te dijo cada comando, causa raíz, fix.
12. Quítale al `nginx.conf` de la Fase 13 la línea del `try_files`, construye `lab-frontend:1.2.0`, despliégala y recarga estando en `/patients/42/orders`. Diagnostica de cuál de los dos nginx viene el 404 y demuéstralo con evidencia, no con intuición. Después revierte con `rollout undo`.

**🔴 Muy difícil (13–15)**

13. 🔬 *Diagnóstico.* Levanta el cluster **sin** los `extraPortMappings` del `kind-cluster.yaml` y despliega todo lo demás correctamente. La aplicación funciona con `port-forward` y no funciona en `lab.local`. Escribe el diagnóstico completo: qué probaste, en qué orden, qué descartó cada prueba, y por qué este fallo concreto no se puede arreglar sin recrear el cluster.
14. Consigue que un cambio en el ConfigMap provoque el rollout **automáticamente**, sin `rollout restart` a mano. Pista: los pods se reemplazan cuando cambia la plantilla del pod, así que necesitas que algo de esa plantilla cambie junto con el ConfigMap. Escribe un script en `k8s/` que calcule el hash del ConfigMap, lo escriba como anotación en la plantilla del Deployment y aplique ambos. Documenta en dos líneas por qué esto es un parche y qué lo resuelve de verdad en un pipeline serio.
15. Levanta un segundo namespace, `lab-frontend-uat`, con la **misma imagen** y un ConfigMap con `ENVIRONMENT_NAME: uat` y otro `API_URL`, expuesto en `uat.lab.local`. Los dos ambientes tienen que convivir en el mismo cluster, corriendo el mismo digest de imagen, y comportarse distinto. Demuéstralo con dos pestañas del navegador abiertas y sus dos `config.json` en pantalla. Este ejercicio es toda la tesis del curso en una captura.

**🔥 Opcionales**

- 🔥 Añade `livenessProbe` y `readinessProbe` apuntando a `/index.html`, más `resources.requests` y `limits` conservadores. Después baja el `limits.memory` a un valor absurdo (`16Mi`) y observa qué le pasa al pod y qué te cuenta `kubectl describe` sobre `OOMKilled`. Es la deuda 💸 de §5.5, pagada por curiosidad.
- 🔥 Levanta json-server como un segundo Deployment y Service dentro del cluster, expuesto en `api.lab.local`, y apunta el `API_URL` ahí. Vas a chocar de frente con CORS y con el hecho de que ahora el mock es efímero: cada reinicio pierde los datos de las órdenes que cargaste.
- 🔥 Instala `k9s` y repite los ejercicios 9 a 12 sin escribir un solo `kubectl`. Compara honestamente cuál de las dos herramientas te hizo entender mejor lo que estaba pasando.
- 🔥 Escribe el mismo Deployment como un chart mínimo de Helm y explica, en cinco líneas, qué te dio Helm que el YAML plano no te daba. Si no encuentras nada, esa también es una respuesta válida para un proyecto de este tamaño.

---

## 📚 8. Referencias

**Documentación oficial**

- https://kind.sigs.k8s.io/docs/user/quick-start/ — instalación y `kind create cluster`. Documentación viva; verifica la versión de kind y las imágenes de nodo disponibles antes de copiar tags.
- https://kind.sigs.k8s.io/docs/user/ingress/ — la guía de la que sale el `kind-cluster.yaml` de §5.2, con el `ingress-ready=true` y los `extraPortMappings`. Léela antes de crear el cluster, no después.
- https://kind.sigs.k8s.io/docs/user/local-registry/ — el paso siguiente si te cansas de `kind load`: un registry local que se parece más a cómo funciona el cluster real.
- https://kubernetes.io/docs/concepts/workloads/controllers/deployment/ — Deployment, ReplicaSet y la mecánica exacta del rolling update. La sección "Updating a Deployment" es la que corresponde a §5.9.
- https://kubernetes.io/docs/concepts/services-networking/service/ — Service, selectores y endpoints. Si solo lees una sección, que sea la de los selectores: es el error 2 de §6.
- https://kubernetes.io/docs/concepts/configuration/configmap/ — ConfigMap, con la advertencia explícita de que no es un lugar para secretos y la nota sobre montajes de solo lectura que explica la pieza forense.
- https://kubernetes.io/docs/tasks/debug/debug-application/debug-running-pod/ — `describe`, `logs`, `logs --previous` y `exec`. Es la página que hay que tener abierta cuando un pod no arranca.
- https://kubernetes.io/docs/reference/kubectl/quick-reference/ — la chuleta de `kubectl`. Imprímela.
- https://kubernetes.github.io/ingress-nginx/deploy/#quick-start — el ingress controller, con los manifiestos por proveedor. Comprueba la versión: la URL de §5.7 apunta a `controller-v1.8.2` a propósito, y a estas alturas ya habrá salido algo posterior.

**Video / apoyo**

- Busca "kind kubernetes tutorial" o "kubernetes for frontend developers": hay crash courses de una hora que cubren exactamente estos cinco objetos. Los títulos y URLs cambian seguido, así que búscalos por concepto y descarta cualquiera que empiece por Helm —eso es la segunda clase, no la primera—.

**Orden de lectura sugerido:** antes de escribir un YAML, la guía de Ingress de kind (porque decide el `kind-cluster.yaml`, que no se puede cambiar después) y el **Apéndice A09** para el vocabulario. Durante, la referencia rápida de `kubectl` y la página de Deployment. Después, si tu pod no arranca, la página de debug de pods; y si vas a acercarte al cluster real, el cierre del A09 **antes** de tocar nada.

> ⚠️ A diferencia del resto del curso, aquí las URLs apuntan a documentación **viva** de herramientas que se mueven rápido: los números de versión de este capítulo envejecen en meses. Los conceptos —Pod, Deployment, Service, ConfigMap, Ingress— llevan estables desde 2017 y son lo que de verdad te llevas. Si un comando de esta fase falla, sospecha de la versión antes que del concepto.

---

## 🚀 9. Cierre y conexión con la siguiente fase

No hay fase siguiente. Esta era la última, y era opcional.

Lo que hiciste acá cabe en una frase: tomaste la imagen de la Fase 13, no le tocaste nada, y la pusiste a correr en un Kubernetes de verdad —pequeño, local y desechable, pero de verdad— alimentada por un objeto del cluster en vez de por una variable de tu terminal. Y viste el rolling update reemplazar los pods de a uno mientras la aplicación seguía respondiendo, que es la primera vez en todo el curso que ves un despliegue que no interrumpe a nadie.

Lo que **no** hiciste, y conviene que lo tengas igual de claro: no configuraste probes, ni límites de recursos, ni seguridad, ni un registry, ni un pipeline. Tu pod corrió como root porque kind se lo permitió. El cluster de la empresa es otra cosa, con otras reglas y con gente cuyo trabajo es cuidarlo. El valor de esta fase no es que ahora sepas desplegar en Kubernetes —no sabes, y está bien—, sino que cuando alguien te comparta un YAML sepas leerlo, y cuando alguien te diga *"tu pod está en CrashLoopBackOff"* sepas que eso no es un diagnóstico y sepas exactamente qué dos comandos pedir.

Con esto, el curso está cerrado. Las fases obligatorias construyeron una aplicación Angular 8 completa y el ojo para diagnosticarla cuando se rompe; esta última te enseñó a reconocer el sitio donde esa aplicación va a vivir. Lo que sigue no está en ningún capítulo: es el primer ticket real que te asignen. Y para ese, la herramienta que más te va a servir de todo el curso no es NgRx ni Kubernetes: es el hábito de preguntar *"¿qué me está mintiendo la pantalla?"* antes de tocar código.

> **La señal de que quedó bien:** "abro el YAML que me pasaron y reconozco las cinco piezas sin buscar en Google. Y cuando alguien me dice que mi pod está en CrashLoopBackOff, no pregunto qué hago: pido el `describe` y los logs del contenedor anterior, porque sé que la causa nunca está en el estado que me mostraron."


> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-14-casi-prod-kind -m "F14 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`f14: …`) y los de ejercicio su
> número (`f14 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f14/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
>
> Que la fase sea 🔥 opcional y no ocupe calendario no cambia nada acá: dejó
> manifiestos en el repositorio, y lo que cambió el repo se marca.

---

## 📌 Pendientes sugeridos

- **[`forense-fase-14.md`](./forense-fase-14.md)** — desarrollo completo del árbol de decisión para un pod que no arranca: `Pending` / `ImagePullBackOff` / `CrashLoopBackOff` / `Running pero sin responder`, con la salida de `describe` y de `logs --previous` transcrita en cada rama, y la tabla de qué comando responde qué pregunta.
- **Registry local con kind** — 🪦 Resuelto. El `kind load` es un atajo que no existe en el cluster real; el camino de verdad —registry, nombre completo de la imagen, tag contra digest, `imagePullSecrets`— quedó en el **Apéndice A09 §3**, con el enlace a la configuración del registry local. Montarlo sigue siendo un **ejercicio 🔥** de esta fase.
- **Anotación con hash del ConfigMap para rollout automático** — planteado como ejercicio 14. La solución correcta vive en un pipeline de CI/CD y está fuera de alcance del curso; anotado por si algún día ese alcance se amplía.
- **Correr como non-root en un cluster con Pod Security Standards** — heredado de la Fase 13 y **no resuelto acá**, porque kind no lo exige. El **Apéndice A09 §8** ya explica qué rechaza cada política y qué rompe de esta imagen concreta —usuario, puerto 80, sistema de archivos de solo lectura contra el `entrypoint.sh` que escribe—; lo que sigue abierto es dejar el `Dockerfile` y el Deployment ya migrados, que es el **ejercicio 28 de la Fase 13** y una decisión de proyecto.
- **Probes y `resources`** — 💸 declarada en §5.5 y ofrecida como ejercicio 🔥. El **Apéndice A09 §8** agrega el motivo por el que no es solo higiene: un namespace con `ResourceQuota` puede **rechazar** un pod que no declare `requests`. Si alguna vez el curso añade un Track B de operación, este es su primer capítulo.

### Reservas para el cuaderno de incidentes

Esta fase **no tiene incidentes asignados**: el índice de `cuaderno-incidentes.md` cierra en el 21 y esta fase es opcional, así que no consume ninguno. Un incidente que solo pueden resolver los estudiantes que hicieron una fase 🔥 no es un incidente del curso.

Queda un candidato anotado por si algún día se abre el 22, con esa misma salvedad:

- **22 (🔥 candidato, no dado de alta)** · Fase 14 · *"El pod arrancó bien y la aplicación le habla al ambiente equivocado"* · Categoría: despliegue · Dificultad 🟠 — alguien cambió el ConfigMap, nadie reinició el Deployment, y los pods siguen sirviendo el `config.json` que escribieron al arrancar hace tres días. Es el hermano en Kubernetes del incidente 19, con la misma moraleja y otro culpable: allá el caché del navegador, acá un pod que nunca releyó su configuración.
