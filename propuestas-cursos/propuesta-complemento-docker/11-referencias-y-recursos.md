# Referencias y Recursos Técnicos

Compilación de links, documentación oficial y recursos de terceros mencionados (o implícitos) en la conversación.

---

## 🔗 glibc y musl

### Documentación oficial
- **musl-libc (oficial):** https://www.musl-libc.org/
  - Compatibility guide: https://www.musl-libc.org/compatibility.html
  - Por qué musl existe: https://www.musl-libc.org/about.html
  
- **glibc (GNU):** https://www.gnu.org/software/libc/
  - Manual: https://www.gnu.org/software/libc/manual/

### Artículos técnicos
- **Alpine Linux y Docker:** https://www.alpinelinux.org/posts/Docker-image-sizes.html
  - Explica por qué Alpine es pequeño pero problemático.
  
- **musl vs glibc en Kubernetes:** https://gist.github.com/Soulou/... (busca "musl DNS Kubernetes")
  - El bug clásico: respuestas DNS truncadas en Alpine.

---

## 📦 Node.js

### Descargas y releases
- **nodejs.org releases:** https://nodejs.org/en/download/releases/
  - Node 10.24.1 (última serie 10): https://nodejs.org/dist/v10.24.1/
  - Node 12.22.12 (última 12): https://nodejs.org/dist/v12.22.12/
  - Node 14.21.3 (última 14): https://nodejs.org/dist/v14.21.3/
  
- **Changelog por arquitectura:** Mira `node-vX.Y.Z.tar.xz` (source) vs `node-vX.Y.Z-linux-x64.tar.gz` (prebuilt).

### node-gyp y addons
- **Documentación oficial de addons:** https://nodejs.org/en/docs/guides/simple-native-extension-for-nodejs/
- **node-gyp repo:** https://github.com/nodejs/node-gyp
  - Issue tracker útil para "Node 10 arm64" o "Node 12 musl".

### Problemas históricos (Node legacy)
- **Node.js GitHub issues:**
  - Busca: "node 10 arm64" → encontrarás por qué no hubo soporte oficial.
  - Busca: "alpine" → verás quejas de 2018-2021 sobre musl.
  - Busca: "python2 deprecated" → por qué npm 7+ es problema.

---

## 🐳 Docker y containerización

### Imágenes oficiales
- **Node Docker images:** https://hub.docker.com/_/node
  - Tags históricos: node:10-alpine, node:14-buster, etc.
  - Verifica qué Alpine/Debian version trae cada tag antiguo.

### Documentación técnica
- **Docker documentation:**
  - Build context: https://docs.docker.com/build/building/context/
  - Build caching: https://docs.docker.com/build/cache/
  - Buildx multi-arch: https://docs.docker.com/build/building/multi-platform/

- **BuildKit cache mounts:** https://docs.docker.com/build/cache/backends/
  - Cómo usar `RUN --mount=type=cache` (usado en nuestros Dockerfiles).

### docker-bake
- **Documentación:** https://docs.docker.com/build/bake/overview/
- **Sintaxis HCL:** https://docs.docker.com/build/bake/reference/

---

## 🖥️ Herramientas específicas por plataforma

### macOS + Lima
- **Lima (official):** https://github.com/lima-vm/lima
  - Templates: https://github.com/lima-vm/lima/tree/master/examples
  - Para descargar template debian: `limactl start --name legacy template://debian-12`

- **Colima (friendly wrapper de Lima):** https://github.com/abiosoft/colima
  - Instalación: `brew install colima`
  - Soporte Rosetta: https://github.com/abiosoft/colima/issues/... (busca "vz-rosetta")

### macOS + Docker Desktop
- **Docker Desktop para Mac:** https://www.docker.com/products/docker-desktop
  - Feature flags (Rosetta): Settings > Features en GUI.
  - Licencias: Community (gratis) para desarrollo personal, Pro/Team/Business para empresas.

### Windows 11 + WSL2
- **WSL2 oficial:** https://learn.microsoft.com/en-us/windows/wsl/
  - Instalación: `wsl --install`
  - Performance tips: https://learn.microsoft.com/en-us/windows/wsl/compare-versions

- **Rancher Desktop (alternativa gratis):** https://rancherdesktop.io/
- **Podman Desktop (otra alternativa):** https://podman-desktop.io/

### Windows 11 + Proxy corporativo
- **Configurar proxy en Docker:** https://docs.docker.com/config/daemon/systemd/#http-proxy
- **WSL2 + proxy corporativo:** https://learn.microsoft.com/en-us/windows/wsl/networking#configure-proxy

---

## 📚 Packages problemáticos específicos

### node-sass (el peor ofensor)
- **Repo oficial:** https://github.com/sass/node-sass (ahora deprecated, mantiene archive)
- **Problemas conocidos:** https://github.com/sass/node-sass/issues/... (busca "alpine" o "musl")
- **Migración a sass (dart-sass):** https://sass-lang.com/blog/dart-sass-is-now-node-sass/
  - API compatible; cambio de 1 línea en package.json.

### phantomjs-prebuilt
- **Repo:** https://github.com/Medium/phantomjs
- **Alternativa recomendada:** Puppeteer (https://pptr.dev/) o Cypress (https://cypress.io/).
- **En Karma:** Usa `karma-chrome-launcher` con Chromium headless.

### bcrypt
- **bcrypt nativo:** https://github.com/kelektiv/node.bcrypt.js
- **bcryptjs (alternativa JS pura):** https://github.com/dcodeIO/bcrypt.js
  - Más lento pero funciona en cualquier plataforma.

### sharp (image processing)
- **Sharp official:** https://github.com/lovell/sharp
- **Alternativa simple:** ImageMagick bindings o GraphicsMagick (CLI).
- **Para Gatsby:** Documentación de image optimization.

### fibers (Meteor)
- **Fibers en Node.js:** https://github.com/laverdet/node-fibers
- **Alternativa en Meteor 2+:** Async/await nativo (fibers fue deprecado).

### grpc (antiguo)
- **gRPC-js (alternativa JavaScript pura):** https://www.npmjs.com/package/@grpc/grpc-js
- **Cambio mínimo** en imports, misma API.

---

## 🔍 Debugging y troubleshooting

### Comandos útiles (ya mencionados)
```bash
# Ver qué libc usa un binario
ldd ./binary
file ./binary
nm -D ./binary | grep GLIBC_

# Verificar qué versión de glibc
./binary
ldd ./binary | grep libc

# En Alpine, verificar symbols
apk add libc6-compat  # Emulación parcial de glibc

# Caché de compilación
ccache -s  # Ver stats
ccache -C  # Limpiar caché
```

### GDB (GNU Debugger)
- **Manual:** https://sourceware.org/gdb/
- **Debugging Node:** https://nodejs.org/en/docs/guides/debugging-getting-started/
- **Con debug symbols:** Compila Node con `--debug` flag.

---

## 📖 Lectura avanzada

### V8 (JavaScript engine, lo que hace Node tan complejo)
- **V8 official:** https://v8.dev/
- **How V8 compiles (la JIT es por qué toma tanto tiempo):** https://v8.dev/blog/jitless-code-caching
- **ARM64 backend en V8:** https://chromium.googlesource.com/v8/v8/+/refs/heads/main/src/codegen/arm64/
  - Es la raíz de por qué compilar es lento en ARM.

### libuv (event loop, threads, I/O)
- **libuv official:** http://libuv.org/
- **Documentación:** http://docs.libuv.org/v1.x/

### OpenSSL (criptografía, por qué compilar desde fuente es importante)
- **OpenSSL 1.1 (usado en Node 10-14):** https://www.openssl.org/news/vulnerabilities-1.1.html
  - EOL: 16 de septiembre de 2023 (hace años).
- **Compilar manualmente:** https://github.com/openssl/openssl/blob/master/INSTALL.md

---

## 🛠️ Herramientas complementarias

### docker buildx (multi-arquitectura)
- Documentación: https://docs.docker.com/build/architecture/

### QEMU (emulación, entender sus límites)
- **QEMU oficial:** https://www.qemu.org/
- **ARM64 backend:** https://wiki.qemu.org/Features/Aarch64
- **Por qué es lento:** https://www.qemu.org/docs/master/system/arm/virt.html

### Rosetta 2 (no es open-source, pero hay documentación)
- **Apple sobre Rosetta:** https://support.apple.com/en-us/HT211861
- **Roadmap:** Rosetta 2 se quita después de macOS 27 (otoño 2026).

---

## 📰 Artículos y blog posts relevantes (escritos por otros)

### Alpine Linux en producción
- "Alpine Linux: Small is Beautiful, but...": Busca en medium.com
  - Explica trade-offs de tamaño vs compatibility.

### Kubernetes + Alpine (DNS bugs)
- "Why you shouldn't use Alpine as a base image": Popular en 2019-2021 por DNS issues.
- Está parcialmente fixed en musl 1.2.4+, pero Alpine tardó en actualizar.

### Node.js en Docker
- "Node.js best practices for Docker": https://snyk.io/blog/10-docker-image-security-best-practices/
- Multi-stage builds, security, size optimization.

---

## 🎓 Aprendizaje progresivo (nivel)

### Nivel 1: "Solo quiero que funcione"
- Lee: Resúmenes en semilla-docker-legacy-node.md
- Usa: Dockerfile simple + Rosetta (macOS) o nativo (Windows)

### Nivel 2: "Entiendo los conceptos"
- Lee: Todos los docs excepto la parte "casi bare-metal"
- Usa: Dockerfile optimizado con layer caching, ccache
- Experimenta: Elige musl vs glibc para un proyecto

### Nivel 3: "Geek completo"
- Lee: Todos los docs incluyendo compilacion-casi-bare-metal.md
- Haz: Compila Node desde fuente, parchea código C++, usa gdb
- Crea: GitHub Actions workflow multi-arch, CI con caching remoto

### Nivel 4: "Contribuidor de Node"
- Lee: Código fuente de V8 en https://chromium.googlesource.com/v8/v8/
- Contribuye: Fixes para arm64, musl compatibility, etc.

---

## 🤝 Comunidades útiles

### GitHub
- **nodejs/node issues:** Cualquier problema con Node legacy.
- **alpine/aports:** Si necesitas parchear Alpine packages.
- **docker-library/node:** Maintainers de imágenes oficiales.

### Stack Overflow
- Tags: `node.js`, `docker`, `alpine-linux`, `glibc`, `arm64`
- Búsqueda específica: "node-sass alpine" (miles de hits).

### Discusiones académicas
- **Hacker News:** Busca "Alpine" o "Node.js Docker" para debate comunitario.
- **Reddit r/docker, r/golang, r/programming**

---

## 💾 Archivos de referencia (en el proyecto)

Dentro de tu repo tendrás:

```
proyecto-legacy-node/
├── Dockerfile.node10          # Recipe compilada
├── Dockerfile.node12
├── Dockerfile.node14
├── docker-bake.hcl           # Orquestación multi-arch
├── docker-compose.yml        # Servicios (app, db, etc.)
├── .dockerignore             # Qué NO copiar al build context
├── COMPILE_LOG.md            # Tu documentación personal
├── SETUP.md                  # Instrucciones para el equipo
└── README.md                 # Project overview
```

Cada Dockerfile debería tener comentarios que hacen referencia a estos docs:
```dockerfile
# Ver compilacion-casi-bare-metal.md: "El ./configure mágico"
./configure \
  --shared-openssl \   # See glibc-vs-musl.md: por qué prebuilts
  --shared-zlib
```

---

## ⏱️ Checklist de validación

Cuando hayas recorrido todo:

- [ ] Puedo explicar la diferencia entre glibc y musl.
- [ ] Puedo listar 5 paquetes que explotan en Alpine.
- [ ] Sé si Rosetta va a existir en mi macOS en 2 años.
- [ ] He compilado Node desde fuente, al menos una vez.
- [ ] Tengo un Dockerfile reproducible que mi equipo puede usar.
- [ ] Puedo debuggear un binario roto con `ldd` y `nm`.
- [ ] Entiendo por qué `node_modules` no se monta desde el host.

---

## 🚀 Siguientes pasos

1. **Clona un repo con tu setup:** Crea tu propio repositorio con los Dockerfiles.
2. **Prueba en ambas máquinas:** macOS + Windows, asegúrate de que funciona.
3. **Documenta diferencias:** Crea un SETUP.md para tu equipo.
4. **Automatiza con CI:** GitHub Actions + docker buildx para compilar multi-arch.
5. **Comparte el conocimiento:** Escribe un post en blog interno o docs del equipo.

---

**Última actualización:** Agosto 2026  
**Válido hasta:** macOS 27 (otoño 2026), después revisa Rosetta deprecation.

Ahora ve, compila, aprende y domina. 🚀

