# 🗺️ Centinela de Flota — Alcance del proyecto

> Deriva de `05-centinela-de-flota-semilla.md` y de las instrucciones de la
> Ruta NoSQL. Si algo contradice a la semilla, gana la semilla.

## 🎯 Qué construye el curso

Centinela de Flota es un **sistema de ingesta de telemetría de alto caudal**
con roll-ups progresivos. Al terminar el curso, el estudiante tiene, corriendo
en su propia máquina:

- Un **clúster Cassandra multi-nodo** (3 nodos, vía Compose) modelado con el
  patrón *tabla por consulta*: `readings_by_device`, `readings_by_region`,
  `readings_by_metric_threshold`.
- Una **familia de tablas de roll-up** (`rollup_per_minute`, `rollup_per_hour`,
  `rollup_per_day`) alimentadas en el propio camino de ingesta, no calculadas
  en tiempo de lectura.
- Un **generador de telemetría sintética** que produce el mismo dataset
  semántico (dispositivos, regiones, métricas con deriva temporal) en tres
  motores a la vez: Cassandra, ScyllaDB y PostgreSQL.
- Un **arnés de benchmark propio** (`scripts/vs.ts`) que cronometra la misma
  consulta semántica contra los tres motores y acumula resultados en
  `BENCHMARKS.md` — ninguna afirmación comparativa del curso existe sin pasar
  por ahí primero.
- Un **nodo ScyllaDB** corriendo la misma carga, para medir wide-column contra
  wide-column y no solo wide-column contra relacional.
- La **autopsia medida del villano**: un CRUD de catálogo de dispositivos de
  bajo volumen montado sobre Cassandra a propósito, con su migración de vuelta
  a Postgres y los números antes/después lado a lado.
- `INSTINTOS.md` y `BENCHMARKS.md` acumulativos, más un diccionario de
  traducción relacional → wide-column.

El eje pedagógico no es "aprender CQL": es aprender a **reconocer el régimen
de escritura** en el que la coordinación central de un motor relacional deja
de ser viable, y a diseñar tablas por patrón de consulta en vez de por
entidad normalizada — con el costo operativo de esa elección nombrado sin
rodeos.

## 🚫 Qué queda fuera por ahora

- **Multi-tenancy real ni facturación por cliente.** El proyecto simula una
  flota, no un SaaS de observabilidad vendible tal cual (ver más abajo,
  productizabilidad condicional).
- **Machine learning sobre la telemetría** (detección de anomalías, modelos
  predictivos de falla). El curso enseña el modelo de acceso, no analítica
  avanzada; puede quedar como semilla para un curso 🔥 futuro, no para este.
- **Bigtable operado.** Se estudia como diseño conceptual (paper de Google,
  arquitectura de filas ordenadas y tablet splitting) sin levantar cuenta
  cloud ni atar el curso a un proveedor — decisión ya fijada en la semilla.
- **Interfaz de usuario final (dashboard visual).** El curso expone una API
  de consulta y el arnés `vs.ts`; no construye un frontend de gráficas. Si el
  estudiante quiere visualizar, es una extensión 🔥 fuera del alcance base.
- **Seguridad y autenticación de producción** (mTLS entre nodos, RBAC fino,
  rotación de credenciales). Se nombra como deuda operativa real pero no se
  implementa: el foco es el modelo de datos y el régimen de escritura, no el
  hardening del clúster.
- **Migraciones de esquema en caliente entre versiones mayores de Cassandra.**
  El curso fija una versión (5.0.x) y no cubre el camino de upgrade entre
  majors.
- **Compatibilidad con drivers de otros lenguajes** (Python, Java, Go). Todo
  el arnés y la API de consulta son TypeScript/Node; se menciona la existencia
  de otros drivers solo en un aparte, sin profundizar.

## 🏪 Contra qué mercado real se valida (productizable)

**Veredicto: productizable ⚠️ condicional — necesita un vertical propio.**

El *criterio* que enseña el curso (diseñar por consulta, medir el punto donde
un nodo relacional se ahoga, operar un clúster distribuido con su costo
visible) es directamente transferible a cualquier plataforma que ingiera
eventos a escala: IoT industrial, telemetría de flotas de vehículos
comerciales, medición energética distribuida, mensajería de alto volumen. Eso
es mercado real y grande.

Lo que **no** es directamente vendible tal cual es "un genérico ingestor de
telemetría": el mercado de observabilidad e IoT lo ocupan incumbentes fuertes
(Datadog, AWS IoT, Azure IoT Hub, TimescaleDB-as-a-service, InfluxDB Cloud) con
años de integraciones, alertas y dashboards ya resueltos. Centinela de Flota
se vuelve un producto defendible únicamente cuando se ancla a un **vertical
concreto** con jerga y umbrales propios — por ejemplo telemetría de
mantenimiento predictivo de maquinaria pesada, o monitoreo energético de una
red de cargadores — donde el conocimiento del dominio, no el motor, es el
diferenciador.

El curso nombra esto explícitamente como una **decisión de negocio a tomar
después**, no como una promesa de "monta esto y tienes un SaaS". Esa
honestidad sobre el techo comercial es parte del criterio que se enseña:
distinguir infraestructura interna valiosa de producto vendible es un juicio
aparte del juicio técnico de modelado.

## 🌳 Árbol de decisión: cuándo NO usar wide-column

Este árbol es el que el curso deja instalado como instinto recalibrado, y es
el mismo que cierra la Fase 11 con números de la autopsia del villano.

```
¿El caudal de escritura desborda lo que UN nodo relacional bien
dimensionado puede arbitrar de forma sostenida?
│
├── NO → ¿Hay relaciones ricas (muchos-a-muchos, invariantes que cruzan
│        entidades) o necesitas consulta ad-hoc que no puedes anticipar?
│        │
│        ├── SÍ → NO uses wide-column. Usa relacional. El "escala"
│        │        de Cassandra no compensa renunciar a JOINs y a la
│        │        integridad referencial si nunca vas a necesitar el
│        │        volumen que la justifica. (Este es exactamente el
│        │        villano del curso: el catálogo de bajo volumen
│        │        montado sobre Cassandra.)
│        │
│        └── NO → Zona gris: probablemente relacional también, hasta
│                 que el caudal lo desmienta con números — no antes.
│
└── SÍ → ¿Los patrones de consulta son conocidos y estables de
         antemano (un puñado fijo de "dame X por Y"), y puedes
         tolerar duplicar datos entre tablas para no unir en
         caliente?
         │
         ├── SÍ → ¿Puedes vivir con consistencia eventual y
         │        disponibilidad por encima de consistencia
         │        inmediata en la mayoría de las lecturas?
         │        │
         │        ├── SÍ → **Wide-column vota.** Diseña una tabla
         │        │        por consulta, dimensiona la partition
         │        │        key para que no queden particiones
         │        │        calientes ni ilimitadas, y mide el
         │        │        cruce contra tu control relacional
         │        │        antes de comprometerte en producción.
         │        │
         │        └── NO (necesitas ACID multi-fila fuerte y
         │             consistente) → Reconsidera: quizás el
         │             volumen exige sharding relacional o un
         │             motor distribuido con transacciones (fuera
         │             de este curso), no wide-column puro.
         │
         └── NO (las consultas cambian seguido, quieres explorar
              ad-hoc) → NO uses wide-column todavía. El costo de
              rediseñar tablas por cada nueva pregunta suele superar
              el beneficio del volumen. Considera un motor documental
              o relacional con buenos índices mientras el patrón de
              acceso madura, y revisita wide-column cuando el patrón
              se estabilice Y el caudal lo exija.
```

**La frontera se mide, no se asume.** El propio curso enseña, en la Fase 1 y
de nuevo en la Fase 6, que a bajo volumen Postgres gana sin discusión: la
pregunta correcta nunca es "¿wide-column es mejor?" sino "¿en qué régimen de
escritura, medido con el mismo reloj, deja de serlo la alternativa relacional?".
