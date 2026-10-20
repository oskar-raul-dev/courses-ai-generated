# .devcontainer/Dockerfile
# Imagen de DESARROLLO, no de producción. Debian y no Alpine: deasync y
# node-sass compilan contra glibc.
FROM node:14.21.3-bullseye-slim

# Debian 11 salió de soporte en agosto de 2026 y sus paquetes de seguridad
# ya no están en deb.debian.org: apt tiene que ir al archivo histórico.
RUN printf '%s\n' \
      'deb http://archive.debian.org/debian bullseye main' \
      'deb http://archive.debian.org/debian bullseye-updates main' \
      'deb http://archive.debian.org/debian-security bullseye-security main' \
      > /etc/apt/sources.list

# Lo que node-gyp necesita para compilar dependencias nativas en arm64
# (Apéndice 6): python3 para deasync, del tronco; python2 para node-sass,
# de la ruta Q, que trae un node-gyp 3 que no acepta Python 3.
RUN apt-get update && apt-get install -y --no-install-recommends \
      python3 \
      python2 \
      make \
      g++ \
      git \
    && rm -rf /var/lib/apt/lists/*

# El volumen de node_modules se monta aquí. Si la carpeta ya existe en la
# imagen y es de 'node', el volumen nace con ese dueño; si no, nace de root
# y el primer npm ci falla con EACCES.
RUN mkdir -p /workspace/node_modules && chown -R node:node /workspace

# 'node' ya existe en la imagen y no es root: lo que crees en la carpeta
# montada queda a tu nombre en el Mac.
USER node
WORKDIR /workspace
