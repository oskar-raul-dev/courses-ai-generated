# 🎓 Ruta de aprendizaje de sistemas: de Arch a LFS, BSDs y hardware propio

> Resumen de la segunda mitad de la conversación: el plan de aprendizaje
> "geek" que se desprendió del proyecto Docker Legacy — compilar a mano,
> internals de SO, Unix libres, y la flota de hardware para lograrlo.

---

## 1. ¿Vale la pena aprender "a mano" si luego usarás apt?

**Sí, rotundamente.** Los argumentos centrales:

- **Desmitificación**: quien compiló un kernel o un sistema LFS deja de ver
  el OS como caja negra. Cuando falla un `GLIBC_2.28 not found` en producción,
  reconoce la capa exacta del problema porque él construyó esas capas.
- **Criterio**: después de compilar todo a mano entiendes qué te *regala*
  apt (resolución de dependencias, ABI estable, parches). Usas la abstracción
  por elección informada, no por ignorancia.
- **Vacuna contra el miedo**: "abajo" no hay magia, solo más código y Makefiles.

Matices honestos: retorno decreciente (la 5ª compilación de kernel enseña poco),
LFS vale oro *una vez* — el ejercicio es el destino, no el sistema resultante.
Y rinde si hay curiosidad genuina; por checkbox de CV rinde mucho menos.

## 2. La escalera de distros "de cambios"

```text
1. Arch Linux   → instalación 100% manual, paquetes binarios.
                  Anatomía del sistema sin esperar compilaciones.
                  ~40% del aprendizaje de LFS en ~5% del tiempo.
                  La Arch Wiki: mejor documentación de Linux que existe.

2. Gentoo       → todo desde fuente con orquestador (Portage, USE flags).
                  "LFS con andamios". Desde 2023 hay binarios oficiales
                  para los mastodontes (Firefox, LibreOffice).

3. LFS          → sin gestor de paquetes, el libro y tú. Jefe final.
```

Slackware: venerable, pero enseña más "administración Unix de los 90" y
estoicismo que construcción de sistemas. No es peldaño necesario.

**Dato genealógico**: Portage de Gentoo se inspiró explícitamente en el
sistema de Ports de FreeBSD. La familia completa: FreeBSD Ports →
Gentoo Portage, Arch ABS/PKGBUILD, NetBSD pkgsrc, Homebrew (macOS).
El "paquete" como receta (Makefile/ebuild) en vez de binario.

## 3. Los BSD y otros Unix libres: qué aporta cada uno

| Sistema | Aprendizaje único | Prioridad |
|---|---|---|
| **FreeBSD** | Sistema base coherente (kernel+libc+userland = un proyecto), **jails** (contenedores pre-Docker → conecta con el tutorial), ZFS de primera clase + boot environments, Ports, el Handbook | 🥇 Partición real |
| **OpenBSD** | Seguridad como criterio de diseño (pledge/unveil, W^X), cuna de OpenSSH/LibreSSL/tmux/pf. Man pages impecables. Liviano: ideal para hardware viejo | 🥈 Partición real (perfecto para la Yoga) |
| **NetBSD** | Portabilidad como religión (~50 arquitecturas), pkgsrc | 🥉 VM |
| **illumos/OmniOS** | Cuna original de ZFS, **DTrace** y Zones. Observabilidad a nivel que Linux alcanzó recién con eBPF | VM |
| **DragonFly BSD** | HAMMER2, kernel híbrido. Nicho: solo si interesa diseño de kernels | VM curiosa |
| **Haiku** | No es Unix (BeOS renacido); coherencia de diseño. Puro postre | Tarde libre |
| **Minix 3** | Microkernel de Tanenbaum; valor histórico. (Corre dentro del Intel ME de tu laptop sin que lo sepas 😄) | Visita cultural |

El premio del recorrido completo: ver **cuatro filosofías de construir un
Unix** — catedral coherente (BSD), bazar ensamblado (Linux), fortaleza
minimalista (OpenBSD), ingeniería corporativa liberada (Solaris/illumos).
Dejas de pensar "así funciona un OS" y piensas "así *decidieron* que funcionara".

## 4. ETAPA 1 — La Yoga 11e: casi-tablet de lectura + banco de cacharreo

**Hardware**: Lenovo Yoga 11e (~2017), Celeron/Pentium ~Braswell, 4 GB RAM,
SSD 512 GB. Verificar antes: variante táctil o no; quirks Bay Trail
(posible UEFI 32-bit con CPU 64-bit; errata cstates → `intel_idle.max_cstate=1`).

**Caso de uso**: lectura (PDF/DjVu/EPUB/DVI), notas Markdown, navegador de
una pestaña, laboratorio Linux. Es el caso de uso *perfecto* para 4 GB.

**Stack recomendado**:
- Entorno: **Sway** (Wayland, ultraligero, configurarlo es aprender).
  GNOME solo si hay táctil y se acepta que 4 GB van justos. XFCE como plan B aburrido.
- Lector: **Zathura** (vim-style; plugins para PDF/DjVu/EPUB; DVI vía xdvi
  de TeX Live). Alternativa bonita para EPUB: Foliate.
- Notas MD: **Neovim + glow** (preview terminal) o Marker/Apostrophe (GTK).
  ⚠️ Evitar Obsidian/Logseq en esta máquina: son Electron (un Chrome cada una).
  Las notas como archivos .md planos en git → compatibles con Obsidian en
  otras máquinas.
- **zram** (swap comprimido en RAM): dos líneas de systemd, salva los 4 GB.

**Menú de cacharreo (en orden)**:
1. La instalación Arch misma (particionado, chroot, fstab, bootloader, red).
2. **Compilar kernel propio** para esa máquina: `make menuconfig`, quitar todo
   lo que el hardware no tiene, entrada GRUB separada (riesgo cero).
3. **Módulos de kernel**: hello world en kernel space → /proc → char device.
4. **Contenedores desde los cimientos** (conecta con el tutorial Docker):
   construir un "contenedor" sin Docker con `unshare` (namespaces),
   cgroups v2 a mano, `pivot_root`, capabilities. El ejercicio célebre:
   "Docker en ~100 líneas de bash/Go". Docker deja de ser magia para siempre.
5. **Shell propio tipo Tanenbaum** en C: parsing, fork/exec/wait, pipes
   (pipe/dup2), redirecciones, señales, job control. EL ejercicio clásico.

Ese menú = un semestre de SO autodidacta con hardware de gaveta.

## 5. ETAPA 2 — Internals de SO: xv6 en vez de Minix

**Recomendación central**: para *ejercicios prácticos*, **xv6 (MIT)** supera
a Minix en 2026:
- Unix v6 reescrito en C moderno para RISC-V, ~10.000 líneas (se lee entero
  en un fin de semana).
- Los **labs públicos del curso 6.1810 de MIT** son exactamente los ejercicios
  buscados: añadir syscalls, lazy allocation, copy-on-write fork,
  **modificar el planificador** (RR → prioridades/lottery),
  **extender el filesystem** (archivos grandes, symlinks), traps, VM.
- Tests automáticos por lab. Corre con `make qemu` en cualquier máquina.

**Ruta**:
- Libro guía: **OSTEP** (Operating Systems: Three Easy Pieces, gratuito online).
- Práctica: labs de xv6 en orden.
- Minix: visita cultural de una tarde (arquitectura microkernel, contraste).
- Graduación: tocar Linux real — un filesystem simple sobre VFS ("simplefs"),
  o tweak al scheduler EEVDF y medir.

**Cronograma realista**: Arch+lectora = 1 fin de semana; cacharreo = semanas
a ritmo propio; xv6+OSTEP = 2-4 meses a ratos. Compatible con el tutorial Docker.

## 6. ETAPA 3 — Armar PC + multiboot (desmitificar hardware)

La simetría: LFS = "arma tu OS desde piezas"; armar PC = "arma tu hardware
desde piezas". Hoy es LEGO con tornillos; el miedo dura hasta el primer POST.

**Presupuesto ~300 USD, dos rutas**:

Ruta A (recomendada) — armar con piezas usadas/mixtas:
```text
Ryzen 5 3600 (6C/12T) usado        ~60-80 USD
Board B450 usada                    ~45-60
16-32 GB DDR4 usada                 ~30-50
NVMe 500GB-1TB nuevo                ~35-50
PSU 450-550W NUEVA de marca         ~40-50   ← única pieza donde NO ahorrar
Caja usada/genérica                 ~20-30
GPU: Ryzen 3000 no trae video → 5600G/4600G (APU) o GPU vieja de 20-30
```
12 hilos que compilan Gentoo world de noche y LFS en una tarde.

Ruta B — ex-corporativo SFF (OptiPlex/EliteDesk/ThinkCentre):
~120-160 USD el equipo (i5-9500 6C) + RAM + NVMe = ~210-250 total.
Ventaja oculta: hardware Intel vanilla = **el mejor soportado en
FreeBSD/OpenBSD/NetBSD del planeta**. Cero drama de drivers.
Desventaja: no armas nada y tiene techo de expansión.

**Multiboot en el desktop**: Gentoo + LFS + FreeBSD (+ OpenBSD) en 512 GB+.
EFI compartida; el arranque triple con el bootloader de FreeBSD conviviendo
con GRUB es una lección de bootloaders en sí misma.

## 7. ETAPA 4 (futura) — NAS casero, no "SAN"

**Corrección de vocabulario**: lo que se quiere (Synology casero: archivos +
streaming personal) es un **NAS** (sirve archivos por SMB/NFS), no una SAN
(bloques crudos por iSCSI/FC, cosa de datacenter). Ahorra confusión al buscar docs.

**Plan en dos tiempos (filosofía correcta del proyecto)**:
1. Versión "a mano" sobre Gentoo: ZFS/mdadm + Samba/NFS + Jellyfin compilados
   y configurados manualmente → el aprendizaje.
2. Versión estable en partición/disco aparte con Debian (o directamente
   FreeBSD+ZFS, que para NAS es de primera clase) → la operación.

## 8. La flota completa

```text
XPS 15 2022 (i7-12700H, 20 hilos, 64 GB)
  → Personal Windows 11. Apoyo: VMs de ensayo (Hyper-V o VMware
    Workstation Pro, gratis desde 2024; VirtualBox con Hyper-V
    activo corre degradado), binhost/distcc para rescatar a la Yoga.

Yoga 11e (4 GB)
  → Arch a mano; lectora + banco de cacharreo (Etapa 1).
    Si algún día muere: fue una gaveta bien aprovechada.
    Candidata natural también a OpenBSD (liviano, corre en todo).

Inspiron 7559 (i7-6700HQ = 4C/8T reales, no 8 núcleos)
  → Si la reparación (batería + jack DC, ~40-80 USD) es viable:
    laboratorio portátil. RAM DDR3L barata hasta 32 GB.
    Hardware Dell de esa era = BSD-friendly.
    Si la placa tiene daño en circuito de carga: no vale el rabbit hole
    (salvo que ESE rabbit hole también llame 😄).

Desktop armado (Etapa 3)
  → Estación principal: Gentoo, LFS, FreeBSD, OpenBSD, binhost,
    futuro NAS. Infinitamente expandible.
```

**Decisión sobre comprar laptop Acer i3 10ª/11ª usada (~300 USD)**: no por
ahora. Un i3-10110U apenas supera al 6700HQ; el dinero rinde más como
reparación de la 7559 + RAM + SSD (~120 USD total) o como piezas del desktop.
Solo tiene sentido si la Dell resulta irreparable.
