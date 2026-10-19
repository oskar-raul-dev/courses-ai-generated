#!/usr/bin/env python3
"""Arma mock/db.incidente-21.json como dice la receta: la semilla de F03 §5.2 y las
filas del bloque json de `### `db.incidente-21.json`` en preparaciones, las dos
copiadas del markdown. Después le aplica el diff de datos del fix (el ```diff sin
cabecera de la solución del 21 en el cuaderno) para obtener la versión arreglada.
Escribe en ARBOLES/{base,fix21}/pruebas/db-21.check.ts los datos con `satisfies`
contra los modelos del árbol: así tsc los tipa con las uniones literales del modelo.
Uso: python3 gen-db-21.py CURSO ARBOLES"""
import json
import re
import sys
from pathlib import Path

curso, arboles = Path(sys.argv[1]), Path(sys.argv[2])

def primer_bloque(texto, lenguaje, desde):
    i = texto.index(desde)
    return re.search(rf"^```{lenguaje}\n(.*?)^```$", texto[i:], re.M | re.S).group(1)

semilla = json.loads(primer_bloque((curso / "03-mock-api-caos.md").read_text(encoding="utf-8"), "json", "### 5.2 El modelo sembrado"))
prep = (curso / "prompts/preparaciones-de-incidentes.md").read_text(encoding="utf-8")
filas_txt = primer_bloque(prep, "json", "### `db.incidente-21.json`")

cuaderno = (curso / "cuaderno-incidentes.md").read_text(encoding="utf-8")
sol = cuaderno[cuaderno.index("## Incidente 21"):]
sol = sol[sol.index("Solución de referencia"):]
diff = re.search(r"^```diff\n(\s+\{ \"id\": \"CAL-INN-GPS-01\".*?)^```$", sol, re.M | re.S).group(1).rstrip("\n").split("\n")
viejo = "\n".join(l[1:] for l in diff if l[:1] in (" ", "-"))
nuevo = "\n".join(l[1:] for l in diff if l[:1] in (" ", "+"))
assert filas_txt.count(viejo) == 1, "el diff de datos del fix no calza con la receta"

def arma(filas):
    db = json.loads(json.dumps(semilla))
    for coleccion, nuevas in filas.items():
        db[coleccion].extend(nuevas)
    return db

roto = arma(json.loads(filas_txt))
fix = arma(json.loads(filas_txt.replace(viejo, nuevo)))
(arboles / "db.incidente-21.json").write_text(json.dumps(roto, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
(arboles / "db.incidente-21-fix.json").write_text(json.dumps(fix, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

CABECERA = """// GENERADO por gen-db-21.py, no es del curso. Los datos con `satisfies`: tsc los tipa
// contra los modelos de ESTE árbol, con exceso de propiedades incluido.
import { Asset } from '../src/app/core/models/asset.model';
import { Certificate } from '../src/app/core/models/certificate.model';
import { ChecklistTemplate } from '../src/app/core/models/checklist-template.model';
import { Client } from '../src/app/core/models/client.model';
import { Finding } from '../src/app/core/models/finding.model';
import { Inspection } from '../src/app/core/models/inspection.model';

interface Db {
  readonly clients: readonly Client[];
  readonly assets: readonly Asset[];
  readonly templates: readonly ChecklistTemplate[];
  readonly inspections: readonly Inspection[];
  readonly findings: readonly Finding[];
  readonly certificates: readonly Certificate[];
}
"""
for arbol, datos in (("base", {"roto": roto}), ("fix21", {"roto": roto, "fix": fix})):
    cuerpo = CABECERA + "".join(f"\nexport const {k} = {json.dumps(v, ensure_ascii=False, indent=2)} satisfies Db;\n" for k, v in datos.items())
    destino = arboles / arbol / "pruebas" / "db-21.check.ts"
    destino.parent.mkdir(parents=True, exist_ok=True)
    destino.write_text(cuerpo, encoding="utf-8")
print(f"db.incidente-21.json: {sum(len(v) for v in roto.values())} filas; fix con timeZone en CAL-INN-GPS-01")
