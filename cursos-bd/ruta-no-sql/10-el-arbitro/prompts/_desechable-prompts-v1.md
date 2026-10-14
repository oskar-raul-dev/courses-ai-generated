# 🧰 El Árbitro — Prompts reutilizables

> Cada prompt de este documento es **autónomo**: incluye el contexto mínimo
> necesario para correr en una conversación nueva sin depender del proyecto
> de la Fábrica de arranque. Copia el prompt completo, pégalo en un chat
> nuevo (idealmente con `EL-ARBITRO-SEMILLA.md`, `EL-ARBITRO-ALCANCE.md` y
> `EL-ARBITRO-GUIA-ESTILO.md` adjuntos como archivos de proyecto), y ajusta
> solo lo marcado entre `{{ así }}`.

---

## 0. Prompt de arranque — Fase 0

```
Vas a redactar la Fase 0 del curso "El Árbitro" (curso 10 de cierre de la
Ruta NoSQL), un curso de persistencia políglota que NO enseña un modelo
nuevo sino la factura de combinar varios motores.

CONTEXTO DEL CURSO (autónomo, no asumas nada más)

Dominio: Ágora, una plataforma de venta de entradas para eventos en vivo
(conciertos, teatro, deporte amateur, conferencias, ferias). Organizadores
publican eventos, el público busca y compra, la gente entra por una puerta
donde alguien escanea un código, y a fin de mes se liquida dinero real a
cada organizador con un detalle que resiste una auditoría.

Ágora tiene siete patrones de acceso genuinamente distintos que conviven en
el mismo sistema:
1. Ficha de evento — agregado autocontenido, heterogéneo por tipo de evento.
2. Aforo y reserva temporal — contador y llave con expiración.
3. Búsqueda y facetas — índice invertido con conteos por filtro.
4. Ledger y liquidación — asientos contables inmutables, invariantes duras.
5. Analítica — columnas largas, pocas por consulta, sobre 18 meses de datos.
6. Telemetría de puerta — append-only con eje temporal.
7. Afinidad entre asistentes — co-ocurrencia de profundidad 2 (spoiler: no
   duele lo suficiente para justificar un motor propio — es parte de la
   lección).

El curso construye un backend en TypeScript sobre Node, contenerizado de
punta a punta, con UNA fuente de verdad transaccional (PostgreSQL) y varios
almacenes derivados alimentados por una costura explícita: outbox → captura
de cambios (Debezium sobre el WAL) → Redpanda → consumidores idempotentes.
Los derivados NUNCA se escriben directo desde el código de negocio
(dual-write); todo cambio sale de la fuente de verdad por la costura.

Stack fijado (2026, verificar versión exacta al momento de escribir):
PostgreSQL 18.x (fuente de verdad), MongoDB 8.0.x (catálogo documental
derivado), Valkey 9.1.x (reservas con expiración, aforo caliente, rate
limit), Meilisearch 1.48.x (búsqueda facetada derivada), DuckDB 1.5.x
(analítica embebida sobre Parquet), Debezium 3.6.x, Redpanda (última
estable), Node.js 24 LTS, TypeScript (última 5.x), Fastify 5.x, Zod,
Prometheus + Grafana, OpenTelemetry SDK Node, k6, Testcontainers, Podman o
Docker + Compose.

El arnés de medición `scripts/vs.ts` nace en esta fase y NUNCA se toca la
lógica de negocio para alimentarlo. Recibe un escenario semántico (no en el
lenguaje de un motor) y una lista de implementaciones; las ejecuta con
calentado previo, bajo la misma carga de k6, y registra p50/p95/p99, CPU y
memoria del contenedor en `BENCHMARKS.md`, siempre con fecha, versión de
cada motor y descripción de la máquina.

GUÍA DE ESTILO (resumen operativo — respétala en todo lo que escribas)

- Código en inglés (identificadores, endpoints, colecciones/tablas, campos,
  eventos de costura en formato `recurso.acción` pasado: `order.created`);
  todo lo demás en español, SIN VOSEO ("tú", nunca "vos").
- Tono cálido, informal, de colega senior a colega senior, humor moderado y
  bajo en las zonas de dinero (ledger) y pérdida de datos (restore).
- Prosa antes que listas; tablas solo para comparar/decidir/mapear.
- Plantilla obligatoria de 9 secciones (ver abajo).
- 20-40 ejercicios graduados 🟢🟡🟠🔴 (objetivo 30), numeración continua por
  rangos, al menos 5 de diagnóstico, sin voseo, siempre anclados a Ágora.
- Diccionario del dominio: event/session, venue, seat, hold, order, payment,
  payout, organizer, attendee, scan, capacity.
- Todo "vs" se produce con `scripts/vs.ts`, nunca se narra.
- Cierra SIEMPRE con sección `## 📚 Referencias` (URL completa, nota de
  versión, advertencia de verificación). Nunca inventes DOIs, números de
  página ni IDs de video.

PLANTILLA DE FASE (9 SECCIONES, EN ESTE ORDEN)

1. 🎯 Propósito
2. ✅ Qué queda listo al terminar
3. 🚫 Qué queda fuera por ahora
4. 🧠 Conceptos mínimos (incluye 🪞/🩻/📖 si aplican)
5. 💻 Implementación y código comentado (incluye medición con vs.ts)
6. ⚠️ Errores comunes y pieza forense
7. 🧪 Ejercicios progresivos (20-40, graduados)
8. 📚 Referencias
9. 🚀 Cierre y conexión con la siguiente fase (incluye "la señal de que
   quedó bien")

TU TAREA — FASE 0: "🧪 El laboratorio y su factura de arranque"

Escribe el `.md` completo de la Fase 0 con:

- El `compose.yaml` completo (o su núcleo comentado si es muy largo) con
  Postgres, MongoDB, Valkey, Meilisearch, Redpanda y la pila de
  observabilidad (Prometheus + Grafana), con volúmenes nombrados y
  healthchecks reales — no solo `depends_on`.
- El diseño del generador de datos sintéticos de Ágora: organizadores,
  recintos, eventos de al menos cuatro tipos con atributos distintos,
  funciones, inventario de asientos, y un histórico de pedidos con
  estacionalidad creíble (las ventas de un show explotan en los primeros
  diez minutos, no son uniformes).
- El primer escenario de `scripts/vs.ts`, deliberadamente trivial (por
  ejemplo, medir el tiempo de arranque en frío y la RAM de cada
  configuración de Compose), y la primera entrada real de `BENCHMARKS.md`.
- El primer recuadro 🩻 "esto sí viaja igual": el instinto de DBA sobre
  memoria, disco y conexiones vale lo mismo en los cinco motores.
- El "vs" de la fase: costo de arranque (tiempo, RAM y disco) por
  configuración de Compose (perfil `min` vs `base` vs `full`).

No asumas ninguna fase posterior escrita todavía; deja los ganchos hacia la
Fase 1 (inventario de patrones) en el cierre.
```

---

## 1. Prompt-plantilla por fase (Fases 1 a 12)

Usa este prompt para cualquier fase del cuerpo del curso, reemplazando los
campos entre `{{ }}`. La tabla de referencia rápida está al final de este
documento (§3) para copiar el contenido de cada fase sin tener que abrir la
semilla completa.

```
Vas a redactar la Fase {{N}} del curso "El Árbitro" (curso 10 de cierre de
la Ruta NoSQL, persistencia políglota). Este prompt es autónomo.

CONTEXTO MÍNIMO DEL CURSO

Dominio: Ágora, plataforma de venta de entradas para eventos en vivo, con
siete patrones de acceso heterogéneos conviviendo (ficha de evento, aforo y
reserva temporal, búsqueda facetada, ledger y liquidación, analítica,
telemetría de puerta, afinidad entre asistentes). Backend TypeScript/Node,
contenerizado, con UNA fuente de verdad transaccional (PostgreSQL) y
derivados alimentados por costura explícita (outbox → CDC con Debezium →
Redpanda → consumidores idempotentes). Nunca dual-write.

Stack: PostgreSQL 18.x, MongoDB 8.0.x, Valkey 9.1.x, Meilisearch 1.48.x,
DuckDB 1.5.x, Debezium 3.6.x, Redpanda, Node 24 LTS, TypeScript, Fastify 5,
Zod, Prometheus + Grafana, OpenTelemetry, k6, Testcontainers, Podman/Docker
Compose. Diccionario del dominio: event/session, venue, seat, hold, order,
payment, payout, organizer, attendee, scan, capacity.

El arnés `scripts/vs.ts` (nacido en la Fase 0) mide cada "vs" del curso:
escenario semántico + lista de implementaciones, ejecutadas bajo carga de
k6, resultado a `BENCHMARKS.md` con fecha, versión y máquina. Ningún "vs"
se narra, todos se miden.

Artefactos acumulativos que esta fase debe actualizar si corresponde:
- `INSTINTOS.md`: predicción (firmada, antes de medir) → procedimiento →
  veredicto (sobrevivió / sobrevivió con matices / murió).
- `BENCHMARKS.md`: toda medición de `vs.ts`.
- `FACTURA.md`: una ficha por motor (imagen/versión, backup, restore
  cronometrado, modos de fallo, observabilidad, runbook, consistencia,
  aprendizaje), llenada en la fase donde ese motor entra al sistema.

GUÍA DE ESTILO (resumen operativo)

Código en inglés, todo lo demás en español SIN VOSEO. Tono cálido, informal,
de colega senior a colega senior, humor moderado (bajo en dinero/pérdida de
datos). Prosa antes que listas; tablas solo para comparar/decidir/mapear.
20-40 ejercicios graduados 🟢🟡🟠🔴 (objetivo 30), numeración continua por
rango, mínimo 5 de diagnóstico. Cierra siempre con `## 📚 Referencias` (URL
completa, nota de versión, advertencia de verificación — nunca inventes
DOIs, páginas ni IDs de video).

PLANTILLA DE FASE (9 SECCIONES, EN ESTE ORDEN)

1. 🎯 Propósito
2. ✅ Qué queda listo al terminar
3. 🚫 Qué queda fuera por ahora
4. 🧠 Conceptos mínimos (recuadros 🪞/🩻/📖 cuando aportan; el marco de 5
   preguntas aplicado al patrón de esta fase si es la primera vez que
   aparece ese patrón)
5. 💻 Implementación y código comentado (SIEMPRE incluye la medición con
   `scripts/vs.ts` del "vs" de esta fase contra su alternativa sin el motor
   nuevo o sin la técnica nueva)
6. ⚠️ Errores comunes y pieza forense
7. 🧪 Ejercicios progresivos (20-40, graduados, ≥5 de diagnóstico)
8. 📚 Referencias
9. 🚀 Cierre y conexión con la siguiente fase (incluye "la señal de que
   quedó bien"; si esta fase sumó un motor, incluye la ficha de factura
   recién llenada)

TU TAREA — FASE {{N}}: "{{TÍTULO DE LA FASE}}"

Núcleo de la fase: {{NÚCLEO — copiar de la tabla de fases, §3 de este
documento}}

"Vs" de la fase: {{VS DE LA FASE — copiar de la tabla de fases, §3}}

Contenido específico a cubrir: {{pegar aquí el párrafo descriptivo de esa
fase desde EL-ARBITRO-SEMILLA.md, sección "Estructura de fases"}}

No contradigas ninguna fase anterior ya escrita {{si hay fases previas,
adjúntalas o pega sus decisiones clave de nombres de código, esquema de
eventos y resultados de BENCHMARKS.md que esta fase deba respetar}}.
```

---

## 2. Prompts para artefactos transversales

### 2.1 `INSTINTOS.md` — inicialización

```
Vas a crear el archivo acumulativo `INSTINTOS.md` para el curso "El
Árbitro" (curso 10, persistencia políglota, Ruta NoSQL). Este prompt es
autónomo.

Contexto: el curso enseña cuándo sumar un motor de datos a un sistema que
ya tiene otros, usando como dominio Ágora, una plataforma de venta de
entradas para eventos en vivo. `INSTINTOS.md` registra cada instinto del
lector (mayormente instintos operativos y de arquitectura, no de sintaxis)
que el curso somete a prueba con el arnés `scripts/vs.ts`.

Cada entrada de `INSTINTOS.md` tiene tres tiempos que nunca se colapsan:

1. **Predicción** — escrita ANTES de medir, con fecha y quién la hizo (el
   lector, en primera persona, o "predicción típica de la industria" si el
   curso la aporta como punto de partida).
2. **Procedimiento** — el escenario exacto del arnés y las condiciones
   (motor, versión, carga de k6, máquina).
3. **Veredicto** — el número, y una frase que declare si el instinto
   sobrevivió, sobrevivió con matices, o murió.

Los instintos de este curso son mayormente sobre COSTO, no sobre sintaxis:
"cuántos motores hacen falta para un sistema de este tamaño", "cuánto tarda
un restore coherente entre dos almacenes", "cuántos modos de fallo nuevos
aparece al sumar el cuarto motor", "si la latencia percibida por el usuario
mejora al pasar de tres a seis motores".

Formato en español, sin voseo, tono cálido e informal. Crea el archivo con:
- Un encabezado explicando el propósito y las tres columnas fijas.
- Una tabla o lista de entradas con al menos los dos instintos ya conocidos
  de la semilla del curso: (a) "Ágora necesita al menos cuatro motores"
  (predicción típica anotada en la Fase 1, a revisar en la Fase 12), y (b)
  el instinto sobre si la latencia mejora sustancialmente al pasar de tres
  a seis motores en la Fase 11 (déjalo con procedimiento y veredicto en
  blanco, listo para completarse cuando se redacte esa fase).
- Deja el resto de la tabla vacía pero con la estructura de columnas fija,
  para que cada fase futura agregue sus propias filas sin cambiar el
  formato.
```

### 2.2 `BENCHMARKS.md` — inicialización

```
Vas a crear el archivo acumulativo `BENCHMARKS.md` para el curso "El
Árbitro" (curso 10, persistencia políglota, Ruta NoSQL). Este prompt es
autónomo.

Contexto: todo "vs" del curso se produce con `scripts/vs.ts`, un arnés que
recibe un escenario semántico (una operación descrita sin lenguaje de un
motor específico) y una lista de implementaciones, las ejecuta con
calentado previo y repeticiones suficientes bajo la misma carga concurrente
de k6, y mide p50, p95, p99, CPU y memoria del contenedor. Un número entra a
`BENCHMARKS.md` solo si trae fecha, versión de cada motor implicado y
descripción de la máquina donde corrió — sin esas tres etiquetas, no entra.

Además de latencia, el arnés de este curso mide, cuando el escenario lo
pide: lag de convergencia (percentil 99, bajo carga), tiempo de restore
coherente (del sistema completo, no de un motor aislado), superficie de
fallo (modos de fallo distintos documentados) y costo operativo semanal
(minutos-persona, con método declarado y aplicado igual a todas las
arquitecturas comparadas).

Crea `BENCHMARKS.md` con:
- Un encabezado que explique el propósito, el método (`scripts/vs.ts`) y
  las columnas obligatorias de cada entrada: fecha, escenario, motores y
  versiones comparados, máquina, métrica(s) medida(s), resultado, y una
  nota si el resultado contradice la expectativa declarada en
  `INSTINTOS.md`.
- Una plantilla de entrada en Markdown lista para copiar en cada fase
  futura.
- Las cinco entradas de cabecera que el curso ya anticipa como "los duelos
  que atraviesan el curso" (déjalas con resultado pendiente, listas para
  completarse fase a fase): (1) monolito Postgres vs políglota, patrón por
  patrón; (2) tres motores vs seis motores (Fase 11); (3) dual-write vs
  outbox vs CDC; (4) reserva con expiración: Valkey vs SKIP LOCKED en
  Postgres (Fase 5); (5) analítica: DuckDB sobre Parquet vs consulta
  directa contra producción (Fase 9).

Español, sin voseo, tono técnico y directo (esta es la sección más "seca"
del curso a propósito: son datos, no narrativa).
```

### 2.3 Diccionario de traducción de lenguajes de consulta (Apéndice C)

```
Vas a redactar el Apéndice C del curso "El Árbitro" (curso 10, persistencia
políglota, Ruta NoSQL): el diccionario de traducción de lenguajes de
consulta. Este prompt es autónomo.

A diferencia de otros cursos de la ruta, que traducen entre DOS paradigmas
(por ejemplo SQL ↔ MQL), este apéndice traduce la MISMA pregunta semántica
a CINCO lenguajes de consulta a la vez, porque Ágora sostiene cinco motores
simultáneos: SQL (PostgreSQL 18.x, fuente de verdad), MQL (MongoDB 8.0.x,
catálogo derivado), comandos de Valkey 9.1.x (reservas y aforo), la API de
Meilisearch 1.48.x (búsqueda facetada), y SQL analítico de DuckDB 1.5.x
sobre Parquet.

Formato: una tabla por pregunta semántica, con una fila por lenguaje,
lado a lado, para consultar en caliente durante el resto del curso. No es
prosa explicativa larga: es material de referencia rápida.

Preguntas semánticas mínimas a cubrir (usa el vocabulario del dominio:
event, venue, seat, hold, order, payment, payout, organizer, attendee,
scan, capacity):

1. "Dame la ficha completa de este evento" (SQL con JOIN vs Postgres JSONB
   vs `db.events.findOne` de Mongo — nota: esta pregunta no aplica
   naturalmente a Valkey/Meilisearch/DuckDB; indícalo así en la tabla, sin
   forzar una fila vacía sin explicación).
2. "¿Cuántos asientos libres quedan en esta función?" (contador en Valkey
   vs `COUNT` con lock en Postgres).
3. "Reserva este asiento por 10 minutos" (comando de Valkey con TTL vs
   `SELECT ... FOR UPDATE SKIP LOCKED` con columna de expiración en
   Postgres).
4. "Conciertos en Bogotá, este sábado, menos de 200 mil, con filtro de
   género" (query de Meilisearch con facetas vs `tsvector` + `pg_trgm` en
   Postgres).
5. "¿Cuánto le debemos a este organizador y por qué?" (SQL sobre el ledger
   — este patrón vive SOLO en Postgres; indícalo explícitamente como
   ejemplo de patrón que no vota motor derivado).
6. "Conversión por canal y ciudad, últimos 18 meses" (SQL analítico de
   DuckDB sobre Parquet exportado vs la misma consulta contra Postgres
   transaccional, mostrando por qué la segunda es la versión que el curso
   desaconseja).

Español para las explicaciones breves alrededor de cada tabla (sin voseo);
código de cada consulta en su sintaxis nativa, con nombres de campo en
inglés según el diccionario del dominio. Cierra con una nota ⚠️ aclarando
que las versiones exactas de sintaxis deben verificarse contra la
documentación oficial de cada motor al momento de publicar.
```

---

## 3. Tabla de referencia rápida de fases

Para copiar el "núcleo" y el "vs" de cada fase directamente en el prompt-
plantilla (§1) sin tener que abrir `EL-ARBITRO-SEMILLA.md` completo.

| # | Fase | Núcleo | "Vs" de la fase |
|---|---|---|---|
| 0 | 🧪 El laboratorio y su factura de arranque | Compose con los cinco motores, generador de datos, nace `vs.ts` | Costo de arranque: tiempo, RAM y disco por configuración |
| 1 | 🗺️ Inventario de patrones de acceso | Las 5 preguntas aplicadas a los siete patrones de Ágora | — (marco, sin medición) |
| 2 | 🧾 La línea base: todo en un solo motor | Ágora completa en Postgres, honestamente bien hecha | Monolito contra sí mismo: dónde empieza a doler |
| 3 | 🔒 La fuente de verdad y el ledger | Invariantes, transacciones, tabla `outbox` | Invariante en la base vs en la aplicación |
| 4 | 🍃 El catálogo se va a un motor documental | Ficha heterogénea en Mongo, derivada de Postgres | Mongo vs JSONB, lectura y evolución de forma |
| 5 | 🔑 Aforo y reservas con expiración | Reserva temporal, anti-sobreventa, contadores calientes | Valkey TTL vs `SKIP LOCKED` con durabilidad declarada |
| 6 | 🔍 Búsqueda facetada como índice derivado | Meilisearch alimentado por la costura | Meilisearch vs `tsvector` + `pg_trgm` |
| 7 | 🔄 La costura: outbox y captura de cambios | Debezium sobre el WAL, Redpanda, consumidores idempotentes | Dual-write vs outbox vs CDC |
| 8 | 🧯 Divergencia, reconciliación y el botón rojo | Detectar que un derivado miente y reconstruirlo | Reconciliación periódica vs reindexado total |
| 9 | 🦆 Analítica sin tocar producción | Exportación a Parquet, DuckDB, panel | DuckDB aparte vs consulta analítica contra la OLTP |
| 10 | 💾 Backups, restore y el ensayo del desastre | Restore cronometrado por motor y coherente entre motores | Restore aislado vs restore coordinado |
| 11 | ⚰️ La autopsia del exceso | Se construye la versión de seis motores y se mide entera | Seis motores vs tres, con factura completa |
| 12 | ⚖️ El veredicto con las dos manos | Árbol de decisión de cuándo NO sumar un motor | La arquitectura final, defendida con números |

Apéndices (formato reducido, no llevan las 9 secciones completas):

| Apéndice | Contenido |
|---|---|
| A | Arranque de motores en contenedores (Podman/Docker, Linux/macOS/Windows+WSL) |
| B | El `compose.yaml` comentado, con perfiles `min`/`base`/`full`/`villain` |
| C | Diccionario de traducción de lenguajes de consulta (ver prompt §2.3) |
| D | El generador de datos: volumen, estacionalidad, consistencia entre motores |
| E | Troubleshooting del laboratorio |
| F | Runbooks por motor y plantilla de post-mortem |

---

## 4. Notas de uso

- Si vas a encadenar varias fases en la misma conversación, no hace falta
  repetir todo el contexto del prompt-plantilla en cada mensaje: basta con
  indicar el número de fase y pegar el contenido específico de la tabla de
  §3, ya que el contexto del curso persiste en la conversación.
- Si vas a arrancar cada fase en una conversación **nueva** (recomendado
  para fases largas, que se benefician de una ventana de contexto limpia),
  usa el prompt-plantilla completo de §1 cada vez, y adjunta como archivo
  el `.md` de la fase inmediatamente anterior para que el modelo pueda
  verificar coherencia de nombres, esquema de eventos y resultados previos
  de `BENCHMARKS.md`.
- Las decisiones pendientes de `EL-ARBITRO-SEMILLA.md` (nombre del sistema,
  dataset sintético vs público, motores del villano, Redpanda vs Kafka,
  outbox-primero vs CDC-directo, durabilidad de las reservas, método de
  costo operativo) deben resolverse **antes** de correr el prompt de la
  Fase 0, porque varias de ellas condicionan el `compose.yaml` inicial.
