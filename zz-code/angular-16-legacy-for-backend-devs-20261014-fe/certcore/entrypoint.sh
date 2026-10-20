#!/bin/sh
# /docker-entrypoint.d/40-certcore-config.sh
#
# Se ejecuta DENTRO del contenedor, antes de que nginx acepte la primera
# conexión, y su único trabajo es traducir variables de entorno a un archivo
# JSON que el navegador pueda pedir.
#
# Ésta es la pieza que hace que la misma imagen sirva para todos los ambientes.
# Todo lo demás de esta fase es andamiaje alrededor de estas quince líneas.

# `set -e` para que el script muera al primer fallo. Sin esto, un error a mitad
# deja un config.json vacío o a medias, nginx arranca igual, y la aplicación
# sale rota con un mensaje que no apunta aquí.
set -e

CONFIG_FILE=/usr/share/nginx/html/assets/config.json

# Valores por defecto pensados para que un `docker run` sin variables funcione
# y sea evidente que le faltan: `/api` es lo que el nginx de al lado sabe
# reenviar, y la etiqueta dice PROD porque es el ambiente que más veces se
# despliega sin pensar.
API_BASE_URL="${API_BASE_URL:-/api}"
ENVIRONMENT_NAME="${ENVIRONMENT_NAME:-PROD}"

# El JSON se escribe entero, no se parchea. Un `sed` sobre el archivo existente
# es la forma habitual de hacer esto y es peor: depende del formato exacto del
# original, se rompe silenciosamente cuando alguien reindenta, y deja el
# archivo a medias si falla. Escribirlo completo no puede quedar a medias.
cat > "$CONFIG_FILE" <<EOF
{
  "apiBaseUrl": "$API_BASE_URL",
  "environmentName": "$ENVIRONMENT_NAME"
}
EOF

# Se imprime en el log de arranque del contenedor. No es decoración: cuando
# alguien pregunte "¿contra qué backend está corriendo esto?", la respuesta
# está en `docker logs` y no hace falta entrar al contenedor a mirar.
echo "[certcore] configuración de arranque: $ENVIRONMENT_NAME -> $API_BASE_URL"
