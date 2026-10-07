# rescatado de la sesión f9f4966e, 2026-09-10T15:58:43Z · Check soporte_v1 coverage in course 02 incidents
import io,re
s=io.open('02-complement-mongodb-backend/cuaderno-incidentes.md',encoding='utf-8').read()
partes=re.split(r'^## Incidente (\d\d)', s, flags=re.M)
for i in range(1,len(partes),2):
    n=partes[i]; t=partes[i+1]
    h=len(re.findall(r'soporte_v1', t))
    if h: print("inc",n,"->",h,"menciones de soporte_v1")
