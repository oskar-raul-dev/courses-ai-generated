"""Fase 26 · la factura de licencias a cinco años, con precios de lista públicos y su fecha.

Fuentes (descargadas y leídas el 15/10/2026):
  · Oracle Technology Global Price List, 15 de septiembre de 2026, sección I (Oracle Database);
  · Oracle Processor Core Factor Table, actualizada el 28 de enero de 2026: Intel Xeon y AMD EPYC, 0,5.

Los núcleos por defecto son los del SIH según la historia (dos Xeon de 16, primario y standby), como si el
laboratorio tuviera los suyos. Lo que el script NO sabe, y la lección declara: qué descuento tiene Horizonte (los precios de lista no son lo que se paga), ni el costo del soporte
comercial de Postgres, que no tiene lista pública. El soporte de Oracle es el de la lista: un 22 % anual del valor
de la licencia, desde el primer año.

Uso:  python 26-el-comite/01_factura.py [núcleos por servidor] [servidores]     (por defecto, 16 y 2)
"""

import math
import sys

NUCLEOS = int(sys.argv[1]) if len(sys.argv) > 1 else 16
SERVIDORES = int(sys.argv[2]) if len(sys.argv) > 2 else 2     # el primario y el standby, que también se licencia
FACTOR = 0.5                                                   # x86: Xeon y EPYC
ANIOS = 5

# (licencia por procesador, soporte anual) en USD, de la lista del 15/09/2026
LISTA = {
    "Enterprise Edition": (47_500, 10_450),
    "Partitioning": (11_500, 2_530),
    "Diagnostics Pack": (7_500, 1_650),
    "Tuning Pack": (5_000, 1_100),
    "Active Data Guard": (11_500, 2_530),
}
ESCENARIOS = {
    "EE sola": ["Enterprise Edition"],
    "EE + particionado": ["Enterprise Edition", "Partitioning"],
    "EE + particionado + packs de diagnóstico y tuning": ["Enterprise Edition", "Partitioning", "Diagnostics Pack",
                                                          "Tuning Pack"],
    "EE + particionado + packs + standby legible": ["Enterprise Edition", "Partitioning", "Diagnostics Pack",
                                                     "Tuning Pack", "Active Data Guard"],
}

procesadores = math.ceil(NUCLEOS * FACTOR) * SERVIDORES
print(f"{SERVIDORES} servidores de {NUCLEOS} núcleos x86 · factor {FACTOR} · {procesadores} licencias de procesador")
print(f"{'escenario':52} {'licencias':>12} {'soporte/año':>12} {f'{ANIOS} años':>12}")
for nombre, items in ESCENARIOS.items():
    lic = sum(LISTA[i][0] for i in items) * procesadores
    sop = sum(LISTA[i][1] for i in items) * procesadores
    print(f"{nombre:52} {lic:12,.0f} {sop:12,.0f} {lic + sop * ANIOS:12,.0f}")
print(f"{'PostgreSQL (soporte comercial: sin lista pública)':52} {0:12,.0f} {'—':>12} {0:12,.0f}")
