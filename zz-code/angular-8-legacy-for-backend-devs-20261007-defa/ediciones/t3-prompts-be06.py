# T3: the be06 question and evidence in the BE prompts, with the new timeline.
import sys, os; sys.path.insert(0, os.path.dirname(__file__))
from rep import Archivo
f = Archivo('prompts/prompts-backend-fase.md')
f.rep('*"¿qué rango de glucosa estaba vigente el 12\n  de marzo de 2020?"*', '*"¿qué rango de glucosa estaba vigente el 12\n  de octubre de 2022?"*')
f.save()
p = Archivo('prompts/propuesta-fases-backend.md')
n = p.s.count('marzo de\n2020?"*') + p.s.count('marzo de 2020?"*')
if 'marzo de\n2020?"*' in p.s: p.rep('marzo de\n2020?"*', 'octubre de\n2022?"*')
if 'marzo de 2020?"*' in p.s: p.rep('marzo de 2020?"*', 'octubre de 2022?"*')
p.rep('un resultado validado en 2020 cuyo `rangeVersionApplied`', 'un resultado validado en 2022 cuyo `rangeVersionApplied`')
p.save()
print('propuesta:', n)
# (second pass) the forense line of prompts-backend-fase
g = Archivo('prompts/prompts-backend-fase.md')
if 'un resultado validado en 2020 cuyo `rangeVersionApplied`' in g.s:
    g.rep('un resultado validado en 2020 cuyo `rangeVersionApplied`', 'un resultado validado en 2022 cuyo `rangeVersionApplied`'); g.save()
