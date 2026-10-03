# 📜 Contrato del cluster
## Laboratorio de contenedores y Kubernetes local

> **Qué es este documento:** los nombres técnicos que ninguna fase puede cambiar: la estructura de
> `src/lab/`, los servicios, los puertos, las rutas de plataforma, los namespaces, los hosts, las
> labels, los perfiles, las tareas del Taskfile y la matriz de generación. **Es de lectura
> obligatoria antes de tocar cualquier cosa bajo `src/lab/`.**
> **Precedencia:** debajo del [alcance](alcance-del-proyecto.md) y de la
> [guía](guia-de-estilo-y-convenciones.md), por encima de las propuestas, las plantillas y los
> prompts. Si una fase necesita un nombre que no está aquí, **lo agrega aquí primero**.
> **Fecha:** 30/09/2026. **Lo marcado ⏳** se fija en la verificación de laboratorio (P11) y se
> traslada en P12.

---

## 1. 🧭 Las tres reglas del contrato

1. **Un contrato de plataforma uniforme.** Los cuatro servicios cumplen exactamente la misma
   interfaz hacia el cluster: el mismo puerto, las mismas rutas de salud, la misma ruta de métricas,
   la misma forma de log. **Cómo lo consigue cada runtime es el contenido del curso**; que lo
   consiga no se negocia.
2. **El contrato de dominio se congela en la Fase 02.** Desde ahí, los endpoints que todavía no
   existen están marcados como pendientes en el OpenAPI, y ninguna fase cambia una forma de
   payload sin cambiar primero el contrato y la suite.
3. **Una capacidad no llega antes que su fase.** Si el código de un servicio expone `/metrics`
   antes de la Fase 17, el código está mal, aunque funcione.

---

## 2. 📁 La estructura de `src/lab/`

Un solo proyecto, que crece fase a fase y se etiqueta con `fase-NN-<slug>`.

```text
src/lab/
├── Taskfile.yml                 punto de entrada único (§7)
├── kind/
│   ├── cluster-minimo.yaml      un nodo
│   └── cluster-lab.yaml         control-plane + 2 workers
├── contracts/
│   ├── openapi/                 catalog.yaml · inventory.yaml · replenish.yaml · pricing.yaml
│   ├── proto/pricing/v1/        pricing.proto (desde la Fase 23)
│   ├── docs/                    Swagger UI en compose, para leer los OpenAPI
│   └── conformance/             suite Hurl, un archivo por servicio y uno del flujo de venta
├── services/
│   ├── catalog/                 PHP · Laravel · Dockerfile · CLAUDE.md
│   ├── inventory/               Java · Spring Boot · Dockerfile · CLAUDE.md
│   ├── replenish/               Node · NestJS · Dockerfile · CLAUDE.md
│   ├── pricing/                 Go · Dockerfile · CLAUDE.md
│   └── storefront/              React · Vite · Dockerfile · CLAUDE.md
├── compose/compose.yaml         Partes 0 y I
├── deploy/manifests/            YAML plano, Fases 08 a 12
├── charts/platform/             umbrella chart desde la Fase 13, un subchart por servicio
├── platform/                    gateway · cert-manager · observability · data (postgres, valkey, nats)
├── chaos/                       el generador de caos (Go), Fase 22
├── legacy/                      el patrimonio de arranque, apéndice a16 (tanda T1b)
│   ├── contingencia/            el código del Siga en Eclipse GlassFish, SOAP + Postgres propio
│   ├── portal/                  Laravel (PPVW), con su SQLite y el job nocturno de catálogo
│   └── braqui/                  Node, sondeando las tablas de despachos de Contingencia;
│                                y el script de traslados por archivo (Python + cron, D30)
├── scripts/                     scripts de Python del laboratorio (D31), un requirements.txt por directorio
│   └── seed/                    datos sintéticos con Faker; a01 lo presenta y la F12 lo corre como Job
├── bench/                       scripts de k6 y resultados crudos de cada medición
└── switch-container.ps1         alternancia de motores en Windows (revisado en T1: pasa a Python
                                 si la alternancia aplica también a macOS y Linux)
```

**Los prompts de generación no viven aquí**: se publican en `a03`. Lo que vive en cada servicio es
su `CLAUDE.md`, corto (menos de 150 líneas), con el stack, los comandos, las convenciones y el
contrato del servicio con los pasos futuros marcados como pendientes.

---

## 3. 🧱 Los servicios y su interfaz de plataforma

| Servicio | Puerto HTTP | Puerto extra | Imagen | Rol |
|---|---|---|---|---|
| `catalog` | 8080 | — | `lab/catalog` | maestro de productos y categorías |
| `inventory` | 8080 | — | `lab/inventory` | stock por tienda y movimientos; orquestador de la saga |
| `replenish` | 8080 | — | `lab/replenish` | órdenes de reposición; consumidor de eventos |
| `pricing` | 8080 | 9090 (gRPC, desde F23) | `lab/pricing` | precio vigente por producto y tienda |
| `storefront` | 8080 | — | `lab/storefront` | frontend estático servido por nginx sin privilegios |

**Por qué todos en 8080:** ningún contenedor del curso necesita un puerto privilegiado, y un puerto
uniforme hace que la diferencia entre servicios esté donde importa. El puerto se lee de la variable
`PORT` y 8080 es su valor por defecto.

**Rutas de plataforma, iguales en los cuatro backends:**

| Ruta | Desde | Qué responde |
|---|---|---|
| `GET /health/live` | F02 | 200 si el proceso puede atender; **nunca** consulta dependencias |
| `GET /health/ready` | F02 trivial, F15 real | 200 solo si el servicio puede atender tráfico de verdad |
| `GET /metrics` | F17 | formato de exposición de Prometheus |

`inventory` cumple estas rutas remapeando Actuator, y eso se dice en la fase que lo hace: el
contrato es uniforme aunque el framework tenga su propia convención.

**Variables de entorno comunes:** `PORT`, `LOG_LEVEL`, `DATABASE_URL` (desde F12), las URL de los
vecinos como `CATALOG_URL`, `PRICING_URL`, `REPLENISH_URL` (desde F09, usadas desde F16),
`NATS_URL` y `VALKEY_URL` (Parte IV), y las de OpenTelemetry estándar (`OTEL_*`, desde F23).
`storefront` recibe `API_BASE_URL`, y la Fase 11 existe para mostrar por qué no alcanza con eso.
`pricing` recibe `REGULATED_CAP_ENABLED` y la ruta de la tabla de topes regulados, que viven en un
`ConfigMap` desde la Fase 11 (D23).

**Logs:** a stdout, nunca a archivo. Texto libre hasta la Fase 18; desde ahí, **una línea JSON por
evento** con al menos `timestamp`, `level`, `service`, `message` y, desde la Fase 23, `traceId`.

**Apagado:** desde la Fase 16, al recibir `SIGTERM` el servicio deja de aceptar conexiones nuevas,
termina las que tiene en vuelo y sale en menos de `terminationGracePeriodSeconds`.

---

## 4. 🧭 Namespaces, hosts y labels

**Namespaces:**

| Namespace | Qué vive ahí | Desde |
|---|---|---|
| `apps` | los cuatro servicios y `storefront` | F09 (en F08, `pricing` vive en `default` a propósito) |
| `data` | Postgres, Valkey, NATS | F12 / Parte IV |
| `gateway` | Envoy Gateway y el `Gateway` compartido | F10 |
| `observability` | Prometheus, Grafana, Loki, Fluent Bit, Tempo | F17 |
| `cert-manager` | cert-manager y trust-manager | F19 |
| `legacy` | el patrimonio: Contingencia, su Postgres, el portal y la Braqui | F10 (antes, en compose) |
| `apps-b` | la segunda cadena: el mismo chart como release `tenant-b`, con su archivo de valores | F14, F15 y F20 (D24); apagada en `minimo` |

**Hosts**, todos bajo `.localhost`, que resuelve a la máquina local sin tocar `/etc/hosts` en la
mayoría de los clientes (la excepción, y qué hacer con ella, es contenido de la Fase 10):

`storefront.localhost` · `api.localhost` (ruteo por prefijo a los cuatro backends) ·
`grafana.localhost` · `prometheus.localhost`

**Puertos del host:** 8080 para HTTP y 8443 para HTTPS, nunca 80 ni 443, porque Podman sin
privilegios no los puede publicar. Cómo llega ese puerto al `Gateway` —`cloud-provider-kind` o
`extraPortMappings` con `NodePort`— se decide en la verificación ⏳.

**Labels**, las recomendadas por Kubernetes y ninguna inventada:

```yaml
app.kubernetes.io/name: pricing          # el servicio
app.kubernetes.io/part-of: lab           # el sistema
app.kubernetes.io/component: backend     # backend · frontend · database · bus · observability
app.kubernetes.io/version: "{{tag}}"     # el tag legible; la imagen se fija por digest
```

Los selectores de `Service` y `Deployment` usan **solo** `app.kubernetes.io/name`. Un selector con
más labels es la causa de uno de los incidentes del cuaderno.

---

## 5. 📦 Los perfiles de despliegue

No son cosmética: son parte del arnés de medición y del presupuesto de memoria.

| Perfil | Cluster | Qué corre | Réplicas | Dónde se usa |
|---|---|---|---|---|
| `minimo` | kind de un nodo | servicios y Postgres; todo lo demás apagado | 1 | Partes 0–II, salvo las excepciones |
| `lab` | control-plane + 2 workers | lo que la fase encienda | las de la fase | F07 (topología), F16, F18, Partes III y IV |
| `medicion` | el que declare la medición | **solo** lo medido y su generador de carga | las de la medición | cada 📏 |

**Los interruptores**, que desde la Fase 13 son valores del umbrella chart y antes son archivos que
se aplican o no:

```yaml
observability:
  metrics:    { enabled: false }   # Prometheus (metrics-server va aparte: lo necesita el HPA)
  dashboards: { enabled: false }   # Grafana
  logs:       { enabled: false }   # Loki + Fluent Bit
  traces:     { enabled: false }   # Tempo
bus:
  valkey: { enabled: false }
  nats:   { enabled: false }
```

**El presupuesto de memoria** de cada pieza (`requests` y `limits`) y la memoria del host por perfil
se miden en la verificación ⏳ y se publican en `a01`. Hasta entonces, ningún documento cita un
número.

---

## 6. 🌊 La matriz de generación

Cada celda es un prompt publicado en `a03`, con el contrato de ese paso y el comando de la suite
que lo valida. `pricing` va primero en cada fila (es el piloto) y **los otros tres lo siguen**.

| Paso | Fase | Qué agrega | Servicios |
|---|---|---|---|
| **G0 · Esqueleto** 🌊 | F02 | `/health/live`, `/health/ready` triviales y un endpoint con JSON fijo | los cinco |
| **G1 · Almacén propio** 🌊 | F09 | SQLite dentro del pod, lectura y escritura básicas, sin llamar a nadie | los cuatro backends; `storefront` lista productos |
| **G2 · Configuración en arranque** | F11 | `storefront` lee su configuración al arrancar, no al compilar | `storefront` |
| **G3 · Postgres** | F12 | `DATABASE_URL`, migraciones idempotentes ejecutables como `Job` | los cuatro backends |
| **G4 · Readiness real** | F15 | la sonda de readiness comprueba lo que el servicio necesita para atender | los cuatro backends |
| **G5 · El flujo de venta** 🌊 | F16 | venta completa y apagado limpio ante `SIGTERM`; aviso a `replenish` sin esperar respuesta | los cuatro backends y `storefront` |
| **G6 · Métricas** | F17 | `/metrics` con las métricas RED del servicio | los cuatro backends |
| **G7 · Logs estructurados** | F18 | una línea JSON por evento a stdout | los cuatro backends |
| **G8 · Cliente mTLS** | F19 | `inventory` presenta certificado a `pricing` y verifica el suyo | `inventory`, `pricing` |
| **G9 · Resiliencia** | F22 | timeouts, reintentos con backoff y circuit breaker en las llamadas salientes | `inventory` |
| **G10 · gRPC y trazas** | F23 | `pricing` sirve gRPC; los cuatro propagan contexto con OpenTelemetry | los cuatro backends |
| **G11 · Saga orquestada** | F24 | pasos y compensaciones coordinados por `inventory` | `inventory`, `replenish` |
| **G12 · Coreografía** | F25 | eventos por Valkey pub/sub y después por NATS JetStream | `inventory`, `replenish` |
| **G13 · Idempotencia y outbox** | F26 | claves de idempotencia y tabla outbox con su publicador | `inventory`, `replenish` |

**El patrimonio es insumo de la matriz.** Desde G0, el prompt de cada servicio nuevo recibe el
código del que se extrae: `pricing` y `inventory`, de Contingencia; `catalog`, del portal;
`replenish`, de la Braqui. El contrato y la suite siguen siendo los que deciden qué es válido.

**La suite de conformidad crece con la matriz**: cada paso agrega sus casos Hurl, y un paso está
hecho cuando `task conformance -- <paso>` pasa contra compose (Partes 0–I) o contra el cluster
(desde la Parte II).

---

## 7. ⌨️ Las tareas del Taskfile

Los nombres son contrato: las fases los citan tal cual. Cada tarea es corta y legible, porque el
lector tiene que poder abrirla y ver qué `kubectl` o qué `helm` corre debajo.

| Tarea | Qué hace | Desde |
|---|---|---|
| `task engine:status` | qué motor está activo y si responde | F00 |
| `task build -- <svc>` / `task build:all` | construye la imagen con el motor activo | F01 / F04 |
| `task compose:up` / `compose:down` | el sistema en compose | F02 |
| `task legacy:up` / `legacy:down` | enciende o apaga el patrimonio (perfil de compose y, desde F10, namespace `legacy`) | F02 |
| `task conformance -- <paso>` | corre la suite Hurl del paso contra el entorno activo | F02 |
| `task contracts:docs` | levanta Swagger UI en un contenedor con los cuatro OpenAPI, en `localhost:8090` | F02 |
| `task cluster:up -- minimo\|lab` / `cluster:down` | crea o borra el cluster kind | F07 |
| `task images:load` | carga las imágenes al cluster (con la variante de Podman) | F08 |
| `task deploy -- <perfil>` | aplica manifiestos (F08–F12) o instala el chart (desde F13) | F08 |
| `task obs:on -- <pieza>` / `obs:off` | enciende o apaga una pieza de observabilidad | F17 |
| `task measure -- <id>` | corre una medición del `BENCHMARKS.md` y deja el crudo en `bench/` | F04 |
| `task inc:break -- <ID>` / `inc:fix -- <ID>` | lleva el laboratorio al estado roto de un incidente, o lo repara | F08 |

---

## 8. 🏷️ Git

- **Tags de fase:** `fase-NN-<slug>`, anotados, con el checklist de cierre en el mensaje.
- **Commits:** `fNN: …`; los de ejercicio, `fNN ejMM: …`.
- **Incidentes:** el par `inc/<ID>/<slug>-roto` e `inc/<ID>/<slug>-fix`, con el ID que el cuaderno ya
  tiene reservado y nunca uno inventado. El `git diff` entre los dos **es** la corrección, aislada
  del ruido de la fase.
- **Apéndices:** sin tag, salvo `a01`, `a03` y `a16`, que dejan archivos versionados
  (`apendice-a01-laboratorio`, `apendice-a03-contratos`, `apendice-a16-patrimonio`).

---

## 9. 📌 Pendientes de este documento

- ✅ Controlador de Gateway API: **Envoy Gateway** (D12). La verificación mide su memoria en reposo
  y su conformidad con la versión de Gateway API fijada.
- ⏳ Cómo llega el puerto del host al `Gateway` en las tres plataformas y con los dos motores.
- ⏳ Si kindnet aplica `NetworkPolicy` en la versión fijada de kind; si no, qué CNI se instala en el
  perfil de la Fase 20.
- ⏳ Presupuesto de memoria por pieza y por perfil, **incluido el perfil `legacy`** del patrimonio.
- ✅ **La empresa no toca este contrato**: los identificadores son funcionales a propósito. El
  nombre visible —"Droguerías La Vecina" en el `storefront`, y la marca de la segunda cadena en
  `apps-b`— va en los valores de configuración, nunca en un identificador.

Los tres ⏳ que quedan se cierran **solo ejecutando**, en la verificación de laboratorio (P11), y se
trasladan aquí en P12. Ninguno cambia un nombre de este contrato: cambian valores.
