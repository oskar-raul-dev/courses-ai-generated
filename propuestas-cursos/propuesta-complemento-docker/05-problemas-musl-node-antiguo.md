# Problemas musl con Node 10-14 en Docker/Alpine

## Contexto

Alpine Linux (musl) + Node 10/12/14 en Docker es un escenario atractivo (imagen 80 MB), pero en la práctica fue **la combinación con mayor tasa de bugs reportados** entre 2017-2023. Este doc mapea exactamente qué falla y por qué.

---

## Problema root: Ausencia de prebuilts musl para esa era

```
Flujo normal (glibc, linux-x64):
npm install node-sass
→ Busca prebuilt linux-x64-{ABI}
→ Encuentra en node-sass releases
→ Descarga .tar.gz, desempaca .node
→ ✅ Funciona en segundos

Flujo Alpine/musl:
npm install node-sass  
→ Busca prebuilt linux-x64-musl o linux-arm64-musl
→ ❌ No existe (casi nadie lo publicaba)
→ Fallback: node-gyp compila desde fuente
  → ¿Tienes python2? ✅ (Alpine <3.12)
  → ¿Tienes g++? ✅ (apk add build-base)
  → ¿LibSass.h asume glibc? ❌ BOOM → Errores de compilación crípticos
```

La lección: **necesitas toolchain completo + código C++ compatible con musl**, no solo "apk add build-base".

---

## Top 5 paquetes que explotaban en Alpine+Node antiguo

### 1. node-sass (el peor ofensor)

**Por qué falla**
- LibSass es C++ y fue escrito para glibc.
- Node 10-14 **no publicó prebuilt para arm64 jamás** — incluso en glibc.
- En Alpine arm64: **triple incompatibilidad**: musl + arm64 + V8 viejo.
- V8 bajo qemu-user (si compilas en Mac emulado) sufre segfaults.

**Síntomas típicos**
```
gyp ERR! configure error
gyp ERR! stack Error: not found: <binding.node>
# O:
Error: /app/node_modules/node-sass/build/Release/binding.node: 
  invalid ELF header (¿binario de Mac? ¿glibc?)
# O (durante compilación):
/node_modules/node-sass/src/libsass/src/ast.cpp:1:
  includes glibc-specific headers
  error: <execinfo.h>: No such file or directory
```

**Soluciones en orden de sanidad**
1. **Cambiar a sass (dart-sass)** — JavaScript/Dart puro, zero native code. 
   ```bash
   npm uninstall node-sass && npm install sass
   # update webpack config: sass-loader funciona igual
   ```
   ✅ Solución definitiva.

2. **Alpine amd64 emulado en Mac + Rosetta**
   ```dockerfile
   FROM --platform=linux/amd64 node:14-alpine3.12
   ```
   Más rápido que qemu-user puro, pero sigue siendo emulación.

3. **Debian en lugar de Alpine**
   ```dockerfile
   FROM node:14-buster-slim
   RUN apt-get update && apt-get install -y python2 make g++
   ```
   Los prebuilts de node-sass para linux-x64 existen → cero compilación.

4. **Compilar explícitamente en Alpine amd64 (local)**
   ```bash
   npm ci --build-from-source
   # + tener mucho patience y ccache
   ```
   Funciona a veces, muy lento, no reproducible.

---

### 2. fibers (Meteor, legacy SSR)

**Por qué falla**
- Nativo puro para manipular stacks de corrutinas.
- Incompatible con Node ≥16.
- En musl arm64: no compila sin parches específicos.
- V8 de Node 10-14 + fibers = condiciones de carrera en segfault intermitente.

**Síntoma**
```
FATAL ERROR: CALL_AND_RETRY_LAST Allocation failed - JavaScript heap out of memory
# (sin razón aparente, gc logs limpios)
```

**Solución**
- Si es Meteor: upgrade a Meteor 2+ (dejó de usar fibers).
- Si es código legacy: reemplaza con `async/await` (reescribe el 90% del código).
- Renuncia a musl arm64 si no hay alternativa.

---

### 3. phantomjs-prebuilt (Karma, tests AngularJS)

**Por qué es irreparable**
- No es módulo que compila; es un **descargador de binario**.
- ```javascript
  // package.json phantom script
  "install": "node install.js"  // descarga phantomjs binario (darwin-x64 o linux-x64)
  ```
- **No existe phantomjs prebuilt para musl jamás**. Punto.
- Incluso si compilaras PhantomJS (WebKit entero, 4 horas) en Alpine, los scripts de npm no lo encuentran.

**Síntoma en tests**
```
Error: spawn phantomjs ENOENT
# or silent failure (npm install "succeeds" pero el binario no funciona)
```

**Solución (la única)**
```bash
npm uninstall phantomjs-prebuilt
npm install --save-dev chromium
# En karma.conf.js:
browsers: ['ChromeHeadless']
# En package.json:
{
  "scripts": {
    "test": "PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=1 PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium karma start"
  }
}
```

¿Pain? Sí. ¿Único camino? También sí.

---

### 4. bcrypt (autenticación backends)

**Por qué falla**
- Nativo que envuelve bcrypt en C.
- Binario prebuilt musl inexistente.
- Compilación en Alpine a veces funciona, a veces no (random segfaults en tests).

**Síntoma**
```
Error: Can't find module 'bcrypt' / Segmentation fault during compare()
```

**Solución**
```bash
npm uninstall bcrypt
npm install bcryptjs  # Pure JavaScript, slowish but works
# Code: bcrypt.compare() → bcryptjs.compare() (misma API)
```

Cost: ~20% de overhead en auth, irrelevante para 99% de apps.

---

### 5. sharp (optimización de imágenes, Gatsby)

**Por qué falla**
- Envuelve libvips (C library for image processing).
- Prebuilt solo glibc-x64 en esa época.
- Alpine: o compilas vips + sharp (hell), o lo desactivas.

**Síntoma**
```
Cannot find module 'sharp'
# o: 
Error: /app/node_modules/sharp/build/Release/sharp.node: 
  wrong ELF class (64-bit vs 32-bit, o glibc vs musl magic number)
```

**Solución para Gatsby**
```javascript
// gatsby-config.js
module.exports = {
  plugins: [
    // Disable image optimization in dev/Docker
    process.env.SKIP_SHARP
      ? []
      : [
          {
            resolve: 'gatsby-plugin-image',
            options: { skipOptimization: true }  // use native browser features
          }
        ]
  ]
}
```

**O: cambiar a Alpine amd64** (pre-compilas con Rosetta, descargas prebuilt).

---

## Otros ofensores: tabla de referencia rápida

| Paquete | Problema | Alternativa |
|---|---|---|
| **node-canvas** | Requiere cairo, pango, jpeg; prebuilt solo glibc | Use canvas.js (canvas API puro) o desactiva |
| **grpc** (viejo) | Nativo, sin musl prebuilt | Usa @grpc/grpc-js (JavaScript, disponible desde 2019) |
| **sqlite3** | Nativo | better-sqlite3 o SQL.js (WASM) |
| **leveldown** | Nativo | level (portuese JS) |
| **libxmljs** | Nativo XML parser | xml2js (JS puro) |
| **re2** | Nativo regex engine | Evita, usa RegExp nativo |
| **deasync** | Frágil, nativo, roto en musl | Reescribe con async/await |
| **iltorb / node-zopfli** | Compresión; prebuilts solo glibc | Desactiva en dev Docker, webpack tiene brotli JS |
| **canvas / pixeljs** | Render headless; nativo | puppeteer con chromium de apk |

---

## Flujo: cómo diagnosticar en Alpine

### Checklist de compilación que falla
```bash
FROM node:14-alpine3.12

# Step 1: ¿Tienes python2?
RUN node -e "console.log(require('child_process').execSync('which python2').toString())"
# ❌ → apk add python2.7

# Step 2: ¿Tienes build tools?
RUN apk add --no-cache build-base

# Step 3: ¿npm ve deps C de headers?
RUN npm install node-sass --build-from-source 2>&1 | head -20
# Si dice "cannot find cairo.h" or "glibc.h not found" → no es el toolchain, es el código
```

### Debugging de binario roto
```bash
# Dentro del contenedor, post-install fallido:
$ file node_modules/node-sass/build/Release/binding.node
binding.node: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), 
             dynamically linked, not stripped
$ ldd binding.node
  linux-vdso.so.1 (0x...)
  libm.so.6 => /lib/ld-musl-x86_64.so.1  ← ✅ musl, bien
  libgcc_s.so.1 => not found            ← ❌ gcc_s no disponible
  libstdc++.so.6 => not found           ← ❌ c++ stdlib no disponible
# Solución: apk add libgcc libstdc++
```

---

## Anti-patrón clásico: volumen de node_modules del host

```bash
# ❌ NUNCA hagas esto:
docker run -v $(pwd):/app -v /app/node_modules node:14-alpine npm install
# El :node_modules es un "named volume" que preserva el del contenedor
# Pero si lo compilaste en tu Mac (darwin-arm64 .node),
# Linux intenta cargar binarios macOS → instant failure
```

**Correcto:**
```bash
# Excluir node_modules del volumen bind
docker run -v $(pwd):/app -e NODE_ENV=development node:14-alpine npm ci
# npm ci siempre compila in-place dentro del contenedor
```

---

## Estrategia de equipo: usar Debian, no Alpine, para legacy

Si tu equipo toca código Node 10-14:

```dockerfile
# ✅ base/Dockerfile
FROM node:14-buster-slim

RUN sed -i 's|deb.debian.org|archive.debian.org|g' /etc/apt/sources.list && \
    sed -i '/buster-updates/d' /etc/apt/sources.list && \
    apt-get update && apt-get install -y --no-install-recommends \
      python2.7 make g++ git ca-certificates && \
    rm -rf /var/lib/apt/lists/*
```

**Ventajas sobre Alpine:**
- Prebuilts de node-sass, bcrypt, sharp: ✅ existen y bajan en segundos.
- No hay sorpresas de musl compatibility.
- Imagen: 250-300 MB (vs 150 Alpine). **Aceptable** para legacy.
- Una sola compilación por lockfile, cached por layer Docker.

**Implementación en equipo:**
```bash
# Paso 1: Construye la imagen base una vez
docker build -t legacy-base:node14 -f base/Dockerfile .

# Paso 2: Por proyecto
docker build --from legacy-base:node14 -t myapp:dev .

# Paso 3: Equipo ejecuta
docker run -v $(pwd):/app myapp:dev npm start
# Zero compilación, zero frustraciones.
```

---

## Conclusión

**Para Node 10-14 en Docker: Debian > Alpine, siempre.**

Alpine brilla en:
- Golang standalone binaries
- Microservicios modernos (Node 16+, Python 3.9+)
- Imágenes de 5 MB que no necesitan compilar

Alpine falla en:
- Cualquier cosa que compile nativos
- Proyectos legacy pre-2021 que dan por hecho glibc
- Entornos de equipo donde nadie quiere debuggear musl

**Upgrade path:**
1. Migra de Alpine a Debian slim (si factible ahora).
2. Reemplaza node-sass → sass, bcrypt → bcryptjs, phantomjs → chromium (cambios mínimos).
3. Cuando tengas sólido: considera musl de nuevo para infra modernizada.

---

## Lectura recomendada

- Alpine Linux + Docker: https://www.alpinelinux.org/posts/Docker-image-sizes.html (el por qué pequeño no siempre es mejor)
- Node prebuilts: https://github.com/nodejs/node/blob/main/doc/api/addons.md (cómo node-gyp decide qué descargar)
- musl-based Linux: https://www.musl-libc.org/compatibility.html (oficial sobre incompatibilidades)
