# Bitácora de ejecución · sesión 6edc206c-14b6-4874-8e4e-e3c76f720d90

Comandos que ejecutaron código, con el inicio de su salida.

### ⏱️ 2026-09-08T03:34:07Z · List headings of referenced appendices

~~~~~~bash
for f in a03-node-npm.md a04-webpack-oculto.md a05-rxjs.md a06-ngrx.md a07-i18n.md a08-pdf-cliente.md a09-kubernetes.md a12-arm64-m1.md a13-docker-colima.md; do echo "### $f"; grep -n "^## \|^### " $f | head -30; done
~~~~~~

~~~~~~text
### a03-node-npm.md
16:## Índice
33:## 1. Qué versión estás mirando
41:### 1.1 Las dos líneas del curso, y por qué son dos
67:### 1.2 macOS Apple Silicon: por qué la 12 no es una opción
78:### 1.3 Por qué acá la versión de **npm** importa más que la de Node
97:## 2. Tu `package.json` no fija nada
123:### 2.1 Y de ahí sale el otro `node_modules`
142:### 2.2 Por qué no se arregla pinneando todo a mano
150:## 3. El lockfile
184:### 3.1 Se commitea. No es negociable
190:### 3.2 Cómo se lee un `git diff` del lockfile sin desesperarse
212:## 4. `npm install` vs `npm ci`
237:## 5. `dependencies` vs `devDependencies`
246:### 5.1 Y ahora la parte donde tu instinto de backend miente
260:## 6. `--legacy-peer-deps` y el día que alguien llegue con npm 7
262:### 6.1 Qué es una peer dependency
266:### 6.2 El cambio de npm 6 a npm 7, que es el problema de verdad
278:### 6.3 Por qué el flag no es la solución, sino el parche
298:## 7. Scripts, el `--` y las variables de entorno
300:### 7.1 Por qué `ng` funciona sin instalarlo global
321:### 7.2 El `--`, que rompe builds y no está explicado en ningún sitio
333:### 7.3 Variables de entorno: la línea que no funciona en Windows
366:### 7.4 Los hooks que puedes heredar sin saberlo
374:## 8. Comparar tu proyecto heredado contra este stack
384:### 8.1 El `package.json` de LabCore, comentado
475:### 8.2 El diff, en tres comandos
494:### 8.3 Las tres formas del desajuste
526:### 8.4 Lo que NO se compara
549:## 🧭 Cuándo usar qué
571:## ⚠️ Advertencias
#
~~~~~~

### ⏱️ 2026-09-08T03:40:12Z · Inspect appendix insertion points

~~~~~~bash
sed -n '306,312p' a04-webpack-oculto.md; echo "---a05 210"; sed -n '210,214p;348,353p' a05-rxjs.md; echo "---a06 370 481"; sed -n '370,374p;481,485p' a06-ngrx.md; echo "---a07 369"; sed -n '369,373p' a07-i18n.md; echo "---a08 241"; sed -n '241,246p' a08-pdf-cliente.md; echo "---a09 296"; sed -n '296,300p' a09-kubernetes.md; echo "---a12 203"; sed -n '203,207p' a12-arm64-m1.md; echo "---a13 319"; sed -n '319,323p' a13-docker-colima.md
~~~~~~

~~~~~~text
## 6. Source maps y el stack trace de PROD

Un source map es un archivo `.map` que traduce una posición del bundle minificado —`main.9c4f.js:1:284712`— a la línea y columna del `.ts` original. Sin él, el stack trace de un error de producción es una coordenada dentro de una sola línea de 1.2 MB, y no sirve para nada.

**Este proyecto los genera en producción y los deja viajar dentro de la imagen.** El CLI 8 genera `"sourceMap": false` en su configuración de producción; acá está en `true` a propósito:

```jsonc
---a05 210
## 6. `switchMap` vs `mergeMap` — la decisión que pierde datos

**La sección central de este apéndice.** Los dos hacen lo mismo: reciben un valor y arrancan con él un observable nuevo (típicamente una petición HTTP). La diferencia está en qué hacen cuando llega un **segundo** valor antes de que el primero termine.

- **`switchMap` cancela el anterior.** Se desuscribe del observable en curso —lo que en HTTP significa abortar la petición— y se queda solo con el último. *Switch* = cambiar de canal.
## 9. La suscripción: quién la cierra

Un observable no hace **nada** hasta que alguien se suscribe. `subscribe()` es lo que abre el canal, y devuelve una `Subscription`, que es el objeto con el que se cierra. Mientras nadie lo cierre, el callback se sigue ejecutando cada vez que la fuente emita — aunque el componente que lo abrió ya no esté en pantalla.

Si vienes de backend, la analogía es exacta: **es un connection leak**. Abriste algo que consume recursos y no lo c
~~~~~~

### ⏱️ 2026-09-08T03:41:28Z · Check template placeholder and cross-course links

~~~~~~bash
grep -n "forense-fase-NN" prompts/formato-piezas-forenses.md | cut -c1-140; echo "=== docker-container-legacy refs ==="; grep -oh "\](\.\./docker-container-legacy[^)]*)" a*.md | sort -u | sed 's/^](//;s/)$//' | while read f; do [ -f "$f" ] && echo "OK  $f" || echo "ROTO $f"; done
~~~~~~

~~~~~~text
5:construyen `forense-master.md` y los quince `forense-fase-NN.md`, que son los
69:## 3. Estructura de un `forense-fase-NN.md`
134:| Va en la sección 6 de la fase | Va en `forense-fase-NN.md` |
=== docker-container-legacy refs ===
OK  ../docker-container-legacy/0-programa-del-curso.md
OK  ../docker-container-legacy/19-dev-containers.md
OK  ../docker-container-legacy/21-arquitecturas-y-emulacion.md
OK  ../docker-container-legacy/22-apple-silicon-y-hosts.md
OK  ../docker-container-legacy/23-estudios-de-caso-multiplataforma.md
OK  ../docker-container-legacy/README.md
~~~~~~

