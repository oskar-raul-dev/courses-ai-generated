# T5: README — LabCore's company and place, the cuaderno counts with incident 22, the consultancy.
import sys, os; sys.path.insert(0, os.path.dirname(__file__))
from rep import Archivo
r = Archivo('README.md')
r.rep('''> **LabCore** es el sistema de gestión de laboratorio clínico que tu equipo
> heredó. Lo escribió entre 2019 y 2021 un equipo que ya no está, hoy está en
> mantenimiento y tiene decomisión prevista en dos o tres años.''', '''> **LabCore** es el sistema de gestión de laboratorio clínico de Andina
> Laboratories Inc., una red chica de laboratorio con sede en Ottawa y puntos de
> toma a los dos lados del río, en Ottawa y en Gatineau. Lo escribió entre 2019 y
> 2021 una consultora cuyo equipo ya no está, hoy está en mantenimiento y tiene
> decomisión prevista en dos o tres años.''')
r.rep('''**veintiún tickets vagos, escritos**, con su preparación, tres pistas escalonadas
y la solución colapsada, que se trabajan **sin instructor**. Los veintiún IDs los''', '''**veintidós tickets vagos, escritos**, con su preparación, tres pistas escalonadas
y la solución colapsada, que se trabajan **sin instructor**. Los veintidós IDs los''')
r.rep('''La escala quedó en **2 🟢 · 8 🟡 · 9 🟠 · 2 🔴**, repartidos 7 / 7 / 4 / 3 por
semana: el curso carga incidentes en las fases que producen material y se
aligera al final, cuando ya estás desplegando. Y **no todos terminan en fix**:
seis de ellos —el 03, el 04, el 07, el 11, el 12 y el 17— terminan en un''', '''La escala quedó en **2 🟢 · 8 🟡 · 10 🟠 · 2 🔴**, repartidos 7 / 8 / 4 / 3 por
semana: el curso carga incidentes en las fases que producen material y se
aligera al final, cuando ya estás desplegando. Las 14h son el presupuesto del
calendario, no la suma de los tiempos sugeridos, que es mayor. Y **no todos
terminan en fix**: siete de ellos —el 03, el 04, el 07, el 11, el 12, el 17 y el
22— terminan en un''')
r.rep('''otro frente del equipo contratado de 2019 en **Java 8 + Spring Boot 2.1 sobre un''', '''otro frente de la misma consultora en 2019, en **Java 8 + Spring Boot 2.1 sobre un''')
r.rep('''los **veintiún incidentes** de''', '''los **veintidós incidentes** de''')
r.save()
