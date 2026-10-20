#!/bin/sh
# F10 ➕: la prueba de lo aleatorio, 50 corridas seguidas (cada una con su propia semilla en la técnica 2).
cd "$1"
ok=0; fail=0
for i in $(seq 1 50); do
  if CI=true npx react-scripts test --watchAll=false src/features/reconciliation/oddsAudit.test.js >/dev/null 2>&1; then ok=$((ok+1)); else fail=$((fail+1)); fi
done
echo "50 corridas: $ok verdes, $fail rojas"
