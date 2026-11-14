#!/usr/bin/env python3
"""Reconstruye el repositorio del lector a partir de los bloques de código de las fases.

Un bloque cuya primera línea es un comentario con una ruta (`// labs/x/main.go`,
`# compose.yaml`, `-- migrations/001.sql`) se escribe en esa ruta dentro de --destino.
Si la ruta reaparece, la nueva versión pisa a la anterior; todas quedan en
salidas/versiones/<ruta>.<fase>-L<línea>.

Uso:
    python3 extraer.py ../../cursos-algoritmos-lenguajes/go-for-java-devs/01-sintaxis-y-valores.md
    python3 extraer.py --destino lector --listar FASE.md   # solo lista, no escribe
"""
import argparse
import pathlib
import re
import sys

AQUI = pathlib.Path(__file__).resolve().parent
RUTA = re.compile(r"^(?://|#|--)\s*((?:[A-Za-z0-9_./-]*/)?(?:Makefile|Dockerfile)|[A-Za-z0-9_.][A-Za-z0-9_./-]*?\.[A-Za-z0-9]+)(?:\s|$)")
PREFIJOS = ("labs/", "services/", "reference/", "deploy/", "docs/", ".github/", ".vscode/", "tools/", "migrations/", "scripts/", "loadtest/", "bench/")
RAIZ = {"Makefile", "compose.yaml", ".golangci.yml", "go.work", ".editorconfig", ".gitignore", ".pre-commit-config.yaml", "Dockerfile"}
APERTURA = re.compile(r"^(`{3,})(\S*)")


def bloques(texto):
    lineas = texto.splitlines()
    i = 0
    while i < len(lineas):
        m = APERTURA.match(lineas[i])
        if not m:
            i += 1
            continue
        valla, lang = m.group(1), m.group(2)
        inicio = i + 1
        j = inicio
        while j < len(lineas) and lineas[j].strip() != valla:
            j += 1
        yield inicio, lang, lineas[inicio:j]
        i = j + 1


CABEZA = re.compile(r"^(package \w+|import\b|func (\([^)]*\) )?(\w+)|type (\w+)|var (\w+)|const (\w+)|var \(|const \()")


def _delta(l):
    """Balance de llaves y paréntesis de una línea, sin contar strings ni comentarios."""
    l = re.sub(r"`[^`]*`|\"(\\.|[^\"\\])*\"|'(\\.|[^'\\])*'", "", l).split("//")[0]
    return l.count("{") + l.count("(") - l.count("}") - l.count(")")


def trozos(lineas):
    """Parte un archivo Go en declaraciones de nivel superior; los comentarios y líneas en
    blanco previos van con la declaración que sigue. Lo que queda al final va suelto."""
    out, pend, i = [], [], 0
    while i < len(lineas):
        l = lineas[i]
        if CABEZA.match(l):
            bloque, prof = [l], _delta(l)
            while prof > 0 and i + 1 < len(lineas):
                i += 1; bloque.append(lineas[i]); prof += _delta(lineas[i])
            out.append({"clave": clave(l), "lineas": pend + bloque}); pend = []
        else:
            pend.append(l)
        i += 1
    if pend: out.append({"clave": None, "lineas": pend})
    return out


def clave(l):
    if l.startswith("package "): return ("package", "")
    if l.startswith("import"): return ("import", "")
    m = re.match(r"^func (\(\s*\w*\s*\*?(\w+)[^)]*\) )?(\w+)", l)
    if m: return ("func", m.group(2) or "", m.group(3))
    m = re.match(r"^(type|var|const) (\w+)", l)
    if m: return (m.group(1), m.group(2))
    m = re.match(r"^(var|const) \(", l)
    return (m.group(1) + "(", None) if m else None


def nombres_bloque(t):
    """Nombres declarados dentro de un var ( ... ) o const ( ... )."""
    return {m.group(1) for l in t["lineas"][1:] for m in [re.match(r"^\t(\w+)\b", l)] if m}


def fusionar(base, parche):
    """Cada declaración del parche reemplaza la homónima de base; las nuevas van al final."""
    tb = trozos(base)
    for t in trozos(parche):
        k = t["clave"]
        if k is None or (isinstance(k, tuple) and k[0] == "func" and k[2] in ("main",) and False):
            pass
        idx = None
        if k and k[1] is not None and not k[0].endswith("("):
            idx = next((i for i, b in enumerate(tb) if b["clave"] == k), None)
        elif k and k[0].endswith("("):
            nb = nombres_bloque(t)
            idx = next((i for i, b in enumerate(tb) if b["clave"] and b["clave"][0] == k[0] and nombres_bloque(b) & nb), None)
        if any(l.strip().startswith("// ...") for l in t["lineas"]) and k is None:
            continue  # comentario de elisión suelto
        if k == ("import", "") and idx is not None:
            viejas = tb[idx]["lineas"]
            nuevas = [l for l in t["lineas"] if l.strip().startswith('"') or re.match(r'^\s*\w+ "', l)]
            if viejas[-1].strip() == ")":
                faltan = [l if l.startswith("\t") else "\t" + l.split("import ", 1)[-1] for l in nuevas if l.strip() not in {v.strip() for v in viejas}]
                tb[idx]["lineas"] = viejas[:-1] + faltan + [viejas[-1]]
            continue
        if idx is None:
            tb.append({"clave": k, "lineas": [""] + t["lineas"]})
        else:
            tb[idx] = {"clave": k, "lineas": t["lineas"] + ([""] if tb[idx]["lineas"][-1:] == [""] else [])}
    return [l for b in tb for l in b["lineas"]]


def paquete_de(f):
    """Paquete de un archivo nuevo sin `package`: el de sus hermanos, o el nombre del directorio."""
    for h in sorted(f.parent.glob("*.go")):
        m = re.search(r"^package (\w+)", h.read_text(encoding="utf-8"), re.M)
        if m:
            return m.group(1).removesuffix("_test")
    return "main" if f.parent.parent.name == "cmd" else re.sub(r"[^a-z0-9]", "", f.parent.name.lower())


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("fases", nargs="+")
    ap.add_argument("--destino", default=str(AQUI / "lector"))
    ap.add_argument("--listar", action="store_true")
    a = ap.parse_args()
    destino = pathlib.Path(a.destino)
    versiones = AQUI / "salidas" / "versiones"
    for fase in a.fases:
        p = pathlib.Path(fase)
        for inicio, lang, cuerpo in bloques(p.read_text(encoding="utf-8")):
            if not cuerpo or lang in ("", "text", "bash", "sh", "console", "mermaid"):
                # text/bash solo cuentan si nombran un archivo de datos (testdata, .txt, .csv…)
                if not cuerpo or lang in ("", "mermaid"):
                    continue
            k0 = 0  # un //go:build va antes de la ruta: se salta para encontrarla y se conserva
            while k0 < len(cuerpo) - 1 and (cuerpo[k0].startswith("//go:build") or not cuerpo[k0].strip()):
                k0 += 1
            m = RUTA.match(cuerpo[k0])
            if not m:
                continue
            if k0:
                cuerpo = [cuerpo[k0]] + cuerpo[:k0] + cuerpo[k0+1:]
            ruta = m.group(1)
            if not ruta.startswith(PREFIJOS) and ruta not in RAIZ:
                continue  # ejemplo ilustrativo (internal/… suelto, *_impl.go del antipatrón)
            if lang in ("bash", "sh", "console") and not ruta.endswith(".sh"):
                continue
            # La línea del nombre se quita en datos (text, csv) y se deja en código, donde es un comentario.
            contenido = cuerpo[1:] if lang in ("text", "csv", "json", "jsonc") else cuerpo
            print(f"{p.name}:{inicio}\t{lang}\t{ruta}")
            if a.listar:
                continue
            f = destino / ruta
            f.parent.mkdir(parents=True, exist_ok=True)
            sin_pkg = ruta.endswith(".go") and not any(re.match(r"^package \w+", l) for l in contenido)
            if sin_pkg and not f.exists():
                contenido = [contenido[0], f"package {paquete_de(f)}", ""] + contenido[1:]
                print(f"\t  (sin package: se deduce '{paquete_de(f)}')")
                with open(AQUI / "salidas" / "fusionados.txt", "a", encoding="utf-8") as fz:
                    fz.write(ruta + "\n")
            elif ruta.endswith(".go") and f.exists() and not any(re.match(r"^package \w+", l) for l in contenido):
                contenido = fusionar(f.read_text(encoding="utf-8").split("\n"), contenido[1:])
                print(f"\t  (parche fusionado en {ruta})")
                with open(AQUI / "salidas" / "fusionados.txt", "a", encoding="utf-8") as fz:
                    fz.write(ruta + "\n")
            f.write_text("\n".join(contenido).rstrip("\n") + "\n", encoding="utf-8")
            v = versiones / f"{ruta}.{p.stem[:2]}"  # la última versión de la fase
            v.parent.mkdir(parents=True, exist_ok=True)
            v.write_text("\n".join(contenido) + "\n", encoding="utf-8")


if __name__ == "__main__":
    sys.exit(main())
