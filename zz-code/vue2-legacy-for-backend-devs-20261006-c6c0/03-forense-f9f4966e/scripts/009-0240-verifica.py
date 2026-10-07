# rescatado de la sesión f9f4966e, 2026-09-10T02:40:23Z · Stitch course 02 phases 05-08
import sys
sys.path.insert(0,'/private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/f9f4966e-40c6-443c-bf3d-e3e59987dc49/scratchpad')
from coser import coser
RES = "Esta fase aporta al [`cuaderno-incidentes.md`](cuaderno-incidentes.md) del curso:\n\n| ID | Título propuesto | Categoría | Dif. |\n|---|---|---|---|\n"

coser("05-lookup-y-por-que-es-una-alarma.md","forense-fase-05.md",
"""⭐ Aquí es donde el instinto SQL más se equivoca, y no por ignorancia: por
**exceso de confianza**. El `$lookup` se parece tanto a un JOIN que se usa igual,
y usarlo igual es el síntoma de un modelo diseñado como si fuera un esquema
relacional. El síntoma que llega es *"la pantalla funciona y es lenta"*, con una
lentitud que **crece con los datos, no con el código** — la firma de un problema
de modelo. Se depura contando viajes primero (los logs de la API), después con
`explain()` sobre el pipeline, y la pregunta del último paso es la que la fase
te obliga a hacerte: *¿esto debió embeberse?* Un `$lookup` no es un error; es
una alarma que pide justificar una decisión de modelado.""",
"""Cuenta los viajes antes de optimizar nada. Enciende el log de consultas y carga
la pantalla del listado una sola vez:

```js
db.setProfilingLevel(2)
// …carga la pantalla…
db.system.profile.find({ ns: /minijira/ }).count()
db.setProfilingLevel(0)
```

Si el número crece cuando hay más tickets en la página, tienes un N+1, y el
`$lookup` que ibas a escribir lo va a esconder, no a resolver.""",
RES + '| 05 | "El tablero tarda cuatro segundos y antes iba bien" | Modelado | 🟠 |')

coser("06-atomicidad-transacciones-consistencia.md","forense-fase-06.md",
"""⭐ La pieza donde el instinto relacional falla por una razón muy concreta: en tu
motor de siempre la transacción era gratis y la mitad de los frameworks la
ponían por defecto. Acá **no hay nada puesto**, y el bug no se ve nunca en
desarrollo, donde eres un solo usuario haciendo una cosa a la vez. Dos
operaciones que deberían excluirse tuvieron éxito las dos y ninguna dio error.
El recorrido empieza por lo que casi nadie mira —**qué devolvió cada escritura**,
`matchedCount` y `modifiedCount`— y sigue por el patrón culpable: el código
**lee y después escribe**, con una ventana entre las dos. La corrección no es
una transacción: es meter la precondición **dentro del filtro** de la
escritura.""",
"""Reproduce la carrera a voluntad, con dos sesiones de `mongosh` abiertas y el
mismo ticket:

```js
// en las dos, casi a la vez:
db.tickets.updateOne({ _id: id }, { $set: { assignee: "ana" } })
db.tickets.updateOne({ _id: id }, { $set: { assignee: "beto" } })
```

Las dos contestan `matchedCount: 1, modifiedCount: 1`. Las dos "ganaron", y el
ticket tiene un solo dueño. Ahora repítelo con la precondición dentro del filtro
—`{ _id: id, assignee: null }`— y mira qué contesta la segunda.""",
RES + '| 06 | "Dos agentes tomaron el mismo ticket" | Atomicidad | 🟠 |')

coser("07-indices.md","forense-fase-07.md",
"""Todo lo que sabes de índices en tu motor relacional sigue valiendo: selectividad,
prefijo izquierdo, el coste en las escrituras. Lo que cambia es la **herramienta
de diagnóstico y su capacidad de mentir** — por eso esta pieza es, sobre todo,
un curso de lectura de `explain()`. El síntoma típico es el más frustrante: *"el
índice está creado y `explain()` sigue diciendo COLLSCAN"*. Las causas suelen ser
tres, y ninguna es Mongo portándose mal: el índice compuesto no está en el orden
que la consulta necesita, la consulta no puede usarlo (un regex sin anclar, una
comparación entre tipos), o el índice se usa y la lentitud viene de otro sitio.
El paso 5 cierra con la pregunta honesta: *¿el problema es la consulta o el
modelo?* — un índice no arregla una decisión de forma.""",
"""Mide antes y después, que es lo único que convierte una opinión en un dato:

```js
db.tickets.find({ title: /impresora/ }).explain("executionStats").executionStats
// mira totalDocsExamined y nReturned, y anótalos
db.tickets.createIndex({ title: 1 })
db.tickets.find({ title: /impresora/ }).explain("executionStats").executionStats
```

Sigue en COLLSCAN, y el índice existe. Ancla ahora el regex (`/^impresora/`) y
vuelve a medir. Los tres números juntos son la explicación entera.""",
RES + '| 07 | "Creamos el índice y sigue igual de lento" | Índices | 🟠 |')

coser("08-la-autopsia.md","forense-fase-08.md",
"""Una migración es el único trabajo de este curso donde **el error se descubre
tarde y ya no hay origen al que volver**. Por eso la pieza no va sobre arreglar:
va sobre **verificar**, que es lo que nadie hace hasta la segunda vez que le
pasa. El síntoma es el peor de todos porque parece un éxito: la migración
terminó, los totales cuadran, y los datos no significan lo que dicen. Un conteo
igual no prueba nada —los documentos están, con los campos vacíos, con el tipo
cambiado o con el valor por defecto de todos—, así que la verificación es
**muestreo campo a campo**, más las dos preguntas que deciden si puedes dormir:
en qué orden se migró, y si el script se puede volver a correr sin duplicar.""",
"""Comprueba que el conteo miente, con el ejemplo más barato:

```js
db.tickets.countDocuments()                        // igual que el origen ✅
db.tickets.countDocuments({ priority: { $exists: false } })   // ¿cuántos perdieron el campo?
db.tickets.countDocuments({ createdAt: { $type: "string" } }) // ¿cuántos cambiaron de tipo?
```

Dos consultas de diez segundos que el conteo total nunca te iba a contar. Ésa es
la lista que se pega en el post-mortem.""",
RES + '| 08 | "La migración pasó el conteo y los reportes salen mal" | Modelado | 🟠 |')
