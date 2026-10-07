# 🧪 vue2-legacy-for-backend-devs-20261006-c6c0 · cómo correr estas pruebas

> **Curso:** vue2-legacy-for-backend-devs · **Tanda:** rescate posterior al cierre · **Creado:** 2026-10-06
> **Propósito:** rescatar de las transcripciones de las sesiones el código de prueba de la producción
> del curso, con instrucciones para replicarlo.
> **Vigencia:** rescatado el 2026-10-06 con `zz-instrucciones/herramientas/rescatar-transcripcion.py`,
> sin ejecutar nada.

> ⚠️ **Lo primero: aquí no hay corridas del código del curso.** Los dos cursos (`01-vue2-legacy` y
> `02-complement-mongodb-backend`) ya estaban en el commit «Courses V1» del 16/08/2026, antes de la
> primera transcripción guardada (06/09). El proyecto aparte `curso-vue2-legacy` de Claude Code tiene
> una sola sesión, del 20/09, de dos minutos y sin herramientas. Las sesiones de este repositorio que
> trabajaron el curso (09–10/09) hicieron el cuaderno de incidentes y el forense, y no corrieron `npm`,
> `node` ni Docker. Lo que se rescata son sus **verificaciones del corpus**.

---

## 1. 🎯 Qué se prueba y para qué

| Carpeta | Sesión | Fecha (UTC) | Qué hay |
|---|---|---|---|
| `01-forense-8654ffa2/` | `8654ffa2…` | 09/09, 02:35–13:34 | La decisión de crear cuaderno de incidentes y forense en los dos cursos: encabezados de la sección 6, convenciones de incidentes y soporte de caos, bloques de tags en fases y apéndices, tuteo y enlaces |
| `02-forense-51943195/` | `51943195…` | 10/09, 00:35–02:17 | Que lo hecho en los prompts 0–3 de `contenido_forense.md` esté completo: afirmaciones de la convención de git, síntomas con fuente en los «errores comunes» de cada fase, excepciones HTML, voseo |
| `03-forense-f9f4966e/` | `f9f4966e…` | 10/09, 02:18–17:46 | El cierre de los prompts restantes y su checklist; `archivos/…/coser.py`, el script que cosió la sección «⚠️ Errores comunes y pieza forense» en cada fase |

`coser.py` **edita** el curso (agrega un bloque si no está): no es una prueba, pero es el único código que la
sesión escribió como archivo. La versión rescatada es la que escribió; un `sed -i` posterior le quitó un
salto de línea antes del bloque (está en `comandos.sh`).

### Qué hay en cada carpeta

- `comandos.sh` — todos los comandos Bash de la sesión, en orden. Una bitácora: no se corre entera.
- `scripts/NNN-HHMM-verifica.{py,sh}` y su `.salida.txt` — las verificaciones y lo que la sesión vio. Se
  omitieron los scripts que editaban la prosa (siguen en `comandos.sh`).
- `bitacora.md` — solo en `01-`: dos búsquedas que el detector tomó por ejecución.

## 2. 🛠️ Prerrequisitos

Bash, `grep` y Python 3. Para reconstruir, las transcripciones en
`~/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/`.

## 3. 🧭 Reglas antes de correr

- Las verificaciones solo leen el curso: no hace falta inventario de Docker.
- Se corren desde la raíz del curso (`cursos-legacy/vue2-legacy-for-backend-devs`); varias entran a
  `01-vue2-legacy/` o `02-complement-mongodb-backend/`. Entonces el curso vivía en la raíz del
  repositorio.
- `coser.py` **no** se corre contra el curso: ya se aplicó, y reconoce las fases cosidas («YA COSIDO»),
  pero escribe archivos.

## 4. ▶️ Cómo se corre

```bash
cd zz-code/vue2-legacy-for-backend-devs-20261006-c6c0
./rescatar.sh               # rehace desde cero las carpetas generadas (lee ../rescates.tsv); no ejecuta nada
./rescatar.sh --comprobar   # las regenera aparte y compara, sin tocar nada

AQUI="$PWD"
cd ../../cursos-legacy/vue2-legacy-for-backend-devs
bash "$AQUI/01-forense-8654ffa2/scripts/009-1331-verifica.sh"    # enlaces del maestro forense y estado
```

## 5. 📏 Cómo se mide

No aplica: no hay mediciones.

## 6. 🧮 Los intermedios que amasan la salida

No aplica.

## 7. ✅ Qué se espera ver

La salida de cada script es su `.salida.txt` (09–10/09/2026).

## 8. 📂 Salidas

Ninguna.

## 9. 🧹 Limpieza

Nada que limpiar.

## 10. 🚫 Qué se dejó fuera

- **El borrador de prosa** `/tmp/chaos_section.md` de `51943195`: ya está en el curso.
- **Los scripts que editaban la prosa:** en `comandos.sh`.
- **La sesión del proyecto `curso-vue2-legacy`** (20/09): no tiene comandos.
