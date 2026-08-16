# 📎 Apéndice bea-05 — Índices y `explain()` en MongoDB

> Tutorial Angular 8 — Laboratorio clínico · 🔥 Track BE · Consulta rápida · **3 horas**
> Usado por: be02, be03 · Versiones cubiertas: MongoDB 4.0 y 7.0

**Esto no se lee de corrido.** Se entra con una consulta lenta y la pregunta *"¿esto usó un índice?"*, y se sale con la respuesta y con el `explain()` sabiendo leerse.

Resuelve una cosa: **saber si la consulta que el repositorio de Spring generó por ti usó un índice o barrió la colección entera.** Porque el repositorio no te lo dice, y el método se llama `findByDocumentId`, que suena a que sabe lo que hace.

**Qué queda fuera:** índices de texto y geoespaciales, que LabCore no tiene y no va a tener; el perfilado continuo en producción, que es una práctica de operación y no de mantenimiento; y el ajuste fino, que en un sistema con dos años de decomisión no se hace — se crean los tres índices que faltan y se cierra el tema.

---

## Índice

- [1. 🩻 Esto sí funciona igual](#1--esto-sí-funciona-igual)
- [2. Lo que sí cambia](#2-lo-que-sí-cambia)
- [3. Leer un `explain()`: los cinco campos](#3-leer-un-explain-los-cinco-campos)
- [4. El `COLLSCAN` que el repositorio escondía](#4-el-collscan-que-el-repositorio-escondía)
- [5. Índices compuestos y la regla ESR](#5-índices-compuestos-y-la-regla-esr)
- [6. Índices sobre arreglos: multiclave y su trampa](#6-índices-sobre-arreglos-multiclave-y-su-trampa)
- [7. Parciales, únicos y TTL](#7-parciales-únicos-y-ttl)
- [8. Los índices que LabCore tiene y los que debería tener](#8-los-índices-que-labcore-tiene-y-los-que-debería-tener)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-8)

---

## 1. 🩻 Esto sí funciona igual

Antes de nada, lo que **no** hay que reaprender. Vienes de SQL y la mayor parte de tu instinto sobre índices vale aquí tal cual:

**Un índice sigue siendo un B-tree.** Mismo concepto, misma estructura, mismos costes. Acelera las lecturas que lo usan y **encarece todas las escrituras**, porque cada `insert` y cada `update` de un campo indexado tiene que mantenerlo.

**La selectividad sigue mandando.** Un índice sobre un campo con dos valores distintos y un millón de documentos no sirve para casi nada; uno sobre un identificador único lo resuelve todo. La intuición es idéntica.

**Un recorrido completo sigue siendo lo primero que se sospecha** cuando algo tarda, y sigue llamándose igual en tu cabeza aunque aquí se escriba `COLLSCAN` en vez de *full table scan*.

**El orden de los campos en un índice compuesto sigue importando**, y por la misma razón: el índice está ordenado por el primer campo, después por el segundo, y así. Un índice `{a, b}` sirve para consultar por `a` y por `a+b`, y **no** sirve para consultar solo por `b`. Es la misma regla del prefijo izquierdo que ya conoces.

**Y ordenar sin índice sigue costando memoria.** Un `SORT` en el plan es lo mismo que un *filesort*: el motor trae todo y ordena aparte.

> 🧭 **Dicho de otra forma: tu instinto de índices está intacto y no hay que recalibrarlo.** Este apéndice existe por lo que cambia alrededor, que es poco pero muerde.

---

## 2. Lo que sí cambia

Tres cosas, y solo tres.

**Nadie te obliga a tener una clave alternativa.** En SQL, declarar `UNIQUE` sobre `documentId` era parte de crear la tabla y el motor te lo recordaba. Aquí la colección nace sin nada y sin que nadie pregunte. **La única cosa que existe siempre es el índice sobre `_id`**, que es automático y no se puede borrar. Todo lo demás lo creas tú o no existe.

**El plan lo esconde una capa más.** Entre tú y la consulta hay un repositorio derivado del nombre del método. `findByDocumentId` no menciona ningún índice, así que nadie se pregunta si lo hay. En SQL escribías el `WHERE` con tus manos y al menos sabías lo que estabas pidiendo.

**Y los índices se crean en caliente, con consecuencias.** Crear un índice sobre una colección grande bloquea escrituras durante la construcción —salvo en modo `background` en 4.0, que es más lento y no bloquea—. En LabCore, con miles de documentos, es instantáneo; el reflejo de preguntarse *"¿esto bloquea?"* antes de crear un índice en producción hay que conservarlo igual.

> ⚠️ **Por eso `be03` §5.1 pone `spring.data.mongodb.auto-index-creation=false`.** En Boot 2.1 el valor por defecto es `true`, y eso significa que las anotaciones `@Indexed` crean índices **al arrancar la aplicación**. Sobre una colección grande, el arranque se queda colgado el tiempo que tarde, y nadie relaciona el despliegue lento con una anotación. Los índices se crean a mano y se miden.

---

## 3. Leer un `explain()`: los cinco campos

```javascript
db.patients.find({ documentId: 'CC-1032456789' }).explain('executionStats');
```

Los tres modos, y cuál usar:

| Modo | Qué da | Cuándo |
|---|---|---|
| `queryPlanner` (por defecto) | El plan elegido, **sin ejecutar** | Para ver qué índice piensa usar |
| `executionStats` | El plan **y los números reales** | **El que quieres casi siempre** |
| `allPlansExecution` | Lo anterior más los planes descartados | Cuando el optimizador elige raro |

De la salida, que es un JSON enorme, importan cinco campos:

```json
{
  "executionStats": {
    "nReturned": 1,                  ← cuántos documentos devolvió
    "executionTimeMillis": 12,       ← cuánto tardó
    "totalKeysExamined": 0,          ← cuántas entradas de índice miró
    "totalDocsExamined": 4820,       ← cuántos DOCUMENTOS leyó
    "executionStages": {
      "stage": "COLLSCAN"            ← cómo lo hizo
    }
  }
}
```

**Y la lectura, en dos reglas:**

> 🧭 **Regla 1 — la proporción.** Divide `totalDocsExamined` entre `nReturned`. Si es cercana a 1, el índice está haciendo su trabajo. Si es 4820:1, estás leyendo la colección entera para devolver un documento. **Esa proporción es el único número que hay que mirar** cuando no tienes tiempo de leer nada más.

> 🧭 **Regla 2 — `totalKeysExamined` en cero significa que no se usó ningún índice.** Es más fiable que buscar la palabra `COLLSCAN`, porque en planes anidados el `COLLSCAN` puede estar enterrado tres niveles.

Las etapas que vas a ver, y qué significan:

| `stage` | Qué pasó |
|---|---|
| `COLLSCAN` | Recorrido completo. El sospechoso habitual |
| `IXSCAN` | Se usó un índice. Va acompañado de `indexName` |
| `FETCH` | Se usó el índice y **además** hubo que ir a buscar los documentos |
| `PROJECTION_COVERED` | El índice tenía todo lo pedido: **no se tocó ni un documento**. Lo mejor que hay |
| `SORT` | Se ordenó **en memoria**, sin índice. Ver abajo |
| `SORT_MERGE` | Se ordenó usando índices. Bien |
| `LIMIT`, `SKIP` | Lo que parecen |

> ⚠️ **`SORT` en el plan es una bandera roja discreta.** Significa que el motor trajo los documentos y los ordenó aparte, y eso tiene un límite duro: **32 MB de memoria por ordenación**. Al pasarlo, la consulta **falla** con `Sort exceeded memory limit` en vez de ir más lenta. Con los datos de LabCore no ocurre; con diez años de auditoría, sí. La solución es un índice que ya entregue el orden — o `allowDiskUse`, que es más lento y en una consulta de pantalla no se quiere.

```javascript
// Truco: quedarse solo con lo que importa, sin leer el JSON entero.
var e = db.patients.find({ documentId: 'CC-1032456789' })
                   .explain('executionStats').executionStats;
print(e.executionStages.stage + '  docs=' + e.totalDocsExamined +
      '  keys=' + e.totalKeysExamined + '  ret=' + e.nReturned +
      '  ms=' + e.executionTimeMillis);
```

**Y para una agregación**, que es lo que más usa este track:

```javascript
db.orders.explain('executionStats').aggregate([ { $lookup: { … } } ]);
// Ojo al orden: explain() va ANTES de aggregate(), no después. Es distinto
// de find() y se equivoca todo el mundo la primera vez.
```

---

## 4. El `COLLSCAN` que el repositorio escondía

El gancho de este apéndice, y el caso real del track.

```java
// La consulta que el validador asíncrono del formulario dispara con CADA
// tecla que el operador escribe en el campo de documento.
List<Patient> findByDocumentId(String documentId);
```

Ese método no menciona ningún índice, no devuelve ninguna advertencia, y funciona perfectamente. Lo que hace por debajo, medido en `be02` §5.7:

| Medición | Sin índice | Con índice |
|---|---|---|
| `stage` | `COLLSCAN` | `IXSCAN` |
| `totalDocsExamined` | 4.820 | 1 |
| `totalKeysExamined` | 0 | 1 |
| `executionTimeMillis` | 12 | 0 |

**Doce milisegundos.** Y ahí está la razón exacta de que nadie lo arreglara en seis años: doce milisegundos no se sienten. No hay ticket, no hay queja, no hay alerta.

> 🧠 **El argumento para crear el índice no es el número de hoy: es la derivada.** El mismo `COLLSCAN` con diez veces más datos son ciento veinte milisegundos; con cien veces, más de un segundo — **por cada tecla**, en la pantalla que más se usa del sistema. Un `COLLSCAN` no es un problema de rendimiento: es un problema de rendimiento **aplazado**, y la fecha del aplazamiento la pone el crecimiento de los datos, no tú.

Cómo se encuentran todos los demás sin ir uno por uno:

```javascript
// El profiler, en modo "solo lo lento". Se enciende, se usa la aplicación
// diez minutos, se apaga, y se mira qué quedó.
db.setProfilingLevel(1, { slowms: 50 });

// … usar la aplicación …

db.setProfilingLevel(0);
db.system.profile.find({ 'planSummary': 'COLLSCAN' },
                       { ns: 1, command: 1, millis: 1, planSummary: 1 })
                 .sort({ millis: -1 }).limit(20);
```

> ⚠️ **El profiler escribe en una colección limitada dentro de tu base y tiene coste.** En un laboratorio, perfecto. En producción se enciende con `slowms` alto, un rato corto, y **se apaga** — y en un sistema clínico, además, hay que pensar dos veces qué acaba escrito en `system.profile`, porque los comandos llevan los valores de la consulta adentro.

---

## 5. Índices compuestos y la regla ESR

Un índice sobre varios campos sirve para las consultas que usan **un prefijo** de esos campos, en ese orden. `{a: 1, b: 1, c: 1}` sirve para `{a}`, `{a,b}` y `{a,b,c}`, y no sirve para `{b}` ni para `{b,c}`.

La pregunta práctica es en qué orden ponerlos, y la respuesta tiene nombre:

> 🧭 **Regla ESR: Equality, Sort, Range.** Primero los campos de **igualdad**, después los de **ordenación**, y al final los de **rango**.

```javascript
// La consulta: los asientos de una entidad, del último mes, más recientes
// primero.
db.auditLog.find({
  entityType: 'sample',                          // ← igualdad
  timestamp: { $gte: oneMonthAgo }                 // ← rango
}).sort({ timestamp: -1 });                      // ← orden

// El índice correcto por ESR:
db.auditLog.createIndex({ entityType: 1, timestamp: -1 });
// La igualdad primero (fija el punto de entrada), y como aquí el campo de
// orden y el de rango son el mismo, uno solo sirve para las dos cosas.
```

Por qué funciona, en una frase: **el campo de igualdad reduce el índice a un tramo contiguo, y dentro de ese tramo las entradas ya vienen ordenadas.** Si pusieras el rango primero, tendrías que recorrer un tramo enorme filtrando, y además ordenar después.

Cómo se comprueba que acertaste: en el `explain`, la etapa `SORT` **desaparece**. Si sigue ahí, el índice no está entregando el orden y ESR está mal aplicado.

```javascript
// Y un caso que merece la pena conocer: el índice que cubre la consulta.
// Si el índice contiene TODOS los campos que pides, el motor no toca ni un
// documento. El plan dice PROJECTION_COVERED y totalDocsExamined es 0.
db.results.createIndex({ sampleId: 1, status: 1 });
db.results.find({ sampleId: 501 }, { _id: 0, status: 1 });   // ← cubierta
// El { _id: 0 } es obligatorio: si pides _id y no está en el índice, hay
// que ir al documento y se pierde la cobertura.
```

---

## 6. Índices sobre arreglos: multiclave y su trampa

Un índice sobre un campo que contiene un arreglo se llama **multiclave** y se crea igual: el motor guarda **una entrada por cada elemento**. No hay que declararlo.

```javascript
// testCodes es un arreglo: ["CBC", "GLU"]
db.orders.createIndex({ testCodes: 1 });
db.orders.find({ testCodes: 'GLU' });   // usa el índice, y va bien
```

Las tres cosas que hay que saber, porque las tres sorprenden:

**El índice crece con los elementos, no con los documentos.** Un arreglo de cincuenta elementos son cincuenta entradas de índice por documento. Con arreglos grandes, el índice puede acabar pesando más que la colección.

**Un índice compuesto admite como máximo un campo multiclave.** `{testCodes: 1, status: 1}` es válido; `{testCodes: 1, otroArreglo: 1}` **no se puede crear** y el error es explícito. Es una limitación del formato, no una opción.

**Y la trampa de verdad: una consulta con dos condiciones sobre un arreglo de subdocumentos casa entre elementos distintos.**

```javascript
// Una muestra hipotética con eventos embebidos:
// { events: [ { type: "received", by: "ana" }, { type: "processed", by: "luis" } ] }

// Esto CASA con ese documento, y probablemente no es lo que querías:
db.samples.find({ 'events.type': 'received', 'events.by': 'luis' });
// Hay un evento "received" y hay un evento de "luis". No el mismo.

// Lo que querías:
db.samples.find({ events: { $elemMatch: { type: 'received', by: 'luis' } } });
```

> 🧠 **Ese falso positivo no da error, da resultados de más**, y es de los bugs más difíciles de ver en una revisión de código porque la consulta se lee bien. En LabCore no muerde hoy —la custodia está aplanada en campos fijos, ver [`bea-03`](./bea-03-modelar-documentos-embeber-o-referenciar.md)— pero mordería el día que exista la colección de eslabones que `be05` propone.

---

## 7. Parciales, únicos y TTL

**Único** — el que además es una restricción de integridad:

```javascript
// El de be03. No es solo velocidad: es la ÚNICA restricción de integridad
// que este sistema va a tener, y es la red que atrapa el fallo del contador.
db.patients.createIndex({ legacyId: 1 }, { unique: true });
```

> ⚠️ **Crear un índice único sobre una colección que ya tiene duplicados falla**, con `E11000` y el documento culpable en el mensaje. Es una buena noticia disfrazada de error: te acabas de enterar de que tienes duplicados. Mídelos primero con un `$group` + `$match: { n: { $gt: 1 } }`, decide qué hacer con ellos, y **solo entonces** crea el índice.

**Parcial** — indexa solo los documentos que cumplen una condición:

```javascript
// Solo los pacientes activos, que son los únicos que se buscan por pantalla.
// Índice más pequeño, escrituras más baratas.
db.patients.createIndex(
  { documentId: 1 },
  { partialFilterExpression: { active: true } }
);
```

Con un matiz que lo hace inutilizable si no se conoce: **el optimizador solo usa un índice parcial si la consulta garantiza la condición del filtro**. Una consulta sin `active: true` **no lo usa**, aunque los documentos que busque estén todos dentro. Y en LabCore hay un agravante: el selector del frontend filtra con `active !== false`, así que los documentos **sin** el campo —las formas B y C de `be02`— quedarían fuera de un índice parcial con `{ active: true }`. Es un buen ejemplo de cómo una deriva de esquema convierte una optimización razonable en un bug.

**TTL** — borra documentos pasado un tiempo:

```javascript
// Borra cada asiento 90 días después de su timestamp.
db.auditLog.createIndex({ timestamp: 1 }, { expireAfterSeconds: 7776000 });
```

> ⚠️ **Y en LabCore esto NO se hace, y la razón no es técnica.** Un TTL sobre la bitácora de auditoría de un laboratorio clínico es **borrar evidencia automáticamente**, y la retención de esos registros la fija una norma, no el equipo de desarrollo. Si el volumen del audit log llega a ser un problema, la solución es archivar a otro sitio con constancia de lo archivado —nunca un `expireAfterSeconds`—. Es la misma doctrina de `be05` §4.4: lo que documenta un hecho no se borra en silencio.

---

## 8. Los índices que LabCore tiene y los que debería tener

**Lo que hay al empezar el track**, en todas y cada una de las cinco colecciones:

```
_id_    ← el automático. Y nada más.
```

Seis años de sistema, cero índices creados. No es negligencia sino ausencia de fricción: nadie tuvo que declararlos para crear las colecciones, y nada volvió a pedirlos.

**Lo que `be03` crea**, con su before/after medido:

```javascript
db.patients.createIndex({ documentId: 1 });
db.patients.createIndex({ legacyId: 1 }, { unique: true });
```

**Y lo que falta**, con su justificación en una línea cada uno. Esta tabla es un entregable: sale del inventario de peticiones de `be00` §5.2, ordenado por frecuencia observada.

| Índice | Quién lo necesita | Por qué |
|---|---|---|
| `orders: { legacyId: 1 }` único | Todo `GET /orders/:id` | El identificador del contrato, en las cinco colecciones |
| `orders: { patientId: 1 }` | `/orders?patientId=` y el `$lookup` de huérfanas | Sin él, ese cruce es cuadrático |
| `samples: { orderId: 1 }` | `/samples?orderId=` | Lo mismo |
| `results: { sampleId: 1 }` | `/results?sampleId=` | Lo mismo |
| `auditLog: { entityType: 1, entityId: 1, timestamp: -1 }` | La timeline de la Fase 11 | ESR aplicado. Hoy la bitácora se trae entera y se filtra en el navegador (💸 3) |
| `referenceRanges: { analyte: 1, effectiveFrom: -1 }` | La selección de rango vigente | Son nueve documentos: **no hace falta**, y decirlo es parte del ejercicio |

> 💡 **La última fila es la más instructiva de la tabla.** Con nueve documentos, un `COLLSCAN` es más rápido que un índice, y crear el índice solo añade coste de escritura y una cosa más que mantener. **Un índice que no hace falta no es neutral: es deuda.** Saber cuándo *no* crear uno es la mitad de esta página.

```javascript
// Inventario de lo que hay, colección por colección:
db.getCollectionNames().forEach(function (c) {
  print('== ' + c);
  db.getCollection(c).getIndexes().forEach(function (i) {
    print('   ' + i.name + '  ' + JSON.stringify(i.key));
  });
});

// Y lo que de verdad se usa. $indexStats lleva la cuenta desde el último
// arranque del servidor: un índice con "ops: 0" después de una semana es
// un índice que alguien creó por si acaso.
db.patients.aggregate([ { $indexStats: {} } ]);
```

---

## 🧭 Cuándo usar qué

| Situación | Qué hacer |
|---|---|
| Una consulta va lenta | `explain('executionStats')` y mirar la proporción docs/ret |
| Quiero saber si usó índice | `totalKeysExamined`. Cero = no usó ninguno |
| Aparece `SORT` en el plan | Falta un índice que entregue el orden. Aplica ESR |
| Consulta con igualdad + orden + rango | Índice compuesto, en ese orden |
| Solo pido dos campos y son los del índice | Proyección cubierta con `{ _id: 0 }` |
| Campo con arreglo | Multiclave, automático. Y `$elemMatch` si hay dos condiciones |
| Solo me interesan los activos | Parcial — **comprobando** que la consulta lleva la condición |
| Necesito que no haya duplicados | Único, midiendo los duplicados antes |
| La colección crece sin parar | **Archivar, no TTL**, si es evidencia |
| Nueve documentos | Ningún índice. El `COLLSCAN` gana |
| Encontrar todos los `COLLSCAN` de golpe | Profiler con `slowms`, un rato, y apagarlo |

---

## ⚠️ Advertencias

**El repositorio de Spring Data no te va a avisar nunca.** Genera la consulta a partir del nombre del método y no sabe ni le importa si hay un índice detrás. **La única forma de saberlo es el `explain()`**, y tiene que ser un hábito y no una reacción: en el momento en que reaccionas, ya hay un ticket abierto.

**`auto-index-creation` es una trampa de arranque.** En Boot 2.1 está en `true` por defecto y crea índices desde las anotaciones `@Indexed` **al arrancar**. Sobre una colección grande eso es un arranque que se cuelga, y nadie relaciona un despliegue lento con una anotación en un modelo. `be03` lo pone en `false` a propósito.

**Un índice no es gratis.** Encarece cada escritura, ocupa espacio y hay que mantenerlo. Con cinco colecciones y seis años de datos que crecen despacio, el balance está clarísimo a favor de los cinco que faltan. **Crearlos "por si acaso" sobre cada campo que aparece en un filtro es la otra forma de hacerlo mal**, y `$indexStats` es lo que lo delata.

**Y los planes cambian entre versiones.** El mismo `explain()` sobre la misma consulta puede elegir otro índice en 7.0 que en 4.0. Es una de las comprobaciones que `be07` §5.5 manda hacer al subir, y es de las silenciosas: no falla nada, solo va más lento.

---

## 📚 Referencias

- MongoDB 4.0 — índices, la sección completa: https://www.mongodb.com/docs/v4.0/indexes/
- `explain()` y sus tres modos: https://www.mongodb.com/docs/v4.0/reference/method/cursor.explain/
- Cómo interpretar la salida de `explain`, campo por campo: https://www.mongodb.com/docs/v4.0/reference/explain-results/
- Índices compuestos y la regla del prefijo: https://www.mongodb.com/docs/v4.0/core/index-compound/
- La regla ESR, en la guía oficial de rendimiento: https://www.mongodb.com/docs/v4.0/tutorial/equality-sort-range-rule/
- Índices multiclave y `$elemMatch`: https://www.mongodb.com/docs/v4.0/core/index-multikey/
- Índices parciales, con la condición de uso por el optimizador: https://www.mongodb.com/docs/v4.0/core/index-partial/
- Índices TTL: https://www.mongodb.com/docs/v4.0/core/index-ttl/
- El profiler de consultas lentas: https://www.mongodb.com/docs/v4.0/tutorial/manage-the-database-profiler/
- `$indexStats`: https://www.mongodb.com/docs/v4.0/reference/operator/aggregation/indexStats/
- Spring Data MongoDB 2.1 — `@Indexed` y la creación automática: https://docs.spring.io/spring-data/mongodb/docs/2.1.x/reference/html/#mapping-usage-indexes

> ⚠️ URLs y contenidos cambian; verifícalos. Y comprueba la versión: el límite de memoria de `SORT` y algunos valores por defecto se han movido entre versiones mayores.

---

## 🧪 Ejercicios (8)

Todos con medición **antes y después**. Un ejercicio de índices sin los dos números no enseña nada.

1. Lista los índices de las cinco colecciones antes de que `be03` cree ninguno. Anota cuántos hay en total y cuáles son.
2. Corre el `explain('executionStats')` de `findByDocumentId` sin índice. Anota los cuatro números y la proporción docs/devueltos.
3. Crea el índice, repite, y anota los cuatro números otra vez. Escribe la frase que le dirías a alguien que pregunte si valió la pena.
4. Enciende el profiler con `slowms: 0`, usa la aplicación cinco minutos, apágalo, y lista todas las consultas con `planSummary: COLLSCAN`. Esa lista es tu plan de trabajo.
5. Escribe la consulta de la timeline de auditoría —entidad, último mes, más recientes primero— y crea el índice por ESR. Comprueba que la etapa `SORT` desaparece del plan.
6. **Diagnóstico.** Crea un índice **parcial** con `{ active: true }` sobre `documentId` y comprueba que la consulta del validador **no lo usa**. Explica por qué, y después explica qué pasaría con los pacientes de las formas B y C de `be02`.
7. **Diagnóstico.** Intenta crear el índice único sobre `legacyId` en una colección donde hayas provocado duplicados (ejercicio 18 de `be03`). Lee el `E11000` entero y localiza el documento culpable.
8. **Diagnóstico + decisión.** Crea el índice sobre `referenceRanges` de la tabla del §8, mide antes y después sobre nueve documentos, y decide si lo dejas. Escribe la decisión y su razón: es el ejercicio de esta página que más se parece al trabajo real.

---

> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida y los índices que describe los crea **be03**, así que lo que salga de leerlo se commitea con el prefijo de la fase desde la que llegaste (`be02: …`, `be03: …`). Las mediciones de antes y después **no van en un tag**: van en `MEASUREMENTS.md`, porque `be08` las necesita para argumentar qué deudas se pagan y cuáles no. La convención completa está en [`00-convencion-de-git-y-tags.md`](./00-convencion-de-git-y-tags.md) §10.
