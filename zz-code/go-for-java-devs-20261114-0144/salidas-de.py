#!/usr/bin/env python3
"""Lista lo que una fase da como salida: bloques text, bloques bash con líneas '# salida'
y, de los bloques go, solo las líneas de comentario que parecen salida o error del compilador.
Uso: python3 salidas-de.py FASE.md"""
import re, sys
L = open(sys.argv[1], encoding="utf-8").read().splitlines()
GO = re.compile(r"//.*(❌|✅|cannot|undefined|panic|declared|imprime|salida:|imported|invalid|missing|does not|<nil>|^\s*//\s*[\[\{0-9\"]|\b(true|false)\b\s*$|=>|→ )")
i = 0
while i < len(L):
    m = re.match(r"^(`{3,})(\S*)", L[i])
    if not m: i += 1; continue
    v, lang = m.group(1), m.group(2); j = i + 1
    while j < len(L) and L[j].strip() != v: j += 1
    body = L[i+1:j]
    if lang in ("text", "console"):
        print(f"── L{i+1} {lang}"); [print(f"{i+2+k}: {b}") for k, b in enumerate(body)]
    elif lang in ("bash", "sh", "powershell"):
        seen_cmd = False; out = False
        for b in body:
            if b.strip() and not b.lstrip().startswith("#"): seen_cmd = True
            elif seen_cmd and re.match(r"^#\s+\S", b) and not re.search(r"[a-záéíóú]{3,} [a-záéíóú]{3,} [a-záéíóú]{3,} [a-záéíóú]{4,}", b): out = True
        if out:
            print(f"── L{i+1} {lang}"); [print(f"{i+2+k}: {b}") for k, b in enumerate(body)]
    elif lang == "go":
        hits = [(i+2+k, b) for k, b in enumerate(body) if GO.search(b)]
        if hits:
            print(f"── L{i+1} go (líneas con salida)"); [print(f"{n}: {b}") for n, b in hits]
    i = j + 1
