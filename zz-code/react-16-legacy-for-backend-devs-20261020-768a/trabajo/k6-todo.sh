#!/usr/bin/env bash
# T12: el k6 de be05 y el de be08 otra vez, para comparar en forma y rango con lo publicado (be05 §8, be08 §5.6).
# Una corrida por fila; be05.sh y be08-carga.sh dejan cada salida en salidas/. Necesita r16t12-pg (regresion.sh).
Z="$(cd "$(dirname "$0")/.." && pwd)"
docker exec r16t12-pg psql -q -U esclusa -d postgres -tc "SELECT 1 FROM pg_database WHERE datname='esclusa'" | grep -q 1 \
  || docker exec r16t12-pg psql -q -U esclusa -d postgres -c 'CREATE DATABASE esclusa' >/dev/null
B05=fase-be05-giro-concurrente
"$Z/trabajo/be05-k6.sh" naive 50 naive-50
"$Z/trabajo/be05-k6.sh" "$B05:pessimistic" 50 pesimista-50
"$Z/trabajo/be05-k6.sh" "$B05:optimistic" 50 condicional-50
for v in naive "$B05:pessimistic" "$B05:optimistic"; do
  for n in 50 200; do "$Z/trabajo/be05-k6.sh" "$v" "vus$n" "${v##*:}-vus$n"; done
done
B08=fase-be08-pruebas-y-la-regla-del-motor
"$Z/trabajo/be08-carga.sh" $B08 fase-pico50 50
"$Z/trabajo/be08-carga.sh" $B08 fase-vus200 vus200
"$Z/trabajo/be08-carga.sh" incidente/be-09 be09-vus50 vus50
