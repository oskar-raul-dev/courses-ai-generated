# 📎 Apéndice bea-06 — Restricciones, claves compuestas y datos sucios

> Tutorial Angular 16 — Inspecciones y certificaciones · **Track BE opcional 🔥** · Consulta rápida · **3 horas**
> Usado por: **be05** ⭐ · Versiones cubiertas: **PostgreSQL 16**
> 🔥 Pertenece al track opcional de backend. El track base se completa sin abrirlo.

**Esto no se lee de corrido.** Se entra con una pregunta operativa —*"¿esto bloquea la tabla?"*, *"¿cómo pongo esto si ya hay filas malas?"*— y se sale con el comando y con el bloqueo que toma.

🧭 **El ángulo:** el problema nunca es escribir la restricción. Es que **ocho años de datos no la cumplen** y el sistema tiene que seguir emitiendo certificados mañana por la mañana.

**Qué queda fuera:** **limpiar los datos sucios**. En un dominio regulado el histórico no se reescribe, y este apéndice no da recetas para hacerlo — enlaza con la doctrina del track y no la contradice. Tampoco entra el diseño de esquema, que es [`be03`](be03-el-reemplazo.md), ni el análisis de la invariante concreta de CertCore, que es [`be05`](be05-la-invariante-que-no-sostenia-nadie.md).

---

## Índice

- [Claves primarias y foráneas compuestas](#claves-primarias-y-foráneas-compuestas)
- [`NOT VALID` y `VALIDATE CONSTRAINT` ⭐](#not-valid-y-validate-constraint-)
- [`CHECK` con función, y sus tres límites](#check-con-función-y-sus-tres-límites)
- [Columnas generadas, y lo que **no** pueden hacer](#columnas-generadas-y-lo-que-no-pueden-hacer)
- [Índices únicos parciales](#índices-únicos-parciales)
- [El procedimiento de despliegue sin bloquear la tabla](#el-procedimiento-de-despliegue-sin-bloquear-la-tabla)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [Referencias](#-referencias)
- [Ejercicios](#-ejercicios-7)

---

## Claves primarias y foráneas compuestas

Una clave compuesta es una clave cuyo valor son **varias columnas juntas**. No tiene nada de exótico y PostgreSQL las soporta desde siempre; lo que suele faltar es el ORM.

```sql
-- Clave primaria compuesta: lo que `templates` necesitaba y no tuvo hasta be03.
ALTER TABLE templates ADD PRIMARY KEY (template_id, version);

-- Y la foránea compuesta que apunta a ella.
ALTER TABLE inspections
  ADD CONSTRAINT inspections_template_fk
  FOREIGN KEY (template_id, template_version)
  REFERENCES templates (template_id, version);
```

Tres cosas que hay que saber y que casi nunca se dicen:

1. **La tabla referenciada necesita un `PRIMARY KEY` o un `UNIQUE` sobre exactamente esas columnas, en ese orden.** Sin él, el `ALTER` falla con *"there is no unique constraint matching given keys"*, y ése es el mensaje que delata que el problema está en la **otra** tabla.
2. **El orden de las columnas importa** para el índice que respalda la clave, aunque no para la semántica de la restricción.
3. **PostgreSQL no crea índice para la foránea**, sólo para la clave referenciada. Si vas a borrar o actualizar filas de la tabla padre, quieres un índice en las columnas hijas o cada `DELETE` hará un recorrido secuencial.

```sql
CREATE INDEX inspections_template_idx ON inspections (template_id, template_version);
```

> 🧠 **Cuando un sistema tiene un identificador compuesto aplastado en una cadena —`"elevator-annual-v2"`— casi siempre es que alguien no pudo declarar la clave compuesta y buscó la salida.** La causa suele ser el ORM, y la consecuencia es que la foránea compuesta que hacía falta no se pudo ni escribir. En CertCore eso es literal ([`bea-04`](bea-04-eloquent-lo-que-absorbe-y-lo-que-no.md)).

---

## `NOT VALID` y `VALIDATE CONSTRAINT` ⭐

El mecanismo central del apéndice, y la herramienta más infravalorada de PostgreSQL.

**El problema:** `ALTER TABLE ... ADD CONSTRAINT` valida el histórico entero. Si hay una sola fila que no cumple, no se añade nada. Y si hay millones de filas que sí cumplen, la validación bloquea la tabla mientras las lee todas.

**La salida, en dos tiempos:**

```sql
-- Tiempo 1 — HOY. No lee las filas existentes: sólo declara la regla.
ALTER TABLE inspections
  ADD CONSTRAINT inspections_template_fk
  FOREIGN KEY (template_id, template_version) REFERENCES templates (template_id, version)
  NOT VALID;

-- Tiempo 2 — CUANDO SE PUEDA, y sólo si se decidió qué hacer con las filas malas.
ALTER TABLE inspections VALIDATE CONSTRAINT inspections_template_fk;
```

Qué hace exactamente cada uno:

| | `ADD ... NOT VALID` | `VALIDATE CONSTRAINT` |
|---|---|---|
| Filas nuevas y modificadas | **Se comprueban** desde el primer segundo | Ya se comprobaban |
| Filas viejas que violan | **Se quedan**, intactas | Hacen fallar el comando |
| ¿Lee la tabla entera? | **No** | Sí |
| Bloqueo (foránea) | `SHARE ROW EXCLUSIVE` sobre ambas tablas, breve | `SHARE UPDATE EXCLUSIVE`: **no bloquea lecturas ni escrituras normales** |
| ¿Lo usa el planificador? | No confía en ella | Sí, una vez validada |

Y los tres efectos que sorprenden y hay que anunciar antes de desplegar:

- **Un `UPDATE` sobre una fila vieja inválida falla**, aunque el `UPDATE` no toque las columnas de la restricción. La fila entera se revalida al modificarse. Es correcto, y es lo que rompe el primer proceso masivo que alguien corra después.
- **Una foránea `NOT VALID` sí impide borrar filas del padre** referenciadas por hijos válidos, y también por los inválidos existentes. La protección "hacia el otro lado" es completa desde el primer día, y suele ser el motivo principal para ponerla.
- **`VALIDATE` se puede correr en cualquier momento** y, si falla, no deja la restricción peor de lo que estaba: sigue existiendo como `NOT VALID`.

> 🧭 **`NOT VALID` no es una restricción a medias: es una restricción completa para el futuro.** Separa el futuro del pasado, que es justo lo que hace falta cuando el pasado no se puede tocar.

```sql
-- Qué restricciones hay sin validar en esta base:
SELECT conrelid::regclass AS tabla, conname, contype
FROM pg_constraint WHERE NOT convalidated;
```

Ese `SELECT` conviene tenerlo a mano: una restricción `NOT VALID` que lleva tres años sin validar **es una deuda declarada**, y aparece en un inventario. Una que nadie sabe que existe, no.

---

## `CHECK` con función, y sus tres límites

Una restricción `CHECK` puede llamar a una función, y eso permite reglas que la sintaxis declarativa no expresa:

```sql
CREATE FUNCTION template_version_exists(p_template_id text, p_version integer)
RETURNS boolean AS $$
  SELECT EXISTS (SELECT 1 FROM templates WHERE template_id = p_template_id AND version = p_version);
$$ LANGUAGE sql STABLE;

ALTER TABLE inspections
  ADD CONSTRAINT inspections_template_check
  CHECK (template_version_exists(template_id, template_version)) NOT VALID;
```

Los tres límites, en orden de importancia:

1. **Un `CHECK` sólo se evalúa cuando cambia su propia fila.** Si la verdad que comprueba vive en **otra** tabla, un cambio allí no lo revalida nunca. Borra la plantilla y las inspecciones se quedan huérfanas sin un error. **Para eso está la foránea, y por eso no son intercambiables.**
2. **Un `CHECK` no inmutable miente al restaurar.** `pg_restore` revalida las restricciones al cargar; según el orden de las tablas, puede fallar o pasar sin significar nada.
3. **Rendimiento:** una función que consulta otra tabla se ejecuta en cada `INSERT` y en cada `UPDATE` de esa fila.

A cambio, es la única forma de expresar reglas más ricas que "existe": *que estuviera vigente en la fecha*, *que la severidad sea coherente con el estado*, *que las fechas no se crucen*.

---

## Columnas generadas, y lo que **no** pueden hacer

Una columna generada se calcula a partir de otras columnas **de la misma fila**, al escribir:

```sql
ALTER TABLE certificates
  ADD COLUMN is_revoked boolean GENERATED ALWAYS AS (revoked_at IS NOT NULL) STORED;
```

Y ahora la parte que importa, porque es donde se estrella todo el mundo:

```sql
ALTER TABLE certificates
  ADD COLUMN status_derivado text GENERATED ALWAYS AS (
    CASE WHEN revoked_at IS NOT NULL THEN 'revoked'
         WHEN valid_until < now()    THEN 'expired'
         ELSE 'valid' END
  ) STORED;
--   ERROR:  generation expression is not immutable
```

> ⚠️ **Una columna generada exige una expresión inmutable, y `now()` no lo es.** No es una limitación arbitraria: la columna se calcula **una vez, al escribir**, y se guarda. Si dependiera del reloj, el valor guardado sería falso al minuto siguiente — exactamente el defecto que se estaba intentando arreglar.

> 🧠 **Si un valor cambia sin que nadie escriba la fila, no es una columna: es una consulta.** Ésa es la definición operativa de dato derivado, y la que decide entre estas tres herramientas:

| Lo que necesitas | Herramienta |
|---|---|
| Un valor que depende **sólo de la fila** | **Columna generada** (`STORED`) |
| Un valor que depende del **reloj** o de **otras tablas** | **Vista** (o expresión en la consulta) |
| Un valor caro que se lee mucho y tolera estar desfasado | **Vista materializada**, con su refresco y su desfase declarado |

En CertCore, `certificates.status` es del segundo tipo, y por eso [`be05`](be05-la-invariante-que-no-sostenia-nadie.md) lo resuelve con una vista. La columna generada, ahí, **no es una opción** — y el error de inmutabilidad es la mejor explicación de por qué el dato estaba mal guardado desde el principio.

---

## Índices únicos parciales

El truco que resuelve la mitad de las reglas de unicidad del mundo real, donde la unicidad sólo aplica a **algunas** filas:

```sql
-- "Sólo puede haber UNA plantilla vigente por templateId."
-- La vigente es la que tiene valid_until nulo; las cerradas, cualquier número.
CREATE UNIQUE INDEX templates_one_active_per_id
  ON templates (template_id)
  WHERE valid_until IS NULL;
```

Es declarativo, lo comprueba la base, y no necesita disparadores. Y se puede crear sin bloquear escrituras:

```sql
CREATE UNIQUE INDEX CONCURRENTLY ...   -- tarda más, no bloquea
```

⚠️ `CONCURRENTLY` **no se puede ejecutar dentro de una transacción**, así que no encaja en una migración normal de Eloquent sin desactivar la transacción envolvente. Y si falla, deja un índice **inválido** que hay que borrar a mano (`DROP INDEX`) antes de reintentar. Compruébalo siempre después:

```sql
SELECT indexrelid::regclass FROM pg_index WHERE NOT indisvalid;
```

---

## El procedimiento de despliegue sin bloquear la tabla

Seis pasos, y el primero no es técnico:

1. **Censa.** Cuenta las filas que violan la regla, con fecha y hora. **Sin censo no hay decisión.**
2. **Clasifica.** ¿Las violaciones son viejas y estables, o siguen apareciendo? Ordena por la fecha de creación: si siguen apareciendo, la restricción es urgente; si pararon, algo se arregló solo y conviene saber qué.
3. **Decide qué pasa con las filas malas, y que alguien firme.** En un dominio regulado, la respuesta suele ser *nada*. Escríbela.
4. **Añade con `NOT VALID`**, fuera de hora punta por prudencia, sabiendo que no reescribe la tabla.
5. **Comprueba las dos caras:** una fila nueva mala falla, las viejas siguen ahí. **Siempre las dos.**
6. **Anuncia los efectos laterales** —el `UPDATE` sobre filas viejas inválidas ahora falla— en el correo de despliegue, y deja `VALIDATE` documentado sin ejecutar.

Y el `SET lock_timeout` que evita el peor escenario, que es el `ALTER` esperando un bloqueo detrás de una transacción larga y **bloqueando a todos los que llegan después**:

```sql
SET lock_timeout = '3s';   -- si no consigo el bloqueo en 3 segundos, me rindo
ALTER TABLE inspections ADD CONSTRAINT ... NOT VALID;
```

> 🧭 **Un `ALTER` que espera es peor que un `ALTER` que falla.** Mientras espera el bloqueo, todo lo que llega detrás se encola. `lock_timeout` convierte un incidente en un reintento.

---

## 🧭 Cuándo usar qué

| Situación | Herramienta | Qué cuesta |
|---|---|---|
| La verdad está en otra tabla | **Clave foránea** (compuesta si hace falta) | Bloqueo breve con `NOT VALID` |
| Hay filas que ya la violan | **`NOT VALID`**, y validar después o nunca | Las viejas siguen inválidas y declaradas |
| La regla es más rica que "existe" | `CHECK` con función | No protege de cambios en otra tabla |
| El valor depende sólo de la fila | Columna generada `STORED` | Debe ser inmutable |
| El valor depende del reloj | **Vista** | Se calcula en cada lectura |
| Unicidad sólo para algunas filas | Índice único **parcial** | `CONCURRENTLY` fuera de transacción |
| La tabla es enorme y está caliente | `NOT VALID` + `lock_timeout` | Nada: es el caso para el que existe |
| No puedes poner nada en la base | Disciplina de aplicación **documentada** | Sólo vale si hay una única puerta de escritura |

---

## ⚠️ Advertencias

**Limpiar los datos para que la restricción entre es casi siempre el error más caro.** Reescribir el histórico de un sistema regulado destruye evidencia y encima lo hace de forma indetectable: las filas corregidas afirman algo que nunca ocurrió. Si alguien propone un `UPDATE` masivo "para dejar la tabla limpia", la pregunta que lo frena es: *¿quién firma que esos datos ahora dicen la verdad?*

**Una restricción protege en la dirección en que está escrita, no en la que te imaginas.** Antes de darla por buena, escribe las dos o tres operaciones que **quieres** impedir y compruébalas una a una. La mitad de las restricciones mal elegidas del mundo son `CHECK` puestos donde hacía falta una foránea.

**`NOT VALID` no es un estado transitorio por definición.** Puede quedarse años, y es legítimo — siempre que esté **declarado** en un inventario de deuda y no escondido. La consulta de `pg_constraint` de arriba es la que convierte "se nos quedó así" en "está así, y estas son las razones".

---

## 📚 Referencias

- https://www.postgresql.org/docs/16/sql-altertable.html — `ADD CONSTRAINT ... NOT VALID`, `VALIDATE CONSTRAINT` y, sobre todo, **la sección de bloqueos**, que es la que contesta si algo se puede desplegar.
- https://www.postgresql.org/docs/16/ddl-constraints.html — restricciones, incluidas las compuestas y las parciales.
- https://www.postgresql.org/docs/16/ddl-generated-columns.html — columnas generadas y el requisito de inmutabilidad.
- https://www.postgresql.org/docs/16/sql-createindex.html — índices únicos parciales y `CONCURRENTLY`, con lo que pasa si falla.
- https://www.postgresql.org/docs/16/explicit-locking.html — la tabla de conflictos entre modos de bloqueo. Imprescindible antes de proponer una ventana.
- https://www.postgresql.org/docs/16/runtime-config-client.html — `lock_timeout` y `statement_timeout`.

> ⚠️ Los enlaces pueden haber cambiado; verifícalos. Y con los bloqueos en particular, **comprueba la versión**: lo que leas de PostgreSQL 9 sobre qué bloquea un `ALTER` es más pesimista que lo que hace la 16, y en una discusión de despliegue esa diferencia cambia la decisión.

---

## 🧪 Ejercicios (7)

Todos con un criterio de éxito numérico: **el número de filas que violan la restricción**, antes y después.

1. Cuenta las filas que violan la invariante de `inspections`. Añade la foránea **sin** `NOT VALID` y pega el error. Después con `NOT VALID` y comprueba que el número de filas malas **no cambió**.
2. **Diagnóstico.** Con la restricción `NOT VALID` puesta, intenta tres operaciones: insertar una fila mala, actualizar una fila vieja mala, y actualizar una fila vieja buena. Anota cuáles fallan y explica por qué.
3. Implementa la misma regla con `CHECK` y función. Después borra una plantilla referenciada y cuenta las filas huérfanas que aparecieron. Repite con la foránea: el número tiene que ser cero.
4. **Diagnóstico.** Intenta crear la columna generada con `now()` y pega el error. Después resuélvelo con una vista y comprueba que el resultado cambia con el paso del tiempo sin que nadie escriba.
5. Crea el índice único parcial de "una sola plantilla vigente por `templateId`". Cuenta cuántas filas lo violan hoy; si son cero, provoca una violación y comprueba que la base la impide.
6. **Diagnóstico.** Mide los bloqueos: en una transacción abierta haz un `SELECT ... FOR UPDATE` sobre `inspections`, y desde otra sesión lanza el `ALTER ... NOT VALID`. Observa qué pasa. Después repite con `SET lock_timeout = '3s'` y anota la diferencia.
7. **Diagnóstico.** Lista las restricciones `NOT VALID` de tu base con la consulta de `pg_constraint`. Para cada una, escribe una línea: qué protege, cuántas filas la violan hoy, y qué haría falta para poder validarla. Ese documento es, exactamente, una entrada del mapa de deuda de [`bea-10`](bea-10-mapa-de-deuda-del-track-be.md).

---

> 🏷️ **Este apéndice no lleva tag propio.** Lo que salga de leerlo se commitea con el prefijo de la fase desde la que llegaste (`be05: …`). El inventario del ejercicio 7 conviene conservarlo: be05 lo cita en `INVARIANTES.md` y `bea-10` lo consume entero. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
