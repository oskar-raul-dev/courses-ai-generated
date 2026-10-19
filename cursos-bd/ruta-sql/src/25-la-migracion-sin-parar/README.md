# 🚚 La migración sin parar

Lo que ejecuta la [Fase 25](../../25-la-migracion-sin-parar.md): las 71 tablas anchas de antes de 2008 al modelo
tipado, las reconciliaciones que tienen que cerrar en cero, la convivencia con el frontal por CDC, el maestro del
SIH, el simulacro de corte y la vuelta atrás.

## 🗂️ Qué hay

| Archivo | Qué hace |
|---|---|
| `01_anchas.sql` | la tanda que migra las anchas; cada resultado nuevo queda anotado con la celda de donde vino |
| `02_reconciliacion.sql` | las tres reconciliaciones de esa tanda, R1 a R3 |
| `03_cantidad.sql` | la que no cerró: la cantidad de lo facturado, arreglada con *expand* |
| `04_cdc_setup.sql` | el rol `access_frontend`, el slot `f25_legacy` y las funciones que aplican cada tabla |
| `cdc.py` | el aplicador: cada transacción de legacy, una vez, junto con su posición |
| `05_convivencia.py` | un día comprimido: tres sedes escriben en legacy y el aplicador las sigue, con una caída |
| `06_sih.sql` | el esquema `sih` armado desde la verdad del generador, y el cruce con el maestro del laboratorio |
| `07_corte.py` | el corte en cuatro pasos, y con `--romper`, la vuelta atrás |
| `08_deshacer.sql` | deshace la fase en orden inverso; se puede correr las veces que haga falta |
| `09_ejercicios.sql` | los ejercicios 1 a 16, dentro de una transacción que se revierte |

## ▶️ Cómo se corre

Con el modelo de la Fase 08 cargado (`uv run lab load --profile m --model`). Los `.sql`, desde `src/lab/`; los
`.py`, desde `src/`:

```bash
f() { docker compose exec -T postgres psql -U postgres -d alameda -v ON_ERROR_STOP=1 < "../25-la-migracion-sin-parar/$1"; }
f 01_anchas.sql; f 02_reconciliacion.sql; f 03_cantidad.sql; f 04_cdc_setup.sql   # en src/lab/
uv run python 25-la-migracion-sin-parar/05_convivencia.py [segundos] [semilla]     # en src/
f 06_sih.sql; f 09_ejercicios.sql                                                 # en src/lab/
uv run python 25-la-migracion-sin-parar/07_corte.py [segundos] [--romper]          # en src/
f 08_deshacer.sql                                                                 # y se repite desde 01
```

`09_ejercicios.sql` va justo después de `05_convivencia.py`, con el slot todavía creado.

## ✅ Lo que tiene que salir

La lista de comprobación de la fase: `01_anchas.sql` migra 592.358 celdas en 578.005 resultados y 14.353 rechazos;
`02_reconciliacion.sql` da 0 en R1, R2 y R3; `03_cantidad.sql` deja las unidades del modelo iguales a las de legacy;
`05_convivencia.py` y `07_corte.py` terminan con 0 diferencias, y el segundo vuelve atrás con `--romper`; el slot
`f25_legacy` queda borrado, y `08_deshacer.sql` deja el modelo con 12.132.303 resultados y 33 analitos.
