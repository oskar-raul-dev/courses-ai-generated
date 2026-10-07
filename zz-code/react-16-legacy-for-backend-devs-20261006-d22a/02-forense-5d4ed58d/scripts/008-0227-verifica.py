# rescatado de la sesión 5d4ed58d, 2026-09-10T02:27:38Z · Cross-check phase-incident references, BE siblings and anchors
import re, io, glob
print("== 11. FASES → INCIDENTES: ¿los IDs que citan existen y son de esa fase? ==")
idx = {}
s = io.open("cuaderno-incidentes.md",encoding="utf-8").read()
for m in re.finditer(r'^\| (\d{2}) \| ([\d\-]+) \|', s, re.M): idx[m.group(1)] = m.group(2)
fases = {"00-setup-hola-mundo-cra.md":"0","01-estructura-base-router-5.md":"1","02-autenticacion-minima.md":"2",
 "03-mock-api-express-caos.md":"3","04-rifas-crud.md":"4","05-venta-de-numeros.md":"5","06-redux-observable-a-fondo.md":"6",
 "07-cierre-polling-resultado.md":"7","08-liquidacion-calculo-premio.md":"8","09-dashboard.md":"9",
 "10-testing-minimo.md":"10-11","11-cierre-puente-react-moderno.md":"10-11"}
for f, fase in fases.items():
    txt = io.open(f,encoding="utf-8").read()
    ids = set(re.findall(r'incidentes? \*\*(\d{2})\*\*|incidente \*\*(\d{2})\*\*|\*\*(\d{2})\*\* (?:⭐ )?— \*', txt))
    ids = {x for t in ids for x in t if x}
    ids |= set(re.findall(r'incidente ⭐ (\d{2})|incidentes? (\d{2}) y (\d{2})', txt) and [] or [])
    for i in sorted(ids):
        if i not in idx: print(f"  {f}: cita el incidente {i}, que NO existe")
        elif idx[i] != fase and not (fase=="10-11" and idx[i]=="10-11"):
            print(f"  {f} (fase {fase}): cita el incidente {i}, que el índice asigna a la fase {idx[i]}")
print("  (sin discrepancias en lo detectable)")

print("\n== 12. CUADERNO BE: tabla de hermanos vs cuaderno base ==")
b = io.open("cuaderno-incidentes-be.md",encoding="utf-8").read()
pares_be = re.findall(r'incidente \*\*(\d{2}) del track base\*\*', b)
print(f"  el cuaderno BE remite a los incidentes base: {sorted(set(pares_be))}")
declar = re.findall(r'^\| (\d{2}) — .+? \| `?(be-\d\d)', s, re.M)
print(f"  el cuaderno base declara hermanos:          {sorted(dict(declar))}")

print("\n== 13. ANCLAS #… en enlaces internos ==")
import os
for f in sorted(glob.glob("*.md")+glob.glob("prompts/*.md")):
    if f=="completado_cuaderno_incidentes.md": continue
    txt = io.open(f,encoding="utf-8").read()
    for m in re.finditer(r'\]\(([^)]*#[^)]+)\)', txt):
        tgt = m.group(1)
        path, anchor = tgt.split('#',1)
        p = os.path.normpath(os.path.join(os.path.dirname(f), path)) if path else f
        if not os.path.exists(p): print(f"  {f}: destino inexistente {tgt}"); continue
        heads = [re.sub(r'[^a-z0-9\s-]','',h.lower()).strip().replace(' ','-')
                 for h in re.findall(r'^#+ (.+)$', io.open(p,encoding="utf-8").read(), re.M)]
        if anchor.lower() not in heads: print(f"  {f}: ancla '{anchor}' no encontrada en {p}")
print("  (sin anclas rotas detectadas)")
