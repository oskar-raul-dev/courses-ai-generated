# .devcontainer/Dockerfile
# Imagen de DESARROLLO. Debian y no Alpine: el tooling nativo de esta epoca
# necesita glibc, y el porque esta en el Apéndice A03 §9.
FROM node:14.21.3-bullseye-slim

RUN printf 'deb [check-valid-until=no] http://archive.debian.org/debian bullseye main\ndeb [check-valid-until=no] http://archive.debian.org/debian-security bullseye-security main\n' > /etc/apt/sources.list

# Lo que node-gyp necesita para compilar dependencias nativas. Es exactamente
# la lista del Apéndice A12 §4, en su versión de Linux.
RUN apt-get update && apt-get install -y --no-install-recommends \
      python3 \
      build-essential \
      git \
      curl \
    && rm -rf /var/lib/apt/lists/*

# El usuario 'node' ya existe en esta imagen y no es root. Trabajar como root
# dentro del contenedor deja archivos de root en tu carpeta montada, y eso se
# arregla después con chown y malhumor.
USER node
WORKDIR /workspace
