# 📎 Apéndice a06 — Lenguajes, drivers y frameworks

> **Curso:** Ruta NoSQL Lite · Consulta rápida · **4 h**
> **Usado por:** todas las fases · **Versiones cubiertas:** Node 24.21.0, npm 11.19.0,
> TypeScript 7.0.2 (opcional), Python 3.13.4, uv 0.11.14, y los drivers de la tabla
> **Fecha de verificación ejecutada:** 29/09/2026, en macOS arm64, contra el laboratorio de
> [`a02`](a02-compose-de-la-ruta.md). Linux y Windows 11 (WSL2): **no ejecutado todavía en esas
> plataformas**.

**Esto no se lee de corrido.** Se entra por el índice buscando algo concreto y se sale. Resuelve
una sola cosa: que puedas hablar con los diez motores desde tu máquina, en el lenguaje que toca,
sin quedarte parado en una fase por no escribir Python o Node a diario.

**Qué queda fuera:** ORMs, ODMs, frameworks de aplicación y patrones de repositorio. **Es una
decisión pedagógica, no un olvido:** los clientes de alto nivel esconden justo lo que el curso
quiere medir —cuántos viajes, qué se examinó, qué se escribió—. Cuando entiendes el mecanismo,
esas capas se aprenden en una tarde. Los contenedores están en [`a01`](a01-laboratorio-contenerizado.md)
y [`a02`](a02-compose-de-la-ruta.md); los datos, en [`a05`](a05-el-dominio-de-flota.md).

---

## Índice

- [La regla de los dos entornos](#-la-regla-de-los-dos-entornos)
- [Instalar y preparar](#-instalar-y-preparar)
- [TypeScript sin compilar](#-typescript-sin-compilar)
- [Un driver por motor](#-un-driver-por-motor)
- [La conexión que no se cierra](#-la-conexión-que-no-se-cierra)
- [Cuatro detalles que muerden](#-cuatro-detalles-que-muerden)
- [Python, solo donde manda](#-python-solo-donde-manda)
- [`async/await` en cinco líneas](#-asyncawait-en-cinco-líneas)
- [TypeScript y Python, en equivalencias](#-typescript-y-python-en-equivalencias)
- [Script local o `docker compose exec`](#-script-local-o-docker-compose-exec)
- [Cuándo usar qué](#-cuándo-usar-qué)
- [Advertencias](#️-advertencias)
- [Referencias](#-referencias)
- [Ejercicios](#-ejercicios-8)

---

## ⚖️ La regla de los dos entornos

**TypeScript por defecto, y siempre para el instrumento.** El arnés de medida y el generador de
datos son TypeScript en todas las fases: un instrumento con dos implementaciones deja de ser un
instrumento.

**Python solo donde el ecosistema de la familia vive ahí de verdad:** analítico embebido
(DuckDB, F07–F08) y la ingesta de vectorial (embeddings, F15–F16). En ninguna otra parte. Y aun
en vectorial, **la consulta se hace en TypeScript**, a propósito: es la forma de desmontar que
esa familia "es de Python".

---

## 🧰 Instalar y preparar

Todo el código del curso vive en `src/`, con **un único entorno por lenguaje, compartido por
todas las fases** y con las versiones exactas fijadas:

| | Archivo | Qué fija |
|---|---|---|
| Node | `src/package.json` + `package-lock.json` | cada driver con su versión exacta, sin `^` |
| Python | `src/pyproject.toml` + `uv.lock` + `.python-version` | el intérprete (3.13) y **todas** las dependencias, también las transitivas |

**Necesitas Node 24** (cualquier gestor sirve: nvm, fnm, el instalador oficial) **y
[uv](https://docs.astral.sh/uv/)**, que además instala el Python 3.13 si no lo tienes.

```bash
cd src
npm ci        # instala exactamente lo del package-lock.json
uv sync       # crea .venv con exactamente lo del uv.lock
```

`node_modules/` y `.venv/` no se versionan (`src/.gitignore`).

> ⚠️ **npm 11 ya no ejecuta los scripts de instalación de las dependencias sin permiso**, y lo
> avisa así:
>
> ```text
> 4 packages have install scripts not yet covered by allowScripts:
>   leveldown@5.6.0 (install: node-gyp rebuild)
>   leveldown@6.1.1 (install: node-gyp rebuild)
>   onnxruntime-node@1.30.0 (postinstall: node ./script/install)
>   protobufjs@7.6.6 (postinstall: node scripts/postinstall)
> ```
>
> **Para este curso no hace falta aprobar ninguno.** Verificado el 29/09/2026: PouchDB guarda en
> local y `transformers.js` calcula embeddings sin esos scripts, porque los paquetes traen
> binarios ya compilados. Si en tu plataforma algo falla por eso, `npm install-scripts approve
> <paquete>` lo habilita; esta situación no está verificada en Linux ni en WSL2.

**La prueba de que todo está en su sitio**, con el laboratorio arriba (`a02`):

```bash
cd src
node lab/check/conectar.ts            # los diez motores, desde TypeScript
uv run python lab/check/conectar.py   # DuckDB, Postgres, Qdrant y el modelo de embeddings
node lab/check/embeddings.ts          # el modelo de embeddings, desde TypeScript
```

---

## 📜 TypeScript sin compilar

**Node 24 ejecuta TypeScript directamente**: `node script.ts`, sin `tsc`, sin `tsx` y sin
bundler. Quita los tipos y ejecuta lo que queda. Tiene una condición: el código solo puede usar
sintaxis **"borrable"**, la que desaparece sin dejar rastro al quitar los tipos. Lo que no lo es
falla antes de ejecutar:

```text
SyntaxError [ERR_UNSUPPORTED_TYPESCRIPT_SYNTAX]: TypeScript enum is not supported in strip-only mode
```

En la práctica son tres cosas: **ni `enum`, ni `namespace`, ni *parameter properties***
(`constructor(private readonly x: T)`). Se sustituyen por un objeto `as const`, un módulo y un
campo asignado en el constructor. Los imports entre archivos propios llevan la extensión
`.ts`.

**`tsc` queda opcional, y solo para comprobar tipos.** No es un paso de compilación: no produce
ningún archivo.

```bash
cd src
npx tsc -p tsconfig.json    # con "noEmit" y "erasableSyntaxOnly" en tsconfig.json
```

Vale la pena correrlo de vez en cuando. En la verificación de este apéndice encontró seis
errores de tipos reales en código que se ejecutaba bien, entre ellos una incompatibilidad
entre los tipos de `Buffer` de `@types/node` 24 y TypeScript 7.

---

## 🔌 Un driver por motor

Verificado el 29/09/2026 con `node lab/check/conectar.ts`: los diez conectan desde tu máquina por
los puertos desplazados de [`a02`](a02-compose-de-la-ruta.md), preguntan la versión y cierran.

| Familia | Driver (versión) | Conexión desde tu máquina | Cómo se cierra |
|---|---|---|---|
| base | `pg` 8.23.0 | `postgres:condor@localhost:15432/postgres` | `await client.end()` |
| documental | `mongodb` 7.7.0 | `mongodb://localhost:27018/?directConnection=true` | `await client.close()` |
| clave-valor | `iovalkey` 0.4.0 | `localhost:16379` | `await client.quit()` |
| series | `pg` 8.23.0 | `postgres:condor@localhost:15433/postgres` | `await client.end()` |
| búsqueda | `@opensearch-project/opensearch` 3.9.0 | `http://localhost:19200` | `await client.close()` |
| grafos | `neo4j-driver` 6.2.0 | `bolt://localhost:17687`, `neo4j` / `condor-mro` | `await driver.close()` |
| vectorial | `@qdrant/js-client-rest` 1.19.0 | `http://localhost:16333` | HTTP sin estado: nada que cerrar |
| columnar | `cassandra-driver` 4.10.0 | `localhost:19042`, `localDataCenter: "datacenter1"` | `await client.shutdown()` |
| offline | `pouchdb` 9.0.0 | `http://condor:condor@localhost:15984/<base>` | `await db.close()` |
| NewSQL | `pg` 8.23.0 | `root@localhost:26258/defaultdb`, sin contraseña | `await client.end()` |

La salida real:

```text
✅ base         pg 8.23.0                                  PostgreSQL 18.6 (Debian 18.6-1.pgdg12+2)  (52 ms)
✅ documental   mongodb 7.7.0                              MongoDB 8.0.20  (28 ms)
✅ clave-valor  iovalkey 0.4.0                             Valkey 9.1.2  (19 ms)
✅ series       pg 8.23.0                                  TimescaleDB 2.30.1 (disponible)  (44 ms)
✅ busqueda     @opensearch-project/opensearch 3.9.0       OpenSearch 3.8.0  (16 ms)
✅ grafos       neo4j-driver 6.2.0                         Neo4j/2026.09.0  (37 ms)
✅ vectorial    @qdrant/js-client-rest 1.19.0              Qdrant 1.19.1  (29 ms)
✅ columnar     cassandra-driver 4.10.0                    Cassandra 5.0.9  (157 ms)
✅ offline      pouchdb 9.0.0                              CouchDB 3.5.2 (_users)  (20 ms)
✅ newsql       pg 8.23.0                                  CockroachDB CCL v26.3.2 (aarch64-unknown-linux-gnu, built 2026/09/16 12:26:13, go1.26.6)  (7 ms)
```

> 🩻 **Tres familias hablan con el driver de Postgres** sin ser Postgres: series, porque
> TimescaleDB es una extensión; NewSQL, porque CockroachDB habla su protocolo; y la línea base.
> **La etiqueta no decide nada; el modelo de acceso sí.**

`newsql-global`, el perfil de nueve nodos de F22, se conecta igual que `newsql`, por el puerto
26259. Se verificó en [`a02`](a02-compose-de-la-ruta.md), no en este script: no cabe en memoria
junto con todo lo demás.

---

## 🚪 La conexión que no se cierra

**Es el error más común con estos drivers, y no da ningún mensaje.** El script hace su trabajo,
imprime su resultado… y no termina: una conexión abierta mantiene vivo a Node. Con `pg` y sin
`client.end()`, el 29/09/2026:

```text
$ timeout 15 node sin-cerrar.ts
consulta hecha: 9 conexiones; ahora el script 'termina'…
$ echo $?
124
```

El 124 es de `timeout`: el proceso seguía vivo a los 15 segundos y hubo que matarlo. **El
patrón que lo evita es `try` / `finally`**, que cierra también cuando la consulta falla:

```ts
const client = new pg.Client({ host: "localhost", port: 15432, user: "postgres", password: "condor" });
await client.connect();
try {
  const { rows } = await client.query("SELECT count(*) AS n FROM pg_stat_activity");
  console.log(rows[0].n);
} finally {
  await client.end(); // sin esto, el proceso no termina
}
```

🩺 **La prueba de que cerraste todo:** el script termina solo. `lab/check/conectar.ts` abre y
cierra diez conexiones y termina en 1 s.

---

## 🦷 Cuatro detalles que muerden

**Mongo necesita `directConnection=true` desde tu máquina.** El replica set de un nodo se anuncia
como `localhost:27017`, que es su dirección **dentro** del contenedor. Sin la opción, el driver
lo descubre e intenta seguirlo hasta tu `localhost:27017`, donde no está el laboratorio. En la
máquina de verificación, ese puerto lo tenía otro Mongo ajeno al curso, y el resultado fue este:

```text
MongoServerSelectionError: Server selection timed out after 8000 ms
```

**Cassandra exige `localDataCenter`.** El driver no se conecta sin saber cuál es el datacenter
local. En el laboratorio es `datacenter1`.

**iovalkey se importa con nombre.** `import { Valkey } from "iovalkey"`. La importación por
defecto funciona al ejecutar, pero `tsc` la rechaza (`has no construct signatures`).

**Los tipos de PouchDB van atrasados.** `@types/pouchdb` está en la 6.4.2 y PouchDB en la 9.0.0.
Para lo que usa el curso coinciden, pero si una opción nueva no aparece en el autocompletado, es
por eso.

---

## 🐍 Python, solo donde manda

```bash
cd src
uv run python lab/check/conectar.py
```

```text
✅ analitico    duckdb 1.5.6                       DuckDB v1.5.6  (15 ms)
✅ base         psycopg 3.3.6                      PostgreSQL 18.6 (Debian 18.6-1.pgdg12+2)  (42 ms)
✅ vectorial    qdrant-client                      Qdrant 1.19.1  (27 ms)
✅ embeddings   sentence-transformers              intfloat/multilingual-e5-small@614241f6 · 384 dimensiones  (3273 ms)
```

**`uv run` ejecuta dentro del entorno del `uv.lock`**, sin activar nada a mano. Lo que usa cada
familia:

- **DuckDB 1.5.6** es embebido: no hay servidor, la base es un archivo (o memoria) dentro de tu
  proceso. `duckdb.connect()` y listo.
- **psycopg 3.3.6** para la línea base de Postgres en las mismas fases.
- **qdrant-client 1.19.1** para cargar vectores en la ingesta de F15.
- **sentence-transformers 6.1.0** con **`intfloat/multilingual-e5-small`**, fijado en la revisión
  `614241f622f53c4eeff9890bdc4f31cfecc418b3`. Nunca se entrena nada.

> ⚠️ **Todo script con procesos necesita `if __name__ == "__main__":`.** En macOS y en Windows,
> `multiprocessing` arranca los hijos reimportando el script: sin la guarda, cada hijo vuelve a
> ejecutar todo el archivo, y el síntoma es un proceso que no reporta nada. F08 lo usa para
> reproducir el candado de DuckDB, cuyo mensaje literal está en
> [`a09`](a09-catalogo-de-errores.md).

**El modelo, igual en los dos lenguajes.** La ingesta embebe en Python y la consulta en
TypeScript, así que tienen que dar el mismo vector para el mismo texto. Verificado el 29/09/2026
con sentence-transformers 6.1.0 y `@huggingface/transformers` 4.3.0 (ONNX en fp32, del mismo
repositorio y la misma revisión): **coseno 1,000000 y diferencia máxima de 1,5 × 10⁻⁷**.

```bash
node lab/check/embeddings.ts
```

```text
✅ embeddings   @huggingface/transformers   intfloat/multilingual-e5-small@614241f6 · 384 dimensiones  (14999 ms)
```

La primera vez tarda porque descarga el modelo (unos 470 MB); después queda en caché.

---

## ⏳ `async/await` en cinco líneas

Para quien no vive en Node. Todo driver de este curso devuelve **promesas**: la operación se lanza
y el resultado llega después.

- `await` espera a que la promesa se resuelva y te da el resultado. Sin `await`, tienes la
  promesa, no el dato.
- En un script `.ts` del curso puedes usar `await` directamente en el nivel superior del archivo.
- Una promesa rechazada es una excepción: se captura con `try` / `catch`.
- `finally` se ejecuta siempre, con error o sin él: por eso ahí va el cierre de la conexión.
- **Dos `await` seguidos son dos viajes, uno detrás del otro.** Si no dependen entre sí,
  `await Promise.all([a, b])` los lanza a la vez. Contar viajes es parte del curso, así que esto
  importa.

---

## 🔁 TypeScript y Python, en equivalencias

| | TypeScript (Node 24) | Python 3.13 |
|---|---|---|
| Ejecutar | `node script.ts` | `uv run python script.py` |
| Instalar lo fijado | `npm ci` | `uv sync` |
| Añadir una dependencia | `npm install --save-exact paquete@1.2.3` | `uv add "paquete==1.2.3"` |
| Esperar una operación | `await client.query(…)` | llamada síncrona: `conn.execute(…)` |
| Cerrar pase lo que pase | `try { … } finally { await client.end() }` | `with psycopg.connect(…) as conn:` |
| Leer una variable de entorno | `process.env.BASE_PORT ?? 15432` | `os.environ.get("BASE_PORT", 15432)` |
| Un registro NDJSON | `JSON.parse(line)` | `json.loads(line)` |
| Comprobar tipos | `npx tsc -p tsconfig.json` (opcional) | no se usa en el curso |

---

## 🐳 Script local o `docker compose exec`

**Por defecto, script local contra el motor en contenedor**, por los puertos de
[`a02`](a02-compose-de-la-ruta.md). Es lo que hace el arnés, y es lo que ve un sistema real: el
cliente fuera, el motor dentro.

**`docker compose exec` cuando la herramienta ya vive dentro del contenedor**: las CLIs
(`psql`, `mongosh`, `cqlsh`, `cypher-shell`…), que están en [`a03`](a03-clis-de-los-motores.md),
y los diagnósticos que el motor solo expone ahí.

```bash
cd src/lab
docker compose exec base psql -U postgres -c "select count(*) from pg_stat_activity"
```

---

## 🧭 Cuándo usar qué

| Situación | Usa | Por qué |
|---|---|---|
| Cualquier fase, salvo las de abajo | TypeScript | es el entorno por defecto y el del arnés |
| F07–F08, analítico embebido | Python, DuckDB | DuckDB vive ahí |
| F15, la ingesta de embeddings | Python, sentence-transformers + qdrant-client | el ecosistema de embeddings vive ahí |
| F15–F16, la consulta | TypeScript, `transformers.js` + `@qdrant/js-client-rest` | la familia no "es de Python" |
| Medir | siempre TypeScript | un instrumento, una implementación |
| Una consulta rápida a mano | la CLI con `docker compose exec` | [`a03`](a03-clis-de-los-motores.md) |
| El script no termina | `try` / `finally` con el cierre de su driver | una conexión abierta mantiene vivo a Node |

---

## ⚠️ Advertencias

- **No cambies versiones de drivers a mitad de una familia.** Una medición cita la versión con la
  que se hizo, y otra versión puede cambiar cuántos viajes hace el driver por su cuenta.
- **Algunos drivers hacen viajes que tú no pediste**: descubrimiento del replica set,
  metadatos del clúster, *keep-alive*. Cuando una fase cuenta viajes, los cuenta en el servidor
  o en el arnés, no en tu código ([`a04`](a04-el-arnes-de-medida.md)).
- **Linux y WSL2 no están verificados.** Los scripts de instalación que npm bloquea y los binarios
  precompilados de `leveldown` y `onnxruntime-node` son lo primero que conviene comprobar ahí.

---

## 📚 Referencias

> ⚠️ Las URLs y sus contenidos cambian, y la documentación suele cubrir solo la última versión.
> Este apéndice se verificó con las versiones de la tabla de drivers.

- **Node.js: ejecutar TypeScript** — https://nodejs.org/api/typescript.html — la sintaxis
  "borrable" y lo que no se admite.
- **uv** — https://docs.astral.sh/uv/ — proyectos, `uv.lock` y `uv run`.
- **node-postgres** — https://node-postgres.com/ — `Client`, `Pool` y el cierre.
- **Driver de MongoDB para Node** — https://www.mongodb.com/docs/drivers/node/current/ —
  `directConnection` y la selección de servidor.
- **iovalkey** — https://github.com/valkey-io/iovalkey
- **Cliente de OpenSearch para JavaScript** — https://docs.opensearch.org/latest/clients/javascript/index/
- **Driver de Neo4j para JavaScript** — https://neo4j.com/docs/javascript-manual/current/
- **Cliente de Qdrant para JavaScript** — https://github.com/qdrant/qdrant-js
- **Driver de Cassandra para Node** — https://docs.datastax.com/en/developer/nodejs-driver/latest/
- **PouchDB** — https://pouchdb.com/guides/
- **psycopg 3** — https://www.psycopg.org/psycopg3/docs/
- **DuckDB para Python** — https://duckdb.org/docs/stable/clients/python/overview
- **sentence-transformers** — https://sbert.net/
- **Transformers.js** — https://huggingface.co/docs/transformers.js/

**Orden sugerido:** instalar y la prueba de los tres scripts antes de F01; la conexión que no se
cierra la primera vez que un script tuyo no termine; Python cuando llegues a F07.

---

## 🧪 Ejercicios (8)

### 🟢 Ejercicio 1 — Tu entorno

Ejecuta `npm ci` y `uv sync` en `src/`, y después los tres scripts de comprobación con el
laboratorio arriba.

**Objetivo:** diez ✅ en TypeScript, cuatro en Python y el vector de 384 dimensiones desde
TypeScript.

### 🟢 Ejercicio 2 — La conexión que no se cierra

Copia el ejemplo de `pg` sin el `finally` y ejecútalo con `timeout 15`.

**Pregunta:** ¿qué código de salida devuelve y por qué? Añade el cierre y comprueba que termina
solo.

### 🟢 Ejercicio 3 — Un `enum` en Node 24

Escribe un `enum` con los estados de una pieza (`installed`, `inStore`…) y ejecútalo con `node`.

**Objetivo:** reconocer `ERR_UNSUPPORTED_TYPESCRIPT_SYNTAX` y reescribirlo como un objeto
`as const` que Node sí ejecute.

### 🟡 Ejercicio 4 — Mongo sin `directConnection`

Quita `directConnection=true` de la conexión a `documental` y conéctate.

**Pregunta:** ¿qué pasa en tu máquina? ¿Cambiaría el resultado si tuvieras otro Mongo en el 27017, o
si no tuvieras ninguno? Explícalo con lo que devuelve el comando `hello`.

### 🟡 Ejercicio 5 — Tres familias, un driver

Conéctate con `pg` a `base`, `series` y `newsql`, y ejecuta `SELECT version()` en las tres.

**Objetivo:** explicar por qué el mismo driver sirve para tres motores distintos, y qué dejaría de
funcionar si en `newsql` usaras una función propia de Postgres.

### 🟡 Ejercicio 6 — Los dos viajes

Escribe un script que haga dos consultas independientes a `base`, primero con dos `await`
seguidos y después con `Promise.all`.

**Pregunta:** ¿cuántos viajes hace cada versión? ¿Cuál termina antes, y por qué eso no convierte al
tiempo en argumento?

### 🟠 Ejercicio 7 — La paridad, por tu cuenta

Embebe el mismo reporte de piloto en Python y en TypeScript y compara los dos vectores.

**Objetivo:** reproducir la paridad de este apéndice. Después prueba el modelo cuantizado en
TypeScript (`dtype: "q8"`) y **predice antes de ejecutar** cuánto cambia el coseno.

### 🟠 Ejercicio 8 — Lo que `tsc` encuentra

Introduce un error de tipos que Node no detecte al ejecutar —por ejemplo, un número donde va un
`hangarId`— y corre `node` y después `npx tsc`.

**Pregunta:** ¿por qué uno lo ejecuta sin quejarse y el otro lo rechaza, y qué te dice eso del modo
"solo quitar tipos"?

---

> 🏷️ **Este apéndice no lleva tag propio.** Los archivos de entorno de `src/` y los scripts de
> comprobación se commitean con él, con el prefijo de la fase desde la que se llegó; el primero
> que los necesita es F01.
