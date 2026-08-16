# 🐹 Nichos de Go y 50 ideas de proyecto con potencial de producto

> **Qué es esto:** material de exploración para alimentar proyectos prácticos —de curso, de
> portafolio o de MVP— alrededor de Go. No es una propuesta de curso aprobada ni un plan de
> negocio: es un inventario de nichos y de ideas, con las apreciaciones de mercado marcadas
> como tales.
> **Fecha:** 12 de septiembre de 2026
> **Contexto:** ya existe `cursos-algoritmos-lenguajes/go-for-java-devs/` (18 fases, cuatro
> servicios de backend, 46 mini proyectos). Este documento **no** duplica ese temario: mira
> hacia afuera, a qué se puede construir con Go que además tenga a quién venderse.
> **Estado:** borrador de discusión. Ninguna cifra de mercado de aquí está verificada, y
> ningún "Go gana" de aquí pasó por un benchmark propio.

Una idea ordena el documento entero y conviene ponerla primero:

> 🧠 **Go no ganó por ser el mejor lenguaje: ganó por ser el más barato de operar.** Un
> binario estático, sin runtime que instalar, con arranque en milisegundos, unas decenas de
> megas de RSS y concurrencia legible por cualquiera del equipo. Cada nicho donde Go domina es
> un nicho donde *esas cuatro propiedades* son el requisito principal. Todo lo que sigue es
> consecuencia de eso.

---

## 1. 🧭 El criterio de selección

Las 50 ideas de la segunda mitad no se eligieron por "suena divertido". Cada una cumple —o
debería cumplir, y donde no lo hace se dice— cuatro condiciones:

- **Vive en un nicho natural de Go.** Si el proyecto se escribiría igual de bien en Python o
  en Java, no enseña Go: enseña el dominio. El proyecto tiene que exprimir goroutines,
  `context`, binario único, o la frontera con el sistema operativo.
- **Tiene un MVP que cabe en un fin de semana largo.** No la versión completa: la versión
  mínima que ya le sirve a alguien. Si la primera versión útil son tres meses, es un producto,
  no un proyecto de aprendizaje.
- **Hay un usuario identificable y un dolor concreto.** "Equipos de plataforma con más de 20
  clústeres" es un usuario. "Desarrolladores" no lo es.
- **Se puede medir.** Latencia, RSS, throughput, tiempo de arranque, costo mensual de la
  instancia. Sin número, el proyecto no puede defender por qué está escrito en Go.

> 🧭 **La regla que mantiene honesto el ejercicio:** cada idea tiene que poder responder "¿por
> qué esto en Go y no en el lenguaje que ya sé?" con una frase que contenga una unidad de
> medida. Si la respuesta es "porque quería aprender Go", el proyecto está bien como ejercicio
> pero no como producto — y conviene decirlo en voz alta antes de empezar.

---

## 2. 📊 Dónde se usa Go de verdad

Ranking por volumen de empleo y por estabilidad del nicho, no por entusiasmo de la comunidad.
**Apreciación de mercado sin verificar**: contrastar con ofertas reales antes de escribir
cualquiera de esto en un README publicado.

### 2.1 Infraestructura cloud y plano de control — la casa de Go

Docker, Kubernetes, Terraform, etcd, Consul, Vault, Nomad, Containerd, Helm, ArgoCD, Crossplane.
El nicho es tan dominante que resulta casi circular: Kubernetes está escrito en Go, así que
todo lo que extiende Kubernetes se escribe en Go, porque las bibliotecas cliente son de Go.

Aquí Go no compite con Java ni con Python: **compite consigo mismo**. Es el nicho con más
plazas, más estable, y el más aburrido en el buen sentido — la tecnología ya no se mueve, lo
que se mueve es el problema de negocio encima.

### 2.2 Redes, proxies y el borde

Traefik, Caddy, Cloudflare (parte), Tailscale, gVisor, CoreDNS, MinIO, SeaweedFS. Software que
está en la ruta de cada paquete, donde el modelo de concurrencia de Go —una goroutine por
conexión, que en cualquier otro lenguaje sería una locura— es exactamente lo que se necesita.

Didácticamente es el mejor nicho del idioma: obliga a entender `io.Reader`/`io.Writer`,
cancelación con `context`, *backpressure* y fugas de goroutines, que son los cuatro sitios
donde la intuición de alguien que viene de un framework con *thread pool* necesita recalibrarse.

### 2.3 Observabilidad

Prometheus, Grafana (backend), Loki, Tempo, Jaeger, InfluxDB (v2/v3 IOx es Rust, el resto
histórico es Go), Telegraf, Vector (ese es Rust), el *collector* de OpenTelemetry. El nicho
crece con el gasto en cloud: cuanto más cara es la factura, más presupuesto tiene la
herramienta que la explica.

El agente de observabilidad es el arquetipo perfecto de Go: corre en **cada** nodo, así que
30 MB de RSS contra 300 MB es una diferencia que se multiplica por toda la flota y se ve en la
factura.

### 2.4 CLIs y herramientas de desarrollo

`gh`, `hugo`, `lazygit`, `k9s`, `cobra`, `charmbracelet` (Bubble Tea, Lip Gloss), `air`,
`golangci-lint`, `mkcert`, `dive`. Menos plazas en absoluto —muchas son herramientas de una
sola persona— pero es **el nicho más imitable y con la distribución más barata**: un binario
por plataforma, `go install`, y ya está.

Si el objetivo es lanzar algo y tener usuarios esta semana, se construye aquí. La razón es
prosaica y decisiva: el usuario no tiene que instalar un runtime para probarlo.

### 2.5 Backend de APIs y SaaS

El nicho más grande en número de ofertas, aunque el menos distintivo. Uber, Twitch, Monzo,
Dropbox, Cloudflare, Shopify, prácticamente cualquier startup fundada después de 2015 que
necesitara servicios con alta concurrencia y despliegue barato en contenedor.

Aquí Go **sí compite con Java y con Node**, y gana por consumo y tiempo de arranque más que
por productividad: un servicio típico arranca en decenas de milisegundos con ~20 MB, contra
segundos y cientos de megas de una JVM con Spring. La contrapartida honesta es que en
productividad pura de CRUD, Spring Boot y Rails siguen ganando.

### 2.6 Datos, colas y pipelines

Kafka Connect alternativo, NATS, Benthos/Redpanda Connect, Temporal, ClickHouse (C++ pero con
tooling Go alrededor), `dbmate`, `goose`, Airbyte (parte). El *streaming* de eventos es, por
temperamento, un problema de concurrencia y de E/S — el terreno de Go.

### 2.7 Seguridad y DevSecOps

Trivy, Falco (parte), Grype/Syft, `gitleaks`, `nuclei` (ProjectDiscovery entero), Cosign,
OPA/Gatekeeper, Teleport, Boundary, `osquery` (C++ con envoltura). Nicho en crecimiento
sostenido por regulación —SBOM, cadena de suministro, cumplimiento— más que por moda técnica.

Es además un nicho con presupuesto: el comprador es el CISO, no el equipo de desarrollo.

### 2.8 Blockchain, fintech e infraestructura de pagos

Geth (Ethereum), Cosmos SDK, Hyperledger Fabric, Chainlink, buena parte de los *exchanges*.
Salarios altos, volatilidad alta, y una barrera de dominio empinada. **Es el nicho más fácil
de mal calibrar**: mucha oferta visible, mucha de ella efímera.

### 2.9 Agentes, sidecars, IoT y borde

Agentes de respaldo, agentes de configuración, sidecars de malla de servicios (Linkerd2-proxy
es Rust; el plano de control es Go), pasarelas IoT, k3s, EdgeX Foundry. La compilación cruzada
de Go —`GOOS=linux GOARCH=arm64` y sale un binario— es una ventaja tan grande sobre empaquetar
un runtime para ARM que casi cierra la discusión sola.

### 2.10 Dónde Go *no* es la respuesta

Por honestidad, y porque afecta a qué ideas tienen sentido:

| Terreno | Por qué Go pierde | Qué gana ahí |
|---|---|---|
| Ciencia de datos y ML | No hay ecosistema numérico ni notebooks | Python |
| Front-end y aplicaciones de escritorio con GUI | WASM es viable pero marginal; no hay toolkit de primera | TypeScript, Swift, Kotlin |
| Cómputo con latencia de cola dura (sub-ms p99) | El GC, aunque tenga pausas cortas, existe | Rust, C++ |
| CRUD de empresa con mucho dominio | Sin genéricos maduros en ORM ni inyección de dependencias | Java/Spring, C# |
| Cálculo numérico pesado | Sin SIMD idiomático ni bibliotecas BLAS de primera | Rust, C++, Fortran |

> ⚠️ **Trampa recurrente:** elegir un proyecto de este cuadro "para demostrar que se puede en
> Go". Se puede, casi siempre, y el resultado es un portafolio que demuestra terquedad en vez
> de criterio.

---

## 3. 🧪 Las 50 ideas

Cada idea trae: **qué es**, **el MVP** (la primera versión que ya le sirve a alguien), **qué
enseña de Go**, y **la señal de mercado** — quién pagaría y qué existe ya. Dificultad:
🟢 fin de semana · 🟡 una o dos semanas · 🟠 un mes · 🔴 varios meses o requiere dominio previo.

📝 Donde una idea compite con una herramienta establecida se dice explícitamente. Competir no
es descalificador —casi todo lo que existe compite con algo— pero el proyecto tiene que saber
en qué se diferencia antes de la primera línea de código.

### 3.1 ☸️ Infraestructura y plano de control (1–7)

**1. Operador de Kubernetes para respaldos con verificación de restauración** 🟠
Un CRD `BackupPolicy` que no solo respalda un `PersistentVolumeClaim`, sino que periódicamente
*restaura* el respaldo en un espacio de nombres efímero y verifica que la aplicación arranca.
**MVP:** operador con un solo CRD, respaldo a S3, restauración de prueba semanal, evento de
Kubernetes con el resultado. **Enseña:** `controller-runtime`, el bucle de reconciliación,
*finalizers*, clientes con reintento. **Mercado:** todo el mundo respalda, casi nadie prueba la
restauración; Velero respalda pero la verificación es manual.

**2. Calculadora de costos por espacio de nombres con reglas de asignación** 🟡
Lee métricas de uso (CPU, memoria, almacenamiento, egreso) y las cruza con la lista de precios
del proveedor para producir una factura por equipo. **MVP:** un binario que consulta Prometheus,
aplica un YAML de precios y emite CSV + un panel HTML estático. **Enseña:** clientes HTTP con
`context`, agregación concurrente, plantillas con `text/template`. **Mercado:** Kubecost existe
y es caro; el hueco está en la simplicidad y en el modelo autoalojado sin licencia.

**3. Detector de deriva entre el Terraform declarado y la nube real** 🟠
Un demonio que ejecuta `plan` en modo solo lectura contra un catálogo de estados y avisa cuando
alguien cambió algo a mano en la consola. **MVP:** una nube, un proveedor, comparación de
recursos, notificación a Slack con el `diff`. **Enseña:** ejecución de subprocesos, análisis de
JSON sin esquema fijo, planificación con `time.Ticker`. **Mercado:** driftctl fue archivado y
dejó un hueco real.

**4. Servidor de catálogo interno de plantillas de servicio** 🟡
El "botón de crear servicio nuevo": plantillas versionadas, variables, generación del repo con
CI, Dockerfile y manifiestos ya cableados. **MVP:** CLI + servidor HTTP que renderiza una
plantilla desde Git y abre un PR. **Enseña:** `text/template`, `go-git`, integración con la API
de GitHub. **Mercado:** Backstage lo hace pero pesa como un edificio; hay demanda de la versión
de 20 MB.

**5. Admisión de políticas ligera para Kubernetes** 🟠
Un *webhook* de admisión que valida reglas escritas en un DSL mínimo en vez de Rego. **MVP:**
validación de tres reglas frecuentes —límites obligatorios, prohibición de `:latest`, etiquetas
requeridas— con modo auditoría. **Enseña:** servidores TLS, certificados, serialización de
objetos de la API de Kubernetes. **Mercado:** compite de frente con Kyverno y OPA; la
diferenciación tendría que ser la curva de aprendizaje, y hay que demostrarla.

**6. Planificador de apagado por horario para entornos no productivos** 🟢
Apaga los entornos de desarrollo a las 19:00 y los enciende a las 8:00, con excepciones por
etiqueta y un botón de "lo necesito ahora". **MVP:** un `CronJob` en Go que escala a cero los
*deployments* etiquetados, más un endpoint HTTP para despertarlos. **Enseña:** `client-go`,
zonas horarias, idempotencia. **Mercado:** el ahorro es inmediato y medible en la factura, que
es el mejor argumento de venta que existe.

**7. Migrador de esquemas de base de datos consciente del despliegue progresivo** 🟠
Aplica migraciones en dos fases —expandir y contraer— y bloquea la contracción hasta que ningún
proceso con el esquema viejo siga vivo. **MVP:** soporte de PostgreSQL, registro de versiones
en tabla, verificación de procesos vivos mediante un endpoint de salud. **Enseña:** `database/sql`,
bloqueos de asesoramiento, coordinación distribuida sencilla. **Mercado:** `goose` y `dbmate`
migran pero no coordinan; la fase de contracción es donde se rompen los despliegues reales.

### 3.2 🌐 Redes, proxies y borde (8–13)

**8. Proxy inverso con límite de tasa por identidad y no por IP** 🟡
Limita por clave de API, por usuario o por *tenant*, con cubos jerárquicos: el plan paga 1000
req/min y cada usuario dentro de él como máximo 100. **MVP:** proxy con `httputil.ReverseProxy`,
cubos en memoria, configuración en YAML recargable. **Enseña:** `net/http` a fondo,
`sync.Map`, el algoritmo del cubo con fichas, recarga en caliente. **Mercado:** todos los
gateways lo hacen; el hueco está en el *self-hosted* de un archivo para equipos pequeños.

**9. Túnel de desarrollo autoalojado (ngrok propio)** 🟠
Un servidor con dominio comodín y un cliente que abre un túnel inverso para exponer `localhost`.
**MVP:** un solo túnel HTTP, TLS automático vía ACME, sin autenticación más allá de un token.
**Enseña:** multiplexado sobre una conexión (`yamux`), `crypto/tls`, `autocert`. **Mercado:**
ngrok se volvió caro y hay demanda persistente de la versión propia.

**10. Servidor DNS con división por vistas y bloqueo de listas** 🟡
DNS que responde distinto según la red de origen y filtra dominios por lista. **MVP:** servidor
autoritativo mínimo sobre `miekg/dns`, caché, lista de bloqueo recargable, métricas.
**Enseña:** UDP, tiempos de espera agresivos, cachés con expiración. **Mercado:** Pi-hole cubre
el hogar; el hueco es el *split-horizon* de oficina pequeña.

**11. Proxy de salida con lista blanca para contenedores** 🟠
Un *egress gateway* que solo deja salir a los dominios autorizados y registra todo intento
bloqueado. **MVP:** CONNECT proxy con lista blanca, inspección de SNI, bitácora estructurada.
**Enseña:** el protocolo HTTP CONNECT, manejo de TLS sin terminarlo, fugas de goroutines.
**Mercado:** requisito directo de auditorías de cumplimiento — comprador con presupuesto.

**12. Servidor de archivos con firma de URL y cuotas por *tenant*** 🟡
Almacenamiento compatible con S3 pero mínimo, pensado para incrustarse en un producto propio.
**MVP:** PUT/GET/DELETE, URLs prefirmadas, cuota por *tenant*, respaldo en disco local.
**Enseña:** `io.Copy` y flujos sin cargar en memoria, HMAC, límites de tamaño. **Mercado:**
MinIO cambió de licencia y dejó gente incómoda buscando alternativas.

**13. Sonda de conectividad multipunto** 🟠
Agentes desplegados en varias regiones que se prueban entre sí y dibujan la matriz de latencia y
pérdida. **MVP:** agente que hace ping TCP a sus pares y reporta a un colector central, más un
panel simple. **Enseña:** malla de goroutines, relojes y desfase, agregación de percentiles.
**Mercado:** las nubes lo cobran caro y solo para su propia red.

### 3.3 🔭 Observabilidad (14–19)

**14. Agente de bitácoras con muestreo por presupuesto** 🟠
En vez de mandarlo todo o filtrar a ciegas, el agente respeta un presupuesto de bytes por hora y
decide qué muestrear priorizando errores y trazas lentas. **MVP:** lectura de archivos con
seguimiento, muestreo por nivel, envío a Loki, presupuesto configurable. **Enseña:** E/S de
archivos con rotación, contrapresión, algoritmos de muestreo con reservorio. **Mercado:** el
dolor número uno de la observabilidad es la factura, no la funcionalidad.

**15. Convertidor de trazas a documentación de arquitectura** 🟠
Consume trazas de OpenTelemetry y genera el diagrama real de dependencias entre servicios — el
que se contradice con el de Confluence. **MVP:** lectura desde Tempo o Jaeger, agregación de
aristas, salida en Mermaid. **Enseña:** OTLP, agrupación de grafos, generación de texto.
**Mercado:** todo equipo con más de 15 servicios tiene un diagrama desactualizado.

**16. Detector de consultas SQL lentas con atribución al código** 🟠
Cruza el registro de consultas lentas de PostgreSQL con las trazas para decir *qué endpoint*
—y qué línea— genera cada consulta cara. **MVP:** lectura de `pg_stat_statements`, correlación
por comentario SQL inyectado, informe semanal por correo. **Enseña:** `database/sql`, análisis
de texto, correlación por identificadores. **Mercado:** el enlace entre consulta lenta y código
culpable sigue siendo manual en casi todos lados.

**17. Verificador de presupuestos de error como código** 🟡
Define SLOs en YAML, los evalúa contra Prometheus, y falla el paso de CI cuando el despliegue
consumiría más presupuesto del disponible. **MVP:** un binario para CI, tres tipos de SLO,
código de salida distinto de cero. **Enseña:** PromQL desde cliente, aritmética de ventanas
temporales, diseño de CLI para CI. **Mercado:** Nobl9 lo vende caro; la versión autoalojada
tiene público.

**18. Panel de estado público generado desde las propias comprobaciones** 🟢
Un binario que ejecuta comprobaciones, guarda el histórico en SQLite y sirve una página
estática de estado. **MVP:** comprobaciones HTTP y TCP, 90 días de historia, página sin
JavaScript. **Enseña:** SQLite con `modernc.org/sqlite` (sin cgo), `embed`, HTML con plantillas.
**Mercado:** compite con Uptime Kuma; diferenciarse por el binario único sin Node.

**19. Perfilador continuo de bajo costo para producción** 🔴
Toma perfiles de `pprof` periódicos de toda la flota, los almacena comprimidos y permite
comparar dos ventanas de tiempo. **MVP:** recolector, almacenamiento en disco, endpoint de
diferencia entre perfiles. **Enseña:** el formato pprof, `runtime/pprof`, series temporales.
**Mercado:** Polar Signals y Pyroscope existen y son buenos; entrar aquí exige un ángulo claro.

### 3.4 🛠️ CLIs y herramientas de desarrollo (20–26)

**20. TUI de revisión de PR sin salir de la terminal** 🟡
Navegar, comentar y aprobar PRs con Bubble Tea, con el `diff` con resaltado de sintaxis.
**MVP:** lista de PRs, vista de `diff`, aprobar y comentar. **Enseña:** Bubble Tea, el modelo
Elm en Go, clientes de API con paginación. **Mercado:** `gh` no tiene TUI real; hay hueco.

**21. Gestor de secretos para desarrollo local** 🟢
Sustituye el `.env` compartido por Slack: secretos cifrados en el repo, descifrados con la clave
del equipo al arrancar. **MVP:** `cifrar`, `descifrar`, `ejecutar -- comando` que inyecta el
entorno. **Enseña:** `crypto/nacl`, manejo de entorno, `exec`. **Mercado:** SOPS es potente y
áspero; el hueco es la ergonomía.

**22. Grabador y reproductor de sesiones HTTP para pruebas** 🟡
Graba el tráfico real contra una API externa y lo reproduce como servidor simulado determinista.
**MVP:** proxy de grabación, formato de cinta en JSON, servidor de reproducción con coincidencia
por método, ruta y cuerpo. **Enseña:** `httptest`, serialización, coincidencia de peticiones.
**Mercado:** existe en Ruby (VCR) y en Node; en Go la opción idiomática es floja.

**23. Linter de contratos de API entre repositorios** 🟠
Detecta que el servicio A cambió un campo que el servicio B consume, cruzando especificaciones
OpenAPI de varios repos. **MVP:** lectura de varios OpenAPI, grafo de consumo declarado,
detección de cambios rompedores en CI. **Enseña:** análisis de esquemas, comparación de árboles,
diseño de reglas. **Mercado:** el problema es universal en microservicios y la solución actual
es "acordarse".

**24. Generador de datos de prueba respetando claves foráneas** 🟡
Lee el esquema real de una base de datos y genera volumen coherente, con relaciones válidas y
distribuciones realistas. **MVP:** PostgreSQL, orden topológico de tablas, tipos básicos,
inserción por lotes. **Enseña:** introspección de catálogos, ordenamiento topológico,
`COPY` masivo. **Mercado:** todo equipo lo reimplementa mal, cada vez.

**25. Ejecutor local de canalizaciones de CI** 🟠
Ejecuta el YAML de CI en la máquina del desarrollador dentro de contenedores, para no depurar a
base de veinte *commits*. **MVP:** un solo proveedor de CI, pasos secuenciales, montaje del
repo. **Enseña:** el SDK de Docker, análisis de YAML, transmisión de salida en vivo.
**Mercado:** `act` cubre GitHub Actions; los demás proveedores están desatendidos.

**26. Servidor de caché de compilación compartida para equipos** 🟠
Caché remota para `go build`, `bazel` o `turbo` con desalojo por tamaño y métricas de aciertos.
**MVP:** almacenamiento por contenido, API HTTP, expiración por LRU, panel de tasa de acierto.
**Enseña:** almacenamiento direccionado por contenido, control de concurrencia en disco,
`sync.Pool`. **Mercado:** la venta es directa: "tu CI tarda 12 minutos y va a tardar 4".

### 3.5 🧱 Backend, APIs y SaaS (27–32)

**27. Pasarela de webhooks con reintentos, firma y reproducción** 🟠
El servicio que toda empresa que expone webhooks termina escribiendo: cola, reintentos con
retroceso, firma HMAC, bitácora de entregas y botón de reenviar. **MVP:** endpoint de ingreso,
cola persistente en PostgreSQL, reintentos, panel de entregas. **Enseña:** idempotencia,
retroceso exponencial con dispersión, trabajadores con `context`. **Mercado:** Svix lo vende y
le va bien; es la prueba de que el nicho paga.

**28. Servicio de banderas de funcionalidad con evaluación local** 🟡
Las banderas se evalúan en el proceso —sin llamada de red por comprobación— y se sincronizan por
flujo de eventos. **MVP:** servidor con SDK en Go, reglas por porcentaje y por atributo, SSE
para la sincronización. **Enseña:** SSE, evaluación determinista con dispersión, diseño de SDK.
**Mercado:** LaunchDarkly es caro; OpenFeature abrió la puerta a implementaciones alternativas.

**29. Motor de facturación por uso** 🔴
Ingresa eventos de medición, los agrega por periodo y emite la factura con prorrateo y
escalones. **MVP:** ingesta idempotente, agregación por *tenant*, un modelo de precio por
escalones, salida en JSON. **Enseña:** exactamente-una-vez práctico, aritmética con decimales
—nunca `float`—, cierres por periodo. **Mercado:** Lago y Metronome existen; el dominio es
difícil y por eso tiene margen.

**30. Servicio de exportación de datos para grandes volúmenes** 🟡
El endpoint "descargar todo" que no tumba la aplicación: transmite desde la base a CSV o Parquet
sin materializar en memoria, con reanudación. **MVP:** exportación en flujo a CSV, límite de
filas por lote, URL firmada de descarga. **Enseña:** `io.Pipe`, cursores de base de datos,
presión de memoria medible. **Mercado:** interno más que producto, pero es el proyecto que
mejor enseña flujos.

**31. Motor de búsqueda incrustable para aplicaciones pequeñas** 🟠
Búsqueda de texto completo en proceso, sin levantar Elasticsearch, con índice en disco.
**MVP:** indexación, tokenización, BM25, filtros por faceta. **Enseña:** índices invertidos,
`mmap`, compresión de listas de ocurrencias. **Mercado:** Bleve existe pero está poco mantenido;
Meilisearch y Typesense son servidores aparte, no bibliotecas.

**32. Servidor de colaboración en tiempo real con CRDT** 🔴
Concurrencia de edición sobre documentos con resolución automática de conflictos y persistencia.
**MVP:** un tipo de CRDT (texto), WebSocket, persistencia por instantáneas. **Enseña:**
WebSocket, concurrencia sin bloqueos compartidos, serialización eficiente. **Mercado:** el
backend de Yjs suele ser Node; la versión Go de un solo binario tiene su público.

### 3.6 🌊 Datos, colas y pipelines (33–38)

**33. Captura de cambios de PostgreSQL a cualquier destino** 🔴
Lee la replicación lógica y emite los cambios a Kafka, NATS, webhooks o SQLite. **MVP:** un
destino, un esquema, reanudación por LSN, orden garantizado por tabla. **Enseña:** el protocolo
de replicación de PostgreSQL, decodificación binaria, punto de control. **Mercado:** Debezium
pesa (JVM + Kafka Connect); un binario de 20 MB es un argumento fuerte.

**34. Motor de transformación de flujos configurable por YAML** 🟠
Un Benthos mínimo: origen, transformaciones, destino, declarado en un archivo. **MVP:** tres
orígenes, tres destinos, transformaciones con expresiones, métricas. **Enseña:** interfaces y
composición, contrapresión, `errgroup`. **Mercado:** Benthos cambió de manos y su futuro abierto
generó incertidumbre.

**35. Orquestador de trabajos por lotes reanudables** 🟠
Trabajos largos que sobreviven al reinicio del proceso: puntos de control, reanudación desde el
último lote confirmado, cancelación limpia. **MVP:** definición de trabajo, estado en PostgreSQL,
reanudación, endpoint de progreso. **Enseña:** `context` en profundidad, apagado ordenado,
transacciones. **Mercado:** Temporal resuelve mucho más y cuesta mucho más operar.

**36. Cola de trabajos sobre PostgreSQL sin broker** 🟡
`SELECT ... FOR UPDATE SKIP LOCKED` bien hecho: prioridades, reintentos, trabajos programados y
un panel. **MVP:** encolar, consumir, reintentar, panel de trabajos muertos. **Enseña:**
bloqueos de PostgreSQL, concurrencia de trabajadores, señales de apagado. **Mercado:** River y
`gue` existen; el hueco está en la operación y la observabilidad.

**37. Servicio de deduplicación y resolución de identidades** 🟠
Dado un flujo de registros de personas o empresas de varias fuentes, los agrupa en entidades
únicas. **MVP:** normalización, bloqueo por claves, similitud por trigramas, umbral configurable.
**Enseña:** procesamiento concurrente de flujos, estructuras de conjuntos disjuntos, ajuste de
umbrales. **Mercado:** dolor caro y recurrente en CRM y en datos de marketing.

**38. Archivador de datos fríos con consulta directa** 🟠
Mueve particiones viejas de PostgreSQL a Parquet en S3 y permite consultarlas sin restaurarlas.
**MVP:** exportación por partición, catálogo de archivos, consulta por filtro simple. **Enseña:**
Parquet desde Go, paginación en S3, planificación de consultas básica. **Mercado:** el ahorro es
directo y medible — el mejor tipo de argumento.

### 3.7 🔐 Seguridad y DevSecOps (39–43)

**39. Escáner de secretos con validación en vivo** 🟡
No solo detecta que *parece* una clave de AWS: comprueba contra el proveedor si sigue activa, y
prioriza por eso. **MVP:** diez tipos de secreto, validación de tres proveedores, enganche de
pre-commit. **Enseña:** expresiones regulares con rendimiento, concurrencia limitada, `go-git`.
**Mercado:** `gitleaks` detecta; la validación en vivo reduce el ruido, que es el problema real.

**40. Generador y diferenciador de SBOM con política** 🟠
Genera el SBOM, lo compara con el de la versión anterior y falla la compilación si una
dependencia nueva incumple la política —licencia, antigüedad, mantenedor único—. **MVP:**
módulos de Go y npm, salida CycloneDX, tres reglas de política. **Enseña:** análisis de árboles
de dependencias, formatos estándar, diseño de reglas. **Mercado:** empujado por regulación, que
es la demanda más estable que existe.

**41. Servidor de credenciales efímeras para bases de datos** 🟠
Emite usuarios de PostgreSQL con caducidad de una hora, con audiencia y permisos por rol.
**MVP:** emisión, revocación automática, bitácora de auditoría, CLI para desarrolladores.
**Enseña:** `database/sql` con DDL, temporizadores y caducidad, diseño de auditoría.
**Mercado:** es el motor de base de datos de Vault en pequeño, sin desplegar Vault.

**42. Proxy de auditoría de sesiones SSH** 🔴
Todo acceso a producción pasa por el proxy, que graba la sesión y la reproduce después. **MVP:**
proxy SSH con autenticación por certificado, grabación en formato asciicast, reproductor web.
**Enseña:** `golang.org/x/crypto/ssh`, canales y pty, almacenamiento de flujos. **Mercado:**
Teleport lo hace completo y es pesado; el requisito de auditoría es no negociable en muchos
sectores.

**43. Verificador de exposición de infraestructura desde fuera** 🟡
Escanea periódicamente el perímetro propio —puertos, certificados, cabeceras, subdominios
huérfanos— y avisa de cambios. **MVP:** descubrimiento de subdominios, escaneo de puertos,
caducidad de certificados, diferencia contra la ejecución anterior. **Enseña:** concurrencia con
límite, tiempos de espera de red, `crypto/x509`. **Mercado:** la toma de subdominios huérfanos
sigue ocurriendo en 2026.

### 3.8 💰 Fintech y blockchain (44–47)

**44. Motor de contabilidad de doble entrada como servicio** 🔴
Libro mayor con asientos inmutables, saldos derivados y cierre por periodo. **MVP:** cuentas,
asientos balanceados, saldos, cierre; API HTTP. **Enseña:** transacciones serializables,
decimales, diseño append-only. **Mercado:** Formance y TigerBeetle van por ahí; el dominio es
difícil, lo que es exactamente la barrera de entrada.

**45. Conciliador de pagos multipasarela** 🟠
Cruza lo que dice Stripe, lo que dice el banco y lo que dice la base de datos propia, y señala
las diferencias. **MVP:** dos fuentes, coincidencia por importe y fecha con tolerancia, informe
de discrepancias. **Enseña:** análisis de CSV, algoritmos de coincidencia, aritmética exacta.
**Mercado:** hoy se hace en hojas de cálculo, lo cual es una oportunidad y un aviso.

**46. Indexador de eventos de blockchain a base de datos relacional** 🟠
Sigue contratos concretos, decodifica los eventos y los deja consultables en SQL, con manejo de
reorganizaciones de cadena. **MVP:** una cadena, un contrato, reanudación por bloque, manejo de
reorg. **Enseña:** `go-ethereum` como biblioteca, ABI, puntos de control idempotentes.
**Mercado:** The Graph domina pero es caro y complejo; el indexador propio es una necesidad
frecuente.

**47. Detector de anomalías en transacciones con reglas** 🟠
Motor de reglas para fraude: umbrales, velocidad, listas, con puntuación y decisión en menos de
50 ms. **MVP:** DSL de reglas simple, estado en memoria con ventanas, endpoint de decisión.
**Enseña:** ventanas temporales, estructuras concurrentes, presupuesto de latencia medido.
**Mercado:** cada fintech lo escribe; el ángulo sería el motor autoalojado y auditable.

### 3.9 📡 Agentes, sidecars, IoT y borde (48–50)

**48. Agente de flota con actualización automática verificada** 🟠
El problema difícil de cualquier agente: actualizarse solo sin dejar la flota rota. Firma,
despliegue por anillos y reversión automática ante fallo. **MVP:** agente que consulta un
manifiesto firmado, se actualiza, verifica salud y revierte. **Enseña:** reemplazo del propio
binario, `crypto/ed25519`, máquinas de estado. **Mercado:** es infraestructura reutilizable para
cualquiera de las otras 49 ideas.

**49. Pasarela IoT con almacenamiento y reenvío** 🟠
Recibe de sensores por MQTT o serie, almacena localmente cuando no hay red y reenvía con orden
al recuperarla. **MVP:** ingesta MQTT, búfer en SQLite, reenvío con reintento, compilación
cruzada a ARM. **Enseña:** compilación cruzada, E/S con recursos escasos, colas persistentes.
**Mercado:** EdgeX es enorme; el sector industrial pequeño quiere un binario y nada más.

**50. Ejecutor de inferencia en el borde con cola de trabajos** 🔴
Corre modelos pequeños localmente —ONNX o `llama.cpp` vía cgo— con cola, límites de recursos y
métricas, para cuando los datos no pueden salir del sitio. **MVP:** un modelo, cola en memoria,
límite de concurrencia, endpoint OpenAI-compatible. **Enseña:** cgo y sus costos reales, límites
de memoria, contrapresión. **Mercado:** la restricción de soberanía de datos crea demanda
genuina; el riesgo es que el ecosistema de ML en Go sigue siendo pobre.

---

## 4. ⚖️ Veredicto honesto: qué hacer con esta lista

Cincuenta ideas no son un plan; son un menú, y el menú tiene una trampa conocida: invita a
elegir la idea más impresionante en lugar de la más terminable. Tres criterios ayudan a elegir
bien:

- **Si el objetivo es aprender Go**, la mejor idea es de las 🟡 en redes o CLIs — la 8, la 20,
  la 22 o la 36. Todas obligan a usar goroutines, `context` y `io` de verdad en su primera
  semana, que es donde vive la recalibración de quien llega de otro lenguaje.
- **Si el objetivo es un producto**, el filtro correcto no es técnico sino de distribución: la
  idea buena es aquella cuyo primer usuario ya conoces por su nombre. Las de más señal aquí son
  la 2, la 14, la 26 y la 40, porque el comprador tiene presupuesto y el ahorro es medible.
- **Si el objetivo es portafolio**, conviene una 🟠 de un nicho donde Go es indiscutible —la 1,
  la 33 o la 42— porque demuestra criterio de elección de herramienta, y no solo capacidad de
  escribir código.

Y la advertencia final, que es la misma que cierra cualquier curso de este repositorio: **de
estas 50 ideas, unas 12 compiten de frente con una herramienta madura, bien financiada y
gratuita.** Eso no las descalifica, pero obliga a responder una pregunta antes de escribir la
primera línea: *¿qué hace esto que la herramienta establecida no puede hacer sin rehacerse
entera?* Si la respuesta es "es más simple", hay que poder decir en qué unidad — megas de
binario, minutos de puesta en marcha, líneas de configuración. Si no hay unidad, el proyecto
sigue siendo un buen ejercicio de Go, y conviene llamarlo así 😉.
