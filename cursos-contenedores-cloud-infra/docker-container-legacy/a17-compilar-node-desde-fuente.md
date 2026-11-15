# 🔩 Apéndice a17 — Compilar Node desde fuente

> **Curso:** Docker Legacy Node · **Apéndice opcional**
> **Cierra los bucles de:** [a02](a02-estrategia-node-y-clis.md) §3 · [F06](06-instalacion-node.md) §3 · [F14](14-abi-libc-y-prebuilds.md) §6 · [a03](a03-binutils-y-elf.md) §3
> **Requisitos:** F04 (el toolchain), F14 (ABI y glibc) y [a07](a07-colima-y-lima.md) (Lima)
> **Fecha de verificación ejecutada:** 14 de noviembre de 2026 — las dos compilaciones completas de §5, con sus fallos, en VM de Lima 2.3.0 sobre un MacBook Pro M1 Pro (8 núcleos, 32 GB, macOS 26.7.2): Node 14.21.3 en Debian 11 y Node 26.13.1 en Debian 13, las dos `arm64` nativas. **No se midió en `amd64` ni en Windows con WSL2**
> **Código de este apéndice:** [`src/a17-compilar-node-desde-fuente/`](src/a17-compilar-node-desde-fuente/)
> **Qué encontrarás:** qué pasa de verdad cuando compilas Node 14 y Node actual en la misma máquina, con los minutos, el pico de memoria y los cuatro fallos literales que salieron por el camino

[a02](a02-estrategia-node-y-clis.md) §3 dice que compilar Node desde fuente es la peor opción de las cinco para este
laboratorio, y lo sigue siendo. Este apéndice no es una vía de escape: **`node-v14.21.3-linux-arm64.tar.xz`
existe** en `nodejs.org/dist`, y el que no existe es `darwin-arm64`, que se resuelve con el
contenedor desde [F00](00-problema-y-contrato.md). Es un ejercicio de comprensión: ver por dentro qué te ahorra el
tarball oficial, y medirlo.

---

## 🧭 Índice de salto rápido

| Si tu pregunta es… | Ve a |
|---|---|
| "¿Por qué dos VM y no una?" | [§1](#1--dos-eras-dos-distribuciones) |
| "¿Cómo levanto las VM?" | [§2](#2-️-las-dos-vm-con-lima) |
| "`apt-get` me da 404 en bullseye" | [§3](#3-️-bullseye-ya-es-arqueología) |
| "¿Qué comando corro?" | [§4](#4--el-guion) |
| "¿Cuánto tarda y cuánta RAM pide?" | [§5](#5--los-números) |
| "Se murió `cc1plus` y no sé por qué" | [§6](#6--el-oom-que-no-dice-que-es-oom) |
| "`ccache` no me ahorró nada" | [§7](#7--ccache-y-la-trampa-de-ccache_disable) |
| "¿Qué binario me salió?" | [§8](#8--cerrar-el-bucle-con-a03) |

---

## 1. 🏺 Dos eras, dos distribuciones

La idea bonita era "misma VM, mismo comando, dos eras". No se puede, y el motivo es el
contenido del apéndice: **lo que Node exige de su toolchain y lo que la distro empaqueta se
mueven a ritmos distintos**.

| | Node 14.21.3 (2023) | Node 26.13.1 LTS (2026) |
|---|---|---|
| Distro | **Debian 11 bullseye** | **Debian 13 trixie** |
| GCC | 10.2.1 | 14.2.0 |
| glibc | 2.31 | 2.41 |
| Python | 3.9.2 | 3.13.5 |
| OpenSSL del sistema | 1.1.1w | 3.5.7 |
| Por qué esta distro | la de su época, con OpenSSL 1.1.1 | su `BUILDING.md` pide GCC 13.2 o más, y bookworm trae GCC 12 |

**Debian 12 bookworm no sirve para Node 26**: su GCC 12 no llega al mínimo que declara el
`BUILDING.md`. Para Node 14 se eligió bullseye por ser la distro de su época, no porque bookworm
fallara: no se probó, y con la OpenSSL vendorizada de §4 la del sistema ni siquiera interviene.
Lo que se mantiene constante es el hardware, la herramienta de VM y el guion; lo que cambia, la
distro, cambia porque tuvo que cambiar.

> 🧠 **Tu instinto dice que Node 14 necesita Python 2… y esta vez se equivoca.** Es lo que se
> repite en los foros, y era cierto en las versiones más viejas. El `configure` de Node 14.21.3
> encontró **Python 3.9.2** y siguió sin quejarse; bullseye ni siquiera trae `python2` instalado.
> El último Node 14 ya no depende de Python 2 para compilar.

Dos distros que **no**: Alpine, porque compilar contra `musl` es otro experimento y mezclaría dos
variables ([F14](14-abi-libc-y-prebuilds.md) §6); y Buster, el baseline del curso, que como sistema de una VM añadiría
todavía más arqueología de la que ya trajo bullseye (§3).

---

## 2. 🖥️ Las dos VM, con Lima

[a07](a07-colima-y-lima.md) presenta Lima. Aquí se usa a secas, sin Colima: solo hace falta una VM Linux con un
compilador. Los cuatro parámetros se fijan **al crear**, porque cambiarlos después exige recrear:

```bash
limactl start --tty=false --name=p6-node26 --cpus=8 --memory=12 --disk=60 \
    --vm-type=vz template:debian-13

limactl start --tty=false --name=p6-node14 --cpus=8 --memory=12 --disk=60 \
    --vm-type=qemu template:debian-11
```

`cpus` es el `-j` de tu `make` y tiene que ser igual en las dos para que los minutos se
comparen. `memory` decide si V8 cabe (§6). `disk` de 60 GiB sobra: el árbol de Node 26 compilado
ocupó 1,9 GB.

**Y el `--vm-type` no es el mismo en las dos, aunque debería.** `vz`, el framework de
virtualización de Apple, es lo natural en Apple Silicon. Con la plantilla `debian-11` la VM no
llegó a arrancar:

```text
[hostagent] [VZ] - vm state change: running
level=fatal msg="did not receive an event with the `running` status"
```

Diez minutos de espera, `limactl start` con código 1, el log serie vacío y el SSH rechazando
conexiones. Lima 2.3.0 marca esa plantilla como obsoleta. Con `--vm-type=qemu` (QEMU 11.1.3
instalado con Homebrew, acelerado con el hipervisor de macOS, sin emulación) la VM arranca y
funciona, pero en dos de tres arranques `limactl start` **también** devolvió código 1, a los
601 s, esperando en el paso `Sshfs binary to be installed`; el tercero salió limpio en 45 s.
No te fíes del código de salida: comprueba con `limactl list` y `limactl shell p6-node14 uname -a`. La de trixie con `vz` arrancó limpia en 183 s.

> 📝 **QEMU aquí no emula.** La VM es `aarch64` sobre un Mac `arm64`: QEMU usa la aceleración
> por hardware de macOS, igual que `vz`. La emulación de [F21](21-arquitecturas-y-emulacion.md) §7 es otra cosa, cuando
> la arquitectura del invitado no es la del host.

---

## 3. 🗄️ Bullseye ya es arqueología

Debian 11 salió de su soporte LTS a finales de agosto de 2026. El primer `apt-get install`
del guion falló así, 23 veces:

```text
E: Failed to fetch http://security.debian.org/debian-security/pool/updates/main/g/glibc/libc6-dev_2.31-13%2bdeb11u14_arm64.deb  404  Not Found [IP: 199.232.178.132 80]
E: Unable to fetch some archives, maybe run apt-get update or try with --fix-missing?
```

El detalle traicionero: **`apt-get update` no falló**. `security.debian.org` todavía sirve el
índice de `bullseye-security`, pero los paquetes ya no están en su `pool/`; se mudaron a
`archive.debian.org`. El índice dice que el paquete existe y la descarga dice que no. Sin
`build-essential`, el guion siguió y el `configure` terminó en:

```text
ERROR: No acceptable C compiler found!
```

El arreglo es el mismo `sed` que [F03](03-apt-y-utilidades.md) enseña para Buster, solo sobre la línea de seguridad:

```bash
sudo sed -i 's#http://security.debian.org/debian-security#http://archive.debian.org/debian-security#' \
    /etc/apt/sources.list
sudo apt-get update
```

Y una más, menor: la imagen cloud de Debian **no trae `/usr/bin/time`**, en ninguna de las dos
versiones. Sin él no hay pico de memoria; el guion lo instala (paquete `time`).

---

## 4. 📜 El guion

El mismo en las dos VM: [`src/a17-compilar-node-desde-fuente/compilar-node.sh`](src/a17-compilar-node-desde-fuente/compilar-node.sh). Lo esencial:

```bash
./configure --prefix="$HOME/opt/node-${NODE_VERSION}" --with-intl=small-icu

export CCACHE_DIR=$HOME/.ccache
/usr/bin/time -v make -j"$JOBS" CC="ccache gcc" CXX="ccache g++"   # make-1, caché fría
make clean
/usr/bin/time -v make -j"$JOBS" CC="ccache gcc" CXX="ccache g++"   # make-2, caché caliente
make install
```

Tres decisiones, y las tres cambian lo que se mide:

- **`--with-intl=small-icu` en las dos**, aunque Node 26 traiga otro valor por defecto. Con
  banderas distintas comparas compilaciones distintas.
- **OpenSSL vendorizada**, sin `--shared-openssl`. Node trae su propia copia en `deps/openssl`, y
  compilar con ella desacopla la compilación de la OpenSSL del sistema: Node 14 sale con la
  1.1.1t y Node 26 con la 3.5.9, tenga la distro la que tenga.
- **`ccache` desde la primera pasada.** Si la primera no pasa por `ccache`, la segunda no tiene
  nada que reutilizar. §7 cuenta qué pasa si lo olvidas, porque pasó.

`/usr/bin/time -v` imprime al final la línea que nadie publica: `Maximum resident set size`, el
pico del proceso hijo más grande. Es la cifra que decide si esto cabe en tu VM.

---

## 5. 📊 Los números

Misma máquina, mismos 8 núcleos y 12 GiB por VM, sin swap.

| | Node 14.21.3 · bullseye · `qemu` | Node 26.13.1 · trixie · `vz` |
|---|---:|---:|
| Fuentes descomprimidas | 340 MB | 762 MB |
| Avisos del `configure` | ninguno | 3: sin `cargo` ni `rustc`, Temporal desactivado |
| Compilaciones de C y C++ | 2.884 | 4.742 |
| `make -j8`, caché fría | **10 min 37 s** (771 % de CPU) | ❌ OOM a los 14 min 35 s |
| `make -j5`, sin caché | — | **1 h 12 min 48 s** (495 % de CPU) |
| Tiempo de CPU total | ~82 min | ~360 min |
| Pico de memoria de un proceso | 0,94 GiB | 2,6 GiB |
| `make`, caché caliente | **23 s** (98,6 % de aciertos) | **43 s** (100 % de aciertos) |
| Binario `bin/node` | 48 MB (39 MB con `strip`) | 105 MB (85 MB con `strip`) |

La fila que compara de verdad es la del tiempo de CPU, porque las dos compilaciones no
pudieron usar el mismo `-j`: **Node 26 cuesta 4,4 veces más CPU que Node 14**, con 1,6 veces
más archivos. Cada archivo de hoy es casi tres veces más caro que uno de 2023.

> 📝 **¿Y no será que `qemu` es más lento que `vz`?** Es la objeción obvia, porque cada era corrió
> en un hipervisor distinto. La medí con el **mismo binario** en las dos VM (el Node 14 oficial,
> un bucle de 2.000 millones de iteraciones): con un solo hilo, `vz` tardó 7,2–7,5 s y `qemu`
> 7,7–9,2 s; con ocho copias en paralelo, que es lo que hace `make -j8`, las dos tardaron
> 10,3–10,8 s cada copia. El hipervisor no explica un factor de 4,4.

Lo que la tabla pone sobre la mesa sin forzarla:

- **Qué se volvió más caro.** El árbol de fuentes es más del doble, el pico de memoria por
  proceso casi el triple, y el tiempo de CPU más del cuádruple. V8 es casi todo: el tramo final
  de Node 26, los archivos `torque-generated/*-tq-csa.o`, llega a 40 s de CPU y 1,2 GB de RAM
  **por archivo**.
- **Qué no cambió.** Ninguna de las dos pidió Python 2, y ninguna peleó con la OpenSSL del
  sistema, porque las dos compilaron la suya.
- **Lo nuevo.** Node 26 quiere Rust para la API `Temporal`; sin `cargo` la compila sin ella y
  solo lo avisa. §8 muestra que eso se nota.

---

## 6. 💥 El OOM que no dice que es OOM

La primera compilación de Node 26 con `-j8` en 12 GiB murió a los 14 min 35 s con esto:

```text
g++: fatal error: Killed signal terminated program cc1plus
compilation terminated.
make[1]: *** [tools/v8_gypfiles/v8_compiler.target.mk:398: .../turboshaft/code-elimination-and-simplification-phase.o] Error 1
```

Ni una palabra sobre memoria. La pista está en el kernel, no en `make`:

```bash
sudo dmesg | grep -iE "out of memory|killed process"
```

```text
cc1plus invoked oom-killer: gfp_mask=0x140cca(GFP_HIGHUSER_MOVABLE|__GFP_COMP), order=0, oom_score_adj=0
Out of memory: Killed process 3956 (exe) total-vm:1281584kB, anon-rss:17608kB ...
Out of memory: Killed process 4115 (buildkitd) total-vm:1312500kB, anon-rss:15084kB ...
```

Y aquí está la segunda sorpresa: **las primeras víctimas no fueron el compilador.** La plantilla
de Lima arranca `containerd` y `buildkitd` dentro de la VM, con `oom_score_adj` de 200, y el
kernel mató en tres rondas: en cada una cayeron primero un proceso de `containerd`, `buildkitd` y
`containerd-shim`, que juntos no llegaban a 50 MB, y solo después un `cc1plus` de 2 GB. Si esa
VM hubiera sido tu motor de contenedores, el síntoma habría sido "Docker se cayó mientras
compilaba".

La aritmética explica el resto. Ocho trabajos en paralelo por unos 2 GB en el pico son 16 GB, y
la VM tenía 12 GiB sin swap. Con `-j5` el pico medido de un proceso fue 2,6 GiB, a mitad de camino
la VM tenía 6 GiB disponibles, y la compilación terminó.

> 🧭 **La regla práctica.** Para el Node actual, planifica **unos 2,5 GB por trabajo en
> paralelo**: `-j` = (RAM de la VM − 2 GB) / 2,5. Con 12 GiB salen 4 o 5; para `-j8` hacen falta
> 20 GiB. Node 14 cupo con `-j8` en 12 GiB y un pico de 0,94 GiB: esa es la diferencia entre las dos eras.

---

## 7. 🧠 `ccache`, y la trampa de `CCACHE_DISABLE`

`ccache` guarda el resultado de cada compilación indexado por el hash de su entrada: fuente
preprocesada, banderas y compilador. Si la entrada no cambió, devuelve el `.o` guardado sin
llamar a `cc1plus`.

Funciona. Tras el OOM de §6, la segunda pasada de Node 26 en caliente reutilizó 3.380 de 3.394
compilaciones (99,59 %) y llegó al mismo punto en **2 min 26 s** en lugar de 14 min 35 s.

Y aquí está el fallo que cometí, para que no lo repitas. Para medir una primera pasada "pura",
la corrí con `CCACHE_DISABLE=1`. Luego la pasada "en caliente" tardó **59 min 51 s** con solo un
76 % de aciertos. El motivo: `CCACHE_DISABLE` no solo desactiva la lectura de la caché, **también
desactiva la escritura**. Los 1.137 fallos fueron justo los archivos que nunca habían pasado por
`ccache` —los que vinieron después del OOM—, y eran los más caros de todo V8: el 24 % de las
compilaciones se llevó unos 57 de los 60 minutos.

Con la caché por fin completa, la tercera pasada tardó **43 s**, con 4.742 aciertos de 4.742.
Node 14, que sí usó `ccache` desde la primera pasada, bajó de 10 min 37 s a 23 s a la primera.

> ⚠️ **El síntoma es "ccache no ahorra nada", y `ccache -s` lo explica.** Mira la proporción de
> *misses*: si es alta en una segunda pasada, la primera no escribió. Las causas habituales son
> `CCACHE_DISABLE`, otro `CCACHE_DIR`, o banderas que cambian entre pasadas (un `-j` no cuenta;
> un `CFLAGS` distinto sí).

---

## 8. 🔬 Cerrar el bucle con a03

Las herramientas de [a03](a03-binutils-y-elf.md) §3 sobre los dos binarios recién salidos, y sobre los oficiales de
`nodejs.org/dist` para `linux-arm64`, descargados en la misma VM:

| | Node 14 compilado | Node 14 oficial | Node 26 compilado | Node 26 oficial |
|---|---|---|---|---|
| `file` | `pie executable` | `executable` | `pie executable` | `executable` |
| Tamaño | 48 MB | 71 MB | 105 MB | 144 MB |
| `GLIBC_` más alta (`readelf -V`) | **2.29** | 2.17 | **2.38** | 2.28 |
| ICU | `small-icu` | completa | `small-icu` | completa |
| `typeof Temporal` | `undefined` | `undefined` | `undefined` | **`object`** |

La versión de V8, de OpenSSL y de ICU que reporta `process.versions` es idéntica entre el
compilado y el oficial de cada era. Y aun así son binarios distintos, en tres sitios que
importan.

**La glibc.** Un binario exige las versiones de los símbolos de glibc con los que se enlazó, y
esas salen de la máquina donde se compiló: nunca más nuevas que su glibc, y a menudo cerca. El
oficial de Node 14 solo pide `GLIBC_2.17`, de 2012, y corre casi en cualquier Linux; el nuestro,
compilado en bullseye, ya no arranca en el baseline del curso:

```text
$ docker run --rm --platform linux/arm64 \
    --mount type=bind,src="$PWD/bin14",dst=/n,readonly debian/eol:buster /n/node --version
/n/node: /lib/aarch64-linux-gnu/libm.so.6: version `GLIBC_2.29' not found (required by /n/node)
/n/node: /usr/lib/aarch64-linux-gnu/libstdc++.so.6: version `GLIBCXX_3.4.26' not found (required by /n/node)
```

En `debian:bookworm-slim` el mismo archivo da `v14.21.3`. Es la tesis de [F14](14-abi-libc-y-prebuilds.md) §6 vista desde el
otro lado: allí un prebuild moderno no cargaba en una distro vieja; aquí lo moderno es tu
propia VM.

**ICU.** `--with-intl=small-icu` deja solo el inglés:

```text
new Intl.DateTimeFormat("de", {month: "long"}).format(new Date(2026, 0, 1))
compilado → "January"        oficial → "Januar"
```

**Temporal.** El aviso de `cargo` del `configure` (§5) no era cosmético: el Node 26 oficial trae
`Temporal` y el nuestro no.

> 🧭 **La conclusión de la tabla.** "Misma versión" no es "mismo binario". Las banderas del
> `configure` y la máquina de compilación quedan grabadas en el resultado, y el oficial está
> construido a propósito para la glibc más vieja que pueda. Si algún día compilas para
> distribuir, compila en la distro más vieja que quieras soportar, no en la más nueva que tengas.

---

## 🧭 Guía rápida: cuándo usar qué

| Situación | Qué hacer |
|---|---|
| Necesitas Node 10–16 en Linux, `x64` o `arm64` | el tarball oficial, como [F06](06-instalacion-node.md) |
| Estás en un Mac y quieres Node 10 | el contenedor del curso: `darwin-arm64` no existe, `linux-arm64` sí |
| Quieres entender qué te ahorra el tarball | **este apéndice**, una vez |
| Una plataforma sin binario oficial (`musl` antiguo, `ppc64le` viejo, `riscv64`) | compilar, con este guion y las lecciones de §3 y §6 |
| Investigas un bug del propio runtime o aplicas un parche a V8 | compilar, con `ccache` desde la primera pasada |
| Necesitas Node actual en producción | **nunca compilarlo**: el binario oficial está firmado y lo parchean otros |

> 🧭 **El veredicto honesto.** Compilar Node 14 lo haces una vez para entender; compilar el Node
> actual no lo haces nunca, salvo que trabajes en Node. El ejercicio demuestra su propia
> inutilidad práctica, y ese es el mejor final que puede tener.

---

## ⚠️ Errores comunes

**`g++: fatal error: Killed signal terminated program cc1plus`.** Memoria. Baja el `-j` o sube la
RAM de la VM; confírmalo con `dmesg`. §6.

**`apt-get install` da 404 en bullseye, pero `apt-get update` funcionó.** El índice
sigue en `security.debian.org` y los paquetes se mudaron a `archive.debian.org`. §3.

**`ERROR: No acceptable C compiler found!`** No hay `gcc`: casi siempre, porque un `apt-get`
anterior falló y nadie lo leyó. Sube por el log.

**`/usr/bin/time: No such file or directory`.** La imagen cloud no lo trae: `apt-get install time`.

**La VM de `debian-11` no arranca con `vz`.** Usa `--vm-type=qemu`. §2.

**La segunda pasada no es más rápida.** La primera no escribió en `ccache`. §7.

---

## 🧪 Ejercicios (6)

### 🟢 Ejercicio 1 — Comprueba que no lo necesitas

Lista `https://nodejs.org/dist/v14.21.3/` y verifica el SHA-256 del tarball `linux-arm64` con el
procedimiento de [a04](a04-checksums-gpg-y-archivos.md).

**Criterio de éxito:** `sha256sum -c` dice `OK`, y puedes explicar en una frase por qué existe el
`linux-arm64` y no el `darwin-arm64` de Node 10.

### 🟢 Ejercicio 2 — Lee el `configure`

En el árbol de Node 14, ejecuta `./configure --help | grep -E "shared-|with-intl"`.

**Criterio de éxito:** una lista de las dependencias que Node trae vendorizadas en `deps/` y la
bandera que cambiaría cada una por la del sistema.

### 🟡 Ejercicio 3 — Provoca el OOM

Crea una VM de trixie con `--memory=6` y compila Node 26 con `-j"$(nproc)"`.

**Criterio de éxito:** capturas la línea `Killed signal terminated program cc1plus` **y** la línea
`Out of memory: Killed process` de `dmesg`, y nombras los procesos que murieron antes que el
compilador.

### 🟡 Ejercicio 4 — La trampa de `ccache`, a propósito

Compila un proyecto C pequeño (el `hello.c` de [F04](04-toolchain-de-compilacion.md) §7 sirve) tres veces: con
`CCACHE_DISABLE=1`, sin él, y sin él otra vez. Ejecuta `ccache -s` después de cada una.

**Criterio de éxito:** una tabla con aciertos y fallos de las tres pasadas que demuestre que la
primera no escribió nada.

### 🟠 Ejercicio 5 — Dónde arranca tu Node 26

§8 dice que tu Node 26 compilado exige `GLIBC_2.38` y el oficial `GLIBC_2.28`. Antes de ejecutar
nada, predice en cuáles de estos arranca cada uno: `debian/eol:buster`, `debian:bullseye`,
`debian:bookworm` y `debian:trixie`. Usa `ldd --version` dentro de cada imagen para saber qué
glibc trae.

**Criterio de éxito:** una tabla de 2 × 4 con tu predicción, y la misma tabla confirmada
montando cada binario en cada contenedor con `--platform linux/arm64`. Si una casilla no
coincide, explica por qué.

### 🔴 Ejercicio 6 — El multi-stage que no debería funcionar

Escribe un Dockerfile con una etapa `debian:bullseye` que compile Node 14 con este guion y una
etapa final `debian/eol:buster` que copie solo `/opt/node-14.21.3`.

**Criterio de éxito:** el build termina, `node --version` en la imagen final da un resultado que
sabes explicar con [F14](14-abi-libc-y-prebuilds.md) §6, y propones el cambio de una línea que lo arreglaría.

---

## 📚 Referencias

- Node.js, `BUILDING.md` (requisitos de compilación por versión): https://github.com/nodejs/node/blob/main/BUILDING.md
- Node.js, distribuciones oficiales: https://nodejs.org/dist/
- Lima: https://lima-vm.io
- ccache, manual: https://ccache.dev/manual/latest.html
- Debian, archivo de versiones retiradas: https://archive.debian.org
- Debian LTS: https://wiki.debian.org/LTS
- Linux, OOM killer: https://www.kernel.org/doc/gorman/html/understand/understand016.html

> ⚠️ **Los números son de una máquina.** Un M1 Pro con 6 núcleos de rendimiento y 2 de
> eficiencia, dentro de una VM. En otra máquina los minutos cambian; la forma del resultado —el
> pico de memoria por trabajo, la proporción entre las dos eras y lo que ahorra `ccache`— es lo
> que se traslada. Enlaces revisados el 14 de noviembre de 2026.

**Vuelve a:** [a02 §3](a02-estrategia-node-y-clis.md) · [F06 §3](06-instalacion-node.md) · [a07](a07-colima-y-lima.md)
