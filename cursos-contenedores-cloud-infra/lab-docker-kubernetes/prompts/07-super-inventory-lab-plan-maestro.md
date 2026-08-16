# super-inventory-lab — Plan maestro de construcción

Documento consolidado del juguete de microservicios para aprender infraestructura
cloud-native. Reúne todo lo diseñado hasta ahora: el laboratorio, las oleadas de
construcción (empezando por infra), los microservicios en detalle, los anillos de
aprendizaje, los experimentos Podman/Docker y los prompts para arrancar el
desarrollo con Claude Code o Codex.

Documentos fuente que complementa (no los reemplaza, los ordena):
`brief-inventario-supermercados.md`, `diseno-dominios-y-experimentos.md`,
`certificados-tls.md`, `lab-incidentes-certificados.md`,
`anillo-0-refinamiento-y-hoja-de-ruta.md`.

---

## 0. Objetivo y filosofía

**Qué se aprende:** Kubernetes local (kind), Helm, observabilidad open source,
redes, certificados/TLS, patrones distribuidos (gRPC, sagas, eventos), y el contraste
Docker Desktop vs Podman. El código de negocio es andamiaje: se genera rápido por
vibecoding; el valor está en todo lo que rodea a los servicios.

**Dominio:** inventario de una cadena de supermercados. Elegido porque genera datos
con volumen y estructura temporal (movimientos de stock por sucursal y producto),
lo que abre la puerta a un futuro juguete de ciencia de datos.

**Tres principios de trabajo:**

1. **Infra primero, dominio después.** Se construye en *oleadas horizontales* (cada
   oleada toca los 4 servicios con poca profundidad) en lugar de terminar un servicio
   antes de empezar el siguiente. Así se llega a jugar con infra en el primer día.
2. **Anillos concéntricos.** El MVP es deliberadamente simple; la complejidad (gRPC,
   sagas, TLS, mesh) se añade en capas opcionales, cada una asumiendo la anterior
   cerrada.
3. **Incremental, sin excepciones.** El Anillo 0 funcionando end-to-end antes de
   sumar cualquier cosa. El diseño de los anillos futuros ya está escrito; no hay
   costo en dejarlos quietos.

---

## 1. El laboratorio (entorno base)

Lo que existe antes de escribir una línea de código del juguete.

| Componente | Herramienta | Rol |
|---|---|---|
| Host | Windows 11 | Máquina de trabajo |
| Motores de contenedores | Docker Desktop **y** Podman | Conviven; uno activo a la vez vía script `switch-container --switch-docker / --switch-podman` |
| Kubernetes local | kind (multi-nodo) | El cluster donde vive todo |
| Empaquetado | Imágenes OCI + `kind load` | Sin registry externo en el MVP |
| Despliegue | Helm (umbrella chart) | Un `helm install` levanta todo |
| Métricas | Prometheus | Scrapea `/metrics` de cada servicio |
| Dashboards | Grafana | Visualización |
| Logs | Loki (+ Promtail/Alloy) | El "Splunk gratis", búsqueda con LogQL |
| Trazas | Tempo | Para las fases gRPC/sagas (apagado en local al inicio) |
| GUI web | Headlamp | Reemplazo oficial del Kubernetes Dashboard; lo más cercano a OpenShift |
| GUI terminal | k9s | Navegación rápida del cluster día a día |
| IDEs | IntelliJ (Java), GoLand (Go), WebStorm (Node) | Con Claude Code o Codex dentro |

### 1.1 Cluster kind — topología concreta

- 1 nodo control-plane + 2 nodos worker (`kind/cluster.yaml`).
- `extraPortMappings` en el control-plane para exponer el Ingress (80/443 mapeados
  a puertos del host) sin depender de un LoadBalancer externo.
- Nombre de cluster: `inv-lab` para el trabajo normal; `inv-docker` / `inv-podman`
  cuando se hace el experimento comparativo (sección 7).
- Dominio local del Ingress: `inv.localhost` (se mantiene desde el Anillo 0 aunque
  todavía no haya TLS; la rama TLS lo reutiliza tal cual).

### 1.2 Estructura de repositorio

```
super-inventory-lab/
├── README.md
├── CLAUDE.md / AGENTS.md          ← agent file raíz (sección 8)
├── Makefile                       ← up, build, load, deploy, down
├── kind/
│   └── cluster.yaml               ← 1 control-plane + 2 workers, port mappings
├── services/
│   ├── catalog/                   ← Go            (+ su CLAUDE.md/AGENTS.md)
│   ├── inventory/                 ← Spring Boot 3 (+ su CLAUDE.md/AGENTS.md)
│   ├── replenish/                 ← Node/Fastify  (+ su CLAUDE.md/AGENTS.md)
│   └── web-inventory/             ← MicroProfile  (+ su CLAUDE.md/AGENTS.md)
├── charts/
│   └── platform/                  ← umbrella chart
│       ├── values.yaml            ← base, constante entre ambientes
│       ├── values-local.yaml
│       ├── values-e2e.yaml
│       ├── values-qa.yaml
│       └── charts/                ← subchart por servicio + por DB
├── platform/
│   ├── observability/             ← Prometheus, Grafana, Loki, Tempo
│   └── dashboards/                ← notas de instalación Headlamp, k9s
└── docs/
    ├── fases/                     ← guía por oleada y por anillo
    └── bitacora-docker-vs-podman.md
```

---

## 2. Oleadas de construcción (el orden real de trabajo)

Cada oleada toca los 4 servicios. **catalog es el piloto**: se lleva primero por
cada oleada para validar el patrón (Dockerfile, subchart, health, métricas) y
después se replica a los otros 3 casi mecánicamente ("haz lo mismo que catalog pero
en Java/Node").

### Oleada 0 — Walking skeleton (≈ 1 sesión) → **aquí ya se juega con infra**

**Servicios:** cada uno expone solo su health check y un endpoint dummy que devuelve
JSON fijo. Sin Postgres, sin lógica.

**Infra (el foco de la oleada):**
- Cluster kind levantado desde `kind/cluster.yaml`.
- Dockerfile multi-stage mínimo por servicio; `make build` + `make load`.
- Umbrella Helm chart con un subchart por servicio (sin DBs todavía).
- Prometheus scrapeando los 4 `/metrics`; Grafana con un dashboard básico
  (requests/segundo, latencia); Loki recibiendo los logs de los 4 pods.
- Headlamp y k9s mostrando pods/servicios sin errores de RBAC.

**Definition of Done — Oleada 0:**
- [ ] `make up` crea el cluster y despliega los 4 servicios sin pasos manuales.
- [ ] Los 4 health checks responden OK dentro del cluster.
- [ ] Los 4 servicios aparecen en Prometheus como targets UP y en Loki con logs.
- [ ] `kind delete cluster` + `make up` reproduce todo desde cero.

### Oleada 1 — DB + un endpoint real por servicio

**Servicios:** cada backend suma su Postgres y UN endpoint con datos reales:
- catalog: `GET /products` desde DB con seed.
- inventory: `GET /stores` y `GET /stores/{id}/stock`.
- replenish: `GET /replenishments` (vacío pero leyendo de DB).
- web-inventory: página que lista productos consumiendo catalog.

**Infra:** subchart Postgres por servicio, Secrets con credenciales, connection
strings vía variables de entorno, Job de seed post-deploy (Helm hook
`post-install` o Job manual), migraciones de esquema por servicio.

**DoD:** los 4 endpoints leen de su propia DB; ningún servicio conoce la DB de otro;
`make up` desde cero deja los datos de seed cargados.

### Oleada 2 — El flujo central end-to-end (cierra el Anillo 0)

**Servicios:** se implementa `POST /stores/{id}/sales` completo:
validar producto contra catalog → descontar stock y registrar `StockMovement` →
si el stock queda bajo umbral, disparar `POST /replenishments`. web-inventory
muestra dashboard, detalle de sucursal (con acción de venta) y órdenes.

**Infra:** el ConfigMap/env de cada servicio apunta a los otros por DNS interno del
cluster; dashboards de Grafana enriquecidos; logs correlacionables por request
(aunque sea por texto — el trace-id llega con Tempo en anillos posteriores).

**DoD (= DoD del Anillo 0):**
- [ ] Una venta registrada desde web-inventory se refleja en inventory (stock y
      movimiento) y, si corresponde, crea una orden en replenish.
- [ ] Ese flujo se ve en Grafana (4 servicios) y en Loki.
- [ ] `helm install/upgrade` con `values-local.yaml` deja todo arriba solo.
- [ ] Reproducible desde cero sin intervención manual.

### Oleada 3+ — Anillos

A partir de aquí se abren los anillos de la sección 6, uno a la vez, cada uno con
el anterior cerrado.

---

## 3. Los microservicios en detalle

Todos comparten estas convenciones (para que la observabilidad sea uniforme):

- **Logs:** JSON estructurado a stdout, nunca a archivo. Spring Boot y Liberty
  loguean texto plano por defecto; hay que configurarlo (Logback con encoder JSON
  en inventory; equivalente en Liberty).
- **IDs:** UUID en todas las tablas (evita colisiones al comparar clusters
  Docker/Podman).
- **Migraciones:** una herramienta idiomática por lenguaje — Flyway (inventory),
  golang-migrate (catalog), node-pg-migrate o SQL versionado (replenish).
- **Dockerfile:** multi-stage, imagen final mínima (distroless/alpine/JRE slim).
- **Comunicación MVP:** REST/JSON. gRPC llega en el Anillo 2.

| Servicio | Stack | Health | Métricas | Rol |
|---|---|---|---|---|
| catalog | Go, stdlib `net/http` o chi, pgx/database/sql | `/healthz` | `/metrics` (client_golang) | Maestro de productos |
| inventory | Spring Boot 3 + Java 17 (JAR + JVM), JPA o JDBC, Flyway | `/actuator/health` | `/actuator/prometheus` | **Central**: stock + movimientos |
| replenish | Node + Fastify, `pg` plano | `/healthz` | `/metrics` (prom-client) | Órdenes de reabastecimiento |
| web-inventory | Java 17 + MicroProfile / Open Liberty, SSR | `/health/ready`, `/health/live` | `/metrics` (MP Metrics) | Frontend del operador |

Decisiones explícitas de lo que **no** se usa: Gin/Echo/Fiber (Go), NestJS (Node),
Prisma u ORM pesado en Node, GraalVM nativo en el MVP.

### 3.1 catalog (Go) — el piloto

Fuente de verdad de QUÉ productos existen (no cuántos hay).

Entidades: `Product` (id, sku, name, categoryId, brand, unit, listPrice, barcode),
`Category` (id, name, parentId — jerarquía).

```
GET /products?category={id}   → 200 [Product]
GET /products/{id}            → 200 Product | 404 {"error":"product_not_found"}
GET /categories               → 200 [Category]
GET /healthz
```

DB: `catalog-db` — tablas `products`, `categories`.

### 3.2 inventory (Spring Boot 3) — servicio central

Sabe CUÁNTAS unidades de cada producto hay en cada sucursal y registra cada
movimiento. Orquestador de sagas en anillos futuros.

Entidades: `Store` (id, name, address, region), `StockLevel` (storeId, productId,
quantity, minThreshold), `StockMovement` (id, storeId, productId, type
SALE|REPLENISHMENT|SHRINKAGE|TRANSFER, quantity, timestamp, reference) — **la tabla
fuente de datos temporales para ciencia de datos**: nunca se borra histórico.

```
GET  /stores                         → 200 [Store]
GET  /stores/{id}/stock              → 200 [{productId, quantity, minThreshold}]
POST /stores/{id}/sales              body {productId, quantity}
                                     → 201 {movementId, newQuantity, thresholdBreached}
                                     → 404 product_not_found | 409 insufficient_stock
POST /stores/{id}/movements          movimiento genérico
GET  /stores/{id}/movements?from&to&type → 200 [StockMovement]
GET  /actuator/health
```

DB: `inventory-db` — tablas `stores`, `stock_levels`, `stock_movements`.

**Decisión de diseño:** el aviso a replenish tras una venta bajo umbral es
**fire-and-forget con log del resultado**. La venta no falla si replenish está
caído. Esto siembra la motivación real del Anillo 4 (eventos): ¿qué pasa si esa
llamada se pierde?

### 3.3 replenish (Node + Fastify)

Gestiona órdenes de reposición. Ciclo de vida `PENDING → IN_TRANSIT → RECEIVED`
(o `CANCELLED`). Cuando una orden pasa a RECEIVED debería avisar a inventory para
sumar stock — ese enlace es el que en el Anillo 4 se vuelve coreografía por eventos.

Entidad: `ReplenishmentOrder` (id, storeId, productId, quantityRequested, status,
createdAt, receivedAt).

```
POST  /replenishments               body {storeId, productId, quantityRequested}
                                    → 201 {id, status:"PENDING"}
GET   /replenishments?status&storeId → 200 [ReplenishmentOrder]
PATCH /replenishments/{id}          body {status} → 200 orden actualizada
GET   /healthz
```

DB: `replenish-db` — tabla `replenishment_orders`.

### 3.4 web-inventory (MicroProfile / Open Liberty)

Frontend server-side (no SPA) del operador de la cadena. Consume los 3 backends
vía MicroProfile Rest Client, con las URLs por variables de entorno (DNS interno
del cluster, nunca localhost).

Vistas: dashboard (resumen por sucursal, alertas bajo umbral), detalle de sucursal
(stock + registrar venta), órdenes de reabastecimiento.

### 3.5 Mapa de relaciones

```
web-inventory ──REST──> catalog      ¿qué productos hay?
web-inventory ──REST──> inventory    ¿cuánto stock? registrar venta
web-inventory ──REST──> replenish    ¿estado de órdenes?
inventory     ──REST──> catalog      validar producto al vender
inventory     ──REST──> replenish    crear orden si stock bajo umbral (fire-and-forget)
replenish     ──REST──> inventory    avisar recepción → sumar stock (futuro: evento)
```

---

## 4. Infra en detalle

### 4.1 Umbrella Helm chart y values por ambiente

- **`values.yaml` (constante):** nombres de servicio, puertos internos, rutas de
  health/metrics, labels/selectors.
- **Varía por ambiente (`values-local/e2e/qa.yaml`):** réplicas (1 en local, 2+ en
  qa), requests/limits, nivel de log, Tempo/tracing activo (apagado en local),
  tag de imagen (`:local` vs versionado).
- Sin PodDisruptionBudget ni HA en local: el Anillo 0 solo necesita que el flujo
  funcione.
- Un subchart por servicio y uno por DB (`charts/platform/charts/`).

### 4.2 Observabilidad

- Prometheus scrapea los endpoints de la tabla de la sección 3.
- Grafana: un dashboard "plataforma" (RPS, latencia, errores por servicio) desde la
  Oleada 0; dashboards de dominio (ventas, stock bajo umbral) desde la Oleada 2.
- Loki: recolección uniforme gracias a logs JSON a stdout.
- Tempo: se enciende cuando llegan gRPC/sagas (trace-id propagado entre servicios).

### 4.3 Persistencia

- **Anillo 0:** datos efímeros + seed post-deploy. Se pierden al borrar el
  cluster, se regeneran con `make up`. Cero fricción con StorageClass/PV/permisos.
- **Anillo 0.5 (opt-in):** `extraMounts` en kind + PersistentVolume hostPath para
  que los datos de Postgres sobrevivan al `kind delete`. Advertencia: hostPath +
  Postgres da fricción de permisos y no es para producción.

### 4.4 Semilla de datos

Sugerido: 3 sucursales, ~20 productos, 3-4 categorías, umbrales que permitan
disparar reabastecimientos con pocas ventas. Suficiente para que los dashboards
muestren algo sin ser pesado. En el Anillo 8 se amplía a meses de movimientos
sintéticos.

---

## 5. Definition of Done del Anillo 0 (= Oleada 2 cerrada)

- [ ] Los 4 servicios responden en sus health checks dentro de kind.
- [ ] `POST /stores/{id}/sales` ejecuta el flujo completo (catalog → inventory →
      replenish).
- [ ] El flujo se ve en Grafana y en Loki.
- [ ] `helm install/upgrade` con `values-local.yaml` deja todo arriba sin pasos
      manuales fuera del Makefile.
- [ ] Headlamp y k9s muestran todo sin errores de RBAC.
- [ ] `kind delete cluster` + `make up` reproduce todo desde cero.

Cuando esto esté en verde, recién se abre el primer anillo.

---

## 6. Anillos de aprendizaje (después del Anillo 0)

| Anillo | Qué añade | Concepto que enseña |
|---|---|---|
| 0.5 | Persistencia real (extraMounts + PV hostPath), opt-in | Volúmenes en kind, fricción de permisos |
| 1 | Servicio `reports` (Node/Express) + endpoint de export | Contraste Express/Fastify; datos para análisis |
| 2 | gRPC entre inventory ↔ catalog (Protobuf compartido) | HTTP/2 en Kubernetes, contratos binarios |
| 3 | Saga orquestada del reabastecimiento (reservar → ordenar → confirmar + compensaciones) | Transacción distribuida, inventory como orquestador |
| 4 | Saga coreografiada (eventos vía Redis pub/sub o NATS) | Desacoplamiento por eventos; resuelve el fire-and-forget del MVP |
| 5 | Migración Spring Boot Java 17 → 25 | Migración LTS-a-LTS |
| 6 | Compilación nativa GraalVM de inventory + medición antes/después | Optimización cloud-native (arranque, memoria) |
| 7 | NetworkPolicies + service mesh (Linkerd) | Quién puede hablar con quién; mTLS automático |
| 8 | Semilla de datos masiva + Jupyter en el cluster / export Parquet | Puente a ciencia de datos (demanda, quiebres, estacionalidad) |

### Rama de certificados y TLS (documentos `certificados-tls.md` y `lab-incidentes-certificados.md`)

Se aborda **después** de que el MVP funcione sin cifrado: añadir TLS sobre algo que
ya funciona enseña mejor que arrancar con TLS.

| Anillo | Qué añade | Concepto |
|---|---|---|
| C1 | TLS self-signed en el Ingress (`inv.localhost`), CA propia con OpenSSL o mkcert | Secret TLS, terminación en el borde, SAN, confiar en una CA |
| C2 | cert-manager con ClusterIssuer de CA propia | Emisión y renovación automática, `renewBefore` |
| C3 | mTLS entre servicios: primero a mano, luego Linkerd | Handshake mutuo, zero-trust interno, cómo el mesh lo abstrae |
| C4 | Registry local con cert self-signed (ángulo Podman/Docker) | Error `x509: unknown authority`, confianza en CA distinta por motor |
| Lab | Laboratorio de incidentes: cert expirado, CA desconocida, SAN incorrecto, clave/cert desparejados, cert-manager que no emite, mTLS sin cert de cliente | Reconocer el síntoma → causa → primer comando en 30 segundos |

Orden recomendado global: Anillo 0 → 0.5 (opcional) → 1 → 2 → C1 → C2 → 3 → 4 →
7 (con C3 dentro, ya que Linkerd resuelve mTLS) → C4 + Lab → 5 → 6 → 8.
No es rígido; la única regla dura es "el anterior cerrado antes del siguiente".

---

## 7. Experimentos Podman vs Docker Desktop

El mismo juguete se levanta en kind-sobre-Docker y kind-sobre-Podman y se documentan
las diferencias en `docs/bitacora-docker-vs-podman.md`. Se puede empezar desde la
Oleada 0 (el walking skeleton ya es suficiente para comparar cluster, build y load).

- **A — Rootless en la práctica:** exponer el Ingress en el puerto 80 con Podman
  rootless; observar la fricción y la solución (rootful o puertos altos).
- **B — Portabilidad de imágenes:** `docker save` → `podman load`; comprobar que OCI
  hace las imágenes portables.
- **C — Tiempos de arranque del cluster:** cronometrar `kind create cluster` en cada
  motor y razonar la diferencia (VM de Podman vs WSL de Docker).
- **D — `podman generate kube`:** comparar el YAML generado con el manifiesto propio.
- **E — Observabilidad del motor:** Docker Desktop GUI vs Podman Desktop vs
  Headlamp/k9s: motor, orquestador y GUI de cada capa.
- **C4 (rama TLS):** confiar en la CA de un registry self-signed, distinto en cada
  motor.

Matriz a completar: crear cluster, build, `kind load`, puerto 80, RAM del host,
experiencia GUI, generar YAML.

---

## 8. Vibecoding: agent files y prompts de arranque

### 8.1 Agent files

- **Claude Code** lee `CLAUDE.md` automáticamente (raíz y por subcarpeta).
- **Codex** usa `AGENTS.md`, estándar abierto con el mismo espíritu.
- Regla: **cortos** (bajo ~200 líneas), solo lo universalmente cierto para ese
  directorio, apuntando a los documentos de diseño en lugar de pegarlos.

Estructura:
- **Raíz:** dominio, los 4 servicios en una línea cada uno, stack de infra,
  filosofía de oleadas/anillos, comandos del Makefile, dónde está cada documento
  de diseño, estado actual de cada oleada por servicio.
- **Por servicio:** stack, comandos de build/run/test, convenciones, contrato REST
  completo de ese servicio (incluyendo endpoints de oleadas futuras marcados como
  pendientes).

Los prompts siguientes están pensados para abrir un chat de **diseño** con la
herramienta (decidir 2-3 cosas puntuales), no para generar todo el código de golpe,
y terminan con el agent file escrito. Ajustar `CLAUDE.md`/`AGENTS.md` según la
herramienta elegida.

### 8.2 Prompt raíz (infra — el que desbloquea la Oleada 0)

```
Este es el repo raíz de un juguete de microservicios de aprendizaje de infra
cloud-native. 4 servicios: catalog (Go), inventory (Spring Boot, central),
replenish (Node/Fastify), web-inventory (MicroProfile). Database-per-service
estricto. Kubernetes local vía kind, despliegue con umbrella Helm chart,
observabilidad Prometheus+Grafana+Loki+Tempo, Headlamp+k9s.

Ahora mismo estamos en Oleada 0 (walking skeleton): los 4 servicios solo exponen
health checks, sin DB ni lógica de negocio. El objetivo de esta sesión es SOLO
infra: cluster kind (1 control-plane + 2 workers, port mappings del Ingress),
Dockerfiles mínimos, umbrella Helm chart con subchart por servicio (sin DB
todavía), y que Prometheus/Grafana/Loki/Headlamp/k9s vean los 4 pods arriba.

No toques la lógica de negocio de ningún servicio. Al terminar, escribe un
CLAUDE.md/AGENTS.md raíz con: comandos del Makefile (up/build/load/deploy/down),
estructura del repo, y estado actual de cada oleada por servicio.
```

### 8.3 Prompt catalog (piloto — hacer primero)

```
Estoy construyendo un juguete de microservicios para aprender infra cloud-native
(Kubernetes/kind/Helm/observabilidad). Este directorio es el servicio `catalog`.

Stack: Go, sin framework pesado (stdlib net/http o chi como máximo), Postgres
propio (catalog-db), sin ORM (database/sql o pgx directo).

Responsabilidad: maestro de productos (qué existe, no cuánto hay).

Endpoints (Oleada 0 — solo esto por ahora, sin DB):
  GET /healthz  → 200 OK
  GET /products → [] (hardcodeado, sin DB todavía)

Quiero que primero discutamos juntos:
1. Estructura de carpetas idiomática para un servicio Go chico (sin sobre-ingeniería).
2. Cómo expondremos /metrics en formato Prometheus (prometheus/client_golang).
3. Forma del Dockerfile multi-stage (build en golang:X, runtime en distroless o alpine).

No generes el servicio completo todavía. Al terminar de decidir esto, escribe un
AGENTS.md/CLAUDE.md para este directorio con: stack, comandos (build/run/test),
convenciones de código, y el contrato REST completo (Oleada 1 suma DB +
GET /products real, Oleada 2 suma GET /products/{id} consumido por inventory).
```

### 8.4 Prompt inventory (servicio central)

```
Mismo juguete de microservicios que catalog. Este directorio es `inventory`,
el servicio central: stock por sucursal + tabla de movimientos.

Stack: Spring Boot 3 + Java 17, JAR normal (NO GraalVM nativo, eso es un anillo
futuro), Spring Data JPA o JDBC directo (a decidir juntos), Postgres propio
(inventory-db), Actuator + Micrometer para /actuator/health y /actuator/prometheus.

Endpoints Oleada 0 (solo esto por ahora):
  GET /actuator/health → debe responder OK

Antes de generar código quiero decidir contigo:
1. JPA vs JDBC directo — para un juguete de infra, ¿cuál da menos fricción?
2. Herramienta de migraciones (Flyway o Liquibase).
3. Configuración de Logback para loguear JSON estructurado a stdout (para Loki).

No implementes el flujo de venta todavía, eso es Oleada 2. Al cerrar la discusión,
escribe un CLAUDE.md/AGENTS.md para este directorio con stack, comandos
Maven/Gradle, convenciones, y el contrato REST completo (incluye ya el de
POST /stores/{id}/sales como referencia futura, aunque no se implemente aún).
```

### 8.5 Prompt replenish

```
Mismo juguete. Este directorio es `replenish` (Node + Fastify), órdenes de
reabastecimiento, Postgres propio (replenish-db).

Endpoints Oleada 0 (solo esto):
  GET /healthz → 200 OK

Decidamos antes de codear:
1. pg plano vs un query builder liviano (nada de ORM pesado tipo Prisma — el foco
   del juguete es infra, no el ORM).
2. Plugin de health/metrics para Fastify (fastify-healthcheck + prom-client).
3. Estructura para que después convivan Fastify (replenish) y Express (reports,
   anillo futuro) en el mismo repo sin pisarse convenciones.

Al terminar, escribe AGENTS.md/CLAUDE.md con stack, comandos npm, convenciones, y
el contrato REST completo (incluyendo POST /replenishments y
PATCH /replenishments/{id} como referencia, aunque Oleada 0 no los implemente).
```

### 8.6 Prompt web-inventory

```
Mismo juguete. Este directorio es `web-inventory`: frontend Java 17 + MicroProfile
sobre Open Liberty, server-side rendering, consume catalog/inventory/replenish.

Endpoints Oleada 0 (solo esto):
  /health/ready y /health/live (MicroProfile Health) → deben responder OK
  Una página estática de placeholder

Decidamos antes de codear:
1. Motor de templates server-side (JSP clásico vs Qute vs algo más simple).
2. Cómo configuramos MicroProfile Rest Client para apuntar a los otros 3 servicios
   vía variables de entorno (nombres DNS internos del cluster, no localhost).
3. Cómo se ve /metrics con MicroProfile Metrics.

No implementes las vistas de dashboard/sucursal todavía, eso es Oleada 2. Cierra
con un CLAUDE.md/AGENTS.md para este directorio: stack, comandos Maven,
convenciones, y qué consume de cada backend.
```

### 8.7 Prompts por anillo (para generar cuando toque)

Uno por anillo (0.5, 1–8, C1–C4, Lab), cada uno con tres reglas: (a) recuerda el
DoD del anillo anterior como precondición, (b) trae solo el concepto nuevo de ese
anillo, (c) no re-explica el dominio completo — apunta a este documento y a los de
diseño.

---

## 9. Decisiones pendientes (no bloquean la Oleada 0)

1. JPA vs JDBC en inventory (se decide en el chat de arranque de inventory).
2. Motor de templates en web-inventory (ídem).
3. Promtail vs Alloy como agente de recolección para Loki.
4. Si Tempo se instala desde la Oleada 0 apagado o se añade recién en el Anillo 2.

---

## 10. Recordatorio final

El orden es: **Oleada 0 (infra con esqueletos) → Oleada 1 (DBs) → Oleada 2 (flujo
end-to-end = Anillo 0 cerrado) → anillos, uno a la vez.** Todo lo demás de este
documento ya está diseñado y no se toca hasta que el paso anterior tenga su
Definition of Done en verde.
