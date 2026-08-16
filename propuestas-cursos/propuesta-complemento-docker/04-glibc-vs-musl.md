# glibc vs musl: Comparativa técnica y compatibilidad

## Resumen ejecutivo

**glibc** es la librería C estándar de facto en Linux desktop/servidores. **musl** es una alternativa minimalista, segura y autocontenida. La elección define si "todo funciona" o necesitas compilar desde fuente.

---

## glibc (GNU C Library)

### Ventajas
- **Compatibilidad máxima**: 99% del software Linux se desarrolla/prueba contra glibc.
- **Rendimiento superior**: funciones optimizadas (memcpy, malloc) con variantes específicas por CPU.
- **Extensiones GNU completas**: `gethostbyname_r`, comportamiento extendido de printf, NSS (Name Service Switch).
- **NSS robusto**: resolución flexible de nombres (LDAP, mDNS, systemd-resolved, sssd).
- **Soporte de locales/i18n**: internacionalización y LC_* completos.
- **Binarios propietarios**: drivers NVIDIA, Steam, Chrome, software comercial asumen glibc.

### Desventajas
- **Tamaño**: varios MB, múltiples archivos, pesada para contenedores.
- **Complejidad**: código intrincado, superficie grande de bugs de seguridad históricamente.
- **Enlace estático problemático**: NSS requiere dlopen dinámico, no se recomienda linking estático oficial.
- **Curva de compilación**: más dependencias, más complejidades en cross-compile.

---

## musl

### Ventajas
- **Tamaño mínimo**: ~1 MB, ideal contenedores e incrustados.
- **Código legible**: limpio, auditable, excelente reputación de seguridad.
- **Enlace estático perfecto**: binarios verdaderamente portables y autocontenidos (Go, Rust lo prefieren).
- **Cumplimiento POSIX estricto**: comportamiento predecible, pocos GNU-ismos.
- **Determinista**: malloc simple, sin sorpresas de NSS.

### Desventajas
- **Compatibilidad limitada**: software que asume GNU-extensions falla o requiere parches.
- **Rendimiento menor**: malloc bajo alta concurrencia, funciones de string menos optimizadas.
- **DNS históricamente quebrado**: antes de musl 1.2.4 fallaba con respuestas DNS grandes (el bug clásico de Alpine+Kubernetes).
- **Sin NSS**: no integra con LDAP/sssd/autenticación empresarial.
- **Locales ausentes**: i18n mínimo, problemas con LC_*.
- **Binarios precompilados para glibc**: incompatibles directamente (`gcompat` como parche parcial).

---

## Distros por libc

### Basadas en glibc
- Debian, Ubuntu, Linux Mint, Pop!_OS
- Fedora, RHEL, CentOS, Rocky, Alma Linux
- Arch Linux, Manjaro
- openSUSE
- Amazon Linux, Oracle Linux
- Gentoo (default)

### Basadas en musl
- **Alpine Linux** (la más popular)
- Void Linux (variante musl; también existe en glibc)
- postmarketOS
- OpenWrt (default)
- Chimera Linux
- Adélie Linux

---

## Problemas de compatibilidad glibc ↔ musl

### Cuando usas musl (los errores reales)

**1. Binarios precompilados no funcionan**
- Ejecutables `.elf` enlazados dinámicamente contra glibc fallan en musl: `cannot find libc.musl-x86_64.so.1` o crash silencioso.
- Wheels Python viejo (pre-manylinux2014) no existen para musl; `pip install` compila desde fuente (lento, requiere toolchain).
- Soluciones: compilar localmente, buscar wheels `musllinux`, o cambiar a glibc.

**2. DNS quebrado en contenedores**
- El caso histórico: Alpine en Kubernetes con respuestas DNS truncadas.
- musl consultaba en paralelo sin TCP fallback (mejorado en 1.2.4+, pero sigue siendo punto débil).
- Síntoma: timeouts aleatorios, especialmente con `search` domains o respuestas >512 bytes.

**3. GNU-ismos en fuente**
```c
// Esto FALLA en musl:
#include <execinfo.h>        // backtrace() — GNU extension
#include <error.h>           // error() — GNU extension
int r = qsort_r(...);        // GNU signature distinta de POSIX
```
- No compila o se comporta distinto.
- Solución: parchear el código o no usar musl.

**4. NSS/autenticación empresarial**
- LDAP, Active Directory (sssd), systemd-resolved no funcionan.
- Solo `/etc/resolv.conf` y `/etc/nsswitch.conf` básicos.
- En entornos corporativos, musl es no-starter.

**5. Locales**
- `LC_ALL=es_ES.UTF-8 date +%A` da nombres en inglés, no español.
- Ordenamiento distinto, formatos regionales ignorados.
- Apps que dependen de ICU o gettext necesitan configuración extra.

**6. Stack size de hilos**
- musl usa 128 KB default (glibc: 8 MB).
- Programas asumen stacks grandes → `stack overflow`.
- Pasó con Rust, Java; soluciones requieren parches o flags específicos.

### Cuando usas glibc (los errores reales)

**1. Incompatibilidad de versiones**
```bash
# Binary compilado en Ubuntu 24.04 con GLIBC 2.38
$ ./app
./app: /lib/x86_64-linux-gnu/libc.so.6: version `GLIBC_2.38' not found
# Error en Debian 11 que tiene glibc 2.31
```
- Solución: compilar en la glibc más vieja que necesites soportar, o imagen docker estable.

**2. Enlace estático impracticable**
- NSS requiere dlopen dinámico → no puedes enlazar estáticamente.
- `/etc/nsswitch.conf`, `/etc/resolv.conf` viven fuera del binario.
- Por eso Go y Rust emigraron a musl para binarios estáticos portables.

**3. Tamaño de imágenes**
- Contenedor Debian base: 100-150 MB.
- Alpine: 5-10 MB.
- (Mitiga con distroless/debian-slim, pero aun así.)

---

## Matriz de decisión rápida

| Necesidad | Elige |
|---|---|
| Binarios precompilados de 2015-2020 | glibc (era la plataforma estándar) |
| Máxima compatibilidad software | glibc |
| Entorno corporativo con LDAP/AD | glibc |
| Contenedores minimalistas | musl (Alpine) |
| Binarios estáticos portables | musl |
| Embebido/IoT | musl |
| Compilar todo desde fuente | musl (más simple, código portable) |

---

## Cross-compile glibc ↔ musl: El caso de Node.js legacy

### Prebuilts históricos (2017-2020)
Distribuidores publicaban binarios por tripla:

```
node-{version}-{platform}-{arch}
Ejemplos:
- linux-x64-glibc       ✅ existía (el 95% de casos)
- linux-x64-musl        ❌ raro, pocos maintainers lo hacían
- linux-arm64-glibc     ❌ casi ninguno (ARM era tier-2)
- linux-arm64-musl      ❌ inexistente
```

### Por qué compila-pero-falla
```bash
# En Alpine (musl) compila node-sass porque es fuente:
npm install node-sass --build-from-source
# ✅ Compila

# Pero puede fallar porque:
# 1. LibSass C++ asume glibc internals (thread_local, malloc specifics)
# 2. Herramientas de build buscan .so glibc en /lib
# 3. Resultados pueden tener references a glibc symbols
```

### Soluciones

**Opción A: Compilar todo en musl con flags**
```bash
./configure --with-libc=musl
make CC=gcc-musl  # si existe toolchain específico
```
Frágil, muchos proyectos no probaron musl.

**Opción B: Cambiar a glibc**
```dockerfile
FROM debian:buster-slim  # glibc, no Alpine
```
100% de prebuilts funcionan, compilación más robusta.

**Opción C: Compilar desde fuente con toolchain correcto**
```dockerfile
FROM alpine:3.12
RUN apk add python2 make g++ libc6-compat
RUN npm install --build-from-source
```
Funciona pero lento, frágil con código C++ legacy.

---

## Cheatsheet: Debugging compatibilidad

```bash
# ¿Qué libc está usando un binario?
ldd ./binary  # mustra si es glibc
file ./binary | grep musl  # detecta musl

# ¿Qué versión de glibc?
./binary
ldd ./binary | grep libc

# En Alpine, verificar libc6-compat (emulación parcial de glibc)
apk add libc6-compat  # parche que a veces salva prebuilts glibc

# Ver GLIBC symbols requeridos
nm -D ./binary | grep GLIBC_
```

---

## Referencias históricas importantes

- **2017-2020**: Era de oro del monolito glibc en servidores Linux.
- **2020**: Auge de Alpine Docker + Kubernetes; bugs DNS musl revelados a escala.
- **2021+**: Herramientas modernas (Go, Rust) comienzan a usar musl por defecto para binarios estáticos.
- **2024+**: glibc sigue dominando desktop/servidores; musl dominante solo en contenedores minimalistas.

---

## Conclusión para Node legacy

Para **Node 10/12/14 (2018-2020)** en contenedores:

- **Alpine + musl**: 80 MB imagen, pero compilas 90% de dependencias desde fuente, 10-20 min de build.
- **Debian + glibc**: 250 MB imagen, pero descargas prebuilts, 2-3 min de build.

Para development/tutorials geek, musl es educativo. Para producción legacy, glibc es pragmático.
