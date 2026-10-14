# T1: the history said "no time zone anywhere"; since Fase 02 there is one, used only to display.
import sys, os; sys.path.insert(0, os.path.dirname(__file__))
from rep import Archivo
h = Archivo('00-historia-del-sistema.md')
h.rep('''refresh token. No hay paginación de servidor. No hay zona horaria en ningún
lado: solo desfases.''','''refresh token. No hay paginación de servidor. No hay zona horaria en los datos:
solo desfases; la única zona del sistema vive en la configuración y sirve para
mostrar fechas, no para compararlas.''')
h.save()
