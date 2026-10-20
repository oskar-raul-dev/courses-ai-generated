# 🕵️ Forense Fase 07 — "El índice está creado y la consulta sigue igual de lenta"

> **Sale de:** [Fase 7 — Índices](07-indices.md) ·
> **Herramientas:** `explain("executionStats")`, `getIndexes()` y `currentOp()`
> · **Recorrido:** cinco pasos
>
> **El síntoma, en una línea:** el índice existe, el plan hasta dice que lo usa,
> y la consulta no mejora.

Todo lo que sabes de índices en tu motor relacional sigue valiendo acá:
selectividad, prefijo izquierdo, el coste en las escrituras. Lo que cambia es la
**herramienta de diagnóstico** y su capacidad de mentir. Esta pieza es, sobre
todo, un curso de lectura de `explain()`.

---

## 🎫 El ticket

> "Creamos el índice que dijiste y la consulta sigue igual de lenta. Lo verifiqué
> en Compass, ahí está el índice. ¿Hay que reiniciar Mongo para que lo tome?"
>
> — el compañero que está optimizando el listado · **Ambiente:** UAT

No hay que reiniciar nada, y ésa es la primera cosa que conviene sacar de la
conversación: los índices se usan —o no— consulta por consulta.

---

## 🧭 La ruta

Del más barato al más caro. Y una advertencia sobre el orden: mucha gente empieza
creando índices, que es el paso caro. Acá se empieza mirando.

### Paso 1 — ¿qué índices hay, exactamente?

```js
> db.tickets.getIndexes()
[
  { v: 2, key: { _id: 1 }, name: '_id_' },
  { v: 2, key: { createdAt: -1, status: 1 }, name: 'createdAt_-1_status_1' }
]
```

**Qué descarta.** Descarta la duda de si el índice existe y, de paso, ya deja ver
el problema más probable: el orden de las claves. Guárdalo para el paso 3.

### Paso 2 — ¿qué dice el plan, con los números?

Nunca el `explain()` a secas: siempre con estadísticas de ejecución.

```js
> db.tickets.find({ status: "open" }).sort({ createdAt: -1 })
    .explain("executionStats").executionStats
{
  nReturned: 17875,
  executionTimeMillis: 85,
  totalKeysExamined: 100000,
  totalDocsExamined: 100000,
  executionStages: { stage: 'FETCH', inputStage: { stage: 'IXSCAN',
    indexName: 'createdAt_-1_status_1', … } }
}
```

*(La base de 100k de `scripts/generate.js`; los milisegundos son los de tu
máquina, los conteos no.)*

**Qué descarta.** Descarta la sensación y la reemplaza por dos números. El
`stage` dice `IXSCAN`, que es lo que el compañero quería leer, y la razón que
importa dice otra cosa: **`totalDocsExamined` frente a `nReturned`**, 100.000
examinados para devolver 17.875. Un `IXSCAN` que toca toda la colección es un
COLLSCAN con corbata.

### Paso 3 — ¿el compuesto está en el orden correcto?

Con el índice del paso 1 y la consulta del paso 2, el desajuste salta:

```
Índice:   { createdAt: -1, status: 1 }
Consulta: filtra por status, ordena por createdAt
```

**Qué descarta.** Cierra el caso más común. El prefijo izquierdo del índice es
`createdAt`, y la consulta no filtra por ese campo: el índice no puede acotar
por `status`. Mongo igual lo elige, porque le sirve para **ordenar** (por eso no
hay etapa `SORT`), y entonces recorre el índice entero y descarta los que no son
`open` documento por documento. Con `{ status: 1, createdAt: -1 }` el filtro
entra por el prefijo y el orden sale gratis:

```js
{ nReturned: 17875, executionTimeMillis: 13,
  totalKeysExamined: 17875, totalDocsExamined: 17875 }
```

Es exactamente la regla de prefijo izquierdo que ya conoces; lo nuevo es dónde
leerla. (El `COLLSCAN` con el índice creado aparece cuando la consulta filtra
**solo** por un campo que no es prefijo: un `find({ createdAt: { $gte: … } })`
contra `{ status: 1, createdAt: -1 }` lo da.)

### Paso 4 — usa el índice y sigue lento

El caso que más despista, porque el `stage` dice lo que querías leer:

```js
> db.tickets.createIndex({ title: 1 })
> db.tickets.find({ title: /impresora/i }).explain("executionStats").executionStats
{ nReturned: 11202, executionTimeMillis: 40,
  totalKeysExamined: 100000, totalDocsExamined: 11202,
  executionStages: { stage: 'FETCH', inputStage: { stage: 'IXSCAN', indexName: 'title_1', … } } }
```

**Qué descarta.** Descarta la etapa como criterio: un regex no anclado —y encima
insensible a mayúsculas— recorre **las 100.000 claves** del índice; el `IXSCAN`
solo le ahorra traer los documentos que no coinciden. Sin el índice, el mismo
`find` hace COLLSCAN en 24 ms: el índice lo volvió **más lento**. Solo un
`/^La impresora/` acota: 11.203 claves y 7 ms. La regla es la misma que la del `LIKE '%algo%'`
de siempre, con la diferencia de que acá el plan no te dice "no puedo": te dice
que usó el índice.

### Paso 5 — ¿el problema es la consulta o el modelo?

Antes de crear el siguiente índice, la pregunta que la fase pone con todas las
letras:

```js
> db.tickets.find({ status: "open" }).sort({ createdAt: -1 }).limit(20)
    .explain("executionStats").executionStats
{ nReturned: 20, totalKeysExamined: 20, totalDocsExamined: 20,
  executionTimeMillis: 0 }
```

Y la pantalla sigue tardando cuatro segundos.

**Qué descarta.** Descarta los índices por completo, y es el meta-error de la
fase: **seguir afinando índices cuando el `explain()` ya está limpio y lo lento
es el modelo.** Si cada consulta es óptima y la pantalla sigue lenta, el coste
está en el número de consultas o en la forma de los datos — que es la
[pieza de la Fase 5](forense-fase-05.md).

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| El índice existe y el plan dice COLLSCAN | Prefijo izquierdo, o tipos que no coinciden |
| IXSCAN y sigue lento | `totalDocsExamined` contra `nReturned`: la razón es el diagnóstico |
| Aparece una etapa SORT | El compuesto está al revés para esa consulta |
| Un regex que "usa" el índice y va más lento | El flotante recorre todas las claves; solo el anclado (`^…`) acota |
| El índice está y el plan ordena con él, pero examina todo | Compuesto al revés: sirve para el `sort`, no para el filtro |
| El TTL no borra nada y no avisa | Está sobre fechas guardadas como string (Fase 1) |
| Un índice unique que rechaza documentos legítimos | Los documentos **sin** el campo también compiten por el `null` |
| Los inserts se volvieron lentos | Índices nuevos en una colección de escritura intensa |
| El plan cambia entre corridas | Plan cacheado: el que ves puede no ser el que corrió |
| Todo óptimo y la pantalla sigue lenta | Es el modelo o el N+1, no los índices (Fase 5) |
| "Mongo va lento" sin más datos | Pide la consulta y su `explain()` antes de proponer nada |

---

## ⚰️ Los callejones

**"Creo un índice por cada campo importante."** Indexar por catálogo es el error
de instinto más caro de la fase: cada índice se paga en cada escritura, y una
colección con doce índices tiene los inserts lentos y probablemente sigue sin
cubrir la consulta real. Se indexa **por consulta del contrato**, no por campo.

**"Hay que reiniciar Mongo para que tome el índice."** No. Los índices están
disponibles al instante; lo que puede engañarte es el **plan cacheado**, que hace
que una consulta siga usando el plan elegido antes. Es la mentira característica
de `explain()` y conviene conocerla antes de sacar conclusiones de dos
mediciones seguidas.

**"Ya está indexado, entonces es rápido."** Es la conclusión que el paso 4
desmiente. "Usa índice" y "usa bien el índice" son afirmaciones distintas, y solo
la segunda se puede comprobar — mirando cuántos documentos examinó para devolver
los que devolvió.

---

## 🧠 El patrón transferible

**Un plan de ejecución no se lee por su etiqueta, se lee por su aritmética.** La
razón entre lo examinado y lo devuelto es el único número que no se puede
maquillar: si es cercana a 1, el acceso es sano; si es de miles a uno, da igual
lo que diga la etapa. Ese criterio es idéntico en cualquier motor que hayas usado
—solo cambian los nombres de las columnas del plan— y es lo que te permite
opinar sobre una consulta que no escribiste tú.

Y la disciplina que va con él: **mide antes, mide después, y con las mismas
condiciones.** Una medición con caché caliente contra otra con caché fría no
compara nada, y es la forma más común de "demostrar" una mejora que no existe.

**Sigue por acá:** el resumen en la sección 6 de la [Fase 7](07-indices.md); el
índice de síntomas en [`forense-master.md`](forense-master.md); el caso completo
en el [incidente 07](cuaderno-incidentes.md); y qué hacer cuando el problema
resulta ser el modelo, en la [pieza de la Fase 8](forense-fase-08.md).
