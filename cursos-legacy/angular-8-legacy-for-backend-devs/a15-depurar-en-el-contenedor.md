# 📎 Apéndice A15 — 🔎 Depurar dentro del contenedor amd64

> Tutorial Angular 8 — Laboratorio clínico · Receta · **1h**
> Usado por: A14 · Versión cubierta: la del devcontainer de **A14 §4** (Node 14.21.3, Angular CLI 8.3.29, Docker Desktop en macOS con chip M) · Probado el 14/10/2026
> Estado: 🔥 **Opcional por plataforma.** Sigue a A14 y no se lee sin él.

Este apéndice continúa **A14**: ya tienes el contenedor, la base de LabCore corriendo y `ng serve` respondiendo. Aquí lo conectas al depurador de VS Code. Son dos piezas distintas, y conviene separarlas desde el principio:

- **El inspector de Node.** El proceso `ng serve` y el proceso que orquesta `ng test` corren en Node. Se adjuntan por el protocolo de inspección, en el puerto 9229 y el 9230.
- **El navegador.** Los specs de Karma y la aplicación corren en Chromium. Un breakpoint dentro de código que ejecuta el navegador **no lo atrapa** el adjuntado a Node. Ese caso está fuera de lo que este apéndice verifica (ver §4).

Lo que se verificó: que los dos inspectores responden desde el Mac, y que el adjuntado apunta al proceso correcto. **El breakpoint dentro de la interfaz de VS Code es un paso manual**: quien lo lea lo comprueba con sus propios ojos (§5).

> 📝 **Este apéndice no tiene ejercicios.** Igual que A14, es una receta y la verificación es correr los pasos. La excepción está declarada en la guía de estilo.

---

## Índice

- [1. El inspector y una trampa de `npx`](#1-el-inspector-y-una-trampa-de-npx)
- [2. `ng serve` con inspector](#2-ng-serve-con-inspector)
- [3. La configuración de VS Code](#3-la-configuración-de-vs-code)
- [4. Karma: qué adjuntar y qué no](#4-karma-qué-adjuntar-y-qué-no)
- [5. El paso manual: el breakpoint](#5-el-paso-manual-el-breakpoint)
- [6. Cómo saber que funcionó](#6-cómo-saber-que-funcionó)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [📚 Referencias](#-referencias)

---

## 1. El inspector y una trampa de `npx`

Node abre el inspector con la variable `NODE_OPTIONS=--inspect=HOST:PUERTO`. Esa variable la hereda **todo proceso hijo**, y ahí está la trampa.

Si lanzas el CLI con `npx ng serve`, el proceso que recibe el puerto 9229 es **`npx`**, no `ng`: `npx` es un script de Node que arranca el CLI como hijo. Cuando el hijo intenta el mismo puerto, falla, y la aplicación sigue funcionando. Resultado: `ng serve` responde, pero VS Code adjuntado a 9229 se conecta al envoltorio, y los breakpoints no se detienen en nada.

Lo comprobamos así: con `npx`, el listado de targets del inspector devolvía un único proceso llamado `/usr/local/bin/npx`. Con `node` directo, devuelve `node_modules/@angular/cli/bin/ng`.

Por eso la receta **no usa `npx` para depurar**: invoca el CLI con `node` sobre su ejecutable.

---

## 2. `ng serve` con inspector

Dentro del contenedor, en una terminal:

```bash
cd /workspace
NODE_OPTIONS=--inspect=0.0.0.0:9229 node node_modules/@angular/cli/bin/ng serve --host 0.0.0.0 --poll 2000
```

- **`--inspect=0.0.0.0:9229`** abre el inspector en todas las interfaces del contenedor. Con `127.0.0.1`, el puerto no se alcanza desde el Mac.
- **`node node_modules/@angular/cli/bin/ng`** en vez de `npx ng`: §1.

Al arrancar verás dos líneas que parecen un error y no lo son:

```
Debugger listening on ws://0.0.0.0:9229/…
Starting inspector on 0.0.0.0:9229 failed: address already in use
```

La primera es el proceso que importa. La segunda es el proceso hijo que el CLI lanza con el mismo `NODE_OPTIONS` y que no puede repetir el puerto. Lo que decide si todo está bien es el listado de targets, no el texto del log.

Para comprobarlo desde el Mac (con el puerto 9229 publicado, ver **A14 §8**):

```bash
curl -s http://127.0.0.1:<PUERTO_9229>/json
```

Debe devolver un único objeto con `"type": "node"` y un `"title"` que termine en `node_modules/@angular/cli/bin/ng`. Si el título dice `npx`, vuelve a §1.

---

## 3. La configuración de VS Code

Crea `.vscode/launch.json` en la raíz del proyecto (en tu Mac, dentro de la carpeta montada). VS Code lo lee con la extensión de devcontainers abierta. Las rutas son **del contenedor**, por eso `remoteRoot` es `/workspace`:

```jsonc
// .vscode/launch.json
{
  "version": "0.2.0",
  "configurations": [
    {
      // 1. ng serve. Primero levántalo con el inspector (§2).
      "name": "Adjuntar a ng serve (9229)",
      "type": "node",
      "request": "attach",
      "address": "localhost",
      "port": 9229,
      "localRoot": "${workspaceFolder}",
      "remoteRoot": "/workspace",
      "restart": true,
      "skipFiles": ["<node_internals>/**", "${workspaceFolder}/node_modules/**"]
    },
    {
      // 2. Karma, lado Node (§4). Igual que el anterior, con otro puerto.
      "name": "Adjuntar a Karma, lado Node (9230)",
      "type": "node",
      "request": "attach",
      "address": "localhost",
      "port": 9230,
      "localRoot": "${workspaceFolder}",
      "remoteRoot": "/workspace",
      "skipFiles": ["<node_internals>/**", "${workspaceFolder}/node_modules/**"]
    }
  ]
}
```

`address` es `localhost` porque VS Code corre dentro del contenedor cuando el devcontainer está abierto, y los puertos 9229 y 9230 están reenviados al Mac por `forwardPorts` (**A14 §4**). `restart: true` hace que la sesión se vuelva a adjuntar si `ng serve` se reinicia.

---

## 4. Karma: qué adjuntar y qué no

`ng test` tiene dos partes. El **proceso de Node** orquesta: compila con webpack, levanta el servidor de Karma y lanza Chromium. Ese proceso se adjunta con la configuración 2 de §3:

```bash
cd /workspace
NODE_OPTIONS=--inspect=0.0.0.0:9230 node node_modules/@angular/cli/bin/ng test --watch=false --browsers=ChromeHeadlessNoSandbox
```

Con `--watch=false` la corrida termina en pocos segundos y el inspector se cierra con ella. Para depurar de verdad, quítalo: `ng test` queda observando y el inspector sigue abierto. Eso también verifica que el puerto responde: `curl -s http://127.0.0.1:<PUERTO_9230>/json` devuelve un target `node` cuyo título termina en `node_modules/@angular/cli/bin/ng`.

Los **specs** y el código de la aplicación corren en **Chromium**, no en Node. Un breakpoint dentro de un `it(…)` no se detiene con esta configuración: el código no está en el proceso que adjuntaste. Para ese caso hay dos caminos, y **ninguno lo verificamos en esta receta**: poner `debugger;` en el spec y abrir las herramientas de desarrollo de Chromium desde un navegador del Mac, o lanzar Chromium con un puerto de depuración remoto y adjuntar VS Code a ese puerto. Ese caso queda pendiente de probar en esta receta; no lo documentamos como si funcionara.

---

## 5. El paso manual: el breakpoint

Este paso **no lo puede hacer un script**: requiere la interfaz de VS Code. Elegimos un punto de ruptura que **corre en Node**, porque es lo que el adjuntado puede atrapar. `karma.conf.js` lo lee el proceso de `ng test` al arrancar.

1. En el contenedor, arranca `ng test` pausado en la primera línea, esperando al depurador:

   ```bash
   cd /workspace
   NODE_OPTIONS=--inspect-brk=0.0.0.0:9230 node node_modules/@angular/cli/bin/ng test --watch=false --browsers=ChromeHeadlessNoSandbox
   ```

   Verás `Debugger listening on ws://0.0.0.0:9230/…` y nada más: la suite no empieza hasta que adjuntes.

2. En VS Code, abre `karma.conf.js` y pon un breakpoint en la línea `basePath: '',`.
3. En **Run and Debug**, elige **Adjuntar a Karma, lado Node (9230)** y pulsa ▶.
4. **Esperado:** VS Code se detiene en `karma.conf.js`, la pila muestra archivos bajo `/workspace`, y al continuar la terminal empieza a ejecutar los specs (`Executed 3 of 3 SUCCESS`).

Si el breakpoint aparece en gris (*unbound*), revisa que `localRoot` y `remoteRoot` coincidan con §3, y que el target del inspector sea `node_modules/@angular/cli/bin/ng` (§2 y §4).

> ⚠️ **Lo que sí verificamos:** que `--inspect-brk` deja el proceso esperando (sin salida de Karma hasta adjuntar) y que el inspector responde desde el Mac con el target correcto. **No verificamos** el breakpoint dentro de VS Code: el paso 4 depende de tu sesión y lo confirmas tú.
>
> El mismo mecanismo con `ng serve` (§2) adjunta bien al servidor, pero el código de la aplicación corre en Chromium y ese breakpoint no se detiene aquí (§4).

---

## 6. Cómo saber que funcionó

1. **`ng serve` lleva el inspector del CLI.** `curl -s http://127.0.0.1:<PUERTO_9229>/json` devuelve un único target `node` con título `…/bin/ng`, no `npx`.
2. **La versión de Node es la del curso.** `curl -s http://127.0.0.1:<PUERTO_9229>/json/version` devuelve `node.js/v14.21.3`.
3. **Karma responde también.** Con `ng test` y el inspector en 9230, el mismo `curl` en ese puerto devuelve un target `node` con título `…/bin/ng`.
4. **Las pruebas siguen verdes.** `ng test --watch=false --browsers=ChromeHeadlessNoSandbox` termina con `TOTAL: 3 SUCCESS`.
5. **El breakpoint se detiene** (§5). Este punto lo confirmas tú.

---

## 🧭 Cuándo usar qué

| Situación | Qué haces | Por qué |
|---|---|---|
| Quieres ver por qué falla un servicio en el arranque | Breakpoint en `ng serve` (§2 y §3) | Ese código corre en Node |
| El fallo está en un spec | `debugger;` o un puerto de depuración de Chromium (§4) | Ese código corre en el navegador |
| Solo quieres ver un `console.log` | No hace falta depurar | Es más rápido que un inspector |
| La depuración te pide `npx` | No uses `npx` (§1) | Adjuntas al envoltorio |

---

## ⚠️ Advertencias

**El inspector escucha en `0.0.0.0` dentro del contenedor.** Solo lo alcanza quien tenga el puerto publicado, y el devcontainer lo publica en `127.0.0.1` del Mac. No lo expongas en una red compartida ni lo dejes abierto en una imagen publicada.

**Los breakpoints de los specs no están cubiertos.** Lo que se verificó es el lado Node de Karma. Un breakpoint en código del navegador no funciona con esta configuración, y no hay una receta probada para ese caso todavía.

**El paso de breakpoint es manual.** Este apéndice no lo puede verificar; declararlo así es parte de la receta.

---

## 📚 Referencias

- https://nodejs.org/en/docs/guides/debugging-getting-started — El protocolo de inspección de Node, `--inspect` y `NODE_OPTIONS`. Es la fuente de §1 y §2.
- https://code.visualstudio.com/docs/editor/debugging — La depuración en VS Code: *attach*, `launch.json` y los puntos de ruptura. Es la fuente de §3 y §5.
- https://karma-runner.github.io/latest/intro/configuration.html — La configuración de Karma y sus lanzadores, de donde sale `customLaunchers` de **A14 §7.1**.
