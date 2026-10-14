# T1: incident 07 preparation data, commit example and tag example (new mechanism and thresholds).
import sys, os; sys.path.insert(0, os.path.dirname(__file__))
from rep import Archivo
p = Archivo('prompts/preparaciones-de-incidentes.md')
p.rep('''### `db.incidente-07.json` — el crítico del sábado por la noche

**Lo que cambia:** una muestra tomada en el borde exacto de la vigencia, y su
resultado crítico.''','''### `db.incidente-07.json` — el crítico de la noche del 31

**Lo que cambia:** una muestra tomada en el borde exacto de la vigencia, su
resultado crítico, y los dos bordes del potasio escritos en UTC, como los dejó el
script que cargó la v2 a fines de 2021.''')
p.rep('''  "collectedAt": "2021-12-31T20:15:00-05:00",   // ← sábado, 20:15 local = 01:15Z del 1 de junio''',
      '''  "collectedAt": "2021-12-31T20:15:00-05:00",   // ← viernes 31, 20:15 en Ottawa = 01:15Z del 1 de enero''')
p.rep('''// referenceRanges — dos versiones de potasio con el borde en el 1 de junio
{ "id": 31, "analyte": "potassium", "version": 1,
  "low": 3.5, "high": 5.5, "criticalLow": 2.5, "criticalHigh": 7.0,
  "effectiveFrom": "2019-01-01T00:00:00-05:00",
  "effectiveTo":   "2021-12-31T23:59:59-05:00" },
{ "id": 32, "analyte": "potassium", "version": 2,
  "low": 3.5, "high": 5.1, "criticalLow": 2.8, "criticalHigh": 6.5,
  "effectiveFrom": "2022-01-01T00:00:00-05:00",
  "effectiveTo":   null }''','''// referenceRanges — dos versiones de potasio con el borde en el 1 de enero,
// escrito en UTC (la "Z"): es el dato roto del incidente
{ "id": 31, "analyte": "potassium", "version": 1,
  "low": 3.5, "high": 5.1, "criticalLow": 2.5, "criticalHigh": 6.5,
  "effectiveFrom": "2019-01-01T00:00:00-05:00",
  "effectiveTo":   "2021-12-31T23:59:59Z" },
{ "id": 32, "analyte": "potassium", "version": 2,
  "low": 3.5, "high": 5.2, "criticalLow": 2.8, "criticalHigh": 7.0,
  "effectiveFrom": "2022-01-01T00:00:00Z",
  "effectiveTo":   null }''')
p.rep('''**El mecanismo:** con la v1 vigente (la que de verdad le tocaba), 6.8 está **por
debajo** del `criticalHigh` de 7.0 → sale fuera de rango pero **no crítico**. Con la
v2, que es la que elige la comparación en UTC, el `criticalHigh` baja a 6.5 y 6.8
**sí** es crítico. Los dos veredictos son defendibles y sólo uno es el correcto,
que es exactamente lo que hace al incidente incómodo.''','''**El mecanismo:** con la v1 vigente (la que de verdad le tocaba), 6.8 está **por
encima** del `criticalHigh` de 6.5 → sale **crítico**, en rojo. Pero el borde de la
v2 quedó escrito como medianoche UTC, que en Ottawa son las 19:00 del 31, y la
muestra de las 20:15 cae del lado de la v2: el `criticalHigh` sube a 7.0 y 6.8
queda solo fuera de rango, en amarillo, que es lo que vio la coordinadora. Los dos
veredictos son defendibles y sólo uno es el correcto, que es exactamente lo que
hace al incidente incómodo.''')
p.rep('''`selectActiveRange(ranges, 'potassium', '2021-12-31T20:15:00-05:00').version`
devuelve `2`. Con la misma fecha a las 12:15 devuelve `1`.''','''`selectActiveRange(ranges, 'potassium', '2021-12-31T20:15:00-05:00').version`
devuelve `2`. Con la misma fecha a las 12:15 devuelve `1`, y con los bordes
corregidos a `-05:00` las dos devuelven `1`.''')
p.save()

f = Archivo('prompts/formato-cuaderno-incidentes.md')
f.rep('incidente(07): abre — resultados críticos sin alerta el sábado', 'incidente(07): abre — resultados críticos sin alerta el fin de semana')
f.rep('incidente(07): causa — comparación de fecha sin zona horaria en el selector', 'incidente(07): causa — borde de vigencia de la v2 cargado en UTC')
f.rep('incidente(07): fix — normaliza a la TZ de la aplicación antes de comparar', 'incidente(07): fix — bordes del potasio con el desfase de Ottawa')
f.rep('alerta-del-sabado-roto', 'critico-de-nochevieja-roto')
f.rep('alerta-del-sabado-fix', 'critico-de-nochevieja-fix')
f.save()

c = Archivo('cuaderno-incidentes.md')
c.rep('incidente(07): causa — comparación de fecha sin zona horaria en el selector', 'incidente(07): causa — borde de vigencia de la v2 cargado en UTC', count=c.s.count('incidente(07): causa — comparación de fecha sin zona horaria en el selector'))
c.rep('incidente(07): fix — normaliza a la TZ de la aplicación antes de comparar', 'incidente(07): fix — bordes del potasio con el desfase de Ottawa', count=c.s.count('incidente(07): fix — normaliza a la TZ de la aplicación antes de comparar'))
c.rep('incidente(07): repro — falla con TZ del navegador en UTC-5', 'incidente(07): repro — falla con el navegador en America/Toronto', count=c.s.count('incidente(07): repro — falla con TZ del navegador en UTC-5'))
c.save()

g = Archivo('00-convencion-de-git-y-tags.md')
g.rep('''git tag -a inc/07/alerta-del-sabado-roto -m "Síntoma: un resultado crítico del
sábado no disparó alerta. Repro: navegador en UTC-5, muestra procesada el
sábado 23:40 hora local. Evidencia: la acción entra al log de DevTools, el
selector devuelve lista vacía, y el spec de regresión falla."''','''git tag -a inc/07/critico-de-nochevieja-roto -m "Síntoma: un potasio de 6.8 del
viernes 31 a las 20:15 salió en amarillo y no en rojo. Repro: db.incidente-07.json,
muestra 612. Evidencia: selectActiveRange elige la v2 a las 20:15 y la v1 a las
12:15; los bordes del potasio terminan en Z. El spec de regresión falla."''')
g.rep('''git tag -a inc/07/alerta-del-sabado-fix -m "Causa raíz: el selector compara la
fecha con new Date() sin normalizar zona horaria, así que el sábado tarde cae
en el día siguiente. Fix: normalizar a la zona de la aplicación antes de
comparar. Regresión: el spec con TZ fijada pasa."''','''git tag -a inc/07/critico-de-nochevieja-fix -m "Causa raíz: la v2 se cargó con
bordes en UTC; medianoche UTC son las 19:00 del 31 en Ottawa. Fix: los dos
bordes con -05:00. Regresión: el spec de la noche del 31 pasa."''')
g.rep('git diff inc/07/alerta-del-sabado-roto inc/07/alerta-del-sabado-fix', 'git diff inc/07/critico-de-nochevieja-roto inc/07/critico-de-nochevieja-fix')
g.save()
