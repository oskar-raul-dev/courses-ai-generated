#!/usr/bin/env bash
# Incident 19 and Fase 13, against the clinical-lab skeleton image built with the Fase 13 Dockerfile.
# Runs the cuaderno's `docker run` blocks as written, with two changes: a label, and the port bound to
# 127.0.0.1:18080 instead of 8080. Then renders the probe page in headless Chrome in other zones.
# Usage: CURSO=<course dir> bash incidente19.sh   (needs lab-frontend:t1 built from esqueleto/clinical-lab)
set -euo pipefail
cd "$(dirname "$0")"
: "${CURSO:?set CURSO}"
NET=angular8-t1
CHROME=zenika/alpine-chrome:124
docker tag lab-frontend:t1 lab-frontend:inc19
docker network inspect $NET >/dev/null 2>&1 || docker network create --label curso=angular8 $NET >/dev/null

adapt() {  # the course command -> the one we run
  sed -e 's/docker run -d /docker run -d --label curso=angular8 --network '$NET' /' -e 's/-p 8080:80/-p 127.0.0.1:18080:80/'
}
render() {  # $1 = TZ of the browser
  docker run --rm --label curso=angular8 --network $NET -e TZ="$1" $CHROME \
    --no-sandbox --virtual-time-budget=5000 --dump-dom http://lab-frontend-prod/ 2>/dev/null \
    | python3 -c 'import sys,re,html; d=sys.stdin.read(); [print("   ", " | ".join(html.unescape(c).strip() for c in re.findall(r"<td[^>]*>(.*?)</td>", r))) for r in re.findall(r"<tr[^>]*>(.*?)</tr>", d, re.S)]; print("    config:", html.unescape((re.findall(r"<p id=\"config\">(.*?)</p>", d) or ["?"])[0]))'
}

docker rm -f lab-frontend-prod >/dev/null 2>&1 || true
echo "== 1. the command 'deployed to PROD' (cuaderno, incident 19)"
python3 extraer/bloque.py cuaderno-incidentes.md "docker build -t lab-frontend:inc19 ." | grep -v '^docker build' | adapt | bash -s >/dev/null
sleep 1
echo "-- config.json"; curl -s http://127.0.0.1:18080/assets/config.json; echo
echo "-- docker logs | head -3"; docker logs lab-frontend-prod 2>&1 | head -3
echo "-- docker inspect env"; docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' lab-frontend-prod
echo "-- the page, browser in Asia/Tokyo (columns: instant | appDate env | appDate config | date with IANA)"; render Asia/Tokyo

echo "== 2. the fix (cuaderno, incident 19)"
python3 extraer/bloque.py cuaderno-incidentes.md "-e API_URL=http://prod.interno:3000" | grep -v '^docker logs' | adapt | bash -s >/dev/null
sleep 1
echo "-- docker logs | head -1"; docker logs lab-frontend-prod 2>&1 | head -1
echo "-- config.json"; curl -s http://127.0.0.1:18080/assets/config.json; echo

echo "== 3. no APP_TIME_ZONE: the entrypoint default"
docker rm -f lab-frontend-prod >/dev/null
docker run -d --label curso=angular8 --network $NET --name lab-frontend-prod -p 127.0.0.1:18080:80 lab-frontend:inc19 >/dev/null; sleep 1
curl -s http://127.0.0.1:18080/assets/config.json; echo

echo "== 4. Fase 13 exercise 13: APP_TIME_ZONE=America/Vancouver, browser in UTC"
docker rm -f lab-frontend-prod >/dev/null
docker run -d --label curso=angular8 --network $NET --name lab-frontend-prod -p 127.0.0.1:18080:80 -e APP_TIME_ZONE=America/Vancouver lab-frontend:inc19 >/dev/null; sleep 1
render UTC

docker rm -f lab-frontend-prod >/dev/null
