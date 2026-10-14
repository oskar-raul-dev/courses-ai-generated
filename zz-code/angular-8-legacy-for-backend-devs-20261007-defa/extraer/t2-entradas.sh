#!/usr/bin/env bash
# Extracts the Fase 05 patients store and the Fase 12 reducer/selector specs into sondas/angular8/fase12/.
set -euo pipefail
cd "$(dirname "$0")/.."
: "${CURSO:?set CURSO}"
x() { python3 extraer/bloque.py "$@"; }
F=sondas/angular8/fase12
mkdir -p $F
x 05-pacientes.md "// src/app/patients/store/patients.actions.ts" > $F/patients.actions.ts
# Fase 05 exercise 1 leaves setPatientsFilter unwritten on purpose; the probe adds the exercise's answer.
printf "\n// zz-code: answer to Fase 05 exercise 1, needed for the reducer to compile\nexport const setPatientsFilter = createAction('[Patients] Set Patients Filter', props<{ filter: string }>());\n" >> $F/patients.actions.ts
x 05-pacientes.md "// src/app/patients/store/patients.reducer.ts" > $F/patients.reducer.ts
x 05-pacientes.md "// src/app/patients/store/patients.selectors.ts" > $F/patients.selectors.ts
x 12-testing-coverage.md "// src/app/patients/store/patients.reducer.spec.ts" > $F/patients.reducer.spec.ts
x 12-testing-coverage.md "// src/app/patients/store/patients.selectors.spec.ts" > $F/patients.selectors.spec.ts
x 05-pacientes.md "Validators.pattern(/^(HC|PP|LB)" | grep -o "/\^(HC|PP|LB)[^/]*/" > $F/regex.txt
wc -l $F/*.ts $F/regex.txt
