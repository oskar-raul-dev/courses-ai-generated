#!/bin/sh
# a14: las peticiones a la API por el proxy de Headlamp, sin token y con un token de la ClusterRole view.
K="kubectl --context kind-lab"
echo "headlamp-admin → $($K get clusterrolebinding headlamp-admin -o jsonpath='{.roleRef.name}')"
$K -n headlamp create serviceaccount lector > /dev/null 2>&1
$K create clusterrolebinding a14-lector-view --clusterrole=view --serviceaccount=headlamp:lector > /dev/null 2>&1
$K -n apps run a14-prueba --image=busybox:latest --image-pull-policy=IfNotPresent --restart=Never -- sleep 600 > /dev/null 2>&1
T=$($K -n headlamp create token lector --duration=1h)
$K -n headlamp port-forward svc/headlamp 38411:80 > /dev/null 2>&1 &
PF=$!
sleep 3
U=http://127.0.0.1:38411/clusters/main
code() { curl -s -o /tmp/a14-body -w '%{http_code}' "$@"; }
echo "sin token: listar pods de apps                  $(code $U/api/v1/namespaces/apps/pods)"
echo "token view: listar pods de apps                 $(code -H "Authorization: Bearer $T" $U/api/v1/namespaces/apps/pods) · $(python3 -c "import json; print(len(json.load(open('/tmp/a14-body'))['items']))" 2>/dev/null) pods"
echo "token view: listar los Secret de apps           $(code -H "Authorization: Bearer $T" $U/api/v1/namespaces/apps/secrets)"
echo "token view: borrar un pod de prueba             $(code -X DELETE -H "Authorization: Bearer $T" $U/api/v1/namespaces/apps/pods/a14-prueba)   ($($K -n apps get pod a14-prueba -o name 2>/dev/null || echo 'el pod ya no está'))"
kill $PF
$K -n apps delete pod a14-prueba --wait=false > /dev/null 2>&1
