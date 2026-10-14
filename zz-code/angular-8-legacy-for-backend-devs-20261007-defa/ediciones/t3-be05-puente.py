# T3: be05's bridge to be06 quotes the auditor's question.
import sys, os; sys.path.insert(0, os.path.dirname(__file__))
from rep import Archivo
a = Archivo('be05-la-cadena-de-custodia-y-la-transaccion.md')
a.rep('*"¿Qué rango de glucosa estaba vigente el 12 de marzo de 2020?"*', '*"¿Qué rango de glucosa estaba vigente el 12 de octubre de 2022?"*')
a.save()
