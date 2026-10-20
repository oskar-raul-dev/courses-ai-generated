#!/usr/bin/env bash
# Corridas 2 y 3 de cada medición con contención, para ver la dispersión del p95.
Z="$(cd "$(dirname "$0")/.." && pwd)"
for n in 2 3; do for v in naive pessimistic optimistic; do for r in vus50 vus200; do
  "$Z/trabajo/be05-k6.sh" "$v" "$r" "$v-$r-corrida$n" >/dev/null 2>&1 || echo "falló $v $r $n"
done; done; done
echo listo
