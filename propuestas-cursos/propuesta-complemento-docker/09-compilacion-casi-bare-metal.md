# Compilación casi bare-metal: Node 10/12/14 desde fuente

## Filosofía

En lugar de depender de prebuilts binarios, vas a:
1. Descargar el tarball de fuente de Node.
2. Ejecutar `./configure` con flags educativos.
3. Compilar V8 + libuv + libssl manualmente.
4. Documentar cada paso (luego convertible a Dockerfile).

**Beneficio:** Aprendes exactamente qué es lo que falla en musl vs glibc, arm64 vs x64, y por qué.

---

## Parte 1: Compilación interactiva en macOS (Lima)

### Paso 1: Instalar y arrancar Lima

```bash
# Si no tienes Lima:
brew install lima

# Crear una VM Debian 10 (buster) ARM64
limactl start --name legacy template://debian-12

# Dentro de la VM:
limactl shell legacy
# Estás dentro de Linux ARM64, kernel Linux de verdad
```

### Paso 2: Instalar toolchain

```bash
# Dentro de la VM Lima:
sudo apt-get update

# El mínimo imprescindible
sudo apt-get install -y build-essential python2.7 curl wget git

# Opcionales pero útiles
sudo apt-get install -y ccache pkg-config

# Verificar versiones (importante para compatibilidad)
gcc --version      # Debe ser ~8.x (en buster)
python2 --version  # 2.7.x
```

### Paso 3: Descargar Node

```bash
cd /tmp
NODE_VERSION=14.21.3  # Última de la serie 14 (stable)
curl -fsSL https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}.tar.xz | tar -xJ

cd node-v${NODE_VERSION}
ls -la
# Deberías ver: LICENSE, README.md, configure, vcbuild.bat, deps, lib, src, tools, ...
```

### Paso 4: El ./configure mágico

**Opciones geek a explorar:**

```bash
# Opción 1: Minimal (enlazar a SSL/zlib del sistema)
./configure \
  --shared-openssl \
  --shared-zlib \
  --with-intl=small-icu

# Opción 2: Con debug symbols (para gdb, aprender internals)
./configure \
  --shared-openssl \
  --shared-zlib \
  --debug

# Opción 3: Vendored (todo incluido, reproducible pero más lento)
./configure \
  --with-intl=small-icu
  # No especificas --shared-*, Node compila su propio OpenSSL/zlib

# Opción 4: Máximo control (casi nunca necesario)
./configure \
  --prefix=/opt/node14 \
  --with-openssl=/usr \
  --shared-openssl \
  --shared-zlib
```

**Qué hace cada uno:**

| Flag | Significado |
|---|---|
| `--shared-openssl` | Enlaza contra OpenSSL del sistema (`/usr/lib`), no compila el vendored. Ahorra ~5 min de compilación, permite parchear OpenSSL sin recompilar Node. Riesgo: versión de sistema no coincide. |
| `--shared-zlib` | Igual con zlib (compresión gzip). Pequeño ahorro. |
| `--with-intl=small-icu` | Unicode/internacionalización. `small-icu` = 10 MB, `full-icu` = 50+ MB, `none` = sin i18n. **Para desarrollo:** small-icu basta. |
| `--debug` | Símbolos de debug (binario ~2x más grande, pero puedes `gdb` dentro). Solo para aprendizaje. |
| `--prefix` | Dónde instalar. Default: `/usr/local`. |

```bash
# Elige uno. Yo recomiendo para educativo:
./configure \
  --shared-openssl \
  --shared-zlib \
  --with-intl=small-icu \
  --prefix=/opt/node14

# Output esperado: 
# Configure summary
#   shared openssl ... yes
#   shared zlib ... yes
#   ...
# (sin errores)
```

### Paso 5: Compilación con make

```bash
# ¡El momento geek!
# Opción A: Rápido, sin caché
make -j$(nproc)
# Toma ~15-20 min en ARM64 moderno (V8 es el 80%)
# -j$(nproc) = paraleliza en todos los cores

# Opción B: Educativo con ccache (cache de compilación)
make -j$(nproc) CC="ccache gcc" CXX="ccache g++"
# Primera vez: igual de lento
# Segunda compilación: 2-3 min (caché hit)
```

**Mientras esperas (15+ min):** observa el output.
- `gyp` configurando módulos nativos.
- `binding.gyp` procesando dependencies.
- `g++` compilando V8 (la mayor parte del tiempo).

```bash
# Si falla, el output típico es:
# error: 'execinfo.h' no such file (musl-specific issue)
# error: 'std::optional' (C++17 en code C++11)
# error: conflicting types for 'accept' (threading weirdness)

# Soluciones:
# 1. Si es musl: necesitas headers de GNU compatibility (`libc6-compat`)
# 2. Si es versión de compiler: usa gcc-8 explícitamente
# 3. Si es headers: `apt-get install ...` lo que falta
```

### Paso 6: Instalar y verificar

```bash
# Instalar en /opt/node14 (o lo que pusiste en --prefix)
make install

# Verificar binarios
/opt/node14/bin/node --version       # v14.21.3
/opt/node14/bin/npm --version        # 6.14.18

# Symlink para facilidad
sudo ln -sf /opt/node14/bin/node /usr/local/bin/node
sudo ln -sf /opt/node14/bin/npm /usr/local/bin/npm

# Test
node --version
npm --version
```

### Paso 7: Compilar un paquete nativo (node-sass, para ver magia)

Dentro de la VM Lima:

```bash
mkdir -p /tmp/test-app
cd /tmp/test-app
npm init -y

# Instala un paquete nativo desde fuente
npm install node-sass --build-from-source

# Output esperado:
# npm WARN node-sass@4.14.1 has incorrect peer dependency "sass@~1.x"
# > node-sass@4.14.1 install `/tmp/test-app/node_modules/node-sass`
# > node scripts/build.js
# Building: /tmp/test-app/node_modules/node-sass/build/Release/binding.node
# gyp info it worked if it ends with ok
# gyp verb cli [ '/opt/node14/bin/node', '/usr/local/bin/node-gyp', 'configure', '--fallback-to-build', ... ]
# make: Entering directory `...libsass...'
# g++ -c -pthread -std=gnu++0x ...src/libsass/src/ast.cpp
# # Esto tarda 3-5 min en ARM64

# Verifica el binario
file node_modules/node-sass/build/Release/binding.node
# ELF 64-bit LSB shared object, ARM aarch64, version 1 (SYSV), dynamically linked
# ✅ Compiló para arm64 nativo
```

### Paso 8: Documentar (la parte geek importante)

Crea un `COMPILE_LOG.md`:

```markdown
# Compilación Node 14.21.3 en Debian 10 (buster) ARM64 — Lima macOS

## Hardware
- Host: Apple M1 MacBook Pro
- VM: Lima, kernel Linux 5.10.x, arm64

## Toolchain
- gcc 8.3.0
- python 2.7.18
- make 4.2.1
- OpenSSL 1.1.1n (sistema)
- zlib 1.2.11 (sistema)

## Comando de configuración
\`\`\`bash
./configure \
  --shared-openssl \
  --shared-zlib \
  --with-intl=small-icu \
  --prefix=/opt/node14
\`\`\`

## Tiempo de compilación
- Primera vez: 18 minutos (con -j8)
- Con ccache: 3 minutos

## Paquetes compilados exitosamente
- node-sass 4.14.1: ✅ arm64 nativo
- sqlite3 4.2.0: ✅
- bcryptjs (JS puro): ✅

## Notas
- musl no era necesario; glibc de Debian funcionó perfectamente.
- V8 tuvo que compilar la JIT para ARM64, hence el tiempo.
- --shared-openssl fue crítico para evitar conflictos con versión de sistema.
```

---

## Parte 2: Docker + Compilación (macOS o Windows)

### Convierte tus notas a Dockerfile

Lo que aprendiste en Lima lo automatizas:

```dockerfile
# Dockerfile.node14
FROM debian:buster-slim

# Step 1: Instalar toolchain
RUN sed -i 's|deb.debian.org|archive.debian.org|g; s|security.debian.org|archive.debian.org|g' /etc/apt/sources.list && \
    sed -i '/buster-updates/d' /etc/apt/sources.list && \
    apt-get update && apt-get install -y --no-install-recommends \
      build-essential \
      python2.7 \
      curl wget git \
      ca-certificates \
      ccache \
      pkg-config \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf /usr/bin/python2.7 /usr/local/bin/python

ENV CCACHE_DIR=/ccache
ENV PATH="/ccache:$PATH"

# Step 2: Descargar + compilar Node
ARG NODE_VERSION=14.21.3

RUN mkdir -p /usr/src && \
    curl -fsSL https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}.tar.xz | \
    tar -xJ -C /usr/src

WORKDIR /usr/src/node-v${NODE_VERSION}

# Step 3: Configure con flags educativos
RUN ./configure \
      --shared-openssl \
      --shared-zlib \
      --with-intl=small-icu \
      --prefix=/opt/node${NODE_VERSION}

# Step 4: Compilar con cache
RUN --mount=type=cache,target=/ccache \
    make -j$(nproc) CC="ccache gcc" CXX="ccache g++" && \
    make install

# Step 5: Setup
RUN ln -sf /opt/node${NODE_VERSION}/bin/node /usr/local/bin/node && \
    ln -sf /opt/node${NODE_VERSION}/bin/npm /usr/local/bin/npm

WORKDIR /app

RUN node --version && npm --version

# Herramientas para desarrollo
RUN npm config set build-from-source true && \
    npm config set python python2.7
```

### Construir la imagen

```bash
# En macOS (M1):
docker build -t legacy-node:14-arm64 -f Dockerfile.node14 .
# Resuelve a linux/arm64 automáticamente, cero emulación
# Toma ~20-25 min la primera vez
# Con mount cache: 3-5 min si relanzas

# En Windows:
docker build -t legacy-node:14-x64 -f Dockerfile.node14 .
# Resuelve a linux/amd64, nativo en tu sistema
# Toma ~15-20 min
```

### Compartir entre equipo (multi-arch)

```bash
# Construir para ambas arquitecturas
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t registry.company.com/legacy-node:14 \
  --push \
  -f Dockerfile.node14 .
```

Cada miembro del equipo:
```bash
docker pull registry.company.com/legacy-node:14  # Descarga su arquitectura automáticamente
docker run -it legacy-node:14 node --version
```

---

## Parte 3: Windows 11 — Compilación en WSL2

### Setup

```bash
# En PowerShell (host Windows):
wsl --list --verbose
# Verifica que WSL2 esté activo

# Dentro de WSL2:
wsl
```

### Flujo idéntico a Lima

```bash
# Dentro de WSL2 (Linux subsystem):
sudo apt-get update && \
  sudo apt-get install -y build-essential python2.7 curl ccache

cd /tmp
NODE_VERSION=14.21.3
curl -fsSL https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}.tar.xz | tar -xJ
cd node-v${NODE_VERSION}

./configure \
  --shared-openssl \
  --shared-zlib \
  --with-intl=small-icu

make -j$(nproc) CC="ccache gcc" CXX="ccache g++"
make install

# Prueba
node --version
```

**Ventaja sobre Docker en Windows:** compilas *dentro* de WSL2 sin extra de image overhead. Luego puedes usar el Node nativo desde PowerShell o Docker.

### Alternativa: Docker en Windows

Si quieres reproducibilidad total (dockerfile):

```bash
# PowerShell o WSL2:
docker build -t legacy-node:14-windows -f Dockerfile.node14 .
# Usa WSL2 backend automáticamente, cero emulación (x86_64 nativo)
```

---

## Troubleshooting por plataforma

### Error en macOS (Lima): `execinfo.h` no encontrado

```
error: 'execinfo.h' file not found
#include <execinfo.h>
```

**Causa:** Intentaste compilar con musl. Lima debería usar glibc (Debian).

**Solución:**
```bash
# Verifica que estés en Debian, no Alpine
uname -a           # Linux, arm64
file /lib/libc.so.6  # GNU C Library o musl?
ldd --version      # Debe decir "GNU"

# Si es musl (raro en Lima Debian):
limactl stop legacy
limactl start --name legacy template://debian-12  # Usa Debian, no Alpine
```

### Error: `openssl/opensslv.h` no encontrado

```
error: openssl/opensslv.h: No such file or directory
```

**Causa:** `--shared-openssl` pero openssl-dev no instalado.

**Solución:**
```bash
sudo apt-get install -y libssl-dev
# Reintenta ./configure
```

### Error: Python no encontrado

```
configure: error: Python is not installed
```

**Solución:**
```bash
# En Debian/Ubuntu buster:
sudo apt-get install -y python2.7

# En Debian/Ubuntu bullseye+ (Python 2 deprecated):
sudo apt-get install -y python3
npm config set python python3  # Dile a npm que use python3
```

### Error: Compilación en arm64 que falla pero sucede en x64

**Posible causa:** Código C++ que asume pointers de 64 bits o endianness.

**Debugging:**
```bash
# Compilar con máximo verbosity
make V=1 -j1  # -j1 = sin paralelismo, sale error claro

# Busca línea exacta de fallo:
# `... src/foo.cpp:123: error: cast from pointer to smaller type ...`

# Solución: Si es Node legacy (10-12), puede que necesites un patch específico arm64
# Busca: github.com/nodejs/node/issues/... arm64 debian
```

### Timeout en compilación (M1 + QEMU)

Si estás en QEMU emulado (no Rosetta, no nativo):

```bash
# Síntoma: proceso se cuelga en V8 compilation
# Solución:
make -j1  # Paralelismo a 1
timeout 1800 make  # 30 min timeout
```

---

## Matriz: Dónde compilar según plataforma

| Plataforma | Método | Tiempo | Nota |
|---|---|---|---|
| macOS M1 + Lima | Bare-metal en VM | 18-25 min | 🏆 Educativo, rápido |
| macOS M1 + Docker nativo arm64 | Dockerfile | 20-25 min | ✅ Reproducible, shareable |
| macOS M1 + Rosetta amd64 | Dockerfile | 3-5 min | ✅ Rápido, pero Rosetta expira 2027 |
| Windows 11 + WSL2 | Bare-metal en WSL2 | 15-20 min | ✅ Nativo x86_64 |
| Windows 11 + Docker | Dockerfile | 15-20 min | ✅ Reproducible |

---

## Optimización: ccache y capas Docker

### ccache en Dockerfile

Habilita caching de compilación entre rebuilds:

```dockerfile
RUN --mount=type=cache,target=/ccache \
    CCACHE_DIR=/ccache \
    make -j$(nproc) CC="ccache gcc" CXX="ccache g++" && \
    make install
```

**Beneficio:**
- Build 1: 20 min, ccache populated.
- Build 2 (solo cambias un flag): 3 min.

### Layer caching en Dockerfile

Ordena los steps de lento a rápido:

```dockerfile
# ✅ Orden correcto
FROM debian:buster-slim
RUN apt-get update && apt-get install ...  # Layer 1, rara vez cambia
COPY Dockerfile ...                         # Layer 2, build context pequeño
RUN ./configure                             # Layer 3, cambias flags aquí
RUN make -j ...                             # Layer 4, la más lenta (pero caché)
```

Si cambias un flag en configure, solo Layer 3 se invalida (Layer 1-2 se reutilizan).

---

## Entregables finales

Después de todo este viaje geek, tendrás:

1. **COMPILE_LOG.md** — Documentación de tu proceso.
2. **Dockerfile.node10, .node12, .node14** — Recetas reproducibles.
3. **docker-bake.hcl** — Orquestación multi-arquitectura.
4. **shared docker image en registry** — Equipo no compila, solo ejecuta.

Ejemplo:
```bash
# Comparte la imagen
docker buildx build --platform linux/amd64,linux/arm64 \
  -t company-registry/node:14-compiled \
  --push .

# Equipo la usa
docker pull company-registry/node:14-compiled
docker run -it -v $(pwd):/app company-registry/node:14-compiled npm install
# Cero compilación, 10 segundos (solo descarga dependencies)
```

---

## Próximos pasos geek

1. **Compila Node 10 también** — V8 más viejo, más lecciones sobre ABI y portabilidad.
2. **Compila con musl** — Monta Alpine en lugar de Debian, ve exactamente dónde falla.
3. **Integra ccache en CI** — GitHub Actions con docker buildx y remote cache.
4. **Compara binarios** — `nm -D node` en arm64 vs x64 vs musl, aprende qué cambia.
5. **GDB+Node internals** — Compila con `--debug` y debuguea V8 mismo.

La belleza de compilar desde fuente es que no hay "magia negra" — todo es código que puedes leer, parchear y entender completamente.

