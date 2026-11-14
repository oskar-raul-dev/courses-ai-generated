#!/usr/bin/env python3
"""Añade a los bloques go completos del curso los imports de la biblioteca estándar que les
faltan (según goimports), sin quitar ninguno. Uso: python3 imports-curso.py [--aplicar] FASE.md..."""
import pathlib, re, subprocess, sys, tempfile
args = [a for a in sys.argv[1:] if not a.startswith("--")]; aplicar = "--aplicar" in sys.argv
tmp = pathlib.Path(tempfile.mkdtemp(prefix="imp-", dir=pathlib.Path(__file__).parent / "salidas"))
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
        if any(re.match(r"^package \w+", b) for b in body) and not any("..." in b and not b.lstrip().startswith("//") for b in body):
            n = len(idx); (tmp / f"b{n}.go").write_text("\n".join(body) + "\n", encoding="utf-8")
            idx.append((f, i + 1, j))
        i = j + 1
subprocess.run(["docker", "run", "--rm", "--label", "curso=go-for-java-devs", "-v", "gfjd-gopath:/go", "-v", f"{tmp}:/b",
                "golang:1.25.1-bookworm", "sh", "-c",
                "export PATH=$PATH:/go/bin; command -v goimports >/dev/null || go install golang.org/x/tools/cmd/goimports@v0.36.0 >/dev/null 2>&1; "
                "cd /b && for f in b*.go; do goimports $f > $f.out 2>$f.err || true; done"], check=True)
def imps(lines):
    out, dentro = set(), False
    for l in lines:
        if l.startswith("import ("): dentro = True; continue
        if dentro and l.strip() == ")": dentro = False; continue
        m = re.match(r'^import "([^"]+)"', l) or (re.match(r'^\s*(?:\w+ )?"([^"]+)"', l) if dentro else None)
        if m: out.add(m.group(1))
    return out
EXTERNOS = {
    "bson": "go.mongodb.org/mongo-driver/v2/bson", "mongo": "go.mongodb.org/mongo-driver/v2/mongo",
    "options": "go.mongodb.org/mongo-driver/v2/mongo/options", "valkey": "github.com/valkey-io/valkey-go",
    "singleflight": "golang.org/x/sync/singleflight", "errgroup": "golang.org/x/sync/errgroup",
    "pgconn": "github.com/jackc/pgx/v5/pgconn", "pgxpool": "github.com/jackc/pgx/v5/pgxpool",
    "goose": "github.com/pressly/goose/v3", "require": "github.com/stretchr/testify/require",
    "prometheus": "github.com/prometheus/client_golang/prometheus", "promhttp": "github.com/prometheus/client_golang/prometheus/promhttp",
}
def externos_que_faltan(body, presentes):
    usados = set(re.findall(r"(?<![\w.])([a-z]+)\.[A-Z]", "\n".join(l for l in body if not l.lstrip().startswith("//"))))
    nombres = {i.rsplit("/", 1)[-1] for i in presentes} | {re.sub(r"/v\d+$", "", i).rsplit("/", 1)[-1] for i in presentes}
    return sorted(EXTERNOS[u] for u in usados if u in EXTERNOS and u not in nombres and EXTERNOS[u] not in presentes)
cambios = {}
for n, (f, ini, fin) in enumerate(idx):
    out = (tmp / f"b{n}.go.out").read_text().split("\n")
    if not any(out): out = pathlib.Path(f).read_text(encoding="utf-8").split("\n")[ini:fin]
    old = pathlib.Path(f).read_text(encoding="utf-8").split("\n")[ini:fin]
    faltan = sorted(i for i in imps(out) - imps(old) if "." not in i.split("/")[0]) + externos_que_faltan(old, imps(old))
    if faltan:
        print(f"{pathlib.Path(f).name}:{ini+1}  faltan {', '.join(faltan)}")
        cambios.setdefault(f, []).append((ini, fin, faltan))
if aplicar:
    for f, lst in cambios.items():
        L = pathlib.Path(f).read_text(encoding="utf-8").split("\n")
        for ini, fin, faltan in sorted(lst, reverse=True):
            blk = L[ini:fin]
            k = next((x for x, l in enumerate(blk) if l.startswith("import (")), None)
            if k is not None:
                # tras el último import de la stdlib del grupo (los de módulo van después de una línea en blanco)
                e = k + 1
                while e < len(blk) and blk[e].strip() != ")" and blk[e].strip() != "": e += 1
                std = [x for x in faltan if "." not in x.split("/")[0]]; ext = [x for x in faltan if x not in std]
                grupo = sorted(set(l.strip() for l in blk[k+1:e]) | {f'"{x}"' for x in std})
                blk[k+1:e] = ["\t" + g for g in grupo]
                if ext:
                    cierre = next(x for x in range(k+1, len(blk)) if blk[x].strip() == ")")
                    previos = [l for l in blk[e:cierre] if l.strip()]
                    blk[e:cierre] = [""] + sorted(set(previos) | {f'\t"{x}"' for x in ext})
            else:
                one = next((x for x, l in enumerate(blk) if l.startswith("import \"")), None)
                pk = next(x for x, l in enumerate(blk) if l.startswith("package "))
                todos = sorted(({blk[one].split(" ", 1)[1].strip()} if one is not None else set()) | {f'"{x}"' for x in faltan})
                nuevo = ["import ("] + ["\t" + t for t in todos] + [")"]
                if one is not None: blk[one:one+1] = nuevo
                else: blk[pk+1:pk+1] = [""] + nuevo
            L[ini:fin] = blk
        pathlib.Path(f).write_text("\n".join(L), encoding="utf-8")
print(f"{len(idx)} bloques completos, {sum(len(v) for v in cambios.values())} con imports de más que añadir")
