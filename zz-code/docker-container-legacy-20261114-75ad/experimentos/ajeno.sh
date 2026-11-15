set -u
P=/Users/oskar/Developer/Learning/courses-ia-generated/zz-code/docker-container-legacy-20261114-75ad/proyectos/ajeno-angular8; V=/Users/oskar/Developer/Learning/courses-ia-generated/zz-code/docker-container-legacy-20261114-75ad/validacion/20261114-ajeno-angular8
docker volume create ajeno-node12-modules >/dev/null
docker rm -f p5-ajeno >/dev/null 2>&1
docker run -d --name p5-ajeno --platform linux/amd64 -e NODE_VERSION=12.22.12 \
  --mount type=bind,src=$P,dst=/workspace --mount type=volume,src=ajeno-node12-modules,dst=/workspace/node_modules \
  legacy-node-toolchain:phase15 sleep infinity >/dev/null
docker exec p5-ajeno bash -c 'node -v; npm -v; node -p process.versions.modules' > $V/toolchain.txt
x(){ n=$1; shift; s=$(date +%s); timeout ${T:-1200} docker exec p5-ajeno bash -c "$*" > $V/$n.log 2>&1; e=$?; echo "$n exit=$e $(( $(date +%s)-s ))s" | tee -a $V/exit-codes.txt; }
: > $V/exit-codes.txt
x install 'npm ci'
T=120 x test 'npm test -- --watch=false'
x lint 'npm run lint'
x build 'npm run build'
docker exec -d p5-ajeno bash -c 'npm start -- --host 0.0.0.0 > /tmp/serve.log 2>&1'
for i in $(seq 1 60); do docker exec p5-ajeno curl -sI http://localhost:4200 2>/dev/null | head -1 | grep -q 200 && break; sleep 3; done
{ echo "intentos=$i"; docker exec p5-ajeno curl -sI http://localhost:4200 | head -1; docker exec p5-ajeno tail -5 /tmp/serve.log; } > $V/http.txt 2>&1
docker exec p5-ajeno pkill -f "ng serve" ; docker exec p5-ajeno pkill -f karma; true
echo fin
