# 🕵️ Forense Fase 01 — "El dato está en la base y la consulta no lo encuentra"

> **Sale de:** [Fase 1 — Mongo en 30 minutos](01-mongo-en-30-min.md) ·
> **Herramientas:** `mongosh` sobre el documento crudo · **Recorrido:** cinco
> pasos
>
> **El síntoma, en una línea:** ves el documento en Compass y tu `find` devuelve
> vacío, sin ningún error.

En SQL, una consulta que no encuentra nada suele ser una consulta mal escrita, y
el motor te avisa si el nombre de la tabla o de la columna no existe. En Mongo
**no hay ese aviso**: una colección que no existe está vacía, un campo que no
existe es `null`, y una comparación entre tipos distintos simplemente no
coincide. Todo el silencio de esta pieza sale de ahí.

---

## 🎫 El ticket

> "El ticket está en la base, lo veo en Compass, tiene su `_id` y todo. Pero el
> script que hice para buscarlo por `_id` me devuelve vacío. Lo copié y pegué,
> no puede estar mal escrito."
>
> — un compañero migrando desde Oracle · **Ambiente:** local

Copiar y pegar el `_id` es exactamente lo que produce este bug, y es lo primero
que hace todo el mundo. La respuesta está en el paso 3.

---

## 🧭 La ruta

Del más barato al más caro: primero se comprueba dónde estás parado, después si
el documento existe, y solo entonces se discute el filtro.

### Paso 1 — ¿en qué base y en qué colección estás?

```js
> db
test
> show dbs
admin     41 kB
config    61 kB
local     41 kB
minijira  2.4 MB
```

**Qué descarta.** Descarta la mitad de los sustos de esta fase en dos líneas. Si
`db` dice `test`, no estás donde crees, y todo lo que consultes va a salir
vacío sin una sola queja. Es la primera pregunta y casi nadie se la hace.

### Paso 2 — ¿la colección se llama como tú crees?

```js
> use minijira
> show collections
comments
tickets
users
> db.tiket.countDocuments()
0
> db.tickets.countDocuments()
100
```

**Qué descarta.** Descarta el "se borraron los datos", que es como llega este
ticket la mitad de las veces. **Mongo no tiene el error "la tabla no existe":**
un typo crea el concepto de una colección fantasma que responde `0` con toda
naturalidad. En SQL esto habría sido un `ORA-00942`; acá es un cero.

### Paso 3 — ¿el valor que buscas es del tipo que está guardado?

Ahora sí, el caso del ticket. Mira el documento crudo, sin cliente gráfico de
por medio:

```js
> db.tickets.findOne({ title: /impresora/i })
{
  _id: ObjectId("5f8a1c2e4b3d2f0012a4e991"),
  title: 'La impresora no imprime',
  status: 'open',
  createdAt: ISODate('2020-03-10T10:00:00.000Z')
}
> db.tickets.find({ _id: "5f8a1c2e4b3d2f0012a4e991" }).count()
0
> db.tickets.find({ _id: ObjectId("5f8a1c2e4b3d2f0012a4e991") }).count()
1
```

**Qué descarta.** Cierra el caso y explica el silencio: un `_id` es un
**`ObjectId`**, no la cadena de 24 caracteres con la que se imprime. Comparar un
`ObjectId` con un string no es un error de tipos: es una comparación que da
`false`, y Mongo te devuelve el conjunto vacío que corresponde. Esa traducción
—string afuera, `ObjectId` adentro— es exactamente de lo que vive la capa API de
la [Fase 10](forense-fase-10.md), y es el origen del incidente de costura más
clásico del curso: *el frontend no muestra nada y `curl` sí devuelve los
tickets*.

### Paso 4 — la misma trampa, con fechas

El primo del caso anterior, y el que más tarda en aparecer:

```js
> db.tickets.findOne({}, { createdAt: 1 })
{ _id: ObjectId("…"), createdAt: '2020-03-10T10:00:00Z' }     // ⚠️ comillas
> db.tickets.find({ createdAt: { $gte: ISODate("2020-01-01") } }).count()
0
```

**Qué descarta.** Descarta el rango, que está bien escrito. Si `createdAt` se
guardó como **string** —porque así venía en el `db.json` heredado— comparar
contra un `ISODate` no coincide nunca. Lo traicionero es que a veces *parece*
funcionar: entre strings, el orden lexicográfico del ISO 8601 coincide con el
cronológico… hasta que llega una fecha sin zona, o con otro formato. Y el TTL de
la [Fase 7](forense-fase-07.md) sobre un campo string no borra nada y no avisa.

### Paso 5 — ¿o simplemente no está?

Si nada de lo anterior encaja, comprueba el supuesto de partida:

```js
> db.tickets.countDocuments()
0
> db.tickets.countDocuments({ status: "open" })
0
```

**Qué descarta.** Descarta el filtro y te manda a la siembra: si la colección
está vacía, el `npm run seed` falló, corrió contra otra base, o el contenedor se
recreó sin volumen —que es el caso de la [pieza de la Fase 0](forense-fase-00.md).
Comprobar el total antes de discutir un filtro cuesta un comando y evita
investigaciones enteras en la dirección equivocada.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| El `find` devuelve vacío y el documento está en Compass | Tipos: `ObjectId` contra string, o `Date` contra string |
| "Se borraron los datos" y la colección está intacta | Typo en el nombre: colecciones fantasma que responden 0 |
| Todo sale vacío, incluso lo que existe | Estás en otra base: mira `db` |
| Un rango de fechas devuelve cualquier cosa | Fechas guardadas como string |
| El orden por fecha pone los documentos donde no toca | Mezcla de tipos en el mismo campo: Mongo ordena entre tipos |
| `distinct` devuelve `null` entre los valores | Hay documentos sin el campo, y eso es un valor más |
| Recreaste el contenedor y no hay nada | Sin volumen no hay persistencia (Fase 0) |
| El seed "corrió bien" y la colección está vacía | Corrió contra otra base o contra otro puerto |

---

## ⚰️ Los callejones

**"Mongo perdió mi documento."** Prácticamente nunca. En esta fase, un documento
que "desaparece" está en otra base, en otra colección por un typo, o guardado
con un tipo distinto del que buscas. Antes de acusar al motor, cuenta: `db` →
`show collections` → `countDocuments()`. Son tres comandos y cierran el 90%.

**"Voy a poner un índice, seguro por eso no lo encuentra."** Un índice cambia la
velocidad, nunca el resultado. Si una consulta devuelve vacío, con índice
devolverá vacío más rápido. Confundir rendimiento con corrección es el error de
instinto más caro de este curso, y la [Fase 7](forense-fase-07.md) le dedica una
sección entera.

**"Le pongo `String(_id)` a todo y listo."** Convierte el bug en un problema de
datos: si empiezas a guardar `_id` como string pierdes el índice natural, el
orden temporal implícito del `ObjectId` y la compatibilidad con cualquier
herramienta. La traducción se hace **en la frontera** —la capa API de la Fase
10—, no en la base.

---

## 🧠 El patrón transferible

**En Mongo, "no existe" y "no coincide" se ven exactamente igual: un conjunto
vacío.** No hay error de tabla inexistente, ni de columna desconocida, ni de
tipos incompatibles. Eso obliga a un método distinto del que traes de SQL:
**antes de dudar del filtro, comprueba el terreno** —base, colección, total— y
solo después discute la condición.

Y la regla que se lleva uno a cualquier base sin esquema: **mira el documento
crudo antes que cualquier cosa que lo formatee.** Compass, un ODM o tu API te
enseñan una versión traducida del dato, y las comillas alrededor de una fecha
—o su ausencia— son justamente lo que se pierde en la traducción.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 1](01-mongo-en-30-min.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); el caso completo en el
[incidente 02](cuaderno-incidentes.md); y la versión con más filtros encima, en
la [pieza de la Fase 2](forense-fase-02.md).
