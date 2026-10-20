#!/usr/bin/env bash
# Corre las pruebas de regresión de be-01 y be-03 en su rama (rojo) y en la fase o la corrección (verde).
Z="$(cd "$(dirname "$0")/../.." && pwd)"
run() { # $1 ref  $2 archivo de prueba  $3 parche opcional (python)
  rm -rf "$Z/etapas/inc" && git -C "$Z/esclusa-app" worktree add -q --detach "$Z/etapas/inc" "$1"
  cp "$Z/trabajo/incidentes/$2" "$Z/etapas/inc/server/internal/http/"
  [ -n "${3:-}" ] && python3 -c "$3" "$Z/etapas/inc/server/internal/http"
  docker run --rm --label curso=react16 -v "$Z/etapas/inc/server":/src -v r16t7-gomod:/go/pkg/mod -w /src golang:1.19.13 \
    sh -c 'go test -count=1 ./internal/http/ 2>&1 | grep -E "^(ok|FAIL|---|    )" | grep -v "^    \[" | head -8' 
  git -C "$Z/esclusa-app" worktree remove --force "$Z/etapas/inc"
}
echo "### be-01 en incidente/be-01 (rojo)"; run incidente/be-01 be01_expose_test.go
echo "### be-01 en fase-be01 (verde)"; run fase-be01-go-y-la-forma-del-monolito be01_expose_test.go
echo "### be-03 en incidente/be-03 (rojo)"; run incidente/be-03 be03_panic_test.go
FIX='import sys,re,os
d=sys.argv[1]
p=os.path.join(d,"players.go"); s=open(p).read(); s=s.replace("r.URL.Query()[\"name_like\"][0]","r.URL.Query().Get(\"name_like\")"); open(p,"w").write(s)
p=os.path.join(d,"router.go"); s=open(p).read(); s=s.replace("\thandler = chaosMiddleware(chaos)(handler)\n","\thandler = chaosMiddleware(chaos)(handler)\n\thandler = recoverMiddleware(handler)\n"); open(p,"w").write(s)'
echo "### be-03 con la corrección (handler + recover) (verde)"; run incidente/be-03 be03_panic_test.go "$FIX"
