#!/usr/bin/env bash
# be-16: la imagen de la rama y la de la fase, construidas sin caché; y qué pasa al arrancar cada una.
Z="$(cd "$(dirname "$0")/../.." && pwd)"
for ref in incidente/be-16 fase-be09-empaquetado-ambientes-y-pipeline; do
  rm -rf "$Z/etapas/img"; git -C "$Z/esclusa-app" worktree prune; git -C "$Z/esclusa-app" worktree add -q --detach "$Z/etapas/img" "$ref"
  T="r16t10-esclusa-api:$(echo "$ref" | tr '/' '-')"
  echo "### $ref"
  docker build --no-cache --label curso=react16 -t "$T" "$Z/etapas/img/server" 2>&1 | grep -iE "warn|error|naming to" | head -3
  C=$(docker run -d --label curso=react16 --network r16t7-net -e DATABASE_URL="postgres://esclusa:esclusa@pg:5432/esclusa?sslmode=disable" \
      -e JWT_SECRET=laboratorio-esclusa-secreto-de-32-bytes-o-mas "$T"); sleep 3
  echo "estado: $(docker inspect -f '{{.State.Status}} (salida {{.State.ExitCode}})' "$C")"; docker logs "$C" 2>&1 | tail -2
  docker rm -f -v "$C" >/dev/null
  docker run --rm --label curso=react16 -v "$Z/etapas/img/server":/src -v r16t7-gomod:/go/pkg/mod -w /src golang:1.19.13 sh -c \
    "$( [ "$ref" = incidente/be-16 ] && echo 'CGO_ENABLED=1 go build -tags sqlite' || echo 'CGO_ENABLED=0 go build' ) -o /tmp/api ./cmd/api 2>/dev/null && (apt-get -qq install -y file >/dev/null 2>&1 || true) && go version -m /tmp/api | grep -o 'CGO_ENABLED=[01]'; ldd /tmp/api 2>&1 | head -2"
  git -C "$Z/esclusa-app" worktree remove --force "$Z/etapas/img"
done
