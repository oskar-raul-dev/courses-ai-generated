"""Genera un perfil de la caja con el generador del curso (src/lab/generator) en salidas/caja/.

Uso: python3 -I generar.py s|m [semilla] [destino]   (solo biblioteca estándar)
"""
import json
import sys

sys.path.insert(0, "/Users/oskar/Developer/Learning/courses-ia-generated/cursos-bd/ruta-sql/src")
from lab.generator import generate  # noqa: E402

profile = sys.argv[1]
seed = int(sys.argv[2]) if len(sys.argv) > 2 else 1996
out = sys.argv[3] if len(sys.argv) > 3 else "salidas/caja"
m = generate(profile, seed, out)
print(json.dumps({k: v for k, v in m.items() if k not in ("files", "rows")}, ensure_ascii=False))
r = m["rows"]
print({k: r[k] for k in ["Pacientes", "Protocolos", "ResultadoItem", "ProtocoloPracticas", "Comprobantes",
                         "ComprobantesRechazados", "Recibos", "ParaLlamar", "Hemograma", "Quimica", "Orina",
                         "archivos/listado.csv", "turnos/Turnos.csv"]})
