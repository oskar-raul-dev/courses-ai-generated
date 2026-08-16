# 🧱 Temario candidato y valor pedagógico
## Laboratorio de contenedores y Kubernetes local

Documento **exploratorio**. Es el inventario de todo lo que este curso *podría* enseñar, con el
valor pedagógico de cada tema, lo que cuesta y un veredicto de entrada. No manda sobre nada:
existe para alimentar la discusión que produce `propuesta-fases-y-alcance.md`, y **pierde contra
ese documento en cualquier contradicción**.

> 🧭 **El filtro que se aplica a cada tema, y es uno solo:** ¿esto le da al lector **panorámica**
> de la plataforma, o le da **profundidad** que no pidió? Un curso de infraestructura para alguien
> que nunca ha tenido un cluster propio se arruina por exceso, no por defecto.

---

## 0. 🎯 El encuadre que este inventario da por sentado

Antes de leer la lista conviene tener presentes las cinco decisiones que ya se cerraron en la
discusión de arranque, porque son las que explican por qué un tema entra o sale.

**El lector.** Un dev **semi-senior o senior políglota**: ha escrito JavaScript, PHP y Java, monta
endpoints sin pensarlo, entiende un ORM, una migración, un token y un `docker-compose.yml`. Lo que
no tiene es la panorámica del sistema completo, ni una plataforma que pueda romper sin pedir
permiso ni pagar.

**La tesis.** El curso se ordena alrededor de una sola pregunta:

> 🧭 *¿Qué te da el contenedor, qué te da el orquestador, y qué te sigue tocando escribir a ti?*

La primera mitad del curso es lo que la plataforma **sí** te regala. La segunda es lo que no te va
a dar nunca — y por eso existen las sagas.

**El stack, ya cerrado.** Cuatro servicios en cuatro runtimes, un frontend estático, un Postgres
compartido, Valkey, NATS y una observabilidad deliberadamente flaca. Cada pieza está elegida por
la lección de infraestructura que compra, no por variedad.

**El presupuesto.** El laboratorio tiene que correr en una máquina de 8 GB. Es una restricción de
diseño, no una molestia, y aparece en el veredicto de varios temas de abajo.

**Y el paradigma de origen.** El instinto que este curso tiene que recalibrar es el de
`docker-compose`, no el de una máquina virtual. Esa es la 🪞 recurrente del material.

---

## 1. 🗺️ Cómo leer este inventario

Los temas van agrupados en **quince familias**, empezando por la **Familia 0**, que es el suelo
sobre el que se para todo lo demás. Cada tema lleva lo mismo:

- **Qué es**, en una línea.
- **Qué compra**, que es lo único que decide: la lección de plataforma que este tema y ningún otro
  enseña.
- **Qué cuesta**, en fricción, en RAM o en fases de andamiaje.
- **Veredicto**: ✅ entra al camino base · 🔥 opcional o apéndice · 🚫 fuera, con su razón.

Los veredictos son **propuestas**, no decisiones. La discusión es el siguiente paso y es donde se
cierran.

> ⚠️ **Sobre los números de RAM que aparecen abajo.** Son estimaciones de diseño, no mediciones.
> Ninguno de ellos puede citarse en el material del curso hasta que el arnés de medición lo
> produzca. Están aquí para decidir alcance, y se corrigen sin luto cuando el número real
> aparezca.

---

## 2. 🧰 Familia 0 — Prolegómenos: el ambiente y el vocabulario

Es la **Parte 0** del arco, y su regla es distinta a la de todas las demás familias: aquí no se
filtra por profundidad conceptual, se filtra por **si el lector puede seguir sin esto**. Si la
respuesta es no, entra, aunque sea elemental.

> 🧭 **La regla que ordena esta parte:** *primero funciona, después se entiende.* La Familia A
> explica qué es realmente un contenedor; esta hace que el lector tenga uno corriendo antes de esa
> conversación. El orden inverso —teoría del kernel antes del primer `run`— es cómo se pierde a la
> mitad de la audiencia en la primera sesión.

Y una segunda regla, que es la que la separa de un curso de Docker desde cero: **esta parte no se
recrea en nada**. Da el vocabulario mínimo para que el resto del curso pueda darse por entendido y
se detiene ahí. Cada vez que aparezca la tentación de profundizar, el destino correcto es una
familia posterior, donde el tema llega con un problema que lo justifique.

**Prerrequisitos y validación por plataforma.** Windows 11 con WSL 2, macOS Apple Silicon y Linux
amd64: qué hace falta, cómo se comprueba que está bien, y qué hacer con los tres o cuatro fallos
clásicos de virtualización. **Qué compra:** que nadie se quede fuera del curso en la primera hora
por un problema que no es de contenedores. **Qué cuesta:** es el material que más rápido envejece
de todo el curso, y hay que declararlo con fecha de verificación. ✅ **Entra.**

**Docker Desktop y Podman Desktop, instalados y conviviendo.** Los dos en la misma máquina, con
una forma explícita de saber cuál está activo y de alternar. **Qué compra:** que el contraste 🦭
del resto del curso sea reproducible en vez de teórico, y que el lector que solo quiera uno sepa
exactamente qué se pierde. **Qué cuesta:** los dos motores compiten por recursos y por el socket;
hay que decir cómo se evita. ✅ **Entra.**

**El primer contenedor, y los verbos.** `run`, `ps`, `logs`, `exec`, `stop`, `rm`. Con lo que pasa
de verdad en cada uno: qué es `-it`, por qué tu contenedor murió al salir, dónde quedó el que
creíste borrado. **Qué compra:** el bucle de trabajo diario, que el lector va a repetir mil veces
durante el curso. ✅ **Entra.**

**Los tres sustantivos: imagen, contenedor y tag.** La confusión más común de quien llega, y la
que hace que después no se entienda nada del registry ni del rollout. Aquí solo el modelo mental
—la imagen es la plantilla, el contenedor es la instancia, el tag es un apodo móvil—; las capas y
OCI son de la Familia A. **Qué compra:** desactiva de entrada una ambigüedad que envenena cuatro
capítulos posteriores. ✅ **Entra.**

**Anatomía de un Dockerfile.** `FROM`, `WORKDIR`, `COPY`, `RUN`, `ENV`, `EXPOSE`, `CMD` y
`ENTRYPOINT`, y la diferencia entre los dos últimos, que nadie explica bien. Un solo Dockerfile,
de un solo stage, deliberadamente simple. **Qué compra:** el lector escribe y construye su primera
imagen. El multi-stage, el caché y las imágenes base **no entran aquí**: son la Familia B, y
llegan cuando hay cuatro runtimes que empaquetar y algo que medir. ✅ **Entra.**

**Puertos y volúmenes desde la línea de comandos.** `-p`, `-v`, bind mount contra volumen
nombrado, y por qué tu archivo aparece con el dueño equivocado. **Qué compra:** las dos cosas que
el lector necesita el primer día para que su código y su base de datos sean útiles. ✅ **Entra**,
en versión operativa; el modelo completo de red del motor es de la Familia A.

**Compose: el sistema en un archivo.** `services`, `image` contra `build`, `ports`, `environment`,
`volumes`, `depends_on`, `networks`, y los comandos `up`, `down`, `logs`, `ps`, `exec`. **Qué
compra:** la línea base contra la que se compara todo el curso, y el vocabulario de la 🪞 que lo
atraviesa. ✅ **Entra**, y es la pieza más importante de esta parte.

**🦭 `docker compose` contra `podman compose`.** Que el `compose` de Podman no es el mismo programa,
que hay más de una implementación, y qué diferencias de comportamiento vas a notar. **Qué compra:**
evita una tarde perdida al lector que eligió Podman, y estrena el marcador 🦭 en un sitio inocuo
antes de que aparezca donde duele. ✅ **Entra**, corto.

**De dónde salen las imágenes.** Docker Hub, `pull`, qué significa `:latest` y la fricción muy real
de los límites de descarga anónima. **Qué compra:** el lector entiende por qué su build falló a la
tercera y cómo se evita, y queda sembrado el concepto de registry que la Familia B recoge.
✅ **Entra**, mínimo.

**Limpieza y espacio en disco.** `system prune`, imágenes huérfanas, volúmenes que nadie borró, y
el disco que se llenó sin que nadie sepa por qué. **Qué compra:** es el problema operativo más
común de cualquiera que empieza, y cuesta tres párrafos. ✅ **Entra.**

**🩺 Los incidentes de instalación.** WSL 2 que no arranca, virtualización deshabilitada en BIOS,
la máquina de Podman que no levanta, el puerto 80 ya ocupado, el socket al que no tienes permiso.
Con el mismo formato que el resto de incidentes del curso: síntoma, evidencia, causa, primer
comando. **Qué compra:** convierte la fricción inevitable de la instalación en material en vez de
en abandono. ✅ **Entra**, y es la primera entrada del cuaderno de incidentes.

> 📝 **Y una nota que este curso puede dar y el de contenedores heredados no:** al trabajar con
> las versiones actuales de los cuatro runtimes, **no hace falta ningún toolchain de compilación
> dentro de las imágenes**. Las dependencias nativas de Node llegan precompiladas, las extensiones
> de PHP vienen en las imágenes oficiales, Java no compila nada nativo y Go compila estático en su
> propia etapa. Eso simplifica los Dockerfiles del curso enormemente — y por eso mismo **se dice
> en voz alta dónde dejaría de ser verdad**: una dependencia sin binario para tu arquitectura, una
> extensión de PHP que no está empaquetada, o una imagen base con musl en vez de glibc. Se nombra,
> se explica el síntoma, y se sigue.

**Lo que esta familia deja fuera a propósito**, con su destino: el multi-stage y el caché de capas
(Familia B) · las capas y OCI (Familia A) · rootless y permisos a fondo (Familia A) ·
`docker-compose` como herramienta de producción (🚫 fuera: no lo es, y decirlo es parte del
contenido) · la arqueología del motor, los plugins de red y los drivers de almacenamiento
(🚫 fuera, sin remordimiento).

---

## 3. 🐳 Familia A — El contenedor, de verdad

Es la Parte I del arco, y llega con el lector ya teniendo contenedores corriendo gracias a la
Familia 0. Lo que no tiene todavía es el modelo mental de qué está pasando debajo. Y aquí está la
tentación más grande del curso: convertirlo en un tratado de namespaces y cgroups. **Se resiste.**
Este curso enseña el modelo, no el kernel.

**Qué es realmente un contenedor.** Un proceso del host con la vista recortada — namespaces,
cgroups, un sistema de archivos propio. **Qué compra:** desactiva de entrada la analogía con la
máquina virtual, que es de donde salen la mitad de los errores de intuición de este perfil (*"le
pongo más RAM"*, *"le meto systemd dentro"*, *"le entro por SSH"*). **Qué cuesta:** media fase, y
la disciplina de no seguir bajando. ✅ **Entra**, con una regla explícita: se explica hasta el
punto en que cambia una decisión, y ni un milímetro más.

**La imagen y sus capas.** Sistema de archivos apilado, capas inmutables, la capa de escritura del
contenedor. **Qué compra:** es lo que hace comprensibles el caché de build, el tamaño de la imagen
y por qué los datos se van cuando el contenedor muere. Sin esto, el capítulo de almacenamiento es
magia. ✅ **Entra.**

**El estándar OCI y por qué importa.** Imagen, runtime y distribución como especificaciones
separadas. **Qué compra:** es la explicación de por qué construyes con Podman y corres en
containerd sin que nada se rompa, y de por qué el debate Docker-contra-Podman es mucho menos
dramático de lo que parece en internet. ✅ **Entra**, pero como una sección corta, no como fase.

**El proceso PID 1, las señales y el apagado limpio.** Quién recibe el `SIGTERM`, qué pasa si tu
proceso lo ignora, y de dónde salen los contenedores zombis. **Qué compra:** es la mitad
invisible de un rollout sin downtime — un pod que no atiende `SIGTERM` corta peticiones en vuelo
cada vez que despliegas. **Qué cuesta:** poco, y se amortiza dos veces (aquí y en el capítulo de
ciclo de vida del pod). ✅ **Entra.**

**Usuarios, permisos y rootless.** Correr como no-root, el mapeo de UID, y por qué tu volumen
aparece con permisos raros. **Qué compra:** es el origen del `CrashLoopBackOff` más frustrante que
existe —el que no deja ni un log útil— y es un prerrequisito real de la fase de `securityContext`.
✅ **Entra**, con alcance acotado: lo que se necesita para no romperse, no la teoría de user
namespaces.

**Redes y volúmenes del motor.** `bridge`, `host`, publicación de puertos, bind mounts y volúmenes
nombrados. **Qué compra:** es el vocabulario contra el que se va a comparar toda la red de
Kubernetes. **Qué cuesta:** el lector ya sabe la mitad. ✅ **Entra**, comprimido, y apoyándose en
lo que ya sabe.

**cgroups y namespaces por dentro.** 🚫 **Fuera.** Es exactamente la profundidad que este lector no
pidió. Se nombra qué son, se dice dónde se lee más, y se sigue.

**Construcción de imágenes sin Docker** (Buildah, Kaniko, ko, Jib). 🔥 **Apéndice.** Interesante y
genuinamente útil en CI, pero no cambia ninguna decisión del laboratorio.

---

## 4. 📦 Familia B — Empaquetar los cuatro runtimes

Aquí está la primera gran oportunidad de medición del curso, y es la que fija el arnés.

**El Dockerfile multi-stage, cuatro veces.** El mismo patrón —compilar en una imagen gorda,
copiar el resultado a una flaca— resuelto en Java, PHP, Node y Go. **Qué compra:** el lector ve
que el patrón es uno y que **cada runtime lo paga distinto**, y eso es panorámica pura. ✅ **Entra**,
y es una de las fases centrales.

**📏 La medición de las cuatro imágenes.** Tamaño final, tiempo de build en frío, tiempo de build
con caché, tiempo de arranque hasta el primer request atendido. **Qué compra:** el rango completo
entre una imagen distroless de Go y una de Spring Boot. Esa tabla es la que el lector va a
recordar tres años después, y es la que hace defendible todo lo demás. ✅ **Entra**, y es la
primera 📏 del curso.

**Imágenes base: distroless, Alpine, slim, UBI.** Qué te llevas y qué pierdes con cada una —musl
contra glibc, el shell que ya no tienes para depurar, la superficie de CVE. **Qué compra:** una
decisión real que el lector va a tomar en su trabajo el mes que viene, y que casi nadie toma con
criterio. ✅ **Entra**, como sección de la fase anterior.

**El caché de capas y el contexto de build.** Orden de instrucciones, `.dockerignore`, por qué
copiar el código antes que las dependencias te cuesta minutos en cada build. **Qué compra:**
tiempo real, medible, en el ciclo de trabajo del propio curso. ✅ **Entra.**

**Arquitecturas y builds multiplataforma.** ARM contra amd64, `--platform`, la imagen que corre
lentísima bajo emulación. **Qué compra:** el lector en Apple Silicon se va a estrellar con esto
sí o sí, y el diagnóstico —*"¿por qué mi pod tarda 40 segundos en arrancar?"*— no es obvio.
🔥 **Apéndice**, con un puntero desde la fase de imágenes, porque solo le pasa a una parte del
público.

**SBOM, firma de imágenes y cadena de suministro.** 🚫 **Fuera** del camino base. Importa mucho y es
otro curso: exige un registry con políticas, una cadena de CI y un modelo de amenazas. Se declara
la exclusión y se para ahí.

**Registries.** Cómo se distribuye una imagen, manifiestos, tags contra digests. **Qué compra:**
el digest frente al tag es una lección de oro —`:latest` es la causa raíz de una familia entera
de "pero si yo desplegué el arreglo"—. ✅ **Entra** en versión mínima: el concepto y el digest.
El registry local con TLS propio es 🔥.

---

## 5. 🦭 Familia C — Docker y Podman, sin guerra

Este eje estaba en el diseño original como una comparación de arquitecturas. Con el tratamiento
legacy fuera, se reduce y mejora: **los dos motores entran como herramienta, no como tesis**.

**Un motor u otro, y el mismo cluster encima.** Que kind corra sobre cualquiera de los dos, y que
las imágenes viajen entre ellos porque OCI. **Qué compra:** la lección tranquilizadora de que esto
es un estándar y no un ecosistema cautivo. ✅ **Entra**, corto.

**Dónde divergen de verdad** 🦭 — el demonio contra el modelo sin demonio, rootless por defecto,
el puerto 80 que Podman no te deja publicar sin más, la máquina virtual de Podman en macOS y
Windows contra el WSL de Docker. **Qué compra:** son los sitios exactos donde el lector se va a
atascar, y merecen un marcador propio que se pueda buscar. ✅ **Entra**, distribuido: cada
divergencia se cuenta donde duele, no en un capítulo de comparación.

**📏 La medición de los dos motores.** Tiempo de `kind create cluster`, tiempo de build, RAM del
host en reposo. **Qué compra:** convierte una discusión de foro en una tabla. **Qué cuesta:** que
el lector tenga los dos instalados, lo cual no siempre pasa. ✅ **Entra**, con la medición
declarada como opcional de ejecutar: los números del curso están publicados y el lector puede
leerlos sin reproducirlos.

**`podman generate kube`.** Generar manifiestos desde contenedores corriendo. **Qué compra:** es
un puente conceptual bonito entre los dos mundos. **Qué cuesta:** produce YAML que nadie
desplegaría tal cual, y puede enseñar malos hábitos. 🔥 **Opcional**, como curiosidad bien
enmarcada.

**Podman Desktop y Docker Desktop como GUI.** 🔥 **Apéndice.** Útil para quien arranca, irrelevante
para el contenido.

---

## 6. 🪜 Familia D — Del compose al cluster

Es la bisagra del curso y, creo, su mejor material. Aquí vive la 🪞 recurrente.

**El sistema entero en `docker-compose`, primero.** Los cuatro servicios, Postgres y el frontend,
corriendo con un solo comando. **Qué compra:** tres cosas a la vez — el lector tiene el sistema
funcionando en la primera sesión, el dominio queda establecido sin mezclarlo con Kubernetes, y
**queda una línea base contra la cual comparar todo lo que viene**. ✅ **Entra**, y creo que debería
ser de las primeras fases.

**🪞 Dónde se rompe el instinto de compose.** `depends_on` no espera a que el servicio esté listo;
`restart: always` no es un `Deployment`; la red de compose resuelve por nombre de servicio pero no
es DNS de cluster; `scale` te da réplicas pero nadie las balancea de verdad; tus volúmenes son del
host y punto. **Qué compra:** es el músculo central del curso y ningún tutorial lo entrena, porque
todos arrancan en el `kubectl apply`. ✅ **Entra**, y es una sección recurrente, no una sola fase.

**📖 El diccionario compose ⇄ Kubernetes, en las dos direcciones.** `service` ⇄ `Deployment` +
`Service`, `ports` ⇄ `Service` + `Ingress`, `environment` ⇄ `ConfigMap`, `volumes` ⇄ `PVC`,
`healthcheck` ⇄ probes, `deploy.replicas` ⇄ `replicas`. **Qué compra:** el lector puede traducir
cualquier compose que tenga en su trabajo, que es transferencia inmediata. ✅ **Entra.**

**Qué no tiene traducción.** `Namespace`, `ServiceAccount`, RBAC, el planificador, `PodDisruptionBudget`,
el bucle de reconciliación. **Qué compra:** marca la frontera de lo que es genuinamente nuevo, y
le dice al lector dónde gastar atención. ✅ **Entra**, como cierre de la fase anterior.

**El bucle de reconciliación y el modelo declarativo.** Que le dices al cluster qué quieres, no
qué haga, y que algo trabaja sin parar para que se parezca. **Qué compra:** es **el** concepto
del que cuelgan todos los demás. Sin él, Kubernetes es una API rara; con él, casi todo se deduce.
✅ **Entra**, y probablemente sea el concepto más importante de todo el curso.

---

## 7. ☸️ Familia E — El cluster local y los objetos que importan

**Elegir el cluster local.** kind, k3d, minikube, MicroK8s, Docker Desktop. **Qué compra:** una
decisión informada en vez de copiar el primer tutorial. **Qué cuesta:** es fácil que se convierta
en una comparativa interminable. ✅ **Entra** en forma acotada: **kind es el cluster del curso**, y
los demás se miden una vez —tiempo de arranque, RAM en reposo, multi-nodo sí o no— y se archivan.

**La topología del cluster.** Control plane y workers, qué corre en cada uno, `extraPortMappings`
para que el Ingress se vea desde el host. **Qué compra:** entender por qué `localhost:8080` llega
o no llega a tu pod, que es la primera frustración de todo el mundo. ✅ **Entra.**

**Pod, ReplicaSet, Deployment.** La escalera completa, incluyendo por qué casi nunca escribes un
Pod a mano. **Qué compra:** el objeto de trabajo diario. ✅ **Entra.**

**El primer despliegue, en YAML plano y a mano.** Sin Helm, sin plantillas. **Qué compra:** que el
lector vea los campos reales antes de que una herramienta se los genere. Helm sobre un modelo que
no entiendes es una máquina de frustración. ✅ **Entra**, y el orden importa: **YAML plano primero,
siempre.**

**`Job` y `CronJob`.** El trabajo que termina. **Qué compra:** el seed de la base, las migraciones
y el reporte nocturno — tres necesidades reales del laboratorio, no ejemplos inventados.
✅ **Entra**, amarrado al seed.

**`DaemonSet`.** Un pod por nodo. **Qué compra:** es cómo funciona el recolector de logs, así que
se enseña donde ya hace falta. ✅ **Entra**, dentro de la fase de logs.

**`StatefulSet`.** Identidad estable, arranque ordenado, un PVC por pod, `Service` headless.
**Qué compra:** la familia de objetos que todo el mundo salta y que es la que de verdad distingue
a quien sabe operar. ✅ **Entra**, con Postgres como sujeto.

**Operators y CRDs.** 🔥 **Apéndice de lectura.** El lector tiene que saber qué son porque los va a
encontrar en cualquier cluster real, pero escribir uno es otro curso. Se explica el concepto, se
muestra uno instalado, y se para.

**RBAC, `ServiceAccount`, roles.** **Qué compra:** por qué tu pod no puede leer un Secret, y por
qué la GUI del cluster te muestra la mitad de las cosas. ✅ **Entra** en versión mínima y
práctica, provocada por un fallo real.

**El planificador, afinidad, taints y tolerations.** **Qué compra:** por qué tu pod está en
`Pending` sin explicación aparente. **Qué cuesta:** el segundo nodo worker, que en el perfil
mínimo está apagado. ✅ **Entra** en versión mínima —`Pending` y `describe pod`—; afinidad y taints
son 🔥.

---

## 8. 🌐 Familia F — Red, descubrimiento y entrada

**`Service` y el DNS interno.** ClusterIP, el nombre estable, el balanceo. **Qué compra:** es la
respuesta a *"¿cómo se llaman entre sí mis servicios?"*, que es la primera pregunta de cualquiera
que llega de compose. ✅ **Entra.**

**Los tipos de `Service`.** ClusterIP, NodePort, LoadBalancer y por qué el último se queda
`Pending` para siempre en local. **Qué compra:** una de las frustraciones más comunes, resuelta
con su explicación honesta: **en local no hay nube que te dé una IP**. ✅ **Entra**, y es un buen
sitio para el primer 🚧 *"hasta aquí llega el laboratorio"*.

**`Ingress` y el controlador.** Enrutado por host y por ruta, y que el objeto no hace nada sin
alguien que lo implemente. **Qué compra:** la entrada única al sistema, y el concepto de
controlador. ✅ **Entra.**

**Gateway API.** El sucesor declarado de Ingress. **Qué compra:** que el lector no aprenda hoy
algo que va a estar en retirada. **Qué cuesta:** todavía no es lo que se encuentra en la mayoría
de clusters. ✅ **Entra como sección corta** dentro de la fase de Ingress: se nombra, se muestra
la diferencia, y se sigue con Ingress.

**Dominio local y resolución.** `.localhost`, `/etc/hosts`, por qué tu navegador llega y tu `curl`
no. **Qué compra:** quita una hora de frustración a cada lector. ✅ **Entra.**

**`NetworkPolicy`.** Quién puede hablar con quién, y el descubrimiento de que **por defecto todo el
mundo puede hablar con todo el mundo**. **Qué compra:** es la lección de seguridad más
transferible del curso y se demuestra en dos minutos. ✅ **Entra**, con el experimento 🧨 de
exponer una base de datos por accidente.

**Service mesh (Linkerd).** mTLS automático, reintentos, métricas de red sin tocar el código.
**Qué compra:** es la respuesta real a media Parte IV, y verlo funcionar cambia el criterio del
lector. **Qué cuesta:** RAM, un plano de control entero y complejidad conceptual encima de un
lector que acaba de conocer los `Service`. 🔥 **Opcional**, al final, y honesto sobre su costo.

---

## 9. ⚙️ Familia G — Configuración y secretos

**`ConfigMap` y variables de entorno.** **Qué compra:** el mecanismo básico, y de paso la lección
de que cambiar un ConfigMap no reinicia nada. ✅ **Entra.**

**`Secret`, y la verdad incómoda.** Que están en base64, que eso no es cifrado, y qué hace falta
de verdad. **Qué compra:** desactiva una creencia falsa muy extendida. ✅ **Entra.**

**La configuración horneada en build contra la inyectada en arranque.** El frontend estático es el
caso perfecto: su `API_URL` se hornea al compilar, y el contenedor espera inyectarla al arrancar.
**Qué compra:** es la causa raíz de la mitad de los *"funciona en QA y no en prod"* de cualquier
SPA, y aquí se ve con dos despliegues de la misma imagen. ✅ **Entra**, y es un candidato fuerte a
pieza ⭐.

**Perfiles por ambiente.** Los `values-*.yaml`, qué varía y qué no. ✅ **Entra**, amarrado a Helm.

**Gestores de secretos externos** (Vault, External Secrets, SOPS). 🚫 **Fuera** del camino base, con
la exclusión declarada: exigen infraestructura que el laboratorio no tiene y no cambian ninguna
decisión local.

---

## 10. 💾 Familia H — Estado y almacenamiento

**🧨 El experimento del stock fantasma.** El servicio arranca con SQLite dentro del pod,
funcionando perfecto. Subes a dos réplicas. Las dos responden, ninguna falla, ningún log se
queja — y el stock aparece y desaparece según qué réplica conteste. **Qué compra:** la mejor
puerta de entrada posible al capítulo de estado, porque es un fallo **silencioso**, y nadie olvida
un bug que no produce ningún error. ✅ **Entra**, y creo que es una de las mejores ideas del curso.

**Volúmenes, `PersistentVolume`, `PersistentVolumeClaim`, `StorageClass`.** **Qué compra:** el
modelo de almacenamiento completo, motivado por el fallo anterior. ✅ **Entra.**

**Postgres en el cluster, y si eso es buena idea.** **Qué compra:** un ⚖️ veredicto honesto de los
buenos — *"lo vas a hacer en el laboratorio y probablemente no deberías hacerlo en producción, y
aquí está por qué"*. ✅ **Entra.**

**Migraciones de esquema en un despliegue.** Job de migración, el orden contra el rollout, qué
pasa si dos réplicas migran a la vez. **Qué compra:** un problema real que el lector tiene hoy en
su trabajo y probablemente resuelve a mano. ✅ **Entra.**

**Backup, restore y snapshots.** 🔥 **Opcional.** Importante en la vida real, poco denso en concepto
nuevo para lo que cuesta.

---

## 11. 📦 Familia I — Helm y el paquete desplegable

**Por qué YAML plano deja de alcanzar.** Cuatro servicios por tres ambientes son doce archivos
casi idénticos. **Qué compra:** la herramienta llega **después** del dolor, que es la regla del
andamio. ✅ **Entra.**

**Chart, plantillas, valores, releases.** El modelo de Helm y qué es realmente un release.
✅ **Entra.**

**Umbrella chart y subcharts por servicio.** **Qué compra:** el patrón real de un monorepo de
microservicios, y la disciplina de qué va en el chart base y qué en el override. ✅ **Entra.**

**`upgrade`, `rollback`, `--dry-run`, `helm diff`.** **Qué compra:** operación de verdad, y la red
de seguridad que hace que el lector se atreva a tocar. ✅ **Entra.**

**Hooks de Helm.** Para el seed y las migraciones. ✅ **Entra**, corto.

**Kustomize como alternativa.** **Qué compra:** que el lector sepa que hay dos escuelas y en qué se
diferencian —plantillas contra parches—. ✅ **Entra como sección corta**, no como fase.

**Helmfile, ArgoCD, Flux, GitOps.** 🔥 **Apéndice de lectura.** GitOps es el destino natural de todo
esto y merece nombrarse con honestidad, pero montarlo exige un repositorio, un flujo y un plano de
control que duplican el alcance del curso.

---

## 12. 📈 Familia J — Escalado, salud y ciclo de vida

**Probes: liveness, readiness, startup.** Las tres, y sobre todo la diferencia entre las dos
primeras, que casi nadie tiene clara. **Qué compra:** una readiness mal puesta corta tráfico en
cada despliegue, y una liveness mal puesta reinicia pods sanos en bucle. Los dos fallos son
comunes y los dos son invisibles. ✅ **Entra**, y es pieza ⭐.

**La readiness de cada runtime.** Spring Boot tarda segundos y Go milisegundos; PHP-FPM está
"listo" antes de poder atender de verdad. **Qué compra:** que el lector vea que el mismo campo del
YAML significa cosas distintas según lo que corre debajo. ✅ **Entra.**

**`requests` y `limits`.** Qué le prometes al planificador y qué te impone el cgroup. **Qué
compra:** el `Pending` por recursos y el `OOMKilled` salen de aquí. ✅ **Entra.**

**⚰️ La autopsia del `OOMKilled` de la JVM.** El heap que no sabe que está en un contenedor, el pod
que muere sin escribir ni un error, y `MaxRAMPercentage` como arreglo. **Qué compra:** es la mejor
autopsia de anti-patrón que este stack puede ofrecer, con números antes y después. ✅ **Entra**, y
es otra candidata a ⭐.

**Rollouts, estrategias y el apagado limpio.** RollingUpdate, `maxSurge`, `maxUnavailable`,
`terminationGracePeriodSeconds`, y el `preStop` que le da tiempo al balanceador a enterarse.
**Qué compra:** desplegar sin cortar peticiones, que es literalmente el trabajo. ✅ **Entra.**

**Escalado manual y HPA.** **Qué compra:** el escalado automático es lo que el lector cree que es
Kubernetes, así que hay que darle eso **y** su decepción honesta: el HPA reacciona tarde, mide una
sola métrica, y con PHP-FPM se comporta distinto que con Node. ✅ **Entra.**

**📏 La medición de escalado.** Con carga generada, cuántas réplicas de cada runtime hacen falta
para sostener la misma tasa de peticiones, y cuánta RAM cuesta cada una. **Qué compra:** la tabla
que cierra la tesis de la Parte II. ✅ **Entra.**

**`PodDisruptionBudget`, autoescalado de nodos, multi-zona.** 🚧 **Frontera declarada.** Se nombran
como lo que existe del otro lado y no se pueden reproducir gratis en local.

---

## 13. 🔭 Familia K — Observabilidad

**Qué es cada pilar y cuándo sirve.** Métricas para saber que algo va mal, logs para saber qué,
trazas para saber dónde. **Qué compra:** el criterio de a cuál mirar primero, que es lo que separa
diagnosticar de adivinar. ✅ **Entra.**

**Métricas: el modelo de pull y el `scrape_config` escrito a mano.** **Qué compra:** entender el
modelo antes de que un Operator lo esconda. ✅ **Entra.**

**Instrumentar los cuatro runtimes.** Micrometer, `prom-client`, el cliente de PHP, `client_golang`.
**Qué compra:** que exponer `/metrics` es responsabilidad de la aplicación, no regalo de la
plataforma — y eso es tesis del curso. ✅ **Entra**, pero comprimido: es el mismo concepto cuatro
veces.

**Las métricas que da el cluster gratis.** metrics-server, lo que trae el kubelet, y por qué eso no
te dice nada del negocio. ✅ **Entra**, corto.

**Logs a stdout, en JSON, y por qué no a archivo.** **Qué compra:** la regla operativa que hace que
la recolección sea uniforme, y la fricción real de conseguirlo en Java y en PHP, que por defecto
loguean texto plano. ✅ **Entra.**

**Loki, LogQL y buscar a través de cuatro servicios.** ✅ **Entra.**

**Trazas distribuidas y el `trace-id` propagado.** **Qué compra:** es lo único que responde *"¿por
qué esta venta tardó ocho segundos?"* cuando pasó por cuatro servicios. ✅ **Entra**, en la Parte
IV, que es donde por fin hay algo que trazar.

**OpenTelemetry como capa común.** 🔥 **Sección corta.** Es hacia donde va todo el ecosistema y
merece nombrarse; instrumentarlo entero en cuatro runtimes no cabe.

**Dashboards como código y alertas.** Dashboards provisionados sí, ✅. Alertmanager y una cadena de
alerta de verdad, 🚫 **fuera**: sin guardias ni destinatario, una alerta es un ejercicio vacío.

---

## 14. 🔐 Familia L — TLS y certificados

Esta rama ya está diseñada en el material previo y es de lo mejor que hay en la carpeta. La
traigo casi entera.

**TLS en el Ingress con una CA propia.** Generar la CA, firmar con SAN correcto, montarlo como
`Secret` TLS, confiar en la CA desde el host. **Qué compra:** entender de una vez la cadena de
confianza, que casi nadie entiende del todo. ✅ **Entra.**

**cert-manager.** Emisión y renovación automáticas con un `ClusterIssuer` propio. **Qué compra:** el
patrón que el lector va a encontrar en cualquier cluster real. ✅ **Entra.**

**mTLS entre servicios.** A mano primero, y después con el mesh si se hace 🔥. **Qué compra:** el
concepto de confianza mutua y cero-confianza interna. ✅ **Entra** la versión a mano; el mesh
queda opcional.

**🧨 El laboratorio de incidentes de certificados.** Certificado expirado, CA desconocida, SAN
incorrecto, clave y certificado desparejados, cert-manager que no emite, mTLS sin certificado de
cliente. Cada uno con su síntoma, su evidencia, su causa y su primer comando. **Qué compra:** es,
en mi opinión, **el mejor activo individual de todo el curso** — nadie enseña esto y todo el mundo
lo sufre. ✅ **Entra**, y merece ser pieza ⭐.

**`securityContext`, `runAsNonRoot`, capacidades, Pod Security Standards.** **Qué compra:** el
endurecimiento mínimo que cualquiera debería aplicar, y la conexión con la familia A. ✅ **Entra**,
en versión práctica.

---

## 15. 🩺 Familia M — El laboratorio de incidentes de plataforma

Hermano del anterior, y creo que la segunda mejor idea del curso. Cada incidente sigue el mismo
formato: **qué provocar, qué síntoma esperar, qué mirar primero, cuál es la causa, cómo se
arregla, y cómo se previene.**

El catálogo candidato, todos reproducibles en el laboratorio:

`ImagePullBackOff` por tag inexistente y por imagen que nunca se cargó al cluster ·
`CrashLoopBackOff` por permisos, por variable ausente y por puerto ocupado · `OOMKilled` de la JVM ·
`Pending` por recursos y por PVC sin enlazar · readiness que nunca pasa a verde · liveness
demasiado agresiva reiniciando pods sanos · DNS interno que no resuelve por namespace equivocado ·
`Service` sin endpoints porque el selector no coincide con las labels · `Ingress` que devuelve 404
porque la ruta no es la que crees · ConfigMap cambiado que no reinicia nada · secreto ausente ·
PVC pegado en `Terminating` · el nodo que se queda sin disco y desaloja pods · el rollout que se
queda a medias y no avanza.

**Qué compra:** convierte al lector de alguien que despliega en alguien que **diagnostica**, que es
la diferencia entre haber hecho un tutorial y saber operar. Y cada incidente entrena el reflejo de
los primeros treinta segundos, que es donde se gana o se pierde una guardia. ✅ **Entra**, y creo
que debería tener **cuaderno propio**, con IDs estables, como en los cursos hermanos del
repositorio.

**Herramientas de diagnóstico.** `kubectl describe`, `logs --previous`, `events`, `exec`,
`port-forward`, `debug` con contenedores efímeros, k9s. **Qué compra:** el kit de trabajo diario.
✅ **Entra**, repartido: cada herramienta se estrena en el incidente que la necesita, nunca en una
lista.

**k9s y Headlamp.** ✅ **Entra** k9s, que es el que se usa a diario. Headlamp 🔥.

---

## 16. 🔀 Familia N — Patrones distribuidos

Es la Parte IV y es la que demuestra la tesis: **nada de esto lo resuelve Kubernetes.**

**gRPC entre dos servicios.** Contrato en Protobuf, HTTP/2, y el problema real que tiene dentro de
un cluster: el balanceo de un `Service` de Kubernetes funciona por conexión, y gRPC mantiene la
conexión abierta — así que **todo tu tráfico se va a una sola réplica**. **Qué compra:** un fallo
sutil, medible y específico de la combinación, que es exactamente el tipo de cosa que este curso
existe para enseñar. ✅ **Entra**, y es pieza ⭐.

**REST síncrono y sus límites.** El fallo en cascada, el timeout que no pusiste, el reintento que
empeora las cosas. ✅ **Entra**, como la motivación de todo lo que sigue.

**Resiliencia: timeouts, reintentos, backoff, circuit breaker.** Y la pregunta buena: **¿esto va en
tu código o en la plataforma?** **Qué compra:** es la tesis del curso aplicada a una decisión
concreta y cotidiana. ✅ **Entra.**

**Saga orquestada.** Un servicio coordina, y las compensaciones son código que tú escribes.
**Qué compra:** entender que no hay transacción distribuida gratis y que "deshacer" es una
operación de negocio, no técnica. ✅ **Entra**, con `inventory` de orquestador.

**Saga coreografiada por eventos.** Sin coordinador, cada servicio reacciona. **Qué compra:** el
contraste directo con la anterior, y el ⚖️ veredicto de cuándo conviene cada una —que es lo que
nadie te dice. ✅ **Entra.**

**🧨 Valkey pub/sub primero, y perder mensajes.** Se monta la coreografía sobre pub/sub, funciona,
y entonces se reinicia un consumidor durante una venta. El mensaje no existió nunca. **Qué
compra:** la motivación real de todo lo que viene después, sentida en vez de explicada.
✅ **Entra.**

**NATS con JetStream y la entrega *at-least-once*.** **Qué compra:** el arreglo del fallo anterior,
y su factura inmediata: si entrego al menos una vez, entrego dos veces. ✅ **Entra.**

**Idempotencia.** La consecuencia directa de lo anterior: claves de idempotencia, operaciones que
se pueden repetir sin daño. ✅ **Entra.**

**El patrón outbox.** Escribir el evento en la misma transacción que el dato, y un proceso aparte
que lo publica. **Qué compra:** resuelve la escritura dual, que es el bug distribuido más común y
el peor diagnosticado. ✅ **Entra**, y es candidata a ⭐.

**Event sourcing y CQRS.** 🚫 **Fuera**, con la exclusión declarada. Son patrones de arquitectura de
datos, no de infraestructura, y se comen un curso entero.

**El generador de caos.** Inyectar latencia, errores intermitentes y respuestas malformadas entre
servicios para ver qué aguanta. **Qué compra:** convierte los patrones anteriores en algo
demostrable en vez de creído. ✅ **Entra**, como código propio del curso, no como herramienta
externa.

---

## 17. 🌩️ Familia O — La frontera con la nube

No es una familia de temas: es una **sección recurrente** que aparece en casi todas las fases, y
es lo que convierte un laboratorio local en conocimiento transferible.

**📖 El diccionario local ⇄ nube, en las dos direcciones.** `Ingress` ⇄ ALB o Application Gateway ·
`kind load` ⇄ ECR, GCR, ACR · `Secret` ⇄ Secrets Manager · `StorageClass` ⇄ EBS o Persistent Disk ·
`Service type: LoadBalancer` ⇄ una IP que alguien te factura · `HPA` ⇄ autoescalado de nodos
encima. ✅ **Entra**, distribuido por todo el curso.

**🚧 Lo que el laboratorio no puede darte.** Un control plane gestionado y su disponibilidad, un
balanceador de verdad, multi-zona, autoescalado de nodos, IAM y la identidad de carga de trabajo,
el coste como restricción de diseño. **Qué compra:** honestidad, que es lo que evita que el lector
salga creyendo que ya vio la nube. ✅ **Entra**, declarado en cada sitio donde toca.

**Desplegar en una nube de verdad.** 🚫 **Fuera.** Cuesta dinero y rompe la premisa del curso. Se
declara la exclusión y se para ahí.

---

## 18. 🚫 Familia P — Lo que dejo fuera, junto

Reunidos aquí para que la exclusión sea visible y no se pierda entre los veredictos:

**cgroups y namespaces por dentro** (profundidad no pedida) · **SBOM, firma y cadena de
suministro** (otro curso) · **gestores de secretos externos** (infraestructura ausente) ·
**Alertmanager y guardias** (sin destinatario, es un ejercicio vacío) · **event sourcing y CQRS**
(arquitectura de datos) · **desplegar en nube de pago** (rompe la premisa) · **escribir un
Operator** (otro curso) · **un segundo motor relacional** (no enseña nada nuevo de Kubernetes) ·
**Kafka** (RAM y ceremonia; NATS enseña lo mismo) · **Next.js con SSR en el camino base**
(🔥 apéndice) · **MongoDB en el camino base** (🔥 apéndice: el `StatefulSet` se enseña con Postgres).

---

## 19. ⚖️ El recuento, y lo que hay que decidir

Contando solo lo marcado ✅, salen alrededor de **setenta temas**, que es demasiado para una fase
cada uno y razonable para **veinte a veinticuatro fases** de tres o cuatro temas. Está en el
orden de magnitud de los cursos hermanos del repositorio.

El reparto por parte, tal como quedaría:

| Parte | Familias | Temas ✅ | Fases estimadas |
|---|---|---|---|
| **0 · Prolegómenos** | 0 | ~11 | 3 |
| **I · El modelo y el salto** | A, B, C, D | ~18 | 4-5 |
| **II · El despliegue** | E, F, G, H, I, J | ~26 | 8-9 |
| **III · Operarlo** | K, L, M | ~12 | 4-5 |
| **IV · El lab de patrones** | N | ~10 | 4 |
| **Transversal** | O | — | — |

> 🧭 **La Parte 0 resuelve el problema de ritmo de la Parte I.** Con el ambiente, el Dockerfile y
> el compose resueltos en tres fases de manos en la masa, la Parte I deja de tener que enseñar a
> usar nada y se queda con lo que de verdad le toca: **qué está pasando debajo, y por qué compose
> deja de alcanzar.** Eso la comprime a cuatro o cinco fases sin perder ningún tema, y pone al
> lector delante de un cluster en la séptima u octava en vez de en la quinta — pero llegando con
> el sistema ya corriendo en su máquina, que es un punto de partida completamente distinto.

### Las preguntas que la discusión tiene que cerrar

1. **¿Tres fases de Parte 0 son suficientes, o se va a dos?** Mi reparto sería: instalación y
   validación en las tres plataformas · el primer contenedor, el Dockerfile y los tres sustantivos ·
   compose y el sistema completo corriendo. Se puede comprimir a dos fusionando la primera con la
   segunda, a costa de que la fase de instalación —que es la que más fallos produce— pierda sitio
   para sus incidentes 🩺.
2. **¿El cuaderno de incidentes es un archivo propio o va repartido en las fases?** El repositorio
   tiene precedente de las dos formas. Mi recomendación es **cuaderno propio**, porque el lector
   lo va a consultar por síntoma, no por fase.
3. **¿La rama TLS va donde está o al final?** El diseño previo la ponía después del MVP, y creo
   que tenía razón: añadir TLS sobre algo que ya funciona enseña más que arrancar con TLS.
4. **¿Se declara reparto horario?** Angular lo hace (122 h), Python no. Para un curso con tanto
   tiempo de espera de cluster, las horas son difíciles de estimar honestamente.
5. **¿Cuántos incidentes?** El catálogo de la familia M da para unos quince de plataforma más los
   seis de certificados. Veintiuno es un buen número y está en línea con los cursos hermanos.
6. **¿Hay proyecto final?** Un encargo de cierre que obligue a usar todo —desplegar un servicio
   nuevo de cero, con su chart, sus probes, sus métricas y su participación en la saga— sería el
   mejor criterio de éxito posible. Cuesta una fase.
