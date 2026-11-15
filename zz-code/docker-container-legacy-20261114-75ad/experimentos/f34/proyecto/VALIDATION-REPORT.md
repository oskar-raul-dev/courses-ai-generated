# Validation Report

## Identificación
- Proyecto: LabCore (`clinical-lab`), copia de zz-code `angular-8-legacy-for-backend-devs-20261020-8dfa/host-labcore`
- Commit: fb8c47c (repositorio local de la pasada)
- Fecha UTC: 2026-11-14
- Framework y versión: Angular 8.2.14, CLI 8.3.29, `node-sass` 4.14.1
- Fixture de referencia usado: `00-node-smoke` (12 ceros de 12 en las cuatro generaciones)

## Source snapshot
- package-lock.json SHA-256: 5db55ff87820593eb5b2b480fc48fd3fbd0516df3c321e42b88f76b5f647e8c2
- working tree limpio: sí

## Toolchain
- Imagen y tag: `legacy-node-toolchain:phase09`
- Image ID: sha256:79001bfad401d27af5007709c8198cd04f91c19235fcb8fbcdecf92a6ce00933
- Plataforma: linux/amd64, emulada (Rosetta) en macOS Apple Silicon, Docker Desktop 29.9.3
- Debian: 10 (buster)
- Node: v10.24.1 · npm: 6.14.12 · ABI: 64
- Python 2 / Python 3: 2.7.16 / 3.7.3 · GCC: 8.3.0

## Hipótesis inicial
- Node esperado: 10 (Angular 8 pide >= 10.9; `node-sass` 4.14.1 publica binario para ABI 64)
- Evidencia que la sostiene: `package.json`, versión del CLI en el README
- Riesgos identificados: `node-sass` (addon nativo), tests con Karma y navegador

## Resultado
| Nivel | Etapa | Comando | Exit code | Resultado |
|---|---|---|---:|---|
| 2 | Install | npm ci | 0 | 1.612 paquetes en 96 s; `node-sass` descarga su binario `linux-x64-64` y carga |
| 3 | Tests | npm test | — | N/A: Karma pide Chrome (`No binary for Chrome browser`) y, con `singleRun: false`, se queda esperando; cortado a mano |
| 3 | Lint | npm run lint | 1 | `Unable to find TSLint`: el proyecto no declara `tslint` |
| 4 | Build | npm run build | 0 | 87 s, differential loading ES5 + ES2015 |
| 5 | Run | npm start | 0 | `ng serve` en 0.0.0.0:4200, compila en 15 s |
| 5 | HTTP | curl -sI localhost:4200 | 0 | HTTP/1.1 200 OK a los ~18 s |
| 6 | Watch | edición de archivo | 0 | recompila sin sondeo (VirtioFS); también con `--poll 1000` |

## Veredicto
- Nivel alcanzado (1–7): 6, con dos agujeros declarados en el 3
- Compatible para: instalar, construir, servir y trabajar con recarga en Node 10.24.1
- NO compatible para: correr sus unit tests sin navegador; su lint, mientras no declare `tslint`

## Lo que no se pudo resolver
- Tests: hace falta Chrome Headless (a09) o `singleRun: true` con `ChromeHeadless`.
- Lint: añadir `tslint` a `devDependencies` es un cambio del proyecto, no del laboratorio.

## Reproducir
- `docker volume create labcore-node10-modules`
- `PROJECT_DIR=$PWD MODULES_VOLUME=labcore-node10-modules /ruta/al-lab/scripts/run-dev.sh`
- `docker exec legacy-node-dev npm ci`, `npm run build`, `npm start -- --host 0.0.0.0`
- `docker exec legacy-node-dev curl -sI http://localhost:4200`
