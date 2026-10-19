# 🧊 Contrato de nombres
## Ruta SQL

> **Qué es este documento:** los nombres que muchas fases arrastran y que no se pueden cambiar
> después sin tocarlas todas: los del laboratorio, los del código, los de los datos y los de git.
> **Origen:** agregado el 06/10/2026, en la revisión contra los lineamientos de producción del
> repositorio, **antes de T0**. Recoge lo que ya fijaron el alcance (§7, §9, §12), la guía §5 y §14 y
> las dos propuestas; lo que dependía de la verificación de laboratorio (P8) lo fijó P11 el
> 11/10/2026 (§8), T1 fijó el laboratorio el 12/10/2026, y lo que queda ⏳ lleva la tanda que lo fija.
> **Precedencia:** por debajo del [alcance](alcance-del-proyecto.md) y de la
> [guía](guia-de-estilo-y-convenciones.md); al lado del [diccionario](diccionario-de-terminos.md),
> que fija las palabras. Por encima de cualquier fase.
> **Vigencia:** 2026-10-12 (T1).

---

## 1. 🧭 Las reglas del contrato

1. **No se inventan valores nuevos** en una fase. Todo nombre, puerto, perfil, esquema, tag o
   variable sale de aquí.
2. **No se renombra** lo ya publicado. Si un nombre resultó malo, se documenta la excepción aquí.
3. **Lo que todavía no se puede fijar se marca ⏳** con la tanda que lo fija, y esa tanda lo escribe
   aquí antes de cerrar (§8).
4. **Nunca `latest`, `*` ni rangos de versión**: las imágenes van por digest, y solo en `a02` (D12).

---

## 2. 🌍 Valores globales

| Qué | Valor | Nota |
|---|---|---|
| Proyecto de Compose | `alameda-lab` (D26) | prefijo de todo lo que levanta el laboratorio |
| Puertos del laboratorio publicado | desplazados a `2xxxx`, solo en `127.0.0.1` y configurables por variable (D27): `POSTGRES_PORT=25432`, `MYSQL_PORT=23306`, `ORACLE_PORT=21521`, `MONGO_PORT=27027`, `SQLSERVER_PORT=21433` (T1, `a02`); los de `api` y `broker`, ⏳ T11 con la misma regla | no chocan con motores locales ni con la NoSQL Lite (`15432`, `27018`…) |
| Puertos de las pruebas de la sesión | aleatorios, los elige Docker (`-p 127.0.0.1::PUERTO`), con un `compose.override.yaml` en `zz-code/` | regla de los lineamientos; nunca los del curso |
| Etiqueta de las pruebas de la sesión | `curso=ruta-sql` | solo se borra lo que la lleva |
| Entornos | SQL y Python con `uv` en todo el camino base; Java 25 solo en el boss del puente y en `a10` | alcance §9, D11, D19 |
| Comando del laboratorio | CLI de Python con `uv` (D28), declarado en `src/pyproject.toml`, desde `src/`: `uv run lab up [perfil …]` (`base` por defecto, con `--wait`), `uv run lab down [-v]`, `uv run lab ps`, `uv run lab generate --profile s\|m\|l [--seed 1996]`, `uv run lab load [--profile s\|m\|l] [--engine postgres\|mysql\|oracle] [--tables …] [--private]` (S y Postgres por defecto; `--tables` obligatorio en MySQL y Oracle), `uv run lab measure [--engine …] [--profile …] -c "…" \| -f archivo [--private]` | fijado en T1 (`a02`, `a04`, `a05`); `--model` (D41) en T4 con F08; `uv run lab race -f escenario.race [--engine …] [--isolation read-committed\|repeatable-read\|serializable\|read-uncommitted] [--permutation "a1 b1 …"] [--timeout 30] [--patience 3] [--sql]` y el módulo `lab.race` (D43) en T7 con `a04` |

> ⚠️ **Excepción documentada: dos perfiles se llaman en español** (`contraste` y `puente`), aunque la
> guía §5 pide inglés para todo lo que se ejecuta: nombran el papel en el curso, no el producto, como
> los perfiles de la NoSQL Lite. Si T1 prefiere otros nombres, los cambia aquí antes de escribir `a02`.

---

## 3. 🗂️ La estructura de archivos

```text
ruta-sql/
├── README.md                          T15
├── 0-ESTRUCTURA-CURSO.md              T15
├── 00-historia-de-alameda.md          la historia: el lector la lee antes de F00
├── 00-…md … 26-…md                    fases; los slugs canónicos, en la propuesta de fases §11
├── a01-…md … a10-…md                  apéndices; slugs en la propuesta de apéndices §2
├── ss01-…md … ss05-…md · ssa-01-…md   track opcional de SQL Server
├── INSTINTOS.md · bitacora-de-medicion.md    documentos vivos (con a08)
├── soluciones/                        un solucionario por documento con ejercicios, con su mismo nombre (D18)
├── prompts/                           maquinaria; el lector no la abre
└── src/                               el código; un solo .gitignore, en src/ (nace en T0)
    ├── lab/                           compose.yaml, generator/, el arnés y la caja generada (no se versiona)
    └── NN-<slug>/ · aNN-<slug>/       una carpeta por fase o apéndice que deja código, con el nombre exacto del documento
```

---

## 4. 🧱 El laboratorio: perfiles

| Perfil | Motor o servicio | Para qué | Fases |
|---|---|---|---|
| `base` | PostgreSQL | el motor principal, siempre arriba | todas |
| `contraste` | MySQL | el contraste donde cambia la decisión | según la ficha |
| `oracle` | Oracle Database Free | el caso de estudio; sin números publicados | según la ficha |
| `mongo` | MongoDB | el invitado del duelo | F20 |
| `api` | PostgREST | la base como producto | F23, boss V |
| `puente` | Apache Artemis y el servicio Java 25 | el boss del puente | F23 |
| `sqlserver` | SQL Server | el track opcional | `ss01`–`ss05` |

Servicios: `postgres`, `mysql`, `oracle`, `mongo`, `api`, `broker`, `bridge` y `sqlserver` (guía §12),
los mismos que usó la verificación de laboratorio. Volúmenes (`<servicio>-data`, con la etiqueta
`curso=ruta-sql`), puertos, digests, límites de memoria y la tabla de RAM: fijados en T1 en `a02` y en
`src/lab/compose.yaml`; los de `api`, `broker` y `bridge`, ⏳ T11.

---

## 5. 🗄️ Datos

- **Entidades del modelo nuevo**, en `snake_case` y en singular (guía §5, D10): `patient`,
  `identity_document`, `lab_order`, `order_item`, `practice`, `analyte`, `result`,
  `reference_range`, `specimen`, `payer`, `agreement`, `site`, `physician`, `invoice`, `appointment`.
- **Restricciones e índices:** `<tabla>_<columnas>_<sufijo>`, con los sufijos de Postgres (`pkey`,
  `key`, `fkey`, `check`, `idx`, `excl`).
- **Esquema `legacy`:** la caja tal cual, con sus nombres originales y comillas donde el motor las
  exija (`legacy."Pacientes"`, `legacy."ResultadoItem"`). Nada nuevo se crea en `legacy`. Se carga en
  Postgres siempre y en MySQL y Oracle solo las tablas que pide cada fase (D13).
- **La verdad del generador:** esquema **`truth`**, cargado siempre en Postgres (D31), con siete
  tablas: las seis fijadas en T1 (`a05`): `person`, `patient_record`, `parser_case`, `order_payer`,
  `result_value` y `planted_case` (§8, T1); y `antibiogram`, agregada en T9 (D46).
- **Esquema `lab`** (en MySQL, la base `lab`): la tabla `lab.loaded`, con qué caja cargó `lab load`.
- **Esquema del modelo nuevo:** **`alameda`** (en MySQL, la base `alameda`), y el área de carga,
  **`staging`** (D34), con la tabla de rechazos `staging.rejection` y su vista
  `staging.rejection_report` (D37).
- **Perfiles de volumen:** S, M y L (D4), con la semilla `1996` (D25); los conteos, en §8 (P11, a rehacer en T1). `a05` los
  confirma en T1 y, si su generador cambia, los reescribe aquí.

---

## 7. 🏷️ Git

- **Tags de fase:** `fase-NN-<slug>`; commits con prefijo `fNN:` y los de ejercicio `fNN ejM: …`.
- **Track:** `ss-fase-NN-<slug>` y `ssNN:`, para que `git tag -l 'fase-*'` siga siendo el índice
  limpio del camino base.
- **Apéndices que dejan archivos:** `apendice-a02-compose`, `apendice-a05-la-caja` y
  `apendice-a10-access-de-museo`. Los demás, sin tag.

(La numeración salta de §5 a §7 para conservar la de la plantilla de los lineamientos: los eventos y
colas del boss del puente se fijan en §8 cuando T11 los diseñe.)

---

## 8. 🔒 Fijado por tanda

Cada tanda que fije un nombre nuevo (el proyecto de Compose, los puertos, el esquema del modelo, la
cola del puente) agrega aquí su subsección **al cerrarse**, con fecha y tanda, y quita su ⏳ de arriba.

### P11 · 11/10/2026 · Perfiles de volumen y semilla

Calibrados con el prototipo del generador en la verificación de laboratorio (`hallazgos.md` §H12).
M entra en 16 GB con los tres motores arriba, así que no se achicó.

| Perfil | Personas | Filas de `Pacientes` | `Protocolos` | `ResultadoItem` | Uso |
|---|---|---|---|---|---|
| `s` | ≈ 20.700 | ≈ 25.200 | ≈ 142.000 | ≈ 1,7 M | por defecto en `lab load` |
| `m` | ≈ 208.000 | ≈ 252.000 | ≈ 1,43 M | ≈ 16,8 M | las mediciones publicadas |
| `l` | ≈ 1 M | ≈ 1,2 M | ≈ 7 M | ≈ 84 M | opcional, nunca por defecto |

- **Semilla por defecto:** ~~`1979`~~ → **`1996`**, el año del cuaderno de la historia (D25, Oskar,
  12/10/2026). Los conteos de arriba son del prototipo con `1979`, y quedan como registro: los vigentes
  son los de T1, abajo. Después de publicar el primer número, la semilla no cambia. Misma semilla,
  mismos bytes: se comprueba por SHA-256 sobre todos los archivos generados.
- **La verdad**, en el prototipo: `truth/patient_person.csv` y `truth/result_value.csv`. El nombre del
  esquema donde se carga (`truth`, propuesto) seguía ⏳ hasta `a05`: lo fijó T1, con seis tablas (abajo).

---

### T0 · 12/10/2026 · Decisiones del paso 1 de T0–T5 y la caja

- **Proyecto, puertos, comando, esquemas y verdad:** fijados arriba en §2 y §5 (D26–D28, D31, D34,
  D37), con lo que quedaba ⏳ para `a02`, `a04` y `a05` (fijado en T1, abajo).
- **La caja generada vive en `src/lab/caja/`**, ignorada por `src/.gitignore`, con un directorio por
  perfil (`s/`, `m/`, `l/`).
- **Semilla `1996`** (D25): los conteos de la tabla de P11 se rehacen en T1.

### T1 · 12/10/2026 · El laboratorio, la caja y la verdad

**Los perfiles, medidos con la semilla `1996`** (reemplazan la tabla de P11, que era del prototipo con
`1979`). Después de publicar el primer número de una fase, no cambian:

| Perfil | Personas | Filas de `Pacientes` | `Protocolos` | `ResultadoItem` | CSV | SHA-256 de la caja |
|---|---|---|---|---|---|---|
| `s` | 20.002 | 24.245 | 132.065 | 1.201.086 | 214 MB | `49cfb8db41947b05ec06c81d0948fbe872f1d57d14d8ba9d293f46e687453fab` |
| `m` | 200.002 | 242.427 | 1.327.622 | 12.134.453 | 2,2 GB | `3e59292e9918ee259e44c49c928d0b024686019fe070cc9fdca40a97fb2dd465` |
| `l` | ≈ 1 M | ≈ 1,2 M | ≈ 6,6 M | ≈ 61 M | ≈ 11 GB | sin generar (opcional, D4) |

**El parser de Rubén** (`rubens_parser.py`, el port de `ExtraerDNI()`): 88,9 % en S y **90,1 % en M**
(23.048 de 25.575), que es la cifra que publica F04 (D35).

**Las columnas de `truth`:**

| Tabla | Columnas |
|---|---|
| `person` | `person_id`, `sex`, `birth_date`, `document_type`, `document_country`, `document_number`, `later_dni`, `mother_person_id`, `payer_code` |
| `patient_record` | `legacy_patient_id`, `person_id`, `dirt` (`text[]`: `dni_in_name`, `name_variant`, `payer_in_name`, `empty_dni`, `other_site`, `newborn_mother_dni`, `passport_in_dni`, `libreta_and_dni`, `future_birth`, `newborn_other_dni`) |
| `parser_case` | `legacy_patient_id`, `expected_dni`, `expected_payer` |
| `order_payer` | `legacy_protocol_id`, `person_id`, `payer_code`, `written_as` |
| `result_value` | `legacy_result_item_id`, `value_numeric`, `qualifier`, `value_text`, `state` (`dot`, `comma`, `below`, `above`, `hemolyzed`, `empty`, `qualitative`) |
| `planted_case` | `case_code` (`boss-1-lady`, `boss-1-grandson`), `person_id`, `note` |
| `antibiogram` | `culture_id`, `person_id`, `culture_date`, `germ`, `antibiotic`, `sensitivity` (`S`, `I`, `R`) |

**Lo demás que fija T1:** el usuario `LEGACY` de Oracle para la caja (y `alameda`, `APP_USER`, para el
modelo nuevo); un `DIRECTORY` de Oracle por carpeta, `CAJA_<PERFIL>_TABLAS`; la imagen de Java 25 con
Maven fuera del compose, fijada en `a02`; y `requires-python = ">=3.13,<3.14"`, porque el hash de la
caja depende de la versión de `random`.

### T3 · 12/10/2026 · Los huérfanos de la caja y la numeración única

La caja no tenía huérfanos, y la historia dice que las claves foráneas de 2011 se crearon `WITH NOCHECK`
por ellos. Decisión de Oskar: un flujo aparte del generador (`ResultadoItem/borrados`) hace que los
resultados del 0,5 % de los protocolos de abril de 2008 a mayo de 2011 apunten a un protocolo borrado.
**No cambia ningún conteo**: solo `ResultadoItem.csv`, y con él los hashes. En M, 2.150 resultados de 198
protocolos.

| Perfil | SHA-256 de la caja (vigente desde T4) |
|---|---|
| `s` | `49cfb8db41947b05ec06c81d0948fbe872f1d57d14d8ba9d293f46e687453fab` |
| `m` | `3e59292e9918ee259e44c49c928d0b024686019fe070cc9fdca40a97fb2dd465` |

Los de la tabla de T1 se reemplazaron por estos en todo el curso. En la misma tanda, la fecha que la
recepción escribe dentro de `Nombre` (`DNI 6659374 12/03/46`) pasó a ser la de nacimiento de la persona,
con el año en dos cifras, como en el formato de Rubén; antes era una fecha al azar. Tampoco cambió ningún
conteo ni el largo de ningún archivo.

**13/10/2026 · La numeración nacional, única.** El generador sorteaba el DNI dentro del rango de cada año de
nacimiento, y 407 números quedaron en 814 personas distintas. Decisión de Oskar: si el número ya está tomado,
se usa el siguiente libre (`_free_number` en `world.py`), **sin consumir azar**, para el DNI, la libreta y el
DNI posterior del extranjero. No cambió ningún conteo, ni el 90,1 % del parser, ni la prueba de fuego; sí
cambian los hashes (la tabla de arriba ya tiene los nuevos) y una cifra de F04: `DNI → Nombre` pasa de 11.120
a **10.903**. Verificado en macOS con Python 3.13.4 y en Linux con 3.13.13: el mismo hash para S.

**Los nombres que estrena F05:** `alameda.patient` (con `mother_patient_id`, `merged_into_patient_id`,
`merged_at` y `merged_by`), `alameda.identity_document` (tipos `DNI`, `LE`, `LC`, `PAS`, `OTRO`; país ISO
3166-1 alfa-3), `alameda.patient_merge`, el disparador `patient_forbid_delete`; en `staging`,
`patient_clean`, `match_candidate`, `match_review` (niveles `automatic` y `review`; decisiones `same_person`
y `different_people`) y `document_candidate`; y las reglas de rechazo `pacientes.pasaporte_sin_pais`,
`pacientes.recien_nacido_con_documento_ajeno`, `pacientes.numero_fuera_de_formato` y
`pacientes.documento_de_otro_paciente`.

### T4 · 14/10/2026 · La unidad bioquímica de septiembre de 2002

`ub_value()` devolvía el último valor de la curva (3.600, el de 2026) para cualquier fecha anterior a su
primera ancla, y septiembre de 2002 cae antes. Salía con precios de 2026 `Precios_2002_09`, y también los
coseguros, recibos y deudores anteriores a septiembre de 2002. Decisión de Oskar: antes de la primera ancla,
la curva vale lo que vale la primera. No consume azar ni cambia conteos; cambian esos montos y los hashes,
que la tabla de T3 ya muestra (S `49cfb8db4194…`, M `3e59292e9918…`; el `MANIFIESTO.json` de S,
`c96d8911163fe925…`, igual en macOS y en Linux). En F01 cambian la foto del catálogo (`Recibos` pasa de
3.896 a 3.888 kB) y las estimaciones de MySQL, que además varían en cada carga; los 15.696 bloques de
`Protocolos` no cambian.

**La 4FN de F06** usa médicos derivantes y teléfonos: la caja trae una sola obra social por persona
(decisión de Oskar, 13/10/2026). **Los nombres que estrena F06:** `alameda.nomenclator`, `alameda.practice`,
`alameda.practice_code`, `alameda.site`, `alameda.payer_practice`, `alameda.practice_site`,
`alameda.payer_site` y la vista `alameda.agreement`; en `staging`, `agreement_raw`, `agreement_noncyclic`,
`patient_phone`, `patient_physician` y `patient_contact_combined`.

**Los nombres que estrenan F07 y F08:** `alameda.biochemical_unit` (con la exclusión
`biochemical_unit_valid_during_excl`), `alameda.practice_price` y `alameda.agreement_price` (claves `WITHOUT
OVERLAPS`), `alameda.billed_practice` (clave foránea con `PERIOD`), `alameda.lab_order`, `alameda.analyte` y
`alameda.result` (con `result_value_check`); en `staging`, `monthly_price`, `price_2025`, `result_item_current` y
`result_item_history`, `agreement_price_bitemporal`, las cuatro `patient_anchor*` de la 6FN, `result_eav`,
`result_wide` y `result_document`; las reglas `precios.pegado_dos_veces`, `precios.vigencia_duplicada` y
`facturacion.practica_sin_precio_vigente`. **El CLI:** `uv run lab load --profile m --model` (D41), que borra
`staging` y `alameda` y corre en orden los scripts de las fases 04 a 08 (`src/lab/model.py`).

### T5 · 14/10/2026 · Los nombres del tamaño, las claves y los índices

**Los nombres que estrena F09** (todo en `staging`): `file_listing` (el listado de `/caja/m/archivos/listado.csv`),
`report_pdf_bytea`, `report_pdf_lo` y `report_file` (los 2.000 informes en tres formas), `result_as_is` y `result_reordered`,
`align_bad` y `align_good`, `result_by_month` (223 particiones mensuales, `result_YYYY_MM`), `scan_pglz` y `scan_lz`.
En MySQL, base `staging`, `protocolos_en_orden` (con `protocolos_en_orden_idpaciente_idx` y `protocolos_en_orden_sede_fecha_idx`)
y `report_pdf`. **F10:** `order_bigint`, `order_uuid4`, `order_uuid7` (en Postgres y en MySQL, con `<tabla>_patient_id_idx`),
`lab_order_new`, `portal_url` y `md5_dictionary`; el script `mysql_keys.py`. **F11:** `result_recent` (con sus índices
`result_recent_*`), `write_source` y `write_cost`, `result_write` (y sus `result_write_*_idx`), `hot_result` y `hot_report`,
`order_note` (y `order_note_note_idx`, el que rompe); en Postgres, el BRIN `result_as_is_recorded_at_brin` y el índice de
trigramas `patient_clean_norm_name_trgm_idx`. Los scripts con `\gset` e `\ir` se nombran `*_round.sql`.

### T6 · 14/10/2026 · Los nombres de las estadísticas, el optimizador y el cable

**F12** (en `staging`): `protocol_stats` y el objeto de estadísticas `staging.protocol_stats_site_prefix_stat`,
`result_2020` (con el autovacuum apagado, a propósito), `plan_cliff` y la función `measure_cliff`, y el B-tree
`result_as_is_recorded_at_idx` (el barrido quita el BRIN de F11); en MySQL, `protocol_hist`. **F13:** `order_site` (con
`order_site_site_ordered_idx`), la sentencia preparada `by_site`, el script `psycopg_prepare.py`, y en MySQL `protocol_hint`.
La imagen derivada del 🔥 se llama `ruta-sql/postgres-hint-plan:f13`, con la etiqueta `curso=ruta-sql`, y su contenedor de
prueba `ruta-sql-hint-f13`. **F14:** `portal_order` (con `portal_order_newest_idx`), los scripts `front.py`,
`portal_offset.pgbench` y `portal_keyset.pgbench`; en MySQL, `staging.protocolos` y `staging.resultado_item`, las copias con
los índices del `AutoIndex`. **Boss II:** `staging.portal_2018` en `src/14-la-base-no-estaba-lenta/boss/`; la solución
(`portal_report`, `portal_expired_link`) vive en `zz-code` (D42).

### T7 · 14/10/2026 · Los nombres de las carreras y del folio

**El arnés:** `src/lab/race.py` (`Race`, `Session`, `Monitor`, `Outcome`) y los escenarios `*.race`, con las directivas `@engine`,
`@isolation`, `@setup`, `@check`, `@teardown` y `@permutation`, los pasos `<sesión><número>:` y el marcador `{isolation}`; la
versión de MySQL de un escenario lleva el sufijo `_mysql.race`. **F15** (en `staging`, en los dos motores): `specimen` (con
`taken_by` en Postgres) y `specimen_take` (con `specimen_take_specimen_id_idx`; `specimen_take_unique` solo dentro de una
medición), `debtor`, `cash_batch` y `cash_receipt`; los escenarios `dirty_read`, `nonrepeatable_read`, `phantom`, `lost_update`,
`write_skew`, `read_only`, `locking_check` y `current_read_mysql`; los scripts `matrix.py` y `technicians.py`. **F16:** el esquema
`fiscal` (`fiscal.authorized` y `fiscal.start`, el registro del organismo simulado), `staging.invoice_counter`, `staging.invoice`
y `staging.invoice_number_seq` (en MySQL, `invoice_counter` e `invoice`); los scripts `fiscal.py` (`FiscalService`, `Rejected`,
`Timeout`), `races.py` y `cajas.py`, y los escenarios `counter_mysql` y `get_lock_mysql`.

### T8 · 14/10/2026 · Los nombres de MVCC, los bloqueos y el boss III

**F17** (en `staging`): `mvcc_counter`, `result_day` y `result_copy` (borrada al terminar), `para_llamar` (con
`para_llamar_pending_idx`) y `call_made`; los scripts `mvcc.py` y `mysql_history.py`. **F18:** `hemogram` (con `version`),
`result_ddl` (la copia de los resultados para el DDL, 686 MB), y en MySQL `ddl_target` y `payment`; los escenarios
`lunch_form`, `lunch_form_timeout`, `optimistic`, `deadlock`, `ddl_queue`, `ddl_lock_timeout` y sus `_mysql`; los scripts
`ddl_rewrite.py` y `ten_am.py`. **Boss III:** `src/18-bloqueos-deadlocks-y-ddl/boss/` con `01_july.sql`, `tills.py` (lo que el lector
arregla) y `afternoon.py` (el arnés); en `staging`, `july_counter`, `july_invoice`, `july_specimen`, `july_specimen_take` y
`july_hemogram`. La solución vive en `zz-code` (D42).

### T12 · 15/10/2026 · Los nombres de la migración, del SIH y del martes

**F24:** `src/24-el-diseno/01_inventario.sql` y `02_ejercicios.sql`, de solo lectura. **F25** (en `staging`, salvo donde se dice):
`wide_column`, `wide_cell`, `wide_unmapped` y `wide_result` (el mapa celda → resultado), con la secuencia `wide_result_id_seq`, que
empieza en **1.000.000.000** mientras legacy viva; los analitos nuevos de las anchas se llaman `N<últimos tres dígitos del código
NBU>.<cinco primeras letras de la columna>` (`N020.COLOR`); la columna `alameda.billed_practice.quantity` con
`billed_practice_quantity_check`; el rol `access_frontend` (el frontal Access), el slot lógico `f25_legacy` (`test_decoding`), las
tablas `f25_cdc_position` y `f25_cdc_log`, y las funciones `f25_value(text)`, `f25_apply_protocol(jsonb)`,
`f25_apply_practice(jsonb)` y `f25_apply_result(jsonb)`; las reglas de rechazo `anchas.valor_no_numerico`,
`anchas.protocolo_inexistente`, `anchas.celda_repetida`, `cdc.paciente_desconocido`, `cdc.protocolo_desconocido`,
`cdc.practica_sin_obra_social`, `cdc.practica_sin_codigo`, `cdc.clave_ocupada` y `cdc.borrado_de_protocolo`; el esquema `sih`
(`sih.patient`, `sih.lab_link`) y `staging.patient_sih`; los scripts `cdc.py`, `05_convivencia.py` y `07_corte.py`; el día de
convivencia es el **12/10/2026**. **F26:** `01_factura.py`; el 🏆 boss global en `src/26-el-comite/martes/` con `00_base.sql` (del
curso), `01_setup.sql` y `flujo.py` (del lector) y `arnes.py`; el rol `facturacion` con la política `facturacion_lee_todo` sobre
`alameda.lab_order`; `staging.martes_cap` y `staging.martes_writes`; `alameda.presentation`, `alameda.presentation_line` y
`alameda.presentation_excluded`, con los motivos `sin_precio`, `fuera_de_convenio`, `incluida_en_panel` y `excede_tope`; la semana
del martes, del **28/09 al 04/10/2026**. La solución vive en `zz-code` (D42).

### T13 · 18/10/2026 · Los nombres del track de SQL Server

**El laboratorio:** el extra `sqlserver` del proyecto (`mssql-python`), `lab/engines/sqlserver.py`, `--engine sqlserver` en `lab load`,
`lab measure` y `lab race`, la directiva `@database` y el nivel `snapshot` de `lab race`, y el perfil `dab` del compose; la base del
motor original se llama `ALAMEDA`, con el esquema `dbo` del script de SSMS, más `lab.loaded`. **Una base por fase**, para que lo que
cambia una no toque `ALAMEDA`: `ss01_pruebas`, `ss02`, `ss03`, `ss04`, `ss05`. **ss01:** `src/ss01-…/sqlcmd.sh`, que usa todo el track.
**ss02:** `dbo.hemogram`, `dbo.specimen`, `dbo.specimen_take`, `dbo.debtor` (los nombres de las Fases 15 y 18, sin `staging`).
**ss03:** `dbo.resultados_por_sede` y sus variantes `resultados_optimize_for_c`, `resultados_optimize_for_unknown`,
`resultados_recompile`, `resultados_opcional`; `dbo.protocol_hint` con los índices de la Fase 13. **ss04:** `order_int`,
`order_newid`, `order_newseq`, `order_uuid4_app`, `order_uuid7_app`, `dbo.seq_restart`; la tabla temporal `dbo.resultado` con
`dbo.resultado_historia`, el período `ValidoDesde`/`ValidoHasta` y la columna `ModificadoPor`, que se llena desde
`SESSION_CONTEXT(N'usuario')`. **ss05:** el modelo de la Fase 23 con sus nombres (`alameda.*`), `staging.culture_doc` con la columna
`antibiogram json`, el esquema `api` con `api.resultados`, `api.protocolos`, el predicado `api.puede_ver` y la política `api.portal`;
el *login* `dab_api`; los *claims* `roles`, `patient_id`, `physician_id`; `dab-config.json`. Los tags del track, `ss-fase-NN-<slug>`.

## 9. ❓ Qué hacer si falta un nombre

1. Se busca aquí, en el diccionario §4 y en las fases ya escritas.
2. Si no existe, se propone con las convenciones de la guía §5 y se agrega aquí, con la fase que lo
   estrena.
3. Si choca con uno existente, gana el existente.
