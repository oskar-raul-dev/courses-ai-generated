# Extrae del .md, tal cual, los ejemplos de A5 §7 y A6 §6 (createSlice) a módulos de prueba.
# Uso: python3 extraer-ejemplos-apendices.py <raiz-del-curso> <directorio-de-salida>
import re, sys
from pathlib import Path
curso, salida = Path(sys.argv[1]), Path(sys.argv[2]); salida.mkdir(parents=True, exist_ok=True)
a5 = (curso / "A5-class-components-vs-hooks.md").read_text(encoding="utf-8")
b = [x for x in re.findall(r"```jsx\n(.*?)```", a5, re.S) if "function requestReducer" in x][0]
(salida / "a5Request.jsx").write_text('import React, { useReducer } from "react";\n' + b + "\nexport { requestReducer, ResendButton };\n", encoding="utf-8")
a6 = (curso / "A6-redux-clasico-vs-toolkit.md").read_text(encoding="utf-8")
b = [x for x in re.findall(r"```javascript\n(.*?)```", a6, re.S) if "una versión reducida del de F05" in x][0]
(salida / "a6GrantSlice.js").write_text(b, encoding="utf-8")
print("extraídos:", sorted(p.name for p in salida.iterdir()))
