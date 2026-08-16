# ⚠️ ERRATA IMPORTANTE: Rosetta NO desaparece para contenedores Linux

> **Lee esto ANTES de tomar decisiones basadas en los documentos 02, 06 y 07.**
> Esos documentos afirman que "Rosetta desaparece totalmente en macOS 28" y que por eso
> es urgente migrar a arm64 nativo antes de 2027. **Esa afirmación es incorrecta para
> el caso de uso de contenedores Docker `linux/amd64`.** Verificado en documentación
> oficial de Apple (Virtualization framework).

---

## 1. Lo que se afirmó (incorrecto)

En documentos anteriores de este proyecto se dijo:

> "Rosetta desaparece totalmente en macOS 28, salvo un subset para juegos.
> No queda ninguna capa de emulación. Docker amd64 dejará de funcionar."

Esto colapsaba **dos tecnologías distintas** bajo el nombre "Rosetta".

## 2. La realidad (verificada en Apple Developer Documentation)

Apple separa dos vías:

| Componente | Qué traduce | Destino confirmado |
|---|---|---|
| **Rosetta 2 para apps macOS** | Apps Intel de Mac (.app x86_64 de macOS) | ❌ Termina en macOS 28 (otoño 2027), salvo subset para juegos viejos sin mantenimiento |
| **Traducción Intel para Linux VMs** | Binarios Linux x86_64 dentro de VMs ARM (= contenedores `linux/amd64` de Docker/Colima/Podman) | ✅ **Se INTEGRA al sistema en macOS 27**, sin necesidad de instalar Rosetta |

Cita textual de la documentación oficial de Apple
("Running Intel Binaries in Linux VMs", Virtualization framework):

> "Until macOS 26, this capability was part of Rosetta [...].
> **macOS 27 directly integrates support for Intel binary translation,
> without needing to install Rosetta.**"

Y el detalle de API que lo confirma:

> "Starting in macOS 27, support for Intel binary translation for Linux apps
> is included in macOS. Testing for availability starting in macOS 27
> **always returns installed** and installRosetta **always returns immediately**."

Fuente: https://developer.apple.com/documentation/virtualization/running-intel-binaries-in-linux-vms

## 3. Qué significa para el laboratorio Docker Legacy Node

```text
Contenedor linux/amd64 en Apple Silicon:

macOS ≤ 26  →  Rosetta (instalable) o QEMU (fallback)
macOS ≥ 27  →  Traducción Intel INTEGRADA en el OS (misma tecnología,
               ya no requiere instalación) o QEMU (fallback)
```

Consecuencias directas:

1. **El baseline `linux/amd64` con `debian/eol:buster` es sostenible.**
   No hay fecha de muerte para la vía amd64 en Mac. La urgencia de
   "migra a arm64 nativo antes de 2027 o quedas huérfano" era exagerada.

2. **Compilar arm64 nativo (Lima, compilación desde fuente) sigue valiendo** —
   pero como ejercicio educativo y optimización (Fase 14 multiplataforma),
   no como plan de supervivencia.

3. **Los benchmarks de QEMU (~10x más lento) siguen siendo válidos** para el
   fallback QEMU: macOS viejos, binarios raros que la traducción no maneje
   (JITs antiguos, Chrome viejo), y la VM x86_64 completa como "modo arqueología".

## 4. Reformulación recomendada para tutoriales

En lugar de:

> "En Apple Silicon necesitamos Rosetta" ❌

Escribir:

> "El laboratorio requiere **capacidad de ejecutar binarios Linux x86_64**,
> no Rosetta. En macOS ≤26 la provee Rosetta o QEMU; desde macOS 27, la
> traducción Intel para Linux está integrada en el sistema." ✅

## 5. Cautelas honestas que se mantienen

- **Apple no promete permanencia contractual.** Ante la pregunta directa en
  foros de Apple Developer sobre si la capacidad persistirá tras macOS 28,
  la respuesta de Apple DTS fue que no pueden dar guía más allá de la
  documentación pública — aunque el mismo ingeniero distinguió explícitamente
  que el caso Linux "is not the same use case as the Rosetta Translation
  Environment". La integración al OS en macOS 27 es la señal más fuerte
  disponible de continuidad, pero es inferencia razonable, no contrato.

- **Los runtimes tienen que adaptarse.** Docker Desktop, Podman y Colima hoy
  exponen esto como "Rosetta" (`--vz-rosetta`, checkbox "Use Rosetta").
  Con macOS 27 (septiembre 2026) tendrán que actualizar detección y
  terminología. Es fricción de tooling, no de arquitectura.

- **Checklist post-upgrade a macOS 27**: verificar que la versión instalada
  de Colima/Docker/Podman detecta la traducción integrada, y que
  `docker run --platform linux/amd64 debian:buster uname -m` devuelve
  `x86_64` con rendimiento tipo-Rosetta (segundos en npm ci) y no
  tipo-QEMU (minutos).

## 6. Tabla de sostenibilidad corregida

| Escenario | Sostenibilidad | Riesgo principal |
|---|---|---|
| Linux/Windows x86_64 nativo | 🟢 Muy alta | Ninguno por arquitectura |
| Mac + macOS 27+ (traducción integrada) | 🟢 Alta | Adopción por Docker/Podman/Colima |
| Mac ≤ macOS 26 + Rosetta | 🟢 Alta | Dependencia temporal de Rosetta |
| Mac + QEMU puro | 🟠 Media | Rendimiento 10x, inotify, crashes |
| arm64 nativo con proyecto legacy | 🟠 Variable | Dependencias históricas sin arm64 |

---

**Moraleja del proyecto:** verificar en fuente primaria antes de declarar
muerta una tecnología. Este documento existe porque una afirmación con
mucha confianza resultó estar equivocada en el matiz que más importaba.
