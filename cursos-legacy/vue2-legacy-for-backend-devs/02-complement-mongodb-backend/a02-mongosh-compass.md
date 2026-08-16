# 🍃 Apéndice 2 — mongosh y Compass a fondo

## 🎯 Para qué sirve este apéndice

El shell fue tu herramienta en las catorce fases y siempre lo usaste al 20%:
comandos sueltos, copiar-pegar, salida ilegible. Aquí está el otro 80% — el
que convierte a mongosh en tu **navaja de auditoría** y a Compass en algo más
que un visor bonito.

La idea de fondo, que ya intuiste en la Fase 1: **mongosh es un REPL de
JavaScript con una base de datos dentro**. Eso significa que todo lo que
sabes de JS (variables, bucles, funciones, `map`/`filter`, JSON) vale aquí —
y que el "script de auditoría" que en Oracle era un PL/SQL de media hora, aquí
son cuatro líneas en el prompt.

---

## 🧠 Las dos herramientas, en su sitio

| | mongosh | Compass |
|---|---|---|
| Es | REPL de JS + driver | GUI oficial |
| Brilla en | auditar, scriptear, operar, medir, reparar | explorar, inferir esquema, construir pipelines, mostrarle algo a alguien |
| Tu analogía | `sqlplus` / `psql` | SSMS / DBeaver / pgAdmin |
| El curso lo usó para | todo lo importante | mirar, y el explain visual |

**La regla:** Compass para entender lo que no conoces; mongosh para hacer lo
que decidiste. Nunca operes en producción desde una GUI que hace clic donde
tú creías que solo mirabas.

### 📝 Nota legacy honesta: `mongo` vs `mongosh`

Dos shells conviven en tu vida:

| | `mongo` (clásico) | `mongosh` (moderno) |
|---|---|---|
| Motor JS | SpiderMonkey viejo (ES5-ish) | Node moderno (async/await, ES2020) |
| Dónde lo encuentras | **dentro de la imagen 4.4** y en TODO servidor legacy | tu máquina, instalado aparte |
| Promesas | no las entiende bien | nativas |
| Salida | plana | coloreada, paginada |
| `print`/`printjson` | ✅ | ✅ (+ mejor formato por defecto) |

Todo lo que el curso escribió funciona en ambos. Las diferencias que muerden:
en `mongo` clásico, `async/await` no existe y algunos helpers modernos no
están; en `mongosh`, ciertos comandos legacy están deprecados (`db.copyDatabase`
y familia). **En un servidor de 2019 solo habrá `mongo`** — por eso los
scripts de operación del curso evitan sintaxis exótica.

---

## 🔧 mongosh como REPL: lo que cambia todo

```js
// 1. Es JavaScript. Guarda cosas en variables.
const t = db.tickets.findOne({ status: "open" });
t.title                                  // navega el objeto
Object.keys(t)                           // ¿qué campos tiene REALMENTE?

// 2. Los cursores son iterables: mapea, filtra, reduce
db.tickets.find({ status: "open" }).toArray()
  .map(x => x.priority)
  .reduce((acc, p) => (acc[p] = (acc[p] || 0) + 1, acc), {})
// ⬆️ un GROUP BY en el cliente, en una línea, sin aggregation

// 3. Bucles: la reparación quirúrgica
db.tickets.find({ createdAt: { $type: "string" } }).forEach(function (doc) {
  db.tickets.updateOne({ _id: doc._id },
    { $set: { createdAt: new Date(doc.createdAt) } });
});
// ⬆️ la migración de la Fase 4, en el shell, para 200 documentos
// (para 200.000: script con driver y lotes — F4 ej. 28)

// 4. Funciones propias: tu librería de auditoría
function formas(col, n) {
  const campos = {};
  db[col].find().limit(n || 1000).forEach(d =>
    Object.keys(d).forEach(k => campos[k] = (campos[k] || 0) + 1));
  return campos;                          // campo → cuántos docs lo tienen
}
formas("tickets")                         // ⬅️ detector de drift en 5 líneas
```

🔎 **Qué hace:** ese último ejemplo es el `schema-drift` de la Fase 4 (ej. 31)
en formato interactivo. **Ese es el punto del apéndice**: cuando entiendes que
el shell es JS, dejas de buscar "el comando que hace X" y simplemente escribes
X.

### Salida legible (deja de leer muros)

```js
// Solo lo que importa (proyección, siempre)
db.tickets.find({}, { title: 1, status: 1, _id: 0 })

// Tabla en vez de JSON gigante
db.tickets.find().limit(5).toArray()
  .forEach(t => print(t.status.padEnd(12), t.priority.padEnd(8), t.title));

// Contar rápido sin traerte nada
db.tickets.countDocuments({ status: "open" })

// Cursores grandes: it (siguiente lote), o .itcount() para contar iterando
db.tickets.find()      // muestra 20 y ofrece "Type 'it' for more"
```

> ⚠️ **`count()` vs `countDocuments()`:** el viejo `db.col.count()` (que verás
> por todo el legacy) usa metadatos y **puede mentir** tras un apagón sucio o
> en shards. `countDocuments()` cuenta de verdad. `estimatedDocumentCount()`
> es el rápido-y-aproximado cuando no hay filtro. Este es uno de los fósiles
> datadores de la Fase 15.

### `.mongoshrc.js`: tu shell, permanente

Vive en tu `$HOME`. Se ejecuta en cada arranque:

```js
// ~/.mongoshrc.js — tus helpers de guardia, siempre a mano
prompt = function () {
  return db.getName() + " [" + (db.serverStatus().host || "?") + "] > ";
};

// Atajos que usarás toda la vida
globalThis.lentas = function (ms) {
  return db.system.profile.find({ millis: { $gt: ms || 100 } })
    .sort({ ts: -1 }).limit(10).toArray()
    .map(o => ({ ms: o.millis, ns: o.ns, plan: o.planSummary }));
};

globalThis.colscans = function () {          // ⬅️ el detector de la F7/F14
  return db.system.profile.find({ planSummary: "COLLSCAN" })
    .sort({ ts: -1 }).limit(10).toArray().map(o => o.command);
};

globalThis.idx = function (col) {
  return db[col].getIndexes().map(i => ({ name: i.name, key: i.key }));
};
```

Ahora `lentas(50)` y `colscans()` son comandos tuyos en cualquier base.
✅ **Buena práctica de la época:** versiona tu `.mongoshrc.js` en un gist o
dotfiles — es capital acumulado.

---

## 📜 El shell como intérprete de scripts (lo que la F14 usó)

```bash
# Ejecutar y salir: la base de todo script de operación
mongosh "mongodb://localhost:27017/minijira" --quiet --eval 'db.tickets.countDocuments()'

# --quiet: sin banner de bienvenida → la salida es PARSEABLE por bash
COLECCIONES=$(mongosh "$URI" --quiet --eval 'db.getCollectionNames().join(" ")')
for c in $COLECCIONES; do mongoexport --collection="$c" ...; done   # ⬅️ F0 ej. 21

# Un archivo entero
mongosh "$URI" scripts/audit.js
mongosh "$URI" --eval 'load("scripts/helpers.js")' --shell   # carga y te deja dentro
```

> 💡 **El truco del `--eval` que devuelve JSON:** para que bash pueda comer la
> salida, envuelve en `JSON.stringify()` y usa `--quiet`. Sin eso, el formato
> bonito de mongosh te llena la variable de colores y saltos.

**Cuándo NO usar el shell y sí un script con driver (Node):** cuando necesitas
control de errores decente, lotes, concurrencia, reintentos o que el código
sea testeable. Regla del curso: **shell para operar e investigar; driver para
lo que corre solo** (las migraciones de la F4 son driver, no shell — por eso).

---

## 🧭 Navegación y metadatos (el `\d` que buscabas)

```js
show dbs                                   // las bases
use minijira
show collections
db.getCollectionInfos()                    // ⬅️ incluye el VALIDATOR (F4)
db.tickets.getIndexes()                    // los índices
db.tickets.stats()                         // tamaño, storageSize, indexSizes
db.stats()                                 // la base entera
db.serverStatus()                          // el monstruo: conexiones, memoria, opcounters
db.serverStatus().connections              // ⬅️ pícalo por partes o te ahogas
db.tickets.distinct("status")              // el dominio REAL de un campo (F4)
db.version()
```

**El ritual de reconocimiento** ante una base ajena (5 minutos, F15):

```js
show collections                                    // 1. ¿qué hay?
db.getCollectionInfos().map(c => c.name + ": " + (c.options.validator ? "✅" : "❌"))
db.X.countDocuments()                               // 2. ¿cuánto pesa cada una?
db.X.findOne()                                      // 3. ¿qué forma tiene?
db.X.getIndexes()                                   // 4. ¿qué se indexó?
formas("X")                                         // 5. ¿todos los docs son iguales?
```

Esos cinco comandos + la tabla de olores de la Fase 15 = tu diagnóstico
forense.

---

## 🧿 Compass: lo que sí aporta

**1. La pestaña Schema (el arma secreta).** Muestrea la colección e infiere:
qué campos existen, en qué % de documentos, con qué tipos. Es el detector de
drift de la Fase 4 en formato visual — y ver "createdAt: string 12%, date 88%"
en colores vale más que mil párrafos.

**2. Explain visual.** El plan de la Fase 7 con el árbol dibujado: etapas,
docs examinados vs devueltos, índice usado. Para *entender* un plan la primera
vez, gana al JSON crudo. Para *auditar en serie*, mongosh gana.

**3. Aggregation Pipeline Builder.** Construyes etapa por etapa **viendo la
salida de cada una** con datos reales. Es la mejor forma de aprender el
pipeline de la Fase 9 — y luego copias el pipeline a código con el botón
"Export to language" (Node incluido).

**4. Índices con uso real.** La pestaña Indexes muestra tamaño y **cuántas
veces se usó cada uno** (`$indexStats` por debajo): el detector de índices
inútiles de la Fase 7, servido.

**Lo que Compass NO debe ser:** tu forma de editar producción. Un clic en
"delete" no tiene `--dry`, no deja rastro en un script, y no se revisa en un
PR. Mirar, sí; operar, en el shell y por escrito.

---

## 🧩 Chuleta

```js
// El shell ES JavaScript: variables, funciones, map/filter/forEach, JSON
const t = db.tickets.findOne(); Object.keys(t)
db.col.find().forEach(d => ...)          // reparación quirúrgica (pocos docs)
// ⬆️ ¿muchos docs, o corre solo? → script con driver, no shell

// Salida legible
find({}, { campo: 1, _id: 0 })  ·  countDocuments()  ·  print(...)  ·  `it`

// Reconocimiento (5 min): show collections → getCollectionInfos (validator!)
//   → countDocuments → findOne → getIndexes → formas()

// Scripting
mongosh "$URI" --quiet --eval 'JSON.stringify(x)'    # parseable por bash
mongosh "$URI" script.js  ·  load("helpers.js")
~/.mongoshrc.js  →  tus helpers permanentes (lentas, colscans, idx)

// Fósiles: count() miente → countDocuments() · db.copyDatabase() ya no existe

// Compass: Schema (drift) · Explain visual · Pipeline Builder (+ export a Node)
//   · Indexes con uso real.  MIRAR sí; OPERAR no.
```

---

## ⚠️ Errores comunes

- Usar `find()` sin proyección sobre documentos gordos y ahogarse en la
  salida (proyecta SIEMPRE en el shell).
- `forEach` con update sobre 500.000 documentos desde el shell: una operación
  por documento, sin lotes, sin manejo de errores, y una hora mirando el
  cursor. Eso es un script con driver.
- Confundir `count()` con `countDocuments()` en una auditoría (y reportar un
  número que el motor se inventó).
- Editar producción desde Compass "porque era un cambio chiquito".
- Olvidar `--quiet` en el `--eval` de un script bash y parsear colores.
- Asumir que el shell del servidor (`mongo` clásico) entiende tu `async/await`
  o tu arrow function moderna: prueba antes de pegar.
- Dejar el `.mongoshrc.js` apuntando a helpers que dependen de una base
  concreta (hazlos genéricos o falla en cada conexión).
- Leer `db.serverStatus()` entero: pícalo (`.connections`, `.opcounters`,
  `.wiredTiger.cache`).

---

## 🧪 Ejercicios (32) — todos opcionales

**🟢 Fácil (1–10)**

1. En el shell: guarda un ticket en una variable, imprime sus claves con `Object.keys`, y añade un campo al objeto **local**. Verifica que la base no cambió (el objeto es una copia: entender esto evita bugs).
2. Cuenta tickets por prioridad usando solo JS (`toArray` + `reduce`), sin aggregation. Compáralo con `db.tickets.aggregate` de la Fase 9: ¿cuándo prefieres cada uno?
3. Escribe `formas(col)` (la del capítulo) y córrela sobre `tickets` y sobre `soporte_v1.tickets`. ¿Qué te dice de cada base en 3 segundos?
4. Proyecta: lista 20 tickets mostrando SOLO estado, prioridad y título, alineados con `padEnd`. Compara la legibilidad con el `find()` pelado.
5. `count()` vs `countDocuments()` vs `estimatedDocumentCount()`: mide los tres sobre 100k. ¿Cuál miente? ¿Cuál tarda?
6. Ritual de reconocimiento completo (los 5 comandos) sobre `soporte_v1`. Cronométrate: ¿5 minutos?
7. Crea tu `~/.mongoshrc.js` con un prompt que muestre la base actual y los helpers `idx()` y `lentas()`. Reinicia el shell y úsalos.
8. `db.getCollectionInfos()`: encuentra el validator de la Fase 4 y léelo desde el shell. ¿Qué colecciones NO tienen validator?
9. `--eval` desde bash: imprime el conteo de tickets abiertos y guárdalo en una variable de shell. Falla primero sin `--quiet` y entiende por qué.
10. En Compass: abre la pestaña Schema de `tickets`. ¿Qué porcentaje tiene `assignee: null`? ¿Coincide con tu `countDocuments`?

**🟡 Intermedio (11–20)**

11. Repara desde el shell: crea 20 tickets con `createdAt` string (sabotaje), y arréglalos con un `forEach` + `updateOne`. Ahora reescribe la misma reparación como un solo `updateMany` con pipeline (F4). ¿Cuál prefieres y por qué?
12. Escribe `scripts/audit.js` (para `mongosh script.js`): imprime el reconocimiento completo de cualquier base — colecciones, conteos, validators, índices, y las formas de cada una. Córrelo contra las dos bases del curso.
13. El detector de índices inútiles: usando `$indexStats` desde el shell, lista los índices con `accesses.ops === 0`. Compáralo con lo que Compass muestra en su pestaña Indexes.
14. Pipeline Builder de Compass: construye el `GET /stats` de la Fase 9 etapa por etapa, mirando la salida intermedia. Expórtalo a Node y compáralo con lo que escribiste a mano. ¿Alguna diferencia interesante?
15. Explain visual vs `explain("executionStats")`: corre la misma query lenta en ambos. ¿Qué te dice Compass más rápido? ¿Qué solo ves en el JSON?
16. Un script bash de operación real: recorre todas las colecciones (vía `--eval` + `getCollectionNames`) y reporta conteo + tamaño de cada una en formato tabla. Es el `scripts/health-report` de la F14, versión shell.
17. Prueba tus scripts contra el shell CLÁSICO (`docker exec -it minijira-mongo mongo`). ¿Cuáles se rompen? Anota exactamente qué sintaxis no soportó — esa lista es tu guía para escribir scripts que sobrevivan a un servidor legacy.
18. Cursores grandes: `find()` sin límite sobre 100k. Usa `it`, luego `.itcount()`, luego `.batchSize(1000)`. Explica qué hace cada uno con la memoria del shell.
19. La reparación con confirmación: escribe un helper que reciba un filtro y un update, muestre CUÁNTOS documentos afectaría, pida confirmación (variable booleana), y solo entonces ejecute. Tu `--dry` en el shell.
20. Conecta mongosh a la base efímera de los tests (F13): imprime la URI desde el globalSetup y explora la base mientras un test corre en debug. Depurar tests contra un motor real es un superpoder.

**🟠 Difícil (21–27)**

21. Librería de guardia: convierte tu `.mongoshrc.js` en una librería completa (`lentas`, `colscans`, `formas`, `idx`, `unused`, `drift`) versionada en tu repo de dotfiles, con documentación. Úsala en las tres bases del curso y refínala hasta que no toques la doc oficial para diagnosticar.
22. Shell vs driver, medido: la migración de fechas (F4) sobre 100.000 documentos — hazla con `forEach` en el shell y con script de driver por lotes. Cronometra ambas, mide el impacto en el server (`mongostat`), y documenta el umbral a partir del cual el shell deja de ser aceptable.
23. Auto-completado y exploración de la API: en mongosh, escribe `db.tickets.` + TAB. Explora 5 métodos que el curso NO usó, lee su doc con `db.tickets.help()` y encuentra uno que te habría servido en alguna fase. Documéntalo.
24. Salida a archivo con formato: script que exporte un informe (markdown o CSV) del estado de la base — colecciones, formas, drift, índices sin uso. `mongosh --quiet --eval` + redirección. Ahora tienes un reporte que puedes pegar en un ticket.
25. Reproduce el explain visual: sin usar Compass, escribe una función que tome el `explain("executionStats")` y lo imprima como árbol legible (etapas indentadas, docs examinados/devueltos, índice). Entender el JSON del plan a este nivel es lo que separa al que lee el plan del que lo interpreta.
26. Compass contra producción: enumera todas las acciones de Compass que MODIFICAN datos (busca los botones), y escribe la política de tu equipo: qué está permitido hacer con Compass en qué entorno. Media página, con justificación. (Este ejercicio ha salvado empresas.)
27. Reescribe tres scripts de operación de la Fase 14 en sintaxis compatible con el `mongo` clásico (sin async/await, sin arrow functions, sin métodos ES2020). Verifícalos dentro del contenedor. Ahora tus scripts corren en cualquier servidor legacy que te encuentres.

**🔴 Muy difícil (28–32)**

28. El auditor automático: script que, dado un URI, produzca el informe forense de la Fase 15 completo — aplica la tabla de olores programáticamente (detecta lookup-tables por conteo bajo + referencias, ids numéricos, arrays sin techo, ausencia de validators/schemaVersion, índices sin uso) y emita un veredicto con evidencia. Pruébalo contra `soporte_v1` (debe encender) y `minijira` (debe callarse). Es el curso entero, ejecutable.
29. Shell interactivo con estado: escribe un `load()`-able que implemente un "modo investigación": captura cada query que ejecutas (wrapper sobre `find`), la cronometra y la va apilando en un array; al final imprime tu sesión con tiempos. Un profiler del lado del cliente, hecho por ti.
30. Portabilidad total: verifica que tu librería del ej. 21 funciona en mongosh, en `mongo` clásico y como script no interactivo. Documenta las tres incompatibilidades que tuviste que rodear. Es el ejercicio que te enseña a escribir herramientas de operación duraderas.
31. Enseña con Compass: prepara una demo de 10 minutos que le explique el modelo del Mini Jira a un dev SQL usando solo Compass (Schema para mostrar la heterogeneidad, Explain para el índice, Pipeline Builder para el stats). Grábate. Descubrirás qué NO entiendes cuando no puedas explicarlo.
32. El fósil datador: reúne 8 comandos/APIs deprecados o eliminados desde 4.4 (`count()`, `db.copyDatabase()`, `$eval`, `background: true`...) con su versión de deprecación y su reemplazo. Es la tabla que te permitirá **fechar** un script legacy con solo leerlo — el ejercicio 8 de la Fase 15, con munición real.

---

## 📚 Referencias

**Documentación oficial**

- mongosh (guía completa): https://www.mongodb.com/docs/mongodb-shell/
- mongosh — configurar y `.mongoshrc.js`: https://www.mongodb.com/docs/mongodb-shell/reference/configure-shell-settings/
- mongosh — ejecutar scripts (`--eval`, `load`): https://www.mongodb.com/docs/mongodb-shell/write-scripts/
- mongosh vs mongo (diferencias de compatibilidad): https://www.mongodb.com/docs/mongodb-shell/reference/compatibility/
- Métodos del shell (referencia, 4.4): https://www.mongodb.com/docs/v4.4/reference/method/
- `db.collection.explain()`: https://www.mongodb.com/docs/v4.4/reference/method/db.collection.explain/
- `$indexStats` (índices sin uso): https://www.mongodb.com/docs/v4.4/reference/operator/aggregation/indexStats/
- Compass (guía): https://www.mongodb.com/docs/compass/
- Compass — Schema tab: https://www.mongodb.com/docs/compass/current/schema/
- Compass — Aggregation Pipeline Builder: https://www.mongodb.com/docs/compass/current/aggregation-pipeline-builder/

**Video (YouTube)**

- MongoDB Compass Tutorial (canal oficial MongoDB): busca "Compass" en su canal
- The MongoDB Shell (mongosh) — MongoDB oficial, charlas de lanzamiento 2020–2021

**Orden de lectura sugerido:**
la sección "mongosh como REPL" de este apéndice (es el 80% del valor) → tu
`.mongoshrc.js` (ej. 7: hazlo AHORA, te acompañará años) → Write Scripts de
la doc → la pestaña Schema de Compass → el resto como consulta.
