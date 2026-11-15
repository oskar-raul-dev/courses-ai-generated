#!/usr/bin/env bash
# P7 — limpieza de lo que creó la pasada (comparado contra logs/P0/00-docker-inventario-inicial.log).
# NO toca: php-refresh*, jaeger, graalvm, greenmail, openldap, openssh, distroless, ftp, r16nav-*,
# los volúmenes anónimos, la caché de build de Docker ni la podman-machine-default.
set -u
echo "== contenedores"; docker rm -f p5-registry-local 2>&1 | tail -1
echo "== imágenes"
docker images --format '{{.Repository}}:{{.Tag}}' | grep -E '^(legacy-node-toolchain|localhost:15000/|p[0-9]-|proyecto-final:)' | xargs -r docker rmi 2>&1 | grep -c -E "Untagged|Deleted"
docker rmi alpine:3.20 anchore/syft:v1.18.1 aquasec/trivy:0.58.1 debian:bookworm-slim debian/eol:buster \
  gcr.io/projectsigstore/cosign:v2.4.1 moby/buildkit:buildx-stable-1 node:16.20.2 quay.io/skopeo/stable:v1.16.1 \
  registry:2 rhysd/actionlint:1.7.4 selenium/standalone-chrome:4.1.4 2>&1 | grep -c -E "Untagged|Deleted"
echo "== volúmenes"
docker volume ls -q | grep -E '^(p[1-5]-|ajeno-node12-modules$|labcore-node10-modules$|legacy-node-toolchain-opt$|legacy-node10-modules$)' | xargs -r docker volume rm | wc -l
echo "== Podman"; CONTAINER_CONNECTION=p4-legacy podman machine rm -f p4-legacy 2>&1 | tail -1
echo "== Lima"; for v in p6-node14 p6-node26; do limactl delete -f $v 2>&1 | tail -1; done
echo "== artefactos grandes en zz-code"; Z=/Users/oskar/Developer/Learning/courses-ia-generated/zz-code/docker-container-legacy-20261114-75ad
rm -fv $Z/experimentos/f29/img.tar $Z/experimentos/a13/toolchain-1.0.0.tar.gz $Z/experimentos/a13/toolchain.tar $Z/experimentos/f29/cosign/*.key $Z/experimentos/a13/ca/ca.key $Z/experimentos/a17/bin14/node 2>/dev/null | wc -l
echo "== resto: lo que queda de la pasada"; docker images --format '{{.Repository}}:{{.Tag}}' | grep -cE 'legacy-node|^p[0-9]-'; docker volume ls -q | grep -cE '^p[1-5]-'; limactl list 2>&1 | tail -1
