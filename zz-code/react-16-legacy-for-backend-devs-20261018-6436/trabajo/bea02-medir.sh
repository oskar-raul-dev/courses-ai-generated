#!/usr/bin/env bash
# bea-02: la versión A (rama apendice/bea-02, desde fase-be03) de punta a punta, y los errores 6.2 y 6.3.
Z="$(cd "$(dirname "$0")/.." && pwd)"
W="$Z/etapas/bea02"; rm -rf "$W"; git -C "$Z/esclusa-app" worktree prune; git -C "$Z/esclusa-app" worktree add -q --detach "$W" apendice/bea-02
C="docker compose -p r16t11 -f $W/server/docker-compose.yml -f $Z/trabajo/bea02/compose-lab.yml"
echo "== up"; s=$(date +%s); $C up -d --build 2>&1 | tail -2; e=$(date +%s); echo "($((e-s)) s)"
for i in $(seq 1 60); do docker exec r16t7-app curl -s -o /dev/null localhost:3001/health && break; sleep 2; done
$C ps --format '{{.Service}} {{.State}} {{.Status}}'; $C logs migrate 2>&1 | tail -1
echo "== siembra"; $C exec -T api /seed -file /mock/db.json 2>&1 | tail -1
echo "== la imagen"; docker image ls --format '{{.Repository}}:{{.Tag}} {{.Size}}' | grep r16t11
echo "== smoke.sh de be03"
docker run --rm --label curso=react16 --network r16t7-net -v "$W":/repo -w /repo -v "$Z/salidas/apk-cache":/etc/apk/cache alpine:3.20 \
  sh -c 'apk add -q bash curl jq >/dev/null 2>&1; BASE_URL=http://app:3001 bash server/smoke.sh' 2>&1 | tail -2
echo "== 6.2: localhost dentro del contenedor"
docker run --rm --label curso=react16 --network r16t7-net -e DATABASE_URL="postgres://esclusa:esclusa@localhost:5432/esclusa?sslmode=disable" r16t11-api 2>&1 | tail -1
$C down -v 2>&1 | tail -1
echo "== 6.3: sin healthcheck ni condition, cinco veces con down -v"
sed -e '/healthcheck:/,/retries: 15/d' -e 's/db: { condition: service_healthy }/- db/' -e 's/migrate: { condition: service_completed_successfully }/- migrate/' "$W/server/docker-compose.yml" > "$W/server/compose-sin-health.yml"
for i in 1 2 3 4 5; do
  docker compose -p r16t11 -f "$W/server/compose-sin-health.yml" -f "$Z/trabajo/bea02/compose-lab.yml" up -d 2>/dev/null >/dev/null; sleep 6
  echo "corrida $i: migrate $(docker inspect -f '{{.State.ExitCode}}' r16t11-migrate-1) · $(docker logs r16t11-migrate-1 2>&1 | tail -1 | cut -c1-110)"
  docker compose -p r16t11 -f "$W/server/compose-sin-health.yml" -f "$Z/trabajo/bea02/compose-lab.yml" down -v >/dev/null 2>&1
done
rm -f "$W/server/compose-sin-health.yml"
git -C "$Z/esclusa-app" worktree remove --force "$W"
