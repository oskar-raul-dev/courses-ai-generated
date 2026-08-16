# 📚 Índice de lectura — Proyecto completo

**Contenido:** Docker Legacy Node (macOS Apple Silicon + Windows 11) +
ruta de aprendizaje de sistemas (Arch/LFS/BSD/hardware).
**Orden:** numérico. Cada archivo se sostiene solo, pero el orden acumula contexto.

---

## ⚠️ Antes de leer

El documento **08 (errata)** corrige una afirmación presente en los
documentos 02, 06 y 07: se dijo que "Rosetta desaparece totalmente en
macOS 28" — es **incorrecto para contenedores Linux amd64**. Apple integra
esa traducción al sistema en macOS 27. Si solo lees uno de estrategia,
lee el 08 después del 06.

---

## Bloque A — Proyecto Docker Legacy Node

| # | Archivo | Qué contiene | Tiempo |
|---|---|---|---|
| 01 | `01-inicio.md` | Puerta de entrada: 3 caminos (rápido/educativo/geek), 4 gotchas principales | 10 min |
| 02 | `02-resumen-ejecutivo.md` | Los 5 puntos clave, matriz de decisión, setup copy-paste. ⚠️ Ver errata 08 | 15 min |
| 03 | `03-poster-visual.md` | Diagramas ASCII: árbol de decisión, matrices, timings | 10 min |
| 04 | `04-glibc-vs-musl.md` | Fundamentos: qué es cada libc, distros, problemas de compatibilidad | 20 min |
| 05 | `05-problemas-musl-node-antiguo.md` | Los paquetes que explotan (node-sass, phantomjs, bcrypt...) + soluciones | 25 min |
| 06 | `06-semilla-docker-legacy-node.md` | Estrategia: Rosetta/QEMU/nativo, macOS vs Windows, gotchas. ⚠️ Ver errata 08 | 25 min |
| 07 | `07-rendimiento-colima-qemu.md` | Benchmarks: QEMU ~10x vs Rosetta ~1.2x, por qué V8 sufre, optimizaciones. ⚠️ Ver errata 08 | 20 min |
| 08 | `08-errata-rosetta-macos27.md` | **CORRECCIÓN verificada en Apple**: macOS 27 integra la traducción Intel para Linux VMs. El baseline amd64 es sostenible | 10 min |
| 09 | `09-compilacion-casi-bare-metal.md` | Compilar Node desde fuente: Lima (macOS), WSL2 (Windows), flags de ./configure, ccache, conversión a Dockerfile | 30 min + compilación |
| 10 | `10-templates-dockerfile.md` | 7 Dockerfiles copy-paste: básico → multi-stage, multi-arch, proxy corporativo | 5 min consulta |
| 11 | `11-referencias-y-recursos.md` | Links oficiales: Node, Docker, Lima/Colima, paquetes, debugging | consulta |

## Bloque B — Ruta de aprendizaje de sistemas

| # | Archivo | Qué contiene | Tiempo |
|---|---|---|---|
| 12 | `12-ruta-aprendizaje-sistemas.md` | El plan completo: por qué compilar a mano vale la pena; escalera Arch→Gentoo→LFS; qué aporta cada BSD; **Etapa 1** (Yoga: Arch + lectora + cacharreo: kernel propio, módulos, contenedores con unshare, shell en C); **Etapa 2** (xv6 + OSTEP en vez de Minix); **Etapa 3** (armar PC ~300 USD, multiboot); **Etapa 4** (NAS —no SAN— sobre Gentoo y luego Debian/FreeBSD); la flota de hardware completa | 30 min |
| 13 | `13-guia-compra-hardware-colombia.md` | Comprar usado sin estafas: canales locales (Unilago, MercadoLibre, FB Marketplace), checklist de prueba presencial con USB Linux live, eBay + casillero (franquicia USD 200 del TLC), qué traer vs comprar local, precios objetivo | 15 min |

---

## Rutas según tu momento

**"Necesito el Docker funcionando ya"** → 01, 02, 08, 10. (~45 min)

**"Quiero entender las decisiones"** → 01→08 en orden. (~2 h)

**"Modo geek completo"** → todo en orden; el 09 con terminal abierta. (~4 h + compilaciones)

**"Vengo por la ruta de aprendizaje de sistemas"** → 12, 13, y el 09 como
puente (compilar Node es el precalentamiento de compilar kernels).

---

## Estado del proyecto

- Tutorial Docker (fases 00-04 del usuario): pendiente revisión completa
  con la reformulación Rosetta → "traducción de binarios Linux x86_64"
  (ver doc 08, sección 4).
- Etapa 1 (Arch en la Yoga): lista para arrancar.
- Etapa 2 (xv6): lista, corre en cualquier máquina de la flota.
- Etapas 3-4: planificadas, dependen de compras (doc 13).
