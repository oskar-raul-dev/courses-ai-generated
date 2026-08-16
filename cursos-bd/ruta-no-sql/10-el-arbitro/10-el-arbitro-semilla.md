# ⚖️ Proyecto El Árbitro — Semilla del curso (persistencia políglota: no un modelo nuevo, sino el costo de combinar varios)

## 🎯 Motivación

Casi todos los cursos de bases de datos se organizan alrededor de una
pregunta cómoda: dado este patrón de acceso, ¿qué motor lo sirve mejor? Es
una buena pregunta, pero es la pregunta de un sistema de juguete. Los
sistemas reales, pasado cierto tamaño, no tienen *un* patrón de acceso:
tienen cinco o seis, genuinamente distintos, conviviendo en el mismo
producto y compitiendo por la misma máquina. La ficha de un producto se lee
entera y se escribe entera. El contador de reservas se lee mil veces por
segundo y expira solo. La búsqueda facetada quiere un índice invertido con
conteos. El libro contable quiere ACID y una auditoría que nadie pueda
tocar. El panel de dirección quiere escanear diez millones de filas por dos
columnas. Cada uno de esos patrones, aislado, tiene una respuesta clara. El
problema es que aparecen juntos.

Ese es el patrón de acceso que enseña este curso, y conviene nombrarlo con
precisión porque no es "muchos patrones": es **la heterogeneidad de patrones
dentro de un mismo sistema, más el problema derivado que nadie factura al
principio — mantener coherentes varias copias de la misma verdad**. En el
momento en que un dato vive en dos motores, aparece una pregunta que ningún
motor resuelve solo: quién es la fuente de verdad, por dónde viaja el cambio,
cuánto tarda en llegar, qué pasa cuando no llega, y cómo te enteras. Ese
tránsito —la costura entre almacenes— es el objeto de estudio real de este
curso. Los motores son el decorado.

Un motor relacional moderno puede, honestamente, con casi todo esto. Puede
guardar documentos con validación, hacer búsqueda de texto con ranking,
servir de cola con `SKIP LOCKED`, expirar filas con un job, y responder
consultas analíticas si le das la RAM. No fue *diseñado* para hacerlo todo
bien al mismo tiempo, y ahí está el matiz que separa a un arquitecto de un
entusiasta: el problema no es de expresividad, es de **interferencia**. Una
consulta analítica que barre la tabla de pedidos compite por caché de páginas
con las transacciones de compra; un índice invertido que se reconstruye
compite por I/O con el checkpoint; un contador caliente actualizado mil veces
por segundo genera bloat y trabajo de vacuum que el planificador de la
consulta de al lado va a pagar. Separar motores es, antes que nada, una
decisión de **aislamiento de cargas** — y solo después, a veces, una decisión
de rendimiento bruto.

Lo que separar motores nunca es: gratis. Cada motor que un sistema adopta
trae una superficie operativa completa y propia. Una imagen y una versión que
mantener. Un procedimiento de backup y —lo que casi nadie ensaya— un
procedimiento de *restore* verificado. Un conjunto de modos de fallo que hay
que aprender a reconocer a las tres de la mañana con los ojos hinchados. Un
dashboard, unas alertas, un runbook, un umbral de disco. Una curva de
aprendizaje para cada persona que entre al equipo en los próximos cinco
años. Y, sobre todo, un problema de consistencia nuevo que **antes no
existía**. Esa suma es la factura, y el curso entero existe para que aprendas
a leerla antes de firmarla.

Un ingeniero senior de bases relacionales que domina esto gana tres cosas
concretas. Gana la capacidad de **defender una arquitectura con números** en
la reunión donde alguien propone sumar el motor de moda: no con escepticismo
de veterano, sino con un benchmark propio y un cálculo de costo operativo.
Gana la capacidad opuesta y más difícil —**decir que sí con criterio**,
sabiendo exactamente qué cuota mensual está firmando y qué clase de fallo
está comprando a cambio. Y gana el oficio de la costura: outbox, CDC,
idempotencia, reconciliación, reindexado desde cero, restore coherente entre
almacenes. Ese oficio es hoy el trabajo real de la mayoría de los sistemas de
tamaño medio, y casi nunca se enseña, porque no es de nadie: no lo enseña el
curso de Postgres, no lo enseña el curso del motor de búsqueda, y desde
luego no lo enseña el proveedor.

El error de arquitectura que deja de cometer es específico y muy caro:
**adoptar un motor por su mejor caso y operarlo en su peor caso**, sin haber
puesto jamás un cronómetro ni una hoja de costos sobre la mesa. Y el error
simétrico, igual de caro y mucho menos comentado: mantener durante años una
carga que ya no cabe en un solo motor, porque sumar uno le da miedo y a
"miedo" nadie le pone número.

---

## 🏗️ El dominio: Ágora, una plataforma de venta de entradas para eventos en vivo

**Ágora** vende entradas para eventos en vivo: conciertos, teatro, deporte
amateur, conferencias, ferias. Organizadores publican eventos, el público
busca y compra, la gente entra por una puerta donde alguien escanea un
código, y a fin de mes hay que liquidarle dinero real a cada organizador con
un detalle que resista una auditoría.

El dominio se eligió por una razón y una sola: es el sistema más pequeño que
se me ocurre donde los patrones de acceso son **honestamente distintos entre
sí** y ninguno se puede tirar por la borda diciendo "eso no es el core". No
hay forma de argumentar que el ledger de pagos y la búsqueda facetada quieren
la misma estructura física. No hay forma de argumentar que el contador de
asientos disponibles de un show que sale a la venta en dos minutos se parece
al panel de cohortes que mira el equipo de marketing una vez por semana. La
heterogeneidad no está forzada por el ejercicio: está en el producto.

### Los patrones de acceso que conviven en Ágora

| Patrón | La pregunta que responde | Forma natural del dato | Qué le duele si lo fuerzas al motor equivocado |
|---|---|---|---|
| Ficha de evento | "dame todo lo de este show" | agregado autocontenido, heterogéneo por tipo de evento | esquema rígido o una tabla de atributos que convierte una lectura en quince |
| Aforo y reserva temporal | "¿queda asiento? guárdamelo 10 minutos" | contador y llave con expiración | filas calientes, bloat, o un job de limpieza que alguien tiene que operar |
| Búsqueda y facetas | "conciertos en Bogotá, sábado, menos de 200 mil" | índice invertido con conteos por filtro | relevancia binaria y conteos que se recalculan a fuerza bruta |
| Ledger y liquidación | "¿cuánto le debemos a este organizador y por qué?" | asientos contables inmutables, invariantes duras | pérdida de atomicidad justo donde hay dinero |
| Analítica | "conversión por canal y ciudad, últimos 18 meses" | columnas largas, pocas por consulta | barrido de tabla que compite con las compras en curso |
| Telemetría de puerta | "cuántos escaneos por minuto en la entrada norte" | append-only con eje temporal | crecimiento sin techo dentro de la base transaccional |
| Afinidad entre asistentes | "quien fue a X también fue a Y" | co-ocurrencia, profundidad 2 | (spoiler: aquí no duele nada — y esa es la lección) |

Siete patrones, y el curso va a terminar defendiendo **tres motores**. La
distancia entre esos dos números es exactamente la materia del curso.

### El sistema que se construye

Ágora se construye como un backend en TypeScript sobre Node, contenerizado
de punta a punta, con una **fuente de verdad transaccional única** y varios
almacenes derivados que se alimentan de ella por una costura explícita. Los
derivados nunca se escriben directo desde el código de negocio: eso es
*dual-write*, y el curso lo trata como lo que es, un bug con buena prensa.
Todo cambio sale de la fuente de verdad y viaja por una sola tubería —
primero como tabla `outbox` leída por un publicador, después como captura de
cambios (CDC) sobre el log de replicación— hasta los almacenes que lo
necesitan.

La consecuencia arquitectónica que el curso repite hasta que duele: **todo
almacén derivado debe poder borrarse entero y reconstruirse desde cero sin
pérdida de información**. Si un índice de búsqueda contiene un dato que no
está en ningún otro lado, dejó de ser un derivado y se convirtió, sin que
nadie firmara nada, en una segunda fuente de verdad. Ese es el momento exacto
en que un sistema políglota se vuelve infernal, y suele pasar sin ceremonia,
en un pull request de treinta líneas un jueves por la tarde.

### La factura: qué cuesta cada motor que sumas

Esta tabla es el instrumento central del curso. Se llena, motor por motor, a
medida que el sistema crece, y se mide de verdad — el tiempo de restore es
un número cronometrado, no una estimación.

| Superficie | Qué hay que responder con evidencia |
|---|---|
| Imagen y versión | qué versión corre, cada cuánto sale una nueva, cuánto dura el soporte |
| Backup | qué comando, con qué frecuencia, dónde queda, cuánto ocupa |
| **Restore** | cuánto tarda en volver, medido, con datos reales, la última vez que se ensayó |
| Modos de fallo | qué se rompe, cómo se ve en las métricas, qué síntoma llega al usuario |
| Observabilidad | qué métricas exporta, qué alerta se dispara, con qué umbral |
| Runbook | qué hace a las 3 am la persona de guardia que no lo instaló |
| Consistencia | qué datos duplica, con qué retraso, cómo se detecta la divergencia |
| Aprendizaje | cuánto tarda alguien nuevo del equipo en poder tocarlo sin miedo |

### El marco de 5 preguntas, aplicado ANTES de modelar

| Pregunta | Veredicto para Ágora |
|---|---|
| ¿Qué se lee junto? | depende del patrón: la ficha del evento se lee entera; el ledger se lee por rangos y agregados; la búsqueda no lee entidades, lee un índice |
| ¿Quién custodia la forma y las invariantes? | la forma la custodia cada dominio (la ficha evoluciona sola), pero **las invariantes duras viven todas en un solo sitio**: no se vende más de lo que hay, no se cobra dos veces, la liquidación cuadra |
| ¿Cuánto se une en caliente? | poco entre agregados, mucho dentro del ledger — y **nada** entre motores distintos: si necesitas unir dos motores en caliente, el corte está mal |
| ¿Dónde viven las invariantes? | en el motor transaccional, sin excepciones; todo lo demás es copia y puede mentir un rato sin que el negocio se rompa |
| ¿Qué pide la operación? | lectura masiva y elástica en catálogo y búsqueda; escritura con contención brutal y acotada en el tiempo en las salidas a la venta; latencia de puerta dura pero simple; evolución continua de la forma del evento |

**Veredicto honesto: no vota "un modelo N-0".** Ágora vota *aislamiento de
cargas* para tres familias —transaccional, documental-de-lectura y
clave-valor-con-expiración— más un índice de búsqueda derivado que se gana
su lugar solo si la búsqueda es una funcionalidad de producto y no un `LIKE`
con pretensiones. La analítica no vota motor nuevo: vota **no correr sobre la
base transaccional**, que es un requisito distinto y mucho más barato de
satisfacer. Y la afinidad entre asistentes no vota absolutamente nada: es una
agregación de dos saltos que el curso va a medir y descartar en público.

Ese "no vota N-0" es deliberado y es la tesis del curso. Un capstone que
terminara con un veredicto limpio y unánime estaría mintiendo sobre cómo se
ven las decisiones de arquitectura reales.

### El villano: sumar motores por moda y no nombrar la factura

El anti-patrón que este curso disecciona no es un esquema mal normalizado ni
una consulta sin índice. Es una **arquitectura de diapositiva**: seis o siete
motores dibujados en un diagrama que se ve impresionante, cada uno elegido
por su mejor caso de marketing, ninguno con un número al lado, y con la parte
más cara del sistema —la coherencia entre ellos— representada por flechitas
sin etiqueta. Nadie escribió cuánto tarda el restore. Nadie ensayó qué pasa
si el conector de cambios se queda atrás cuatro horas. Nadie preguntó quién
va a estar de guardia.

El curso construye esa versión de Ágora **de verdad**, en la Fase 11, y le
hace la autopsia con el mismo arnés que usó todo el curso: latencia por
patrón, lag de convergencia, tiempo de restore coherente, cantidad de modos
de fallo, minutos-persona de operación por semana. Después la reduce a tres
motores y vuelve a medir. La expectativa honesta, declarada antes de medir
—y por lo tanto falsable, que es la única forma de decir algo interesante—:
la latencia percibida por el usuario apenas mejora, mientras que la factura
operativa cae de forma brutal. Si los números dicen otra cosa, se escriben
los números.

El villano tiene una versión espejo que el curso trata con la misma dureza:
el veterano que se niega a sumar el segundo motor cuando la evidencia ya lo
pide, y que tampoco puso número a nada. Terca es el mismo pecado que crédula,
con mejor reputación.

---

## 📐 Stack (2026, estable y moderno)

Todo es open source y ejecutable sin licencia comercial en entorno de
desarrollo, todo corre en contenedores, y todo lo verificable se verificó en
agosto de 2026. Las versiones exactas se vuelven a confirmar al montar la
Fase 0: las series se mueven, y el curso no clava números de memoria.

| Componente | Versión / elección | Rol en el sistema |
|---|---|---|
| PostgreSQL | 18.x (serie estable actual) | **fuente de verdad**: pedidos, ledger, liquidaciones, tabla `outbox` |
| MongoDB | 8.0.x (última major GA para on-premise) | catálogo documental de eventos: ficha heterogénea, derivada |
| Valkey | 9.1.x | reservas con expiración, aforo caliente, límite de peticiones, caché |
| Meilisearch | 1.48.x | índice de búsqueda facetada, derivado y reconstruible |
| DuckDB | 1.5.x | analítica embebida sobre exportaciones en Parquet, fuera de producción |
| Debezium | 3.6.x | captura de cambios desde el WAL de Postgres |
| Redpanda | última estable (verificar) | bus de eventos compatible con la API de Kafka, sin ZooKeeper ni JVM |
| Node.js | 24 LTS ("Krypton", soporte hasta 2028) | runtime |
| TypeScript | última 5.x (verificar) | tipado en todo el backend, incluido el arnés |
| Fastify | 5.x | API HTTP |
| Zod | última | validación en la frontera |
| Prometheus + Grafana | 3.x / 13.x | métricas y tableros — aquí son materia, no decorado |
| OpenTelemetry (SDK Node) | última | trazas que cruzan cuatro motores en una sola petición |
| k6 | última | generación de carga reproducible para el arnés |
| Testcontainers | última | pruebas de integración contra motores reales, no dobles |
| Podman o Docker + Compose | última | todo el laboratorio, un comando |
| Motores del villano (Fase 11) | Neo4j Community y un motor de series temporales, a decidir | existen solo para ser medidos y retirados |

### Por qué PostgreSQL es la fuente de verdad y no un motor "moderno"

Porque las invariantes de Ágora son duras, cruzadas y con dinero: no vender
el mismo asiento dos veces, no cobrar dos veces, que la suma de las
liquidaciones cuadre con la suma de las ventas. Ese conjunto de reglas quiere
transacciones multi-fila, restricciones declarativas y un log de escritura
del que se pueda leer el cambio en orden — que es justo lo que habilita toda
la costura del resto del curso. Elegir aquí un motor sin transacciones
completas no es audacia arquitectónica: es mudar el problema al código de
aplicación, donde no hay optimizador que te salve y sí una guardia que te
espera.

Hay un segundo motivo, menos noble y más importante: Postgres es también el
**rival permanente**. Cada vez que el curso propone sumar un motor, la
alternativa honesta es "esto ya lo hace Postgres" — con JSONB, con
`tsvector` y `pg_trgm`, con `SKIP LOCKED`, con particiones. Esa alternativa
se implementa y se mide en la misma fase. Un curso de persistencia políglota
que no hiciera esto sería propaganda.

### Por qué el "vs" aquí es arquitectónico y no de productos

En este curso no compiten Meilisearch contra otro buscador. Compiten
**combinaciones**: la arquitectura de un motor contra la de tres contra la de
seis, sobre el mismo dominio, con el mismo arnés y con métricas que incluyen
lo que normalmente no se mide. Por eso el stack no lista "rivales" sueltos:
el rival de cada fase es la versión del sistema que resuelve ese mismo
patrón sin sumar el motor.

### Por qué TypeScript y Node, y por qué contenerizado

Node 24 LTS tiene soporte hasta 2028 y drivers oficiales maduros para los
cinco motores del sistema, lo que evita que el curso pase medio capítulo
peleando con un cliente inmaduro. TypeScript da un beneficio específico y
poco obvio en un sistema políglota: los **tipos del contrato de eventos** que
viajan por la costura se declaran una vez y se comparten entre el publicador
y cada consumidor, de modo que una divergencia de forma explota al compilar y
no seis horas después, en un índice a medio reconstruir.

Contenerizar no es preferencia: es la única forma de que "levantar el
laboratorio" sea reproducible entre Linux, macOS y Windows con WSL, y de que
la factura operativa sea medible. La Fase 0 cronometra el arranque en frío y
mide la RAM de cada configuración, porque ese número —cuánto cuesta tener
todo esto encendido en el portátil de alguien que acaba de entrar al equipo—
es la primera línea de la factura y casi nadie la anota.

### Validación en capas y contrato de eventos

La validación vive en tres alturas, y el curso las distingue con cuidado
porque el fallo típico de un sistema políglota es asumir que el derivado
valida lo que la fuente ya validó. Zod valida en la frontera HTTP, donde el
mensaje de error tiene que ser legible para una persona. Las restricciones
declarativas de Postgres son la última línea que ningún cliente puede
esquivar. Y el **contrato de eventos** —el esquema versionado de lo que viaja
por la costura— se valida al publicar y al consumir, porque el día que un
campo cambie de forma vas a querer que el consumidor se detenga ruidosamente
en vez de escribir basura en silencio durante seis horas.

---

## ⚖️ El método del "vs": un arnés, no anécdotas

`scripts/vs.ts` nace en la Fase 0 y no se toca la lógica de negocio para
alimentarlo. Recibe un escenario —una consulta o una operación descrita en
términos *semánticos*, no en el lenguaje de un motor— y una lista de
implementaciones. Ejecuta cada implementación contra su motor, con calentado
previo, repeticiones suficientes para que la mediana signifique algo, y bajo
la misma carga concurrente generada por k6. Registra p50, p95, p99, uso de
CPU y memoria del contenedor, y vuelca todo a `BENCHMARKS.md` con fecha,
versión de cada motor y la máquina donde corrió. Un número sin esas tres
etiquetas no entra.

Lo que distingue al arnés de este curso es que la latencia es solo la primera
de sus métricas. Un sistema políglota se juzga también por:

**Lag de convergencia.** Cuánto tarda un cambio en la fuente de verdad en
ser visible en cada derivado, medido en el percentil 99 y bajo carga, no en
reposo.

**Tiempo de restore coherente.** Cuánto tarda el sistema completo en volver a
un estado consistente después de una pérdida — no cuánto tarda cada motor por
separado, que es la respuesta fácil y engañosa.

**Superficie de fallo.** Cuántos modos de fallo distintos hay que reconocer y
tener documentados, contados de verdad.

**Costo operativo semanal.** Minutos-persona de mantenimiento, actualización,
revisión de alertas y atención de incidentes, estimados con un método
declarado y aplicado igual a todas las arquitecturas.

Los duelos que atraviesan el curso, todos entre arquitecturas y no entre
marcas:

1. **Monolito Postgres vs políglota, patrón por patrón.** El duelo de fondo,
   presente en cada fase donde se propone sumar algo.
2. **Tres motores vs seis motores.** El duelo de la Fase 11, con la factura
   completa en la mesa.
3. **Dual-write vs outbox vs CDC.** Tres costuras, medidas por lag,
   divergencia bajo fallo y complejidad operativa.
4. **Reserva con expiración: Valkey vs `SKIP LOCKED` en Postgres.** El duelo
   más honesto del curso, porque el resultado depende de un requisito de
   durabilidad que hay que decidir antes de medir.
5. **Analítica: DuckDB sobre Parquet vs consulta directa contra producción.**
   Donde se mide la interferencia, no solo la velocidad.

---

## 🌳 Estructura de fases

Trece fases. La estructura no sigue una escalera de dificultad técnica sino
el ciclo de vida real de una decisión de arquitectura: primero se inventarían
los patrones, después se construye la línea base más simple posible, después
se suma cada motor pagando su cuota en el momento, después se enfrenta la
costura y sus fallos, y solo al final se hace la autopsia del exceso y se
escribe el veredicto.

| # | Fase | Núcleo | "Vs" de la fase |
|---|---|---|---|
| 0 | 🧪 El laboratorio y su factura de arranque | Compose con los cinco motores, generador de datos, nace `vs.ts` | Costo de arranque: tiempo, RAM y disco por configuración |
| 1 | 🗺️ Inventario de patrones de acceso | Las 5 preguntas aplicadas a los siete patrones de Ágora | — (marco) |
| 2 | 🧾 La línea base: todo en un solo motor | Ágora completa en Postgres, honestamente bien hecha | Monolito contra sí mismo: dónde empieza a doler |
| 3 | 🔒 La fuente de verdad y el ledger | Invariantes, transacciones, tabla `outbox` | Invariante en la base vs en la aplicación |
| 4 | 🍃 El catálogo se va a un motor documental | Ficha heterogénea en Mongo, derivada de Postgres | Mongo vs JSONB, lectura y evolución de forma |
| 5 | 🔑 Aforo y reservas con expiración | Reserva temporal, anti-sobreventa, contadores calientes | Valkey TTL vs `SKIP LOCKED` con durabilidad declarada |
| 6 | 🔍 Búsqueda facetada como índice derivado | Meilisearch alimentado por la costura | Meilisearch vs `tsvector` + `pg_trgm` |
| 7 | 🔄 La costura: outbox y captura de cambios | Debezium sobre el WAL, Redpanda, consumidores idempotentes | Dual-write vs outbox vs CDC |
| 8 | 🧯 Divergencia, reconciliación y el botón rojo | Detectar que un derivado miente y reconstruirlo | Reconciliación periódica vs reindexado total |
| 9 | 🦆 Analítica sin tocar producción | Exportación a Parquet, DuckDB, panel | DuckDB aparte vs consulta analítica contra la OLTP |
| 10 | 💾 Backups, restore y el ensayo del desastre | Restore cronometrado por motor y **coherente** entre motores | Restore aislado vs restore coordinado |
| 11 | ⚰️ La autopsia del exceso | Se construye la versión de seis motores y se mide entera | Seis motores vs tres, con factura completa |
| 12 | ⚖️ El veredicto con las dos manos | Árbol de decisión de cuándo NO sumar un motor | La arquitectura final, defendida con números |

### Fase 0 — 🧪 El laboratorio y su factura de arranque

Se monta el `compose.yaml` con Postgres, MongoDB, Valkey, Meilisearch,
Redpanda y la pila de observabilidad, todo con volúmenes nombrados y healthchecks
reales. Se escribe el generador de datos sintéticos de Ágora: organizadores,
recintos, eventos de cuatro tipos con atributos distintos, funciones,
inventario de asientos, y un histórico de pedidos con estacionalidad creíble
(las ventas de un show no son uniformes: explotan en los primeros diez
minutos). Nace `scripts/vs.ts` con su primer escenario, que es
deliberadamente trivial, y nace `BENCHMARKS.md` con la primera medición del
curso: cuánto tarda y cuánto pesa levantar esto. 🩻 Aquí entra el primer
recuadro de "esto sí viaja igual": tu instinto de DBA sobre memoria, disco y
conexiones vale exactamente lo mismo en los cinco motores.

### Fase 1 — 🗺️ Inventario de patrones de acceso

Sin escribir código de producto todavía, se toman los siete patrones de Ágora
y se les aplican las cinco preguntas, una por una, escribiendo la respuesta.
El entregable es una tabla de decisión con una columna que casi nunca se
escribe: *qué evidencia haría falta para cambiar esta respuesta*. 🪞 Primer
instinto falsable del curso, y es incómodo: la mayoría de los ingenieros
predice que un sistema como Ágora "necesita al menos cuatro motores". Se
anota la predicción con nombre y fecha; se revisa en la Fase 12.

### Fase 2 — 🧾 La línea base: todo en un solo motor

Ágora entera en Postgres, y bien hecha: JSONB con índices GIN para la ficha
heterogénea, búsqueda con `tsvector` y `pg_trgm`, reservas con `SKIP LOCKED`
y expiración por columna, métricas en tablas particionadas por tiempo. No es
un espantapájaros: es la implementación que un buen equipo entregaría, y en
muchas empresas sería el final feliz de la historia. Se mide todo. Este
conjunto de números es la vara contra la que se juzgará cada motor que el
curso sume después, y ninguna fase posterior puede declarar victoria sin
compararse contra él.

### Fase 3 — 🔒 La fuente de verdad y el ledger

Se cierran las invariantes duras donde tienen que estar cerradas: no vender
dos veces el mismo asiento, no cobrar dos veces el mismo pedido, cuadrar la
liquidación. Aparece la tabla `outbox` en la misma transacción que el cambio
de negocio —el detalle que hace posible todo el resto— y se discute por qué
escribir el evento fuera de esa transacción ya es dual-write aunque estén a
dos líneas de distancia. 🪞 El instinto que se recalibra: "si el evento se
publica justo después del commit, es prácticamente atómico". No lo es, y la
fase lo demuestra matando el proceso en el instante exacto.

### Fase 4 — 🍃 El catálogo se va a un motor documental

Primer motor sumado, primera cuota pagada. La ficha del evento —cuyos
atributos difieren radicalmente entre un concierto, una obra de teatro y una
conferencia— se materializa como documento en Mongo, alimentada desde la
fuente de verdad. Se mide contra la implementación JSONB de la Fase 2, en
lectura de ficha completa, en filtro por atributo específico de tipo, y en el
costo de agregar un tipo de evento nuevo. 📖 Aquí cae la primera entrada
grande del diccionario de traducción: relacional ↔ documental, sin
condescendencia, para alguien que ya sabe qué es un índice compuesto. Y se
llena la primera **ficha de factura** completa del curso.

### Fase 5 — 🔑 Aforo y reservas con expiración

El patrón más caliente de Ágora: un show sale a la venta, cinco mil personas
compiten por dos mil asientos durante noventa segundos, y cada una necesita
una reserva temporal de diez minutos. Se implementan las dos versiones y se
miden bajo la misma carga. El duelo es honesto porque el resultado depende de
un requisito que hay que decidir antes de medir: **qué pasa si el motor de
reservas se cae con reservas vivas**. Si la respuesta es "se pierden y la
gente vuelve a intentar", una llave con expiración es ideal; si la respuesta
es "hay que poder reconstruir el estado exacto", la conversación cambia por
completo. 🪞 El instinto relacional que aquí falla no es el que uno espera:
no es "un contador en memoria es inseguro" —es razonable—, sino asumir que la
atomicidad de un `INCR` resuelve la sobreventa, cuando el problema real está
en la ventana entre reservar y confirmar.

### Fase 6 — 🔍 Búsqueda facetada como índice derivado

Se suma el buscador y, con él, la doctrina que el curso repite: **índice
derivado, nunca fuente de verdad**. Se implementa la búsqueda con facetas y
tolerancia a errores tipográficos, se mide contra la versión Postgres de la
Fase 2, y —esto es lo importante— se implementa desde el primer día el
comando de reconstrucción total desde la fuente, con su tiempo cronometrado.
Un buscador sin botón de reconstrucción medido es un pasivo, no un activo.

### Fase 7 — 🔄 La costura: outbox y captura de cambios

La fase central del curso, y la que más gente necesita y menos gente estudió.
Se migra de publicar desde la tabla `outbox` a capturar cambios directamente
del log de replicación de Postgres con Debezium, publicando en Redpanda, con
consumidores idempotentes por derivado. Se enfrentan los tres problemas que
siempre aparecen: **orden** (garantizado por clave, no globalmente),
**entrega al menos una vez** (por eso la idempotencia no es opcional) y
**reproceso** (rebobinar el offset y no romper nada). 🪞 El instinto a
desactivar con firmeza: "esto se arregla con una transacción distribuida".
Casi nunca se arregla así; se arregla asumiendo consistencia eventual con un
límite declarado y una alerta cuando ese límite se supera.

### Fase 8 — 🧯 Divergencia, reconciliación y el botón rojo

Los derivados van a mentir. No es una posibilidad, es una certeza operativa:
un consumidor que se cayó, un evento mal formado, un despliegue a medias. La
fase construye la maquinaria para enterarse **antes que el usuario**: conteos
cruzados, sumas de verificación por ventana temporal, muestreo comparativo, y
una alerta sobre el lag de convergencia con un umbral que se justifica. Y
construye el botón rojo: reconstruir cualquier derivado desde cero, con su
procedimiento y su tiempo medido. La lección transferible: la reconciliación
no es una tarea de mantenimiento, es una **funcionalidad del sistema** y se
diseña, se prueba y se mide como tal.

### Fase 9 — 🦆 Analítica sin tocar producción

El equipo de dirección quiere conversión por canal y ciudad de los últimos
dieciocho meses. La versión ingenua —lanzar esa consulta contra la base de
pedidos— se ejecuta de verdad, con carga transaccional simultánea, y se mide
el daño colateral sobre el p99 de las compras. Después se hace bien:
exportación periódica a Parquet y análisis con DuckDB en un proceso aparte.
🩻 Recuadro de consuelo: aquí no hay nada nuevo que aprender sobre modelado
dimensional ni sobre agregaciones; lo que cambia es dónde corre la consulta,
no cómo se escribe. Se discute explícitamente por qué esto **no** cuenta como
"sumar un motor" en el sentido caro del término: DuckDB embebido no tiene
servidor, no tiene guardia y su restore es volver a exportar.

### Fase 10 — 💾 Backups, restore y el ensayo del desastre

La fase donde el curso deja de ser cómodo. Cada motor tiene su backup y su
restore, y se cronometran de verdad con el volumen del generador de datos.
Después llega la pregunta que nadie hace en la reunión de arquitectura: si
restauras Postgres a las 14:03 y Mongo a las 14:07, **¿qué estado tiene el
sistema?** La respuesta es que la única forma sensata de restaurar un sistema
políglota es restaurar la fuente de verdad al punto elegido y **reconstruir
todos los derivados desde ahí** — lo cual solo funciona si en las fases 6 y 8
se construyó el botón rojo. Aquí es donde se cobra, retroactivamente, la
disciplina de todo el curso.

### Fase 11 — ⚰️ La autopsia del exceso

Se construye la arquitectura de diapositiva completa: se suma un motor de
grafo para "quien fue a X también fue a Y", un motor de series temporales
para los escaneos de puerta, y un segundo motor documental porque alguien
leyó un benchmark. Se mide todo con el mismo arnés: latencia por patrón, lag
de convergencia, tiempo de restore coherente, cantidad de modos de fallo,
costo operativo semanal, RAM total del laboratorio. Después se reduce a tres
motores y se vuelve a medir. Los números antes y después van a
`BENCHMARKS.md` sin maquillaje, incluidos los que contradigan la expectativa
declarada — especialmente esos.

### Fase 12 — ⚖️ El veredicto con las dos manos

El árbol de decisión que el curso venía construyendo, escrito por fin. La
regla que lo ordena, y que es lo único que hay que memorizar de todo el
curso: **un motor nuevo entra solo si gana un orden de magnitud en un
patrón que importa, o si elimina una clase entera de fallo — y en ambos casos
solo después de nombrar por escrito quién lo opera, cuánto tarda su restore y
cómo te enteras de que se desincronizó.** Se revisan las predicciones de la
Fase 1 contra los resultados, se cierra `INSTINTOS.md`, y se escribe el
veredicto honesto: cuándo esta arquitectura políglota es correcta, cuándo un
solo motor era la respuesta desde el principio, y cuál es la señal temprana
de que te pasaste.

### Apéndice A — Arranque de motores en contenedores

Instalación de Podman o Docker en Linux, macOS y Windows con WSL,
particularidades de cada uno, y la tabla de puertos, volúmenes y credenciales
del laboratorio.

### Apéndice B — El `compose.yaml` de trabajo, comentado

El archivo completo con perfiles: `min` (solo Postgres), `base` (los tres
motores del veredicto), `full` (todo, incluida la pila de observabilidad) y
`villain` (la configuración de la Fase 11). Comentarios en español
explicando el porqué de cada límite de recursos.

### Apéndice C — 📖 Diccionario de traducción de lenguajes de consulta

La misma pregunta semántica escrita en SQL, en el lenguaje de consulta
documental, en comandos de clave-valor, en la API del buscador y en SQL
analítico de DuckDB. Lado a lado, en tabla, para consultar en caliente.

### Apéndice D — El generador de datos

Cómo se parametriza el volumen, cómo se simula la estacionalidad de una
salida a la venta, y cómo se garantiza que el mismo dataset semántico llegue
a todos los motores.

### Apéndice E — Troubleshooting del laboratorio

Los fallos de montaje que se repiten: puertos ocupados, `wal_level` mal
configurado para la captura de cambios, límites de memoria del motor de
búsqueda, permisos de volúmenes en máquinas con SELinux, relojes
desincronizados entre contenedores.

### Apéndice F — Runbooks y plantilla de post-mortem

Un runbook por motor, con la estructura fija que el curso usa, y la plantilla
de post-mortem sin culpabilización que se aplica a los incidentes inyectados
en las fases 8 y 10.

---

## 📓 Artefactos acumulativos

**`INSTINTOS.md`** registra cada instinto que el curso somete a prueba, y lo
hace en tres tiempos que nunca se colapsan: la **predicción**, escrita antes
de medir y firmada por quien la hizo; el **procedimiento**, con el escenario
del arnés y las condiciones exactas; y el **veredicto**, con el número y una
frase que diga si el instinto sobrevivió, sobrevivió con matices o murió. Un
instinto que resulta correcto es tan valioso como uno que falla: la mitad de
la experiencia relacional de este lector va a viajar intacta, y saber cuál
mitad es exactamente el objetivo. En este curso los instintos más
interesantes no son sobre motores sino sobre costo: casi todo el mundo
subestima el tiempo de restore por un factor incómodo, y casi nadie predice
correctamente cuántos modos de fallo distintos aparecen al sumar el cuarto
motor.

**`BENCHMARKS.md`** acumula todo "vs" del curso, siempre producido por
`scripts/vs.ts`, siempre con fecha, versión de cada motor y descripción de la
máquina. Nada entra por narración. Cuando un resultado contradice lo que el
curso esperaba, entra igual y con una nota explicando la sorpresa: un
documento de benchmarks donde todo salió como estaba previsto es un documento
en el que no se puede confiar.

**`FACTURA.md`** es el artefacto propio de este curso y el que probablemente
sobreviva más tiempo en la carpeta del lector. Es la tabla de superficie
operativa, una ficha por motor, que se llena en la fase donde ese motor entra
al sistema y se actualiza cada vez que aparece un modo de fallo nuevo o se
vuelve a cronometrar un restore. Al terminar el curso, `FACTURA.md` es un
documento directamente reutilizable en el trabajo: la plantilla que se pone
sobre la mesa la próxima vez que alguien proponga sumar un motor.

---

## 📚 Referencias por fase (semilla)

> ⚠️ **Todo lo que sigue debe verificarse antes de publicarse.** Las URLs de
> documentación cambian de ruta con cada versión mayor, los títulos de libros
> y sus ediciones deben confirmarse contra el editor, y **no se incluye
> ningún identificador de video**: para el material audiovisual se indica qué
> buscar, y quien redacte la fase localiza y verifica el recurso concreto. No
> se inventan números de página, DOIs ni enlaces.

**Transversales a todo el curso**

Documentación oficial: PostgreSQL (https://www.postgresql.org/docs/18/),
MongoDB (https://www.mongodb.com/docs/manual/), Valkey
(https://valkey.io/topics/), Meilisearch (https://www.meilisearch.com/docs),
DuckDB (https://duckdb.org/docs/), Debezium
(https://debezium.io/documentation/), Redpanda (https://docs.redpanda.com/),
OpenTelemetry (https://opentelemetry.io/docs/), Prometheus
(https://prometheus.io/docs/), Grafana (https://grafana.com/docs/), k6
(https://grafana.com/docs/k6/latest/), Node.js (https://nodejs.org/docs/latest-v24.x/api/),
Fastify (https://fastify.dev/docs/latest/), Zod (https://zod.dev/),
Testcontainers (https://testcontainers.com/).

Libros de cabecera del curso, a verificar edición y año: *Designing
Data-Intensive Applications* (Kleppmann) para consistencia, replicación y
sistemas derivados; *Database Internals* (Petrov) para lo que pasa por
debajo; *Site Reliability Engineering* (Google) para SLOs, presupuesto de
error y guardia; *Release It!* (Nygard) para modos de fallo y patrones de
estabilidad; *Software Architecture: The Hard Parts* (Ford, Richards y otros)
para el vocabulario de compensaciones arquitectónicas.

**Fase 0** — documentación de Compose y de imágenes oficiales de cada motor;
guía de recursos y límites en contenedores. *Orden sugerido:* Compose →
healthchecks → volúmenes y persistencia → primera medición.

**Fase 1** — capítulos de modelado de *Designing Data-Intensive
Applications*; documentación de tipos y patrones de acceso de PostgreSQL.
*Orden sugerido:* patrones de acceso → las cinco preguntas → tabla de
decisión.

**Fase 2** — PostgreSQL: JSONB e índices GIN, búsqueda de texto completo,
`pg_trgm`, `SKIP LOCKED`, particionado declarativo. *Orden sugerido:* JSONB →
GIN → texto completo → concurrencia.

**Fase 3** — PostgreSQL: niveles de aislamiento, restricciones de exclusión,
`SERIALIZABLE`; material sobre el patrón outbox (el artículo fundacional está
en el blog de Debezium; verificar URL vigente).

**Fase 4** — MongoDB: modelado de esquema, validación con `$jsonSchema`,
índices; PostgreSQL JSONB para la comparación. *Orden sugerido:* modelado →
validación → índices → medición cruzada.

**Fase 5** — Valkey: estructuras de datos, expiración, `INCR`, scripting;
PostgreSQL: `SELECT ... FOR UPDATE SKIP LOCKED`. Video de apoyo: buscar
charlas sobre sistemas de inventario bajo alta contención (verificar fuente).

**Fase 6** — Meilisearch: facetas, relevancia, tolerancia a errores, tareas
de indexación; PostgreSQL: `tsvector`, diccionarios, `pg_trgm`.

**Fase 7** — Debezium: conector de PostgreSQL, snapshots, señales; Redpanda:
particiones, claves y orden; capítulos de CDC y sistemas derivados de
Kleppmann. *Orden sugerido:* WAL y replicación lógica → conector → orden e
idempotencia → reproceso.

**Fase 8** — material sobre consistencia eventual y reconciliación; alertas
sobre lag de consumidor en la documentación de Redpanda y Prometheus.

**Fase 9** — DuckDB: lectura de Parquet, extensiones, formatos columnares;
documentación de exportación de PostgreSQL.

**Fase 10** — PostgreSQL: recuperación a un punto en el tiempo, `pg_basebackup`,
pgBackRest (https://pgbackrest.org/); MongoDB: `mongodump`/`mongorestore` y
snapshots; capítulo de recuperación ante desastres de *SRE*.

**Fase 11** — documentación de los motores del villano, elegidos en la
decisión pendiente correspondiente; material crítico sobre complejidad
accidental en arquitectura.

**Fase 12** — capítulos de compensaciones de *The Hard Parts*; el artículo o
charla que se elija sobre "elegir tecnología aburrida" (verificar autoría y
URL vigente antes de citarlo).

---

## 🧪 Nota sobre ejercicios

Cada fase lleva entre **20 y 40 ejercicios**, con 30 como objetivo cómodo,
numerados de forma continua y agrupados por rangos de dificultad. La
distribución sugerida para una fase de treinta: unos 8 🟢, unos 9 🟡, unos 8
🟠 y unos 5 🔴, más los 🔥 opcionales listados aparte y sin numeración
continua.

Los 🟢 calientan: leer una métrica, ejecutar un escenario del arnés existente,
localizar dónde vive una invariante. Los 🟡 construyen: agregar un consumidor,
escribir un escenario nuevo, instrumentar una operación con trazas. Los 🟠
integran dos o más piezas del sistema y suelen exigir medir antes de decidir.
Los 🔴 son de arquitectura y de dolor real: cerrar una ventana de sobreventa
bajo doble clic, hacer converger un derivado que quedó a cuatro horas de
distancia sin parar el sistema, o reconstruir el estado coherente después de
un restore desalineado.

Al menos cinco ejercicios por fase son **de diagnóstico**: se entrega el
sistema con un fallo ya inyectado —un consumidor no idempotente, un índice
derivado que perdió doscientos documentos, un `wal_level` mal configurado, un
umbral de alerta que nunca dispara— y se pide reproducir, localizar y
explicar antes de arreglar. Todos los enunciados están anclados a Ágora:
eventos, funciones, asientos, reservas, pedidos, liquidaciones y escaneos de
puerta, nunca `foo` y `bar`. Cuando un ejercicio nombra código, usa el
identificador en inglés vigente del proyecto.

---

## 🧩 Decisiones pendientes de confirmar antes de redactar la Fase 0

- [ ] **Nombre definitivo del sistema.** Se propone *Ágora*; confirmar que no
      colisiona con nada y fijarlo en el diccionario del proyecto.
- [ ] **Dataset semilla: sintético o público adaptado.** Por defecto se
      propone sintético generado, porque permite controlar la estacionalidad
      de una salida a la venta, que es justo lo que hace interesante la Fase
      5; un dataset público de eventos culturales podría dar realismo a la
      búsqueda, a costa de control.
- [ ] **Qué motores encarnan al villano en la Fase 11.** Se propone un motor
      de grafo y uno de series temporales, más un segundo documental;
      confirmar cuáles, y si el segundo documental aporta algo o solo ruido.
- [ ] **¿Redpanda o Kafka?** Se propone Redpanda por arrancar sin JVM ni
      coordinación externa, lo que abarata el laboratorio; confirmar que la
      compatibilidad con los conectores de Debezium está donde se necesita.
- [ ] **¿La costura empieza en outbox y migra a CDC, o entra CDC directo?**
      Se propone la ruta larga (outbox en la Fase 3, CDC en la Fase 7) porque
      la comparación es el contenido, no el rodeo.
- [ ] **Durabilidad exigida a las reservas temporales.** Es el parámetro que
      decide el duelo de la Fase 5 y debe fijarse *antes* de medir para que el
      duelo sea honesto. Se propone: se pierden ante caída y el usuario
      reintenta.
- [ ] **¿La analítica de la Fase 9 se implementa o se documenta como diseño?**
      Se propone implementarla: es barata en infraestructura y sostiene el
      argumento de que no todo motor nuevo cuesta lo mismo.
- [ ] **Método de estimación del costo operativo semanal.** Hace falta uno
      declarado y aplicado igual a todas las arquitecturas, o la Fase 11
      pierde rigor. Se propone un inventario de tareas con tiempo asignado y
      frecuencia, revisable.
- [ ] **Formato de fase.** Se propone mantener la plantilla de nueve
      secciones; confirmar si las fases 10 y 11, muy operativas, la respetan
      bien o necesitan una variante.
- [ ] **Recursos mínimos del laboratorio.** Hay que fijar y publicar el
      mínimo de RAM y disco para el perfil `full`, y tener una ruta digna
      para quien no lo alcance.

---

## 💭 Consideraciones adicionales

### Esto es un cierre, no un producto

Este curso no propone una arquitectura para vender ni un servicio para
lanzar. Su salida no es un sistema desplegable sino **criterio con evidencia
propia**: un árbol de decisión, un archivo de benchmarks reproducible y una
plantilla de factura operativa que se puede usar en el trabajo del lunes
siguiente. Por eso su condición de productizable es un ⚠️ honesto y no una
debilidad disimulada: intentar venderlo como producto sería, precisamente, el
tipo de decisión que el curso enseña a rechazar.

Su lugar natural es el final de un recorrido. Alguien que llega aquí ya sabe
qué hace bien cada familia de motores por separado; lo que aprende en Ágora
es que ese conocimiento, sin una hoja de costos al lado, produce arquitecturas
que impresionan en la presentación y desangran en la guardia. Todos los
patrones de acceso que aparecen en el sistema se explican desde cero en el
curso —no se asume ninguna lectura previa—, pero se explican **al servicio de
la decisión de integración**, no de la maestría en cada motor.

### El riesgo pedagógico principal, y cómo se maneja

El riesgo evidente de un capstone así es la superficialidad: seis motores
tocados de refilón producen un curso que no enseña ninguno. La defensa es
estructural y hay que respetarla al redactar: **cada motor entra por un
patrón concreto, se mide contra la alternativa de no sumarlo, y solo se
profundiza en lo que esa decisión requiere.** El curso no enseña a operar
Mongo; enseña a decidir si Mongo entra, y a mantener coherente lo que Mongo
guarda. Cuando una fase empiece a derivar hacia el tutorial del motor, es
señal de que se salió del carril.

El segundo riesgo es más sutil: que el curso se lea como una condena de la
persistencia políglota. No lo es. Ágora termina con tres motores, no con uno,
y esa es una arquitectura políglota defendida con números. La tesis no es
"usa un solo motor": es "sabe exactamente cuánto cuesta cada uno de los que
usas, y no sumes el cuarto sin volver a hacer la cuenta".

### Los límites de la analogía con lo relacional

Casi todo lo que este lector sabe viaja intacto: capacidad, índices,
selectividad, planes de ejecución, contención, aislamiento. Hay una cosa que
no viaja, y conviene decirla temprano y sin adornos: **la intuición de que
"la base es consistente" deja de ser cierta en el momento en que hay dos
almacenes.** No es que se vuelva falsa, es que se vuelve una pregunta con
parámetros — consistente respecto de qué almacén, con cuánto retraso, medido
cómo. Un ingeniero que arrastre la intuición monolítica a un sistema políglota
va a escribir código correcto que produce datos incorrectos, y va a tardar
mucho en entender por qué. Ese es el instinto central que el curso desmonta.

### Convención de idioma del código

Como en todo el material: **el código en inglés, todo lo demás en español.**
Identificadores, endpoints, tablas, colecciones, campos, constantes, enums y
nombres de evento en inglés; comentarios de código, narrativa y textos de
interfaz en español. El vocabulario del dominio de Ágora se fija así:

| Español (narrativa, interfaz) | Inglés (código) |
|---|---|
| evento / función | `event` / `session` |
| recinto | `venue` |
| asiento | `seat` |
| reserva temporal | `hold` |
| pedido | `order` |
| pago | `payment` |
| liquidación al organizador | `payout` |
| organizador | `organizer` |
| asistente | `attendee` |
| escaneo en puerta | `scan` |
| aforo | `capacity` |

Los eventos que viajan por la costura siguen el patrón `recurso.acción` en
inglés y en pasado, porque describen algo que ya ocurrió: `order.created`,
`hold.expired`, `event.published`, `payout.settled`. Los estados van en
inglés y en `snake_case` cuando son compuestos: `on_sale`, `sold_out`,
`checked_in`. Un texto que ve una persona usuaria —"Quedan 3 entradas",
"Tu reserva expira en 09:58"— va siempre en español.
