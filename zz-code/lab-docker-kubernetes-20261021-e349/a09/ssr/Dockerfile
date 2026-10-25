# a09: el storefront con renderizado en el servidor. Node y React, sin build: el servidor es un .mjs.
# node:24.21.0-alpine
FROM node@sha256:ebfe2f90462722a7a4de65e91990e97fe0d401c70e0e762c5b53302f905ec1c1
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev --no-audit --no-fund
COPY server.mjs ./
# El usuario sin privilegios que trae la imagen de Node.
USER node
EXPOSE 8080
CMD ["node", "server.mjs"]
