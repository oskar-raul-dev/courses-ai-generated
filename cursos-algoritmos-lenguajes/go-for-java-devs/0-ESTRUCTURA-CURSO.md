# 🗺️ Estructura del curso

> Go para desarrolladores Java senior · la plataforma Meridian
> 18 fases · 4 servicios · 46 mini proyectos · 131 horas

Este documento es **la fuente de verdad del mapa del curso**: qué fase construye
qué, de qué proyecto, con qué mediciones y qué deudas deja. Si algo de aquí
contradice a una fase, manda este documento y la fase se corrige.

---

## 🧭 1. La idea que ordena todo

```text
Bloque A — Fases 00-07   Go 1.13, stdlib pura        El lenguaje sin azúcar
Bloque B — Fase 08 ⭐     La migración                 Dos servicios reales migran
Bloque C — Fases 09-17   Go moderno, ecosistema      El Go que vas a escribir
```

**Por qué empezar en 1.13.** Sin genéricos no hay dónde esconder un diseño
perezoso; sin `slog` se ve qué es un log estructurado; sin `slices` se aprende que
un `for` de cuatro líneas casi siempre gana. Y sobre todo: sin el `ServeMux`
moderno hay que escribir el enrutado a mano una vez, que es la única forma de
entender qué hace Spring MVC por debajo de `@GetMapping`.

**Por qué migrar a mitad y no al final.** Migrando en la Fase 08, más de la mitad
del curso transcurre en Go moderno —el que vas a escribir— y la migración misma es
rica: se migran dos servicios con concurrencia, errores y tests completos, no un
puñado de ejemplos.

**Por qué cuatro proyectos.** Un solo servicio no cubre las cuatro familias de
backend Go que existen: el de datos y lotes, el de red y resiliencia, el de lectura
intensiva con caché, y el transaccional con cierre contable. Y porque el veredicto
final solo es honesto si hay un servicio implementado dos veces.

---

## ⏱️ 2. Las 18 fases

| Fase | Archivo | Época | Horas | Ejerc. | Proyecto que avanza |
|---|---|---|---|---|---|
| 🛠️ 00 | [`00-instalacion-ambiente-y-tooling.md`](00-instalacion-ambiente-y-tooling.md) | previa | 5 | 20 | monorepo |
| 🔤 01 | [`01-sintaxis-y-valores.md`](01-sintaxis-y-valores.md) | 1.13 | 7 | 24 | **OpsReport nace** |
| 🧱 02 | [`02-structs-interfaces-composicion.md`](02-structs-interfaces-composicion.md) | 1.13 | 7 | 26 | OpsReport · **EventRelay nace** |
| 🧯 03 | [`03-errores-paquetes-io.md`](03-errores-paquetes-io.md) | 1.13 | 7 | 24 | ambos |
| 🧪 04 | [`04-testing-dobles-cobertura.md`](04-testing-dobles-cobertura.md) | 1.13 | 8 | 26 | ambos |
| 🌐 05 | [`05-http-rest-stdlib.md`](05-http-rest-stdlib.md) | 1.13 | 8 | 26 | ambos · nace `fakeconsumer` |
| ⚙️ 06 | [`06-concurrencia.md`](06-concurrencia.md) ⭐ | 1.13 | 9 | 30 | ambos |
| ⏱️ 07 | [`07-context-y-ciclo-de-vida.md`](07-context-y-ciclo-de-vida.md) | 1.13 | 7 | 24 | ambos |
| 🚀 08 | [`08-migracion-a-go-moderno.md`](08-migracion-a-go-moderno.md) ⭐ | frontera | 8 | 26 | ambos migran |
| 🗄️ 09 | [`09-sql-postgres-sqlite.md`](09-sql-postgres-sqlite.md) | moderna | 9 | 30 | OpsReport · **ClearingHouse nace** |
| 🔌 10 | [`10-clientes-http-y-apis-externas.md`](10-clientes-http-y-apis-externas.md) | moderna | 8 | 28 | EventRelay · **AtlasSync nace** |
| 🍃 11 | [`11-mongodb-y-modelado-documental.md`](11-mongodb-y-modelado-documental.md) | moderna | 7 | 24 | AtlasSync |
| ⚡ 12 | [`12-cache-con-valkey.md`](12-cache-con-valkey.md) | moderna | 6 | 22 | AtlasSync · EventRelay |
| 📦 13 | [`13-lotes-scheduling-y-asincronia.md`](13-lotes-scheduling-y-asincronia.md) | moderna | 8 | 28 | **los cuatro se conectan** |
| 👁️ 14 | [`14-observabilidad-y-hardening.md`](14-observabilidad-y-hardening.md) | moderna | 7 | 26 | los cuatro |
| 📈 15 | [`15-rendimiento-y-profiling.md`](15-rendimiento-y-profiling.md) | moderna | 7 | 26 | los cuatro |
| ⚖️ 16 | [`16-go-frente-a-spring-boot.md`](16-go-frente-a-spring-boot.md) ⭐ | moderna | 8 | 30 | ClearingHouse ×2 |
| 🏁 17 | [`17-capstone.md`](17-capstone.md) | moderna | 5 | 20 | los cuatro |
| | **Total** | | **131** | **460** | |

Son **unos treinta y tres días de media jornada**. Dos horas diarias, poco más de
tres meses; a tiempo completo, tres semanas y media.

---

## 🏗️ 3. Los cuatro servicios

| # | Servicio | Qué resuelve | Eje técnico | Nace | Doc |
|---|---|---|---|---|---|
| 1 | **OpsReport** | trabajos operativos y reportes | CRUD, jobs, PostgreSQL, streaming | F01 | `prompts/proyecto-01-opsreport.md` |
| 2 | **EventRelay** | webhooks a socios | cliente HTTP, reintentos, idempotencia | F02 | `prompts/proyecto-02-eventrelay.md` |
| 3 | **AtlasSync** | catálogo de referencia | APIs públicas, MongoDB, Valkey, pruebas | F10 | `prompts/proyecto-03-atlassync.md` |
| 4 | **ClearingHouse** | conciliación y cierre | SQLite en el borde, lotes, el duelo | F09 | `prompts/proyecto-04-clearinghouse.md` |

Los dos primeros nacen en Go 1.13 y migran en la Fase 08. Los dos últimos nacen ya
modernos, **y esa asimetría es deliberada**: escribes el mismo tipo de código en
las dos épocas y puedes comparar sin que nadie te lo cuente.

---

## 📌 4. Trazabilidad: qué fase toca qué proyecto

| Fase | OpsReport | EventRelay | AtlasSync | ClearingHouse |
|---|---|---|---|---|
| 01 | nace: dominio | — | — | — |
| 02 | servicio + memoria | nace: dominio + estados | — | — |
| 03 | errores + config | errores + config | — | — |
| 04 | suite unitaria | suite unitaria | — | — |
| 05 | API REST | API REST + `fakeconsumer` | — | — |
| 06 | motor de jobs | cola de entregas | — | — |
| 07 | cancelación + apagado | cancelación + apagado | — | — |
| 08 | migra | migra | — | — |
| 09 | PostgreSQL | cola en base de datos | — | nace: `storeagent` + SQLite |
| 10 | — | cliente HTTP resiliente | nace: ingesta + dobles | `storeagent sync` |
| 11 | — | — | MongoDB | — |
| 12 | — | límite de tasa + idempotencia | caché | — |
| 13 | outbox + reportes | consume el outbox | ingesta programada | cierre por lotes |
| 14 | los cuatro | los cuatro | los cuatro | los cuatro |
| 15 | perfilado | perfilado | perfilado | perfilado |
| 16 | — | — | — | duelo contra Spring |
| 17 | integración final | integración final | integración final | integración final |

---

## 🧰 5. Los 46 mini proyectos

Viven en `labs/`, cada uno con su `main.go` y sus tests, y ninguno supera las
doscientas líneas. **La regla que los mantiene honestos: si un mini proyecto no
alimenta después a un servicio, o sobra o está mal planteado.**

| Fase | Mini proyectos | Alimenta a |
|---|---|---|
| 00 | `hello-go`, `build-info`, `crossbuild` | el monorepo y la Fase 14 |
| 01 | `movement-parser`, `text-toolkit`, `log-grep` | ClearingHouse (F09), EventRelay |
| 02 | `shapes`, `store-registry`, `notifier` | el diseño de los dos servicios |
| 03 | `error-chain`, `config-loader`, `json-codec` | la política de errores y `internal/config` |
| 04 | `validator-tests`, `fake-clock`, `golden-report` | **`fake-clock` se usa en los cuatro** |
| 05 | `tiny-router`, `middleware-chain`, `httptest-lab` | las dos APIs; `tiny-router` muere en la F08 |
| 06 | `race-counter`, `deadlock-lab`, `leak-lab`, `unbounded-queue` | el motor de jobs y el despachador |
| 07 | `cancellable-worker`, `timeout-client`, `graceful-server`, `leak-detector` | el apagado de los cuatro |
| 08 | *(ninguno nuevo)* | — |
| 09 | `pool-lab`, `tx-lab`, `cursor-vs-offset` | la persistencia de los cuatro |
| 10 | `client-timeouts`, `backoff-lab`, `recorded-responses` | EventRelay y AtlasSync |
| 11 | `bson-lab`, `aggregation-lab` | AtlasSync |
| 12 | `cache-aside-lab`, `stampede-lab`, `ratelimit-lab` | AtlasSync y EventRelay |
| 13 | `chunked-stream`, `checkpoint-lab`, `outbox-lab` | el cierre y el outbox |
| 14 | `slog-lab`, `metrics-lab`, `distroless-lab` | los cuatro |
| 15 | `benchstat-lab`, `escape-lab`, `pool-vs-alloc` | el banco de pruebas |
| 16–17 | *(ninguno)* | el banco es el laboratorio |

---

## 📐 6. Las 29 mediciones

Cada afirmación de rendimiento del curso tiene su entrada en
[`BENCHMARKS.md`](BENCHMARKS.md). Ninguna se escribe sin medir.

| ID | Tema | Fase |
|---|---|---|
| B-01 | Compilación cruzada: cinco plataformas, tiempo y tamaño | 00 |
| B-02 | `strings.Builder` frente a `+=` y `fmt.Sprintf` | 01 |
| B-03 | `regexp` compilado fuera del bucle | 01 |
| B-04 | Slice pre-dimensionado frente a `append` | 01 |
| B-05 | Coste de una llamada por interfaz | 02 |
| B-06 | JSON completo frente a streaming | 03 |
| B-07 | Goroutine frente a hilo de la JVM (y hebras virtuales) | 06 |
| B-08 | Canal con búfer frente a mutex | 06 |
| B-09 | Worker pool acotado frente a goroutine por tarea | 06 |
| B-10 | Coste de `-race` | 06 |
| B-11 | El mismo servicio en 1.13 y moderno | 08 |
| B-12 | `ServeMux` moderno frente al enrutado a mano | 08 |
| B-13 | `database/sql` frente a `pgx` nativo | 09 |
| B-14 | SQL a mano frente a `sqlc` frente a GORM | 09 |
| B-15 | Cursor frente a `OFFSET` | 09 |
| B-16 | SQLite con y sin WAL | 09 |
| B-17 | AtlasSync: con y sin caché (y con mapa en memoria) | 12 |
| B-18 | Bytes precodificados frente a codificar por petición | 12 |
| B-19 | Reporte de 500.000 filas: streaming frente a completo | 13 |
| B-20 | Tamaño de fragmento frente a tiempo del cierre | 13 |
| B-21 | Imagen: Go distroless frente a Spring Boot | 14 |
| B-22 | `GOGC` y `GOMEMLIMIT` | 15 |
| B-23 | EventRelay: entregas por segundo | 15 |
| B-24 | **El duelo completo** | 16 |
| B-25 | Amplificación del reintento: fijo frente a exponencial con jitter | 10 |
| B-26 | `$push` sin límite frente al tamaño del documento | 11 |
| B-27 | El despachador del outbox frente al número de instancias | 13 |
| B-28 | Coste del middleware de observabilidad por petición | 15 |
| B-29 | Fake frente a mock generado: tiempo de suite | 10 |

Las cinco últimas se asignaron al cerrar el curso, cuando el repaso de continuidad
encontró siete afirmaciones apoyadas en mediciones propuestas y nunca asignadas.
Las **dos restantes** —el coste de `slog` frente a `log.Printf` y el de `ctx.Value`
por profundidad— se resolvieron por la otra salida que el formato admite:
**suavizar la afirmación a lo estructural**, porque ninguna de las dos cambia una
decisión de diseño.

> 📝 **Las salidas de las fases se corrieron el 14/11/2026**, en contenedores
> `linux/arm64` sobre la máquina REF-1 de [`BENCHMARKS.md`](BENCHMARKS.md), y cada fase
> dice en una nota, después de su §5, qué se reprodujo y qué no. Se reprodujo todo lo que
> el curso entrega completo: los labs, los mensajes del compilador, las salidas de los
> comandos, las migraciones, el gemelo y su duelo. Lo que no: lo que solo existe en tu
> repositorio, es decir, los servicios que construyes a partir de los fragmentos de cada
> fase. Los bloques muestran lo que la fase enseña; los tipos y ayudantes mecánicos que
> no aparecen (un DTO, un generador de datos de prueba, un `searchDB` falso) los escribes
> tú.
>
> Las cifras de rendimiento de las fases son de esa máquina. Las que cuentan para tus
> decisiones son las tuyas: las anotas en la tabla vacía de cada entrada de
> [`BENCHMARKS.md`](BENCHMARKS.md), al lado de los "Resultados de REF-1", y si contradicen
> el veredicto, gana tu número.

---

## 💸 7. Las deudas técnicas y dónde se pagan

Cada 💸 del curso declara su fase de cobro. Este es el inventario completo; la
Fase 17 lo repite en su bloque de autoría con el detalle de cada sección.

| Deuda | Declarada | Pagada |
|---|---|---|
| `Makefile` sin validación · umbral de cobertura | F00 | F14 |
| Verificación por pantalla | F01 | F04 |
| `memstore` no concurrente | F02 | F06 |
| Retroceso lineal sin jitter | F02 | F10 |
| **SSRF en la URL del endpoint** | **F02** | **F14** |
| Logger provisional | F03 | F14 |
| Enrutado a mano | F05 | F08 |
| Sin apagado ordenado | F05 | F07 |
| Cola en memoria · `time.Timer` por entrega | F06 | F09 |
| Apagado sin plazo | F06 | F07 |
| `import _ "time/tzdata"` en imagen mínima | F09 | F14 |
| AtlasSync sin persistencia · caché en memoria | F10 | F11 · F12 |
| Firma HMAC sin verificar | F10 | F14 |
| Hook de pre-commit | F00 | F14 |

> ✅ **Diecisiete de diecisiete.** Ninguna deuda 💸 del curso queda sin cobrar. La
> más larga es la del SSRF: doce fases entre su declaración y su pago, y está así a
> propósito — es el tiempo que una deuda de seguridad sobrevive en un proyecto real
> cuando nadie la agenda.

---

## 📚 8. Documentos del curso

**Transversales, en la raíz:**

- [`README.md`](README.md) — presentación
- **`0-ESTRUCTURA-CURSO.md`** — este documento
- [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md) — commits y tags
- [`00-historia-de-la-empresa-meridian.md`](00-historia-de-la-empresa-meridian.md) — la empresa
  ficticia: personajes, cifras y los incidentes que originaron cada servicio. **Fuente de verdad
  de todo lo narrativo**; ninguna fase inventa un dato de Meridian por su cuenta
- [`INSTINTOS.md`](INSTINTOS.md) — el catálogo de reflejos ☕, **el documento del curso**
- [`BENCHMARKS.md`](BENCHMARKS.md) — el banco de pruebas

**Que el estudiante produce**, en `docs/`:

| Documento | Fase | Qué es |
|---|---|---|
| `errores.md` | 03 | la política de errores de la plataforma |
| `testing.md` | 04 | el régimen de pruebas |
| `rechazos.md` | 08 | lo que se evaluó y se descartó, con condición de revisión |
| `ciclo-de-vida.md` | 07 | el contrato de arranque y apagado |
| `webhooks.md` | 10 | el contrato de integración con los socios |
| `cache.md` | 12 | la política de caché |
| `runbook-cierre.md` | 13 | operación del cierre nocturno |
| `operacion.md` | 14 | el manual de guardia |
| `optimizaciones-fallidas.md` | 15 | **lo que se midió y no funcionó** |
| `veredicto.md` | 16 | la recomendación al arquitecto |
| `defensa.md` | 17 | las ocho preguntas |
| `veredicto-general.md` | 17 | cuándo NO usar Go |
| `postmortem.md` | 17 | el recorrido propio |

**Nota de alcance:** este curso **no tiene apéndices**, y es una decisión
deliberada: lo que normalmente sería un apéndice vive dentro de la fase que lo
necesita, porque el formato "diciendo y haciendo" pierde sentido si hay que saltar
a otro archivo para poder ejecutar el siguiente comando. El precio es que algunas
fases son largas; se acepta.

---

## 🧩 9. La plantilla de fase

Las dieciocho fases tienen **exactamente diez secciones**, en orden:

1. 🎯 Propósito
2. ✅ Qué queda listo al terminar
3. 🚫 Qué NO entra todavía
4. 🧠 Concepto mínimo — con 🪞 y 🩻 obligatorias
5. 🛠️ CLI de la fase
6. 💻 Construcción guiada
7. ⚰️ Autopsia y errores comunes — con al menos un 🧨
8. 🧪 Ejercicios (20–30, con 🟢🟡🟠🔴) — y al final, los 🔴 **Desafíos de cierre**
9. 📚 Referencias
10. ⚖️ Veredicto y cierre — con 📖 diccionario y el bloque 🏷️

Y después, fuera de lo que lee el estudiante, el bloque 📌 de autoría.

**Dos piezas quedan fuera de los presupuestos de la fase** (guía de estilo §9.2),
porque son las que se consultan después de terminarla y acotarlas las
empobrecería:

- **🔴 Desafíos de cierre** — tres por fase, identificados `D1`/`D2`/`D3`, **sin
  numerar y fuera del total declarado**. Son **54 en todo el curso**, y no cubren
  lo mismo que los 🔴 numerados: mientras aquellos consolidan lo enseñado, estos
  atacan **lo que la fase dejó fuera a propósito** — el hueco declarado en su §3,
  la comparación que no se hizo, la herramienta que el temario no montó. Varios
  cierran omisiones reconocidas del propio curso: el `JSONB` que la Fase 09 no
  evaluó (D1 de la Fase 11), el `LISTEN/NOTIFY` que la Fase 13 dejó como sondeo
  (D1 de la Fase 13), o el `CLIENT TRACKING` que la Fase 12 rechazó con condición
  de revisión (D1 de la Fase 12).
- **📚 Referencias** — obligatoria y **nunca se recorta por longitud**. Si hay que
  quitar contenido de una fase, sale de la §6.

**Total de ejercicios: 460 numerados + 54 desafíos de cierre + los 🔥 opcionales.**

**Los marcadores del curso:** ☕ reflejo Java · 🩻 esto sí funciona igual · 🕰️ fuera
de época · 💸 deuda intencional · ⭐ pieza central · 🔥 opcional · 📐 medido · 🧨
rompe a propósito · 🏷️ tag.

---

## 🚦 10. Por dónde empezar

1. [`00-instalacion-ambiente-y-tooling.md`](00-instalacion-ambiente-y-tooling.md) — deja la máquina lista.
2. De ahí **en orden**. Las fases se apoyan unas en otras y no se saltan: la Fase
   08 no tiene sentido sin el Bloque A, y la 16 no tiene sentido sin las quince
   anteriores.
3. **No dejes `INSTINTOS.md` ni `BENCHMARKS.md` para el final.** Se alimentan al
   cerrar cada fase; si se dejan para la 17, ninguno se hace bien.

**Requisitos:** ocho años o más de backend en Java, Docker, y un terminal.

---

## 🗓️ 11. Las versiones del curso, con su fecha

El curso se escribió en septiembre de 2026 y fija sus versiones para que todo lo que
ejecutas sea reproducible. Pero una versión sin fecha envejece sin que nadie lo note.
Esta tabla le pone fecha a cada una, dice cuál es la vigente al **14/11/2026** y de
dónde sale ese dato. **El curso no cambia de versión**: las fases siguen escritas
contra la columna "Lo que fija el curso".

| Pieza | Lo que fija el curso | Publicada | Vigente al 14/11/2026 | Qué significa para ti |
|---|---|---|---|---|
| Go, Bloque A | go1.13 | 03/09/2019 | — | Es la época a propósito (§1). No recibe parches desde 2020 y no se usa fuera del curso |
| Go, Bloques B y C | go1.25.1 | 03/09/2025 | go1.27.3 (1.27: 19/08/2026) | Go da soporte a las dos últimas versiones mayores. La 1.25 quedó sin parches cuando salió la 1.27. Para el curso da igual; en producción usa la vigente |
| JDK | 21 (LTS) | 19/09/2023 | 25 (LTS, 16/09/2025) | El 21 sigue con soporte de largo plazo, así que la comparación de la Fase 16 sigue siendo justa |
| Spring Boot | 3 (texto) · 4.1 (gemelo) | 4.1.0: 10/06/2026 | 4.1.1 (20/08/2026) | La línea 3.5 perdió el soporte libre el 30/06/2026; por eso el gemelo de la Fase 16 se escribe en 4.1 |
| PostgreSQL | 16 (`postgres:16-alpine`) | 14/09/2023 | 18; la 19 está en RC, con salida prevista el 19/11/2026 | Lo que usa el curso es SQL estándar y no cambia de la 16 a la 18 |
| MongoDB | 7 (`mongo:7`) | 15/08/2023 | 8.0 (mayor) · 8.3 (rápida) | Nada de la Fase 11 depende de algo posterior a la 7 |
| Valkey | 8 (`valkey/valkey:8-alpine`) | 15/09/2024 | 9.1.x · la 8.1 todavía recibe parches | Los comandos de la Fase 12 son los mismos en la 9 |

### Las dependencias, fijadas a go1.25.1

Las bibliotecas siguen subiendo su versión mínima de Go, y desde 2026 muchas piden
Go 1.26. Con `GOTOOLCHAIN=auto`, el valor por defecto, un `go get` o un `go install`
de una de esas versiones **te cambia de toolchain sin preguntar**: sube la directiva
`go` de tu `go.mod` y descarga otro compilador. Para que el curso siga siendo el
curso, cada dependencia se instala con la última versión que todavía compila con
go1.25.1. Si quieres que Go falle en vez de cambiarte de toolchain sin avisar:
`go env -w GOTOOLCHAIN=local`.

| Dependencia | Fase | Versión fijada | La más nueva, y lo que pide |
|---|---|---|---|
| `golangci-lint` | 00 | v2.12.2 | v2.15.0, Go 1.26 |
| `goimports` (`golang.org/x/tools`) | 00 | v0.49.0 | v0.52.0, Go 1.26 |
| `modernize` (`golang.org/x/tools/gopls`) | 08 | v0.21.1 | v0.24.0, Go 1.27 |
| `github.com/jackc/pgx/v5` | 09 | v5.13.0 | la misma |
| `goose` (`github.com/pressly/goose/v3`) | 09 | v3.27.0 | v3.30.1, Go 1.26 |
| `modernc.org/sqlite` | 09 | v1.59.0 | v1.62.0, Go 1.26 |
| `testcontainers-go` y su módulo `postgres` | 09 | v0.44.0 | v0.45.0, Go 1.26 |
| `mockgen` (`go.uber.org/mock`) | 10 | v0.6.0 | la misma |
| `go.mongodb.org/mongo-driver/v2` | 11 | v2.10.0 | la misma |
| `github.com/valkey-io/valkey-go` | 12 | v1.0.79 | la misma |
| `golang.org/x/sync` (`errgroup`, `singleflight`) | 08, 12 | v0.22.0 | v0.25.0, Go 1.26 |
| `github.com/prometheus/client_golang` | 14 | v1.24.1 | v1.25.0, Go 1.26 |
| `govulncheck` (`golang.org/x/vuln`) | 14 | v1.7.0 | v1.9.0, Go 1.26 |
| `benchstat` (`golang.org/x/perf`) | 15 | v0.0.0-20260112171951-5abaabe9f1bd | sin versiones etiquetadas; la de octubre de 2026 pide Go 1.26 |

Para una biblioteca, `go get github.com/jackc/pgx/v5@v5.13.0`. Para una herramienta,
el `go install …@versión` de su fase ya lleva la versión fijada.

📝 **Fuentes**, consultadas el 14/11/2026: el historial de versiones de Go
(https://go.dev/doc/devel/release) y su política de soporte; las versiones y el
`go.mod` de cada dependencia en el proxy de módulos (https://proxy.golang.org); el blog de Spring
(https://spring.io/blog), con los anuncios de 4.1.0 y 4.1.1; los anuncios de
PostgreSQL (https://www.postgresql.org/about/news/), la descarga de Valkey
(https://valkey.io/download/) y las notas de versión de MongoDB
(https://www.mongodb.com/docs/manual/release-notes/). La próxima revisión del curso
actualiza esta tabla antes de tocar una sola fase.
