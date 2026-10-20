# Para cada archivo probado, comprueba que su contenido (normalizado) aparece como bloque de código de la fase.
# Uso: python3 comparar-bloques.py <fase.md> <raiz-del-proyecto> <archivo> [<archivo> ...]
import re, sys
from pathlib import Path
doc = Path(sys.argv[1]).read_text(encoding="utf-8")
raiz = Path(sys.argv[2])
bloques = [b for _, b in re.findall(r"```(\w+)?\n(.*?)```", doc, re.S)]
def norm(s): return "\n".join(l.rstrip() for l in s.strip().splitlines())
def sin_ruta(b):
    # el documento abre cada bloque con su ruta (// src/…); no forma parte del archivo
    lineas = b.strip().splitlines()
    if lineas and lineas[0].startswith(("// src/", "// mock/")):
        lineas = lineas[1:]
    return "\n".join(lineas)
bloques_n = [norm(sin_ruta(b)) for b in bloques]
todo = True
for rel in sys.argv[3:]:
    real = norm((raiz / rel).read_text(encoding="utf-8"))
    ok = real in bloques_n
    todo &= ok
    print(("OK      " if ok else "DIFIERE ") + rel)
print("todo idéntico:", todo)
