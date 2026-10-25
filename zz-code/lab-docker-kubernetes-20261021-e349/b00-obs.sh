#!/bin/sh
# B-00, sexta entrega (F17 §8): la observabilidad pieza por pieza, en el cluster lab con los valores de
# minimo. Tres ciclos de apagar todo y encender cada pieza; cada lectura, 60 s después de encender.
# Working set de cada pod por metrics-server (kubectl top) y memoria usada de la VM (MemTotal - MemAvailable,
# del /proc/meminfo que el nodo comparte con la VM).
cd "$(dirname "$0")/mi-lab/src/lab" || exit 1
vm() { docker exec lab-control-plane cat /proc/meminfo | awk '/MemTotal/{t=$2}/MemAvailable/{a=$2}END{print int((t-a)/1024)}'; }
top() { kubectl -n observability top pods --no-headers 2>/dev/null | awk '{printf "%s=%s ", $1, $3}'; }
read_() { sleep 60; echo "$(date +%H:%M:%S) ciclo=$1 estado=$2 vm_used_mib=$(vm) $(top)"; }
for c in 1 2 3; do
  task obs:off PROFILE=minimo CLUSTER=lab -- all > /dev/null 2>&1; read_ $c nada
  task obs:on PROFILE=minimo CLUSTER=lab -- metrics > /dev/null 2>&1; read_ $c prometheus
  task obs:on PROFILE=minimo CLUSTER=lab -- dashboards > /dev/null 2>&1; read_ $c prometheus+grafana
done
