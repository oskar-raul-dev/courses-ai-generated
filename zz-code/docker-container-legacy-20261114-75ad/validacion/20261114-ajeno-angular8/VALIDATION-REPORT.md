# Validation Report

## Identificación
- Proyecto: `t-hnh10/angular-8-app` (GitHub, archivado), clonado en `proyectos/ajeno-angular8`
- Commit: 4443bf9 ("updated outdated packages")
- Fecha UTC: 2026-11-14
- Framework y versión: Angular 9.1.1 y CLI 9.1.1 según `package.json`; el README dice "generated with Angular CLI version 8.3.24" y el nombre del repo dice Angular 8
- Fixture de referencia usado: `20-angular8-min` (el más cercano; la matriz de F11 dio ✅ en Node 10 y 12)

## Source snapshot
- package-lock.json SHA-256: 0154fcd768d55605f594dfd6fa4694718b39ccaf3ba8c5967dc18b1c2fc9acbe (lockfileVersion 1 → npm 6)
- working tree limpio: sí (antes y después; `dist/` y `node_modules/` están en `.gitignore`)

## Toolchain
- Imagen y tag: `legacy-node-toolchain:phase15`
- Image ID: sha256:035c5f9ba87909e9395c3ca1b63f654cefd40d5b18ae2e7e62dc1a167fcfa78d
- Plataforma: linux/amd64, emulada (Rosetta) en macOS Apple Silicon, Docker Desktop 29.9.3
- Debian: 10 (buster)
- Node: v12.22.12 · npm: 6.14.16 · ABI: 72

## Hipótesis inicial
- Node esperado: 12. Sin `.nvmrc` ni `engines`; el README miente sobre la versión (8.3.24 contra el 9.1.1 instalado). Angular 9 declara Node 10.13+ o 12.11+, y el lock es v1 (npm 6): las dos generaciones valen, y 12 es la que el CLI 9 recomendaba.
- Evidencia que la sostiene: `package.json` (`@angular/core ^9.1.1`, `typescript ^3.8.3`), `lockfileVersion: 1`, commit "updated outdated packages" (la subida de 8 a 9 sin tocar el README).
- Riesgos identificados: ningún addon nativo en el árbol (sin `node-sass`, `fsevents` solo opcional); tests con Karma y Chrome; `ng lint` con TSLint.

## Resultado
| Nivel | Etapa | Comando | Exit code | Resultado |
|---|---|---|---:|---|
| 2 | Install | npm ci | 0 | 1.447 paquetes en 56 s; `postinstall` del CLI sin errores |
| 3 | Tests | npm test -- --watch=false | 1 | N/A: Karma pide Chrome (`No binary for Chrome browser on your platform`) |
| 3 | Lint | npm run lint | 1 | 6 errores de estilo **del código** (TSLint sí está declarado): tipos triviales, espacios finales, `let` sin reasignar, `Object` como tipo |
| 4 | Build | npm run build | 0 | 84 s; un aviso (`environment.prod.ts` en la compilación sin usar) |
| 5 | Run | npm start -- --host 0.0.0.0 | 0 | `Compiled successfully`, escuchando en 0.0.0.0:4200 |
| 5 | HTTP | curl -sI localhost:4200 | 0 | HTTP/1.1 200 OK al sexto intento (~18 s) |
| 6 | Watch | — | — | no probado |

## Veredicto
- Nivel alcanzado (1–7): 5, con dos agujeros declarados en el 3
- Compatible para: instalar, construir y servir en Node 12.22.12
- NO compatible para: correr sus unit tests sin navegador; pasar su propio lint, que falla por el código, no por el entorno

## Lo que no se pudo determinar
- Si el autor lo usó alguna vez con Node 10: Angular 9 lo admitiría; no se probó.
- Si los tests pasan: hace falta Chrome Headless (a09) o un `karma.conf.js` con `ChromeHeadless` y `singleRun`.
- Qué versión "manda": el README (8.3.24) o el `package.json` (9.1.1). Se tomó el lock como verdad, que es lo que instala `npm ci`.
- El e2e (Protractor) no se intentó: necesita navegador y un servidor Selenium.

## Reproducir
- `docker volume create ajeno-node12-modules`
- `docker run -d --name p5-ajeno --platform linux/amd64 -e NODE_VERSION=12.22.12 --mount type=bind,src=$PWD,dst=/workspace --mount type=volume,src=ajeno-node12-modules,dst=/workspace/node_modules legacy-node-toolchain:phase15 sleep infinity`
- `docker exec p5-ajeno npm ci`, `npm run build`, `npm start -- --host 0.0.0.0`
- `docker exec p5-ajeno curl -sI http://localhost:4200`
- Script completo: `experimentos/ajeno.sh`; logs en este directorio.
