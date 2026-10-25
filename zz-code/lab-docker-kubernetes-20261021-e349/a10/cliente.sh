#!/bin/sh
# a10: 200 lecturas de catalog a través de chaos desde un pod del mesh; los códigos, y lo que recibió el vecino.
cd "$(dirname "$0")/../mi-lab/src/lab"
task chaos:set -- errorPercent=50 > /dev/null 2>&1
before=$(task chaos:set -- show 2>/dev/null | tr -d ' \n' | grep -o '"received":[0-9]*' | cut -d: -f2)
kubectl --context kind-lab -n apps run a10-cliente --rm -i --restart=Never --quiet --image=curlimages/curl:latest --image-pull-policy=IfNotPresent \
  --labels=app.kubernetes.io/name=a10-cliente --command -- sh -c \
  'for i in $(seq 1 200); do curl -s -o /dev/null -w "%{http_code}\n" http://chaos.apps.svc.cluster.local:8080/products/SKU-0001; done | sort | uniq -c' 2>&1 | grep -v 'warning'
after=$(task chaos:set -- show 2>/dev/null | tr -d ' \n' | grep -o '"received":[0-9]*' | cut -d: -f2)
echo "el vecino recibió $((after - before)) peticiones"
