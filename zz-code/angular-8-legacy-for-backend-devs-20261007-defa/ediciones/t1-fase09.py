# T1: Fase 09 PDF date comment (zone only; the 'es-CO' locale is T2).
import sys, os; sys.path.insert(0, os.path.dirname(__file__))
from rep import Archivo
a = Archivo('09-entrega-pdf.md')
a.rep('''  // Formatea una fecha ISO en la zona de la aplicación (America/Bogotá, fijada
  // en environment desde la Fase 2). Se usa toLocaleString con timeZone porque
  // acá no corre el pipe date de Angular: estamos fuera de una plantilla.''','''  // Formatea una fecha ISO en la zona de la aplicación (America/Toronto, fijada
  // en environment desde la Fase 2). Se usa toLocaleString con timeZone porque
  // acá no corre ningún pipe: estamos fuera de una plantilla. Y a diferencia de
  // formatDate, toLocaleString sí entiende un identificador IANA, con el
  // horario de verano incluido.''')
a.save()
