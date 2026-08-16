# 🧩 Prompts — Curso Libro Mayor (NewSQL)

Prompts reutilizables para arrancar y redactar el curso en un **proyecto de
chat nuevo**, sin depender de este proyecto de fábrica. Cada prompt es
autónomo: trae el contexto mínimo necesario (dominio, stack, veredicto,
reglas de estilo) para poder pegarse solo y producir contenido correcto. Si
el proyecto nuevo sí tiene adjuntos `09-libro-mayor-semilla.md`,
`LIBRO-MAYOR-ALCANCE.md` y `LIBRO-MAYOR-GUIA-ESTILO.md`, dilo al inicio del
prompt para que se usen como fuente de verdad completa en vez del resumen
incluido aquí.

> Convención: sustituye cualquier `{{marcador}}` antes de enviar el prompt.

---

## 1. Prompt de arranque — Fase 0

```
Eres mi coautor para redactar el curso "Libro Mayor", parte de una ruta de
formación en modelos de acceso a datos no relacionales (Ruta NoSQL). Este
curso en particular es el caso fronterizo NewSQL: no es NoSQL, es SQL
distribuido con ACID, y se incluye porque completa el mapa del debate.

## Contexto del curso (resumen autónomo)

**Dominio:** Libro Mayor, un sistema de contabilidad de cuentas por partida
doble para una plataforma de pagos ficticia con presencia en tres regiones
(América del Norte, Europa, América del Sur). Cada usuario tiene cuentas
(`accounts`) con saldo en una moneda; cada movimiento es un `transfer` que
genera dos o más `postings` cuya suma es exactamente cero. Nada se borra ni
se edita: corregir un asiento es otro asiento.

**Veredicto del marco de 5 preguntas:** NewSQL gana 4-1. El voto disidente es
sincero: si todo el negocio vive en una sola región y no supera lo que un
nodo grande aguanta, Postgres gana y NewSQL es sobre-ingeniería. El curso
mide ese voto disidente en la Fase 1 y lo revisita en el veredicto final.

**El villano — el falso dilema, con tres caras:**
(A) renunciar a ACID por miedo a escalar (sagas y compensaciones a mano
sobre un motor sin transacciones multi-clave — se mide cuánto dinero queda
en el limbo); (B) forzar un único nodo por miedo a distribuir (escalado
vertical + réplica asíncrona + failover manual — se mide el RPO real y la
latencia del usuario lejano); (C) usar NewSQL donde no toca (un CRUD de una
sola región sobre un clúster de tres nodos — se mide la latencia de consenso
pagada por nada).

**Stack (verificar versiones vigentes antes de fijarlas — esta lista es la
propuesta de la semilla, agosto de 2026):**
- CockroachDB (LTS más reciente, self-hosted) — motor principal
- TiDB (LTS más reciente, con TiKV + PD) — rival 1
- YugabyteDB (LTS más reciente, `yugabyted`) — rival 2
- PostgreSQL 17.x — línea base / testigo, no rival
- Node.js LTS activo, TypeScript (7.x si el ecosistema lo soporta bien, si
  no 6.x sin discusión)
- Fastify 5.x para la API
- `pg` (cliente de Cockroach/Yugabyte/Postgres) y `mysql2` (cliente de TiDB)
- Zod para validación en el borde
- Toxiproxy para inyectar latencia y particiones inter-región
- Vitest para pruebas
- Docker/Podman + Compose
- Prometheus + Grafana

**Método del "vs":** `scripts/vs.ts` es el corazón metodológico. Recibe un
escenario semántico, lo ejecuta contra cada motor configurado y devuelve
siempre las mismas métricas: p50/p95/p99, throughput, tasa de aborto por
conflicto de serialización, reintentos, errores por categoría. Reglas: fase
de calentamiento descartada, mismos escenarios contra los cuatro motores en
la misma sesión y topología de latencia, y todo resultado anexado a
`BENCHMARKS.md` con versión exacta de cada motor, configuración de Toxiproxy
y commit del arnés. Ningún número entra al curso si no salió del arnés.

## Reglas de estilo (resumen autónomo — el detalle completo está en
LIBRO-MAYOR-GUIA-ESTILO.md si lo tienes adjunto)

- Código en inglés (tablas, columnas, endpoints, funciones, servicios,
  scripts); narrativa, comentarios y mensajes de error legibles en español.
- **Español sin voseo**: usa "tú", nunca "vos" ni sus conjugaciones.
- Tono cálido, informal, de colega senior a colega senior. El lector domina
  SQL relacional de nodo único: no le expliques lo obvio de ese mundo,
  recalíbrale el instinto para lo distribuido.
- Prosa antes que listas; tablas solo para comparar, decidir o mapear.
- Cada fase sigue la plantilla obligatoria de 9 secciones (Propósito / Qué
  queda listo / Qué queda fuera / Conceptos mínimos / Implementación y
  código comentado / Errores comunes y pieza forense / Ejercicios
  progresivos / Referencias / Cierre y conexión).
- Callouts del curso: 🪞 (instinto de nodo único que se paga distinto), 🩻
  (esto sí viaja igual), ⚰️ (autopsia del villano), 📖 (diccionario de
  traducción nodo único ↔ clúster distribuido), 📝 (nota de arquitectura),
  ⚠️ (advertencia), 💡 (truco), 💸 (deuda técnica declarada y pagada), 🔥
  (opcional).
- 20 a 40 ejercicios por fase (objetivo 30), numerados por rango de
  dificultad 🟢🟡🟠🔴, al menos cinco de diagnóstico por fase, todos anclados
  al dominio de Libro Mayor (nunca `foo`/`bar`).
- Ningún "vs" se narra a ojo: todo duelo mencionado en prosa tiene su entrada
  correspondiente en `BENCHMARKS.md`.
- No inventar números de página, DOIs ni IDs de video en referencias; marcar
  que URLs y títulos deben verificarse antes de publicar.

## Tarea de esta sesión

Redacta la **Fase 0 — 🧪 El laboratorio de cuatro motores** completa, en
`.md`, siguiendo la plantilla de 9 secciones. La fase debe:

1. Levantar todo el entorno en contenedores: un clúster de tres nodos de
   CockroachDB, un TiDB completo (PD + TiKV + TiDB), un YugabyteDB de tres
   nodos, un Postgres de un nodo, Toxiproxy delante de la red interna de
   cada clúster, y Prometheus/Grafana observándolo todo.
2. Etiquetar cada nodo con su "región" simulada y calibrar la latencia
   (80 ms NA↔EU, 120 ms NA↔SA, 160 ms EU↔SA — verificar si este dato viene
   fijado en un apéndice del proyecto).
3. Escribir el generador de datos (`scripts/seed.ts`) y hacer nacer
   `scripts/vs.ts` con su primer escenario trivial: un `INSERT` de una fila,
   cuatro motores, cuatro números.
4. Cerrar con `BENCHMARKS.md` teniendo su primera tabla, reproducible con un
   comando documentado.

Antes de escribir, dime qué decisiones pendientes de la semilla (versiones
exactas, presupuesto de recursos del laboratorio, TypeScript 7 vs 6) asumes
por defecto, y por qué, en una lista corta — luego procede con la fase
completa sin esperar confirmación adicional salvo que algo sea genuinamente
bloqueante.
```

---

## 2. Prompt-plantilla por fase (rellenar y reusar)

```
Eres mi coautor del curso "Libro Mayor" (NewSQL, Ruta NoSQL). Ya tienes el
contexto del curso — dominio (ledger de contabilidad multi-región por
partida doble), villano (el falso dilema en sus tres caras), stack
(CockroachDB + TiDB + YugabyteDB + Postgres de testigo, Node/TypeScript,
Fastify, Toxiproxy) y método de medición (`scripts/vs.ts`, todo resultado en
`BENCHMARKS.md`). Si tienes adjuntos `09-libro-mayor-semilla.md` y
`LIBRO-MAYOR-GUIA-ESTILO.md`, úsalos como fuente de verdad completa; si no,
aplica el resumen de reglas de estilo del prompt de Fase 0 de este mismo
documento.

## Fase a redactar

**Número y nombre:** Fase {{n}} — {{emoji}} {{nombre de la fase}}

**Núcleo de la fase (de la tabla maestra de la semilla):**
{{descripción de núcleo, 1-2 líneas}}

**"Vs" de la fase (duelo medido):**
{{descripción del duelo, motores involucrados, qué se mide}}

**Instinto relacional en juego (si aplica, para el recuadro 🪞):**
{{el instinto de nodo único que esta fase pone a prueba, y qué predicción
numérica se le pide al lector antes de medir}}

**Qué sí viaja igual desde el nodo único (para el recuadro 🩻, si aplica):**
{{qué se mantiene igual}}

**Deuda técnica que esta fase declara o paga (si aplica, para 💸):**
{{qué deuda, de qué fase viene o a qué fase se difiere}}

**Fases previas cuyo contenido no se puede contradecir:**
{{resumen de decisiones ya tomadas en fases anteriores que esta fase debe
respetar: nombres de tablas/columnas ya fijados, estrategia de clave
primaria elegida, convenciones de `withRetry`, etc.}}

## Tarea

Redacta la fase completa en `.md`, siguiendo exactamente la plantilla
obligatoria de 9 secciones:

1. 🎯 Propósito
2. ✅ Qué queda listo al terminar
3. 🚫 Qué queda fuera por ahora
4. 🧠 Conceptos mínimos (incluye aquí 📖/🪞/🩻 si esta fase los usa)
5. 💻 Implementación y código comentado (código en inglés, comentarios en
   español, ejecutable contra el stack fijado)
6. ⚠️ Errores comunes y pieza forense
7. 🧪 Ejercicios progresivos (20-40, objetivo 30; numeración continua por
   rango 🟢🟡🟠🔴; al menos cinco de diagnóstico; todos anclados al dominio
   de Libro Mayor)
8. 📚 Referencias (oficial primero, luego papers/libros, luego video; orden
   de lectura sugerido; advertencia de verificación de URLs y títulos)
9. 🚀 Cierre y conexión con la siguiente fase (incluye "La señal de que
   quedó bien")

Reglas no negociables: español sin voseo en toda la narrativa; código,
tablas, columnas, endpoints y servicios en inglés; ningún "vs" se narra sin
una entrada equivalente en `BENCHMARKS.md` (si el escenario todavía no
existe en el arnés, escribe primero el escenario en TypeScript y luego los
números que produciría, marcados claramente como "a ejecutar antes de
publicar" si no puedes correr código en esta sesión).

Si esta fase alimenta `INSTINTOS.md` o `BENCHMARKS.md`, escribe también las
entradas correspondientes en el formato fijado por esos artefactos (ver
prompts §3 y §4 de este documento) al final de tu respuesta.
```

---

## 3. Prompt para `INSTINTOS.md`

```
Vas a crear o actualizar el artefacto acumulativo `INSTINTOS.md` del curso
"Libro Mayor" (NewSQL, Ruta NoSQL).

## Qué es este documento

Recoge, fase por fase, cada instinto relacional de nodo único que el curso
pone a prueba. El lector llega con años de hábitos de Postgres/MySQL de un
solo nodo bien afinado; este documento es el mapa personal de qué reflejos
sobrevivieron al cambio de arquitectura y cuáles no.

## Formato rígido por entrada (no te apartes de él)

```
### Instinto #{{n}} — Fase {{n}}: "{{el instinto en primera persona, tal
como lo pensaría el lector}}"

**Predicción (antes de medir):** {{el número o comportamiento que el lector
predice, escrito ANTES de correr el arnés}}

**Escenario del arnés:** {{el escenario exacto de `scripts/vs.ts` que se
corrió — nombre del escenario, motores involucrados, número de clientes
concurrentes, topología de latencia}}

**Resultado medido:** {{los números reales, con referencia a la entrada
correspondiente en `BENCHMARKS.md`}}

**Veredicto:** ✅ Confirmado / 🟡 Matizado / ❌ Refutado — {{una frase que
explique el veredicto}}
```

## Reglas

- Un instinto confirmado vale tanto como uno refutado; lo único que no vale
  es no haber escrito la predicción antes de medir.
- Nunca se reescribe un instinto ya cerrado; si una fase posterior lo pone a
  prueba de nuevo con matices, se agrega como instinto nuevo referenciando
  al anterior.
- Español sin voseo; el instinto se redacta en primera persona del lector
  ("yo pensaba que…"), el resto del documento en la voz normal del curso.

## Tarea de esta sesión

{{Si es la primera vez: crea el documento con su encabezado y la primera
entrada de la Fase 1 (el instinto "un clúster distribuido siempre escribe
más lento que un nodo único").}}

{{Si es una actualización: agrega la entrada del Instinto #{{n}} para la
Fase {{n}}, con los datos de predicción/escenario/resultado que te doy a
continuación: {{pegar datos}}. No toques las entradas anteriores.}}
```

---

## 4. Prompt para `BENCHMARKS.md`

```
Vas a crear o actualizar el artefacto acumulativo `BENCHMARKS.md` del curso
"Libro Mayor" (NewSQL, Ruta NoSQL).

## Qué es este documento

El registro de todos los duelos ejecutados con `scripts/vs.ts`. Es evidencia,
no folleto: crece por acumulación, nunca por reescritura. Si una medición
posterior contradice a una anterior, se anexa la nueva explicando la
diferencia; el pasado no se corrige.

## Formato rígido por entrada

```
## Escenario: {{nombre del escenario, tal como aparece en scripts/vs.ts}}
**Fecha / commit del arnés:** {{fecha}} / {{hash de commit}}
**Motores y versiones exactas:** CockroachDB {{versión}}, TiDB {{versión}},
YugabyteDB {{versión}}, PostgreSQL {{versión}}
**Topología de latencia (Toxiproxy):** {{configuración exacta usada}}
**Clientes concurrentes:** {{número}}
**Fase de calentamiento:** {{duración, descartada}}

| Motor | p50 | p95 | p99 | Throughput | Tasa de aborto | Reintentos promedio |
|---|---|---|---|---|---|---|
| CockroachDB | | | | | | |
| TiDB | | | | | | |
| YugabyteDB | | | | | | |
| PostgreSQL (testigo) | | | | | | |

**Lectura del resultado:** {{2-4 frases interpretando el número, sin
narrar el "vs" de forma distinta a lo que la tabla muestra}}
```

## Reglas

- Ningún resultado se reporta a ojo: si no corriste el escenario, no
  inventes números — describe el escenario y marca la tabla como
  "pendiente de ejecución" en vez de rellenarla.
- Cada entrada necesita los tres datos de reproducibilidad (versión exacta
  de cada motor, configuración de Toxiproxy, commit del arnés) o no cuenta
  como reproducible.
- Español sin voseo en la interpretación; los nombres de escenario y
  columnas de la tabla en inglés donde correspondan a identificadores reales
  del código.

## Tarea de esta sesión

{{Si es la primera vez: crea el documento con su encabezado explicando el
método del "vs" (una versión breve de la sección homónima de la semilla) y
la primera entrada, el INSERT trivial de la Fase 0.}}

{{Si es una actualización: agrega la entrada del escenario "{{nombre}}" de
la Fase {{n}}, con estos datos: {{pegar datos crudos del arnés}}. No
modifiques entradas anteriores; si este resultado contradice una medición
previa, dilo explícitamente en "Lectura del resultado" y enlaza la entrada
anterior por su nombre de escenario y fecha.}}
```

---

## 5. Prompt para el diccionario de traducción

```
Vas a crear o actualizar `DICCIONARIO-TRADUCCION-LIBRO-MAYOR.md`, el
diccionario de traducción del curso "Libro Mayor" (NewSQL, Ruta NoSQL): del
vocabulario y los reflejos de un Postgres/MySQL de nodo único al vocabulario
y los reflejos de un clúster NewSQL distribuido (CockroachDB, TiDB,
YugabyteDB).

## Estructura del documento

1. **Tabla central** — concepto en nodo único ↔ equivalente distribuido ↔
   nota de matiz (cuándo el equivalente no es 1 a 1). Ejemplo de fila:
   `SERIAL` como clave primaria ↔ UUIDv7 o clave hash-sharded ↔ "una clave
   monótona concentra el rango de escritura en un solo nodo; el equivalente
   no es una traducción literal sino una corrección de diseño".
2. **Glosario de términos nuevos sin equivalente directo** — *range*,
   *leaseholder*, *follower read*, *placement*, *quorum*, con su definición
   en español y el motor donde aplica cada nombre concreto.
3. **Diccionario del dominio** — cuenta/account, transferencia/transfer,
   asiento/posting, etc. (ver §4.3 de la guía de estilo).
4. **Matriz de dialectos por motor** — para los comandos o cláusulas que
   cambian de nombre entre CockroachDB, TiDB y YugabyteDB (geo-partición,
   lecturas históricas, DDL en línea), una fila por concepto y una columna
   por motor.

## Reglas

- Es tabla, no prosa (§3 de la guía de estilo): "tablas solo para comparar,
  decidir o mapear" es exactamente este documento.
- Los nombres de comandos y cláusulas SQL se citan tal cual (inglés, como
  código); las notas de matiz van en español sin voseo.
- El diccionario crece fase por fase: cada fase que introduce un concepto
  nuevo (geo-partición en la Fase 5, lecturas históricas en la Fase 8, DDL en
  línea en la Fase 10) debe reflejarse aquí antes de cerrarse esa fase.

## Tarea de esta sesión

{{Si es la primera vez: crea el documento con la tabla central inicial
(Fase 2: DDL básico y tipos) y el diccionario del dominio completo.}}

{{Si es una actualización: agrega las filas correspondientes a los
conceptos nuevos de la Fase {{n}}: {{listar conceptos}}. No elimines ni
reescribas filas existentes salvo error genuino, y si lo haces, dilo.}}
```
