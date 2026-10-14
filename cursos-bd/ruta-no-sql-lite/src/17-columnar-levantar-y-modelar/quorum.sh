#!/usr/bin/env bash
# La consistencia ajustable, ejecutada en el anillo de tres nodos (lab/compose.anillo.yaml): qué nivel
# responde con cuántos nodos caídos, y una lectura vieja provocada a propósito.
#
#   17-columnar-levantar-y-modelar/quorum.sh   (desde src/, con el anillo arriba y el laboratorio detenido)
set -uo pipefail
dc() { docker compose -f lab/compose.anillo.yaml "$@"; }
cql() { local node=$1; shift; dc exec -T "$node" cqlsh -e "$*" 2>&1 | grep -v '^$'; }

echo "== el anillo"
dc exec -T c1 nodetool status | grep -E '^UN|^DN'
cql c1 "DROP KEYSPACE IF EXISTS condor;
CREATE KEYSPACE condor WITH replication = {'class': 'NetworkTopologyStrategy', 'datacenter1': 3};
CREATE TABLE condor.reading_by_aircraft_month (aircraft text, month text, ts timestamp, egt_c int, PRIMARY KEY ((aircraft, month), ts));"

# la matriz: con 0, 1 y 2 nodos caídos, escribir y leer en ONE, QUORUM y ALL
probe() {
  for cl in ONE QUORUM ALL; do
    # la salida se guarda antes de buscar en ella: con pipefail, grep -q cortaría la tubería y mentiría
    local wo ro
    wo=$(cql c1 "CONSISTENCY $cl; INSERT INTO condor.reading_by_aircraft_month (aircraft, month, ts, egt_c) VALUES ('HC-2157', '2025-10', '2025-10-01 12:00:00', 700);")
    ro=$(cql c1 "CONSISTENCY $cl; SELECT egt_c FROM condor.reading_by_aircraft_month WHERE aircraft = 'HC-2157' AND month = '2025-10';")
    w=$(grep -qE "Error|Unavailable|NoHostAvailable" <<<"$wo" && echo falla || echo ok)
    r=$(grep -qE "Error|Unavailable|NoHostAvailable" <<<"$ro" && echo falla || echo ok)
    echo "  $1 caídos · $cl · escribir $w · leer $r"
  done
}
echo "== la matriz"
probe 0
dc stop c3 >/dev/null 2>&1; probe 1
dc stop c2 >/dev/null 2>&1; probe 2
echo "  el mensaje literal:"
cql c1 "CONSISTENCY QUORUM; SELECT egt_c FROM condor.reading_by_aircraft_month WHERE aircraft = 'HC-2157' AND month = '2025-10';" | grep -o "Cannot achieve.*" | head -1
dc start c2 c3 >/dev/null 2>&1
dc up -d --wait >/dev/null 2>&1

echo "== la lectura vieja"
for n in c1 c2 c3; do echo "  $n = $(dc exec -T $n hostname -i | tr -d '\r')"; done
# sin hints, la réplica que estuvo caída no recibe lo que se escribió mientras tanto
for n in c1 c2 c3; do dc exec -T $n nodetool disablehandoff; done
cql c1 "CONSISTENCY ALL; INSERT INTO condor.reading_by_aircraft_month (aircraft, month, ts, egt_c) VALUES ('HC-2157', '2025-10', '2025-10-02 12:00:00', 700);" >/dev/null
dc stop c3 >/dev/null 2>&1
cql c1 "CONSISTENCY ONE; UPDATE condor.reading_by_aircraft_month SET egt_c = 745 WHERE aircraft = 'HC-2157' AND month = '2025-10' AND ts = '2025-10-02 12:00:00';" >/dev/null
echo "  con c3 caído: 700 → 745, escrito en ONE"
dc start c3 >/dev/null 2>&1; dc up -d --wait >/dev/null 2>&1
SEL="SELECT egt_c FROM condor.reading_by_aircraft_month WHERE aircraft = 'HC-2157' AND month = '2025-10' AND ts = '2025-10-02 12:00:00';"
# el valor y el nodo que leyó, de la traza: la línea "Read N live rows" trae la columna source
C3=$(dc exec -T c3 hostname -i | tr -d '\r')
LAST=""
read_with() {
  local out; out=$(cql c3 "CONSISTENCY $1; TRACING ON; $SEL")
  LAST=$(grep 'live rows' <<<"$out" | awk -F'|' '{gsub(/ /,"",$3); print $3}' | sort -u | tr '\n' ' ')
  local repair=""; grep -qiE 'mismatch|repair' <<<"$out" && repair=" · reparación al leer"
  echo "  $1 desde c3 → $(grep -E '^ +[0-9]+$' <<<"$out" | tr -d ' ') · leyó $LAST$repair"
}
# en ONE el coordinador elige una réplica, y evita la que acaba de volver: se repite hasta que conteste c3
for i in $(seq 1 30); do read_with ONE; [[ $LAST == "$C3 " ]] && break; sleep 1; done
read_with QUORUM
for i in 1 2 3; do read_with ONE; done
for n in c1 c2 c3; do dc exec -T $n nodetool enablehandoff; done
