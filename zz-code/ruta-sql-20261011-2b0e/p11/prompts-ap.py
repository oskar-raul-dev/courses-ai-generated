PAIRS = [
("""> ⚠️ **El orden importa.** `a01`, `a02`, `a05` y `a06` se escriben **antes de F01**, y los cuatro
> dependen de la verificación de laboratorio (P8).""",
"""> ⚠️ **El orden importa.** `a01`, `a02`, `a05` y `a06` se escriben **antes de F01**, y los cuatro
> dependen de la verificación de laboratorio (P8, hecha el 11/10/2026: lee
> [`verificacion-de-laboratorio/hallazgos.md`](verificacion-de-laboratorio/hallazgos.md) antes de
> empezar)."""),
("""- **La tabla de emulación es lo nuevo** respecto de la Lite: qué corre nativo en arm64 y qué no,
  medido en P8. Si P8 no está hecha, para y dímelo.
- **Oracle y la memoria.** El límite por servicio decide si los tres motores entran a la vez en
  16 GB; el número sale de P8.""",
"""- **La tabla de emulación es lo nuevo** respecto de la Lite: qué corre nativo en arm64 y qué no,
  medido en P8 (`hallazgos.md` §H3 y §H4). Todo es nativo salvo SQL Server, que solo arranca en
  Docker Desktop.
- **Oracle y la memoria.** El límite por servicio decide si los tres motores entran a la vez en
  16 GB; P8 midió que entran con margen (tabla de RAM de `hallazgos.md`), y con dos Oracle a la vez
  la VM se llena: es el ejercicio de abajo."""),
("""- **Bloqueado por P8.** Los digests y la tabla de RAM salen de ejecutar.""",
 """- **Parte de P8** (`hallazgos.md`): digests, tiempos de arranque, tabla de RAM y los arreglos de
  §H5 (MySQL), §H8 (PostgREST) y §H9 (Artemis). Vuelve a resolver los digests el día de la sesión y
  anota lo que cambió. `wal_level=logical` y `pg_stat_statements` van en el `command` de `postgres`
  (§H10)."""),
("""- **Los perfiles S, M y L** se calibran en P8 y aquí se fijan (D4).""",
 """- **Los perfiles S, M y L** se calibraron en P8 con un prototipo (`hallazgos.md` §H12: M, unos
  250.000 pacientes y 17 M de resultados) y aquí se fijan (D4). Las proporciones que la historia no
  fija se confirman en el paso 1."""),
("""- **El driver de MySQL** se elige en P8 (propuesta de apéndices §14): documenta la elección y su
  porqué.
- **Java es mínimo**: Java 21, lo justo""",
"""- **El driver de MySQL es PyMySQL** (D22, `hallazgos.md` §H11): documenta la elección y su porqué.
- **Java es mínimo**: Java 25 (D19), lo justo"""),
]
