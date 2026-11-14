#!/usr/bin/env bash
# B-07: 100.000 tareas de 10 ms. Cada variante en un contenedor con --cpus=4 --memory=2g.
cd "$(dirname "$0")/.."
L="--label curso=go-for-java-devs --cpus=4 --memory=2g"
docker run --rm --label curso=go-for-java-devs -v gfjd-gopath:/go -v "$PWD/b07":/b -w /b -e GOWORK=off -e CGO_ENABLED=0 golang:1.25.1-bookworm sh -c 'go mod init b07 >/dev/null 2>&1; go build -o spawn spawn.go'
for i in 1 2 3; do docker run --rm $L -v "$PWD/b07":/b debian:bookworm-slim sh -c '/b/spawn 100000; echo memory.peak=$(cat /sys/fs/cgroup/memory.peak)'; done
for m in virtual platform; do for i in 1 2 3; do docker run --rm $L -v "$PWD/b07":/b eclipse-temurin:21-jdk sh -c "cd /tmp && javac -d /tmp /b/Threads.java && java -cp /tmp Threads $m 100000 2>&1 | tail -2; echo memory.peak=\$(cat /sys/fs/cgroup/memory.peak)"; done; done
