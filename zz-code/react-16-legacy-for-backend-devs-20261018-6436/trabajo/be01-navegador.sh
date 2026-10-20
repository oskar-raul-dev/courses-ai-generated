#!/usr/bin/env bash
# Corre el binario de una rama de be01 dentro del espacio de red de r16t7-app (3011) y la spec del navegador.
# Uso: trabajo/be01-navegador.sh <rama-o-tag> <salida.json>
Z="$(cd "$(dirname "$0")/.." && pwd)"
REF="$1"; OUT="$2"
rm -rf "$Z/etapas/be01-nav" && git -C "$Z/esclusa-app" worktree add -q -f "$Z/etapas/be01-nav" "$REF" 2>/dev/null || git -C "$Z/esclusa-app" worktree add -q --detach "$Z/etapas/be01-nav" "$REF"
docker rm -f -v r16t7-gonav >/dev/null 2>&1
docker run -d --name r16t7-gonav --label curso=react16 --network container:r16t7-app -v "$Z/etapas/be01-nav/server":/src \
  -v r16t7-gomod:/go/pkg/mod -w /src -e PORT=3011 golang:1.19.13 go run ./cmd/api >/dev/null
for i in $(seq 1 60); do docker exec r16t7-app curl -s -o /dev/null localhost:3011/health 2>/dev/null && break; sleep 2; done
docker run --rm --label curso=react16 --network container:r16t7-app -v "$Z/trabajo/recorrido":/e2e -w /e2e \
  -v "$Z/esclusa-app/node_modules/axios/dist":/axios:ro -e CYPRESS_OUT="salida/$OUT" -e NO_COLOR=1 \
  cypress/included:10.11.0 --browser electron --spec cypress/e2e/be01-navegador.cy.js 2>&1 | grep -E "✓|✖|passing|failing|Error" | head -5
cat "$Z/trabajo/recorrido/salida/$OUT"; echo
docker logs r16t7-gonav 2>&1 | grep -E "panic serving|PÁNICO|GET /players" | head -4
docker rm -f -v r16t7-gonav >/dev/null
git -C "$Z/esclusa-app" worktree remove --force "$Z/etapas/be01-nav"
