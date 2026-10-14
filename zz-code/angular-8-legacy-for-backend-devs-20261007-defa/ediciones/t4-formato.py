# T4: cuaderno format — the two candidates are different, the 22 in §1 and in the closing note.
import sys, os; sys.path.insert(0, os.path.dirname(__file__))
from rep import Archivo
f = Archivo('prompts/formato-cuaderno-incidentes.md')
f.rep('''curso*. Las dos dejaron anotado el mismo candidato, que **no está dado de
alta**: si algún día se abre, su sitio es el **23**. El 22 quedó reservado para
el cambio de hora (el `-05:00` constante de la Era 1 cruzando el horario de
verano), que la historia del sistema cita desde que LabCore pasó a Ottawa.''', '''curso*. Las dos dejaron anotado un candidato —distinto cada una—, y ninguno **está
dado de alta**: si algún día se abre uno, su sitio es el **23**. El 22 es el
cambio de hora (el `-05:00` constante de la Era 1 cruzando el horario de verano),
que se escribió cuando LabCore pasó a Ottawa y que se ancla en la Fase 7.''')
f.rep('''   anclan deudas 💸 declaradas en su fase.''', '''   anclan deudas 💸 declaradas en su fase.

   Y **dos son de tiempo**, con el mismo `Date` pelado debajo y causas que no se
   parecen: el borde de vigencia escrito en UTC (07) y el `-05:00` de invierno
   pegado a una toma de verano (22). Los dos nacen en un dato, no en una línea de
   la aplicación, y por eso los dos se diagnostican mirando **cómo está escrita**
   una fecha y no qué día dice.''')
f.rep('''> comportamiento vive en el código tal como se escribió. Los dos candidatos que
> quedaron anotados —el `setTextColor` que no se revierte (desde el 15) y el
> `undefined` del slice lazy que la Fase 6 dejó apuntado— pasan al **23**: el 22
> queda reservado para el cambio de hora.''', '''> comportamiento vive en el código tal como se escribió. Los dos candidatos que
> quedaron anotados —el `setTextColor` que no se revierte (desde el 15) y el
> `undefined` del slice lazy que la Fase 6 dejó apuntado— pasan al **23**.
>
> ✅ **El 22, el 07/10/2026**, con el giro a Ottawa: un cuarto
> `db.incidente-NN.json`, anclado en la Fase 7, 🟠, semana 2; reparto 7 / 8 / 4 / 3
> y escala 2 🟢 · 8 🟡 · 10 🟠 · 2 🔴, verificados contra el índice fila por fila.''')
f.save()
