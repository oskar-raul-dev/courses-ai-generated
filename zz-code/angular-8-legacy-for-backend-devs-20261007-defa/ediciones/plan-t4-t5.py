# Plan: T4 and T5 closed, decisions D20-D23, log, checklist §8 and §9.
import sys, os; sys.path.insert(0, os.path.dirname(__file__))
from rep import Archivo
p = Archivo('prompts/_desechable-plan-de-edicion.md')
p.rep("**Siguiente paso:** T4 (incidente 22), que se discute antes de escribir; después T5.",
      "**Siguiente paso:** ninguno. T0–T5 cerradas el 2026-10-07; el plan espera el permiso del autor para borrarse.")
p.rep("- ⬜ **T4 — Incidente 22.**", "- ✅ **T4 — Incidente 22**, cerrada el 2026-10-07 (D20–D22).")
p.rep("- ⬜ **T5 — README y cierre.**", "- ✅ **T5 — README y cierre**, cerrada el 2026-10-07 (D23), con revisión final de forma y continuidad.")
p.rep('''---

## 2. 🧱 Reglas de orden''', '''### 1.5 Tomadas por el autor en T4 y T5 (2026-10-07)

- **D20 — Mecánica del 22.** El punto de Gatineau comprado (D19) sigue tomando muestras en la agenda de
  la clínica; desde noviembre de 2020 una interfaz copia la toma a LabCore con la hora de la pared y el
  `-05:00` pegado. Desde el 14/3/2021 cada toma queda una hora tarde, y si la recepción en Ottawa llega
  antes de una hora, la muestra figura recibida antes de tomada. La historia v2 lo cuenta.
- **D21 — Anclaje del 22:** Fase 7, 🟠, semana 2, categoría Tiempo. Reparto 7 / 8 / 4 / 3, escala
  2 🟢 · 8 🟡 · 10 🟠 · 2 🔴. Termina en contención (detector `offsetDoesNotMatchZone`, nota de custodia,
  texto para Calidad), no en fix.
- **D22 — Semillero de la Fase 05 en invierno.** Generaba fechas de enero a septiembre de 2019 con
  `-05:00` (26 de 40 en verano, y anteriores al arranque de LabCore). Ahora dic 2021 – feb 2022, con la
  misma cantidad de `random()`: pacientes y órdenes idénticos salvo las fechas.
- **D23 — Las 14h del cuaderno son presupuesto.** Los tiempos sugeridos suman de 18 a 26 h; las 122h
  no cambian, y el formato del cuaderno y el README lo dicen.

---

## 2. 🧱 Reglas de orden''')
p.rep('''- [ ] `grep -rn "Bogot\\|Colombia\\|colombian" .` → cero fuera de esta nota.
- [ ] `grep -rnE "(CC|TI|CE)-[0-9]" .` → cero.
- [ ] `grep -rn "Laboratorios Andina\\|S\\.A\\.S\\|es-CO\\|'COP'" .` → cero.
- [ ] Toda marca de tiempo del curso está en la tabla del script de T1, con su desfase real.
- [ ] Ninguna frase dice que la zona de la aplicación no tiene horario de verano.
- [ ] El incidente 22 existe, está en el índice y en el README, y su preparación reproduce el síntoma.
- [ ] La historia v2 cita el 22 y dice "veintidós tickets", y las dos cosas son verdad.
- [ ] Los tests de la Fase 12 y los incidentes 07, 19 y 22 corrieron en contenedor, con salida
      fechada en `zz-code/`.
- [ ] Todo bloque de código tocado en T1–T4 corrió en contenedor (regla 9), incluidos el `DatePipe`
      con IANA, el `$jsonSchema` de `bea-06` y los fragmentos Java de `bea-08`.
- [ ] La corrida final de T5 se hizo de cero desde los README de `zz-code/`, con las mismas salidas.
- [ ] §9 al día; contenedores y volúmenes de la edición borrados, nada fuera de lo creado.
- [ ] Validadores del curso en cero.
- [ ] Ningún documento del curso cita este plan ni `zz-code/`.''', '''- [x] `grep -rn "Bogot\\|Colombia\\|colombian" .` → cero fuera de esta nota, salvo "bacterióloga
      colombiana" en la historia, que es la nacionalidad de Liliana y no el lugar.
- [x] `grep -rnE "(CC|TI|CE)-[0-9]" .` → cero.
- [x] `grep -rn "Laboratorios Andina\\|S\\.A\\.S\\|es-CO\\|'COP'" .` → cero.
- [x] Toda marca de tiempo del camino base está en la tabla de T1 con su desfase real, salvo las
      intencionales: los bordes en `Z` del 07 y la semana de marzo de 2021 del 22 (con su propia prueba).
- [x] Ninguna frase dice que la zona de la aplicación no tiene horario de verano.
- [x] El incidente 22 existe, está en el índice y en el README, y su preparación reproduce el síntoma.
- [x] La historia v2 cita el 22 y dice "veintidós tickets", y las dos cosas son verdad.
- [x] Los tests de la Fase 12 (reducer y selectores; servicio y effect por lectura, D18) y los
      incidentes 07, 19 y 22 corrieron en contenedor, con salida fechada en `zz-code/`.
- [x] Todo bloque de código tocado en T1–T4 corrió en contenedor (regla 9), incluidos el `DatePipe`
      con IANA, el `$jsonSchema` de `bea-06`, los fragmentos Java de `bea-08` y los `curl` de las
      soluciones del 07 y del 22. Excepción declarada: el `docker inspect` y el `config.json` del 19 se
      muestran resumidos (mismo contenido).
- [x] La corrida final de T5 se hizo de cero (`corrida-final.sh`), con contenedores nuevos y la build
      `--no-cache`: 19 de 19 salidas iguales a las guardadas.
- [x] §9 al día; contenedores, redes, volúmenes e imágenes de la edición borrados. Queda la caché de
      build de Docker (sin `prune`, por la regla 7).
- [x] Validadores del curso en cero (`verificar-curso.py` y `verificar-secciones.py`, 568 referencias §).
- [x] Ningún documento del curso cita este plan ni `zz-code/`.''')
p.rep('''| `angular-8-legacy-for-backend-devs-20261007-defa` | T3 | Java 8, Spring Data Commons 2.1 y `mongo:4.0`: `bea-08`, `bea-06`, `bea-12` | vigente |
| *(por crear o el de T1)* | T4 | Incidente 22: preparación y orden del audit log | — |''', '''| `angular-8-legacy-for-backend-devs-20261007-defa` | T3 | Java 8, Spring Data Commons 2.1 y `mongo:4.0`: `bea-08`, `bea-06`, `bea-12` | archivado |
| `angular-8-legacy-for-backend-devs-20261007-defa` | T4–T5 | Incidente 22, semillero de la Fase 05, verificadores del curso, corrida final | archivado |''')
p.s = p.s.replace('''| `angular-8-legacy-for-backend-devs-20261007-defa` | T1 (y T3) | Extractor de bloques, tabla de fechas, `DatePipe` con IANA, selector y 07, Fase 05, PDF, esqueleto Angular 8 con `ng build --prod`, incidente 19 en Chrome headless, scripts de edición | vigente |''', '''| `angular-8-legacy-for-backend-devs-20261007-defa` | T1 (y T3) | Extractor de bloques, tabla de fechas, `DatePipe` con IANA, selector y 07, Fase 05, PDF, esqueleto Angular 8 con `ng build --prod`, incidente 19 en Chrome headless, scripts de edición | archivado |''')
p.s = p.s.replace('''| `angular-8-legacy-for-backend-devs-20261007-defa` | T2 | Regex de la Fase 05, specs de la Fase 12, moneda y locale, `json-server` | vigente |''', '''| `angular-8-legacy-for-backend-devs-20261007-defa` | T2 | Regex de la Fase 05, specs de la Fase 12, moneda y locale, `json-server` | archivado |''')
p.rep('''  fila del 22.
''', '''  fila del 22.
- **2026-10-07** — T4 y T5 cerradas (D20–D23, §1.5). **T4:** antes del 22, el semillero de la Fase
  05 pasó a invierno (D22: generaba 2019 ene–sep con `-05:00`). Incidente 22 escrito con la plantilla
  del formato y el 17 como modelo de cierre sin fix, con su preparación (`db.incidente-22.json`, cuatro
  muestras), su fila en el índice, la reserva en la Fase 7 (encabezado y 📌), el puente desde el
  forense 07, una fila nueva en el índice de síntomas del forense master y el pendiente [22] del
  cuaderno; el candidato viejo pasó al 23 en `06-ordenes`, `14-casi-prod-kind` y el cuaderno; cuentas de
  21 a 22 en el cuaderno, el formato, las preparaciones, la convención de git, el cuaderno BE y los
  prompts; la historia cuenta la interfaz de Gatineau; `bea-08` §8 habla de toma y recepción. Pruebas:
  detector, spec (3/3), datos y la línea de custodia con `appDate` en Toronto y Tokio, antes y después
  de insertar, iguales; el índice cuadra con los 22 encabezados (0 diferencias, 2/8/10/2, 7/8/4/3).
  **T5:** README (Andina, Ottawa–Gatineau y la consultora en el párrafo de LabCore; cuentas; las 14h
  como presupuesto; siete incidentes sin fix; "equipo contratado" fuera). Revisión de forma y
  continuidad: verificador de enlaces y anclas (reusa `verificador_base.py`), vallas, citas a
  `zz-code`, restos del escenario y reciprocidad incidente ↔ fase, en 0; seis enlaces de A13 al curso
  de Docker estaban rotos desde que el repo se agrupó en familias (`../../cursos-contenedores-cloud-infra/…`);
  568 referencias "Fase N §X" comprobadas exactas, 0 rotas; edad del sistema unificada (24 "seis años"
  → "siete años" desde 2019; la bitácora, cinco; el `rangeVersionApplied`, "años después"); "coger" en
  `bea-02`; la fila del 07 en el forense master. Corrida final de cero: 19/19 iguales, más la build
  `--no-cache`; la tabla de T1 se rehízo desde `git archive HEAD` (la corrida la había regenerado sobre
  el curso editado: error del script, corregido). Docker limpio, imágenes base borradas.
''')
p.save()
