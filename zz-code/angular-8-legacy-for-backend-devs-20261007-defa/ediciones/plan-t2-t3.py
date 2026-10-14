# Plan: T2 and T3 closed, decisions D17-D19, log entry, §9 rows, notes for T4/T5.
import sys, os; sys.path.insert(0, os.path.dirname(__file__))
from rep import Archivo
p = Archivo('prompts/_desechable-plan-de-edicion.md')
p.rep("**Siguiente paso:** T3 (track BE); T2 y T4 siguen abiertas.", "**Siguiente paso:** T4 (incidente 22), que se discute antes de escribir; después T5.")
p.rep("- ⬜ **T2 — Paciente, moneda y locale** del camino base.", "- ✅ **T2 — Paciente, moneda y locale** del camino base, cerrada el 2026-10-07 (pedida por el autor junto con T3).")
p.rep("- ⬜ **T3 — Track BE.**", "- ✅ **T3 — Track BE**, cerrada el 2026-10-07 (D17–D19).")
p.rep('''---

## 2. 🧱 Reglas de orden''', '''### 1.4 Tomadas por el autor en T2 y T3 (2026-10-07)

- **D17 — T2 junto con T3.** El track BE lee los datos del camino base; cambiar D8 solo en uno dejaba a
  los dos tracks contradiciéndose.
- **D18 — Fase 12 sin Karma.** Los specs de reducer y selectores corren con Jasmine en Node; los del
  servicio y el effect (TestBed) se verifican por lectura: el identificador es un dato que ninguna
  aserción mira.
- **D19 — La importación de 2020 es el punto de Gatineau comprado.** Los 718 pacientes con `name` y
  `_source: legacy-import` vienen del punto de toma que Andina le compró a una clínica que cerraba, con
  su fichero en el sistema de agenda de la clínica. La historia v2 lo cuenta en la Era 2.

---

## 2. 🧱 Reglas de orden''')
p.rep('''| *(por crear o el de T1)* | T2 | Regex de la Fase 05, specs de la Fase 12, moneda y locale | — |
| *(por crear o el de T1)* | T3 | Java 8 y `mongo:4.0`: `bea-08`, `bea-06`, `bea-12` | — |''',
'''| `angular-8-legacy-for-backend-devs-20261007-defa` | T2 | Regex de la Fase 05, specs de la Fase 12, moneda y locale, `json-server` | vigente |
| `angular-8-legacy-for-backend-devs-20261007-defa` | T3 | Java 8, Spring Data Commons 2.1 y `mongo:4.0`: `bea-08`, `bea-06`, `bea-12` | vigente |''')
p.rep('''  con saltos de línea (mismo contenido; se deja).
''', '''  con saltos de línea (mismo contenido; se deja).
- **2026-10-07** — T2 y T3 cerradas (D17–D19, §1.4). **T2:** D8 en los dos tracks (34 reemplazos en
  15 archivos, regex de la Fase 05 y `pattern` de `bea-06` incluidos; Deisy, la menor, pasa de `TI-`
  a `PP-`); `CAD` con `'1.2-2'` en A07 (con la salida real en el comentario) y `'es'` en el PDF.
  Pruebas: regex 11/11; 9/9 specs de la Fase 12 en Node, después de corregir un error viejo del spec de
  selectores (le pasaba `state.items` a un proyector que recibe el estado; 3 fallaban); la sonda
  agrega la respuesta del ejercicio 1 de la Fase 05 (`setPatientsFilter`), que la fase deja sin
  escribir a propósito; `json-server` 0.16.3 carga el `db.json`; T1 repetida en verde. **T3:**
  `bea-08` a Ottawa con §8 nueva ("Ottawa sí, y por eso": tabla de cambios de hora 2019–2022, la
  constante de julio, el hueco de marzo y la hora doble de noviembre, la regla de antes de 2007, el
  puente al incidente 22). Hallazgos viejos corregidos: el `1757516645123L` de §5 era de 2025 y no la
  `2026-09-10T15:04:05.123Z` de la tabla (ahora `1789052645123L`, y en Ottawa son cuatro horas, no
  cinco); la advertencia de `LocalDate` estaba al revés (sale un día antes escrito en UTC y leído en
  Ottawa, probado con los conversores reales de Spring Data 2.1). `be04` a Toronto. `be06` corrido a
  la cronología nueva sin perder su forma: la v2 escrita el 28/12/2021 y vigente desde el 1/1/2022, el
  resultado del 12/10/2022, el `$set` del 1/3/2023, 14 meses; con sus ecos en `be05`, `be08`, `bea-12`,
  el cuaderno BE y los dos prompts BE. D10 en `be07`, `be08`, `bea-09`, `bea-10`; la consultora en `be00`
  y `be01`; D19 en `be02`, el cuaderno BE y la historia. Pruebas: los cinco fragmentos Java de
  `bea-08` en Java 8 (UTC y Toronto) dan lo que dicen sus comentarios; en `mongo:4.0.28`, el `pattern`
  acepta HC/PP/LB y rechaza CC, los 4.820 pacientes del generador de `bea-12` pasan la regex y el
  esquema, y la agregación con `timezone: 'America/Toronto'` reparte bien la noche en invierno y en
  verano (un `-05:00` fijo manda al día anterior lo de 00:00–01:00 de verano; el texto lo dice así).
  Cierres: `Bogot|Colombia|Laboratorios Andina|S.A.S|es-CO|'COP'` = 0 y `(CC|TI|CE)-[0-9]` = 0 en todo el
  curso. Limpieza: contenedores, red, imágenes `lab-frontend` y volúmenes anónimos del mongo borrados;
  quedan las imágenes base para T5. Un volumen de Maven se creó sin etiqueta y se borró enseguida.
  **Para T4:** `bea-08` §8 ya fija la mecánica del 22 (una marca escrita con la constante en verano y
  otra con el reloj del navegador a menos de una hora: "validado antes de recibido"); la historia y
  `04-mock-api-caos` ya lo citan; el candidato viejo pasa al 23 en `06-ordenes`, `14-casi-prod-kind` y el
  cuaderno. **Para T5 (README):** la línea ~138 dice "equipo contratado"; las cuentas del cuaderno y la
  fila del 22.
''')
p.save()
