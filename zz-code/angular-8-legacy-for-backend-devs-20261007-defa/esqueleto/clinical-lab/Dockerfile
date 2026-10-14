# Dockerfile
# Etapa 1: build. Tiene Node y todo node_modules; produce el dist y muere acá.
# La 14 coincide con el .nvmrc del proyecto (Fase 0). Y es -bullseye-slim, o sea
# Debian, NO alpine: alpine usa musl en vez de glibc y el tooling nativo de esta
# epoca -node-gyp, node-sass- falla o compila raro contra musl. El peso extra de
# la imagen da igual porque esta etapa se descarta entera. El apendice A03 lo
# desarrolla, junto con el por que de npm ci.
FROM node:14.21.3-bullseye-slim AS build

WORKDIR /app

# Copiamos primero solo los manifiestos y hacemos npm ci ANTES de copiar el
# código. Así Docker cachea la capa de dependencias: si cambia el código pero no
# el package-lock, no reinstala node_modules. npm ci (no npm install) porque
# reproduce el lockfile exacto y no lo modifica. El apéndice A03 explica por que.
COPY package.json package-lock.json ./
RUN npm ci

# Ahora sí, el resto del código. Este COPY invalida la cache hacia abajo, no
# hacia arriba: node_modules ya quedó cacheado en la capa anterior.
COPY . .

# Compilamos para producción. Esto hornea environment.prod.ts, pero ya no nos
# importa: la única cosa que cambia entre ambientes salió de ahí y vive en
# config.json, que se genera al arrancar el contenedor, no acá.
RUN npm run build -- --prod

# Etapa 2: runtime. Parte de nginx limpio y se lleva SOLO el dist. Nada de Node,
# nada de node_modules, nada de código fuente TypeScript. La imagen final es
# nginx + archivos estáticos y punto.
# Acá sí usamos alpine, y no es una contradicción con la etapa 1: el problema de
# musl es compilar dependencias nativas de Node, y en esta etapa no se compila
# nada. Solo se sirven archivos estaticos.
FROM nginx:stable-alpine

# La config de nginx del proyecto reemplaza la default (el try_files vive acá).
COPY nginx.conf /etc/nginx/conf.d/default.conf

# El dist compilado en la etapa 1. El nombre sale del "ng new clinical-lab" de
# la Fase 0 §5.2, que es lo que fija el outputPath del angular.json: la carpeta
# se llama como el proyecto, no como la imagen. Confundirlos produce un COPY que
# no falla -copia una carpeta vacia- y una imagen que sirve un 404 en la raiz.
COPY --from=build /app/dist/clinical-lab /usr/share/nginx/html

# La plantilla de config y el entrypoint que la va a rellenar en el arranque.
COPY src/assets/config.template.json /usr/share/nginx/html/assets/config.template.json
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

# El entrypoint corre primero (rellena config.json) y después cede el control a
# nginx. Ver entrypoint.sh: termina con exec nginx, no lo lanza en background.
ENTRYPOINT ["/entrypoint.sh"]
