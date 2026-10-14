PAIRS = [
("""> ⚠️ **Antes de F01.** Tienen que estar escritos y verificados `a01`, `a02`, `a05` y `a06`, y hecha
> la verificación de laboratorio (P8). Sin digests fijados, ninguna fase publica una versión.""",
"""> ⚠️ **Antes de F01.** Tienen que estar escritos y verificados `a01`, `a02`, `a05` y `a06`. La
> verificación de laboratorio (P8) está hecha desde el 11/10/2026, en
> [`verificacion-de-laboratorio/hallazgos.md`](verificacion-de-laboratorio/hallazgos.md); sin
> digests fijados en `a02`, ninguna fase publica una versión."""),
("""- **`WITHOUT OVERLAPS` y las claves foráneas con período** solo se usan si la versión del curso las
  trae y se ejecutaron. Si no, la restricción de exclusión con `gist` es el camino, y se dice.""",
"""- **`WITHOUT OVERLAPS` y las claves foráneas con período** existen en la versión del curso
  (`hallazgos.md` §H10). Se usan después de ejecutarlos en la sesión, y la restricción de exclusión
  con `gist` va primero, como el mecanismo que hay debajo."""),
("""- **`uuidv7()`** solo si la versión del curso lo trae y se ejecutó.""",
 """- **`uuidv7()`** existe en la versión del curso (`hallazgos.md` §H10); se usa después de ejecutarlo."""),
("""- **El *skip scan*** solo si la versión lo trae y se ejecutó.""",
 """- **El *skip scan*** existe en la versión del curso: se reconoce por `Index Searches` en el `EXPLAIN
  ANALYZE` (`hallazgos.md` §H10)."""),
("""- **`pg_hint_plan`** solo si está disponible en la imagen del curso; si no, la fase lo nombra y
  explica por qué Postgres no trae hints de serie.""",
"""- **`pg_hint_plan`** no viene en la imagen del curso (`hallazgos.md` §H10): la fase explica por qué
  Postgres no trae hints de serie y deja `pg_hint_plan` como ejercicio 🔥, con una imagen derivada
  que instala `postgresql-18-pg-hint-plan` de PGDG. El `compose.yaml` no cambia."""),
("""Perfiles `api` (PostgREST) y `puente` (Artemis y Java 21) del compose
verificados.""", """Perfiles `api` (PostgREST) y `puente` (Apache Artemis y Java 25) del compose
verificados; P8 dejó los arreglos de los dos en `hallazgos.md` §H8 y §H9."""),
("""en **Java 21** con ActiveMQ
  Artemis (D3, D11).""", """en **Java 25** con Apache
  Artemis (D3, D11, D19)."""),
]
