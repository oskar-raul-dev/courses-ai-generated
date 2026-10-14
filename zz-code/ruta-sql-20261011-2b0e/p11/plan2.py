PAIRS = [
("""Los versiones y los digests no se copiaron""", """Las versiones y los digests no se copiaron"""),
("""**2026-10-07 · Plan al formato de los lineamientos.**""",
"""**2026-10-11 · P8, P9 y P11: la preparación, cerrada.** Pedido de Oskar: *"hagamos un cierre de
P1-P12 para comenzar con las tandas"*. **P8:** las versiones según D12 (Postgres 18.6, MySQL **9.7.2
LTS** en lugar de la 8.4 que nombraba el alcance, Oracle AI Database 26ai Free 23.26.3, PostgREST
v16.4, Apache Artemis 2.57.0, SQL Server 2025 CU9) y sus digests; arranque y RAM de cada servicio;
**Oracle Free nativo en arm64**; el laboratorio entero, con M cargado y todos los perfiles arriba, en
unos 5,3 GiB de pico, dentro de la VM de 8 GB que Docker Desktop da a un Mac de 16 GB; los cuatro
drivers de Python; las funciones de Postgres 18 (todas, menos `pg_hint_plan`); y el prototipo del
generador, determinista y con las proporciones de la historia (M: 252.000 pacientes y 16,8 M de
resultados, cargado en Postgres en 16 s y en MySQL en 51 s). **P9:** las ediciones de los seis libros
y el texto de las dos licencias. **P11:** el traslado a todo `prompts/` (detalle en §5). **Decisiones
de Oskar:** D19 (Java 25 LTS en lugar de 21), D20 (la regla de Oracle se mantiene aunque Oracle Free no
lleve la cláusula DeWitt), D21 (imagen de gvenzl `slim-faststart`), D22 (PyMySQL); por defecto, a
revisar: el track exige Docker Desktop en Apple Silicon, y `pg_hint_plan` queda como ejercicio 🔥.
**Corregido:** el verificador contaba `00-convencion-de-git-y-tags.md` (agregado el 07/10) como F00 y
daba un error de ejercicios; ahora lo excluye, como el de la Lite. **Comprobado:** `verificar-corpus.py`
0 errores en los dos modos, con un aviso. **Trampas para la próxima sesión:** (1) ese aviso es el
callout `🔑` de `00-convencion-de-git-y-tags.md`, que la guía no define; el archivo lo generó la sesión
de convenciones de git (`zz-code/convenciones-git-20261007-7514/generar.py`), así que se arregla allí o
se agrega `🔑` a la guía, y lo decide Oskar; (2) `docker compose rm -sf` deja los volúmenes anónimos
de la imagen (los de `mongo` y `artemis`): usar `down -v` o `rm -sfv`; (3) para MySQL, `LIKE '%Ñ%'`
encuentra las N (§H6 de los hallazgos); (4) la semilla del prototipo es `1979`, sin significado
narrativo, y `a05` puede cambiarla antes de publicar cualquier número. **Recursos levantados:**
ninguno; contenedores, volúmenes y redes iguales al inventario inicial, y la máquina de Podman creada
para la prueba (con permiso de Oskar), borrada. Quedan las nueve imágenes elegidas, para T1.
**`zz-code/`:** `ruta-sql-20261011-2b0e/` (vigente hasta T1). **Tags para el autor:** ninguno.
**Siguiente:** T0.

**2026-10-07 · Plan al formato de los lineamientos.**"""),
]
