#!/usr/bin/env bash
# T3 (a7 §6): ¿Stubby de F0 (:8888) responde desde el Mac cuando corre en un contenedor?
name=vue2-t3-stubby
docker run -d --name $name --label curso=vue2-legacy --label tanda=T3 -p 127.0.0.1::8888 \
  -v "$PWD/f00/tiquetera-legacy:/src:ro" node:14.21.3 sh -c 'cp -r /src /w && cd /w && npm ci --silent >/dev/null 2>&1 && npm run mock' >/dev/null
for i in $(seq 1 90); do docker logs $name 2>&1 | grep -qi "stubs portal\|Quit: ctrl-c" && break; sleep 2; done
docker logs $name 2>&1 | grep -i "portal\|running\|8888" | head -5
hp=$(docker port $name 8888 | head -1)
ruta=/api/hello   # la del stubby.yml de F0
echo "ruta $ruta -> desde el Mac: $(curl -s -o /dev/null -w '%{http_code}' --max-time 5 -X POST "http://$hp$ruta")"
docker exec $name sh -c 'cat /proc/net/tcp /proc/net/tcp6 2>/dev/null | awk "NR>1 && \$4==\"0A\" {print \$2}"' | sort -u
docker rm -f -v $name >/dev/null
