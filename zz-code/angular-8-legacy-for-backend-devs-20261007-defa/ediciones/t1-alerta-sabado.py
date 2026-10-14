# T1: incident 07 is no longer "the Saturday alert" but the critical of New Year's Eve.
import sys, os; sys.path.insert(0, os.path.dirname(__file__))
from rep import Archivo
for rel in ['prompts/formato-cuaderno-incidentes.md', 'cuaderno-incidentes.md']:
    a = Archivo(rel)
    n = a.s.count('la alerta del sábado')
    if n:
        a.rep('la alerta del sábado', 'el crítico de Nochevieja', count=n); a.save()
    print(n, rel)
