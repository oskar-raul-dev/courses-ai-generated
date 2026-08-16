# 📎 Apéndice A09 — Docker y Kubernetes para el dev de front

> Tutorial Angular 16 — Inspecciones y certificaciones · Consulta rápida · **3 horas**
> Usado por: [Fase 13](13-build-despliegue.md), [Fase 14](14-casi-prod-kind.md) · Versión cubierta: Docker Engine 24+ · nginx 1.25 · kind (el que traiga tu runtime)

**Esto no se lee de corrido.** Es material de consulta: se entra por el índice buscando algo concreto y se sale. Resuelve tres cosas muy concretas del día a día de alguien que mantiene un front y no administra un cluster: **leer un manifiesto ajeno sin adivinar, saber qué le pasa a tu imagen después del `docker build`, y hablar con el equipo de plataforma sin sentirte turista.**

Ese último objetivo es el que ordena el apéndice. No vas a operar el cluster; vas a tener que diagnosticar por qué tu aplicación no arranca en él, y a pedir lo que necesites con las palabras correctas.

**Qué queda fuera:** Helm, operadores, service mesh, autoescalado, políticas de red y todo lo que sea administración del cluster — no es tu trabajo y saberlo a medias es peor que no saberlo. Y también quedan fuera el `Dockerfile`, el `nginx.conf` y el `entrypoint.sh` concretos del proyecto: ésos los escribe y los explica la **Fase 13**, línea por línea. Aquí está lo que hace falta para entenderlos, no su repetición.

---

## Índice

- [1. Qué es una imagen, y qué le pasa después del `docker build`](#1-qué-es-una-imagen-y-qué-le-pasa-después-del-docker-build)
- [2. Tag frente a digest, y por qué `:latest` te va a morder](#2-tag-frente-a-digest-y-por-qué-latest-te-va-a-morder)
- [3. El vocabulario, en seis palabras](#3-el-vocabulario-en-seis-palabras)
- [4. Por qué un Secret no es un secreto](#4-por-qué-un-secret-no-es-un-secreto)
- [5. 👁️ ✍️ La caja de herramientas](#5-️-️-la-caja-de-herramientas)
- [6. Los estados de un pod, traducidos](#6-los-estados-de-un-pod-traducidos)
- [7. Leer los logs de un contenedor que ya murió](#7-leer-los-logs-de-un-contenedor-que-ya-murió)
- [8. ⚠️ Tu cluster no es el del libro](#8-️-tu-cluster-no-es-el-del-libro)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-8)

---

## 1. Qué es una imagen, y qué le pasa después del `docker build`

Una imagen es **un sistema de archivos congelado más una receta de arranque**. Nada más. No es un proceso, no está corriendo, y no tiene estado: es un archivo comprimido por capas con todo lo que el contenedor va a ver como su disco.

Un contenedor es esa imagen **más un proceso vivo** y una capa de escritura efímera encima. Cuando el proceso muere, la capa de escritura se va con él. Es la razón por la que un contenedor no guarda nada por su cuenta y por la que un cambio hecho con `docker exec` desaparece en el siguiente reinicio.

**Las capas son la parte que hay que entender para no perder minutos en cada build.** Cada instrucción del `Dockerfile` produce una capa, y Docker reutiliza las que no cambiaron. Por eso el Dockerfile de la **Fase 13** copia primero los manifiestos y sólo después el código:

```dockerfile
COPY package.json package-lock.json ./
RUN npm ci                              # ← esta capa se reutiliza…
COPY . .                                # ← …mientras esta línea no invalide nada
RUN npm run build -- --configuration production
```

Si copiaras todo de una vez, cualquier línea que toques en un `.ts` invalidaría la capa del `npm ci` y cada recompilación reinstalaría el árbol entero.

**Y ahora la pregunta que da título a la sección: ¿qué le pasa a la imagen después del `docker build`?**

Nada. Se queda en el almacén local de tu runtime de contenedores y **no existe en ningún otro sitio del universo**. Ni en un servidor, ni en un cluster, ni en la máquina de tu compañero. Para que exista en otro sitio, alguien tiene que moverla, y sólo hay tres formas:

- **Empujarla a un registro** (`docker push`) y que quien la necesite la baje. Es lo que se hace de verdad.
- **Cargarla a mano en un nodo** (`kind load docker-image`, o `docker save` + `kind load image-archive`). Es lo que hace la **Fase 14** para no obligarte a montar un registro.
- **Exportarla como archivo** (`docker save`) y llevarla por otro medio. Es lo que queda cuando no hay red.

> 🧠 **El patrón a memorizar, y es el mismo de la Fase 14.** Una imagen que existe en tu máquina no existe en ningún otro sitio hasta que alguien la mueve. Es la verdad detrás del `ErrImagePull` de kind, del *"funciona en mi máquina"* de siempre, y de la razón por la que existen los registros.

**La conversación que `kind load` te ahorra y que en tu empresa vas a tener igual.** En un cluster real no hay `kind load`: hay un registro —Harbor, ECR, GCR, Artifactory, el de GitLab— con autenticación, con permisos por proyecto, y con un `imagePullSecret` en el namespace que le da al kubelet las credenciales para bajar. Cuando tu pod diga `ImagePullBackOff` en el cluster de la empresa y la imagen exista, las tres preguntas son: **¿está empujada al registro correcto?**, **¿el nodo llega a ese registro por red?**, y **¿el namespace tiene el `imagePullSecret`?**. Ésa es toda la diferencia entre el laboratorio y la realidad, y sabiendo las tres preguntas ya puedes abrir el ticket bien.

---

## 2. Tag frente a digest, y por qué `:latest` te va a morder

Una imagen se puede nombrar de dos maneras, y sólo una de las dos identifica algo:

```bash
certcore:fase-13                              # un TAG: una etiqueta movible
certcore@sha256:9f2c…                         # un DIGEST: el hash del contenido
```

**Un tag es un post-it.** Se puede despegar y pegar en otra imagen. `certcore:fase-13` señala hoy a una imagen y mañana puede señalar a otra si alguien vuelve a construir con el mismo nombre. **Un digest es el contenido**: dos imágenes con el mismo digest son bit a bit la misma, siempre, en cualquier máquina.

**Y `:latest` es el peor post-it de todos**, por tres razones que se acumulan:

- **No significa "la última".** No significa nada: es el tag por defecto cuando no pones ninguno. Una imagen etiquetada `:latest` puede llevar ahí ocho meses.
- **Cambia la política de descarga.** Kubernetes usa `imagePullPolicy: IfNotPresent` para tags normales y **`Always` para `:latest`**. Con `:latest`, el nodo se va a buscar la imagen aunque ya la tenga — que en kind, donde no hay registro, significa `ErrImagePull` con la imagen delante.
- **Hace imposible la pregunta que ordena el final del curso.** *"¿Por qué esta imagen se comporta distinto en UAT y en PROD?"* empieza por saber qué código hay dentro de cada una. Con `:latest` en las dos, esa pregunta no tiene respuesta.

> 🧭 **Regla del proyecto: la imagen se etiqueta con el mismo nombre del tag de git que la produjo.** `certcore:fase-13` sale del tag `fase-13`, y un hotfix produce `certcore:hotfix-2026-03-14` o lo que corresponda. Cuesta un guion en la línea de `docker build` y te da la mitad barata de cualquier diagnóstico de ambientes. Está anunciado en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md) y desarrollado aquí.

**En producción, el paso siguiente es fijar el digest.** Un Deployment que dice `image: certcore@sha256:9f2c…` corre exactamente esos bytes y nadie puede cambiárselos por debajo moviendo un tag. Es más incómodo de leer y es lo que hace que un despliegue sea reproducible. Si tu equipo de plataforma te lo pide, es por esto.

```bash
# 👁️ El digest de una imagen local, para citarla sin ambigüedad
docker images --digests | grep certcore
```

---

## 3. El vocabulario, en seis palabras

Con estas seis se lee el 95% de los manifiestos que te van a pasar. Cada una responde a una pregunta.

**Pod — *¿dónde corre mi contenedor?*** Es la unidad mínima que Kubernetes programa: uno o varios contenedores que comparten red y almacenamiento, y que viven y mueren juntos. En la práctica, para un front, es un contenedor. **Un pod es desechable**: no tiene nombre estable, no tiene IP estable, y el cluster lo mata y lo recrea sin avisarte. Todo lo que hagas dentro de un pod a mano se pierde.

**Deployment — *¿quién se encarga de que haya pods?*** Declara cuántas réplicas quieres y de qué imagen, y se ocupa de que eso sea verdad. Es también quien sabe hacer un despliegue sin cortar el servicio: crea los pods nuevos, espera a que estén listos, y retira los viejos. Cuando alguien dice "rolling update", habla de esto.

**Service — *¿qué nombre estable tienen esos pods?*** Los pods cambian de IP; el Service no. Da un nombre DNS interno y reparte el tráfico entre los pods que coincidan con su selector. En la Fase 14, `certcore-mock` es un Service, y por eso el `proxy_pass` del `nginx.conf` puede escribirlo por nombre.

**Ingress — *¿cómo se entra desde fuera?*** Es la puerta HTTP del cluster: reglas de host y de ruta que mandan el tráfico externo a un Service. **Un Ingress no hace nada por sí solo**: necesita un controlador instalado que lo lea y lo implemente. Es la causa número uno de "apliqué el Ingress y no pasa nada".

**ConfigMap — *¿de dónde salen los valores que cambian por ambiente?*** Un mapa de clave-valor que se puede exponer al contenedor como variables de entorno o montar como archivos. Es el `-e` de `docker run`, con nombre y versionado.

**Secret — *lo mismo, pero para credenciales.*** Y ahí hay que pararse (§4).

> ⚠️ **La trampa del ConfigMap consumido como variables de entorno**, que es exactamente el incidente que la Fase 14 provoca: se lee **una sola vez, al arrancar el proceso**. Cambiar el ConfigMap no toca los pods que ya corren — siguen con los valores de cuando nacieron, tan tranquilos, mientras `kubectl get configmap` te enseña los nuevos. Hace falta un `kubectl rollout restart deployment/…`. Montado como volumen sí se actualiza solo, con retraso y sin reiniciar el proceso, lo que trae su propio conjunto de sorpresas.

---

## 4. Por qué un Secret no es un secreto

Un `Secret` de Kubernetes guarda su contenido en **base64**. Base64 no es cifrado: es una forma de escribir bytes con caracteres imprimibles, y se deshace con un comando de veinte caracteres.

```bash
# 👁️ Cualquiera con permiso de lectura sobre el namespace hace esto:
kubectl get secret certcore-api-key -o jsonpath='{.data.token}' | base64 -d
```

Lo que un Secret **sí** te da, y no es poco:

- Está **separado del manifiesto**, así que el YAML del Deployment se puede commitear sin credenciales dentro.
- Tiene **permisos propios**: el control de acceso del cluster puede dejar leer ConfigMaps y no Secrets.
- **No se imprime por accidente** en un `kubectl describe`, que sí muestra el contenido de un ConfigMap.
- Puede estar **cifrado en reposo** en el almacén del cluster, si el administrador lo configuró — y ésa es la pregunta que hay que hacerle a plataforma, porque por defecto en muchas instalaciones **no lo está**.

Lo que **no** te da: confidencialidad frente a nadie que pueda leer el namespace, ni frente a quien pueda abrir una shell en el pod, ni rotación, ni auditoría de quién lo leyó.

> 🧭 **La consecuencia práctica para un dev de front, y es la que importa: un secreto que llega al navegador ya no es un secreto, venga de donde venga.** Cualquier valor que acabe en `assets/config.json`, en un bundle o en una variable del `entrypoint.sh` es público: está en el disco de todos los usuarios. La clave de una API de terceros no se pone ahí ni aunque venga de un Secret perfectamente configurado — se pone detrás de un backend que la use por ti. Es la misma frontera que la **Fase 2** traza con el guard: *un guard no es seguridad porque corre en el navegador.* Aquí es idéntico.

---

## 5. 👁️ ✍️ La caja de herramientas

Marcados por lo que hacen. Los 👁️ se pueden ejecutar en cualquier sitio sin pensarlo dos veces; los ✍️ **cambian el estado del cluster** y en el de tu empresa se ejecutan sabiendo qué namespace tienes seleccionado.

**Docker — mirar**

```bash
docker images                                    # 👁️ qué imágenes hay localmente
docker images --digests | grep certcore          # 👁️ el digest, para citar sin ambigüedad
docker ps -a                                     # 👁️ contenedores, incluidos los muertos
docker logs <contenedor>                         # 👁️ su salida estándar
docker inspect <imagen|contenedor>               # 👁️ todo: capas, variables, puertos, usuario
docker history <imagen>                          # 👁️ las capas y qué las creó
```

**Docker — tocar**

```bash
docker build -t certcore:fase-13 .               # ✍️ construye (local)
docker run --rm -p 8080:80 certcore:fase-13      # ✍️ levanta un contenedor
docker exec -it <contenedor> sh                  # ✍️ shell dentro; lo que cambies se pierde
docker save certcore:fase-13 -o certcore.tar     # ✍️ escribe un archivo
```

**Kubernetes — mirar (esto es el 90% de tu trabajo con un cluster)**

```bash
kubectl config current-context                   # 👁️ EN QUÉ CLUSTER ESTOY. Antes de nada.
kubectl get pods                                 # 👁️ qué hay corriendo y en qué estado
kubectl get pods -o wide                         # 👁️ …con nodo e IP
kubectl describe pod <pod>                       # 👁️ los EVENTOS al final: ahí está la causa
kubectl logs <pod>                               # 👁️ la salida del contenedor actual
kubectl logs <pod> --previous                    # 👁️ la del intento anterior. Ver §7.
kubectl logs deploy/certcore --tail=100 -f       # 👁️ en vivo, por Deployment
kubectl get configmap certcore-config -o yaml    # 👁️ qué valores hay de verdad
kubectl get events --sort-by=.lastTimestamp      # 👁️ qué ha pasado últimamente, en orden
kubectl get deploy,svc,ingress                   # 👁️ el mapa de la aplicación de un vistazo
```

**Kubernetes — tocar**

```bash
kubectl apply -f k8s/certcore.yaml               # ✍️ crea o actualiza lo declarado
kubectl rollout restart deployment/certcore      # ✍️ recrea los pods (releer un ConfigMap)
kubectl rollout status deployment/certcore       # 👁️ …aunque acompaña siempre al anterior
kubectl rollout undo deployment/certcore         # ✍️ vuelve a la revisión anterior
kubectl exec -it deploy/certcore -- sh           # ✍️ shell dentro de un pod
kubectl port-forward svc/certcore 8080:80        # ✍️ abre un túnel a tu máquina
kubectl delete pod <pod>                         # ✍️ lo mata; el Deployment lo recrea
```

> ⚠️ **`kubectl config current-context` antes de cualquier ✍️.** Es el equivalente de mirar en qué rama estás antes de un `push --force`, y el fallo tiene el mismo perfil: cuesta un segundo comprobarlo y cuesta una tarde muy mala no haberlo hecho. En un cluster compartido, añade `-n <namespace>` a todo o fija el namespace por defecto.

> 💡 **`kubectl describe` es el comando que más se subestima.** Su información útil está **al final**, en la sección `Events`: ahí es donde el cluster te dice, en español llano y en orden cronológico, que no encontró la imagen, que no hay nodo con recursos, o que el contenedor se murió con un código concreto. Nueve de cada diez diagnósticos empiezan y terminan ahí.

---

## 6. Los estados de un pod, traducidos

| Lo que dice `kubectl get pods` | Qué significa de verdad | Por dónde se empieza |
|---|---|---|
| `Pending` | el cluster todavía no lo ha colocado en ningún nodo | `describe`: no hay recursos, o no hay nodo que cumpla las restricciones |
| `ContainerCreating` | está bajando la imagen o montando volúmenes | normal unos segundos; si se queda, `describe` |
| `ErrImagePull` / `ImagePullBackOff` | no consiguió la imagen | ¿está empujada? ¿llega el nodo al registro? ¿hay `imagePullSecret`? (§1) |
| `Running` | el contenedor arrancó | ⚠️ **arrancar no es funcionar**: mira `READY 1/1`, no sólo el estado |
| `CrashLoopBackOff` | arrancó, se murió, y lleva varios intentos; el cluster espera cada vez más entre uno y otro | `logs --previous` (§7) |
| `OOMKilled` (en `describe`) | se pasó del límite de memoria y el kernel lo mató | subir el límite, o averiguar por qué consume eso |
| `Completed` | el proceso terminó **bien** | correcto en un Job; en un Deployment significa que tu proceso no se queda vivo |
| `Terminating` | le pidieron que se fuera y aún no se ha ido | si se queda ahí, algo no responde a la señal de apagado |

**Dos precisiones que ahorran mucho tiempo:**

**`Running` con `READY 0/1` es un pod que no sirve tráfico.** El contenedor está vivo y su prueba de disponibilidad no pasa, así que el Service no le manda nada. Si la aplicación "está desplegada" y no responde, ésta es la primera columna que hay que mirar.

**`CrashLoopBackOff` no es un error: es una consecuencia.** El error real ocurrió hace unos segundos, en el arranque anterior, y está en los logs de ese intento. El estado sólo te dice que ya ha pasado varias veces.

> 💡 **En un Mac con chip M hay un `CrashLoopBackOff` con causa propia**: la imagen está construida para amd64 y el nodo es arm64. `kubectl describe` no lo explica bien y los logs vienen vacíos. Es lo primero que hay que descartar en Apple Silicon, y el diagnóstico completo está en **A12** 🔥.

---

## 7. Leer los logs de un contenedor que ya murió

Es la técnica que separa diagnosticar de adivinar, y son dos comandos.

```bash
kubectl logs <pod>                # 👁️ el intento ACTUAL, que a lo mejor aún no ha fallado
kubectl logs <pod> --previous     # 👁️ el intento ANTERIOR: aquí está el mensaje que buscas
```

Un contenedor en `CrashLoopBackOff` arranca, falla y se reinicia. Cuando tú escribes `kubectl logs`, estás mirando el intento en curso — que puede llevar dos segundos de vida y no haber llegado todavía al error. El mensaje que explica todo está en el anterior, y `--previous` es la única forma de verlo.

**Y cuando ni eso alcanza**, tres recursos más:

```bash
# 👁️ Los eventos del pod: por qué el cluster hizo lo que hizo
kubectl describe pod <pod> | tail -30

# 👁️ Todos los eventos del namespace en orden, cuando no sabes ni qué pod mirar
kubectl get events --sort-by=.lastTimestamp

# ✍️ Arrancar el contenedor con otro comando para poder entrar a mirar.
#    Sustituye el arranque por un `sleep` y te deja una shell dentro de una
#    imagen que de otro modo se muere antes de que puedas escribir nada.
kubectl run debug --rm -it --image=certcore:fase-13 --command -- sh
```

> ⚠️ **Los logs de un pod borrado no existen.** Si el Deployment recrea el pod, el anterior se fue y sus logs con él. En un cluster de verdad eso lo resuelve un agregador —Loki, ELK, CloudWatch, el que tenga tu empresa— y **preguntar cuál es** debería ser una de las primeras cosas que hagas al llegar a un equipo. Sin agregador, cada diagnóstico es una carrera contra el reinicio.

---

## 8. ⚠️ Tu cluster no es el del libro

Esta sección es obligatoria y es la razón por la que este apéndice existe en vez de un enlace a la documentación de Kubernetes.

Todo lo anterior describe un Kubernetes de manual, y el de tu empresa **no lo es**. Tiene políticas de admisión, cuotas de recursos, namespaces con permisos que quizá no incluyan lo que necesitas, redes segmentadas, controladores de Ingress con anotaciones propias, y un conjunto de convenciones que sólo su equipo de plataforma conoce entero. Ninguna de esas cosas está mal documentada: simplemente es de ellos y no está en ningún libro.

**Y hay una que te va a pasar casi seguro, así que conviene contarla completa.**

La imagen de la **Fase 13** corre nginx como **root**, escuchando en el **puerto 80**. Eso funciona en tu máquina, funciona en kind, y en el cluster de tu empresa se va a caer, porque casi cualquier política de seguridad razonable prohíbe las dos cosas: los contenedores no corren como root, y los puertos por debajo de 1024 requieren privilegios que no vas a tener.

```yaml
# La política que lo prohíbe se parece a esto. Con añadirlo a tu pod
# reproduces el fallo en local antes de que te lo reporten:
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 101
```

El pod entra en `CrashLoopBackOff` y los logs dicen que nginx no puede escribir en `/var/cache/nginx` ni escuchar en el 80.

**El arreglo de verdad son cuatro cambios coordinados**, y ninguno es difícil:

1. **La imagen base pasa a una variante sin privilegios** — `nginxinc/nginx-unprivileged` es la oficial y ya viene preparada: corre como usuario `101` y sus directorios de caché son escribibles por ese usuario.
2. **El puerto pasa a uno por encima de 1024** — el 8080 es la convención. Cambia en el `nginx.conf` (`listen 8080;`) y en el `EXPOSE` del Dockerfile.
3. **El Deployment y el Service se ajustan** al puerto nuevo: `containerPort: 8080` y el `targetPort` del Service.
4. **El `entrypoint.sh` tiene que poder escribir donde escribe.** Genera `assets/config.json` dentro del directorio servido, y con un usuario sin privilegios eso hay que comprobarlo, no suponerlo.

> 🧭 **La instrucción que acompaña a todo esto, y es la parte importante: pregúntale al equipo de plataforma antes de improvisar.** No porque no puedas averiguarlo —acabas de leer cómo—, sino porque en un cluster compartido las decisiones ya están tomadas y hay una forma correcta de hacer cada cosa que no vas a deducir leyendo. Las cinco preguntas que valen una reunión de quince minutos y ahorran una semana:
>
> 1. **¿A qué registro empujo, y cómo se autentica el cluster contra él?**
> 2. **¿Qué políticas de seguridad se aplican a mi namespace?** (usuario, puertos, sistema de archivos de sólo lectura, capacidades)
> 3. **¿Qué probes espera el equipo, y contra qué ruta?**
> 4. **¿Dónde se ven los logs cuando el pod ya se recicló?**
> 5. **¿Quién puede desplegar, y por qué camino?** (¿aplico yo un manifiesto, o hay un pipeline?)

Y una advertencia final, que también es una liberación: **lo que la Fase 14 monta no es producción, y no pretende serlo.** No hay probes, ni límites de recursos, ni TLS, ni registro, ni políticas de admisión, ni la conversación sobre quién despliega qué. Es un ambiente "casi prod" para que entiendas las piezas, y entenderlas es exactamente lo que te permite hacer las cinco preguntas de arriba en vez de asentir.

---

## 🧭 Cuándo usar qué

| Situación | Comando o decisión | Por qué |
|---|---|---|
| Antes de cualquier comando que escriba | 👁️ `kubectl config current-context` | el `--force` a la rama equivocada, versión cluster |
| El pod no arranca y no sabes por qué | 👁️ `kubectl describe pod` y mira los `Events` | ahí está la causa, en orden cronológico |
| `CrashLoopBackOff` | 👁️ `kubectl logs --previous` | el intento actual todavía no ha fallado |
| `ImagePullBackOff` con la imagen delante | ¿empujada? ¿red? ¿`imagePullSecret`? | el nodo no ve tu almacén local |
| Cambiaste un ConfigMap y no pasa nada | ✍️ `kubectl rollout restart deployment/…` | las variables de entorno se leen al arrancar |
| Quieres ver la aplicación sin Ingress | ✍️ `kubectl port-forward svc/…` | túnel directo, sin tocar nada del cluster |
| Necesitas saber qué código hay en la imagen | etiquetar con el tag de git; en producción, digest | `:latest` no responde esa pregunta |
| Una credencial que usa el navegador | **no existe tal cosa** | lo que llega al navegador es público (§4) |
| El despliegue salió mal | ✍️ `kubectl rollout undo deployment/…` | primero recuperar el servicio, después diagnosticar |
| Cualquier duda sobre el cluster de tu empresa | preguntar a plataforma | las decisiones ya están tomadas y no se deducen |

---

## 📚 Referencias

- https://docs.docker.com/build/building/best-practices — capas, caché y por qué el orden del `Dockerfile` importa.
- https://docs.docker.com/reference/cli/docker/image/tag — tags y digests, con la explicación de por qué un tag es movible.
- https://kubernetes.io/docs/concepts/workloads/pods — Pod, y la frase clave sobre que son desechables.
- https://kubernetes.io/docs/concepts/workloads/controllers/deployment — Deployment y rolling update.
- https://kubernetes.io/docs/concepts/services-networking/service · https://kubernetes.io/docs/concepts/services-networking/ingress — Service e Ingress, incluida la nota de que un Ingress necesita un controlador.
- https://kubernetes.io/docs/concepts/configuration/configmap — ConfigMap, con la diferencia entre consumirlo como variables y como volumen.
- https://kubernetes.io/docs/concepts/configuration/secret — Secret. ⚠️ Lee la sección *Risks*: la propia documentación oficial dice que base64 no es cifrado y que el cifrado en reposo hay que configurarlo.
- https://kubernetes.io/docs/reference/kubectl/quick-reference — la chuleta de `kubectl`, que conviene tener abierta las primeras semanas.
- https://kubernetes.io/docs/tasks/debug/debug-application/debug-pods — la guía oficial de diagnóstico de pods, que es la §6 y la §7 con más detalle.
- https://hub.docker.com/r/nginxinc/nginx-unprivileged — la imagen sin privilegios de la §8.
- https://kind.sigs.k8s.io — kind, para la Fase 14.

> ⚠️ La documentación de Kubernetes describe la versión más reciente y las cosas cambian de sitio entre versiones —sobre todo en API de red y en políticas de seguridad—. Si un campo de un manifiesto no te lo acepta el cluster, comprueba primero la versión con `kubectl version` antes de dudar del ejemplo.

**Orden de lectura sugerido:** la §1 y la §2 antes de la Fase 13, que es donde construyes tu primera imagen. La §3 antes de la Fase 14, para que los manifiestos se lean en vez de descifrarse. La §5, la §6 y la §7 el día que algo no arranque — y ese día llega. La §8 dos veces: una al terminar la Fase 14, y otra el día antes de tu primera reunión con el equipo de plataforma.

---

## 🧪 Ejercicios (8)

1. 🟢 Construye la imagen de la Fase 13, cambia una línea de un `.ts` y vuelve a construir. Anota qué capas dice Docker que reutilizó. Después mueve el `COPY . .` al principio del Dockerfile, repite, y compara los dos tiempos.

2. 🟢 Ejecuta `docker images --digests` y anota el digest de tu imagen. Vuelve a construirla sin cambiar nada y compáralo. Después cambia una línea, reconstruye con **el mismo tag**, y compara otra vez. Explica en dos líneas qué acabas de demostrar sobre los tags.

3. 🟡 Crea un Secret con `kubectl create secret generic demo --from-literal=token=abc123` y recupera su valor en claro con un solo comando. Después escribe tres líneas explicándole a un compañero qué te da un Secret y qué no.

4. 🟡 Provoca los cuatro estados de la §6 en el cluster de la Fase 14 y anota, para cada uno, qué comando te dio la causa: `ImagePullBackOff` (aplica sin cargar la imagen), `CrashLoopBackOff` (`command: ["sh", "-c", "exit 1"]`), `Running` con `READY 0/1` (una probe que apunte a una ruta que no existe) y `Pending` (pide `resources.requests` imposibles de satisfacer).

5. 🟡 Con un pod en `CrashLoopBackOff`, ejecuta `kubectl logs` y `kubectl logs --previous` y pega las dos salidas. Explica por qué la segunda es la que sirve, en una frase que un compañero pueda repetir.

6. 🟠 Cambia el ConfigMap de la Fase 14 sin reiniciar nada y comprueba que `kubectl get configmap` dice una cosa y `kubectl exec … cat config.json` dice otra. Después arréglalo con `rollout restart`. Escribe el post-mortem de tres líneas y compáralo con el del incidente de caché de la Fase 13: son el mismo bug con dos mecanismos.

7. 🟠 Etiqueta tu imagen como `:latest`, despliégala en kind y anota qué pasa. Después mira el `imagePullPolicy` efectivo con `kubectl get pod <pod> -o yaml | grep imagePullPolicy` y explica el fallo con la §2 en la mano.

8. 🔴 Cierra la 💸 que la Fase 13 dejó abierta, completa. Añade `runAsNonRoot: true` al pod y reproduce el fallo. Después aplica los cuatro cambios de la §8 —imagen base sin privilegios, puerto 8080, Deployment y Service ajustados, y comprobar que el `entrypoint.sh` puede escribir— hasta que la aplicación vuelva a funcionar con la política puesta. Entrega dos cosas: el diff de los cuatro archivos, y el párrafo que le mandarías al equipo de plataforma explicando qué cambió y por qué. El criterio de éxito del párrafo es que alguien que no conozca CertCore entienda el cambio sin abrir el diff.

---

> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida y la imagen, el `nginx.conf` y los manifiestos los escriben las Fases 13 y 14, así que lo que salga de leerlo se commitea con el prefijo de la fase desde la que llegaste (`fase 13: …`, `fase 14: …`). El ejercicio 8 es la excepción interesante: **deja archivos versionados** —Dockerfile, `nginx.conf` y los dos manifiestos—, así que va como un commit de fase normal y merece su propio tag de ejercicio (`ej/a09/8`), que es lo que después te permite leer el cambio entero con un `git diff fase-14 ej/a09/8`. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
