#!/usr/bin/env python3
"""T5 validators for angular-8-legacy-for-backend-devs (the course has no verificador of its own).

Usage: CURSO=<course> python3 verificar-curso.py
Reuses zz-instrucciones/herramientas/verificador_base.py for links and anchors (GitHub slugs) and adds:
  FENCE     unbalanced code fences
  ZZ-CODE   a course document cites zz-code/ or the disposable plan
  INC-FASE  the phase in the cuaderno index does not list that incident in its "Reservas" section
  ESCENARIO leftovers of the old scenario (Bogotá, Colombia as place, CC-/TI-/CE-, COP, es-CO, Laboratorios Andina)
Prints every error and a summary; exit code 1 if any error.
"""
import os, re, sys
REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
sys.path.insert(0, os.path.join(REPO, "zz-instrucciones", "herramientas"))
from verificador_base import Verificador, leer, lineas_sin_codigo  # noqa: E402

CURSO = os.environ["CURSO"]
v = Verificador(CURSO)
v.AUTOCONTENIDO = True
v.PROHIBIR_ENLACES_A_PROMPTS = False   # this course links to prompts/ from its README on purpose
docs = [p for p in v.archivos() if "_desechable" not in p and "_deprecado" not in p]

for p in docs:
    texto = leer(p)
    v.verificar_enlaces(p, lineas_sin_codigo(texto))
    fences = [l for l in texto.split("\n") if re.match(r"^\s*(```|~~~)", l)]
    # a 4-backtick fence wraps 3-backtick ones (templates): count only the outermost style per file
    if len([l for l in fences if l.strip().startswith("````")]) % 2 or len([l for l in fences if re.match(r"^\s*```(?!`)", l)]) % 2:
        v.error("FENCE", v.rel(p))
    if not v.es_de_prompts(p):
        for n, l in enumerate(texto.split("\n"), 1):
            if "zz-code" in l or "_desechable-plan" in l:
                v.error("ZZ-CODE", f"{v.rel(p)}:{n}")
    for n, l in enumerate(texto.split("\n"), 1):
        if re.search(r"Bogot|\bColombia\b|\b(CC|TI|CE)-\d|'COP'|es-CO|Laboratorios Andina|S\.A\.S", l):
            v.error("ESCENARIO", f"{v.rel(p)}:{n}: {l.strip()[:90]}")

cuaderno = leer(os.path.join(CURSO, "cuaderno-incidentes.md"))
for inc, fase in re.findall(r"^\| (\d\d) \| (\d+) \|", cuaderno, re.M):
    cand = [p for p in docs if re.match(rf"{int(fase):02d}-", os.path.basename(p))
            and not os.path.basename(p).startswith(("00-convencion", "00-historia"))]
    if not cand:
        v.error("INC-FASE", f"incidente {inc}: no hay fase {fase}"); continue
    t = leer(cand[0])
    res = t.split("Reservas para el cuaderno de incidentes")[-1] if "Reservas para el cuaderno de incidentes" in t else ""
    if not re.search(rf"\*\*[^*]*\b{inc}\b[^*]*\*\*|\b{int(inc)}\b", res):
        v.error("INC-FASE", f"incidente {inc} (fase {fase}): su fase no lo menciona en Reservas ({os.path.basename(cand[0])})")

# Links to sibling courses of the repository are a prior decision of A13: check they exist, as notices.
fuera = [e for e in v.errores if e.startswith("FUERA")]
v.errores = [e for e in v.errores if not e.startswith("FUERA")]
for e in fuera:
    ruta, destino = e.split(None, 1)[1].split(" → ")
    objetivo = os.path.normpath(os.path.join(CURSO, os.path.dirname(ruta.split(":")[0]), destino.split("#")[0]))
    if os.path.exists(objetivo):
        print("aviso    ENTRE-CURSOS", ruta, "→", destino, "(existe)")
    else:
        v.error("ROTO", e)
for e in v.errores:
    print(e)
print(f"{len(docs)} documentos · {len(v.errores)} errores")
sys.exit(1 if v.errores else 0)
