#!/usr/bin/env bash
# T12: el k6 de be05 otra vez, con el arnés de be05 (be05-k6.sh). Una corrida por fila de la tabla de be05 §8.
Z="$(cd "$(dirname "$0")/.." && pwd)"; B05=fase-be05-giro-concurrente
"$Z/trabajo/be05-k6.sh" naive 50 naive-50
"$Z/trabajo/be05-k6.sh" "$B05:pessimistic" 50 pessimistic-50
"$Z/trabajo/be05-k6.sh" "$B05:optimistic" 50 optimistic-50
for v in naive "$B05:pessimistic" "$B05:optimistic"; do
  for n in 50 200; do "$Z/trabajo/be05-k6.sh" "$v" "vus$n" "${v##*:}-vus$n"; done
done
