#!/usr/bin/env python3
"""Corrige en el curso lo que la prueba de kind con Rosetta contradijo (salidas/kind-rosetta.log,
salidas/kind-node-x64.log). Cada par aparece exactamente una vez. Uso: python3 -I corregir-curso.py <curso>
"""
import os
import sys

C = sys.argv[1]
E = {
"14-casi-prod-kind.md": [
("así que la imagen tiene que construirse para esa misma arquitectura: el **Apéndice A13 §7** explica cómo se elige al construir y el **§1** cómo se decide el perfil.",
 "así que conviene construir la imagen para esa misma arquitectura: el **Apéndice A13 §7** explica cómo se elige al construir y el **§1** cómo se decide la arquitectura."),
("""> ⚠️ **Apple Silicon.** kind corre el nodo sobre tu mismo runtime, así que el nodo es de la arquitectura de tu máquina. Si construiste la imagen para `amd64` estando en un Mac con chip M —o al revés—, el pod arranca, muere al instante y queda en `CrashLoopBackOff`, y el mensaje que vas a encontrar en los logs es `exec format error`, que no menciona la palabra "arquitectura" por ningún lado. Construye en nativo o revisa el **Apéndice A13 (Docker + Colima en Apple Silicon)**;""",
"""> ⚠️ **Apple Silicon.** kind corre el nodo sobre tu mismo runtime, así que el nodo es arm64, como tu máquina. Si construiste la imagen para `amd64`, **el pod arranca igual**: el kernel de la VM del runtime tiene registrado Rosetta (y QEMU) para los binarios x86, y el contenedor corre traducido, más lento y sin avisar. En la prueba del curso, con Docker Desktop 4.92.0 y `kindest/node:v1.27.3`, un pod con una imagen solo-amd64 quedó `Running`, respondió `x86_64`, y desde el nodo su proceso aparecía como `/run/rosetta/rosetta /bin/sleep`. El fallo de verdad llega en el otro sentido y en otra máquina: una imagen **arm64** construida en tu Mac que aterriza en un cluster **amd64** de la empresa, donde nadie traduce. Ahí el pod arranca, muere al instante y queda en `CrashLoopBackOff`, y el mensaje de los logs es `exec format error`, que no menciona la palabra "arquitectura" por ningún lado. Construye en nativo para kind, construye `linux/amd64` para el servidor, y revisa el **Apéndice A13 (Docker + Colima en Apple Silicon)**;"""),
],
"a09-kubernetes.md": [
("la imagen es de otra arquitectura que el nodo —el caso de Apple Silicon de la **Fase 14 §5.1**—,",
 "la imagen es de otra arquitectura que el nodo y nadie la traduce —el caso típico es una imagen arm64 construida en un Mac que llega a un cluster amd64, **Fase 14 §5.1**—,"),
],
"a12-arm64-m1.md": [
("| `exec format error` (en un contenedor o en un pod) | La imagen es de otra arquitectura que la máquina |",
 "| `exec format error` (en un contenedor o en un pod) | La imagen es de otra arquitectura que la máquina, y nadie la traduce (en tu Mac con Rosetta corre; en un servidor amd64, una imagen arm64 no) |"),
],
"a13-docker-colima.md": [
("El síntoma es que `docker run` falla con `exec format error`, o que la imagen ni siquiera se descarga porque no hay manifiesto para tu plataforma.",
 "El síntoma es que la imagen ni siquiera se descarga porque no hay manifiesto para tu plataforma, o que corre con el `WARNING` de plataforma de §7, traducida por Rosetta."),
("así que en un Mac con chip M y la VM arm64 de §3 tienes que construir **arm64**.",
 "así que en un Mac con chip M y la VM arm64 de §3 conviene construir **arm64**: una imagen amd64 también arranca en kind, traducida por Rosetta y más lenta, y eso esconde la diferencia con el servidor (**Fase 14 §5.1**)."),
("Un servidor amd64 sin emulación que recibe tu imagen arm64 no avisa: no arranca, con `exec format error`. Esa segunda mitad no se reproduce en un Mac con Rosetta, que corre las dos arquitecturas; en el servidor, la comprobación es el `docker image inspect` de arriba.",
 "Un servidor amd64 sin emulación que recibe tu imagen arm64 no avisa: no arranca, con `exec format error`. Esa segunda mitad no se reproduce en un Mac con Rosetta, que corre las dos arquitecturas —tampoco en kind: en la prueba del curso, un pod con una imagen solo-amd64 quedó `Running` en un nodo arm64—; en el servidor, la comprobación es el `docker image inspect` de arriba."),
("| `exec format error` al correr un contenedor | La imagen es de otra arquitectura que la VM | §7, y **Fase 14 §5.1** |",
 "| `exec format error` al correr un contenedor | La imagen es de otra arquitectura que la máquina, y nadie la traduce | §7, y **Fase 14 §5.1** |"),
("| El pod de kind muere al instante | La imagen no coincide con la arquitectura del nodo | §7, **Fase 14 §5.1** |",
 "| Un pod del cluster de la empresa muere con `exec format error` | Le llegó una imagen arm64 construida en un Mac; en tu kind corría, traducida | §7, **Fase 14 §5.1** |"),
("""- **kind con Rosetta en la VM, sin verificar.** La ⚠️ de la **Fase 14 §5.1** dice que un pod con una imagen de otra arquitectura muere con `exec format error`. Con Rosetta encendida en la VM (§3), un contenedor amd64 corre traducido (§7), y no está comprobado si un pod de kind hereda esa traducción o sigue muriendo. Quien lo pruebe confirma o corrige esa ⚠️ → ejercicio de la **Fase 14** o corrección de su §5.1.
""", ""),
],
"forense-fase-14.md": [
("| Un pod que muere sin logs, en un Mac con chip M | casi siempre una imagen amd64 | [**A12**](./a12-arm64-m1.md) §6 |",
 "| Un pod que muere con `exec format error` en el cluster de la empresa | una imagen arm64 construida en un Mac con chip M | [**A13**](./a13-docker-colima.md) §7 |"),
],
"forense-master.md": [
("| `node-sass` que no compila, o un contenedor que muere sin decir nada en un Mac con chip M |",
 "| `node-sass` que no compila en un Mac con chip M, o un pod que muere con `exec format error` tras construir la imagen en uno |"),
],
}
for f, pares in E.items():
    p = os.path.join(C, f)
    t = open(p, encoding="utf-8").read()
    for i, (a, b) in enumerate(pares, 1):
        n = t.count(a)
        if n != 1:
            sys.exit(f"{f} edición {i}: aparece {n} veces")
        t = t.replace(a, b)
    open(p, "w", encoding="utf-8").write(t)
    print(f"{f}: {len(pares)}")
