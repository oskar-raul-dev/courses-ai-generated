# Compara los bloques de la raíz del curso con los archivos probados en trabajo/.
# Uso: python3 comparar-con-doc.py <ruta-a-la-raiz-del-curso> <dir-de-trabajo-de-T0>
import json, re, sys
from pathlib import Path

curso, trabajo = Path(sys.argv[1]), Path(sys.argv[2])
doc = (curso / "00-decisiones-y-versiones.md").read_text(encoding="utf-8")
pj = re.search(r"```json\n(.*?)```", doc, re.S).group(1)
probado = json.loads((trabajo / "paquete/package.json").read_text(encoding="utf-8"))
print("package.json del doc == probado (JSON):", json.loads(pj) == probado)
gm = re.search(r"```\n(module .*?)```", doc, re.S).group(1)
print("go.mod del doc == probado (texto):", gm.strip() == (trabajo / "gomod/go.mod").read_text(encoding="utf-8").strip())
