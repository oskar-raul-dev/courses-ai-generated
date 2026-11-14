#!/usr/bin/env bash
# S10 · B-24, la parte HTTP: arranque en frío, RSS en reposo y bajo carga, latencia,
# rendimiento, CPU por petición y pico de 10×. Corre en el host. Necesita chduel sembrada.
set -uo pipefail
cd "$(dirname "$0")/.."
SP=$(cd ../../cursos-algoritmos-lenguajes/go-for-java-devs/src/clearinghouse-spring && pwd)
L="--label curso=go-for-java-devs --network gfjd-net"
LIM="--cpus=4 --memory=2g"
GOENV="-e DATABASE_URL=postgres://meridian:meridian@gfjd-pg:5432/chduel?sslmode=disable"
JENV="-e DATABASE_URL=jdbc:postgresql://gfjd-pg:5432/chduel -e SPRING_FLYWAY_BASELINE_ON_MIGRATE=true -e SPRING_FLYWAY_BASELINE_VERSION=2"
TUNED="-XX:+UseG1GC -XX:MaxRAMPercentage=75.0 -XX:InitialRAMPercentage=50.0 -XX:MaxGCPauseMillis=100 -XX:+UseStringDeduplication -XX:+TieredCompilation -XX:+AlwaysPreTouch -Xss512k -XX:+ExitOnOutOfMemoryError"
START="-XX:TieredStopAtLevel=1 -XX:+UseSerialGC"
docker run --rm --label curso=go-for-java-devs -v gfjd-gopath:/go golang:1.25.1-bookworm go install github.com/tsenart/vegeta/v12@v12.13.0 2>&1 | tail -1
VEG() { docker run --rm $L -v gfjd-gopath:/go -v "$PWD/salidas":/out golang:1.25.1-bookworm sh -c "$1"; }

echo "### arranque en frío y RSS en reposo (5 corridas por configuración)"
for i in 1 2 3 4 5; do docker run --rm $L $LIM $GOENV -e HTTP_ADDR=:8080 -v "$PWD/ch-go/bin":/b -v "$PWD/scripts":/s:ro debian:bookworm-slim bash /s/cold-start.sh 8080 /b/clearinghouse serve | tr '\n' ' '; echo " ← Go"; done
for cfg in defecto ajustada arranque; do
  case $cfg in defecto) o="";; ajustada) o="$TUNED";; arranque) o="$START";; esac
  for i in 1 2 3 4 5; do docker run --rm $L $LIM $JENV -v "$SP/target":/app -v "$PWD/scripts":/s:ro eclipse-temurin:21-jre bash /s/cold-start.sh 8081 java $o -jar /app/clearinghouse.jar | tr '\n' ' '; echo " ← Spring ($cfg)"; done
done

carga() { # nombre url-base
  local n=$1 url=$2
  echo "GET $url/movements?store=ST-001&limit=50&cursor=ST-001-R00050000" > salidas/targets-$n.txt
  VEG "vegeta attack -targets=/out/targets-$n.txt -rate=200 -duration=30s > /dev/null"   # calentamiento
  local c=$3
  local cpu0=$(docker exec $c cat /sys/fs/cgroup/cpu.stat | awk '/usage_usec/{print $2}')
  VEG "vegeta attack -targets=/out/targets-$n.txt -rate=500 -duration=60s > /out/res-$n.bin && vegeta report /out/res-$n.bin | sed -n '1,8p'"
  local cpu1=$(docker exec $c cat /sys/fs/cgroup/cpu.stat | awk '/usage_usec/{print $2}')
  echo "CPU por petición: $(( (cpu1 - cpu0) / 30000 )) µs   RSS bajo carga: $(docker exec $c cat /sys/fs/cgroup/memory.current | awk '{printf "%.0f MB", $1/1048576}')"
  echo "-- pico de 10×: 50 rps 20 s → 500 rps 15 s → 50 rps 20 s (p99 de cada tramo)"
  for r in "50 20s" "500 15s" "50 20s"; do set -- $r; VEG "vegeta attack -targets=/out/targets-$n.txt -rate=$1 -duration=$2 | vegeta report -type=text | grep -E 'Latencies|Success'" | tr '\n' ' '; echo; done
}
echo "### Go bajo carga"
docker run -d --name gfjd-chgo $L $LIM $GOENV -v "$PWD/ch-go/bin":/b debian:bookworm-slim /b/clearinghouse serve >/dev/null; sleep 2
carga go http://gfjd-chgo:8080 gfjd-chgo; docker rm -f gfjd-chgo >/dev/null
for cfg in defecto ajustada; do
  o=""; [ $cfg = ajustada ] && o="$TUNED"
  echo "### Spring ($cfg) bajo carga"
  docker run -d --name gfjd-chsp $L $LIM $JENV -v "$SP/target":/app eclipse-temurin:21-jre java $o -jar /app/clearinghouse.jar >/dev/null; sleep 15
  carga sp-$cfg http://gfjd-chsp:8081 gfjd-chsp; docker rm -f gfjd-chsp >/dev/null
done
