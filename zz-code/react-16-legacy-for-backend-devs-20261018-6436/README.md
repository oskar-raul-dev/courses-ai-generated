# 🧪 react-16-legacy-for-backend-devs-20261018-6436 · cómo correr estas pruebas

> **Curso:** react-16-legacy-for-backend-devs · **Tandas:** T7 (be00–be04, incidentes be-01–be-08, bea-01, 03, 04, 07 y 08; y R23 de F09/F10) T8 (be05, incidentes be-09, be-10 y be-17, bea-05, bea-10 y bea-11) T9 (be06, be07, incidentes be-11–be-14 y be-18, bea-06) y T10 (be08, be09, be-15, be-16, bea-02, bea-09) · **Creado:** 2026-10-18
> **Propósito:** el repo de prueba vigente del track BE (`esclusa-app/`), clonado de `…-20261015-f769` desde
> `fase-11-cierre-puente-react-moderno` con todas sus ramas y etiquetas, más el backend en Go de be00 a be04 escrito
> siguiendo los documentos, las ramas `incidente/be-01` … `be-08`, y cada medición que el curso publica de esas fases.
> Las reglas, en `zz-code/README.md` § "El README de cada directorio". Si una sección no aplica, se dice por qué.

## 1. 🎯 Qué se prueba y para qué

| Prueba | Documento | Qué alimenta |
|---|---|---|
| `trabajo/inventario.py`, `trabajo/recorrido/` (Cypress, `recorrido.cy.js`) | be00 §5.1–5.2 | el inventario leído (`grep` sobre `src/` y `scripts/`) y el medido (cada petición del navegador en un recorrido completo) |
| `server/smoke.sh` contra el mock y contra Go | be00, be03, be04 | 17/17 contra el mock y contra Go (be03); 18/18 con el login real (be04) |
| `trabajo/hallazgos-mock.sh` | be00 §5.4 | los hallazgos del mock: `name_like` como regex (`(` → 500), `_page` pisa `Access-Control-Expose-Headers`, los dos `404` |
| `trabajo/panico/`, `trabajo/be01/*` | be01 §4, §6, forense, bea-01 | el pánico en `net/http` (handler: conexión cerrada, proceso vivo; goroutine: proceso muerto), Express con `throw`, axios ante el corte, el orden de la cadena, el caos, el apagado |
| `trabajo/be01-navegador.sh`, `recorrido/cypress/e2e/be01-navegador.cy.js` | be01, incidente be-01 | `fetch` desde el navegador: `X-Request-Id` visible con `Expose` y `null` sin él |
| `trabajo/be02/*_test.go` (vía `gotest-extra.sh`) | be02 §4–§6, bea-03, bea-04 | migraciones en los dos dialectos, `/health` 200 y 503, la fuga de `Rows`, las divergencias SQLite/Postgres (zona, `$1`/`?`, `LastInsertId`, `LIKE`, `TEXT` contra `TIMESTAMP`) |
| `trabajo/comparar-json.sh`, `trabajo/escrituras.sh` | be03 🪦 | lecturas idénticas al mock salvo `wheelVersion`; 23 escrituras idénticas |
| `recorrido/cypress/e2e/be02-tablero.cy.js`, `be03-pantallas.cy.js` | be03, be-02, be-06 | el recorrido contra Go en el `3001`; el tablero con el giro de 2019 y con `sql.NullString` |
| `trabajo/be04-forense.sh`, `be04-sin-chequeo.sh`, `recorrido/cypress/e2e/be04-login.cy.js` | be04, bea-07, bea-08 | bcrypt, el login real, govulncheck antes y después de migrar, el `alg` sin chequeo, el tiempo del login, `authService.js` |
| `recorrido/cypress/e2e/be08-sesion.cy.js` | incidente be-08 | con `JWT_TTL=3m`, el primer clic después de 3 min 10 s termina en `/login` |
| `trabajo/incidentes/*_test.go` y sus dos `correr-*.sh` | cuaderno BE be-01, 03, 05, 06, 07 | cada prueba de regresión publicada: rojo en su rama, verde en su fase |
| `trabajo/r23-filtro.py`, `r23-filtro-b.py` | F09, F10 (R23) | `hourCycle: "h23"` en `MetricCard` y la aserción de medianoche, metidos en toda la historia con `filter-branch` |
| `trabajo/render_fase.py` con `trabajo/beNN-plantilla.md` y `F09/F10-plantilla.md` | be01–be04, F09, F10 | que cada bloque publicado sea el archivo de la etiqueta (se rinde contra un `worktree` de la etiqueta) |
| `trabajo/contract_desde_be00.py`, `be00-purchasetoken.py`, `rows-comentario.py`, `empalmar.py` | be00, `CONTRACT.md`, cuaderno BE | el `CONTRACT.md` sale del §5.3–5.4 de be00; los incidentes se empalman en el cuaderno respetando los bloques de código |
| `server/internal/spin/race_test.go` (en el repo) | be05 | las tres carreras con barrera y `-race`, en las dos estrategias, y la bitácora inmutable |
| `trabajo/be05-k6.sh`, `be05-k6-repeticiones.sh`, `server/load/*` | be05 §5.7, `concurrencia.md`, bea-11 §3 | k6 contra el giro de 2019 (sobre el esquema de be04), el pesimista y el condicional, escenarios `pico` y `notificacion`; tres corridas por fila |
| `trabajo/be05/sqlite_test.go`, `sinmutex_test.go` | be05 §6 | la carrera del stock contra SQLite (fase y rama de be-09, en verde las dos) y el `DATA RACE` del sorteo sin mutex |
| `trabajo/be05-forense.sh` | be05 §6, paso 2 | `pg_stat_activity` y `pg_blocking_pids` con dos giros de la API esperando; el `X-Request-Id` del `409` en el log |
| `trabajo/be05-corte.sh`, `be05-reinicios.sh` | be05 §5.5, be-10, be-17 | `kill -9` durante la entrega (rama y fase); dos arranques de 2.000 giros y su χ² |
| `trabajo/incidentes/be10_processing_test.go`, `be17_two_boots_test.go`, `correr-be09-be17.sh` | cuaderno BE be-09, be-10, be-17 | las regresiones en rojo en su rama y en verde en `fase-be05` |
| `trabajo/bea05/escena.sh` y sus `*.t1.sql`/`*.t2.sql`/`*.t3.sql` | bea-05 | cada escena de dos (o tres) terminales de `psql` en la base `bea05` |
| `trabajo/bea10-medir.sh`, `trabajo/bea10/ejemplos_test.go` | bea-10 | huellas de la semilla, la llamada de más, `ANALYZE`, el borrado del volumen; los tres ejemplos del §7 |
| `trabajo/bea11-medir.sh`, `bea11-calentamiento.sh`, `bea11-callback.sh`, `trabajo/bea11/*.js` | bea-11 | el script mínimo y los errores que dan números falsos |
| `trabajo/be05-plantilla.md`, `bea10-plantilla.md` | be05, bea-10 | rendidas con `render_fase.py` contra `fase-be05-giro-concurrente` y `apendice-bea-10-datos-de-prueba-y-faker` |
| `trabajo/be06-forense.sh`, `trabajo/be06/settz_test.go`, `openraw.go`, `trabajo/be06/tzlocal/` | be06 §5.1, §6, `reloj.md` | la pieza forense (giro gratis, cierre por reloj, barrido, envío rechazado); `SET TIME ZONE` sobre un pool contra la zona en el DSN; `os.Setenv("TZ")` contra `time.Local` |
| `trabajo/be06-k6-cierre.sh` | be06 §6, be-12 | k6 con la rueda de medición cerrando a los 5 s: giros anotados después del cierre, rama y fase |
| `trabajo/incidentes/correr-be12-be18.sh`, `be18_client_clock_test.go`, `be18-binario.sh`, `be11-cypress.sh`, `recorrido/cypress/e2e/be11-reloj.cy.js` | be-11, be-12, be-18 | regresiones en rama y fase; el celular adelantado con `X-Client-Now`; la consola con `cy.clock` una hora adelante |
| `trabajo/bea06/pg.sql`, `trabajo/bea06/go/` | bea-06 | `TIMESTAMPTZ` en tres zonas, Santiago en sus dos cambios de hora, Asunción en las dos imágenes, SQLite contra Postgres, `==` contra `Equal`, el peso de `time/tzdata` |
| `trabajo/be07-compra.sh`, `be07-conciliacion.sh`, `trabajo/be07/consola-ref.test.js` | be07 §5.6, §6 | la compra contra el `3002` (tarjeta, efectivo, avisos repetidos); la conciliación del servidor contra la de la consola sobre la misma bitácora |
| `trabajo/incidentes/correr-be13-be14.sh`, `be13_stale_client_test.go`, `be13-cypress.sh`, `be14-binario.sh`, `recorrido/cypress/e2e/be13-conciliacion.cy.js` | be-13, be-14 | regresiones en rama y fase; la conciliación con la pantalla abierta; la compra acreditada en pasos sueltos |
| `trabajo/be06-plantilla.md`, `be07-plantilla.md` | be06, be07 | rendidas con `render_fase.py` contra `fase-be06-…` y `fase-be07-…` |
| `trabajo/be08-carga.sh` | be08 §5.6 | el nivel de carga: k6 con sus `thresholds` y `invariantes.sql` después, en la fase y en la rama de be-09 |
| `esclusa-app/server/Makefile` | be08 §5.7 | los niveles: `make test-unit`, `test-handler`, `test-all`, `test-contract`, `test-engine` dentro de `r16t7-go` |
| `trabajo/incidentes/correr-be15.sh` | be-15 | la suite sin y con Postgres en la rama y en la fase; el alta de una rueda con el binario |
| `trabajo/be09-compose.sh`, `trabajo/be09/compose-lab.yml` | be09 §5.4 | el compose del repo, la siembra, `smoke.sh`, el recorrido y la smoke de F10 con la consola |
| `trabajo/be09-ci-local.sh` | be09 §5.5 | los pasos del trabajo `test` del workflow, en `golang:1.19.13` con `postgres:13`; actionlint aparte |
| `trabajo/be09/medir-d19.sh` | be09 §5.2 | D19 en tres escenarios, con la caché vacía |
| `trabajo/incidentes/correr-be16.sh` | be-16 | la imagen de la rama y de la fase sin caché, y su arranque; `ldd` del binario |
| `trabajo/bea02-medir.sh`, `trabajo/bea02/compose-lab.yml`, `trabajo/bea02/tz/` | bea-02 | la versión A de punta a punta, los errores 6.2 y 6.3, la base de zonas en distroless y `scratch` |
| `trabajo/be08-plantilla.md`, `be09-plantilla.md`, `bea02-plantilla.md` | be08, be09, bea-02 | rendidas contra `fase-be08-…`, `fase-be09-…` y `apendice-bea-02-…` |

## 2. 🛠️ Prerrequisitos

- Docker con `node:14.21.3`, `golang:1.19.13`, `postgres:13` (13.23), `alpine:3.20`, `cypress/included:10.11.0`. Nada
  se instala en la máquina; `migrate` v4.15.2 y `govulncheck` v1.0.0 se compilan dentro del contenedor de Go.
- El repo `esclusa-app/` tal como está. Etiquetas del track BE: `pre-backend-go` (`9edf8d5`, sobre `fase-11-…`),
  `fase-be00-el-contrato-auditoria-del-mock` (`e259d38`), `fase-be01-go-y-la-forma-del-monolito` (`e059209`),
  `fase-be02-la-costura-de-datos` (`5d590c9`), `fase-be03-crud-y-el-reemplazo` (`abb7772`),
  `fase-be04-identidad-real-jwt-y-un-cve` (`2b1eeac`; dos commits: adopta `dgrijalva/jwt-go` y migra a
  `golang-jwt/jwt/v4`). Las etiquetas base `fase-09`, `fase-10`, `fase-11` y `pre-modernizacion` se reescribieron por R23.
- Ramas de incidente: `incidente/be-01` (`ff2e19e`, CORS sin `Expose`), `be-03` (`3d48119`, `[0]` y sin `recover`),
  `be-04` (= `fase-be03`, diff vacío), `be-05` (`1ddfc11`, `Query` sin contexto y `return` temprano), `be-06`
  (`538d0ce`, `sql.NullString`), `be-07` (`11acfc6`, sin la `000003`), `be-08` (= `fase-be04`; se corre con
  `JWT_TTL=3m`). `previo-t7/master-f02` guarda el `master` anterior.
- El volumen `r16t7-gomod` cachea los módulos de Go; `salidas/apk-cache` cachea los paquetes de `alpine`.
- T8: `fase-be05-giro-concurrente` (`e38597f`, enmendada tres veces: sin `random_test.go`, sustitutos en la siembra y no en el
  `db.json`, `server/evidence/concurrencia.md`); ramas `incidente/be-09` (`8c47a88`), `be-10` (`4cfa472`), `be-17` (`80ed1c5`),
  rebasadas sobre la etiqueta final; `apendice/bea-10` con la etiqueta `apendice-bea-10-datos-de-prueba-y-faker` (`1acd263`).
  Imagen `grafana/k6:1.5.0` (ya estaba) y, solo para be-17, `golang:1.20` (1.20.14, ya estaba). Base aparte `bea05` en `r16t7-pg`.

## 3. 🧭 Reglas antes de correr

```bash
mkdir -p salidas
docker ps -aq --no-trunc > salidas/contenedores-antes.txt
docker images -q --no-trunc | sort -u > salidas/imagenes-antes.txt
docker volume ls -q > salidas/volumenes-antes.txt
docker network ls -q > salidas/redes-antes.txt
```

El inventario de esta sesión está en `salidas/inventario-inicial-docker.txt`. Todo lleva `--label curso=react16`
(la etiqueta del curso en todas sus tandas). Ningún puerto se publica en el host: la consola, los mocks y Go conviven en
el espacio de red de `r16t7-app` (`--network container:r16t7-app`) y Cypress corre en ese mismo espacio, así que el
navegador ve `localhost:3000`, `3001` y `3002`. Postgres es `pg` en la red `r16t7-net`. No hay cambios en la máquina.

## 4. ▶️ Cómo se corre

Desde este directorio:

```bash
docker network create --label curso=react16 r16t7-net
docker run -d --name r16t7-pg --label curso=react16 --network r16t7-net --network-alias pg \
  -e POSTGRES_USER=esclusa -e POSTGRES_PASSWORD=esclusa -e POSTGRES_DB=esclusa postgres:13
docker exec r16t7-pg createdb -U esclusa esclusa_test
docker volume create --label curso=react16 r16t7-gomod
# contenedor de Go de trabajo (3011), con migrate compilado adentro
docker run -d --name r16t7-go --label curso=react16 --network r16t7-net -v "$PWD/esclusa-app":/app \
  -v r16t7-gomod:/go/pkg/mod -w /app/server golang:1.19.13 sleep infinity
docker exec r16t7-go go install -tags 'postgres sqlite3' github.com/golang-migrate/migrate/v4/cmd/migrate@v4.15.2
```

- `trabajo/levantar-app.sh mocks|go` — la consola (`npm start`) y los mocks, o solo el `3002` si el `3001` lo da Go.
- `trabajo/levantar-go-3001.sh [ref]` — el 🪦: Go en el `3001` del espacio de `r16t7-app`, desde la etiqueta o rama
  `ref` (en un `worktree` de `etapas/go3001`). Lee `DATABASE_URL`, `GRANT_DELIVERY_MS`, `JWT_SECRET`, `JWT_TTL`.
- `trabajo/go-reiniciar.sh [DATABASE_URL]` — `drop` + `up` + siembra + binario en el `3011` de `r16t7-go`. Sin
  `timezone=America/Panama` en el DSN reproduce be-04.
- `trabajo/tools.sh '<comando>'` — `bash`, `curl` y `jq` en un `alpine:3.20` efímero; p. ej.
  `trabajo/tools.sh 'BASE=http://app:3001 ./server/smoke.sh'`.
- `trabajo/gotest-extra.sh <paquete> <archivo_test.go> [args]` — `go test` sobre una copia de `server/` con una prueba
  extra; así corren `trabajo/be01/*` y `trabajo/be02/*`.
- `trabajo/comparar-json.sh`, `trabajo/escrituras.sh` — lecturas y escrituras, mock contra Go.
- `trabajo/be04-forense.sh v3|v4`, `trabajo/be04-sin-chequeo.sh` — govulncheck, `go list -m all`, `go version -m` y el
  token sin chequeo de `alg`.
- Cypress: `docker run --rm --label curso=react16 --network container:r16t7-app -v "$PWD/trabajo/recorrido":/e2e -w /e2e
  cypress/included:10.11.0 --spec cypress/e2e/<spec>.cy.js` (el recorrido escribe en `trabajo/recorrido/salida/`).
- `trabajo/incidentes/correr-be01-be03.sh` y `correr-be05-be07.sh` — las regresiones en rama y fase.
- `python3 trabajo/render_fase.py <plantilla> <worktree> <salida>` — rinde un documento contra el árbol de una etiqueta.

## 5. 📏 Cómo se mide

MacBook (Apple Silicon, arm64), Docker Desktop. Imágenes arm64. Cada cifra publicada sale de una corrida guardada en
`salidas/`. No hay benchmarks de rendimiento en esta tanda: las únicas cifras de tiempo son el login (~1 ms con un email
desconocido —0,67 a 1,01 ms— contra ~67 ms con un email conocido y contraseña mala —67,2 a 67,6 ms—, bcrypt costo 10,
tres corridas de cada uno en `salidas/bea08.txt`; la dispersión es tan chica que se publica el orden de magnitud), el `503` de `/health` a los 2 s (el timeout del `Ping`) y la expiración de be-08 (`JWT_TTL=3m`, clic a los
3 min 10 s). El caos usa semilla fija (`CHAOS_SEED`), así que sus proporciones se repiten exactas.

## 6. 🧮 Los intermedios que amasan la salida

- Inventario medido: `trabajo/recorrido/salida/*.json` → `trabajo/inventario.py` (agrupa método + ruta normalizada,
  cuenta) → `salidas/inventario-medido-{mock,go,be04}.txt` → `server/evidence/inventario-medido.txt`.
- Contrato: be00 §5.3–5.4 → `trabajo/contract_desde_be00.py` → `server/CONTRACT.md` (y `be00-purchasetoken.py` para la
  fila agregada con `filter-branch`).
- Lecturas: `comparar-json.sh` normaliza con `jq -S` y compara con `diff`; la única diferencia es `wheelVersion`.
- govulncheck: la salida cruda en `salidas/be04-govulncheck-v{3,4}.txt`; el resumen con `grep -E "^Vulnerability|Found in|Fixed in"`.
- Login: tres `curl -w '%{http_code} %{time_total}s'` por caso, sin procesar (`salidas/bea08.txt`, bloque `== login`);
  el costo 10 se lee en el prefijo `$2a$10$` de los hashes de `salidas/be04-hashes.txt`.

## 7. ✅ Qué se espera ver

Corrido el 18 y 19/10/2026:

- `smoke.sh`: 17/17 contra el mock (`salidas/smoke-mock.txt`) y contra Go en be03 (`smoke-be03-go.txt`); 18/18 en be04.
- `go test ./...`: verde en be02, be03 y be04, en SQLite y en Postgres (`salidas/be0N-go-test.txt`).
- El recorrido de Cypress pasa contra el mock y contra Go; diferencias de inventario: sin `304` y `wheelVersion` en el
  cuerpo del `PUT`. La smoke de Cypress de F10 y Jest 25/25 pasan contra Go.
- Incidentes (`salidas/inc-be0*.txt`, `be05-pool.txt`, `be07.txt`, `be04-ttl.txt`): be-01 `null`; be-02 stock 980 y
  tablero en 0; be-03 `Failed to fetch` con el proceso vivo; be-04 `2031-01-01T01:00:00Z`; be-05 25 × `409`, después
  cuelgue y 25 `idle`; be-06 *10000 gratis · 0 pagos*; be-07 `missingInApi: []`; be-08 `/login` y *token is expired by
  11.08s*. Las regresiones: rojo en la rama, verde en la fase.
- govulncheck: en v3, GO-2020-0017 (informativo); tras migrar, GO-2024-3250 y GO-2025-3553 alcanzables en v4.4.2, más
  42 del stdlib de Go 1.19.13. `go list -m all` sigue mostrando `dgrijalva` (vía golang-migrate); el binario, no.
- R23: `salidas/r23-rojo-con-hour12.txt` (la aserción de medianoche en rojo sin `hourCycle`), F09 y F10 rendidas de nuevo.
- T8 (19/10/2026): `race_test.go` verde con `-race` en las dos estrategias (`salidas/be05-race.txt`; el primer intento, con el
  deadlock de la clave foránea, en `be05-race-1-deadlock.txt`, y la variante `FOR NO KEY UPDATE` en `be05-race-2-no-key-update.txt`);
  `smoke.sh` 19/19; el recorrido de Cypress y la smoke de F10 contra be05 en el `3001`; k6 en `salidas/be05-k6-*.txt` y la tabla en
  `be05-k6-tabla.txt` (las invariantes de be05 en todas las corridas: 1.500 / 1.000 / 500 / 0 / 0 / 0); be-09, be-10 y be-17 en rojo y
  verde (`inc-be09-be17.txt`), con el binario (`inc-be10-binario.txt`, `inc-be17-binario.txt`, `be05-k6-inc-be09-*.txt`); bea-05 en
  `bea05-*.txt`; bea-10 en `bea10-*.txt`; bea-11 en `bea11-*.txt`.
- T9 (19/10/2026): be06 con `go test -race` verde en Postgres, la prueba del barrido también en SQLite, y la suite con
  `TZ=Asia/Tokyo` (`salidas/be06/`); el borde roto a propósito hace fallar dos casos (`rompe-el-borde.log`); `SET TIME ZONE`
  en el pool, 9/200 contra 200/200 (`set-time-zone-pool.log`); `smoke.sh` 22/22 sin zona en el DSN; recorrido y smoke de
  F10 contra be06; be-12 108, 61 y 5 giros después del cierre contra 0 (`k6-cierre-*.txt`); be-11 con `cy.clock`; be-18 con
  el binario (`inc-be18-binario.txt`; el primer intento, con 4 h exactas, en `…-intento1-4h-exactas.txt`). be07: 51 avisos,
  1 compra (`be07-go-test-1.log`); simulación con 21 corridas, una alarma de χ² (`be07-simulacion-20.log`); conciliación del
  servidor igual a la de la consola (`be07-conciliacion.txt`, `be07-consola-ref.json`); compra contra el `3002`
  (`be07-compra.txt`); `smoke.sh` 24/24; recorrido y smoke de F10 contra be07; k6 con el arnés de un giro por jugador, las
  invariantes en las cuatro corridas (`be05-k6-be07-*.txt`); be-13 y be-14 en rojo y verde (`inc-be13-be14.txt`), con la
  consola (`inc-be13-cypress.txt`) y con el binario (`inc-be14-binario.txt`, 60 giros contra 20). bea-06 en `salidas/bea06/`.
- T10 (20/10/2026): be08 con la suite por niveles (`be08-nivel1y2.txt`, `be08-contrato.txt`, `be08-suite-4.txt`; los intentos
  con la conexión retenida por migrate y la regresión de be-01 sin reloj, en `be08-suite-1..3.txt`), la prueba sembrada 50/50
  (`be08-semilla-50.txt`), el par contradictorio (`be08-regla-del-motor.txt`), el nivel de carga (`be08-carga-*.txt`), el
  `TRUNCATE` rechazado y la recreación del esquema, y lo que decía be07 sin Postgres (`be08-antes-sin-postgres.txt`); be-15
  (`inc-be15.txt`; el primer intento sin `mock/` montado en `inc-be15-intento1-sin-mock.txt`). be09 en `salidas/be09/`: D19,
  la imagen y sus arranques, el compose de punta a punta, actionlint, los pasos del workflow, la base de zonas; be-16
  (`inc-be16.txt`, `inc-be16-paso-ci.txt`); bea-02 (`bea02.txt`).

## 8. 📂 Salidas

Todo en `salidas/`, un archivo por medición, nombrado por fase (`be01-…`, `be02-…`) o incidente (`inc-…`). Se regenera
corriendo el script de §4 correspondiente. La carpeta ya no está en disco (comprobado el 25/10/2026; `limpiar.py`
la libera): las cifras de §7 son el registro, y el inventario inicial de Docker, que era de una sola vez, se perdió. Al curso se copiaron, rendidos, be01–be04 (desde sus plantillas), F09 y F10;
be00 y los incidentes se escribieron a mano con las cifras de aquí. `server/evidence/` del repo guarda los inventarios y
las divergencias, como parte de la fase.

## 9. 🧹 Limpieza

```bash
docker rm -f -v r16t7-app r16t7-go r16t7-go3001 r16t7-pg r16t7-api r16t7-api11
docker image rm r16t10-esclusa-api:puro r16t10-esclusa-api:incidente-be-16 r16t10-esclusa-api:fase-be09-empaquetado-ambientes-y-pipeline \
  r16t10-api r16t10-migrate r16t11-api r16t10-tz:distroless r16t10-tz:vacia
docker volume rm r16t7-gomod
docker network rm r16t7-net
git -C esclusa-app worktree remove --force ../etapas/go3001; git -C esclusa-app worktree prune
```

Comparar después contra `salidas/inventario-inicial-docker.txt`. Nunca `prune`.

## 10. 🚫 Qué se dejó fuera

`esclusa-app/node_modules` (428 MB; `npm ci` en `node:14.21.3`), `trabajo/recorrido/node_modules` si existe (lo trae la
imagen de Cypress), el caché de módulos de Go (volumen `r16t7-gomod`; `go mod download`), `salidas/apk-cache` (se
rellena solo) y los binarios `/tmp/api` y `migrate`, que viven dentro de los contenedores. El secreto JWT del
laboratorio es un valor de prueba escrito en los scripts, no un secreto real.
