#!/usr/bin/env bash
# Corre la receta a mano de A13 §6 extraída del apéndice publicado, con cuatro sustituciones de prueba:
# nombres con prefijo a8-t2-, etiquetas de la sesión, puertos aleatorios (127.0.0.1::) y '-it … bash'
# cambiado por '-d … sleep infinity'. Dentro: npm ci, un Express en el 3000 (el mock de la Fase 4 escucha
# igual) y ng serve; curl a los dos desde el Mac. Uso: ./t2-receta-a-mano.sh
set -uo pipefail
cd "$(dirname "$0")"
A13=../../cursos-legacy/angular-8-legacy-for-backend-devs/a13-docker-colima.md
python3 extraer-bloques.py "$A13" '# Desde la raíz del repositorio, una sola vez.' salidas/t2/receta.sh >/dev/null
L="--label curso=angular-8-legacy --label tanda=AS"
sed -e "s/clinical-lab-dev/a8-t2-clinical-lab-dev/g" -e "s/lab-node-modules/a8-t2-lab-node-modules/g" \
    -e "s/docker build /docker build $L /" -e "s/docker volume create /docker volume create $L /" \
    -e "s/docker run -it --rm /docker run -d $L /" -e "s/127.0.0.1:4200:4200/127.0.0.1::4200/" \
    -e "s/127.0.0.1:3000:3000/127.0.0.1::3000/" -e "s/a8-t2-clinical-lab-dev bash$/a8-t2-clinical-lab-dev sleep infinity/" \
    salidas/t2/receta.sh > salidas/t2/receta-prueba.sh
diff salidas/t2/receta.sh salidas/t2/receta-prueba.sh
docker rm -f -v a8-t2-clinical-lab-dev >/dev/null 2>&1; docker volume rm a8-t2-lab-node-modules >/dev/null 2>&1
(cd devc/clinical-lab && bash ../../salidas/t2/receta-prueba.sh > /dev/null) ; echo "EXIT_RECETA=$?"
C=a8-t2-clinical-lab-dev
docker exec $C bash -c 'ls -ld node_modules; time npm ci > /tmp/ci.log 2>&1; echo EXIT_NPM_CI=$?; tail -1 /tmp/ci.log'
docker exec -d $C node -e "require('express')().get('/', (q, r) => r.send('mock')).listen(3000)"
docker exec -d $C bash -c 'npx ng serve --host 0.0.0.0 --poll 2000 > /tmp/serve.log 2>&1'
for i in $(seq 1 90); do docker exec $C grep -q 'Compiled successfully' /tmp/serve.log 2>/dev/null && break; sleep 2; done
P4200=$(docker port $C 4200/tcp | head -1 | sed 's/.*://'); P3000=$(docker port $C 3000/tcp | head -1 | sed 's/.*://')
echo "4200 desde el Mac: $(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:$P4200/)"
echo "3000 desde el Mac: $(curl -s -w ' %{http_code}' http://127.0.0.1:$P3000/)"
docker rm -f -v $C >/dev/null; docker volume rm a8-t2-lab-node-modules >/dev/null
