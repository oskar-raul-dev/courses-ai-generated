# 🐳 Apéndice A9 — Entornos y contenedores

> Tutorial React 16 — Rifas y chances · Apéndice de **consulta rápida** · **~3 horas**
> Lo usa: Fase 0 (setup), y el track forense ante cualquier bug de entorno.
> No es lectura secuencial: salta al bloque que necesites.

La Fase 0 te deja la app corriendo por el camino más corto: Node 14 nativo con
nvm y `npm start`. Para el "Hola mundo" eso sobra y no hace falta nada más.

Este apéndice es para el día siguiente. El día en que un compañero dice "en mi
máquina anda", el día en que un bug solo se reproduce en Linux, el día en que
tienes que decidir si vale la pena montar un contenedor para ganar paridad con
producción. Todo eso es setup, sí, pero es setup **de diagnóstico**, y por eso
vive acá y no dentro de la Fase 0: mezclarlo con el primer componente del curso
hacía que la fase más liviana pesara como la más difícil.

> 📝 **De dónde sale este apéndice.** Todo esto vivía dentro de la §5.3 de
> `00-setup-hola-mundo-cra.md`. Se extrajo porque la Fase 0 son 6 horas y ese
> bloque solo se necesita cuando aparece un incidente de entorno — que puede ser
> en la semana 1 o en la 4.

---

## 🧭 Índice de salto rápido

1. [Cuándo necesitas un contenedor (y cuándo no)](#1-cuándo-necesitas-un-contenedor-y-cuándo-no)
2. [Las siete vías de setup, comparadas](#2-las-siete-vías-de-setup-comparadas)
3. [Colima arm64 — la opción por defecto en Apple Silicon](#3-colima-arm64--la-opción-por-defecto-en-apple-silicon)
4. [Colima amd64 con vz-rosetta — paridad exacta con producción](#4-colima-amd64-con-vz-rosetta--paridad-exacta-con-producción)
5. [Colima frente a Docker Desktop](#5-colima-frente-a-docker-desktop)
6. [Windows dentro de macOS](#6-windows-dentro-de-macos)
7. [La regla del `node_modules`](#7-la-regla-del-node_modules-la-que-más-caro-sale)
8. [🧩 Cuándo usar qué](#-cuándo-usar-qué)
9. [🧪 Ejercicios](#-ejercicios-8)

---

## 1. Cuándo necesitas un contenedor (y cuándo no)

La respuesta honesta es: **casi nunca, hasta que sí**. Y saber distinguir esos
dos momentos te ahorra días.

**No lo necesitas** mientras estés escribiendo features. Node 14 nativo con nvm
compila más rápido, el hot reload responde mejor, y el debugger de tu editor se
engancha sin configurar nada. Desde que este proyecto usa dart-sass (D11) y no
`node-sass`, **no queda ninguna dependencia nativa que compilar**, así que la
razón histórica número uno para contenerizar en Apple Silicon desapareció.

**Sí lo necesitas** cuando el bug depende del sistema operativo. Los síntomas
que lo delatan son siempre los mismos tres: un test pasa local y falla en CI; un
comportamiento aparece en producción y no en tu máquina; un compañero con otro
sistema operativo ve algo que tú no. Ahí ya no estás desarrollando, estás
**reproduciendo**, y reproducir sin paridad de entorno es adivinar.

> 🧭 **La regla.** El contenedor no es una mejora del entorno de desarrollo: es
> una herramienta de diagnóstico. Se monta cuando hay algo que reproducir, no
> "por si acaso". Un equipo que contenedoriza todo desde el día uno paga
> lentitud todos los días para cubrir un problema que aparece dos veces al año.

---

## 2. Las siete vías de setup, comparadas

Cada vía se describe con lo mismo: qué es, cuánto cuesta montarla, qué paridad
con producción te da, y cuándo la elegirías.

**Windows 11 nativo**
Node 14 con nvm-windows, todo x86_64, sin sorpresas de arquitectura. Setup de
20-30 minutos contando descargas. Velocidad máxima, consumo de RAM mínimo. La
paridad con producción es media-alta: mismo procesador, distinto sistema
operativo. *Elígela si trabajas en Windows y no estás persiguiendo un bug de
Linux.*

**Linux amd64 nativo**
El caso sin fricción: nvm, `nvm install 14.21.3`, listo en quince minutos.
Velocidad máxima, RAM mínima. Si tu producción también es Linux amd64 —lo más
probable—, **tienes la mejor paridad de todas prácticamente gratis**, sin
contenedor de por medio. *Elígela siempre que puedas.*

**macOS Apple Silicon, nativo en el host**
nvm con Node 14 arm64, sin contenedor. Rápido de montar y rápido de correr.
La paridad con producción es **baja**: arquitectura distinta y sistema operativo
distinto. *Elígela para todo el trabajo de features, y cambia de vía en cuanto
tengas que reproducir algo serio.*

**macOS Apple Silicon + Colima arm64** (§3)
Contenedor Linux corriendo arm64 nativo, sin emulación. Casi tan rápido como el
host, ~2 GB de RAM. Paridad media: mismo sistema operativo que producción,
distinta arquitectura. *Es la opción por defecto en Apple Silicon en cuanto
entra un contenedor al proyecto.*

**macOS Apple Silicon + Colima amd64 vz-rosetta** (§4)
Contenedor Linux amd64 traducido por Rosetta 2. Dos o tres veces más lento que
arm64, pero **idéntico a producción** en sistema operativo y arquitectura.
*Elígela solo cuando estés persiguiendo un bug que no reproduces de otra forma.*

**macOS + Docker Desktop** (§5)
Funciona exactamente igual que Colima desde el punto de vista del proyecto: los
mismos comandos, el mismo `docker-compose.yml`. Lo que cambia es que trae GUI y
consume 6-8 GB de RAM en reposo. *Elígela si prefieres la interfaz gráfica y la
RAM no te preocupa.*

**Windows 11 dentro de macOS (UTM o Parallels)** (§6)
Máquina virtual completa. Setup de una a dos horas, lento, pesado. Es la única
vía que reproduce bugs específicos de Windows. *Elígela solo cuando un incidente
lo exija, y apágala al terminar.*

> 💡 **El resumen, si tienes prisa:** Linux nativo si puedes; Windows nativo si
> es tu máquina; en Mac, nativo para trabajar y Colima arm64 cuando entre el
> contenedor. El resto son herramientas de incidente.

---

## 3. Colima arm64 — la opción por defecto en Apple Silicon

Colima corre contenedores Linux **arm64 sin emulación**: casi tan rápido como
nativo, sin Rosetta de por medio. Es la opción por defecto frente a Docker
Desktop porque consume ~2 GB de RAM en reposo contra 6-8 GB (D13).

`Dockerfile.dev`:

```dockerfile
FROM node:14.21.3-bullseye

RUN apt-get update && apt-get install -y \
    build-essential python3 \
    && ln -sf /usr/bin/python3 /usr/bin/python

WORKDIR /app
EXPOSE 3000 3001 3002
CMD ["bash"]
```

`docker-compose.yml`:

```yaml
services:
  react:
    build: .
    volumes:
      - .:/app
      - node_modules:/app/node_modules    # ← volumen dedicado, no del host
    ports: ["3000:3000"]
    stdin_open: true
    tty: true
  mock:
    image: node:14.21.3-bullseye
    working_dir: /app
    volumes: [.:/app]
    command: npm run mock:all
    ports: ["3001:3001", "3002:3002"]
volumes:
  node_modules:
```

Flujo completo:

```bash
brew install colima docker docker-compose
colima start --cpu 4 --memory 4 --arch aarch64
docker compose up -d
docker compose exec react bash
# ya dentro del contenedor:
npm ci
npm start
```

Editas en tu editor del host (o con Dev Containers) y abres el navegador en
`localhost:3000`. El servicio `mock` levanta los dos backends de la Fase 3 —el
json-server del `3001` y la lotería del `3002`— con un solo comando.

> 📝 **Por qué `build-essential` y `python3` si ya no usamos `node-sass`.** No
> hacen falta hoy. Están en el `Dockerfile.dev` como red por si alguna
> dependencia futura trae código nativo, y porque quitarlos de una imagen que
> funciona es cambio sin beneficio. Es, en pequeño, la misma lógica de deuda
> deliberada que el curso aplica en el código. 💸

---

## 4. Colima amd64 con vz-rosetta — paridad exacta con producción

Si producción corre en Linux **amd64** y quieres reproducir exacto —el caso de
los bugs "solo pasan en PROD" y de los smoke tests del track forense—:

```bash
colima start --cpu 4 --memory 4 --arch x86_64 --vm-type vz --vz-rosetta
```

Y en el `Dockerfile.dev` fijas la plataforma:

```dockerfile
FROM --platform=linux/amd64 node:14.21.3-bullseye
```

El resto es igual que en §3. Velocidad: 2-3× más lento que arm64 nativo, pero
**idéntico a producción**.

`vz` es el Virtualization framework de Apple y `--vz-rosetta` activa la
traducción x86_64 acelerada por Rosetta 2. La combinación te da amd64 utilizable
sin la lentitud de la emulación por software pura, que es lo que hacía
inviable esta vía antes de que existiera.

> ⚠️ **Mide antes de creer.** "2-3× más lento" es un orden de magnitud, no una
> promesa: depende de tu máquina y de qué estés compilando. El ejercicio 6 te
> pide medirlo en la tuya y anotarlo, precisamente porque el número que importa
> es el tuyo.

---

## 5. Colima frente a Docker Desktop

Los dos funcionan sin cambiar una línea del proyecto: el código es agnóstico del
runtime y los comandos `docker` y `docker compose` son idénticos. La elección es
de consumo y de gusto.

| | Colima | Docker Desktop |
|---|---|---|
| RAM en reposo | ~2 GB | 6-8 GB |
| GUI | No | Sí |
| amd64 en Apple Silicon | VZ + Rosetta 2 | Rosetta (activar en Settings) |

Si usas Docker Desktop, activa "Use Rosetta for x86_64/amd64 emulation on Apple
Silicon" en Settings o la vía amd64 de §4 va a ir mucho más lenta de lo
necesario.

El proyecto recomienda Colima (D13) por la RAM: en una máquina de 16 GB, seis de
consumo en reposo es la diferencia entre tener el editor, el navegador con
DevTools y el contenedor abiertos, o ir cerrando cosas.

---

## 6. Windows dentro de macOS

Solo para incidentes que **únicamente** ocurren en Windows: separadores de ruta,
finales de línea CRLF, permisos NTFS, o un `npm script` que usa sintaxis de
shell POSIX y en `cmd` no corre.

Dos vías en Apple Silicon:

**UTM** — gratis, basado en QEMU, corre Windows 11 ARM Insider Preview. Setup de
una a dos horas. Suficiente para reproducciones puntuales, incómodo para
trabajar a diario.

**Parallels o VMware Fusion** — mejor integración con el host (portapapeles,
carpetas compartidas, escalado), más pesados. Parallels es de pago; Fusion tiene
licencia gratuita para uso personal.

No es requisito del tutorial. Es un recurso del track forense para cuando un
incidente lo justifique, y la recomendación práctica es no montarlo hasta que
ese incidente exista.

---

## 7. La regla del `node_modules`, la que más caro sale

Si te llevas una sola cosa de este apéndice, que sea esta:

> ⚠️ **Nunca compartas `node_modules` entre arquitecturas distintas.**

El `docker-compose.yml` de §3 declara `node_modules` como **volumen nombrado**,
no como bind mount del host. Eso no es un detalle de configuración: es lo único
que impide que el `node_modules` de tu macOS arm64 —con sus binarios compilados
para arm64-darwin— quede montado dentro de un contenedor Linux que espera
binarios linux-amd64.

Cuando eso pasa, el síntoma es desconcertante: la app compila en un lado y falla
en el otro con errores de módulo nativo que no mencionan la arquitectura por
ningún lado. Se pierden horas buscando en el código un problema que está en el
montaje.

El volumen nombrado mantiene el `node_modules` compilado **dentro** del
contenedor, aislado del host. El precio es que `npm ci` hay que correrlo una vez
dentro; a cambio, el problema desaparece para siempre.

---

## 🧩 Cuándo usar qué

- **Estás escribiendo una feature** → nativo, la vía más rápida de tu sistema
  operativo. Sin contenedor.
- **Un test pasa local y falla en CI** → contenedor Linux (§3), y si sigue sin
  reproducir, amd64 (§4).
- **"En mi máquina anda" entre dos compañeros** → antes de contenedorizar,
  compara `node -v`, `npm -v` y el lockfile. Nueve de cada diez veces es eso
  (`A3-node-y-npm.md` §7).
- **Un bug solo aparece en producción** → §4, paridad exacta. Es la única vía que
  descarta la arquitectura como variable.
- **Un bug solo aparece en Windows** → §6, y solo entonces.
- **Errores raros de binarios al cambiar de entorno** → §7, casi seguro es el
  `node_modules`.

---

## 🧪 Ejercicios (8)

1. **🟢** Levanta el proyecto con Colima arm64 (§3) y confirma que `npm start`
   responde en `localhost:3000` desde el navegador del host. Anota cuánto tardó
   el primer `npm ci` dentro del contenedor.
2. **🟢** Con el contenedor corriendo, ejecuta `docker compose exec react node -v`
   y compáralo con el `node -v` de tu host. Explica en dos líneas por qué pueden
   diferir y por qué el `.nvmrc` no aplica dentro del contenedor.
3. **🟡** Levanta el servicio `mock` del `docker-compose.yml` y confirma que
   `localhost:3001/raffles` y `localhost:3002/results/1` responden desde el
   navegador del host. Si alguno no responde, diagnostica si es el mapeo de
   puertos o el `--host 0.0.0.0`.
4. **🟡** Alterna entre Colima y Docker Desktop sin tocar el proyecto: apaga uno,
   enciende el otro, levanta el mismo `docker compose up`. Documenta los pasos y
   la diferencia de RAM en reposo que mide tu Mac.
5. **🟠 Diagnóstico.** Cambia el `docker-compose.yml` para montar el
   `node_modules` del host (`- ./node_modules:/app/node_modules`) en vez del
   volumen nombrado. Levanta, corre `npm start` y **captura el error exacto**.
   Explica por qué el mensaje no menciona la arquitectura y cómo llegarías a la
   causa desde ese síntoma. Revierte al terminar.
6. **🟠** Migra de la vía arm64 (§3) a la amd64 vz-rosetta (§4). Mide con `time`
   cuánto tarda `npm ci` y cuánto tarda el arranque de `npm start` en cada una.
   Anota los cuatro números y calcula el factor real en tu máquina. Explica en
   qué situación pagarías esa diferencia.
7. **🔴 Diagnóstico integrado.** Un compañero reporta que un test de la Fase 10
   pasa en su Mac y falla en el CI (Linux amd64). Diseña el plan de
   reproducción: qué vía eliges, en qué orden descartas variables (versión de
   Node, arquitectura, sistema operativo, zona horaria del contenedor), y qué
   evidencia recoges en cada paso. No hace falta que lo ejecutes: el entregable
   es el plan.
8. **🔴** Escribe un script `bash` que detecte la plataforma —Windows, Linux,
   macOS arm64, macOS x86_64— y le imprima al usuario la vía de setup
   recomendada de §2 con sus comandos exactos. Pruébalo al menos en tu propia
   máquina. Es el entregable que ojalá existiera en todo proyecto legacy y nunca
   existe.

**🔥 Opcionales**

- 🔥 Configura VS Code Dev Containers para abrir el proyecto directamente dentro
  del contenedor de Colima, y compara la experiencia de debugging contra el
  entorno nativo.
- 🔥 Monta una VM de Windows con UTM (§6) y reproduce un bug de finales de línea:
  commitea un archivo con CRLF desde la VM y mira qué le pasa al `git diff` en
  el host.

---

## 📚 Referencias

**Documentación oficial**

- Colima — https://github.com/abiosoft/colima — instalación, `colima start` y
  sus flags de arquitectura.
- Docker Compose — https://docs.docker.com/compose/ — referencia de la sintaxis
  de servicios y volúmenes. Ojo: la doc actual cubre Compose V2; la clave
  `version:` de V1 ya no hace falta y por eso no aparece en nuestros ejemplos.
- Imágenes oficiales de Node — https://hub.docker.com/_/node — para confirmar
  qué tags existen (`14.21.3-bullseye`, `14.21.3-alpine`) y en qué
  arquitecturas.
- nvm (Unix) — https://github.com/nvm-sh/nvm
- nvm-windows — https://github.com/coreybutler/nvm-windows — proyecto distinto,
  para Windows.
- UTM — https://mac.getutm.app/ — para levantar Windows 11 en Apple Silicon.
- Rosetta 2 en contenedores Linux —
  https://developer.apple.com/documentation/virtualization — el fundamento de
  `--vz-rosetta`.

**Orden de lectura sugerido:** §1 para decidir si de verdad necesitas esto →
§2 para elegir vía → la sección de tu vía (§3, §4 o §6) → §7 **siempre**, porque
es el error que vas a cometer.

> ⚠️ Las URLs y los nombres de comandos pueden haber cambiado: Colima y Docker
> Desktop iteran rápido, y varios flags de este apéndice son relativamente
> recientes. Verifica contra `colima --help` y `docker compose --help` de tu
> instalación antes de dar por bueno un comando que copies de acá.

---

## 🚀 Y ahora, de vuelta al código

Si viniste desde la Fase 0, ya tienes lo que necesitabas: vuelve a §5.4 y sigue
con `.nvmrc` y la creación del CRA. Si viniste persiguiendo un bug de entorno,
el paso siguiente es el incidente **02** del `cuaderno-incidentes.md`, que es
exactamente este problema con un ticket delante.

> **La señal de que quedó bien:** cuando alguien diga "en mi máquina anda" y tu
> primera reacción no sea montar un contenedor, sino preguntar tres cosas —qué
> Node, qué lockfile, qué sistema operativo— y resolverlo sin contenedor en el
> 90% de los casos.

---

> 🏷️ **Este apéndice deja código: márcalo.** Cuando termines lo que viniste a
> hacer acá, con `git status` limpio:
>
> ```bash
> git tag -a apendice-a9-entornos-y-contenedores -m "A9: entorno resuelto — Dockerfile y compose funcionando, o la decisión
> escrita de no usar contenedor y por qué."
> ```
>
> Los commits llevan su prefijo (`a9: …`) y los de ejercicio su número
> (`a9 ej3: …`). La convención completa —tags de fase, de ejercicio y de
> incidente— está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
