# Plan: T1 closed, decisions D11-D16 of 2026-10-07, log entry and §9 row.
import sys, os; sys.path.insert(0, os.path.dirname(__file__))
from rep import Archivo
p = Archivo('prompts/_desechable-plan-de-edicion.md')
p.rep("**Siguiente paso:** T1 (zona horaria y fechas).", "**Siguiente paso:** T3 (track BE); T2 y T4 siguen abiertas.")
p.rep("- ⬜ **T1 — Zona horaria y fechas** del camino base.", "- ✅ **T1 — Zona horaria y fechas** del camino base, cerrada el 2026-10-07 (D11–D16).")
p.rep('''---

## 2. 🧱 Reglas de orden''', '''### 1.3 Tomadas por el autor en T1 (2026-10-07)

Salieron de pruebas que fallaron contra lo que el curso decía. Todas por ejecución, en `zz-code/`.

- **D11 — `appDate`.** El `DatePipe` de Angular 8 ignora en silencio un identificador IANA y formatea
  en la zona del navegador (también pasaba con `'America/Bogota'`). Se arregla el código: pipe propio
  `appDate` en `shared/` (Fase 02 §5.10), que calcula con `Intl` el desfase de ese instante y delega en
  `formatDate`. Lo declara y exporta el `SharedModule` (Fases 02 y 05).
- **D12 — Semilla en enero de 2022.** Las órdenes, custodias y validaciones de ago–sep de 2019 se
  corren 122 semanas (2019-09-02 → 2022-01-03, mismos días de la semana), para que los
  `rangeVersionApplied: 2` sigan siendo verdad con la v2 desde el 1/1/2022. El validado sin norma del
  incidente 12 pasa a 2019-02-15 (dato del sistema anterior).
- **D13 — Incidente 07 en Nochevieja.** La muestra es del viernes 31/12/2021 a las 20:15 (el texto
  viejo decía "sábado" sobre un 31/05/2019 que era viernes).
- **D14 — Fase 05, carga de la fecha.** `new Date('1984-03-12')` es medianoche UTC y en Ottawa corre
  un día al editar; la carga usa `toLocalDate()`. §6 explica las dos causas (oeste y este de UTC).
- **D15 — Mecánica del 07.** Con `-05:00` en los dos lados el selector elegía bien: el incidente no se
  reproducía. Ahora la v2 del potasio la cargó un script con `toISOString()` y sus bordes terminan en
  `Z`; desde las 19:00 del 31 se elige la v2. Umbrales: v1 `criticalHigh` 6.5 (6.8 es crítico, rojo),
  v2 7.0 (6.8 solo fuera, amarillo), que es lo que dice el ticket. El fix mínimo corrige el dato; el
  correcto guarda la vigencia como fecha de calendario de `America/Toronto`.
- **D16 — Custodia con `appDate`.** La línea de custodia de la Fase 07 muestra la hora de Ottawa; con el
  PDF de la Fase 09 son los dos consumidores de `timeZone` que nombra la Fase 13 (el de la Fase 02
  desaparecía en la Fase 05).

---

## 2. 🧱 Reglas de orden''')
p.rep('''| *(por crear)* | T1 | Extractor de bloques, script de fechas, `DatePipe` con IANA, selector de rangos, incidentes 07 y 19 | — |''',
'''| `angular-8-legacy-for-backend-devs-20261007-defa` | T1 (y T3) | Extractor de bloques, tabla de fechas, `DatePipe` con IANA, selector y 07, Fase 05, PDF, esqueleto Angular 8 con `ng build --prod`, incidente 19 en Chrome headless, scripts de edición | vigente |''')
p.rep('''  (fuera de vigencia).
''', '''  (fuera de vigencia).
- **2026-10-07** — T1 cerrada, con D11–D16 del autor (§1.3). Directorio `zz-code/…-20261007-defa`.
  Hallazgos por ejecución, todos anteriores al giro: el `DatePipe` ignora IANA; la tabla de A07 §6 traía
  `'short'` y `'medium'` con una coma que Angular no pone; la Fase 05 corría un día al editar en
  Ottawa (y en Bogotá); el incidente 07 no se reproducía con el código del curso y sus umbrales
  contradecían el ticket; la Fase 13 nombraba un consumidor de `timeZone` que la Fase 05 borró; la
  historia decía "no hay zona horaria en ningún lado". Cambios: tabla de fechas (31 equivalencias, 0
  problemas, igual en tres zonas del host) aplicada a 04, 08, cuaderno, forenses 07/08/11 y
  `preparaciones`; Fases 02 (`appDate`, §5.10 nueva), 04, 05, 07, 08, 09, 13; A07 §6; cuaderno 04, 07
  (reescrito), 11, 12, 19; forenses 02, 08, 13; `preparaciones` 07, 11, 19; `formato-cuaderno`;
  `00-convencion` (tags `inc/07/critico-de-nochevieja-*`); historia (§5, zona). Pruebas: 15/15 y el
  spec del 07 en verde con Jasmine (Toronto y Tokio); `ng build --prod` real de un esqueleto
  `clinical-lab` con los bloques del curso; los `docker run` del 19 tal como están, con `config.json`,
  log e `inspect` como dice el cuaderno; Chrome headless en Tokio y con `APP_TIME_ZONE=America/Vancouver`
  confirma `appDate`. Cierre: `Bogot` = 0 fuera del track BE (queda "colombiana" en la historia, que es
  la nacionalidad de Liliana) y 0 marcas fuera de tabla. **Para T4:** el `04-mock-api-caos` y la historia
  ya citan el incidente 22, que todavía no existe. **No hecho en T1:** el `'es-CO'` del PDF y el `'COP'`
  de A07 son de T2; el `config.json` del cuaderno y del forense 13 se muestra compacto y nginx lo sirve
  con saltos de línea (mismo contenido; se deja).
''')
p.save()
