# rescatado de la sesión f9f4966e, 2026-09-10T02:39:25Z · Stitch course 02 phases 00, 01, 04
import sys
sys.path.insert(0,'/private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/f9f4966e-40c6-443c-bf3d-e3e59987dc49/scratchpad')
from coser import coser
RES = "Esta fase aporta al [`cuaderno-incidentes.md`](cuaderno-incidentes.md) del curso:\n\n| ID | Título propuesto | Categoría | Dif. |\n|---|---|---|---|\n"

coser("00-preliminares.md","forense-fase-00.md",
"""Lo que se rompe en esta fase no es Mongo: es el entorno que lo rodea, y se
diagnostica sin abrir un archivo de la aplicación. El contenedor dice que está
arriba y nadie logra conectarse — un puerto ocupado por otro Mongo instalado a
mano hace años, un volumen que no es el que crees, credenciales que el compose
declara y el cliente no manda. El reflejo que instala la pieza vale para
cualquier servicio en contenedor: **lee el log del arranque antes de googlear el
mensaje de error del cliente**, porque el cliente casi nunca sabe por qué no lo
dejaron entrar.""",
"""Provoca el choque de puertos a propósito, que es el caso que más veces vas a
vivir:

```bash
docker compose up -d          # con otro Mongo ya escuchando en 27017
docker compose logs mongo | tail -20
lsof -i :27017                # ¿quién tiene el puerto?
```

Compara lo que dice el cliente ("connection refused", "authentication failed")
con lo que dice el log del contenedor. No hablan del mismo suceso, y ésa es la
lección.""",
RES + '| 01 | "El contenedor está arriba y nadie conecta" | Operación | 🟢 |')

coser("01-mongo-en-30-min.md","forense-fase-01.md",
"""El silencio es la firma de esta fase: ves el documento en Compass y tu `find`
devuelve vacío, **sin ningún error**. En SQL el motor te avisa si la tabla o la
columna no existen; en Mongo no hay ese aviso — una colección que no existe está
vacía, un campo que no existe es `null`, y una comparación entre tipos distintos
simplemente no coincide. Por eso el recorrido empieza por lo aburrido y barato:
en qué base estás, cómo se llama de verdad la colección, y **qué tipo tiene lo
que hay guardado** frente a lo que buscas. El caso estrella es el `_id`: un
`ObjectId` no es la cadena con la que se imprime, y `find({ _id: "5f8a…" })`
devuelve el conjunto vacío que corresponde.""",
"""Comprueba el silencio con tus propios ojos, en `mongosh`:

```js
db.tickets.findOne()                                  // copia su _id
db.tickets.find({ _id: "<pega aquí el id como string>" }).count()   // 0
db.tikets.find().count()                              // 0, y la colección ni existe
```

Ningún error, dos veces. Anota cuánto habrías tardado en sospechar del tipo si
el segundo caso te llega en un ticket a las seis de la tarde.""",
RES + '| 02 | "El ticket está en la base y mi script no lo encuentra" | Consultas | 🟡 |')

coser("04-el-esquema-que-no-esta-en-la-base.md","forense-fase-04.md",
"""Un validator es la primera pieza del curso que **dice que no**, y decir que no
es justo lo que querías. Por eso la investigación no va sobre si el validator
está roto, sino sobre **qué regla concreta se está violando** — que es
exactamente lo que el mensaje por defecto no cuenta. El recorrido va del
`db.getCollectionInfos()` que te muestra la regla puesta al `typeof` del valor
que mandas, y termina en la pregunta que más desconcierta: *¿por qué entonces sí
entró ese documento inválido?* La respuesta —`validationLevel` y los documentos
que ya estaban— es la mitad de lo que hay que saber sobre validators en un
sistema heredado.""",
"""Pide el error completo, que es lo que casi nadie hace:

```js
try {
  db.tickets.insertOne({ title: "sin estado" });
} catch (e) {
  printjson(e.errInfo);      // ← acá está la regla que falló, no en e.message
}
```

Compáralo con lo que imprime `e.message` a secas. Un `Document failed
validation` no es un diagnóstico; `errInfo` sí.""",
RES + '| 04 | "Hay tickets que tardan diez veces más que los demás" | Modelado | 🟡 |')
