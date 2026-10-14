#!/bin/sh
# T2 checks, run inside node:14.21.3 from sondas/angular8: Fase 12 reducer and selector specs with Jasmine,
# and the Fase 05 regex against valid and invalid identifiers.
set -e
rm -rf fase12/out && npx tsc --module commonjs --target es2015 --lib es2017,dom --types jasmine --skipLibCheck --outDir fase12/out fase12/*.ts
npx jasmine --config=/dev/null fase12/out/patients.reducer.spec.js fase12/out/patients.selectors.spec.js
node -e '
const re = eval(require("fs").readFileSync("fase12/regex.txt", "utf8").trim());
const ok = ["HC-1032456789", "PP-1122334455", "LB-123456", "HC-123456789012"];
const bad = ["CC-1032456789", "TI-1122334455", "HC1032456789", "hc-1032456789", "HC-12345", "HC-1234567890123", "HC-12AB5678"];
let fails = 0;
ok.forEach(v => { if (!re.test(v)) { console.log("FAIL debe aceptar", v); fails++; } });
bad.forEach(v => { if (re.test(v)) { console.log("FAIL debe rechazar", v); fails++; } });
console.log("regex Fase 05", re, ":", ok.length + bad.length - fails + "/" + (ok.length + bad.length), "PASS");
process.exitCode = fails ? 1 : 0;'
