# react-16-legacy-for-backend-devs · verificación previa P7 (14/10/2026)

Sesión de `zz-code/` para la preparación P7 del plan de edición
(`prompts/_desechable-plan-de-edicion.md`). Qué se hizo y qué se encontró está en
[`hallazgos.md`](hallazgos.md). Lo que el autor revisa a mano está en
[`lista-verificacion-a-mano.md`](lista-verificacion-a-mano.md).

> 📝 Los archivos de `salidas/` que se citan abajo ya no está en disco (comprobado el 25/10/2026): no se versiona y `limpiar.py` la libera como regenerable. Las cifras quedan en
> `hallazgos.md`; los inventarios de Docker eran de una sola vez y se perdieron.

## 1. Qué es esto

Medidas y comprobaciones de las cifras y versiones que las fases densas van a
reproducir. No es el repo del alumno (`esclusa-app`), que nace en T1.

## 2. Entorno

- macOS (Darwin 25.6.0), arm64, Docker 29.8.0.
- Nada instalado en el host. Todo corre en contenedores con `--label curso=react16`
  y sin puertos publicados (la red es privada: `r16p7-net`).
- Imágenes usadas: `node:14.21.3`, `golang:1.19.13`, `golang:1.20`, `postgres:13`,
  `grafana/k6:1.5.0`, `cypress/included:10.11.0`, `rhysd/actionlint:1.7.9`. Todas con
  `linux/arm64` (`salidas/manifiestos-plataformas.txt`).

## 3. Inventario inicial de Docker

Antes de empezar, con `docker ps -a`, `docker images` y `docker volume ls`. Los
resultados están en `salidas/inventario-inicial-*.txt`. Hay contenedores y volúmenes
**ajenos al curso**, que no se tocaron.

## 4. Imágenes y plataformas

`docker manifest inspect <imagen>` para cada una; después `docker pull --platform
linux/arm64`. Log: `salidas/pull-imagenes.log`, `salidas/pull-golang-1.20.log`.

## 5. k6, versión fijada

`docker manifest inspect grafana/k6:<versión>` sobre 1.0.0 a 1.5.0. Se fija
`grafana/k6:1.5.0`. Ver `salidas/k6-versiones-consultadas.txt`.

## 6. El giro ingenuo y el transaccional

```bash
cd trabajo/carga
./correr-giro.sh ingenuo          # salidas: sql-giro-ingenuo.txt, k6-giro-ingenuo.txt
./correr-giro.sh transaccional    # salidas: sql-giro-transaccional.txt, k6-giro-transaccional.txt
```

El script crea una red privada, un Postgres 13 con esquema de `schema.sql`, la app
(`servidor.js`, en `node:14.21.3`) y corre k6 (`giro-k6.js`). Solo el modo
transaccional crea la restricción `UNIQUE (key)`. Limpieza al final: el contenedor de
la app se borra con sus volúmenes; el de Postgres, en el paso 10.

## 7. Trampa de `math/rand`

```bash
docker run --rm -v "$PWD/trabajo/go-rand":/src -w /src golang:1.19.13 go run main.go
docker run --rm -v "$PWD/trabajo/go-rand":/src -w /src golang:1.20   go run main.go
```

Dos corridas por versión. Resultado: `salidas/math-rand-1.19-vs-1.20.txt`.

## 8. oddsAudit y prorrateo

```bash
docker run --rm -v "$PWD/trabajo/odds":/src -w /src node:14.21.3 node odds.js
```

Resultado: `salidas/odds-audit-prototipo.txt`.

## 9. Las demás comprobaciones

- **CRA 4:** `npx create-react-app@4.0.3` falla (ver H7). La resolución de React 16.14.0 con
  react-scripts 4.0.3 se comprueba con `trabajo/resolucion/package.json` y `npm install`
  en `node:14.21.3`: `salidas/resolucion-react16-cra4.log`.
- **Mock de Google Play:** `trabajo/google-play/prueba.sh` en `node:14.21.3`.
- **cgo y migraciones:** `trabajo/cgo-migrate/` compilado en `golang:1.19.13` con
  `CGO_ENABLED=1`.
- **Cypress:** `cypress --version` dentro de `cypress/included:10.11.0`.
- **actionlint:** `trabajo/actionlint/.github/workflows/{ok,roto}.yml` con
  `rhysd/actionlint:1.7.9 -no-color`.

## 10. Limpieza y verificación final

```bash
docker rm -fv r16p7-pg          # Postgres de la medición, con su volumen anónimo
docker network rm r16p7-net     # la red privada
docker ps -a --filter label=curso=react16 --format '{{.Names}}'     # debe salir vacío
docker volume ls > salidas/inventario-final-volumenes.txt
docker ps -a > salidas/inventario-final-contenedores.txt
```

Al cierre se compara el inventario final con el inicial. Los recursos ajenos al curso
cambiaron durante la sesión por actividad que no es de estos comandos (H12); quedó
registrado, no se tocó nada de ellos. Las imágenes descargadas se quedan (no son
contenedores ni volúmenes).
