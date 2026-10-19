# 🌙 Fase 22 — La exportación de las 9:40: la marca de agua que pierde filas, la cola que no duplica, y hasta dónde llega la integración dentro de la base

> **Curso:** Ruta SQL · Fase 22 de 27 · Bloque V — La base en la red · **15 h** · la fase más larga del curso
> **Motores:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` (18.6, con `wal_level = logical` que pone `a02`, `test_decoding` y `staging`) · Oracle, solo con la documentación (🔒, D20)
> **Entorno de ejecución:** SQL y Python en `src/22-la-exportacion-de-las-9-40/`, con `uv run lab race` para el intercalado
> **Perfil de volumen:** el día de mayor movimiento de 2025 en la caja (26/12/2025, 6.651 resultados y 601 protocolos), con la verdad de `truth.result_value`
> **El dolor de Alameda:** la exportación nocturna al portal, que empezaba a las 22:00 y terminaba a las 9:40; la notificación obligatoria en doce horas, copiada a mano; y la interfaz con el sistema de historia clínica, *"la pieza que más incidentes genera"*
> **Depende de:** Fase 21 · **Habilita:** el 💀 boss del puente de la [Fase 23](23-la-base-como-producto.md#-16b-boss-del-puente--el-puente), que compara el broker con la cola de esta fase
> **Apéndices de apoyo:** a02, a04, a07, a08
> **Fecha de verificación ejecutada:** 14/10/2026
> **Objetivo:** medir hasta dónde llega la integración dentro de la base: la exportación incremental, su punto de rotura, el CDC por decodificación lógica, el *outbox*, la cola con `SKIP LOCKED`, la idempotencia y los descartes. Sin broker.

---

## 🧭 1. Dónde estamos

Las fases anteriores trataron la base como un lugar donde se guarda y se consulta. Esta fase la trata como el **origen de los eventos** de los demás sistemas: el portal de exportación, la notificación obligatoria y el sistema de historia clínica leen de Alameda, o reciben de ella, cada vez que algo cambia. La pregunta ya no es cómo consultar, sino cómo asegurarse de que **cada cambio llega exactamente una vez** a cada destino.

La tentación de quien viene de aplicaciones es resolverlo con una marca de tiempo y un bucle. Esta fase mide dónde falla esa solución, y cuáles son las herramientas del motor que sí resuelven el problema.

---

## 🎯 2. Objetivos de esta fase

1. Exportar incrementalmente por marca de agua, y medir cuántas filas pierde cuando hay transacciones concurrentes.
2. Entender por qué el orden de confirmación no es el orden de registro, y cómo lo ve el motor.
3. Leer el flujo de cambios con decodificación lógica (CDC) y saber qué se decodifica y qué no.
4. Usar el *outbox* para que el cambio y su mensaje sean una sola transacción, y medir la pérdida de la doble escritura.
5. Consumir una cola dentro de Postgres con `SKIP LOCKED`, sin duplicados, y distinguir la entrega al menos una vez de la exactamente una vez.
6. Hacer cumplir la idempotencia con una clave única, aplicar correcciones fuera de orden con número de versión, y apartar el mensaje veneno.

---

## 🚫 3. Qué NO entra todavía

- **Un broker.** Ni Kafka, ni RabbitMQ, ni Artemis. La pregunta "¿hacía falta un broker?" la contesta el 💀 boss del puente de la Fase 23, contra la cola que esta fase deja escrita.
- **Colas gestionadas de Oracle** (AQ, TxEventQ). Son apuesta sin resolver, con la documentación (🔒, D20).
- **Un pgoutput con cliente.** La replicación lógica real usa `pgoutput` y un consumidor. Aquí se usa `test_decoding`, que viene en la imagen y muestra la mecánica (§5).
- **Un sistema de historia clínica real.** La caja no trae mensajes de entrada: los mensajes son simulados, con formato simplificado y declarado.
- **LISTEN/NOTIFY medido.** Se describe en prosa (§8.5); no se mide en esta fase.

---

## 🏚️ 4. El dolor, en la caja

La exportación de la noche sale de la base a las 22:00 y termina a las 9:40 en la pandemia, según la historia. La caja no tiene esa noche: tiene el **día de mayor movimiento del año**, el 26 de diciembre de 2025, con **6.651 resultados** que se registraron entre las 09:01 y las 17:59 (el horario de atención), en **601 protocolos** de unos once resultados cada uno.

Todos esos resultados tienen algo en común: su fecha de registro (`recorded_at`) cae exactamente en el minuto. De los 6.651, los 6.651 tienen el segundo en cero, y solo hay **357 instantes distintos** en todo el día. Un protocolo registra todos sus resultados en el mismo instante, y **162 instantes los comparten dos o más protocolos**: 406 de los 601 protocolos tienen un empate con otro. Esa granularidad no es un detalle de la fase: es parte del mecanismo que la fase mide.

> 📝 **Supuestos declarados.** La exportación se mide en un día, no en una noche de pandemia. Los mensajes del sistema de historia clínica no están en la caja: se generan con semilla y con formato simplificado. La demora de las transacciones es un modelo del curso (§5.2). Ninguno cambia la pregunta, pero cada uno tiene que estar a la vista.

---

## 🌊 5. La exportación por marca de agua, y la fila que se pierde

### 5.1 El mecanismo

La forma más simple de exportar solo lo nuevo es guardar una **marca de agua**: la fecha del último resultado enviado. Cada ciclo lee lo que tiene una fecha posterior a la marca, lo envía, y avanza la marca al máximo enviado.

```sql
SELECT result_id, recorded_at FROM alameda.result
WHERE recorded_at > :marca ORDER BY recorded_at LIMIT 1000;
```

El problema está en qué significa "lo que se ve". Una transacción que registra un resultado a las 10:00 y confirma a las 10:00:05, pero que tarda en confirmar, no es visible hasta el `COMMIT`. Si mientras tanto otra transacción registró a las 10:05 y confirmó, el exportador avanza la marca a las 10:05. Cuando la primera confirma, su fila tiene una fecha **anterior** a la marca, y la consulta incremental nunca la vuelve a leer.

🧭 Lo que se pierde no es por un error de programación: es por el orden en que el motor **confirma**, que no es el orden en que la aplicación **registra**.

### 5.2 La prueba con transacciones concurrentes

`02_marca_de_agua.py` replaya los 6.651 resultados del día con **cuatro escritores concurrentes**, un protocolo por transacción. Cada transacción pasa por un tiempo de demora antes de confirmar: el 95 % tarda entre 1 y 5 ms, y el 5 % es una transacción lenta de 0,3 a 0,6 s de reloj. El día entero se reproduce en 30 segundos de reloj (cada segundo son 48 minutos del día), para que los protocolos lleguen con la cadencia real del día y no todos a la vez.

Dos variantes, diez corridas cada una, medidas contra la verdad de `truth.result_value`:

| Variante | Corridas con pérdida | Mediana de filas perdidas (de 6.651) |
|---|---:|---:|
| **Ingenua**: la consulta mira solo lo posterior a la marca | **10 de 10** | **2.385** (36 %) |
| **Con ventana**: la consulta mira desde la marca menos 1 hora del día, y descarta lo ya enviado por `result_id` | **0 de 10** | **0** |

Fuente: `salidas/f22-marca-ingenua.txt` y `salidas/f22-marca-ventana.txt`, en la sesión de verificación del 14/10/2026.

### 5.3 De dónde viene la pérdida: dos causas, separadas

Antes de confiar en la cifra, la instrumentamos. Se midió, por protocolo, la hora objetivo, la hora real de confirmación y si la transacción fue lenta. El resultado separa las dos causas:

- **Las transacciones lentas se pierden todas.** De los 601 protocolos, 34 o 40 fueron lentos (según la corrida), y **todos** los lentos aparecen en la lista de pérdida. Es la causa que describe la ficha: la transacción que tarda en confirmar.
- **Los protocolos rápidos también se pierden, y eso no lo predice el modelo de demora.** En la primera versión del experimento, con un día de 15 s de reloj, la mediana de retraso de confirmación era de 76 ms: los escritores iban atrasados y se reordenaban confirmaciones rápidas. Con un día de 30 s, la mediana bajó a 13 ms, pero **149 protocolos rápidos siguieron perdidos**, con retrasos de 10 a 14 ms. La causa es otra: **varios protocolos comparten exactamente el mismo `recorded_at`**. Como el exportador avanza con `recorded_at > marca` (estrictamente mayor), el protocolo que confirma después de otro con la misma fecha queda detrás de la marca.

El segundo punto es el hallazgo de la fase: **la caja registra al minuto**, así que los empates no son raros. Con la granularidad de milisegundos de un sistema real, los empates serían menos frecuentes, pero no imposibles: dos transacciones pueden tener la misma marca de tiempo. La regla que sale es que la marca de agua tiene que tratar los empates y las transacciones tardías, no solo el orden.

🪞 **Apuesta antes de medir** (acordada en el paso 1 de la fase, por defecto): *"la exportación por marca de agua, con dos transacciones concurrentes, pierde al menos una fila en 8 de 10 corridas, y la pérdida se cuenta contra `truth.result_value`."*
**Resultado: ganada.** La pérdida aparece en 10 de 10 corridas, con una mediana de 2.385 filas contra la verdad.

### 5.4 La corrección: ventana de retroceso, y dedupe

La corrección es tan simple como la pérdida: la consulta mira desde **la marca menos una ventana**, mayor que la demora lenta máxima y que la granularidad de los empates. El exportador lleva un conjunto de los `result_id` ya enviados, y como la ventana vuelve a leer filas que ya salieron, descarta las repetidas. Con una hora del día de ventana, cubre la demora de 29 minutos que produce una transacción lenta de 0,6 s de reloj.

Diez corridas, cero pérdidas. La ventana no es gratis: relee filas en cada ciclo (en el día de referencia, unas 700 filas de cada hora cada vez), y la ventana tiene que ser mayor que la demora lenta máxima **medida en producción**, no supuesta. Si una transacción puede tardar horas, la ventana tiene que ser de horas.

> ⚠️ **El error del exportador ingenuo no es de código, es de supuesto.** Supone que el orden de registro es el orden de confirmación. La base no lo garantiza, y la granularidad de la fecha lo hace más visible.

### 5.5 Por dentro: qué hora le pone el motor a una fila

En la caja, `recorded_at` viene escrito; en un sistema que la llena con `DEFAULT now()`, el problema se agrava, y conviene saber por qué. **`now()` no es la hora del reloj: es la hora en que empezó la transacción**, y no cambia mientras la transacción dure. Medido en el laboratorio, dentro de una misma transacción con dos segundos de espera en el medio:

```text
            ahora_1            |           reloj_1
 2026-10-19 02:45:41.766177+00 | 2026-10-19 02:45:41.78266+00
            ahora_2            |            reloj_2
 2026-10-19 02:45:41.766177+00 | 2026-10-19 02:45:43.787845+00
```

`now()` dio dos veces el mismo instante; `clock_timestamp()`, el reloj de verdad, avanzó dos segundos. Para una exportación, eso quiere decir que **una transacción larga estampa sus filas con una hora vieja**: la hora en que empezó, que puede ser minutos antes de que confirme. Es exactamente la fila que la marca de agua ya dejó atrás. Cambiar a `clock_timestamp()` no lo arregla, porque lo que importa no es cuándo se escribió la fila sino cuándo se volvió visible, y eso pasa recién en el `COMMIT`.

Por eso la corrección de fondo no es una hora mejor sino otra fuente: **lo que el motor confirmó, en el orden en que lo confirmó**. Eso es lo que lee la decodificación lógica de la sección 6, y por eso el CDC no tiene el problema de la marca de agua. La ventana de retroceso de la sección 5.4 es la corrección barata, que funciona mientras se conozca la demora máxima; el CDC es la corrección que no depende de conocerla.

### 5.6 La prueba determinista

`lab race` reproduce el mecanismo con un orden fijo, sin azar: el protocolo de las 10:00 confirma tarde; el de las 10:05, antes; el exportador avanza la marca en el medio. Resultado: la comprobación da **1 fila sin exportar**, y el último `INSERT` del exportador inserta **0 filas**. Es la misma pérdida, reproducible en una sola permutación.

Fuente: `salidas/f22-race.txt`.

---

## 🔁 6. Captura de cambios: la decodificación lógica

Postgres escribe cada cambio en el WAL. La **decodificación lógica** lee ese WAL y lo convierte en cambios de fila, con su orden de confirmación. Es la base de la captura de cambios (CDC): otra herramienta, o un consumidor, puede seguir los cambios de una tabla sin consultarla.

La demostración usa `test_decoding`, que viene en la imagen (con `pgoutput`, el que usa la replicación real, se necesita un cliente, y aquí se describe en prosa):

```text
BEGIN 752637
table staging.f22_cdc_demo: INSERT: result_id[integer]:1 analyte_code[text]:'GLU' value_numeric[numeric]:110
table staging.f22_cdc_demo: INSERT: result_id[integer]:2 analyte_code[text]:'HB' value_numeric[numeric]:13.2
table staging.f22_cdc_demo: UPDATE: result_id[integer]:1 analyte_code[text]:'GLU' value_numeric[numeric]:112
COMMIT 752637
```

Dos cosas que se ven en la salida:

- **La transacción revertida no aparece.** Solo se decodifica lo confirmado, y en el orden en que se confirmó. La solución de la marca de agua se apoya en lo mismo: el CDC ve la confirmación, no el registro.
- **El `UPDATE` trae la fila completa**, no solo la columna cambiada (ejercicio 10). El consumidor recibe el estado nuevo y tiene que saber qué cambió comparando con el anterior, o confiar en el valor.

Medidas del día completo: la transacción que inserta los 6.651 resultados se decodifica en **6.656 líneas**: las 6.651 inserciones, los delimitadores de transacción y el `TRUNCATE` que la precedió.

> ⚠️ **Un slot de replicación que nadie consume retiene WAL.** El slot guarda hasta dónde leyó su consumidor, y el motor no borra el WAL más allá de ese punto. En el ejercicio 8, 20.000 filas dejaron **1.280 kB** retenidos. Con un día de Alameda, el WAL retenido crece en cada noche en que el consumidor no corre. Un slot abandonado llena el disco: es la primera autopsia de §10.

Fuente: `salidas/f22-cdc.txt`.

### 6.1 De `test_decoding` a la replicación lógica de verdad

`test_decoding` existe para mirar la mecánica. Un consumidor real usa `pgoutput`, el *plugin* de la replicación lógica de Postgres, y se arma en dos piezas: una **publicación** del lado de Alameda (`CREATE PUBLICATION resultados FOR TABLE alameda.result`), que dice qué tablas y qué operaciones salen, y un **suscriptor** del otro lado, que puede ser otro Postgres (`CREATE SUBSCRIPTION`) o un programa que habla el protocolo de replicación, como los conectores de CDC que leen Postgres para llevarlo a un *broker*. El slot es el mismo de esta sección, y su contrato también: el motor guarda el WAL hasta que el consumidor confirma que lo leyó (`confirmed_flush_lsn` en `pg_replication_slots`).

Ese contrato tiene una defensa, y en el laboratorio está apagada: **`max_slot_wal_keep_size` vale `-1`**, sin límite. Con un valor, por ejemplo `50GB`, un slot que se atrasa más que eso se **invalida**: el motor deja de guardarle WAL, y `pg_replication_slots.wal_status` pasa a `lost`. El disco se salva; el consumidor pierde su lugar y tiene que volver a empezar desde una copia completa. Es una decisión de negocio, no técnica: qué es peor para Alameda, que se llene el disco del servidor de resultados o que el portal tenga que reconstruirse. Para la base de los resultados, la respuesta del curso es el límite y una alerta sobre el atraso del slot, antes de que el límite llegue.

> 🩻 **Esto sí funciona igual** en MySQL, con otro nombre: el equivalente del WAL decodificado es el *binlog* en formato de filas, y un consumidor de CDC lo lee como lee el WAL de Postgres, con su posición guardada. Lo que cambia es quién retiene: MySQL borra el *binlog* por antigüedad (`binlog_expire_logs_seconds`), sin esperar a nadie, y un consumidor que se atrasó más que eso pierde los cambios en lugar de llenar el disco. Es la decisión opuesta a la del slot sin límite, tomada de fábrica. Esta fase no lo mide.

---

## 📤 7. El *outbox*: el cambio y su mensaje, en una sola transacción

Si la aplicación confirma el cambio y después envía el mensaje, hay una **doble escritura**: entre los dos pasos, el proceso puede caer. Mil cambios con una caída del 2 % entre los dos pasos:

| Patrón | Cambios confirmados | Mensajes enviados | Mensajes perdidos |
|---|---:|---:|---:|
| **Doble escritura** | 1.000 | 981 | **19** |
| **Outbox**: cambio y fila de `outbox` en la misma transacción; un relevador envía lo pendiente | 1.000 | 1.000 | **0** |

Con el outbox, el relevador puede caer después de enviar y antes de marcar el mensaje como enviado: entonces lo reenvía. En la corrida hubo **28 reenvíos**, y el destino los absorbió porque su clave del identificador es única: **1.000 de 1.000** mensajes, sin duplicados aplicados.

🧭 El outbox convierte "el cambio o el mensaje" en "el cambio y el mensaje", a costa de una tabla más y de un relevador. Y la entrega pasa a ser **al menos una vez**: lo que hace exactamente una vez es el destino.

Fuente: `salidas/f22-outbox.txt`.

---

## 📬 8. Mensajes entre bases, sin broker

### 8.1 La cola con `SKIP LOCKED`

Los mensajes pendientes viven en una tabla. Cada consumidor toma uno con `SELECT … FOR UPDATE SKIP LOCKED`: si otro consumidor ya lo tiene bloqueado, se salta a la siguiente fila en lugar de esperar. Con cuatro consumidores y 6.651 mensajes, diez corridas:

| Corrida | Duplicados en el destino | Faltantes |
|---|---:|---:|
| 1 a 10 | **0** en todas | **0** en todas |

Mediana de **5,49 s** para los 6.651 mensajes, con cuatro consumidores. El trabajo se reparte: cada consumidor procesó entre 1.653 y 1.668 mensajes en la última corrida.

Fuente: `salidas/f22-colas.txt`.

🪞 La apuesta de la ficha, "sin duplicados en 10 de 10 corridas", se cumple. La condición es que **el procesamiento sea transaccional**: el destino se escribe y el mensaje se marca como hecho en la misma transacción.

### 8.2 La entrega al menos una vez

Lo que cambia cuando el destino está **fuera** de la base es que la transacción no lo cubre. Un consumidor envía, y se cae (2 % de las veces) antes de marcar el mensaje como procesado: el mensaje vuelve a estar pendiente, y otro consumidor lo envía de nuevo.

- **Destino sin clave: 140 o 142 duplicados** en las dos corridas de la fase (la cifra varía, porque las caídas son aleatorias). Ningún mensaje se pierde: se repite.
- **Bandeja de entrada con clave única del identificador: 0 duplicados.** En esa corrida hubo 143 caídas, y cada una provocó el reenvío de un mensaje que ya estaba en la bandeja; `ON CONFLICT DO NOTHING` lo rechazó sin error. La idempotencia la hace cumplir la base, no el consumidor.

🧭 La combinación que se usa en la práctica es **al menos una vez en el transporte, y exactamente una vez en el efecto**. La cola da lo primero; la clave única de la bandeja da lo segundo.

Fuente: `salidas/f22-colas.txt`.

### 8.3 El mensaje veneno y los descartes

Cinco mensajes con formato inválido, que fallan siempre. Cada intento suma uno a `attempts`, y al tercero el mensaje se mueve a `staging.f22_dead` con su motivo y sale de la cola. El resultado: **5 en descartes**, **0 pendientes**, y los **6.651 resultados** procesados.

Sin ese corte, un mensaje veneno vuelve a la cola para siempre, y cada consumidor lo intenta de nuevo en cada vuelta, bloqueando a los demás sin que nadie se entere.

### 8.4 Correcciones fuera de orden

Un resultado puede corregirse varias veces, y los mensajes de corrección no llegan siempre en orden. Cien resultados con cinco versiones cada uno, barajados:

| Aplicación | Resultados con una versión que no es la última |
|---|---:|
| La última que llega gana | **86 de 100** |
| Comparación por número de versión (`ON CONFLICT … WHERE excluded.version > version`) | **0 de 100** |

Lo que sale: la versión no la decide la llegada, la decide el número. Y la consulta de upsert tiene que comparar; un `ON CONFLICT` sin `WHERE` sobre la versión sobrescribe siempre.

### 8.5 LISTEN/NOTIFY: el timbre, no el mensaje

`LISTEN/NOTIFY`, que la ficha menciona, avisa a una conexión que escucha un canal (`LISTEN resultados`) de que otra hizo `NOTIFY resultados`. La cola de esta sección lo usaría para no sondear la tabla cada tanto: el productor inserta el mensaje y avisa, y el consumidor dormido se despierta y va a buscarlo. Tres propiedades de la documentación deciden cómo se usa:

- **La notificación sale al confirmar.** Un `NOTIFY` dentro de una transacción que se deshace no llega nunca, y uno que confirma llega después del `COMMIT`. Va con el dato, como el outbox.
- **No es durable.** Si nadie escucha en ese momento, la notificación se pierde: no se guarda para el consumidor que se conecta después. Por eso es un timbre y no un mensaje. El mensaje vive en la tabla; la notificación solo dice "fijate".
- **Ocupa una conexión dedicada** por consumidor, que no puede estar en un *pool* que la reparta entre otros, y lleva una carga útil corta (menos de 8.000 bytes de fábrica).

La combinación que funciona es la de esta sección más el timbre: la tabla con `SKIP LOCKED` es la fuente, `NOTIFY` acorta la espera, y el consumidor igual revisa la tabla cada tanto por si un aviso se perdió. No se midió aquí: la latencia del aviso y el costo de la conexión dedicada son otro experimento.

### 8.6 Las colas de Oracle

Oracle trae la cola dentro de la base desde hace mucho: **Advanced Queuing** y su sucesora, **Transactional Event Queues**. La idea es la de esta sección con el motor haciendo el trabajo: el mensaje se encola dentro de la transacción del cambio, como el outbox, y se desencola con bloqueo de lo que otro consumidor ya tomó, como `SKIP LOCKED`, con reintentos y una cola de excepciones para el veneno ya resueltos.

> 🪞🔒 **Apuesta sin resolver: Oracle.** Hipótesis: con una cola transaccional y cuatro consumidores, los 6.651 mensajes del día se procesan sin duplicados ni faltantes, como la cola en Postgres, y el veneno termina en la cola de excepciones a los tres intentos. Resuélvela con un `DBMS_AQADM` que cree la cola, el mismo productor y cuatro consumidores que desencolan en su transacción, contando duplicados contra `staging.f22_expected` cargada en Oracle. Ni el tiempo ni ningún otro número se publican ([`a09`](a09-licencias-publicacion-y-riesgo.md)).

> 🩻 **Esto sí funciona igual** en los tres motores: `FOR UPDATE SKIP LOCKED` existe en Postgres, en MySQL desde la 8.0 y en Oracle, con la misma semántica ([`a07`](a07-diccionario-y-glosario.md#-entre-los-tres-motores)). La cola de esta sección se lleva a MySQL cambiando la sintaxis del *upsert* de la bandeja; el resto es igual.

---

## 🪞 9. Tu instinto dice… y las apuestas

**Tu instinto dice** que la exportación incremental es una marca de tiempo y un bucle, y que la cola es una tabla con un `UPDATE` de estado. Las dos cosas funcionan en la demo y fallan en la concurrencia real:

- la marca pierde el **36 %** de las filas con transacciones concurrentes (apuesta ganada);
- la cola sin transacción da **140 duplicados** en un destino sin clave (la apuesta de `SKIP LOCKED` solo se sostiene con el procesamiento transaccional).

**La segunda apuesta**, la del destino, la gana la clave única, no la cola: la base hace cumplir la idempotencia que el consumidor no puede garantizar.

---

## 💥 10. El punto de rotura y la autopsia

**Punto de rotura medido: las filas que la marca de agua pierde.** Con la ventana de cero, la pérdida es del 36 % de los resultados del día, en 10 de 10 corridas. La rotura no es un caso raro: es el día normal con transacciones concurrentes.

**Autopsia: el slot de replicación abandonado.** Un consumidor que se cae y nadie revisa. El slot sigue reteniendo WAL desde su último punto leído; el disco se llena una noche cualquiera, y el error no aparece en la aplicación sino en el servidor de la base. El ejercicio 8 mide el crecimiento: 1.280 kB retenidos tras 20.000 filas. El WAL retenido se acumula con cada noche sin consumo, y el ejercicio 18 pide calcularlo para el volumen de Alameda. La salida tiene tres partes, y las tres son baratas: un tope (`max_slot_wal_keep_size`, §6.1), una alerta sobre el atraso de cada slot (`pg_current_wal_lsn()` menos `confirmed_flush_lsn`, en bytes) y una costumbre, que es borrar el slot cuando se retira el consumidor, en el mismo cambio que lo retira.

**La doble escritura, la autopsia clásica.** Dos sistemas que se actualizan por separado y que, un día, no coinciden. El outbox no es un refinamiento: es la única forma de que el cambio y el mensaje tengan el mismo destino.

---

## 📖 11. Traducción

| Lo que sabes (aplicación) | En Postgres | Lo que cambia |
|---|---|---|
| Un `UPDATE` de estado para marcar un trabajo | `FOR UPDATE SKIP LOCKED` | Los consumidores no se esperan; cada uno toma otro |
| Un `if (!existe) insert` | `INSERT … ON CONFLICT DO NOTHING` con clave única | El motor lo hace atómico; el código no tiene que |
| Un reloj que avanza | Marca de agua sobre `recorded_at` | La marca mira el registro, no la confirmación: hay que retroceder |
| Un evento en una cola externa | Fila en `outbox` en la misma transacción | El evento se confirma con el dato, y el envío es después |
| Un "vuelve a intentarlo" sin fin | Contador `attempts` y tabla de descartes | El veneno sale de la cola a los tres intentos |
| Un webhook | Decodificación lógica (CDC) | Lee el WAL confirmado, no las consultas |

📖 **De la cola en Postgres a un broker:** la cola en la base llega hasta donde llegan sus transacciones. Un broker se gana su lugar cuando los consumidores están en otras máquinas, cuando el volumen de mensajes excede lo que la base puede tomar sin afectar a las consultas, o cuando hay que retener los mensajes por días para varios suscriptores. El boss del puente medirá exactamente eso.

---

## ⚖️ 12. Veredicto honesto: hasta dónde llega la cola dentro de la base

La cola en Postgres con `SKIP LOCKED`, procesamiento transaccional y una bandeja con clave única **resuelve la entrega exactamente una vez para un destino de la misma base o de un sistema que acepta la clave**. Procesó 6.651 mensajes en 5,5 s, con cuatro consumidores, sin duplicados ni faltantes en diez corridas. Esa es la cifra con la que el boss del puente comparará el broker.

No resuelve lo que está fuera de la transacción: un envío a un sistema que no tiene clave duplica (140 duplicados en la corrida B), y una marca de agua sin ventana pierde el 36 %. Y la cola vive con la base: un consumidor lento, un slot abandonado o una tabla de mensajes sin particionar le cuestan a las consultas de la sala de resultados.

Para Alameda, la decisión queda así. La exportación al portal deja la marca de agua y pasa a leer el CDC, con un slot que tiene tope y alerta; mientras eso no exista, la ventana de una hora de la sección 5.4 cierra la pérdida. La notificación obligatoria sale por el outbox, en la misma transacción que el resultado detectable, y su destino recibe con clave única, porque el organismo que la recibe no ofrece otra garantía. Y la cola de mensajes queda en Postgres, con `SKIP LOCKED` y descartes a los tres intentos, hasta que el boss del puente diga si el SIH necesita otra cosa.

La regla que sale: **la base sirve de cola mientras los consumidores puedan vivir en su transacción y el volumen no compita con las consultas**. Donde no se cumple, el broker se gana el lugar, y esa es la pregunta del boss del puente.

---

## ⚠️ 13. Errores comunes y diagnóstico

- **Exportar con `recorded_at > marca`** y creer que el orden de registro es el de confirmación. Pierde filas con transacciones concurrentes y empates.
- **Una ventana de retroceso menor que la demora lenta real.** Medirla en producción, no suponerla.
- **Un `ON CONFLICT` sin comparar la versión.** La última que llega gana, y la última no es la vigente.
- **Un consumidor que marca el mensaje como hecho fuera de la transacción del efecto.** Duplica o pierde según la caída.
- **Un slot de replicación sin consumidor.** Retiene WAL hasta llenar el disco.
- **Un mensaje veneno sin contador de intentos.** Bloquea a la cola para siempre.
- **Llenar `recorded_at` con `now()` y exportar por esa columna.** `now()` es la hora en que empezó la transacción, no la del `COMMIT`: una transacción larga deja sus filas detrás de la marca (§5.5).
- **Usar `NOTIFY` como mensaje.** No es durable: si nadie escuchaba, se perdió. El mensaje va en la tabla; `NOTIFY` solo avisa (§8.5).
- **Un slot sin tope ni alerta.** `max_slot_wal_keep_size` en `-1` es la configuración de fábrica, y es la que llena el disco (§6.1).

---

## 📋 14. Checklist de validación

- [ ] `staging.f22_expected` tiene 6.651 resultados, la verdad del día según `truth.result_value`.
- [ ] La variante ingenua pierde filas en 10 de 10 corridas, y la de ventana, en ninguna.
- [ ] `lab race` reproduce la pérdida con una comprobación de 1 fila.
- [ ] El slot de replicación se crea, se consume y se borra: no queda ninguno activo al final.
- [ ] Doble escritura: pérdida distinta de cero. Outbox: pérdida cero, y los reenvíos aparecen.
- [ ] La cola con cuatro consumidores: cero duplicados y cero faltantes en diez corridas.
- [ ] La bandeja con clave única: cero duplicados, y los rechazos contados.
- [ ] El mensaje veneno termina en `staging.f22_dead` a los tres intentos.

---

## 🧪 15. Ejercicios (28)

Cada ejercicio tiene su solución en `soluciones/22-la-exportacion-de-las-9-40.md`. Los 1 a 16 se corren con `07_ejercicios.sql`; los 17 a 28 se resuelven con su rúbrica.

### 🟢 Ejercicio 1 — La verdad del día

¿Cuántos resultados y cuántos protocolos tiene la verdad del 26/12/2025?

*Solución:* [soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-1](soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-1)

### 🟢 Ejercicio 2 — La marca máxima

¿Cuál es la marca de agua que se alcanzaría si todo el día estuviera confirmado?

*Solución:* [soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-2](soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-2)

### 🟢 Ejercicio 3 — El span de un protocolo

¿Cuánto tiempo abarcan los resultados de un protocolo?

*Solución:* [soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-3](soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-3)

### 🟢 Ejercicio 4 — Los empates

¿Cuántos instantes distintos hay, y cuántos los comparten dos o más protocolos?

*Solución:* [soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-4](soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-4)

### 🟢 Ejercicio 5 — El segundo en cero

¿Qué fracción de las fechas de registro cae exactamente en el minuto?

*Solución:* [soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-5](soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-5)

### 🟢 Ejercicio 6 — La ventana

¿Cuántas filas re-leería una ventana de una hora, con la marca a la mitad del día?

*Solución:* [soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-6](soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-6)

### 🟡 Ejercicio 7 — La demora en el reloj del día

¿Cuánto del día equivale una demora lenta de 0,3 a 0,6 s de reloj?

*Solución:* [soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-7](soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-7)

### 🟡 Ejercicio 8 — El slot que nadie consume

¿Cuánto WAL retiene un slot que no se consume, después de escribir 20.000 filas?

*Solución:* [soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-8](soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-8)

### 🟡 Ejercicio 9 — La transacción revertida

¿Aparece una transacción revertida en el flujo de cambios?

*Solución:* [soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-9](soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-9)

### 🟡 Ejercicio 10 — El `UPDATE` completo

¿Qué trae el cambio de un `UPDATE` que cambió una sola columna?

*Solución:* [soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-10](soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-10)

### 🟡 Ejercicio 11 — La clave única de la bandeja

¿Cuántas filas quedan tras dos envíos del mismo identificador?

*Solución:* [soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-11](soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-11)

### 🟡 Ejercicio 12 — La versión que llega tarde

¿Qué versión queda cuando llega una corrección vieja después de una nueva?

*Solución:* [soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-12](soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-12)

### 🟡 Ejercicio 13 — El mensaje veneno

¿Cuántos mensajes llegaron a descartes, y con qué motivo?

*Solución:* [soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-13](soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-13)

### 🟡 Ejercicio 14 — El outbox vaciado

¿Cuántos mensajes quedan pendientes en el outbox después del relevador?

*Solución:* [soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-14](soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-14)

### 🟡 Ejercicio 15 — El reparto de la cola

¿Cómo se reparten los mensajes entre los consumidores?

*Solución:* [soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-15](soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-15)

### 🟡 Ejercicio 16 — El destino sin duplicados

¿Cuántos identificadores aparecen más de una vez en el destino tras la última corrida transaccional?

*Solución:* [soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-16](soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-16)

### 🟠 Ejercicio 17 — Notificación sin sondeo

Diseña un consumidor que se entere de una fila nueva con LISTEN/NOTIFY, sin sondear la tabla. Di qué pasa si el consumidor estaba desconectado cuando se emitió la notificación.

*Solución:* [soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-17](soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-17)

**Rúbrica (sobre 4 puntos):** 1 punto por el mecanismo (`LISTEN` y `NOTIFY`); 1 por reconocer que la notificación no se persiste y que hace falta reconciliar con una marca; 1 por una reconciliación que use el outbox o la marca; 1 por medir o declarar la latencia.

### 🟠 Ejercicio 18 — El slot que se olvidó

Un consumidor de CDC lleva un mes caído. Calcula el crecimiento del WAL retenido y di qué harías antes de que el disco se llene.

*Solución:* [soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-18](soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-18)

**Rúbrica (sobre 3 puntos):** 1 punto por calcular el crecimiento a partir del ejercicio 8; 1 por una consulta de alerta sobre `pg_replication_slots`; 1 por la decisión (reanudar, o borrar el slot con su costo para el consumidor).

### 🟠 Ejercicio 19 — La cola particionada

La tabla de la cola crece con el año. Diseña una partición por fecha que no rompa el `SKIP LOCKED` ni los índices de pendientes.

*Solución:* [soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-19](soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-19)

**Rúbrica (sobre 4 puntos):** 1 punto por la partición por rango de fecha de encolado; 1 por el índice parcial de pendientes por partición; 1 por la consulta de toma que recorre las particiones en orden; 1 por medir el costo antes y después.

### 🟠 Ejercicio 20 — El outbox sin relevador

Un relevador deja de correr un fin de semana. Di cuántos mensajes se acumulan, qué le pasa a la tabla `outbox` y cómo lo detectarías.

*Solución:* [soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-20](soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-20)

**Rúbrica (sobre 3 puntos):** 1 punto por el cálculo con la tasa de cambios; 1 por el efecto en la tabla (crece sin purga, y el índice de no enviados se hace grande); 1 por una alerta sobre la antigüedad del mensaje más viejo sin enviar.

### 🟠 Ejercicio 21 — Orden por clave

¿Garantiza la cola con cuatro consumidores el orden de los mensajes de un mismo protocolo? Diseña cómo lograrlo sin serializar toda la cola.

*Solución:* [soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-21](soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-21)

**Rúbrica (sobre 4 puntos):** 1 punto por decir que `SKIP LOCKED` no garantiza orden; 1 por una clave de partición (el protocolo) que se toma con un bloqueo asesor (`pg_advisory_xact_lock`) o por hash; 1 por medir que el orden se respeta; 1 por el costo en paralelismo.

### 🟠 Ejercicio 22 — Lo que Oracle ofrece

Lee la documentación de las colas de Oracle (AQ, TxEventQ) y escribe, sin cifras, qué resuelven que la cola de Postgres no.

*Solución:* [soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-22](soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-22)

**Rúbrica (sobre 3 puntos):** 1 punto por describir la cola integrada con la base; 1 por la comparación en prosa, sin números de Oracle (D20); 1 por decir cuándo lo elegirías.

### 🔴 Ejercicio 23 — pgoutput con cliente

Reemplaza `test_decoding` por `pgoutput` y escribe el cliente mínimo que lee el flujo. Di qué cambia en lo que el cliente recibe.

*Solución:* [soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-23](soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-23)

**Rúbrica (sobre 4 puntos):** 1 punto por el plugin `pgoutput` y su publicación; 1 por el cliente (con `psycopg` o `pg_recvlogical`); 1 por describir el formato binario frente al texto; 1 por el acuse de recibo del consumidor (`confirmed_flush_lsn`).

### 🔴 Ejercicio 24 — La demora máxima medida

Diseña cómo medirías, en producción, la demora de confirmación para dimensionar la ventana de la marca de agua.

*Solución:* [soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-24](soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-24)

**Rúbrica (sobre 4 puntos):** 1 punto por medir la diferencia entre el instante de registro y el de visibilidad (con un sello de confirmación o con el CDC); 1 por un percentil alto más un margen; 1 por el costo de la ventana en filas releídas; 1 por la revisión periódica.

### 🔴 Ejercicio 25 — La tabla de exportados

La tabla `staging.f22_exported` crece sin límite. Diseña su purga sin perder la deduplicación.

*Solución:* [soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-25](soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-25)

**Rúbrica (sobre 3 puntos):** 1 punto por limitar la deduplicación a la ventana (lo anterior a la ventana ya no vuelve a leerse); 1 por la purga por rango de fecha; 1 por una prueba de que la purga no reabre duplicados.

### 🔴 Ejercicio 26 — La marca con zona horaria

Un sistema externo envía la fecha de registro con zona horaria y la base la guarda sin ella. Diseña la comparación de la marca para que no se pierda ni se duplique una hora al cambio de horario.

*Solución:* [soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-26](soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-26)

**Rúbrica (sobre 4 puntos):** 1 punto por normalizar a UTC en la captura; 1 por el problema de la hora repetida o saltada; 1 por una marca en UTC con ventana; 1 por una prueba con la fecha de cambio de horario.

### 🔴 Ejercicio 27 — El formato del mensaje

El sistema de historia clínica pide un formato parecido a HL7 v2. Diseña el mensaje de un resultado y declara qué simplificas.

*Solución:* [soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-27](soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-27)

**Rúbrica (sobre 3 puntos):** 1 punto por los segmentos del mensaje; 1 por declarar qué se simplifica y qué se omite; 1 por la clave de idempotencia del mensaje (el identificador único).

### 🔴 Ejercicio 28 — El veredicto de la base

Decide, con las medidas de la fase, si la cola de Alameda necesita un broker. Justifica con el volumen, la latencia y el número de consumidores.

*Solución:* [soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-28](soluciones/22-la-exportacion-de-las-9-40.md#ejercicio-28)

**Rúbrica (sobre 4 puntos):** 1 punto por la decisión; 1 por el volumen y la latencia medidos (6.651 mensajes en 5,5 s, con cuatro consumidores); 1 por el número de consumidores y sus caídas (140 duplicados sin clave, 0 con clave); 1 por la medida que cambiaría la decisión.

---

## 📚 16. Referencias

**Documentación oficial**

- **Decodificación lógica de Postgres 18** — https://www.postgresql.org/docs/18/logicaldecoding.html — el WAL lógico, los slots y los plugins.
- **`SELECT … FOR UPDATE SKIP LOCKED`** — https://www.postgresql.org/docs/18/sql-select.html — la cláusula de bloqueo y su efecto sobre la toma de filas.
- **`INSERT … ON CONFLICT`** — https://www.postgresql.org/docs/18/sql-insert.html
- **`LISTEN` y `NOTIFY`** — https://www.postgresql.org/docs/18/sql-notify.html
- **Replicación lógica y `pgoutput`** — https://www.postgresql.org/docs/18/protocol-logical-replication.html

**Papers y libros**

- **Martin Kleppmann, *Designing Data-Intensive Applications*, 2.ª ed., O'Reilly, 2026** — los capítulos de logs, de transmisión de eventos y de consistencia entre sistemas.

> ⚠️ **Verificación pendiente:** las URL de esta sección no se comprobaron con su código de estado en esta sesión. Quedan como deuda de verificación de la fase (plan §4).

---

## 🏁 17. Resultado de la fase

- **La marca de agua pierde el 36 % de las filas con transacciones concurrentes** (10 de 10 corridas, contra `truth.result_value`). La ventana de una hora del día la deja en cero. **Apuesta ganada.**
- **La causa son dos, medidas por separado:** las transacciones lentas, que se pierden todas, y los empates de `recorded_at`, porque la caja registra al minuto (357 instantes para 6.651 resultados).
- **La cola con `SKIP LOCKED` y procesamiento transaccional: cero duplicados y cero faltantes en diez corridas**, con mediana de 5,5 s para 6.651 mensajes y cuatro consumidores.
- **Sin transacción que cubra el envío: 140 duplicados.** Con clave única en la bandeja: cero. La idempotencia la hace cumplir la base.
- **Outbox: cero pérdidas, frente a 19 de la doble escritura**, con 28 reenvíos absorbidos por el destino.
- **Correcciones con número de versión: cero resultados desordenados, frente a 86 de la última que llega.**
- **Mensaje veneno: 5 en descartes a los tres intentos**, sin bloquear la cola.
- **La regla que queda:** la base sirve de cola mientras el consumidor viva en la transacción y el volumen no compita con las consultas. La pregunta de si hace falta un broker la contesta el boss del puente.

Esta fase deja escrita la cola contra la que el boss del puente medirá el broker (D3): el número es **6.651 mensajes en 5,5 s con cuatro consumidores, sin duplicados ni faltantes**.

> **La señal de que quedó bien:** *"Mi exportación no pierde la fila de la transacción que confirma tarde, mi cola no entrega dos veces lo que se aplica una, y sé cuándo hace falta un broker y cuándo no."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-22-la-exportacion-de-las-9-40 -m "F22 cerrada: la marca de agua, la cola con SKIP LOCKED, el outbox y la decodificación lógica"
> ```
>
> Commits de la fase con prefijo `f22:`, los de ejercicio `f22 ej28: …`.
