# Estrategia base: Docker + Node legacy en macOS Apple Silicon y Windows 11

## Contexto

Tienes:
- **macOS M1/M2/M3**: ARM64 nativo.
- **Windows 11 corporativo**: x86_64 nativo.
- **Legacy stacks**: Node 10-14 (2018-2020), Angular 8, Vue 2, que no puedes (o no quieres) actualizar todavía.
- **Objetivo geek**: entender *por qué* funcionan las cosas, compilar desde fuentes, sin depender de prebuilts.

---

## El problema fundamental: Triple incompatibilidad

```
Tu M1 macOS:        ARM64 darwin
Contenedor legacy:  linux-amd64 (donde viven los prebuilts)
                    ↓
                    Emulación necesaria
```

¿Por qué amd64? Porque **Node 10-14 nunca tuvo soporte oficial darwin-arm64** (llegó en Node 16+). Los únicos binarios eran:
- darwin-x64 (Intel Mac, obsoleto en tu M1)
- linux-x64 (todavía disponible, prebuilts completos)
- linux-arm64 (casi ninguno)

**Resultado:** si quieres contenedores legacy, necesitas emular x86 o compilar nativamente arm64.

---

## Opciones de emulación y su coste

### 1. Rosetta 2 (la mejor opción, hasta 2027)

**Qué es:** Traductor de Apple para x86→ARM en macOS. No es emulador (no interpreta instrucción por instrucción); es **JIT de binario** (traduce chunks x86 a ARM on-the-fly).

**Cómo activarlo en Docker**
```bash
# Docker Desktop (licencia, pero estable):
# Settings > Features > "Use Rosetta for x86/amd64 emulation on Apple Silicon"
# Luego:
docker run --platform linux/amd64 node:14 node --version

# Colima (gratis, con vz framework):
colima start --vm-type vz --vz-rosetta
# Idéntico a Docker Desktop pero sin licencia
```

**Ventajas**
- Rápido: traducciones correctas, sin segfaults de V8 viejo.
- Binarios prebuilt de 2017-2020 funcionan tal cual.
- npm install de node-sass: 2-3 minutos.

**Desventajas**
- **Fecha de caducidad**: macOS 27 (otoño 2026) es la última con soporte completo; macOS 28 (otoño 2027) lo quita.
- Docker Desktop requiere licencia (Colima es alternativa gratis).

**Línea temporal**
- Hoy (agosto 2026): pleno soporte.
- Sept 2026 (macOS 27): último release con Rosetta completo.
- Otoño 2027 (macOS 28): Rosetta desaparece (excepto subconjunto para juegos viejos).

---

### 2. QEMU user-mode (en Colima sin Rosetta)

**Qué es:** Emulador clásico de QEMU, traduce **cada instrucción x86**. Más preciso pero mucho más lento que Rosetta.

```bash
colima start --arch aarch64 --vm-type qemu
```

**Ventajas**
- A prueba de futuro: QEMU no va a desaparecer.
- Funciona en cualquier macOS.

**Desventajas**
- **Node 10-14 + QEMU = segfaults aleatorios** en V8 (su JIT no emula bien bajo QEMU).
- npm install node-sass: 15-30 minutos, con fallos intermitentes.
- Compilaciones crípticas fallan sin razón clara.
- Watchers/hot-reload son tortura.

**Cuándo es tolerable**
- Una compilación inicial cacheada que luego solo ejecutas.
- Procesos que no usan paralelismo (make -j1).
- Paciencia sin límite.

---

### 3. VM x86_64 completa en QEMU

**Qué es:** La máquina *entera* es emulada en x86, no solo los procesos.

```bash
colima start --arch x86_64 --vm-type qemu
```

**Ventajas**
- Ejecutas "el OS correcto" — cero problemas de ABI.

**Desventajas**
- **Brutalmente lento**: el sistema operativo completo se emula (TCG without hardware acceleration).
- Compilar node-sass: 45-60 minutos.
- No recomendable más que como "último recurso".

---

### 4. Compilar nativo linux-arm64 (la mejor opción técnica, pero requiere trabajo)

**Qué es:** Ignorar los prebuilts x64, compilar Node y dependencias nativas directamente para ARM64 Linux.

```dockerfile
FROM debian:buster-slim  # arm64 automático en tu M1
# Node compila desde fuente
# node-sass, bcrypt, sqlite3 compilan desde fuente
# Cero emulación, velocidad total
```

**Ventajas**
- Cero emulación → velocidad nativa.
- A prueba de futuro: no depende de Rosetta.
- Educativo: aprendes cómo funcionan las cosas de verdad.

**Desventajas**
- Primera compilación: 20-30 min para Node 10.
- Necesitas toolchain arm64 (gcc, python2, make).
- Código C++ viejo que asume cosas de x64 puede no compilar (aunque raro).

**Mejor para**
- Desarrollo educativo (tu caso 😄).
- Cuando cacheas la imagen y la compartes con el equipo.
- Paso 1 hacia eliminar Rosetta antes de macOS 28.

---

## Decisiones por escenario

### Si estás en macOS M1/M2/M3 hoy (antes de 2027)

**Opción recomendada: Rosetta + Debian amd64 emulado**
```dockerfile
FROM --platform=linux/amd64 node:14-buster-slim
RUN sed -i 's|deb.debian.org|archive.debian.org|g' /etc/apt/sources.list && \
    apt-get update && apt-get install -y python2 make g++
```

```bash
# Docker Desktop:
docker build -t legacy-node14 .  # Rosetta traduce automáticamente
docker run -it legacy-node14 npm install  # 2-3 min

# O Colima:
colima start --vm-type vz --vz-rosetta
docker build -t legacy-node14 .
```

**Por qué:** velocidad aceptable, prebuilts funcionan, zero misterios.

---

### Si quieres futuro-proof (antes de macOS 28)

**Opción: Compilar arm64 nativo + cachear imagen**

```dockerfile
FROM debian:buster-slim  # arm64 en tu M1
# Descargas Node 14.21.3, haces ./configure && make
# (Detalles en compilacion-casi-bare-metal.md)
```

```bash
docker build -t legacy-node14-native .  # 25 min, una sola vez
docker push registry.com/legacy-node14-native  # Compartir con equipo
# Equipo:
docker pull registry.com/legacy-node14-native  # 2 min, instant
docker run -it ... npm ci  # Solo descarga, no compila
```

**Por qué:** Zero Rosetta dependency, velocidad total, compartible.

---

### Si estás en Windows 11 corporativo

**Arquitectura:**
- Tu máquina: x86_64 (Intel/AMD).
- Docker corre en **WSL2** (VM Linux x86_64).
- Contenedores: linux/amd64 nativo (sin emulación).

```dockerfile
FROM node:14-buster-slim  # Automáticamente amd64
RUN apt-get update && apt-get install -y python2 make g++
```

**Ventajas sobre macOS**
- Cero emulación, velocidad nativa.
- Prebuilts de node-sass, bcrypt, etc. descargan directamente.
- npm install: 2-3 minutos.

**Desventajas corporativas**
1. **Proxy/SSL corporativo**
   ```dockerfile
   # Inyecta certificado raíz
   COPY corp-ca.crt /usr/local/share/ca-certificates/
   RUN update-ca-certificates
   ENV NODE_EXTRA_CA_CERTS=/usr/local/share/ca-certificates/corp-ca.crt
   ```

2. **Filesystem lento (NTFS desde WSL2)**
   ```bash
   # ❌ LENTO: clonar en C:\Users\..., mountear desde WSL
   # ✅ RÁPIDO: git clone dentro de WSL (ext4)
   wsl
   cd ~
   git clone ...
   docker run -v $(pwd):/app node:14-buster-slim npm install
   ```

3. **CRLF (carriage return issues)**
   ```bash
   # En WSL2:
   git config --global core.autocrlf input
   # O en el repo:
   echo "* text=auto eol=lf" > .gitattributes
   ```

4. **Docker Desktop vs alternativas**
   - Oficial pero con licencia para empresas.
   - **Rancher Desktop** (gratis, idéntico).
   - **Podman Desktop** (gratis, compatible).

---

## Matriz de decisión rápida

| Máquina | Stack | Emulación | Tiempo build 1° vez | Recomendación |
|---|---|---|---|---|
| M1/M2 macOS | Node 14 | Rosetta amd64 | 3-5 min | ✅ Recomendado ahora |
| M1/M2 macOS | Node 14 | QEMU amd64 | 20-30 min | ⚠️ Si Rosetta no disponible |
| M1/M2 macOS | Node 14 | Nativo arm64 | 20-30 min | ✅ Geek, futuro-proof |
| Windows 11 | Node 14 | Nada (amd64 nativo) | 2-3 min | ✅ Recomendado |
| M1/M2 macOS | Node 16+ | Nada (arm64 nativo prebuilts) | <1 min | ✅ Modernos |

---

## El plan de equipo (macOS + Windows mixto)

```
Repo compartido:
├── Dockerfile                    # FROM node:14-buster-slim
├── docker-compose.yml            # Servicios (app, db, etc.)
├── .dockerignore                 # Excluir node_modules volúmenes
├── docker-bake.hcl              # Multi-arquitectura si quieres
└── SETUP.md
   └── "En macOS: colima start --vm-type vz --vz-rosetta"
   └── "En Windows: Docker Desktop / Rancher"
   └── "En Linux: Linux nativo (x86_64), cero emulación"
```

**Flujo para todos**
```bash
git clone ...
docker build -t myapp-dev .  # Cada quien, su arquitectura
docker run -it -v $(pwd):/app myapp-dev npm start
```

**Beneficio:** buildkit de Docker elige la arquitectura nativa automáticamente.

---

## Warnings y gotchas

### ❌ Montar node_modules del host
```bash
# NUNCA (especialmente macOS ↔ Linux):
docker run -v $(pwd):/app node:14 npm install
# El .node binario es darwin-arm64; Linux no puede cargarlo
```

**Correcto:**
```bash
# Excluir node_modules del volumen
docker run -v $(pwd):/app -v /app/node_modules node:14 npm ci
# O usar .dockerignore
```

### ⚠️ Python 2 en Debian moderno
```dockerfile
RUN apt-get install -y python2.7  # Buster tiene; Bullseye no
# Para Debian >buster:
RUN apt-get install -y python  # apunta a python3, node-gyp viejo falla
# Solución: configurar explícitamente
RUN npm config set python python3
# Pero algunos paquetes (node-sass viejo) si requieren python2
```

### 🔴 Rosetta desaparece en macOS 28
**Plan ahora:**
- Imagen arm64 nativa alternativa.
- Pipeline CI x86 real para compilar amd64 si es necesario.
- Tests funcionales en ambas arquitecturas.

---

## Próximos pasos

1. **Lee `compilacion-casi-bare-metal.md`** para las recetas detalladas.
2. **Elige tu camino:**
   - **Pragmático**: Rosetta amd64 + Debian (bueno para producción).
   - **Geek**: Compilar arm64 nativo desde fuente (bueno para aprendizaje y futuro).
3. **Configura Colima** si quieres gratis + Rosetta, o Docker Desktop si tienes licencia.
4. **Valida** con un proyecto real (Angular 8, Vue 2) en ambas máquinas.

---

## Resumen ejecutivo

| Aspecto | macOS M-series | Windows 11 |
|---|---|---|
| Nativo | arm64 | x86_64 |
| Mejor opción hoy | Rosetta amd64 | Nativo x86_64 |
| Tiempo build | 2-3 min | 2-3 min |
| Futuro-proof | Compilar arm64 | Compilar arm64 (menos urgente) |
| Herramientas | Docker Desktop (licencia) o Colima (gratis) | Docker Desktop / Rancher Desktop |
| Gotchas | Montar node_modules, Rosetta expira 2027 | Proxy corporativo, NTFS lento |

**La realidad geek:** vas a aprender más compilando manualmente en Lima (macOS) o WSL2 (Windows), viendo exactamente dónde falla cada cosa, que descargando prebuilts. Eso es la próxima sección.
