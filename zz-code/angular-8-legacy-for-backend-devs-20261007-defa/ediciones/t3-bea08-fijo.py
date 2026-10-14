# T3: precise wording for the fixed '-05:00' timezone in bea-08 §3, per salidas/t3-mongo.txt.
import sys, os; sys.path.insert(0, os.path.dirname(__file__))
from rep import Archivo
a = Archivo('bea-08-tiempo-zonas-y-fechas-en-mongo.md')
a.rep("Y un `timezone: '-05:00'` fijo no lo arregla: acierta en invierno y reparte mal una hora cada noche de verano.",
      "Y un `timezone: '-05:00'` fijo no lo arregla: acierta en invierno, y en verano manda al día anterior todo lo ocurrido entre la medianoche y la una.")
a.save()
