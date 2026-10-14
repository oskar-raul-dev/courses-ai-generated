# T4: insert incident 22 and its preparation; counts 21 -> 22; candidates -> 23; links and the history.
import sys, os; sys.path.insert(0, os.path.dirname(__file__))
from rep import Archivo
H = os.path.dirname(__file__)
inc = open(os.path.join(H, 't4-incidente22.md'), encoding='utf-8').read()
prep = open(os.path.join(H, 't4-preparacion22.md'), encoding='utf-8').read()

c = Archivo('cuaderno-incidentes.md')
c.rep('pistas, las soluciones y tu registro de cómo llegaste a cada una. Los veintiún\nincidentes vienen escritos de antemano;',
      'pistas, las soluciones y tu registro de cómo llegaste a cada una. Los veintidós\nincidentes vienen escritos de antemano;')
c.rep('Los veintiún IDs quedaron reservados por las fases que los producen;', 'Los veintidós IDs quedaron reservados por las fases que los producen;')
c.rep('**Los veintiún enunciados están escritos abajo**', '**Los veintidós enunciados están escritos abajo**')
c.rep('| 21 | 7 | La lista no cambia al cambiar de orden | Estado (store) | 🟠 | ⬜ |\n',
      '| 21 | 7 | La lista no cambia al cambiar de orden | Estado (store) | 🟠 | ⬜ |\n| 22 | 7 | La muestra llegó al laboratorio antes de que se la sacaran al paciente | Tiempo | 🟠 | ⬜ |\n')
c.rep('# 🪞 Retrospectiva del mes', inc + '# 🪞 Retrospectiva del mes')
c.rep('buen candidato para el **22**.', 'buen candidato para el **23**.')
c.rep('buen candidato al **22**, que sigue sin dar', 'buen candidato al **23**, que sigue sin dar')
c.rep('''- **[19] [20]** Los dos guiones de humo''', '''- **[22]** La interfaz de la agenda de Gatineau sigue pegando `-05:00` y nadie es su
  dueño → el arreglo es de quien herede ese sistema; mientras tanto, el detector
  `offsetDoesNotMatchZone` se corre el segundo domingo de marzo y el primero de
  noviembre, y el número va al informe de Calidad.
- **[19] [20]** Los dos guiones de humo''')
c.save()

p = Archivo('prompts/preparaciones-de-incidentes.md')
p.rep('`db.incidente-NN.json`, o una rama `incidente/NN`—, y los veintiún enunciados usan', '`db.incidente-NN.json`, o una rama `incidente/NN`—, y los veintidós enunciados usan')
p.rep('línea rompe cada rama y qué registros lleva cada archivo de datos. Sin eso, trece\nde los veintiún incidentes', 'línea rompe cada rama y qué registros lleva cada archivo de datos. Sin eso, catorce\nde los veintidós incidentes')
p.rep('- [4. Los tres `db.incidente-NN.json`](#4-los-tres-dbincidente-nnjson)', '- [4. Los cuatro `db.incidente-NN.json`](#4-los-cuatro-dbincidente-nnjson)')
p.rep('## 4. Los tres `db.incidente-NN.json`', '## 4. Los cuatro `db.incidente-NN.json`')
p.rep('| 21 | rama | `incidente/21` |\n', '| 21 | rama | `incidente/21` |\n| 22 | datos | `db.incidente-22.json` |\n')
p.rep('**Nueve ramas, tres archivos de datos, un comando.**', '**Nueve ramas, cuatro archivos de datos, un comando.**')
p.rep('## 5. El que sólo necesita un comando de arranque', prep + '---\n\n## 5. El que sólo necesita un comando de arranque')
p.rep('Antes de dar por lista cualquiera de las trece,', 'Antes de dar por lista cualquiera de las catorce,')
p.rep('**Las trece preparaciones no se aplican todas a la vez.**', '**Las catorce preparaciones no se aplican todas a la vez.**')
p.save()

f = Archivo('prompts/formato-cuaderno-incidentes.md')
f.rep('''**Presupuesto:** 21 incidentes, **14h** repartidas en el mes, ≈3.5h por semana.
Está fuera de las 108h de las fases y así suma las 122h de
`propuesta-fases-y-alcance.md` §2.''', '''**Presupuesto:** 22 incidentes, **14h** repartidas en el mes, ≈3.5h por semana.
Está fuera de las 108h de las fases y así suma las 122h de
`propuesta-fases-y-alcance.md` §2. Las 14h son el **presupuesto del calendario**,
no la suma de los tiempos sugeridos: esa suma da de 18 a 26 horas, y quien haga
los veintidós con calma se pasa. Se declara así para no inflar el calendario del
curso con un número que depende de cuánto se atasque cada uno.''')
f.rep('3. **📋 Índice** — la tabla de los 21 IDs (§3).', '3. **📋 Índice** — la tabla de los 22 IDs (§3).')
f.rep('### El reparto de los 21', '### El reparto de los 22')
f.rep('''- **Semana 2** — fases 5-8 · **7 incidentes** (07, 09, 10, 11, 12, 13, 21): la
  baja lógica que sigue en la lista, la escritura cancelada, la custodia
  imposible, la norma que falta, la doble firma y el crítico de Nochevieja.''', '''- **Semana 2** — fases 5-8 · **8 incidentes** (07, 09, 10, 11, 12, 13, 21, 22): la
  baja lógica que sigue en la lista, la escritura cancelada, la custodia
  imposible, la norma que falta, la doble firma, el crítico de Nochevieja y la
  toma de Gatineau que llega después de su recepción.''')
f.rep('''> no son dos.''' if '> no son dos.' in f.s else '''> dos únicos 🟢 y no tiene ningún 🔴, y los dos 🔴 están los dos en la semana 4.''', '''> dos únicos 🟢 y no tiene ningún 🔴, y los dos 🔴 están los dos en la semana 4.
>
> Y el **22** se agregó después, con el giro de LabCore a Ottawa: es el cambio de
> hora, anclado en la custodia de la Fase 7, 🟠. El reparto quedó **7 / 8 / 4 / 3**
> y la escala **2 🟢 · 8 🟡 · 10 🟠 · 2 🔴**.''')
f.rep('''- [ ] 21 incidentes, con el reparto por semana de §3 y la escala
      2 🟢 · 8 🟡 · 9 🟠 · 2 🔴.''', '''- [ ] 22 incidentes, con el reparto por semana de §3 (7 / 8 / 4 / 3) y la escala
      2 🟢 · 8 🟡 · 10 🟠 · 2 🔴.''')
f.save()

for rel, pairs in {
 '00-convencion-de-git-y-tags.md': [('**Nueve de los veintiún incidentes** empiezan\n> así, y los otros doce', '**Nueve de los veintidós incidentes** empiezan\n> así, y los otros trece'),
                                    ('reserva **veintiún IDs** —el paciente que se guardó y\ndice que no, el resultado crítico que no alertó el sábado,', 'reserva **veintidós IDs** —el paciente que se guardó y\ndice que no, el resultado crítico que no alertó en Nochevieja,')],
 'cuaderno-incidentes-be.md': [('del track base, sus veintiún\nincidentes,', 'del track base, sus veintidós\nincidentes,'),
                               ('Los veintiún incidentes del frontend viven en\n[`cuaderno-incidentes.md`](cuaderno-incidentes.md), con IDs `01`–`21`', 'Los veintidós incidentes del frontend viven en\n[`cuaderno-incidentes.md`](cuaderno-incidentes.md), con IDs `01`–`22`')],
 'prompts/propuesta-fases-y-alcance.md': [('| 📓 | **Cuaderno de incidentes** | **14h** | 21 incidentes, ≈3.5h/semana |', '| 📓 | **Cuaderno de incidentes** | **14h** | 22 incidentes, ≈3.5h/semana (presupuesto, no suma) |'),
                                          ('21 incidentes, ≈3.5h por semana. Distribución por dificultad:', '22 incidentes, ≈3.5h por semana. Distribución por dificultad (la proyección original; la real está en `formato-cuaderno-incidentes.md` §3):')],
 'prompts/prompts-backend-apendice.md': [('base y sus veintiún incidentes.', 'base y sus veintidós incidentes.')],
 'prompts/formato-piezas-forenses.md': [('que es el formato con el que se cierran los veintiún incidentes.', 'que es el formato con el que se cierran los veintidós incidentes.'),
                                        ('que es el molde de los veintiún incidentes y el cierre de la', 'que es el molde de los veintidós incidentes y el cierre de la')],
 '06-ordenes.md': [('Si alguna vez se abre el **22**, ese es su sitio,', 'Si alguna vez se abre el **23**, ese es su sitio,')],
 '14-casi-prod-kind.md': [('el índice de `cuaderno-incidentes.md` cierra en el 21 y esta fase es opcional', 'el índice de `cuaderno-incidentes.md` cierra en el 22 y esta fase es opcional'),
                          ('Queda un candidato anotado por si algún día se abre el 22, con esa misma salvedad:', 'Queda un candidato anotado por si algún día se abre el 23, con esa misma salvedad:'),
                          ('- **22 (🔥 candidato, no dado de alta)** · Fase 14', '- **23 (🔥 candidato, no dado de alta)** · Fase 14')],
 '07-muestras-custodia.md': [('Esta fase toma los incidentes **11 y 21**, los dos nuevos.', 'Esta fase toma los incidentes **11, 21 y 22**. El 22 llegó después, con el giro de\nLabCore a Ottawa: es la toma de Gatineau que la interfaz de su agenda copia con el\n`-05:00` de la Era 1, y que en horario de verano aparece después de su propia\nrecepción. Se ancla aquí porque la línea de custodia es donde se ve.')],
 'forense-fase-07.md': [('y el **21** —*"la lista no cambia al cambiar de orden"*, que es el `snapshot` de la última fila de la tabla.', 'el **21** —*"la lista no cambia al cambiar de orden"*, que es el `snapshot` de la última fila de la tabla— y el **22** —*"la muestra llegó al laboratorio antes de que se la sacaran al paciente"*, que también entra por el paso 5: el dato no lo escribió la aplicación, lo copió la agenda de Gatineau.')],
 'bea-08-tiempo-zonas-y-fechas-en-mongo.md': [('Cuando dos marcas así quedan a menos de una hora de una marca bien escrita —una muestra *recibida* con la constante y *validada* con el reloj del navegador—, el orden entre las dos se invierte. Es el incidente **22** del cuaderno base, y su síntoma es exactamente ese: resultados que se validaron antes de que llegara la muestra.',
                                               'Cuando una marca así queda a menos de una hora de otra bien escrita —una toma copiada con la constante por la agenda de Gatineau y una recepción estampada por el navegador—, el orden entre las dos se invierte. Es el incidente **22** del cuaderno base, y su síntoma es exactamente ese: muestras que llegaron al laboratorio antes de que se las sacaran al paciente.')],
 '00-historia-del-sistema.md': [('llegó con su fichero de pacientes en el sistema de agenda de la clínica; un script\nlos pasó a LabCore una sola vez, y nadie volvió a mirar cómo.',
                                 'llegó con su fichero de pacientes en el sistema de agenda de la clínica; un script\nlos pasó a LabCore una sola vez, y nadie volvió a mirar cómo. El punto siguió\nregistrando las tomas en esa agenda, y desde noviembre de 2020 una interfaz de la\nmisma consultora las copia a LabCore.')],
}.items():
    a = Archivo(rel)
    for x, y in pairs: a.rep(x, y)
    a.save()
print('ok')
