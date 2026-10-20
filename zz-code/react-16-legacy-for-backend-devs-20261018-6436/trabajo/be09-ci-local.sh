#!/usr/bin/env bash
# Los pasos del trabajo "test" de .github/workflows/ci.yml, en contenedores: golang:1.19.13 con un postgres:13 que se
# llama "postgres" en la red, como el servicio del workflow. Sin runner (D31).
Z="$(cd "$(dirname "$0")/.." && pwd)"
docker rm -f -v r16t10-ci-pg >/dev/null 2>&1
docker run -d --name r16t10-ci-pg --label curso=react16 --network r16t7-net --network-alias postgres \
  -e POSTGRES_USER=esclusa -e POSTGRES_PASSWORD=esclusa -e POSTGRES_DB=esclusa_test postgres:13 >/dev/null
for i in $(seq 1 30); do docker exec r16t10-ci-pg pg_isready -U esclusa >/dev/null 2>&1 && break; sleep 1; done
docker run --rm --label curso=react16 --network r16t7-net -v "$Z/esclusa-app":/repo:ro -v r16t7-gomod:/go/pkg/mod \
  -e TEST_DB="postgres://esclusa:esclusa@postgres:5432/esclusa_test?sslmode=disable" golang:1.19.13 sh -c '
  cp -r /repo /w && cd /w/server
  for step in "make test-unit" "make test-handler" "make test-all TEST_DB=\"$TEST_DB\"" "CGO_ENABLED=0 go build -o /tmp/api ./cmd/api"; do
    s=$(date +%s); sh -c "$step" > /tmp/out 2>&1; rc=$?; e=$(date +%s)
    echo "== $step → código $rc en $((e-s)) s"; grep -E "^(ok|FAIL|--- FAIL)" /tmp/out | sed "s/^/   /"
  done'
docker rm -f -v r16t10-ci-pg >/dev/null 2>&1
