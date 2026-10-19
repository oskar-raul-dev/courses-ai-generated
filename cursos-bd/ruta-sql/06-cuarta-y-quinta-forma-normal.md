# 🔗 Fase 06 — Cuarta y quinta forma normal, con dependencias de verdad

> **Curso:** Ruta SQL · Fase 06 de 27 · Bloque I — El modelo · **8 h**
> **Motores:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · — · —
> **Entorno de ejecución:** SQL + Python (solo la biblioteca estándar, para leer la planilla)
> **Perfil de volumen:** M para todo
> **El dolor de Alameda:** la planilla de convenios y las tres columnas de código de práctica (historia §4)
> **Depende de:** Fase 05 · **Habilita:** Fase 07
> **Apéndices de apoyo:** a03, a05, a07
> **Fecha de verificación ejecutada:** 13/10/2026
> **Objetivo:** distinguir una dependencia multivaluada de una dependencia de join midiéndolas en la caja,
> descomponer los convenios en tres tablas binarias que los reconstruyen sin perder ni inventar una fila,
> y demostrar que la misma descomposición inventa 107 convenios cuando la regla deja de ser cíclica.

---

## 🧭 1. Dónde estamos

La [Fase 04](04-un-valor-un-hecho.md) llegó hasta la BCNF con dependencias funcionales: un valor determina
otro. La [Fase 05](05-una-persona-no-es-su-documento.md) separó a la persona de sus documentos. Lo que queda
del modelo no se explica con dependencias funcionales, porque nadie determina a nadie: un paciente tiene
**varios** teléfonos y **varios** médicos, y una obra social cubre **varias** prácticas en **varias** sedes.

Esas son las dependencias de la cuarta y la quinta forma normal, y tienen algo en común con las de la Fase
04: no se discuten, se miden. Una dependencia funcional se prueba con un `GROUP BY`; una multivaluada y una de
join, con una proyección y un join que reconstruye la tabla. Casi todos los cursos las enseñan con
ejemplos de libro y concluyen que en la práctica no importan. Esta fase las mide sobre dos cosas reales de
Alameda, y la conclusión es más incómoda: la quinta forma normal es correcta **solo si la regla del negocio
tiene una forma precisa**, y esa forma no está en los datos de hoy. Está en la cabeza de quien firma los
convenios.

---

## 🎯 2. Objetivos de esta fase

1. Medir en la caja una dependencia multivaluada y el costo de guardarla mal.
2. Probar que la regla de convenios es una dependencia de join y no una multivaluada.
3. Descomponer los convenios en tres tablas binarias y reconstruirlos sin perder ni inventar filas.
4. Contar las filas que inventa la misma descomposición cuando la regla no es cíclica.
5. Reemplazar las tres columnas de código por un catálogo versionado, y medir lo que traduce cada uno.

---

## 🚫 3. Qué NO entra todavía

- **La vigencia de un convenio o de un precio** (desde cuándo, hasta cuándo) → [Fase 07](07-el-tiempo-en-el-modelo.md).
- **Los resultados de laboratorio y su forma** → [Fase 08](08-los-dos-extremos-del-mismo-error.md).
- **Facturar con los convenios**, con coseguros y topes → Bloque VI.

---

## 🏚️ 4. El dolor, en la caja

> 🏚️ **`planillas/convenios_2026.xlsx`**, la primera hoja:
>
> ```text
> ObraSocial,Practica,Sede
> APROSS,660001,A
> APROSS,660001,C
> APROSS,660001,J
> APROSS,660002,A
> ```

Los convenios de Alameda no están en la base. Están en una planilla que alguien de facturación actualiza
cuando una obra social cambia algo, con una fila por obra social, práctica y sede. La caja la trae, y
`xlsx_to_csv.py` (biblioteca estándar, sin dependencias) la pasa a `staging.agreement_raw`:

```text
 filas | obras_sociales | practicas | sedes
-------+----------------+-----------+-------
  1422 |             10 |        75 |     5
(1 row)
```

El segundo dolor está en el catálogo de prácticas. `Practicas` tiene **una columna de código por versión
del nomenclador**: `CodINOS`, `CodNBU` y `CodNBU2012`. Y existe una tabla `EquivalenciasCodigos`, que alguien
armó para traducir entre versiones y nadie terminó. Para las prácticas facturadas con el nomenclador del
INOS, entre 1997 y 2011:

```text
 filas_inos | por_equivalencias | por_practice_code
------------+-------------------+-------------------
     238482 |             90446 |            238482
(1 row)
```

Las dos cosas tienen la misma raíz que el parser de la Fase 04: una regla que el esquema no declara. La
planilla aplica una regla de convenios que nadie escribió en la base; las columnas de código declaran una
versión en el nombre de la columna, donde ninguna consulta la puede usar como dato.

La tabla de equivalencias traduce **el 37,9 %**. El resto queda sin código actual, aunque `Practicas` tiene
los tres códigos en la misma fila: la equivalencia estaba en las columnas, y la tabla que debía reemplazarlas
quedó a medias.

---

## 🧩 5. Dependencias que no son funcionales

### 5.1 La dependencia multivaluada y la cuarta forma normal

Un paciente tiene teléfonos y tiene médicos derivantes, y los dos hechos son **independientes**: el
teléfono no depende del médico que pidió el análisis. Eso es una **dependencia multivaluada**: `paciente →→
teléfono` y `paciente →→ médico`. La cuarta forma normal pide que dos hechos multivaluados independientes no
compartan una tabla.

`05_patient_contacts.sql` separa los dos hechos (`staging.patient_phone` y `staging.patient_physician`) y arma,
solo para medirla, la tabla que los junta: una fila por cada teléfono con cada médico.

> 📐 **Medición: dos hechos multivaluados en una tabla** · perfil M · `pgvector/pgvector@sha256:2358fcba361e…` ·
> verificado el 13/10/2026
>
> | | Filas | Tamaño |
> |---|---|---|
> | `patient_phone` | 247.226 | 19 MB |
> | `patient_physician` | 1.229.411 | 69 MB |
> | la combinada, `(paciente, teléfono, médico)` | 1.254.558 | 100 MB |
>
> Reproducir: `src/06-cuarta-y-quinta-forma-normal/05_patient_contacts.sql` y la consulta del ejercicio 8.

La combinada no tiene muchas más filas, porque casi todos los pacientes tienen un solo teléfono. Su costo
está en lo que se repite y en lo que no puede guardar:

- **Cada teléfono está 5,15 veces**, una por médico. Cambiar uno de los dos teléfonos del paciente 33 es un
  `UPDATE` de **43 filas**; en `patient_phone`, de una.
- **3.608 pacientes pierden el teléfono**, porque no tienen ningún protocolo con médico, y en la combinada no
  hay fila sin médico que lo guarde (salvo con un `NULL` en la clave).

**El patrón a memorizar.** Si dos columnas de una tabla dependen de la clave pero no una de la otra, la
tabla está guardando un producto cartesiano. Se prueba como en la Fase 04, con datos: si reconstruir la
tabla desde sus dos proyecciones da exactamente las mismas filas, la dependencia multivaluada se cumple y la
tabla se parte.

### 5.2 La dependencia de join y la quinta forma normal

Los convenios son otra cosa. La regla de Alameda, la que aplica facturación cuando arma la planilla, es:

> *Si una obra social cubre una práctica, y la sede hace esa práctica, y la sede atiende a esa obra social,
> entonces la obra social tiene convenio para esa práctica en esa sede.*

Esa regla es **cíclica**: el convenio de tres partes es exactamente el join de tres hechos de dos partes. Es
una **dependencia de join**, y la quinta forma normal pide guardar los tres hechos y no su join.

Antes de descomponer, se descarta el camino de la 4FN. Si `obra social →→ práctica` fuera una dependencia
multivaluada, alcanzarían dos tablas:

```sql
-- postgres
WITH pp AS (SELECT DISTINCT payer, practice FROM staging.agreement_raw),
     ps AS (SELECT DISTINCT practice, site FROM staging.agreement_raw)
SELECT count(*) AS dos_binarias, count(*) - 1422 AS espurias FROM pp JOIN ps USING (practice);
```

```text
 dos_binarias | espurias
--------------+----------
         1783 |      361
(1 row)
```

**361 convenios inventados.** Dos tablas no alcanzan: la sede tiene que atender a la obra social, y eso es un
tercer hecho. `03_agreements.sql` guarda los tres, con sus claves foráneas, y el convenio pasa a ser una vista:

```sql
-- postgres
CREATE VIEW alameda.agreement AS
SELECT pp.payer_code, pp.practice_id, ps.site_code
FROM alameda.payer_practice AS pp
JOIN alameda.practice_site AS ps ON ps.practice_id = pp.practice_id
JOIN alameda.payer_site AS ys ON ys.payer_code = pp.payer_code AND ys.site_code = ps.site_code;
```

```text
 ternaria | pp  | ps  | ys | vista
----------+-----+-----+----+-------
     1422 | 556 | 241 | 38 |  1422
(1 row)
```

Tres tablas con 835 filas en total reconstruyen las 1.422, y la comparación contra la planilla da **0
espurias y 0 perdidas**. La descomposición no es más chica por casualidad: cada hecho está una vez.

**Cómo se reconoce una dependencia de join.** Igual que una funcional o una multivaluada: con los datos, y
sin creerles del todo. Se proyecta la tabla en las tablas candidatas, se reconstruye con el join, y se compara
con `EXCEPT` en las dos direcciones. El join de proyecciones nunca pierde filas; lo que puede hacer es
**inventarlas**. Si no inventa ninguna, los datos de hoy cumplen la dependencia. Se llama cíclica porque las
tres proyecciones forman un ciclo (obra social, práctica, sede, y de vuelta a la obra social), y ninguna de
las tres sobra: con dos, la tabla de la sección anterior inventó 361 convenios.

### 5.3 Lo que compra la quinta forma normal

La sede de Villa Allende empieza a hacer el análisis de orina. En la planilla son **8 filas nuevas**, una por
cada obra social que cubre la práctica y que la sede atiende, y quien las carga tiene que saber cuáles son. En
el modelo, es **una fila** en `practice_site`, y la vista calcula las ocho. Hay 209 pares de práctica y sede
sin convenio todavía; cada uno que se abra es, en la planilla, una consulta a la regla hecha a mano.

Lo mismo al revés. Si Villa Allende deja de atender a OSDE, en la planilla hay que borrar **29 filas**, una por
práctica, y una que se olvide sigue diciendo que el convenio existe. En el modelo se borra una fila de
`payer_site`. Si OSDE deja de cubrir la hemoglobina glicosilada, son 3 filas en la planilla (una por sede) y
una en `payer_practice`. Cada hecho cambia en un solo lugar, que es lo que prometen todas las formas normales;
la quinta lo promete para reglas de tres partes.

Y lo que cuesta. Leer un convenio por su clave:

```text
-- la planilla, como tabla
 Index Only Scan using agreement_raw_pkey on agreement_raw (actual time=0.014..0.014 rows=1.00 loops=1)
   Buffers: shared hit=3
-- la vista de tres tablas
 Nested Loop (actual time=0.030..0.032 rows=1.00 loops=1)
   Buffers: shared hit=7
```

Tres bloques contra siete, y los 1.422 convenios enteros se leen en seis bloques. Para una tabla de este
tamaño, el join es gratis; la Fase 08 muestra lo que pasa cuando la descomposición no es de 835 filas sino de
millones.

> 🩻 **Esto sí funciona igual** en los tres motores: las dependencias multivaluadas y de join son del modelo,
> y la vista de tres tablas se escribe igual en Postgres, MySQL y Oracle.

### 5.4 El catálogo versionado

La tercera dependencia de esta fase es más simple y más cara: el código de una práctica depende del
nomenclador. La [Fase 04](04-un-valor-un-hecho.md#53-2fn-3fn-y-bcnf-sobre-tablas-de-la-caja) ya mostró que el
código solo no identifica una práctica. `01_catalogs.sql` lo modela como dato:

```sql
-- postgres
CREATE TABLE alameda.practice_code (
    nomenclator_code varchar(10) NOT NULL REFERENCES alameda.nomenclator (nomenclator_code),
    code             varchar(20) NOT NULL,
    practice_id      integer NOT NULL REFERENCES alameda.practice (practice_id),
    CONSTRAINT practice_code_pkey PRIMARY KEY (nomenclator_code, code),
    CONSTRAINT practice_code_nomenclator_code_practice_id_key UNIQUE (nomenclator_code, practice_id)
);
```

Una práctica es una fila de `alameda.practice`; cada nomenclador le da un código. **La equivalencia entre
dos códigos es tener la misma práctica**, y no hace falta otra tabla que la repita:

```text
  description  | nomenclator_code |  code
---------------+------------------+--------
 CREATININEMIA | INOS             | 410
 CREATININEMIA | NBU              | 660004
 CREATININEMIA | NBU2012          | 660504
(3 rows)
```

Con este catálogo, las 238.482 prácticas facturadas con el INOS se traducen al NBU 2012 sin perder ninguna.
Hay 68 códigos que aparecen en dos nomencladores, y en los 68 casos son la misma práctica. En otra caja
podrían no serlo, y la clave `(nomenclator_code, code)` no lo daría por supuesto.

**El patrón a memorizar.** Una versión no es una columna. Si un catálogo tiene versiones, la versión es parte
de la clave del dato, y la equivalencia entre versiones es una consecuencia del modelo, no una tabla a
mantener.

---

## 🔀 6. El contraste: dónde otro motor cambia la decisión

Ninguno. Las dependencias multivaluadas y de join son del modelo relacional, y los tres motores del curso
declaran igual las tres tablas binarias, sus claves foráneas y la vista. Lo que cambiaría entre motores es
cómo se hace cumplir una **excepción** a la regla (ejercicio 18): con una tabla y un `EXCEPT` en los tres,
porque ninguno tiene una restricción declarativa de dependencia de join. MySQL tiene `EXCEPT` desde la
8.0.31, según sus notas de versión, y el 9.7 del curso lo ejecuta.

---

## 🪞 7. Tu instinto dice… y la apuesta

**Tu instinto dice** que la quinta forma normal es una curiosidad académica, y que una tabla de convenios de
tres columnas está bien como está. Es el instinto correcto en casi todos los sistemas, porque casi ninguna
regla de tres partes es cíclica.

> 🪞 **Apuesta antes de ejecutar** (escrita el 30/09/2026, al diseñar esta fase). *"La descomposición en
> tres tablas binarias no pierde ni inventa filas si, y solo si, la regla de negocio es cíclica",
> demostrada con el generador en las dos variantes.*
> **Resultado:** **ganada.** Con la regla cíclica de la caja, las tres tablas reconstruyen los 1.422
> convenios con 0 espurios y 0 perdidos. Con la variante no cíclica, la misma descomposición reconstruye
> 1.412 filas para 1.305 convenios: **107 inventados**, y ninguno perdido.

La variante sale de `04_noncyclic.sql`: los mismos convenios, menos el 10 % que una obra social excluye en una
sede aunque cubra la práctica y la sede la haga. Se eligen con la semilla 1996 y un hash, sin `random()`, para
que la tabla sea la misma en cualquier máquina. Con otras semillas el número cambia (138 con 1997, 133 con
2026), pero nunca es cero.

Y la parte que la apuesta no preguntaba: **los datos de hoy no dicen si la regla es cíclica.** Que la planilla
de 2026 se reconstruya sin espurios prueba que hoy se cumple, no que facturación la aplique siempre. El
primer convenio con una excepción la rompe, y la descomposición lo convierte en convenios que no existen.

---

## 💥 8. El punto de rotura

La variante no cíclica, descompuesta y reconstruida:

```sql
-- postgres
WITH t AS (SELECT * FROM staging.agreement_noncyclic),
     pp AS (SELECT DISTINCT payer, practice FROM t),
     ps AS (SELECT DISTINCT practice, site FROM t),
     ys AS (SELECT DISTINCT payer, site FROM t),
     j AS (SELECT pp.payer, pp.practice, ps.site
           FROM pp JOIN ps USING (practice) JOIN ys ON ys.payer = pp.payer AND ys.site = ps.site)
SELECT (SELECT count(*) FROM t) AS ternaria, (SELECT count(*) FROM j) AS rejoin,
       (SELECT count(*) FROM (SELECT * FROM j EXCEPT SELECT * FROM t) AS x) AS espurias;
```

```text
 ternaria | rejoin | espurias
----------+--------+----------
     1305 |   1412 |      107
(1 row)
```

Cada una de las 107 es un convenio que la vista afirma y la obra social no firmó: una práctica que el
laboratorio hace, a un paciente que la sede atiende, y que se va a facturar y a debitar. La descomposición no
da error, ni advertencia, ni una fila de menos: **da filas de más**, y nada en el esquema las distingue de las
verdaderas.

El arreglo conserva la 5FN y declara la excepción: una tabla de convenios excluidos, y la vista como el join
menos las excepciones. Con las 107 que el join inventaría, la vista vuelve a dar exactamente los 1.305
(ejercicio 18). Es más modelo, y vale la pena solo si las excepciones son pocas.

---

## ⚰️ 9. Autopsia: una columna de código nueva por cada versión del nomenclador

**1. La decisión.** *"Sale el NBU: agrego una columna `CodNBU` en `Practicas`."* Y con el NBU 2012, otra:
`CodNBU2012`. Así lo cuenta la caja: tres columnas, una por versión.

**2. Por qué era razonable.** Era una columna y una tarde de trabajo. Cada protocolo ya guardaba con qué
nomenclador se había facturado, y el informe que necesitaba el código elegía la columna con un `CASE`. Para
traducir entre versiones, la misma fila tenía los tres códigos a la vista.

**3. Qué pasó después.** En algún momento alguien armó `EquivalenciasCodigos` para traducir sin depender de
las columnas, y quedó a medias: tiene 52 filas para 74 prácticas con código INOS, y 31 con el código de 2012. Traduce el
**37,9 %** de las 238.482 prácticas facturadas con el INOS. Hay dos fuentes de equivalencia, y la que todos
creen oficial es la incompleta.

**4. Cuánto cuesta salir.** `01_catalogs.sql`: tres tablas y un `CROSS JOIN LATERAL` que pasa las columnas a
filas. Lo caro no es el script, es encontrar cada `CASE` que elige una columna según el nomenclador, en VBA,
en T-SQL y en las planillas.

**5. Qué lo habría cambiado.** La versión como parte de la clave desde el primer nomenclador. El NBU de 2016,
o el que venga, es una fila en `nomenclator` y 75 en `practice_code`, y ningún `ALTER TABLE`.

**Antes y después, con números:** una tabla de equivalencias que traduce 90.446 prácticas de 238.482, contra
un catálogo que traduce las 238.482, y una versión nueva que cuesta 76 filas en lugar de una columna y todos
sus `CASE`.

---

## 📖 10. Traducción

| Concepto | Access / T-SQL | Postgres | MySQL | Oracle |
|---|---|---|---|---|
| comparar una tabla con su reconstrucción | `EXCEPT` (desde 2005) | `EXCEPT` | `EXCEPT` (desde 8.0.31) | `MINUS`; `EXCEPT` desde 21c |
| vista sobre el join de tres tablas | vista | vista | vista | vista |
| pasar columnas a filas | `UNPIVOT` o `CROSS APPLY (VALUES …)` | `CROSS JOIN LATERAL (VALUES …)` | `JSON_TABLE` o `UNION ALL` | `UNPIVOT` |
| restricción de dependencia de join | no existe | no existe | no existe | no existe |

Hacia la NoSQL Lite: un documento de obra social con un arreglo de convenios por sede es la tabla ternaria
otra vez, con la misma pregunta: ¿la regla es cíclica? Si lo es, el documento guarda un join y cada cambio en
una sede se repite en cada obra social. El diccionario completo está en [`a07`](a07-diccionario-y-glosario.md).

---

## ⚖️ 11. Veredicto honesto: cuándo NO usar esto

**Cuándo no llegar a la 5FN.** Cuando la dependencia de join es **accidental**: los datos de hoy la cumplen,
pero nadie puede afirmar que la regla sea esa. La descomposición se paga en joins (siete bloques contra tres
por convenio) y no compra nada; y el día que llega la primera excepción, inventa convenios en silencio. Con
1.422 filas, la tabla ternaria con su clave primaria es más honesta: cada fila es un convenio que alguien
firmó.

**Cuándo sí.** Cuando la regla es **del negocio**, escrita y aplicada así, y los hechos binarios cambian por
separado. En Alameda lo es: facturación arma la planilla aplicando la regla, y una sede que empieza a hacer una
práctica es una fila y no ocho.

**Lo que esta fase no resuelve:** la planilla sigue siendo la fuente. Pasar los convenios a la base sirve si
facturación deja de editar la planilla y empieza a editar los tres hechos; si no, la base copia la planilla
cada mes y las dos se separan, como el parser de 2016.

**Cuándo no partir una tabla por la 4FN:** cuando uno de los dos hechos no es multivaluado de verdad. El
teléfono "fijo y celular" de un sistema que solo guarda dos puede ir en dos columnas, y la combinada de esta
fase no tiene sentido. La 4FN aplica cuando la cantidad es abierta.

Las cinco preguntas, para lo que enseñó esta fase:

- **Frontera transaccional:** abrir una práctica en una sede es una fila; en la planilla, ocho que tienen que
  entrar juntas.
- **Consultas conocidas:** "¿tiene convenio esta obra social para esta práctica en esta sede?", con un join
  de tres índices.
- **Unidad de lectura:** el convenio se lee entero; se escribe por partes.
- **Saltos:** dos, conocidos y chicos.
- **Exactitud o parecido:** exactitud, y por eso las 107 espurias son inaceptables.

---

## ⚠️ 12. Errores comunes y diagnóstico

- **Descomponer en dos tablas una regla de tres partes.** 🩺 Reconstruye y compara con `EXCEPT`: 361 espurias
  en esta caja. Si sobran filas, falta un hecho.
- **Concluir que la regla es cíclica porque los datos la cumplen.** 🩺 Pregúntale a quien la aplica. Los datos
  prueban el pasado, no la regla.
- **Una tabla de equivalencias entre versiones de un catálogo.** 🩺 Cuenta cuánto traduce contra las filas
  que necesitan traducción. Si la equivalencia se puede derivar de una clave común, la tabla sobra.
- **Un `NULL` en la clave para guardar un teléfono sin médico.** 🩺 Es la combinada pidiendo partirse.

---

## 📋 13. Checklist de validación

```text
[ ] los cinco scripts de src/06-cuarta-y-quinta-forma-normal/ corren en orden, con la planilla cargada
[ ] staging.agreement_raw tiene 1.422 filas, y alameda.agreement las reconstruye con 0 espurias y 0 perdidas
[ ] dos tablas binarias dan 1.783 filas: 361 espurias
[ ] la variante no cíclica da 1.305 convenios y 107 espurios
[ ] alameda.practice_code traduce las 238.482 prácticas del INOS al NBU 2012
[ ] la combinada de teléfonos y médicos tiene 1.254.558 filas y deja afuera a 3.608 pacientes
```

---

## 🧪 14. Ejercicios (20)

## 🟢 Fácil — los hechos, uno por uno (1–6)

### 🟢 Ejercicio 1 — La planilla

Carga `convenios_2026.xlsx` en `staging.agreement_raw` con `xlsx_to_csv.py` y `\copy`.

**Objetivo:** 1.422 filas, 10 obras sociales, 75 prácticas y 5 sedes.

[Solución](soluciones/06-cuarta-y-quinta-forma-normal.md#ejercicio-1)

### 🟢 Ejercicio 2 — Las tres proyecciones

Cuenta los pares distintos de obra social y práctica, de práctica y sede, y de obra social y sede.

**Objetivo:** 556, 241 y 38.

[Solución](soluciones/06-cuarta-y-quinta-forma-normal.md#ejercicio-2)

### 🟢 Ejercicio 3 — El join que vuelve

Corre `03_agreements.sql` y compara `alameda.agreement` con la planilla en las dos direcciones.

**Objetivo:** 1.422 filas, 0 espurias y 0 perdidas.

[Solución](soluciones/06-cuarta-y-quinta-forma-normal.md#ejercicio-3)

### 🟢 Ejercicio 4 — Dos teléfonos

Cuenta los pacientes de `legacy."Pacientes"` con dos teléfonos en el mismo campo.

**Objetivo:** 4.799, y el separador que usa la recepción.

[Solución](soluciones/06-cuarta-y-quinta-forma-normal.md#ejercicio-4)

### 🟢 Ejercicio 5 — Los tres códigos de una práctica

Consulta en `alameda.practice_code` los códigos de la creatininemia.

**Objetivo:** `410`, `660004` y `660504`, y qué columna de `Practicas` elegiría un informe de 2015.

[Solución](soluciones/06-cuarta-y-quinta-forma-normal.md#ejercicio-5)

### 🟢 Ejercicio 6 — La sede sin convenios

Cuenta los convenios de cada sede de `alameda.site`.

**Pregunta:** ¿qué sede no tiene ninguno, y por qué está bien?

[Solución](soluciones/06-cuarta-y-quinta-forma-normal.md#ejercicio-6)

## 🟡 Intermedio — medir cada forma normal (7–12)

### 🟡 Ejercicio 7 — Dos tablas no alcanzan

Descompón los convenios en `(obra social, práctica)` y `(práctica, sede)` y reconstruye.

**Objetivo:** 1.783 filas y 361 espurias, y qué hecho falta.

[Solución](soluciones/06-cuarta-y-quinta-forma-normal.md#ejercicio-7)

### 🟡 Ejercicio 8 — La combinada

Corre `05_patient_contacts.sql` y mide las tres tablas: filas, tamaño y copias por teléfono.

**Objetivo:** la tabla de la sección 5.1 y 5,15 copias por teléfono.

[Solución](soluciones/06-cuarta-y-quinta-forma-normal.md#ejercicio-8)

### 🟡 Ejercicio 9 — Los que pierden el teléfono

Cuenta los pacientes con teléfono que no aparecen en la combinada.

**Objetivo:** 3.608, y por qué.

[Solución](soluciones/06-cuarta-y-quinta-forma-normal.md#ejercicio-9)

### 🟡 Ejercicio 10 — La tabla de equivalencias

Traduce al NBU 2012 las prácticas facturadas con el INOS, con `EquivalenciasCodigos` y con
`alameda.practice_code`.

**Objetivo:** 90.446 contra 238.482.

[Solución](soluciones/06-cuarta-y-quinta-forma-normal.md#ejercicio-10)

### 🟡 Ejercicio 11 — Una práctica nueva en una sede

Para el análisis de orina en Villa Allende, cuenta las filas que agregaría la planilla y las que agrega el
modelo.

**Objetivo:** 8 contra 1.

[Solución](soluciones/06-cuarta-y-quinta-forma-normal.md#ejercicio-11)

### 🟡 Ejercicio 12 — Lo que cuesta leer

Compara con `EXPLAIN (ANALYZE, BUFFERS)` la lectura de un convenio en la planilla y en la vista.

**Objetivo:** 3 bloques contra 7, y qué índice usa cada paso.

[Solución](soluciones/06-cuarta-y-quinta-forma-normal.md#ejercicio-12)

## 🟠 Difícil — la regla (13–17)

### 🟠 Ejercicio 13 — La variante no cíclica

Corre `04_noncyclic.sql`, descompón y reconstruye.

**Objetivo:** 1.305 convenios, 1.412 reconstruidos, 107 espurios y 0 perdidos.

[Solución](soluciones/06-cuarta-y-quinta-forma-normal.md#ejercicio-13)

### 🟠 Ejercicio 14 — Otra semilla

Repite el ejercicio 13 con las semillas `1997` y `2026`.

**Pregunta:** ¿hay alguna semilla con la que la variante no invente convenios? Justifica sin probarlas todas.

[Solución](soluciones/06-cuarta-y-quinta-forma-normal.md#ejercicio-14)

### 🟠 Ejercicio 15 — La dependencia multivaluada, demostrada

Prueba sobre la combinada que `paciente →→ teléfono` se cumple, reconstruyéndola desde sus dos proyecciones.

**Objetivo:** 1.254.558 filas reconstruidas, ni una más.

[Solución](soluciones/06-cuarta-y-quinta-forma-normal.md#ejercicio-15)

### 🟠 Ejercicio 16 — Un código, dos nomencladores

Cuenta los códigos que aparecen en más de un nomenclador, y cuántos de ellos son prácticas distintas.

**Objetivo:** 68 y 0, y por qué la clave sigue siendo el par.

[Solución](soluciones/06-cuarta-y-quinta-forma-normal.md#ejercicio-16)

### 🟠 Ejercicio 17 — ¿Es cíclica?

Escribe la prueba que dice si una tabla de tres columnas cumple una dependencia de join, y córrela sobre la
planilla y sobre la variante.

**Objetivo:** una consulta que dé 0 para la planilla y 107 para la variante.

[Solución](soluciones/06-cuarta-y-quinta-forma-normal.md#ejercicio-17)

## 🔴 Muy difícil — decidir (18–20)

### 🔴 Ejercicio 18 — La excepción declarada

Conserva la 5FN para la variante no cíclica con una tabla de excepciones, y que la vista dé exactamente sus
convenios.

**Objetivo:** cuántas excepciones hacen falta como mínimo, y la vista con 0 espurias y 0 perdidas.

[Solución](soluciones/06-cuarta-y-quinta-forma-normal.md#ejercicio-18)

### 🔴 Ejercicio 19 — El nomenclador que viene

Sale una actualización del NBU con 75 códigos. Escribe lo que cambia en el modelo y lo que habría cambiado en
`Practicas`.

**Objetivo:** las sentencias de los dos lados y la lista de lo que hay que revisar en el viejo.

[Solución](soluciones/06-cuarta-y-quinta-forma-normal.md#ejercicio-19)

### 🔴 Ejercicio 20 — ¿Tres tablas o una?

Decide para Alameda si los convenios van en 5FN o en una tabla ternaria, y defiéndelo ante facturación.

**Objetivo:** la decisión, con los números de esta fase y la pregunta que le harías a quien arma la planilla.

[Solución](soluciones/06-cuarta-y-quinta-forma-normal.md#ejercicio-20)

---

## 📚 15. Referencias

**Documentación oficial**

- **Consultas combinadas en Postgres 18** — https://www.postgresql.org/docs/18/queries-union.html — `UNION`,
  `INTERSECT` y `EXCEPT`.
- **`LATERAL` en Postgres 18** — https://www.postgresql.org/docs/18/queries-table-expressions.html — la
  subconsulta lateral que pasa columnas a filas.
- **`EXCEPT` en MySQL 9.7** — https://dev.mysql.com/doc/refman/9.7/en/except.html — disponible desde la
  8.0.31.

**Papers y libros**

- **Ronald Fagin, "Multivalued Dependencies and a New Normal Form for Relational Databases", *ACM TODS*,
  1977** — la cuarta forma normal.
- **Ronald Fagin, "Normal Forms and Relational Database Operators", *SIGMOD*, 1979** — la quinta, como forma
  normal de proyección y join.
- **C. J. Date, *SQL and Relational Theory*, 3.ª ed., O'Reilly, 2015** — la 4FN y la 5FN con ejemplos que
  sí distinguen una dependencia de join accidental.

**Orden de lectura sugerido:** Date sobre la 5FN antes de la sección 5.2; Fagin (1979) después del punto de
rotura.

> ⚠️ Las URL y sus contenidos cambian. Se consultaron el 13/10/2026.

---

## 🏁 16. Resultado de la fase

```text
LOS CONVENIOS · perfil M · planilla de 2026
  ternaria                      1.422 filas
  5FN: tres binarias            556 + 241 + 38 = 835 filas · reconstruye 1.422 · 0 espurias · 0 perdidas
  dos binarias                  1.783 filas · 361 espurias
  variante no cíclica           1.305 convenios · el join da 1.412 · 107 espurios
LA 4FN · teléfonos y médicos
  separadas                     247.226 + 1.229.411 filas · 88 MB
  combinada                     1.254.558 filas · 100 MB · 5,15 copias por teléfono · 3.608 pacientes afuera
EL CATÁLOGO
  equivalencias                 90.446 de 238.482 prácticas del INOS
  practice_code                 238.482 de 238.482
```

> **La señal de que quedó bien:** *"Puedo decir, con una consulta, si una tabla de tres columnas guarda un
> join; y sé que la respuesta de los datos no es la respuesta del negocio."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-06-cuarta-y-quinta-forma-normal -m "F06 cerrada: la 4FN con teléfonos y médicos, los convenios en 5FN sin espurias, la variante no cíclica con 107, y el catálogo versionado"
> ```
>
> Commits de la fase con prefijo `f06:`, los de ejercicio `f06 ej18: …`.
