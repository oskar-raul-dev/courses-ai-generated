# 🕵️ Forense Fase 04 — "El validator rechaza un documento que a mí me parece correcto"

> **Sale de:** [Fase 4 — El esquema que no está en la base](04-el-esquema-que-no-esta-en-la-base.md)
> · **Herramientas:** `mongosh`, `db.getCollectionInfos()` y el error completo
> de la escritura · **Recorrido:** cuatro pasos
>
> **El síntoma, en una línea:** una escritura que siempre funcionó empieza a
> fallar, y el documento se ve bien.

Un validator es la primera pieza del Curso 02 que dice **que no**. Y decir que no
es exactamente lo que querías —para eso lo pusiste—, así que la investigación no
va sobre si el validator está roto, sino sobre **qué regla concreta se está
violando**, que el mensaje por defecto no cuenta.

---

## 🎫 El ticket

> "Desde ayer el script de carga falla. El documento que manda es idéntico al
> que cargamos toda la semana pasada, lo comparé campo por campo. El error solo
> dice 'Document failed validation'. No dice qué campo."
>
> — el compañero que mantiene los scripts de datos · **Ambiente:** desarrollo

"Es idéntico" suele ser cierto **a la vista**. Lo que casi nunca se compara es
el **tipo** de cada valor, y ahí está el caso más famoso de esta fase.

---

## 🧭 La ruta

Del más barato al más caro: primero se lee la regla, después se compara el
documento contra ella, y solo al final se discute si la regla debería existir.

### Paso 1 — ¿qué regla hay puesta, exactamente?

El validator no vive en tu código: vive en la colección.

```js
> db.getCollectionInfos({ name: "tickets" })[0].options
{
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: [ 'title', 'status', 'priority', 'createdAt' ],
      properties: {
        status: { enum: [ 'open', 'in_progress', 'resolved', 'closed' ] },
        schemaVersion: { bsonType: 'int' },
        createdAt: { bsonType: 'date' }
      }
    }
  },
  validationLevel: 'strict',
  validationAction: 'error'
}
```

**Qué descarta.** Descarta tu aplicación entera y te da el contrato en la mano.
Y contesta de paso una pregunta que la gente arrastra desde el ODM: **esto no es
el schema de Mongoose.** El de Mongoose valida dentro de tu proceso Node; éste
lo aplica el motor a **todos** los clientes — tu API, el script del compañero,
mongosh y la herramienta gráfica.

### Paso 2 — ¿qué tipo tiene de verdad el valor que mandas?

Con la regla delante, compara tipo por tipo, no valor por valor:

```js
> db.tickets.insertOne({ title: "Prueba", status: "open", priority: "high",
                         createdAt: new Date(), schemaVersion: 3 })
MongoServerError: Document failed validation
> typeof 3
'number'
> db.tickets.insertOne({ …, schemaVersion: NumberInt(3) })
{ acknowledged: true, insertedId: ObjectId("…") }
```

**Qué descarta.** Cierra el caso más clásico de la fase, el que se lleva una
hora y media de todo el mundo la primera vez: **JavaScript no tiene enteros**. El
driver manda `double` por defecto, y un `bsonType: "int"` lo rechaza aunque el
número sea `3` a la vista. Las salidas son dos, y son decisión de diseño:
mandar `NumberInt()` desde el cliente, o relajar la regla a `"number"`.

La misma trampa con otra ropa: `createdAt` como string ISO contra un
`bsonType: "date"`, que es el eco de la [Fase 1](forense-fase-01.md).

### Paso 3 — ¿y si el que falla es el seed?

Variante que descoloca, porque parece un fallo del curso:

```bash
npm run seed
```

```
MongoServerError: Document failed validation
```

**Qué descarta.** Descarta el validator como sospechoso y **le da la razón**. Si
el seed de la [Fase 1](forense-fase-01.md) no pasa la validación que acabas de
poner, la validación acaba de encontrarle un bug al seed: llevabas semanas
sembrando documentos que no cumplen tus propias invariantes. Es el resultado
correcto y el más incómodo, y por eso conviene decirlo en voz alta antes de que
alguien "arregle" el validator para que el seed vuelva a pasar.

### Paso 4 — ¿por qué entonces sí entró ese documento inválido?

El caso simétrico, y el que de verdad enseña la fase:

```js
> db.tickets.countDocuments({ status: { $nin: ["open","in_progress","resolved","closed"] } })
3
```

Con el validator puesto, y aun así hay tres documentos que lo violan.

```js
> db.getCollectionInfos({ name: "tickets" })[0].options.validationLevel
'moderate'
```

**Qué descarta.** Descarta que alguien haya "saltado" la validación. Con
`validationLevel: "moderate"`, el motor **solo valida los documentos que ya
cumplían**: los históricos rotos pueden seguir actualizándose sin pasar por el
aro. Es lo correcto para activar reglas sobre datos heredados sin romper la
operación, y es exactamente lo que hay que saber antes de prometerle a alguien
que "la base ya no acepta basura". Si el nivel es `strict` y aun así entró,
mira la fecha del documento: probablemente es anterior a la regla.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| `Document failed validation` sin más detalle | Lee la regla con `getCollectionInfos`, después compara tipos |
| Un número "obviamente entero" rechazado | El driver manda `double`: `NumberInt()` o relaja a `"number"` |
| Una fecha rechazada | Llega como string ISO contra un `bsonType: "date"` |
| El seed dejó de entrar | El validator le encontró un bug al seed: no lo relajes por reflejo |
| Documentos inválidos que siguen entrando | `validationLevel: "moderate"`, o son anteriores a la regla |
| Otro servicio escribió basura y nadie avisó | Ese servicio no pasa por tu ODM: el validator del motor sí los cubre |
| La migración corrió dos veces y duplicó datos | No era idempotente: el `--dry` existe por esto |
| El validator rechaza campos nuevos legítimos | `additionalProperties: false` con un modelo que evolucionó |

---

## ⚰️ Los callejones

**"El validator está roto, lo quito."** Es la reacción natural bajo presión y la
peor decisión posible: quitarlo no arregla el documento, solo apaga al único
testigo. Si hay que desbloquear la operación, el movimiento correcto es bajar el
`validationAction` a `warn` —que registra y deja pasar— y arreglar con calma.

**"Lo valido en Mongoose y listo."** Cubre a tu proceso Node y a nadie más. En
un sistema donde escriben la API, un script de migración y el compañero desde
mongosh, la única regla que aplica a todos es la del motor. Las dos capas no
compiten: la del ODM da mensajes buenos al usuario, la del motor garantiza la
invariante.

**"Le pongo todas las reglas de negocio."** Un validator que replica el negocio
entero se convierte en un despliegue cada vez que cambia una política. Al motor
van las **invariantes duras** —lo que jamás debe existir en la base—; lo que
cambia seguido va a la aplicación.

---

## 🧠 El patrón transferible

**La pregunta no es "¿hay esquema?" sino "¿quién lo hace cumplir, y sobre
quién?"** En tu motor relacional esas dos respuestas eran una sola —la base, para
todos— y por eso nunca hiciste la pregunta. Acá hay al menos tres candidatos con
alcances distintos: el ODM (tu proceso), el validator (todos los clientes) y los
scripts (nadie los vigila). Elegir mal no da error: da una garantía que crees
tener y no tienes.

Y el corolario para heredar una base ajena: **antes de confiar en un campo,
cuenta cuántos documentos lo violan.** El validator te dice qué debería haber;
solo un conteo te dice qué hay.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 4](04-el-esquema-que-no-esta-en-la-base.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); y la autopsia de lo que pasa cuando
nadie hizo esta pregunta durante años, en la
[pieza de la Fase 8](forense-fase-08.md).
