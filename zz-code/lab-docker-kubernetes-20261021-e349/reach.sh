#!/bin/sh
# Corre reach.js desde el replenish de una cadena: reach.sh apps-b | apps
NS=$1; P=$(kubectl -n $NS get pod -l app.kubernetes.io/name=replenish,app.kubernetes.io/component=backend -o name | head -1)
echo "# desde $P ($NS)"
kubectl -n $NS exec $P -- env OWN_NS=$NS node -e "$(cat "$(dirname "$0")/reach.js")"
