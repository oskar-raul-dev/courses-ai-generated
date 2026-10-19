# ⏳ Fase 07 — El tiempo en el modelo: vigencias, historia y lo que se sabía cuándo

> **Curso:** Ruta SQL · Fase 07 de 27 · Bloque I — El modelo · **8 h**
> **Motores:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · contraste MySQL `mysql@sha256:e2bde46db656…` · Oracle (apuesta sin resolver)
> **Entorno de ejecución:** SQL
> **Perfil de volumen:** M para todo
> **El dolor de Alameda:** las 280 tablas `Precios_AAAA_MM`, la vigencia sin fin de 2025 y la pregunta de Norma (historia §3, §4 y §5)
> **Depende de:** Fase 06 · **Habilita:** Fase 08
> **Apéndices de apoyo:** a03, a05, a07, a08
> **Fecha de verificación ejecutada:** 14/10/2026
> **Objetivo:** pasar los precios de 280 copias mensuales a rangos sin superposición, medir qué responde
> cada modelo cuando se pregunta por un mes pasado, y contestar con una consulta la pregunta de Norma:
> quién cambió un resultado, cuándo y qué decía antes.

---

## 🧭 1. Dónde estamos

Hasta aquí, el modelo describía el presente: un paciente, sus documentos, los convenios de hoy. La
[Fase 06](06-cuarta-y-quinta-forma-normal.md) dejó dicho que un convenio tiene vigencia y que esa vigencia
era de esta fase. En Alameda, casi todo lo que importa tiene una fecha: el precio que valía el mes que se
facturó, el resultado que se firmó antes de que alguien lo corrigiera, el documento que la persona tenía
cuando vino.

Hay dos preguntas distintas, y conviene no mezclarlas desde el principio. **¿Cuándo vale un dato en el
mundo?** El precio de la glucemia vale desde el 1 de julio hasta el 31: es el **tiempo válido**. **¿Cuándo lo
supo la base?** OSDE avisó en mayo un precio que valía desde abril: es el **tiempo de transacción**. La
mayoría de los sistemas guarda uno de los dos a medias, y la mayoría de los dolores de esta fase vienen de
ahí.

---

## 🎯 2. Objetivos de esta fase

1. Pasar los precios de 2002 a 2025 a una tabla de rangos con clave `WITHOUT OVERLAPS`.
2. Medir, mes por mes, qué devuelve la unión de las 280 tablas y qué devuelve la consulta *as-of*.
3. Cargar las vigencias de 2025 contra la restricción, y contar lo que no entra y por qué.
4. Validar lo facturado con una clave foránea con período.
5. Contestar la pregunta de Norma con una historia de correcciones, y una corrección retroactiva con dos
   tiempos.
6. Medir el costo de la sexta forma normal.

---

## 🚫 3. Qué NO entra todavía

- **El modelo completo de resultados** (tipos, calificadores, la bandera de muestra) → [Fase 08](08-los-dos-extremos-del-mismo-error.md). Aquí la
  historia de correcciones se prueba sobre un día de resultados.
- **Quién es "quién"**: usuarios, roles y permisos de verdad → Bloque V. Aquí el usuario es el
  `application_name` de la sesión.
- **Las tablas versionadas de SQL Server** → el track de SQL Server.

---

## 🏚️ 4. El dolor, en la caja

> 🏚️ **El catálogo de `legacy`**, filtrado por nombre:
>
> ```text
>  tablas | tamano  | filas
> --------+---------+-------
>     280 | 2240 kB | 20554
> (1 row)
> ```

En 2002 las obras sociales renegociaban la unidad bioquímica cada pocos meses. Rubén tenía **un precio por
práctica**, y cuando cambiaba lo pisaba. En septiembre una obra social pidió refacturar marzo, y el sistema
ya no sabía cuánto valía marzo: Rubén lo reconstruyó a mano desde los recibos impresos. Desde entonces, el
día 1 de cada mes, alguien copia la tabla `Precios` a `Precios_AAAA_MM`. Son 280, de `Precios_2002_09` a
`Precios_2025_12`.

Las copias tienen los defectos de lo que copiaban. Para cada práctica y cada mes en que existía:

```text
 filas_en_el_mes | pares_mes_practica | meses
-----------------+--------------------+-------
               0 |                425 |   219
               1 |              20180 |   280
               2 |                187 |   131
(3 rows)
```

**425 veces falta la práctica** en la copia (alguien la borró de `Precios` y la volvió a cargar después del
día 1), y **187 veces está dos veces**, una de ellas un 10 % más cara. Los dos defectos están repartidos en 248
de los 280 meses.

En 2025 Matías cambió a una tabla `Precios` con `VigenciaDesde`, por obra social y práctica. Es un paso
enorme, y tiene un hueco: **la vigencia no tiene fin**. El fin de una vigencia es el comienzo de la
siguiente, y cuando dos empiezan el mismo día, nada dice cuál vale.

Y la tercera pregunta no tiene tabla en la caja. Norma firma los resultados, y pregunta lo que el sistema
nunca contestó: *"¿quién cambió este resultado, cuándo, y qué decía antes?"*. `ResultadoItem` guarda el valor
y la fecha de carga. Si alguien lo corrige, el valor anterior desaparece.

---

## 🧩 5. Dos tiempos, un rango

### 5.1 El precio como rango, y la restricción que lo cuida

`02_practice_price.sql` junta las 280 copias en `staging.monthly_price`, con el mes como dato, y pasa cada
precio a un rango de fechas:

```sql
-- postgres
CREATE TABLE alameda.practice_price (
    practice_id  integer NOT NULL REFERENCES alameda.practice (practice_id),
    valid_during daterange NOT NULL,
    amount       numeric(19, 4) NOT NULL,
    CONSTRAINT practice_price_pkey PRIMARY KEY (practice_id, valid_during WITHOUT OVERLAPS)
);
```

`WITHOUT OVERLAPS`, nuevo en Postgres 18, dice que una práctica no puede tener dos precios cuyos rangos se
toquen. Debajo hay un mecanismo más viejo, la **restricción de exclusión** con un índice `gist`, que la fase
usa a mano en la tabla del valor de la unidad bioquímica:

```sql
-- postgres
CREATE TABLE alameda.biochemical_unit (
    valid_during daterange NOT NULL,
    amount       numeric(19, 4) NOT NULL,
    CONSTRAINT biochemical_unit_valid_during_excl EXCLUDE USING gist (valid_during WITH &&)
);
```

`WITHOUT OVERLAPS` necesita al menos una columna además del rango (`biochemical_unit` no la tiene, y por eso
usa la exclusión), y la columna escalar necesita la extensión `btree_gist`. Sin ella, el error es literal:
`data type integer has no default operator class for access method "gist"`.

Un precio que se superpone:

```text
ERROR:  conflicting key value violates exclusion constraint "practice_price_pkey"
DETAIL:  Key (practice_id, valid_during)=(2, [2009-07-15,2009-08-15)) conflicts with existing key (practice_id, valid_during)=(2, [2009-07-01,2009-08-01)).
```

¿Cuál de las dos filas pegadas es la buena? Las copias no lo dicen, pero la unidad bioquímica sí: en un mes,
todas las filas bien cargadas implican el mismo valor (`Valor / UB` de la práctica). La mediana de cada mes es
el valor de la UB, y la fila que implica un 10 % más va a la tabla de rechazos como
`precios.pegado_dos_veces`. Son las 187, y en las 187 la otra fila del par es la coherente.

### 5.2 La pregunta *as-of*

Con rangos, "¿cuánto valía la glucemia el 15 de julio de 2009?" es un predicado de contención:

```sql
-- postgres
SELECT p.description, x.valid_during, x.amount
FROM alameda.practice_price AS x JOIN alameda.practice AS p USING (practice_id)
WHERE x.practice_id = 2 AND x.valid_during @> date '2009-07-15';
```

```text
 description |      valid_during       | amount
-------------+-------------------------+--------
 GLUCEMIA    | [2009-07-01,2009-08-01) | 7.3400
(1 row)
```

Con las copias, la misma pregunta es "abrir la tabla del mes correcto", y una consulta que cruce meses tiene
que nombrar una tabla por mes. La de un año entero de glucemia, sobre los rangos, lee 11 bloques, por el índice
de la clave primaria.

### 5.3 La vigencia que no termina, y la clave foránea con período

`03_agreement_price.sql` calcula el fin de cada vigencia de 2025 como el comienzo de la siguiente, con `lead()`.
Las vigencias que empiezan el mismo día que otra (380 filas, 190 días, en 172 combinaciones de obra social y
práctica) van a la tabla de rechazos como `precios.vigencia_duplicada`, **las dos**: el modelo no puede elegir,
y ese período queda sin precio, que es lo que de verdad se sabe.

Lo facturado desde 2025 se valida contra esos precios con una **clave foránea con período**, también nueva en
Postgres 18 (`04_billed_practice.sql`):

```sql
-- postgres
ALTER TABLE alameda.billed_practice
    ADD CONSTRAINT billed_practice_agreement_price_fkey
    FOREIGN KEY (payer_code, practice_id, PERIOD billed_during)
    REFERENCES alameda.agreement_price (payer_code, practice_id, PERIOD valid_during) NOT VALID;
```

La clave pide que el período de lo facturado esté cubierto por las vigencias de su obra social y práctica,
aunque sean dos contiguas. Igual que con los huérfanos de la Fase 04, se crea `NOT VALID`, lo que no cumple va
a la tabla de rechazos y después se valida. De 1.746.067 prácticas facturadas desde enero de 2025, **109.496 no
tienen precio vigente**:

| Motivo | Prácticas |
|---|---|
| caen en el período de una vigencia duplicada | 73.855 |
| son anteriores a la primera vigencia de su obra social y práctica | 35.641 |

Las primeras tienen dos precios posibles, que difieren un 4 %. Sumada, **la duda vale $60.958.377**: lo que
Alameda puede haber facturado de más o de menos sin saberlo.

### 5.4 La historia de un resultado: la pregunta de Norma

El tiempo de transacción es el que pide Norma: no cuándo vale el resultado, sino cuándo la base dijo cada cosa.
`05_result_history.sql` lo arma sobre los 5.568 resultados del 9 de octubre de 2026: la tabla del valor actual
y una de historia, con el período en que cada versión fue la vigente y quién la reemplazó, llenada por un
disparador.

Una bioquímica corrige una glucemia (`165` → `156`), y Norma la vuelve a dejar como estaba. La pregunta, como
consulta:

```sql
-- postgres
SELECT h.value_text AS decia, h.recorded_by AS lo_cargo, h.replaced_by AS lo_cambio,
       upper(h.system_during) AS cuando
FROM staging.result_item_history AS h WHERE h.result_item_id = 12123358
UNION ALL
SELECT c.value_text, c.recorded_by, NULL, NULL
FROM staging.result_item_current AS c WHERE c.result_item_id = 12123358
ORDER BY cuando NULLS LAST;
```

```text
 decia |   lo_cargo   | lo_cambio |            cuando
-------+--------------+-----------+-------------------------------
 165   | carga-legacy | lucia2    | 2026-10-14 05:15:15.218698+00
 156   | lucia2       | norma     | 2026-10-14 05:15:16.227524+00
 165   | norma        |           |
(3 rows)
```

Tres líneas que en `ResultadoItem` no existen. El historial tiene clave `(result_item_id, system_during WITHOUT
OVERLAPS)`: dos versiones del mismo resultado no pueden haber sido vigentes a la vez. Quién es "lucia2" lo
dice hoy `application_name`, que la sesión escribe como quiere; la [Fase 23](23-la-base-como-producto.md) lo ata a
usuarios de verdad, con un rol por perfil y la identidad en los *claims* del token.

### 5.5 Lo bitemporal: lo que se sabía cuándo

Los dos tiempos juntos. El 1 de marzo de 2025 la base registra el precio de OSDE para la hemoglobina
glicosilada, vigente desde marzo. El 12 de mayo OSDE avisa que **desde el 1 de abril** vale otra cosa. Una
corrección común pisaría el precio, y la facturación de abril quedaría sin explicación. `06_bitemporal.sql`
guarda las dos versiones, cada una con su período de validez y su período de registro:

```text
 payer_code | practice_id |      valid_during       |                   recorded_during                   |   amount
------------+-------------+-------------------------+-----------------------------------------------------+------------
 OSDE       |           7 | [2025-03-01,)           | ["2025-03-01 12:00:00+00","2025-05-12 13:00:00+00") | 21000.0000
 OSDE       |           7 | [2025-03-01,2025-04-01) | ["2025-05-12 13:00:00+00",)                         | 21000.0000
 OSDE       |           7 | [2025-04-01,)           | ["2025-05-12 13:00:00+00",)                         | 23100.0000
```

Y las dos preguntas tienen respuesta distinta:

```text
          segun           |   amount
--------------------------+------------
 lo que se sabía el 30/04 | 21000.0000
 lo que se sabe hoy       | 23100.0000
(2 rows)
```

La primera explica la factura de abril; la segunda dice cuánto había que cobrar. La restricción es una
exclusión sobre los dos rangos a la vez: una tercera versión que se superponga en validez **y** en registro se
rechaza con el mismo `conflicting key value` de la sección 5.1.

### 5.6 La sexta forma normal, con su costo

Llevado al extremo, cada atributo tiene su propia historia: el nombre de un paciente cambia por separado de
su fecha de nacimiento. La **sexta forma normal** (y el *anchor modeling*, que la usa como método) pone cada
atributo en su tabla, con su período. `07_sixth_normal_form.sql` lo hace con tres atributos del paciente, y la
misma pregunta en los dos modelos (mujeres nacidas en 1950, con su nombre):

> 📐 **Medición: el paciente en 3FN y en 6FN** · perfil M · `pgvector/pgvector@sha256:2358fcba361e…` ·
> verificado el 14/10/2026
>
> | | 3FN (`alameda.patient`) | 6FN (ancla y tres atributos, al 1/1/2026) |
> |---|---|---|
> | tablas | 1 | 4, con 3 joins |
> | bloques leídos | 2.410 | 13.285 |
> | filas estimadas contra reales | 1.013 contra 1.014 | 764 contra 884 |
> | tamaño | 30 MB (con todas sus columnas) | 76 MB |
>
> Reproducir: las dos consultas del ejercicio 19.

Cinco veces y media los bloques, para tres atributos. La estimación todavía es buena porque cada atributo
tiene una sola versión; con historia de verdad, cada predicado de rango suma su error. Y la respuesta cambia:
884 contra 1.014, porque al 1 de enero de 2026 la base todavía no conocía a los 130 pacientes que llegaron
después de esa fecha. La 6FN contesta la pregunta temporal que la 3FN ni siquiera puede hacer, y la cobra en cada consulta.

> 🩻 **Esto sí funciona igual** en los tres motores: un rango de validez se puede guardar como dos columnas
> en cualquiera, y "vigente al día D" es `desde <= D AND D < hasta`. Lo que cambia es quién garantiza que no
> se superpongan (sección 6).

---

## 🔀 6. El contraste: dónde otro motor cambia la decisión

**MySQL no tiene tipos de rango, ni restricciones de exclusión, ni `WITHOUT OVERLAPS`:**

```text
ERROR 1064 (42000) at line 4: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'WITHOUT OVERLAPS))' at line 1
```

El rango va en dos columnas, con un `CHECK (valid_from < valid_to)`, y la no superposición en un disparador
que busca un rango que se toque y, si lo encuentra, aborta con `SIGNAL`:

```text
ERROR 1644 (45000) at line 20: practice_price: overlapping validity
```

Funciona para una sesión. Con dos sesiones que insertan a la vez, la búsqueda del disparador es una lectura
consistente que no bloquea nada, y las dos pueden pasar: la garantía es de la aplicación, no del motor. La
decisión que cambia es dónde vive la regla, y el Bloque III mide lo que cuesta.

> 🪞🔒 **Apuesta sin resolver: Oracle.** Hipótesis: con *Flashback Query* (`SELECT … AS OF TIMESTAMP`), un
> resultado corregido hace un minuto devuelve su valor anterior sin ninguna tabla de historia; uno corregido
> hace un día ya no, porque la retención de *undo* (`UNDO_RETENTION`, 900 segundos por defecto, o la que ajusta
> la gestión automática) no garantiza un día. Condiciones: una tabla con una fila, un `UPDATE` con `COMMIT`, y la consulta `AS OF TIMESTAMP`
> antes y después de la retención, en `sqlplus` ([`a03`](a03-clis-de-los-motores.md#️-oracle--sqlplus)). El
> mecanismo, en la documentación oficial: *Using Oracle Flashback Technology* (en las referencias). 📝 No
> publicamos números de Oracle; el porqué está en [`a09`](a09-licencias-publicacion-y-riesgo.md).

---

## 🪞 7. Tu instinto dice… y la apuesta

**Tu instinto dice** que una vez que los precios están en rangos sin superposición, cualquier mes pasado tiene
su precio correcto. Es lo que prometen los rangos, y es cierto para todo lo que se cargó.

> 🪞 **Apuesta antes de ejecutar** (escrita el 30/09/2026, al diseñar esta fase). *"La consulta as-of sobre
> el modelo de rangos devuelve el precio correcto en los 280 meses; la unión de las 280 tablas falla en los
> meses donde dos vigencias se superponen."*
> **Resultado:** **perdida.** La unión falla, como se esperaba, en los 131 meses con una fila pegada dos veces;
> los rangos los resuelven. Pero los rangos **no devuelven nada** en los 425 pares de práctica y mes en que la
> copia perdió la fila, repartidos en 219 meses. El modelo no inventa lo que la copia no guardó.

```text
     resultado     | pares | meses
-------------------+-------+-------
 sin fila          |   425 |   219
 una fila correcta | 20367 |   280
(2 rows)
```

"Correcto" quiere decir la UB de la práctica por la UB del mes, la que implican las filas bien cargadas. Y por
eso hay una salida: si el modelo guarda el valor de la UB de cada mes como un hecho (`biochemical_unit`), el
precio que falta se reconstruye, y la consulta *as-of* acierta **los 20.792 pares**. Es exactamente lo que hizo
Rubén con los recibos de marzo de 2002, con una diferencia: marzo de 2002 no está en ninguna copia, y para él no
hay reconstrucción posible. La consulta *as-of* de marzo de 2002 devuelve cero filas, y es la respuesta honesta.

---

## 💥 8. El punto de rotura

La vigencia de 2025, cargada como la guardó Matías, sin fin:

```sql
-- postgres
INSERT INTO alameda.agreement_price (payer_code, practice_id, valid_during, amount)
SELECT y.payer_code, c.practice_id, daterange(x."VigenciaDesde"::date, NULL), x."Valor"
FROM legacy."Precios" AS x
JOIN alameda.payer AS y ON y.payer_id = x."IdObraSocial"
JOIN alameda.practice_code AS c ON c.nomenclator_code = 'NBU2012' AND c.code = x."CodPractica";
```

```text
ERROR:  conflicting key value violates exclusion constraint "agreement_price_pkey"
DETAIL:  Key (payer_code, practice_id, valid_during)=(PAMI, 1, [2025-05-01,)) conflicts with existing key (payer_code, practice_id, valid_during)=(PAMI, 1, [2025-01-01,)).
```

La segunda vigencia de la primera combinación ya choca: una vigencia sin fin se superpone con todas las que
vienen después. La restricción dice en voz alta lo que la tabla de 2025 escondía.

Con el fin calculado por `lead()`, la carga vuelve a fallar, por otra razón:

```text
ERROR:  empty WITHOUT OVERLAPS value found in column "valid_during" in relation "agreement_price"
```

En un día duplicado, la primera de las dos vigencias termina donde empieza: `[d, d)`, un rango **vacío**.
`WITHOUT OVERLAPS` lo rechaza. Una restricción de exclusión escrita a mano no: los rangos vacíos no se
superponen con nada, y la misma carga entra entera, **con 190 vigencias vacías** que nadie ve. Es la única
diferencia práctica entre las dos formas, y está a favor de la nueva.

---

## ⚰️ 9. Autopsia: copiar la tabla de precios el primer día de cada mes

**1. La decisión.** *"Todos los días 1 copio `Precios` a una tabla con el mes en el nombre. Así no se pierde
nunca más un mes."* Rubén, septiembre de 2002, después de tres fines de semana con los recibos de marzo.

**2. Por qué era razonable.** Funcionó para lo que se pedía: desde entonces, ningún mes se perdió entero. Era
un paso en el menú, sin cambiar la tabla que usaban las pantallas, y en Access copiar una tabla es un clic.

**3. Qué pasó después.** 280 tablas que ocupan 2.240 kB y repiten 20.554 filas. La copia guarda lo que había
el día 1, con sus errores: 187 filas pegadas dos veces y 425 que alguien había borrado justo ese día. Un precio
que cambió el 15 no existe hasta el mes siguiente. Y cualquier consulta que cruce meses nombra una tabla por
mes: la evolución de un precio en diez años es una unión de 120 tablas.

**4. Cuánto cuesta salir.** `02_practice_price.sql`: un bloque `DO` que recorre las 280, una regla para las
filas pegadas, y una tabla de 20.367 rangos que ocupa 2.448 kB, casi lo mismo. Lo que no se recupera son las 425
filas borradas, salvo reconstruyéndolas con la UB del mes.

**5. Qué lo habría cambiado.** Una columna de vigencia en `Precios` y la costumbre de no pisar: un precio nuevo
es una fila nueva que cierra la anterior. Matías lo hizo en 2025, a medias: le faltó el fin, y la restricción
que impide dos vigencias el mismo día.

**Antes y después, con números:** 280 tablas, 248 meses con algún defecto y una consulta por mes, contra una
tabla que responde cualquier mes con un predicado, rechaza las 187 duplicadas y deja ver los 425 huecos.

---

## 📖 10. Traducción

| Concepto | Access / T-SQL | Postgres | MySQL | Oracle |
|---|---|---|---|---|
| rango de fechas | dos columnas | `daterange`, `tstzrange` | dos columnas | dos columnas; `PERIOD FOR` (12c) |
| no superposición | disparador; tablas temporales (2016) para el tiempo de sistema | `EXCLUDE USING gist`; `WITHOUT OVERLAPS` (18) | disparador con `SIGNAL` | disparador |
| clave foránea con período | — | `FOREIGN KEY (…, PERIOD …)` (18) | — | — |
| historia de sistema | `SYSTEM_VERSIONING` (2016) | disparador y tabla de historia | disparador y tabla de historia | *Flashback Query*, *Flashback Data Archive* |
| *as-of* | `FOR SYSTEM_TIME AS OF` | `rango @> fecha` | `desde <= d AND d < hasta` | `AS OF TIMESTAMP`; `AS OF PERIOD FOR` |

Hacia la NoSQL Lite: un documento con un arreglo de versiones es la tabla de historia dentro de la fila, y la
pregunta *as-of* se vuelve un filtro sobre el arreglo. Lo que ningún documento trae es la restricción que impide
que dos versiones se superpongan. El diccionario completo está en [`a07`](a07-diccionario-y-glosario.md).

---

## ⚖️ 11. Veredicto honesto: cuándo NO usar esto

**Cuándo no ir a lo bitemporal.** Cuando nadie va a preguntar "¿qué se sabía cuándo?". Para los precios de
Alameda sí se pregunta (la factura de abril tiene que poder explicarse en junio), pero el catálogo de sedes o
las unidades de una determinación no lo necesitan: un tiempo alcanza, y muchas veces ninguno. Cada tiempo suma
un rango a cada fila, una condición a cada consulta y una restricción más difícil de leer.

**Cuándo no ir a la 6FN.** Casi siempre. Paga cinco veces y media los bloques por tres atributos, y su ventaja
(que cada atributo tenga su historia) solo vale para los atributos que de verdad cambian por separado y que
alguien consulta en el tiempo. El nombre de un paciente puede merecerlo; su sexo y su fecha de nacimiento, en
Alameda, no. La forma razonable es **la 3FN con historia donde haga falta**: una tabla de historia para los
resultados, rangos para los precios.

**Cuándo no usar un disparador para la historia.** Cuando el motor la trae: las tablas versionadas de SQL
Server y *Flashback* en Oracle lo hacen sin código. En Postgres y MySQL, el disparador es la herramienta, y su
costo (una escritura más por cada corrección) se mide en el Bloque III.

Las cinco preguntas, para lo que enseñó esta fase:

- **Frontera transaccional:** cerrar una vigencia y abrir la siguiente van juntas, o queda un hueco o una
  superposición.
- **Consultas conocidas:** "¿cuánto valía el día D?" y "¿qué decía antes?", las dos con su consulta.
- **Unidad de lectura:** la versión vigente; la historia se lee poco y se escribe en cada corrección.
- **Saltos:** uno más por atributo en la 6FN; ninguno en la 3FN con historia.
- **Exactitud o parecido:** exactitud, y el modelo prefiere un hueco declarado a un precio adivinado.

---

## ⚠️ 12. Errores comunes y diagnóstico

- **`data type integer has no default operator class for access method "gist"`** al crear `WITHOUT
  OVERLAPS` o una exclusión con una columna escalar. 🩺 Falta `CREATE EXTENSION btree_gist`.
- **`constraint using WITHOUT OVERLAPS needs at least two columns`.** 🩺 Si el rango es la única columna, usa
  una restricción de exclusión.
- **`empty WITHOUT OVERLAPS value found`.** 🩺 Un rango `[d, d)`: dos vigencias que empiezan el mismo día.
  Búscalas antes de cargar.
- **Una exclusión que deja entrar duplicados.** 🩺 `count(*) FILTER (WHERE isempty(valid_during))`: los rangos
  vacíos no se superponen con nada.
- **Una vigencia sin fin.** 🩺 Si cada fila solo tiene `desde`, el `hasta` es el `desde` de la siguiente:
  `lead()` sobre la partición correcta.

---

## 📋 13. Checklist de validación

```text
[ ] los siete scripts de src/07-el-tiempo-en-el-modelo/ corren en orden, después de los de F06
[ ] alameda.practice_price tiene 20.367 rangos y precios.pegado_dos_veces rechaza 187
[ ] la vigencia sin fin falla contra WITHOUT OVERLAPS con el mensaje de la sección 8
[ ] precios.vigencia_duplicada rechaza 380 filas, y la clave con período deja 109.496 prácticas sin precio
[ ] la pregunta de Norma devuelve las tres versiones del resultado 12123358
[ ] la consulta bitemporal da 21.000 con lo que se sabía el 30/04 y 23.100 con lo que se sabe hoy
```

---

## 🧪 14. Ejercicios (24)

## 🟢 Fácil — el tiempo, de a uno (1–7)

### 🟢 Ejercicio 1 — Las 280 tablas

Cuenta en el catálogo las tablas `Precios_AAAA_MM`, sus filas y su tamaño.

**Objetivo:** 280 tablas, 20.554 filas y 2.240 kB.

[Solución](soluciones/07-el-tiempo-en-el-modelo.md#ejercicio-1)

### 🟢 Ejercicio 2 — Una, dos o ninguna

Para cada práctica y cada mes en que existía, cuenta cuántas filas tiene la copia de ese mes.

**Objetivo:** la tabla de la sección 4.

[Solución](soluciones/07-el-tiempo-en-el-modelo.md#ejercicio-2)

### 🟢 Ejercicio 3 — La unidad bioquímica de un mes

Consulta en `alameda.biochemical_unit` el valor de septiembre de 2002 y el de diciembre de 2009.

**Objetivo:** 1,2000 y 3,9427, y de dónde sale cada uno.

[Solución](soluciones/07-el-tiempo-en-el-modelo.md#ejercicio-3)

### 🟢 Ejercicio 4 — Un precio que se superpone

Inserta un precio de la glucemia del 15 de julio al 15 de agosto de 2009.

**Objetivo:** el error literal y con qué fila choca.

[Solución](soluciones/07-el-tiempo-en-el-modelo.md#ejercicio-4)

### 🟢 Ejercicio 5 — *As-of*

Consulta el precio de la glucemia el 15 de julio de 2009.

**Objetivo:** 7,34, y el rango que lo contiene.

[Solución](soluciones/07-el-tiempo-en-el-modelo.md#ejercicio-5)

### 🟢 Ejercicio 6 — La pregunta de Norma

Corre `05_result_history.sql`, corrige dos veces una glucemia con dos `application_name` distintos, y consulta
la historia.

**Objetivo:** las tres versiones, quién las cargó y quién las cambió.

[Solución](soluciones/07-el-tiempo-en-el-modelo.md#ejercicio-6)

### 🟢 Ejercicio 7 — `WITHOUT OVERLAPS` en MySQL

Crea en MySQL una tabla con `PRIMARY KEY (practice_id, valid_from, valid_to WITHOUT OVERLAPS)`.

**Objetivo:** el error literal, y qué hay que hacer en su lugar.

[Solución](soluciones/07-el-tiempo-en-el-modelo.md#ejercicio-7)

## 🟡 Intermedio — los precios, medidos (8–14)

### 🟡 Ejercicio 8 — Las filas pegadas dos veces

Clasifica las filas de `staging.monthly_price` según la UB que implican, contra la del mes.

**Objetivo:** 187 incoherentes, todas cerca de 1,10 veces, y la otra fila del par siempre coherente.

[Solución](soluciones/07-el-tiempo-en-el-modelo.md#ejercicio-8)

### 🟡 Ejercicio 9 — La vigencia sin fin

Carga las vigencias de 2025 con `daterange(VigenciaDesde, NULL)`.

**Objetivo:** el error literal, y por qué choca la segunda vigencia de la primera combinación.

[Solución](soluciones/07-el-tiempo-en-el-modelo.md#ejercicio-9)

### 🟡 Ejercicio 10 — El día duplicado

Cuenta las vigencias de 2025 que empiezan el mismo día que otra de su obra social y práctica.

**Objetivo:** 380 filas, 190 días y 172 combinaciones.

[Solución](soluciones/07-el-tiempo-en-el-modelo.md#ejercicio-10)

### 🟡 Ejercicio 11 — La exclusión que deja pasar

Carga las vigencias con el fin calculado en una tabla con `EXCLUDE USING gist` y en una con `WITHOUT
OVERLAPS`.

**Objetivo:** 6.878 filas con 190 vacías en la primera, y el error en la segunda.

[Solución](soluciones/07-el-tiempo-en-el-modelo.md#ejercicio-11)

### 🟡 Ejercicio 12 — La clave foránea con período

Corre `04_billed_practice.sql` y clasifica las prácticas sin precio vigente.

**Objetivo:** 109.496: 73.855 en días duplicados y 35.641 antes de la primera vigencia.

[Solución](soluciones/07-el-tiempo-en-el-modelo.md#ejercicio-12)

### 🟡 Ejercicio 13 — Lo que vale la duda

Suma, para las prácticas facturadas en un período de vigencia duplicada, la diferencia entre los dos precios
posibles.

**Objetivo:** $60.958.377, un 4 %.

[Solución](soluciones/07-el-tiempo-en-el-modelo.md#ejercicio-13)

### 🟡 Ejercicio 14 — Marzo de 2002

Pregunta el precio de cualquier práctica el 15 de marzo de 2002, en los precios y en la UB.

**Pregunta:** ¿por qué cero filas es la respuesta correcta?

[Solución](soluciones/07-el-tiempo-en-el-modelo.md#ejercicio-14)

## 🟠 Difícil — dos tiempos (15–20)

### 🟠 Ejercicio 15 — La apuesta, mes por mes

Para cada práctica y cada mes, compara lo que devuelve la unión de las copias y lo que devuelve la consulta
*as-of* contra el precio correcto.

**Objetivo:** las dos tablas de resultados, y en cuántos meses falla cada una.

[Solución](soluciones/07-el-tiempo-en-el-modelo.md#ejercicio-15)

### 🟠 Ejercicio 16 — Reconstruir con la UB

Completa la consulta *as-of* con la UB de la práctica por la UB del mes donde no hay precio.

**Objetivo:** 20.792 de 20.792, y por qué esa reconstrucción es legítima aquí y no siempre.

[Solución](soluciones/07-el-tiempo-en-el-modelo.md#ejercicio-16)

### 🟠 Ejercicio 17 — La corrección retroactiva

Registra en `staging.agreement_price_bitemporal` el precio de marzo y la corrección del 12 de mayo, y consulta
el 20 de abril con lo que se sabía el 30 de abril y con lo que se sabe hoy.

**Objetivo:** 21.000 y 23.100.

[Solución](soluciones/07-el-tiempo-en-el-modelo.md#ejercicio-17)

### 🟠 Ejercicio 18 — La corrección que se superpone

Agrega una tercera versión, registrada el 1 de junio, válida desde el 15 de abril.

**Objetivo:** el error de la exclusión, y cómo habría que registrarla.

[Solución](soluciones/07-el-tiempo-en-el-modelo.md#ejercicio-18)

### 🟠 Ejercicio 19 — La sexta forma normal

Corre `07_sixth_normal_form.sql` y compara los dos planes de la sección 5.6.

**Objetivo:** 2.410 contra 13.285 bloques, y por qué una devuelve 1.014 filas y la otra 884.

[Solución](soluciones/07-el-tiempo-en-el-modelo.md#ejercicio-19)

### 🟠 Ejercicio 20 — El disparador de MySQL

Escribe el disparador que impide superposiciones en MySQL y pruébalo con un rango que se toca.

**Objetivo:** el `ERROR 1644`, y el caso en que el disparador no alcanza.

[Solución](soluciones/07-el-tiempo-en-el-modelo.md#ejercicio-20)

## 🔴 Muy difícil — decidir (21–24)

### 🔴 Ejercicio 21 — Un precio por obra social, desde 2002

Las copias mensuales tienen un precio por práctica; desde 2025 hay uno por obra social. Diseña una sola tabla
para los dos períodos.

**Objetivo:** el esquema, la carga de los dos orígenes y qué se hace con las obras sociales antes de 2025.

[Solución](soluciones/07-el-tiempo-en-el-modelo.md#ejercicio-21)

### 🔴 Ejercicio 22 — La historia de un protocolo

Extiende la pregunta de Norma a un protocolo entero: todas las correcciones de todos sus resultados, en orden.

**Objetivo:** la consulta, su salida sobre el protocolo 11232670, y qué índice necesita.

[Solución](soluciones/07-el-tiempo-en-el-modelo.md#ejercicio-22)

### 🔴 Ejercicio 23 — *Flashback*

Resuelve en tu máquina la apuesta 🪞🔒 de la sección 6.

**Objetivo:** explicar el resultado con la documentación de Oracle, sin publicar ningún número.

[Solución](soluciones/07-el-tiempo-en-el-modelo.md#ejercicio-23)

### 🔴 Ejercicio 24 — ¿Bitemporal para los resultados?

Decide si los resultados de Alameda necesitan tiempo válido además del de transacción.

**Objetivo:** la decisión, un caso de la historia que la sostenga, y lo que cuesta.

[Solución](soluciones/07-el-tiempo-en-el-modelo.md#ejercicio-24)

---

## 📚 15. Referencias

**Documentación oficial**

- **Restricciones en Postgres 18** — https://www.postgresql.org/docs/18/ddl-constraints.html — `WITHOUT
  OVERLAPS`, las claves foráneas con `PERIOD` y las restricciones de exclusión.
- **Tipos de rango en Postgres 18** — https://www.postgresql.org/docs/18/rangetypes.html — `daterange`, los
  operadores `@>` y `&&`, y los rangos vacíos.
- **`btree_gist`** — https://www.postgresql.org/docs/18/btree-gist.html — las clases de operador que
  necesita una columna escalar en un índice `gist`.
- **Oracle Flashback** — https://docs.oracle.com/en/database/oracle/oracle-database/23/adfns/flashback.html —
  *Flashback Query* y la retención de *undo*.

**Papers y libros**

- **Richard T. Snodgrass, *Developing Time-Oriented Database Applications in SQL*, Morgan Kaufmann, 1999** —
  tiempo válido, de transacción y bitemporal, con SQL de verdad.
- **C. J. Date, Hugh Darwen y Nikos Lorentzos, *Time and Relational Theory*, 2.ª ed., Morgan Kaufmann,
  2014** — la sexta forma normal y los intervalos.
- **Lars Rönnbäck y otros, "Anchor Modeling", *Data & Knowledge Engineering*, 2010** — el método que lleva
  la 6FN a la práctica.

**Orden de lectura sugerido:** la documentación de rangos antes de la sección 5.1; Snodgrass después de la
5.5; Date, Darwen y Lorentzos solo si vas a defender una 6FN.

> ⚠️ Las URL y sus contenidos cambian. Se consultaron el 14/10/2026.

---

## 🏁 16. Resultado de la fase

```text
LOS PRECIOS · perfil M
  copias mensuales               280 tablas · 20.554 filas · 187 pegadas dos veces · 425 faltantes
  alameda.practice_price         20.367 rangos sin superposición · 2.448 kB
  la apuesta                     unión: falla en 131 meses por duplicados · as-of: 425 pares sin fila en 219 meses
  con la UB del mes              20.792 de 20.792
  2025, por obra social          6.878 vigencias · 380 en días duplicados · 6.498 cargadas
  lo facturado desde 2025        1.746.067 · 109.496 sin precio vigente · la duda vale $60.958.377
EL TIEMPO DE TRANSACCIÓN
  la pregunta de Norma           tres versiones de una glucemia, con quién y cuándo
  bitemporal                     21.000 con lo que se sabía · 23.100 con lo que se sabe
LA 6FN
  tres atributos                 13.285 bloques contra 2.410 · 76 MB contra 30 MB
```

> **La señal de que quedó bien:** *"Puedo contestar cuánto valía una práctica cualquier día desde 2002, decir
> cuándo no lo sé, y mostrarle a Norma qué decía un resultado antes de que alguien lo cambiara."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-07-el-tiempo-en-el-modelo -m "F07 cerrada: precios en rangos sin superposición, la vigencia sin fin rota y medida, la clave foránea con período, la historia de resultados y lo bitemporal"
> ```
>
> Commits de la fase con prefijo `f07:`, los de ejercicio `f07 ej16: …`.
