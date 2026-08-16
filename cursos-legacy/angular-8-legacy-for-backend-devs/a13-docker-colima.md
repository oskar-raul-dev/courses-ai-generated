# 📎 Apéndice A13 — 🔥 Docker + Colima en Apple Silicon

> Tutorial Angular 8 — Laboratorio clínico · Consulta rápida · **2h**
> Usado por: Fases 0, 13 y 14 · Versión cubierta: la CLI de Docker y el formato de imagen, que son lo estable. **Las versiones de Colima y Docker Desktop no se fijan a propósito** (§⚠️)
> Estado: 🔥 **Opcional por plataforma.** El curso se completa sin abrir este apéndice

**Esto no se lee de corrido.** Es material de consulta: se entra por el índice buscando algo concreto y se sale. Resuelve una situación muy concreta: **estás en un Mac con chip M y necesitas que el proyecto corra sin dedicarle la mañana al runtime de contenedores.**

Es la continuación natural del **Apéndice A12**: allá, la opción B de su §3 dice *"deja de pelear con tu máquina y métete en un contenedor"*. Esto es ese contenedor.

Y lo primero, porque es la confusión de origen: **aquí hay dos preguntas independientes que todo el mundo mezcla en una.** *Qué runtime* usas —Docker Desktop, Colima u otro— y *para qué arquitectura* corren tus contenedores —arm64 o amd64—. Son ejes distintos, con dueños distintos: el runtime lo decide tu equipo o tu licencia, la arquitectura la decide con qué necesitas tener paridad. Se pueden combinar de las cuatro formas y las cuatro funcionan.

> 🧰 **Esto es la versión de bolsillo. El taller completo está aparte.**
> Este apéndice responde *"qué hago yo el lunes"* en un Mac con chip M, y con eso te
> desbloquea. Si lo que quieres es entender **por qué** funciona —qué es un image index y
> cómo un tag contiene varias imágenes, qué hace exactamente QEMU frente a Rosetta y cuánto
> cuesta cada uno medido, o por qué `node_modules` no puede cruzar de arquitectura—, eso vive
> en un curso propio de este repositorio: **[Docker Legacy Node](../docker-container-legacy/README.md)**.
>
> Los tres capítulos que continúan lo de aquí son
> **[F21 — Arquitecturas, OCI multi-platform y emulación](../docker-container-legacy/21-arquitecturas-y-emulacion.md)**,
> **[F22 — Apple Silicon y el zoológico de hosts](../docker-container-legacy/22-apple-silicon-y-hosts.md)** y
> **[F23 — Estudios de caso y árbol de decisión](../docker-container-legacy/23-estudios-de-caso-multiplataforma.md)**;
> el devcontainer de §6 lo abre por dentro **[F19](../docker-container-legacy/19-dev-containers.md)**.
> Y si nunca has usado Docker, su **Parte I** lo enseña desde `docker --version` sin dar nada
> por sabido: **[índice del curso](../docker-container-legacy/0-programa-del-curso.md)**.

**Qué queda fuera:** la **comparativa exhaustiva de runtimes** —Podman, OrbStack, Lima y compañía se nombran en una línea y no se comparan: este apéndice responde "qué hago yo el lunes", no "cuál es mejor"—; el `Dockerfile` de dos etapas, el `nginx.conf` y el `entrypoint.sh` del proyecto, que son de la **Fase 13 §5.6-5.8** y **no son los de acá** (§6); `node-sass`, `node-gyp` y el Node del curso, que son el **Apéndice A12**; kind y el cluster local, que son la **Fase 14**; y por qué se compila sobre Debian y no sobre Alpine, que es del **A03 §9**.

---

## Índice

- [1. La decisión en una página](#1-la-decisión-en-una-página)
- [2. Los dos Rosetta, que no son la misma pieza](#2-los-dos-rosetta-que-no-son-la-misma-pieza)
- [3. Perfil arm64 nativo](#3-perfil-arm64-nativo)
- [4. Perfil amd64: paridad con fecha de caducidad](#4-perfil-amd64-paridad-con-fecha-de-caducidad)
- [5. Volúmenes: dónde vive `node_modules`](#5-volúmenes-dónde-vive-node_modules)
- [6. Un devcontainer para este proyecto](#6-un-devcontainer-para-este-proyecto)
- [7. Construir para la arquitectura correcta](#7-construir-para-la-arquitectura-correcta)
- [8. Cambiar de runtime sin romper nada](#8-cambiar-de-runtime-sin-romper-nada)
- [9. 🩺 Diagnóstico por síntoma](#9--diagnóstico-por-síntoma)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios (6)](#-ejercicios-6)

---

## 1. La decisión en una página

Dos ejes, cuatro casillas, y ninguna es "la correcta" en abstracto:

```
                     ARQUITECTURA DE LOS CONTENEDORES
                  arm64 (nativo)          amd64 (traducido)
              ┌────────────────────────┬────────────────────────┐
   Docker     │ Rapido, sin sorpresas  │ Paridad con PROD.      │
   Desktop    │ de rendimiento.        │ Mas lento. Y con       │
              │ Interfaz grafica.      │ fecha de caducidad     │
              │ Licencia: preguntala   │ (§2, §4)               │
              ├────────────────────────┼────────────────────────┤
   Colima     │ Lo mismo, por CLI      │ Lo mismo. Se enciende  │
              │ y sin licencia         │ con --arch x86_64      │
              │ comercial. El default  │ y --vz-rosetta         │
              │ razonable hoy          │                        │
              └────────────────────────┴────────────────────────┘
```

**El eje del runtime lo decide tu organización, no tu gusto.** Docker Desktop trae interfaz gráfica y una experiencia más pulida; Colima hace lo mismo desde la terminal, es software libre y arranca más rápido. La diferencia que suele decidir no es técnica: **las condiciones de uso comercial de Docker Desktop no son las de una herramienta libre**, y qué aplica a tu empresa lo responde tu organización —no un apéndice, y menos uno escrito hace meses—. Pregunta antes de instalarlo en una máquina de trabajo.

**El eje de la arquitectura lo decide con qué necesitas parecerte.** arm64 si lo que quieres es trabajar rápido (§3); amd64 si necesitas reproducir exactamente lo que corre en producción (§4).

> 🧭 **La regla por defecto, si no quieres pensarlo:** **Colima con arm64 nativo.** Es rápido, no arrastra licencia y cubre el 90% del trabajo del curso. Cambias a amd64 el día que un `exec format error` o una diferencia con producción te obliguen — y para entonces §4 y §8 te dicen cómo, sin tirar lo que ya tienes.

Y una tercera cosa que **no** es una decisión, aunque lo parezca: si vas a meterte en un contenedor *para desarrollar* (§6) o solo para *construir la imagen* de la **Fase 13**. Son usos distintos del mismo runtime y no compiten: puedes hacer las dos, y la mayoría de la gente empieza por la segunda porque es la que ya pide el curso.

---

## 2. Los dos Rosetta, que no son la misma pieza

Sección corta y necesaria, porque el nombre se repite y confunde a todo el mundo.

**Rosetta 2, el de macOS.** Traduce binarios de Intel para que corran en tu Mac con chip M. Es lo que hace funcionar el **Node 14.21.3 del curso**, que es un binario x64 (**A03 §1.2**, **A12 §1**). Vive en tu máquina, fuera de cualquier contenedor.

**Rosetta para Linux.** Es otra pieza, que corre **dentro de la máquina virtual** del runtime de contenedores y traduce procesos x86 de Linux. Es lo que hace que una imagen `amd64` vaya razonablemente rápida en vez de arrastrarse bajo emulación completa. En Colima se enciende con `--vm-type vz --vz-rosetta`.

Se llaman igual, hacen cosas parecidas en capas distintas, y **puedes tener una sin la otra**: un contenedor arm64 nativo no usa ninguna de las dos, y tu Node del curso usa la primera aunque nunca abras Docker.

> ⚠️ **Rosetta tiene fecha, y es reciente.** Apple mantiene Rosetta 2 completo en **macOS 27** y **lo retira en gran parte a partir de macOS 28**, conservando solo un subconjunto pensado para juegos antiguos; desde macOS 26.4 el sistema ya avisa al abrir una aplicación que lo necesita. **Verifica el anuncio vigente antes de apoyar una decisión de equipo en esta fecha** — es un dato que se mueve y que este apéndice no puede garantizar en el tiempo.
>
> Lo que importa no es la fecha exacta sino la forma del problema, y esa no cambia: **el camino de la traducción tiene vencimiento y el nativo no.** Eso afecta a las dos piezas de arriba, así que toca dos decisiones de este curso: el perfil amd64 (§4) y, más de fondo, el Node 14 bajo Rosetta que el curso fija para Apple Silicon (**A03 §1.2**). Ninguna de las dos es urgente hoy; las dos conviene tenerlas anotadas.

---

## 3. Perfil arm64 nativo

Es el default razonable y el que deberías intentar primero.

```bash
# Un perfil arm64 con recursos suficientes para compilar Angular sin sufrir.
# --mount-type virtiofs es lo que hace que los archivos montados no vayan
# lentos: es la parte que más se nota en el día a día (§5).
colima start \
  --arch aarch64 \
  --vm-type vz \
  --cpu 4 --memory 8 --disk 60 \
  --mount-type virtiofs

# Comprobar que quedó como esperabas.
colima status
docker info | grep -i architecture
```

> ⚠️ Los nombres exactos de los flags de Colima cambian entre versiones. **Comprueba los tuyos con `colima start --help`** en vez de copiar de memoria: es la única fuente que no envejece, y es el mismo criterio que este curso aplica con `kubectl` (**A09**) y con `ng update` (**A10**).

**Qué ganas.** Velocidad real, sin capa de traducción, y un consumo de batería civilizado. Para el trabajo del curso —compilar Angular, levantar json-server, construir la imagen de la Fase 13 y probarla— es la opción cómoda.

**Qué rompe, y son dos cosas concretas:**

**Una imagen sin variante arm64.** Todavía existen, sobre todo entre las viejas y las de nicho. El síntoma es que `docker run` falla con `exec format error`, o que la imagen ni siquiera se descarga porque no hay manifiesto para tu plataforma. La salida rápida es forzar la otra arquitectura solo para esa imagen (§7); la salida buena es buscar si hay una variante nativa. Las imágenes del curso —`node:14-bullseye-slim` y `nginx:stable-alpine` de la **Fase 13 §5.6**— sí tienen arm64.

**Las dependencias nativas de Node.** Dentro de un contenedor arm64, tu Node es **arm64 de verdad**, no x64 bajo Rosetta. Y ahí `node-sass` vuelve a no tener binario precompilado, que es exactamente el problema de **A12 §2**. Es el detalle que sorprende: *"me metí al contenedor para escapar de `node-sass` y me lo encontré igual"*. Si te pasa, tienes dos salidas y las dos están en A12 §3: un perfil amd64 (§4), o dart-sass como experimento.

> 🧠 **La regla que resume las dos:** **meterte en un contenedor no cambia el problema de arquitectura, cambia dónde ocurre.** Lo que gana el contenedor es que ese "dónde" es reproducible, desechable e idéntico para todo el equipo — no que el problema desaparezca.

---

## 4. Perfil amd64: paridad con fecha de caducidad

```bash
# Un SEGUNDO perfil, con nombre propio, que convive con el de §3.
# Los perfiles son maquinas virtuales independientes: cada una con sus
# imágenes, sus volúmenes y su cache (§8).
colima start --profile amd64 \
  --arch x86_64 \
  --vm-type vz --vz-rosetta \
  --cpu 4 --memory 8 --disk 60
```

**Cuándo lo necesitas de verdad.** Solo por una razón: **paridad**. Si producción corre en `linux/amd64` —que es lo normal— y estás persiguiendo un bug que solo aparece allá, tu máquina tiene que dejar de ser especial. También cuando una dependencia nativa no tiene binario arm64 y no quieres pelear (§3).

**Cuándo no.** Para el trabajo diario. Es más lento incluso con Rosetta, gasta más batería, y la mayoría de los bugs de este curso no dependen de la arquitectura.

**Y el costo que no se ve:** este perfil depende de la traducción, y la traducción tiene vencimiento (§2). Montar el flujo de trabajo del equipo entero encima de él es construir sobre algo con fecha. Como herramienta de diagnóstico puntual es perfecto; como ambiente por defecto, conviene saber lo que se está eligiendo.

> 💡 Sin `--vz-rosetta` también funciona, con emulación completa, y la diferencia de velocidad es de las que se sienten sin cronómetro. Si tu versión de macOS o de Colima no soporta la opción, el perfil sigue siendo válido: solo va más despacio.

---

## 5. Volúmenes: dónde vive `node_modules`

Esta es la sección que decide si un devcontainer se usa o se abandona el primer día.

**El problema.** Cuando montas la carpeta del proyecto dentro del contenedor, cada lectura de archivo cruza la frontera entre macOS y la máquina virtual. Con miles de archivos pequeños —y `node_modules` son decenas de miles— eso se nota muchísimo: instalaciones eternas y builds que tardan el doble. `virtiofs` mejora bastante la situación frente a las opciones anteriores y **no la elimina**.

**El problema serio, que además rompe.** Si `node_modules` vive en la carpeta montada, esa carpeta la comparten **tu Mac y el contenedor Linux**. Y ahí aplica sin matices la advertencia central de **A03 §9**: `node_modules` contiene binarios atados a un sistema, una arquitectura y una versión de Node. Instalas desde el contenedor, corres `npm start` en el Mac, y revienta. O al revés. Y el error no menciona ni el volumen ni la arquitectura.

**La solución, que es una línea de configuración:** que `node_modules` **no** esté en el bind mount. Se monta un volumen con nombre —gestionado por Docker, que vive dentro de la VM— justo encima de esa ruta:

```jsonc
// Fragmento de .devcontainer/devcontainer.json (el archivo completo esta en §6)
"mounts": [
  // node_modules vive DENTRO de la VM, no en el disco del Mac. Dos efectos:
  // el npm install va mucho más rápido, y los binarios nativos de Linux dejan
  // de mezclarse con los de macOS. Es la aplicación directa de A03 §9.
  "source=lab-node-modules,target=${containerWorkspaceFolder}/node_modules,type=volume"
]
```

**La consecuencia que hay que tener presente:** con ese montaje, `node_modules` **desaparece de la vista de tu editor en el Mac** —está dentro de la VM— y el `npm install` hay que correrlo **dentro** del contenedor. Eso es lo correcto y a la vez es lo que confunde el primer día: el proyecto se ve sin dependencias desde fuera y funciona perfectamente desde dentro.

> ⚠️ **Y el reverso, que es la trampa real:** si en algún momento corres `npm install` en el Mac *y también* dentro del contenedor sobre la misma carpeta montada, acabas con binarios de dos plataformas mezclados y errores que no se parecen a su causa. **Elige un lado y quédate ahí.** Si tienes que cambiar, el ritual es el de **A12 §7**: borrar `node_modules` y reinstalar desde el lockfile.

---

## 6. Un devcontainer para este proyecto

> ⚠️ **Esto NO es el `Dockerfile` de la Fase 13.** Aquel compila la aplicación y la sirve con nginx: es el artefacto que va a producción, y no lleva Node en su etapa final (**Fase 13 §5.6**). Este es un ambiente **de desarrollo**, con Node, Python y las build tools, donde tú trabajas. Viven en carpetas distintas, se construyen por separado y confundirlos produce imágenes de producción con medio compilador dentro.

```dockerfile
# .devcontainer/Dockerfile
# Imagen de DESARROLLO. Debian y no Alpine: el tooling nativo de esta epoca
# necesita glibc, y el porque esta en el Apéndice A03 §9.
FROM node:14.21.3-bullseye-slim

# Lo que node-gyp necesita para compilar dependencias nativas. Es exactamente
# la lista del Apéndice A12 §4, en su versión de Linux.
RUN apt-get update && apt-get install -y --no-install-recommends \
      python3 \
      build-essential \
      git \
      curl \
    && rm -rf /var/lib/apt/lists/*

# El usuario 'node' ya existe en esta imagen y no es root. Trabajar como root
# dentro del contenedor deja archivos de root en tu carpeta montada, y eso se
# arregla después con chown y malhumor.
USER node
WORKDIR /workspace
```

```jsonc
// .devcontainer/devcontainer.json
{
  "name": "clinical-lab (Angular 8)",
  "build": { "dockerfile": "Dockerfile" },

  // node_modules fuera del bind mount: es la §5 y no es opcional.
  "mounts": [
    "source=lab-node-modules,target=${containerWorkspaceFolder}/node_modules,type=volume"
  ],

  // 4200 es ng serve; 3000 es json-server (Fase 4). Se publican para poder
  // abrirlos desde el navegador del Mac, que es donde corre la aplicación.
  "forwardPorts": [4200, 3000],

  // El volumen de node_modules nace vacío y pertenece a root: hay que darselo
  // al usuario 'node' antes de instalar nada. Este es el paso que falta en el
  // 90% de los devcontainer.json que encontraras copiados por ahí.
  "postCreateCommand": "sudo chown -R node:node node_modules && npm ci",

  "remoteUser": "node"
}
```

Y el detalle que hace que se pueda usar de verdad:

```bash
# Dentro del contenedor, ng serve tiene que escuchar en todas las interfaces.
# Con el default (localhost) el servidor solo se ve DESDE DENTRO, y desde el
# navegador del Mac no carga nada: es el "no me abre en el 4200" clasico.
npx ng serve --host 0.0.0.0 --poll 2000
```

**Detalles con intención.**

- **`--host 0.0.0.0`** es obligatorio dentro de un contenedor. Sin él, publicar el puerto no sirve de nada.
- **`--poll`** hace que el detector de cambios pregunte por los archivos en vez de esperar a que el sistema le avise. Los eventos de cambio de archivo **no siempre cruzan** la frontera entre macOS y la VM, y el síntoma es que guardas y la página no se recarga. Cuesta algo de CPU y evita la pregunta *"¿por qué tengo que reiniciar `ng serve` cada vez?"*.
- **El formato `devcontainer.json` es de VS Code**, aunque otras herramientas lo lean. Si tu editor no lo soporta, el `Dockerfile` sigue valiendo: lo levantas a mano con `docker run` montando la carpeta y publicando los puertos.
- **Este contenedor es la "ruta corta"** del ejercicio 🔥 de la **Fase 0** que propone armar el ambiente en Debian slim a mano. Si quieres la lección completa, hazlo a mano primero; si quieres trabajar, esto es lo que hay.

---

## 7. Construir para la arquitectura correcta

La **Fase 14 §5.1** y el **A09 §7** te enseñan a *diagnosticar* el `exec format error`: la imagen es de otra arquitectura que la máquina que la corre. Esta sección es la otra mitad, la que nadie escribió todavía: **cómo evitarlo al construir.**

```bash
# 1. De qué arquitectura es esta imagen, realmente. Es la comprobación que
#    resuelve la discusión antes de que empiece.
docker image inspect lab-frontend:1.0.0 --format '{{.Architecture}}'

# 2. Construir para una arquitectura concreta, sin importar en que Mac estes.
docker build --platform linux/amd64 -t lab-frontend:1.0.0 .

# 3. Correr una imagen de otra arquitectura, puntualmente.
docker run --platform linux/amd64 --rm -p 8080:80 lab-frontend:1.0.0
```

**La regla, en una línea:** la imagen tiene que ser de la arquitectura **de la máquina que la va a correr**, y esa máquina no siempre es la tuya. Para el kind de la **Fase 14**, el nodo hereda la arquitectura de tu VM, así que en un Mac con chip M y un perfil arm64 tienes que construir **arm64**. Para un servidor de la empresa, casi siempre `linux/amd64`.

Y cuando la misma imagen tiene que servir para las dos:

```bash
# Una imagen multi-arquitectura: un solo tag que contiene las dos variantes, y
# cada máquina descarga la suya. Necesita un builder con soporte multiplataforma.
docker buildx build --platform linux/amd64,linux/arm64 \
  -t registry.interno/lab/frontend:1.4.0 --push .
```

> ⚠️ **`--push` no es opcional en el comando de arriba, y es lo que más sorprende.** Una imagen multi-arquitectura es un manifiesto que apunta a varias variantes, y el almacén local de imágenes de tu Docker guarda una sola: por eso `--load` solo funciona con **una** plataforma a la vez. Multi-arquitectura significa, en la práctica, **publicar en un registry** — que es justo la diferencia con el `kind load` de la **Fase 14 §4**, y otro recordatorio de que el atajo de kind no existe en la empresa (**A09 §3**).

---

## 8. Cambiar de runtime sin romper nada

Docker Desktop y cada perfil de Colima son **máquinas virtuales independientes**. Eso tiene una consecuencia que se descubre en el peor momento: **las imágenes, los volúmenes y la caché de build viven dentro de una VM y no se ven desde la otra.** Cambiar de runtime no borra nada, pero lo esconde, y el síntoma es *"mi imagen desapareció"*.

Quién está atendiendo tus comandos lo dice el **contexto**:

```bash
# 👁️ Que contextos hay y cual esta activo (la estrella).
docker context ls

# ✍️ Cambiar. El nombre exacto depende de lo que tengas instalado; sale en
#    la lista de arriba.
docker context use colima
docker context use desktop-linux

# 👁️ Y la confirmación que de verdad importa: a qué VM le estoy hablando y
#    de que arquitectura es.
docker info --format '{{.Name}} / {{.Architecture}} / {{.OperatingSystem}}'
```

**El ritual para cambiar sin perder la mañana:**

1. **Comprueba dónde estás** (`docker context ls`). Si algo "desapareció", empieza por aquí: en el 90% de los casos no se borró, está en la otra VM.
2. **Levanta el destino antes de apagar el origen.** Los perfiles de Colima conviven; no hay que elegir uno para siempre.
3. **Reconstruye la imagen en el runtime nuevo.** Es más rápido que buscar cómo exportarla, y además te confirma que el `Dockerfile` de la **Fase 13** sigue construyendo en ese entorno.
4. **Si usas el devcontainer de §6, recrea el contenedor.** El volumen con nombre de `node_modules` vive en la VM vieja: en la nueva nace vacío y el `postCreateCommand` lo vuelve a llenar. Eso es correcto, no un fallo.
5. **Si tenías un cluster de kind** (**Fase 14**), ese cluster vivía en la VM anterior. Se recrea con los mismos manifiestos en minutos; no intentes moverlo.

```bash
# Los perfiles de Colima, y cual esta corriendo.
colima list

# Apagar uno sin destruirlo (conserva imágenes y volúmenes).
colima stop --profile amd64

# Destruirlo de verdad, con todo lo que tenia dentro. Esto SI borra.
colima delete --profile amd64
```

> 💡 **Antes de destruir un perfil, anota qué había dentro.** Las imágenes se reconstruyen y los clusters de kind se recrean, pero un volumen con datos —el `db.json` del mock de la **Fase 4** montado dentro, por ejemplo— no vuelve solo. `docker volume ls` con el contexto correcto, y dos minutos antes de escribir `delete`.

---

## 9. 🩺 Diagnóstico por síntoma

> 🕵️ Si el síntoma no está acá, el índice de síntomas **transversal** del curso está en [`forense-master.md`](forense-master.md) §3, y el pod que no arranca en [`forense-fase-14.md`](forense-fase-14.md).

| Lo que ves | Qué es | Dónde vas |
|---|---|---|
| `exec format error` al correr un contenedor | La imagen es de otra arquitectura que la VM | §7, y **Fase 14 §5.1** |
| `no matching manifest for linux/arm64` al descargar | Esa imagen no tiene variante arm64 | §3, o `--platform` (§7) |
| El pod de kind muere al instante | La imagen no coincide con la arquitectura del nodo | §7, **Fase 14 §5.1** |
| `node-sass` falla **dentro** del contenedor | Tu Node ahí es arm64 de verdad, sin binario | §3, y **A12 §3** |
| `npm install` tarda una eternidad | `node_modules` está en el bind mount | §5 |
| Instalé fuera y no funciona dentro (o al revés) | Binarios de dos plataformas mezclados | §5, ritual de **A12 §7** |
| Guardo un archivo y `ng serve` no recarga | Los eventos de archivo no cruzan a la VM | §6, `--poll` |
| El 4200 no abre desde el navegador del Mac | Falta `--host 0.0.0.0`, o el puerto no está publicado | §6 |
| "Mi imagen desapareció" | Estás en otro contexto: vive en la otra VM | §8 |
| `docker` no responde | El perfil no está levantado (`colima status`) | §8 |
| Todo va lento, sin errores | ¿Perfil amd64 sin necesitarlo? ¿`virtiofs`? | §3, §4 |
| Archivos de `root` en tu carpeta del Mac | El contenedor corre como root | §6, `remoteUser` |

---

## 🧭 Cuándo usar qué

| Situación | Qué haces | Por qué |
|---|---|---|
| Empiezas en un Mac con chip M | Colima con arm64 (§1, §3) | Rápido, sin licencia, cubre el 90% del curso |
| Tu empresa ya tiene licencia y la quieres gráfica | Docker Desktop, arm64 | El eje del runtime es independiente del de la arquitectura |
| Persigues un bug que solo pasa en producción | Un perfil amd64 aparte (§4) | Paridad; y no lo dejes como ambiente por defecto |
| Una imagen no tiene variante arm64 | `--platform linux/amd64` solo para esa (§7) | Es más barato que cambiar todo el perfil |
| `node-sass` te persigue dentro del contenedor | **A12 §3**: perfil amd64, o dart-sass | El contenedor mueve el problema, no lo borra |
| Vas a construir la imagen de la Fase 13 para un servidor | `--platform linux/amd64` (§7) | La máquina que la corre no es la tuya |
| La imagen tiene que servir para las dos | `buildx --platform ... --push` (§7) | Multi-arquitectura implica registry |
| Solo quieres desarrollar cómodo | El devcontainer de §6, con el volumen de §5 | Sin ese volumen, se abandona el primer día |
| Cambiaste de runtime y falta algo | `docker context ls` (§8) | Casi nunca se borró: está en la otra VM |
| Alguien propone Podman, OrbStack o Lima | Fuera del alcance de este apéndice | Existen y funcionan; comparar no es el trabajo de hoy |

---

## ⚠️ Advertencias

**El curso se completa sin abrir este apéndice.** Windows 11 es el entorno por defecto y Linux amd64 funciona sin sorpresas. Esto existe para que quien llegue con un Mac de chip M no se quede fuera.

**Aquí no se fija ninguna versión de herramienta, y es a propósito.** Colima, Docker Desktop y macOS se mueven rápido, y los flags cambian entre versiones. Lo que sí es estable es la CLI de Docker y el formato de las imágenes. **Comprueba los flags con `colima start --help` y `docker --help`**, no con la memoria de un apéndice.

**Rosetta tiene vencimiento.** Se mantiene completo en macOS 27 y se retira en gran parte a partir de macOS 28, con un subconjunto reservado para juegos antiguos. Verifica el anuncio vigente antes de apoyar una decisión de equipo en esa fecha. Toca dos cosas de este curso: el perfil amd64 (§4) y el Node 14 bajo Rosetta que se fija para Apple Silicon (**A03 §1.2**). Ninguna es urgente; las dos conviene tenerlas anotadas.

**El contenedor no borra el problema de arquitectura, lo reubica.** Dentro de un contenedor arm64, tu Node es arm64 de verdad y `node-sass` vuelve a no tener binario (**A12 §3**). Lo que ganas es que ese entorno es reproducible, desechable e idéntico para todo el equipo.

**`node_modules` en el bind mount rompe, no solo va lento.** Binarios de macOS y de Linux en la misma carpeta producen errores que no mencionan ni el volumen ni la plataforma (§5, **A03 §9**). Elige un lado —dentro o fuera— y quédate ahí.

**El contenedor de desarrollo no es el de la Fase 13.** Aquel va a producción y no lleva Node en su etapa final. Este trae compilador, Python y build tools. Mezclarlos produce imágenes de producción con medio toolchain dentro (§6).

**Y antes de `colima delete`, mira qué hay dentro.** Las imágenes se reconstruyen y los clusters de kind se recrean; un volumen con datos, no (§8).

---

## 📚 Referencias

- https://github.com/abiosoft/colima — Colima: instalación, perfiles y los flags de `--arch`, `--vm-type` y Rosetta. ⚠️ Es la fuente de §3 y §4, y la que hay que consultar en vez de fiarse de los flags de este apéndice.
- https://lima-vm.io — Lima, la máquina virtual sobre la que Colima está construido. Útil solo cuando algo falla por debajo de Colima.
- https://docs.docker.com/desktop/setup/install/mac-install — Docker Desktop en macOS, con sus requisitos. Las **condiciones de uso comercial** están en la web de Docker y las confirma tu organización, no un apéndice (§1).
- https://docs.docker.com/build/building/multi-platform — `buildx` y las imágenes multi-arquitectura, incluida la razón por la que `--load` no sirve con varias plataformas (§7).
- https://docs.docker.com/engine/manage-resources/contexts — los contextos de Docker, que son el mecanismo del §8.
- https://docs.docker.com/engine/storage/volumes — volúmenes con nombre frente a bind mounts, que es la decisión del §5.
- https://containers.dev/implementors/json_reference — la referencia del formato `devcontainer.json` (§6). Es una especificación abierta, aunque la implementación más común sea la de VS Code.
- https://developer.apple.com/documentation/virtualization — el framework de virtualización de Apple, que es lo que hay detrás de `--vm-type vz` y de Rosetta para Linux (§2).
- https://support.apple.com/en-us/HT211861 — Rosetta 2 en macOS: qué es y cómo se instala. La misma referencia del **A12**.
- https://v8.angular.io/cli/serve — las opciones de `ng serve`, incluidas `--host` y `--poll` del §6, en la versión del curso.

> ⚠️ Los enlaces y contenidos pueden haber cambiado o desaparecido; verifícalos. En este tema hay un riesgo específico: **casi todo lo que encuentres sobre "Docker en M1" es de 2021-2022**, cuando el ecosistema se estaba adaptando y muchas imágenes no tenían variante arm64. Buena parte de esos trucos hoy sobran. Fíjate en la fecha antes de copiar nada.

**Orden de lectura sugerido:** si estás empezando, §1 y §3, y nada más. Si vas a desarrollar dentro del contenedor, §5 **antes** que §6 — el orden importa, porque §6 sin §5 se abandona. Si te llegó un `exec format error`, §7. Si algo desapareció, §8.

---

## 🧪 Ejercicios (6)

Cortos y de consulta. **Todos necesitan un Mac con Apple Silicon**; si estás en Windows o Linux, este apéndice no te toca y el curso sigue completo sin él.

1. Levanta un perfil arm64 (§3) y confirma con `docker info` que la arquitectura es la que esperas. Después corre `docker run --rm alpine uname -m` y compara la respuesta con la de tu `uname -m` en el Mac. Anota las dos y explica en una línea por qué coinciden.
2. Construye la imagen de la **Fase 13** en tu perfil arm64 y comprueba su arquitectura con `docker image inspect`. Después reconstruye con `--platform linux/amd64` e inspecciona otra vez. Anota cuánto tardó cada una: esa diferencia es el costo de la traducción, medido por ti (§7).
3. Corre la imagen `amd64` del ejercicio anterior **sin** `--platform` en el perfil arm64 y anota el error exacto. Confírmalo contra la fila correspondiente de la tabla del §9 y contra la ⚠️ de la **Fase 14 §5.1**. Es el mismo error visto desde el otro lado.
4. Monta el devcontainer del §6 **sin** el volumen de `node_modules`, corre `npm ci` dentro y cronométralo. Después añade el volumen, recrea el contenedor y repite la medida. Anota los dos tiempos; con eso ya no necesitas que nadie te convenza de la §5.
5. **Rompe a propósito.** Con el devcontainer sin volumen —el del ejercicio anterior—, corre `npm ci` **dentro** del contenedor y después `npm start` **fuera**, en el Mac. Anota el error y explica por qué no menciona ni el contenedor ni la arquitectura. Después aplica el ritual de **A12 §7** y confirma que se arregla.
6. Levanta un segundo perfil `amd64` (§4) y cambia entre los dos con `docker context use`. Comprueba que las imágenes que construiste en uno **no aparecen** en el otro, y escribe en tres líneas qué le contestarías a un compañero que dice *"se me borraron todas las imágenes"* (§8).


> 🏷️ **Este es el único apéndice que puede llevar tag propio.** El §6 escribe
> archivos de verdad —`.devcontainer/devcontainer.json` y su `Dockerfile`— y
> versionarlos o no es una decisión de proyecto todavía abierta (📌 de abajo).
> Si decides versionarlos, ese commit se etiqueta y queda dicho cuándo entró el
> devcontainer y por qué:
>
> ```bash
> git tag -a apendice-a13-docker-colima -m "A13: devcontainer versionado, con el volumen con nombre para node_modules."
> ```
>
> Todo lo demás de este apéndice cambia tu máquina y no el repositorio, así que
> no se etiqueta. La convención completa está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

- **El Node 14 bajo Rosetta también tiene fecha.** La decisión de **A03 §1.2** —Node 14.21.3 x64 traducido— es correcta hoy y depende de una pieza que Apple retira (§2). Cuando esa fecha se acerque, en Apple Silicon quedarán dos caminos: un Node arm64 nativo, que reabre el problema de `node-sass` (**A12 §3**), o trabajar dentro del contenedor de §6. **No es urgente y conviene decidirlo antes de que lo decida el calendario** → decisión de proyecto, con nota en **A03** y en **A12**.
- **Los tiempos reales de cada perfil.** Los ejercicios 2 y 4 los piden y este apéndice no los publica, por la misma política de A08, A10 y A12: no se inventan cifras. Si alguien los mide sobre este proyecto, son el mejor argumento —a favor o en contra— de trabajar dentro del contenedor.
- **El devcontainer no está en el repositorio del curso.** El §6 lo escribe, pero nadie ha decidido si `.devcontainer/` se versiona junto al proyecto. Versionarlo ayuda a quien llegue con un Mac; también añade dos archivos que el 90% del equipo nunca abrirá → decisión de proyecto.
- **Multi-arquitectura implica registry**, y el curso no tiene ninguno: la **Fase 14** usa `kind load` y el **A09 §3** explica que ese atajo no existe en la empresa. Montar el registry local que kind documenta cerraría ese hueco y daría sentido al `buildx --push` del §7 → **ejercicio 🔥** de la Fase 14, ya anotado allá.
