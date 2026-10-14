#!/usr/bin/env python3
"""Continuity check: every "Fase N §X", "AXX §X", "beNN §X", "bea-NN §X" reference points to a numbered heading
that exists in the target document. Usage: CURSO=<course> python3 verificar-secciones.py"""
import os, re, glob
C = os.environ["CURSO"]
def target(kind, num):
    pats = {"Fase": f"{int(num):02d}-*.md", "A": f"a{int(num):02d}-*.md", "be": f"be{int(num):02d}-*.md", "bea-": f"bea-{int(num):02d}-*.md"}
    fs = [f for f in glob.glob(os.path.join(C, pats[kind])) if not os.path.basename(f).startswith(("00-convencion", "00-historia"))]
    return fs[0] if fs else None
def sections(path):
    t = open(path, encoding="utf-8").read()
    t = re.sub(r"^```.*?^```", "", t, flags=re.S | re.M)
    return set(re.findall(r"^#{2,4}\s+(?:\S+\s+)?(\d+(?:\.\d+)*)[.\s]", t, re.M))
REF = re.compile(r"\b(Fase|A|be|bea-)\s?(\d{1,2})\*{0,2}`?\s+§\s?(\d+(?:\.\d+)*)")
bad = 0
for f in sorted(glob.glob(os.path.join(C, "**", "*.md"), recursive=True)):
    if "_desechable" in f or "_deprecado" in f:
        continue
    for n, line in enumerate(open(f, encoding="utf-8"), 1):
        for kind, num, sec in REF.findall(line):
            t = target(kind, num)
            if not t:
                print(f"SIN-DOC  {os.path.relpath(f, C)}:{n} {kind}{num} §{sec}"); bad += 1
            elif sec not in sections(t):
                print(f"SECCION  {os.path.relpath(f, C)}:{n} {kind}{num} §{sec} (no existe en {os.path.basename(t)})"); bad += 1
print(bad, "referencias rotas")
