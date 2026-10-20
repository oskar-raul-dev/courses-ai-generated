# Filtro de árbol (git filter-branch --tree-filter): la Esclusa de Oro es un avatar (historia §3, Hoy),
# no un set de gemas. Cambia solo el prizeType de ese segmento, en el código y en mock/db.json.
import re
from pathlib import Path
for f in list(Path("src").rglob("*.js")) + list(Path("src").rglob("*.jsx")) + [Path("mock/db.json")]:
    if not f.exists():
        continue
    s = f.read_text(encoding="utf-8")
    t = s.replace('segmentId: "esclusa-de-oro", prizeType: "gemSet"', 'segmentId: "esclusa-de-oro", prizeType: "avatar"')
    t = re.sub(r'("segmentId":\s*"esclusa-de-oro",\s*"prizeType":\s*)"gemSet"', r'\1"avatar"', t)
    if t != s:
        f.write_text(t, encoding="utf-8")
