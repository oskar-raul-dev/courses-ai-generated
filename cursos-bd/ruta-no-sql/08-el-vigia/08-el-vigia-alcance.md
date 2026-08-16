# 🗺️ El Vigía — Alcance del proyecto

> Deriva de `08-el-vigia-semilla.md`. Ante cualquier conflicto, la semilla
> manda; este documento es su lectura en clave de "qué se construye, qué no,
> y contra qué mercado real se mide".

---

## 1. Qué construye el curso

El Vigía es un **sistema de monitoreo de métricas de infraestructura**
construido y medido tres veces: contra InfluxDB 3 Core (motor de series
dedicado), contra TimescaleDB (extensión temporal de PostgreSQL) y contra las
colecciones Time Series nativas de MongoDB. Al terminar el curso, lo que
existe en el repositorio es:

- Un **laboratorio contenerizado** (`docker-compose.yml`) con los tres
  motores arriba de un comando, más un generador de telemetría en
  TypeScript/Node que produce el **mismo dataset semántico** (misma flota,
  misma cadencia, misma cardinalidad) en las tres formas de entrada: line
  protocol, SQL sobre hypertables, y documentos Time Series de Mongo.
- Un **villano construido de verdad**: la tabla `metrics` genérica en
  Postgres, cargada hasta que duele, con su índice B-tree que engorda sin
  techo — para sentir el problema antes de resolverlo, no para leerlo en
  abstracto.
- **Los tres pilares del modelo, implementados y medidos** en los tres
  motores: partición temporal nativa, compresión columnar por cercanía
  temporal, y retención escalonada con downsampling automático.
- El **diseño de cardinalidad** como disciplina explícita: qué tags entran a
  la serie, cuáles explotan la cardinalidad, y cómo se detecta antes de que
  tumbe un motor en producción.
- El **contraste Mongo**: bucket pattern manual construido a mano vs.
  colección Time Series nativa, midiendo qué compra el soporte de primera
  clase frente a la artesanía.
- Una **API de tablero** (Node/TS) que sirve los tres regímenes de consulta
  del dominio —reciente a resolución completa, histórico agregado,
  ventana-contra-ventana— contra cada uno de los tres motores, con Grafana
  como capa de visualización **opcional**, no como parte del núcleo.
- El **arnés `scripts/vs.ts`**, que corre la misma consulta semántica contra
  los motores en juego, cronometra percentiles (no promedios), mide tamaño en
  disco tras compresión, y alimenta `BENCHMARKS.md`. Ningún "X es mejor que Y"
  entra al curso sin pasar por acá.
- `INSTINTOS.md` y `BENCHMARKS.md`, acumulativos fase a fase, como evidencia
  que sostiene el veredicto final.
- El **veredicto de la Fase 11**: cuándo cada uno de los tres motores gana,
  y —el crimen inverso— cuándo ninguno de los tres debía usarse porque el
  dato no era realmente una serie temporal.

El entregable pedagógico no es "aprende InfluxDB" ni "aprende TimescaleDB":
es el **criterio** para reconocer un patrón de acceso temporal, elegir entre
las tres respuestas serias que el mercado ofrece hoy, y saber cuándo ninguna
de las tres aplica.

---

## 2. Qué queda fuera por ahora

El curso fija una frontera clara para no diluir el modelo con problemas que
pertenecen a otra capa del sistema. Fuera del alcance de las doce fases:

- **Alerting y motor de reglas.** No se construye un Alertmanager ni un
  motor de evaluación de umbrales o anomalías. El dominio de monitoreo lo
  pide naturalmente, pero es un problema de *reglas y notificación*, no de
  *almacenamiento y consulta por tiempo* — el eje del curso. Puede
  mencionarse como extensión 🔥 opcional, nunca como fase propia.
- **Detección de anomalías y machine learning sobre series.** Forecasting,
  detección estadística de outliers, modelos entrenados sobre la telemetría:
  fuera de alcance. Es un curso de acceso a datos, no de analítica avanzada.
- **Alta disponibilidad y clustering productivo.** InfluxDB 3 Core es
  mono-nodo por diseño en su edición open source; TimescaleDB y MongoDB
  podrían montarse en réplica, pero el curso no enseña a *operar* un clúster
  de producción (failover, particionado entre nodos, backups distribuidos).
  El laboratorio es de un nodo por motor, deliberadamente.
- **Seguridad y multi-tenancy completos.** Auth, TLS, aislamiento por
  tenant y políticas de acceso granular no son el foco. El laboratorio corre
  en modo desarrollo, sin credenciales productivas. Puede señalarse como
  💸 deuda técnica intencional donde corresponda, no como fase a resolver.
- **Protocolos de ingesta más allá de los tres del dataset semántico.**
  No se cubren Prometheus remote-write, el colector de OpenTelemetry, Kafka
  como buffer de ingesta, ni conectores de terceros. El generador propio
  basta para exhibir el patrón de acceso sin acoplar el curso a todo un
  ecosistema de integración.
- **Grafana como núcleo del curso.** Aparece como capa de visualización
  opcional sobre la API de tablero (Fase 10), nunca como objeto de
  aprendizaje en sí mismo. El curso enseña el modelo de acceso, no una
  herramienta de tableros concreta.
- **Escalado horizontal del generador más allá de lo que corre en un
  portátil de desarrollo.** El volumen objetivo (cardinalidad y cadencia) se
  fija para que el villano duela sin necesitar infraestructura de nube; no
  se enseña a escalar el generador a millones de series por segundo.
- **Motores adicionales fuera del triángulo fijado.** No entran QuestDB,
  ClickHouse, Prometheus/VictoriaMetrics ni TDengine como motores del curso
  base. Pueden mencionarse en una nota comparativa de la Fase 11, nunca con
  fase o dataset propios — eso sería otro curso.

---

## 3. Contra qué mercado real se valida (productizable)

**Veredicto explícito: ⚠️ débil como SaaS horizontal.** El monitoreo de
infraestructura genérico es un mercado saturado por jugadores con años de
inversión —Grafana, Datadog, Prometheus, la propia InfluxData—. Competir de
frente ahí con lo que produce este curso no es una tesis de negocio seria, y
el curso lo dice sin adornos: el entregable no es "monta tu propio Datadog".

Donde el modelo **sí** produce valor defendible es como **componente dentro
de un producto vertical más grande**, en dominios donde las herramientas
horizontales no encajan bien de fábrica:

- Telemetría de un tipo específico de maquinaria industrial o IoT
  especializado, con formas de dato y umbrales propios del dominio.
- Métricas de un sector regulado con requisitos de retención particulares
  (por ejemplo, registros que deben conservarse íntegros N años y agregados
  después, por norma).
- Observabilidad de un stack o proceso de negocio muy específico, donde el
  valor está en la integración con el resto del sistema, no en competir como
  motor de métricas genérico.

La lección productizable que el curso deja no es "el motor es el producto",
sino **"saber elegir e integrar bien el motor temporal correcto es lo que se
monetiza dentro de un sistema mayor"**. El criterio de elección —y de
descarte— es el entregable; el motor es solo un medio.

---

## 4. Árbol de decisión: cuándo NO usar esta familia

El villano de El Vigía tiene dos caras y el curso las nombra a ambas. Este
árbol resume el criterio que la Fase 11 cierra con números medidos.

```
¿El dato nace con un timestamp y casi nunca se actualiza después de escrito?
│
├─ NO → el dato se actualiza, se corrige, se referencia por id de negocio.
│       No es una serie temporal aunque tenga un campo `created_at`.
│       Ejemplo: una tabla de pedidos. → usa el modelo relacional
│       (o documental/clave-valor según su propio patrón). Montar un motor
│       temporal acá es el villano en su cara inversa.
│
└─ SÍ → sigue.
   │
   ¿La consulta dominante es por rango de tiempo y/o agregación por ventana,
   más que "una fila por su identidad"?
   │
   ├─ NO → se consulta sobre todo por entidad (por cliente, por producto),
   │       el tiempo es un filtro secundario. → el motor generalista
   │       (relacional o documental) ya resuelve esto; no fuerces el eje
   │       temporal donde el eje real es otro.
   │
   └─ SÍ → sigue.
      │
      ¿El volumen y la cadencia son suficientes para que la partición,
      la compresión y la retención automática paguen su complejidad
      operativa? (una tabla de cincuenta mil filas nunca va a doler)
      │
      ├─ NO → el villano "tabla genérica con índice en timestamp" alcanza
      │       de sobra a esa escala. No sumes una superficie operativa
      │       nueva por una molestia que todavía no existe.
      │
      └─ SÍ → el patrón de acceso es genuinamente temporal. Ahora decide
              *cuál* de los tres, no *si*:
              │
              ├─ ¿Ya operas Postgres y el equipo no quiere sumar un motor
              │  nuevo a la guardia de las 3 am? → TimescaleDB primero
              │  (mismo `psql`, mismos backups, extensión sobre lo conocido).
              │
              ├─ ¿Ya vives en MongoDB y el volumen de series es moderado?
              │  → colecciones Time Series nativas de Mongo; no dupliques
              │  motor si el generalista que ya tienes alcanza.
              │
              └─ ¿El volumen, la cadencia o la necesidad de compresión
                 extrema superan lo que un generalista extendido rinde
                 con comodidad? → InfluxDB 3 Core (u otro motor dedicado),
                 justificado con el arnés `vs.ts`, no con preferencia.
```

**La frase que resume la Fase 11:** el motor temporal es casi siempre
correcto como *componente*, casi nunca correcto como *reflejo automático*
ante cualquier campo `timestamp`. El criterio —no el motor— es lo que el
curso entrega.
