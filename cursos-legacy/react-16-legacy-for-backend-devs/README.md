# ⚛️ React 16 Legacy — para devs de backend

Tutorial práctico y **autocontenido** de **98 horas** para desarrolladores senior
de backend que necesitan aprender a mantener una aplicación React 16 heredada.
El objetivo no es que aprendas a escribir React bonito: es que puedas **leer
código ajeno y viejo, reproducir un bug desde un ticket vago, depurarlo y
aplicar un hotfix que no rompa otras tres cosas**.

No necesitas acceso a ningún sistema previo, ni a un repositorio de empresa, ni
a un instructor. Todo lo que el curso usa lo construyes tú a lo largo de las
fases, con las versiones y los comandos exactos escritos en
`00-decisiones-y-versiones.md`.

## 🏢 El sistema: La Esclusa, la consola de Jewel Locks

**Interoceanic Games es un estudio ficticio** de Ciudad de Panamá, y su
juego, *Jewel Locks*, también lo es. Lo inventamos para este curso, íntegro, y esa
es justamente la gracia: te podemos contar su historia completa —quién escribió
cada parte, en qué año, con qué prisa y con qué presupuesto— porque no hay nada que
ocultar. Jewel Locks es un juego de gemas para Android con una **rueda de
premios**: el jugador gira con giros gratis o comprados en Google Play, y gana
vidas, avatares y sets de gemas. **La Esclusa** es la consola interna con la que el
estudio arma esas ruedas, compensa a jugadores, sigue las compras pendientes y
concilia lo que la rueda entregó contra lo que publica. La escribió una agencia en
2019, la siguieron dos freelancers de Lima, y hoy la hereda un equipo de Colombia
—tú incluido— con un evento por mes en el calendario y una decisión que tomar en
2028: apagarla o migrarla.

Se eligió ese dominio porque cualquiera entiende una rueda de premios sin
explicación previa, y porque concentra en poco espacio las cuatro cosas que hacen
difícil un frontend: **concurrencia** (dos envíos del mismo caso que se cruzan),
**tiempo** (una rueda que cierra a una hora exacta, en otra zona), **dinero**
(que no perdona un centavo) y **reactividad** (polling que hay que saber apagar).

La historia del sistema —sus eras, la noche de la Esclusa de Oro, quién dejó cada
cosa y por qué está como está— vive en
[`00-historia-del-sistema.md`](00-historia-del-sistema.md). Léela antes de la
Fase 0: entender por qué un código es como es cambia por completo cómo lo tocas.

## 🎯 Qué vas a saber hacer al terminar

Leer código legacy mezclado (clases con `componentDidMount` conviviendo con
hooks, `connect()` conviviendo con `useSelector`) sin marearte. Detectar y
reproducir bugs en cualquier capa: componente, store, epic o backend. Entender
epics de `redux-observable` —cancelación, race conditions, memory leaks—, que es
el salto conceptual real de este curso. Distinguir una corrección mínima de una
refactorización, y defender cuál corresponde. Escribir la prueba de regresión
**antes** del fix. Y auditar con números si una rueda da lo que publica.

Lo que **no** es objetivo: formar arquitectos de React, promover patrones
modernos idealizados ni migrar el sistema. La modernización aparece solo como
comparación o en secciones 🔥.

## 👤 Para quién es

Desarrollador **backend o full-stack senior**. Damos por sabidos JavaScript,
HTML, CSS, HTTP, JSON, autenticación y APIs REST: no se gasta espacio
explicándolos. Puedes conocer React moderno, pero probablemente no class
components, y casi seguro no RxJS ni las pruebas de canicas. Ahí es donde el curso
pone el peso.

## 📚 Estructura

**Doce fases (0-11)**, cada una en su `.md`, con la misma plantilla de nueve
secciones: propósito, qué queda listo, qué queda fuera, conceptos mínimos,
implementación comentada, errores comunes y pieza forense, ejercicios,
referencias y cierre.

| # | Fase | Foco | Horas |
|---|---|---|---|
| 00 | [Setup + Hola mundo CRA](00-setup-hola-mundo-cra.md) | Ambiente, CRA 4, primer componente | 6 |
| 01 | [Estructura base + Router 5](01-estructura-base-router-5.md) | Rutas, layout, clases y hooks juntos | 8 |
| 02 | [Autenticación mínima](02-autenticacion-minima.md) | Store, interceptores, `requestId` | 8 |
| 03 | [Mock API + Express caos](03-mock-api-express-caos.md) | Fallos, latencia y 401 a propósito; el giro de 2019 bajo carga | 6 |
| 04 | [Ruedas CRUD](04-ruedas-crud.md) | Thunks, slices, estados de carga, pesos que suman 10.000 | 8 |
| 05 | [⭐ Envíos manuales](05-envios-manuales.md) | Race conditions en el store, UI optimista, rollback | 12 |
| 06 | [⭐ redux-observable a fondo](06-redux-observable-a-fondo.md) | Epics, cancelación, memory leaks | 12 |
| 07 | [Cierre a hora exacta + polling de compras](07-cierre-polling-compras.md) | Hora dura, zona horaria, `takeUntil` | 10 |
| 08 | [Conciliación](08-conciliacion.md) | Dinero en enteros; ¿la rueda da lo que publica? | 10 |
| 09 | [Dashboard](09-dashboard.md) | Memoización, performance, charts | 6 |
| 10 | [Testing mínimo](10-testing-minimo.md) | Jest, RTL, canicas, smoke con Cypress | 6 |
| 11 | [Cierre + puente a React moderno](11-cierre-puente-react-moderno.md) | Migrar con red, cerrar el ciclo | 6 |

**Catorce apéndices** de consulta rápida, que no se leen de corrido: los abres
cuando una fase te manda a ellos.

| # | Apéndice | Para cuándo |
|---|---|---|
| A1 | [`A1-bootstrap-4-y-sass.md`](A1-bootstrap-4-y-sass.md) | Grid, cards, forms y utilidades de Bootstrap 4 |
| A2 | [`A2-mini-design-system.md`](A2-mini-design-system.md) | Tokens, mixins y cómo extender Bootstrap con Sass |
| A3 | [`A3-node-y-npm.md`](A3-node-y-npm.md) | `npm ci`, semver, lockfile, "en mi máquina anda" |
| A4 | [`A4-cra-por-dentro.md`](A4-cra-por-dentro.md) | Qué esconde `react-scripts` y por qué no hacemos `eject` |
| A5 | [`A5-class-components-vs-hooks.md`](A5-class-components-vs-hooks.md) | Traducir `componentDidMount` a `useEffect` y viceversa |
| A6 | [`A6-redux-clasico-vs-toolkit.md`](A6-redux-clasico-vs-toolkit.md) | `connect()` frente a `useSelector`, `switch` frente a `createSlice` |
| A7 | [`A7-redux-observable-epica-por-epica.md`](A7-redux-observable-epica-por-epica.md) | Qué operador de RxJS toca y qué error trae cada uno |
| A8 | [`A8-puente-a-react-moderno.md`](A8-puente-a-react-moderno.md) | Qué hay del otro lado: React 17/18, RTK Query, RxJS 7 |
| A9 | [`A9-entornos-y-contenedores.md`](A9-entornos-y-contenedores.md) | Cuándo necesitas contenedor y cuándo no |
| A10 | [`A10-aritmetica-de-dinero.md`](A10-aritmetica-de-dinero.md) | Centavos enteros, redondeo y repartos que cuadran |
| A11 | [`A11-marble-testing.md`](A11-marble-testing.md) | Probar que un epic **deja** de emitir |
| A12 | [`A12-mapa-de-deuda-tecnica.md`](A12-mapa-de-deuda-tecnica.md) | Qué está feo a propósito y qué lo vuelve exigible |
| A13 | [`A13-depurar-el-build-de-produccion.md`](A13-depurar-el-build-de-produccion.md) | Source maps, bundles minificados, UAT frente a PROD |
| A14 | [`A14-estadistica-para-auditar-una-rueda.md`](A14-estadistica-para-auditar-una-rueda.md) | La banda de ±3σ, el chi-cuadrado sin tabla y cuánta muestra hace falta |

**Un cuaderno de incidentes** ([`cuaderno-incidentes.md`](cuaderno-incidentes.md)):
veintiún tickets vagos —como llegan en la vida real— con pistas escalonadas y
solución de referencia colapsada. Es donde se entrena el músculo central del curso.
Cinco de los veintiuno son de RxJS, porque son los que más caro salen.

Y una puerta de entrada que se usa más que el índice: la sección 🩺 **"Entrar por
el síntoma"**, con el método de cuatro preguntas y una tabla que va de la frase del
ticket —*"a veces no carga"*, *"verde en mi máquina, rojo en la de al lado"*— a la
primera herramienta que hay que abrir. Porque nadie llega a una investigación
sabiendo de qué fase es su problema.

> 🧭 **Tres de los veintiuno no terminan en un commit.** Uno cierra en
> documentación, otro en un *"no se reproduce, y acá está la evidencia"*, y el
> último —el de la rueda que dice 15 % y entrega 5 %— en una decisión que hay que
> escribir y firmar con el estudio. Ese desenlace es tan real como un fix y casi
> nunca se practica.

**Y una convención de git** ([`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md)):
cómo versionas el código que escribes mientras haces el curso —un repo por
aplicación, commits con el prefijo de la fase, un tag anotado por fase cerrada, y
los pares `-roto` / `-fix` que convierten cada incidente resuelto en un `git diff`
que se entiende dentro de seis meses—.

**Y dos documentos de consulta**, que no se leen de corrido:
[`00-decisiones-y-versiones.md`](00-decisiones-y-versiones.md), con cada versión
congelada, el `package.json` y el `go.mod` de referencia, los puertos y las
decisiones D1–D38 con su porqué; y
[`00-alcance-del-proyecto.md`](00-alcance-del-proyecto.md), con qué cubre el curso,
qué deja fuera y cuántas horas lleva cada track.

## 🔥 Track BE opcional — el backend de verdad (be00–be09)

Las doce fases de arriba se completan **enteras contra el mock**, y ahí termina
el curso de 98 horas. Pero el mock dejó deudas 💸 que ninguna fase de frontend
puede pagar: el token es una constante escrita a mano, el `409` del envío repetido
lo produce un `if` en JavaScript, la hora de cierre la evalúa el reloj del
navegador, y el giro de 2019 entregó 1.047 Esclusas de Oro de un stock de 1.000.

El **track BE** es opcional y las paga. Diez fases más (**86 horas aparte**, que
no cuentan en las 98) donde reemplazas `json-server` por un backend real en **Go
1.19 contra PostgreSQL 13**, con una regla que lo ordena todo:

> 🧭 **Se apaga el mock, se levanta el binario de Go en el mismo puerto `3001`, y
> la consola no cambia ni un archivo** (salvo el que la Fase 2 señaló, `D27`).

Se puede empezar **en cuanto termines la Fase 8**. Las versiones y las decisiones
propias del track (D14–D38) están en la §7 de `00-decisiones-y-versiones.md`.

| # | Fase | Foco | Horas |
|---|---|---|---|
| be00 | [El contrato: auditoría del mock](be00-el-contrato-auditoria-del-mock.md) | Qué consume la consola, medido con Network | 6 |
| be01 | [Go 1.19 y la forma del monolito](be01-go-y-la-forma-del-monolito.md) | `net/http`, middlewares, `context`, el caos en Go | 8 |
| be02 | [La costura de datos](be02-la-costura-de-datos.md) | Dos motores, migraciones y el mito de la agnosia SQL | 10 |
| be03 | [CRUD y el reemplazo 🪦](be03-crud-y-el-reemplazo.md) | El mock se apaga y la consola no se entera | 10 |
| be04 | [Identidad real](be04-identidad-real-jwt-y-un-cve.md) | bcrypt, JWT, un CVE y su post-mortem | 8 |
| be05 | [⭐ El giro concurrente](be05-giro-concurrente.md) | El giro como hecho, `FOR UPDATE` contra escritura condicional, medido con k6 | 12 |
| be06 | [Hora dura y la autoridad del reloj](be06-hora-dura-y-la-autoridad-del-reloj.md) | `TIMESTAMPTZ`, el cierre en el servidor, el giro gratis cada 4 h | 8 |
| be07 | [Compras y conciliación](be07-compras-y-conciliacion.md) | La compra una vez, la conciliación en SQL, la protección con sustituto | 6 |
| be08 | [Pruebas y la regla del motor](be08-pruebas-y-la-regla-del-motor.md) | Cuándo SQLite te engaña; la estadística sembrada y la carga | 10 |
| be09 | [Empaquetado y pipeline](be09-empaquetado-ambientes-y-pipeline.md) | Imagen, ambientes, CI y el veredicto honesto, con 2028 | 8 |

Y **once apéndices propios** (`bea-01` a `bea-11`):

| # | Apéndice | Para cuándo |
|---|---|---|
| bea-01 | [`bea-01-go-para-quien-no-escribe-go.md`](bea-01-go-para-quien-no-escribe-go.md) | Lo que Go hace distinto de lo que ya sabes, en el orden en que aparece |
| bea-02 | [`bea-02-receta-de-imagen-y-compose.md`](bea-02-receta-de-imagen-y-compose.md) | Postgres en contenedor, el `Dockerfile` con y sin cgo, compose |
| bea-03 | [`bea-03-sql-portable-y-dialectos.md`](bea-03-sql-portable-y-dialectos.md) | Lo que cambia entre PostgreSQL y SQLite |
| bea-04 | [`bea-04-jwt-por-dentro-y-su-cve.md`](bea-04-jwt-por-dentro-y-su-cve.md) | Qué firma un JWT y por qué no se revoca |
| bea-05 | [`bea-05-concurrencia-en-postgres.md`](bea-05-concurrencia-en-postgres.md) | Aislamiento, `FOR UPDATE`, deadlocks, en dos terminales |
| bea-06 | [`bea-06-tiempo-zonas-y-relojes.md`](bea-06-tiempo-zonas-y-relojes.md) | Instantes, horario de verano y el reloj del cliente |
| bea-07 | [`bea-07-logs-request-id-y-correlacion.md`](bea-07-logs-request-id-y-correlacion.md) | Seguir un `X-Request-Id` del navegador a la base |
| bea-08 | [`bea-08-seguridad-de-api-aplicada.md`](bea-08-seguridad-de-api-aplicada.md) | Lo que este backend cubre y lo que deja fuera |
| bea-09 | [`bea-09-mapa-de-deuda-del-track-be.md`](bea-09-mapa-de-deuda-del-track-be.md) | Qué deuda sigue viva, y cuál se paga sola en 2028 |
| bea-10 | [`bea-10-datos-de-prueba-y-faker.md`](bea-10-datos-de-prueba-y-faker.md) | 🔥 Volumen de prueba con semilla |
| bea-11 | [`bea-11-k6-101.md`](bea-11-k6-101.md) | k6 en contenedor, escenarios y los errores que dan números falsos |

Y **su propio cuaderno de incidentes** ([`cuaderno-incidentes-be.md`](cuaderno-incidentes-be.md)):
dieciocho tickets vagos que ocurren del otro lado del cable —en el binario, en
Postgres, en el contenedor o en el pipeline—, con pistas escalonadas y solución de
referencia colapsada. Seis son hermanos de incidentes del track base: el mismo
síntoma, resuelto en la capa donde de verdad vivía.

---

## 🛠️ Stack

Node 14.21.3 · React 16.14.0 · CRA / react-scripts 4.0.3 · Redux 4.1.2 · Redux
Toolkit 1.8.6 · redux-observable 1.2.0 · RxJS 6.6.7 · React Router 5.3.4 · axios
0.21.4 · Bootstrap 4.6.2 · Jest 26 · React Testing Library 11 · Cypress (smoke) ·
chart.js 2.9.4. En el track BE: Go 1.19.13 · PostgreSQL 13 · k6 1.5.0.

Las versiones exactas, el `package.json` completo, qué instala cada fase y el
porqué de cada decisión están en **`00-decisiones-y-versiones.md`**, que es la
fuente de verdad. Si un número aparece en dos sitios y no coinciden, gana ese
archivo.

Nada de React 17/18, Router 6, RTK 2 ni RxJS 7 en el código principal: aparecen
solo como comparación. Todo corre local, contra un `json-server` y dos mocks de
Express —el API del `3001` y Google Play en el `3002`— que **fallan a propósito**.

## 🚀 Cómo se recorre

Lee `00-historia-del-sistema.md` primero, para saber qué estás heredando. Después
las fases en orden: cada una construye sobre la anterior y ninguna se sostiene
sola. Los apéndices se consultan cuando la fase te manda a ellos. Los incidentes
se abren cuando llegas a la fase que los produce: el índice del cuaderno te dice
cuál corresponde a cada momento.

**Cierra cada fase con su tag** (`git tag -a fase-04-ruedas-crud …`). Es el hábito
que después te deja correr `git tag -l 'fase-*'` y saber dónde estás sin releer
nada, y, en un curso donde vas a romper cosas a propósito, el que te deja volver
a un estado sano sin pensarlo. La convención completa está en
`00-convencion-de-git-y-tags.md` y se lee en diez minutos.

Y una advertencia sobre el cuaderno: cada incidente trae su solución adentro,
colapsada. Abrirla antes de escribir tu propio diagnóstico no te ahorra tiempo,
te ahorra el aprendizaje. 😉

## 📐 Convenciones

Tu progreso se lleva en git: un repo por aplicación, commits con el prefijo de
la fase (`f04: …`), un tag anotado por fase cerrada y pares de tags
`-roto` / `-fix` para los incidentes. Todo eso está en
`00-convencion-de-git-y-tags.md`.

El código va **en inglés** (identificadores, endpoints, constantes). Los
comentarios, los textos de interfaz y toda la narrativa van **en español
latinoamericano con tuteo**. Para no dudar al nombrar algo, estos son los
términos del dominio y su nombre en código:

| En el curso | En el código | En la base (track BE) |
|---|---|---|
| rueda | `wheel` | `wheels`, con sus versiones en `wheel_versions` |
| segmento | `segment` | `wheel_segments` |
| peso de un segmento | `weightBp` (puntos básicos; suman 10.000) | `weight_bp` |
| jugador | `player` | `players` |
| saldo de giros | `freeSpins`, `paidSpins` | `free_spins`, `paid_spins` |
| giro | `spin` | `spin_log` (la bitácora, solo se agrega) |
| segmento en que cayó / premio entregado | `landedSegment` / `deliveredPrize` | `landed_segment` / `delivered_prize` |
| envío manual | `grant`, `sendGrant` | `grants` |
| compra | `purchase`, `purchaseToken` | `purchases` |
| conciliación | `reconciliation`, `oddsAudit` | `reconciliations` |
| hora de cierre | `closesAt` | `closes_at` |

Los estados de una rueda son `draft` → `scheduled` → `live` → `ended` →
`reconciled`, y los de un envío, `queued` → `sending` → `sent` (o `failed`, o
`reverted` dentro de la ventana de deshacer). Los nombres se arman con esos
términos y verbos en inglés: `fetchWheels`, `sendGrant`, `wheelSlice`,
`pollingEpic`, `selectPurchases`. En el backend, las tablas van en plural y
`snake_case`, las etiquetas JSON en `camelCase` como las consume la consola, y la
columna puede llamarse distinto que la etiqueta (`wheel_segments` frente a
`segments`): la etiqueta es el contrato, la columna no.

---

## 📜 Licencia y ficción

Texto y código, bajo **CC BY-SA 4.0**. Los detalles y los enlaces están en [`LICENSE.md`](LICENSE.md).
Interoceanic Games, Jewel Locks, La Esclusa y las personas de la historia son ficticios.
