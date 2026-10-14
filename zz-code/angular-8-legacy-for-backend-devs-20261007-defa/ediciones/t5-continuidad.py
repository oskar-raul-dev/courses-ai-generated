# T5 continuity: Fase 7 header, forense-master symptom index (07 new mechanism, 22).
import sys, os; sys.path.insert(0, os.path.dirname(__file__))
from rep import Archivo
f7 = Archivo('07-muestras-custodia.md')
f7.rep('[Incidentes asociados](./cuaderno-incidentes.md): 11, 21', '[Incidentes asociados](./cuaderno-incidentes.md): 11, 21, 22')
f7.save()
fm = Archivo('forense-master.md')
fm.rep('| Un hueco en la línea de custodia, sin ningún error | [Fase 7](07-muestras-custodia.md) ⭐ — el bug se ve como un dato imposible, no como algo rojo |',
       '| Un hueco en la línea de custodia, sin ningún error | [Fase 7](07-muestras-custodia.md) ⭐ — el bug se ve como un dato imposible, no como algo rojo |\n| Una hora exacta de diferencia, desde un domingo de marzo | [Fase 7](07-muestras-custodia.md) ⭐ — un `-05:00` escrito a mano en horario de verano: mira cómo está escrita la marca, no qué hora dice |')
fm.rep('| Un veredicto de rango que cambia según la fecha, y sólo de noche | [Fase 8](08-resultados-rangos.md) — nunca es un bug de fechas: es no haber decidido la zona horaria |',
       '| Un veredicto de rango que cambia según la fecha, y sólo de noche | [Fase 8](08-resultados-rangos.md) — casi nunca es un bug de la comparación: mira si el borde está escrito en la zona de la norma |')
fm.save()
