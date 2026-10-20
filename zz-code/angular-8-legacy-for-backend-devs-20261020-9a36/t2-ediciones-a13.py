#!/usr/bin/env python3
"""T1/T2: ediciones puntuales de A13 §7–§9, «Cuándo usar qué», Advertencias, Referencias, ejercicios
y pendientes. Cada par (viejo, nuevo) tiene que aparecer exactamente una vez.
Uso: python3 -I t2-ediciones-a13.py <a13-docker-colima.md>
"""
import sys

E = [
# §7
("""Para el kind de la **Fase 14**, el nodo hereda la arquitectura de tu VM, así que en un Mac con chip M y un perfil arm64 tienes que construir **arm64**. Para un servidor de la empresa, casi siempre `linux/amd64`.""",
"""Para el kind de la **Fase 14**, el nodo hereda la arquitectura de tu VM, así que en un Mac con chip M y la VM arm64 de §3 tienes que construir **arm64**. Para un servidor de la empresa, casi siempre `linux/amd64`.

**Lo que ves en tu Mac no es lo que ve el servidor.** Con Rosetta encendida en la VM, si corres una imagen amd64 sin `--platform`, Docker avisa y la corre igual, traducida:

```text
WARNING: The requested image's platform (linux/amd64) does not match the detected host platform (linux/arm64/v8) and no specific platform was requested
```

Un servidor amd64 sin emulación que recibe tu imagen arm64 no avisa: no arranca, con `exec format error`. Esa segunda mitad no se reproduce en un Mac con Rosetta, que corre las dos arquitecturas; en el servidor, la comprobación es el `docker image inspect` de arriba."""),
# §8
("""```bash
# Los perfiles de Colima, y cual esta corriendo.
colima list

# Apagar uno sin destruirlo (conserva imágenes y volúmenes).
colima stop --profile amd64

# Destruirlo de verdad, con todo lo que tenia dentro. Esto SI borra.
colima delete --profile amd64
```""",
"""```bash
# Los perfiles de Colima, y cuál está corriendo.
colima list

# Apagar sin destruir (conserva imágenes y volúmenes). Sin -p es el perfil
# 'default'; con -p <nombre>, el que creaste aparte (§3).
colima stop

# Borrar la VM y su configuración. En la 0.10.3, el disco con las imágenes
# y los volúmenes se conserva para el próximo start con ese nombre.
colima delete

# Borrar también ese disco. Esto SÍ borra todo.
colima delete --data
```

En la prueba del curso, después de un `colima delete` quedaron 1,5 GB en `~/.colima/_lima/_disks/`, y se fueron con `colima delete --data`."""),
("""**Y antes de `colima delete`, mira qué hay dentro.** Las imágenes se reconstruyen y los clusters de kind se recrean; un volumen con datos, no (§8).""",
"""**Y antes de `colima delete --data`, mira qué hay dentro.** Las imágenes se reconstruyen y los clusters de kind se recrean; un volumen con datos, no (§8)."""),
# §9
("""| `node-sass` falla **dentro** del contenedor | Tu Node ahí es arm64 de verdad, sin binario | §3, y **A12 §3** |""",
"""| `E: Failed to fetch http://deb.debian.org/debian-security/… 404  Not Found` al construir | Debian 11 fuera de soporte: fuentes en `archive.debian.org` | §6 |
| `bash: line 1: sudo: command not found` | La imagen slim no trae `sudo`: no lo uses en el `postCreateCommand` | §5 |
| `npm ERR! code EACCES` … `mkdir '…/node_modules/…'` | El volumen nació de `root`: la carpeta tiene que existir en la imagen | §5, §6 |
| `cannot run ssh` … `FileSaver.js.git` | `file-saver` por SSH: falta la reescritura de git a `https://` | §6, **A14 §3** |
| `node-sass` falla **dentro** del contenedor | Tu Node ahí es arm64 de verdad, sin binario: compila, y le falta algo | §3, §6, y **A12 §3** |
| `Can't find Python executable "python"` en `node-sass` | Falta `python2` para el `node-gyp` 3 de `node-sass` | §6 |
| `WARNING: The requested image's platform (linux/amd64) does not match…` | Corres una imagen amd64 sin pedirlo; funciona traducida | §4, §7 |"""),
("""| Guardo un archivo y `ng serve` no recarga | Los eventos de archivo no cruzan a la VM | §6, `--poll` |
| El 4200 no abre desde el navegador del Mac | Falta `--host 0.0.0.0`, o el puerto no está publicado | §6 |""",
"""| Guardo un archivo y `ng serve` no recarga | Los eventos de archivo no cruzan a la VM (en Colima, por defecto) | §3, §6, `--poll` |
| El 4200 no abre desde el navegador del Mac | Falta `--host 0.0.0.0` (`listening on localhost:4200`), o el puerto no está publicado | §6 |"""),
("""| `docker` no responde | El perfil no está levantado (`colima status`) | §8 |
| Todo va lento, sin errores | ¿Perfil amd64 sin necesitarlo? ¿`virtiofs`? | §3, §4 |""",
"""| `docker` no responde | El perfil no está levantado (`colima status`) | §8 |
| `'volume mount type' cannot be updated after initial setup, discarded` | Colima arrancó un perfil viejo con su configuración | §3 |
| `guest agent binary could not be found for Linux-x86_64` | Perfil de Colima con `--arch x86_64` y `vz`: esa combinación no existe | §4, §8 |
| Todo va lento, sin errores | ¿Contenedores amd64 sin necesitarlos? ¿Sin `virtiofs`? | §3, §4 |"""),
# Cuándo usar qué
("""| Empiezas en un Mac con chip M | Colima con arm64 (§1, §3) | Rápido, sin licencia, cubre el 90% del curso |""",
"""| Empiezas en un Mac con chip M | Colima con una VM arm64 y Rosetta (§1, §3) | Rápido, sin licencia, cubre el 90% del curso |"""),
("""| Persigues un bug que solo pasa en producción | Un perfil amd64 aparte (§4) | Paridad; y no lo dejes como ambiente por defecto |""",
"""| Persigues un bug que solo pasa en producción | `--platform linux/amd64` en ese contenedor (§4), o el devcontainer amd64 de **A14** | Paridad; y no lo dejes como ambiente por defecto |"""),
("""| Una imagen no tiene variante arm64 | `--platform linux/amd64` solo para esa (§7) | Es más barato que cambiar todo el perfil |
| `node-sass` te persigue dentro del contenedor | **A12 §3**: perfil amd64, o dart-sass | El contenedor mueve el problema, no lo borra |""",
"""| Una imagen no tiene variante arm64 | `--platform linux/amd64` solo para esa (§4, §7) | Es más barato que cambiar la VM |
| `node-sass` te persigue dentro del contenedor | El devcontainer de §6, que lo compila; o amd64 (§4), o Dart Sass (**A12 §3**) | El contenedor mueve el problema, no lo borra |
| Necesitas un Docker que por defecto sea amd64 | Una VM `--arch x86_64`, con QEMU, en un perfil aparte (§4) | Emulación completa: lenta, y casi nunca hace falta |"""),
# Advertencias
("""Toca dos cosas de este curso: el perfil amd64 (§4) y el Node 14 bajo Rosetta""",
"""Toca dos cosas de este curso: los contenedores amd64 (§4) y el Node 14 bajo Rosetta"""),
("""Dentro de un contenedor arm64, tu Node es arm64 de verdad y `node-sass` vuelve a no tener binario (**A12 §3**). Lo que ganas""",
"""Dentro de un contenedor arm64, tu Node es arm64 de verdad y `node-sass` vuelve a no tener binario: el devcontainer de §6 lo compila, y para eso trae `python2` (**A12 §3**). Lo que ganas"""),
# Referencias
("""- https://lima-vm.io — Lima,""",
"""- https://github.com/abiosoft/colima/blob/main/docs/FAQ.md — las preguntas frecuentes de Colima, incluidas Rosetta y los perfiles.
- https://lima-vm.io — Lima,"""),
("""- https://containers.dev/implementors/json_reference — la referencia del formato `devcontainer.json` (§6). Es una especificación abierta, aunque la implementación más común sea la de VS Code.""",
"""- https://containers.dev/implementors/json_reference — la referencia del formato `devcontainer.json` (§6). Es una especificación abierta, aunque la implementación más común sea la de VS Code.
- https://code.visualstudio.com/docs/devcontainers/containers — la extensión *Dev Containers* de VS Code, la que entiende el `devcontainer.json` de §6.
- https://archive.debian.org/debian/ — el archivo de versiones viejas de Debian, de donde el Dockerfile de §6 instala los paquetes de Debian 11."""),
# Ejercicios
("""3. Corre la imagen `amd64` del ejercicio anterior **sin** `--platform` en el perfil arm64 y anota el error exacto. Confírmalo contra la fila correspondiente de la tabla del §9 y contra la ⚠️ de la **Fase 14 §5.1**. Es el mismo error visto desde el otro lado.""",
"""3. Corre la imagen `amd64` del ejercicio anterior **sin** `--platform` en tu VM arm64 con Rosetta y anota qué pasa: el aviso exacto y si arranca. Confírmalo contra la fila del §9 y explica en dos líneas por qué un servidor amd64 sin emulación no te daría ese aviso, sino un `exec format error` con la imagen arm64 (§7)."""),
("""6. Levanta un segundo perfil `amd64` (§4) y cambia entre los dos con `docker context use`. Comprueba que las imágenes que construiste en uno **no aparecen** en el otro, y escribe en tres líneas qué le contestarías a un compañero que dice *"se me borraron todas las imágenes"* (§8).""",
"""6. Ten dos runtimes a la vez —Colima y Docker Desktop— o dos perfiles de Colima (`-p`, §3), y cambia entre ellos con `docker context use`. Comprueba que las imágenes que construiste en uno **no aparecen** en el otro, y escribe en tres líneas qué le contestarías a un compañero que dice *"se me borraron todas las imágenes"* (§8)."""),
# Pendientes
("""- **Los tiempos reales de cada perfil.** Los ejercicios 2 y 4 los piden y este apéndice no los publica, por la misma política de A08, A10 y A12: no se inventan cifras. Si alguien los mide sobre este proyecto, son el mejor argumento —a favor o en contra— de trabajar dentro del contenedor.""",
"""- **Los tiempos reales, completos.** El §4 publica una sola corrida del devcontainer, en Docker Desktop y sobre la base del proyecto. Faltan los que piden los ejercicios 2 y 4 —la imagen de la **Fase 13** en las dos arquitecturas y el volumen frente al bind mount— y todos sobre Colima; no se publican hasta medirlos, por la misma política de A08, A10 y A12: no se inventan cifras."""),
]

md = sys.argv[1]
t = open(md, encoding="utf-8").read()
for i, (viejo, nuevo) in enumerate(E, 1):
    n = t.count(viejo)
    if n != 1:
        sys.exit(f"edición {i}: aparece {n} veces")
    t = t.replace(viejo, nuevo)
open(md, "w", encoding="utf-8").write(t)
print(f"{len(E)} ediciones aplicadas")
