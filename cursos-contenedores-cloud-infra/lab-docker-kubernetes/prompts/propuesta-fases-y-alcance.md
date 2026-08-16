# 🗺️ Propuesta de fases, apéndices y alcance
## Laboratorio de contenedores y Kubernetes local

Este documento es la **fuente de verdad estructural del curso**. Fija el arco, la secuencia
numerada de fases, el encargo de cada una, los apéndices, el cuaderno de incidentes, las
convenciones de archivo y de git, y las decisiones cerradas con su porqué.

Manda sobre la guía de estilo y sobre las plantillas. Solo `alcance-del-proyecto.md` está por
encima, y únicamente en lo que toca al encuadre, al perfil del lector y a las versiones fijadas.

> 🧭 **La pregunta que ordena el curso entero:** *¿qué te da el contenedor, qué te da el
> orquestador, y qué te sigue tocando escribir a ti?*
>
> Las Partes 0 a III son lo que la plataforma **sí** te regala. La Parte IV es lo que no te va a
> dar nunca, y por eso existen las sagas. El curso cierra con el ⚖️ veredicto honesto: cuándo no
> necesitabas nada de esto.

---

## 1. ✅ Decisiones cerradas

Ninguna de estas se reabre al escribir una fase. Si una fase necesita contradecir alguna, se
corrige **aquí primero**, con su razón escrita.

**🪦 El curso es autocontenido y no nombra ningún otro curso.** Ni como prerrequisito, ni como
profundización, ni para justificar una exclusión. Cuando un tema queda fuera, se declara la
exclusión y el texto se detiene ahí: decir dónde vive ese material es una promesa que esta carpeta
no puede cumplir.

**🪦 Nada de tratamiento *legacy*.** Todo el stack es actual y cada pieza se elige por lo que hace
hoy. No hay convivencia de generaciones de estilo, ni deuda heredada, ni arqueología de motores.
Lo que el ecosistema está retirando —y hay cosas— se nombra como lo que es y se sigue.

**🪦 El lector es un dev semi-senior o senior políglota.** Ha escrito JavaScript, PHP y Java, monta
endpoints sin pensarlo, y ha visto un `docker-compose.yml`. Lo que no tiene es la panorámica del
sistema completo ni una plataforma que pueda romper sin pagar. Se le explica infraestructura, no
programación.

**🪦 El código de negocio es andamiaje, y se genera asistido por LLM.** Es la decisión de método
que hace posible el alcance: el curso publica el **contrato** de cada servicio y el **prompt** que
lo genera, y el código resultante vive en `src/`. El lector puede regenerarlo, escribirlo a mano o
usar el que viene — y en los tres casos el curso funciona igual, porque **ninguna fase enseña a
programar el endpoint**. El detalle está en `a02`.

**🪦 El sistema se construye en oleadas horizontales, no servicio por servicio.** Tres oleadas
—esqueleto, almacén propio y el flujo que los cruza— repartidas por el arco, cada una tocando los
cuatro servicios a la vez con una capa fina. Y dentro de cada patrón nuevo, **`pricing` es el
servicio piloto** y los otros tres lo siguen. El detalle está en la §4.1, y es la decisión de
método que hace que ninguna fase de infraestructura tenga que depurar lógica de negocio.

**🪦 Cuatro servicios, cuatro runtimes, un frontend tonto.** `inventory` en Spring Boot con Java
21, `catalog` en PHP con Laravel, `replenish` en Node con TypeScript y NestJS, `pricing` en Go, y
`storefront` en React con Vite servido como estático. Cada runtime está elegido por la lección de
plataforma que compra, no por variedad — la tabla completa está en la §3.

**🪦 Un solo Postgres con una base y un usuario por servicio.** *Database-per-service* es el
principio, y el laboratorio lo implementa con la credencial en vez de con el hardware, para caber
en la memoria del lector. **La divergencia se declara en voz alta** en la fase que la estrena:
en producción esto son instancias separadas, y esto es exactamente lo que se pierde.

**🪦 El laboratorio tiene que correr en una máquina de 8 GB.** Es una restricción de diseño, no una
molestia. De ahí salen tres perfiles de despliegue —`minimo`, `lab` y `medicion`— y la
observabilidad deliberadamente flaca de la §3.

**🪦 kind es el cluster del curso.** k3d, minikube, MicroK8s y Docker Desktop se miden una vez, con
el arnés, y se archivan.

**🪦 No hay reparto horario.** Un curso donde media hora se va esperando a que un cluster levante o
a que una imagen de Java se construya no puede estimar horas con honestidad, y una cifra inventada
es peor que ninguna. Cada fase declara en su cabecera su **peso** —ligera, media o densa— y ahí se
acaba la promesa.

**🪦 TLS llega después de que el sistema funcione.** Añadir cifrado sobre algo que ya opera enseña
más que arrancar con cifrado, y permite que el laboratorio de incidentes de certificados tenga
contra qué romperse.

**🪦 El cuaderno de incidentes es un archivo propio**, con IDs globales que no se reasignan. El
lector lo consulta por síntoma, no por fase.

**🪦 Las versiones exactas se fijan en `alcance-del-proyecto.md`**, con su fecha de verificación,
antes de escribir la primera línea que las use. Ninguna se pone de memoria en este documento.

---

## 2. 🎭 El dominio y la empresa

El curso construye el sistema de inventario de una **cadena de retail**: venta → validar producto →
descontar stock → disparar reposición si el stock cae bajo el umbral. Es el flujo central, y está
elegido porque es la **transacción distribuida más honesta que cabe en un laboratorio**: cuatro
servicios, cuatro bases lógicas, y una compensación que significa algo cuando falla a la mitad.

> ⚠️ **La empresa todavía no tiene nombre ni historia.** Se decide aparte y vive en
> `00-historia-de-<empresa>.md`, en la raíz del curso, que será la fuente de verdad de todo lo
> narrativo: personajes, cifras, cronología y reglas de negocio. **Este documento fija la
> estructura; ninguna fase inventa dominio por su cuenta.**

Lo que sí está fijado desde aquí, porque es contrato técnico y no narrativa, son los **nombres de
los servicios y de las entidades**, en inglés como manda la guía de estilo:

`product` · `category` · `store` · `stockLevel` · `stockMovement` · `replenishmentOrder` · `price`

Y los cinco servicios: **`catalog`**, **`inventory`**, **`replenish`**, **`pricing`**,
**`storefront`**. Ninguna fase los renombra. El detalle de qué gana cada uno en cada fase vive en
`contrato-del-cluster.md`, que es de lectura obligatoria antes de tocar cualquier cosa bajo
`charts/` o `kind/`.

---

## 3. 🧱 El stack, y qué compra cada pieza

Ninguna pieza entra por variedad ni por completitud. Entra si enseña algo de la plataforma que las
otras no enseñan.

### 3.1 Los servicios

| Servicio | Stack | La lección de plataforma que compra |
|---|---|---|
| `inventory` | Spring Boot 3 · Java 21 | La JVM contra los `limits` del cgroup. **El `OOMKilled` es la clase magistral del curso** y solo la da Java. Además arranca lento, lo que obliga a entender `readinessProbe` de verdad |
| `catalog` | PHP · Laravel | El modelo de proceso que no encaja: PHP-FPM y nginx son **dos procesos en un pod**. Quién responde el health check, y por qué "un request, un proceso" hace que el HPA por CPU se comporte distinto a todo lo demás |
| `replenish` | Node · TypeScript · NestJS | El consumidor de eventos y el lado asíncrono de la saga. Y el *event loop* como tercer modelo de concurrencia frente a hilos y procesos |
| `pricing` | Go | El **suelo y el techo del experimento**: la imagen más pequeña y el arranque más rápido. Es el control de todas las mediciones y el sujeto de la fase de gRPC |
| `storefront` | React · Vite · nginx | Que el frontend **no es un servicio**: es un archivo que alguien sirve, y su configuración se hornea en tiempo de build |

### 3.2 Los datos y el bus

**PostgreSQL** como base del laboratorio, con una base y un usuario por servicio.
**SQLite** en tres sitios elegidos y en ninguno más: el primer despliegue sin dependencias, las
pruebas donde el SQL no es el punto, y el experimento 🧨 del stock fantasma.
**Testcontainers** para todo lo que sí toque SQL de verdad — y la decisión se mide, con el tiempo
de suite de cada opción.
**Valkey** con doble función: caché en la Parte II y el pub/sub deliberadamente frágil de la
Parte IV.
**NATS con JetStream** como bus de la coreografía en serio, que es lo que fuerza las lecciones de
idempotencia y de outbox.

### 3.3 La observabilidad, deliberadamente flaca

Sin Operator. Nada de una distribución que traiga plano de control, alertas y exportadores: es de
donde salen los gigabytes, y además esconde el `scrape_config` detrás de un recurso propio, que es
justo lo que el lector necesita ver.

| Pieza | Elección | Por qué esta |
|---|---|---|
| Métricas | Prometheus binario único, configuración a mano, retención corta | El lector escribe el `scrape_config` y entiende el modelo de *pull* |
| Dashboards | Grafana con dashboards provisionados | Efímera y sin persistencia. Los dashboards son código y se versionan |
| Logs | Loki monolítico y Fluent Bit como `DaemonSet` | Fluent Bit es el recolector más liviano que existe, y el `DaemonSet` es contenido |
| Trazas | Tempo monolítico, **apagado por defecto** | Solo se enciende en la Parte IV, donde por fin hay algo que trazar |
| Escalado | metrics-server | No es opcional: sin él no hay HPA |

### 3.4 Los tres perfiles de despliegue

No son cosmética: son parte del arnés de medición y del presupuesto de memoria.

- **`minimo`** — servicios y Postgres, observabilidad apagada, un solo nodo worker, todo a una
  réplica. Es el perfil de las Partes 0 a II.
- **`lab`** — todo encendido, dos nodos worker. Es el de las Partes III y IV.
- **`medicion`** — únicamente lo que se está midiendo, para que los números no los contamine nada
  más.

---

## 4. 🪜 El arco: cinco partes, 28 fases

| Parte | Qué hace | Fases |
|---|---|---|
| **0 · Prolegómenos** | El ambiente y el vocabulario. El sistema corriendo en compose | 00 – 02 |
| **I · El modelo y el salto** | Qué pasa debajo, y por qué compose deja de alcanzar | 03 – 06 |
| **II · El despliegue** | Lo que la plataforma te da: cluster, red, configuración, estado, Helm, escalado | 07 – 16 |
| **III · Operarlo** | Observabilidad, TLS, seguridad y diagnóstico | 17 – 21 |
| **IV · El lab de patrones** | Lo que la plataforma **no** te da: resiliencia, gRPC, sagas, outbox | 22 – 26 |
| **Cierre** | El veredicto honesto y el proyecto final | 27 |

Dos reglas de secuencia que ninguna fase puede saltarse:

> 🧭 **Primero funciona, después se entiende.** La Parte 0 pone al lector a correr contenedores
> antes de explicarle qué son. El orden inverso —teoría del kernel antes del primer `run`— pierde a
> media audiencia en la primera sesión.
>
> 🧭 **YAML plano antes que Helm, siempre.** Una herramienta de plantillas sobre un modelo que no
> entiendes es una máquina de frustración. El lector escribe los campos a mano antes de que nada
> se los genere.

### 4.1 🌊 El método de construcción: tres oleadas

El sistema **no se construye servicio por servicio**. Se construye en **oleadas horizontales**:
cada oleada toca los cuatro servicios a la vez y les añade una capa fina, en vez de terminar uno
antes de empezar el siguiente.

> 🧭 **Infra primero, dominio después.** El dominio es ruido mientras aprendes la plataforma.
> Cuando la fase trata sobre `readinessProbe`, lo último que quieres es estar depurando por qué la
> venta no descuenta stock — y al revés, cuando llega la saga quieres toda tu atención ahí y no en
> si el Ingress enruta bien.

Son tres, y cada una aterriza en la fase que la necesita, no al principio del curso:

| Oleada | Qué añade a los cuatro servicios | Dónde aterriza | Por qué ahí |
|---|---|---|---|
| **0 · Esqueleto** | Solo `/health` y un endpoint que devuelve JSON fijo. Sin base de datos, sin lógica | **Fase 02** | Es todo lo que hace falta para que compose —y después el cluster— tengan algo que levantar. Y es lo mínimo que deja ver la **forma** del sistema: cuatro procesos, una red, resolución por nombre |
| **1 · Almacén propio** | Cada servicio suma su almacén y sus operaciones básicas de lectura y escritura, **sin cruzarse entre ellos** | **Fase 09** | Es lo que hace posible el experimento 🧨 de la Fase 12: para que el stock se vuelva fantasma tiene que haber stock que escribir. Llega en SQLite, dentro del pod, y eso es deliberado |
| **2 · El flujo que los cruza** | La venta completa: validar producto, descontar stock, consultar precio y disparar reposición | **Fase 16** | Es lo que da **carga real** a la medición de escalado, y lo que la Parte III tiene que observar y la Parte IV tiene que romper. Antes de aquí, ningún servicio llama a otro por trabajo de negocio |

Entre la Fase 02 y la 16 el sistema devuelve datos poco interesantes, **y eso es correcto**: durante
diez fases lo que se está aprendiendo no tiene nada que ver con el dominio, y meterlo antes solo
habría añadido superficie donde equivocarse. El curso lo dice en voz alta en la Fase 02 en vez de
dejar al lector con la sensación de que le falta algo.

### 4.2 🧪 El servicio piloto

Dentro de cada oleada, y de cada patrón de infraestructura nuevo, **un servicio va primero y los
otros tres lo siguen**. El piloto es **`pricing`**, el más pequeño y el que arranca más rápido:
construir con él un Dockerfile, un subchart, un juego de probes o un `ServiceMonitor` cuesta
minutos en vez de esperas.

Una vez el patrón funciona en el piloto, replicarlo es casi mecánico —*"lo mismo que `pricing`,
pero en Java"*—, y ahí es donde aparece lo interesante: **las tres veces que no es mecánico**. Que
PHP necesite dos procesos, que Java tarde cinco segundos en estar listo, que Node cargue
dependencias que Go no tiene. Esas fricciones son el contenido, y solo se ven si hay un patrón
previo contra el que compararlas.

---

## 5. 📋 Las 28 fases, en detalle

Cada bloque declara: **qué construye**, **qué concepto trae**, y cuando corresponda **qué mide**
📏, **qué rompe a propósito** 🧨 y **qué difiere** a otra fase. El peso —ligera, media, densa— es
la única promesa de esfuerzo que da el curso.

### Parte 0 · Prolegómenos

Su regla es distinta a la del resto: aquí no se filtra por profundidad conceptual, sino por si el
lector puede seguir sin esto. Y **no se recrea en nada**: da el vocabulario mínimo y se detiene.
Cada tentación de profundizar tiene destino en una parte posterior, donde el tema llega con un
problema que lo justifique.

#### 🛠️ Fase 00 — El ambiente: dos escritorios y tres plataformas · *media*

**Construye:** una máquina lista. Docker Desktop y Podman Desktop instalados y conviviendo, con
una forma explícita de saber cuál está activo y de alternar entre ellos.

**Trae:** los prerrequisitos y su validación en las tres plataformas soportadas —Windows 11 con
WSL 2, macOS Apple Silicon y Linux amd64—, sin nota al pie y sin condescendencia: se dan las tres
instrucciones, en ese orden.

**🩺 Estrena el cuaderno de incidentes** con los cuatro fallos de instalación que se llevan por
delante a más gente: WSL 2 que no arranca, virtualización deshabilitada, la máquina de Podman que
no levanta, y el socket al que no tienes permiso.

**Difiere:** todo lo que sea *usar* los motores, que es la Fase 01.

> ⚠️ Es el material que más rápido envejece del curso. Lleva fecha de verificación visible y se
> revisa antes de cualquier publicación.

#### 📦 Fase 01 — Tu primer contenedor, y tu primer Dockerfile · *media*

**Construye:** la imagen de `pricing` —el servicio más pequeño— y un contenedor corriendo.

**Trae:** los tres sustantivos (imagen, contenedor, tag) y el modelo mental que los separa; los
verbos del trabajo diario (`run`, `ps`, `logs`, `exec`, `stop`, `rm`); la anatomía de un
Dockerfile de un solo *stage* con `FROM`, `WORKDIR`, `COPY`, `RUN`, `ENV`, `EXPOSE`, y **la
diferencia entre `CMD` y `ENTRYPOINT`**, que casi nadie explica bien; puertos y volúmenes desde la
línea de comandos; de dónde salen las imágenes y por qué tu descarga falló a la tercera; y la
limpieza del disco, que es el problema operativo más común de quien empieza.

**Difiere:** el multi-stage, el caché de capas y las imágenes base a la Fase 04. Las capas y OCI a
la Fase 03.

> 📝 **La nota del toolchain, y es propia de este curso.** Con las versiones actuales de los
> cuatro runtimes **ninguna imagen del laboratorio necesita un toolchain de compilación**: Node
> trae binarios precompilados, las extensiones de PHP vienen en las imágenes oficiales, Java no
> compila nada nativo y Go compila estático en su propia etapa. Eso simplifica mucho los
> Dockerfiles — y por eso la fase dice **dónde dejaría de ser verdad**: una dependencia sin
> binario para tu arquitectura, una extensión de PHP sin empaquetar, o una base con musl en vez de
> glibc. Se nombra el síntoma y se sigue.

#### 🧩 Fase 02 — Compose: el sistema entero en un archivo · *media*

**🌊 Oleada 0 — el esqueleto.** Los cuatro servicios y el `storefront` corriendo con un solo
comando, cada uno exponiendo `/health` y un endpoint que devuelve JSON fijo. **Sin base de datos y
sin lógica de negocio**, y eso es deliberado: lo que esta fase enseña es la **forma** del sistema
—cuatro procesos, una red, resolución por nombre— y el dominio solo la taparía.

**Trae:** `services`, `image` contra `build`, `ports`, `environment`, `volumes`, `depends_on`,
`networks`, y los comandos de operación. Y el contrato REST completo de los cuatro servicios
—incluidos los endpoints que todavía no existen, marcados como pendientes—, que a partir de aquí
está congelado.

**Y dice en voz alta por qué el sistema todavía no hace nada interesante**, con el calendario de
las tres oleadas delante, para que el lector no arrastre la sensación de que le falta algo.

**🦭 Estrena el marcador de divergencia** en un sitio inocuo: `docker compose` y `podman compose`
no son el mismo programa, hay más de una implementación, y conviene saberlo antes de que la
diferencia aparezca donde duele.

**Difiere:** la 🪞 de dónde se rompe el instinto de compose a la Fase 06. Aquí compose se usa y se
disfruta; la crítica llega cuando haya con qué compararla.

### Parte I · El modelo y el salto

Llega con el lector ya teniendo el sistema corriendo. Lo que no tiene todavía es el modelo mental
de qué pasa debajo. **Y aquí está la tentación más grande del curso: convertirlo en un tratado de
namespaces y cgroups. Se resiste** — este curso enseña el modelo, no el kernel.

#### 🔬 Fase 03 — El contenedor por dentro, y su ciclo de vida · *media*

**Trae:** qué es realmente un contenedor —un proceso del host con la vista recortada—, que es lo
que desactiva la analogía con la máquina virtual de la que salen la mitad de los errores de
intuición de este perfil; la imagen y sus capas, que es lo que hace comprensibles el caché, el
tamaño y por qué los datos se van; el estándar OCI y por qué construir con un motor y correr en
otro no rompe nada; **PID 1, las señales y el apagado limpio**, que son la mitad invisible de un
rollout sin cortes; y usuarios, permisos y rootless, en la medida exacta en que evitan el
`CrashLoopBackOff` más frustrante que existe.

**Difiere:** `securityContext` y el endurecimiento del pod a la Fase 20.

**🚫 Deja fuera, declarándolo:** cgroups y namespaces por dentro. Se nombra qué son y se sigue.

#### 🏗️ Fase 04 — Empaquetar los cuatro runtimes ⭐ · *densa*

**Construye:** el Dockerfile multi-stage definitivo de los cuatro servicios y del frontend.

**Trae:** el patrón multi-stage resuelto cuatro veces, y **la constatación de que el patrón es uno
y cada runtime lo paga distinto**; las imágenes base y su costo —musl contra glibc, el shell que
ya no tienes para depurar—; el caché de capas, el orden de instrucciones y el `.dockerignore`; y
el digest frente al tag, que es la causa raíz de toda una familia de *"pero si yo desplegué el
arreglo"*.

**📏 La primera medición del curso, y la que fija el arnés:** tamaño final, build en frío, build
con caché y tiempo hasta el primer request atendido, para los cuatro runtimes. Es la tabla que el
lector va a recordar tres años después, y es la que hace defendible todo lo demás.

#### 🦭 Fase 05 — Los dos motores, sin guerra · *ligera*

**Trae:** que el mismo cluster corre sobre cualquiera de los dos y que las imágenes viajan entre
ellos porque OCI es un estándar; y **dónde divergen de verdad** — el demonio frente al modelo sin
demonio, rootless por defecto, el puerto 80 que Podman no te deja publicar sin más, y la máquina
virtual frente al WSL en cada plataforma.

**📏 Mide:** tiempo de creación del cluster, tiempo de build y memoria del host en reposo, en los
dos motores. La medición se publica; **ejecutarla es opcional para el lector**, que puede no tener
los dos instalados.

**🔥 Deja como opcional:** generar manifiestos desde contenedores corriendo. Es un puente
conceptual bonito y produce YAML que nadie desplegaría tal cual.

#### 🪜 Fase 06 — Del compose al cluster · *densa*

Es la bisagra del curso y donde vive su sección insignia.

**Trae:** 🪞 **dónde se rompe el instinto de compose** — `depends_on` no espera a que el servicio
esté listo, `restart: always` no es un `Deployment`, la red de compose resuelve por nombre pero no
es DNS de cluster, `scale` te da réplicas que nadie balancea de verdad, y tus volúmenes son del
host y punto. 📖 **El diccionario compose ⇄ Kubernetes en las dos direcciones**, para que el lector
pueda traducir cualquier archivo que tenga hoy en su trabajo. Y **qué no tiene traducción**:
`Namespace`, `ServiceAccount`, RBAC, el planificador, el bucle de reconciliación.

**Y el concepto del que cuelga todo lo demás:** el modelo declarativo y el bucle de reconciliación
— le dices al cluster qué quieres, no qué haga, y algo trabaja sin parar para que la realidad se
parezca. Sin esto, Kubernetes es una API rara; con esto, casi todo se deduce.

**🚫 Deja fuera, declarándolo:** compose como herramienta de producción. No lo es, y decirlo es
parte del contenido.

### Parte II · El despliegue

Es la mitad *"esto es lo que la plataforma te da"*, y es a lo que el lector vino.

#### ☸️ Fase 07 — El cluster local · *media*

**Construye:** el cluster de kind desde su archivo de configuración, con un nodo de control y los
workers, y los `extraPortMappings` que hacen que el Ingress se vea desde el host.

**Trae:** la topología y qué corre en cada nodo; `kubectl`, contextos y la higiene de no
equivocarse de cluster; y por qué `localhost` llega o no llega a tu pod, que es la primera
frustración universal.

**📏 Mide:** kind, k3d, minikube y MicroK8s — tiempo de arranque, memoria en reposo y si dan
multi-nodo. Y después se archivan: **kind es el cluster del curso.**

#### 🚀 Fase 08 — El primer despliegue, en YAML plano ⭐ · *densa*

**Construye:** `pricing` desplegado a mano, con su `Deployment` y su `Service`, sin ninguna
herramienta que genere nada.

**Trae:** la escalera Pod → ReplicaSet → Deployment y por qué casi nunca escribes un Pod; el
`Service` de tipo ClusterIP y el DNS interno, que es la respuesta a *"¿cómo se llaman entre sí mis
servicios?"*; y el primer contacto con `describe`, `logs` y `events`.

**🩺 Primeros incidentes de plataforma:** la imagen que nunca se cargó al cluster, y el `Service`
sin endpoints porque el selector no coincide con las labels.

#### 🧱 Fase 09 — Los cuatro servicios dentro · *media*

**Construye:** los cuatro servicios y el `storefront` desplegados en el cluster, siguiendo el
patrón que `pricing` estrenó en la Fase 08.

**🌊 Oleada 1 — el almacén propio.** Cada servicio suma su almacén y sus operaciones básicas de
lectura y escritura, **sin llamarse entre ellos todavía**: `catalog` sirve productos de verdad,
`inventory` registra movimientos y devuelve existencias, `replenish` crea y lista órdenes,
`pricing` resuelve precios. Todo en **SQLite, dentro del pod**, y eso es una deuda 💸 declarada con
fecha de cobro: la Fase 12.

**Trae:** `Namespace` como frontera, labels y selectores como el mecanismo que lo une todo, el DNS
interno entre namespaces, y el primer `ConfigMap` con las URLs de los vecinos —que todavía nadie
usa, y por eso es un buen sitio para introducirlo sin ruido.

**🚫 Deja fuera:** la persistencia real y el flujo que cruza servicios. Los dos con su fase de
destino escrita.

#### 🌐 Fase 10 — La entrada al sistema · *media*

**Construye:** el Ingress con dominio local, y el `storefront` accesible desde el navegador del
host.

**Trae:** los tipos de `Service` y **por qué `LoadBalancer` se queda en `Pending` para siempre en
local**, que es el primer 🚧 *"hasta aquí llega el laboratorio"* del curso; el `Ingress` y su
controlador, y el concepto de que un objeto no hace nada sin alguien que lo implemente; el dominio
local y por qué tu navegador llega y tu `curl` no.

**Sección corta sobre Gateway API:** se nombra, se muestra la diferencia, y se sigue con Ingress —
que es lo que el lector va a encontrar en la mayoría de clusters.

#### ⚙️ Fase 11 — Configuración y secretos ⭐ · *media*

**Trae:** `ConfigMap` y variables de entorno, con la lección de que cambiar un ConfigMap no
reinicia nada; `Secret` y la verdad incómoda de que base64 no es cifrado; y **la pieza central de
la fase: la configuración horneada en build frente a la inyectada en arranque.**

El `storefront` es el caso perfecto y se demuestra con dos despliegues de la misma imagen: su
`API_URL` se fija al compilar, y el contenedor espera inyectarla al arrancar. Ese desajuste es la
causa raíz de la mitad de los *"funciona en QA y no en producción"* de cualquier aplicación de
página única.

**🚫 Deja fuera, declarándolo:** los gestores de secretos externos. Exigen infraestructura que el
laboratorio no tiene y no cambian ninguna decisión local.

#### 💾 Fase 12 — Estado, almacenamiento y datos iniciales · *densa*

**🧨 Abre rompiendo, y es la mejor puerta de entrada del curso.** Desde la Oleada 1 de la Fase 09
los servicios llevan tres fases escribiendo en SQLite dentro del pod, impecable. Le subes las
réplicas a dos. Las dos responden, ninguna falla, ningún log se queja — **y el stock aparece y
desaparece según qué réplica conteste.** Nadie olvida un bug que no produce ningún error.

Ahí se cobra la deuda 💸 que la Fase 09 dejó declarada.

**Construye:** Postgres en el cluster como `StatefulSet`, con su PVC y su `Service` headless, y los
cuatro servicios apuntando a su propia base con su propia credencial.

**Trae:** volúmenes, `PersistentVolume`, `PersistentVolumeClaim` y `StorageClass`, todos motivados
por el fallo de arriba; identidad estable y arranque ordenado; `Job` y `CronJob` para el seed y las
migraciones; y **el orden de la migración contra el rollout**, con la pregunta que nadie se hace a
tiempo: qué pasa si dos réplicas migran a la vez.

**⚖️ Y un veredicto honesto:** vas a poner Postgres en el cluster en este laboratorio, y
probablemente no deberías hacerlo en producción. Aquí está por qué.

**Declara la divergencia:** un servidor con una base por servicio en vez de instancias separadas,
y qué se pierde con eso.

#### 📦 Fase 13 — Helm: el paquete · *densa*

**Abre con el dolor:** cuatro servicios por tres perfiles son doce archivos casi idénticos. La
herramienta llega después de que el lector haya sentido eso, no antes.

**Construye:** el umbrella chart con un subchart por servicio, y los tres perfiles de valores.

**Trae:** chart, plantillas, valores y qué es realmente un release; la disciplina de qué va en el
chart base y qué en el override; y los *hooks* para el seed y las migraciones que la fase anterior
dejó como Jobs sueltos.

#### 🔧 Fase 14 — Helm en operación · *media*

**Trae:** `upgrade`, `rollback`, `--dry-run` y el *diff* previo — la red de seguridad que hace que
el lector se atreva a tocar; y los tres perfiles de la §3.4 en uso real, incluido el de medición.

**Sección corta sobre Kustomize:** que hay dos escuelas —plantillas contra parches— y en qué se
diferencian.

**🔥 Deja como apéndice:** GitOps. Es el destino natural de todo esto y merece nombrarse con
honestidad, pero montarlo exige un repositorio, un flujo y un plano de control que duplican el
alcance.

#### 🩺 Fase 15 — Salud y recursos ⭐ · *densa*

**Trae:** las tres *probes* y, sobre todo, **la diferencia entre liveness y readiness**, que casi
nadie tiene clara: una readiness mal puesta corta tráfico en cada despliegue, y una liveness mal
puesta reinicia pods sanos en bucle. Los dos fallos son comunes y los dos son invisibles.

Y la observación que solo un curso políglota puede hacer: **el mismo campo del YAML significa cosas
distintas según lo que corre debajo.** Spring Boot tarda segundos, Go milisegundos, y PHP-FPM está
"listo" antes de poder atender de verdad.

Después, `requests` y `limits`: qué le prometes al planificador y qué te impone el cgroup.

**⚰️ La autopsia central del curso: el `OOMKilled` de la JVM.** El heap que no sabe que está en un
contenedor, el pod que muere sin escribir ni un error, y el arreglo. Con números antes y después.

#### 📈 Fase 16 — Escalado y rollout · *densa*

**🌊 Oleada 2 — el flujo que los cruza.** Abre cerrando el dominio: la venta completa, con
`inventory` validando el producto contra `catalog`, consultando a `pricing`, descontando
existencias y disparando una reposición en `replenish` cuando el stock cae bajo el umbral. **Es la
primera vez en todo el curso que un servicio llama a otro por trabajo de negocio**, y llega aquí
porque es lo que da carga real a la medición de esta fase, material que observar a la Parte III y
algo que romper a la Parte IV.

El aviso a `replenish` se hace **sin esperar respuesta, registrando el resultado en el log**: la
venta no puede fallar porque el servicio de reposición esté caído. Es una decisión deliberada y
deja sembrada la pregunta que la Fase 25 responde — *¿y si esa llamada se pierde?*

**Trae:** escalado manual y HPA, con su decepción honesta incluida — el HPA reacciona tarde, mide
una sola métrica, y con PHP-FPM se comporta distinto que con Node; las estrategias de rollout,
`maxSurge` y `maxUnavailable`; y **el apagado limpio**, con `terminationGracePeriodSeconds` y el
`preStop` que le da tiempo al balanceador a enterarse. Ahí se cobra lo que la Fase 03 sembró sobre
`SIGTERM`.

**📏 Mide:** con carga generada, cuántas réplicas de cada runtime sostienen la misma tasa de
peticiones, y cuánta memoria cuesta cada una. Es la tabla que cierra la tesis de la Parte II.

**🚧 Frontera declarada:** `PodDisruptionBudget`, autoescalado de nodos y multi-zona se nombran
como lo que existe del otro lado y no se puede reproducir gratis.

### Parte III · Operarlo

Aquí el sistema deja de ser un diagrama y se vuelve algo que se rompe.

#### 📊 Fase 17 — Métricas y dashboards · *densa*

**Construye:** Prometheus con su `scrape_config` escrito a mano, Grafana con dashboards
provisionados como código, y los cuatro servicios exponiendo `/metrics`.

**Trae:** los tres pilares y cuándo sirve cada uno —métricas para saber que algo va mal, logs para
saber qué, trazas para saber dónde—, que es el criterio que separa diagnosticar de adivinar; el
modelo de *pull*; y la instrumentación de los cuatro runtimes, comprimida, porque es el mismo
concepto cuatro veces.

**Y una tesis del curso, dicha aquí:** exponer métricas es responsabilidad de la aplicación, no
regalo de la plataforma. Lo que el cluster te da gratis no te dice nada de tu negocio.

**🚫 Deja fuera, declarándolo:** las alertas y una cadena de guardia. Sin destinatario, una alerta
es un ejercicio vacío.

#### 🔎 Fase 18 — Logs · *media*

**Construye:** los cuatro servicios logueando JSON estructurado a stdout, Fluent Bit como
`DaemonSet` y Loki recibiéndolo todo.

**Trae:** la regla operativa —a stdout, nunca a archivo— y la fricción real de conseguirla en Java
y en PHP, que por defecto loguean texto plano; el `DaemonSet` como el objeto que explica cómo
funciona un recolector; y LogQL para buscar una venta a través de cuatro servicios.

#### 🔐 Fase 19 — TLS y certificados ⭐ · *densa*

**Construye:** una CA propia, el certificado del Ingress firmado con su SAN correcto, montado como
`Secret` TLS, y la confianza instalada en el host. Después, cert-manager con un emisor propio que
lo renueva solo.

**Trae:** la cadena de confianza entendida de una vez, que es lo que casi nadie tiene claro del
todo; y el patrón de emisión automática que el lector va a encontrar en cualquier cluster real.

**🧨 Y abre el laboratorio de incidentes de certificados**, que es el mejor activo individual del
curso: certificado expirado, CA desconocida, SAN incorrecto, clave y certificado desparejados,
cert-manager que no emite, y mTLS sin certificado de cliente. Cada uno con su síntoma, su
evidencia, su causa y su primer comando.

**Incluye** mTLS entre servicios en su versión a mano. La versión con mesh es apéndice.

#### 🛡️ Fase 20 — Seguridad del pod y de la red · *media*

**Trae:** `securityContext`, `runAsNonRoot` y las capacidades, que cobran lo que la Fase 03 sembró
sobre permisos; RBAC en versión mínima y provocada por un fallo real —por qué tu pod no puede leer
un Secret—; y `NetworkPolicy`.

**🧨 Con el experimento que lo justifica:** por defecto, en un cluster, **todo el mundo puede
hablar con todo el mundo**. Se demuestra exponiendo la base de datos por accidente, y se arregla en
dos minutos. Es la lección de seguridad más transferible del curso.

**🔥 Deja como apéndice:** el service mesh. Es la respuesta real a media Parte IV y verlo funcionar
cambia el criterio, pero cuesta memoria, un plano de control entero y complejidad conceptual
encima de un lector que acaba de conocer los `Service`.

#### 🩻 Fase 21 — Diagnóstico: el kit y el cuaderno · *densa*

**Trae:** el kit completo de trabajo —`describe`, `logs --previous`, `events`, `exec`,
`port-forward`, contenedores efímeros de depuración y k9s—, cada herramienta estrenada en el
incidente que la necesita y nunca en una lista.

**Y abre formalmente el cuaderno de incidentes de plataforma**, que a esta altura ya tiene entradas
de fases anteriores. Aquí se enseña **el método**: síntoma, evidencia, hipótesis, primer comando,
causa, corrección, prevención. El reflejo de los primeros treinta segundos es donde se gana o se
pierde una guardia.

> 🧭 Esta fase es la que convierte al lector de alguien que despliega en alguien que **diagnostica**,
> que es la diferencia entre haber hecho un tutorial y saber operar.

### Parte IV · El lab de patrones distribuidos

Es donde el curso demuestra su tesis: **nada de esto lo resuelve Kubernetes.**

#### 🔥 Fase 22 — Resiliencia, y el generador de caos · *media*

**Construye:** el generador de caos del curso —código propio, no una herramienta externa— que
inyecta latencia, errores intermitentes y respuestas malformadas entre servicios.

**Trae:** el fallo en cascada, el timeout que no pusiste, el reintento que empeora las cosas; y
timeouts, backoff y circuit breaker como respuestas. **Con la pregunta que ordena la parte
entera:** ¿esto va en tu código o en la plataforma? Es la tesis del curso aplicada a una decisión
cotidiana.

#### 🔌 Fase 23 — gRPC, y el balanceo que no balancea ⭐ · *densa*

**Construye:** la llamada entre `inventory` y `pricing` migrada a gRPC, con su contrato en
Protobuf. Y **enciende Tempo**: aquí por fin hay algo que trazar.

**Trae:** contratos binarios y HTTP/2, y el fallo que hace que esta fase exista: **el balanceo de un
`Service` funciona por conexión, y gRPC mantiene la conexión abierta — así que todo tu tráfico se
va a una sola réplica.** Es sutil, es medible, y es específico de la combinación. Exactamente el
tipo de cosa que este curso existe para enseñar.

**Trae también** las trazas distribuidas y el `trace-id` propagado, que es lo único que responde
*"¿por qué esta venta tardó ocho segundos?"* cuando pasó por cuatro servicios.

#### 🎬 Fase 24 — La saga orquestada · *densa*

**Construye:** el flujo de venta como saga coordinada por `inventory`, con sus compensaciones
escritas a mano.

**Trae:** que no hay transacción distribuida gratis, y que **"deshacer" es una operación de
negocio, no técnica**. Se provoca el fallo a mitad de saga con el generador de caos de la Fase 22 y
se observa el sistema a medio compensar.

#### 📡 Fase 25 — La coreografía, y los mensajes que se pierden · *densa*

**🧨 Abre rompiendo, otra vez a propósito.** Se monta la coreografía sobre el pub/sub de Valkey.
Funciona. Se reinicia un consumidor durante una venta, y el mensaje **no existió nunca**. La
motivación de todo lo que sigue se siente en vez de explicarse.

**Construye:** la misma coreografía sobre NATS con JetStream, con entrega *al menos una vez*.

**Trae:** el desacoplamiento por eventos; el contraste directo con la saga orquestada y el ⚖️
veredicto de cuándo conviene cada una, que es lo que nadie te dice; y la factura inmediata del
arreglo: **si entrego al menos una vez, entrego dos veces.**

#### 🔁 Fase 26 — Idempotencia y outbox ⭐ · *densa*

**Trae:** claves de idempotencia y operaciones que se pueden repetir sin daño, que es la
consecuencia directa de la fase anterior; y **el patrón outbox** — escribir el evento en la misma
transacción que el dato, con un proceso aparte que lo publica. Resuelve la escritura dual, que es
el bug distribuido más común y el peor diagnosticado.

**🚫 Deja fuera, declarándolo:** event sourcing y CQRS. Son patrones de arquitectura de datos, no
de infraestructura, y se comen un curso entero.

### Cierre

#### ⚖️ Fase 27 — El veredicto honesto, y el proyecto final · *densa*

**El veredicto:** cuándo **no** necesitabas nada de esto. Un árbol de decisión honesto que empieza
por la pregunta que el curso lleva veintisiete fases ganándose el derecho a hacer: ¿esto lo
resolvía un contenedor y un servicio del sistema? ¿Lo resolvía compose en una máquina? ¿De verdad
necesitas un orquestador, o necesitas dos servidores y una lista de comprobación?

**🌩️ Y el diccionario local ⇄ nube consolidado**, en las dos direcciones, con la 🚧 frontera de lo
que el laboratorio nunca pudo darte: un plano de control gestionado y su disponibilidad, un
balanceador de verdad, multi-zona, autoescalado de nodos, identidad de carga de trabajo, y el coste
como restricción de diseño.

**El proyecto final:** desplegar un servicio nuevo de cero —su imagen, su subchart, sus probes, sus
límites, sus métricas, su entrada en el Ingress y su papel en la saga— sin que ninguna fase lo
explique. Es el mejor criterio de éxito que el curso puede darse.

---

## 6. 🎨 Apéndices

No cuentan como camino base y no llevan peso declarado. Formato de consulta rápida: índice de
salto, secciones cortas, una guía final de "cuándo usar qué" y entre cinco y diez ejercicios
breves.

| Apéndice | Qué es |
|---|---|
| `a01` | Solución de problemas del ambiente, por plataforma. La cola larga de la Fase 00 |
| `a02` | **Los prompts de generación de los servicios.** El contrato de cada uno y el prompt que lo produce. Es la pieza que sostiene la decisión de método de la §1 |
| `a03` | Referencia rápida de `kubectl` y de k9s |
| `a04` | 🔥 Arquitecturas y builds multiplataforma: ARM contra amd64, y la imagen que corre lentísima bajo emulación |
| `a05` | 🔥 Construir imágenes sin Docker: Buildah, Kaniko, y los constructores por lenguaje |
| `a06` | 🔥 MongoDB y el `StatefulSet` de varios miembros: arranque ordenado y failover |
| `a07` | 🔥 Qué cambia cuando el frontend necesita un runtime: renderizado en servidor |
| `a08` | 🔥 Service mesh: mTLS automático, reintentos y métricas de red sin tocar el código |
| `a09` | 🔥 GitOps, de lectura: qué resuelve, qué cuesta, y por qué no está en el camino base |
| `a10` | 🔥 Operators y recursos propios, de lectura. El lector los va a encontrar en cualquier cluster real |
| `a11` | 🔥 Respaldo y restauración de los datos del cluster |
| `a12` | 🔥 Las GUI del cluster: cuándo ayudan y cuándo estorban |
| `a13` | 🌩️ El diccionario local ⇄ nube, consolidado y en las dos direcciones |

---

## 7. 📓 El cuaderno de incidentes

Un único archivo, `cuaderno-incidentes.md`, con **24 incidentes** de IDs globales que no se
reasignan. Cada uno lleva: índice por síntoma, enunciado, evidencia observable, pistas graduadas,
solución, y espacio para la bitácora del lector.

Y cada uno traduce a git con el par de tags `inc/<ID>/<slug>-roto` e `inc/<ID>/<slug>-fix`, de
modo que el `git diff` entre los dos **es** la corrección aislada del ruido de la fase.

| Familia | Cuántos | De dónde salen |
|---|---|---|
| 🩺 Ambiente | 4 | Fase 00 |
| ☸️ Plataforma | 14 | Fases 08 a 21 |
| 🔐 Certificados | 6 | Fase 19 |

El catálogo de plataforma, que es el grueso: imagen que nunca se cargó al cluster · tag inexistente ·
`CrashLoopBackOff` por permisos · por variable ausente · por puerto ocupado · `OOMKilled` de la JVM ·
`Pending` por recursos · `Pending` por PVC sin enlazar · readiness que nunca pasa a verde ·
liveness demasiado agresiva · DNS que no resuelve por namespace equivocado · `Service` sin
endpoints · Ingress con 404 por ruta · ConfigMap cambiado que no reinicia nada.

> 🧭 **El formato es el mismo siempre:** qué provocar, qué síntoma esperar, **qué mirar en los
> primeros treinta segundos**, cuál es la causa, cómo se arregla, y cómo se previene. El tercer
> punto es el que hace útil al cuaderno; sin él es una lista de errores.

---

## 8. 📏 Las mediciones del curso

Seis, todas con el mismo arnés, todas consolidadas en `BENCHMARKS.md` con la declaración del
entorno de referencia.

| Fase | Hipótesis, en una línea |
|---|---|
| 04 | El costo de empaquetar cada runtime: tamaño, build en frío, build con caché, arranque |
| 05 | Los dos motores: creación del cluster, build y memoria del host en reposo |
| 07 | Los cuatro clusters locales: arranque, memoria en reposo, multi-nodo |
| 12 | Pruebas contra SQLite frente a pruebas contra el motor real: tiempo de suite y fidelidad |
| 16 | Réplicas necesarias por runtime para sostener la misma tasa, y memoria por réplica |
| 23 | Distribución del tráfico gRPC entre réplicas, antes y después del arreglo |

Y las reglas de honestidad, que son las que hacen que el curso sobreviva a un lector escéptico:
se publica lo que salió y no lo que esperabas · **el empate se llama empate** · nada de números
redondos sin dispersión · el competidor se configura bien · se declara lo que no se midió · y
nunca se extrapola.

---

## 9. 📁 Convención de nombres y de git

**Fases:** `NN-tema.md`, de `00-` a `27-`, minúsculas con guiones y dos dígitos.
**Apéndices:** `aNN-tema.md`, de `a01-` a `a13-`.
**Documentos de raíz:** `0-ESTRUCTURA-CURSO.md`, `00-convencion-de-git-y-tags.md`,
`00-historia-de-<empresa>.md`, `README.md`, `BENCHMARKS.md`, `INSTINTOS.md`,
`cuaderno-incidentes.md`.
**Código:** un único directorio de proyecto bajo `src/`, porque el curso construye **un solo
artefacto** que crece fase a fase, y no una carpeta por capítulo.

**Tags:** `fase-NN` anotado, con el checklist de cierre en el mensaje. **Commits:** `fase NN: …`, y
los de ejercicio `fase NN ejMM: …`. **Incidentes:** el par `inc/<ID>/<slug>-roto` e
`inc/<ID>/<slug>-fix`, con el ID que el cuaderno ya tiene reservado y nunca uno inventado.

Los apéndices **no llevan tag propio**, porque el código que explican lo escriben las fases. Solo
se etiquetan (`apendice-aNN`) si dejan archivos versionados.

---

## 10. 🚫 Lo que queda fuera del alcance

Reunido aquí para que cada exclusión sea visible y no se pierda entre las fases. Se declara y el
texto se detiene: **no se dice dónde estaría ese material.**

cgroups y namespaces por dentro · SBOM, firma de imágenes y cadena de suministro · gestores de
secretos externos · alertas y cadena de guardia · event sourcing y CQRS · desplegar en una nube de
pago · escribir un Operator propio · un segundo motor relacional · Kafka · compose como herramienta
de producción · profundidad de negocio en el dominio de inventario, que se mantiene mínimo a
propósito.

Si algo interesante aparece fuera de alcance mientras se escribe, se registra como **pendiente 📌**
con su destino sugerido. No se infla la fase actual.

---

## 11. 🚦 Lo que sigue, y lo que queda abierto

**Lo que sigue, en este orden:**

1. La **historia de la empresa** —`00-historia-de-<empresa>.md`—, que desbloquea todo lo narrativo
   y sin la cual ninguna fase se puede escribir sin inventar dominio.
2. `alcance-del-proyecto.md`, con las versiones fijadas y su fecha de verificación.
3. `guia-de-estilo-y-convenciones.md` y `plantillas-de-capitulo.md`.
4. `contrato-del-cluster.md`, obligatorio antes de cualquier fase de la Parte II en adelante.
5. Los formatos de medición y de cuaderno, y después los prompts de fase.

**Lo que queda abierto, y no bloquea:**

- **El nombre y la historia de la empresa**, con las dos o tres candidatas de retail que se
  evalúan aparte. El criterio que tienen que aguantar: una **transacción distribuida con
  consecuencia real**, no solo movimientos de stock, porque la Parte IV se apoya entera en eso.
- **Las versiones exactas** de los cuatro runtimes, de kind, de Helm y del stack de
  observabilidad. Se fijan con su fecha de verificación y no se ponen de memoria.
- **El orden de escritura** de las fases, que no tiene por qué ser el numérico. Las candidatas a
  escribirse primero son la 04 y la 12: la primera fija el arnés de medición del que dependen
  otras cinco, y la segunda es la que más puede obligar a reescribir la Parte II si su experimento
  no sale como se espera.
