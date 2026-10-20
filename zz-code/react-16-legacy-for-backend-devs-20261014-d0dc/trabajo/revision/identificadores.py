"""Revisión de continuidad: identificadores que define el repo de prueba en un tag, contra el diccionario.
Uso: python3 identificadores.py <repo> <tag> <diccionario.md>"""
import re, subprocess, sys
repo, tag, dic = sys.argv[1:4]
texto_dic = open(dic, encoding="utf-8").read()
archivos = subprocess.run(["git", "-C", repo, "ls-tree", "-r", "--name-only", tag, "src", "mock", "scripts"],
                          capture_output=True, text=True).stdout.split()
patrones = [
    r"export\s+(?:default\s+)?(?:const|function|class)\s+([A-Za-z_]\w*)",
    r"^(?:const|function|class)\s+([A-Za-z_]\w*)",
    r"createAsyncThunk\(\s*\"([^\"]+)\"",
    r"name:\s*\"([a-z]\w*)\"",
    r"app\.(?:get|post|put|patch|delete|use)\(\s*\"([^\"]+)\"",
    r"path=\"([^\"]+)\"",
]
vistos = {}
for a in archivos:
    if not re.search(r"\.(js|jsx)$", a):
        continue
    src = subprocess.run(["git", "-C", repo, "show", f"{tag}:{a}"], capture_output=True, text=True).stdout
    for p in patrones:
        for m in re.finditer(p, src, re.M):
            vistos.setdefault(m.group(1), a)
    # campos del initialState
    m = re.search(r"initialState\s*=\s*\{([^}]*)\}", src) or re.search(r"initialState:\s*\{([^}]*)\}", src)
    if m:
        for c in re.findall(r"(\w+)\s*:", m.group(1)):
            vistos.setdefault(c, a + " (initialState)")
faltan = sorted((k, v) for k, v in vistos.items() if k not in texto_dic)
print(f"{tag}: {len(vistos)} identificadores, {len(faltan)} fuera del diccionario")
for k, v in faltan:
    print(f"  {k:32} {v}")
