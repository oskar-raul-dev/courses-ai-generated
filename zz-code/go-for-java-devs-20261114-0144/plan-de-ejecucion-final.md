# 🗓️ Plan de ejecución: las salidas de las fases y el gemelo Spring Boot
## Go para desarrolladores Java senior

> ✏️ **Desechable.** Este plan nace el 14/11/2026 para cerrar dos de las deudas de la guía §14.2:
> que las salidas de las fases se declaren ilustrativas y que el gemelo Spring Boot no exista. Se
> deriva de `zz-instrucciones/plantillas/plan-de-produccion.md`, recortado a una revalidación, porque
> el curso ya está escrito. **No se cita desde ninguna fase ni README.** Al cerrar la última tanda se
> copia a su directorio de `zz-code/` y se borra de aquí.
>
> **Vigencia:** 2026-11-14.

Cualquier sesión que retome este trabajo empieza leyendo §3 (estado), §5 (bitácora) y la tanda que
le toca en §4.

---

## 1. 🧭 Decisiones de partida (14/11/2026, el autor)

| # | Decisión | Consecuencia |
|---|---|---|
| E1 | **Las versiones se fechan, no se suben** | Las tandas corren go1.13 (Bloque A) y go1.25.1 (Bloques B y C), las del texto. La tabla con fechas está en `0-ESTRUCTURA-CURSO.md` §11 |
| E2 | **Las salidas se ejecutan por tandas**, empezando por F00–F01 | Cada salida medida reemplaza a la ilustrativa, o queda marcada como no reproducida y con el motivo |
| E3 | **El gemelo va en `src/clearinghouse-spring/`**, en Spring Boot 4.1 sobre Java 21 | Es el único `src/` del curso. Se abre una excepción en la guía §14 y el lector lo copia a su `reference/`. Se escribe cuando exista el ClearingHouse en Go (tanda S10) |
| E4 | `APRENDIZAJE.md` sale a la raíz | Hecho el 14/11/2026, fuera de este plan |
| E5 | **BENCHMARKS: la cifra del curso más la columna del lector** (14/11) | Se llena REF-1 (Apple M1 Pro, 8 núcleos, 32 GB, macOS 26.7.2; contenedor `linux/arm64` con 8 CPU y 8 GB) y cada tabla gana la columna "REF-1 del curso" con su fecha. La columna del lector queda vacía, y el veredicto provisional se corrige donde la medición lo contradiga |
| E6 | **El código que falta se completa en `lector/`** (14/11) | A la fase solo entra lo que un senior no podría deducir, y cada caso queda en la tabla de su tanda |
| E7 | **Docker con 8 GB** desde el 14/11 (el autor lo subió) | Se miden la JVM ajustada y `native-image`. Al cierre se le recuerda al autor que puede devolver la memoria a 4 GB |
| E8 | **Internet: pocas llamadas reales** (14/11) | Unas pocas llamadas a restcountries.com, guardadas como fixture. El resto corre contra `httptest` |

## 2. 📏 Las reglas

1. **Todo corre en contenedor** y nunca en el host. Nada publica puertos por defecto. Lo que crea la
   sesión lleva la etiqueta `curso=go-for-java-devs`, y se borra solo por esa etiqueta.
2. **El repositorio del lector se reconstruye en `zz-code/<id>/lector/`** con `extraer.py`: cada
   bloque cuya primera línea es una ruta (`// labs/x/main.go`, `# compose.yaml`) se escribe en esa
   ruta. Si un archivo aparece dos veces, la segunda versión pisa a la primera, y las dos quedan en
   `salidas/versiones/`.
3. **Una salida del curso se compara contra la corrida**, y la corrida gana. Hay tres casos:
   - **igual** (salvo rutas, tiempos o direcciones de memoria): no se toca;
   - **distinta**: se reemplaza por la medida, y si la prosa la comenta, se corrige también la prosa;
   - **no reproducible en contenedor** (macOS, Rosetta, un IDE): se deja, con su marca en la tabla de
     la tanda, y se comprueba al menos su forma con el equivalente en Linux.
4. **Un código que no compila es un error del curso**, y se corrige en la fase en la misma tanda.
5. **Cada fase revalidada lleva una línea fechada** después de su §5 (CLI de la fase): dónde se corrió,
   con qué toolchain y qué quedó sin reproducir. Las cifras de rendimiento siguen siendo de esa
   máquina, y `BENCHMARKS.md` sigue mandando sobre las del lector.
6. **El aviso de "ilustrativas"** del README y de `0-ESTRUCTURA-CURSO.md` §6 se reescribe en la última
   tanda (S11), cuando se sepa qué quedó cubierto. Hasta entonces nadie lo toca.
7. **Git lo hace el autor.** Cada tanda deja en §5 el mensaje de commit sugerido. Se borra con `rm`.
8. **Secuencial, sin agentes.** La sesión se para al cerrar cada tanda.

## 3. 📊 Estado

| Tanda | Alcance | Toolchain | Estado |
|---|---|---|---|
| S0 | Plan, directorio de `zz-code`, `extraer.py`, imagen base | — | ✅ 14/11/2026 |
| S1 | F00 · F01 | go1.25.1 + go1.13 | ✅ 14/11/2026 |
| S2 | F02 · F03 | go1.13 | ✅ 14/11/2026 |
| S3 | F04 · F05 | go1.13 | ✅ 14/11/2026 |
| S4 | F06 · F07 (cierra el Bloque A) | go1.13 | ✅ 14/11/2026 |
| S5 | F08, la migración | go1.13 → go1.25.1 | ✅ 14/11/2026 |
| S6 | F09 · F10 (PostgreSQL 16, SQLite, clientes HTTP) | go1.25.1 | ✅ 14/11/2026 |
| S7 | F11 · F12 (MongoDB 7, Valkey 8) | go1.25.1 | ✅ 14/11/2026 |
| S8 | F13 · F14 (lotes, observabilidad, imagen distroless) | go1.25.1 | ✅ 14/11/2026 |
| S9 | F15 y las B-nn de `BENCHMARKS.md` que no se cubrieron antes | go1.25.1 | ✅ 14/11/2026 |
| S10 | El gemelo en `src/clearinghouse-spring/`, el contrato y el duelo de la F16 | go1.25.1 · JDK 21 · Spring Boot 4.1 | ✅ 14/11/2026 |
| S11 | F17 y cierre: avisos, README, guía §14, `0-ESTRUCTURA-CURSO.md` §6, reporte de estado | — | ✅ 14/11/2026 |

## 4. 📦 Las tandas

Cada tanda entrega cuatro cosas:

1. el repositorio del lector al día en `lector/`;
2. `corridas/sNN-*.log` con la corrida literal (versionada: `salidas/` la borra `limpiar.py`);
3. la tabla de la tanda abajo, con una fila por salida del curso: fase y línea, caso (igual, distinta o
   no reproducible) y qué se cambió;
4. las correcciones en las fases, más la línea fechada de la regla 5.

### S1 — F00 · F01 ✅ 14/11/2026

Corridas: `corridas/s1-f00*.log`, `s1-compose.log`, `s1-f01.log` y `s1-regresion.log`, que re-extrae el
curso corregido y termina con `make fmt vet lint test` en verde. Imágenes: `golang:1.25.1-bookworm`,
`postgres:16-alpine` (16.16), `mongo:7` (7.0.48) y `valkey/valkey:8-alpine` (8.1.11).

| Fase:línea | Caso | Qué se hizo |
|---|---|---|
| F00:80, 274, 467 | no reproducible | `darwin/arm64` → la corrida da `linux/arm64`, con la misma forma. Se deja |
| F00:106, 297 + nota de época | **distinta** | En Apple Silicon, `go1.13 download` falla: el envoltorio pide `go1.13.darwin-arm64.tar.gz`, que da 404 (está en el código de `golang.org/dl`). Se añadió la receta `GOARCH=amd64 go install` + `mv` y el aviso sobre `GOBIN` ("cannot install cross-compiled binaries when GOBIN is set"). **Probada en el Mac (M1 Pro, macOS 26, go1.27.1) el 14/11/2026**: `go1.13 version` da `darwin/amd64`; compila, pasa `vet` y ejecuta. Se añadió el `export PATH` antes de `go1.13 download` (sin él, `command not found`) y el aviso de que `go env -u GOBIN` se queja si no existe `go/env` |
| F00:414 | distinta | `count declared and not used` → `declared and not used: count` (formato desde Go 1.20) |
| F00:1010, 1035 + prosa | distinta | `go mod init` escribe `go 1.25.1`, no `go 1.25`; `go get` de un paquete sin importar lo marca `// indirect` |
| F00:832 | **distinta** | `golangci-lint@latest` (v2.15.0) exige Go 1.26. Se fija en `@v2.12.2`, la última que compila con go1.25 |
| F00 `.golangci.yml` | **distinta** | Sin cambios, `make lint` no pasaba con el código del curso: `errcheck` en `defer file.Close()`, `misspell` en los comentarios en español (`cuánto` → `nto`) y `govet inline` en `ioutil` (Bloque A). Se añadió el preset `std-error-handling`, se quitó `misspell` (con su porqué en la prosa) y se desactivó `inline` |
| F00 `Makefile` | **distinta** | `make fmt` fallaba en la raíz: no hay `go.mod` raíz hasta `go.work` (F08). El `Makefile` recorre ahora los módulos y salta los que no tienen `.go` |
| F00:1147–1157 + prosa | **distinta** | El error de `go1.13` con `slices` era el de GOPATH (el real: `malformed module path "slices"`), y con `go 1.13` en el `go.mod` el compilador moderno sí rechaza `slices.Sort`, porque es genérico. Se rehízo con `strings.Cut`: compila con `go` y `go vet` calla aunque el módulo diga `go 1.13`, y `go1.13` falla con `undefined: strings.Cut` |
| F00 `compose.yaml` | igual | Los cuatro servicios quedan en `healthy` y el conjunto `rs0` responde PRIMARY |
| F00 `build-all.sh` | igual | Cinco binarios de ~1,6 MB; tiempos para B-01 (no se copian) |
| F01:460 | distinta | El struct `Movement` no pasaba `gofmt` |
| F01:552 | igual | Se completaron las tres líneas aceptadas en lugar de `...` |
| F01 prueba de fuego del monto | **distinta** | Prometía el mensaje de `strconv` y el código descarta `err`. La prosa dice ahora lo que se ve y cómo hacer aparecer `value out of range` |
| F01:813 | **distinta** | Con 12 bytes el corte no rompe nada (`conciliació…`). Pasa a 11: `conciliaci�…` |
| F01:911–921, 6.1 | distinta | `go mod init` → `go1.13 mod init` (con el moderno, el `go.mod` dice `go 1.25.1`), y se muestra cómo nace el módulo de cada lab |
| F01:1150 | **distinta** | El orden era al revés: la cola sale `WI-002` (8) antes que `WI-001` (7). La prueba de fuego con `-6` ya era correcta |
| F01:108 | distinta | El mensaje real de go1.13 es `cannot use p (type Priority) as type int in assignment` |
| F01 rompe a propósito + INSTINTOS | distinta | Medido: `FirstLineLeaky` retiene 10.494.376 bytes y `FirstLineSafe` unas decenas. "Tres órdenes de magnitud" se cambió por la cifra |
| F01 fragmentos de §4 (L87–344), log-grep, error común 5 | igual | — |

**Fuera de la tanda, para las que siguen:**

- La F04 (`make cover`, §6.6) y la F14 (el `Makefile` pagado) tienen que rimar con el `Makefile` que
  recorre módulos (S3 y S8).
- El `Makefile` usa `GO ?= go` también en el Bloque A. Revisar en S2–S4 si la prosa espera `go1.13`.
- Los ejercicios no se resuelven: no tienen solucionario (decisión de la guía). Solo se comprueba lo
  que un enunciado da como salida literal.
- 👤 Que el autor pruebe en su Mac la receta de Apple Silicon (§6.1 de la F00).


### S2 — F02 · F03 ✅ 14/11/2026

Herramientas nuevas en zz-code: `reconstruir.sh NN`, que rehace `lector/` desde cero con las fases 00..NN;
la fusión de parches en `extraer.py` (un bloque con ruta y sin `package` reemplaza las declaraciones
homónimas); `completar.py`, con lo que las fases omiten a propósito; `scripts/modulos.tsv` y
`scripts/prep.sh`; y `gofmt-curso.py`, que formatea los bloques Go del curso (a los fragmentos solo les
cambia espacios). Corridas: `corridas/s2-*.log`.

| Fase:línea | Caso | Qué se hizo |
|---|---|---|
| Todo el curso | distinta | `gofmt` sobre 22 archivos completos y 108 fragmentos (solo alineación). Ningún bloque tenía el formato que exige el propio curso |
| F02 `java_style.go` | **distinta** | No compilaba: le faltaba `import "fmt"` y redeclaraba `Rectangle` junto a `shapes.go`. Pasa a `labs/shapes/javastyle/` |
| F02 `memstore/store.go`, `opsreport/service.go` | **distinta** | Faltaban los imports `errors` y `sort` |
| F02 `main.go` | distinta | `done, _ :=` no pasaba el `errcheck` del curso (`check-blank`). Ahora maneja el error |
| F02:L115 | distinta | Mensaje real de go1.13 para el receptor por puntero |
| F02 prueba de fuego de imports | distinta | Las listas incluyen la biblioteca estándar; el texto ahora lo dice |
| F02, EventRelay `go mod init` + "edita go.mod" | distinta | Pasa a `go1.13 mod init` |
| F02 `workitem.go` (`// ... como en la Fase 01`) | completado | En `lector/`. La marca del curso ahora nombra todo lo que omite (errores, `maxDescriptionRunes`, `agingBoost`) |
| F02:L494, L1606, L1263 | igual | — |
| F03 `ErrNotFound` | **distinta, de diseño** | `opsreport` importaba `memstore` para preguntar por su `ErrNotFound`, contra la regla de la F02, y `Start` envolvía solo `opsreport.ErrNotFound`, así que el test de la F04 que pide las dos cadenas fallaría. Ahora el centinela vive en `workitem`, `memstore.ErrNotFound` lo envuelve con `%w` y `opsreport.ErrNotFound` lo reexporta. Se probó que `errors.Is` da `true true`. **La F09 (`pgstore`) tiene que seguir el mismo patrón (S6)** |
| F03 `ErrInvalidTransition` | distinta | Se muda a `errors.go`; se añadió la instrucción de borrarla de `workitem.go` |
| F03 EventRelay `json.go` | **distinta** | Usaba `ValidationError`, que no existe en `relay`. El texto dice ahora que se copia en `relay/errors.go` |
| F03 `codec.go` | distinta | Import `encoding/json` sin usar (no compilaba) |
| F03 `buildLargeDocument` | completado | El generador va en `lector/` |
| F03 trampa 3 de JSON | distinta | El pánico real es `interface conversion: interface {} is float64, not int` |
| F03 CLI `./internal/config` | distinta | No existe: pasa a `labs/config-loader` |
| F01 CLI `go1.13 run ./labs/movement-parser` | distinta | Desde la raíz no encuentra `testdata/`: `(cd … && go1.13 run .)` |
| F03 Inspect, `errors.Is/As`, `defer`, LIFO, nil en interfaz, ciclo de imports, JSON, prueba de fuego de validación | igual | — |

### S3 — F04 · F05 ✅ 14/11/2026

`scripts/verde.sh` (al cierre de cada tanda: `make fmt vet lint test` en verde) y `nota-fechada.py`.
Corridas: `corridas/s3-*.log`.

| Fase:línea | Caso | Qué se hizo |
|---|---|---|
| F04 `validator-tests` | **distinta, de diseño** | El lab importaba `opsreport/internal/workitem` desde otro módulo: lo prohíbe la regla de `internal/` que enseña la F03. Pasa a `services/opsreport/internal/workitem/validate_test.go` (`package workitem_test`), con el porqué en la prosa |
| F04 `fakes_test.go` | **distinta** | No tenía ruta completa, `package` ni imports, y faltaban `fakeClock` y `seqIDs`, que la suite de §6.4 usa. Se completó en el bloque |
| F04 suite de §6.4 | **distinta** | "propaga el fallo del almacén" esperaba `ErrStorage` en `Create`, y la F03 solo traducía en `Start`. Ahora la F03 dice que `Create`, `Complete` y `Fail` traducen igual |
| F04 golden | distinta | `-update` falla si no existe `testdata/`; se añadió `mkdir -p` |
| F04:L1232 | **distinta** | La cobertura de la suite es 41,2%, no 84,2%. El texto dice ahora qué falta (los ejercicios) |
| F04 `Makefile` `cover` | distinta | Usaba `./internal/...` desde la raíz. Recorre los módulos que tienen `internal/`, y `cover-html` toma `DIR=` |
| F04 rompe a propósito | distinta | La cobertura no queda igual: pasa de 27,9% a 26,2%. Se corrigió la frase |
| F04:L189, L466, L511, `-run` de subtest | igual | — |
| F05 `main.go` | **distinta** | No tenía imports y usaba `ulid.NewGenerator()`, que no existe en el curso. Se añadieron los imports, `sequentialIDs` (el de la F02) y la nota de que los labs se copian a `internal/{router,middleware,config,clock}` |
| F05 `workitems.go` | **distinta** | Usaba `http.MaxBytesError` (Go 1.19) en el Bloque A, importaba `strconv` sin usarlo y le faltaba `now`. Faltan además `Get` y `Cancel` en el servicio y cinco ayudantes: se enumeran con su contrato en la prosa, y van en `lector/` |
| F05 `errors.go`, `workitems_test.go` | distinta | Faltaba el import de `middleware`; el test no tenía los imports del módulo y sobraba `bytes`. Se dijo de dónde salen `fakeStore` y `seqIDs`, y se anunciaron `mustCreateViaAPI` y `mustPost` |
| F05 `slowloris_test.go` | distinta | No tenía `package` ni imports; ignoraba errores de `Listen`/`Serve` |
| F05 `fakeconsumer` | distinta | `body, _ := ioutil.ReadAll` (errcheck) |
| F05:L255 | distinta | `/slow` está en el socio falso (9100), no en OpsReport (8080, devolvía 404) |
| F05 servidor + `curl`, 405 con `Allow`, 400 de validación, 413, enrutador, socio falso, `/slow` con `--max-time 2`, slowloris (103 goroutines sin timeout, 53 con `ReadHeaderTimeout`) | igual | — |
| F00 `.golangci.yml` | **distinta** | `errorlint` con `errorf-multi: false` (en go1.13, `"%w: %v"` es la única forma), y `noctx` fuera de los `_test.go`, porque pide `NewRequestWithContext` (Go 1.23). En la F03, `//nolint` justificado en dos líneas que son así a propósito |

### S4 — F06 · F07 ✅ 14/11/2026

**Decisión de alcance (tomada en esta tanda).** A partir de la F07, los servicios aparecen en
fragmentos que suponen el servicio entero del lector (`ctx` en todas las firmas, structs a medio
mostrar). Reconstruirlos es escribir el servicio. Por eso: **los labs se corren enteros; de los
servicios se compila lo que la fase muestra completo; la integración queda "no reproducible sin
completar"**, y la línea fechada de cada fase lo dice. La excepción es ClearingHouse, que la S10
necesita para el duelo. Herramientas nuevas: `imports-curso.py`, que añade a los bloques completos
del curso los imports de la biblioteca estándar que faltan (corrió sobre todas las fases: 17
bloques); la deducción de `package` en `extraer.py`; `stubs/<tanda>/`; y `scripts/compila.sh`.
Corridas: `corridas/s4-*.log`.

| Fase:línea | Caso | Qué se hizo |
|---|---|---|
| Curso entero | distinta | 17 bloques completos sin los imports de la biblioteca estándar que usan (F06–F17): añadidos |
| F06 `scale.go`, `deadlock.go`, `leak_test.go` | **distinta** | `scale.go` y `leak_test.go` no tenían `package`. `deadlock.go` usaba `time` sin importarlo y `from.id` sin campo `id` (no compilaba) |
| F06:L569 | distinta | La cifra cambia en cada corrida (51,2%, 37,4% y 43,3%); el texto ahora lo dice |
| F06:L575 | **distinta** | La pila real no nombra `(*Unsafe).Inc()` (está expandida en línea) y la ruta del paquete es `labs/race-counter`, no `labs/counter`. Se puso la real y se explicó `-gcflags=-l` |
| F06:L723, L747 | distinta | Pilas reales del deadlock (marco de `UnbufferedNoReceiver`, `lockSlow`/`Lock`) |
| F06:L833 | igual | `antes=2 después=202 fugadas=200`, exacto. Pero el test fallaba siempre y dejaba `make test` en rojo: ahora registra sin fallar, como `TestUnsafe` |
| F06 `patterns`, `leak-lab`, `unbounded-queue`, motor, dispatcher | completado | Tipos y ayudantes omitidos (`searchDB`, `Input`, `JobExecution`, `Stats`, `ErrShuttingDown`, `Sender`…) en `stubs/f06` |
| F06:L1283 (carrera del dispatcher), B-08 `-cpu` | no reproducible | No hay servicio completo, y el lab no tiene benchmark: a S9 |
| F07 `detect.go`, `worker.go` | distinta | Imports sin usar (`sort`, `strings`, `time`): no compilaban |
| F07 `graceful-server` | igual | `SIGTERM` con una petición de 3 s en curso: el `curl` recibe 200 y después llega "servidor detenido" |
| F07 servicios (L792 y la integración con `ctx`) | no reproducible | Fragmentos; se declara en la línea fechada |

### S5 — F08 ✅ 14/11/2026

Corridas: `corridas/s5-*.log`.

| Fase:línea | Caso | Qué se hizo |
|---|---|---|
| F08 `go.work` (§6.2 y CLI) | **distinta** | `go work init` escribe `go 1.25.1` y ordena los `use`. Y, sobre todo, **con `go.work` en la raíz, los módulos que no están en la lista dejan de compilar** (todos los labs, y el `make` que recorre módulos). Se añadió el aviso y `go work use -r .` |
| F08:L179 `modernize@latest` | **distinta** | gopls v0.24 exige Go 1.27. Se fija en `@v0.21.1`, la última que compila con go1.25, y en `text-toolkit` encuentra `b.Loop()` y el `+=` en bucle |
| F08 fuzzing | distinta | Encuentra `"|||0|"` en 0,11 s, no `"0|0|0|0|"` en 12 s; salida y prosa con la corrida real. El `ls` apuntaba a `services/clearinghouse/`, y el lab es `labs/movement-parser` |
| F08 `-d=loopvar=2` | distinta | Con `all=` informa también de los bucles del runtime; se quitó |
| F08 `slices.Chunk` | **distinta** | No compilaba ni con 1.25: devuelve `iter.Seq` y el `for _, chunk :=` sobraba. Con la directiva en 1.21, el error real es de *range over func* |
| F08 `loopvar.go` (1.21 → `3 3 3`, 1.22 → `1 2 3`), `go get go@1.25.1` | igual | — |
| F08 `String()` de `Movement` | completado | El fuzz test lo usa y la fase no lo escribe |
| F08 migración de servicios, `git diff --stat` | no reproducible | Salen del repositorio del lector |

### S6 — F09 · F10 ✅ 14/11/2026

Infraestructura: red `gfjd-net` y contenedor `gfjd-pg` (`postgres:16-alpine`), los dos con la
etiqueta del curso y sin puertos publicados; `correr.sh` se une a la red con `NET=gfjd-net`.
`versiones-compatibles.sh` calcula, para cada dependencia, la última versión que compila con
go1.25.1. Corridas: `corridas/s6-*.log`.

| Fase:línea | Caso | Qué se hizo |
|---|---|---|
| Curso entero | **distinta, sistémica** | Las versiones `@latest` de las dependencias ya piden Go 1.26 o 1.27, y con `GOTOOLCHAIN=auto` cambian de toolchain sin preguntar. Nueva subsección "Las dependencias, fijadas a go1.25.1" en `0-ESTRUCTURA-CURSO.md` §11, con 14 dependencias, y los `go install …@latest` pasan a versión fijada (goose, mockgen, govulncheck, benchstat, goimports) |
| F09 goose (CLI) | **distinta** | Los dos servicios comparten base y tabla `goose_db_version`: tras migrar EventRelay, `goose redo` de OpsReport falla con `no current version found`. Se añadió `GOOSE_TABLE` por servicio y se probó con `-table` |
| F09 `pgstore.ErrNotFound` | distinta, de diseño | Envuelve `workitem.ErrNotFound`, como `memstore` (S2) |
| F09 `postgres/workitem.go` | distinta | Import `time` sin usar |
| F09 test de integración | distinta | Usaba `goose.Up` sin importar `goose`. Compila con testcontainers v0.44.0 (no se corrió: necesitaría el socket de Docker dentro del contenedor) |
| F09 migraciones, `SKIP LOCKED` (dos sesiones se llevan lotes disjuntos), `pool-lab` (cinco consultas y la sexta espera), SQLite en WAL con sus `CHECK` | igual | — |
| F09 incidente de L1966 | no reproducible | Necesita OpsReport completo |
| F10 REST Countries | **distinta, del mundo** | La v3.1 está retirada: 301 y después **200** con `{"success": false, …}`. La v5 pide clave. Aviso en §6.5; el corpus se graba desde `mledoze/countries` (ODbL), que conserva casi toda la forma; el test `live` ya no puede pasar |
| F10 Frankfurter | distinta | `api.frankfurter.app` responde 301 → `api.frankfurter.dev/v1/latest`. Cambiado en F10, F15 y `proyecto-03` |
| F10 `amplification_test.go` | **distinta** | Mal escrito: la política "fija" no tenía `Max`, así que el techo quedaba en 0 y todo caía en el segundo 0, y `Backoff` siempre aplica jitter. Se reescribió con una función de espera por caso. El fijo da exactamente `[0 0 500 0 500 0 500 0 500 0]`; el jitter con base de 500 ms da `[953 418 …]`, no `[128 97 …]`. Se corrigió la conclusión: el jitter reparte, no frena, y el umbral de 200 lo cruzan los dos |
| F10 clientes de servicios | no reproducible | Paquetes no mostrados |

### S7 — F11 · F12 ✅ 14/11/2026

`gfjd-mongo` (`mongo:7`, 7.0.48) y `gfjd-valkey` (`valkey/valkey:8-alpine`, 8.1.11) en `gfjd-net`.
`imports-curso.py` aprendió los imports externos conocidos (`bson`, `mongo`, `valkey`,
`singleflight`…). Corridas: `corridas/s7-*.log`, `s9-b26.log`.

| Fase:línea | Caso | Qué se hizo |
|---|---|---|
| F11 `traps.go`, `pipelines.go`; F12 `cache.go` | distinta | Usaban `bson`, `mongo` y `valkey` sin importarlos |
| F11 trampas BSON 1, 2, 4 y 6 | igual | Contra `mongo:7`: `commonname`/`updatedat` en minúsculas; la fecha pierde los nanosegundos y `Equal` da `false` (con `Truncate(ms)`, `true`); `omitempty` borra `0` y `false`; `Replace` con un struct sin el campo lo elimina |
| F11:L1445 (`$push` hasta 16 MB) | distinta | El texto prometía el fallo en el punto 187.431. Medido: 200.000 puntos son 7,5 MB y no fallan; el `$push` pasa de 1,9 ms a 41 ms (74 min en total). Salida y lección reescritas, cifras en B-26 |
| F12:L1438 (expiración sincronizada) | **distinta** | Con 20% de jitter sobre 10 s salen cuatro cubetas de ~60 (`[… 68 64 56 62 …]`), no ocho de ~30. `EX` trunca a segundos. Política por defecto, `noeviction`: igual |
| F11/F12, servicios | no reproducible | AtlasSync con Mongo y caché, limitador e idempotencia de EventRelay: fragmentos |

### S8 — F13 · F14 ✅ 14/11/2026

| Fase:línea | Caso | Qué se hizo |
|---|---|---|
| F13 migración de `batches` | **distinta** | goose no la parseaba (`StatementEnd` sin `StatementBegin`) y no tenía `Down`. Corregida y probada de subida y bajada |
| F14 `Dockerfile` | **distinta** | Copiaba `go.work.sum` (que la F08 no versiona: `"/go.work.sum": not found` en un clon limpio) y hacía `go mod download` con un `go.work` que lista módulos no copiados. Ahora copia los dos módulos, arma su propio workspace y usa montajes de caché de BuildKit. Probado con un par sintético: imagen de 13,6 MB, usuario `nonroot`, sin shell |
| F14 y F17, Jaeger | distinta | `all-in-one:latest` no se publica desde el 03/12/2025: `jaegertracing/jaeger:2.23.0`, comprobada (UI 16686, OTLP 4317) |
| F14 `Makefile` | igual | Sus objetivos (`build SVC=`, `cover-check` con `./services/*/internal/...`) funcionan desde la raíz porque, desde la F08, `go.work` cubre todos los módulos |
| F13 trazas del cierre ingenuo, F14 servicios | no reproducible | Código del lector |

### S9 — F15 y BENCHMARKS ✅ 14/11/2026

`ref1.py` inserta en cada entrada la subsección "Resultados de REF-1 (14/11/2026)"; los textos
viven en `ref1-textos/`. REF-1 se llenó con la máquina del curso, y la ficha del lector se
conservó.

| Entrada o fase | Caso | Qué se hizo |
|---|---|---|
| F15 `escape-lab` | **distinta** | `[]byte(s)` no copia en go1.25 cuando no hace falta ("zero-copy string->[]byte conversion"); `strconv.Itoa` hace 1 asignación, no 0; `append` desde cero hace 19, no log₂(n). Comentarios corregidos con la medición |
| B-01, B-02, B-05, B-06, B-20, B-21, B-24, B-25, B-26 | medidas | Ver cada entrada |
| B-03, B-04, B-08 a B-19, B-22, B-23, B-27 a B-29 | no medidas | Cada una dice por qué: benchmarks que el curso no escribe o servicios que solo existen en el repositorio del lector |
| B-07 | parcial | El lado Go (Fase 06) y los hilos de la JVM con un programa mínimo |

### S10 — El gemelo y el duelo ✅ 14/11/2026

Lo publicado: `src/clearinghouse-spring/` (Spring Boot 4.1.1, Java 21, 11 clases, Flyway sobre
`V1__clearinghouse.sql` y `V2__stores.sql`, Spring Batch para el cierre) y su suite de contrato
`contract/` (18 casos, Go). La versión Go de referencia vive en `zz-code/…0144/ch-go` y no se
publica. Corridas: `corridas/s10-*.log`.

| Paso | Resultado |
|---|---|
| Contrato | Go, gemelo JVM y gemelo nativo pasan los 18 casos |
| Libro mayor | Un millón de movimientos sembrados con semilla 42: **1.750.372 asientos con el mismo md5** en Go, JVM y nativo |
| Esquema | Un solo SQL para goose y Flyway. Hibernate (`validate`) rechazó `CHAR(3)`: la moneda pasó a `TEXT` con `CHECK`, en las dos |
| Primer gemelo, lector paginado | El cierre tardaba 145 s frente a 43 s de Go. Diagnóstico: Spring esperaba la base el 75% del tiempo, en la consulta de página (780 ms frente a 190 ms en `psql`). No fue `reWriteBatchedInserts`, ni `prepareThreshold=0`, ni el plan genérico, ni el paralelismo (probado). Con `JdbcCursorItemReader`, 44 s: empate. Queda en el README del gemelo y en B-24 como resultado incómodo |
| `reWriteBatchedInserts` | Se quedó (ajuste estándar), pero rompió el conteo de `accepted`: el driver devuelve `SUCCESS_NO_INFO`. Lo detectó la suite de contrato; ahora se cuenta por la marca de recepción, truncada a microsegundos |
| `native-image` | La imagen `:21` trae GraalVM 21.0.2 (enero de 2024) y Boot 4.1 la rechaza por los metadatos; se compiló con GraalVM CE 25.0.5 (`release 21`): 3 min 42 s, 6,4 GB de pico, 127 MB. El modo `--batch` no funciona en nativo (AOT fija el tipo servlet): el cierre se midió por `POST /runs` |
| Mediciones | B-24 y B-21. AppCDS no se midió |
| Texto | La F16 y el README anuncian el gemelo; la guía §14 abre la excepción del único `src/`; la F16 corrige sus cifras de nativo con la medición |

### S11 — Cierre ✅ 14/11/2026

`0-ESTRUCTURA-CURSO.md` §6 y el README del curso ya no dicen "ilustrativas": dicen qué se corrió
y qué no. Guía §14 y alcance §13 actualizados. Notas fechadas en las 18 fases (F11 incluida
cuando terminó B-26). Verificador, limpieza de Docker y reporte de estado: ver bitácora.

## 5. 📓 Bitácora

- **14/11/2026 · S2–S11.** Todas las tandas cerradas en una sesión, con las preguntas E5–E8
  hechas al principio. B-26 (`$push` hasta 200.000 puntos) tardó 74 min y desmintió el fallo que
  prometía la F11: el documento llega a 7,5 MB. Verificador: 0 errores y los mismos 32 avisos de S1.
  Docker: borrados `gfjd-pg`, `gfjd-mongo`, `gfjd-valkey`, `gfjd-net`, los volúmenes `gfjd-gopath`,
  `gfjd-sdk` y `gfjd-m2` y las imágenes `gfjd-ch:*` y `gfjd-b21:go`; las imágenes base se quedan.
  Commit sugerido: `go-for-java-devs: run every phase output in containers (S2–S11), add the Spring
  Boot 4.1 twin in src/clearinghouse-spring with its contract suite, fill BENCHMARKS REF-1, and date
  each phase`.
- **14/11/2026 · S1.** F00 y F01 corridas y corregidas (tabla de S1). Verificador: 0 errores y 32
  avisos, los 30 de antes más 2 `DIAGRAMA` en `APRENDIZAJE.md`, que son agendas (D-12 las deja en
  `text`). Commit sugerido: `go-for-java-devs: date versions (0-ESTRUCTURA §11), move APRENDIZAJE.md
  out of prompts/, and run F00–F01 outputs (Apple Silicon go1.13 recipe, module-walking Makefile,
  pinned golangci-lint, corrected outputs)`.
- **14/11/2026 · S0.** Plan creado. Directorio `zz-code/go-for-java-devs-20261114-0144`. Inventario
  inicial de Docker en `salidas/inventario-docker-inicial.log`.

## 6. 🧪 Directorios de `zz-code/`

| Directorio | Tandas | Estado |
|---|---|---|
| `go-for-java-devs-20261114-0144` | S0–S11 | cerrado el 14/11/2026 |
