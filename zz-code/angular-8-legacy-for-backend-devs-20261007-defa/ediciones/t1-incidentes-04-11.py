# T1: incident 04 (real 'medium' output for the new seed date, appDate pipe) and incident 11 (week of the data).
import sys, os; sys.path.insert(0, os.path.dirname(__file__))
from rep import Archivo
c = Archivo('cuaderno-incidentes.md')
c.rep("saliendo en español: dice '2 septiembre 2019' en medio de una pantalla que está", "saliendo en español: dice '3 ene. 2022' en medio de una pantalla que está")
c.rep("Dernière commande: 2 septiembre 2019, 8:15:00", "Dernière commande: 3 ene. 2022 8:15:00")
c.rep("pipes de `@angular/common` —`date`, `decimal`, `currency`— cambia.", "pipes de formato —`appDate` (que delega en `formatDate` de `@angular/common`), `decimal`, `currency`— cambia.")
c.rep("¿Quién le dijo al pipe `date`", "¿Quién le dijo al pipe `appDate`")
c.rep("todas de la misma semana de 2019, y ninguna la escribió esta aplicación", "todas de la primera semana de enero de 2022, y ninguna la escribió esta aplicación")
c.save()
f = Archivo('forense-fase-02.md')
f.rep("Dernière commande: 2 septiembre 2019, 8:15:00", "Dernière commande: 3 ene. 2022 8:15:00")
f.rep("lo que pasa por los pipes de `@angular/common` —`date`, `decimal`, `currency`— no.", "lo que pasa por los pipes de formato —`appDate` (que delega en `formatDate` de `@angular/common`), `decimal`, `currency`— no.")
f.rep("Y al mismo tiempo, el pipe `date` está formateando en español.", "Y al mismo tiempo, el pipe `appDate` está formateando en español.")
f.rep("y los pipes de `@angular/common` leen ese token y nada más.", "y los pipes de formato —`appDate` incluido, que lo inyecta igual que `DatePipe`— leen ese token y nada más.")
f.save()
p = Archivo('prompts/preparaciones-de-incidentes.md')
p.rep('''número mayor que uno. Tres o cuatro es suficiente, todas con `collectedAt` de la
misma semana de 2019 — que es lo que sostiene la hipótesis de la migración.''', '''número mayor que uno. Tres o cuatro es suficiente, todas con `collectedAt` de la
primera semana de enero de 2022 —la del cierre de año y la carga de la v2 de
rangos— que es lo que sostiene la hipótesis de una migración o un script de carga.''')
p.save()
