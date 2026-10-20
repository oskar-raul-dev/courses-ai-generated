FROM node:14.21.3-alpine

WORKDIR /app

# ⚡ Truco de capas: copiar SOLO los manifiestos primero.
# Docker cachea cada capa; si package.json no cambió, no reinstala nada
# aunque hayas tocado 40 archivos de src/. Invertir estas 4 líneas
# = npm install en CADA build. Es EL error de Dockerfile de la época.
COPY package*.json ./
RUN npm ci --only=production

COPY . .

ENV NODE_ENV=production
EXPOSE 3000 4000
CMD ["node", "src/server.js"]
