#!/usr/bin/env python3
"""R23, segunda pasada: la medianoche con el reloj congelado en el mismo instante (para que el incidente 20 siga pasando en Bogotá)."""
import os
test = "src/features/dashboard/MetricCard.test.jsx"
if os.path.exists(test):
    s = open(test, encoding="utf-8").read()
    old = '''    // Y la medianoche es 00, no 24: el formato fija el ciclo de 23 horas.
    render(<MetricCard title="Giros" value="10000" updatedAt={Date.parse("2026-10-19T00:18:00-05:00")} />);
    expect(screen.getByText("Actualizado: 19/10 00:18")).toBeInTheDocument();'''
    new = '''    // Y la medianoche es 00, no 24: el formato fija el ciclo de 23 horas.
    const MIDNIGHT = Date.parse("2026-10-19T00:18:00-05:00");
    jest.setSystemTime(MIDNIGHT);
    render(<MetricCard title="Giros" value="10000" updatedAt={MIDNIGHT} />);
    expect(screen.getByText("Actualizado: 19/10 00:18")).toBeInTheDocument();'''
    if old in s:
        open(test, "w", encoding="utf-8").write(s.replace(old, new))
