# ruta-sql-20261014-d471

- **Curso:** ruta-sql
- **Tanda:** T9 a T11 (F19 a F23, el boss IV, el boss V y el boss del puente), 14/10/2026
- **Creado:** 2026-10-14
- **Propósito:** ejecutar lo que publican F19–F23, generar la caja M con la verdad de antibiogramas (D46) y guardar las soluciones de tres boss, que no se publican (D42)
- **Estado:** archivado (18/10/2026, T16): lo publicable está en el curso; quedan la caja t9 y las soluciones de boss como registro
- **Cómo regenerar lo que limpiar.py borra:** `salidas/caja-t9/` con `uv run lab generate --profile m` desde `cursos-bd/ruta-sql/src/` (semilla 1996; los hashes, en el `MANIFIESTO.json` de la caja); `puente/lib/` y `puente/m2/` con `mvn -q dependency:copy-dependencies -DoutputDirectory=lib` en la imagen de Maven de `a02`, desde `src/23-la-base-como-producto/puente/`

## Qué hay

- `cargar-verdad.py` — carga solo el esquema `truth` desde la caja nueva, sin tocar `legacy` ni los modelos (T9).
- `boss4/` — la solución del boss IV (`solucion.py`) y `reiniciar-estado.sh`, que rehace `staging.f20_*` antes de cada corrida del arnés.
- `boss5/` — la solución del boss V (`01_setup.sql`, `flujo.py`).
- `puente-solucion/` — la solución del boss del puente (`01_setup.sql`, `Puente.java`).
- `puente/` — `lib/` (las dependencias de Java 25) y `m2/` (la caché de Maven), regenerables.
- `salidas/caja-t9/` — la caja M regenerada con `truth/antibiogram.csv` (2,1 GB): los 439 archivos anteriores con el mismo hash que el manifiesto publicado, más el nuevo.
- `salidas/f19-*` a `salidas/f23-*` — las salidas de cada medición y de los ejercicios de F19 a F23, y las de los tres boss (punto de partida y solución).

## Qué sirvió

`src/lab/generator/antibiogramas.py` y el flujo de la verdad de antibiogramas (D46), `src/19-…` a `src/23-…` con sus boss, los perfiles `api` y `puente` del compose; las mediciones M-35 a M-51, los errores E-54 a E-68 e INSTINTOS 19 a 26. Las soluciones de los boss se quedan aquí, a propósito.
