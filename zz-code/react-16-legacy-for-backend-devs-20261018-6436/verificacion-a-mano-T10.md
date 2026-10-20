# Verificación a mano de T10 (para el autor)

Lo que no se pudo correr en el laboratorio de la tanda, o solo se ve con las manos. Lo que corrió en contenedor está en el
README §7. Repo: `esclusa-app/` de este directorio. Anota la fecha y el resultado al lado.

## be09 — el compose con los puertos de verdad

`cd server && docker compose up -d --build` en `fase-be09-empaquetado-ambientes-y-pipeline`, con el `5432` y el `3001` de tu
máquina libres, y la consola (`npm run mock:googleplay & npm start`) en el `3000`. Siembra con
`DATABASE_URL=postgres://esclusa:esclusa@localhost:5432/esclusa?sslmode=disable go run ./cmd/seed -file ../mock/db.json`.

1. La consola funciona contra el API del compose sin cambiar nada (login, ruedas, envíos, conciliación).
2. Una compra desde la pantalla de Compras: el API llega al `3002` por `host.docker.internal` (si no, anota el error).
3. El paso 5 de la pieza forense: el `X-Request-Id` de un envío, en DevTools y en `docker compose logs api`.
4. `docker compose down -v` al terminar.
- Resultado: ____ · fecha: ____

## be09 — el pipeline en un runner de verdad

En un repositorio de prueba en GitHub con el contenido de `esclusa-app/`: el trabajo `test` en verde, y el `image` publicando
en `ghcr.io` en un push a `master`. En el laboratorio se validó con actionlint 1.7.9 y con sus pasos en contenedor, sin runner (D31).
- Resultado: ____ · fecha: ____

## be09 y bea-02 — `exec format error`

Docker Desktop emula la otra arquitectura y el error no apareció en el laboratorio (no verificado por ejecución). En una
máquina `amd64` sin emulación —o con `docker run --platform` y la emulación apagada—, la imagen construida en arm64 sin
`--platform`. Anota el mensaje exacto y el tiempo de una construcción con `--platform linux/amd64`.
- Resultado: ____ · fecha: ____

## be08 — la suite en tu máquina

`make test-unit` (sin base), y `make test-all TEST_DB=…/esclusa_test…` con la base de pruebas creada como dice bea-02 §1.
Comprueba que sin `TEST_DATABASE_URL` las pruebas de base fallan con su mensaje, y que el par contradictorio
(`make test-engine`) da las cuatro salidas del documento.
- Resultado: ____ · fecha: ____
