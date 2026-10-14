# T1: APP_TIME_ZONE literal in incident 19, its preparation and forense 13 (D6).
import sys, os; sys.path.insert(0, os.path.dirname(__file__))
from rep import Archivo
for rel in ['cuaderno-incidentes.md', 'forense-fase-13.md', 'prompts/preparaciones-de-incidentes.md']:
    a = Archivo(rel)
    n = a.s.count('America/Bogota')
    a.rep('America/Bogota', 'America/Toronto', count=n)
    a.save()
    print(n, rel)
