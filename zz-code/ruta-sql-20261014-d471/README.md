# 🧪 ruta-sql-20261014-d471 · cómo correr estas pruebas

> **Curso:** ruta-sql · **Tanda:** T9 a T11 (F19 a F23 y sus tres boss) · **Creado:** 2026-10-14
> **Propósito:** ejecutar lo que publican F19–F23, generar la caja M con la verdad de antibiogramas (D46) y
> guardar las soluciones de los boss IV, V y del puente, que no se publican (D42).
> Este README se completó al cerrar el curso (T16, 18/10/2026) desde el registro del plan de producción: en
> T9–T11 la sesión dejó las salidas en `salidas/` y este archivo sin llenar.

## 1. 🎯 Qué se prueba y para qué

- `salidas/caja-t9/` → D46: la caja M regenerada con `truth/antibiogram.csv` (469.863 filas, 60.001 cultivos). Alimenta F19 y el
  boss IV; desde T9, Postgres la monta con `LAB_CAJA`.
- `cargar-verdad.py` → carga solo `truth` de esa caja, sin tocar `legacy` ni los modelos.
- `salidas/f19-*` → M-35 a M-37: la búsqueda por un resultado en forma larga, documento y los dos GIN; el WAL por forma; MySQL.
- `salidas/f20-*` → M-38: las cinco operaciones en los tres diseños (relacional, `jsonb`, MongoDB 8.0.20).
- `salidas/f21-*` → M-39 a M-41: nombres, recursión, vectores y el boss IV (punto de partida y solución, `boss4/`).
- `salidas/f22-*` → M-42 a M-46: marca de agua, `lab race`, colas, outbox y CDC con `test_decoding`.
- `salidas/f23-*` → M-47 a M-51: RLS, la API, el MD5 del portal, el boss V (`boss5/`) y el boss del puente (`puente-solucion/`).

## 2. 🛠️ Prerrequisitos

El laboratorio `alameda-lab` con Docker Desktop, la caja de `salidas/caja-t9` montada (`LAB_CAJA`), el modelo de `uv run lab load
--profile m --model`, y los perfiles `mongo` (F20), `api` (F23) y `puente` (boss del puente). Python con `uv` desde
`cursos-bd/ruta-sql/src/`; Java 25 y Maven en las imágenes fijadas en `a02` y `a06`.

## 3. 🧭 Reglas antes de correr

No se tomó inventario de Docker en esta sesión: todo lo que creó lleva la etiqueta `curso=ruta-sql` (los servicios del compose y
los contenedores `--rm` de uv y de Java). Los cambios en la base son tablas de `staging`, la tabla `alameda.referral` y la seguridad
por fila de F23 (que `lab load --model` borra y `src/23-…/01_setup.sql` rehace), y los slots de F22, que cada prueba borra al
terminar.

## 4. ▶️ Cómo se corre

Desde `cursos-bd/ruta-sql/src/`, con `LAB_CAJA` apuntando a `salidas/caja-t9`:

```bash
uv run lab generate --profile m            # si salidas/caja-t9 no existe: genera la caja en lab/caja/
uv run python -I ../../../zz-code/ruta-sql-20261014-d471/cargar-verdad.py
# F19–F23: los scripts de cada src/NN-…/ en el orden de su prefijo, como dice cada lección
sh ../../../zz-code/ruta-sql-20261014-d471/boss4/reiniciar-estado.sh
uv run python 21-hasta-donde-llega-el-motor/boss/arnes.py ../../../zz-code/ruta-sql-20261014-d471/boss4/solucion.py
uv run python 23-la-base-como-producto/boss/arnes.py ../../../zz-code/ruta-sql-20261014-d471/boss5
PUENTE_LIB=../../../zz-code/ruta-sql-20261014-d471/puente/lib \
  uv run python 23-la-base-como-producto/puente/arnes.py ../../../zz-code/ruta-sql-20261014-d471/puente-solucion
```

## 5. 📏 Cómo se mide

En la máquina de referencia de la bitácora (Apple M1 Pro, VM de 7,75 GiB), con el perfil M. Postgres con `EXPLAIN (ANALYZE,
BUFFERS)` y `lab measure`; el WAL tras un `CHECKPOINT` y con corridas de calentamiento descartadas (F19); F20 con cinco
repeticiones tras un calentamiento y la mediana; F22 con diez corridas por variante, contra `truth.result_value`; el boss del
puente con la medida de 6.651 mensajes y cuatro consumidores. Las corridas que se rehicieron y por qué están en la bitácora del plan
de producción (T9, T10 y T11): la granularidad al minuto de la caja (F22), el *pacing* de los escritores y la sesión
transaccional de Artemis.

## 6. 🧮 Los intermedios que amasan la salida

Las cifras publicadas salen directo de las salidas de cada script: conteos y bloques de `EXPLAIN`, medianas que calculan los
propios scripts (`statistics.median`), y los conteos contra `truth` que hacen las consultas de verificación. No hay pasos a mano.

## 7. ✅ Qué se espera ver

Las cifras de M-35 a M-51 en `bitacora-de-medicion.md` del curso, verificadas el 14/10/2026. Los boss: el IV pasa 5 de 5 con la
solución (2 de 5 en el punto de partida); el V, 5 de 5 (0 de 5); el del puente, 5 de 5 (1 de 5).

## 8. 📂 Salidas

`salidas/f19-*` a `salidas/f23-*`, una por prueba, y `salidas/caja-t9/` con su `MANIFIESTO.json`. Se regeneran corriendo cada
prueba. Al curso se copió lo publicable: las cifras, a las lecciones y a la bitácora.

## 9. 🧹 Limpieza

Los contenedores y volúmenes del curso se borran por la etiqueta `curso=ruta-sql` o con `uv run lab down -v` (T16). `salidas/` y
`puente/` los libera `zz-code/limpiar.py`.

## 10. 🚫 Qué se dejó fuera

Nada de esta sesión se versiona fuera de los scripts: la caja (2,1 GB) se regenera desde la semilla, y `puente/lib/` y `puente/m2/`
(43 MB) con Maven en contenedor.
