# Resumen Ejecutivo: Node Legacy en Docker — Lo que importa

## TL;DR (Too Long; Didn't Read)

Tienes Node 10-14 (2018-2020) y quieres correrlo en Docker en macOS Apple Silicon y Windows 11. Aquí están los 5 puntos que importan:

---

## 1️⃣ El Problema Fundamental

**Node 10-14 nunca tuvo binarios oficiales para darwin-arm64 (tu M1).**

Lo que significa:
- No puedes correr `node:14` nativo en tu Mac — no existe el binario compilado para ARM.
- Necesitas **emulación x86** (correr Linux x64 dentro de tu ARM) O **compilar desde fuente** (arm64 nativo).

**Emulación x86:** Rosetta 2 (rápido, pero desaparece en macOS 28, otoño 2027) vs QEMU (lento, pero futuro-proof).

**Compilar desde fuente:** Nada de emulación, pero requiere trabajo (20-30 min de compilación inicial).

---

## 2️⃣ Tu Decisión de Hoy: ¿Qué uso?

### macOS M1/M2/M3 (hoy, antes de 2027)

**Mejor opción ahora:** Rosetta amd64 + Debian (glibc)

```dockerfile
FROM --platform=linux/amd64 node:14-buster-slim
```

- ✅ Rápido: npm install toma 2-3 minutos.
- ✅ Prebuilts funcionan: node-sass, bcrypt, sqlite3, todo descarga binario.
- ⚠️ Expira: macOS 28 (otoño 2027) quita Rosetta.
- 💡 Usa: `colima start --vm-type vz --vz-rosetta` (gratis, no Docker Desktop).

**Mejor opción futuro-proof:** Compilar arm64 nativo

```dockerfile
FROM debian:buster-slim  # Automáticamente arm64 en tu M1
# Descargas Node 14 fuente, ./configure && make
```

- ✅ Cero Rosetta dependency, A prueba de futuro.
- ✅ Rápido (nativo): compilación initial ~20-25 min, luego cachéa.
- ⚠️ Trabajo: necesitas entender compilación.
- 💡 Mejor: construye una vez, comparte imagen con equipo, nadie vuelve a compilar.

### Windows 11 (x86_64 nativo, no hay emulación)

**Mejor opción:** Nativo x86_64

```dockerfile
FROM node:14-buster-slim  # Automáticamente amd64 en Windows
```

- ✅ Cero emulación, velocidad total.
- ✅ npm install: 2-3 minutos.
- ⚠️ Proxy corporativo: inyecta certificado raíz en Dockerfile.
- ⚠️ NTFS lento: clona repos dentro de WSL2 (ext4), no en C:\.

---

## 3️⃣ El Gotcha: Alpine vs Debian

**Alpine (musl)** = 80 MB, pero...

```bash
npm install node-sass  # ❌ Compila desde fuente, 15-20 min
# Casi seguro FALLA porque:
# - node-sass es LibSass (C++), no tiene prebuilt musl
# - Código C++ asume glibc internals
```

**Debian (glibc)** = 250 MB, pero...

```bash
npm install node-sass  # ✅ Descarga prebuilt, 10 segundos
```

**Para Node legacy: Alpine = dolor. Debian = pragmático.**

Si insistes en Alpine:
- Reemplaza node-sass → `sass` (JavaScript puro, 1 línea).
- Reemplaza phantomjs → `chromium` + Karma headless (5 líneas).
- Reemplaza bcrypt → `bcryptjs` (más lento, pero funciona).

---

## 4️⃣ Los Paquetes que Explotan (y soluciones rápidas)

| Paquete | Problema | Solución |
|---|---|---|
| **node-sass** | Sin prebuilt musl/arm64 | Usa `sass` (dart-sass, JS puro) |
| **phantomjs-prebuilt** | Descarga binario x64-glibc | Usa `chromium` (apk) + karma-chrome |
| **bcrypt** | Sin prebuilt musl | Usa `bcryptjs` (JS puro, más lento) |
| **sharp** | Compila vips pesado | Desactiva optimización en dev Docker |
| **fibers** | Nativo, roto en arm64 | Reescribe con async/await |
| **grpc** (viejo) | Nativo sin musl | Usa `@grpc/grpc-js` (JavaScript) |

**Regla:** Si usa compilación nativa (node-gyp), va a dar problemas. Busca alternativa JS pura o desactívalo en dev.

---

## 5️⃣ El Plan: Imagen compartida con el equipo

La jugada más geek (y pragmática):

```bash
# Paso 1: UNA PERSONA compila (20 min, una sola vez)
docker build -t legacy-node:14-compiled -f Dockerfile.node14 .
docker push registry.com/legacy-node:14-compiled

# Paso 2: EQUIPO descarga y usa (2 min, cero compilación)
docker pull registry.com/legacy-node:14-compiled
docker run -it -v $(pwd):/app legacy-node:14-compiled npm install
# Listo, zero pain points, todos en arm64 o amd64 según su máquina
```

**Beneficio:**
- macOS: construye nativo arm64 una vez, todos los M1/M2/M3 lo usan.
- Windows: construye nativo amd64 una vez, todos los Windows lo usan.
- Single Dockerfile, multi-arch automático.

---

## 🎯 Las 3 decisiones que necesitas tomar

### Decisión 1: ¿Ahora o futuro-proof?

| Si dices... | Elige... |
|---|---|
| "Necesito funcionando YA" | Rosetta amd64 (macOS) o nativo (Windows) + Debian |
| "Quiero aprender compilando" | Compila arm64 nativo desde fuente (macOS) |
| "Necesita durar más allá de 2027" | Compila arm64 nativo, planifica CI x86 real |

### Decisión 2: ¿Alpine o Debian?

| Si dices... | Elige... |
|---|---|
| "Menor tamaño posible" | Alpine (pero espera problemas) |
| "Pragmático, sin sorpresas" | Debian slim (250 MB, todo funciona) |
| "Legacy Node 10-14" | Debian sin dudarlo |

### Decisión 3: ¿Solo yo o equipo?

| Si dices... | Elige... |
|---|---|
| "Proyecto personal" | Rosetta + Dockerfile simple |
| "Compartir con equipo (macOS+Windows)" | Compila nativo, comparte imagen multi-arch |
| "Equipo corporativo Windows" | Dockerfile + Docker Desktop / Rancher Desktop |

---

## ⚡ El Setup de 5 minutos (hoy, antes de pensar)

```bash
# macOS: instala Colima (gratis, Rosetta)
brew install colima
colima start --vm-type vz --vz-rosetta

# Windows: asume Docker Desktop / Rancher Desktop instalado

# Ambos: Dockerfile simple
cat > Dockerfile << 'EOF'
FROM --platform=linux/amd64 node:14-buster-slim  # macOS emula, Windows nativo
RUN sed -i 's|deb.debian.org|archive.debian.org|g' /etc/apt/sources.list && \
    apt-get update && apt-get install -y python2.7 make g++ && \
    rm -rf /var/lib/apt/lists/*
EOF

# Build
docker build -t myapp:dev .

# Run
docker run -it -v $(pwd):/app myapp:dev npm install
# Listo. Espera 2-3 minutos (descargando, no compilando).
```

---

## 🚨 Los gotchas que causan 90% de problemas

❌ **No montes node_modules del host**
```bash
# NUNCA:
docker run -v $(pwd):/app node:14 npm install
# El .node binario es darwin-arm64; Linux no lo carga.
```

✅ **Excluye node_modules del volumen**
```bash
docker run -v $(pwd):/app -v /app/node_modules node:14 npm install
```

❌ **No uses Alpine para Node 10-14**
```dockerfile
FROM node:14-alpine3.12  # Vas a sufrir 2 horas debuggeando
```

✅ **Usa Debian para legacy**
```dockerfile
FROM node:14-buster-slim
```

❌ **No olvides Python 2**
```dockerfile
# Si tu Dockerfile no trae python2:
RUN apt-get install -y python2.7
```

❌ **No olvides archive.debian.org**
```dockerfile
# Buster está obsoleto, repos apk/apt mueren
RUN sed -i 's|deb.debian.org|archive.debian.org|g' /etc/apt/sources.list
```

---

## 📚 Para ir más profundo

| Necesitas... | Lee... | Tiempo |
|---|---|---|
| Entender glibc vs musl | `glibc-vs-musl.md` | 15 min |
| Saber qué paquete va a fallar | `problemas-musl-node-antiguo.md` | 20 min |
| Elegir arquitectura (Rosetta? QEMU?) | `semilla-docker-legacy-node.md` | 20 min |
| Compilar desde fuente tú mismo | `compilacion-casi-bare-metal.md` | 30 min + 20-30 min compilando |
| Links y recursos técnicos | `REFERENCIAS-Y-RECURSOS.md` | Consulta |

---

## ✅ Validación: ¿Lo entendiste?

Si puedes responder esto, completaste:

1. **¿Qué es glibc vs musl?** → Dos librerías C. glibc en Debian, musl en Alpine. Problema: compatibilidad binarios.
2. **¿Por qué node-sass falla en Alpine?** → No hay prebuilt musl, compila desde fuente, código C++ asume glibc.
3. **¿Rosetta desaparece cuándo?** → macOS 28 (otoño 2027). Mejor plan: compilar arm64 nativo ahora.
4. **¿Qué reemplazo por phantomjs?** → Chromium headless + karma-chrome-launcher (5 líneas de cambio).
5. **¿Cómo compartir con equipo macOS+Windows?** → Compile nativo en cada arquitectura, push a registry, multi-arch manifest.

---

## 🚀 Acción inmediata (hoy)

**Si tienes macOS M1/M2/M3:**
```bash
brew install colima
colima start --vm-type vz --vz-rosetta
# Copia el Dockerfile de arriba
docker build -t myapp:dev .
docker run -it -v $(pwd):/app myapp:dev npm start
```

**Si tienes Windows 11:**
```bash
# Instala Docker Desktop o Rancher Desktop (si no tienes)
# Copia el Dockerfile (igual, solo sin --platform flag)
docker build -t myapp:dev .
docker run -it -v C:\Users\...\project:/app myapp:dev npm start
```

**Listo, funciona en 2-3 minutos.**

---

## 🎓 Lo que aprendes después

- Compilar Node desde fuente (20-30 min, muy educativo).
- Debuggear binarios con ldd, nm, file.
- Entender V8, arm64 ABI, cross-compilation.
- Docker multi-arch, buildx, caching.
- Por qué Rosetta expira y cómo prepararse.

---

## Conclusión

**Para Node 10-14 en Docker en 2026:**

| | macOS | Windows |
|---|---|---|
| **Ahora (rápido)** | Rosetta amd64 + Debian | Nativo x86_64 + Debian |
| **Futuro (2027+)** | Compilar arm64 desde fuente | Seguir con nativo (sin cambios) |
| **Equipo** | Imagen multi-arch compartida | Imagen multi-arch compartida |

**Lo importante:** Debian (glibc) > Alpine (musl) para legacy.  
**Lo práctico:** Compilar una vez, compartir imagen, nadie vuelve a compilar.  
**Lo geek:** Entender *por qué* falla cada cosa y cómo arreglarlo.

---

Ahora sí, ¡a compilar! 🚀

