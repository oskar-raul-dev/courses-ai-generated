# ruta-sql-20261006-fc2f

- **Curso:** ruta-sql
- **Tanda:** revisión contra `zz-instrucciones/` (06/10/2026); el código es de la sesión de diseño del 29/09/2026
- **Creado:** 2026-10-06
- **Propósito:** PoC del `.accdb` de museo (Jackcess, UCanAccess y el `.bas` de Rubén en LibreOffice Basic), mudado desde `cursos-bd/ruta-sql/taller/accdb-museo/` porque es código de prueba y no material del curso. Lo extrae `a10-el-access-de-museo.md` en la tanda T14, a `src/a10-el-access-de-museo/`, y lo vuelve a ejecutar allí.
- **Estado:** extraído (18/10/2026, T14)
- **Cómo regenerar lo que limpiar.py borra:** `cd accdb-museo && mvn -q dependency:copy-dependencies -DoutputDirectory=lib` para los `.jar`; `out/` se rehace corriendo los comandos de §4 del README.

## Qué hay

- `accdb-museo/` — el PoC tal como estaba en `taller/`, sin editar: `AccdbTool.java`, `QueryAccdb.java`, `ModParser.bas`, `TestParser.bas`, `parse_patients.py`, `run_bas_tests.py`, `pom.xml` y su `README.md` original (que es la referencia de corrida).
- `accdb-museo/lib/` — los once `.jar` que baja `pom.xml` (11 MB; estaban versionados en `taller/`).
- `accdb-museo/out/` — los `.accdb`, los CSV y `bas_tests.txt` de la última corrida, del 29/09/2026 (ignorado por git).
- `historia-alineada.py` — los reemplazos que alinearon `00-historia-de-alameda.md` con la plantilla de historia el 06/10/2026 (encabezado, emojis, sin citas a `prompts/` ni a otros cursos, la §9 reescrita). Ya aplicado: volver a correrlo falla en la primera aserción.

## Qué sirvió

**Extraído el 18/10/2026 (T14)** a `cursos-bd/ruta-sql/src/a10-el-access-de-museo/`: los siete archivos de código y el
`README.md` de `accdb-museo/`, copiados sin editar y sin `lib/` ni `out/` (se regeneran). En el curso se agregó
`Dockerfile.libreoffice`, porque esta prueba usó el LibreOffice de la máquina. Todo se volvió a ejecutar en contenedores
(`zz-code/ruta-sql-20261018-527b/a10/`): los dos CSV salieron idénticos byte a byte a los de `accdb-museo/out/`, y las
pruebas del `.bas`, 40, 31 y 39 de 40 (la última con la ventana desde 1950 explícita; la "por defecto" de LibreOffice 25.2.3
es 1930 y da 40). Lo publica `a10-el-access-de-museo.md`, con M-77. `historia-alineada.py` no se llevó: ya estaba aplicado.
Este directorio queda como registro; `lib/` y `out/` los puede borrar `limpiar.py`.
