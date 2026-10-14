PAIRS = [
("""- **a01, a02, a05 y a06 están bloqueados por P8**, la verificación de laboratorio.
- **El nombre del driver de MySQL para Python** se decide en P8, entre el conector oficial y PyMySQL,
  por su comportamiento con transacciones y con `LOAD DATA`.
- **El texto exacto de la cláusula de las licencias** se cita en `a09` desde la licencia vigente, no
  de memoria.""",
"""- ✅ **P8 hecha el 11/10/2026**: a01, a02, a05 y a06 ya no están bloqueados. Lo verificado, en
  `prompts/verificacion-de-laboratorio/hallazgos.md`.
- ✅ **El driver de MySQL para Python es PyMySQL** (D22): igual al conector oficial con transacciones
  y con `LOAD DATA`; gana por ser Python puro, MIT e independiente de Oracle.
- ✅ **El texto de las cláusulas** está citado en `hallazgos.md` (§F2), con enlace y fecha, desde la
  licencia vigente. `a09` lo vuelve a comprobar el día que se escribe.
- **SQLcl** no viene en ninguna imagen de Oracle: `a03` decide en T1 si usa la imagen de SQLcl o
  `sqlplus`, que sí viene."""),
("""los tres motores, calibrado en P8)""", """los tres motores, calibrado en P8: M tiene unos 250.000 pacientes y 17 M de resultados)"""),
]
