PAIRS = [
("""> **Fecha:** 30/09/2026.""", """> **Fecha:** 30/09/2026, con lo verificado en P8 y P9 trasladado el 11/10/2026."""),
("""qué
  imagen del curso corre nativa en arm64 y cuál no (SQL Server seguro no; Oracle Free, a verificar);""",
 """qué
  imagen del curso corre nativa en arm64 y cuál no (todas nativas salvo SQL Server, que corre con
  Rosetta en Docker Desktop y **no arranca en Podman**; verificado el 11/10/2026);"""),
("""- **Depende de:** la verificación de laboratorio (P8). Hereda la estructura del `a01` de la Lite.""",
 """- **Depende de:** la verificación de laboratorio (P8, hecha el 11/10/2026: `prompts/verificacion-de-laboratorio/hallazgos.md`,
  §H3 y §H4). Hereda la estructura del `a01` de la Lite."""),
("""- **Bloqueado por:** P8. Sin digests medidos no se escribe.""",
 """- **Depende de:** P8, hecha el 11/10/2026. Los digests, los tiempos de arranque y la tabla de RAM
  medidos están en `hallazgos.md`; `a02` los vuelve a resolver el día que se escribe y anota la
  diferencia."""),
("""(psycopg 3 para
  Postgres; el de MySQL y `python-oracledb` en modo *thin*, que no necesita Instant Client, a
  verificar en P8);""",
 """(psycopg 3 para
  Postgres; **PyMySQL** para MySQL (D22); y `python-oracledb` en modo *thin*, que no necesita Instant
  Client, verificado el 11/10/2026);"""),
("""(D11): Java 21, Maven y ejecutar""", """(D11, D19): Java 25, Maven y ejecutar"""),
("""- **Alcance:** **la cláusula DeWitt** en las licencias de Oracle Database y SQL Server, citada del
  texto de la licencia vigente, y cómo la aplica el curso (guía §6.1);""",
 """- **Alcance:** **la cláusula DeWitt** en las licencias de Oracle Database y SQL Server, citada del
  texto de la licencia vigente, y cómo la aplica el curso (guía §6.1). **Con un matiz que P9
  encontró**: la licencia de SQL Server 2025 Developer la trae (§5, "BENCHMARK TESTING"), pero Oracle
  AI Database Free se licencia con los *Free Use Terms*, que no la tienen; el curso igual no publica
  números de Oracle (D20) y explica por qué. Los *Free Use Terms* sí limitan el uso para dar
  formación a terceros, y `a09` lo trata como riesgo declarado;"""),
]
