#!/bin/bash
# (parametrizado: SVC RATE URL) F16 §5.4 / §9: HPA de pricing con 1.500 req/s; $1 = límite de memoria (64Mi|128Mi), $2 = etiqueta.
SVC=${SVC:-pricing}; RATE=${RATE:-1500}; DUR=${DUR:-60}; cd mi-lab/src/lab
K="kubectl --context kind-lab -n apps"
TAGS="--set pricing.image.tag=g5 --set inventory.image.tag=g5 --set catalog.image.tag=g4 --set replenish.image.tag=g5 --set storefront.image.tag=g5"
LIM=""; [ "$SVC" = pricing ] && LIM="--set pricing.resources.limits.memory=$1"
HELM="helm upgrade --install lab"
# Base: HPA fuera, una réplica (el HPA anterior se borra al quitar autoscaling.enabled).
$HELM charts/platform -n apps --kube-context kind-lab -f charts/platform/values-lab.yaml $TAGS --set $SVC.replicaCount=1 $LIM --wait --timeout 10m --force-conflicts >/dev/null 2>&1 || { echo "helm base falló"; exit 1; }
$K rollout status deployment/$SVC --timeout=120s >/dev/null
helm upgrade --install lab charts/platform -n apps --kube-context kind-lab -f charts/platform/values-lab.yaml $TAGS \
  --set $SVC.autoscaling.enabled=true $LIM --wait --timeout 10m --force-conflicts >/dev/null 2>&1 || { echo "helm falló"; exit 1; }
$K rollout status deployment/$SVC --timeout=120s >/dev/null
sleep 45   # que metrics-server tenga una lectura en reposo
$K get hpa $SVC --no-headers
URL=${URL:-'http://api.localhost:8080/pricing/prices/SKU-0001?store=DRO-007'}
k6 run -q -e RATE=$RATE -e DURATION=${DUR}s -e URL="$URL" bench/b16/rate.js > /tmp/k6-$2.out 2>&1 &
T0=$(date +%s)
primera=""; lista=""
while kill -0 $! 2>/dev/null; do
  now=$(( $(date +%s) - T0 ))
  d=$($K get hpa $SVC -o jsonpath='{.status.desiredReplicas}'); r=$($K get deploy $SVC -o jsonpath='{.status.readyReplicas}'); c=$($K get hpa $SVC -o jsonpath='{.status.currentMetrics[0].resource.current.averageUtilization}')
  printf '%4s s · cpu %s%% · deseadas %s · listas %s\n' $now "${c:-?}" "${d:-?}" "${r:-0}"
  [ -z "$primera" ] && [ "${d:-1}" -gt 1 ] && primera=$now
  [ -z "$lista" ] && [ "${r:-0}" -gt 1 ] && lista=$now
  sleep 5
done
wait
echo "primera réplica pedida a los ${primera:-None} s; lista a los ${lista:-None} s"
grep 'http_req_failed\|http_req_duration\|http_reqs' /tmp/k6-$2.out
$K get pods -l app.kubernetes.io/name=$SVC --no-headers | grep -v migrate | awk '{print $1,$2,$3,"reinicios="$4}'
$K get pods -l app.kubernetes.io/name=$SVC -o jsonpath='{range .items[*]}{.status.containerStatuses[0].lastState.terminated.reason}{"\n"}{end}' | sort | uniq -c
