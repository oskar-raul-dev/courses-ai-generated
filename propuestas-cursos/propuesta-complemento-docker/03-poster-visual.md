# Poster Visual: Node Legacy Docker en 2026

Diagrama de decisión y matriz rápida para imprimir/compartir con tu equipo.

---

## 🎯 Árbol de decisión: ¿Qué hago?

```
        ┌─ Tengo Node 10-14 en Docker
        │
        ├─ ¿En qué máquina corro?
        │
        ├─── macOS M1/M2/M3
        │    ├─ ¿Quiero que funcione YA?
        │    │  └─ SÍ → Rosetta amd64 + Debian (2-3 min npm install)
        │    │
        │    └─ ¿Quiero futuro-proof (sin Rosetta post-2027)?
        │       └─ SÍ → Compilar arm64 nativo (25 min, una sola vez)
        │
        └─── Windows 11 x86_64
             ├─ ¿Tienes proxy corporativo?
             │  └─ SÍ → Docker + Dockerfile con cert raíz corporativo
             │
             └─ ¿Sin proxy?
                └─ Docker Desktop / Rancher → Nativo x86_64 (2-3 min)
```

---

## 📊 Matriz: Velocidad vs Complejidad

```
RAPIDEZ
   ▲
   │  Rosetta amd64
   │  (macOS hoy)
   │      ★ 2-3 min
   │
   │  Nativo Windows  
   │  (Windows siempre)
   │      ★ 2-3 min
   │
   │  Compilar arm64 nativo
   │  (macOS futuro)
   │      ◇ 25 min 1° vez
   │      ◇ 0 min después (caché)
   │
   │  QEMU (Alpine)
   │      ✗ 20-30 min, inestable
   │
   └────────────────────────────────► COMPLEJIDAD/EDUCACIÓN
```

---

## 🔀 Flujo: ¿Alpine o Debian?

```
¿Usas Node legacy (10-14)?
    │
    ├─ SÍ → Debian SIEMPRE
    │       (Alpine = sufrimiento)
    │
    └─ NO (Node 16+) → Alpine OK
                      (prebuilts existen)

REGLA ORO:
  Node 10-14 + Alpine = 
    node-sass falla (15-20 min, luego ERROR)
    phantomjs falla (no existe binario)
    bcrypt falla (compila mal)
    
    SOLUCIÓN: Debian (250 MB, todo funciona)
```

---

## 💾 Paquetes que explotan + Soluciones

```
┌─────────────────────┬──────────────────────────────┬──────────────────┐
│ Paquete             │ Problema                     │ Solución         │
├─────────────────────┼──────────────────────────────┼──────────────────┤
│ node-sass           │ Sin prebuilt musl/arm64      │ sass (JS puro)   │
│ phantomjs-prebuilt  │ Descarga binario x64 no.más  │ chromium + karma │
│ bcrypt              │ Nativo, sin musl             │ bcryptjs (JS)    │
│ sharp               │ Requiere vips compilado      │ Desactiva dev    │
│ fibers              │ Nativo, arm64 falla          │ async/await      │
│ grpc (viejo)        │ Nativo sin musl              │ @grpc/grpc-js    │
└─────────────────────┴──────────────────────────────┴──────────────────┘

PATRÓN: Si usa "node-gyp" (compilación nativa) → riesgo.
        Si es "JavaScript puro" → seguro.
```

---

## 🛠️ Herramientas por plataforma

```
┌──────────────────────────────────────────────┐
│ macOS M1/M2/M3                               │
├──────────────────────────────────────────────┤
│                                              │
│  Opción A (rápida, hoy)                     │
│  ├─ Colima (gratis) + Rosetta               │
│  │  brew install colima                     │
│  │  colima start --vm-type vz --vz-rosetta  │
│  │  docker build -t myapp . (2-3 min)       │
│  │  ✅ Funciona, pero expira 2027            │
│  │                                           │
│  └─ Docker Desktop (licencia)               │
│     Equivalent a Colima pero de pago         │
│                                              │
│  Opción B (futuro-proof)                    │
│  ├─ Lima (educativo)                        │
│  │  limactl start --name legacy              │
│  │     template://debian-12                  │
│  │  Compila Node manualmente (25 min)        │
│  │  ✅ Sin Rosetta dependency                │
│  │                                           │
│  └─ Docker + arm64 nativo                   │
│     Dockerfile.compile-from-source           │
│     Construye imagen, comparte con equipo    │
│                                              │
└──────────────────────────────────────────────┘

┌──────────────────────────────────────────────┐
│ Windows 11                                   │
├──────────────────────────────────────────────┤
│                                              │
│  ✅ Nativo x86_64 (sin emulación)            │
│                                              │
│  ├─ Docker Desktop                          │
│  │  Instalado → docker build (2-3 min)      │
│  │                                           │
│  ├─ Rancher Desktop (gratis)                │
│  │  Alternativa gratuita a Docker Desktop   │
│  │                                           │
│  └─ Podman Desktop (gratis)                 │
│     Otra alternativa, OCI compatible        │
│                                              │
│  ⚠️ Gotchas:                                 │
│  • Proxy corporativo → inyecta cert raíz    │
│  • NTFS lento → compila en WSL2 (ext4)      │
│  • CRLF → git config core.autocrlf input    │
│                                              │
└──────────────────────────────────────────────┘
```

---

## ⏱️ Timings reales

```
Escenario                           Tiempo          Notas
─────────────────────────────────────────────────────────────
macOS Rosetta amd64 + npm install   2-3 minutos     ✅ Hoy, rápido
Windows nativo + npm install        2-3 minutos     ✅ Siempre rápido
                                                    
Compilar Node arm64 (1° vez)        25 minutos      ⏳ Paciencia
Compilar Node arm64 (caché)         3 minutos       ✅ Segunda vez
                                                    
QEMU amd64 emulado + npm install    20-30 min       ❌ Inestable
QEMU VM x86 completa                45-60 min       ❌❌ Tortura
```

---

## 🎯 Setup de 5 minutos (copy-paste)

### macOS
```bash
brew install colima
colima start --vm-type vz --vz-rosetta

# Dockerfile (simple)
cat > Dockerfile << 'EOF'
FROM --platform=linux/amd64 node:14-buster-slim
RUN sed -i 's|deb.debian.org|archive.debian.org|g' /etc/apt/sources.list && \
    apt-get update && apt-get install -y python2.7 make g++ && \
    rm -rf /var/lib/apt/lists/*
EOF

docker build -t myapp:dev .
docker run -it -v $(pwd):/app myapp:dev npm install
```

### Windows
```bash
# Si no tienes Docker Desktop/Rancher, instala primero

cat > Dockerfile << 'EOF'
FROM node:14-buster-slim
RUN sed -i 's|deb.debian.org|archive.debian.org|g' /etc/apt/sources.list && \
    apt-get update && apt-get install -y python2.7 make g++ && \
    rm -rf /var/lib/apt/lists/*
EOF

docker build -t myapp:dev .
docker run -it -v C:\Users\...\project:/app myapp:dev npm install
```

---

## ⚠️ Los 3 gotchas que causan 90% de bugs

### ❌ Gotcha 1: Montar node_modules del host

```bash
# JAMÁS hagas esto:
docker run -v $(pwd):/app node:14 npm install

# El .node binario es darwin-arm64 (tu Mac)
# Linux intenta cargarlo → Segmentation fault

# ✅ CORRECTO:
docker run -v $(pwd):/app -v /app/node_modules node:14 npm install
```

### ❌ Gotcha 2: Olvidar archive.debian.org

```dockerfile
# ❌ FALLA (repos están muertos):
RUN apt-get update  # No encuentra paquetes

# ✅ CORRECTO:
RUN sed -i 's|deb.debian.org|archive.debian.org|g' /etc/apt/sources.list && \
    apt-get update
```

### ❌ Gotcha 3: Alpine con Node legacy

```dockerfile
# ❌ Dolor durante horas:
FROM node:14-alpine3.12
RUN npm install node-sass

# ✅ Pragmático:
FROM node:14-buster-slim
RUN npm install node-sass  # Funciona en 10 segundos
```

---

## 📈 Ciclo de vida: Hoy vs 2027

```
2026 (hoy)          2027 (macOS 28)     Post-2027
──────────────────────────────────────────────────
│                   │                   │
Rosetta funciona ──┐│                   │
                   ││ Rosetta          │
                   ││ desaparece       │
                   │└─ Plan fallback: ││
                   │  ARM64 nativo    ││
                   │  o CI x86 real   ││
                   │                   │
Acción HOY:        Acción ANTES 2027:  Congelado
├─ Rosetta+amd64   ├─ Tener arm64     ├─ No más
├─ O arm64 nativo  │  alternativa     │  Rosetta
└─ Ambas OK        └─ O CI pipeline   └─ Forzar
                      arm64 + x86         arm64
```

---

## 🎓 Niveles de aprendizaje

```
┌─────────────────────────────────────────────────────────┐
│ NIVEL 1: "Solo quiero funcionando"                      │
├─────────────────────────────────────────────────────────┤
│ Lee: RESUMEN-EJECUTIVO.md (5 min)                       │
│ Haz: Copia Template 1 Dockerfile, docker build (3 min)  │
│ Tiempo total: 10 minutos                                 │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ NIVEL 2: "Entiendo qué falla y por qué"               │
├─────────────────────────────────────────────────────────┤
│ Lee: glibc-vs-musl.md                                   │
│      problemas-musl-node-antiguo.md                     │
│      semilla-docker-legacy-node.md                      │
│ Tiempo: 1 hora                                           │
│ Resultado: Experto en decisiones arquitectura           │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ NIVEL 3: "Geek completo, compilo desde fuente"        │
├─────────────────────────────────────────────────────────┤
│ Lee: compilacion-casi-bare-metal.md                     │
│ Haz: Compila Node manualmente en Lima o WSL2 (25 min)   │
│      Crea Dockerfile.compile-from-source                │
│ Documenta: COMPILE_LOG.md personal                      │
│ Tiempo: 3-4 horas (+ compilación)                       │
│ Resultado: Full control, futuro-proof                   │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ NIVEL 4: "Contribuidor Node/V8"                        │
├─────────────────────────────────────────────────────────┤
│ Estudia: V8 source en chromium.googlesource.com         │
│ Contribuye: Fixes arm64/musl compatibility              │
│ Tiempo: indefinido (rabbit hole ∞)                      │
└─────────────────────────────────────────────────────────┘
```

---

## 📋 Checklist final

Completaste cuando:

- [ ] Entiendes glibc vs musl.
- [ ] Sabes por qué Alpine falla con Node 10-14.
- [ ] Compilaste Node desde fuente (o al menos leíste cómo).
- [ ] Tu Dockerfile funciona en macOS Y Windows (o elegiste uno).
- [ ] Conoces qué reemplaza a node-sass, phantomjs, bcrypt.
- [ ] Tienes imagen compartida en equipo (o sabes cómo hacerlo).
- [ ] Planificaste alternativa post-Rosetta 2027.

---

## 🚀 Acción YA

**Opción A: "Pragmático"**
1. Descarga RESUMEN-EJECUTIVO.md
2. Copia Template 1 Dockerfile
3. `docker build -t myapp:dev . && docker run -it -v $(pwd):/app myapp:dev npm install`
4. ✅ Listo en 10 minutos

**Opción B: "Educativo"**
1. Lee glibc-vs-musl.md (15 min)
2. Lee compilacion-casi-bare-metal.md (30 min)
3. Compila Node en Lima (25 min) o WSL2
4. Crea tu Dockerfile.compile-from-source
5. Documentar en COMPILE_LOG.md
6. Comparte con equipo
7. ✅ Máster en 3-4 horas

---

**¿Listo? Ahora sí a compilar. 🎯**

