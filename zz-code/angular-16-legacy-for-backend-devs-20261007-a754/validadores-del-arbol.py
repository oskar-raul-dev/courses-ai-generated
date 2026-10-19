#!/usr/bin/env python3
"""Copia TAL CUAL el arreglo `validators: [...]` del control taxId del formulario de
clientes de un árbol a ARBOL/pruebas/validators-del-arbol.ts, con los import que use.
Así t4-extra.spec.ts prueba exactamente lo que dice cada versión del componente."""
import re
import sys
from pathlib import Path

arbol = Path(sys.argv[1])
comp = (arbol / "src/app/features/clients/client-form/client-form.component.ts").read_text(encoding="utf-8")
tramo = comp[comp.index("taxId: new FormControl("):]
arreglo = re.search(r"^\s*validators: (\[.*?\]),$", tramo, re.M).group(1)
imports = ["import { ValidatorFn, Validators } from '@angular/forms';"]
if "taxIdValidator" in arreglo:
    imports.append("import { taxIdValidator } from '../src/app/features/clients/tax-id.validator';")
destino = arbol / "pruebas" / "validators-del-arbol.ts"
destino.parent.mkdir(parents=True, exist_ok=True)
destino.write_text("// GENERADO por validadores-del-arbol.py desde client-form.component.ts de este árbol.\n"
                   + "\n".join(imports) + f"\n\nexport const taxIdValidators: ValidatorFn[] = {arreglo};\n", encoding="utf-8")
print(f"{arbol.name}: validators = {arreglo}")
