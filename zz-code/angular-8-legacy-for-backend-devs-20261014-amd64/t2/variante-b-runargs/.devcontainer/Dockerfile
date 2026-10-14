FROM node:14.21.3-bullseye-slim

# deb.debian.org anuncia paquetes de seguridad de bullseye que ya no sirve (404 en el pool).
# Se apunta apt al archivo congelado de bullseye. Ver A14 §3.
RUN rm -f /etc/apt/sources.list.d/* \
    && printf 'deb [check-valid-until=no] http://archive.debian.org/debian bullseye main\ndeb [check-valid-until=no] http://archive.debian.org/debian-security bullseye-security main\n' > /etc/apt/sources.list \
    && printf 'Acquire::Check-Valid-Until "false";\n' > /etc/apt/apt.conf.d/99archive \
    && apt-get update && apt-get install -y --no-install-recommends \
      python3 build-essential git curl sudo chromium \
    && rm -rf /var/lib/apt/lists/* \
    && echo "node ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/node
ENV CHROME_BIN=/usr/bin/chromium
USER node
WORKDIR /workspace
