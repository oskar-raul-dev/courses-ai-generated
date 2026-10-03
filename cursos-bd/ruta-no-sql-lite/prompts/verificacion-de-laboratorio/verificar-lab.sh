#!/usr/bin/env bash
# Verificación del compose.yaml de la ruta (src/lab): para cada familia, levanta, escribe un
# marcador, apaga SIN -v, vuelve a levantar y comprueba que el marcador sigue ahí. Eso prueba
# que el volumen está montado donde el motor escribe de verdad. Anota RAM en reposo.
#
# Uso:  ./verificar-lab.sh [familia ...]
set -uo pipefail
LAB="$(cd "$(dirname "$0")/../../src/lab" && pwd)"
cd "$(dirname "$0")"
platform="${PLATFORM:-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m)}"
out="lab-${platform}.tsv"
[ -f "$out" ] || printf "fecha\tfamilia\tpersiste\tram_reposo\tnota\n" > "$out"

dc() { docker compose --project-directory "$LAB" -f "$LAB/compose.yaml" --profile "$1" "${@:2}"; }
ex() { dc "$1" exec -T "$1" "${@:2}"; }

write_marker() {
  case "$1" in
    base|series) ex "$1" psql -U postgres -qc "CREATE TABLE lab_marker (id int); INSERT INTO lab_marker VALUES (42);" ;;
    documental) ex "$1" mongosh --quiet --eval 'db.getSiblingDB("condor").labMarker.insertOne({id: 42})' ;;
    clave-valor) ex "$1" valkey-cli SET lab:marker 42 ;;
    busqueda) curl -s -XPUT "localhost:19200/lab-marker/_doc/1?refresh=true" -H 'content-type: application/json' -d '{"id":42}' ;;
    grafos) ex "$1" cypher-shell -u neo4j -p condor-mro "CREATE (:LabMarker {id: 42})" ;;
    vectorial) curl -s -XPUT localhost:16333/collections/lab_marker -H 'content-type: application/json' -d '{"vectors":{"size":4,"distance":"Cosine"}}' ;;
    columnar) ex "$1" cqlsh -e "CREATE KEYSPACE lab_marker WITH replication = {'class':'SimpleStrategy','replication_factor':1}" ;;
    offline) curl -s -XPUT -u condor:condor localhost:15984/lab_marker ;;
    newsql) ex "$1" cockroach sql --insecure -e "CREATE TABLE lab_marker (id INT PRIMARY KEY); INSERT INTO lab_marker VALUES (42);" ;;
  esac
}

read_marker() {
  case "$1" in
    base|series) ex "$1" psql -U postgres -tAc "SELECT id FROM lab_marker" ;;
    documental) ex "$1" mongosh --quiet --eval 'db.getSiblingDB("condor").labMarker.findOne().id' ;;
    clave-valor) ex "$1" valkey-cli GET lab:marker ;;
    busqueda) curl -s localhost:19200/lab-marker/_doc/1 | python3 -c "import sys,json;print(json.load(sys.stdin)['_source']['id'])" ;;
    grafos) ex "$1" cypher-shell -u neo4j -p condor-mro --format plain "MATCH (m:LabMarker) RETURN m.id" | tail -1 ;;
    vectorial) curl -s localhost:16333/collections/lab_marker | python3 -c "import sys,json;print(42 if json.load(sys.stdin)['status']=='ok' else 0)" ;;
    columnar) ex "$1" cqlsh -e "DESCRIBE KEYSPACES" | grep -q lab_marker && echo 42 ;;
    offline) curl -s -u condor:condor localhost:15984/lab_marker | python3 -c "import sys,json;print(42 if json.load(sys.stdin).get('db_name')=='lab_marker' else 0)" ;;
    newsql) ex "$1" cockroach sql --insecure --format=csv -e "SELECT id FROM lab_marker" | tail -1 ;;
  esac
}

families=("$@")
[ ${#families[@]} -eq 0 ] && families=(base documental clave-valor series busqueda grafos vectorial columnar offline newsql)

for f in "${families[@]}"; do
  echo "== $f"
  dc "$f" down -v >/dev/null 2>&1
  dc "$f" up -d --wait "$f" >/dev/null 2>&1 || { echo "   no llegó a healthy"; printf "%s\t%s\tNO\t-\tno healthy\n" "$(date -u +%FT%TZ)" "$f" >> "$out"; continue; }
  write_marker "$f" >/dev/null 2>&1
  dc "$f" down >/dev/null 2>&1
  dc "$f" up -d --wait "$f" >/dev/null 2>&1
  got=$(read_marker "$f" 2>/dev/null | tr -d '[:space:]')
  sleep 45
  ram=$(docker stats --no-stream --format '{{.MemUsage}}' "condor-lab-$f-1" | cut -d/ -f1 | tr -d ' ')
  persist=$([ "$got" = "42" ] && echo SI || echo "NO($got)")
  echo "   persiste tras down/up: $persist · RAM: $ram"
  printf "%s\t%s\t%s\t%s\t\n" "$(date -u +%FT%TZ)" "$f" "$persist" "$ram" >> "$out"
  dc "$f" down -v >/dev/null 2>&1
done
