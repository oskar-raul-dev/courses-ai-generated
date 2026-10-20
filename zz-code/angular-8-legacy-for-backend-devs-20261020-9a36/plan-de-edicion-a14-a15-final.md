# Plan de edición — Apéndices de contenedor amd64 (Docker Desktop + VS Code)

> Desechable. Historia de este plan: se abrió el 14/10/2026 para una sola tanda (T0–T9).
> Se borra cuando el autor lo autorice. Nada de lo que dice aquí se cita desde el curso.

## 1. Pedido

Un apéndice (o dos, si el largo lo exige) para **LabCore** que enseñe a:

- crear un contenedor **linux/amd64 emulado** en Docker Desktop, con **Node 14.21.3** (la misma base que la Fase 13: `node:14.21.3-bullseye-slim`);
- levantar dentro de él la **base del proyecto Angular 8** (ng new con CLI 8.3.29, `npm ci` contra el lockfile de A03, `ng build`, `ng test`, `ng serve`);
- trabajar, **probar y depurar** desde VS Code con la extensión Dev Containers;
- en copiar y pegar, con referencia por nombre al curso de contenedores legacy (`cursos-contenedores-cloud-infra/docker-container-legacy`) para el detalle.

Excepción explícita al formato de apéndice: **sin ejercicios**. Va declarada en la guía (ver D3).

## 2. Veredicto de viabilidad

**Viable.** Lo verificado hoy en esta máquina:

| Punto | Estado | Evidencia |
|---|---|---|
| Docker Desktop disponible | ✅ | `docker version`: servidor `linux/arm64` 29.8.0, contexto `desktop-linux` activo |
| Imagen con variante amd64 | ✅ | `docker manifest inspect node:14.21.3-bullseye-slim` lista `amd64`, `arm64`, `arm`, `ppc64le`, `s390x` |
| VS Code + Dev Containers | ✅ | `/opt/homebrew/bin/code`; `ms-vscode-remote.remote-containers-0.470.0` instalada |
| Esqueleto Angular 8 de T1 para comparar | ✅ | `zz-code/angular-8-legacy-for-backend-devs-20261007-defa/esqueleto/clinical-lab` |
| Material previo | ✅ parcial | A13 §4 (perfil amd64 de Colima), §6 (devcontainer), §7 (`--platform`); A12 §5 (Chromium para Karma); container course `21-arquitecturas-y-emulacion`, `10-vscode-y-debugging`, `19-dev-containers` |

**Riesgos que la prueba tiene que medir, no suponer:**

1. **Lentitud.** `npm ci` y `ng build` bajo emulación pueden tardar varias veces lo que en arm64 nativo. Hay que medir y publicar el número, no decir "un poco más lento".
2. **`node-sass` 4.14.1 en linux-x64/Node 14.** Necesita el binario precompilado desde GitHub (red) o compilar con `python`/`g++`. La prueba decide cuál de los dos camina y lo anota.
3. **Chromium para Karma.** En bullseye amd64 hay que instalarlo dentro de la imagen y correr con `--no-sandbox` en headless. Se prueba.
4. **Plataforma en el devcontainer.** `devcontainer.json` no tiene un campo `platform` simple para el build. Hay que probar dos caminos: `docker-compose` con `platform: linux/amd64`, o `runArgs: ["--platform=linux/amd64"]`. Se elige el que funcione y se explica por qué.
5. **Emulación: Rosetta o QEMU.** Docker Desktop ofrece ambos para amd64 en Apple Silicon. Hay que confirmar cuál está activo en esta máquina (`docker info`, `uname -m` dentro del contenedor) y documentar los dos pasos de la configuración.
6. **Depuración desde VS Code.** La UI no la puedo manejar yo. Lo que sí se prueba aquí: el puerto del inspector responde desde el host (`/json` del inspector) y el `ng serve` escucha en `0.0.0.0`. El "breakpoint se detiene" queda como **paso manual de Oskar**, declarado como tal en el apéndice (memoria: lo no contenerizable se le pide con `!`).
7. **Licencia de Docker Desktop.** Para empresas grandes es de pago. Va como advertencia, con fecha de verificación, no como afirmación fija.

## 3. Estado de partida

- LabCore tiene **13 apéndices** (`a01`–`a13`). A13 ya escribe el `.devcontainer/` **para Colima**. El apéndice nuevo no puede contradecirlo ni repetirlo completo.
- La guía (`prompts/guia-de-estilo-y-convenciones.md`, líneas ~456 y ~503) dice que los apéndices usan 5-10 ejercicios cortos. La excepción de "sin ejercicios" **no está declarada**: tiene que entrar en la guía, porque el CLAUDE.md del repo lo exige.
- README: tabla de 13 apéndices y el texto "los trece apéndices" (líneas ~93, ~220, ~236).
- Fases que enlazan apéndices de entorno: Fase 0 (A03, A12, A13), Fase 13 (A09, A13), Fase 14 (A09, A12, A13).
- Memoria del curso (feedback de pruebas): pruebas dentro de contenedor; **sin puertos por defecto**; puerto del host en `127.0.0.1::PUERTO` aleatorio; etiqueta `curso=angular-8-legacy`; **nunca `prune`**; borrar solo lo que esta sesión creó; inventario inicial a log.

## 4. Decisiones (cerradas por Oskar el 14/10/2026)

- **D1 · Número y partición:** A14 y A15, como se propuso. A15 solo si A14 pasa de ~400 líneas.
- **D2 · Relación con A13:** A14 es la ruta Docker Desktop; A13 sigue siendo Colima, con puntero desde §6.
- **D3 · Sin ejercicios:** sí, excepción declarada en la guía, con su porqué.
- **D4 · Tag:** ninguno. Prefijo de commit `f00:`.
- **D5 · Navegación:** Fases 0 y 13 enlazan A14; A14 enlaza el curso de contenedores por nombre y capítulo.
- **D6 · Alcance (ajustado):** solo macOS con Docker Desktop. Windows y Linux quedan fuera, porque allí Node 14 se instala con nvm y no hace falta emulación. Se dice en el apéndice.

### Decisiones originales (referencia)

- **D1 · Número y partición.** Propuesta: `a14-docker-desktop-amd64-vscode.md` (receta: setup de Docker Desktop, Dockerfile, devcontainer, base Angular 8, comandos de copiar y pegar) y, solo si pasa de unas ~400 líneas, `a15-depurar-en-el-contenedor.md` (launch.json, adjuntar el depurador, Karma, pasos manuales). Sin tercero.
- **D2 · Relación con A13.** Propuesta: A14 es la ruta **Docker Desktop**; A13 sigue siendo la ruta **Colima**. A13 §6 recibe un puntero a A14, sin cambiar su contenido. Dos devcontainers distintos en el mismo repo colisionan: A14 explica cuál usar según el motor.
- **D3 · Sin ejercicios.** Propuesta: sí, excepción declarada en la guía con su porqué ("apéndice de receta: la verificación es correr los pasos, y cada paso ya tiene su comprobación"). El apéndice tiene sección de "Cómo saber que funcionó" en vez de ejercicios.
- **D4 · Tag de git.** Propuesta: sin tag (regla de la guía para apéndices), con prefijo de commit `f00:` (la fase desde la que se llega, Fase 0). Sin excepción nueva.
- **D5 · Navegación.** Propuesta: Fase 0 y Fase 13 enlazan A14; A14 enlaza el curso de contenedores por nombre de carpeta y capítulo (21, 10, 19), no por ruta relativa frágil.
- **D6 · Alcance de la prueba.** Propuesta: Mac arm64 con Docker Desktop, que es lo que hay aquí. Windows y Linux quedan fuera de esta tanda, declarado en el apéndice.

## 5. Tanda única T0–T9

Todo se ejecuta **dentro de contenedores**, con etiqueta `curso=angular-8-legacy` y puerto del host aleatorio en `127.0.0.1`. Salidas a `zz-code/angular-8-legacy-for-backend-devs-20261014-amd64/`.

- **T0 · Inventario y log (solo lectura).** `docker ps -a`, `docker images`, `docker volume ls`, `docker network ls`, `docker context ls`, `docker info` a `salidas/inventario-inicial.txt`. Sin borrar nada ajeno. Confirma el estado de partida antes de tocar Docker.
- **T1 · Configuración de Docker Desktop y emulación.** Registrar Rosetta o QEMU activo; probar `uname -m` y `node -v` con la imagen amd64 (ver T2 abajo, que pasa a ser parte de esta).
- **T2 · Dockerfile y devcontainer.** Dos variantes (`docker-compose` con `platform` y `runArgs`), elegir una y justificar en la salida. Usuario `node`, no root. Chromium y dependencias nativas (lista de A12 §4, versión Linux).
- **T3 · Base Angular 8 dentro del contenedor.** `npm i -g @angular/cli@8.3.29`, `ng new clinical-lab` con el CLI 8, lockfile y versiones de A03 (Angular 8.2.14, TypeScript 3.5.3). Medir tiempo de `npm ci` y de `ng new`.
- **T4 · Build, test y serve.** `ng build` (medir), `ng test --watch=false --browsers=ChromeHeadlessNoSandbox`, `ng serve --host 0.0.0.0` con el puerto mapeado y `curl` desde el host. Comprobar `node-sass` (T4 decide el camino).
- **T5 · Depuración.** Config de `launch.json` para adjuntar a Node y a Karma; verificar desde el host que el inspector responde (`curl http://127.0.0.1:PUERTO/json`). El breakpoint en la UI queda como paso manual.
- **T6 · Redacción del apéndice A14** (y A15 si D1 lo pide), con copiar y pegar y "cómo saber que funcionó" en cada bloque. Cada comando del apéndice se corre en T2–T6 antes de darlo por bueno.
- **T7 · Enlaces y declaraciones.** Puntero desde A13 §6 y desde Fases 0 y 13; README (tabla, conteo 13 → 14/15, texto "los trece apéndices"); guía: excepción de D3 con su porqué.
- **T8 · Verificación.** `verificar-curso.py` y `verificar-secciones.py` del archivo de zz-code, más revisión de continuidad (nombres, versiones 8.2.14 / 14.21.3 / 8.3.29, puertos, etiquetas).
- **T9 · Limpieza.** Detener los contenedores de la sesión. Borrar solo los que tengan etiqueta `curso=angular-8-legacy` y que la sesión creó. Nada de `prune`. Dejar `inventario-final.txt` para comparar con el inicial.

## 6. Criterios de cierre

- Cada comando de los apéndices se corrió dentro de un contenedor y su salida está en `zz-code/…-20261014-amd64/salidas/`.
- `uname -m` = `x86_64` y `node -v` = `v14.21.3` dentro del contenedor.
- `ng build`, `ng test` y `ng serve` (con `curl` desde el host) pasan.
- Los tiempos medidos están en el apéndice con su máquina y modo de emulación.
- Verificadores del curso en 0 errores y 0 referencias rotas.
- El paso de breakpoint en VS Code está marcado como manual.

## 7. Fuera de alcance

- No se toca el contenido de A13 más allá del puntero.
- No se toca el curso de contenedores (`cursos-contenedores-cloud-infra/`).
- No se hace commit (el git lo maneja Oskar).

## 8. Estado

- [x] Viabilidad verificada (§2).
- [x] D1–D6 cerradas por Oskar (14/10/2026); D6 acotada a macOS.
- [x] T0 · inventario inicial (14/10/2026). Salida: `zz-code/angular-8-legacy-for-backend-devs-20261014-amd64/salidas/inventario-inicial.txt` (95 líneas). Hallazgos:
  - Docker Desktop 29.8.0, arquitectura `aarch64`, 8 CPU y ~8 GB de RAM asignados. Con 8 GB, `ng build` bajo emulación puede ser lento o quedarse sin memoria; hay que medirlo y, si hace falta, subir la RAM en Docker Desktop (decisión de Oskar).
  - Hay 5 contenedores corriendo de otros cursos y proyectos (ruta-sql, ev-lab, fgapp-dev, alameda-lab). No se tocan.
  - Ningún recurso con `curso=angular-8-legacy` existe todavía. Esa es la línea base.
- [x] T1 · Rosetta activo + prueba amd64 (14/10/2026). Salida: `zz-code/angular-8-legacy-for-backend-devs-20261014-amd64/salidas/t1-emulacion.txt` y `t1-amd64-check.txt`. Hallazgos:
  - Emulación: **Rosetta** (no QEMU). `UseVirtualizationFramework: true` y la VM arranca con `--rosetta`; `oahd` activo en el host.
  - Dentro de `--platform linux/amd64`: `uname -m` = `x86_64`, `node -v` = `v14.21.3`, `npm -v` = 6.14.18, Debian 11 (bullseye).
  - La imagen `node:14.21.3-bullseye-slim` no estaba en el inventario; se descargó en T1. Es imagen, no contenedor; sin borrar.
  - No hizo falta cambiar nada en la configuración de Docker Desktop.
- [x] T2 · Dockerfile y devcontainer (14/10/2026). Elegida la variante **compose** (`platform: linux/amd64` en el servicio). `runArgs --platform` da build arm64 y `pull access denied` al correr. Hallazgos: apt de bullseye (404 en debian-security) → archive.debian.org; `ca-certificates` ausente; dependencia `file-saver` de GitHub por ssh/git:// → `insteadOf` a https. Registro: `zz-code/…-20261014-amd64/salidas/registro-T2-T5.txt`.
- [x] T3 · Base Angular 8 (14/10/2026). CLI 8.3.29 global; `ng new` en el FS del contenedor. El lockfile de `esqueleto/` es anterior (sin karma, mock, node-sass ni jspdf): **no** sirve como lock de A03. Se generó el lock desde el manifiesto de A03 §8.1 con npm 6 (lockfileVersion 1). Añadidos al manifiesto: `@types/jasmine` y `@types/node ~8.9.4` (sin el segundo, instalación en frío resuelve 26.x y TS 3.5 no compila). Medidos: npm install 82 s con caché, 140–166 s en frío; npm ci 52–87 s.
- [x] T4 · Build, test y serve (14/10/2026). `ng build` 73–99 s; `ng test` 3/3 SUCCESS con `ChromeHeadlessNoSandbox`; `ng serve` 200 desde el host. node-sass 4.14.1: binario linux-x64-83 descargado de GitHub (camino A); el camino B (compilar) no se probó. Karma: el `karma.conf.js` de `ng new` no sirve (reporter kjhtml fuera del manifiesto); se usa la forma de Fase 12 §5.1 más el lanzador.
- [x] T5 · Depuración (14/10/2026). Trampa verificada: `npx ng serve` con `NODE_OPTIONS=--inspect` deja el inspector en el proceso `npx`; se usa `node node_modules/@angular/cli/bin/ng`. Inspector de ng serve (9229) y de ng test (9230) responden desde el host; `--inspect-brk` deja Karma en pausa. El breakpoint en VS Code queda **manual** (§6 de este plan).
- [x] T6 · Redacción de A14 y A15 (14/10/2026). Se separó A15 (depuración) porque A14 superaba ~400 líneas (D1). Sin ejercicios en ambos (D3). Bloques de A14 comparados con los archivos probados: Dockerfile e IGUAL; devcontainer difiere solo en comentarios; compose IGUAL.
- [x] T7 · Enlaces y declaraciones (14/10/2026). A13 §6: puntero a A14, sin cambiar contenido. Fases 0 y 13: enlace a A14. README: quince apéndices (tabla con A14 y A15). Guía: excepción de «sin ejercicios» para A14 y A15 con su porqué; A14 sin tag (D4), prefijo `f00:`.
- [x] T8 · Verificación (14/10/2026). `verificar-curso.py`: 85 documentos, 0 errores. `verificar-secciones.py`: 0 referencias rotas. Corrida limpia de §6 y §7 de A14 con contenedor nuevo y caché de imagen y de npm vacías: pasa (`salidas/registro-corrida-limpia.txt`). Puertos §8 y A15 verificados. Corrección hecha por la corrida limpia: `@types/node`.
- [x] T9 · Limpieza (14/10/2026). Retirados solo los contenedores y volúmenes con `curso=angular-8-legacy` de esta sesión y las imágenes de prueba `clinical-lab-amd64-app` y `t2-variante-b:test`. Sin `prune`. Quedan `node:14.21.3-bullseye-slim` (pull de esta sesión, base de la Fase 13) y `node:14.21.3` (no se tocó). Inventario: `salidas/inventario-final.txt`.

**Actualizado el 14/10/2026 (tras T9):**
- Manifiesto de A03 §8.1: se añadieron `@types/jasmine ^3.4.6` y `@types/node ~8.9.4`. Es el mismo conjunto de dependencias que probó la corrida limpia. A14 y A15 se ajustaron.
- `file-saver` (GitHub) se deja tal cual, documentado en A14 §3 y §8.
- Plan de edición: se conserva (no se borra hasta que lo autorices).

**Pendiente, para Oskar:** (1) decidir si el lockfile de LabCore se versiona y de dónde sale (hoy se genera en A14 §6.4); (2) el breakpoint en la interfaz de VS Code (A15 §5, manual) y los breakpoints de specs en Chromium (A15 §4, sin probar); (3) el Dockerfile de A13 §6 tiene las trampas de apt y certificados y un `sudo` sin instalar: no se tocó, fuera del puntero; (4) camino B de node-sass (compilación) sin probar; (5) los commits los haces tú.

**19/10/2026:** los pendientes (3) y (4) pasan a `_desechable-plan-apple-silicon.md`; esa misma noche, también
(1) y (2), al final de su §8. **Este plan ya no tiene trabajo abierto: T0–T9 cerradas y sus pendientes absorbidos.
Se puede borrar con permiso del autor.**
