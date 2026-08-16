# Imagen del catálogo. Multi-stage no hace falta aquí (no hay build),
# pero usamos una base slim para mantener la imagen pequeña.
FROM node:20-alpine

WORKDIR /app

# Copiamos primero package.json para aprovechar la cache de capas:
# si no cambian las dependencias, Docker/Podman reutiliza esta capa.
COPY package.json ./
RUN npm install --omit=dev

COPY server.js ./

EXPOSE 3000
CMD ["node", "server.js"]
