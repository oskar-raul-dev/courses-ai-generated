# 🔑 Fase 10 — Identificadores: qué cuesta cada clave y qué dice de ti

> **Curso:** Ruta SQL · Fase 10 de 27 · Bloque II — La física y el tuning · **10 h**
> **Motores:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · MySQL `mysql@sha256:e2bde46db656…` (el caso central) · Oracle (apuesta sin resolver)
> **Entorno de ejecución:** SQL + Python
> **Perfil de volumen:** M, con el modelo de `uv run lab load --profile m --model`
> **El dolor de Alameda:** el protocolo `-1847263541`, el `DMax + 1` y el portal enumerado en 2018 (historia §3, 2004 y 2018)
> **Depende de:** Fase 09 · **Habilita:** Fase 11
> **Apéndices de apoyo:** a03, a04, a05, a06, a08
> **Fecha de verificación ejecutada:** 14/10/2026
> **Objetivo:** medir lo que cuesta cada tipo de clave en los dos motores, demostrar qué filtra cada
> identificador que se muestra, y dejar escrito el patrón: clave interna `bigint` e identificador público opaco.

---

## 🧭 1. Dónde estamos

La [Fase 09](09-el-tamano-de-las-cosas.md) mostró que InnoDB *es* su clave primaria: las filas viven ordenadas por
ella, y cada índice secundario la carga. Esta fase elige esa clave. Y elige algo más, que casi nunca se piensa al
mismo tiempo: **qué identificador se le muestra al mundo**, porque todo identificador que sale de la base cuenta
algo de ella.

Alameda tiene tres historias de identificadores, y las tres siguen en la caja. En 2004 la replicación de Jet
convirtió los autonuméricos en aleatorios, y durante una semana los informes salieron con números como
`-1847263541`. Rubén lo tapó con un `NroProtocolo` calculado con `DMax + 1`, que con dos recepcionistas a la vez da
números repetidos. Y en 2018 un paciente le restó uno al número de su URL en el portal, vio el resultado de otra
persona, y descargó catorce mil informes en una noche. La corrección de la agencia fue el MD5 del número.

---

## 🎯 2. Objetivos de esta fase

1. Medir en MySQL y en Postgres el tamaño de la clave primaria y de un índice secundario con `bigint`, UUIDv4 y
   UUIDv7.
2. Entender los huecos de las secuencias y del *identity*, y cuándo no importan.
3. Reproducir la secuencia que queda atrás después de una carga, y el techo de `integer`.
4. Demostrar qué filtra cada identificador: el secuencial, el MD5 del secuencial y el UUIDv7.
5. Dejar escrito el patrón de la clave interna y el identificador público, y lo que no arregla.

---

## 🚫 3. Qué NO entra todavía

- **Los índices en general y lo que cuestan al escribir** → [Fase 11](11-indices-y-lo-que-cuestan.md).
- **La autorización** (quién puede ver qué protocolo) → [Fase 23](23-la-base-como-producto.md). Esta fase lo dice y no lo resuelve.
- **El folio fiscal correlativo y sin huecos** → [Fase 16](16-el-folio-sin-huecos.md). Un identificador interno no necesita ser correlativo.

---

## 🏚️ 4. El dolor, en la caja

> 🏚️ **`legacy."Protocolos"`, los identificadores por año:**
>
> ```text
>  extract |     min     |    max     | neg
> ---------+-------------+------------+------
>     2003 |       16324 |      20632 |    0
>     2004 | -2145755878 | 2147056698 | 2211
>     …
>     2011 | -2147402959 | 2146872082 | 3943
>     2012 |    10011210 |   10031654 |    0
> ```

Hasta 2003, `IdProtocolo` es un autonumérico de Access que cuenta de uno en uno. De 2004 a 2011, con la replicación
de Jet, es **aleatorio en todo el rango de un entero de 32 bits**: 36.310 de ellos son negativos en la caja M. Desde
2012, con SQL Server, vuelve a ser secuencial, empezando en diez millones para no chocar con los viejos. Y la semana
de marzo de 2004 en que el número aleatorio fue también el número visible está en la caja: trece protocolos de la sede
central con `NroProtocolo` como `-1324281976`.

El número visible tiene su propio defecto. `DMax + 1` lee el máximo y le suma uno, y dos recepcionistas que lo leen a
la vez obtienen el mismo. En la primera semana de marzo de 2025, la sede central tiene 1.741 protocolos y 1.735
números distintos.

Y el tercero no está en la caja, porque es el portal: la URL era `ver.php?protocolo=C-0048213`. El estudiante de 2018
no necesitó ninguna técnica: le restó uno.

---

## 🧩 5. Qué cuesta cada clave, y qué dice

### 5.1 Las tres claves, en MySQL

MySQL es el caso central de esta fase, porque en InnoDB la clave primaria es la tabla. `mysql_keys.py` copia los
1.327.622 protocolos de `alameda.lab_order` en tres tablas de MySQL que solo difieren en la clave: `bigint`, un
UUIDv4 y un UUIDv7, los dos como `binary(16)`, con un índice secundario por paciente. Se insertan en el orden en que
llegaron los protocolos, como lo haría la aplicación. Python 3.13 no trae UUIDv7, y el script lo arma como dice la RFC
9562: 48 bits de milisegundos, la versión, la variante y azar.

> 📐 **Medición: la clave primaria en InnoDB** · perfil M · `mysql@sha256:e2bde46db656…` · verificado el 14/10/2026
>
> | Clave | Índice primario (la tabla) | Hojas | Índice por paciente |
> |---|---|---|---|
> | `bigint` | 3.109 páginas · 48,6 MB | 3.103 | 2.405 páginas · 37,6 MB |
> | UUIDv4 | 6.001 páginas · 93,8 MB | 5.190 | 3.497 páginas · 54,6 MB |
> | UUIDv7 | 3.816 páginas · 59,6 MB | 3.794 | 3.497 páginas · 54,6 MB |
>
> Reproducir: `uv run python 10-identificadores/mysql_keys.py`, desde `src/`.

Dos efectos distintos, y la tabla los separa. **El ancho**: un UUID ocupa 16 bytes y un `bigint` 8, y por eso el
UUIDv7 ya ocupa un 23 % más que el `bigint`, y el índice por paciente crece un 45 % con cualquiera de los dos UUID,
porque cada entrada secundaria lleva la clave primaria. **El orden**: el UUIDv4 es aleatorio, cada inserción cae en
cualquier hoja, la hoja llena se parte en dos medio vacías, y el índice primario termina con 6.001 páginas contra 3.816
del v7, que tiene el mismo ancho pero llega en orden. Por ser aleatorio, el UUIDv4 no mide lo mismo dos veces: en la
validación del cierre del Bloque II, sobre una carga nueva, dio 6.129 páginas y 95,8 MB (un 97 % más que el `bigint`); el
`bigint` y el v7 dieron exactamente lo mismo.

### 5.2 Las tres claves, en Postgres

En Postgres, la tabla es un montón y la clave primaria es un índice más. `01_postgres_keys.sql` y `02_load_keys.sql`
arman las mismas tres tablas; el UUIDv7 sale de `uuidv7()`, nuevo en Postgres 18, corrido a la fecha del protocolo
con su argumento de desplazamiento:

> 📐 **Medición: la clave primaria en Postgres** · perfil M · `pgvector/pgvector@sha256:2358fcba361e…` · verificado el
> 14/10/2026
>
> | Clave | Tabla | Índice primario | Índice por paciente | WAL de la carga |
> |---|---|---|---|---|
> | `bigint` *identity* | 66 MB | 28 MB | 18 MB | 280 MB |
> | UUIDv4 | 76 MB | 54 MB | 18 MB | 318 MB |
> | UUIDv7 | 76 MB | 40 MB | 18 MB | 298 MB |

El índice por paciente mide lo mismo en las tres: en Postgres, un índice secundario apunta a la fila con un puntero
físico, no con la clave. El primario repite el patrón de MySQL: el v4 casi duplica al `bigint`, y el v7 queda en el
medio, solo por el ancho (en la validación, el primario con UUIDv4 dio 52 MB). Y el WAL suma lo que cuesta escribir hojas en cualquier lugar: después de cada
`CHECKPOINT`, la primera modificación de una página se escribe entera en el WAL (*full-page write*), y el UUIDv4 toca
más páginas distintas.

### 5.3 Secuencias, *identity* y huecos

Una secuencia entrega números crecientes, y **no garantiza que no haya huecos**. Una transacción que pidió un número y
se deshizo no lo devuelve:

```text
 id | note
----+------
  1 | uno
  3 | dos
(2 rows)
```

El 2 se lo llevó un `ROLLBACK`. Con `CACHE 20`, cada sesión reserva veinte números de una vez, y los que no usa se
pierden cuando se desconecta. Los ORM llevan la idea más lejos con *hi/lo* (o el optimizador `pooled` de Hibernate):
la secuencia avanza de a cincuenta, y la aplicación reparte los cincuenta sin volver a la base:

```text
 primera_sesion
----------------
              1
 segunda_sesion
----------------
             51
```

Hay dos formas de declarar una *identity*, y la diferencia importa en una migración. Con `BY DEFAULT`, un `INSERT`
puede traer su propio valor, y la secuencia no se entera (es la rotura de la sección 8). Con `ALWAYS`, el motor lo
rechaza, salvo que se diga a propósito:

```text
ERROR:  cannot insert a non-DEFAULT value into column "id"
DETAIL:  Column "id" is an identity column defined as GENERATED ALWAYS.
HINT:  Use OVERRIDING SYSTEM VALUE to override.
```

`ALWAYS` convierte el error silencioso del día siguiente en un error ruidoso el día de la carga, y obliga a escribir
`OVERRIDING SYSTEM VALUE` en el único lugar donde tiene sentido: el script de migración, que después ajusta la
secuencia. Por eso el modelo del curso usa `ALWAYS` donde genera sus claves, como en `alameda.patient`.

Los huecos no son un problema para una clave interna: nadie la cuenta. Son un problema para un número que alguien sí
cuenta, como el folio de una factura, y eso es otra herramienta ([Fase 16](16-el-folio-sin-huecos.md)).

### 5.4 Lo que filtra cada identificador

Todo identificador que sale de la base es información. Tres casos, medidos.

**El secuencial filtra el volumen del negocio.** Dos números de protocolo de la sede central, uno del lunes 3 de marzo de
2025 y otro del lunes siguiente, tienen una diferencia de **1.735**. Esa semana la sede atendió **1.741** protocolos. Un
competidor que se hace dos análisis con una semana de distancia sabe cuántos pacientes atiende Alameda.

**El MD5 de un secuencial no oculta nada.** El portal de 2018 cambió `C-0048213` por su MD5. Pero los números posibles son
pocos: seis prefijos de sede por menos de un millón de números. `04_what_ids_leak.sql` arma el diccionario entero y lo cruza
con los hashes de las URL de 2018:

```text
 urls_2018 | revertidas
-----------+------------
     25517 |      25517
(1 row)
```

**Las 25.517**, con un diccionario de 4,2 millones de hashes que tardó 7,3 segundos en esta máquina. Para el rango del perfil
S, 420.000 hashes, un tercio de segundo. Un hash no es secreto si el espacio de lo que se hashea se puede recorrer.

**El UUIDv7 filtra la fecha.** Sus primeros 48 bits son el momento de su creación, y Postgres 18 los lee:

```text
               order_id               | version |   uuid_extract_timestamp   | ordered_on
--------------------------------------+---------+----------------------------+------------
 01a1231c-1a83-7cfa-b0e1-a32ca3695672 |       7 | 2026-10-10 00:00:06.787+00 | 2026-10-10
```

Para la mayoría de los sistemas eso no importa. Para un laboratorio, la fecha de un análisis puede ser un dato de salud
(el día de un hisopado en 2020). Un UUIDv4 no filtra nada: `uuid_extract_timestamp` devuelve `NULL`.

### 5.5 El número que se dicta por teléfono

Hay un tercer identificador, y no es una clave: el número que la recepción le da al paciente, el que se dicta por
teléfono y se imprime en el sobre. En Alameda es `NroProtocolo`, con el prefijo de la sede y `DMax + 1`. En la caja M,
**3.902 números están repetidos**, en 7.811 protocolos. Por año:

```text
 anio | count
------+-------
 2005 |    14
 2012 |    68
 2019 |    69
 2020 |   310
 2025 |   608
```

El error crece con la concurrencia, no con el tiempo: dos recepcionistas en 2005, tres cajas desde 2012, y la pandemia,
que multiplicó por seis los protocolos diarios y por cuatro y medio los repetidos. `DMax + 1` lee el máximo y escribe el
siguiente en dos pasos, y entre los dos cualquiera puede leer el mismo máximo. Es una carrera, y el Bloque III la
reproduce.

Para el modelo nuevo, la lección de esta fase es separar los tres papeles que `NroProtocolo` mezclaba. **Identificar
la fila** es de la clave interna. **Viajar por internet** es del identificador público opaco. **Ser dictado por
teléfono** pide algo corto y legible, único dentro de su sede y su año, que puede salir de una secuencia por sede: una
secuencia no se repite nunca, aunque tenga huecos, y un hueco en el número del sobre no le importa a nadie. Lo que no se
puede es pedirle a un solo número que sea corto, legible, imposible de adivinar y sin huecos a la vez.

### 5.6 El patrón: una clave interna y un identificador público

Lo que esta fase mide se resume en un patrón:

- **La clave interna es un `bigint`** con *identity*: angosta, ordenada, barata en el índice primario y en cada secundario.
  No sale nunca de la base ni de la API interna.
- **El identificador público es opaco**: un UUIDv4, o un *token* al azar de longitud suficiente, en otra columna con un
  índice único. Es el que va en la URL, en el código QR del informe, en el correo.

El índice único del identificador público agregado a los protocolos de M mide 40 MB construido de una vez, y crece
hacia los 54 MB del primario con UUIDv4 a medida que se mantiene con inserciones al azar. Pero es un índice secundario
que solo se usa para entrar desde afuera: no entra en los joins ni en los demás índices de la tabla.

> ⚠️ **El ID opaco no arregla un IDOR.** Un identificador que no se puede adivinar evita que alguien recorra los protocolos
> de a uno, como en 2018. No evita que alguien que tiene un identificador ajeno (porque se lo reenviaron, porque quedó en
> un correo, porque lo copió de una pantalla) vea un resultado que no es suyo. Eso es una **referencia directa insegura a
> un objeto** (*IDOR*), y lo arregla la autorización: verificar en cada consulta que quien pide el protocolo tiene derecho
> a verlo. Es la [Fase 23](23-la-base-como-producto.md), con la seguridad por fila.

> 🩻 **Esto sí funciona igual** en los tres motores: una secuencia no garantiza ausencia de huecos, un UUID ocupa 16 bytes,
> y lo que se muestra al mundo filtra lo que contiene.

---

## 🔀 6. El contraste: dónde otro motor cambia la decisión

**En MySQL, la clave primaria es la decisión física más cara de la tabla**, y por eso esta fase lo puso en el centro: el
UUIDv4 duplica el índice primario y agranda en un 45 % cada índice secundario, que en Postgres no se mueve.

Y MySQL se comporta distinto en la rotura (sección 8). Cargada la misma tabla con los identificadores explícitos de la caja,
`AUTO_INCREMENT` se ajusta solo al máximo más uno, y el `INSERT` siguiente no falla:

```text
+-------------------+------------+
| max(lab_order_id) | siguiente  |
+-------------------+------------+
|        2147413575 | 2147413576 |
+-------------------+------------+
```

No falla, pero hereda el otro problema: el máximo es un identificador de Jet, a 70.072 números del techo de un `int`. Al
llegar, MySQL repite el último valor:

```text
ERROR 1062 (23000) at line 3: Duplicate entry '2147483647' for key 'lab_order_new.PRIMARY'
```

> 🪞🔒 **Apuesta sin resolver: Oracle.** Hipótesis: los valores de `SYS_GUID()` generados por una misma sesión crecen casi en
> orden (la documentación dice que combina un identificador del equipo, uno del proceso y un valor que no se repite), y un
> índice primario `RAW(16)` cargado con ellos queda mucho más cerca del UUIDv7 que del UUIDv4 de MySQL. Condiciones: los
> protocolos de M en una tabla con `DEFAULT SYS_GUID()`, insertados en el orden de llegada, y el tamaño del índice con
> `DBMS_SPACE` en `sqlplus` ([`a03`](a03-clis-de-los-motores.md#️-oracle--sqlplus)). El mecanismo, en la documentación oficial:
> la función `SYS_GUID` (en las referencias). 📝 No publicamos números de Oracle; el porqué está en
> [`a09`](a09-licencias-publicacion-y-riesgo.md).

---

## 🪞 7. Tu instinto dice… y la apuesta

**Tu instinto dice** que los UUID agrandan los índices porque son aleatorios, y que un UUIDv7, que es ordenado, tiene que
costar casi lo mismo que un `bigint`. La primera mitad es cierta.

> 🪞 **Apuesta antes de ejecutar** (escrita el 30/09/2026, al diseñar esta fase). *"Con UUIDv4 como clave primaria en
> InnoDB, el índice primario del perfil M queda al menos un 30 % más grande que con `bigint`, y con UUIDv7 la diferencia
> baja a menos del 10 %."*
> **Resultado:** **perdida.** El UUIDv4 queda **un 93 % más grande** (93,8 MB contra 48,6), muy por encima del 30 %. Pero el
> UUIDv7 queda **un 23 % más grande** (59,6 MB), no menos del 10 %.

El orden arregla las divisiones de página, y no arregla el ancho. Un UUIDv7 sigue ocupando 16 bytes contra los 8 de un
`bigint`, en cada fila de la tabla y en cada entrada de cada índice secundario (54,6 MB contra 37,6 en el índice por
paciente). La apuesta mezcló dos costos, y la medición los separó: de los 45 MB que el v4 le agrega al `bigint`, 11 son del
ancho y 34 del desorden.

---

## 💥 8. El punto de rotura

La migración de los protocolos a una tabla nueva, con *identity*, cargando los identificadores que ya tienen
(`03_sequence_behind.sql`):

```sql
-- postgres
CREATE TABLE staging.lab_order_new (
    lab_order_id integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    patient_id   integer NOT NULL,
    ordered_on   date NOT NULL
);
INSERT INTO staging.lab_order_new (lab_order_id, patient_id, ordered_on)
SELECT lab_order_id, patient_id, ordered_on FROM alameda.lab_order WHERE lab_order_id > 0;
-- y al día siguiente, el primer protocolo nuevo:
INSERT INTO staging.lab_order_new (patient_id, ordered_on) VALUES (1, '2026-10-11');
```

```text
INSERT 0 1291312
ERROR:  duplicate key value violates unique constraint "lab_order_new_pkey"
DETAIL:  Key (lab_order_id)=(1) already exists.
```

La secuencia de la *identity* no se entera de los valores explícitos, y entrega 1, que ya existe. La salida conocida es
`setval` al máximo, y ahí aparece la segunda rotura, la que la caja trae de 2004:

```text
   setval
------------
 2147413574
```

El máximo es un identificador aleatorio de Jet. Quedan 70.072 números antes del techo de `integer`, y en Postgres la
secuencia lo dice así:

```text
ERROR:  nextval: reached maximum value of sequence "lab_order_new_lab_order_id_seq" (2147483647)
```

Con unos 2.600 protocolos diarios, como en la pandemia, son 27 días. La salida de verdad es `bigint`: con él, el mismo
máximo deja más de nueve trillones de números por delante.

---

## ⚰️ 9. Autopsia: el MD5 del número de protocolo

**1. La decisión.** *"Que la URL no lleve el número de protocolo. Ponemos el MD5 del número."* La agencia del portal, 2018,
después del incidente.

**2. Por qué era razonable.** Era rápido: una columna calculada en la exportación nocturna, sin tocar SQL Server ni la
forma en que la recepción trabaja. El MD5 parece aleatorio, tiene 32 caracteres y nadie le resta uno. Y resolvía,
literalmente, lo que había pasado: el estudiante ya no podía recorrer los protocolos de a uno.

**3. Qué pasó después.** Nada visible, que es lo peligroso. El MD5 de un número de un espacio chico se revierte armando
todos los hashes posibles: 4,2 millones en 7 segundos, y las 25.517 URL de 2018 vuelven a ser números. Es el mismo
problema con un paso más. Y el portal quedó con su propia base, unida a la de SQL Server por el nombre, el DNI y ese
hash.

**4. Cuánto cuesta salir.** Una columna nueva con un identificador al azar (UUIDv4 o un *token* de 128 bits), un índice
único, y las URL viejas redirigidas o invalidadas. Y, sobre todo, la autorización que la URL nunca tuvo.

**5. Qué lo habría cambiado.** Separar las dos preguntas: *¿se puede adivinar el identificador?* y *¿quien lo usa tiene
derecho?* El MD5 contestaba mal la primera y no se hacía la segunda.

**Antes y después, con números:** un identificador que se revierte en el 100 % de los casos con un diccionario de 7 segundos,
contra uno de 122 bits al azar que no se puede recorrer, y una regla de autorización que no depende de ninguno de los dos.

---

## 📖 10. Traducción

| Concepto | Access / T-SQL | Postgres | MySQL | Oracle |
|---|---|---|---|---|
| autonumérico | `IDENTITY`; `SEQUENCE` desde 2012 | `GENERATED … AS IDENTITY`; secuencias | `AUTO_INCREMENT` | `GENERATED … AS IDENTITY`; secuencias |
| ajustar al máximo | `DBCC CHECKIDENT` | `setval` | automático al cargar | `START WITH LIMIT VALUE` |
| UUID aleatorio | `NEWID()` | `gen_random_uuid()` | `UUID()` es v1; v4 desde la aplicación | `SYS_GUID()` (no es un UUID estándar) |
| UUID ordenado | `NEWSEQUENTIALID()` | `uuidv7()` (18) | `UUID_TO_BIN(UUID(), 1)`, v1 reordenado | — |
| leer la fecha de un UUID | — | `uuid_extract_timestamp` (v1 y v7) | — | — |
| tipo de 16 bytes | `uniqueidentifier` | `uuid` | `binary(16)` | `RAW(16)` |

Hacia la NoSQL Lite: el `ObjectId` de Mongo tiene la marca de tiempo en sus primeros cuatro bytes, como un UUIDv7, y
filtra lo mismo. El diccionario completo está en [`a07`](a07-diccionario-y-glosario.md).

---

## ⚖️ 11. Veredicto honesto: cuándo NO usar esto

**Cuándo sí vale la pena un UUID como clave.** Cuando los identificadores se generan fuera de la base y antes de llegar a
ella: aplicaciones que trabajan sin conexión, varias bases que se juntan, un sistema que crea el registro en el teléfono del
paciente. Ahí, un UUIDv7 evita la coordinación que una secuencia necesita, y su costo (16 bytes y un 23 % de índice en
InnoDB) se paga con gusto. Es, irónicamente, el problema que la replicación de Jet resolvía en 2004 con números aleatorios.

**Cuándo no.** Cuando la base es una sola y genera las claves: ahí un `bigint` con *identity* es más chico, más rápido de
insertar y más fácil de leer en un plan. Y nunca un UUIDv4 como clave primaria de InnoDB en una tabla que crece: el 93 % de
la medición es el costo. Si el identificador tiene que ser un UUID por razones de negocio, que sea un v7, y que la clave
primaria de InnoDB siga siendo un `bigint` con el UUID en un índice único aparte: el desorden y el ancho quedan en un
solo índice, no en la tabla y en todos los demás.

**Cuándo no esconder el número.** Cuando no sale de la base. Un número de protocolo que solo ve la recepción no necesita ser
opaco, y un número que el paciente dicta por teléfono tiene que ser corto y legible. El identificador opaco es para lo que
viaja: URL, correos, códigos QR.

Las cinco preguntas, para lo que enseñó esta fase:

- **Frontera transaccional:** la secuencia está fuera de la transacción, y por eso deja huecos.
- **Consultas conocidas:** "el protocolo de esta URL", por el identificador público; todo lo demás, por la clave interna.
- **Unidad de lectura:** sin cambios.
- **Saltos:** ninguno nuevo; el identificador público es una columna, no una tabla.
- **Exactitud o parecido:** exactitud, y un hash de un espacio chico no la protege.

---

## ⚠️ 12. Errores comunes y diagnóstico

- **`duplicate key value violates unique constraint … Key (id)=(1)` después de una carga.** 🩺 La secuencia quedó atrás:
  `SELECT setval(pg_get_serial_sequence('t', 'id'), (SELECT max(id) FROM t));`, y mira cuánto falta para el techo del tipo.
- **`reached maximum value of sequence`.** 🩺 El tipo es `integer`. Pasa la columna y la secuencia a `bigint`.
- **`Duplicate entry '2147483647'` en MySQL.** 🩺 `AUTO_INCREMENT` llegó al techo del `int` y repite el último valor.
- **Un UUIDv4 que agranda todos los índices de MySQL.** 🩺 `mysql.innodb_index_stats`: si el primario tiene muchas más
  páginas que hojas llenas, son las divisiones; si los secundarios crecieron, es el ancho de la clave.
- **"Los IDs tienen huecos".** 🩺 Es normal en una secuencia. Si alguien los cuenta, no era un ID: era un folio.

---

## 📋 13. Checklist de validación

```text
[ ] mysql_keys.py deja las tres tablas en MySQL con 48,6 / 93,8 / 59,6 MB de índice primario
[ ] las mismas tres en Postgres: 28 / 54 / 40 MB de primario y 18 MB por paciente en las tres
[ ] la carga con identificadores explícitos falla con Key (lab_order_id)=(1) already exists
[ ] el máximo de los protocolos queda a 70.072 números del techo de integer
[ ] el diccionario de MD5 revierte las 25.517 URL de 2018
[ ] uuid_extract_timestamp devuelve la fecha de un UUIDv7 y NULL para un v4
```

---

## 🧪 14. Ejercicios (26)

## 🟢 Fácil — leer un identificador (1–7)

### 🟢 Ejercicio 1 — Los años de Jet

Cuenta los identificadores negativos de `legacy."Protocolos"` por año.

**Objetivo:** negativos solo de 2004 a 2011, y 36.310 en total.

[Solución](soluciones/10-identificadores.md#ejercicio-1)

### 🟢 Ejercicio 2 — La semana de los números raros

Busca los protocolos cuyo `NroProtocolo` no tiene la forma de la sede y el número.

**Objetivo:** trece, todos de la sede central y de marzo de 2004.

[Solución](soluciones/10-identificadores.md#ejercicio-2)

### 🟢 Ejercicio 3 — Un hueco

Crea una tabla con *identity*, inserta una fila, inserta otra en una transacción que se deshace, e inserta una tercera.

**Objetivo:** los identificadores 1 y 3.

[Solución](soluciones/10-identificadores.md#ejercicio-3)

### 🟢 Ejercicio 4 — La fecha de un UUIDv7

Genera un `uuidv7()` y lee su fecha con `uuid_extract_timestamp`.

**Objetivo:** la hora de ahora, y la versión 7.

[Solución](soluciones/10-identificadores.md#ejercicio-4)

### 🟢 Ejercicio 5 — Un UUIDv4

Haz lo mismo con `gen_random_uuid()`.

**Objetivo:** la versión 4 y una fecha `NULL`.

[Solución](soluciones/10-identificadores.md#ejercicio-5)

### 🟢 Ejercicio 6 — Las tres claves en Postgres

Corre `01_postgres_keys.sql` y `02_load_keys.sql` y mide los índices.

**Objetivo:** 28, 54 y 40 MB de índice primario.

[Solución](soluciones/10-identificadores.md#ejercicio-6)

### 🟢 Ejercicio 7 — Las tres claves en MySQL

Corre `mysql_keys.py` desde `src/`.

**Objetivo:** 48,6, 93,8 y 59,6 MB de índice primario.

[Solución](soluciones/10-identificadores.md#ejercicio-7)

## 🟡 Intermedio — lo que cuesta y lo que filtra (8–14)

### 🟡 Ejercicio 8 — El índice secundario carga la clave

Compara el índice por paciente en los dos motores, con las tres claves.

**Objetivo:** 37,6 contra 54,6 MB en MySQL, y 18 MB en las tres de Postgres.

[Solución](soluciones/10-identificadores.md#ejercicio-8)

### 🟡 Ejercicio 9 — El WAL de cada carga

Mide los bytes de WAL de cargar cada una de las tres tablas de Postgres.

**Objetivo:** 280, 318 y 298 MB, y por qué el v4 escribe más.

[Solución](soluciones/10-identificadores.md#ejercicio-9)

### 🟡 Ejercicio 10 — El volumen de una semana

Resta los números de protocolo de la sede central de dos lunes seguidos, y compara con los protocolos de la semana.

**Objetivo:** 1.735 contra 1.741, y por qué no son iguales.

[Solución](soluciones/10-identificadores.md#ejercicio-10)

### 🟡 Ejercicio 11 — El MD5 revertido

Corre `04_what_ids_leak.sql` y revierte las URL de 2018.

**Objetivo:** 25.517 de 25.517.

[Solución](soluciones/10-identificadores.md#ejercicio-11)

### 🟡 Ejercicio 12 — La secuencia atrás

Corre `03_sequence_behind.sql`.

**Objetivo:** el error literal, y la clave con la que choca.

[Solución](soluciones/10-identificadores.md#ejercicio-12)

### 🟡 Ejercicio 13 — `setval` y el techo

Pon la secuencia al máximo y calcula cuántos números quedan en un `integer`.

**Objetivo:** 2.147.413.574 y 70.072, y de dónde sale ese máximo.

[Solución](soluciones/10-identificadores.md#ejercicio-13)

### 🟡 Ejercicio 14 — `AUTO_INCREMENT` después de una carga

Repite la carga del ejercicio 12 en MySQL.

**Objetivo:** el valor siguiente de `AUTO_INCREMENT`, y por qué no falla.

[Solución](soluciones/10-identificadores.md#ejercicio-14)

## 🟠 Difícil — diseñar el identificador (15–20)

### 🟠 Ejercicio 15 — El techo en los dos motores

Lleva la secuencia y el `AUTO_INCREMENT` al máximo de un `integer` e inserta.

**Objetivo:** los dos errores literales.

[Solución](soluciones/10-identificadores.md#ejercicio-15)

### 🟠 Ejercicio 16 — La clave interna y el público

Agrega a `staging.order_bigint` un identificador público opaco con su índice único, y mide lo que cuesta.

**Objetivo:** el esquema, el tamaño del índice nuevo, y qué índices no se agrandaron.

[Solución](soluciones/10-identificadores.md#ejercicio-16)

### 🟠 Ejercicio 17 — Divisiones de página

Compara las páginas y las hojas del índice primario con UUIDv4 y con UUIDv7 en MySQL.

**Objetivo:** 6.001 y 5.190 contra 3.816 y 3.794, y qué significa la diferencia entre páginas y hojas.

[Solución](soluciones/10-identificadores.md#ejercicio-17)

### 🟠 Ejercicio 18 — *Hi/lo*

Crea una secuencia con `INCREMENT BY 50` y pide un valor desde dos sesiones.

**Objetivo:** 1 y 51, y cómo los usa un ORM.

[Solución](soluciones/10-identificadores.md#ejercicio-18)

### 🟠 Ejercicio 19 — El diccionario del perfil S

Mide cuánto tarda el diccionario de MD5 para el rango de protocolos del perfil S.

**Objetivo:** 420.000 hashes y el tiempo, y cuánto crece con la base de verdad.

[Solución](soluciones/10-identificadores.md#ejercicio-19)

### 🟠 Ejercicio 20 — La fecha como dato

Decide si un UUIDv7 puede ir en la URL del informe de un hisopado de 2020.

**Objetivo:** qué filtra, a quién le importa, y la alternativa.

[Solución](soluciones/10-identificadores.md#ejercicio-20)

## 🔴 Muy difícil — decidir (21–26)

### 🔴 Ejercicio 21 — El IDOR

Un paciente reenvía a su empleador el enlace opaco de su informe. Escribe qué falla y qué lo arregla.

**Objetivo:** por qué el identificador opaco no alcanza, y la regla de autorización que haría falta.

[Solución](soluciones/10-identificadores.md#ejercicio-21)

### 🔴 Ejercicio 22 — Los identificadores de Jet

Decide qué hace la migración con los 36.310 identificadores negativos y los aleatorios de 2004 a 2011.

**Objetivo:** conservarlos o renumerar, y qué se rompe en cada caso.

[Solución](soluciones/10-identificadores.md#ejercicio-22)

### 🔴 Ejercicio 23 — `SYS_GUID()`

Resuelve en tu máquina la apuesta 🪞🔒 de la sección 6.

**Objetivo:** explicar el resultado con la documentación de Oracle, sin publicar ningún número.

[Solución](soluciones/10-identificadores.md#ejercicio-23)

### 🔴 Ejercicio 24 — ¿UUID como clave?

La app de Florencia crea protocolos en el teléfono sin conexión. Decide la clave.

**Objetivo:** la decisión, con los números de esta fase.

[Solución](soluciones/10-identificadores.md#ejercicio-24)

### 🔴 Ejercicio 25 — `integer` o `bigint` para `result`

Decide el tipo de `result_id` con el volumen de la caja y el de la historia.

**Objetivo:** la cuenta, y cuántos años le quedan a un `integer`.

[Solución](soluciones/10-identificadores.md#ejercicio-25)

### 🔴 Ejercicio 26 — La URL del portal nuevo

Diseña el identificador de la URL del portal, y calcula cuántos intentos haría falta para adivinar uno.

**Objetivo:** el tipo, su longitud y la cuenta del espacio contra los protocolos de un año.

[Solución](soluciones/10-identificadores.md#ejercicio-26)

---

## 📚 15. Referencias

**Documentación oficial**

- **Funciones de UUID en Postgres 18** — https://www.postgresql.org/docs/18/functions-uuid.html — `gen_random_uuid`,
  `uuidv7` y `uuid_extract_timestamp`.
- **Secuencias en Postgres 18** — https://www.postgresql.org/docs/18/sql-createsequence.html — `CACHE`, los huecos y
  `setval`.
- **`AUTO_INCREMENT` en InnoDB** — https://dev.mysql.com/doc/refman/9.7/en/innodb-auto-increment-handling.html — los modos
  de bloqueo y los huecos.
- **`SYS_GUID` en Oracle Database 23** — https://docs.oracle.com/en/database/oracle/oracle-database/23/sqlrf/SYS_GUID.html
- **RFC 9562, *Universally Unique IDentifiers*** — https://www.rfc-editor.org/rfc/rfc9562 — la definición de UUIDv4 y v7.
- **OWASP, *Insecure Direct Object Reference Prevention Cheat Sheet*** —
  https://cheatsheetseries.owasp.org/cheatsheets/Insecure_Direct_Object_Reference_Prevention_Cheat_Sheet.html — por qué un
  identificador opaco no reemplaza la autorización.

**Orden de lectura sugerido:** la RFC 9562 antes de la sección 5.1; la documentación de secuencias antes de la 5.3; OWASP
después del veredicto.

> ⚠️ Las URL y sus contenidos cambian. Se consultaron el 14/10/2026.

---

## 🏁 16. Resultado de la fase

```text
LA CLAVE PRIMARIA · perfil M · 1.327.622 protocolos
  MySQL      bigint 48,6 MB · UUIDv4 93,8 MB (+93 %) · UUIDv7 59,6 MB (+23 %) · por paciente 37,6 → 54,6 MB
  Postgres   bigint 28 MB · UUIDv4 54 MB · UUIDv7 40 MB · por paciente 18 MB en las tres
LO QUE FILTRA CADA UNO
  secuencial      el volumen: 1.735 números para 1.741 protocolos en una semana
  MD5 del número  nada: 25.517 de 25.517 URL de 2018 revertidas en 7 segundos
  UUIDv7          la fecha de creación
LA ROTURA
  identity cargada a mano    Key (lab_order_id)=(1) already exists
  el máximo de Jet           a 70.072 números del techo de integer
```

> **La señal de que quedó bien:** *"Sé cuánto me cuesta cada clave, qué cuenta cada identificador que muestro, y que ninguno
> reemplaza preguntar si quien lo usa tiene derecho."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-10-identificadores -m "F10 cerrada: tres claves medidas en MySQL y Postgres, la secuencia atrás y el techo de integer, el MD5 revertido y el patrón de clave interna e identificador público"
> ```
>
> Commits de la fase con prefijo `f10:`, los de ejercicio `f10 ej16: …`.
