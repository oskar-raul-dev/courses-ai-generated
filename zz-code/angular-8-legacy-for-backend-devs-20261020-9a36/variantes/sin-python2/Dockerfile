# .devcontainer/Dockerfile
# Imagen de DESARROLLO. Debian y no Alpine: el tooling nativo de esta época
# necesita glibc, y el porqué está en el Apéndice A03 §9.
FROM node:14.21.3-bullseye-slim

# Debian 11 salió de soporte y deb.debian.org ya no sirve los paquetes de
# seguridad que su índice anuncia (404): apt va al archivo congelado.
RUN printf '%s\n' \
      'deb [check-valid-until=no] http://archive.debian.org/debian bullseye main' \
      'deb [check-valid-until=no] http://archive.debian.org/debian-security bullseye-security main' \
      > /etc/apt/sources.list

# ca-certificates: sin él, git no verifica ningún certificado HTTPS.
# python2, make y g++: node-sass 4.14.1 no tiene binario para Linux arm64 y se
# compila con un node-gyp 3 que no acepta Python 3. python3 es para el
# node-gyp de npm. chromium es el navegador de ng test (Fase 12).
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates \
      python3 \
      make \
      g++ \
      git \
      chromium \
    && rm -rf /var/lib/apt/lists/*
ENV CHROME_BIN=/usr/bin/chromium

# El volumen de node_modules se monta aquí. Si la carpeta ya existe en la
# imagen y es de 'node', el volumen nace con ese dueño; si no, nace de root
# y el primer npm ci falla con EACCES.
RUN mkdir -p /workspace/node_modules && chown -R node:node /workspace

# 'node' ya existe en la imagen y no es root: lo que crees en la carpeta
# montada queda a tu nombre en el Mac.
USER node
WORKDIR /workspace

# jspdf 1.5.3 trae file-saver desde GitHub, y npm 6 lo pide por ssh:// y
# git://, que el contenedor no tiene. Que git lo pida por https://.
RUN git config --global url."https://github.com/".insteadOf "ssh://git@github.com/" \
    && git config --global --add url."https://github.com/".insteadOf "git://github.com/"
