# Brief de diseño: juguete de microservicios — Inventario de supermercados

Documento de alto nivel para arrancar un proyecto nuevo. Describe QUÉ construir y
POR QUÉ, dejando el CÓMO detallado para la fase de implementación con Claude Code.

**Objetivo del proyecto:** aprender infraestructura cloud-native (Kubernetes vía kind,
Helm, observabilidad, patrones de microservicios) usando un dominio realista. El
código de los servicios es andamiaje que se genera rápido; el foco real es la infra
que los rodea. Diseñado además para extenderse a futuro hacia un juguete de ciencia
de datos.

---

## 1. Dominio: inventario de una cadena de supermercados

Elegido sobre "tienda/pedidos" porque genera datos con volumen y estructura natural
(movimientos de stock a lo largo del tiempo, múltiples sucursales, reabastecimientos),
lo que abre la puerta a análisis de datos más adelante: predicción de demanda,
detección de quiebres de stock, optimización de reabastecimiento.

### Conceptos del dominio

- **Producto**: un SKU del catálogo (nombre, categoría, precio, código de barras).
- **Sucursal (store)**: una tienda física de la cadena.
- **Inventario**: cuántas unidades de cada producto hay en cada sucursal.
- **Movimiento (stock movement)**: entrada o salida de stock (venta, reabastecimiento,
  merma, transferencia entre sucursales). Es el evento central y la fuente de los
  datos temporales para ciencia de datos.
- **Reabastecimiento (replenishment)**: pedido de reposición cuando el stock baja de
  un umbral.

### La actividad de dominio central (el flujo "hola mundo")

**Registrar una venta que descuenta stock y dispara reabastecimiento si aplica:**

1. El frontend registra una venta de N unidades de un producto en una sucursal.
2. El servicio de inventario valida que el producto existe (consulta a catalog).
3. Descuenta el stock y registra el movimiento.
4. Si el stock quedó bajo el umbral, dispara una orden de reabastecimiento.

Este único flujo da material para todo: REST en el MVP, gRPC como optimización,
y una saga cuando el reabastecimiento involucre varios pasos que puedan fallar.

---

## 2. Arquitectura de servicios

```
┌───────────────────────────────────────────────────────┐
│  web-inventory  (Frontend)                             │
│  Java 17 + MicroProfile sobre Open Liberty             │
│  Renderiza el estado del inventario, consume backends  │
└──────────────────┬────────────────────────────────────┘
                   │ REST
    ┌──────────────┼───────────────┬─────────────────────┐
    │              │               │                     │
┌───▼──────┐  ┌────▼────────┐  ┌───▼──────────┐
│ catalog  │  │ inventory   │  │ replenish    │
│ Go       │  │ SpringBoot  │  │ Node/Express │
│          │  │ (Java 17)   │  │              │
│ productos│  │ stock +     │  │ órdenes de   │
│ y precios│  │ movimientos │  │ reposición   │
└───┬──────┘  └────┬────────┘  └───┬──────────┘
    │              │               │
┌───▼──────┐  ┌────▼────────┐  ┌───▼──────────┐
│catalog-db│  │inventory-db │  │replenish-db  │
│Postgres  │  │ Postgres    │  │ Postgres     │
└──────────┘  └─────────────┘  └──────────────┘
```

### Asignación de lenguajes y responsabilidades

| Servicio | Lenguaje | Responsabilidad | Por qué este lenguaje |
|---|---|---|---|
| **web-inventory** | Java 17 + MicroProfile (Open Liberty) | Frontend server-side, orquesta la vista | JEE moderno; trae health/métricas/OpenAPI de fábrica, útil para observabilidad |
| **catalog** | Go | Catálogo de productos (lectura intensiva) | Simple, concurrente, la pieza más fácil para empezar |
| **inventory** | Spring Boot (Java 17) | Stock por sucursal + registro de movimientos. **Servicio central.** | Mejor tooling para lógica de negocio; será el orquestador de la saga |
| **replenish** | Node / Express | Órdenes de reabastecimiento | I/O-bound, encaja con el modelo async de Node |

### Principio clave: database-per-service

Cada microservicio tiene **su propia base de datos Postgres aislada**. Ningún servicio
toca la DB de otro directamente — solo se comunican por API. Este es el patrón que
define microservicios de verdad y evita el anti-patrón de la DB compartida.

---

## 3. Stack de infraestructura

### Contenedores y orquestación
- **Motores**: Docker Desktop y Podman (conviven, uno activo a la vez vía script switch).
- **Kubernetes local**: kind (multi-nodo). Se puede levantar sobre Docker o Podman
  para comparar (aprendizaje dual).
- **Empaquetado**: cada servicio como imagen, cargadas a kind con `kind load`.
- **Despliegue**: umbrella Helm chart con values base + overrides por ambiente
  (local, e2e, qa).

### Observabilidad (stack open source, reemplaza Datadog/Splunk)
- **Prometheus** — métricas
- **Grafana** — dashboards
- **Loki** — logs centralizados (el "Splunk gratis": búsqueda de logs con LogQL)
- **Tempo** — trazas distribuidas (para la fase gRPC/sagas)

### GUIs de gestión (experiencia tipo OpenShift)
- **Headlamp** — web UI, reemplazo oficial del Kubernetes Dashboard (archivado en 2025).
  Ver recursos, abrir terminales en pods, ver logs. Lo más cercano a OpenShift.
- **k9s** — UI de terminal, para navegación rápida del cluster día a día.

---

## 4. Niveles de dificultad: anillos concéntricos

Diseñado para que el MVP sea simple (código rápido con Claude Code) y la complejidad
se añada en capas opcionales. **No construir todo de golpe.**

### Anillo 0 — MVP (dificultad baja)
- Los 4 servicios con REST básico
- Cada uno con su Postgres
- Todo desplegado en kind vía Helm
- El flujo "registrar venta → descontar stock" funcionando end-to-end
- Prometheus + Grafana + Loki desplegados
- Headlamp + k9s para inspeccionar

**Meta del MVP:** ver los pods corriendo, el flujo funcionando, y los datos/logs/
métricas fluyendo a las herramientas de observabilidad.

### Anillo 1 — Comunicación avanzada
- gRPC entre inventory ↔ catalog (contrato Protobuf compartido)
- Explorar por qué gRPC necesita HTTP/2 en Kubernetes

### Anillo 2 — Saga orquestada
- El reabastecimiento como transacción distribuida
- inventory orquesta: reservar → ordenar → confirmar, con compensaciones si algo falla

### Anillo 3 — Saga coreografiada
- Mismo flujo, pero por eventos (Redis pub/sub o NATS)
- Cada servicio reacciona a eventos sin un director central

### Anillo 4 — Redes
- NetworkPolicies (qué servicio puede hablar con cuál)
- Opcional: service mesh (Linkerd es el más simple) para mTLS

### Anillo 5 — Más servicios y extensión a datos
- Nuevos servicios (ej: pricing dinámico, transferencias entre sucursales)
- Semilla de datos: generar movimientos históricos para análisis
- Puente a ciencia de datos (ver sección 6)

---

## 5. Estructura de repositorio sugerida

```
super-inventory-lab/
├── README.md
├── Makefile                       ← up, build, load, deploy
├── kind/
│   └── cluster.yaml               ← cluster multi-nodo
├── services/
│   ├── web-inventory/             ← MicroProfile / Open Liberty
│   ├── catalog/                   ← Go
│   ├── inventory/                 ← Spring Boot
│   └── replenish/                 ← Node/Express
├── charts/
│   └── platform/                  ← umbrella chart
│       ├── values.yaml
│       ├── values-local.yaml
│       ├── values-e2e.yaml
│       └── charts/                ← subchart por servicio + por DB
├── platform/
│   ├── observability/             ← Prometheus, Grafana, Loki, Tempo
│   └── dashboards/                ← Headlamp, k9s (notas de instalación)
└── docs/
    └── fases/                     ← guía por anillos
```

---

## 6. Semilla para ciencia de datos (visión futura)

El dominio se eligió pensando en esto. Los **movimientos de stock** son una serie
temporal natural. Una vez el MVP funcione, se puede:

- Generar datos sintéticos: meses de ventas/reabastecimientos por sucursal y producto.
- Exponer esos datos para análisis (un servicio de export, o acceso read-only a réplicas).
- Casos de análisis: predicción de demanda por producto/sucursal, detección de
  quiebres de stock, estacionalidad, optimización de umbrales de reabastecimiento.
- Herramientas: un Jupyter en el cluster, o exportar a Parquet para análisis externo.

Esto NO es parte del MVP, pero el diseño de datos del MVP debe **no cerrarse** a esto:
guardar timestamps en los movimientos, no borrar histórico, incluir dimensiones
(sucursal, categoría, producto) desde el inicio.

---

## 7. Decisiones de diseño tomadas (resumen)

- **Dominio:** inventario de supermercados (sobre tienda genérica) por su potencial de datos.
- **orders/inventory en Spring Boot** (sobre JEE) por productividad en lógica de negocio.
- **Frontend en MicroProfile** por health/métricas/OpenAPI de fábrica.
- **catalog en Go, replenish en Node** por afinidad con la carga de cada uno.
- **Database-per-service** estricto.
- **MVP deliberadamente simple**, complejidad en anillos opcionales.
- **Observabilidad open source** (Prometheus/Grafana/Loki/Tempo) desde el MVP.
- **Headlamp + k9s** como GUIs de gestión.

---

## 8. Qué pasarle al proyecto nuevo de Claude Code

Cuando arranques el proyecto fresco, el brief para Claude Code sería aproximadamente:

> "Construir el Anillo 0 (MVP) de este diseño: 4 servicios (web-inventory en
> MicroProfile/Open Liberty, catalog en Go, inventory en Spring Boot, replenish en
> Node/Express), cada backend con su Postgres aislado, comunicándose por REST para el
> flujo 'registrar venta → descontar stock → disparar reabastecimiento'. Empaquetar
> cada uno como imagen, desplegar en kind vía umbrella Helm chart con values por
> ambiente, y dejar Prometheus + Grafana + Loki corriendo. Priorizar que el flujo
> funcione end-to-end sobrecompletitud de features."

Ajusta según lo que quieras enfatizar. El código de los servicios puede ser mínimo:
lo importante es que expongan los endpoints, hablen con su DB, y tengan health checks
para las probes de Kubernetes.

---

*Documento de diseño de alto nivel. El detalle de implementación (código, charts
concretos, manifiestos) se desarrolla en el proyecto de construcción.*
