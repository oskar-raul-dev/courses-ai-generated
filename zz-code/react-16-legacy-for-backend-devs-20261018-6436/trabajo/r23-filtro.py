#!/usr/bin/env python3
"""R23: MetricCard a hourCycle "h23" y la prueba de F10 con la medianoche. Lo corre filter-branch en cada commit."""
import os
card = "src/features/dashboard/MetricCard.jsx"
if os.path.exists(card):
    s = open(card, encoding="utf-8").read()
    s = s.replace('  hour12: false,\n', '  hourCycle: "h23", // 00:18 y no 24:18: con hour12: false, algunos motores cuentan la medianoche como 24\n')
    open(card, "w", encoding="utf-8").write(s)
test = "src/features/dashboard/MetricCard.test.jsx"
if os.path.exists(test):
    s = open(test, encoding="utf-8").read()
    old = '''    render(<MetricCard title="Giros" value="10000" updatedAt={EVENING} />);
    expect(screen.getByText("Actualizado: 20/12 21:00")).toBeInTheDocument();
  });'''
    new = '''    render(<MetricCard title="Giros" value="10000" updatedAt={EVENING} />);
    expect(screen.getByText("Actualizado: 20/12 21:00")).toBeInTheDocument();
    // Y la medianoche es 00, no 24: el formato fija el ciclo de 23 horas.
    render(<MetricCard title="Giros" value="10000" updatedAt={Date.parse("2026-10-19T00:18:00-05:00")} />);
    expect(screen.getByText("Actualizado: 19/10 00:18")).toBeInTheDocument();
  });'''
    if "19/10 00:18" not in s and old in s:
        s = s.replace(old, new)
        open(test, "w", encoding="utf-8").write(s)
