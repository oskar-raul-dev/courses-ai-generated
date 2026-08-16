# Anillo 0 — Refinamiento del diseño y hoja de ruta hacia el chat maestro

Este documento continúa el trabajo de `brief-inventario-supermercados.md`,
`diseno-dominios-y-experimentos.md`, `certificados-tls.md` y
`lab-incidentes-certificados.md`. No introduce código: cierra huecos de diseño que
quedaban implícitos y prepara el terreno para el chat maestro que generará los
prompts de construcción (Claude Code) y los prompts guía por anillo.

---

## 1. Consolidado de decisiones (sin cambios respecto a los documentos previos)

- Dominio: inventario de supermercados. Flujo central: venta → validar producto →
  descontar stock → disparar reabastecimiento si aplica.
- 4 servicios MVP, database-per-service estricto:
  web-inventory (MicroProfile/Open Liberty), catalog (Go, stdlib o chi),
  inventory (Spring Boot 3, JVM normal), replenish (Node/Fastify).
- Node: Fastify en replenish, Express reservado para `reports` (anillo 1).
- Go: sin framework pesado.
- Java: Spring Boot 3 en JAR + JVM para el MVP; GraalVM y Java 25 son anillos futuros.
- kind multi-nodo, umbrella Helm chart, Prometheus/Grafana/Loki/Tempo, Headlamp + k9s.
- Anillos concéntricos 0–8 más la rama de TLS (C1–C5), con TLS **después** del MVP.
- Datos: timestamps en movimientos, sin borrado de histórico, dimensiones desde el
  inicio (sucursal, categoría, producto).
- Persistencia MVP: efímera + seed; hostPath/PersistentVolume queda como opción
  avanzada opt-in, no default.

Nada de esto cambia. Lo que sigue es lo que faltaba especificar para que el Anillo 0
sea ejecutable sin ambigüedad por Claude Code.

---

## 2. Refinamientos al diseño existente

### 2.1 Contratos REST explícitos — Anillo 0

Los documentos previos listan rutas pero no formas de payload. Esto es lo mínimo para
que los 4 servicios se puedan construir en paralelo sin choques de contrato.

**catalog**

```
GET /products?category={id}
→ 200: [{ "id": "uuid", "sku": "string", "name": "string", "categoryId": "uuid",
          "brand": "string", "unit": "string", "listPrice": 1234.50,
          "barcode": "string" }]

GET /products/{id}
→ 200: { ...igual que arriba }
→ 404: { "error": "product_not_found" }

GET /categories
→ 200: [{ "id": "uuid", "name": "string", "parentId": "uuid|null" }]
```

**inventory**

```
GET /stores
→ 200: [{ "id": "uuid", "name": "string", "region": "string" }]

GET /stores/{id}/stock
→ 200: [{ "productId": "uuid", "quantity": 42, "minThreshold": 10 }]

POST /stores/{id}/sales
  body: { "productId": "uuid", "quantity": 3 }
→ 201: { "movementId": "uuid", "newQuantity": 39, "thresholdBreached": false }
→ 404: { "error": "product_not_found" }        (catalog no lo conoce)
→ 409: { "error": "insufficient_stock", "available": 2 }

GET /stores/{id}/movements?from&to&type
→ 200: [{ "id": "uuid", "productId": "uuid", "type": "SALE|REPLENISHMENT|SHRINKAGE|TRANSFER",
          "quantity": 3, "timestamp": "ISO-8601", "reference": "string|null" }]
```

**replenish**

```
POST /replenishments
  body: { "storeId": "uuid", "productId": "uuid", "quantityRequested": 50 }
→ 201: { "id": "uuid", "status": "PENDING" }

GET /replenishments?status&storeId
→ 200: [{ "id": "uuid", "storeId": "uuid", "productId": "uuid",
          "quantityRequested": 50, "status": "PENDING|IN_TRANSIT|RECEIVED|CANCELLED",
          "createdAt": "ISO-8601", "receivedAt": "ISO-8601|null" }]

PATCH /replenishments/{id}
  body: { "status": "IN_TRANSIT" | "RECEIVED" | "CANCELLED" }
→ 200: { ...orden actualizada }
```

**Punto de diseño que quedaba abierto:** cuando `inventory` detecta stock bajo umbral
en `POST /stores/{id}/sales`, ¿llama sincrónicamente a `replenish` antes de responder,
o responde primero y dispara la llamada en segundo plano (fire-and-forget)?
Para el Anillo 0, recomiendo **fire-and-forget con log del resultado**: la venta no
debe fallar porque `replenish` esté caído. Esto además siembra naturalmente la
pregunta que resuelve el Anillo 3 (coreografía por eventos): ¿qué pasa si la llamada
se pierde? Anótalo como la primera motivación real para eventos, no solo teoría.

### 2.2 Health checks y contrato de observabilidad por servicio

Para que Prometheus/Grafana/Loki tengan algo uniforme que scrapear desde el día uno:

| Servicio | Health | Métricas | Logs |
|---|---|---|---|
| web-inventory | `/health/ready`, `/health/live` (MicroProfile Health) | `/metrics` (MicroProfile Metrics, formato Prometheus de fábrica) | stdout JSON estructurado |
| catalog | `/healthz` (simple 200 OK + check de conexión a DB) | `/metrics` vía `prometheus/client_golang` | stdout JSON estructurado |
| inventory | `/actuator/health` (Spring Actuator) | `/actuator/prometheus` (micrometer-registry-prometheus) | stdout JSON estructurado |
| replenish | `/healthz` (plugin fastify-healthcheck o handler manual) | `/metrics` vía `prom-client` | stdout JSON estructurado |

Decisión a fijar: **todos los servicios loguean JSON estructurado a stdout**, nunca a
archivo. Es lo único que hace que Loki (via Promtail/Alloy) recolecte de forma
uniforme sin parsers distintos por lenguaje. Vale la pena decirlo explícito porque
Spring Boot y MicroProfile por defecto loguean texto plano, no JSON — hay que
configurarlo (Logback con encoder JSON en inventory; similar en Liberty).

### 2.3 Estrategia de configuración Helm (values) — nivel de detalle que faltaba

Los docs mencionan `values.yaml`, `values-local.yaml`, `values-e2e.yaml`,
`values-qa.yaml` pero no qué varía entre ellos. Para que el subchart por servicio
tenga sentido desde el Anillo 0:

- **Constante entre ambientes** (va en `values.yaml` base): nombres de servicio,
  puertos internos, rutas de health/metrics, estructura de labels/selectors.
- **Varía por ambiente**: réplicas (1 en local, 2+ en qa), requests/limits de
  CPU/memoria, nivel de log, si Tempo/tracing está activo (apagado en local para
  ahorrar recursos, encendido en e2e/qa), tag de imagen (`:local` construida a mano
  vs tag versionado en qa).
- **replicaCount=1 y sin PodDisruptionBudget en local**: el Anillo 0 no necesita alta
  disponibilidad, solo que el flujo funcione. No sobre-diseñar el chart todavía.

### 2.4 Cluster kind: topología concreta

El brief dice "multi-nodo" sin números. Propuesta concreta para no bloquear el
arranque:

- 1 nodo control-plane + 2 nodos worker.
- `extraPortMappings` en el nodo control-plane para exponer el Ingress
  (80→30080, 443→30443 o los que uses) sin depender de un LoadBalancer externo.
- Nombre de cluster sugerido: `inv-lab` (o `inv-docker` / `inv-podman` cuando hagas
  el experimento comparativo de la sección 5 de `diseno-dominios-y-experimentos.md`).

### 2.5 Persistencia — decisión operativa para Anillo 0

Confirmando lo que ya decidiste: **Anillo 0 usa datos efímeros + Job/script de seed**
que corre post-deploy (Helm hook `post-install` o Job manual). Esto simplifica el
Anillo 0 al máximo: no hay que pensar en StorageClass, PV, hostPath ni permisos desde
el primer día. La opción `extraMounts` + PV hostPath queda documentada como anillo
opcional aparte (podría llamarse **Anillo 0.5 — Persistencia real**, entre el MVP y el
Anillo 1) para cuando quieras dejar de perder datos al borrar el cluster.

### 2.6 Definition of Done — Anillo 0

Para saber cuándo "terminó" el MVP y no seguir puliendo indefinidamente:

- [ ] Los 4 servicios responden en sus health checks dentro de kind.
- [ ] `POST /stores/{id}/sales` ejecuta el flujo completo: valida contra catalog,
      descuenta stock en inventory, y si corresponde crea una orden en replenish.
- [ ] Se puede ver ese flujo reflejado en Grafana (al menos un dashboard con
      requests/segundo y latencia de los 4 servicios) y en Loki (logs correlacionables
      por request, aunque sea buscando por texto, sin trace-id todavía — eso es Tempo
      en anillos posteriores).
- [ ] `helm install`/`upgrade` con `values-local.yaml` deja todo arriba sin pasos
      manuales adicionales fuera del Makefile.
- [ ] Headlamp y k9s muestran los pods/servicios sin errores de RBAC.
- [ ] Puedes borrar el cluster (`kind delete cluster`) y recrearlo desde cero
      (`make up`) sin intervención manual.

Cuando todos estos ítems estén en verde, el Anillo 0 está cerrado — recién ahí tiene
sentido abrir gRPC, sagas o TLS.

---

## 3. Preguntas abiertas / decisiones pendientes

Estas no bloquean el arranque del Anillo 0, pero conviene decidirlas antes de que el
chat maestro genere los prompts de construcción:

1. **Formato de IDs**: ¿UUID en todas las tablas (recomendado, evita colisiones al
   comparar Docker/Podman con clusters distintos) o serial autoincremental?
2. **Migraciones de esquema**: ¿Flyway/Liquibase para inventory (encaja natural con
   Spring Boot), y qué para catalog (Go) y replenish (Node)? Sugerencia: `golang-migrate`
   para catalog, `node-pg-migrate` o SQL plano versionado para replenish — mantiene la
   filosofía de "una herramienta idiomática por lenguaje" que ya aplicaste al routing.
2. **Nombre de dominio local**: ¿`inv.localhost` (ya usado en `certificados-tls.md`)
   se mantiene para el Ingress del Anillo 0, aunque no haya TLS todavía?
3. **Semilla de datos**: ¿cuántas sucursales/productos mínimos para que el Anillo 0
   se sienta "real" sin ser pesado? (sugerido: 3 sucursales, ~20 productos, 3-4
   categorías — suficiente para dashboards con algo que mostrar).

---

## 4. Hoja de ruta hacia el chat maestro

El chat maestro no diseña — ejecuta. Necesita, como insumo, una lista cerrada de
prompts. Esta sección es esa lista, para que la construcción del chat maestro sea
mecánica.

### 4.1 Prompts por servicio (uno por IDE/lenguaje, para Claude Code)

Cada prompt debe incluir: contrato REST de la sección 2.1, entidades de
`diseno-dominios-y-experimentos.md`, requisito de health/metrics/logs de la
sección 2.2, y el Dockerfile esperado (multi-stage, imagen final mínima).

- **Prompt catalog** (GoLand): Go + stdlib/chi, Postgres via `pgx` o `database/sql`,
  seed embebido o script separado.
- **Prompt inventory** (IntelliJ): Spring Boot 3, Spring Data JPA o JDBC directo
  (a decidir — JPA da velocidad, JDBC da control; para un juguete de infra, JPA está
  bien), Actuator + Micrometer.
- **Prompt replenish** (WebStorm): Fastify, `pg` o Prisma (a decidir — Prisma añade
  una capa de aprendizaje no pedida; para este juguete, `pg` plano es más honesto con
  el foco en infra).
- **Prompt web-inventory** (IntelliJ): MicroProfile/Open Liberty, cliente REST
  (MicroProfile Rest Client) hacia los 3 backends, vistas server-side (JSP, Qute, o
  templates simples — a decidir).

### 4.2 Prompts por anillo (guías paso a paso, no generación de código de negocio)

- **Prompt Anillo 0**: el que ya está esbozado en la sección 8 de
  `brief-inventario-supermercados.md` — ajustarlo con el DoD de la sección 2.6 de este
  documento.
- **Prompt Anillo 0.5 (persistencia real)**: `extraMounts` + PV hostPath, opt-in.
- **Prompts Anillo 1 a 8**: uno por anillo, cada uno asumiendo el anterior cerrado.
  Cada prompt de anillo debe: (a) recordar el DoD del anillo anterior como
  precondición, (b) traer solo el concepto nuevo de ese anillo, (c) no re-explicar el
  dominio completo.
- **Prompts de la rama TLS (C1–C5)**: siguiendo `certificados-tls.md` y
  `lab-incidentes-certificados.md` tal cual están, después de Anillo 0 (o 0.5).

---

## 5. Recordatorio: trabajar incrementalmente

Antes de sumar gRPC, sagas, redes o TLS: **el Anillo 0 tiene que estar funcionando
end-to-end**, con el Definition of Done de la sección 2.6 en verde. La tentación en
un proyecto de aprendizaje es diseñar los ocho anillos antes de tocar el primero —
este documento existe para que eso no pase: el diseño de los anillos futuros ya está
capturado, así que no hay costo en dejarlos quietos hasta que el MVP respire solo.

---

*Este documento refina y expande el diseño existente sin introducir código. Sirve de
insumo directo para el chat maestro que generará los prompts de construcción
(sección 4).*
