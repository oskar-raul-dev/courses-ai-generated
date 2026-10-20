# T3: el devcontainer.json publicado es JSON válido una vez quitados los comentarios // de línea.
import json, re, sys
texto = open(sys.argv[1], encoding="utf-8").read()
sin = "\n".join(re.sub(r'^\s*//.*$', '', l) for l in texto.splitlines())
d = json.loads(sin)
print("OK", sorted(d))
