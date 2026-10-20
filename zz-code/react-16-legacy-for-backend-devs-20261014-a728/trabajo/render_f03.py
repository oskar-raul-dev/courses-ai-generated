# Renderiza la plantilla de F03: los marcadores <<<archivo:RUTA>>> se sustituyen por el contenido
# del archivo probado (bloque de código), para que lo que el lector copia sea lo que corrió.
import json, re, sys
from pathlib import Path

PLANTILLA = Path(sys.argv[1]); RAIZ = Path(sys.argv[2]); SALIDA = Path(sys.argv[3])
LENG = {".js": "javascript", ".jsx": "jsx", ".json": "json", ".scss": "scss", ".md": "markdown"}

def bloque(ruta):
    rel = ruta.strip()
    if rel == "package.json":  # solo los scripts: el resto de la forma del paquete está en decisiones §3
        texto = json.dumps({"scripts": json.loads((RAIZ / rel).read_text(encoding="utf-8"))["scripts"]}, indent=2, ensure_ascii=False)
        return "```json\n" + texto + "\n```"
    f = RAIZ / rel
    return "```" + LENG.get(f.suffix, "") + "\n" + f.read_text(encoding="utf-8").rstrip("\n") + "\n```"

s = PLANTILLA.read_text(encoding="utf-8")
s, n = re.subn(r"<<<archivo:([^>]+)>>>", lambda m: bloque(m.group(1)), s)
SALIDA.write_text(s, encoding="utf-8")
print("marcadores sustituidos:", n)
