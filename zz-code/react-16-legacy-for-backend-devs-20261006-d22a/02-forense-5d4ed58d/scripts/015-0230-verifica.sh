# rescatado de la sesión 5d4ed58d, 2026-09-10T02:30:26Z · Inspect the end of section 6 in the phases missing incident links
for f in 01-estructura-base-router-5.md 04-rifas-crud.md 05-venta-de-numeros.md 06-redux-observable-a-fondo.md 07-cierre-polling-resultado.md 10-testing-minimo.md; do echo "=========== $f — últimas líneas de §6"; python3 -c "
import re,io,sys
s=io.open('$f',encoding='utf-8').read()
m=re.search(r'^## ⚠️ 6\..*?(?=^## 🧪 7\.)', s, re.M|re.S)
print('\n'.join(m.group(0).rstrip().split('\n')[-4:]))
"; done
