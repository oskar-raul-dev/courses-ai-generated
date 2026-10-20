# Dockerfile
# Comentarios en español, como todo el código del proyecto. Esto también lo es.

# ─── Etapa 1: construir ───────────────────────────────────────────────────────
# La versión EXACTA, con los tres números. `node:18-alpine` traería el npm que
# le toque ese día, y construir con un npm distinto al de tu máquina es cómo se
# consigue que el lockfile resuelva otro árbol. Fase 0 §5.1 y apéndice A03.
FROM node:18.18.2-alpine AS build

WORKDIR /app

# Se copian SÓLO los manifiestos primero, y esto no es manía: Docker cachea por
# capa. Mientras package.json y el lockfile no cambien, la capa del `npm ci` se
# reutiliza y una recompilación de código tarda segundos en vez de minutos.
# Copiar todo de una vez invalida esa capa con cada línea que toques.
COPY package.json package-lock.json ./

# `npm ci` y no `npm install`: instala exactamente el lockfile y falla si no
# coincide con el package.json, en vez de "arreglarlo" silenciosamente. En una
# imagen es la diferencia entre reproducible y parecido. A03 lo desarrolla.
RUN npm ci

COPY . .

RUN npm run build -- --configuration production

# ─── Etapa 2: servir ──────────────────────────────────────────────────────────
# Aquí NO hay Node. La imagen final es nginx y el `dist/`, y nada más: ni
# `node_modules`, ni código fuente, ni el mock, ni el historial de git. Eso son
# cientos de megabytes menos y, sobre todo, es que nada de lo que no se sirve
# puede filtrarse.
FROM nginx:1.25-alpine

# Los .map se quedan FUERA a propósito: `hidden: true` los generó para que tú
# los tengas, no para servirlos. Guárdalos donde reportes errores.
COPY --from=build /app/dist/certcore/ /usr/share/nginx/html/
RUN rm -f /usr/share/nginx/html/*.map

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY entrypoint.sh /docker-entrypoint.d/40-certcore-config.sh

# El bit de ejecución se pone AQUÍ y no se hereda del sistema de archivos del
# que copiaste: si el archivo llega sin permiso de ejecución, nginx arranca
# igual, ignora el script en silencio, y la aplicación sale con la
# configuración de desarrollo. Es la causa raíz más tonta del incidente 19.
RUN chmod +x /docker-entrypoint.d/40-certcore-config.sh

EXPOSE 80
