# 🔑 Proyecto Portalón — Semilla del curso (Clave-valor en memoria, con TTL nativo y estructuras de datos)

## 🎯 Motivación

Hay una clase de preguntas que el modelo relacional puede contestar, pero para
las que nunca fue diseñado: *"¿cuál es el valor asociado a esta clave, ahora
mismo, en microsegundos, y bórralo solo cuando expire?"*. Un motor relacional
la responde —con una tabla, un índice y quizá un job de limpieza— pero paga un
peaje en cada paso: parser SQL, planificador, B-tree, MVCC, durabilidad a
disco. Todo ese aparato existe para dar garantías (transacciones, consultas
ad-hoc, integridad referencial) que en este patrón de acceso **no le estás
pidiendo**. El modelo clave-valor en memoria quita el aparato y deja lo único
que necesitas: una tabla hash gigante en RAM, con estructuras nativas
—listas, sets, sorted sets, hashes, streams— y expiración por clave (TTL) como
primitiva de fábrica, no como columna `expires_at` que alguien tiene que
barrer.

La diferencia no es "más rápido porque sí": es **física**. Los datos viven en
memoria; el acceso es O(1) por clave sin recorrer un índice ordenado; y el
motor te regala operaciones atómicas sobre estructuras (incrementar un
contador, empujar a una cola, actualizar un ranking) que en SQL exigirían un
`SELECT ... FOR UPDATE`, una transacción y una ida y vuelta al disco. Cuando el
patrón de acceso es "escribe y lee esta clave a máxima velocidad, y olvídala
sola después de N segundos", cualquier capa relacional de por medio —por bien
indexada que esté— es trabajo de más.

Para un ingeniero senior que viene de años de Postgres, dominar este modelo
cambia dos cosas concretas. Primero, **deja de meter en la base transaccional
cosas que no son estado de negocio**: la sesión, el contador de rate limit, la
cola de trabajos ligera, el leaderboard en vivo. Esas cosas tienen forma de
clave-valor efímero, y ponerlas en tablas relacionales infla la base
autoritativa, ensucia los backups y compite por conexiones con el trabajo que
sí importa. Segundo, **suma a su criterio la herramienta correcta para la capa
caliente**: el amortiguador que se sienta delante del sistema pesado y absorbe
el tráfico que no debería llegar a la fuente de verdad. Un backend senior que
no sabe modelar con clave-valor termina, tarde o temprano, resolviendo un
problema de caché con una tabla —y pagándolo en producción un martes a las 3am.

Este curso es autocontenido: la motivación no sale de compararlo con otros
modelos, sino del problema mismo. Hay un dominio —una puerta de entrada de
API— que exhibe el patrón clave-valor de forma tan natural que resolverlo con
tablas se siente forzado. Ese dominio es Portalón.

---

## 🏗️ El dominio: Portalón, una puerta de entrada (gateway) de API

Portalón es la capa que se sienta delante de tu backend real y decide, para
cada petición, *si pasa, quién la hace, y qué prioridad tiene* antes de que
toque la base autoritativa. Es el sitio donde vive el estado **caliente y
efímero** del sistema: cosas que cambian miles de veces por segundo, que no son
la verdad última del negocio, y que —si se pierden— se reconstruyen o
simplemente caducan sin drama. Es, casi por definición, un dominio clave-valor.

El proyecto resuelve con un mismo motor cuatro problemas que en muchos sistemas
se atacan por separado, y lo hace usando cada vez una **estructura de datos
nativa distinta**, no `SET`/`GET` para todo. Ese es el objetivo pedagógico:
que veas al motor resolver cuatro formas distintas con cuatro herramientas
distintas del mismo cinturón.

### Los cuatro subsistemas

| Subsistema | Qué resuelve | Estructura nativa que lo modela | Por qué encaja |
|---|---|---|---|
| **Rate limiting** | Límite de peticiones por IP y por usuario en ventanas de tiempo | Contadores con TTL, o sorted set para ventana deslizante | La cuenta caduca sola al cerrar la ventana; nadie la borra a mano |
| **Sesiones** | Autenticación con expiración e invalidación | Hash por sesión + TTL; set de sesiones por usuario | El TTL es la expiración de sesión; la invalidación es un `DEL` |
| **Cola de trabajos** | Encolar trabajo diferido (enviar email, generar reporte) | Lista (`LPUSH`/`BRPOP`) o stream con grupos de consumidores | FIFO nativo, bloqueo eficiente, sin polling a una tabla |
| **Leaderboard** | Ranking en vivo (p.ej. gamificación de soporte) | Sorted set (`ZADD`/`ZREVRANGE`/`ZRANK`) | El ranking ordenado por score es *literalmente* la estructura |

Ninguno de los cuatro es "la fuente de verdad" del negocio. El usuario real, el
ticket real, el pago real viven en la base relacional detrás de Portalón. Lo
que Portalón custodia es estado derivado, contable o efímero. Esa distinción
es el corazón del curso y también la línea que separa el buen uso del modelo
de su villano.

### ¿Por qué el dominio exhibe el patrón, en vez de forzarlo?

Porque cada subsistema tiene, de forma independiente, las tres marcas del
acceso clave-valor: (1) **la unidad de lectura/escritura es una clave**, no una
consulta que cruza entidades; (2) **el dato es efímero o reconstruible**,
así que no exige durabilidad transaccional; y (3) **la latencia manda**: son
decisiones que se toman *en el camino crítico* de cada request, donde un
round-trip a Postgres por cada llamada sería inaceptable. Un gateway que
consulta la base relacional para decidir si dejas pasar una petición es un
gateway que traslada su cuello de botella justo al recurso que intentaba
proteger.

### El marco de 5 preguntas, aplicado ANTES de modelar

Antes de escribir una línea, se pasa el dominio por el mismo tamiz que se
aplica en toda la ruta. La gracia es que aquí la respuesta es incómodamente
consistente:

| Pregunta | Respuesta en Portalón | Empuja hacia… |
|---|---|---|
| **¿Qué se lee junto?** | Una clave a la vez: este contador, esta sesión, este trabajo, este ranking. No hay lectura que cruce los cuatro subsistemas. | Clave-valor |
| **¿Quién custodia la forma / las invariantes?** | La aplicación (Portalón), no la base. No hay invariantes cruzadas entre subsistemas que la base deba garantizar. | Clave-valor |
| **¿Cuánto se une en caliente?** | Nada. Cero JOINs. Cada decisión se resuelve con un acceso directo por clave. | Clave-valor |
| **¿Dónde viven las invariantes?** | En operaciones atómicas de una sola clave (incremento, push, add al set). No hay consistencia multi-entidad que defender. | Clave-valor |
| **¿Qué pide la operación?** | Lectura y escritura a máxima velocidad, latencia sub-milisegundo, expiración nativa, altísima frecuencia, evolución de forma casi nula. | Clave-valor |

**Veredicto: vota clave-valor 5-0.** Es el espejo exacto del caso legendario
donde un dominio tipo Jira votaba relacional 5-0: aquí el patrón de acceso
apunta, sin ambigüedad, al modelo en memoria. No es una preferencia; es que el
dominio *tiene esa forma*.

> ⚠️ El veredicto 5-0 es sobre **la capa del gateway**, no sobre todo el
> sistema. La fuente de verdad detrás de Portalón sigue siendo relacional. El
> curso insiste en esta frontera precisamente porque cruzarla es el villano.

### El villano: Redis como base de datos primaria

El anti-patrón que este curso disecciona con autopsia medida es **usar el
motor clave-valor como base de datos primaria / única fuente de verdad**. Es
el villano en la dirección contraria al del caso Jira: allá alguien metió en
Mongo un dominio relacional; aquí alguien mete en Redis el dominio entero
—usuarios, tickets, pagos— seducido por la velocidad, y descubre tarde que
perdió las consultas ad-hoc, la integridad referencial, la durabilidad seria y
la capacidad de responder cualquier pregunta que no anticipó al modelar.

El curso construye un subsistema "villano" deliberado —por ejemplo, mover la
tabla de usuarios y sus relaciones a estructuras clave-valor— y lo **mide**:
qué cuesta un "dame todos los usuarios que cumplan X" cuando no hay índice
secundario, qué pasa con la memoria cuando el dataset crece más allá de la RAM,
qué se rompe cuando el proceso muere sin haber persistido, y cuánto duele
mantener a mano los índices que el motor relacional te daba gratis. La lección
transferible: **el modelo en memoria es un amortiguador espectacular y una base
primaria peligrosa**, y la evidencia —no la fe— es la que traza la línea.

---

## 📐 Stack (2026, estable y moderno)

Todo el stack es la última línea estable a agosto de 2026, open source y
contenerizado. La audiencia ya vive en contenedores: nada se instala "a pelo".

| Componente | Versión / elección | Rol |
|---|---|---|
| **Valkey** | 9.x (última estable 2026) | Motor clave-valor **principal** del curso; fork BSD de la Linux Foundation |
| **Redis** | 8.x (open source, AGPLv3 desde 8.0) | Rival directo: el incumbente histórico del modelo |
| **Dragonfly** | 1.x (dragonflydb) | Rival moderno multi-hilo, compatible de protocolo |
| **PostgreSQL** | 17.x | Rival relacional de **control** (mide qué cuesta lo mismo en la base autoritativa) |
| **Node.js** | 24 LTS (Active LTS 2026) | Runtime de implementación del gateway y del arnés |
| **TypeScript** | 5.x | Lenguaje de implementación (tipado sobre el cliente y el arnés) |
| **Express** | 5.x | Framework HTTP del gateway (mínimo, sin magia) |
| **cliente redis/valkey** | `iovalkey` o `ioredis` (protocolo RESP compartido) | Driver desde Node; el protocolo es común a los tres motores en memoria |
| **Docker / Podman** | Compose v2 | Orquestación local de los cuatro motores + el gateway |
| **Vitest / node:test** | última estable | Pruebas del gateway y aserciones de los benchmarks |

> ⚠️ Los tres motores en memoria (Valkey, Redis, Dragonfly) hablan el **mismo
> protocolo (RESP)**, así que el mismo código de cliente apunta a los tres
> cambiando solo el `host:port` del contenedor. Esa es justamente la palanca
> que hace el "vs" barato de construir: una variable de entorno, tres targets.

### Por qué Valkey como motor principal (y no Redis)

Valkey es el fork de la Linux Foundation nacido tras el cambio de licencia de
Redis en 2024, y hoy —en su línea 9.x— es un motor de primera con gobernanza
de fundación abierta y compatibilidad de protocolo. Elegirlo como **principal**
no es militancia: es que en 2026 elegir motor clave-valor es también elegir
gobernanza, y el curso quiere que esa decisión sea consciente, no heredada por
inercia. Redis 8.x volvió a ser open source (AGPLv3 desde 8.0), así que la
comparación ya no es "libre vs propietario" sino un contraste técnico y de
gobernanza legítimo entre dos proyectos vivos. Se trata en detalle en las
consideraciones adicionales.

### Por qué estos rivales

Redis entra como el **incumbente**: es la referencia histórica y contra la que
todo el mundo compara mentalmente, así que medirla explícitamente evita la
comparación de pasillo. Dragonfly entra como la **alternativa moderna**: promete
aprovechar máquinas multi-núcleo (frente a la arquitectura tradicionalmente
mono-hilo del modelo) manteniendo compatibilidad de protocolo —una promesa que
el curso **mide, no asume**. Y PostgreSQL entra como **rival de control**: no
para "ganar", sino para poner número a la afirmación central del curso —
"esto en la base relacional cuesta X, en memoria cuesta Y"— y para materializar
la autopsia del villano.

### Por qué TypeScript + Node 24

Porque el gateway es I/O-bound (habla HTTP hacia afuera y RESP hacia el motor),
que es exactamente donde el modelo de concurrencia de Node brilla; porque el
ecosistema de clientes RESP en Node es maduro y comparte protocolo entre los
tres motores; y porque TypeScript da tipado sobre las respuestas del motor sin
imponer una capa pesada. Es multiplataforma (Linux / macOS / Windows vía WSL) y
se conteneriza sin fricción. No hay aquí una razón para salirse del
TypeScript + Node LTS por defecto de la ruta.

### Tooling transversal

- **Arnés `scripts/vs.ts`** — corre la misma operación semántica contra los tres motores en memoria (y contra Postgres cuando aplica), cronometra y vuelca a `BENCHMARKS.md`.
- **Generador de datos** — siembra IPs sintéticas, sesiones, trabajos y jugadores de leaderboard con distribuciones realistas (colas largas, ráfagas).
- **Validación en capas** — dónde vive una decisión: en el middleware del gateway, en el cliente RESP, o en el propio motor. La distinción salva al que depura.

---

## ⚖️ El método del "vs": un arnés, no anécdotas

`scripts/vs.ts` es la columna vertebral empírica del curso. Toma una
**operación semántica** —no un comando concreto, sino un objetivo: "aplica un
rate limit de ventana deslizante a 100k peticiones", "resuelve 50k lecturas de
sesión", "actualiza un leaderboard de 1M de jugadores y pide el top 10"— y la
ejecuta contra cada motor en juego con el mismo arnés, la misma máquina, el
mismo dataset generado, midiendo latencia (p50/p95/p99) y throughput. Acumula
cada corrida en `BENCHMARKS.md` con su fecha y su configuración, para que
ningún "X es más rápido" quede sin número que lo respalde.

Los duelos concretos que atraviesan el curso:

- **Valkey vs Redis vs Dragonfly** en cada uno de los cuatro subsistemas: el mismo trabajo, tres motores, tres columnas de números. Aquí es donde la promesa multi-hilo de Dragonfly se confirma o se cae.
- **Motor en memoria vs PostgreSQL** en el rate limit y en la sesión: cuánto cuesta la misma decisión de gateway resuelta en la base relacional de control. Es el número que justifica (o no) meter un motor nuevo en la arquitectura.
- **Villano vs base correcta**: el subsistema "Redis como base primaria" contra su equivalente honesto en Postgres, para consultas ad-hoc que el modelo en memoria no anticipó. La autopsia medida de la fase final.

> El curso **rechaza** los benchmarks de marketing de cualquiera de los tres
> proyectos. Si un número no salió de `vs.ts` en tu máquina, no entra en
> `BENCHMARKS.md`.

---

## 🌳 Estructura de fases

Doce fases más una **coda**. La Fase 0 monta el laboratorio contenerizado, el
generador de datos y hace nacer `vs.ts`; las fases 1–4 construyen los cuatro
subsistemas del gateway (cada uno con su estructura nativa y su "vs"); las fases
5–8 suben la exigencia operativa (atomicidad, persistencia, memoria,
clustering); las fases 9–10 cierran producción y observabilidad; la Fase 11 es
la autopsia del villano y el veredicto honesto. La **Coda** (Fase 12) sale del
gateway y prueba el mismo escenario desde tres runtimes —TypeScript, Java y
Go— para demostrar que el modelo clave-valor es agnóstico del lenguaje: el
protocolo RESP viaja igual desde los tres.

| # | Fase | Núcleo | "Vs" de la fase |
|---|---|---|---|
| 0 | Laboratorio | Contenedores de los 4 motores, generador de datos, nace `vs.ts` | Arranque idéntico de Valkey/Redis/Dragonfly por protocolo común |
| 1 | Rate limiting | Contadores con TTL y ventana deslizante con sorted set | 3 motores en memoria + Postgres de control |
| 2 | Sesiones | Hashes con TTL, set de sesiones por usuario, invalidación | 3 motores + Postgres (tabla de sesiones) |
| 3 | Cola de trabajos | Listas y streams con grupos de consumidores | Lista vs stream; 3 motores |
| 4 | Leaderboard | Sorted sets: `ZADD`/`ZRANK`/`ZREVRANGE` | 3 motores; sorted set vs `ORDER BY` en Postgres |
| 5 | Atomicidad | Operaciones atómicas, `MULTI`/`EXEC`, scripts Lua, `WATCH` | Lua vs round-trips; coste entre motores |
| 6 | Concurrencia | Locks distribuidos, condiciones de carrera, el doble-consumo | 3 motores bajo contención |
| 7 | Persistencia | Snapshotting vs append-only; qué se pierde al morir | Durabilidad y recuperación por motor |
| 8 | Memoria y evicción | Políticas de evicción, presión de memoria, límites | Comportamiento bajo `maxmemory` por motor |
| 9 | Escala | Réplicas y clustering; particionado por clave | Modelo de cluster de cada motor |
| 10 | Producción | Observabilidad, métricas, `SLOWLOG`, integración con el backend real | Perfil operativo comparado |
| 11 | ⚰️ Autopsia y veredicto | El villano "Redis como base primaria", medido; ⚖️ cuándo NO usar la familia | Villano en memoria vs Postgres honesto |
| 12 | 🎼 Coda multi-lenguaje | El mismo escenario del gateway desde TypeScript, Java y Go | Tres runtimes; cliente idiomático clásico vs Valkey GLIDE |

### Fase 0 — Laboratorio contenerizado

Monta con Compose los tres motores en memoria y el Postgres de control, cada
uno en su puerto, todos accesibles desde el gateway. Nace el generador de datos
(IPs, sesiones, trabajos, jugadores) y el esqueleto de `vs.ts`. Prueba de fuego:
el mismo script de cliente se conecta a Valkey, Redis y Dragonfly cambiando solo
una variable de entorno. Aquí cae el primer 🩻 ("el protocolo RESP viaja igual
en los tres, como el dialecto SQL básico viaja entre motores relacionales").

### Fase 1 — Rate limiting

El primer subsistema y el más didáctico: dos enfoques (contador fijo con TTL vs
ventana deslizante con sorted set), su trade-off de precisión, y la primera
medición seria contra Postgres. Aquí cae un 🪞 fuerte: *"tu instinto SQL dice
'una tabla `requests` con `timestamp` y un `COUNT(*) WHERE ts > now()-60s`', y
esta vez la ventana deslizante en un sorted set con expiración nativa la deja
en ridículo en el camino crítico"*. 📖 primera entrada del diccionario de
traducción (contador ↔ `INCR`+`EXPIRE`).

### Fase 2 — Sesiones

Sesiones como hash con TTL, set de sesiones activas por usuario, e invalidación
(logout, "cerrar todas las sesiones"). El TTL deja de ser una curiosidad y se
vuelve la mecánica central. 🩻: "la sesión sigue siendo un token opaco que
apunta a un estado; eso no cambió respecto de tu tabla de sesiones". 🪞: el
instinto de guardar la sesión en la base transaccional y por qué infla lo que
no debe.

### Fase 3 — Cola de trabajos

Encolar trabajo diferido con listas (`LPUSH`/`BRPOP`) y luego con streams y
grupos de consumidores. Se mide el coste del polling a una tabla Postgres
frente al bloqueo nativo. 🪞: *"tu instinto dice 'tabla `jobs` con columna
`status` y un worker que hace `SELECT ... WHERE status='pending' FOR UPDATE
SKIP LOCKED`'"* —que funciona, y el curso lo respeta— *"pero mira el costo por
trabajo cuando el volumen sube"*. Aparece el matiz honesto: para colas serias y
durables hay herramientas dedicadas; aquí se mide dónde está la frontera.

### Fase 4 — Leaderboard

El caso donde la estructura *es* el problema: un sorted set es un ranking. Top-N,
rango de un jugador, ventanas por periodo. 🪞: el `ORDER BY score DESC LIMIT 10`
recalculado en cada lectura vs el orden mantenido incrementalmente. ⭐ Fase
central del "esto en memoria es de otra liga".

### Fase 5 — Atomicidad

Operaciones atómicas de una sola clave, `MULTI`/`EXEC`, scripting Lua y `WATCH`
(compare-and-set optimista). Aquí el lector relacional reconoce viejos amigos
con caras nuevas. 🩻: "la atomicidad y el optimistic locking que conoces de SQL
siguen valiendo; cambian las primitivas, no el concepto". 📖 diccionario:
transacción ↔ `MULTI`/`EXEC`, `SELECT FOR UPDATE` ↔ `WATCH`.

### Fase 6 — Concurrencia y condiciones de carrera

Locks distribuidos, el doble-consumo de un trabajo, el rate limit que se escapa
bajo ráfaga. Ejercicios de diagnóstico: se entrega una race condition y se pide
reproducir y cerrar. 🪞: el instinto de "lo arreglo con una transacción" y por
qué en un sistema distribuido el lock tiene aristas (expiración, dueño, reloj)
que la transacción de un solo nodo no tenía.

### Fase 7 — Persistencia

Qué significa "durabilidad" en un motor que vive en RAM: snapshotting periódico
vs append-only file, y —crucialmente— **qué se pierde exactamente cuando el
proceso muere**. Esta fase alimenta directamente la autopsia del villano: si tu
fuente de verdad vive aquí, esto es lo que te juegas. ⚠️ diferencias reales de
durabilidad entre los tres motores.

### Fase 8 — Memoria y evicción

El recurso es finito y está en RAM. Políticas de evicción (`allkeys-lru`,
`volatile-ttl`, etc.), presión de memoria, qué pasa al chocar con `maxmemory`.
🪞: el instinto relacional asume "la base crece en disco y ya"; en memoria, el
tamaño del dataset es una decisión de arquitectura, no un detalle.

### Fase 9 — Escala

Réplicas, clustering y particionado por clave (hash slots). Cómo reparte cada
motor, y qué garantías se relajan al distribuir. Se contrasta el modelo de
cluster de Valkey/Redis con el de Dragonfly.

### Fase 10 — Producción

Observabilidad (`SLOWLOG`, métricas, latencia de comandos), y la integración
real: Portalón sentado delante de un backend transaccional, absorbiendo el
tráfico que no debe llegar a Postgres. La señal de que quedó bien: *"apago el
gateway y el backend se ahoga; lo enciendo y respira. Esa es la capa caliente
haciendo su trabajo"*.

### Fase 11 — ⚰️ Autopsia del villano y ⚖️ veredicto honesto

Se construye el subsistema villano —el dominio de negocio entero metido en
clave-valor— y se le hace la autopsia **con números**: consultas ad-hoc sin
índice secundario, memoria desbordada, pérdida al morir, mantenimiento manual
de índices. Enfrentado a su equivalente honesto en Postgres. Cierra con el
⚖️ árbol de decisión de **cuándo NO usar clave-valor**: cuando necesitas
consultas que no anticipaste, cuando el dato es la fuente de verdad, cuando la
durabilidad es innegociable, cuando el dataset excede la RAM disponible.

### Coda (Fase 12) — 🎼 El mismo escenario en TypeScript, Java y Go

Todo el curso se construyó en TypeScript, y eso podría dejar la falsa impresión
de que lo aprendido es "clave-valor con Node". No lo es: el modelo vive en el
motor y en el protocolo, no en el runtime. La coda lo demuestra portando un
subsistema representativo del gateway —la propuesta por defecto es el rate
limiter de ventana deslizante, porque combina sorted set, TTL y una operación
atómica en una pieza pequeña y medible— a **Java** y a **Go**, y corriéndolo
contra los mismos tres motores en memoria con el mismo `vs.ts` como árbitro.

La lección transferible es doble. La primera mitad es un 🩻 grande: *"el
protocolo RESP viaja igual entre lenguajes, como el SQL básico viaja entre
drivers JDBC, `pq` y `pg`"*. `ZADD`, `EXPIRE`, `EVAL` son los mismos comandos;
lo único que cambia es la envoltura idiomática de cada cliente —futuros y Netty
en Java, `context.Context` y errores explícitos en Go, promesas en Node. Un
senior que ya modeló el subsistema una vez lo reconoce de inmediato en los
otros dos runtimes.

La segunda mitad conecta directamente con la nota de gobernanza del curso, y es
donde cae un 🪞 propio de la coda. En 2026 hay dos filosofías de cliente
conviviendo, y elegir entre ellas es una decisión de arquitectura, no de gusto:

| Enfoque | Ejemplos por lenguaje | Qué prioriza |
|---|---|---|
| **Cliente idiomático clásico** | Node: `ioredis`/`node-redis`; Java: Lettuce/Jedis; Go: `go-redis`/`valkey-go` | Encaja con las convenciones del lenguaje; ecosistema maduro y conocido |
| **Cliente unificado (Valkey GLIDE)** | El mismo GLIDE con bindings a Node, Java, Go, Python | Núcleo compartido en Rust: mismas best-practices y comportamiento entre lenguajes |

Valkey GLIDE es interesante justamente porque su **núcleo está escrito una vez
en Rust** y se expone a cada lenguaje mediante bindings, de modo que la lógica
de reconexión, topología de cluster y pipelining es idéntica en Java, Go y
Node. El 🪞 aquí es: *"tu instinto dice 'un cliente por lenguaje, cada uno con
sus mañas'; el enfoque GLIDE dice 'un comportamiento, tres fachadas'"*. La coda
**mide** ambos: ¿paga el cliente unificado su promesa de consistencia sin
penalización de latencia frente al cliente idiomático más pulido de cada
lenguaje? Ese duelo —clásico vs GLIDE, por lenguaje— entra en `BENCHMARKS.md`
como cualquier otro.

> ⚠️ El estado de madurez de cada cliente **debe verificarse al redactar**: en
> 2026 algunos bindings de GLIDE (p.ej. el de Go) venían saliendo de preview,
> y el conjunto de comandos soportado no siempre es completo. La coda no asume
> paridad: la comprueba antes de comparar, y lo deja escrito.

La coda cierra con la señal de que quedó bien del curso entero: *"me cambian el
lenguaje del servicio de Node a Go o Java y no vuelvo a aprender el modelo:
reconozco los mismos comandos, las mismas estructuras y las mismas fronteras.
Aprendí un modelo de acceso, no un cliente"*.

### Apéndices

- **A) Arranque de motores vía contenedores** — Compose de Valkey, Redis, Dragonfly y Postgres, puertos, healthchecks.
- **B) `docker-compose.yml` / `Containerfile` de trabajo** — el archivo real y comentado del laboratorio.
- **C) Guía rápida de comandos RESP** — el subconjunto de comandos por estructura (strings, hashes, listas, sets, sorted sets, streams) que el curso usa, con su equivalente conceptual SQL.
- **D) Generador de datos** — cómo se siembran IPs, sesiones, trabajos y jugadores; distribuciones y semillas reproducibles.
- **E) Troubleshooting de setup** — puertos ocupados, diferencias de flags entre motores, conexión desde el gateway, límites de memoria del contenedor.
- **F) Setup multi-lenguaje de la coda** — contenedores/toolchains de Java (JDK LTS) y Go junto al de Node; cómo cada puerto de la coda apunta a los mismos tres motores; cómo `vs.ts` (o un arnés hermano por lenguaje) recoge sus números en el mismo `BENCHMARKS.md`.

---

## 📓 Artefactos acumulativos

**`INSTINTOS.md`** recoge, fase a fase, cada instinto relacional que el curso
pone a prueba: se escribe la **predicción** ("creo que la tabla `requests` con
índice aguantará el rate limit"), se corre el **cronómetro** con `vs.ts`, y se
escribe el **veredicto medido** ("falso: la ventana deslizante en sorted set es
Nx más rápida en p99 en el camino crítico"). Crece con cada 🪞 del curso, y al
final es un mapa personal de dónde el instinto SQL acertó y dónde se equivocó
con este modelo.

**`BENCHMARKS.md`** es el registro de todo "vs" medido con `vs.ts`: cada
corrida con su fecha, su dataset, su configuración de motor y sus números
(p50/p95/p99, throughput). Nada se narra: si está aquí, se midió. Crece en cada
fase que añade un duelo, y es la evidencia que respalda cada afirmación
comparativa del curso —incluida la autopsia final del villano.

Ambos archivos son **acumulativos y versionados con el curso**: no se
reescriben, se les agrega. Al terminar, cuentan la historia completa de qué se
predijo, qué se midió y qué se concluyó.

---

## 📚 Referencias por fase (semilla)

> ⚠️ **Verificar todo.** Las URLs, títulos e IDs de video de abajo son puntos
> de partida y **deben verificarse** antes de citarse en el curso: las versiones
> de la documentación cambian y los enlaces se mueven. No se inventan números de
> página, DOIs ni IDs de video; donde no haya certeza, se marca como pendiente
> de confirmar.

**Documentación oficial (base para todas las fases)**
- Valkey — https://valkey.io/docs/ (verificar que apunta a la línea 9.x)
- Redis — https://redis.io/docs/latest/ (verificar línea 8.x, licencia AGPLv3)
- Dragonfly — https://www.dragonflydb.io/docs (verificar compatibilidad de comandos usados)
- PostgreSQL — https://www.postgresql.org/docs/17/ (rival de control)
- Node.js 24 LTS — https://nodejs.org/docs/latest-v24.x/api/
- Express 5 — https://expressjs.com/ (verificar que la doc es de la v5)

**Por fase (orden de lectura sugerido entre paréntesis)**
- **Fase 0–1 (rate limiting):** doc de comandos `INCR`/`EXPIRE`/`ZADD` del motor (1º) → patrones de rate limiting con ventana deslizante (2º, verificar autor/fecha) → arnés `vs.ts` propio (3º).
- **Fase 2 (sesiones):** comandos de hash y TTL (1º) → patrón de session store (2º).
- **Fase 3 (colas):** listas y `BRPOP` (1º) → streams y grupos de consumidores (2º) → comparación con `FOR UPDATE SKIP LOCKED` en Postgres (3º, doc oficial de PG).
- **Fase 4 (leaderboard):** sorted sets, `ZRANGEBYSCORE`, `ZRANK` (1º).
- **Fase 5 (atomicidad):** `MULTI`/`EXEC`, scripting Lua, `WATCH` (1º).
- **Fase 6 (concurrencia):** patrones de lock distribuido (1º, verificar la discusión de correctitud) → algoritmos de exclusión mutua distribuida (2º).
- **Fase 7 (persistencia):** doc de snapshotting y append-only de cada motor (1º).
- **Fase 8 (memoria):** políticas de evicción y gestión de memoria (1º).
- **Fase 9 (escala):** clustering y réplicas de cada motor (1º).
- **Fase 10 (producción):** `SLOWLOG`, métricas y observabilidad (1º).
- **Fase 11 (autopsia):** la propia `BENCHMARKS.md` del curso (1º) — la evidencia es interna.
- **Coda (Fase 12, multi-lenguaje):** página de clientes recomendados del motor (1º, verificar estado por lenguaje) → doc del cliente idiomático de Java elegido y del de Go (2º) → doc de Valkey GLIDE y sus bindings por lenguaje (3º, verificar madurez de cada binding). No se citan versiones de cliente de memoria: se fijan y verifican al redactar.

**Libros y video (verificar todo antes de citar)**
- Libros de referencia sobre patrones de datos en memoria y diseño de sistemas con caché existen; **no se citan títulos, autores ni ISBNs de memoria**: se localizan y verifican al redactar cada fase.
- Screencasts / crash courses de YouTube: se buscan y verifican al redactar; **no se inventan IDs de video**.

---

## 🧪 Nota sobre ejercicios

Cada fase lleva entre **20 y 40 ejercicios** graduados 🟢🟡🟠🔴, todos anclados
al dominio de Portalón (IPs, sesiones, trabajos, jugadores; nunca ejemplos
abstractos). Distribución sugerida para ~30 ejercicios: ~8 🟢 (calientan:
comandos básicos, TTL, un contador), ~9 🟡 (intermedios: ventana deslizante,
set de sesiones, encolar y consumir), ~7 🟠 (difíciles: scripting Lua, top-N con
paginación, evicción), ~4–6 🔴 (muy difíciles: integrar varias fases, medir un
duelo en `vs.ts`, cerrar una condición de carrera bajo contención). Los 🔥
opcionales van aparte, sin numeración continua.

Al menos un puñado por fase son de **diagnóstico**: se entrega un bug —un rate
limit que se escapa bajo ráfaga, un trabajo consumido dos veces, una sesión que
no expira— y se pide **reproducir y localizar**, no solo construir. Los 🔴 más
duros exigen abrir `vs.ts`, medir y escribir el veredicto en `INSTINTOS.md`.

---

## 🧩 Decisiones pendientes de confirmar antes de redactar la Fase 0

- [ ] **Cliente Node:** ¿`ioredis`, `node-redis`, `iovalkey` o Valkey GLIDE? (propuesta por defecto: un cliente RESP que apunte a los tres motores sin cambiar código; confirmar cuál da mejor paridad entre Valkey/Redis/Dragonfly en 2026).
- [ ] **Clientes de la coda (Java y Go):** ¿cliente idiomático clásico (Lettuce/Jedis en Java, `go-redis`/`valkey-go` en Go) o Valkey GLIDE en ambos? (propuesta: medir clásico *vs* GLIDE en cada lenguaje; **verificar la madurez y el conjunto de comandos de cada binding de GLIDE al redactar**, ya que algunos venían saliendo de preview en 2026).
- [ ] **Alcance de la coda:** ¿qué subsistema se porta a Java y Go? (propuesta: el rate limiter de ventana deslizante, por combinar sorted set + TTL + atomicidad en una pieza pequeña y medible; confirmar si se porta uno o dos).
- [ ] **¿Los tres motores desde Fase 0 o escalonados?** (propuesta: los tres en memoria desde Fase 0, ya que comparten protocolo; Postgres de control entra en Fase 1, donde nace la primera medición comparativa).
- [ ] **Dataset semilla:** volumen y distribución de IPs/sesiones/trabajos/jugadores (propuesta: colas largas y ráfagas realistas; fijar tamaños concretos por subsistema al montar el generador).
- [ ] **Cola: ¿lista, stream o ambos?** (propuesta: empezar con lista en Fase 3 y presentar streams como evolución en la misma fase, midiendo el trade-off).
- [ ] **Villano: ¿se implementa de verdad o se documenta como diseño?** (propuesta: implementarlo *lo justo* para medirlo —la autopsia exige números reales—, no un sistema completo).
- [ ] **Versiones exactas al pin:** fijar el patch exacto de Valkey 9.x, Redis 8.x, Dragonfly 1.x y Postgres 17.x el día de arrancar (las líneas están confirmadas; el patch se clava al momento).
- [ ] **Formato de fase:** confirmar la plantilla de 9 secciones adaptada al modelo (con 🪞/🩻/⚰️/📖 donde caen) antes de redactar la primera.

---

## 💭 Consideraciones adicionales

### Valkey, Redis y la gobernanza como decisión técnica (nota especial)

Este curso trata el episodio de la licencia como **parte del modelo**, no como
chisme de industria. En 2024 Redis cambió su licencia a source-available, y la
Linux Foundation lanzó Valkey como fork abierto; para 2026, Redis 8.x volvió a
open source (AGPLv3) y Valkey consolidó su línea 9.x bajo BSD y gobernanza de
fundación. La lección para un senior es que **elegir motor hoy es también
elegir gobernanza**: quién controla la hoja de ruta, bajo qué licencia
despliegas, qué pasa si el proyecto vuelve a cambiar de manos. Entender ese
episodio es tan parte de "aprender la familia clave-valor" como entender
`EXPIRE`. El curso no toma partido militante: expone los hechos, mide lo
técnico, y deja que el criterio —no la bandera— decida.

### Costo operativo del modelo

Cada motor en memoria que entra en una arquitectura es una **superficie
operativa nueva**: backups (que aquí significan snapshots y su recuperación),
monitoreo de memoria (porque el recurso es finito y volátil), una guardia que
entiende evicción y persistencia, y la disciplina de **no dejar que se
convierta en la fuente de verdad por comodidad**. El curso nombra este costo
explícitamente: la velocidad no es gratis, se paga en superficie operativa, y
esa cuenta se hace antes de adoptar, no después.

### Límites de la analogía con SQL

El modelo en memoria conserva más de SQL de lo que el lector teme (atomicidad,
optimistic locking, índices conceptuales vía estructuras) pero rompe cosas que
el lector da por sentadas: no hay consultas ad-hoc sobre valores, no hay
integridad referencial, no hay "pregúntale cualquier cosa a la base". El curso
marca esa frontera con los recuadros 🩻 (lo que viaja igual) y 🪞 (lo que no) en
cada fase, para que el lector no la cruce por inercia.

### Por qué la coda cierra el curso (y no es relleno)

La coda no es un "bonus de idiomas": es la prueba final de la tesis de toda la
ruta —se enseña un **modelo de acceso**, no un producto ni un lenguaje—. Portar
un subsistema a Java y Go y verlo comportarse igual contra los mismos motores
es la demostración empírica de que lo aprendido sobrevive al cambio de runtime.
Además paga un dividendo realista: en un sistema de suficiente escala, distintos
servicios están escritos en distintos lenguajes y todos hablan con la misma capa
caliente; un senior debe saber que el modelo no cambia y que la decisión real es
qué familia de cliente adopta (idiomático clásico vs unificado GLIDE) y qué
cuesta esa elección. Conviene mantener la coda **acotada** —un subsistema, no
los cuatro— para que sume claridad sin diluir el foco del curso, que es el
modelo, no un tour de clientes.

### Validación contra un mercado real (productizable: ✅ Fuerte)

Portalón se valida contra un mercado que existe y se paga: los gateways de API,
los rate limiters gestionados, los session stores y los sistemas de cola son
categorías con productos comerciales vivos (gateways gestionados, colas como
servicio, plataformas de leaderboard para gaming). Que ese mercado exista es la
prueba de que el problema es real y de que el modelo clave-valor es la respuesta
correcta a esa forma. El curso ancla cada subsistema a su contraparte comercial
para que el aprendizaje quede pegado a una necesidad de negocio verificable, no
a un ejercicio de laboratorio.
