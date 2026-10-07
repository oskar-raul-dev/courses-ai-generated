# rescatado de la sesión f9f4966e, 2026-09-10T02:52:30Z · Check concurrency coverage in notebooks
import io,re
s=io.open('cuaderno-incidentes.md',encoding='utf-8').read()
partes=re.split(r'^## Incidente (\d\d)', s, flags=re.M)
for i in range(1,len(partes),2):
    n=partes[i]; t=partes[i+1]
    hits=len(re.findall(r'concurren|carrera|race|atómic|findOneAndUpdate|precondición', t, re.I))
    if hits: print(" inc",n,"->",hits,"menciones")
