# T3: be08 and bea-12 still quoted the old be06 timeline (v2 from 2019, $set in 2020).
import sys, os; sys.path.insert(0, os.path.dirname(__file__))
from rep import Archivo
b8 = Archivo('be08-la-contencion-y-lo-irrecuperable.md')
b8.rep('> — *¿Pueden demostrar contra qué rango se validó este resultado de 2020?*', '> — *¿Pueden demostrar contra qué rango se validó este resultado de 2022?*', 2)
b8.rep('''// Nótese lo que esto implica: el $set del §4.2 de be06 habría FALLADO, en
// 2020, con un error de permisos, y alguien habría tenido que preguntar por
// qué. Toda la fase be06 existe porque nadie puso esta línea hace siete años.''','''// Nótese lo que esto implica: el $set del §4.2 de be06 habría FALLADO, en
// 2023, con un error de permisos, y alguien habría tenido que preguntar por
// qué. Toda la fase be06 existe porque nadie puso esta línea en 2019.''')
b8.rep('''entre junio de 2019 y agosto de 2020. Son 1.204 resultados, de los cuales 37''', '''entre enero de 2022 y marzo de 2023. Son 1.204 resultados, de los cuales 37''')
b8.save()
b12 = Archivo('bea-12-datos-de-prueba-y-volumen.md')
b12.rep("con `high: 99` y su `effectiveFrom` de 2019 intacto. El `$set` de 2020 ya ocurrió:", "con `high: 99` y su `effectiveFrom` de 2022 intacto. El `$set` de 2023 ya ocurrió:")
b12.rep("conserve también la versión anterior al `$set` de 2020.", "conserve también la versión anterior al `$set` de 2023.")
b12.save()
