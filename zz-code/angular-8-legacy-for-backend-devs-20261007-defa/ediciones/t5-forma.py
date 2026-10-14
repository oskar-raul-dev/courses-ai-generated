# T5 form: a peninsular verb in bea-02.
import sys, os; sys.path.insert(0, os.path.dirname(__file__))
from rep import Archivo
a = Archivo('bea-02-receta-de-imagen-y-compose.md')
a.rep('una costumbre que conviene no coger.', 'una costumbre que conviene no adoptar.')
a.save()
