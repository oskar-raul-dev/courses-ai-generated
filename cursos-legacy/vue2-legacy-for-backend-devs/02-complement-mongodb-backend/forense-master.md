# 🕵️ Track forense — índice y método
## Curso 02 · MongoDB para cerebros SQL — el backend de Mini Jira

> Puerta de entrada del track. Cubre las doce piezas escritas,
> más las candidatas que §2 nombra.

Ésta es la puerta. Nadie llega a una investigación sabiendo de qué fase es su problema:
llega con un síntoma, y en este curso además llega con un instinto —el relacional— que a
veces acierta y a veces lo manda al sitio equivocado. Por eso el índice que de verdad
importa acá no es el de fases (§2), sino el de **síntomas** (§3).

El track no es material adicional: es el desarrollo de la sección 6 que cada fase ya trae.
La fase te dice **qué** se rompe; la pieza te enseña **en qué orden mirar**.

---

## 1. El método: cuatro preguntas, siempre en este orden

El orden no es una preferencia. Es que cada pregunta cuesta un orden de magnitud más que
la anterior, y contestar la barata primero descarta la mitad de las caras.

**Pregunta 1 — ¿se reproduce, y con qué?** ¿Con **otro dato** —un seed alterno, un
documento sin el campo—, con **más volumen** —porque a 50 documentos todo es rápido—, o
hace falta **otro código**? En este curso la variante de volumen es propia y decisiva: la
mitad de los bugs del modelado no existen hasta que hay datos de verdad.

**Pregunta 2 — ¿qué dice la evidencia observable, antes que el código?** El documento
crudo en mongosh, el `explain()` con su `totalDocsExamined`, la línea de morgan que no
apareció, el `matchedCount` de un update. Casi todas las rutas se resuelven acá, y ninguna
requiere abrir un archivo del proyecto. **El código es el paso 4, no el paso 1.**

**Pregunta 3 — ¿en qué capa está?** Ruta, controller, service o el propio Mongo. Y una
distinción que este curso agrega y que no existe en un backend relacional: ¿el problema
está en la **consulta** o en el **modelo**? Afinar índices sobre un modelo mal diseñado es
la forma más cara de no arreglar nada, y la Fase 7 lo dice con todas las letras.

**Pregunta 4 — ¿de qué lado de la frontera está?** La frontera es
[`00-audit-contrato.md`](00-audit-contrato.md). El `_id` que la base guarda como `ObjectId`
y la API sirve como `id` string, la fecha que es `Date` adentro e ISO afuera, el evento de
socket que tiene que llevar la misma forma que la respuesta HTTP. Un síntoma que aparece
solo cuando mira el frontend casi siempre vive en esa costura, no en Mongo.

> 🔑 **La frase para memorizar:** *"en SQL esto funcionaba"* no es un diagnóstico: es el
> punto de partida de uno. La pregunta que sigue es **qué** funcionaba — el motor, el
> modelo, o la costumbre.

---

## 2. 📇 Índice de las piezas

| Fase | El síntoma que cubre | Herramienta principal | Archivo |
|---|---|---|---|
| 0 | "Levanté todo y no conecta", con errores que no hablan de lo que pasa | El log del contenedor (`docker compose logs`) | `forense-fase-00.md` |
| 1 | "El dato está en la base y la consulta no lo encuentra" | `mongosh`, sobre el documento crudo | `forense-fase-01.md` |
| 2 | "Traduje mi WHERE y devuelve de más" ⭐ | `mongosh`, comparando contra el conteo | `forense-fase-02.md` |
| 4 | "El validator rechaza un documento que a mí me parece correcto" | `mongosh` + `db.getCollectionInfos()` | `forense-fase-04.md` |
| 5 | "Esta pantalla hace seis viajes a la base" ⭐ | `explain()` sobre el pipeline, y Compass | `forense-fase-05.md` |
| 6 | "Dos agentes tomaron el mismo ticket" ⭐ | Dos sesiones de `mongosh`, y `matchedCount` | `forense-fase-06.md` |
| 7 | "El índice está creado y `explain()` sigue diciendo COLLSCAN" | `explain("executionStats")` | `forense-fase-07.md` |
| 8 | "La migración pasó el conteo y los datos son basura" | El muestreo campo a campo, no el conteo | `forense-fase-08.md` |
| 9 | "Mi GROUP BY devuelve UNA fila" | `mongosh`, corriendo el pipeline por etapas | `forense-fase-09.md` |
| 10 | "El request se queda girando para siempre" ⭐ | Los logs de morgan, y `curl` | `forense-fase-10.md` |
| 12 | "Por socket llega distinto que por HTTP" | El cliente de socket junto a `curl`, lado a lado | `forense-fase-12.md` |
| 13 | "Verde en mi máquina, rojo en CI" | La salida de la suite y el log del runner | `forense-fase-13.md` |

**Las cuatro fases sin pieza, y por qué.** La 3 (embeber vs. referenciar) y la 15 (el
veredicto) son de **decisión**, no de depuración: su material es un árbol de criterios, y
forzarles un recorrido las convertiría en un resumen de sí mismas. La 11 (auth) y la 14
(operación) sí tienen recorrido propio —el orden de los middlewares que deja `req.user`
sin poblar, la guardia con `currentOp` y `killOp`— y son las **candidatas naturales a las
piezas 13 y 14** del track: se escriben el día que se sostengan solas, no por simetría.

---

## 3. 🩺 Índice de síntomas transversal

La tabla que se consulta de verdad. A la izquierda, lo que ves o lo que te cuentan; a la
derecha, dónde empezar. Todo lo que está acá sale de lo que las fases ya enseñan —casi
todo, de sus secciones «⚠️ Errores comunes»; el resto, de su código o de sus ejercicios—:
no hay ningún síntoma inventado. Lo que ninguna fase produce está en §6, y no en esta
tabla.

| Lo que ves o te cuentan | Empieza en |
|---|---|
| El contenedor levanta y nadie conecta al 27017 | Fase 0 — hay dos `mongod` peleando; el log del arranque lo dice |
| Cambiaste la ruta de datos y "se perdió todo" | Fase 0 — los datos viejos siguen en la ruta vieja: `down` → cambiar → `up` |
| `mongoexport` no existe | Fase 0 — desde 4.4 las Database Tools se instalan aparte |
| `find({ _id: "5f8a…" })` no encuentra nada y el documento está ahí | Fase 1 → Fase 2 — un `_id` es `ObjectId`, no string. Es la traducción de la que vive la capa API |
| "Se borraron los datos" y la colección está intacta | Fase 1 — el typo-colección: no hay error de "tabla no existe", hay colecciones fantasma |
| Un rango de fechas devuelve cualquier cosa | Fase 1 → Fase 2 — fechas guardadas como string; a veces "funciona" por el orden lexicográfico del ISO, hasta que no |
| Un filtro `$ne` trae documentos que no esperabas | Fase 2 — `$ne` incluye a los **ausentes**; no significa "tiene otro valor" |
| La proyección devuelve campos que no pediste, o falla | Fase 2 — se mezclaron `1` y `0`; solo `_id` va a contracorriente |
| Paginar la página 400 tarda un mundo | Fase 2 — `skip` gigante: el mismo pecado que `OFFSET`, la misma penitencia |
| El seed de la Fase 1 dejó de entrar | Fase 4 — el validator también aplica a tus scripts; si no pasa, acaba de encontrarle un bug al seed |
| El validator rechaza un número que es obviamente entero | Fase 4 — el driver manda `double`; `bsonType: "int"` exige `NumberInt()`. Hora y media perdida, clásica |
| Otro servicio escribió un documento inválido y el validator no dijo nada | Fase 4 — el schema de Mongoose valida en tu proceso Node; el del motor aplica a todos |
| Una pantalla hace seis viajes a la base | Fase 5 ⭐ — el N+1 de siempre, con otro collar |
| El `$lookup` devuelve arrays donde esperabas filas planas | Fase 5 — agrupa; y `$unwind` sin `preserveNullAndEmptyArrays` convirtió tu LEFT en INNER sin avisar |
| Los tickets sin comentarios desaparecieron del listado | Fase 5 — exactamente ese `$unwind` |
| Un `$lookup` que iba rápido se volvió lentísimo al crecer | Fase 5 — falta el `$match` previo, o el pipeline interno con `let` corre por cada documento izquierdo |
| Dos agentes tomaron el mismo ticket | Fase 6 ⭐ — `findOne` + `updateOne` son dos operaciones; la precondición va **en el filtro** |
| Un contador quedó corto tras un pico de tráfico | Fase 6 — `doc.n++; save()` es una carrera con disfraz |
| La transacción "funcionó" y una de las escrituras quedó fuera | Fase 6 — falta `{ session }` en una operación: corre fuera, sin error. El más traicionero del curso |
| Un update devuelve `matchedCount: 0` y el documento existe | Fase 6 — tu filtro llevaba precondición: existe y no la cumple. Son 404 y 409, no lo mismo |
| Creaste el índice y `explain()` sigue en COLLSCAN | Fase 7 — regex flotante, tipos que no coinciden, o el índice no cubre esa consulta |
| `explain()` dice IXSCAN y sigue lento | Fase 7 — mira `totalDocsExamined`: examinar 90.000 para devolver 20 es un COLLSCAN con corbata |
| El índice se usa pero aparece una etapa SORT | Fase 7 — el compuesto está al revés: prefijo izquierdo desperdiciado |
| El TTL no borra nada y no avisa | Fase 7 — está sobre fechas guardadas como string |
| Los inserts se volvieron lentos y nadie tocó el código | Fase 7 — índices nuevos en una colección de escritura intensa |
| La migración pasó el conteo y los datos están corridos | Fase 8 — verificar solo conteos; el muestreo campo a campo existe por esto |
| El proceso de migración se queda sin memoria | Fase 8 — se cargó todo en memoria en vez de usar cursor y lotes |
| Dos mediciones del mismo caso dan números distintos | Fase 8 — una con caché caliente y otra fría; mismas condiciones o los números mienten |
| Un `GROUP BY` colapsa a una sola fila | Fase 9 — el dólar ausente: `_id: "status"` agrupa por el literal |
| El pipeline muere con un error de 100 MB | Fase 9 — `$sort` gigante sin `allowDiskUse`… y si lo pones en un endpoint caliente, acabas de confesar que eso era un batch |
| El request se queda en `pending` para siempre, sin 404 ni 500 | Fase 10 ⭐ — async sin `next(err)`: el handler entró y no salió. Morgan no imprime la línea |
| El frontend no muestra nada y `curl` sí devuelve los tickets | Fase 10 → contrato — el envelope reflejo, o el `_id` sin serializar a `id` |
| Se agotan las conexiones a los pocos minutos | Fase 10 — un `MongoClient.connect` por request |
| El `?q=` revienta con ciertos textos | Fase 10 — regex sin escapar; funciona hasta el primer `(` |
| Por socket llega `_id` y por HTTP llega `id` | Fase 12 — falta el serializer en el emit: bugs fantasma que solo pasan "cuando llega en vivo" |
| El socket conecta y no llega nada, sin errores claros | Fase 12 — servidor 3.x/4.x contra el cliente 2.4 |
| El mismo evento llega dos veces | Fase 12 — quedaron dos emisores: el relé de sockets que el frontend traía y el `io.emit` nuevo del servidor |
| La suite pasa en local y falla intermitente en CI | Fase 13 — la versión del binario no está fijada: Mongo 7 en CI, 4.4 en tu equipo |
| Un test falla solo cuando corre con los demás | Fase 13 — base compartida y `deleteMany` en `afterEach`: depende del orden |
| Un test de concurrencia pasa y el bug sigue ahí | Fase 13 — una sola ronda: la carrera es probabilística, y el verde fue suerte |

---

## 4. 🧰 Las herramientas, y en qué miente cada una

Ninguna miente por malicia: cada una contesta una pregunta muy concreta, y el error es
preguntarle otra.

**`explain()`** miente por **plan cacheado**. El plan que te enseña puede ser el que el
planificador eligió en otra corrida, con otros datos; y miente por **verbosidad**, porque
el `queryPlanner` por defecto no trae los números que importan. Pídele
`executionStats` y mira `totalDocsExamined` frente a `nReturned`: esa razón es el
diagnóstico, no la etapa que aparece arriba.

**Compass** miente por **muestreo**. Lo que llama "el esquema" de una colección es una
inferencia sobre una muestra, no un contrato: un campo que aparece en el 99 % de los
documentos se ve idéntico a uno que aparece en el 100 %, y esa diferencia es justo la que
te rompe la aplicación. Para saber la verdad, cuenta.

**Los logs de Express** mienten por **momento**. La línea de `morgan("dev")` se imprime
cuando la respuesta se **cierra**, así que su ausencia no significa que el request no llegó:
significa que nunca se contestó. Es la primera pista del request colgado de la Fase 10, y
se lee al revés de como el instinto sugiere.

**El profiler** no miente, pero **cuesta**. Nivel 2 encendido en un sistema con tráfico es
un problema nuevo, no una herramienta. Para "algo está lento ahora mismo",
`db.currentOp()` contesta en un segundo lo que el profiler te dirá en diez minutos.

**Y el `mongosh` crudo**, que es la herramienta más honesta del curso: el documento tal
como está, sin el ODM traduciendo, sin el serializer maquillando. Cuando la API dice una
cosa y la pantalla otra, el desempate se hace acá.

---

## 5. Cómo se cierra el track

Este archivo te dice **dónde empezar**. Las piezas te dicen **cómo recorrer** cada camino.
Y lo que te llevas al trabajo real es la tabla de olores de la Fase 15: cinco minutos con
Compass delante de una base ajena y un veredicto con evidencia. Todo lo anterior es el
entrenamiento para poder emitirlo.

Las piezas que más rinden son las de las fases 2, 5, 6 y 10 ⭐, y no por casualidad: las
cuatro son sitios donde **el instinto SQL contesta rápido y contesta mal**. La 2 porque la
traducción literal casi funciona; la 5 porque el `$lookup` se parece demasiado a un JOIN;
la 6 porque en tu motor de siempre la transacción era gratis; y la 10 porque en Express 4
una promesa rechazada no es un 500, es un silencio.

> 🧭 **El criterio para saber si el track hizo su trabajo:** que ante *"Mongo va lento"*, tu
> primer movimiento sea pedir la consulta y el `explain()`, y no proponer un índice.

---

## 6. 📌 Síntomas sin pieza (pendientes)

Dos se consideraron para el índice y **no entraron**, porque ninguna fase los produce como
síntoma. Se anotan acá en vez de inventarles una fase, que es lo que manda
[`formato-piezas-forenses.md`](../prompts/formato-piezas-forenses.md) §9. Si alguna fase
llega a cubrirlos, suben a §3.

| Síntoma | Por qué no tiene pieza |
|---|---|
| "La fecha se guarda bien y se lee con un día menos" | El curso trata las fechas sin zona en un ejercicio de la Fase 1 y en la frontera `Date → ISO` de la Fase 10, pero ninguna fase produce el corrimiento de un día ni enseña a diagnosticarlo |
| "Guardé el ticket y al releerlo falta un campo" | Lo más cercano es la proyección que mezcla `1` y `0` (Fase 2), que es otra causa. El caso del campo que se pierde al escribir no aparece en ninguna fase |
