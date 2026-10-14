# T4 prerequisite: the Fase 05 seed generated 2019 Jan-Sep dates with the winter offset; now Dec 2021 - Feb 2022.
# pick() consumes exactly one random() like the old month draw, so every other seeded value stays the same.
import sys, os; sys.path.insert(0, os.path.dirname(__file__))
from rep import Archivo
a = Archivo('05-pacientes.md')
a.rep('''var SEEDABLE_ORDER_STATUSES = ['pending', 'in_process', 'partial_results', 'complete'];
''', '''var SEEDABLE_ORDER_STATUSES = ['pending', 'in_process', 'partial_results', 'complete'];

// Los meses que se siembran: diciembre a febrero, el invierno de LabCore ya en
// producción. Todas las fechas llevan el -05:00 que la Era 1 escribe como
// constante, y en invierno ese desfase es verdad. Sembrar julio con -05:00
// sería sembrar el incidente 22 en datos que no lo anuncian.
var SEED_MONTHS = ['2021-12', '2022-01', '2022-02'];
''')
a.rep('''    var createdAt = '2019-' + pad(1 + Math.floor(random() * 9), 2) + '-' +
                    pad(1 + Math.floor(random() * 28), 2) + 'T08:15:00-05:00';''', '''    var createdAt = pick(SEED_MONTHS) + '-' +
                    pad(1 + Math.floor(random() * 28), 2) + 'T08:15:00-05:00';''')
a.save()
