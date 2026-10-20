#!/usr/bin/env python3
"""Arma server/CONTRACT.md desde be00 §5.3 y §5.4 (el documento manda) y le pega la línea base del smoke."""
import re, sys
md = open(sys.argv[1], encoding="utf-8").read()
a = md.index("#### Régimen estricto — autenticación")
b = md.index("### 5.4 Los siete hallazgos")
c = md.index("### 5.5 El smoke test")
contract = md[a:b].replace("#### ", "## ")
findings = md[b:c].replace("### 5.4 Los siete hallazgos", "## Hallazgos (C-01 a C-07)")
base = open(sys.argv[2], encoding="utf-8").read()
out = ["# Contrato del puerto 3001 — auditado en be00", "",
       "Medido con un recorrido completo de la consola (HAR en `evidence/recorrido.har`), con el caos apagado.", "",
       contract.strip(), "", findings.strip(), "",
       "## Línea base de `smoke.sh` contra el mock (18/10/2026)", "", "```text", base.strip(), "```", ""]
open(sys.argv[3], "w", encoding="utf-8").write("\n".join(out))
