#!/bin/sh
# entrypoint.sh
# Corre UNA vez, en el arranque del contenedor, antes de que nginx acepte nada.

set -e

# Valores por defecto: si el contenedor arranca sin -e, no queda un ${API_URL}
# literal metido en el JSON. Un default sensato evita un config roto silencioso.
export API_URL="${API_URL:-http://localhost:3000}"
export ENVIRONMENT_NAME="${ENVIRONMENT_NAME:-local}"
export APP_TIME_ZONE="${APP_TIME_ZONE:-America/Toronto}"
export FEATURE_DELIVERY_PDF="${FEATURE_DELIVERY_PDF:-true}"

TEMPLATE=/usr/share/nginx/html/assets/config.template.json
TARGET=/usr/share/nginx/html/assets/config.json

# envsubst reemplaza SOLO las variables que le listamos explícitamente. Sin esa
# lista, tocaría cualquier cosa con forma de ${VAR} en el archivo, incluida
# alguna que no queremos expandir. La lista es la parte fácil de olvidar.
envsubst '${API_URL} ${ENVIRONMENT_NAME} ${APP_TIME_ZONE} ${FEATURE_DELIVERY_PDF}' < "$TEMPLATE" > "$TARGET"

# Dejar rastro en los logs del contenedor: cuando algo falle, la primera
# pregunta va a ser "a qué ambiente arrancó esto". Que la respuesta este en la
# primera línea del log ahorra media hora.
echo "[entrypoint] config generada para ambiente: $ENVIRONMENT_NAME -> $API_URL"

# exec reemplaza el proceso del script por nginx: nginx queda como PID 1 y
# recibe las señales de parada del contenedor directamente. daemon off para que
# nginx corra en primer plano; si corriera en background, el contenedor arranca
# y se muere al instante porque su proceso principal terminó.
exec nginx -g 'daemon off;'
