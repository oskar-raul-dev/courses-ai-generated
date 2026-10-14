FROM node:14.21.3-bullseye-slim

# Dos cosas que la imagen base no trae, en este orden (A14 §3):
# 1. Los repos de bullseye: deb.debian.org ya no sirve los paquetes de seguridad
#    que su índice anuncia (404). Se apunta apt al archivo congelado de bullseye.
# 2. ca-certificates: sin él, git y curl no verifican ningún certificado HTTPS
#    (la imagen no trae /etc/ssl/certs). Lo necesita la dependencia de jspdf que
#    se descarga desde GitHub.
RUN printf 'deb [check-valid-until=no] http://archive.debian.org/debian bullseye main\ndeb [check-valid-until=no] http://archive.debian.org/debian-security bullseye-security main\n' > /etc/apt/sources.list \
    && printf 'Acquire::Check-Valid-Until "false";\nAcquire::Retries "5";\n' > /etc/apt/apt.conf.d/99archive \
    && apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates python3 build-essential git curl sudo chromium \
    && apt-get clean \
    && echo "node ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/node
ENV CHROME_BIN=/usr/bin/chromium
USER node
WORKDIR /workspace

# 3. Las dependencias de GitHub (jspdf 1.5.3 trae file-saver desde github:) se
#    resuelven por git. npm 6 intenta git:// y ssh://, que la red del contenedor
#    no abre. Se reescriben a https:// en la configuración de git del usuario node.
RUN git config --global url."https://github.com/".insteadOf "git://github.com/" \
    && git config --global --add url."https://github.com/".insteadOf "ssh://git@github.com/" \
    && git config --global --add url."https://github.com/".insteadOf "git@github.com:"
