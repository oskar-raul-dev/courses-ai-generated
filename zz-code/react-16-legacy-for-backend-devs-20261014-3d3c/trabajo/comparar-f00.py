# Compara los bloques de F00 con los archivos probados en esclusa-app/. Uso: python3 comparar-f00.py <raiz-del-curso> <esclusa-app>
import re, sys, json
from pathlib import Path
doc = (Path(sys.argv[1]) / "00-setup-hola-mundo-cra.md").read_text(encoding="utf-8")
app = Path(sys.argv[2])
blocks = re.findall(r"```(\w+)?\n(.*?)```", doc, re.S)
def norm(s): return "\n".join(l.rstrip() for l in s.strip().splitlines())
pares = {
 "package.json": app/"package.json",
 "public/index.html": app/"public/index.html",
 "src/App.js": app/"src/App.js",
 "src/components/WheelCard.jsx": app/"src/components/WheelCard.jsx",
 "src/styles/_tokens.scss": app/"src/styles/_tokens.scss",
 "src/index.scss": app/"src/index.scss",
}
ok = True
for nombre, archivo in pares.items():
    real = norm(archivo.read_text(encoding="utf-8"))
    coincide = [b for _, b in blocks if norm(b) == real]
    if coincide:
        print(f"OK     {nombre}: bloque idéntico al probado")
    else:
        ok = False
        # buscar el bloque más parecido por primera línea de código
        primera = real.splitlines()[0]
        cand = [b for _, b in blocks if primera in b]
        print(f"DIFIERE {nombre}: {len(cand)} bloque(s) con la primera línea; revisar")
# index.js: el final es el de §5.6
real_idx = norm((app/"src/index.js").read_text(encoding="utf-8"))
print("OK     src/index.js (final): ", any(norm(b)==real_idx for _,b in blocks) or "DIFIERE, ver bloques con ReactDOM.render")
print("todo idéntico:", ok)
