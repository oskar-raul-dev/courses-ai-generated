# rescatado de la sesión 5d4ed58d, 2026-09-10T02:30:09Z · Check phase section 6 incident links and read notebook tail
import re, io
fases = {"00-setup-hola-mundo-cra.md":["01","02"],"01-estructura-base-router-5.md":["03","04"],
"02-autenticacion-minima.md":["05","06"],"03-mock-api-express-caos.md":["07","08"],
"04-rifas-crud.md":["09","10"],"05-venta-de-numeros.md":["11","12"],
"06-redux-observable-a-fondo.md":["13","14","15"],"07-cierre-polling-resultado.md":["16","17"],
"08-liquidacion-calculo-premio.md":["18"],"09-dashboard.md":["19"],"10-testing-minimo.md":["20"]}
for f, ids in fases.items():
    s=io.open(f,encoding="utf-8").read()
    m=re.search(r'^## ⚠️ 6\..*?(?=^## 🧪 7\.)', s, re.M|re.S)
    sec6 = m.group(0) if m else ""
    falt=[i for i in ids if re.search(rf'\*\*{i}\*\*', sec6) is None]
    print(f"  {f}: {'✓ menciona ' + ', '.join(ids) if not falt else '⚠️ §6 NO menciona ' + ', '.join(falt)}")
