#!/bin/sh
# a15: corre dentro de nats-box. Publica una venta cada ~0,1 s durante $1 segundos, con -J (espera la confirmación del
# stream) y un Nats-Msg-Id propio por venta; imprime una línea por publicación: <segundos desde el inicio> <i> ok|falló.
dur=$1; pre=$2; s=$(date +%s.%N 2>/dev/null || date +%s); i=0
S=nats://nats-ha.data.svc.cluster.local:4222
while :; do
  now=$(date +%s.%N); el=$(echo "$now $s" | awk '{printf "%.2f", $1-$2}')
  awk -v e="$el" -v d="$dur" 'BEGIN {exit !(e < d)}' || break
  i=$((i+1))
  if nats -s $S pub -J -H "Nats-Msg-Id:$pre-$i" a15.ventas "venta $i" > /dev/null 2>/tmp/err; then echo "$el $i ok"; else echo "$el $i falló $(head -c 60 /tmp/err | tr '\n' ' ')"; fi
  sleep 0.1
done
