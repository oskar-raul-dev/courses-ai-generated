# ⚡ Proyecto Libro Mayor — Semilla del curso (NewSQL / distribuido con ACID)

## 🎯 Motivación

Hay una clase de sistemas —dinero, saldos, inventario comprometido, límites de
crédito— donde la corrección no es negociable y la geografía tampoco. El patrón
de acceso es incómodo por definición: **escrituras cortas que tocan pocas filas
pero deben ser atómicas entre sí, leídas inmediatamente después por usuarios que
están a 200 milisegundos de distancia física del nodo que las escribió**. Cada
transferencia toca dos cuentas que pueden vivir en continentes distintos; cada
consulta de saldo tiene que ver el efecto de la transferencia anterior o alguien
gasta dos veces el mismo dinero; y encima el regulador exige que los datos de un
ciudadano europeo no salgan de Europa.

El modelo relacional resuelve la primera mitad de eso mejor que nadie. Un
Postgres bien afinado te da serializabilidad real, restricciones declarativas y
un optimizador que lleva cuarenta años puliéndose. Lo que no te da —porque no
fue diseñado para darlo— es esa misma garantía **cuando el dato deja de caber en
un nodo autoritativo único**. La arquitectura clásica supone un árbitro central:
un primario que decide el orden de los commits, y réplicas que lo siguen con
retraso. En cuanto la latencia entre regiones entra en la ecuación, esa
suposición se cobra su precio de tres formas conocidas: o los usuarios lejanos
escriben lento contra un primario remoto, o lees de una réplica atrasada y
pierdes la lectura-después-de-escritura, o partes el sistema en shards a mano y
descubres que acabas de reinventar el commit distribuido —normalmente mal, y
normalmente en el código de aplicación, donde no hay nadie mirando.

De ahí sale el reflejo defensivo que este curso viene a desarmar: **como
distribuir da miedo, se renuncia a algo**. Se renuncia a ACID (sagas,
compensaciones y "consistencia eventual" escritas a mano sobre un motor que
nunca prometió nada) o se renuncia a distribuir (una máquina cada vez más
grande, una réplica asíncrona en la otra región y un failover manual que alguien
ensaya una vez al año). Las dos renuncias parecen prudentes. Las dos son caras.
Y las dos se apoyan en una premisa que dejó de ser cierta: que la disyuntiva es
una ley física.

Lo que un ingeniero senior de bases relacionales gana al dominar este modelo de
acceso no es sintaxis —el SQL viaja casi intacto, y eso es parte de la gracia—
sino **una lectura correcta del costo del consenso**. Aprende a mirar una
transacción y estimar cuántos viajes de red cuesta confirmarla; a decidir el
domicilio de una fila como decisión de producto y no de infraestructura; a
convivir con un aislamiento serializable que aborta transacciones y exige
reintentos en el cliente; y a reconocer, sobre todo, cuándo **no** hace falta
nada de esto, que es la mayoría de las veces. Con ese criterio puede abordar
proyectos que antes esquivaba —ledgers multi-región, sistemas con residencia de
datos obligatoria por regulación, plataformas que crecen más allá del nodo
único— y deja de cometer el error de arquitectura más caro de esta categoría:
construir a mano, en la capa de aplicación, garantías que el motor podía darle
gratis y mejor.

---

## 🏗️ El dominio: un ledger de contabilidad multi-región

**Libro Mayor** es un sistema de contabilidad de cuentas por partida doble para
una plataforma de pagos que opera en tres regiones: América del Norte, Europa y
América del Sur. Cada usuario tiene una o varias cuentas (`accounts`) con saldo
en una moneda; cada movimiento de dinero es un `transfer` que genera dos o más
`postings` cuya suma es exactamente cero. Nada se borra, nada se edita: la
corrección de un asiento equivocado es otro asiento. El libro mayor es inmutable
por diseño, igual que en el papel.

### Por qué este dominio exhibe el patrón sin forzarlo

La partida doble es, ella misma, una invariante multi-fila: *la suma de los
`postings` de un `transfer` es cero, y ninguna cuenta baja de su límite*. Esa
invariante no se sostiene con escrituras independientes ni con "consistencia
eventual con reconciliación nocturna" —bueno, sí se sostiene, y el resultado es
el descuadre que alguien busca a mano el lunes—. Necesita una transacción
atómica sobre filas que, en un sistema global, están repartidas por diseño.

Y están repartidas por dos razones independientes, ninguna caprichosa. La
primera es de **latencia**: una usuaria en Bogotá no debería esperar un viaje de
ida y vuelta a Virginia para ver su saldo. La segunda es de **residencia de
datos**: la cuenta de un residente europeo debe permanecer físicamente en
Europa, lo cual convierte el domicilio de la fila en un requisito de producto,
verificable y auditable, no en un detalle de despliegue.

| Eje del dominio | Cómo se manifiesta en Libro Mayor |
|---|---|
| Invariante cruzada | suma de `postings` = 0; saldo ≥ límite por `account` |
| Distribución del dato | por región del titular (`homeRegion`), no por hash arbitrario |
| Patrón de escritura | transacciones cortas, 2–6 filas, alto volumen, sin lecturas largas |
| Patrón de lectura | saldo actual (fresco, propio) + extracto histórico (tolera atraso) |
| Contención | cuentas de sistema (comisiones, tesorería) tocadas por *todas* las transferencias |
| Evolución | monedas y tipos de cuenta nuevos; el esquema cambia sin ventana de mantenimiento |

Ese quinto renglón —la **cuenta caliente**— es el que hace honesto al dominio.
Un ledger no es un CRUD repartido uniformemente: hay un puñado de filas que
todas las transacciones tocan, y ahí es donde la teoría del consenso deja de ser
teoría. Un curso que esquivara esa fila estaría vendiendo humo.

### El marco de 5 preguntas, aplicado ANTES de modelar

| Pregunta | Veredicto para Libro Mayor |
|---|---|
| ¿Qué se lee junto? | la cuenta y sus últimos movimientos; casi nunca cuentas de dos titulares distintos a la vez |
| ¿Quién custodia la forma y las invariantes? | el motor: partida doble, tipos, moneda y límites son restricciones declarativas, no confianza en la app |
| ¿Cuánto se une en caliente? | poco y acotado: `transfer` ↔ `postings` ↔ `accounts`, siempre por clave |
| ¿Dónde viven las invariantes? | **entre filas y potencialmente entre regiones** — es el corazón del problema |
| ¿Qué pide la operación? | escritura constante, p99 acotado por región, cero pérdida de datos, esquema evolutivo sin downtime, residencia por jurisdicción |

**Veredicto: vota NewSQL 4-1.** El único voto en contra es sincero y el curso lo
respeta: *si todo el negocio vive en una sola región y no supera lo que un nodo
grande aguanta, Postgres gana y NewSQL es sobre-ingeniería*. Ese voto disidente
se mide en la Fase 1 y se vuelve a mirar en el veredicto final. Un curso que
declarara 5-0 estaría mintiendo, y mintiendo justo en la dirección del villano.

### El villano: el falso dilema

El anti-patrón que este curso disecciona con autopsia medida tiene dos caras y
un solo origen —creer que hay que elegir entre corrección y escala:

**Cara A — renunciar a ACID por miedo a escalar.** El ledger se implementa sobre
un almacén sin transacciones multi-clave, y la atomicidad se emula con sagas,
compensaciones y un reconciliador que corre de madrugada. Funciona hasta que un
proceso muere entre el débito y el crédito. El curso lo construye, lo rompe a
propósito y **mide cuánto dinero queda en el limbo** en una ventana de fallo
realista.

**Cara B — forzar un único nodo por miedo a distribuir.** Escalado vertical
hasta donde la tarjeta de crédito aguante, réplica asíncrona en la otra región y
un failover manual documentado en una wiki. El curso lo monta también, y mide
las dos cifras que nadie mide antes del incidente: la latencia p99 del usuario
lejano en operación normal, y el **RPO real** —cuántas transacciones confirmadas
se pierden— cuando la región primaria desaparece.

Y hay una tercera cara, la que comete el fanboy de esta familia y el curso no le
perdona: **usar NewSQL donde no toca**. Un CRUD de una sola región sobre un
clúster de tres nodos paga latencia de consenso en cada commit a cambio de nada.
Ese caso también se mide, con el mismo arnés, y termina en el árbol de decisión
de la última fase.

---

## 📐 Stack (2026, estable y moderno)

Todo el laboratorio corre en contenedores y todo es de acceso gratuito en
entorno de desarrollo. Las versiones de abajo son las estables al escribir esta
semilla (agosto de 2026) y **deben reverificarse antes de redactar la Fase 0**:
esta familia publica versiones mayores cada trimestre.

| Componente | Versión / elección | Rol |
|---|---|---|
| CockroachDB | v25.4.x LTS (self-hosted); v26.x como línea reciente | motor NewSQL principal del proyecto |
| TiDB | v8.5.x LTS (+ TiKV + PD) | rival 1 — arquitectura desagregada, protocolo MySQL |
| YugabyteDB | v2025.2.x LTS (`yugabyted`) | rival 2 — capa SQL de Postgres sobre DocDB |
| PostgreSQL | 17.x | línea base obligatoria: el nodo único contra el que todo se compara |
| Node.js | 24 LTS (*Krypton*) | runtime de la API y del arnés |
| TypeScript | 7.0.x (compilador nativo) | tipado de todo el código; ver nota de riesgo abajo |
| Fastify | 5.x | API HTTP del ledger |
| `pg` (node-postgres) | última | cliente de CockroachDB, YugabyteDB y Postgres (mismo protocolo) |
| `mysql2` | última | cliente de TiDB (protocolo MySQL) |
| Zod | 4.x | validación en el borde de la API |
| Toxiproxy | 2.x | inyección de latencia y particiones entre "regiones" |
| Vitest | última | pruebas del arnés y de las invariantes del ledger |
| Docker / Podman + Compose | última | todo el laboratorio, en cualquier host unix-like (Linux, macOS, Windows vía WSL2) |
| Prometheus + Grafana | última | métricas de los clústeres y del arnés |

### Por qué CockroachDB como motor principal

Porque es el que más lejos lleva la tesis del curso hasta el nivel del lenguaje:
la geo-partición se declara en SQL (`REGIONAL BY ROW`, `ADD REGION`,
`SURVIVE REGION FAILURE`) en vez de configurarse aparte, y eso permite enseñar
el domicilio del dato como decisión de modelado y no de infraestructura. Habla
protocolo Postgres, así que el cliente y buena parte del SQL viajan sin cambios
desde la línea base —que es exactamente el 🩻 *"esto sí viaja igual"* de este
curso. Una advertencia que la semilla deja escrita para no fingir después: desde
la versión 24.3 se publica bajo la **CockroachDB Software License**, no bajo
Apache. Es gratuito para el uso de desarrollo y aprendizaje de este curso, pero
**no es software libre**, y el curso lo dice donde toca en vez de esconderlo.
Los dos rivales, en cambio, son Apache 2.0: ese contraste es materia del curso,
no ruido.

### Por qué TiDB y YugabyteDB como rivales

Porque representan las dos alternativas arquitectónicas reales, no dos marcas de
lo mismo. **TiDB** separa cómputo (TiDB) de almacenamiento (TiKV) y de la
asignación de timestamps (PD), habla MySQL, y resuelve las transacciones
distribuidas con un esquema optimista de dos fases derivado de Percolator. Ese
diseño desagregado se paga y se cobra en lugares distintos que el de Cockroach,
y medirlo enseña más que leerlo. **YugabyteDB** reutiliza directamente la capa
SQL de PostgreSQL sobre un almacén distribuido propio (DocDB), lo cual le da la
compatibilidad más literal con el mundo del que viene el lector —y una pregunta
incómoda y fértil: si el SQL es el mismo, ¿qué cambia debajo, y cuánto cuesta?
Los tres comparten la promesa; ninguno la cumple igual, y esa es la razón de que
el "vs" no se narre.

Postgres 17 no es un rival: es el **testigo**. Sin una línea base de un solo
nodo, cualquier número de un clúster distribuido es un número sin escala.

### Por qué TypeScript sobre Node 24 LTS

El curso no enseña un lenguaje, enseña un patrón de acceso, así que el criterio
es el más aburrido posible: tooling multiplataforma, contenedores triviales,
clientes maduros para los dos protocolos en juego (`pg` y `mysql2`) y tipos que
hagan explícito lo que en un ledger nunca debe ser implícito —**el dinero es un
entero en unidades mínimas**, `amountMinor` con su `currency`, jamás un `float`.
Node 24 es el Active LTS en la fecha de esta semilla; Node 26 entra en LTS en
octubre de 2026 y probablemente sea el objetivo cuando el curso se redacte, así
que la Fase 0 lo reverifica.

Sobre TypeScript hay una decisión con riesgo que conviene tomar con los ojos
abiertos: **7.0 es muy reciente** (compilador nativo en Go, sin API programática
estable hasta 7.1). Si al redactar la Fase 0 el ecosistema de Vitest y los
plugins todavía cojea, la semilla autoriza caer a **TypeScript 6.0** sin
discusión; nada del contenido del curso depende de esa elección. Queda anotado
en las decisiones pendientes.

### Por qué Toxiproxy

Porque sin latencia entre regiones no hay curso. Los clústeres corren en un solo
host, y una red local no enseña nada sobre consenso: todo parece gratis.
Toxiproxy se interpone entre nodos y les inyecta los 80–160 ms de ida y vuelta
que separan de verdad a tres regiones, además de particiones limpias para los
ejercicios de supervivencia. Es la pieza que convierte el laboratorio en un
simulador honesto en vez de una demo.

### Validación y tooling transversal

La validación va en dos capas y la semilla lo fija desde ahora, porque en un
ledger la diferencia importa: **Zod** valida la forma del request en el borde de
la API (buena experiencia de desarrollo, mensajes en español para el cliente), y
las **restricciones del motor** —`CHECK`, claves foráneas, unicidad,
transacciones— sostienen las invariantes que ningún cliente puede esquivar. Si
la única defensa del cuadre contable vive en TypeScript, no existe.

El generador de datos (`scripts/seed.ts`) produce el mismo dataset semántico en
los cuatro motores: titulares repartidos por región, cuentas, un histórico de
transferencias y —deliberadamente— un puñado de cuentas de sistema que
concentran contención.

---

## ⚖️ El método del "vs": un arnés, no anécdotas

`scripts/vs.ts` es el corazón metodológico del curso y nace en la Fase 0, antes
que cualquier contenido. Su contrato es simple: recibe un **escenario semántico**
(por ejemplo, "transferir entre dos cuentas de regiones distintas, 500 veces, con
32 clientes concurrentes"), lo ejecuta contra cada motor configurado usando el
dialecto que ese motor entiende, y devuelve siempre las mismas métricas: latencia
p50/p95/p99, throughput sostenido, tasa de aborto por conflicto de
serialización, número de reintentos y errores por categoría. Nada se reporta a
ojo; el número que no salió del arnés no entra en el curso.

Tres reglas que el arnés impone y que valen más que su código: se ejecuta una
fase de calentamiento y se descarta; se corre cada escenario contra los cuatro
motores en la misma sesión y con la misma topología de latencia; y todo
resultado se anexa a `BENCHMARKS.md` con la versión exacta de cada motor, la
configuración de Toxiproxy y el commit del arnés. Un benchmark sin esos tres
datos no es reproducible, y uno no reproducible es marketing.

Los duelos que atraviesan el curso:

1. **Clúster NewSQL vs Postgres de un nodo** — el eje. Cuánto cuesta el consenso
   cuando no lo necesitas, y cuánto vale cuando sí.
2. **CockroachDB vs TiDB vs YugabyteDB** — tres implementaciones del mismo
   contrato: aislamiento, reintentos, geo-partición, DDL en línea, recuperación.
3. **Transacción distribuida vs saga hecha a mano** — el villano medido en su
   propio terreno: latencia contra dinero perdido en el limbo.

---

## 🌳 Estructura de fases

Trece fases (0 a 12). El rango es holgado porque este modelo obliga a separar
tres cosas que suelen mezclarse —aislamiento, distribución y supervivencia— y
cada una necesita su propia medición.

| # | Fase | Núcleo | "Vs" de la fase |
|---|---|---|---|
| **0** | 🧪 El laboratorio de cuatro motores | Compose con Cockroach + TiDB + Yugabyte + Postgres, Toxiproxy, generador de datos; nace `vs.ts` | — (montaje y latencia base) |
| **1** | ⚖️ El falso dilema, medido el primer día | CAP/PACELC como presupuesto de latencia; el marco de 5 preguntas | Postgres 1 nodo vs clúster de 3: la misma transacción, con y sin red entre medio |
| **2** | 📖 Partida doble: el esquema del ledger | `accounts`, `transfers`, `postings`; invariantes declarativas; inmutabilidad | El mismo DDL en los cuatro motores: qué se acepta igual y qué no |
| **3** | 🔑 La clave primaria que decide tu escala | Secuencias vs UUIDv7 vs índices hash-sharded: el hotspot de escritura | Throughput de inserción por estrategia de clave, motor por motor |
| **4** | 🧭 Serializable por defecto y el reintento obligatorio | Conflictos de serialización, backoff, savepoints; dónde vive el reintento | SSI de Cockroach vs optimista/Percolator de TiDB vs Yugabyte |
| **5** | 🌍 El domicilio del dato | Geo-partición, `REGIONAL BY ROW`, placement, tablespaces; residencia regulatoria | Latencia de lectura y escritura local vs remota en los tres motores |
| **6** | ⏱️ La factura del consenso | Raft, quórum, relojes y timestamps; anatomía de un commit cross-región | Costo por commit según distancia y número de réplicas |
| **7** | 🔥 La cuenta caliente | Contención sobre cuentas de sistema; saldo particionado, batching, colas | Throughput bajo contención extrema, con y sin patrón de mitigación |
| **8** | 📸 Leer el pasado sin bloquear el presente | Lecturas históricas y de seguidor; extractos y reportes sobre snapshots | Follower reads vs réplica de lectura de Postgres: frescura contra latencia |
| **9** | 💥 Matar un nodo, una zona, una región | Chaos con Toxiproxy; qué ve la app durante el fallo; RPO/RTO reales | Failover automático del clúster vs failover manual del primario Postgres |
| **10** | 🔄 Cambiar el esquema con el negocio encendido | DDL en línea, columnas nuevas, backfill, moneda nueva sin ventana | Online DDL de los tres motores vs `ALTER TABLE` bloqueante |
| **11** | 📊 Operar esto un martes a las 3 am | Métricas, rangos calientes, plan distribuido, backups, restauración puntual | Superficie operativa comparada de los tres |
| **12** | ⚰️ Autopsia del falso dilema y ⚖️ veredicto | Las dos caras del villano, medidas; árbol de decisión de cuándo NO usar NewSQL | Saga a mano vs transacción distribuida vs Postgres monolítico |

### Fase 0 — 🧪 El laboratorio de cuatro motores

Levanta todo el entorno en contenedores: un clúster de tres nodos de
CockroachDB, un TiDB completo (PD + TiKV + TiDB), un YugabyteDB de tres nodos,
un Postgres de un nodo, Toxiproxy delante de la red interna de cada clúster y
Prometheus/Grafana observándolo todo. Se etiqueta cada nodo con su "región"
simulada y se calibra la latencia. Se escribe el generador de datos y nace
`vs.ts` con su primer escenario trivial: un `INSERT` de una fila, cuatro
motores, cuatro números. La fase termina cuando `BENCHMARKS.md` tiene su primera
tabla y cualquiera puede reproducirla con un comando.

### Fase 1 — ⚖️ El falso dilema, medido el primer día

Aquí se instala el marco: las 5 preguntas aplicadas a Libro Mayor, y CAP y
PACELC presentados no como trivia de entrevista sino como lo que son, un
presupuesto de latencia. 🪞 **Primer instinto falsable:** *"un clúster
distribuido siempre escribe más lento que un nodo único"*. El lector escribe su
predicción numérica antes de correr nada; el arnés mide una transacción local en
Postgres, la misma en Cockroach con las tres réplicas en la misma zona, y luego
con las réplicas separadas. El veredicto queda escrito en `INSTINTOS.md` con el
número, no con una impresión. 🩻 **Esto sí viaja igual:** SQL, DDL, tipos,
transacciones explícitas, `EXPLAIN`, índices y el modelo mental de selectividad.

### Fase 2 — 📖 Partida doble: el esquema del ledger

Se modela el ledger de verdad: `accounts`, `transfers`, `postings`, con dinero
en enteros de unidad mínima, `currency` acotada y las invariantes expresadas como
restricciones del motor. Se escribe la primera transferencia atómica y su
prueba: una transacción que sale a la mitad no deja rastro. 📖 **Diccionario de
traducción** desde el paradigma relacional clásico: qué significa aquí "tabla",
"clave primaria", "réplica", "commit", "aislamiento" y "particionamiento" cuando
debajo hay rangos replicados por Raft en vez de archivos en un disco.

### Fase 3 — 🔑 La clave primaria que decide tu escala

La fase donde más instintos se rompen. 🪞 *"Uso `SERIAL`, como siempre"*: en un
motor distribuido, una clave monótona concentra todas las escrituras nuevas en
el mismo rango y el mismo nodo, y el clúster de tres nodos rinde como uno malo.
Se mide con secuencia, con UUIDv7 y con índices hash-sharded, y el estudiante ve
el reparto en el panel de rangos mientras el arnés cronometra. Es también la
fase que introduce la lectura de la topología física del dato.

### Fase 4 — 🧭 Serializable por defecto y el reintento obligatorio

El aislamiento serializable no es un modo exótico aquí: es la casa. Y trae una
consecuencia que el lector de Postgres conoce en teoría y rara vez sufrió en
producción: **las transacciones abortan por conflicto y el cliente debe
reintentarlas**. Se escribe el `withRetry` del proyecto —backoff exponencial,
límite de intentos, idempotencia de la operación— y se mide la tasa de aborto de
cada motor bajo la misma carga. 🩻 Lo que viaja igual: el razonamiento sobre
anomalías (lectura sucia, no repetible, fantasma) es exactamente el que ya se
domina.

### Fase 5 — 🌍 El domicilio del dato

La geo-partición como requisito de producto: las cuentas europeas se quedan en
Europa, y eso se declara. Se reparte la tabla `accounts` por `homeRegion`, se
configuran las supervivencias (zona o región) y se mide qué pasa con una
transferencia **entre** regiones, que es donde aparece la factura. Cada motor lo
expresa a su manera —SQL declarativo en Cockroach, placement rules en TiDB,
tablespaces en Yugabyte— y el "vs" compara tanto la latencia como la ergonomía
de la declaración.

### Fase 6 — ⏱️ La factura del consenso

La fase conceptual del curso, anclada en medición: Raft, quórum, liderazgo de
rango, y cómo se asignan timestamps sin un reloj global perfecto (relojes
sincronizados con incertidumbre acotada en Cockroach y Yugabyte, timestamp
oracle centralizado en TiDB). Se descompone el costo de un commit cross-región
en viajes de red y se contrasta la cuenta teórica con lo que el arnés midió en
la Fase 5. Cuando la aritmética y el cronómetro coinciden, el modelo mental
quedó bien construido.

### Fase 7 — 🔥 La cuenta caliente

Todas las transferencias tocan la cuenta de comisiones. Una sola fila, miles de
escritores, aislamiento serializable: la tormenta perfecta. Se mide el colapso y
luego se aplican los patrones que lo evitan —saldo particionado en N
sub-cuentas con agregación, escrituras por lote, cola con consolidación
periódica— midiendo cada uno. 💸 Aquí se contrae una **deuda declarada**: el
saldo particionado complica la lectura del total, y esa complicación se paga
explícitamente en la Fase 8.

### Fase 8 — 📸 Leer el pasado sin bloquear el presente

El extracto de cuenta y los reportes contables no necesitan el dato de hace un
milisegundo: necesitan un punto de corte coherente. Se usan lecturas históricas
y lecturas de seguidor para servirlos desde la réplica local, sin coordinar y
sin bloquear a los escritores. 🪞 *"Leer de una réplica es leer datos
inconsistentes"*: aquí no —es leer un snapshot consistente de un instante
anterior, que es otra cosa muy distinta y una herramienta de primera. Se paga la
deuda de la Fase 7 sirviendo el total agregado desde snapshot.

### Fase 9 — 💥 Matar un nodo, una zona, una región

Chaos dirigido: se apaga un nodo durante una carga en curso y se observa qué ve
la aplicación (nada, si el `withRetry` está bien hecho); se particiona una
región y se comprueba qué operaciones siguen y cuáles no según la supervivencia
configurada. En paralelo se ejecuta el mismo experimento contra el Postgres con
réplica asíncrona, y se mide el **RPO real** en transacciones confirmadas y
perdidas. Es la fase donde la cara B del villano deja de ser un argumento y pasa
a ser una cifra.

### Fase 10 — 🔄 Cambiar el esquema con el negocio encendido

Añadir una moneda, un tipo de cuenta, una columna con backfill de millones de
filas — con el ledger recibiendo escrituras. Se comparan los mecanismos de DDL
en línea de los tres motores y se contrasta con el bloqueo del `ALTER TABLE`
clásico bajo carga. Se establece la disciplina de migración expandir-contraer,
que en un sistema que no puede apagarse deja de ser una buena práctica y pasa a
ser la única práctica.

### Fase 11 — 📊 Operar esto un martes a las 3 am

El costo operativo, que en esta familia es la mitad de la decisión: qué métricas
importan (rangos calientes, latencia de consenso, retraso de replicación,
compactaciones), cómo se lee un plan distribuido y en qué se diferencia del
`EXPLAIN` de siempre, cómo se hacen backups y restauración a un punto en el
tiempo, y qué implica la guardia de un clúster de tres capas frente a la de un
Postgres. Aquí se nombra sin adornos lo que cuesta operar cada uno de los tres.

### Fase 12 — ⚰️ Autopsia del falso dilema y ⚖️ veredicto

La fase de cierre ejecuta la autopsia completa del villano, con números
antes/después, sobre el mismo dominio y el mismo arnés. Primero la **cara A**: el
ledger reimplementado como saga con compensaciones sobre un almacén sin
transacciones multi-clave; se mata el proceso entre las dos patas y se cuenta el
dinero en el limbo. Luego la **cara B**: el monolito con réplica asíncrona,
midiendo latencia del usuario lejano y RPO en el failover. Y por último la cara
del fanboy: el CRUD de una región sobre el clúster, pagando consenso por nada.
⚖️ El curso termina en un **árbol de decisión** honesto de cuándo NO usar esta
familia, que empieza por la pregunta más incómoda: *¿de verdad no te alcanza con
un Postgres bien afinado?*

### Apéndices

- **A) Arranque de los cuatro motores en contenedores.** Comandos mínimos por
  motor, inicialización del clúster, verificación de salud y errores típicos de
  primera vez.
- **B) `compose.yaml` y `Containerfile` de trabajo.** El archivo comentado
  completo, con perfiles para levantar solo un motor cuando se está iterando.
- **C) Guía rápida de dialectos.** Diferencias prácticas entre el SQL de
  Postgres, el de Cockroach, el de Yugabyte y el MySQL de TiDB: tipos, DDL,
  sintaxis de reintento y lo que no está soportado.
- **D) El generador de datos.** Modelo de la carga sintética, distribución por
  región y cómo se inyecta contención de forma controlada.
- **E) Simulación de latencia y particiones con Toxiproxy.** Topologías de
  región, valores realistas de ida y vuelta, y cómo particionar limpio.
- **F) Troubleshooting del laboratorio.** Recursos insuficientes, relojes
  desincronizados en el host, puertos ocupados, y qué hacer cuando un clúster no
  forma quórum.

---

## 📓 Artefactos acumulativos

**`INSTINTOS.md`** recoge, fase por fase, cada instinto relacional que el curso
pone a prueba. Su formato es rígido a propósito: el instinto enunciado en
primera persona, la predicción numérica escrita **antes** de medir, el escenario
exacto del arnés, el resultado, y un veredicto de tres estados —confirmado,
matizado o refutado—. Un instinto confirmado vale tanto como uno refutado; lo
que no vale es no haberlo escrito antes. Al final del curso, el documento es el
mapa personal de qué reflejos sobrevivieron al cambio de arquitectura, y es la
pieza que el lector se lleva aunque los tres motores desaparezcan.

**`BENCHMARKS.md`** es el registro de todos los duelos. Cada entrada lleva
escenario, motores y versiones exactas, topología de latencia, número de
clientes concurrentes, métricas (p50/p95/p99, throughput, abortos, reintentos) y
el commit del arnés. Crece por acumulación, nunca por reescritura: cuando una
medición posterior contradice a una anterior, se anexa la nueva explicando la
diferencia en vez de corregir el pasado. Ese hábito es el que convierte al
documento en evidencia y no en folleto.

---

## 📚 Referencias por fase (semilla)

> ⚠️ **Verificar todo.** Las URLs de abajo son las raíces oficiales conocidas al
> escribir esta semilla; las rutas concretas de documentación cambian entre
> versiones mayores y algunos enlaces habrán rotado. Los títulos de libros y
> charlas deben confirmarse antes de citarlos. **No se inventan números de
> página, DOIs ni identificadores de video**: cuando se recomiende una charla o
> screencast, se busca al redactar y se pega la URL verificada.

**Documentación oficial (raíces, válidas para todas las fases)**

- CockroachDB: https://www.cockroachlabs.com/docs/stable/
- TiDB: https://docs.pingcap.com/tidb/stable/
- YugabyteDB: https://docs.yugabyte.com/stable/
- PostgreSQL 17: https://www.postgresql.org/docs/17/index.html
- Toxiproxy: https://github.com/Shopify/toxiproxy
- Node.js: https://nodejs.org/docs/latest-v24.x/api/ · TypeScript: https://www.typescriptlang.org/docs/

**Por fase**

- **Fase 0** — guías de despliegue en contenedores de los tres motores y documentación de Compose. *Orden sugerido:* levantar Cockroach primero (el más simple), luego Yugabyte, TiDB al final (más piezas).
- **Fase 1** — el artículo de Daniel Abadi sobre PACELC y el capítulo de replicación de *Designing Data-Intensive Applications* (Kleppmann). *Orden:* PACELC, luego el capítulo, luego medir.
- **Fase 2** — documentación de tipos y restricciones de cada motor; una referencia canónica de contabilidad por partida doble (verificar antes de citar). *Orden:* partida doble primero, SQL después.
- **Fase 3** — claves primarias, rangos e índices hash-sharded en Cockroach; equivalentes en TiDB (`AUTO_RANDOM`) y en Yugabyte (hash vs range sharding). *Orden:* el concepto de rango, luego cada dialecto.
- **Fase 4** — niveles de aislamiento y reintento de transacciones en los tres motores; el paper de Percolator (Google) para el modelo de TiDB. *Orden:* aislamiento en Postgres como base, luego los tres motores, luego el paper.
- **Fase 5** — capacidades multi-región de Cockroach; placement rules de TiDB; tablespaces y geo-partición de Yugabyte. *Orden:* Cockroach por ser declarativo, luego los otros dos como contraste.
- **Fase 6** — el paper de Raft (Ongaro y Ousterhout), el paper de Spanner (Google) y el paper de CockroachDB publicado en SIGMOD 2020. *Orden:* Raft, Spanner, CockroachDB.
- **Fase 7** — documentación de contención y rangos calientes de cada motor; literatura sobre contadores particionados. *Orden:* medir el colapso antes de leer la solución.
- **Fase 8** — lecturas históricas y follower reads en Cockroach; lecturas con timestamp en TiDB; equivalentes en Yugabyte. *Orden:* la idea de snapshot primero.
- **Fase 9** — guías de tolerancia a fallos y recuperación ante desastres de los tres motores. *Orden:* leer la teoría del quórum, luego romper cosas.
- **Fase 10** — DDL en línea de cada motor; *Database Internals* (Petrov) para el fondo del almacenamiento. *Orden:* expandir-contraer primero, mecanismos después.
- **Fase 11** — guías de monitoreo, backup y restauración de los tres. *Orden:* métricas, backups, restauración puntual.
- **Fase 12** — literatura sobre sagas y sus límites; el árbol de decisión se construye con las mediciones propias, no con fuentes. *Orden:* releer `BENCHMARKS.md` completo antes de escribir el veredicto.

---

## 🧪 Nota sobre ejercicios

Cada fase lleva entre **20 y 40 ejercicios** (objetivo cómodo: 30), numerados de
forma continua y agrupados por rango de dificultad 🟢🟡🟠🔴. Distribución
sugerida para 30: unos 8 🟢, 9 🟡, 7 🟠 y 6 🔴, más los 🔥 opcionales listados
aparte y sin numeración.

Los 🟢 calientan y verifican comprensión ("escribe la transferencia entre dos
cuentas de la misma región y comprueba que la suma de `postings` es cero"). Los
🟡 exigen usar bien una herramienta de la fase. Los 🟠 obligan a medir y a
defender el número con el arnés. Los 🔴 integran varias fases o piden cerrar un
caso esquivo: reproducir una anomalía bajo concurrencia, hacer que una
transferencia cross-región baje de cierto p99 sin romper la invariante, o
sostener throughput sobre la cuenta caliente con el clúster degradado.

Al menos **cinco por fase son de diagnóstico**: se entrega código o
configuración con un fallo plantado —un `withRetry` que reintenta una operación
no idempotente, una clave primaria monótona que serializa el clúster, una
partición mal declarada que saca las cuentas europeas de Europa— y se pide
reproducir, localizar y corregir, en ese orden. Todos los enunciados usan el
dominio: cuentas, transferencias, asientos, regiones y monedas de Libro Mayor,
nunca `foo` y `bar`.

---

## 🧩 Decisiones pendientes de confirmar antes de redactar la Fase 0

- [ ] **Reverificar versiones** de los cuatro motores, de Node y de TypeScript el día de redactar la Fase 0. Propuesta por defecto: la última LTS de cada motor, no la última a secas.
- [ ] **TypeScript 7 o 6.** Propuesta: intentar 7.0.x; si Vitest o algún plugin cojea, caer a 6.0 sin discutirlo en el curso.
- [ ] **¿Entran los tres motores distribuidos desde la Fase 0 o TiDB y Yugabyte llegan más tarde?** Propuesta: los cuatro desde el día 0, con perfiles de Compose para levantar solo lo necesario (TiDB pesa; conviene que sea opcional en el arranque diario).
- [ ] **Presupuesto de recursos del laboratorio.** Propuesta: fijar un mínimo realista (≈16 GB de RAM) y ofrecer un modo reducido de un nodo por motor para máquinas modestas, aceptando explícitamente que ese modo no sirve para medir.
- [ ] **¿Fastify o Express 5 para la API?** Propuesta: Fastify 5; la API es un envoltorio fino y la elección no debe robar protagonismo.
- [ ] **¿La cara A del villano (la saga) se implementa de verdad o se documenta como diseño?** Propuesta: implementarla de verdad y sobre un motor sin transacciones multi-clave, porque el número de "dinero en el limbo" es el argumento más fuerte del curso.
- [ ] **Dataset semilla: ¿sintético o público adaptado?** Propuesta: sintético, con distribución realista de regiones y contención controlada; los datasets públicos de pagos son escasos y sucios.
- [ ] **Topología de latencia canónica.** Propuesta: tres regiones con ida y vuelta de 80 ms (NA↔EU), 120 ms (NA↔SA) y 160 ms (EU↔SA), fijadas en el apéndice E para que todos los números del curso sean comparables.
- [ ] **Formato de fase.** Propuesta: mantener las nueve secciones (propósito, qué queda listo, qué queda fuera, conceptos mínimos, implementación, errores comunes y forense, ejercicios, referencias, cierre).
- [ ] **¿Se incluye una nota sobre licencias y gobernanza?** Propuesta: sí, breve y factual, en la Fase 0 — CSL de Cockroach frente a Apache 2.0 de los rivales; elegir motor también es elegir licencia.

---

## 💭 Consideraciones adicionales

### NewSQL no es NoSQL, y ese es justamente el punto

Conviene decirlo en la primera página del curso y no volver a disculparse:
**esto es relacional**. Tablas, SQL, ACID, restricciones. No pertenece a la
familia de los modelos no relacionales por su modelo de datos, sino por su lugar
en la conversación: nació como respuesta al desafío de escalado horizontal que
originó buena parte del movimiento NoSQL, y su existencia demuestra que la
disyuntiva fundacional —*"o tienes ACID en un nodo, o escalas horizontalmente
sin ACID completo"*— dejó de ser una ley física para volverse una limitación de
implementaciones concretas que esta generación de motores superó. Estudiarlo
cierra el mapa: sin esta pieza, alguien puede terminar convencido de que
renunciar a las transacciones es el precio inevitable de crecer, y tomar en 2026
una decisión que solo tenía sentido en 2010.

### El costo operativo, que es la mitad de la decisión

Un clúster distribuido son tres o más procesos que hay que actualizar en orden,
observar por separado y respaldar con herramientas propias; TiDB son tres tipos
de componente distintos. La curva de aprendizaje del equipo no es la del SQL
—que ya la tienen— sino la de la topología: rangos, líderes, quórums,
compactaciones. La Fase 11 existe para que ese costo se nombre con números y no
como una nota al pie, porque es exactamente donde muchas adopciones se tuercen:
no en el modelado, sino en el tercer mes de guardia.

### Los límites de la analogía con SQL

La compatibilidad de estos motores con Postgres o MySQL es alta y engañosa: el
SQL entra, pero el comportamiento no siempre es el que el hábito espera. Las
transacciones largas se llevan mal con el aislamiento optimista; algunas
funciones y extensiones del ecosistema Postgres no existen; los planes se leen
distinto porque el costo dominante pasa a ser la red; y `SELECT ... FOR UPDATE`
no cuesta lo mismo que en casa. El curso debe marcar esas fronteras
explícitamente en cada fase, con el recuadro 🪞, en vez de dejar que el lector
las descubra en producción.

### Cómo se valida contra un mercado real (⚠️ productizable: media)

Libro Mayor no es un producto B2C: es infraestructura interna, y la semilla no
finge lo contrario. Su validación de mercado es indirecta pero sólida —existe
una categoría entera de productos de ledger como servicio y de núcleos bancarios
modernos, y toda plataforma de pagos, wallet o marketplace con dinero en custodia
termina construyendo algo con esta forma. El valor profesional del curso está
menos en publicar un SaaS y más en dos cosas concretas: poder **auditar** un
ledger ajeno con criterio, y poder **defender con números** una decisión de
arquitectura ante un comité que solo ha escuchado el argumento de que
"distribuir es peligroso" o el contrario, igual de vacío.

### Riesgos de la redacción

Tres, anotados para que no sorprendan. El primero es la **rotación de
versiones**: esta familia publica mayores cada trimestre y algunos ejemplos
envejecerán durante la redacción; conviene fijar versión por fase y revisar al
cierre. El segundo es el **peso del laboratorio**: cuatro motores en un portátil
es mucho, y si el arranque es frustrante el curso pierde lectores en la Fase 0
—por eso el apéndice de troubleshooting no es opcional—. El tercero es la
**tentación de ganar el argumento**: el veredicto de este curso tiene que poder
terminar en "usa Postgres" sin que duela, o el curso se convierte en aquello
contra lo que fue escrito.
