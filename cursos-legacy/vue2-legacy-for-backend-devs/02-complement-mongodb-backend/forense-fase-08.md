# 🕵️ Forense Fase 08 — "La migración pasó el conteo y los datos son basura"

> **Sale de:** [Fase 8 — La autopsia](08-la-autopsia.md) ·
> **Herramientas:** el muestreo campo a campo (no el conteo), `mongosh` y el
> cronómetro con condiciones iguales · **Recorrido:** cinco pasos
>
> **El síntoma, en una línea:** la migración terminó, los números cuadran, y los
> datos no significan lo que dicen.

Una migración es el único trabajo de este curso donde **el error se descubre
tarde y ya no hay origen al que volver**. Por eso la pieza no va sobre arreglar:
va sobre verificar, que es lo que nadie hace hasta la segunda vez que le pasa.

---

## 🎫 El ticket

> "La migración a `soporte_v2` terminó bien anoche, el reporte dice 100.000
> tickets migrados de 100.000. Pero el listado sale raro: hay tickets cerrados
> que aparecen como abiertos, y a varios les cambió el asignado. Los conteos por
> estado ahora no cuadran con los de la semana pasada."
>
> — el analista de reportes · **Ambiente:** la base migrada

Un reporte de conteos en verde y datos corridos es la firma de una verificación
que contó filas en vez de mirar contenido.

---

## 🧭 La ruta

Del más barato al más caro: comparar totales cuesta dos comandos, muestrear
cuesta cinco minutos, y rehacer la migración es el final del camino, no el
principio.

### Paso 1 — ¿los totales cuadran de verdad?

```js
> use soporte_v1
> db.tickets.countDocuments()
100000
> use soporte_v2
> db.tickets.countDocuments()
100000
```

**Qué descarta.** Descarta la pérdida de documentos y **nada más**. Es
importante decirlo así, porque este paso es donde la mayoría de las migraciones
declaran victoria: un conteo igual demuestra que hay la misma cantidad de cosas,
no que sean las mismas cosas. Sigue al paso 2 sin celebrar.

### Paso 2 — muestreo campo a campo

Toma documentos concretos de los dos lados y compáralos:

```js
> var sample = db.getSiblingDB("soporte_v1").tickets.find().limit(5).toArray()
> sample.map(function (t) { return { id: t.ticket_id, status: t.status_id, who: t.assignee_id }; })
[ { id: 1, status: 4, who: 12 }, { id: 2, status: 1, who: null }, … ]

> db.tickets.find({ legacyId: { $in: [1, 2] } }, { legacyId: 1, status: 1, assignee: 1 }).toArray()
[ { legacyId: 1, status: 'open',   assignee: 'ana' },
  { legacyId: 2, status: 'closed', assignee: null } ]
```

**Qué descarta.** Ahí está el caso: el ticket 1 era `status_id: 4` y quedó como
`open`; el 2 era `1` y quedó `closed`. **El mapa de estados está corrido una
posición** — el clásico off-by-one de todo diccionario de traducción, casi
siempre por indexar un arreglo desde 0 cuando los ids del origen empiezan en 1.
Los conteos globales por estado pueden incluso coincidir si el corrimiento es
uniforme, que es lo que hace este bug tan difícil de ver desde arriba.

### Paso 3 — ¿en qué orden se migró?

Si además hay referencias que no resuelven:

```js
> db.tickets.countDocuments({ assignee: null })
41210
> db.getSiblingDB("soporte_v1").tickets.countDocuments({ assignee_id: null })
7
```

**Qué descarta.** Descarta el mapa de estados y apunta al **orden de ejecución**:
si `tickets` se migró antes que `users`, el script no tenía todavía el mapa de
traducción `user_id → username` y resolvió a `null` sin quejarse. Por eso la
fase migra usuarios primero y no por gusto: **las referencias se resuelven contra
algo que ya existe, o no se resuelven.**

### Paso 4 — ¿se puede volver a correr?

Antes de arreglar nada, comprueba con qué herramienta cuentas:

```bash
node scripts/migrate-02-tickets.js --dry
```

```
[dry] 100000 documentos serían insertados en soporte_v2.tickets
[dry] 0 actualizaciones
```

**Qué descarta.** Descarta —o confirma— la posibilidad de repetir. Un script
idempotente se puede volver a correr sobre el resultado anterior sin duplicar ni
corromper; uno que no lo es, te obliga a limpiar y empezar de cero, y en un
sistema real eso significa otra ventana de mantenimiento. Si el `--dry` de una
segunda corrida anuncia 100.000 inserciones nuevas en vez de actualizaciones, no
es idempotente y ése es el primer arreglo, antes que el mapa de estados.

### Paso 5 — la re-medición que cierra la autopsia

Con los datos ya correctos, el último paso es el que le da sentido al trabajo:

```js
> db.tickets.find({ status: "open" }).sort({ createdAt: -1 }).limit(20)
    .explain("executionStats").executionStats.executionTimeMillis
3
```

**Qué descarta.** Descarta las opiniones. La tabla de la autopsia —la misma
operación medida en v1 crudo, v1 indexado y v2— es lo que convierte "el modelo
nuevo es mejor" en una afirmación defendible. Con una condición que hay que
vigilar: **las tres mediciones tienen que hacerse en las mismas condiciones**;
una con caché caliente y otra con caché fría produce una mejora que no existe, y
es la forma más común de mentir sin querer en un informe.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| Conteos iguales y datos incorrectos | Verificaste cantidad, no contenido: muestrea campo a campo |
| Un campo enumerado corrido una posición | El mapa de traducción y su índice de origen |
| Referencias que quedaron en `null` | Orden de migración: los referenciados van primero |
| Correr el script dos veces duplicó datos | No es idempotente: `--dry` y `upsert` por clave estable |
| El proceso se queda sin memoria | Se cargó todo en memoria: cursor y lotes |
| La mejora medida no se nota en producción | Caché caliente en una medición y fría en la otra |
| El informe solo trae mejoras | Falta lo que empeoró: sin eso no es un informe, es una venta |
| No sabes a qué modelo migrar | El diagnóstico no está cerrado: migrar sin destino es el pecado original |

---

## ⚰️ Los callejones

**"Los conteos cuadran, la migración está bien."** Es el callejón que produce
este ticket. Cien mil documentos con el `status` corrido pasan cualquier
verificación por cantidad y son basura. La verificación por muestreo cuesta
cinco minutos y es la diferencia entre descubrirlo hoy o descubrirlo cuando
alguien tome una decisión con esos reportes.

**"Lo arreglo con un `updateMany` rápido."** A veces es exactamente eso, pero
solo si sabes con precisión qué documentos están mal y por qué. Un `updateMany`
sobre datos que ya fueron transformados una vez —y quizá dos, si el script corrió
dos veces— puede corregir unos y romper otros. Primero el diagnóstico, después el
bisturí.

**"Migrar a Mongo hizo esto más lento, entonces Mongo es peor."** Puede ser
cierto y hay que estar dispuesto a escribirlo — el informe honesto incluye lo que
empeoró. Pero antes comprueba qué mediste: `soporte_v1` era un esquema relacional
guardado en Mongo, y comparar contra él no dice nada sobre Mongo; dice sobre el
modelo. Esa distinción es el corazón del curso.

---

## 🧠 El patrón transferible

**Verificar una migración por conteo es contar cajas sin abrirlas.** El número de
documentos es la propiedad más fácil de preservar y la que menos información
aporta: casi cualquier bug de transformación la respeta. Lo que hay que
comparar es contenido, y no hace falta comparar todo — un muestreo de veinte
documentos elegidos por los extremos (el más viejo, el más nuevo, los que tenían
campos nulos, los que tenían referencias rotas) encuentra el 90% de los errores.

Y la disciplina que sostiene todo lo demás: **un script de migración es código de
producción**, con dry-run, idempotencia y verificación propia. La diferencia con
el resto de tu código es que este se ejecuta una vez, de noche, con todo el
mundo esperando — que es justo cuando peor se improvisa.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 8](08-la-autopsia.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); el caso completo en el
[incidente 08](cuaderno-incidentes.md); y el modelo que originó todo esto, en la
[pieza de la Fase 5](forense-fase-05.md).
