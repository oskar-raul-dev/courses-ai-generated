# 🧪 react-16-legacy-for-backend-devs-20261006-d22a · cómo correr estas pruebas

> **Curso:** react-16-legacy-for-backend-devs · **Tanda:** rescate posterior al cierre · **Creado:** 2026-10-06
> **Propósito:** rescatar de las transcripciones de las sesiones el código de prueba de la producción
> del curso, con instrucciones para replicarlo.
> **Vigencia:** rescatado el 2026-10-06 con `zz-instrucciones/herramientas/rescatar-transcripcion.py`,
> sin ejecutar nada.

> ⚠️ **Lo primero: aquí no hay corridas del código del curso.** Las salidas de react-16 se ejecutaron al
> escribirlo, pero **sin registro**: el track base ya estaba en el commit «Courses V1» del 16/08/2026,
> antes de la primera transcripción guardada (06/09), y ninguna de las sesiones posteriores corrió
> `npm`, `node` ni Docker sobre el curso (se buscó en todas). Lo único que se puede rescatar son las
> **verificaciones del corpus** de la redacción del track BE, de las piezas forenses y de la revisión
> del 06/10. La revalidación por ejecución está planeada en
> `cursos-legacy/react-16-legacy-for-backend-devs/prompts/_desechable-plan-de-validacion.md`
> (tandas V0–V13, sin empezar) y abrirá su propio directorio en `zz-code/`.

---

## 1. 🎯 Qué se prueba y para qué

| Carpeta | Sesión | Fecha (UTC) | Qué hay |
|---|---|---|---|
| `01-track-be-2c56f1ab/` | `2c56f1ab…` | 08/09 03:34 → 09/09 04:42 | Redacción de las fases y apéndices BE. Sin verificaciones propias: solo `comandos.sh` |
| `02-forense-5d4ed58d/` | `5d4ed58d…` | 10/09, 01:19–02:48 | Los cuadernos de incidentes y el forense: enlaces y citas de archivo, índice de incidentes contra encabezados y hermanos BE, plantilla, tablas anchas, voseo y regionalismos, anclas con el algoritmo real de GitHub (29 verificaciones) |
| `03-nombres-be-14cfaf06/` | `14cfaf06…` | 12/09, 02:12–02:17 | La convención de nombres del track BE y la completitud de su cuaderno |
| `04-revision-zz-073aaed3/` | `073aaed3…` | 06/10, 00:03–00:36 | La revisión contra `zz-instrucciones/`: los ocho scripts que la sesión corrió; sus salidas y diagramas están en `../react-16-legacy-for-backend-devs-20261005-cbd3/` |

### Qué hay en cada carpeta

- `comandos.sh` — todos los comandos Bash de la sesión, en orden. Una bitácora: no se corre entera.
- `scripts/NNN-HHMM-verifica.{py,sh}` y su `.salida.txt` — las verificaciones y lo que la sesión vio. Se
  omitieron los scripts que editaban la prosa (siguen en `comandos.sh`).
- `bitacora.md` — en `01-` y `04-`: los comandos que el detector toma por ejecución (búsquedas, el
  verificador del curso, `mmdc`). Ninguno corre código del curso.

## 2. 🛠️ Prerrequisitos

Python 3 y bash. Para reconstruir, las transcripciones en
`~/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/`.

## 3. 🧭 Reglas antes de correr

- Las verificaciones solo leen el curso: no hace falta inventario de Docker.
- Se corren desde la raíz del curso (`cursos-legacy/react-16-legacy-for-backend-devs`). Las de septiembre
  se escribieron cuando el curso vivía en la raíz del repositorio y antes de la revisión del 05–06/10
  (que subió `decisiones-y-versiones.md` a la raíz y quitó las citas a `prompts/`): un script que hoy
  falla puede estar señalando ese cambio.

## 4. ▶️ Cómo se corre

```bash
cd zz-code/react-16-legacy-for-backend-devs-20261006-d22a
./rescatar.sh               # rehace desde cero las carpetas generadas (lee ../rescates.tsv); no ejecuta nada
./rescatar.sh --comprobar   # las regenera aparte y compara, sin tocar nada

AQUI="$PWD"
cd ../../cursos-legacy/react-16-legacy-for-backend-devs
python3 "$AQUI/02-forense-5d4ed58d/scripts/010-0228-verifica.py"    # anclas con el algoritmo de GitHub
```

La verificación vigente del curso: `python3 prompts/verificar-corpus.py` y, con `--publicacion`, la que
prohíbe citar `prompts/` (ver `../react-16-legacy-for-backend-devs-20261005-cbd3/README.md`).

## 5. 📏 Cómo se mide

No aplica: no hay mediciones.

## 6. 🧮 Los intermedios que amasan la salida

No aplica.

## 7. ✅ Qué se espera ver

La salida de cada script es su `.salida.txt`. Al cierre de la revisión del 05–06/10, los dos verificadores
del curso quedaron en 0 errores y 0 avisos.

## 8. 📂 Salidas

Ninguna: las verificaciones solo imprimen.

## 9. 🧹 Limpieza

Nada que limpiar.

## 10. 🚫 Qué se dejó fuera

- **Los borradores de prosa** del scratchpad de `5d4ed58d` (`L1.md` … `L5c.md`, `sintomas.md`,
  `sintomas-be.md`): son las piezas del cuaderno antes de pasar al curso.
- **Un archivo de memoria** que escribió `2c56f1ab` (`track-be-react16-sin-escribir.md`), ya reemplazado.
- **La sesión `f803daaa`** (09/09) empezó en este curso, conversando la propuesta de backend, pero sus
  pruebas son de los backends de Angular: están en los rescates de angular-16 y angular-8.
- **Sesiones sin código de prueba:** `2915b9e5` (recetas BE) y consultas cortas.
