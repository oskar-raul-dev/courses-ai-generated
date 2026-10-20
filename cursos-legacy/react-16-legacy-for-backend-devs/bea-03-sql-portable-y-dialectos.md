# 🗃️ Apéndice bea-03 — SQL portable y dialectos

> Tutorial React 16 — La Esclusa, la consola de Jewel Locks · **Track BE opcional 🔥** · Consulta rápida · ~3 horas
> Lo referencian: `be02` principalmente; `be05`, `be06` y `be08` lo consultan

---

Este es el diccionario de divergencias entre **PostgreSQL 13** y **SQLite 3.35**,
para abrir cuando algo no funciona igual en los dos motores. Cada entrada tiene la
misma forma: qué hace cada uno, cómo se ve cuando falla, y **qué hacer**.

La tesis que sostiene el apéndice es la misma de `be02` y no se va a suavizar:

> 🧭 **La agnosia total de base de datos no existe.** Lo que existe es
> **portabilidad por disciplina**: una costura donde el dialecto se hace
> explícito, en vez de esconderse detrás de una abstracción que promete lo que no
> puede cumplir. Un ORM no resuelve esto: lo tapa justo donde necesitas verlo.

Y una advertencia simétrica, que es el error que casi nadie comete y por eso
duele más: **no todo diverge**. Dar por sentada una diferencia que no existe
produce código feo por miedo. Verifica en las dos direcciones.

---

## 🧭 Índice de salto rápido

1. [Placeholders: `?` contra `$1`](#1-placeholders--contra-1)
2. [Identidades autoincrementales](#2-identidades-autoincrementales)
3. [`RETURNING` y `LastInsertId`](#3-returning-y-lastinsertid)
4. [Fechas: el tipo que SQLite no tiene](#4-fechas-el-tipo-que-sqlite-no-tiene)
5. [Booleanos](#5-booleanos)
6. [Números, dinero y la afinidad de tipos](#6-números-dinero-y-la-afinidad-de-tipos)
7. [Bloqueo: `FOR UPDATE` no existe](#7-bloqueo-for-update-no-existe)
8. [Concurrencia de escritura y `SQLITE_BUSY`](#8-concurrencia-de-escritura-y-sqlite_busy)
9. [Claves foráneas apagadas por defecto](#9-claves-foráneas-apagadas-por-defecto)
10. [DDL: `ALTER TABLE` y qué obliga a decidir](#10-ddl-alter-table-y-qué-obliga-a-decidir)
11. [Lo que sí porta](#11-lo-que-sí-porta)
12. [🧩 Cuándo usar qué: la regla del motor](#-cuándo-usar-qué-la-regla-del-motor)

---

## 1. Placeholders: `?` contra `$1`

| PostgreSQL | SQLite |
|---|---|
| `WHERE id = $1 AND status = $2` | `WHERE id = ? AND status = ?` |

**Cómo se ve cuando falla.** Un `?` que llega a Postgres revienta en la primera
ejecución: medido con un `WHERE product_id = ?`, `pq: syntax error at end of
input`. El sentido contrario **no falla**: SQLite acepta `$1` como
parámetro con nombre, así que un `$1` escrito a mano funciona en los dos motores
(medido en `be02`) y sobrevive a todas las pruebas.

**Qué hacer.** Escribir siempre con `?` y pasar por `sqlx.Rebind`:

```go
query := s.db.Rebind(`SELECT id FROM wheels WHERE status = ? AND closes_at > ?`)
```

📖 **La regla operativa del track:** si un archivo de store contiene un `$1`
literal, está mal **aunque hoy funcione**: es la mitad de la mezcla que un día
deja pasar un `?` a Postgres. Es un `grep` que vale la pena tener en la revisión
de código.

> ⚠️ Y el límite de `Rebind`, que hay que tener presente todo el tiempo: resuelve
> **la sintaxis de los placeholders y nada más**. No traduce tipos, ni funciones
> de fecha, ni semántica de bloqueo, ni `RETURNING`, ni `ON CONFLICT`. Creer que
> un `Rebind` te dio portabilidad es exactamente el mito que este apéndice
> desmonta.

---

## 2. Identidades autoincrementales

| PostgreSQL | SQLite |
|---|---|
| `id BIGSERIAL PRIMARY KEY` | `id INTEGER PRIMARY KEY AUTOINCREMENT` |
| Una **secuencia** independiente de la tabla | El `rowid` interno de la tabla |

En Postgres, `BIGSERIAL` crea una secuencia aparte. Eso tiene una consecuencia
que muerde en cuanto siembras datos con ids explícitos: **insertar el id 1 a mano
no mueve la secuencia**, así que el siguiente `INSERT` automático intenta usar el
1 y choca.

**Cómo se ve cuando falla.**
`duplicate key value violates unique constraint "wheels_pkey"` justo después de
una siembra que funcionó perfecto (medido en `be03`, con la secuencia de `wheels`
de vuelta en 1). Es el error común nº 1 de `be03`.

**Qué hacer.** Reajustar la secuencia después de sembrar:

```sql
SELECT setval(pg_get_serial_sequence('wheels','id'),
              COALESCE((SELECT MAX(id) FROM wheels), 1));
```

En SQLite no hace falta: el `rowid` se calcula sobre el máximo existente.

> 📝 `BIGSERIAL` es la forma clásica; `GENERATED ALWAYS AS IDENTITY` es la del
> estándar y existe desde Postgres 10. El track usa `BIGSERIAL` porque es lo que
> había en la mayoría de los esquemas de 2022, y porque su rareza con `setval` es
> contenido: la vas a encontrar en cualquier base heredada.

---

## 3. `RETURNING` y `LastInsertId`

Esta es **la divergencia que más caro sale**, porque falla en la dirección
peligrosa.

| | PostgreSQL (`lib/pq`) | SQLite (`mattn/go-sqlite3`) |
|---|---|---|
| `RETURNING` | Siempre | Desde **3.35** (marzo 2021) |
| `res.LastInsertId()` | **No implementado** | Funciona |

`lib/pq` devuelve `LastInsertId is not supported by this driver`. No es un bug del
driver: el protocolo de Postgres sencillamente no ofrece ese dato.

**Por qué es la peor.** El código escrito con `LastInsertId` **pasa las pruebas
contra SQLite y falla en producción contra Postgres**. La suite no detecta el
bug: la suite lo autoriza. Es la Prueba A del par contradictorio de `be08`.

**Qué hacer.** `RETURNING` siempre, en los dos motores:

```go
query := tx.Rebind(`
    INSERT INTO wheels (name, timezone, closes_at, status)
    VALUES (?, ?, ?, ?)
    RETURNING id`)
var id int64
err := tx.GetContext(ctx, &id, query, w.Name, w.Timezone, w.ClosesAt, w.Status)
```

> 🧭 Y acá está el porqué de una decisión que parecía arbitraria: `D18` fija
> **SQLite 3.35 o superior**, y 3.35 no es un número redondo. Es marzo de 2021,
> cuando llegó `RETURNING`. Comprueba la tuya con `select sqlite_version();`: la
> que trae `mattn/go-sqlite3` v1.14.16 es la **3.39.4** (medido en `be02`).

---

## 4. Fechas: el tipo que SQLite no tiene

| PostgreSQL | SQLite |
|---|---|
| `TIMESTAMPTZ` (instante), `TIMESTAMP`, `DATE`, `INTERVAL` | **Ninguno.** `TEXT`, `INTEGER` o `REAL` |
| `now()` | `datetime('now')` |
| Comparación entre **instantes** | Comparación entre **cadenas** |

SQLite no tiene tipo de fecha. Guarda texto, y comparar texto es comparación
lexicográfica. Con formato ISO 8601 y **todo en el mismo huso** funciona por
accidente. Con husos mezclados, no.

**El caso que hay que tener grabado** (Divergencia 2 de `be02`, Prueba B de
`be08`), medido:

```sql
-- closes_at = '2026-08-15T20:00:00-05:00' (la Semana del Canal), que es el 16 a la 01:00 UTC
SELECT name FROM wheels WHERE closes_at > '2026-08-16T00:00:00Z';
```

- **Postgres:** compara instantes. 01:00Z > 00:00Z → **devuelve la rueda**.
- **SQLite:** compara `'2026-08-15…'` con `'2026-08-16…'`, ve que `15 < 16` →
  **no devuelve nada**.

Y una trampa más, del lado de Go (Divergencia 0 de `be02`): con la columna
declarada `TEXT`, `mattn/go-sqlite3` no convierte a `time.Time` y el `Scan` falla
con `unsupported Scan, storing driver.Value type string into type *time.Time`.
Declarada `TIMESTAMP` —que para SQLite no es un tipo, sino un nombre—, el driver
convierte al leer. Adentro sigue siendo texto.

Los dos motores funcionan correctamente según su propia especificación, y tu
regla de negocio da resultados **opuestos**.

**Qué hacer.**

- La expresión de "ahora" sale de la costura, nunca escrita a mano:
  `db.Now()` devuelve `now()` o `datetime('now')` según el dialecto.
- **Nunca literales de fecha en el SQL.** Los instantes se pasan como
  `time.Time` por placeholder; el driver los serializa.
- Y la conclusión que `be08` convierte en regla: **cualquier prueba que dependa
  de comparar instantes corre contra Postgres o no vale.**

---

## 5. Booleanos

| PostgreSQL | SQLite |
|---|---|
| Tipo `BOOLEAN` real: `true` / `false` | `INTEGER` con `0` / `1` |

SQLite acepta las palabras `TRUE` y `FALSE` desde la 3.23 como alias de `1` y
`0`, así que el DDL y las consultas suelen portar sin cambios. Lo que **no**
porta es lo que sale por el cable: Postgres devuelve un booleano, SQLite un
entero.

**Qué hacer.** Declarar el campo Go como `bool` y dejar que el driver convierta —
lo hacen los dos. El problema aparece solo si escaneas a `interface{}` o comparas
el valor crudo. No lo hagas.

---

## 6. Números, dinero y la afinidad de tipos

Y acá está la divergencia más **inquietante** de la lista, porque no falla: mira
para otro lado.

```sql
INSERT INTO packages (product_id, spins, package_price_cents) VALUES ('spins-10', 10, 99);
INSERT INTO packages (product_id, spins, package_price_cents) VALUES ('spins-x', 10, 'mucha plata');
```

- **Postgres:** `invalid input syntax for type bigint: "mucha plata"`. Rechaza.
- **SQLite:** **la acepta y guarda el texto** en una columna `INTEGER`.

Es la **afinidad de tipos**: en SQLite el tipo es una sugerencia sobre la columna,
no una restricción sobre el valor. Medido después con
`SELECT sum(package_price_cents), count(*) FROM packages`: Postgres `99 | 1`,
SQLite `99 | 2`. Dos paquetes en el catálogo, y la plata de uno no existe.

**Qué hacer.**

- Validar en el código, porque el motor de pruebas no te va a avisar.
- Dinero en `BIGINT` de centavos a los dos lados (`A10`, `be07`). Un `INTEGER` de
  32 bits, en centavos, se agota a los ~21,4 millones de dólares.
- Y saber que **las tablas `STRICT`** —que sí hacen cumplir los tipos— llegaron
  en SQLite **3.37**, después de la cota de `D18`. El curso no las usa.

### Y el texto: `LIKE`, mayúsculas y tildes

La búsqueda de jugadores manda `name_like`, que en el mock es una expresión
regular de JavaScript con la bandera `i`: `ángela` encuentra a `Ángela M.`.
Medido en `be02` con los dos motores:

| Consulta | SQLite | PostgreSQL |
|---|---|---|
| `name LIKE '%juan%'` | `Juan P.` | (sin filas) |
| `name LIKE '%ángela%'` | (sin filas) | (sin filas) |
| `lower(name) LIKE '%ángela%'` | (sin filas) | `Ángela M.` |
| `name ILIKE '%ángela%'` | no existe | `Ángela M.` |

El `LIKE` de SQLite ignora mayúsculas solo en ASCII y su `lower()` no toca las
tildes; el de Postgres distingue mayúsculas, e `ILIKE` no existe en SQLite.
**Qué hacer** cuando la regla tiene que ser igual en los dos: filtrar en Go, como
hace `be03` con `regexp` y `(?i)`, o aceptar que esa consulta es SQL del motor y
probarla solo contra Postgres.

---

## 7. Bloqueo: `FOR UPDATE` no existe

| PostgreSQL | SQLite |
|---|---|
| `SELECT … FOR UPDATE`, `FOR SHARE`, `SKIP LOCKED`, `NOWAIT` | **Nada de eso** |
| Bloqueo a nivel de **fila** | Bloqueo a nivel de **archivo** |

```
near "FOR": syntax error
```

No hay emulación posible y no hay que intentarla. SQLite no bloquea filas porque
no tiene concurrencia de escritura que administrar (§8): serializa la base
entera.

**Qué hacer.** Nada, salvo aceptarlo y sacar la conclusión: **la concurrencia no
se puede probar contra SQLite**. Ni siquiera mal. Es el remate de la pieza
forense de `be05` y una de las cuatro áreas de la regla del motor. El detalle
completo de `FOR UPDATE` y sus variantes está en `bea-05`.

---

## 8. Concurrencia de escritura y `SQLITE_BUSY`

SQLite admite **un escritor a la vez** sobre la base completa. Con el modo por
defecto (*rollback journal*), un escritor bloquea también a los lectores; con
`journal_mode=WAL` los lectores no se bloquean, pero el escritor único sigue
siendo único.

```
database is locked
```

**Qué hacer.**

- En pruebas, DSN con `_busy_timeout=5000`: el que llega segundo espera en vez de
  fallar al instante.
- `SetMaxOpenConns(1)` contra SQLite. Un pool de 25 conexiones contra un archivo
  no da paralelismo: da `SQLITE_BUSY`.
- Y otra vez la conclusión: veinte jugadores girando por la última Esclusa de
  Oro compiten en Postgres por **una fila**, y lo que pasa lo decide la
  transacción que escribas (`be05`); los mismos veinte contra SQLite compiten por
  **el archivo**, y el resultado depende del `busy_timeout`.

---

## 9. Claves foráneas apagadas por defecto

En SQLite, `PRAGMA foreign_keys` está **en `OFF`** por defecto, y es **por
conexión**, no por base. Las `REFERENCES` de tu DDL son decorativas hasta que
alguien las encienda.

**Cómo se ve cuando falla.** No falla: eso es lo malo. Insertas un segmento con
un `wheel_version_id` inexistente y SQLite lo acepta sin chistar (medido:
`PRAGMA foreign_keys` dice `0`, aunque la migración lo encienda, porque `migrate`
corrió en su propia conexión). La prueba pasa, el modelo está roto, y Postgres
responde `violates foreign key constraint "wheel_segments_wheel_version_id_fkey"`.

**Qué hacer.** Ponerlo en el DSN, siempre:

```
file::memory:?cache=shared&_foreign_keys=on&_busy_timeout=5000
```

Y un ejercicio que conviene hacer una vez: quítalo y cuenta cuántas de tus
pruebas siguen pasando. Ese número dice bastante sobre tu suite.

---

## 10. DDL: `ALTER TABLE` y qué obliga a decidir

| Operación | PostgreSQL | SQLite |
|---|---|---|
| `ADD COLUMN` | Sí | Sí, con restricciones |
| `RENAME COLUMN` | Sí | Desde 3.25 |
| `DROP COLUMN` | Sí | Desde 3.35, y no siempre |
| `ALTER COLUMN … TYPE` | Sí | **No** |
| Restricción añadida a posteriori | Sí | **No** |

En SQLite, lo que no se puede alterar se resuelve con el baile clásico: crear
tabla nueva, copiar, borrar la vieja, renombrar. Es tedioso y es lo que hay.

**La decisión que esto obliga a tomar**, y que `D25` cerró en `be02`:

> 🧭 **DDL por dialecto, no subconjunto común.** El mínimo común denominador de
> Postgres 13 y SQLite 3.35 no tiene `TIMESTAMPTZ`, ni `BIGSERIAL`, ni
> `ALTER COLUMN`, ni tipos que se hagan cumplir. Escribir el esquema ahí
> significa **degradar el motor real para complacer al motor de pruebas**.

El costo —que los dos juegos de migraciones diverjan— se administra con la regla
del motor y con las pruebas que corren contra los dos, no con buenas intenciones.
Pero se paga **a la vista**, que es la diferencia con esconderlo.

---

## 11. Lo que sí porta

La lista corta, para que no escribas código feo por miedo:

- **Índices parciales** (`CREATE INDEX … WHERE`). SQLite los tiene desde la
  **3.8.0, de 2013**. El índice de reservas vencidas de `be05` porta tal cual.
- **`CHECK`**, incluidas las enumeraciones por `IN (…)`.
- **`UNIQUE`** compuesto, que es la última línea de defensa de `be05`.
- **`ON CONFLICT DO NOTHING` / `DO UPDATE`.** SQLite lo tiene desde la 3.24, con
  sintaxis compatible para los casos del track.
- **Transacciones, `BEGIN`/`COMMIT`/`ROLLBACK` y savepoints.**
- **Índices por expresión**, subconsultas, CTEs y funciones de ventana.
- **`RIGHT`/`FULL OUTER JOIN`**… ojo, **este depende**: llegó a SQLite en la
  3.39. El que trae `mattn/go-sqlite3` v1.14.16 es la 3.39.4, así que en tu
  máquina funciona; `D18` promete 3.35, y en una 3.35 no. Ese es el tipo de
  detalle que hay que verificar y no suponer.

📖 **La moraleja de esta sección.** El inventario de divergencias se hace
**midiendo**, no de memoria ni de un blog. La mitad de lo que "todo el mundo
sabe" que no porta, porta desde hace diez años.

---

## 🧩 Cuándo usar qué: la regla del motor

> 🧭 **SQLite vale para pruebas que no tocan concurrencia, bloqueos, zonas
> horarias ni SQL específico del motor. En cuanto una prueba toca cualquiera de
> las cuatro, corre contra PostgreSQL o no vale.**

| Lo que hace la prueba | ¿SQLite? | Por qué |
|---|---|---|
| Aritmética, transiciones, lógica pura | Ni la necesita | Ni siquiera toca la base |
| Mapear un struct a una fila y volver | ✅ | Nada específico del motor |
| Verificar un `UNIQUE` o un `CHECK` | ✅ | Los dos los hacen cumplir |
| Comparar instantes o rangos de fechas | ❌ §4 | SQLite compara cadenas |
| Cualquier cosa con `FOR UPDATE` | ❌ §7 | No existe |
| Dos escritores a la vez | ❌ §8 | Serializa la base entera |
| `RETURNING`, `setval`, tipos del motor | ❌ §3, §2 | Dialecto puro |
| Que un tipo inválido se rechace | ❌ §6 | SQLite lo acepta |

Y el argumento que sostiene la regla, que es de `be08` y conviene repetir:

> 🧠 **Una suite verde contra el motor equivocado es peor que no tener suite.** No
> tener suite te deja desconfiado y prudente. Una suite verde te da **permiso para
> desplegar**, y ese permiso es exactamente lo que no tenías derecho a recibir.
>
> Por eso el *helper* de `be08` **falla** en vez de saltar: `t.Skip` es la forma
> en que una suite miente.

---

## 🧪 Ejercicios (8)

1. **🟢** Comprueba tu versión de SQLite con `select sqlite_version();` y verifica que cumple la cota de `D18`. Explica qué llegó en la 3.35.
2. **🟢** Ejecuta los dos `INSERT` del §6 en los dos motores y compara. Después corre `SELECT sum(package_price_cents), count(*) FROM packages` en cada uno.
3. **🟡** Reproduce el §4 completo con los dos motores y pega las dos salidas. Es la Divergencia 2 y la Prueba B de `be08`.
4. **🟡 Diagnóstico.** Sustituye `RETURNING` por `LastInsertId` y corre la suite contra los dos motores. Explica por qué el resultado es peligroso y no solo molesto.
5. **🟠 Diagnóstico.** Quita `_foreign_keys=on` del DSN de pruebas, inserta un segmento huérfano, y determina cuántas de tus pruebas siguen pasando.
6. **🟠** Siembra con ids explícitos, omite el `setval`, y crea una rueda desde la consola. Lee el error de Postgres en el log y explica de dónde salió el id que chocó.
7. **🟠** Verifica **midiendo** tres entradas de la §11: crea un índice parcial, un `CHECK` con `IN` y un `ON CONFLICT DO NOTHING` en los dos motores. Si alguna no porta, corrige este apéndice.
8. **🔴 Diagnóstico.** Encuentra una divergencia que **no** esté en este apéndice, con evidencia medida, clasifícala en una de las cuatro áreas de la regla del motor, y decide si obliga a cambiar algo del backend.

---

## 📚 Referencias

**Documentación oficial**
- https://www.sqlite.org/quirks.html — SQLite enumerando honestamente en qué se aparta de todos los demás. Es la mejor fuente de este apéndice y se lee en veinte minutos.
- https://www.sqlite.org/datatype3.html — la afinidad de tipos del §6, explicada por sus autores.
- https://www.sqlite.org/lang_returning.html — `RETURNING` con su nota de versión.
- https://www.sqlite.org/partialindex.html — índices parciales desde la 3.8.0, el §11.
- https://www.sqlite.org/foreignkeys.html#fk_enable — el pragma del §9.
- https://www.sqlite.org/lockingv3.html y https://www.sqlite.org/rescode.html#busy — el §8.
- https://www.sqlite.org/stricttables.html — las tablas `STRICT` de la 3.37, que no alcanzamos.
- https://www.postgresql.org/docs/13/datatype-datetime.html — el §4 desde el otro lado.
- https://wiki.postgresql.org/wiki/Don%27t_Do_This — cinco líneas por tema y sin diplomacia.
- https://jmoiron.github.io/sqlx/ — `Rebind` y el mapeo a structs.

**Libros**
- *SQL Performance Explained* (Markus Winand) — no trata de portabilidad, pero su tratamiento de índices vale para los dos motores. Su sitio `use-the-index-luke.com` es la versión libre.

**Orden de lectura sugerido:** `quirks.html` completo primero —es la fuente de la
mitad de este apéndice— → `datatype3.html` para entender el §6 → y volver a este
índice por saltos, cuando algo falle.

> ⚠️ URLs, títulos y ediciones pueden haber cambiado: verifícalos. Las notas de
> versión de SQLite son especialmente importantes acá: **una función que hoy
> existe puede no existir en la 3.35**, que es la cota del track. Comprueba
> siempre contra tu versión antes de asumir. La fuente de verdad de versiones es
> `00-decisiones-y-versiones.md` §7.

---

> 🏷️ **Este apéndice no lleva tag.** Es de consulta pura. La evidencia que
> generes al recorrerlo va en `server/evidence/divergencias.md`, que sí es
> entregable de `be02` y se versiona con esa fase.
