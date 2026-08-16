# Templates Dockerfile: Copy-Paste Ready

Dockerfiles listos para usar, comentados para cada escenario.

---

## 🟢 Template 1: Básico (cualquier plataforma, hoy)

**Usa en:** Cualquier máquina, máxima compatibilidad.
**Características:** glibc, archive.debian.org para repos EOL, Python 2.

```dockerfile
# Dockerfile
FROM node:14-buster-slim

# Arregla repos archivados (Debian 10 es EOL)
RUN sed -i 's|deb.debian.org|archive.debian.org|g; s|security.debian.org|archive.debian.org|g' /etc/apt/sources.list && \
    sed -i '/buster-updates/d' /etc/apt/sources.list

# Instala toolchain para compilar nativos
RUN apt-get update && apt-get install -y --no-install-recommends \
    python2.7 \
    make \
    g++ \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Linkeado para node-gyp viejo que busca python
RUN ln -sf /usr/bin/python2.7 /usr/local/bin/python

WORKDIR /app

# Configura npm para compilar desde fuente si no hay prebuilt
RUN npm config set build-from-source false

EXPOSE 3000

CMD ["npm", "start"]
```

**Uso:**
```bash
docker build -t myapp:dev .
docker run -it -v $(pwd):/app myapp:dev npm install
```

---

## 🟠 Template 2: Optimizado con caché (macOS + Windows)

**Usa en:** Desarrollo en equipo, compilación rara.
**Características:** ccache (para segunda compilación rápida), layer caching optimizado.

```dockerfile
# Dockerfile.optimized
FROM node:14-buster-slim

# Step 1: Toolchain (rara vez cambia, cacheable)
RUN sed -i 's|deb.debian.org|archive.debian.org|g; s|security.debian.org|archive.debian.org|g' /etc/apt/sources.list && \
    sed -i '/buster-updates/d' /etc/apt/sources.list && \
    apt-get update && apt-get install -y --no-install-recommends \
      python2.7 make g++ git ca-certificates \
      ccache pkg-config \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf /usr/bin/python2.7 /usr/local/bin/python

# Step 2: Setup ccache
ENV CCACHE_DIR=/ccache
ENV PATH="/usr/lib/ccache:$PATH"

# Step 3: npm config (cambia raramente)
RUN npm config set build-from-source false

WORKDIR /app

# Step 4: Dependencias (cambia frecuentemente)
COPY package.json package-lock.json ./

# Instala con caché de ccache (--mount activa BuildKit)
RUN --mount=type=cache,target=/ccache \
    npm ci

# Step 5: Código fuente
COPY . .

EXPOSE 3000
CMD ["npm", "start"]
```

**Uso (requiere BuildKit):**
```bash
DOCKER_BUILDKIT=1 docker build -t myapp:dev -f Dockerfile.optimized .
# Primera vez: 3-5 min (incluye npm install)
# Segunda vez: 1-2 min (ccache hit en compilaciones)
```

---

## 🔵 Template 3: Multi-versión Node (Node 10/12/14)

**Usa en:** Laboratorio educativo, tutoriales, testear en distintas versiones.
**Características:** Parametrizado con ARG.

```dockerfile
# Dockerfile.multiversion
ARG NODE_VERSION=14.21.3

FROM node:${NODE_VERSION}-buster-slim

# Igual que Template 1, pero ahora adapta a cualquier Node version
RUN sed -i 's|deb.debian.org|archive.debian.org|g; s|security.debian.org|archive.debian.org|g' /etc/apt/sources.list && \
    sed -i '/buster-updates/d' /etc/apt/sources.list && \
    apt-get update && apt-get install -y --no-install-recommends \
      python2.7 make g++ git ca-certificates && \
    rm -rf /var/lib/apt/lists/* && \
    ln -sf /usr/bin/python2.7 /usr/local/bin/python

WORKDIR /app
CMD ["npm", "start"]
```

**Uso:**
```bash
# Node 14
docker build -t myapp:node14 --build-arg NODE_VERSION=14.21.3 .

# Node 12
docker build -t myapp:node12 --build-arg NODE_VERSION=12.22.12 .

# Node 10
docker build -t myapp:node10 --build-arg NODE_VERSION=10.24.1 .
```

---

## 🟣 Template 4: Compilar Node desde fuente (arm64 nativo en macOS)

**Usa en:** macOS M1/M2/M3, cuando quieres arm64 nativo (futuro-proof).
**Características:** Descarga Node desde fuente, compila localmente.

```dockerfile
# Dockerfile.compile-from-source
FROM debian:buster-slim

# Toolchain + Archive repos
RUN sed -i 's|deb.debian.org|archive.debian.org|g; s|security.debian.org|archive.debian.org|g' /etc/apt/sources.list && \
    sed -i '/buster-updates/d' /etc/apt/sources.list && \
    apt-get update && apt-get install -y --no-install-recommends \
      build-essential \
      python2.7 \
      curl \
      git \
      ca-certificates \
      ccache \
      pkg-config \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf /usr/bin/python2.7 /usr/local/bin/python

ENV CCACHE_DIR=/ccache

# Descargar y compilar Node
ARG NODE_VERSION=14.21.3

RUN mkdir -p /usr/src && \
    curl -fsSL https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}.tar.xz | \
    tar -xJ -C /usr/src

WORKDIR /usr/src/node-v${NODE_VERSION}

# Configure (flags educativos)
RUN ./configure \
      --shared-openssl \
      --shared-zlib \
      --with-intl=small-icu \
      --prefix=/opt/node

# Compilar con caché
RUN --mount=type=cache,target=/ccache \
    make -j$(nproc) CC="ccache gcc" CXX="ccache g++" && \
    make install

# Setup symlinks
RUN ln -sf /opt/node/bin/node /usr/local/bin/node && \
    ln -sf /opt/node/bin/npm /usr/local/bin/npm && \
    node --version && npm --version

WORKDIR /app
CMD ["npm", "start"]
```

**Uso (macOS arm64 nativo):**
```bash
# Primera vez: ~25 minutos (compilando V8)
docker build -t myapp:native-arm64 -f Dockerfile.compile-from-source .

# Segunda vez (si relanzas): ~3 minutos (ccache hit)

# Verifica que es arm64 nativo:
docker run myapp:native-arm64 uname -m  # arm64
```

---

## ⚫ Template 5: CI/CD Multi-arquitectura (docker buildx)

**Usa en:** Construir para amd64 y arm64 en una sola línea, publicar en registry.
**Características:** docker-bake.hcl para orquestación.

```hcl
# docker-bake.hcl
variable "NODE_VERSION" {
  default = "14.21.3"
}

variable "REGISTRY" {
  default = "docker.io"
}

variable "IMAGE_NAME" {
  default = "mycompany/node-legacy"
}

variable "IMAGE_TAG" {
  default = "14"
}

group "default" {
  targets = ["node14"]
}

target "node14" {
  dockerfile = "Dockerfile"
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
  args = {
    NODE_VERSION = NODE_VERSION
  }
  tags = [
    "${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}",
    "${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}-latest"
  ]
  labels = {
    "org.opencontainers.image.title" = "Node Legacy"
    "org.opencontainers.image.version" = NODE_VERSION
  ]
}
```

**Uso (requiere docker buildx):**
```bash
# Crear builder
docker buildx create --name multi-builder --use

# Construir para ambas arquitecturas
docker buildx bake --push

# Resultado: imagen multi-arch en registry, ambas plataformas
docker pull docker.io/mycompany/node-legacy:14
# Docker Desktop/Colima descarga la arquitectura correcta automáticamente
```

---

## 🟡 Template 6: Windows 11 + Proxy Corporativo

**Usa en:** Windows 11 con proxy MITM (Zscaler, Netskope, etc.).
**Características:** Inyecta certificado raíz corporativo.

```dockerfile
# Dockerfile.windows-corporate
FROM node:14-buster-slim

# Copia el certificado raíz corporativo
# (Descargado desde: Settings > Certificates, or IT team)
COPY ./corp-root-ca.crt /usr/local/share/ca-certificates/

# Actualiza el almacén de certificados
RUN update-ca-certificates

# Variable de entorno para Node.js
ENV NODE_EXTRA_CA_CERTS=/usr/local/share/ca-certificates/corp-root-ca.crt

# Igual que los anteriores
RUN sed -i 's|deb.debian.org|archive.debian.org|g' /etc/apt/sources.list && \
    apt-get update && apt-get install -y --no-install-recommends \
      python2.7 make g++ && \
    rm -rf /var/lib/apt/lists/ && \
    ln -sf /usr/bin/python2.7 /usr/local/bin/python

WORKDIR /app
CMD ["npm", "start"]
```

**Uso:**
```bash
# 1. Descarga tu certificado raíz (pide a IT)
# 2. Coloca corp-root-ca.crt en la carpeta del proyecto
# 3. Construye:
docker build -f Dockerfile.windows-corporate -t myapp:corporate .

# 4. Run (npm install ya puede acceder a internos con proxy):
docker run -it -v C:\Users\...\project:/app myapp:corporate npm install
```

---

## 🔴 Template 7: Development vs Production (multi-stage)

**Usa en:** Cuando quieres imagen pequeña para producción.
**Características:** Stage de build (compila todo) + stage runtime (solo necesarios).

```dockerfile
# Dockerfile.multistage
# Stage 1: Builder (donde compilamos nativos)
FROM node:14-buster-slim AS builder

RUN sed -i 's|deb.debian.org|archive.debian.org|g' /etc/apt/sources.list && \
    sed -i '/buster-updates/d' /etc/apt/sources.list && \
    apt-get update && apt-get install -y --no-install-recommends \
      python2.7 make g++ ca-certificates && \
    rm -rf /var/lib/apt/lists/ && \
    ln -sf /usr/bin/python2.7 /usr/local/bin/python

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build  # Webpack, tsc, etc.

# Stage 2: Runtime (imagen final pequeña)
FROM node:14-buster-slim

# Solo npm (sin build-essential, python2, etc.)
RUN sed -i 's|deb.debian.org|archive.debian.org|g' /etc/apt/sources.list && \
    sed -i '/buster-updates/d' /etc/apt/sources.list && \
    apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates && \
    rm -rf /var/lib/apt/lists/

WORKDIR /app

# Copia solo build results y node_modules compilados
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./

ENV NODE_ENV=production
EXPOSE 3000
CMD ["npm", "start"]
```

**Beneficios:**
- Builder stage: 350 MB (con todos los tools).
- Runtime stage: 150 MB (solo lo necesario).
- Producción usa runtime, desarrollo puede usar builder.

---

## 📋 Comparativa de templates

| Template | Plataforma | Caso uso | Tiempo build 1° | Tamaño |
|---|---|---|---|---|
| 1. Básico | Cualquiera | Inicio rápido | 3-5 min | 250 MB |
| 2. Optimizado | macOS/Windows | Equipo dev | 3-5 min | 250 MB |
| 3. Multi-versión | Educativo | Testear Node 10/12/14 | 3-5 min | 250 MB |
| 4. Compile-source | macOS arm64 | Futuro-proof | 25 min | 250 MB |
| 5. Buildx | CI/CD | Multi-arch, registry | 25 min | Ambas |
| 6. Windows corp | Windows 11 | Proxy corporativo | 3-5 min | 250 MB |
| 7. Multi-stage | Prod/Dev | Imagen pequeña prod | 8-10 min | Builder: 350 MB, Runtime: 150 MB |

---

## 🚀 Quick Start por escenario

### "Quiero funcionando en 5 min"
```bash
# Copia Template 1
# Run: docker build -t myapp:dev . && docker run -it -v $(pwd):/app myapp:dev npm install
```

### "Tengo equipo macOS+Windows"
```bash
# Copia Template 2 (optimizado)
# Construye: docker build -t myapp:dev -f Dockerfile.optimized .
# Equipo: docker run -it -v $(pwd):/app myapp:dev npm install
```

### "Quiero futuro-proof (sin Rosetta 2027)"
```bash
# Copia Template 4 (compile from source)
# En macOS: docker build -t myapp:native . (toma 25 min)
# Comparte imagen con equipo, nadie vuelve a compilar
```

### "Windows con proxy corporativo"
```bash
# Copia Template 6
# Descarga cert raíz, coloca corp-root-ca.crt, build & run
```

### "Producción pequeña vs desarrollo"
```bash
# Copia Template 7 (multi-stage)
# docker build -t myapp:dev --target builder .
# docker build -t myapp:prod --target runtime .
```

---

## ✅ Checklist antes de usar

- [ ] ¿Descargaste `corp-root-ca.crt` si usas Template 6?
- [ ] ¿Tienes `package.json` en el directorio donde corres docker build?
- [ ] ¿NO montaste `node_modules` en el volumen bind?
- [ ] ¿Usaste archive.debian.org? (repos Debian 10 son EOL)
- [ ] ¿Buildeaste con DOCKER_BUILDKIT=1 si usas --mount?

---

**Ahora sí: elige el template, copia-pega, y construye. 🚀**

