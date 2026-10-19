# 🔀 Fase 15 — Aislamiento comparado: anomalías, niveles y el bucle de reintento

> **Curso:** Ruta SQL · Fase 15 de 27 · Bloque III — La concurrencia · **10 h**
> **Motores:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · contraste MySQL `mysql@sha256:e2bde46db656…` · Oracle, solo con la documentación (🪞🔒)
> **Entorno de ejecución:** SQL y Python, con `uv run lab race`
> **Perfil de volumen:** M (`uv run lab load --profile m`; en MySQL, `--tables Protocolos,Deudores`)
> **El dolor de Alameda:** la PCR que procesaron dos técnicos, en la pandemia (historia §3, 2020)
> **Depende de:** Fase 14 · **Habilita:** Fase 16
> **Apéndices de apoyo:** a03, a04, a07, a08
> **Fecha de verificación ejecutada:** 14/10/2026
> **Objetivo:** reproducir cada anomalía de concurrencia siempre igual, medir qué nivel de aislamiento la evita en cada motor y
> con qué costo, y decidir cuándo no subir el nivel y resolverlo con una restricción o con un bloqueo explícito.

---

## 🧭 1. Dónde estamos

El Bloque II midió lo que cuesta una consulta sola. Este bloque mide lo que pasa cuando dos consultas que están bien cada una
se cruzan. La pregunta deja de ser cuántos bloques lee una transacción y pasa a ser **qué ve** mientras otra escribe.

Todo el bloque se ejecuta con `uv run lab race`, el arnés que intercala sesiones en un orden fijo
([`a04`](a04-el-arnes-de-forma.md#-uv-run-lab-race-sesiones-en-un-orden-fijo)). Una anomalía que aparece "a veces" no se
puede estudiar; con un orden fijo aparece siempre, o no aparece nunca, y eso es lo que se publica.

---

## 🎯 2. Objetivos de esta fase

1. Reproducir con `lab race` las seis anomalías clásicas sobre datos de la caja: lectura sucia, no repetible, fantasma,
   actualización perdida, *write skew* y la anomalía de solo lectura.
2. Armar la matriz anomalía × nivel × motor para Postgres y MySQL con lo observado, y para Oracle con lo que dice su
   documentación.
3. Explicar por qué `REPEATABLE READ` es *snapshot isolation* en Postgres y otra cosa en MySQL.
4. Escribir el bucle de reintento y medir lo que cuesta con cuatro, ocho y dieciséis técnicos.
5. Decidir cuándo una restricción o un bloqueo explícito resuelven el problema mejor que subir el nivel.

---

## 🚫 3. Qué NO entra todavía

- **El folio fiscal sin huecos**, que es la carrera más cara de Alameda → [Fase 16](16-el-folio-sin-huecos.md).
- **Versiones de fila, VACUUM y lo que cuesta mantener las fotos** → [Fase 17](17-mvcc-y-su-factura.md).
- **Quién bloquea a quién, *deadlocks* y `SKIP LOCKED` como cola** → [Fase 18](18-bloqueos-deadlocks-y-ddl.md). Aquí aparecen
  como resultado; allá se diagnostican.
- **Aislamiento entre réplicas o entre servicios**: fuera del curso.

---

## 🏚️ 4. El dolor, en la caja

Pandemia, 2020. La planilla de pendientes del laboratorio es una consulta de Access sobre SQL Server: los protocolos `EN
PROCESO`, ordenados por llegada. Cada técnico mira la primera muestra libre, la anota a su nombre y la procesa. Dos técnicos miran
a la vez, ven libre la misma PCR y la procesan los dos, y otra muestra queda sin tomar hasta que se vencen las doce horas de la
notificación.

`01_setup.sql` arma esa planilla en `staging` con los 1.115 protocolos que la caja trae `EN PROCESO`, y la toma en una tabla
aparte, sin restricción de unicidad, como estaba:

```sql
-- postgres
CREATE TABLE staging.specimen AS
SELECT "IdProtocolo" AS specimen_id, "Sede"::char(1) AS site_code, "Fecha" AS collected_at
FROM legacy."Protocolos" WHERE "Estado" = 'EN PROCESO';

CREATE TABLE staging.specimen_take (
    specimen_id integer NOT NULL REFERENCES staging.specimen,
    technician  text    NOT NULL,
    taken_at    timestamp NOT NULL DEFAULT localtimestamp
);
```

El técnico hace dos cosas, en una transacción: mira (`SELECT` de la primera muestra sin toma) y toma (`INSERT`).
`write_skew.race` las intercala para dos técnicos:

```text
🏁 lab race · postgres · permutación a1 b1 a2 b2 a3 b3 a4 b4 · read committed
 a1  BEGIN
 b1  BEGIN
 a2  1 fila  (11231555)
 b2  1 fila  (11231555)
 a3  INSERT 1
 b3  INSERT 1
 a4  COMMIT
 b4  COMMIT
resultado: a sin errores · b sin errores
comprobación: 1 fila  (2, 2)
```

Dos tomas de la muestra 11231555, de dos técnicos, sin un error. **Ningún paso hizo nada incorrecto por sí solo.** Cada técnico
leyó un dato que era cierto cuando lo leyó, y escribió una fila nueva que no choca con ninguna otra. Lo que se rompió es una regla
que vive entre dos filas, "cada muestra tiene un solo técnico", y que nadie escribió en la base.

---

## 🧩 5. Las anomalías y los niveles

### 5.1 Lo que el estándar define y lo que deja afuera

El estándar SQL define cuatro niveles por las anomalías que **prohíben**: `READ UNCOMMITTED` deja pasar todo; `READ
COMMITTED` prohíbe la lectura sucia; `REPEATABLE READ`, además, la lectura no repetible; `SERIALIZABLE`, además, el fantasma.
En 1995, Berenson y otros mostraron que esa definición tiene dos huecos. El primero, que las anomalías están descritas de
forma ambigua. El segundo, que hay anomalías que el estándar no nombra, como la **actualización perdida** y el ***write skew***,
y un nivel que los motores implementan y el estándar no tiene: el ***snapshot isolation***, donde cada transacción lee una foto
de la base tomada al empezar. La foto prohíbe la lectura sucia, la no repetible y el fantasma, y deja pasar el *write skew*. Por
el estándar, el *snapshot isolation* pasaría por `SERIALIZABLE`, y no lo es.

Seis anomalías, cada una en su escenario de `src/15-aislamiento-comparado/`, sobre la planilla de muestras, los deudores de la
caja y el cierre de caja:

| Anomalía | Qué pasa | Escenario |
|---|---|---|
| lectura sucia | b lee el pago que a no confirmó, y a lo deshace | `dirty_read.race` |
| lectura no repetible | a lee el saldo dos veces y b lo cambia en el medio | `nonrepeatable_read.race` |
| fantasma | a cuenta las tomas del turno dos veces y b agrega una | `phantom.race` |
| actualización perdida | dos cajas cobran al mismo deudor, y cada una escribe el saldo que calculó | `lost_update.race` |
| *write skew* | dos técnicos ven libre la misma muestra y la toman los dos | `write_skew.race` |
| anomalía de solo lectura | un informe que solo lee ve el lote cerrado antes del último cobro | `read_only.race` |

### 5.2 La matriz de Postgres

`matrix.py` corre cada escenario en los cuatro niveles, siempre con la misma permutación, y decide si hubo anomalía mirando lo
que cada sesión vio y lo que quedó confirmado. Dos corridas dieron la misma matriz:

> 📐 **Medición: anomalías por nivel en Postgres** · `pgvector/pgvector@sha256:2358fcba361e…` · verificado el 14/10/2026
>
> | Anomalía | `READ UNCOMMITTED` | `READ COMMITTED` | `REPEATABLE READ` | `SERIALIZABLE` |
> |---|---|---|---|---|
> | lectura sucia | no pasa | no pasa | no pasa | no pasa |
> | lectura no repetible | ❌ pasa | ❌ pasa | no pasa | no pasa |
> | fantasma | ❌ pasa | ❌ pasa | no pasa | no pasa |
> | actualización perdida | ❌ pasa | ❌ pasa | error 40001 | error 40001 |
> | *write skew* (la muestra) | ❌ pasa | ❌ pasa | ❌ pasa | error 40001 |
> | anomalía de solo lectura | ❌ pasa | ❌ pasa | ❌ pasa | error 40001 |

Tres cosas que el estándar no anticipa. `READ UNCOMMITTED` es, en Postgres, `READ COMMITTED`: no existe la lectura sucia.
`REPEATABLE READ` no deja pasar el fantasma, porque es *snapshot isolation*. Y `REPEATABLE READ` tampoco pierde la actualización:
la segunda caja que quiere escribir una fila que otra cambió después de su foto recibe un error en vez de pisarla:

```text
 a3  UPDATE 1
 b3  ⏳ espera un bloqueo
 a4  COMMIT
   ↳ b3  ✗ 40001 could not serialize access due to concurrent update
```

### 5.3 `SERIALIZABLE` en Postgres: una foto que vigila

El `SERIALIZABLE` de Postgres es *snapshot isolation* más un detector, el SSI (*Serializable Snapshot Isolation*, Cahill y
otros, 2008; implementado en Postgres 9.1 por Ports y Grittner). Mientras las transacciones corren, anota qué leyó cada una
(bloqueos de predicado que no bloquean nada, `SIReadLock` en `pg_locks`) y busca una estructura peligrosa: dos dependencias
"leí algo que otra escribió después" seguidas. Cuando la encuentra, aborta a una. En la muestra:

```text
 a3  INSERT 1
 b3  INSERT 1
 a4  COMMIT
 b4  ✗ 40001 could not serialize access due to read/write dependencies among transactions
```

El error no llega en el `INSERT` sino en el `COMMIT` de b, cuando el ciclo se cierra. Nadie esperó a nadie; una de las dos
transacciones se descartó entera. **El precio de `SERIALIZABLE` en Postgres no es la espera: es el error.** Y el error obliga a la
aplicación a hacer algo que casi ninguna hace: volver a correr la transacción desde el principio.

### 5.4 La anomalía de solo lectura

Fekete, O'Neil y O'Neil mostraron en 2004 que, en *snapshot isolation*, una transacción que **solo lee** puede ver un estado que
no corresponde a ningún orden en serie. `read_only.race` lo arma con el cierre de caja: a cobra en el lote abierto (el 1), b
cierra el lote (pasa al 2) y c, el informe, lee que el lote abierto es el 2 y suma el lote 1, que da 1.000. Después llega el cobro
de a, en el lote 1, que termina en 2.500. **El informe del lote cerrado salió con un total que nunca fue el final.**

En `REPEATABLE READ` todo confirma. En `SERIALIZABLE`, el que falla es a:

```text
 c3  1 fila  (1000.00)
 c4  COMMIT
 a3  ✗ 40001 could not serialize access due to read/write dependencies among transactions
```

Y sin el informe, con la permutación `a1 a2 b1 b2 b3 a3 a4`, las dos transacciones que escriben confirman en `SERIALIZABLE`: a
antes que b es un orden en serie válido. **La lectura del informe es lo que vuelve imposible ese orden.** Un nivel que solo mira
las escrituras no puede ver esta anomalía.

> 🩻 **Esto sí funciona igual** en Postgres y MySQL: el `SELECT` común no bloquea a nadie y nadie lo bloquea, porque lee
> versiones. La diferencia está en qué versión, y en qué pasa cuando hay que escribir.

---

## 🔀 6. El contraste: dónde otro motor cambia la decisión

**MySQL** corre los mismos escenarios, con `SET SESSION TRANSACTION ISOLATION LEVEL` y `START TRANSACTION` en lugar de `BEGIN
ISOLATION LEVEL` (`*_mysql.race`):

> 📐 **Medición: anomalías por nivel en MySQL** · `mysql@sha256:e2bde46db656…` · verificado el 14/10/2026
>
> | Anomalía | `READ UNCOMMITTED` | `READ COMMITTED` | `REPEATABLE READ` | `SERIALIZABLE` |
> |---|---|---|---|---|
> | lectura sucia | ❌ pasa | no pasa | no pasa | no pasa |
> | lectura no repetible | ❌ pasa | ❌ pasa | no pasa | espera |
> | fantasma | ❌ pasa | ❌ pasa | no pasa | espera |
> | actualización perdida | ❌ pasa | ❌ pasa | ❌ **pasa** | *deadlock* 1213 |
> | *write skew* (la muestra) | ❌ pasa | ❌ pasa | ❌ pasa | *deadlock* 1213 |
> | anomalía de solo lectura | ❌ pasa | ❌ pasa | ❌ pasa | espera |

Dos decisiones cambian. **La actualización perdida pasa en el `REPEATABLE READ` de MySQL**, que es su nivel por defecto: la
segunda caja espera a la primera y después escribe su 23,00 encima del 18,00, sin error. El saldo queda en 23,00 donde debía
quedar en 13,00. Y `SERIALIZABLE` en MySQL no detecta nada: convierte cada `SELECT` dentro de una transacción en una lectura
con bloqueo compartido (`FOR SHARE`). Las anomalías desaparecen porque **el orden que las produce no puede ocurrir**: o alguien
espera (el arnés lo declara imposible) o dos esperas se cruzan y una muere por *deadlock*.

La otra rareza de MySQL es que una transacción en `REPEATABLE READ` tiene **dos verdades**. El `SELECT` común lee la foto; el
`SELECT … FOR UPDATE`, el `UPDATE` y el `DELETE` leen lo último confirmado (`current_read_mysql.race`):

```text
 a3  1 fila  (28.00)          la foto
 b1  UPDATE 1                 otra caja cobra 10 y confirma
 a4  1 fila  (28.00)          la foto, otra vez
 a5  1 fila  (18.00)          FOR UPDATE: lo último confirmado
 a6  UPDATE 1                 balance - 5, sobre el 18
 a7  1 fila  (13.00)
```

En la misma transacción, el saldo es 28,00 o 18,00 según cómo se pregunte. Y la lectura bloqueante bloquea también el
**hueco** del índice donde iría una fila que no existe (*gap lock*). Con la pregunta "¿alguien ya tomó esta muestra?" hecha con
`FOR UPDATE` (`locking_check_mysql.race`), los dos técnicos bloquean el mismo hueco, el `INSERT` de cada uno choca con el del
otro, y MySQL corta el ciclo con un 1213: **el *write skew* no pasa en `REPEATABLE READ`**. En Postgres, el mismo `FOR UPDATE`
sobre una fila que no existe no bloquea nada, y la muestra se toma dos veces (`locking_check.race`). La misma línea de SQL
protege en un motor y no en el otro.

> 🪞🔒 **Apuesta sin resolver: Oracle.** Hipótesis: en Oracle, `SERIALIZABLE` deja pasar el *write skew* de la muestra (los dos
> técnicos confirman, porque escriben filas distintas), y la actualización perdida termina en
> `ORA-08177: can't serialize access for this transaction` para la segunda caja. Condiciones: las tablas de `01_setup.sql`
> creadas en el esquema de la aplicación, `SET TRANSACTION ISOLATION LEVEL SERIALIZABLE` en dos sesiones de `sqlplus`
> ([`a03`](a03-clis-de-los-motores.md#️-oracle--sqlplus)), y los pasos de `write_skew.race` y `lost_update.race` a mano, en ese
> orden. El mecanismo, en la documentación oficial: una transacción serializable ve "solo los cambios confirmados cuando
> empezó la transacción" y recibe un error si intenta modificar datos que otra cambió después; no menciona el *write skew*.
> Oracle ofrece `READ COMMITTED`, `SERIALIZABLE` y un modo de solo lectura, y nunca permite la lectura sucia. 📝 No publicamos
> números de Oracle; el porqué está en [`a09`](a09-licencias-publicacion-y-riesgo.md).

---

## 🪞 7. Tu instinto dice… y la apuesta

**Tu instinto dice** que `REPEATABLE READ` protege a una transacción de lo que hacen las otras, y que `SERIALIZABLE` es lo
mismo con más seguridad: si los dos técnicos corren en un nivel alto, no pueden tomar la misma muestra.

> 🪞 **Apuesta antes de ejecutar** (escrita el 30/09/2026 al diseñar esta fase, con la parte de MySQL agregada el 14/10/2026,
> antes de medir). *"El* write skew *de la muestra pasa en `REPEATABLE READ` de Postgres, y en `SERIALIZABLE` una de las dos
> transacciones falla con un error de serialización (`40001`). En MySQL, `REPEATABLE READ` también lo deja pasar, y
> `SERIALIZABLE` lo frena con un* deadlock *(1213), no con un error de serialización."*
> **Resultado:** **ganada, las dos mitades.** En Postgres, dos tomas confirmadas en `REPEATABLE READ` y un `40001` en el `COMMIT`
> de b en `SERIALIZABLE`. En MySQL, dos tomas en `REPEATABLE READ` y un `1213` en el `INSERT` de b en `SERIALIZABLE`.

Lo que la apuesta no decía es lo que vino al lado. `REPEATABLE READ` no protege la regla porque la regla no está en ninguna fila
que la transacción lea dos veces: está en una fila que **todavía no existe**. Y "subir el nivel" significa cosas distintas en
cada motor: en Postgres, aceptar errores que la aplicación tiene que reintentar; en MySQL, aceptar esperas y *deadlocks*. La
siguiente sección mide la consecuencia de la primera.

---

## 💥 8. El punto de rotura

**El error de serialización sin bucle de reintento.** `technicians.py` pone a cuatro técnicos a tomar 100 muestras cada uno, en
hilos de verdad y sin orden fijo, de seis maneras. Cuatro corridas (tres al escribir la fase y una en la validación del bloque):

> 📐 **Medición: cuatro técnicos, 400 tomas** · Postgres · verificado el 14/10/2026
>
> | Modo | Tomas que quedaron | Muestras tomadas dos veces | Errores que vio el técnico | Reintentos |
> |---|---|---|---|---|
> | `READ COMMITTED`, el código de 2020 | 400 | 123–129 | 0 | 0 |
> | `SERIALIZABLE`, sin bucle | **99–116** | 0 | **284–301** | 0 |
> | `SERIALIZABLE`, con bucle de reintento | 400 | 0 | 0 | 1.012–1.173 |
> | `READ COMMITTED` con `UNIQUE` | 400 | 0 | 0 | 695–773 |
> | `READ COMMITTED`, `FOR UPDATE SKIP LOCKED` sobre la muestra | 400 | **153–165** | 0 | 0 |
> | lo mismo, con la toma anotada en la fila bloqueada | 400 | 0 | 0 | 0 |

En `READ COMMITTED`, las 400 tomas se hacen y un tercio de las muestras se procesa dos veces o más: con cuatro técnicos mirando la
misma primera muestra libre, casi todos ven la misma. En `SERIALIZABLE` sin bucle, la duplicación desaparece **y con ella tres de
cada cuatro tomas**: el técnico recibe un error y esa muestra no la toma nadie en ese turno. Es la rotura: el nivel que evita el
error de datos lo cambia por un error de aplicación, y si la aplicación no lo atrapa, el laboratorio procesa menos.

El bucle de reintento es poco código:

```python
for attempt in range(10):
    try:
        take_once(conn, "serializable", who)       # una transacción entera: mira y toma
        break
    except psycopg.Error as exc:
        if exc.sqlstate not in ("40001", "40P01"):  # solo se reintenta lo que el motor dice que se reintenta
            raise
        time.sleep(random.uniform(0, 0.002 * 2 ** attempt))
```

Con el bucle, las 400 tomas quedan y ninguna se duplica, al precio de 2,5 a 2,9 intentos fallidos por toma con cuatro técnicos.
Sin la espera aleatoria, el costo crece con la concurrencia, porque todos pelean por la misma primera muestra libre:

| Técnicos | Reintentos por toma, sin espera | Con espera aleatoria (base 2 ms, tope de 10 intentos) |
|---|---|---|
| 2 | 0,85 | — |
| 4 | 2,5–2,9 | — |
| 8 | 3,4 | 0,27 |
| 16 | 5,8 | — |

La espera aleatoria baja los reintentos de 1.368 a 108 con ocho técnicos. Sin espera y con el tope de diez intentos, 28 de las
400 tomas se abandonan: el tope sin espera convierte la contención en errores otra vez.

---

## ⚰️ 9. Autopsia: "ponemos `SERIALIZABLE` y listo"

Un escenario, declarado como tal: la historia no dice que nadie en Alameda lo haya hecho. Es la propuesta que aparece en cualquier
equipo después del primer duplicado, y la que el sistema nuevo va a escuchar.

**1. La decisión.** *"Que las transacciones de la planilla corran en `SERIALIZABLE`."* Una línea en la cadena de conexión, o
`default_transaction_isolation` en el rol de la aplicación.

**2. Por qué era razonable.** Es el nivel que el estándar define como "como si corrieran de a una". El duplicado desaparece, y
se puede probar: `write_skew.race` en `SERIALIZABLE` deja una sola toma. No hace falta tocar el código de la planilla.

**3. Qué pasó después.** El código de la planilla no tenía bucle de reintento, porque en `READ COMMITTED` nunca había recibido un
error. Con cuatro técnicos, entre 284 y 301 de 400 tomas terminan en un error que el técnico ve en pantalla. Con dieciséis, 339 de
400. La muestra duplicada se convirtió en una muestra que nadie toma, que es el otro síntoma de 2020: la PCR que se vence.

**4. Cuánto cuesta salir.** El bucle de reintento: diez líneas en el lugar donde se abre la transacción, a condición de que la
transacción se pueda repetir entera. Eso no es gratis: si en el medio manda un correo, imprime una etiqueta o llama a un servicio,
reintentarla lo hace dos veces (la [Fase 16](16-el-folio-sin-huecos.md) tiene ese problema con el web service fiscal).

**5. Qué lo habría cambiado.** Preguntar qué regla se rompía y escribirla donde vive. "Una muestra, un técnico" es una restricción
`UNIQUE (specimen_id)` en la tabla de tomas: en `READ COMMITTED`, el segundo técnico recibe un `23505` o, con `ON CONFLICT DO
NOTHING`, pasa a la siguiente muestra sin error. O un bloqueo explícito sobre la fila de la muestra, con el estado en esa misma
fila.

**Antes y después, con números:** 284–301 tomas perdidas de 400 con `SERIALIZABLE` sin bucle, contra 0 perdidas y 0
duplicadas con la restricción `UNIQUE` en `READ COMMITTED`, que necesitó entre 695 y 773 segundos intentos, y ninguno visible
para el técnico.

---

## 📖 10. Traducción

| Concepto | Access / T-SQL | Postgres | MySQL | Oracle |
|---|---|---|---|---|
| nivel por defecto | `READ COMMITTED` con bloqueos | `READ COMMITTED` | `REPEATABLE READ` | `READ COMMITTED` |
| leer la foto del comienzo | `SNAPSHOT` (si la base lo permite) | `REPEATABLE READ` | `REPEATABLE READ` (lectura común) | `SERIALIZABLE` |
| serializable de verdad | `SERIALIZABLE` (con bloqueos de rango) | `SERIALIZABLE` (SSI) | `SERIALIZABLE` (lecturas con bloqueo) | — |
| leer lo último confirmado dentro de la foto | — | — | `FOR UPDATE`, `FOR SHARE` | — |
| error de serialización | 1205 (*deadlock*), 3960 (`SNAPSHOT`) | `40001`, `40P01` | 1213 (*deadlock*) | `ORA-08177`, `ORA-00060` |
| bloquear la fila antes de calcular | `WITH (UPDLOCK)` | `SELECT … FOR UPDATE` | `SELECT … FOR UPDATE` | `SELECT … FOR UPDATE` |
| tomar la siguiente libre sin esperar | `WITH (READPAST)` | `FOR UPDATE SKIP LOCKED` | `FOR UPDATE SKIP LOCKED` | `FOR UPDATE SKIP LOCKED` |

Hacia la NoSQL Lite: una transacción de varios documentos en MongoDB lee una foto (*snapshot*) y aborta con un error de
conflicto de escritura si otra cambió el mismo documento; el *write skew* entre documentos distintos le pasa igual que al
`REPEATABLE READ` de Postgres. El diccionario completo está en [`a07`](a07-diccionario-y-glosario.md).

---

## ⚖️ 11. Veredicto honesto: cuándo NO usar esto

**Cuándo no subir el nivel.** Cuando la regla que se rompe se puede escribir. "Una muestra, un técnico" es `UNIQUE`; "el saldo no
se pisa" es `UPDATE … SET balance = balance - 10`, que en `READ COMMITTED` espera a la otra caja y resta sobre lo confirmado
(28 − 10 − 5 = 13, ejercicio 9), en los dos motores. La restricción vale para todas las transacciones, en cualquier
nivel, escritas hoy o dentro de diez años; el nivel solo vale para las que lo pidieron.

**Cuándo no usar `SERIALIZABLE`.** Cuando la transacción no se puede repetir entera (llama a un servicio, imprime, manda algo), y
cuando la contención está concentrada en un punto: los reintentos crecen con los técnicos (0,85 por toma con dos, 5,8 con
dieciséis) porque todos chocan en la misma primera muestra. Ahí la cola con `SKIP LOCKED` reparte el trabajo en vez de
reintentarlo.

**Cuándo sí.** Cuando la regla es entre filas que la transacción lee y no se puede escribir como restricción (el informe del
lote cerrado, una disponibilidad calculada), la contención es baja, y el código tiene un solo lugar donde abre transacciones y
puede envolverlo en el bucle. En Postgres, el SSI es la única forma de que ese informe no mienta sin bloquear a la caja.

**El bloqueo explícito, con una condición.** `FOR UPDATE SKIP LOCKED` sobre la muestra, con la toma anotada en otra tabla,
**duplica entre 153 y 165 muestras de 400**: el técnico b bloquea la muestra justo cuando a confirma y la suelta, y Postgres vuelve
a comprobar la fila bloqueada, no el `NOT EXISTS` sobre la otra tabla. Con el estado en la misma fila que se bloquea
(`specimen.taken_by IS NULL`), cero duplicados y cero reintentos. **El bloqueo protege la fila que bloquea, no la regla.**

**Lo que no se mide aquí:** el costo de SSI en memoria con muchas transacciones largas (`max_pred_locks_per_transaction`), y el
de MySQL en `SERIALIZABLE` con carga real, donde cada lectura bloquea.

Las cinco preguntas, para lo que enseñó esta fase:

- **Frontera transaccional:** la regla "una muestra, un técnico" cruza dos transacciones; o se escribe en la base, o el nivel la
  vigila, o se pierde.
- **Consultas conocidas:** la consulta de la planilla es una sola y conocida: por eso su arreglo puede ser una restricción.
- **Unidad de lectura:** la foto de `REPEATABLE READ` es de toda la base, no de las filas leídas.
- **Saltos:** cada lectura de otra tabla dentro de la transacción es una dependencia más que el SSI tiene que vigilar.
- **Exactitud o parecido:** el informe del lote cerrado tiene que ser exacto; el de "cuántas muestras quedan" puede ser
  aproximado y no necesita nada de esto.

---

## ⚠️ 12. Errores comunes y diagnóstico

- **`ERROR: could not serialize access due to read/write dependencies among transactions` (`40001`).** 🩺 Es el SSI de
  Postgres. Se reintenta la transacción entera, no la sentencia; si aparece en el `COMMIT`, también.
- **`ERROR: could not serialize access due to concurrent update` (`40001`).** 🩺 `REPEATABLE READ` o `SERIALIZABLE` quisieron
  escribir una fila que otra transacción cambió después de su foto. Igual: reintentar entera.
- **`ERROR 1213 (40001) at line 1: Deadlock found when trying to get lock; try restarting transaction`** (en PyMySQL, `OperationalError: (1213, …)`). 🩺 En MySQL `SERIALIZABLE` o
  con lecturas bloqueantes, dos lecturas compartidas que después quieren escribir. MySQL ya deshizo la transacción entera.
- **El saldo quedó en el valor de la última caja, sin error, en MySQL.** 🩺 La actualización perdida de `REPEATABLE READ`:
  el `UPDATE` con un valor calculado afuera. Usa `SET balance = balance - …` o `FOR UPDATE` antes de leer.
- **En MySQL, `SELECT` dice una cosa y `SELECT … FOR UPDATE` otra.** 🩺 La foto contra la lectura bloqueante, en
  `REPEATABLE READ`. No es un error; es el diseño.
- **Un escenario de `lab race` en MySQL da resultados distintos en dos corridas.** 🩺 El *setup* borró con `DELETE`: usa
  `TRUNCATE` ([`a04`](a04-el-arnes-de-forma.md#-uv-run-lab-race-sesiones-en-un-orden-fijo)).
- **`FOR UPDATE SKIP LOCKED` y aun así duplicados.** 🩺 El estado que dice "tomada" está en otra tabla que la fila bloqueada.

---

## 📋 13. Checklist de validación

```text
[ ] write_skew.race: dos tomas en READ COMMITTED y en REPEATABLE READ; 40001 en el COMMIT de b en SERIALIZABLE
[ ] write_skew_mysql.race: dos tomas en REPEATABLE READ; 1213 en SERIALIZABLE
[ ] matrix.py: las dos matrices de las secciones 5.2 y 6, iguales en dos corridas
[ ] lost_update_mysql.race en REPEATABLE READ: el saldo queda en 23,00
[ ] current_read_mysql.race: 28,00 con la lectura común, 18,00 con FOR UPDATE
[ ] read_only.race en SERIALIZABLE: falla a; sin el informe, no falla nadie
[ ] technicians.py: SERIALIZABLE sin bucle pierde unas 290 tomas de 400; con UNIQUE, cero
```

---

## 🧪 14. Ejercicios (26)

Los escenarios se corren desde `src/` con `uv run lab race -f 15-aislamiento-comparado/<escenario>.race --isolation <nivel>`,
después de `01_setup.sql` (y `01_setup_mysql.sql` en MySQL).

## 🟢 Fácil — reproducir (1–8)

### 🟢 Ejercicio 1 — La muestra en tres niveles

Corre `write_skew.race` en `read-committed`, `repeatable-read` y `serializable`.

**Objetivo:** cuántas tomas quedan en cada nivel, y en qué paso aparece el error.

[Solución](soluciones/15-aislamiento-comparado.md#ejercicio-1)

### 🟢 Ejercicio 2 — La matriz

Corre `matrix.py` dos veces.

**Objetivo:** las dos matrices de la fase, iguales en las dos corridas, y por qué la lectura sucia no pasa en el `READ
UNCOMMITTED` de Postgres.

[Solución](soluciones/15-aislamiento-comparado.md#ejercicio-2)

### 🟢 Ejercicio 3 — La caja que pisa a la otra

Corre `lost_update.race` en `read-committed` y en `repeatable-read`.

**Objetivo:** el saldo final de cada corrida, y el error de la segunda.

[Solución](soluciones/15-aislamiento-comparado.md#ejercicio-3)

### 🟢 Ejercicio 4 — La misma caja en MySQL

Corre `lost_update_mysql.race` en `repeatable-read`.

**Objetivo:** el saldo final, y por qué no hay error.

[Solución](soluciones/15-aislamiento-comparado.md#ejercicio-4)

### 🟢 Ejercicio 5 — Dos verdades

Corre `current_read_mysql.race`.

**Objetivo:** los cuatro saldos que ve a, y de dónde sale cada uno.

[Solución](soluciones/15-aislamiento-comparado.md#ejercicio-5)

### 🟢 Ejercicio 6 — La lectura sucia existe

Corre `dirty_read_mysql.race` en `read-uncommitted` y en `read-committed`.

**Objetivo:** el saldo que lee b en cada nivel.

[Solución](soluciones/15-aislamiento-comparado.md#ejercicio-6)

### 🟢 Ejercicio 7 — El fantasma

Corre `phantom.race` en `read-committed` y en `repeatable-read`.

**Objetivo:** los dos conteos de a en cada nivel.

[Solución](soluciones/15-aislamiento-comparado.md#ejercicio-7)

### 🟢 Ejercicio 8 — Los códigos

Para `40001`, `40P01`, `23505`, `1213` y `1205`, di qué los produce y si la transacción se puede reintentar entera.

**Objetivo:** la lista, con la fuente de cada uno.

[Solución](soluciones/15-aislamiento-comparado.md#ejercicio-8)

## 🟡 Intermedio — arreglar sin subir el nivel (9–15)

### 🟡 Ejercicio 9 — El cobro relativo

Escribe una versión de `lost_update.race` donde cada caja resta su pago (`balance = balance - 10`) en vez de escribir el saldo
calculado, y córrela en `read-committed`.

**Objetivo:** el saldo final 13,00, sin errores.

[Solución](soluciones/15-aislamiento-comparado.md#ejercicio-9)

### 🟡 Ejercicio 10 — Bloquear antes de calcular

Escribe una versión donde cada caja lee el saldo con `FOR UPDATE`, en `read-committed`, con la permutación que deja a la
segunda caja calcular sobre lo que confirmó la primera.

**Objetivo:** lo que lee la segunda caja, y el saldo final.

[Solución](soluciones/15-aislamiento-comparado.md#ejercicio-10)

### 🟡 Ejercicio 11 — Bloquear antes de calcular, en MySQL

Lo mismo que el 10, en MySQL y en `repeatable-read`.

**Objetivo:** lo que lee la segunda caja con `FOR UPDATE`, aunque su foto diga otra cosa.

[Solución](soluciones/15-aislamiento-comparado.md#ejercicio-11)

### 🟡 Ejercicio 12 — El informe que lo cambia todo

Corre `read_only.race` en `serializable`, y después con la permutación `a1 a2 b1 b2 b3 a3 a4`.

**Objetivo:** quién falla con el informe, quién sin él, y por qué.

[Solución](soluciones/15-aislamiento-comparado.md#ejercicio-12)

### 🟡 Ejercicio 13 — Una muestra, un técnico

Escribe una versión de `write_skew.race` que cree un índice `UNIQUE (specimen_id)` en el *setup* y lo borre en el
*teardown*, y córrela en `read-committed`.

**Objetivo:** el error de b, en qué paso, y cuántas tomas quedan.

[Solución](soluciones/15-aislamiento-comparado.md#ejercicio-13)

### 🟡 Ejercicio 14 — La misma línea, dos motores

Corre `locking_check.race` y `locking_check_mysql.race` en `repeatable-read`.

**Objetivo:** cuántas tomas quedan en cada motor, y qué bloqueó MySQL que Postgres no.

[Solución](soluciones/15-aislamiento-comparado.md#ejercicio-14)

### 🟡 Ejercicio 15 — Dos técnicos y dieciséis

Corre `technicians.py` con 2, 8 y 16 técnicos, siempre 400 tomas en total.

**Objetivo:** los reintentos por toma de `retry` y de `unique` en cada caso.

[Solución](soluciones/15-aislamiento-comparado.md#ejercicio-15)

## 🟠 Difícil — el costo de cada salida (16–21)

### 🟠 Ejercicio 16 — Un bucle de reintento de verdad

Escribe el bucle de reintento con espera aleatoria creciente y un tope de diez intentos, y mídelo con ocho técnicos y esperas
base de 0, 2 y 10 ms.

**Objetivo:** reintentos y tomas abandonadas con cada espera.

[Solución](soluciones/15-aislamiento-comparado.md#ejercicio-16)

### 🟠 Ejercicio 17 — Por qué `SKIP LOCKED` duplica

Explica, con el orden de los pasos de dos técnicos, por qué el modo `skip-locked` de `technicians.py` toma muestras dos veces y
`skip-locked-row` no.

**Objetivo:** el orden, y la frase de la documentación de Postgres que lo explica.

[Solución](soluciones/15-aislamiento-comparado.md#ejercicio-17)

### 🟠 Ejercicio 18 — Los bloqueos del *deadlock*

Con la API de Python de `lab race`, agrega a `lost_update_mysql.race` una tercera sesión que consulte
`performance_schema.data_locks` entre los pasos, en `serializable`.

**Objetivo:** los bloqueos de cada sesión antes del *deadlock*, y cuál de ellos lo produce.

[Solución](soluciones/15-aislamiento-comparado.md#ejercicio-18)

### 🟠 Ejercicio 19 — Las lecturas de predicado

Durante `write_skew.race` en `serializable`, consulta `pg_locks` desde una tercera sesión antes de los `COMMIT`.

**Objetivo:** los `SIReadLock` de cada sesión, sobre qué objetos, y por qué no bloquean a nadie.

[Solución](soluciones/15-aislamiento-comparado.md#ejercicio-19)

### 🟠 Ejercicio 20 — La muestra con el estado en su fila

Escribe un escenario `.race` para la variante `skip-locked-row` de `technicians.py` y córrelo en `read-committed` con dos
técnicos.

**Objetivo:** cada técnico con una muestra distinta, sin espera.

[Solución](soluciones/15-aislamiento-comparado.md#ejercicio-20)

### 🟠 Ejercicio 21 — El nivel por defecto

Muestra con `lab race` que `SET default_transaction_isolation` cambia el nivel de las transacciones que no lo dicen, solo en
esa sesión.

**Objetivo:** `transaction_isolation` en las dos sesiones.

[Solución](soluciones/15-aislamiento-comparado.md#ejercicio-21)

## 🔴 Muy difícil — decidir (22–26)

### 🔴 Ejercicio 22 — Oracle

Resuelve en tu máquina la apuesta 🪞🔒 de la sección 6.

**Objetivo:** el resultado de las dos carreras explicado con la documentación de Oracle, sin publicar ningún número.

[Solución](soluciones/15-aislamiento-comparado.md#ejercicio-22)

### 🔴 Ejercicio 23 — La política de Alameda

Propón el nivel por defecto del sistema nuevo, en qué transacciones se sube, y la regla del bucle de reintento.

**Objetivo:** la política, con la medición que sostiene cada parte.

[Solución](soluciones/15-aislamiento-comparado.md#ejercicio-23)

### 🔴 Ejercicio 24 — ¿Dónde deja de pagar el reintento?

Con las mediciones del 15 y el 16, decide a partir de cuántos técnicos conviene la cola con `SKIP LOCKED` sobre `SERIALIZABLE`
con reintento.

**Objetivo:** la decisión, con los números y lo que no se midió.

[Solución](soluciones/15-aislamiento-comparado.md#ejercicio-24)

### 🔴 Ejercicio 25 — La planilla del sistema nuevo

Diseña las tablas de la planilla de pendientes para el modelo `alameda`: dónde vive el estado de la muestra, qué restricción
cuida la regla, y cómo toma la siguiente un técnico.

**Objetivo:** el DDL y la consulta, con la medición de cero duplicados y cero reintentos.

[Solución](soluciones/15-aislamiento-comparado.md#ejercicio-25)

### 🔴 Ejercicio 26 — El pivote

En la anomalía de solo lectura, identifica las dos dependencias "leí lo que otra escribió después" y la transacción que hace de
pivote. Explica por qué Postgres aborta a esa y no a otra.

**Objetivo:** el diagrama de dependencias en `text`, y la regla del SSI que decide.

[Solución](soluciones/15-aislamiento-comparado.md#ejercicio-26)

---

## 📚 15. Referencias

**Documentación oficial**

- **Aislamiento de transacciones en Postgres 18** — https://www.postgresql.org/docs/18/transaction-iso.html — los cuatro
  niveles, el SSI y la recomendación de reintentar.
- **Bloqueos explícitos y `SKIP LOCKED`** — https://www.postgresql.org/docs/18/sql-select.html — la cláusula de bloqueo y lo que
  se vuelve a comprobar.
- **Niveles de aislamiento de InnoDB** — https://dev.mysql.com/doc/refman/9.7/en/innodb-transaction-isolation-levels.html
- **Lecturas consistentes y lecturas bloqueantes** — https://dev.mysql.com/doc/refman/9.7/en/innodb-consistent-read.html y
  https://dev.mysql.com/doc/refman/9.7/en/innodb-locking-reads.html
- **Concurrencia y consistencia en Oracle** — https://docs.oracle.com/en/database/oracle/oracle-database/23/cncpt/data-concurrency-and-consistency.html
- **`ORA-08177`** — https://docs.oracle.com/en/error-help/db/ora-08177/

**Papers y libros**

- **Hal Berenson et al., "A Critique of ANSI SQL Isolation Levels", SIGMOD 1995** — las anomalías que el estándar no nombra y el
  *snapshot isolation*.
- **Alan Fekete, Elizabeth O'Neil y Patrick O'Neil, "A Read-Only Transaction Anomaly Under Snapshot Isolation", SIGMOD Record,
  2004** — la anomalía de la sección 5.4.
- **Michael Cahill, Uwe Röhm y Alan Fekete, "Serializable Isolation for Snapshot Databases", SIGMOD 2008** — el SSI.
- **Dan Ports y Kevin Grittner, "Serializable Snapshot Isolation in PostgreSQL", VLDB 2012** — cómo lo implementó Postgres, con
  el ejemplo del cierre de lote.
- **Martin Kleppmann y Chris Riccomini, *Designing Data-Intensive Applications*, 2.ª ed., O'Reilly, 2026** — el capítulo de
  transacciones, con el *write skew* y los fantasmas.

**Orden de lectura sugerido:** la página de aislamiento de Postgres antes de la sección 5; Berenson antes de armar la matriz;
Ports y Grittner, con la sección 5.4 a mano.

> ⚠️ Las URL y sus contenidos cambian. Se consultaron el 14/10/2026.

---

## 🏁 16. Resultado de la fase

```text
LA MUESTRA (write skew)
  postgres   READ COMMITTED y REPEATABLE READ: 2 tomas · SERIALIZABLE: 40001 en el COMMIT de b
  mysql      READ COMMITTED y REPEATABLE READ: 2 tomas · SERIALIZABLE: 1213 · FOR UPDATE en REPEATABLE READ: 1213
LO QUE CAMBIA ENTRE MOTORES
  actualización perdida en REPEATABLE READ    postgres 40001 · mysql pasa (23,00 en vez de 13,00)
  SERIALIZABLE                                postgres detecta y aborta · mysql bloquea y espera
LA ROTURA · 4 técnicos, 400 tomas
  SERIALIZABLE sin bucle      284–301 tomas perdidas
  con bucle                   0 perdidas · 2,5–2,9 reintentos por toma (5,8 con 16 técnicos; 0,27 con espera aleatoria y 8)
  UNIQUE en READ COMMITTED    0 perdidas · 0 duplicadas
  SKIP LOCKED, estado en otra tabla   153–165 duplicadas · estado en la fila bloqueada: 0
```

> **La señal de que quedó bien:** *"Puedo reproducir cualquier anomalía siempre igual, decir qué nivel la evita en Postgres y en
> MySQL y a qué precio, y antes de subir el nivel pregunto si la regla se puede escribir en la base."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-15-aislamiento-comparado -m "F15 cerrada: lab race, la matriz de anomalías en dos motores, la muestra tomada dos veces y el bucle de reintento medido"
> ```
>
> Commits de la fase con prefijo `f15:`, los de ejercicio `f15 ej26: …`.
