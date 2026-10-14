#!/usr/bin/env bash
# El hot spot, provocado: el mismo mes de lecturas de toda la flota en dos tablas del anillo de tres nodos,
# una partida por (aeronave, mes) —la de la Fase 17— y otra solo por mes. El keyspace no replica (RF 1), así
# que cada partición vive en un solo nodo y se ve a quién le tocó cada escritura.
#
#   18-columnar-romper-y-medir/hotspot.sh   (desde src/, con el anillo arriba y el laboratorio detenido)
set -uo pipefail
dc() { docker compose -f lab/compose.anillo.yaml "$@"; }
MONTH=${MONTH:-2026-09}

# el mes "en curso" de la flota, en CSV, desde reading-5m
CSV=$(mktemp)
node -e '
  const rl = require("readline").createInterface({ input: require("fs").createReadStream("lab/data/reading-5m/reading.ndjson") });
  const out = [];
  rl.on("line", (l) => { const r = JSON.parse(l); if (r.ts.startsWith(process.argv[1])) out.push([r.aircraft, process.argv[1], r.ts.replace("T", " ").replace("Z", "+0000"), r.flightId, r.egtC].join(",")); });
  rl.on("close", () => process.stdout.write(out.join("\n") + "\n"));' "$MONTH" > "$CSV"
echo "== $MONTH: $(wc -l < "$CSV" | tr -d ' ') lecturas de $(cut -d, -f1 "$CSV" | sort -u | wc -l | tr -d ' ') aeronaves"
dc cp "$CSV" c1:/tmp/month.csv >/dev/null 2>&1
# filas por aeronave, para repartirlas después según el nodo que guarda cada partición
ROWS=$(cut -d, -f1 "$CSV" | sort | uniq -c)
rm -f "$CSV"

dc exec -T c1 cqlsh -e "DROP KEYSPACE IF EXISTS hot;
CREATE KEYSPACE hot WITH replication = {'class': 'NetworkTopologyStrategy', 'datacenter1': 1};
CREATE TABLE hot.by_aircraft_month (aircraft text, month text, ts timestamp, flight_id text, egt_c int, PRIMARY KEY ((aircraft, month), ts));
CREATE TABLE hot.by_month (aircraft text, month text, ts timestamp, flight_id text, egt_c int, PRIMARY KEY ((month), aircraft, ts));" 2>&1 | grep -v '^$'
for t in by_aircraft_month by_month; do
  dc exec -T c1 cqlsh -e "COPY hot.$t (aircraft, month, ts, flight_id, egt_c) FROM '/tmp/month.csv'" 2>&1 | grep -E "rows imported"
done

# "Local write count" cuenta mutaciones, y COPY agrupa varias filas de una partición en una: las filas
# por nodo salen de preguntar a qué nodo pertenece cada partición (bash 3 de macOS: sin arreglos asociativos)
NODES=$(for n in c1 c2 c3; do echo "$(dc exec -T $n hostname -i | tr -d '\r') $n"; done)
node_of() { awk -v ip="$1" '$1 == ip {print $2}' <<<"$NODES"; }
MONTH_NODE=$(node_of "$(dc exec -T c1 nodetool getendpoints hot by_month "$MONTH" | tr -d '\r')")
PLACED=$(while read -r count aircraft; do
  # </dev/null: docker compose exec lee la entrada estándar y se comería el resto de las filas
  echo "$count $(node_of "$(dc exec -T c1 nodetool getendpoints hot by_aircraft_month "$aircraft:$MONTH" </dev/null | tr -d '\r')") $MONTH_NODE"
done <<<"$ROWS")
echo "== filas por nodo"
for n in c1 c2 c3; do
  printf "  %s · por (aeronave, mes) %7s · por mes %7s\n" "$n" \
    "$(awk -v n=$n '$2 == n {s += $1} END {print s + 0}' <<<"$PLACED")" \
    "$(awk -v n=$n '$3 == n {s += $1} END {print s + 0}' <<<"$PLACED")"
done

for t in by_aircraft_month by_month; do
  echo "== hot.$t: lo que dice cada nodo"
  for n in c1 c2 c3; do
    dc exec -T $n nodetool flush hot $t
    s=$(dc exec -T $n nodetool tablestats hot.$t)
    printf "  %s · escrituras locales %8s · particiones %3s · partición máxima %10s B · en disco %10s B\n" "$n" \
      "$(grep 'Local write count' <<<"$s" | awk '{print $NF}')" \
      "$(grep 'Number of partitions' <<<"$s" | awk '{print $NF}')" \
      "$(grep 'Compacted partition maximum bytes' <<<"$s" | awk '{print $NF}')" \
      "$(grep 'Space used (live)' <<<"$s" | awk '{print $NF}')"
  done
done
