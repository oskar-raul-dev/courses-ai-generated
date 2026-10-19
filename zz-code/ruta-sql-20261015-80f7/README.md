# 🧪 ruta-sql-20261015-80f7 · cómo correr estas pruebas

> **Curso:** ruta-sql · **Tanda:** T12 (Bloque VI: F24, F25, F26 y el 🏆 boss global "Un martes") · **Creado:** 2026-10-15
> **Propósito:** ejecutar todo lo que publican F24–F26 y la solución del boss global (que no se publica, D42).

## 1. 🎯 Qué se prueba y para qué

- `explora/` → consultas de exploración antes de escribir (semanas, convenios, coseguros, tablas anchas, colisión, SIH, paneles, rangos de precios). Alimentaron el diseño de F25 y del boss.
- `src/24-el-diseno/` (en el curso) → el inventario y los ejercicios 1–3 de F24 (`salidas/f24-*.txt`).
- `src/25-la-migracion-sin-parar/` → M-52 a M-56: las anchas, la cantidad, la convivencia por CDC (incluida la corrida con la colisión, `f25-05_convivencia-colision.txt`), el SIH, el corte y los ejercicios 1–16.
- `src/26-el-comite/01_factura.py` → la factura de licencias (`f26-01_factura.txt`), con las fuentes en `salidas/fuentes/` (lista de precios de Oracle del 15/09/2026 y tabla de factores de núcleo).
- `martes-solucion/` → la solución del boss global (`01_setup.sql` y `flujo.py`): 5 de 5 (M-57).

## 2. 🛠️ Prerrequisitos

El laboratorio de la ruta arriba (`alameda-lab`, perfil M, con la caja de `zz-code/ruta-sql-20261014-d471/salidas/caja-t9` montada), el modelo de `lab load --model` y las Fases 21, 23 corridas. Docker Desktop. Python con `uv` dentro de un contenedor (`correr-src.sh`), nada instalado en la máquina.

## 3. 🧭 Reglas antes de correr

No se tomó inventario de Docker al empezar: esta sesión no crea contenedores persistentes, volúmenes ni redes. Los contenedores de `uv` son `--rm` con la etiqueta `curso=ruta-sql`; la caché y el entorno de `uv` viven en `salidas/uv-cache` y `salidas/uv-venv`. Los cambios temporales en la base son roles (`access_frontend`, `facturacion`), el slot `f25_legacy` (se borra al terminar cada prueba) y las tablas de `staging`, `sih` y `alameda.presentation*`.

## 4. ▶️ Cómo se corre

Desde este directorio:

```bash
./psql.sh < ../../cursos-bd/ruta-sql/src/25-la-migracion-sin-parar/01_anchas.sql       # y 02, 03, 06 igual
./psql.sh < ../../cursos-bd/ruta-sql/src/25-la-migracion-sin-parar/04_cdc_setup.sql
./correr-src.sh 25-la-migracion-sin-parar/05_convivencia.py 60 1992
./psql.sh < ../../cursos-bd/ruta-sql/src/25-la-migracion-sin-parar/09_ejercicios.sql    # justo después de 05
./psql.sh < ../../cursos-bd/ruta-sql/src/25-la-migracion-sin-parar/04_cdc_setup.sql
./correr-src.sh 25-la-migracion-sin-parar/07_corte.py 20 [--romper]
./psql.sh -c "select pg_drop_replication_slot('f25_legacy')"
python3 ../../cursos-bd/ruta-sql/src/26-el-comite/01_factura.py [núcleos] [servidores]
./correr-src.sh 26-el-comite/martes/arnes.py                      # punto de partida: 0 de 5
./correr-src.sh 26-el-comite/martes/arnes.py /sesion/martes-solucion   # solución: 5 de 5
```

`08_deshacer.sql` deja el modelo como antes de F25 (salvo la cantidad), y tarda unos dos minutos.

## 5. 📏 Cómo se mide

Apple M1 Pro, Docker Desktop con 7,75 GiB, Postgres 18.6 (`pgvector/pgvector@sha256:2358fcba361e…`). La convivencia se corrió cuatro veces con semillas distintas (1992, 1993, 1996 dos veces); se publican rangos, porque los hilos se intercalan distinto. El corte, cuatro veces (dos limpias, una con `--romper`, una tras el cambio a `jsonb`). El arnés del martes, dos veces cada versión.

## 6. 🧮 Los intermedios que amasan la salida

Los totales de la reconciliación del martes se sumaron de la tabla que imprime el arnés (`martes-solucion-1.txt`) con un script de Python de una línea por columna; el denominador de "una de cada ocho" de F25 (78.032 fichas) es 65.668 pares correctos + 12.364 sin pareja (`f25-06_sih.txt`, `f25-09_ejercicios.txt`).

## 7. ✅ Qué se espera ver

Lo de la bitácora M-52 a M-57 (15/10/2026) y lo de los solucionarios de F24–F26.

## 8. 📂 Salidas

Una salida por prueba en `salidas/` (nombres por fase y script). Los diagramas Mermaid de F25 y F26 dibujados con `mmdc` en `salidas/mermaid/`. El estado de las URL de F24–F26 en `salidas/urls-t12-estado.txt`.

## 9. 🧹 Limpieza

`./psql.sh < ../../cursos-bd/ruta-sql/src/25-la-migracion-sin-parar/08_deshacer.sql` y `lab load --model` devuelven la base. `rm -rf salidas/uv-cache salidas/uv-venv` libera el entorno de `uv`.

## 10. 🚫 Qué se dejó fuera

Nada binario salvo `salidas/uv-*` (regenerable con cualquier corrida de `correr-src.sh`) y los dos PDF de Oracle en `salidas/fuentes/` (se descargan de las URL de la referencia de F26).
