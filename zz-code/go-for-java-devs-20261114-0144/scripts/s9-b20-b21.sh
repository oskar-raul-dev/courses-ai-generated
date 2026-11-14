#!/usr/bin/env bash
# B-20 (tamaño de fragmento, con la versión Go de referencia) y B-21 (imágenes). En el host.
set -uo pipefail
cd "$(dirname "$0")/.."
SP=$(cd ../../cursos-algoritmos-lenguajes/go-for-java-devs/src/clearinghouse-spring && pwd)
L="--label curso=go-for-java-devs --network gfjd-net"
GOENV="-e DATABASE_URL=postgres://meridian:meridian@gfjd-pg:5432/chduel?sslmode=disable"
SQL() { docker exec gfjd-pg psql -U meridian -d chduel -qAt -c "$1"; }
echo "### B-20: cierre de un millón por tamaño de fragmento"
for size in 100 500 1000 5000 10000 50000; do
  SQL "TRUNCATE ledger_entries, batches"; SQL "UPDATE movements SET status='received'"; SQL "VACUUM ANALYZE movements"
  docker run --rm $L --cpus=4 --memory=2g $GOENV -v "$PWD/ch-go/bin":/b debian:bookworm-slim \
    sh -c "/b/clearinghouse close --day 2026-09-11 --chunk-size $size | sed 's/^/chunk=$size /'; echo memory.peak=\$(cat /sys/fs/cgroup/memory.peak)" | tr '\n' ' '; echo
done
echo "### B-21: imágenes"
docker build -q -t gfjd-ch:go --label curso=go-for-java-devs ch-go >/dev/null
docker build -q -t gfjd-ch:jvm --label curso=go-for-java-devs "$SP" >/dev/null
docker build -q -t gfjd-ch:jvm-alpine --build-arg BASE=eclipse-temurin:21-jre-alpine --label curso=go-for-java-devs "$SP" >/dev/null
docker images --filter label=curso=go-for-java-devs --format '{{.Repository}}:{{.Tag}} {{.Size}}' | grep gfjd-ch
for b in gcr.io/distroless/static-debian12:nonroot eclipse-temurin:21-jre eclipse-temurin:21-jre-alpine; do docker pull -q $b >/dev/null; docker images $b --format "base $b: {{.Size}}"; done
docker run --rm gfjd-ch:jvm-alpine java -version 2>&1 | head -1
echo "### compilación desde limpio"
( time docker run --rm --label curso=go-for-java-devs -v gfjd-gopath:/go -v "$PWD/ch-go":/ch -w /ch -e GOWORK=off -e CGO_ENABLED=0 golang:1.25.1-bookworm sh -c 'go clean -cache && go build -o /tmp/x .' ) 2>&1 | grep real | sed 's/^/Go: /'
( time docker run --rm --label curso=go-for-java-devs -v gfjd-m2:/root/.m2 -v "$SP":/app -w /app maven:3.9.11-eclipse-temurin-21 mvn -q -B clean package -DskipTests ) 2>&1 | grep real | sed 's/^/Maven: /'
