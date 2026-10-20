#!/usr/bin/env python3
"""Árbol de un commit (directorio actual): R19 (/bitacora → /spin-log, BitacoraPage → SpinLogPage) y measure.js que cuenta
solo las filas del tráfico. Lo corre git filter-branch --tree-filter en cada commit."""
import os, re

if os.path.exists("src/pages/BitacoraPage.jsx"):
    os.rename("src/pages/BitacoraPage.jsx", "src/pages/SpinLogPage.jsx")
for f in ("src/AppRouter.jsx", "src/components/Navbar.jsx", "src/pages/SpinLogPage.jsx"):
    if os.path.exists(f):
        s = open(f, encoding="utf-8").read()
        s = s.replace("BitacoraPage", "SpinLogPage").replace('"/bitacora"', '"/spin-log"')
        s = s.replace("las rutas (URLs) en inglés, salvo /bitacora.", "las rutas (URLs) en inglés.")
        open(f, "w", encoding="utf-8").write(s)

m = "scripts/measure.js"
if os.path.exists(m):
    s = open(m, encoding="utf-8").read()
    old = """  const prizesByKey = {};
  for (const row of spinLog) prizesByKey[row.idempotencyKey] = (prizesByKey[row.idempotencyKey] || 0) + 1;
  const keysWithTwoPrizes = Object.values(prizesByKey).filter((n) => n > 1).length;
  const prizesLogged = spinLog.length;"""
    new = """  // Solo las filas del tráfico (las claves spin-N de traffic.js): la bitácora del mock trae también
  // las filas sembradas, y desde la Fase 8, las 10.000 de la Rueda de fin de mes.
  const traffic = spinLog.filter((row) => /^spin-\\d+$/.test(row.idempotencyKey));
  const prizesByKey = {};
  for (const row of traffic) prizesByKey[row.idempotencyKey] = (prizesByKey[row.idempotencyKey] || 0) + 1;
  const keysWithTwoPrizes = Object.values(prizesByKey).filter((n) => n > 1).length;
  const prizesLogged = traffic.length;"""
    if old in s:
        s = s.replace(old, new)
        open(m, "w", encoding="utf-8").write(s)
