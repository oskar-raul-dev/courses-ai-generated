# 🔥 Fase 14 — Ambiente "casi prod" con kind

> Tutorial Angular 16 — Inspecciones y certificaciones · Fase 14 de 14 · **sin horas asignadas**
> Depende de: Fase 13 (build y despliegue) · Habilita: ninguna
> Apéndices de apoyo: [A09 (Docker y Kubernetes)](a09-docker-kubernetes.md) · [A12 (arm64)](a12-arm64-m1.md) 🔥
> [Incidentes asociados](cuaderno-incidentes.md): ninguno
> Estilo de esta fase: infraestructura. **La aplicación no se toca ni una línea**

> 🔥 **Esta fase no es requisito del onboarding.** El curso se completa sin abrirla y el líder la asigna a quien tenga interés. No tiene horas en el calendario de 122h y no hay ninguna fase que dependa de ella.

---

## 🎯 1. Propósito

La Fase 13 dejó una imagen y una pregunta: si la configuración se inyecta al arrancar, ¿qué pasa cuando quien arranca el contenedor no eres tú con un `docker run`, sino un orquestador?

La respuesta es la razón de este capítulo y cabe en una frase: **no pasa nada, y eso es exactamente lo interesante**. El ConfigMap de Kubernetes hace el mismo trabajo que el `-e` del `docker run`: le pone variables de entorno al proceso. El `entrypoint.sh` de quince líneas que escribiste ayer sigue funcionando sin que le toques una coma, y la imagen que se carga en el cluster es **la misma**, con el mismo digest.

Ésa es toda la lección: **Kubernetes no resuelve el problema de la configuración horneada en tiempo de compilación**. Sólo cambia quién le pasa las variables al mismo script. Ocho versiones mayores de Angular, un contenedor y un orquestador después, la piedra sigue donde estaba — y si sales de aquí con esa idea, la fase cumplió.

Lo demás es vocabulario. Pod, Deployment, Service, ConfigMap, Ingress: cinco palabras que vas a leer en el manifiesto que alguien te pase el primer día en un equipo con cluster, y que conviene poder leer sin fingir.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `kind get clusters` lista un cluster llamado `certcore`, creado con los mapeos de puerto que el Ingress necesita.
- [ ] `kubectl get pods` muestra dos pods corriendo: la aplicación y el mock.
- [ ] `http://localhost/` abre CertCore servido desde el cluster, y la toolbar dice el ambiente que el ConfigMap le dio.
- [ ] Cambias el ConfigMap, reinicias el Deployment, y la toolbar dice otra cosa — **sin reconstruir la imagen y sin tocar el `entrypoint.sh`**.
- [ ] `docker inspect` de la imagen local y la que corre en el cluster dan el mismo digest. Es la misma, no una parecida.
- [ ] Haces un rolling update en vivo y ves los pods reemplazarse de uno en uno, sin que la página deje de responder.
- [ ] Provocaste un pod que no arranca y llegaste a la causa con `kubectl describe` y `kubectl logs`, sabiendo cuál de los dos mirar primero.
- [ ] `git tag` lista `fase-14`, si decidiste que esta fase lleva tag — la sección 9 te dice por qué es una decisión y no una obligación.

---

## 🚫 3. Qué NO entra todavía

- **El cluster real de tu empresa** → fuera de alcance, y la advertencia importa: un cluster de verdad tiene políticas, cuotas, namespaces con permisos y una red que no se parece a ésta. **A09** cierra con la nota obligatoria de preguntarle al equipo de plataforma antes de improvisar, y la primera cosa que te van a decir es que tu contenedor no puede correr como root — que es la 💸 que la Fase 13 dejó sin pagar.
- **Helm, Kustomize, operadores y service mesh** → fuera de alcance. Son capas encima de lo que este capítulo enseña, y ninguna se entiende sin esto debajo.
- **Autoescalado, `HorizontalPodAutoscaler` y métricas** → fuera de alcance. Necesitan un servidor de métricas y un problema de carga que este sistema no tiene.
- **Persistencia** → no hace falta. La aplicación es estática y el mock escribe en `db.json` dentro del pod, que se pierde al reiniciarlo. **Eso es correcto aquí y sería un bug en producción**, y el ejercicio 13 te hace decidir qué harías con un backend de verdad.
- **TLS, Ingress con certificados y DNS** → fuera de alcance, igual que en la Fase 13. `http://localhost` y punto.
- **Probes finas, límites de recursos y presupuestos de interrupción** → es la 💸 de esta fase y **no se paga**.

---

## 🧠 4. Concepto mínimo

### El problema, antes que la herramienta

Tienes dos contenedores corriendo con `docker run` y funcionan. ¿Qué te falta?

Nada, mientras nadie los apague. Si el contenedor de la aplicación muere a las tres de la mañana, sigue muerto a las nueve. Si necesitas dos copias para repartir carga, las levantas a mano y te acuerdas de las dos. Si quieres desplegar una versión nueva sin cortar el servicio, tienes que orquestar tú el reemplazo: levantar la nueva, comprobar que responde, mover el tráfico, apagar la vieja.

**Un orquestador es alguien que hace eso por ti y no se olvida.** Le describes el estado que quieres —*"quiero dos copias de esta imagen, escuchando aquí, con esta configuración"*— y él se encarga de que ese estado sea cierto ahora y dentro de seis meses. No le das órdenes; le das una descripción, y él calcula la diferencia.

Ésa es la única idea de fondo de Kubernetes y todo lo demás son sustantivos:

**Pod** — uno o más contenedores que comparten red y ciclo de vida. Es la unidad más pequeña que el cluster maneja. Casi siempre lleva un contenedor y sólo uno.

**Deployment** — la descripción de *"quiero N pods de esta imagen"*. Cuando cambias la descripción, el Deployment calcula cómo pasar del estado actual al nuevo sin apagarlo todo a la vez. El rolling update de 5.7 es eso.

**Service** — un nombre estable y una dirección fija para un conjunto de pods que van y vienen. Los pods se reemplazan y cambian de IP; el Service no. Es exactamente el mismo problema que resolvía el DNS de la red de Docker en la Fase 13, con más piezas.

**ConfigMap** — un montón de pares clave/valor que se le pueden pasar a un contenedor, como variables de entorno o como archivos. **Es el `-e` del `docker run`, con nombre y versionado.**

**Ingress** — la puerta de entrada desde fuera del cluster. Traduce *"lo que llegue a este host y a esta ruta"* en *"mándalo a este Service"*. Es el `-p 8080:80` de la Fase 13, hecho por alguien que además sabe de nombres de dominio.

### 🩻 Esto sí funciona igual: el ConfigMap **es** el `-e`

Vale la pena verlo al lado, porque es la mitad del capítulo:

```bash
# Fase 13: tú le pasas las variables al proceso.
docker run -e ENVIRONMENT_NAME=UAT -e API_BASE_URL=/api certcore:fase-13
```

```yaml
# Fase 14: se las pasa el cluster, leyéndolas de un ConfigMap.
env:
  - name: ENVIRONMENT_NAME
    valueFrom:
      configMapKeyRef: { name: certcore-config, key: ENVIRONMENT_NAME }
```

El proceso que arranca dentro del contenedor **no nota la diferencia**. Recibe dos variables de entorno, el `entrypoint.sh` las lee, escribe `assets/config.json`, y nginx sirve. El script de quince líneas de la Fase 13 no sabe si quien le habló fue un `docker run` de tu portátil o el kubelet de un cluster de doscientos nodos, y no le hace falta saberlo.

> 🧭 **La regla del proyecto, y es la conclusión del curso entero:** el orquestador no resuelve la configuración horneada en tiempo de compilación. La resuelve el `entrypoint.sh`. El orquestador sólo decide quién le habla.

### El ConfigMap como volumen, que es otra cosa

Hay una variante que parece más elegante y conviene mirarla antes de descartarla, porque el día que alguien la proponga en una revisión hay que poder argumentar.

Un ConfigMap también se puede **montar como archivos**. Podrías tener una clave `config.json` con el contenido exacto que la aplicación espera y montarla directamente encima de `/usr/share/nginx/html/assets/config.json`, saltándote el `entrypoint.sh` por completo. Menos piezas, menos shell, y a primera vista mejor.

Tiene tres problemas y el tercero es el que decide.

**El montaje de un archivo suelto no se actualiza solo.** Kubernetes sí refresca un ConfigMap montado como directorio —con retraso, pero lo hace—, y **no** refresca uno montado con `subPath`, que es lo que hace falta para sustituir un archivo dentro de un directorio que ya tiene otras cosas. Montar el directorio entero, en cambio, borraría el resto de `assets/`. Así que la propiedad que hacía atractiva la idea no la tienes.

**Acopla el formato del ConfigMap al formato del archivo de la aplicación.** El día que `AppConfig` gane un campo, hay que editar un JSON dentro de un YAML, con su indentación y su escapado, en vez de añadir una variable.

**Y rompe la paridad.** Tendrías dos formas distintas de configurar la misma aplicación: variables de entorno con `docker run` y un archivo con Kubernetes. Dos caminos que hay que mantener, probar y documentar, y uno de los dos se va a quedar atrás. **La imagen se prueba en la Fase 13 y se despliega aquí; si la forma de configurarla cambia entre las dos, lo que probaste no es lo que corre.**

Por eso este capítulo usa el ConfigMap como variables de entorno. El ejercicio 12 hace escribir la otra variante y comprobar los tres problemas de primera mano.

### Lo que un orquestador no te deja hacer

Hay un atajo de la Fase 13 que aquí se acaba, y es un buen recordatorio de qué cambia al subir un escalón.

Allí, el mock se levantó **montando tu directorio de trabajo** dentro de un contenedor de Node: `-v "$(pwd)/mock:/app/mock"`. Funciona, es cómodo y evita escribir un Dockerfile más. Aquí no sirve: los pods corren en un nodo que es otro contenedor, tu directorio no existe ahí, y aunque se pudiera montar —kind tiene `extraMounts` para eso— estarías atando el cluster a la máquina que lo levantó, que es justo lo que un orquestador existe para evitar.

Así que el mock necesita su propia imagen. Son cinco líneas y es 5.2. La lección que va debajo es más general: **los atajos que dependen de tu máquina son los primeros que se caen al mover algo de tu máquina.**

> 📝 **Nota de migración.** Nada de este capítulo es de Angular ni tiene versión que envejezca con él: los cinco objetos de Kubernetes que vas a escribir se llaman igual y funcionan igual desde 2017, con `apiVersion: apps/v1` para el Deployment desde la 1.9 y `networking.k8s.io/v1` para el Ingress desde la 1.19. Lo que sí cambia rápido es el ecosistema de alrededor —controladores de Ingress, herramientas de empaquetado, políticas de admisión— y por eso este capítulo se queda en los cinco objetos. Son los que siguen ahí dentro de cinco años.

---

## 💻 5. Código mínimo con comentarios

### 5.1 El cluster, y el orden que no se puede invertir

```yaml
# k8s/kind-config.yaml
# Comentarios en español, como todo el código del proyecto. Un manifiesto
# también lo es.
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    # ⚠️ ESTO HAY QUE PONERLO AL CREAR EL CLUSTER. No se puede añadir después:
    # un cluster de kind es un contenedor, y los mapeos de puerto de un
    # contenedor se fijan al crearlo. Si creas el cluster sin esto y descubres
    # más tarde que el Ingress no responde, la única salida es
    # `kind delete cluster` y volver a empezar.
    #
    # Es el tropiezo número dos de esta fase, y va aquí arriba precisamente
    # para que no te pase.
    kubeadmConfigPatches:
      - |
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
    extraPortMappings:
      - containerPort: 80
        hostPort: 80
        protocol: TCP
```

```bash
kind create cluster --name certcore --config k8s/kind-config.yaml

# El contexto de kubectl queda apuntando al cluster nuevo. Compruébalo antes de
# cualquier otra cosa: aplicar un manifiesto en el cluster equivocado es el
# error más caro que se puede cometer con esta herramienta, y no avisa.
kubectl config current-context      # kind-certcore
kubectl get nodes
```

> ⚠️ **`hostPort: 80` puede chocar** con algo que ya escuche ahí en tu máquina — otro nginx, otro contenedor, o la propia Fase 13 si la dejaste levantada. Si `kind create cluster` falla por eso, para lo que sobre o cambia el `hostPort` a `8090` y ajusta las URLs de todo el capítulo.

### 5.2 La imagen del mock, que la Fase 13 pudo esquivar

```dockerfile
# mock/Dockerfile
# Cinco líneas, y existen sólo porque en un cluster no puedes montar tu
# directorio de trabajo. En la Fase 13 el mock se levantó con
# `-v "$(pwd)/mock:/app/mock"` y eso bastaba; aquí el nodo es otro contenedor y
# tu disco no está ahí.
FROM node:18.18.2-alpine

WORKDIR /app

# Se copia el mock entero: el servidor, el caos, la semilla y el db.json. No
# hay `npm ci` porque el mock usa express, json-server y jsonwebtoken, que ya
# están en el package.json del proyecto — así que las dependencias se instalan
# desde la raíz y sólo se copia lo que hace falta.
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

COPY mock/ ./mock/

EXPOSE 3000

CMD ["node", "mock/server.js"]
```

```bash
docker build -f mock/Dockerfile -t certcore-mock:fase-14 .
```

**Detalles con intención**

- **El `db.json` viaja dentro de la imagen y se pierde al reiniciar el pod.** Es correcto para un mock y sería un bug para un backend. El ejercicio 13 te hace decidir qué harías con datos que importan, y la respuesta —un `PersistentVolumeClaim`— está fuera de alcance a propósito: es un capítulo entero.
- **La imagen del mock se etiqueta `fase-14` y no `latest`**, por la misma razón que la de la aplicación en la Fase 13.

### 5.3 ⭐ Cargar la imagen al nodo: el tropiezo de todo el mundo

Aquí es donde tropieza absolutamente todo el que llega a kind por primera vez, así que en vez de esconderlo, se provoca.

```bash
# Aplica el Deployment de 5.4 sin cargar nada y mira qué pasa:
kubectl get pods
# NAME                        READY   STATUS             RESTARTS   AGE
# certcore-7d4b8f9c5-x2klm    0/1     ErrImagePull       0          15s
```

`ErrImagePull`, o su hermano `ImagePullBackOff`. Y la causa desconcierta porque la imagen **existe**: la acabas de construir y `docker images` la lista.

La explicación es de una frase: **el nodo del cluster no ve tus imágenes**. kind corre el cluster dentro de un contenedor, con su propio almacén de imágenes, y ese almacén no es el de tu demonio de Docker. Cuando el kubelet no encuentra `certcore:fase-13` localmente, hace lo único que sabe: intentar descargarla de un registro público, donde por supuesto no está.

```bash
# La solución, si tienes un demonio de Docker escuchando:
kind load docker-image --name certcore certcore:fase-13
kind load docker-image --name certcore certcore-mock:fase-14
```

```bash
# La solución universal, si usas Podman, Colima en ciertas configuraciones, o
# cualquier runtime que `kind load docker-image` no sepa consultar. Funciona
# siempre porque no depende de quién guarde la imagen, sólo de un archivo:
docker save certcore:fase-13 -o /tmp/certcore.tar     # o `podman save`
kind load image-archive --name certcore /tmp/certcore.tar
```

```bash
# Y la comprobación, que es lo que convierte esto en conocimiento:
docker exec certcore-control-plane crictl images | grep certcore
```

**El patrón a memorizar**

> Una imagen que existe en tu máquina no existe en ningún otro sitio hasta que alguien la mueve. Es la misma verdad detrás del `ErrImagePull` de kind, del *"funciona en mi máquina"* de siempre, y de la razón por la que existen los registros de imágenes.

### 5.4 Deployment y Service

```yaml
# k8s/certcore.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: certcore
spec:
  replicas: 2
  # El selector dice qué pods son "de este Deployment". Tiene que coincidir con
  # las etiquetas de la plantilla de abajo: si no coinciden, el Deployment crea
  # pods que después no reconoce como suyos y los vuelve a crear, para siempre.
  selector:
    matchLabels:
      app: certcore
  template:
    metadata:
      labels:
        app: certcore
    spec:
      containers:
        - name: certcore
          # La MISMA imagen de la Fase 13, con el mismo tag, sin reconstruir.
          image: certcore:fase-13
          # ⚠️ `Never` es obligatorio aquí. Con la política por defecto
          # (`IfNotPresent` para tags normales, `Always` para `:latest`), el
          # kubelet podría intentar descargarla igualmente. Y es la segunda
          # razón por la que este curso no usa `:latest`: con esa etiqueta, la
          # política por defecto cambia sola y el pod deja de arrancar.
          imagePullPolicy: Never
          ports:
            - containerPort: 80
          # ⭐ Aquí está todo el capítulo: dos variables de entorno leídas de un
          # ConfigMap y entregadas al mismo proceso al que la Fase 13 se las
          # daba con `-e`. El contenedor no nota la diferencia.
          env:
            - name: ENVIRONMENT_NAME
              valueFrom:
                configMapKeyRef:
                  name: certcore-config
                  key: ENVIRONMENT_NAME
            - name: API_BASE_URL
              valueFrom:
                configMapKeyRef:
                  name: certcore-config
                  key: API_BASE_URL
---
apiVersion: v1
kind: Service
metadata:
  name: certcore
spec:
  # Un nombre estable delante de unos pods que van y vienen. El Ingress de 5.6
  # apunta a este nombre y nunca a una IP: las IP de los pods cambian en cada
  # rolling update y el Service es lo único que no se mueve.
  selector:
    app: certcore
  ports:
    - port: 80
      targetPort: 80
```

```yaml
# k8s/mock.yaml — el backend, con la misma forma y sin nada nuevo
apiVersion: apps/v1
kind: Deployment
metadata:
  name: certcore-mock
spec:
  replicas: 1
  selector:
    matchLabels:
      app: certcore-mock
  template:
    metadata:
      labels:
        app: certcore-mock
    spec:
      containers:
        - name: mock
          image: certcore-mock:fase-14
          imagePullPolicy: Never
          ports:
            - containerPort: 3000
---
apiVersion: v1
kind: Service
metadata:
  # ⚠️ El nombre importa y no es libre: el `nginx.conf` de la Fase 13 hace
  # `proxy_pass http://certcore-mock:3000/`, y ese nombre lo resuelve ahora el
  # DNS del cluster en vez del de la red de Docker. Llamarlo distinto obligaría
  # a tocar la imagen, que es exactamente lo que esta fase no hace.
  name: certcore-mock
spec:
  selector:
    app: certcore-mock
  ports:
    - port: 3000
      targetPort: 3000
```

**Detalles con intención**

- **`replicas: 1` para el mock y no 2.** El mock escribe en su `db.json` local: con dos copias tendrías dos bases de datos divergentes y peticiones repartidas entre ellas al azar. Es un bug que en un backend real se llama *"estado en el pod"* y es de los que producen tickets imposibles. Aquí se evita con un `1` y una frase.
- **El nombre del Service es una interfaz.** `certcore-mock` está escrito dentro del `nginx.conf` que vive dentro de la imagen. Cambiarlo obligaría a reconstruirla, y entonces esta fase dejaría de demostrar lo que viene a demostrar.

### 5.5 ⭐ El ConfigMap, que es el `-e` con nombre

```yaml
# k8s/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: certcore-config
data:
  # Los mismos dos valores que la Fase 13 pasaba con `-e`, exactamente con los
  # mismos nombres, porque los lee el mismo `entrypoint.sh`.
  #
  # `/api` porque el nginx de dentro de la imagen reenvía esa ruta al Service
  # `certcore-mock`. Ni una línea de la imagen cambió para que esto funcione.
  ENVIRONMENT_NAME: "UAT"
  API_BASE_URL: "/api"
```

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/mock.yaml
kubectl apply -f k8s/certcore.yaml

kubectl get pods -w      # espera a que los dos digan Running
```

**Prueba de fuego**

Ésta es la que justifica el capítulo, y son tres comandos.

```bash
# 1. La aplicación arrancó con la configuración del ConfigMap.
kubectl exec deploy/certcore -- cat /usr/share/nginx/html/assets/config.json
# {"apiBaseUrl": "/api", "environmentName": "UAT"}

# 2. Y lo dijo en su log de arranque, igual que en la Fase 13.
kubectl logs deploy/certcore | grep certcore
# [certcore] configuración de arranque: UAT -> /api

# 3. Ahora cambia el ConfigMap y reinicia. SIN reconstruir la imagen.
kubectl patch configmap certcore-config --type merge \
  -p '{"data":{"ENVIRONMENT_NAME":"PROD"}}'
kubectl rollout restart deployment/certcore
kubectl rollout status deployment/certcore

kubectl exec deploy/certcore -- cat /usr/share/nginx/html/assets/config.json
# {"apiBaseUrl": "/api", "environmentName": "PROD"}
```

El archivo cambió, la imagen no. **Compruébalo**, que es lo que separa creerlo de saberlo:

```bash
docker exec certcore-control-plane crictl images --digests | grep certcore
```

> ⚠️ **El `rollout restart` no sobra.** Un ConfigMap consumido como variables de entorno se lee **una sola vez, al arrancar el proceso**. Cambiarlo no toca los pods que ya están corriendo: siguen con los valores de cuando nacieron, tan tranquilos, y `kubectl get configmap` te enseña los nuevos. Esa desincronización —el ConfigMap dice una cosa y el pod hace otra— es el equivalente exacto del incidente 18 de la Fase 13, con otro mecanismo y el mismo desconcierto.

### 5.6 El Ingress

```bash
# El controlador NO viene con kind: hay que instalarlo, y por eso el cluster se
# creó con la etiqueta `ingress-ready=true` que este manifiesto busca.
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Se espera a que esté listo antes de aplicar ninguna regla: un Ingress creado
# sin controlador no da error, simplemente no hace nada, que es peor.
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
```

> ⚠️ Ese manifiesto apunta a `main` y **puede haber cambiado**. Si falla, busca la versión fijada del proyecto `ingress-nginx` para tu versión de Kubernetes en su documentación. Es el único punto de este capítulo que depende de algo externo al curso, y es inevitable: un controlador de Ingress no se puede escribir en veinte líneas.

```yaml
# k8s/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: certcore
spec:
  ingressClassName: nginx
  rules:
    - http:
        paths:
          # Una sola regla: todo lo que entre va al Service de la aplicación.
          # El reparto entre la SPA y `/api` ya lo hace el nginx de dentro de la
          # imagen, y dejarlo ahí es lo que mantiene la paridad con la Fase 13:
          # el mismo reparto en tu portátil y en el cluster.
          - path: /
            pathType: Prefix
            backend:
              service:
                name: certcore
                port:
                  number: 80
```

**Prueba de fuego**

Abre `http://localhost/`. CertCore aparece, servido desde el cluster, con la toolbar diciendo lo que el ConfigMap dijo. Navega a una inspección, **recarga**, y comprueba que no sale un 404: el `try_files` de la Fase 13 sigue haciendo su trabajo dentro de la imagen, y ni el Ingress ni el Service saben nada de rutas de Angular.

### 5.7 El rolling update, en vivo

```bash
# En una terminal, mirando:
kubectl get pods -w

# En otra, provoca el reemplazo:
kubectl patch configmap certcore-config --type merge \
  -p '{"data":{"ENVIRONMENT_NAME":"PROD"}}'
kubectl rollout restart deployment/certcore
```

Lo que se ve en la primera terminal es la idea entera de un Deployment: aparece un pod nuevo, se espera a que esté `Running`, **y sólo entonces** se termina uno de los viejos. Después el siguiente. Con `replicas: 2` nunca hay menos de dos disponibles, así que la página no deja de responder ni un instante — pruébalo recargando `http://localhost/` a mano mientras ocurre.

```bash
# Y si algo sale mal, el Deployment guarda el historial:
kubectl rollout history deployment/certcore
kubectl rollout undo deployment/certcore
```

> 💡 Ese `rollout undo` es el equivalente de cluster a volver a un tag de git: recupera **la descripción anterior**, no el estado anterior. Si el problema estaba en el ConfigMap y no en el Deployment, deshacer el Deployment no arregla nada — y saber distinguir esas dos cosas es la diferencia entre revertir y dar palos de ciego.

```
💸 DEUDA TÉCNICA INTENCIONAL — manifiestos mínimos, sin recursos ni probes
Estos cuatro manifiestos no declaran `resources` (cuánta CPU y memoria pide y
puede consumir cada pod) ni `livenessProbe` / `readinessProbe` (cómo sabe el
cluster si un contenedor está vivo y si está listo para recibir tráfico).
NO SE PAGA, y con todas las letras: aquí se ve **cómo funciona**, no cómo se
pone en producción. Sin `readinessProbe`, el rolling update de 5.7 considera
que un pod está listo en cuanto el contenedor arranca —no cuando nginx acepta
conexiones— así que en un despliegue real habría una ventana de peticiones
fallidas que aquí no se nota porque nginx arranca en milisegundos. Y sin
`resources`, el planificador no sabe dónde cabe tu pod, que en un cluster
compartido es la diferencia entre desplegar y que te lo rechacen.
Las dos cosas son media docena de líneas y **no están** porque escribirlas aquí
sería enseñar una precaución sin mostrar de qué protege. El ejercicio 14 las
añade y las rompe a propósito para verlo. En un cluster de empresa no son
opcionales: son lo primero que revisa quien acepta tu manifiesto, y **A09** lo
cuenta desde ese lado.
```

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Síntoma:** `ErrImagePull` o `ImagePullBackOff`, con una imagen que `docker images` lista perfectamente.
**Causa:** el nodo del cluster tiene su propio almacén y no ve el tuyo.
**Fix mínimo:** `kind load docker-image`, o la variante con `image-archive`.
**Lo que importa:** es el tropiezo número uno de kind y no es un fallo de la herramienta: es la primera vez que el curso te pone delante de que **una imagen local no existe fuera de tu máquina**. En un cluster real la respuesta no es cargarla a mano, es subirla a un registro — y entonces aparece la conversación de tags, digests y quién tiene permiso para empujar, que está en **A09**.

**Síntoma:** el Ingress está creado, `kubectl get ingress` lo muestra, y `http://localhost/` no responde nada.
**Causa:** no hay controlador de Ingress instalado, o el cluster se creó sin `extraPortMappings`.
**Fix mínimo:** instalar el controlador; si el problema es el mapeo de puertos, `kind delete cluster` y volver a crearlo con la configuración de 5.1.
**Lo que importa:** un `Ingress` sin controlador **no da ningún error**. Es un objeto de descripción, y sin nadie que lo lea se queda ahí, con buen aspecto, sin hacer nada. Es la clase de fallo silencioso que este curso lleva catorce fases persiguiendo, en otro contexto.

**Síntoma:** cambiaste el ConfigMap, `kubectl get configmap` muestra el valor nuevo, y la aplicación sigue diciendo lo de antes.
**Causa:** un ConfigMap consumido como variables de entorno se lee al arrancar el proceso. Los pods vivos siguen con lo que había cuando nacieron.
**Fix mínimo:** `kubectl rollout restart deployment/certcore`.
**Lo que importa:** es el incidente 18 de la Fase 13 con otra ropa. Allí el `index.html` estaba cacheado en el navegador; aquí la configuración está "cacheada" en un proceso que arrancó hace dos horas. El síntoma es idéntico —*"lo cambié y no se ve"*— y la lección también: **cuando algo se lee una sola vez, cambiarlo no basta; hay que provocar que se vuelva a leer.**

**Síntoma:** en un Mac con chip M, el pod entra en `CrashLoopBackOff` inmediatamente y `kubectl describe` no explica por qué.
**Causa:** la imagen se construyó para `amd64` y el nodo es `arm64`.
**Fix mínimo:** reconstruir en la arquitectura del nodo, o construir multi-arquitectura con `docker buildx`.
**Lo que importa:** **el mensaje útil está en `kubectl logs`, no en `kubectl describe`** — dice `exec format error`, que es del kernel y no de Kubernetes. Es el mejor ejemplo del curso de por qué hay que mirar los dos y en qué orden. **A12** lo desarrolla.

### Pieza forense de esta fase

**El pod que no arranca: `describe` y `logs`, y cuál va primero.**

La regla es sencilla y ahorra mucho tiempo:

**`kubectl describe pod` cuenta lo que le pasó al pod desde fuera** — si se pudo planificar, si la imagen se pudo obtener, si el contenedor arrancó, cuántas veces se reinició. Sus eventos, al final de la salida, son lo primero que hay que leer.

**`kubectl logs` cuenta lo que dijo el proceso desde dentro.** Existe sólo si el contenedor llegó a arrancar.

De ahí sale el orden: **si el pod nunca llegó a `Running`, empieza por `describe`; si arrancó y se murió, empieza por `logs`.** Y el estado te dice cuál es cuál.

```bash
# El panorama, y la columna que importa es STATUS.
kubectl get pods

# Lo que le pasó desde fuera. Los eventos van al final.
kubectl describe pod <nombre>

# Lo que dijo el proceso. Si el contenedor ya se reinició, el log que te
# interesa es el de la ejecución ANTERIOR, no el de la actual:
kubectl logs <nombre> --previous
```

Ese `--previous` es la mitad del valor de esta sección. Un contenedor en `CrashLoopBackOff` arranca, falla y se reinicia; cuando tú corres `kubectl logs`, estás mirando el intento actual, que a lo mejor todavía no ha fallado. El mensaje que buscas está en el anterior.

**Los cuatro estados que vas a ver, traducidos:**

- **`Pending`** — el pod no se pudo colocar en ningún nodo. Casi siempre, recursos. `describe`.
- **`ErrImagePull` / `ImagePullBackOff`** — no consiguió la imagen. `describe`, y la causa está en los eventos.
- **`CrashLoopBackOff`** — arrancó y se murió, varias veces, y el cluster está esperando cada vez más entre intentos. `logs --previous`.
- **`Running` pero `0/1` en READY** — arrancó y no está listo. Si hubiera `readinessProbe`, sería ella; sin ella, este estado casi no aparece — que es una de las cosas que la 💸 se lleva por delante.

> 📄 El recorrido completo, con los tickets literales y la salida de cada comando, en `forense-fase-14.md`.

**🧨 Rompe a propósito**

Tres roturas, y las tres enseñan un estado distinto.

1. **Cambia la imagen del Deployment a `certcore:fase-99`** y aplica. `ErrImagePull`. Diagnostícalo con `describe` sin mirar el YAML, y anota en qué línea de la salida está la respuesta.

2. **Pon `command: ["sh", "-c", "exit 1"]`** en el contenedor de la aplicación. `CrashLoopBackOff`. Corre `kubectl logs` y después `kubectl logs --previous`, y anota la diferencia entre las dos salidas. Ésa es la lección entera.

3. **Borra la clave `API_BASE_URL` del ConfigMap** y reinicia el Deployment. El pod arranca —el `entrypoint.sh` tiene valor por defecto— pero mira qué pasa si en vez de borrarla le pones `API_BASE_URL: "http://no-existe:3000"`: la aplicación carga y ninguna petición funciona. Compara ese fallo con el `ENVIRONMENT_NAME=PRD` del 🧨 de la Fase 13 y explica por qué uno impide arrancar y el otro no.

---

## 🧪 7. Ejercicios (15)

> **Nota sobre el número.** Quince está por debajo del mínimo de 25 que la guía §9 pide para una fase, y es una **excepción declarada**: esta fase es 🔥, no tiene presupuesto horario y ninguna otra depende de ella. Tampoco hay ejercicios de estilo 🧬, y por la misma razón: **la aplicación no se toca**, así que no existe ningún archivo del que decidir si el fix va en estilo nuevo o heredado. En su lugar hay dos de **lectura de manifiestos ajenos**, marcados 👁️ (sólo lee) y ✍️ (modifica) como en los apéndices de infraestructura.

**🟢 Fácil (1–5)**

1. Crea el cluster con `kind-config.yaml` y comprueba `kubectl config current-context` y `kubectl get nodes`. Después créalo **sin** el archivo de configuración, en un cluster aparte, y anota qué falta.
2. Escribe `mock/Dockerfile`, constrúyelo y córrelo con `docker run` antes de meterlo en el cluster. Comprueba con `curl` que responde en el 3000.
3. **Diagnóstico.** Aplica el Deployment **sin** cargar la imagen. Copia la salida de `kubectl get pods` y de `kubectl describe pod`, y señala la línea exacta donde está la causa.
4. Carga las dos imágenes con `kind load docker-image` y verifica con `crictl images` dentro del nodo. Después hazlo con la variante `image-archive` y explica en dos frases cuándo usarías cada una.
5. **Diagnóstico.** Con los pods corriendo, ejecuta los tres comandos de la prueba de fuego de 5.5. Entrega la salida de los tres y explica qué demuestra cada uno.

**🟡 Intermedio (6–9)**

6. Instala el controlador de Ingress, aplica `ingress.yaml`, y abre `http://localhost/`. Navega a `/inspections/500`, **recarga**, y explica qué pieza evitó el 404 y dónde vive.
7. **Diagnóstico.** Aplica el `Ingress` **antes** de instalar el controlador. Comprueba que `kubectl get ingress` lo muestra sin error y que la URL no responde. Explica en cinco líneas por qué un objeto que nadie lee no da ningún error, y qué otros fallos silenciosos del curso se parecen a éste.
8. 👁️ **Lectura de manifiesto ajeno.** Te dan `k8s/certcore.yaml` sin haberlo escrito tú. **Sin modificar nada**, contesta por escrito: cuántos pods va a crear, de dónde saca la configuración, qué pasa si el ConfigMap no existe, y qué línea impide que intente descargar la imagen de internet.
9. Cambia el ConfigMap a `PROD` y compruébalo **sin** reiniciar. Anota que no cambió nada. Después reinicia y compruébalo otra vez. Explica por qué hacen falta los dos pasos.

**🟠 Difícil (10–13)**

10. **Diagnóstico.** Provoca el 🧨 número 2 y diagnostica el `CrashLoopBackOff` usando sólo `kubectl`. Entrega la salida de `logs` y la de `logs --previous`, y explica por qué la segunda es la que sirve.
11. Haz el rolling update de 5.7 con `kubectl get pods -w` en una terminal y recargando `http://localhost/` a mano en el navegador. Anota el orden exacto en que aparecen y desaparecen los pods, y si la página dejó de responder en algún momento.
12. Escribe la variante del ConfigMap **montado como volumen** con `subPath` sobre `assets/config.json`, en una rama de usar y tirar. Compruébala funcionando y después comprueba los tres problemas que §4 anuncia: que no se actualiza solo, que acopla el formato, y que rompe la paridad con el `docker run` de la Fase 13. Decide cuál de las dos formas entregarías y defiéndelo en cinco líneas.
13. ✍️ **Diagnóstico sobre manifiesto ajeno.** Te dan `k8s/mock.yaml` con `replicas: 3`, en producción, con un ticket que dice *"a veces la inspección que acabo de guardar desaparece al recargar"*. Explica qué se rompe y por qué —piensa dónde escribe el mock— y aplica la corrección mínima. Después responde qué haría falta para que tres réplicas **sí** tuvieran sentido, sabiendo que eso está fuera del alcance de este curso.

**🔴 Muy difícil (14–15)**

14. 💸 **Paga la deuda de esta fase.** Añade `resources` (peticiones y límites de CPU y memoria) y una `readinessProbe` que consulte `/` al Deployment de la aplicación. Después rómpelas a propósito de dos formas: pon un límite de memoria absurdamente bajo y observa el `OOMKilled`; y apunta la `readinessProbe` a una ruta que no existe y observa que el rolling update se queda a medias **sin terminar nunca**, que es el comportamiento correcto y el que más asusta la primera vez. Entrega las dos salidas de `kubectl describe`.
15. **Cierra el círculo del curso.** La Fase 13 dejó una 💸 sin pagar: la imagen corre nginx como root en el puerto 80. Aplica una política que lo prohíba —un `securityContext` con `runAsNonRoot: true` en el pod basta para reproducirlo— y observa el fallo. Después arréglalo de verdad: reconstruye la imagen sobre `nginxinc/nginx-unprivileged`, ajusta el puerto en el Dockerfile, el `nginx.conf`, el Deployment y el Service, y comprueba que todo sigue funcionando. Escribe al final el párrafo que le mandarías al equipo de plataforma explicando qué cambió y por qué. Lee la nota de cierre de **A09** antes de escribirlo.

**🔥 Opcionales**

- 🔥 **La imagen multi-arquitectura.** Construye con `docker buildx` para `amd64` y `arm64`, cárgala en el cluster y comprueba que el pod arranca en las dos. Es el trabajo que **A12** describe y la única forma de que estos manifiestos funcionen igual en un Mac con chip M y en un portátil con Linux.
- 🔥 **El registro local.** Monta un registro de imágenes dentro del cluster y sustituye los `kind load` por un `docker push`. Es cómo funciona de verdad en cualquier equipo, y hace desaparecer el `imagePullPolicy: Never` de los manifiestos. Cuenta cuántas piezas nuevas hacen falta y decide si compensa para desarrollo local.
- 🔥 **Dos ambientes a la vez.** Despliega la misma imagen en dos namespaces con dos ConfigMaps distintos, y llega a los dos por rutas distintas del Ingress. Es la Fase 13 §5.7 traducida a Kubernetes, y es la demostración más completa de que la imagen no cambia.

---

## 📚 8. Referencias

**Documentación oficial**

- https://kind.sigs.k8s.io/docs/user/quick-start/ — crear el cluster, la configuración con `extraPortMappings` y el `kind load`. Es corta y conviene leerla entera.
- https://kind.sigs.k8s.io/docs/user/ingress/ — la página exacta del Ingress con kind, incluida la etiqueta `ingress-ready` de 5.1 y el manifiesto del controlador.
- https://kubernetes.io/es/docs/concepts/workloads/controllers/deployment/ — Deployment y rolling update, en español.
- https://kubernetes.io/es/docs/concepts/services-networking/service/ — Service y el DNS del cluster, que es lo que hace que `certcore-mock` se resuelva.
- https://kubernetes.io/es/docs/concepts/configuration/configmap/ — ConfigMap, con la advertencia sobre cuándo se relee y cuándo no. Es lo que explica el `rollout restart` de 5.5.
- https://kubernetes.io/docs/concepts/services-networking/ingress/ — Ingress y `pathType`, que sólo está completo en inglés.
- https://kubernetes.io/docs/tasks/debug/debug-application/debug-pods/ — el árbol de decisión oficial para un pod que no arranca. Es la versión larga de la pieza forense de esta fase.
- https://kubernetes.io/docs/reference/kubectl/quick-reference/ — la chuleta de `kubectl`, que es lo que de verdad se consulta.

> ⚠️ La documentación de Kubernetes se mueve más rápido que la de Angular, y el manifiesto del controlador de Ingress de 5.6 apunta a `main`: **puede haber cambiado desde que se escribió esto**. Los cinco objetos que usa este capítulo, en cambio, son estables desde hace años. Si algo falla, va a ser el controlador, no el YAML.

**Orden de lectura sugerido:** la guía rápida de kind **antes** de 5.1, entera. La página de ConfigMap **después** de tropezar con el `rollout restart` de 5.5, no antes. Y **A09** cuando termines el capítulo, no durante: está escrito para alguien que ya vio funcionar estos cinco objetos y quiere saber en qué se diferencia de un cluster real. **A12** sólo si estás en un Mac con chip M — y ahí sí, antes de empezar.

---

## 🚀 9. Cierre y conexión con la siguiente fase

No hay fase siguiente. **El curso lo cerró la Fase 13**, con su balance y su checklist de hotfix; esto es un apéndice con número, y su despedida es corta.

Lo que viste aquí, si sale bien, es una sola cosa: **la misma imagen de la Fase 13, sin modificar una línea, corriendo en un orquestador y configurada por un ConfigMap**. El `entrypoint.sh` de quince líneas no sabe quién le habló. Y ésa es la confirmación de lo que el curso lleva diciendo desde su primera página: la fricción entre configuración horneada en compilación y configuración inyectada en arranque **no la resuelve la herramienta de despliegue**. La resuelve un script, y el orquestador sólo decide quién le pasa las variables.

Lo demás que te llevas es vocabulario, y no es poco: cinco objetos que vas a encontrarte en el primer manifiesto que alguien te pase, y la capacidad de leerlo sin fingir. Un Deployment que describe, un Service que da nombre, un ConfigMap que configura, un Ingress que abre la puerta, y un Pod que es lo que corre de verdad. Con eso, y con `describe` y `logs` en el orden correcto, se diagnostica el 80 % de lo que le pasa a una aplicación en un cluster.

Y lo que **no** te llevas conviene decirlo con la misma claridad. Esto no es producción: no hay probes, ni límites de recursos, ni TLS, ni registro de imágenes, ni políticas de admisión, ni la conversación sobre quién puede desplegar qué. El cluster de tu empresa tiene todo eso y algunas cosas más que sólo su equipo de plataforma conoce — empezando, casi seguro, por que tu contenedor no va a poder correr como root. **A09** cierra con esa advertencia y con la instrucción que la acompaña: pregunta antes de improvisar.

> **La señal de que quedó bien:** cuando alguien te pasa un manifiesto que no escribiste, lo lees de arriba abajo y puedes decir qué va a hacer, qué le falta, y qué pregunta harías antes de aplicarlo.

> 🏷️ **Esta fase sí lleva tag, y es una decisión que conviene entender.** Deja
> archivos versionados —`k8s/*.yaml` y `mock/Dockerfile`— así que por la
> convención le corresponde uno, a diferencia de los apéndices, que no dejan
> nada y por eso no lo llevan. Con el checklist de la sección 2 en verde y
> `git status` limpio:
>
> ```bash
> git tag -a fase-14 -m "F14 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits llevan su prefijo (`fase 14: …`) y los de ejercicio su número
> (`fase 14 ej12: …`). Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
>
> Dicho eso: **la mayoría de quienes terminen el curso no van a crear este
> tag**, porque esta fase es opcional y mucha gente no la hará. Eso está bien y
> no rompe nada — la única fase que ninguna otra necesita es precisamente ésta.
> Si la haces, ten en cuenta que su tag apunta a un commit que sólo añade
> infraestructura: `git diff fase-13 fase-14` no toca ni un archivo de
> `src/`, y ése es el mejor resumen posible de lo que este capítulo demuestra.

---

## 📌 Pendientes sugeridos

- **El prompt de esta fase pedía "ConfigMap montado como volumen alimentando el mismo `entrypoint.sh`", y esas dos cosas no pueden ser ciertas a la vez.** Para alimentar el `entrypoint.sh` sin tocar la imagen, el ConfigMap tiene que llegar como **variables de entorno**; montado como volumen se salta el script por completo, que es un diseño distinto. Se implementó la primera forma y la segunda quedó explicada en §4 y ejercitada en el 12, con sus tres problemas. → **Corrección al prompt de la Fase 14**, ya aplicada aquí.
- **El mock necesitó su propia imagen, y la Fase 13 lo había esquivado.** Allí se levantaba montando el directorio con `-v`, que en un cluster no existe. Son cinco líneas y una lección —los atajos que dependen de tu máquina se caen al salir de tu máquina— pero significa que ahora hay **dos** Dockerfiles que mantener. → **Aviso para una segunda pasada sobre la Fase 13**: quizá convenga escribir el `mock/Dockerfile` allí y usarlo también con `docker run`, para tener una sola forma.
- **Esta fase no reserva ningún ID de incidente**, y aun así tiene pieza forense y archivo `forense-fase-14.md`. El motivo es de alcance: un incidente del cuaderno tiene que poder reproducirlo alguien que haya hecho las fases obligatorias, y montar un cluster no lo es. Los veinte IDs quedan repartidos entre las Fases 0 a 13. → **Nota para el chat del cuaderno de incidentes**: la tabla de reservas de esta fase va vacía a propósito.
- **A09 hereda tres cosas concretas de aquí**, además de su nota obligatoria: la traducción de los cuatro estados de pod, la conversación de registros de imágenes que el `kind load` esquiva, y el desarrollo completo de `runAsNonRoot` que el ejercicio 15 sólo hace tocar. → **Aviso para el chat de A09.**
- **El manifiesto del controlador de Ingress apunta a `main` y es el único enlace del curso que puede romperse solo.** Todo lo demás está fijado con versión exacta; esto no se puede, porque el proyecto no publica una URL estable por versión de Kubernetes. Está advertido en el texto. → **Riesgo conocido**, sin acción posible desde aquí.
- **El `hostPort: 80` va a chocar con algo en la máquina de alguien.** Está advertido en 5.1 con la salida —cambiar a `8090`—, pero significa que las URLs del capítulo no son literales para todo el mundo. → **Pendiente de revisión editorial**: si el curso hace una segunda pasada, quizá convenga usar `8090` desde el principio y evitar el choque en vez de advertirlo.
- 🔥 **Un diagrama de los cinco objetos** —Ingress → Service → Pods, con el ConfigMap entrando por un lado y el Deployment describiendo desde arriba— es lo que más falta hace de todo este capítulo, y es exactamente lo que nadie dibuja bien. Es el duodécimo y último pendiente de ilustración del curso. Pendiente de dibujo, no de contenido.

### Reservas para el cuaderno de incidentes

| ID | Título | Categoría | Dif. |
|---|---|---|---|
| — | Esta fase no reserva ningún ID: es 🔥 opcional y un incidente del cuaderno tiene que poder reproducirlo quien sólo hizo las fases obligatorias | — | — |
