# 📎 Apéndice bea-04 — Agregaciones como instrumento de medida

> Tutorial Angular 8 — Laboratorio clínico · 🔥 Track BE · Consulta rápida · **4 horas**
> Usado por: be02 sobre todo; de consulta suelta desde be05 y be06 · Versiones cubiertas: MongoDB 4.0, con las diferencias que traen 4.4, 6.0 y 7.0

**Esto no se lee de corrido.** Se entra buscando el operador que hace falta para contestar una pregunta sobre los datos, y se sale con el pipeline escrito.

> 🧭 **El ángulo de este apéndice, que lo separa de cualquier tutorial de MongoDB:** aquí las agregaciones **no son la API de consulta del sistema**. LabCore no las usa para servir ni una pantalla: sirve con repositorios de Spring Data y punto. Las agregaciones son el **instrumento con el que se descubre qué hay guardado de verdad** — el equivalente a un multímetro, no a un cable.
>
> Si al terminar este apéndice pudieras resumirlo como *"aquí se explica el aggregation framework"*, estaría mal escrito.

**Qué queda fuera:** `$graphLookup`, funciones de ventana, colecciones de series temporales, y todo lo que llegó después de la 4.0 salvo como nota 🔥 — porque el sistema de 2019 no lo tenía y porque escribir una medición con un operador que tu base no entiende es perder una tarde. También queda fuera servir datos con agregaciones, que es lo que hace todo el mundo y aquí no se hace.

---

## Índice

- [1. Medir no es consultar](#1-medir-no-es-consultar)
- [2. El pipeline: las seis etapas que vas a usar](#2-el-pipeline-las-seis-etapas-que-vas-a-usar)
- [3. `$objectToArray` sobre `$$ROOT`: la técnica central](#3-objecttoarray-sobre-root-la-técnica-central)
- [4. Contar formas, no campos](#4-contar-formas-no-campos)
- [5. `$type`: el campo que es dos cosas](#5-type-el-campo-que-es-dos-cosas)
- [6. `$lookup` para encontrar lo que falta](#6-lookup-para-encontrar-lo-que-falta)
- [7. `$facet`: varias mediciones en una pasada](#7-facet-varias-mediciones-en-una-pasada)
- [8. Sacar el resultado a un informe](#8-sacar-el-resultado-a-un-informe)
- [9. 🗓️ Qué operador existe en qué versión](#9-️-qué-operador-existe-en-qué-versión)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-9)

---

## 1. Medir no es consultar

La diferencia gobierna todo lo demás, así que conviene tenerla explícita:

| | Consultar | **Medir** |
|---|---|---|
| Quién lee el resultado | un usuario, una pantalla | **tú**, y un archivo de mediciones |
| Con qué frecuencia corre | miles de veces al día | una vez, o una vez al mes |
| Qué importa | latencia, índices, plan | **exactitud y reproducibilidad** |
| Qué pasa si tarda 40 s | es un incidente | **no pasa nada** |
| Qué pasa si el número es aproximado | nadie se entera | **el informe no vale** |

De ahí salen tres reglas de método que vas a ver aplicadas en todo el track:

1. **Se puede ser lento.** Un `COLLSCAN` sobre la colección entera está perfectamente bien en una medición. No optimices lo que vas a correr una vez.
2. **El pipeline se guarda entero, copiable.** En `MEASUREMENTS.md`, junto al número y a la fecha. Una medición cuyo pipeline no se puede volver a ejecutar no es una medición: es un recuerdo.
3. **Se mide sobre una base que nadie está escribiendo.** Por eso el volcado sucio de [`bea-12`](./bea-12-datos-de-prueba-y-volumen.md) vive en `labcore_prod_sample` y no en la base de la aplicación. Un número medido mientras alguien escribe es irreproducible por construcción.

---

## 2. El pipeline: las seis etapas que vas a usar

Una agregación es una lista de etapas; cada una recibe documentos y emite documentos.

```javascript
db.patients.aggregate([
  { $match:   { … } },   // filtrar. Lo primero, siempre que se pueda
  { $project: { … } },   // quedarse con lo que importa, o calcular algo
  { $unwind:  '$campo' },// un documento por elemento del arreglo
  { $group:   { … } },   // agrupar y contar
  { $sort:    { … } },   // ordenar
  { $limit:   5 }        // cortar
]);
```

Eso es el 95 % de lo que hace falta para medir. Tres notas que ahorran tiempo:

- **`$match` lo primero.** No porque el optimizador no lo mueva a veces, sino porque escribirlo primero te obliga a decidir qué población estás midiendo, que es la decisión que más veces sale mal.
- **`$group` con `_id: null`** agrupa todo en un solo resultado. Es como se sacan totales.
- **`$unwind` multiplica documentos**, y ese es exactamente su valor: convierte elementos de un arreglo en filas que se pueden contar.

```javascript
// Plantilla de conteo, que sirve para el 70 % de las preguntas:
{ $group: { _id: '$loQueQuieroAgrupar', n: { $sum: 1 } } },
{ $sort:  { n: -1 } }
```

---

## 3. `$objectToArray` sobre `$$ROOT`: la técnica central

La llave maestra del track, y la que casi nadie conoce.

`$objectToArray` convierte un documento en un arreglo de pares `{k, v}`. Aplicado a `$$ROOT` —el documento entero— convierte **los nombres de los campos en datos**, y eso es precisamente lo que hace falta cuando el problema es que no sabes qué campos hay.

```javascript
// Qué claves existen de verdad en esta colección, y con qué frecuencia.
// Es el equivalente de INFORMATION_SCHEMA, y funciona sobre CUALQUIER
// colección sin saber nada de ella de antemano.
db.patients.aggregate([
  { $project: { pairs: { $objectToArray: '$$ROOT' } } },
  { $unwind: '$pairs' },
  { $group: { _id: '$pairs.k', apariciones: { $sum: 1 } } },
  { $sort: { apariciones: -1 } }
]);
```

Paso a paso, porque merece entenderse y no copiarse:

1. `$objectToArray: '$$ROOT'` → `[{k:"_id",v:…}, {k:"documentId",v:"CC-10…"}, …]`
2. `$unwind` → un documento por cada **clave** del original
3. `$group` por `pairs.k` → una fila por nombre de campo, con su recuento

Lo que hay que saber de sus límites, porque los dos muerden:

> ⚠️ **Solo abre el primer nivel.** Un subdocumento aparece como una clave más (`contact`) y sus claves internas no se ven. Para bajar un nivel hay que volver a aplicarlo:
>
> ```javascript
> db.patients.aggregate([
>   { $match: { contact: { $exists: true } } },
>   { $project: { pairs: { $objectToArray: '$contact' } } },
>   { $unwind: '$pairs' },
>   { $group: { _id: '$pairs.k', apariciones: { $sum: 1 } } }
> ]);
> ```
>
> No hay una versión recursiva en 4.0. Si necesitas inventariar un árbol profundo, es un bucle en el cliente.

> ⚠️ **Falla si `$$ROOT` no es un objeto**, cosa que no pasa con documentos de nivel superior pero sí si lo aplicas sobre un campo que a veces es un objeto y a veces una cadena. Fíltralo antes con `$type`.

Dos variantes que salen mucho:

```javascript
// Los valores distintos que toma un campo, con su recuento. Para campos de
// estado, de tipo o de origen, dice más que cualquier documentación.
db.orders.aggregate([
  { $group: { _id: '$status', n: { $sum: 1 } } },
  { $sort: { n: -1 } }
]);

// Cuántas claves tiene cada documento. Una distribución con dos picos es una
// deriva de esquema antes de que la hayas buscado.
db.patients.aggregate([
  { $project: { n: { $size: { $objectToArray: '$$ROOT' } } } },
  { $group: { _id: '$n', documentos: { $sum: 1 } } },
  { $sort: { _id: 1 } }
]);
```

---

## 4. Contar formas, no campos

Saber qué claves existen no es saber cuántas **formas** hay. Para eso se agrupa por el conjunto de claves de cada documento, y ahí aparece un detalle que estropea la medición si no lo conoces.

> 🧠 **En BSON, las claves de un documento están ordenadas por inserción y ese orden se conserva.** Así que `{a, b}` y `{b, a}` son arreglos distintos, y un `$group` ingenuo los contaría como dos formas. Si tu conteo da veintitantas formas donde esperabas cinco, es esto.

```javascript
// Formas canónicas: se ordenan las claves alfabéticamente antes de agrupar.
// El $unwind + $sort + $group intermedio es la forma de hacerlo en 4.0, donde
// $sortArray todavía no existe (llega en 5.2).
db.patients.aggregate([
  { $project: { pairs: { $objectToArray: '$$ROOT' } } },
  { $unwind: '$pairs' },
  { $sort: { '_id': 1, 'pairs.k': 1 } },
  { $group: { _id: '$_id', claves: { $push: '$pairs.k' } } },
  { $group: { _id: '$claves', documentos: { $sum: 1 } } },
  { $sort: { documentos: -1 } }
]);
```

```javascript
// 🔥 Desde MongoDB 5.2, lo mismo en una línea menos. NO funciona en el
// mongo:4.0 de LabCore, y por eso el track usa la versión de arriba.
{ $project: { claves: { $sortArray: {
    input: { $map: { input: { $objectToArray: '$$ROOT' }, in: '$$this.k' } },
    sortBy: 1 } } } }
```

> 💡 **Truco para colecciones grandes:** añade `{ $sample: { size: 10000 } }` al principio y mide sobre una muestra. Para **descubrir** formas es suficiente y es mucho más rápido; para **contarlas** no vale, porque los números dejan de ser exactos. Descubre con muestra, cuenta sin ella.

---

## 5. `$type`: el campo que es dos cosas

```javascript
// Ojo: hay DOS $type y hacen cosas distintas.
//
// 1. Operador de CONSULTA: filtra por tipo.
db.patients.find({ birthDate: { $type: 'string' } });

// 2. Operador de AGREGACIÓN: devuelve el tipo como un valor.
db.patients.aggregate([
  { $group: { _id: { $type: '$birthDate' }, documentos: { $sum: 1 } } },
  { $sort: { documentos: -1 } }
]);
```

El segundo es el que descubre el campo camaleón. Y los tres tipos que más importan en una base con años encima:

| Devuelve | Significa |
|---|---|
| `"missing"` | **El campo no existe.** No es lo mismo que `null` |
| `"null"` | Existe y vale `null` |
| `"string"` / `"int"` / `"double"` / `"date"` / `"bool"` | Lo que parece |

> 🧠 **Que `"missing"` sea un valor devuelto por `$type` es lo que hace posible medir la diferencia entre ausente y nulo**, que en el lenguaje de consulta se confunden: `{ campo: null }` casa con los dos. Es la pieza forense de `be02` §5.6 y la trampa más productiva de MongoDB.

```javascript
// Auditoría de tipos de TODOS los campos de una colección, en un solo
// pipeline. Es la medición más completa de este apéndice y la que conviene
// correr la primera vez que abres una colección ajena.
db.patients.aggregate([
  { $project: { pairs: { $objectToArray: '$$ROOT' } } },
  { $unwind: '$pairs' },
  { $group: { _id: { campo: '$pairs.k', tipo: { $type: '$pairs.v' } },
              n: { $sum: 1 } } },
  { $sort: { '_id.campo': 1, n: -1 } }
]);
```

Un campo que aparece con dos tipos distintos en esa salida es siempre una historia: una migración a medias, dos clientes escribiendo, o un cambio de código que nadie aplicó hacia atrás.

---

## 6. `$lookup` para encontrar lo que falta

La forma correlacionada, que es la que hace falta cuando el cruce no es una igualdad simple:

```javascript
// Forma simple: igualdad entre dos campos.
{ $lookup: { from: 'patients', localField: 'patientId',
             foreignField: 'legacyId', as: 'patient' } },
{ $match: { patient: { $size: 0 } } }       // <- los rotos

// Forma con pipeline (desde 3.6): permite condiciones compuestas, rangos y
// ventanas de tiempo. Es la de la medición de divergencia de be04 §5.6.
{ $lookup: {
    from: 'auditLog',
    let: { entidad: '$entityId', momento: '$timestamp' },
    pipeline: [
      { $match: { $expr: { $and: [
          { $eq: ['$entityId', '$$entidad'] },
          { $lt: [ { $abs: { $subtract: [ '$$momento', { $toDate: '$timestamp' } ] } },
                   120000 ] }
      ]}}}
    ],
    as: 'delCliente'
}}
```

Tres cosas que hay que vigilar siempre y que producen resultados silenciosamente falsos:

- **`$$` es para variables, `$` para campos.** `'$$entidad'` es la variable declarada en `let`; `'$entityId'` es el campo del documento de la colección cruzada. Confundirlos no da error: da vacío.
- **Los tipos tienen que coincidir.** Un entero contra una cadena no casa y no avisa. **Mide el `$type` de los dos campos antes de creerte cualquier cruce**, siempre.
- **Sin índice en `foreignField`, esto es cuadrático.** En una medición puntual da igual; en una que corre sobre el volumen ×10 de `bea-12`, no. Ver [`bea-05`](./bea-05-indices-y-explain-en-mongodb.md).

---

## 7. `$facet`: varias mediciones en una pasada

```javascript
// Tres mediciones distintas sobre la MISMA lectura de la colección. Cada
// rama es un pipeline independiente y el resultado es un solo documento con
// las tres respuestas.
db.patients.aggregate([
  { $facet: {
      porTipoDeFecha: [
        { $group: { _id: { $type: '$birthDate' }, n: { $sum: 1 } } }
      ],
      vaciosDeCorreo: [
        { $group: { _id: null,
            ausente: { $sum: { $cond: [ { $eq: [ { $type: '$email' }, 'missing' ] }, 1, 0 ] } },
            nulo:    { $sum: { $cond: [ { $eq: [ { $type: '$email' }, 'null' ] }, 1, 0 ] } },
            vacio:   { $sum: { $cond: [ { $eq: [ '$email', '' ] }, 1, 0 ] } }
        }}
      ],
      total: [ { $count: 'documentos' } ]
  }}
]);
```

Cuándo vale la pena y cuándo no:

- **Sí**, cuando las mediciones van juntas a un informe y quieres que sean **de la misma foto**. Tres agregaciones separadas sobre una base viva pueden dar números de tres instantes distintos, y entonces no suman.
- **No**, si estás explorando. Un `$facet` es más difícil de depurar que tres consultas: si una rama falla, falla todo y el mensaje no siempre dice cuál.

> ⚠️ **`$facet` tiene el límite de 16 MB por documento de resultado**, como cualquier documento. Una rama que devuelva miles de filas lo revienta. Cada rama debe terminar en un `$group`, un `$count` o un `$limit`.

---

## 8. Sacar el resultado a un informe

Una medición que se queda en la terminal no sirve para nada. Tres formas, de menos a más:

```bash
# 1. A un archivo, con la salida cruda. Lo que se pega en MEASUREMENTS.md.
docker compose exec -T db mongosh labcore_prod_sample --quiet \
  --eval 'db.patients.aggregate([...]).toArray()' > mediciones/m02-claves.json

# 2. A CSV, para una hoja de cálculo o un gráfico. mongoexport acepta una
#    consulta pero NO una agregación: el camino es volcar el resultado a una
#    colección temporal con $out y exportar esa.
docker compose exec -T db mongosh labcore_prod_sample --quiet --eval '
  db.patients.aggregate([ …, { $out: "tmp_formas" } ])'
docker compose exec -T db mongoexport --db labcore_prod_sample \
  --collection tmp_formas --type=csv --fields=_id,documentos > mediciones/formas.csv

# 3. Y la forma de que no se te olvide de dónde salió: un guion por medición,
#    versionado, con el número esperado adentro. Es lo que hace verify-dump.sh
#    en bea-12, y es lo que convierte una medición en algo repetible.
```

> ⚠️ **`$out` reemplaza la colección de destino entera** y desde 4.2 existe `$merge`, que permite combinar. En 4.0 solo hay `$out`: usa siempre un nombre `tmp_` y bórralo, o acabarás pisando algo.

---

## 9. 🗓️ Qué operador existe en qué versión

La tabla que evita la tarde perdida. LabCore arranca en **4.0** y termina en **7.0** (`be07`), así que a mitad del track algunos de estos aparecen.

| Operador | Desde | Nota |
|---|---|---|
| `$objectToArray`, `$arrayToObject` | 3.4 | La técnica central del track |
| `$type` (agregación), `$facet`, `$graphLookup` | 3.4 | |
| `$lookup` con `let` y `pipeline` | 3.6 | La forma correlacionada de `be04` |
| `$expr` dentro de `$match` | 3.6 | Comparar dos campos del mismo documento |
| `$convert`, `$toDate`, `$toLong`, `$toString` | **4.0** | El mínimo del track. En 3.6 no están |
| `$merge` | 4.2 | En 4.0 solo hay `$out` |
| `$bsonSize`, `$unionWith`, `$function`, `$accumulator` | 4.4 | ⚠️ **No existen en el `mongo:4.0` de LabCore** |
| `$setWindowFields` | 5.0 | Funciones de ventana |
| `$sortArray`, `$getField` | 5.2 | Por eso el §"Contar formas" usa el camino largo |

> 🧠 **Y la consecuencia de método, que es de `be07`:** una medición escrita hoy sobre 7.0 puede no correr sobre la base de un compañero que todavía esté en 4.0, y al revés, una medición de 4.0 corre en 7.0 pero puede no ser la forma que hoy escribirías. **Anota la versión al lado de cada pipeline en `MEASUREMENTS.md`**; es una línea y evita discusiones.

---

## 🧭 Cuándo usar qué

| Pregunta | Herramienta |
|---|---|
| ¿Qué campos existen de verdad? | `$objectToArray` + `$unwind` + `$group` |
| ¿Cuántas formas distintas hay? | El mismo, con el `$sort` que canoniza el orden |
| ¿Este campo siempre es del mismo tipo? | `$type` como operador de agregación |
| ¿Ausente, `null` o vacío? | `$type` → `"missing"` / `"null"`, y `$eq: ''` |
| ¿Hay referencias rotas? | `$lookup` + `$match: { as: { $size: 0 } }` |
| ¿Cuántos de cada valor? | `$group` por el campo + `$sort` |
| Varias mediciones de la misma foto | `$facet` |
| Explorar una colección enorme | `$sample` primero, y contar después sin él |
| Sacarlo a un informe | `$out` a una temporal + `mongoexport` |
| Saber si la consulta usó índice | **No es aquí**: [`bea-05`](./bea-05-indices-y-explain-en-mongodb.md) |

---

## ⚠️ Advertencias

**La documentación en línea es la de la versión actual.** Es el riesgo número uno de este apéndice: un operador que "existe según la web" puede no existir en tu base, y el error que devuelve no siempre lo dice claro —a veces es `Unrecognized expression`, que ayuda, y a veces es un resultado vacío, que no—. **Cita siempre la URL con la versión adentro** (`/docs/v4.0/…`).

**El shell cambió de nombre.** `mongo` hasta 4.4, `mongosh` desde 6.0. Todas las mediciones que escribas en `be02`, `be05` y `be06` están escritas para uno de los dos, y `be07` las rompe todas de golpe. No es un detalle: es un capítulo entero.

**Una agregación no es una consulta congelada.** Sin un `$sort` explícito, el orden del resultado no está garantizado y puede cambiar entre versiones o entre ejecuciones. Para una medición que solo cuenta da igual; para una que lista documentos y que alguien va a comparar contra la de la semana pasada, **el `$sort` es obligatorio**.

**Y la más importante: una agregación te dice qué hay, no por qué.** Los 718 documentos con `name` en vez de `fullName` son un hecho medido; que vengan de una importación de 2020 es una **hipótesis** que hay que sostener con otra evidencia. `MEASUREMENTS.md` guarda lo primero; lo segundo va en columna aparte y con su método, que es la regla de `be06` §5.4.

---

## 📚 Referencias

- MongoDB 4.0 — el framework de agregación completo: https://www.mongodb.com/docs/v4.0/aggregation/
- Referencia de etapas del pipeline, versión 4.0: https://www.mongodb.com/docs/v4.0/reference/operator/aggregation-pipeline/
- `$objectToArray`: https://www.mongodb.com/docs/v4.0/reference/operator/aggregation/objectToArray/
- `$type` de agregación y la lista de valores que devuelve, incluido `"missing"`: https://www.mongodb.com/docs/v4.0/reference/operator/aggregation/type/
- `$lookup`, con la forma correlacionada de `let` + `pipeline`: https://www.mongodb.com/docs/v4.0/reference/operator/aggregation/lookup/
- `$facet`: https://www.mongodb.com/docs/v4.0/reference/operator/aggregation/facet/
- Orden de comparación entre tipos BSON, que explica varios resultados sorprendentes: https://www.mongodb.com/docs/v4.0/reference/bson-type-comparison-order/
- `mongoexport`: https://www.mongodb.com/docs/database-tools/mongoexport/
- Notas de versión de 4.2, 4.4, 5.0, 6.0 y 7.0, para comprobar cuándo entró cada operador: https://www.mongodb.com/docs/manual/release-notes/

> ⚠️ URLs y contenidos cambian. Y aquí, más que en ningún otro apéndice: comprueba la versión de la documentación **antes** de copiar un operador.

---

## 🧪 Ejercicios (9)

Todos sobre el volcado sucio de [`bea-12`](./bea-12-datos-de-prueba-y-volumen.md), en `labcore_prod_sample`.

1. Corre el inventario de claves sobre `patients` y reproduce la tabla de `be02` §5.2. Confirma los nueve recuentos.
2. Corre el mismo inventario sobre `orders`, `samples` y `results`. Anota qué colección tiene menos deriva y por qué crees que es.
3. Baja un nivel: inventaría las claves **dentro** de `contact` y anota cuántas variantes tiene ese subdocumento.
4. Corre la auditoría de tipos completa (campo × tipo) sobre `patients`. Señala todos los campos que aparecen con más de un tipo.
5. Cuenta las formas **sin** el `$sort` que canoniza el orden de claves y **con** él. Anota los dos números y explica la diferencia.
6. Escribe con `$facet` las tres mediciones de vacíos de correo en una sola pasada y confirma que dan 1.630 / 906 / 247.
7. **Diagnóstico.** Escribe un `$lookup` correlacionado y equivócate a propósito poniendo `$` donde va `$$`. Anota qué devuelve y por qué no hay error.
8. Exporta el conteo de formas a CSV con `$out` + `mongoexport`, y ábrelo en una hoja de cálculo. Acuérdate de borrar la colección temporal.
9. **Diagnóstico.** Intenta usar `$bsonSize` sobre `mongo:4.0`. Anota el error exacto. Después sube la base a `MONGO_TAG=7.0`, repítelo, y anota que ahora funciona. Escribe en dos líneas qué implica eso para una medición que quieras poder repetir dentro de un año.

---

> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida y las mediciones que describe las produce **be02**, así que lo que salga de leerlo se commitea con el prefijo de la fase desde la que llegaste (`be02: …`, `be05: …`, `be06: …`). Los pipelines que valgan la pena no van en un tag: van en `MEASUREMENTS.md`, con su número, su fecha y su versión de base, que es donde `be08` los va a buscar. La convención completa está en [`00-convencion-de-git-y-tags.md`](./00-convencion-de-git-y-tags.md) §10.
