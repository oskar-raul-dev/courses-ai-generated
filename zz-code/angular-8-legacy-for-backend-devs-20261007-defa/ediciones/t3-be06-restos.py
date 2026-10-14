# T3: leftovers of the be06 timeline in be06 itself and in the BE cuaderno.
import sys, os; sys.path.insert(0, os.path.dirname(__file__))
from rep import Archivo
b6 = Archivo('be06-los-rangos-y-la-historia-perdida.md')
b6.rep('Por eso este problema sobrevivió seis años sin un solo ticket.', 'Por eso este problema sobrevivió tres años sin un solo ticket.')
b6.save()
cb = Archivo('cuaderno-incidentes-be.md')
cb.rep('> *"Un paciente trajo su informe de glucosa de marzo de 2020, impreso, donde dice', '> *"Un paciente trajo su informe de glucosa de octubre de 2022, impreso, donde dice')
cb.rep('`$set` de 2020.', '`$set` de 2023.')
cb.rep('En agosto de 2020, cuando la norma bajó el límite superior de glucosa de 100 a', 'En marzo de 2023, cuando la norma bajó el límite superior de glucosa de 100 a')
cb.rep('El resultado de marzo de 2020 vale 99,4 y dice haberse juzgado', 'El resultado de octubre de 2022 vale 99,4 y dice haberse juzgado')
cb.rep('Porque quien ejecutó el `$set` en 2020 hizo lo que su modelo mental indicaba', 'Porque quien ejecutó el `$set` en 2023 hizo lo que su modelo mental indicaba')
cb.save()
