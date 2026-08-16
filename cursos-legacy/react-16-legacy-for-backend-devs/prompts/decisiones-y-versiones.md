# 🔒 Decisiones y versiones congeladas

> Tutorial React 16 — Rifas y Chances · Documento de referencia · **Fuente de verdad de versiones**
> Lo citan: todas las fases y apéndices · No es lectura secuencial: se consulta.

Este archivo existe para que el curso se sostenga solo. Cada vez que una fase
escribe `(D4)` o dice "la versión fijada", apunta acá. Si un número de versión
aparece en dos archivos y no coinciden, **gana este**.

Antes de que existiera, las decisiones circulaban como códigos `D1`…`D13`
repartidos por diez archivos y una cita a un `DECISIONES-CONFIRMADAS.md` que
nunca se escribió. Eso convertía cada duda de versión en arqueología. Acá está
todo junto, con el porqué al lado.

---

## 1. Cómo se leen estas decisiones

Una decisión congelada no es una opinión sobre qué es mejor hoy. Es un hecho
del sistema que vas a mantener: **así está, y tu trabajo es trabajar con eso**,
no discutirlo. Cuando el curso te muestre una alternativa moderna, la vas a ver
marcada 🔥 y fuera del código principal.

Cada decisión trae tres cosas: qué se fijó, por qué se fijó así en su momento
—la 📝 nota de época—, y qué la volvería revisable. Esa última columna importa
más de lo que parece: distingue "está así porque alguien lo pensó" de "está así
porque nadie lo tocó".

> 🧭 **La regla que gobierna todo este archivo:** ninguna versión se cambia sin
> justificarlo por escrito. En un sistema legacy, cambiar una versión "porque
> hay una más nueva" es la forma más barata de generar un incidente.

---

## 2. El registro de decisiones (D1–D13, track base)

### D1 — React y React DOM 16.14.0

**Qué se fijó.** `react` y `react-dom` en `16.14.0`, y ese es el punto final de
referencia del curso. No se usan APIs de React 17 ni 18 en el código principal:
nada de `createRoot`, `useTransition`, `useId`, batching automático ni
`useSyncExternalStore`.

📝 **Nota de época.** 16.14.0 (octubre de 2020) fue la última menor de la línea
16. Trajo el nuevo transform de JSX —el que te deja escribir JSX sin importar
`React`— y poco más. Es exactamente la versión en la que muchísimos proyectos
de 2020-2021 se quedaron parados: ya tenían hooks (16.8), ya tenían el transform
nuevo, y saltar a 17 no ofrecía nada que justificara el riesgo.

**Qué la vuelve revisable.** Un requisito que solo React 18 resuelve (SSR
streaming, concurrencia real). Ver `A8-puente-a-react-moderno.md` para el costo.

---

### D2 — redux-observable 1.2.0 sobre RxJS 6.6.7

**Qué se fijó.** `redux-observable@1.2.0` y `rxjs@6.6.7`. Los epics son el
mecanismo de async temporal del sistema; los thunks siguen siendo válidos para
el async simple (ver D4).

📝 **Nota de época.** redux-observable 1.2.0 es de enero de 2019 y nunca tuvo
una 2.x. RxJS 6.6.7 (abril de 2021) es la última 6.x. La combinación era el
estándar de facto para "Redux con cancelación" en la época, antes de que RTK
Query se comiera buena parte de esos casos de uso.

⚠️ **La trampa práctica.** RxJS 7 cambió imports y firmas (`retry({count, delay})`,
`toPromise()` deprecado). Cualquier ejemplo de internet posterior a 2021
probablemente sea 7.x y **no compila acá**. La chuleta de imports correcta está
en `A7-redux-observable-epica-por-epica.md` §Chuleta de imports.

**Qué la vuelve revisable.** Nada dentro del curso. Fuera de él, ver A8 §7.

---

### D3 — JavaScript plano (ES2019), sin TypeScript

**Qué se fijó.** JavaScript, no TypeScript. Donde el tipo aporta a la lectura,
se documenta con **JSDoc** (`@typedef`, `@param`, `@returns`), que CRA 4 y los
editores entienden sin configuración extra.

📝 **Nota de época.** En 2019-2020, TypeScript era mayoritario en proyectos
nuevos pero minoritario en los que ya venían andando: migrar una base de JS a TS
es un proyecto en sí mismo, no un fin de semana. Un sistema de esta época en JS
plano es lo más común que te vas a encontrar.

**Qué la vuelve revisable.** Nada en este curso. Una migración a TS es un
proyecto con su propio presupuesto, no una tarea de mantenimiento.

---

### D4 — Redux Toolkit 1.8.x en el código nuevo; Redux clásico donde ya vive

**Qué se fijó.** `@reduxjs/toolkit@1.8.6` con `createSlice`, `configureStore` y
`createAsyncThunk`. Convive con `connect()` de `react-redux` 7.2.x en los
componentes viejos. **RTK Query queda solo mencionada**, nunca adoptada.

📝 **Nota de época.** RTK 1.8 (marzo de 2022) es de la línea que todavía usaba
`createSlice` con la firma de objeto y sin `builder.addCase` obligatorio en todos
lados. RTK 2.x (diciembre de 2023) cambió imports y sacó APIs deprecadas: la
documentación oficial de hoy cubre 2.x y **algunos ejemplos no aplican**.

**Qué la vuelve revisable.** Un salto a RTK 2 exige tocar React-Redux 8+ y
revisar cada `createSlice`. Ver `A6-redux-clasico-vs-toolkit.md`.

---

### D5 — React Router 5.3.4

**Qué se fijó.** `react-router-dom@5.3.4`: `<Switch>`, `component=`/`render=`,
`useHistory`, `useParams`, `useLocation`, `withRouter` para las clases.

📝 **Nota de época.** 5.3.4 (octubre de 2022) es la última 5.x. La v6 salió en
noviembre de 2021 con una API incompatible (`<Routes>`, `element=`,
`useNavigate`), y muchísimos equipos decidieron —con razón— que migrar el router
completo de una app en producción no valía la pena sin un motivo de negocio.

⚠️ **La trampa práctica.** `npm install react-router-dom` a secas te trae v6 o
v7 y **medio curso deja de compilar**. Siempre con `@5.3.4`.

**Qué la vuelve revisable.** Necesidad de rutas anidadas con `<Outlet>` o data
routers. No aparece en este curso.

---

### D6 — Jest 26 + React Testing Library 11 + Cypress para el smoke

**Qué se fijó.** Jest 26 y RTL 11 vienen **dentro** de `react-scripts@4.0.3`: no
se instalan ni se configuran, no hay `jest.config.js`. Se corre con
`react-scripts test`. Cypress se suma como dependencia de desarrollo solo para
el smoke test del happy path (Fase 10).

📝 **Nota de época.** Que el runner de tests venga escondido dentro de
`react-scripts` es puro CRA: cómodo hasta el día que necesitas un transform
propio y descubres que no puedes tocarlo sin `eject`. Ver
`A4-cra-por-dentro.md` §5.

**Qué la vuelve revisable.** Un requisito de configuración de Jest que CRA 4 no
exponga. Ahí empieza la conversación de `craco` o `eject` (A4 §5 y §6).

---

### D7 — `package-lock.json` es norma

**Qué se fijó.** El lockfile se commitea y manda. Se instala con `npm ci`, no
con `npm install`. Ninguna versión se sube "de paso" al agregar otra cosa.

📝 **Nota de época.** El lockfile v1 de npm 6 no es el v2 de npm 7+. Si alguien
del equipo instala con npm 7 sobre un lock v1, **el lock se reescribe entero** y
el diff es ilegible. Por eso D10 fija también el gestor.

**Qué la vuelve revisable.** Nada. Esta es la decisión que hace reproducible
todo lo demás.

---

### D8 — Los interceptors de axios se construyen desde cero en la Fase 2

**Qué se fijó.** No hay interceptors heredados. La Fase 2 crea `apiClient` con
el interceptor de request (token + `X-Request-Id`), y la Fase 3 le **suma** el de
response (401 global). Se extienden, no se reescriben.

📝 **Nota de época.** El patrón "una instancia de axios con interceptors" era
*la* forma canónica de resolver auth transversal antes de que las cookies
`httpOnly` se volvieran la recomendación. Vas a encontrarlo en casi cualquier
SPA de la época.

---

### D9 — `rxjs-marbles` 6.x para el marble testing

**Qué se fijó.** `rxjs-marbles@6.0.1`, sobre Jest 26.

⚠️ **La trampa que sí muerde.** `rxjs-marbles` ata su major a la de RxJS:
**6.x para RxJS 6, 7.x para RxJS 7**. Instalar `rxjs-marbles` a secas te trae la
7.x contra tu RxJS 6.6.7 y los tests fallan con errores de scheduler que no
dicen nada. Es literalmente la deuda 💸 que la Fase 10 declaraba y que este
archivo paga: la versión va pineada.

---

### D10 — Node 14.21.3 con npm 6

**Qué se fijó.** Node `14.21.3` (la última 14.x, febrero de 2023), fijada en
`.nvmrc`. npm 6.14.18, el que viene con ese Node.

📝 **Nota de época.** CRA 4 lleva adentro un Webpack 4 que usa una API de
crypto que **OpenSSL 3 removió**. Node 17+ trae OpenSSL 3, y por eso `npm start`
explota con `error:0308010C:digital envelope routines::unsupported`. Existe el
workaround `NODE_OPTIONS=--openssl-legacy-provider`, y existe justamente para
que no lo uses en mantenimiento: usa la versión de producción.

**Por qué también se fija npm.** npm 7+ instala peer dependencies
automáticamente y falla con `ERESOLVE` donde npm 6 solo advertía. Un `npm ci`
con npm 7 sobre este proyecto necesita `--legacy-peer-deps`; con npm 6, no. Ver
`A3-node-y-npm.md` §6.

---

### D11 — Sass con `sass` (dart-sass), nunca `node-sass`

**Qué se fijó.** `sass@1.32.5` como dependencia de desarrollo. `node-sass` está
**prohibido** en este proyecto.

📝 **Nota de época.** En 2021 lo normal era `node-sass`, un wrapper C++ sobre
LibSass que compila binarios nativos al instalarse. Nunca tuvo prebuilts para
arm64, así que en cualquier Mac con Apple Silicon el `npm install` muere en
node-gyp. dart-sass es JavaScript puro: no compila nada y funciona igual en
Windows x86_64, Linux y Mac arm64. CRA 4 lo detecta solo.

**Qué la vuelve revisable.** Nada. Si ves `node-sass` en un `package.json`
heredado, es un incidente, no un ejemplo.

---

### D12 — Gráficos con chart.js 2.x, sin wrapper de React

**Qué se fijó.** `chart.js@2.9.4`, usada de forma **imperativa**: `new Chart(ctx,
config)` dentro de un `useEffect`, con `chart.destroy()` en el teardown. Sin
`react-chartjs-2` y sin recharts.

📝 **Nota de época.** chart.js 3 (mayo de 2021) reorganizó los imports en
módulos con registro explícito (`Chart.register(...)`) y cambió nombres de
opciones. Un ejemplo de chart.js 3 o 4 **no corre** sobre la 2.9.4. Y no usamos
wrapper a propósito: montar una librería imperativa dentro del ciclo de vida de
React —y limpiarla al desmontar— es precisamente el ejercicio pedagógico de la
Fase 9.

**Qué la vuelve revisable.** Necesidad de tree-shaking del bundle de charts, que
es justo lo que chart.js 3 vino a resolver.

---

### D13 — Colima como runtime de contenedores recomendado

**Qué se fijó.** Cuando haga falta contenedor, Colima; Docker Desktop como
alternativa válida. El proyecto es agnóstico del runtime: el mismo
`docker-compose.yml` corre en ambos.

📝 **Nota de época.** Docker Desktop cambió su licencia para empresas grandes en
2021, y ahí muchos equipos migraron a Colima. Consume ~2 GB en reposo contra los
6-8 GB de Docker Desktop, y en Apple Silicon corre arm64 nativo sin emulación.

El detalle completo de entornos, contenedores y paridad con producción vive en
`A9-entornos-y-contenedores.md`.

---

## 3. El `package.json` de referencia

Este es el `package.json` completo del proyecto al terminar el curso. Cada fase
va agregando su parte; acá está el destino final, para que puedas comparar en
cualquier momento contra dónde deberías estar.

```json
{
  "name": "raffles-app",
  "version": "1.0.0",
  "private": true,
  "engines": {
    "node": "14.21.3",
    "npm": "^6.14.0"
  },
  "dependencies": {
    "@reduxjs/toolkit": "1.8.6",
    "axios": "0.21.4",
    "bootstrap": "4.6.2",
    "chart.js": "2.9.4",
    "react": "16.14.0",
    "react-dom": "16.14.0",
    "react-redux": "7.2.9",
    "react-router-dom": "5.3.4",
    "react-scripts": "4.0.3",
    "redux": "4.1.2",
    "redux-observable": "1.2.0",
    "rxjs": "6.6.7"
  },
  "devDependencies": {
    "concurrently": "6.5.1",
    "cors": "2.8.5",
    "cypress": "10.11.0",
    "dotenv": "10.0.0",
    "express": "4.17.1",
    "json-server": "0.16.3",
    "rxjs-marbles": "6.0.1",
    "sass": "1.32.5"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "mock:api": "node mock/server.js",
    "mock:lottery": "node mock/lottery/server.js",
    "mock:all": "concurrently \"npm run mock:api\" \"npm run mock:lottery\"",
    "dev": "concurrently \"npm run mock:all\" \"npm start\"",
    "cypress": "cypress open"
  },
  "browserslist": {
    "production": [">0.2%", "not dead", "not op_mini all"],
    "development": [
      "last 1 chrome version",
      "last 1 firefox version",
      "last 1 safari version"
    ]
  }
}
```

> 🧠 **Por qué las versiones van sin `^` ni `~`.** El rango `^16.14.0` significa
> "cualquier 16.x mayor o igual", y eso convierte tu instalación en una lotería
> dependiente del día. En una app en mantenimiento no quieres el parche nuevo:
> quieres **la versión que corre en producción**. El lockfile (D7) ya congela el
> árbol entero, pero pinear también en `package.json` hace explícita la
> intención, que es lo que lee el próximo mantenedor. Es redundancia deliberada,
> igual que el `.nvmrc` junto a `engines`.

> ⚠️ **`react-scripts` va en `dependencies`, no en `devDependencies`.** Es donde
> lo pone el template de CRA 4 y no se toca: mover paquetes entre secciones sin
> motivo es la clase de cambio que rompe un build de CI y nadie sabe por qué.

---

## 4. Qué instala cada fase

Ninguna fase te hace instalar todo de golpe. Esta tabla es el mapa de cuándo
entra cada dependencia, para que puedas verificar que vas al día.

| Fase | Comando |
|---|---|
| 0 | `npm install bootstrap@4.6.2` · `npm install --save-dev sass@1.32.5` |
| 1 | `npm install react-router-dom@5.3.4` |
| 2 | `npm install @reduxjs/toolkit@1.8.6 react-redux@7.2.9 redux@4.1.2 axios@0.21.4` |
| 3 | `npm install --save-dev json-server@0.16.3 express@4.17.1 cors@2.8.5 dotenv@10.0.0 concurrently@6.5.1` |
| 6 | `npm install redux-observable@1.2.0 rxjs@6.6.7` |
| 9 | `npm install chart.js@2.9.4` |
| 10 | `npm install --save-dev rxjs-marbles@6.0.1 cypress@10.11.0` |

Las fases 4, 5, 7, 8 y 11 no agregan dependencias: construyen sobre lo que ya
está. Que una fase entera de venta concurrente no necesite ni un paquete nuevo
es, en sí, una lección sobre dónde vive la complejidad real.

---

## 5. Puertos y procesos

Tres procesos, tres puertos. Confundirlos es el primer bug de integración de
cualquiera, así que conviene tenerlos a mano:

- **`3000`** — el dev server de CRA (`npm start`). Sirve la SPA.
- **`3001`** — `json-server` con el middleware de caos. Es el backend propio:
  `raffles`, `numbers`, `participants`, `settlements`, `users`. Lo consume
  `apiClient`. 🔥 En el track BE opcional, a partir de `be03` este mismo puerto
  lo sirve el binario de Go: el puerto no cambia justamente para que el
  frontend no se entere (ver §7.4).
- **`3002`** — el mock de lotería (Express propio, caos `high` por defecto).
  Sirve `GET /results/:raffleId`. Lo consume `apiLottery`, **nunca**
  `apiClient`.

La separación no es cosmética: el backend propio y el servicio externo tienen
perfiles de fallo distintos, y aprender a distinguir "se cayó lo nuestro" de "se
cayó el proveedor" es media hora menos de diagnóstico cada vez.

---

## 6. Advertencia sobre estos números

Las versiones de arriba son las que el curso congela y contra las que está
escrito todo el código. Aun así, **verifícalas al instalar**: los registros de
paquetes cambian, un paquete puede haber sido despublicado, y un `npm view
<paquete> versions` te saca de dudas en cinco segundos. Lo mismo vale para las
fechas de las notas de época: son el contexto que explica cada decisión, no un
dato que debas citar como fuente.

Si encuentras una discrepancia entre este archivo y una fase, **este archivo
gana** y la fase se corrige. Si encuentras una discrepancia entre este archivo y
lo que instaló npm, gana lo que instaló npm y hay que averiguar por qué.


---

## 7. Track BE (opcional) — decisiones D14–D23 🔥

Todo lo de esta sección pertenece al **track opcional de backend** (`be00`–`be09`
y sus apéndices `bea-NN`). El track base se completa con el mock y **no depende
de nada de acá**. El encuadre completo —justificación, fases y horas— vive en
`prompts/propuesta-fases-backend.md`.

La regla del §1 sigue mandando igual: ninguna versión se cambia sin justificarlo
por escrito.

### 7.1 El registro de decisiones del backend

#### D14 — Go 1.19.13

**Qué se fijó.** El backend se escribe en Go `1.19.x`, con `go 1.19` declarado
en el `go.mod`. No se usan `log/slog`, `errors.Join`, los patrones de método de
`http.ServeMux` ni genéricos en el código principal: aparecen marcados 🔥 como
comparación, igual que React 18 en el track base.

📝 **Nota de época.** Go 1.19 es de agosto de 2022, el borde final de la ventana
temporal del curso. La ficción encaja: el frontend es de la segunda era del
sistema y este backend se escribió después, cuando la empresa aceptó que
`db.json` no era un backend. Que los genéricos ya existieran y casi nadie los
usara todavía es fiel al momento.

**Qué la vuelve revisable.** Que el toolchain deje de poder compilar `go 1.19`,
cosa que hoy no pasa: los toolchains actuales lo compilan sin queja.

---

#### D15 — `gorilla/mux` 1.8.0 como router

**Qué se fijó.** Enrutamiento con `gorilla/mux` 1.8.0 sobre `net/http`. Nada de
frameworks completos (Gin, Echo, Fiber): el track enseña el `net/http` que hay
debajo, no a manejar un framework.

📝 **Nota de época.** Era el router por defecto de medio ecosistema Go. Y trae
un regalo pedagógico que no se puede fabricar: el proyecto se archivó a fines de
2022 y volvió a mantenerse después. Una dependencia central que se muere —y
resucita— es exactamente el tipo de evento que define la vida de un sistema
legacy. Se trabaja como contenido 💸, no como accidente.

**Qué la vuelve revisable.** Un segundo archivado sin sucesor claro. Verifica el
estado del repositorio al escribir la fase; no lo cites de memoria.

---

#### D16 — `dgrijalva/jwt-go` v3.2.0, y su migración a `golang-jwt/jwt` v4.4.2

**Qué se fijó.** El backend adopta `dgrijalva/jwt-go` v3.2.0 **a propósito** en
`be04`, descubre que está abandonado y que arrastra un CVE de manejo de
audiencia, y migra al fork oficial `golang-jwt/jwt` v4.4.2 dentro de la misma
fase, con post-mortem.

📝 **Nota de época.** `dgrijalva/jwt-go` era *la* librería de JWT en Go, y quedó
sin mantenimiento con un aviso de seguridad abierto. La comunidad la bifurcó en
`golang-jwt/jwt`, que es hoy la línea viva. Miles de repos de 2020-2022 siguen
apuntando a la original.

**Qué la vuelve revisable.** Nada. La secuencia abandono → CVE → fork **es** el
contenido de la fase; quitarla vaciaría `be04`.

⚠️ Cita el identificador del CVE y las fechas desde el aviso oficial. No los
escribas de memoria.

---

#### D17 — `database/sql` + `sqlx` 1.3.5, sin ORM

**Qué se fijó.** Acceso a datos con la biblioteca estándar más `jmoiron/sqlx`
1.3.5. Nada de GORM ni de generadores de código. El SQL se escribe a mano.

📝 **Nota de época.** La comunidad Go de esos años era mayoritariamente
anti-ORM, y `sqlx` era el punto medio cómodo: mapeo a structs sin esconder la
consulta.

**Qué la vuelve revisable.** Nada dentro de este track: el objetivo pedagógico
de `be02` es que **el dialecto quede a la vista**, y un ORM lo escondería justo
donde queremos que se vea. GORM se menciona como comparación 🔥.

---

#### D18 — PostgreSQL 13 es el motor de verdad; SQLite es solo de pruebas

**Qué se fijó.** PostgreSQL `13.x` en desarrollo, QA, UAT y producción. SQLite
`3.35+` únicamente en pruebas, y solo en las que cumplen la regla del motor:

> 🧭 SQLite vale para pruebas que no tocan concurrencia, bloqueos, zonas
> horarias ni SQL específico del motor. En cuanto una prueba toca cualquiera de
> las cuatro, corre contra PostgreSQL o no vale.

📝 **Nota de época.** Postgres 13 es de septiembre de 2020 y era lo que tenía
media industria en 2022. La cota de SQLite en 3.35 no es arbitraria: es la
versión donde llegó `RETURNING`, en marzo de 2021.

**Qué la vuelve revisable.** Nada. La regla es contenido evaluable de `be08`,
demostrada con una prueba que pasa en SQLite y falla en Postgres.

---

#### D19 — `lib/pq` v1.10.7 y `mattn/go-sqlite3` v1.14.16, con la cuestión cgo abierta

**Qué se fijó.** Driver de Postgres `lib/pq` v1.10.7; driver de SQLite
`mattn/go-sqlite3` v1.14.16. La alternativa pura Go `modernc.org/sqlite`
v1.19.x se evalúa y se mide en `be09`, no se adopta por defecto.

📝 **Nota de época.** `lib/pq` era el driver clásico y hoy está en modo
mantenimiento, con `pgx` como sucesor recomendado. `mattn/go-sqlite3` exige
`CGO_ENABLED=1`, y eso rompe Alpine por musl, mata el cross-compile y engorda la
imagen. Es un "en mi máquina anda" de manual, hermano del que ya cuenta `A3`.

**Qué la vuelve revisable.** Que la fricción de cgo consuma más tiempo del que
enseña. Si pasa, se adopta `modernc.org/sqlite` y la comparación se conserva
como ejercicio.

✅ **Cerrada en `be09`, y con un giro.** La pregunta estaba mal planteada: no era
*qué driver de SQLite*, sino *por qué el binario de producción tiene un driver de
SQLite*. SQLite solo se usa en pruebas. La resolución es **etiquetar la
compilación** —el `import` del driver vive en un archivo `//go:build sqlite`—, de
modo que producción compila con `CGO_ENABLED=0`, estático y sin cgo, y las
pruebas conservan `mattn/go-sqlite3`, que es más rápido en ejecución que
`modernc`. No se cambia de driver. La medición de los tres escenarios queda en
`server/evidence/imagen.md`.

---

#### D20 — Migraciones con `golang-migrate` v4.15.2

**Qué se fijó.** Migraciones versionadas con `golang-migrate/migrate` v4.15.2,
dos archivos SQL por versión (`up` y `down`). Se ejecutan como paso explícito,
nunca de forma implícita al arrancar en producción.

📝 **Nota de época.** `golang-migrate` y `goose` se repartían el terreno. El
detalle relevante para el curso es otro: al tener dos motores, hay que decidir
si el DDL es un subconjunto común o si se mantiene por dialecto. Esa decisión se
toma y se justifica en `be02`.

**Qué la vuelve revisable.** Nada previsible.

---

#### D21 — El backend Go toma el puerto 3001 y honra el contrato del mock

**Qué se fijó.** A partir de `be03`, el binario de Go escucha en el **mismo
puerto 3001** que servía `json-server`, y reimplementa su dialecto tal cual lo
consume el frontend: `_page`, `_limit`, `_sort`, `_order`, `q`, el header
`X-Total-Count`, el `404` con cuerpo vacío, el `POST` que devuelve el recurso
creado con su `id`, las tres rutas propias de la Fase 3 y el `X-Request-Id`.

📝 **Nota de época.** No hay nota de época acá: hay una regla de diseño. El
frontend heredado **no se toca**. Un backend "mejor diseñado" que obligue a
cambiar el cliente es, para este curso, un backend roto.

**Qué la vuelve revisable.** Una discrepancia de contrato que `be00` no haya
auditado. Se corrige el backend, nunca el frontend.

---

#### D22 — El caos se reimplementa en Go, con doble control

**Qué se fijó.** El middleware de caos existe también en el backend real,
**apagado por defecto**, con dos controles: la ruta `POST /_chaos` —la misma que
expone el mock, para que las prácticas de las fases 3 y 7 sigan funcionando sin
cambios— y la variable de entorno `CHAOS_LEVEL`, que fija el nivel al arrancar.
Gana la última orden recibida, y el arranque cuenta como orden.

📝 **Nota de época.** Ninguna. Es andamiaje del curso, y se declara como tal:
ningún backend de producción trae un endpoint para romperse a sí mismo.

**Qué la vuelve revisable.** Nada mientras las fases 3 y 7 del track base
existan.

---

#### D23 — La aplicación es de 2022; el pipeline es de hoy

**Qué se fijó.** El workflow de GitHub Actions usa versiones **actuales** de las
acciones y ejecuta el Go de 2022 dentro de un `container: golang:1.19`, con
`services: postgres:13`.

📝 **Nota de época.** Un workflow escrito con las acciones de 2022 no corre hoy:
los runners actuales rechazan aquellas versiones. En vez de fingir, el track
separa las dos edades y lo dice. Es, además, exactamente la conversación que
tiene un equipo cuando le toca revivir un repositorio dormido.

**Qué la vuelve revisable.** El día que los runners dejen de aceptar la versión
actual de las acciones. Es una fecha, no un si.

---

#### D24 — El puerto de transición es el `3011`

**Qué se fijó.** El binario lee `PORT` y su valor por defecto es `3001`. Mientras
el mock siga levantado —`be01` y `be02`— el laboratorio arranca el binario con
`PORT=3011`, para que los dos convivan. Desde `be03` el mock se apaga y el
`3001` es de Go, sin variable de por medio.

📝 **Nota.** No es un cuarto puerto del sistema: es un puerto de andamiaje que
existe durante dos fases y desaparece. El `3001` sigue siendo el `3001`, que es
justamente el punto de `D21`.

**Qué la vuelve revisable.** Que el `3011` esté ocupado en la máquina del alumno.
Cualquier otro sirve: la variable ya lo cubre.

---

#### D25 — El DDL se mantiene por dialecto, no en subconjunto común

**Qué se fijó.** `server/migrations/postgres/` y `server/migrations/sqlite/`, con
los mismos números de versión y los mismos nombres de archivo. `D20` dejaba la
pregunta abierta y `be02` la cierra.

📝 **Por qué.** El mínimo común denominador de PostgreSQL 13 y SQLite 3.35 no
tiene `TIMESTAMPTZ`, `BIGSERIAL` ni tipos que se hagan cumplir (las tablas
`STRICT` de SQLite son de la 3.37). Escribir el DDL ahí sería
degradar el motor real para complacer al motor de pruebas. El costo —que los dos
juegos diverjan— se administra con la regla del motor de `be08` y queda a la
vista, en vez de esconderse detrás de una abstracción.

**Qué la vuelve revisable.** Que el mantenimiento de los dos juegos consuma más
tiempo del que enseña. Si pasa, se abandona SQLite antes que el DDL por
dialecto.

---

#### D26 — `GET /health` responde `503` si la base no responde

**Qué se fijó.** El endpoint reporta si el servicio **puede trabajar**, no si el
proceso está vivo: sin base, `503` con `{"status":"degraded"}`. `be01` dejó la
pregunta abierta y `be02` la cierra, porque el orquestador de `be09` actúa según
esa respuesta.

📝 **El matiz que evita el desastre.** Esto es una *readiness probe*, no una
*liveness probe*: reiniciar el contenedor no arregla una base caída. La
separación en dos rutas se implementa en `be09`.

**Qué la vuelve revisable.** Nada previsible dentro del track.

---

#### D27 — La única excepción al "el frontend no se toca": `authService.js`

**Qué se fijó.** El frontend hace login con `GET /users?email=…&password=…`, no
con `POST /login`. En `be04` se modifica **un solo archivo del frontend**,
`src/api/authService.js`, para que llame a `POST /login` con las credenciales en
el cuerpo. No se tocan `apiClient.js` ni sus interceptores, ni `authSlice.js`, ni
ningún componente. El campo `token` de la respuesta conserva nombre y forma.

📝 **Por qué es legítima.** La Fase 2 del track base la anunció textualmente
—*"cuando mañana haya un `POST /login` real, cambia **este** archivo y nada
más"*— y la dejó como ejercicio 🔥. La alternativa —honrar la contraseña en la
query string para siempre— haría inauditable el `be04` que enseña `bcrypt`. Se
registra en `be00` como hallazgo `C-06`, con archivo, fase y límite.

📎 **Consecuencia operativa.** Desde `be04`, el comando que demuestra la regla
lleva una exclusión más:
`git diff pre-backend-go..HEAD -- . ':!server' ':!src/api/authService.js'`.

**Qué la vuelve revisable.** Nada. Ampliarla a un segundo archivo exige
renegociarla por escrito en la fase que lo pida.

---

#### D28 — La venta se modela como hecho, no como estado

**Qué se fijó.** En `be05` se crea la tabla `sales`, donde cada venta es una fila
nueva con `UNIQUE (raffle_id, number)`. Vender pasa de ser un `UPDATE` sobre
`raffle_numbers` a ser un `INSERT` en `sales` más la actualización del estado, las
dos en la misma transacción. El `status` de `raffle_numbers` sigue existiendo
—el contrato de `be00` lo exige— pero pasa de ser la verdad a ser una proyección.

📝 **Por qué.** Un `UNIQUE` no puede proteger un `UPDATE` sobre una fila que ya
existe: no hay segunda fila que rechazar. Sin cambiar el modelo, la defensa más
fuerte de las tres —una restricción de la base— sencillamente no está disponible.
El camino principal es el bloqueo pesimista (`SELECT … FOR UPDATE`) por
**observabilidad**, no por rendimiento: se puede mirar en `pg_stat_activity`. La
variante optimista se implementa y se mide en la misma fase.

📎 **Consecuencias.** `be07` usa `sales` como el registro inmutable de su
trazabilidad; `be08` hereda `TestConcurrentSell` y la evidencia de SQLite.

**Qué la vuelve revisable.** Nada dentro del track. Volver al modelo de estado
implicaría renunciar al índice único, que es el punto.

---

### 7.2 El `go.mod` de referencia

Este es el `go.mod` del backend al terminar `be09`. Cada fase agrega su parte;
acá está el destino, para comparar en cualquier momento contra dónde deberías
estar.

```
module github.com/rifas-y-chances/raffles-api

go 1.19

require (
	github.com/golang-jwt/jwt/v4 v4.4.2
	github.com/golang-migrate/migrate/v4 v4.15.2
	github.com/gorilla/mux v1.8.0
	github.com/jmoiron/sqlx v1.3.5
	github.com/kelseyhightower/envconfig v1.4.0
	github.com/lib/pq v1.10.7
	github.com/mattn/go-sqlite3 v1.14.16
	github.com/stretchr/testify v1.8.1
	golang.org/x/crypto v0.4.0
)
```

`github.com/dgrijalva/jwt-go v3.2.0+incompatible` aparece en el `go.mod` **entre
`be04` y su sección de migración**, y sale de ahí en la misma fase. Que quede
fuera del listado final es el punto: la deuda se pagó.

`github.com/brianvoe/gofakeit/v6` v6.19.x entra solo si haces el apéndice
opcional `bea-10`, y no es dependencia del backend: vive en el paquete de
utilidades de siembra.

### 7.3 Qué instala cada fase del track BE

| Fase | Comando |
|---|---|
| be00 | Ninguno. Es auditoría del contrato, no se escribe código |
| be01 | `go get github.com/gorilla/mux@v1.8.0` |
| be02 | `go get github.com/jmoiron/sqlx@v1.3.5 github.com/lib/pq@v1.10.7 github.com/mattn/go-sqlite3@v1.14.16 github.com/golang-migrate/migrate/v4@v4.15.2` |
| be03 | `go get github.com/kelseyhightower/envconfig@v1.4.0` |
| be04 | `go get github.com/dgrijalva/jwt-go@v3.2.0+incompatible golang.org/x/crypto@v0.4.0` y, en la misma fase, `go get github.com/golang-jwt/jwt/v4@v4.4.2` |
| be08 | `go get github.com/stretchr/testify@v1.8.1` |
| bea-10 🔥 | `go get github.com/brianvoe/gofakeit/v6@v6.19.0` |

Las fases `be05`, `be06`, `be07` y `be09` no agregan dependencias: construyen
sobre lo que ya está. Que las tres fases del dominio —concurrencia, tiempo y
dinero— no necesiten ni un paquete nuevo es, igual que en el track base, una
lección sobre dónde vive la complejidad real.

### 7.4 El cuarto puerto

Al track BE le corresponde un puerto más, y ninguno de los tres del §5 se mueve:

- **`5432`** — PostgreSQL en contenedor. Si ya tienes un Postgres local
  ocupándolo, publícalo en `5433`; la configuración por variables de entorno lo
  cubre y `bea-02` explica el cambio.

El `3001` sigue siendo el `3001`: antes lo sirve `json-server` y después de
`be03` lo sirve el binario de Go. **Ese es justamente el punto.**

### 7.5 La misma advertencia, para Go

Los módulos se mueven de path, los repositorios se archivan y las versiones se
retiran. Verifica cada número al instalar con `go list -m -versions <módulo>`, y
cita el CVE de `jwt-go` y las fechas de `gorilla/mux` desde el aviso oficial.
Si encuentras una discrepancia entre este archivo y una fase, **este archivo
gana**.
