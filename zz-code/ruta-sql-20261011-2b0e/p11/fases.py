PAIRS = [
("""`WITHOUT OVERLAPS` y claves foráneas con período, si la versión del curso las trae
  (se verifica);""",
 """`WITHOUT OVERLAPS` y claves foráneas con período (`PERIOD`), que Postgres 18 trae (verificado el
  11/10/2026);"""),
("""(`uuidv7()` nativo en Postgres 18, a verificar)""", """(`uuidv7()` nativo en Postgres 18, verificado)"""),
("""*skip scan*, si la
  versión lo trae;""", """*skip scan*, que
  Postgres 18 trae (verificado: `Index Searches` en el `EXPLAIN ANALYZE`);"""),
("""hints (los de MySQL, `pg_hint_plan` si está disponible, los de Oracle)""",
 """hints (los de MySQL, los de Oracle, y `pg_hint_plan`, que no viene en la imagen del curso y queda
  como ejercicio 🔥 con una imagen derivada)"""),
("""con Java
  21, ActiveMQ Artemis y mensajes""", """con Java
  25, Apache Artemis y mensajes"""),
("""Laboratorio en contenedor Linux, con emulación en Apple Silicon (declarada).""",
 """Laboratorio en contenedor Linux, con emulación en Apple Silicon (declarada), que solo funciona en
Docker Desktop: en Podman no arranca (verificado el 11/10/2026)."""),
("""el tipo `json` nativo de SQL Server 2025 (a verificar) |""", """el tipo `json` nativo de SQL Server 2025 (verificado) |"""),
("""M ≈ 200.000 pacientes y 15 M de resultados, y siempre dentro de 16 GB con los tres motores | ✅ |""",
 """M ≈ 250.000 pacientes y 17 M de resultados (calibrado el 11/10/2026), y siempre dentro de 16 GB con los tres motores | ✅ |"""),
("""| D11 | Java | Java 21 LTS, solo en el boss del puente y en `a10` | ✅ | `a06` |""",
 """| D11 | Java | Java LTS, solo en el boss del puente y en `a10` (la versión, en D19) | ✅ | `a06` |"""),
("""los boss no publican su solución | ✅ 06/10/2026 | guía §10.3 |
""",
"""los boss no publican su solución | ✅ 06/10/2026 | guía §10.3 |
| D19 | Versión de Java | **Java 25 LTS**, la última LTS a la fecha de la verificación (D12), en lugar de la 21 | ✅ 11/10/2026 | alcance §9, `a06` |
| D20 | Números de Oracle | **Se mantiene: ninguno se publica**, aunque los *Free Use Terms* de Oracle Free no lleven la cláusula DeWitt; `a09` cita los dos textos | ✅ 11/10/2026 | alcance §6.1, `a09` |
| D21 | Imagen de Oracle | `gvenzl/oracle-free` en su variante `slim-faststart`: la mitad de disco que la oficial y el usuario de la aplicación por variable | ✅ 11/10/2026 | `a02` |
| D22 | Driver de MySQL para Python | **PyMySQL**: igual al oficial en transacciones y `LOAD DATA`, Python puro, MIT y sin dependencia de Oracle | ✅ 11/10/2026 | `a06` |
"""),
]
