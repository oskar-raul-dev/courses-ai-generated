# 🧵 Portalón — Prompts reutilizables

> Cada prompt de este archivo es **autónomo**: incluye el contexto mínimo
> necesario para correr en un proyecto nuevo, sin depender de este proyecto
> de fábrica. Copia el prompt completo (incluyendo el bloque de contexto) en
> una conversación nueva junto con los tres archivos de referencia que cada
> uno pide adjuntar.

---

## 0. Antes de usar cualquier prompt

Adjunta siempre estos tres archivos a la conversación nueva:

1. `01-portalon-semilla.md` — la semilla completa del curso.
2. `PORTALON-GUIA-ESTILO.md` — tono, idioma, plantilla de fase, callouts.
3. `PORTALON-ALCANCE.md` — qué entra y qué no entra en el curso.

Y, a partir de la Fase 1, adjunta también los artefactos acumulativos que
ya existan: `INSTINTOS.md`, `BENCHMARKS.md` y el `.md` de la fase anterior
(para continuidad de nombres de clave, rutas y decisiones).

---

## 1. Prompt de arranque — Fase 0 (Laboratorio)

```
Eres el redactor de la Fase 0 del curso "Portalón", un curso de la Ruta
NoSQL que enseña el modelo de acceso clave-valor en memoria (TTL nativo,
estructuras de datos) a través de un gateway de API. El lector es un
ingeniero backend senior con años de experiencia en PostgreSQL y SQL; no le
expliques lo obvio de su paradigma de origen, recalíbrale el instinto.

CONTEXTO DEL CURSO (resumen, la semilla adjunta tiene el detalle completo):
Portalón es una puerta de entrada de API que resuelve, con el mismo motor
clave-valor, cuatro problemas: rate limiting (Fase 1), sesiones (Fase 2),
cola de trabajos (Fase 3) y leaderboard (Fase 4). El stack fijado es Valkey
9.x (motor principal), Redis 8.x y Dragonfly 1.x (rivales en memoria) más
PostgreSQL 17.x (rival de control), todos en contenedores, con Node 24 LTS
+ TypeScript 5.x + Express 5.x como runtime del gateway. El curso mide todo
"vs" con un arnés propio, `scripts/vs.ts`, contra los tres motores en
memoria y, cuando aplica, contra Postgres — nunca se citan benchmarks de
marketing.

TAREA DE ESTA FASE:
Redacta la Fase 0 completa: "Laboratorio contenerizado". Debe:
1. Levantar con Docker/Podman Compose los tres motores en memoria y el
   Postgres de control, cada uno en su puerto, accesibles desde el gateway.
2. Hacer nacer el generador de datos sintéticos (IPs, sesiones, trabajos,
   jugadores) con distribuciones realistas (colas largas, ráfagas).
3. Hacer nacer el esqueleto de `scripts/vs.ts`: qué mide, cómo cronometra
   (p50/p95/p99, throughput), cómo vuelca a `BENCHMARKS.md`.
4. Incluir la "prueba de fuego": el mismo script de cliente se conecta a
   Valkey, Redis y Dragonfly cambiando solo una variable de entorno
   (mismo protocolo RESP en los tres).
5. Cerrar con el primer 🩻 del curso: "el protocolo RESP viaja igual en los
   tres motores, como el dialecto SQL básico viaja entre motores
   relacionales".

FORMATO OBLIGATORIO:
Sigue al pie de la letra la plantilla de 9 secciones y el vocabulario de
callouts (📖 🪞 🩻 ⚰️ 📝 🪦 📚 ⚠️ 💡 💸 🔥 ⭐) definidos en
PORTALON-GUIA-ESTILO.md (adjunto). Código en inglés, narrativa y comentarios
en español, segunda persona sin voseo. Cierra con 20-40 ejercicios
graduados 🟢🟡🟠🔴 de diverso nivel de dificultad, anclados al dominio de
Portalón (nunca ejemplos abstractos), y con la sección de referencias al
final del capítulo, con URLs completas y advertencia de que deben
verificarse. Respeta el alcance de PORTALON-ALCANCE.md (adjunto): no
introduzcas nada de "qué queda fuera".

Al terminar la fase, además genera:
- El esqueleto inicial de `INSTINTOS.md` (solo el formato: predicción /
  cronómetro / veredicto, sin entradas todavía salvo que esta fase ya
  produzca una).
- El esqueleto inicial de `BENCHMARKS.md` (formato de entrada: fecha,
  dataset, configuración de motor, p50/p95/p99, throughput).

Antes de escribir, si algo del stack, versión o dataset no está fijado en
la semilla adjunta, señálalo como decisión pendiente y usa la propuesta por
defecto que ahí figura, en vez de bloquear la redacción.
```

---

## 2. Prompt-plantilla por fase (Fases 1 a 11)

Reutiliza este prompt cambiando solo los campos marcados entre `{{ }}`. Los
valores para cada fase están en la tabla de "Estructura de fases" de
`01-portalon-semilla.md`.

```
Eres el redactor de la Fase {{N}} del curso "Portalón" (Ruta NoSQL, modelo
clave-valor en memoria con TTL nativo). El lector es un ingeniero backend
senior con años de PostgreSQL; no le expliques lo obvio de SQL, recalíbrale
el instinto hacia el modelo en memoria.

CONTEXTO MÍNIMO (la semilla adjunta tiene el detalle completo):
Portalón es un gateway de API que resuelve con clave-valor cuatro
problemas: rate limiting, sesiones, cola de trabajos y leaderboard, medidos
todos con `scripts/vs.ts` contra Valkey 9.x, Redis 8.x, Dragonfly 1.x y,
cuando aplica, PostgreSQL 17.x de control. Runtime: Node 24 LTS +
TypeScript 5.x + Express 5.x. Estás continuando un curso ya empezado: no
contradigas las fases anteriores (adjuntas si existen) ni los nombres de
clave, ruta o módulo ya fijados.

ESTA FASE:
- Núcleo: {{NÚCLEO_DE_LA_FASE}}
- "Vs" que mide: {{VS_DE_LA_FASE}}
- Recuadros que caen en esta fase: {{🪞_Y_🩻_PROPUESTOS_EN_LA_SEMILLA}}
- Diccionario de traducción que suma (si aplica): {{ENTRADA_NUEVA_SQL_↔_CLAVE-VALOR}}
- Villano: {{SI_ESTA_FASE_ALIMENTA_O_NO_LA_AUTOPSIA_DE_LA_FASE_11}}

TAREA:
Redacta la Fase {{N}} completa siguiendo exactamente la plantilla de 9
secciones de PORTALON-GUIA-ESTILO.md (adjunto): 🎯 Propósito, ✅ Qué queda
listo, 🚫 Qué queda fuera por ahora, 🧠 Conceptos mínimos (con la 📖 tabla de
traducción y los recuadros 🪞/🩻 que correspondan), 💻 Implementación y
código comentado (con Detalles con intención, El patrón a memorizar, Prueba
de fuego y 💸 Pago de deuda si aplica), ⚠️ Errores comunes y pieza forense,
🧪 Ejercicios progresivos, 📚 Referencias (al final del capítulo), 🚀 Cierre
y conexión con la siguiente fase (con "La señal de que quedó bien").

Código en inglés (identificadores, rutas, claves, comandos), narrativa y
comentarios en español, segunda persona sin voseo. Toda comparación entre
motores debe describirse como algo que se corre en `vs.ts` y se registra en
`BENCHMARKS.md`; no narres un "X es más rápido" sin indicar que sale de una
medición real. Si esta fase pone a prueba un instinto relacional, agrega
la entrada correspondiente a `INSTINTOS.md` en el formato predicción /
cronómetro / veredicto.

Cierra con 20-40 ejercicios graduados 🟢🟡🟠🔴 (mínimo dos niveles de
dificultad representados, distribución sugerida en la guía de estilo),
anclados al dominio de Portalón (IPs, sesiones, trabajos, jugadores),
incluyendo al menos un puñado de diagnóstico (se entrega un bug, se pide
reproducir y localizar). Respeta PORTALON-ALCANCE.md: no introduzcas nada
marcado como "fuera de alcance".

Antes de escribir, si algo de stack, dataset o decisión de diseño no está
fijado en la semilla, señálalo como pendiente y usa la propuesta por
defecto que ahí figura, en vez de bloquear la redacción.
```

### 2.1 Valores sugeridos por fase (para completar `{{ }}`)

| N | Núcleo | "Vs" |
|---|---|---|
| 1 | Contadores con TTL y ventana deslizante | 3 motores en memoria + Postgres de control |
| 2 | Hashes con TTL, set de sesiones por usuario, invalidación | 3 motores + Postgres (tabla de sesiones) |
| 3 | Listas y streams con grupos de consumidores | Lista vs stream; 3 motores |
| 4 | Sorted sets: `ZADD`/`ZRANK`/`ZREVRANGE` | 3 motores; sorted set vs `ORDER BY` en Postgres |
| 5 | Operaciones atómicas, `MULTI`/`EXEC`, scripts Lua, `WATCH` | Lua vs round-trips; coste entre motores |
| 6 | Locks distribuidos, condiciones de carrera, doble-consumo | 3 motores bajo contención |
| 7 | Snapshotting vs append-only; qué se pierde al morir | Durabilidad y recuperación por motor |
| 8 | Políticas de evicción, presión de memoria, `maxmemory` | Comportamiento bajo `maxmemory` por motor |
| 9 | Réplicas y clustering; particionado por clave | Modelo de cluster de cada motor |
| 10 | Observabilidad, `SLOWLOG`, integración con el backend real | Perfil operativo comparado |
| 11 | Autopsia del villano ("Redis como base primaria"), medida | Villano en memoria vs Postgres honesto |

> Para la Fase 11, agrega al prompt-plantilla la instrucción explícita de
> construir el subsistema villano **lo justo para medirlo** (no un sistema
> completo) y cerrar con el árbol ⚖️ de "cuándo NO usar clave-valor" de
> `PORTALON-ALCANCE.md`.

---

## 3. Prompt — Coda multi-lenguaje (Fase 12)

```
Eres el redactor de la Coda (Fase 12) del curso "Portalón" (Ruta NoSQL,
modelo clave-valor en memoria). El lector ya construyó las 11 fases del
gateway en TypeScript/Node. Esta coda demuestra que lo aprendido es un
modelo de acceso, no un cliente de Node.

CONTEXTO MÍNIMO (la semilla adjunta tiene el detalle completo):
Se porta UN subsistema acotado —por defecto, el rate limiter de ventana
deslizante, porque combina sorted set + TTL + una operación atómica en una
pieza pequeña y medible— a Java (JDK LTS) y a Go, contra los mismos tres
motores en memoria (Valkey 9.x, Redis 8.x, Dragonfly 1.x), con el mismo
`scripts/vs.ts` (o un arnés hermano por lenguaje) como árbitro. Se comparan
dos filosofías de cliente por lenguaje: el cliente idiomático clásico
(Lettuce/Jedis en Java, `go-redis`/`valkey-go` en Go) contra el cliente
unificado Valkey GLIDE (núcleo en Rust, bindings por lenguaje).

TAREA:
Redacta la Coda completa siguiendo la plantilla de 9 secciones adaptada
(puedes fusionar 🚫 y 🧠 si el contenido de setup lo pide, mencionándolo
explícitamente). Debe incluir:
1. El setup de toolchains (Java, Go) apuntando a los mismos tres motores.
2. El puerto del rate limiter de ventana deslizante a Java y a Go,
   respetando exactamente la misma clave (`ratelimit:ip:<ip>`) y semántica
   que la Fase 1.
3. El 🩻 grande: "el protocolo RESP viaja igual entre lenguajes, como el
   SQL básico viaja entre drivers JDBC, `pq` y `pg`".
4. El 🪞 propio de la coda: cliente idiomático clásico vs Valkey GLIDE como
   decisión de arquitectura, no de gusto — con el duelo medido en
   `BENCHMARKS.md`.
5. La advertencia ⚠️ de que la madurez de cada binding de GLIDE (en
   especial el de Go) debe verificarse al redactar, no asumirse.
6. El cierre con la señal de que quedó bien de todo el curso: "me cambian
   el lenguaje del servicio y no vuelvo a aprender el modelo".

Código en inglés, narrativa y comentarios en español, segunda persona sin
voseo. Ejercicios: 20-40, pero puedes ajustar la distribución hacia 🟠🔴 ya
que el lector viene de completar el curso completo. Referencias al final
del capítulo, con URLs completas y advertencia de verificación —incluyendo
explícitamente la doc de clientes clásicos y de Valkey GLIDE por lenguaje.
No amplíes el alcance a los otros tres subsistemas del gateway: PORTALON-
ALCANCE.md fija que la coda porta uno solo.
```

---

## 4. Prompt — `INSTINTOS.md` (artefacto transversal)

```
Vas a mantener el archivo acumulativo `INSTINTOS.md` del curso "Portalón"
(Ruta NoSQL, modelo clave-valor en memoria). Este archivo NO se reescribe:
se le agrega una entrada nueva por cada 🪞 "tu instinto SQL dice…" que
aparece en una fase.

FORMATO DE CADA ENTRADA:
## Fase {{N}} — {{título corto del instinto puesto a prueba}}
**Predicción (instinto SQL):** {{qué creía el lector que iba a pasar, en
una frase, con lenguaje relacional: "creo que la tabla `requests` con
índice aguantará el rate limit"}}
**Cronómetro:** {{qué se corrió en `vs.ts`, contra qué motores, con qué
dataset — una o dos líneas, sin números todavía}}
**Veredicto medido:** {{el resultado real, con número, citando la entrada
correspondiente de `BENCHMARKS.md`: "falso: la ventana deslizante en sorted
set es Nx más rápida en p99 en el camino crítico"}}

REGLAS:
- Nunca modifiques una entrada ya escrita de una fase anterior; solo
  agrega la nueva al final, en orden de fase.
- El veredicto siempre cita un número real de `BENCHMARKS.md`; si esta fase
  todavía no corrió `vs.ts` para este instinto, no agregues la entrada
  todavía — vuelve cuando exista el número.
- Español, segunda persona sin voseo, sin humor forzado (este archivo es
  más seco que una fase; es un registro, no una narrativa).

TAREA DE ESTE PROMPT:
Agrega la entrada de la Fase {{N}} a partir de este 🪞 tal como aparece en
la fase recién redactada: {{PEGAR_AQUÍ_EL_RECUADRO_🪞_DE_LA_FASE}}. Adjunto
el `INSTINTOS.md` actual (si es la primera entrada, créalo con este
formato).
```

---

## 5. Prompt — `BENCHMARKS.md` (artefacto transversal)

```
Vas a mantener el archivo acumulativo `BENCHMARKS.md` del curso "Portalón"
(Ruta NoSQL, modelo clave-valor en memoria). Este archivo NO se narra: cada
entrada es el resultado de una corrida real de `scripts/vs.ts`. Nunca
inventes números; si no tienes la salida real de una corrida, deja la
entrada como plantilla con `{{PENDIENTE_DE_CORRER}}` en los campos
numéricos.

FORMATO DE CADA ENTRADA:
## {{fecha ISO}} — Fase {{N}}: {{nombre del "vs"}}
**Operación semántica:** {{qué se midió, en una frase: "rate limit de
ventana deslizante a 100k peticiones"}}
**Motores:** {{lista de motores y versión exacta (patch) usados}}
**Dataset:** {{tamaño y distribución del dataset generado}}
**Máquina/entorno:** {{spec relevante: CPU, RAM, si corrió en contenedor}}

| Motor | p50 | p95 | p99 | throughput |
|---|---|---|---|---|
| {{motor 1}} | {{}} | {{}} | {{}} | {{}} |
| {{motor 2}} | {{}} | {{}} | {{}} | {{}} |
| {{motor 3}} | {{}} | {{}} | {{}} | {{}} |

**Nota:** {{una línea sobre algo que llame la atención del resultado, sin
sacar conclusiones que el número no sostiene}}

REGLAS:
- Nunca se reescribe una entrada anterior; solo se agrega.
- Nunca se citan benchmarks de marketing de Valkey, Redis o Dragonfly: solo
  corridas propias de `vs.ts`.
- Si dos corridas del mismo "vs" dan números distintos en fechas distintas
  (por ejemplo, tras una actualización de versión), ambas quedan, en orden
  cronológico — no se borra la vieja.

TAREA DE ESTE PROMPT:
Agrega la entrada de la corrida de {{VS_DE_LA_FASE_N}} con estos datos
reales de salida de `vs.ts`: {{PEGAR_AQUÍ_LA_SALIDA_CRUDA_DEL_ARNÉS}}.
Adjunto el `BENCHMARKS.md` actual (si es la primera entrada, créalo con
este formato).
```

---

## 6. Prompt — Diccionario de traducción SQL ↔ clave-valor

```
Vas a mantener el diccionario de traducción SQL ↔ clave-valor del curso
"Portalón" (Ruta NoSQL). Es una tabla acumulativa, no un documento narrado:
cada fase que introduce una equivalencia nueva le agrega filas.

FORMATO:
| Operación SQL (Postgres) | Equivalente clave-valor | Motor / comando | Fase donde se introduce |
|---|---|---|---|
| `SELECT COUNT(*) FROM requests WHERE ip=? AND ts > now()-60` | Ventana deslizante | `ZCOUNT ratelimit:ip:<ip> (now-60) +inf` | 1 |
| ... | ... | ... | ... |

REGLAS:
- Cada fila cita el comando RESP real (mayúsculas, como en la doc oficial
  del motor), no una paráfrasis.
- El lado SQL usa sintaxis de PostgreSQL 17.x, la versión fijada del curso.
- No se traduce lo que no tiene equivalente honesto: si una operación SQL
  no tiene equivalente razonable en clave-valor (por ejemplo, un JOIN
  arbitrario), se anota explícitamente "sin equivalente directo — ver
  ⚰️ autopsia del villano, Fase 11" en vez de forzar una fila.
- Español para cualquier nota; los propios términos de columna van como en
  el código (inglés).

TAREA DE ESTE PROMPT:
Agrega al diccionario las equivalencias introducidas en la Fase {{N}} a
partir de las 📖 tablas de traducción que aparecen en esa fase:
{{PEGAR_AQUÍ_LAS_TABLAS_📖_DE_LA_FASE}}. Adjunto el diccionario actual (si
es la primera fase, créalo con este formato, arrancando con las filas de
la Fase 0/1).
```
