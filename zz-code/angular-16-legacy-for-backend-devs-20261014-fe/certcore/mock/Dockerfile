# mock/Dockerfile
# Cinco líneas, y existen sólo porque en un cluster no puedes montar tu
# directorio de trabajo. En la Fase 13 el mock se levantó con
# `-v "$(pwd)/mock:/app/mock"` y eso bastaba; aquí el nodo es otro contenedor y
# tu disco no está ahí.
FROM node:18.18.2-alpine

WORKDIR /app

# Las dependencias del mock —express, jsonwebtoken y json-server— se instalan
# como devDependencies en las Fases 2 y 3. Por eso se hace `npm ci` completo y
# no con `--omit=dev`: con ese flag el contenedor arrancaría sin sus módulos.
COPY package.json package-lock.json ./
RUN npm ci

COPY mock/ ./mock/

# El `.dockerignore` de la Fase 13 deja fuera `mock/db.json` —con razón: es un
# archivo de trabajo—, así que la imagen llega sin él y json-server arranca con
# una base vacía: `/clients` da 404. Se regenera aquí desde la semilla, igual
# que `npm run seed` en tu máquina.
RUN node mock/seed.js

EXPOSE 3000

CMD ["node", "mock/server.js"]
