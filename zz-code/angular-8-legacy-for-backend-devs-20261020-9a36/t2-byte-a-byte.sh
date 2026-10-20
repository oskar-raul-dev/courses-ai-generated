#!/usr/bin/env bash
# Extrae de A13 publicado el Dockerfile y el devcontainer.json de §6 y los compara byte a byte con los
# probados en T0 (devc/clinical-lab/.devcontainer); comprueba que el JSONC parsea. Uso: ./t2-byte-a-byte.sh
set -uo pipefail
cd "$(dirname "$0")"
A13=../../cursos-legacy/angular-8-legacy-for-backend-devs/a13-docker-colima.md
mkdir -p salidas/t2/publicado
python3 extraer-bloques.py "$A13" '# .devcontainer/Dockerfile' salidas/t2/publicado/Dockerfile
python3 extraer-bloques.py "$A13" '// .devcontainer/devcontainer.json' salidas/t2/publicado/devcontainer.json
for f in Dockerfile devcontainer.json; do
  cmp -s salidas/t2/publicado/$f devc/clinical-lab/.devcontainer/$f && echo "$f IGUAL" || echo "$f DISTINTO"
done
shasum -a 256 salidas/t2/publicado/* devc/clinical-lab/.devcontainer/*
python3 -I -c "
import json, re
s = open('salidas/t2/publicado/devcontainer.json').read()
d = json.loads(re.sub(r'^\s*//.*$', '', s, flags=re.M))
print('JSONC parsea:', sorted(d))"
