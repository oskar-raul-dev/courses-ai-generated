#!/usr/bin/env bash
# Copies the course's code blocks, as written in the markdown, into the clinical-lab skeleton.
# Usage: CURSO=<course dir> bash esqueleto/armar.sh   (from the zz-code directory)
set -euo pipefail
cd "$(dirname "$0")/.."
: "${CURSO:?set CURSO to the course directory}"
X="python3 extraer/bloque.py"
P=esqueleto/clinical-lab
mkdir -p $P/src/app/shared $P/src/app/core/config $P/src/assets

# Fase 02 §5.10 — the pipe, and the environment fragment (complete object)
$X 02-i18n.md "export class AppDatePipe" > $P/src/app/shared/app-date.pipe.ts
$X 02-i18n.md "timeZone: 'America/Toronto'" > $P/src/environments/environment.ts
sed 's/production: false/production: true/' $P/src/environments/environment.ts > $P/src/environments/environment.prod.ts
# Fase 05 §5.3 — the full SharedModule (with AppDatePipe declared and exported)
$X 05-pacientes.md "var SHARED_MODULES = [" > $P/src/app/shared/shared.module.ts
# Fase 13 §5.2, §5.3, §5.6, §5.7, §5.8
$X 13-build-despliegue.md '"timeZone": "${APP_TIME_ZONE}"' > $P/src/assets/config.template.json
$X 13-build-despliegue.md "export class AppConfigService" > $P/src/app/core/config/app-config.service.ts
$X 13-build-despliegue.md "FROM node:14.21.3-bullseye-slim AS build" > $P/Dockerfile
$X 13-build-despliegue.md "try_files \$uri \$uri/ /index.html;" > $P/nginx.conf
$X 13-build-despliegue.md "exec nginx -g 'daemon off;'" > $P/entrypoint.sh
printf 'node_modules\ndist\n.git\n' > $P/.dockerignore
# The fixture that the probe page renders (not from the course)
cp esqueleto/sonda/app.module.ts esqueleto/sonda/app.component.ts $P/src/app/
echo "assembled into $P"
