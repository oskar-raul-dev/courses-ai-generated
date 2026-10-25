#!/bin/sh
# F17 §6: el contador de catalog con la memoria del proceso y con APCu. Por cada modo: despliega catalog con
# METRICS_STORAGE, 200 peticiones a /products de a 10 en paralelo por la puerta, y lee su /metrics.
for mode in memory apcu; do
  kubectl -n apps set env deploy/catalog -c php-fpm METRICS_STORAGE=$mode >/dev/null
  kubectl -n apps rollout status deploy/catalog >/dev/null
  sleep 5
  seq 200 | xargs -P10 -I{} curl -s -o /dev/null -H 'Host: api.localhost' http://127.0.0.1:8080/catalog/products
  echo "=== METRICS_STORAGE=$mode · 200 peticiones a /products, de a 10 en paralelo"
  curl -s -H 'Host: api.localhost' http://127.0.0.1:8080/catalog/metrics | grep 'http_server_requests_seconds_count' | grep '/products"' || echo '(ninguna línea con uri="/products")'
done
kubectl -n apps set env deploy/catalog -c php-fpm METRICS_STORAGE- >/dev/null
