#!/usr/bin/env python3
"""Pasa gofmt por los bloques go de las fases que son archivos completos (tienen `package`)
y reescribe en el .md los que cambian. Usa gofmt dentro del contenedor.
Uso: python3 gofmt-curso.py [--aplicar] FASE.md...   (sin --aplicar solo informa)"""
import pathlib, re, subprocess, sys, tempfile
args = [a for a in sys.argv[1:] if not a.startswith("--")]; aplicar = "--aplicar" in sys.argv; FRAG = "--fragmentos" in sys.argv
tmp = pathlib.Path(tempfile.mkdtemp(prefix="gofmt-", dir=pathlib.Path(__file__).parent / "salidas"))
idx = []
for f in args:
    L = pathlib.Path(f).read_text(encoding="utf-8").split("\n")
    i = 0
    while i < len(L):
        m = re.match(r"^(`{3,})go\s*$", L[i])
        if not m: i += 1; continue
        j = i + 1
        while j < len(L) and L[j].strip() != m.group(1): j += 1
        body = L[i+1:j]
        if any(re.match(r"^package \w+", b) for b in body):
            n = len(idx); (tmp / f"b{n}.go").write_text("\n".join(body) + "\n", encoding="utf-8")
            idx.append((f, i + 1, j, "archivo"))
        elif FRAG and body:
            # Fragmento: primero como declaraciones de paquete; si no parsea, como cuerpo de función.
            n = len(idx); (tmp / f"b{n}.go").write_text("package p\n" + "\n".join(body) + "\n", encoding="utf-8")
            (tmp / f"b{n}.fn.go.txt").write_text("package p\nfunc _() {\n" + "\n".join(body) + "\n}\n", encoding="utf-8")
            idx.append((f, i + 1, j, "fragmento"))
        i = j + 1
r = subprocess.run(["docker", "run", "--rm", "--label", "curso=go-for-java-devs", "-v", f"{tmp}:/b", "golang:1.25.1-bookworm",
                    "sh", "-c", "cd /b && for f in *.go; do gofmt -l $f >/dev/null 2>/b/$f.err || true; gofmt -w $f 2>/dev/null; "
                    "g=${f%.go}.fn.go.txt; if [ -s /b/$f.err ] && [ -f $g ]; then cp $g /tmp/x.go; if gofmt -w /tmp/x.go 2>/dev/null; then cp /tmp/x.go $f; : > /b/$f.err; echo fn > /b/$f.modo; fi; fi; done"],
                   capture_output=True, text=True)
cambios = {}
for n, (f, ini, fin, tipo) in enumerate(idx):
    err = (tmp / f"b{n}.go.err").read_text()
    new = (tmp / f"b{n}.go").read_text().rstrip("\n").split("\n")
    if tipo == "fragmento" and not err.strip():
        if (tmp / f"b{n}.go.modo").exists():
            a = new.index("func _() {"); b = len(new) - 1 - new[::-1].index("}")
            new = [l[1:] if l.startswith("\t") else l for l in new[a+1:b]]  # quita func _() { … } y un nivel
        else:
            new = new[1:]  # quita package p
            while new and new[0] == "": new = new[1:]
    if tipo == "fragmento" and err.strip():
        continue
    if tipo == "fragmento":
        old_ = pathlib.Path(f).read_text(encoding="utf-8").split("\n")[ini:fin]
        sin = lambda x: re.sub(r"\s+", "", x)
        if len(new) != len(old_) or any(sin(a) != sin(b) for a, b in zip(old_, new)):
            continue  # gofmt cambiaría la forma (un { } compacto, líneas nuevas): se respeta el fragmento  # no parsea ni como declaraciones ni como cuerpo: tiene "..." o es pseudocódigo
    old = pathlib.Path(f).read_text(encoding="utf-8").split("\n")[ini:fin]
    if err.strip():
        print(f"no parsea  {pathlib.Path(f).name}:{ini+1}  {err.strip().splitlines()[0][:90]}")
    elif new != old:
        print(f"gofmt      {pathlib.Path(f).name}:{ini+1}  ({sum(1 for a,b in zip(old,new) if a!=b)} líneas)")
        cambios.setdefault(f, []).append((ini, fin, new))
if aplicar:
    for f, lst in cambios.items():
        L = pathlib.Path(f).read_text(encoding="utf-8").split("\n")
        for ini, fin, new in sorted(lst, reverse=True):
            L[ini:fin] = new
        pathlib.Path(f).write_text("\n".join(L), encoding="utf-8")
print(f"{len(idx)} bloques completos, {sum(len(v) for v in cambios.values())} con cambios")
