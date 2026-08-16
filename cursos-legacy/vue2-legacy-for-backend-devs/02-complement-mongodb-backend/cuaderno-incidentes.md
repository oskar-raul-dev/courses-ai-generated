# 📓 Cuaderno de incidentes — Curso 02 · MongoDB para cerebros SQL

> Doce tickets vagos, como llegan de verdad: en palabras de quien los sufre, sin
> pasos de reproducción y con la mitad de la información. Cada uno trae su
> preparación, tres pistas plegadas, sitio para tu investigación y una solución
> de referencia.

**El trato.** La solución viene incluida y está plegada por una razón: abrirla
antes de tiempo solo te perjudica a ti. Si llevas cuarenta minutos atascado, abre
la pista 1. Si llevas otros veinte, la 2. Y cuando abras la solución, léela
**después** de haber escrito tu hipótesis, aunque sea la equivocada.

Este cuaderno es del **Curso 02** y sus incidentes son autocontenidos. Los dos
casos de costura —el frontend hablándole al backend— **no exigen haber hecho el
Curso 01**: parten de un frontend ya construido que se entrega listo para correr.

---

## 🧭 Cómo se trabaja un incidente

El método es el de [`forense-master.md`](forense-master.md), y las cuatro
preguntas van siempre en este orden, porque cada una cuesta un orden de magnitud
más que la anterior:

1. **¿Se reproduce, y con qué?** ¿Con otro dato, con más volumen, o hace falta
   otro código? En este curso la variante de volumen es decisiva: la mitad de los
   bugs de modelado no existen hasta que hay datos de verdad.
2. **¿Qué dice la evidencia observable, antes que el código?** El documento crudo
   en `mongosh`, el `explain()`, la línea de morgan que no apareció.
3. **¿En qué capa está?** Ruta, controller, service o el propio Mongo. Y la
   pregunta que este curso agrega: ¿está en la **consulta** o en el **modelo**?
4. **¿De qué lado de la frontera está?** El contrato de
   [`00-audit-contrato.md`](00-audit-contrato.md): `_id` ↔ `id`, `Date` ↔ ISO, la
   forma de cada respuesta.

### Las tres formas de tener el sistema roto

Cada incidente dice cuál usa, y usa **la más barata que sirve**:

```bash
node scripts/seed.incidente-04.js       # 1 · un seed alterno (lo más común acá)
node scripts/generate.js --tickets 100000   # 2 · volumen, cuando el bug lo necesita
git switch -c incidente/06 fase-06-atomicidad-transacciones-consistencia   # 3 · una rama
```

> ⚠️ Antes de sembrar un escenario, ten a mano cómo volver: `npm run seed`
> regenera la base del curso, y `docker compose down -v && docker compose up -d`
> la deja de cero ([A01](a01-docker.md)).

### La convención de commits

```
incidente(06): abre — dos agentes tomaron el mismo ticket
incidente(06): repro — dos sesiones de mongosh, sin carga
incidente(06): hipótesis descartada — no es la transacción, es un solo documento
incidente(06): causa — findOne + updateOne: la precondición no está en el filtro
incidente(06): fix — precondición en el filtro, matchedCount 0 → 409
incidente(06): cierre — test de concurrencia con 50 rondas y post-mortem
```

Los verbos son fijos: `abre`, `repro`, `hipótesis`, `hipótesis descartada`,
`causa`, `fix`, `cierre`. **Commitea también los callejones sin salida.** Y marca
el par de tags de la [convención §🚑](../prompts/convencion-de-git-y-tags.md):

```bash
git tag -a inc/f06/doble-take-roto -m "Síntoma, repro y la prueba en rojo."
git tag -a inc/f06/doble-take-fix  -m "Causa raíz, fix, y la prueba en verde."
```

### Estados

| Estado | Significado |
|---|---|
| ⬜ Sin empezar | Todavía no lo tocaste |
| 🔴 Abierto | Leído, sin reproducir |
| 🟡 En análisis | Reproducido, causa raíz sin confirmar |
| 🟢 Cerrado | Fix aplicado y prueba de regresión pasando |
| ⚪ Descartado | No se reproduce, y está documentado por qué |

---

## 📋 Índice

| ID | Fase | Título | Categoría | Dif. | Estado |
|---|---|---|---|---|---|
| 01 | 0 | "El contenedor está arriba y nadie conecta" | Operación | 🟢 | ⬜ |
| 02 | 1 | "El ticket está en la base y mi script no lo encuentra" | Consultas | 🟡 | ⬜ |
| 03 | 2 | "El reporte de sin asignar da dos números distintos" | Consultas | 🟡 | ⬜ |
| 04 | 3 | "Hay tickets que tardan diez veces más que los demás" | Modelado | 🟡 | ⬜ |
| 05 | 5 | "El tablero tarda cuatro segundos y antes iba bien" | Modelado | 🟠 | ⬜ |
| 06 | 6 | "Dos agentes tomaron el mismo ticket" | Atomicidad | 🟠 | ⬜ |
| 07 | 7 | "Creamos el índice y sigue igual de lento" | Índices | 🟠 | ⬜ |
| 08 | 8 | "La migración pasó el conteo y los reportes salen mal" | Modelado | 🟠 | ⬜ |
| 09 | 9 | "El reporte por estado devuelve una sola línea" | Consultas | 🟠 | ⬜ |
| 10 | 10 | "Apunté el frontend al backend nuevo y no se ve nada" | Contrato | 🔴 | ⬜ |
| 11 | 12 | "En vivo llega mal y al recargar se ve bien" | Contrato | 🔴 | ⬜ |
| 12 | 13 | "Verde en mi máquina, rojo en CI" | Testing | 🔴 | ⬜ |

---

## 🧪 Incidentes

## Incidente 01 — "El contenedor está arriba y nadie conecta"

> **Fase:** 0 · **Categoría:** Operación · **Dificultad:** 🟢
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 20-40 min

### 🎫 El ticket

> "Levanté el compose como dice el README. `docker compose ps` dice que está
> corriendo. Pero ni Compass ni mongosh conectan, y la API tampoco arranca. Ayer
> funcionaba, hoy reinicié la máquina y ya no. No cambié nada."

**Reportado por:** alguien que se incorpora al proyecto · **Ambiente:** local

### 🎯 Qué se te pide

Que conecte, y una explicación de **por qué el cliente no podía saber la causa**.
Este incidente entrena el reflejo más rentable de la operación: leer el log del
servidor antes que el mensaje de error del cliente.

### 🔧 Preparación

La más barata: provocar la situación real, que es tener dos servidores peleando
por el mismo puerto.

```bash
# levanta un proceso cualquiera ocupando el 27017 antes del compose
docker run -d --name mongo-intruso -p 27017:27017 mongo:4.4
docker compose up -d
```

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

El cliente solo sabe que no lo dejaron entrar; el motivo está del otro lado. Hay
un comando que te enseña lo que el servidor intentó hacer al arrancar, y lo dice
en texto plano.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

`docker compose ps` puede decir "up" y el proceso estar reiniciándose en bucle.
Mira el log completo desde el arranque y busca las palabras `listener` y
`address`.

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿Quién más está escuchando en el 27017 de tu máquina?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** El `mongod` del compose no llegó a escuchar porque el puerto
27017 ya estaba ocupado. En el log:

```
mongo_1  | {"s":"E","c":"NETWORK","msg":"Failed to set up listener",
mongo_1  |  "attr":{"error":"Address already in use"}}
mongo_1  | {"s":"I","c":"CONTROL","msg":"now exiting"}
```

Y el "ayer funcionaba" tiene explicación exacta: el reinicio de la máquina
arrancó el `mongod` **nativo** instalado como servicio, que ayer no estaba
levantado. Dos servidores compitiendo; el de Docker llega segundo y se va.

**Parche mínimo:**

```bash
docker rm -f mongo-intruso          # o detén el servicio nativo
docker compose up -d
docker compose logs --tail 20 mongo
```

**La refactorización correcta.** Dos movimientos que hacen imposible la
repetición:

1. Publicar el puerto en uno propio del proyecto y dejarlo en el `.env`:
   `27018:27017`. El servicio nativo de tu máquina deja de ser un competidor.
2. Un `healthcheck` en el compose para que "arriba" signifique "contesta", no
   "el contenedor existe":

   ```yaml
   healthcheck:
     test: ["CMD", "mongo", "--eval", "db.runCommand({ping:1})"]
     interval: 10s
     retries: 5
   ```

**Prueba de regresión.** Un script de diagnóstico de tres líneas en el repo, que
es lo que le pasas al siguiente que reporte esto:

```bash
# scripts/doctor.sh
docker compose ps
docker compose logs --tail 30 mongo | grep -i "listener\|address\|exiting" || echo "log limpio"
docker compose exec -T mongo mongosh --quiet --eval 'db.runCommand({ping:1})'
```

**Prevención.** En el README, la regla de oro de este incidente escrita como
procedimiento: **ante cualquier "no conecta", el primer comando es el log del
servidor, no el cliente.** Y una nota sobre el `mongod` nativo, que es el
competidor invisible en las máquinas de quien ya trabajaba con Mongo.

**Por qué llegó a producción.** Nadie se equivocó: el compose estaba bien, el
README estaba bien, y el sistema no tenía forma de avisar de que había otro
proceso en el puerto salvo en un log que nadie mira. El fallo fue de
**observabilidad**, no de configuración — y por eso el arreglo estructural es el
`healthcheck`, que convierte un estado mentiroso ("up") en uno útil.

**Si tu causa fue distinta a ésta.** Si tu log estaba limpio y el ping funcionaba
**dentro** del contenedor pero no fuera, tu problema es la publicación del
puerto, y ese diagnóstico está en el paso 3 de la
[pieza forense de la Fase 0](forense-fase-00.md). Si al conectar viste las
colecciones vacías, era el volumen: los datos siguen en la ruta vieja.

</details>

---

## Incidente 02 — "El ticket está en la base y mi script no lo encuentra"

> **Fase:** 1 · **Categoría:** Consultas · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 30-50 min

### 🎫 El ticket

> "Estoy haciendo un script de reporte. Copio el `_id` de un ticket desde
> Compass, lo pego en mi `find` y me devuelve vacío. El ticket está ahí, lo estoy
> viendo. Y el reporte por rango de fechas de marzo me trae tickets de julio.
> Vengo de Oracle y esto no me cuadra."

**Reportado por:** un compañero que se está pasando a Mongo · **Ambiente:** local

### 🎯 Qué se te pide

Los dos síntomas tienen la **misma raíz** y hay que decirlo así en el
post-mortem: es la mitad del valor del incidente. Se te pide arreglar el script,
y además escribir un pequeño auditor que detecte el problema de fondo en toda la
colección, porque si pasó con dos campos puede estar pasando con más.

### 🔧 Preparación

Un seed alterno que reproduce una base heredada realista: la mitad de los tickets
con `createdAt` como `Date` y la otra mitad como string ISO, tal como quedan
cuando alguien importó un `db.json` sin convertir.

```bash
node scripts/seed.incidente-02.js
```

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Mira el documento **crudo** en `mongosh`, no en la interfaz gráfica. Fíjate en lo
que hay alrededor de cada valor: unas comillas de más o de menos cambian el caso
entero.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

Compara qué **tipo** tiene el valor guardado y qué tipo tiene el valor con el que
comparas. En Mongo, comparar tipos distintos no es un error: es un `false`.

```js
db.tickets.findOne({}, { createdAt: 1 })
db.tickets.countDocuments({ createdAt: { $type: "string" } })
```

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Un `_id` se **imprime** como 24 caracteres hexadecimales. ¿Se **guarda** como
eso?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** La misma en los dos casos: **se compara contra el tipo
equivocado, y Mongo no avisa.**

1. Un `_id` es un `ObjectId`, no la cadena con la que se imprime.
   `find({ _id: "5f8a…" })` compara un `ObjectId` con un string: no coincide
   nunca, y devuelve el conjunto vacío que corresponde. En Oracle esto habría
   sido un error de tipos; acá es un resultado legítimo.
2. Las fechas del seed heredado están **mezcladas**: unas como `Date` y otras
   como string ISO. Un `$gte: ISODate("2020-03-01")` solo compara contra las
   primeras, y entre strings el orden lexicográfico del ISO *parece* funcionar
   —hasta que llega una sin zona horaria o con otro formato—. Por eso el rango de
   marzo trae julio: mezcla dos universos de comparación.

**Parche mínimo:**

```js
db.tickets.find({ _id: ObjectId("5f8a1c2e4b3d2f0012a4e991") })
db.tickets.find({ createdAt: { $gte: ISODate("2020-03-01"), $lt: ISODate("2020-04-01") } })
```

**La refactorización correcta.** El parche arregla la consulta y deja la base
enferma. Dos movimientos:

1. **Normalizar los datos**, con un script idempotente y con `--dry` primero:

   ```js
   // scripts/fix-dates.js
   db.tickets.find({ createdAt: { $type: "string" } }).forEach(function (doc) {
     db.tickets.updateOne(
       { _id: doc._id },
       { $set: { createdAt: new Date(doc.createdAt) } }
     );
   });
   ```

2. **Impedir que vuelva**, con el validator de la Fase 4 exigiendo
   `bsonType: "date"`. La regla del motor aplica a todos los clientes: tu API, el
   script del compañero y mongosh.

Y el auditor que se pedía, que es la pieza que se lleva uno al trabajo real:

```js
// scripts/audit-types.js — un conteo por campo sospechoso
["createdAt", "priority", "status", "assignee"].forEach(function (field) {
  var types = db.tickets.aggregate([
    { $group: { _id: { $type: "$" + field }, n: { $sum: 1 } } }
  ]).toArray();
  print(field + ": " + JSON.stringify(types));
});
```

**Prueba de regresión.**

```js
// test/data-integrity.spec.js
it("no quedan fechas guardadas como texto", async function () {
  var n = await db.collection("tickets").countDocuments({ createdAt: { $type: "string" } });
  expect(n).toBe(0);
});
```

**Prevención.** Correr el auditor de tipos como parte del pipeline sobre la base
de pruebas. En una base sin esquema, **un conteo por tipo es la prueba unitaria
de los datos**, y cuesta segundos.

**Por qué llegó a producción.** Porque el `db.json` heredado del Curso 01 traía
las fechas como texto —en JSON no hay otra cosa— y el primer seed las insertó
tal cual. Nadie hizo nada raro: la conversión no estaba en ninguna parte porque
en el mundo relacional la columna la habría rechazado. La base aceptó los dos
tipos sin decir nada, y los reportes empezaron a mentir meses después.

**Si tu causa fue distinta a ésta.** Si tu script devolvía vacío pero por estar en
otra base o por un typo en el nombre de la colección, has encontrado el otro
gran silencio de Mongo: no existe el error "la tabla no existe", solo colecciones
fantasma que responden `0`. Está en el paso 2 de la
[pieza forense de la Fase 1](forense-fase-01.md).

</details>

---

## Incidente 03 — "El reporte de sin asignar da dos números distintos"

> **Fase:** 2 · **Categoría:** Consultas · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 40-60 min

### 🎫 El ticket

> "El reporte de tickets sin asignar me da 34 y el que hice yo a mano en Compass
> da 41. Los dos filtran por lo mismo, ninguno da error. Necesito saber cuál
> mando al comité del jueves."

**Reportado por:** el analista de reportes · **Ambiente:** UAT

### 🎯 Qué se te pide

La pregunta correcta no es cuál está bien: es **qué está contando cada uno**.
Se te pide reproducir la diferencia, explicar el mecanismo con una tabla, y
—esto es lo importante— **convertirlo en una pregunta de negocio**: ¿"sin
asignar" incluye a los tickets que nunca tuvieron el campo? Con la respuesta
elegida y escrita, entonces sí, el filtro.

### 🔧 Preparación

Un seed alterno con los tres estados presentes, que es lo que produce una base
heredada de verdad:

```bash
node scripts/seed.incidente-03.js
```

Siembra tickets con `assignee: "soporte1"`, con `assignee: null` explícito, y
otros **sin el campo**.

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

No compares consultas: compara **conteos**. Escribe las dos versiones y cuenta
las dos. La diferencia entre los números es el tamaño exacto del malentendido.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

En SQL toda fila tiene todas las columnas. Acá no. Cuenta cuántos documentos
tienen el campo y cuántos no:

```js
db.tickets.countDocuments({ assignee: { $exists: false } })
```

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Tu instinto dice que `= NULL` no matchea nada. Pruébalo. Se equivoca, y se
equivoca en la dirección contraria a la que esperas.

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** Ninguno de los dos filtros está mal escrito: **cuentan cosas
distintas**, porque en Mongo hay tres estados donde tu instinto relacional ve
dos.

| Filtro | Con valor | `null` explícito | Campo ausente |
|---|---|---|---|
| `{ assignee: null }` | ✗ | ✅ | ✅ **también** |
| `{ assignee: { $type: "null" } }` | ✗ | ✅ | ✗ |
| `{ assignee: { $exists: false } }` | ✗ | ✗ | ✅ |
| `{ assignee: { $ne: null } }` | ✅ | ✗ | ✗ |

El reporte de 41 usaba `{ assignee: null }` —que incluye los ausentes— y el de 34
usaba `$type: "null"`. Los 7 de diferencia son tickets que nunca tuvieron el
campo, casi siempre porque los creó una versión anterior del sistema.

**Parche mínimo.** Depende de la respuesta de negocio, y por eso el fix se
escribe **después** de contestarla. Si "sin asignar" es cualquier ticket que no
tiene a nadie trabajándolo —lo habitual—, la versión correcta es la laxa, y
conviene dejar el porqué en el código:

```js
// "Sin asignar" incluye los tickets sin el campo: son de la versión vieja
// del sistema y operativamente están igual de libres. Decidido con el comité,
// 2020-04. No cambiar sin volver a preguntar.
var UNASSIGNED = { assignee: null };
```

**La refactorización correcta.** Dos cosas, y la segunda es la que evita el
siguiente reporte descuadrado:

1. **Un solo sitio** donde viva la definición de cada concepto del negocio
   —"sin asignar", "activo", "vencido"— y que todos los reportes importen. Dos
   analistas escribiendo el mismo filtro a mano es la fábrica de este incidente.
2. **Normalizar la ausencia**: un script idempotente que ponga `assignee: null`
   explícito donde falte, más el validator de la Fase 4 con `required` para que
   el campo no pueda volver a faltar. Con eso los tres estados se reducen a dos y
   la trampa desaparece de raíz.

**Prueba de regresión.**

```js
it("el filtro de sin asignar cubre null explícito y campo ausente", async function () {
  await col.insertMany([
    { title: "A", assignee: "soporte1" },
    { title: "B", assignee: null },
    { title: "C" }
  ]);
  expect(await col.countDocuments(UNASSIGNED)).toBe(2);
});
```

**Prevención.** Una regla para los reportes heredados, barata y demoledora:
**escribe cada filtro de dos formas y cuenta las dos.** Si los números difieren,
acabas de encontrar una pregunta de negocio que nadie había contestado — y es
mejor encontrarla tú que el comité del jueves.

**Por qué llegó a producción.** Porque los dos filtros son correctos, los dos son
razonables, y ninguna herramienta puede decir cuál querías. La migración desde el
mundo relacional trajo intacto el reflejo de que un campo o tiene valor o es
nulo; el tercer estado no existía en el modelo mental de nadie, y el sistema no
tenía cómo señalarlo.

**Si tu causa fue distinta a ésta.** Si la diferencia venía de `$ne` —"asignados
a alguien que no es soporte1" contra "no asignados a soporte1"— es la misma
trampa por el otro lado, y también es un hallazgo legítimo: `$ne` incluye a los
ausentes. Si venía de `count()` contra `countDocuments()`, encontraste un tercer
miembro de la familia: el primero puede estimar.

</details>

---

## Incidente 04 — "Hay tickets que tardan diez veces más que los demás"

> **Fase:** 3 · **Categoría:** Modelado · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 1-1,5 h

### 🎫 El ticket

> "Casi todos los tickets abren al instante, pero hay unos pocos que tardan
> varios segundos y a veces se queda la pantalla en blanco. Son siempre los
> mismos: los más viejos, los que llevan meses abiertos y se han pasado entre
> varios agentes. Los recién creados van rápido."

**Reportado por:** coordinadora de soporte · **Ambiente:** UAT

### 🎯 Qué se te pide

Medir en vez de opinar: hace falta un número que distinga un ticket "normal" de
uno "lento". Después, decir **qué decisión de modelado** produce esa asimetría y
si tiene techo. Y por último, la parte que este curso pide siempre: si hay que
cambiar el modelo, defiende el cambio con el criterio de la fase, no con gusto
personal.

### 🔧 Preparación

Un seed alterno con la distribución realista de una base heredada: la mayoría de
tickets con historial corto y unos pocos con historial gigante.

```bash
node scripts/seed.incidente-04.js     # 10.000 tickets, 20 con history de ~15.000 entradas
```

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

No mires la consulta todavía: mira los **documentos**. Compara el tamaño de uno
de los lentos con el de uno normal.

```js
Object.bsonsize(db.tickets.findOne({ _id: ObjectId("…") }))
```

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

¿Qué campo hace la diferencia de tamaño? ¿Y quién lo lee? Cuando la API devuelve
un ticket para pintar la pantalla de detalle, ¿necesita ese campo?

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

El array crece con cada cambio de estado del ticket. ¿Cuál es su techo?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** El array `history` está **embebido y no tiene techo**. Cada
transición de estado le añade una entrada, y en tickets que llevan meses vivos
—y que pasaron por varios agentes, con automatismos que también escriben— el
array crece hasta que el documento pesa cientos de KB o más. Como Mongo lee y
escribe el **documento entero**, cada lectura de esos tickets mueve todo ese peso
aunque la pantalla solo pinte el título y el estado.

```js
> Object.bsonsize(db.tickets.findOne({ legacyId: 41 }))
2841
> Object.bsonsize(db.tickets.findOne({ legacyId: 7 }))
1874203
```

La Fase 3 lo nombra entre sus vetos físicos: **arrays sin techo**. El límite duro
de 16 MB por documento es el final del camino —y ahí el ticket deja de poder
guardarse—, pero mucho antes de llegar el rendimiento ya se degradó.

Importante para el post-mortem: el diseño **no era irrazonable**. El historial se
lee junto con el ticket, es del ticket, no se consulta transversalmente. Cumplía
los tres criterios de embeber… salvo el del techo, que es el que veta.

**Parche mínimo** — el del viernes a las seis, que no cambia el modelo:

```js
// La API deja de arrastrar el historial en el listado y en el detalle
db.tickets.find({ status: "open" }, { history: 0 })
```

Con una proyección que excluya `history`, la pantalla vuelve a ir rápida. El
documento sigue siendo enorme —cada escritura lo sigue pagando— pero el síntoma
desaparece, y a veces eso es exactamente lo que hay que hacer un viernes.

**La refactorización correcta.** Sacar el historial a su propia colección, con
referencia al ticket:

```js
// ticket_events
{ _id: ObjectId("…"), ticketId: ObjectId("…"), at: ISODate("…"),
  from: "open", to: "in_progress", by: "soporte1" }
```

Y con eso:

- el ticket vuelve a pesar lo que pesa un ticket, y su lectura no depende de su
  edad;
- el historial se pagina —que es lo que la pantalla necesita: las últimas diez
  entradas, no quince mil—;
- se pierde la atomicidad regalada que tenías al hacer `$push` al array y `$set`
  del estado en **una** operación. Eso hay que decirlo en voz alta: es una
  contrapartida real, y la Fase 6 explica cómo recuperar la garantía cuando de
  verdad haga falta.

La migración es idempotente y va en dos pasos: copiar cada entrada del array a la
colección nueva con su `ticketId`, verificar por muestreo, y solo entonces
`$unset` del campo.

**Prueba de regresión.**

```js
it("ningún ticket supera el techo de tamaño acordado", async function () {
  var big = await col.aggregate([
    { $project: { size: { $bsonSize: "$$ROOT" } } },
    { $match: { size: { $gt: 100 * 1024 } } }
  ]).toArray();
  expect(big).toHaveLength(0);
});
```

(En 4.4 `$bsonSize` está disponible; si tu pipeline no lo admite, el mismo test se
escribe con `Object.bsonsize` en un script de auditoría.)

**Prevención.** La pregunta del techo entra en la plantilla de decisiones de
modelado —`DATA-MODEL.md`— y se contesta con un número, no con "no debería
crecer mucho": **¿cuál es el p99 del tamaño de este array a un año?** Si la
respuesta es "no lo sé", la decisión es referenciar.

**Por qué llegó a producción.** Porque el diseño se validó con datos de
desarrollo, donde todos los tickets tienen dos o tres transiciones. Un array sin
techo se comporta perfectamente hasta que el tiempo lo llena, y el tiempo tarda
meses en llegar. Nadie se equivocó al embeber: faltó preguntar por el techo, que
es la única de las cuatro preguntas de modelado que **no se puede contestar
mirando la aplicación de hoy**.

**Si tu causa fue distinta a ésta.** Si tu conclusión fue "faltan índices",
compruébalo con `explain()`: el acceso por `_id` ya usa el índice y sigue lento,
porque el coste no está en encontrar el documento sino en moverlo. Es
exactamente el caso donde afinar índices no arregla nada, y la
[pieza de la Fase 7](forense-fase-07.md) lo llama el meta-error de esa fase.

</details>

---

## Incidente 05 — "El tablero tarda cuatro segundos y antes iba bien"

> **Fase:** 5 · **Categoría:** Modelado · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 1,5-2 h

### 🎫 El ticket

> "El tablero de soporte tarda como cuatro segundos en abrir. Antes iba bien. No
> hemos tocado esa pantalla en meses, solo se ha ido llenando de tickets y
> comentarios. Y es peor a primera hora, cuando entramos todos."

**Reportado por:** coordinadora de soporte · **Ambiente:** UAT

### 🎯 Qué se te pide

Que la pantalla vuelva a ir rápida, con **números antes y después medidos en las
mismas condiciones**. Y una respuesta escrita a la pregunta que la fase pone
sobre la mesa: ¿esto se arregla con una consulta mejor, o el modelo está
pidiendo otra cosa? Las dos respuestas son legítimas; lo que no vale es no
haberla hecho.

### 🔧 Preparación

Volumen: este bug no existe con datos de juguete.

```bash
node scripts/generate.js --tickets 100000 --comments 400000
```

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Antes de medir ninguna consulta, **cuéntalas**. Abre la pantalla una vez y mira
cuántas líneas aparecen en el log de la API.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

Si son muchas y todas rápidas, el problema no es ninguna de ellas. Si es una sola
y lenta, mira su `explain("executionStats")` y compara `totalDocsExamined` con
`nReturned`.

Y presta atención al **orden de las etapas** del pipeline: ¿en qué momento se
filtra?

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿Cuántos documentos se unen antes de que el filtro descarte la mayoría?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** Dos capas del mismo problema, y conviene separarlas:

1. *El pipeline une antes de filtrar.* El `$match` por `status` está **después**
   del `$lookup` con comentarios, así que el motor une los 100.000 tickets con
   sus 400.000 comentarios y luego se queda con los abiertos:

   ```
   nReturned: 41230, totalDocsExamined: 100000, executionTimeMillis: 3184
   ```

   Moviendo el `$match` al principio, la misma consulta baja a cientos de
   milisegundos. Es el `WHERE` que tu instinto SQL jamás habría puesto al final,
   y acá se escribe así porque el pipeline se lee como una receta.

2. *El modelo pide otra cosa.* Aun con el orden corregido, la pantalla necesita
   tickets **con su conteo de comentarios**, y calcularlo en cada carga es unir
   dos colecciones grandes para producir un número. Eso no es una consulta: es un
   dato derivado que nadie guardó.

**Parche mínimo:**

```js
db.tickets.aggregate([
  { $match: { status: "open" } },                 // primero, siempre
  { $sort: { createdAt: -1 } },
  { $limit: 50 },                                 // y solo lo que la pantalla pinta
  { $lookup: { from: "comments", localField: "_id", foreignField: "ticketId", as: "comments" } }
])
```

**La refactorización correcta.** Un contador denormalizado en el ticket:

```js
{ _id: ObjectId("…"), title: "…", status: "open", commentCount: 12 }
```

Se mantiene con `$inc` en la misma operación que inserta el comentario, y con
eso la pantalla deja de unir nada. Pero **denormalizar sin protocolo es peor que
no denormalizar**, así que la decisión viene con tres compromisos escritos:

- **quién escribe** el contador (solo el service de comentarios, un único sitio);
- **cuánta divergencia se tolera** y por cuánto tiempo;
- **cómo se reconcilia** — un job que recuente, acotado por `updatedAt`, no
  recorriendo la colección entera cada noche.

Sin esas tres frases en `DATA-MODEL.md`, el contador se desincroniza y nadie sabe
cuál es la verdad.

**Prueba de regresión.** Una de corrección y una de coste:

```js
it("mantiene el contador al insertar un comentario", async function () {
  await service.addComment(ticketId, { body: "hola" });
  var t = await col.findOne({ _id: ticketId });
  expect(t.commentCount).toBe(1);
});

it("el listado no examina más documentos de los que devuelve", async function () {
  var stats = await explainList({ status: "open", limit: 50 });
  expect(stats.totalDocsExamined).toBeLessThanOrEqual(stats.nReturned * 2);
});
```

Ese segundo test es de los más útiles que vas a escribir: **una aserción sobre el
plan de ejecución** falla el día que alguien reordene las etapas, mucho antes de
que un usuario lo note.

**Prevención.** Dos hábitos: medir el listado principal con volumen real en cada
cambio del pipeline, y tratar cada `$lookup` nuevo como una pregunta sobre el
modelo —¿estos datos se leen siempre juntos?— antes que como una consulta.

**Por qué llegó a producción.** Porque con mil tickets el pipeline mal ordenado
tarda 30 ms y nadie lo nota. El coste de unir antes de filtrar crece con el
volumen, no con el código, así que el sistema se degrada solo mientras todo el
mundo hace su trabajo bien. Y el `$lookup` se escribió porque se parecía al JOIN
que había en el sistema anterior — el instinto correcto en el sitio equivocado.

**Si tu causa fue distinta a ésta.** Si tu log mostraba decenas de peticiones en
vez de una lenta, encontraste el N+1 clásico y el arreglo es agrupar en una
consulta —no necesariamente un `$lookup`: un `$in` con los ids suele ganar—. Si
tu `$unwind` hizo desaparecer los tickets sin comentarios, encontraste el LEFT
que se volvió INNER: falta `preserveNullAndEmptyArrays`.

</details>

---

## Incidente 06 — "Dos agentes tomaron el mismo ticket"

> **Fase:** 6 · **Categoría:** Atomicidad · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 1,5-2 h

### 🎫 El ticket

> "Ana y yo tomamos el mismo ticket casi al mismo tiempo. A los dos nos dijo que
> quedó asignado, sin ningún error. En el listado aparece asignado a Ana y en mi
> pantalla aparezco yo. Pasa poco, pero cuando pasa nos enteramos tarde y
> duplicamos trabajo."

**Reportado por:** agente de soporte · **Ambiente:** UAT, dos usuarios reales

### 🎯 Qué se te pide

Reproducirlo **de forma determinista** —"pasa poco" tiene que convertirse en "las
veces que yo quiera"—, arreglarlo, y distinguir en el contrato dos respuestas que
hoy se confunden. Y una decisión razonada: ¿hace falta una transacción? Contesta
con argumentos; la respuesta correcta sorprende a casi todo el mundo que viene de
SQL.

### 🔧 Preparación

Ni volumen ni caos: dos sesiones de `mongosh` bastan. Y para el caso del código,
una rama.

```bash
git switch -c incidente/06 fase-06-atomicidad-transacciones-consistencia
node scripts/seed.incidente-06.js     # deja el ticket de prueba sin asignar
```

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Mira lo que **devolvió** cada escritura, no lo que quedó en la base:
`matchedCount` y `modifiedCount` tienen la mitad de la historia.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

Busca en el service la forma característica: una lectura, una comprobación, y una
escritura. Entre la primera y la tercera hay un hueco. ¿Qué lo protege?

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

La condición "solo si sigue libre", ¿dónde está escrita? ¿En un `if` o en el
filtro del update?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** El service hace **read-modify-write**:

```js
var ticket = await tickets.findOne({ _id: id });
if (ticket.assignee) { throw new ConflictError("Ya está asignado"); }
await tickets.updateOne({ _id: id }, { $set: { assignee: user, status: "in_progress" } });
```

Entre el `findOne` y el `updateOne` hay una ventana. Los dos procesos leyeron
"sin asignar", los dos pasaron la comprobación y los dos escribieron: la segunda
escritura pisó a la primera con todo el derecho, porque su filtro solo dice "este
ticket", y ese ticket existe. **No hubo una carrera perdida: hubo dos carreras
ganadas.**

En tu motor de siempre, un `SELECT … FOR UPDATE` dentro de la transacción
implícita del framework tapaba esto sin que tuvieras que pensarlo. Acá no hay
nada puesto.

**Parche mínimo** — la precondición se muda al filtro:

```js
var result = await tickets.updateOne(
  { _id: id, assignee: null },                                   // ← la condición, adentro
  { $set: { assignee: user, status: "in_progress" } }
);
if (result.matchedCount === 0) { … }
```

Una escritura sobre **un** documento ya es atómica: con la condición dentro del
filtro, comprobar y escribir dejan de ser dos operaciones. El segundo agente
recibe `matchedCount: 0` y se entera.

**La refactorización correcta.** El parche arregla la carrera; el contrato
necesita además distinguir dos respuestas que hoy son la misma:

```js
if (result.matchedCount === 0) {
  var exists = await tickets.countDocuments({ _id: id });
  if (!exists) { throw new NotFoundError(); }        // 404: no existe
  throw new ConflictError("Ana se te adelantó");     // 409: existe y no cumple
}
```

`matchedCount: 0` **no significa "no existe"**: puede existir y no cumplir la
precondición. Colapsarlas en un 404 produce el reporte gemelo —*"me dice que el
ticket no existe y ahí está"*— y le quita al usuario la única información útil.

Y la respuesta a la pregunta de la transacción: **no hace falta**. Es un solo
documento, y envolverlo en `withTransaction` paga sesión, límite de 60 s y
riesgo de conflictos por una garantía que ya tenías. Las transacciones son para
cuando de verdad hay que tocar dos colecciones — y entonces hay que acordarse de
pasar `{ session }` a **todas** las operaciones, porque la que se olvide corre
fuera, sin error y sin aviso.

**Prueba de regresión.** Y acá está la parte que casi nadie hace bien: una
carrera es **probabilística**, así que un test de una sola ronda no prueba nada.

```js
it("solo un agente puede tomar el ticket, en 50 rondas", async function () {
  for (var i = 0; i < 50; i++) {
    var id = await seedFreeTicket();
    var results = await Promise.all([
      service.take(id, "ana"),
      service.take(id, "beto")
    ].map(function (p) { return p.catch(function (e) { return e; }); }));

    var ok = results.filter(function (r) { return !(r instanceof Error); });
    expect(ok).toHaveLength(1);
  }
});
```

**Prevención.** Una regla que cabe en la revisión de código: **si un `if` decide
si se puede escribir, esa condición pertenece al filtro de la escritura.** Y un
`grep` que encuentra los sospechosos:

```bash
grep -rn "findOne" -A 6 src/services/ | grep -n "updateOne\|updateMany"
```

**Por qué llegó a producción.** Porque en desarrollo eres un usuario haciendo una
cosa a la vez, y el código *parece* correcto: la comprobación está escrita, es
explícita y se lee bien. El sistema no tenía forma de avisar de que esa
comprobación no valía nada bajo concurrencia — y la concurrencia solo aparece
cuando el sistema tiene usuarios de verdad. Nadie escribió mal el `if`; faltaba
la traducción de un reflejo que en el mundo relacional era gratuito.

**Si tu causa fue distinta a ésta.** Si tu caso era un contador que quedaba corto
(`doc.n++; save()`), es la misma familia con otro disfraz y el arreglo es `$inc`.
Si era una transacción a la que le faltaba una escritura, encontraste el fallo
más traicionero de la fase: la operación sin `{ session }` corre fuera y el
todo-o-nada queda agujereado sin un solo error.

</details>

---

## Incidente 07 — "Creamos el índice y sigue igual de lento"

> **Fase:** 7 · **Categoría:** Índices · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 1-1,5 h

### 🎫 El ticket

> "Nos dijeron que el listado iba lento por falta de índice. Creamos el índice,
> lo vemos en Compass, y va exactamente igual. ¿Hay que reiniciar Mongo? ¿O
> creamos el índice mal?"

**Reportado por:** el compañero que está optimizando · **Ambiente:** UAT

### 🎯 Qué se te pide

Explicar **por qué el índice no se usa** con evidencia del plan de ejecución, no
con teoría; corregirlo; y medir antes y después en las mismas condiciones. Y una
segunda entrega que separa a quien entiende índices de quien los crea: revisar si
el resto de índices de la colección sirven para algo, y borrar los que no —con el
argumento de cuánto cuestan en escritura.

### 🔧 Preparación

Volumen y un índice mal orientado:

```bash
node scripts/generate.js --tickets 100000
```

```js
db.tickets.createIndex({ createdAt: -1, status: 1 })   // el compuesto al revés
```

Y la consulta que sufre es la del contrato: filtrar por `status` y ordenar por
`createdAt` descendente.

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

`explain()` a secas no sirve: pídele estadísticas de ejecución y mira dos
números, no la etiqueta de la etapa.

```js
db.tickets.find({ status: "open" }).sort({ createdAt: -1 })
  .explain("executionStats").executionStats
```

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

Pon el índice y la consulta uno debajo del otro. ¿Por qué campo empieza cada uno?

Y busca en el plan si aparece una etapa `SORT`: si el índice sirviera para
ordenar, no haría falta.

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Un índice compuesto se puede usar empezando por su primera clave. Tu consulta,
¿filtra por esa primera clave?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** El compuesto está **al revés** para esta consulta. Con
`{ createdAt: -1, status: 1 }`, el prefijo izquierdo es `createdAt`, y la consulta
no filtra por ese campo: no hay por dónde entrar al índice. El plan lo dice:

```
totalKeysExamined: 0, totalDocsExamined: 100000, stage: 'COLLSCAN'
```

Es exactamente la regla de prefijo izquierdo que ya conoces de tu motor
relacional; lo único nuevo es dónde leerla.

**Parche mínimo:**

```js
db.tickets.createIndex({ status: 1, createdAt: -1 })
```

```
totalKeysExamined: 20, totalDocsExamined: 20, executionTimeMillis: 3
```

Con el filtro entrando por el prefijo, el orden sale gratis del propio índice: la
etapa `SORT` desaparece, que es la señal de que el compuesto quedó bien
orientado.

**La refactorización correcta.** Un índice no se diseña por campo, se diseña
**por consulta del contrato**. El movimiento correcto es inventariar las
consultas que la API hace de verdad —listado con `status`, búsqueda por `q`,
detalle por `_id`, comentarios por `ticketId`— y tener un índice por patrón, no
uno por campo "importante".

Y la contrapartida, que hay que medir y no suponer: **cada índice se paga en cada
escritura.** Antes de dejar cinco índices en una colección que recibe inserts
constantes, mide el coste:

```js
// mismo lote de inserts, con y sin el índice nuevo
var t0 = Date.now();
db.tickets.insertMany(batch);
print(Date.now() - t0);
```

**Prueba de regresión.** Una aserción sobre el plan, que es lo que impide la
reincidencia:

```js
it("el listado principal usa el índice y no examina de más", async function () {
  var stats = (await col.find({ status: "open" }).sort({ createdAt: -1 }).limit(20)
    .explain("executionStats")).executionStats;

  expect(stats.totalDocsExamined).toBeLessThanOrEqual(20);
  expect(JSON.stringify(stats.executionStages)).not.toContain("COLLSCAN");
});
```

**Prevención.** Tres reglas de lectura del plan, que valen para cualquier motor:

- mira **`totalDocsExamined` frente a `nReturned`**, no la etapa;
- una etapa `SORT` en una consulta que ordena por un campo indexado es una
  bandera roja;
- mide siempre con las mismas condiciones de caché, o los números mienten.

**Por qué llegó a producción.** Porque el índice se creó a partir de una
intuición correcta —"esta consulta necesita índice"— sin mirar el plan ni la
consulta real. Y porque `createIndex` **nunca falla por estar mal orientado**:
crea el índice, lo ocupa en disco, lo cobra en cada escritura y no sirve para
nada. El sistema no tiene forma de decirte "este índice no lo usa nadie" salvo que
se lo preguntes (`$indexStats`).

**Si tu causa fue distinta a ésta.** Si tu plan decía `IXSCAN` y aun así iba
lento, mira la razón examinados/devueltos: un IXSCAN que examina 90.000 para
devolver 20 es un COLLSCAN con corbata, y suele ser un regex flotante. Si el
índice era correcto y la pantalla seguía lenta, felicidades: encontraste el
meta-error de la fase — lo lento es el modelo, y eso es el
[incidente 05](#incidente-05--el-tablero-tarda-cuatro-segundos-y-antes-iba-bien).

</details>

---

## Incidente 08 — "La migración pasó el conteo y los reportes salen mal"

> **Fase:** 8 · **Categoría:** Modelado · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 1,5-2 h

### 🎫 El ticket

> "La migración de `soporte_v1` a `soporte_v2` terminó anoche y el reporte dice
> 100.000 de 100.000. Pero hoy el tablero muestra tickets cerrados como si
> estuvieran abiertos, y a varios les cambió el agente asignado. Los totales por
> estado no cuadran con los de la semana pasada."

**Reportado por:** el analista de reportes · **Ambiente:** la base migrada

### 🎯 Qué se te pide

Encontrar qué se rompió, arreglarlo **sin volver a empezar de cero** si es
posible, y —la parte que de verdad importa— escribir el procedimiento de
verificación que tendría que haber existido. Un conteo no es una verificación, y
este incidente es la demostración.

### 🔧 Preparación

Un seed de las dos bases y una migración con el bug puesto:

```bash
node scripts/seed.soporte-v1.js
node scripts/migrate.incidente-08.js     # migra con el mapa de estados corrido
```

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

No mires el script todavía. Toma cinco documentos del origen y sus equivalentes
en el destino, y ponlos uno al lado del otro campo por campo.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

Fíjate en los campos que en el origen eran **códigos numéricos** y en el destino
son texto. ¿La correspondencia es la que debería? Prueba con el documento cuyo
código era el más bajo y con el del más alto.

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si los ids del origen empiezan en 1 y tu arreglo de traducción empieza en 0,
¿qué le pasa a cada estado?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** Dos, y la segunda solo aparece si miras las referencias:

1. *El mapa de estados corrido una posición.* El script traduce
   `status_id → status` indexando un arreglo desde 0, y los ids del origen
   empiezan en 1. Todos los tickets quedaron con el estado anterior al suyo. Los
   conteos globales **coinciden** porque el corrimiento es uniforme —hay la misma
   cantidad de documentos en cada grupo, solo que con la etiqueta cambiada—, y
   por eso ninguna verificación por cantidad lo detectó.

   ```js
   // origen
   { ticket_id: 1, status_id: 4, assignee_id: 12 }
   // destino
   { legacyId: 1, status: 'open', assignee: 'ana' }     // status_id 4 era 'closed'
   ```

2. *Referencias en `null`.* `tickets` se migró **antes** que `users`, así que el
   script no tenía el mapa `user_id → username` y resolvió a `null` sin quejarse.
   De ahí los agentes que "cambiaron".

**Parche mínimo.** El mapa se corrige y se vuelve a aplicar **solo sobre lo
migrado**, sin repetir la migración entera:

```js
// scripts/fix-08-status.js — idempotente: usa el origen como verdad
db.getSiblingDB("soporte_v1").tickets.find({}, { ticket_id: 1, status_id: 1 })
  .forEach(function (src) {
    db.tickets.updateOne(
      { legacyId: src.ticket_id },
      { $set: { status: STATUS_MAP[src.status_id] } }    // mapa por CLAVE, no por índice
    );
  });
```

Fíjate en el detalle que evita la reincidencia: el mapa deja de ser un arreglo
posicional y pasa a ser un objeto con claves explícitas. Un off-by-one no se
arregla restando uno, se arregla eliminando la aritmética.

**La refactorización correcta.** El script de migración es **código de
producción** y le faltaban tres cosas que no cuestan casi nada:

- **`--dry`**, que imprime qué haría sin hacerlo;
- **idempotencia**, para poder volver a correrlo sobre el resultado anterior sin
  duplicar ni corromper (upsert por una clave estable como `legacyId`);
- **verificación propia**, que es el corazón de este incidente:

```js
// scripts/verify-migration.js
var sample = srcTickets.aggregate([{ $sample: { size: 50 } }]).toArray();
sample.forEach(function (src) {
  var dst = dstTickets.findOne({ legacyId: src.ticket_id });
  assertEqual(STATUS_MAP[src.status_id], dst.status, "status " + src.ticket_id);
  assertEqual(USER_MAP[src.assignee_id] || null, dst.assignee, "assignee " + src.ticket_id);
});
// más los extremos, que son donde viven los off-by-one:
["min status_id", "max status_id", "assignee_id null", "createdAt más antiguo"]
```

Y el orden de ejecución deja de ser implícito: **los referenciados primero**
(`users`), y el script de tickets falla ruidosamente si el mapa está vacío en vez
de resolver a `null`.

**Prueba de regresión.**

```js
it("no quedan tickets con estado fuera del enum", async function () {
  var n = await col.countDocuments({ status: { $nin: ["open","in_progress","resolved","closed"] } });
  expect(n).toBe(0);
});

it("la distribución por estado coincide con el origen", async function () {
  for (var id in STATUS_MAP) {
    expect(await dst.countDocuments({ status: STATUS_MAP[id] }))
      .toBe(await src.countDocuments({ status_id: Number(id) }));
  }
});
```

Ese segundo test es el que habría atrapado el bug: compara **por grupo**, no el
total.

**Prevención.** Una frase en el procedimiento de migración, y que sea condición
para dar por buena cualquiera: **verificar por muestreo campo a campo, incluyendo
los extremos, además de los conteos.** Veinte documentos bien elegidos —el más
viejo, el más nuevo, los que tenían nulos, los que tenían referencias— encuentran
el 90% de los errores de transformación.

**Por qué llegó a producción.** Porque la verificación que existía —conteo origen
contra conteo destino— es la que todo el mundo escribe, y es la que **casi
cualquier bug de transformación respeta**. El número de documentos es la
propiedad más fácil de preservar y la que menos información aporta. Nadie hizo
trampa ni fue descuidado: se verificó lo que se sabía verificar, de noche y con
gente esperando.

**Si tu causa fue distinta a ésta.** Si tu migración se quedó sin memoria, el
hallazgo es otro y también está en la fase: cargar 300.000 documentos en memoria
en vez de usar cursor y lotes. Y si tus números de "antes y después" no
convencían a nadie, revisa las condiciones de medición: una con caché caliente y
otra fría no comparan nada.

</details>

---

## Incidente 09 — "El reporte por estado devuelve una sola línea"

> **Fase:** 9 · **Categoría:** Consultas · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 40-60 min

### 🎫 El ticket

> "El reporte de tickets por estado dejó de funcionar. No da error, pero en vez
> de la tabla con una fila por estado sale una sola línea con el total de todo.
> Lo heredé de quien se fue, no lo he tocado."

**Reportado por:** el analista de reportes · **Ambiente:** desarrollo

### 🎯 Qué se te pide

Localizar la herida —y hay un detalle en la salida que te la confiesa— y arreglar
el pipeline. Después, la parte transferible: describir el **método** con el que
habrías encontrado esto en la primera etapa, sin leer el pipeline entero. Ese
método vale más que el arreglo, porque el siguiente pipeline roto no se va a
parecer a éste.

### 🔧 Preparación

No hace falta romper nada ni sembrar nada: el pipeline heredado se pega tal cual
en `mongosh`.

```js
db.tickets.aggregate([
  { $group: { _id: "status", total: { $sum: 1 } } }
])
```

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Mira la salida, no el código. El documento que devuelve tiene un campo que te está
diciendo por qué agrupó así.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

El `_id` de la salida: ¿trae un **valor de tus datos** o el **nombre de un
campo**?

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

En el lenguaje del pipeline, ¿qué diferencia hay entre `"status"` y `"$status"`?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** `_id: "status"` es el **literal** de cuatro letras, no una
referencia al campo. Mongo agrupó por esa constante: un solo grupo, todos los
documentos dentro. Y la salida lo confiesa:

```js
// [ { "_id" : "status", "total" : 100000 } ]
```

Ese `_id` que sale con el nombre del campo en vez de un valor de tus datos es la
**huella dactilar** del bug. Tu ojo de SQL ya lo había traducido: un `GROUP BY`
que colapsa a una fila es un `GROUP BY <constante>`.

No hay error porque no hay nada ilegal: agrupar por un literal es una operación
válida, solo que inútil.

**Parche mínimo** — un carácter:

```js
db.tickets.aggregate([
  { $group: { _id: "$status", total: { $sum: 1 } } }
])
// [ { "_id":"open", "total":41230 }, { "_id":"closed", "total":38110 }, … ]
```

**La refactorización correcta.** El pipeline de un reporte que alguien va a
firmar merece dos cosas más:

```js
db.tickets.aggregate([
  { $match: { createdAt: { $gte: from, $lt: to } } },   // filtra primero: usa índice
  { $group: { _id: "$status", total: { $sum: 1 } } },
  { $sort: { total: -1 } },
  { $project: { _id: 0, status: "$_id", total: 1 } }    // forma estable para el consumidor
])
```

El `$match` al principio no es cosmético: es la diferencia entre usar el índice y
regalarse un COLLSCAN. Y el `$project` final le da al reporte una forma con
nombres propios, en vez de exponer el `_id` técnico del `$group`.

**Prueba de regresión.**

```js
it("agrupa por el valor del estado, no por el literal", async function () {
  var rows = await service.countByStatus();
  expect(rows.length).toBeGreaterThan(1);
  expect(rows.map(function (r) { return r.status; })).toEqual(
    expect.arrayContaining(["open", "closed"])
  );
});
```

Fíjate en la primera aserción: **más de una fila** es exactamente la invariante
que se rompió, y es trivial de escribir.

**Prevención.** El método que se pedía, y que caza esta familia entera: **corre el
pipeline etapa por etapa, mirando dos documentos.**

```js
db.tickets.aggregate([{ $match: { … } }, { $limit: 2 }]).toArray()
// añade una etapa, vuelve a mirar; añade otra, vuelve a mirar
```

La unidad de depuración de un pipeline no es el pipeline: es la etapa. Con este
hábito, el bug de hoy se detecta en la primera, antes de que el `$group` mienta
en silencio.

**Por qué llegó a producción.** Porque el pipeline **funciona**: no lanza, no
avisa, y devuelve un número que además es correcto —el total sí es 100.000—.
Quien lo escribió venía de SQL, donde `GROUP BY status` no necesita ningún
prefijo, y el lenguaje de agregación usa el mismo texto para dos cosas distintas
según lleve `$` o no. La revisión de código tampoco podía verlo: un carácter
ausente en una cadena.

**Si tu causa fue distinta a ésta.** Si tu pipeline perdía campos después del
`$group`, encontraste otra propiedad importante: el `$group` **no propaga** lo que
no declaras. Y si el tuyo reventaba con el error de 100 MB en un `$sort`, no
tenías un bug sino un batch disfrazado de consulta.

</details>

---

## Incidente 10 — "Apunté el frontend al backend nuevo y no se ve nada"

> **Fase:** 10 · **Categoría:** Contrato · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 1,5-2 h

> 🧩 **Incidente de costura, autocontenido.** No hace falta haber escrito el
> frontend ni haber hecho el Curso 01: se te entrega ya construido y solo tienes
> que levantarlo.

### 🎫 El ticket

> "Cambiamos la URL del frontend para que apunte al backend nuevo en vez del
> mock y la pantalla de tickets sale vacía. Dice 'No hay tickets'. Pero si hago
> `curl` a la API los tickets están todos ahí. Volvimos al mock y todo bien, así
> que el frontend no está roto."

**Reportado por:** el compañero que hizo el cambio · **Ambiente:** desarrollo

### 🎯 Qué se te pide

Que el frontend funcione contra tu backend **sin tocar una línea del frontend**.
Esa restricción no es un capricho: es la promesa del paquete —*se cambia el
`baseURL` y la aplicación no se entera*— y es también la situación real cuando el
cliente lo mantiene otro equipo.

Entregable: la lista de **todas** las diferencias entre lo que tu API devuelve y
lo que el contrato promete, no solo la primera que encuentres. Suelen ser tres o
cuatro y se arreglan juntas.

### 🔧 Preparación

El frontend se entrega construido, con su `db.json` y su mock por si necesitas
comparar contra el comportamiento original:

```bash
git clone <repo-del-frontend> mini-jira-front && cd mini-jira-front
npm ci
npm run mock            # el mock original, en :3000 — tu referencia
npm run serve           # el frontend, en :8080
```

Y para el incidente, apúntalo a tu backend cambiando **solo** el `baseURL`:

```js
// src/services/apiClient.js — la única línea que se toca en todo el frontend
baseURL: "http://localhost:4000"
```

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Tienes la mejor herramienta de diagnóstico posible y casi nadie la usa: **el
sistema que sí funcionaba**. Pide lo mismo a los dos servidores y compara las
dos respuestas carácter por carácter.

```bash
curl -s http://localhost:3000/tickets | head -c 300   # el mock
curl -s http://localhost:4000/tickets | head -c 300   # el tuyo
```

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

Compara tres cosas en ese orden: la **forma de la respuesta** (¿es un arreglo, o
un objeto que envuelve al arreglo?), los **nombres de los campos**, y los
**tipos** de cada valor.

Y después mira el frontend —solo mirar— para ver qué hace con lo que recibe:
`res.data` de axios, y `ticket.id` en la clave de la lista y en las rutas.

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿Con qué campo construye el frontend el enlace al detalle? ¿Existe ese campo en
lo que tú devuelves?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** Tres incumplimientos del contrato, en una sola respuesta, y
ninguno produce un error:

```json
// lo que devuelve tu backend
{"data":[{"_id":"5f8a1c2e4b3d2f0012a4e991","title":"La impresora no imprime",
"createdAt":{"$date":"2020-03-10T10:00:00Z"},"history":[…],"schemaVersion":2}]}

// lo que promete 00-audit-contrato.md
[{"id":"5f8a1c2e4b3d2f0012a4e991","title":"La impresora no imprime",
"createdAt":"2020-03-10T10:00:00.000Z","status":"open","priority":"high"}]
```

1. **El envelope reflejo.** Devuelves `{ data: [...] }` y el contrato dice
   arreglo plano. El frontend hace `res.data` de axios —que ya es el cuerpo— y
   se encuentra un objeto donde esperaba una lista: `tickets` queda con algo que
   no tiene `length`, y la vista muestra su estado vacío. **Silencioso.**
2. **`_id` en vez de `id`.** Aunque el envelope se arregle, cada fila necesita
   `ticket.id` para su `:key` y para construir `/tickets/:id`. Con `_id`, las
   claves son `undefined` y los enlaces no llevan a ninguna parte.
3. **Fechas y campos internos.** `createdAt` viaja como objeto de fecha en vez de
   string ISO, y encima van `history` y `schemaVersion`, que el contrato no
   menciona y el frontend no pidió.

**Parche mínimo** — la frontera, que ya existía a medias:

```js
// src/api/serializers.js
function serializeTicket(doc) {
  return {
    id: doc._id.toString(),                    // la base habla Mongo…
    title: doc.title,
    description: doc.description,
    status: doc.status,
    priority: doc.priority,
    assignee: doc.assignee,
    reporter: doc.reporter,
    createdAt: doc.createdAt.toISOString()     // …la API habla el contrato
  };
}
```

```js
// el controller devuelve el recurso, sin envolver
res.json(docs.map(serializeTicket));
```

**La refactorización correcta.** El parche arregla el listado; el contrato tiene
más superficie —detalle, comentarios, POST, PATCH, DELETE— y cada endpoint puede
incumplirlo por su cuenta. Dos movimientos:

1. **Un solo serializer por recurso**, usado por todos los controllers, y la
   regla de que **ningún handler devuelve un documento crudo**. Es fácil de
   auditar: `grep -rn "res.json(doc" src/`.
2. **Una suite de contrato** que compare tu API contra el contrato escrito, no
   contra tus expectativas:

   ```js
   it("GET /tickets devuelve un arreglo plano con id string", async function () {
     var res = await request(app).get("/tickets").expect(200);
     expect(Array.isArray(res.body)).toBe(true);
     expect(typeof res.body[0].id).toBe("string");
     expect(res.body[0]._id).toBeUndefined();
     expect(res.body[0].history).toBeUndefined();
     expect(res.body[0].createdAt).toMatch(/^\d{4}-\d{2}-\d{2}T/);
   });
   ```

**Prueba de regresión.** La de arriba, más la verificación de extremo a extremo
que cierra la promesa del paquete: apagar el mock, apuntar el frontend al backend
y comprobar que ninguna vista se entera.

**Prevención.** El contrato deja de ser un documento y pasa a ser **tests**. Un
`.md` que describe una API es una intención; una suite que la comprueba es una
garantía. Y una regla para los cambios futuros: si de verdad hace falta cambiar
la forma de una respuesta, **se cambia el contrato primero** y se avisa a quien
lo consume. Un envelope añadido en silencio rompe pantallas que no sabías que
existían.

**Por qué llegó a producción.** Porque las tres diferencias son **mejoras** desde
la perspectiva de quien escribe el backend. El envelope `{ data: … }` es una
convención muy razonable —deja sitio para metadatos de paginación—, devolver
`_id` es lo natural en Mongo, y mandar el documento entero parece generoso.
Ninguna produce un error y todas rompen al consumidor. El sistema no tenía cómo
avisar porque **nadie estaba comprobando el contrato**: existía escrito y no
ejecutable.

**Si tu causa fue distinta a ésta.** Si tu pantalla salía vacía por CORS, es un
diagnóstico legítimo y la evidencia está en la consola del navegador, no en el
`catch` — con `curl` funcionando y el navegador no, la respuesta es siempre ésa.
Si el listado funcionaba y el detalle daba 500 con ciertos ids, encontraste otro
punto de la frontera: un id malformado tiene que ser 404, no una excepción al
construir el `ObjectId`.

</details>

---

## Incidente 11 — "En vivo llega mal y al recargar se ve bien"

> **Fase:** 12 · **Categoría:** Contrato · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 1,5-2 h

> 🧩 **Incidente de costura, autocontenido.** El frontend se entrega construido;
> no hace falta haber hecho el Curso 01 ni haberlo escrito.

### 🎫 El ticket

> "Los tickets que aparecen solos en la pantalla, sin recargar, salen mal: el
> enlace no lleva a ninguna parte y la fecha se ve rarísima. Si recargo, ese
> mismo ticket se ve perfecto. Y desde ayer, además, cada ticket nuevo me sale
> dos veces."

**Reportado por:** agente de soporte · **Ambiente:** UAT

### 🎯 Qué se te pide

Son **dos** problemas y hay que separarlos: la forma de lo que llega en vivo, y
la cantidad de veces que llega. Para el primero, causa raíz y fix. Para el
segundo, identificar cuántos emisores hay en el sistema y por qué existe el
sobrante.

Y una comprobación de diseño que este curso pide siempre: verificar **en qué
orden** ocurren la escritura y el anuncio.

### 🔧 Preparación

El mismo frontend construido del incidente anterior, apuntado a tu backend, y tu
servidor con sockets levantado:

```bash
cd mini-jira-front && npm ci && npm run serve      # frontend en :8080
npm run dev                                        # tu backend, con sockets
```

Dos navegadores con sesión abierta; el ticket se crea en uno y se observa en el
otro.

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Pon los dos canales lado a lado. Pide el mismo ticket por HTTP y mira el payload
que llega por el socket:

```js
socket.on("ticket:created", function (t) { console.log(t); });
```

Si las dos formas no coinciden, ya sabes qué mitad del ticket estás resolviendo.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

Para el duplicado: cuenta **frames**, no filas. Si por el socket llega un solo
frame y la fila aparece dos veces, el problema está en el cliente; si llegan dos
frames, hay dos emisores.

```bash
grep -rn "emit(" src/ | grep -v node_modules
lsof -i :4000
```

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Lo que sale por el socket, ¿pasó por el mismo sitio por el que pasa lo que sale
por HTTP?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** Dos, independientes:

1. *La forma.* El emit manda el **documento crudo** de Mongo: `_id` en vez de
   `id`, la fecha como `Date` en vez de ISO, y campos internos de propina. El
   serializer que la Fase 10 aplica religiosamente en cada respuesta HTTP no se
   aplicó al segundo canal. Por eso al recargar se ve bien: esa vez el dato entró
   por HTTP, que sí tiene guardián.

   ```js
   realtime.emit("ticket:created", doc);            // ⚠️ crudo
   realtime.emit("ticket:created", serializeTicket(doc));   // ✅
   ```

2. *El duplicado.* Hay **dos emisores**: tu backend nuevo emite tras persistir, y
   el relé de sockets que el frontend traía —un servidor de veinte líneas que
   rebota lo que le llega— sigue encendido en el mismo puerto. Cada creación
   produce dos anuncios del mismo hecho.

Y mientras investigas, comprueba el **orden**: si el `emit` está antes del
`insertOne`, estás anunciando algo que todavía puede fallar. Eso reconstruye,
con más pasos, el problema que el frontend tenía cuando el que anunciaba era el
cliente.

**Parche mínimo:**

```js
// services/tickets.service.js
var result = await tickets.insertOne(doc);          // primero se persiste…
realtime.emit("ticket:created", serializeTicket(doc));   // …después se anuncia
```

Y apagar el relé heredado, que es una línea en el `package.json` del frontend y
un proceso menos corriendo.

**La refactorización correcta.** El problema de fondo es que **el sistema tiene
dos fronteras y solo una tiene guardián**. La solución estructural es que el
único camino de salida de un recurso sea el serializer, venga por donde venga:

```js
// realtime/index.js — el módulo de tiempo real no acepta documentos crudos
function emitTicket(event, doc) {
  io.emit(event, serializeTicket(doc));
}
```

Con esa firma, emitir el documento crudo deja de ser posible por accidente. Y una
regla que hay que dejar escrita: **el payload de un evento es una respuesta de
API**, con el mismo contrato y las mismas garantías.

**Prueba de regresión.**

```js
it("el evento de socket lleva la misma forma que la respuesta HTTP", async function () {
  var received = await captureNextEvent("ticket:created", function () {
    return request(app).post("/tickets").send(validPayload).expect(201);
  });

  expect(received.id).toEqual(expect.any(String));
  expect(received._id).toBeUndefined();
  expect(received.createdAt).toMatch(/^\d{4}-\d{2}-\d{2}T/);
  expect(received.history).toBeUndefined();
});

it("emite después de escribir, no antes", async function () {
  tickets.insertOne = jest.fn().mockRejectedValue(new Error("boom"));
  await expect(service.create(validPayload)).rejects.toThrow();
  expect(realtime.emit).not.toHaveBeenCalled();
});
```

Ese segundo test es corto y vale por toda la discusión de diseño: si la escritura
falla, nadie se enteró de nada.

**Prevención.** Un inventario de canales de salida en el README del backend
—HTTP, sockets, y lo que venga después: colas, webhooks, exportaciones— con una
columna que diga quién aplica el serializer en cada uno. Es la lista que evita
que el tercer canal repita esta historia.

**Por qué llegó a producción.** Porque el segundo canal se añadió meses después
del primero, en otra fase y con otra cabeza. El serializer estaba en los
controllers, que es donde se escribió cuando solo había HTTP, y al añadir sockets
nadie pensó en él: el módulo de tiempo real recibía documentos y los mandaba, que
es lo que parece que tiene que hacer. Y el relé viejo siguió encendido porque
apagarlo era responsabilidad de nadie en concreto — estaba en el otro repo.

**Si tu causa fue distinta a ésta.** Si tu socket no conectaba en absoluto, mira
las versiones: un servidor socket.io 3.x/4.x contra el cliente 2.4 del frontend
heredado produce **silencio**, no un error. Y si el duplicado venía de un solo
emisor, el sobrante está en el cliente: handlers suscritos sin dar de baja al
navegar.

</details>

---

## Incidente 12 — "Verde en mi máquina, rojo en CI"

> **Fase:** 13 · **Categoría:** Testing · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 1,5-2 h

### 🎫 El ticket

> "Monté el pipeline el viernes y desde entonces la suite falla allá y pasa acá.
> Siempre el mismo archivo, `test/lib/serializers.test.js`, y siempre el mismo
> assert: dice que esperaba una fecha y recibió otra, con unas horas de
> diferencia. En mi máquina pasa en verde en cada corrida, y en la de todo el
> equipo también. Ese código no lo toca nadie desde que se escribió."

**Reportado por:** el compañero que montó el pipeline · **Ambiente:** local y CI

### 🎯 Qué se te pide

Tres cosas, y la primera es la que de verdad se parece al trabajo:

1. **Reproducir el rojo en tu propia máquina.** No tienes acceso al runner para
   depurar dentro, y ése es el caso normal, no una limitación del ejercicio.
2. Causa raíz hasta el archivo, fix y prueba de regresión.
3. Una decisión de diseño: al final hay **dos arreglos posibles**, y solo uno de
   los dos arregla el sistema — el otro arregla el test. Di cuál es cuál, aplica
   los dos, y justifica el orden.

> ⚠️ La Fase 13 te enseñó una causa clásica para exactamente este síntoma, y la
> pieza forense la recorre entera. **Aquí no es ésa**, y descartarla con evidencia
> —no con un "no puede ser"— es el primer paso de la investigación.

### 🔧 Preparación

Forma 3, una rama de git: hace falta código distinto del que dejó la fase, y sale
del tag que ya tienes.

```bash
git switch -c incidente/12 fase-13-testing-de-api
# el commit de la rama toca DOS líneas: una fixture y un assert. Nada más.
npm ci
npx jest test/lib/serializers.test.js
```

```
PASS  test/lib/serializers.test.js
```

Sí: en tu máquina pasa. Ése es el problema, no la buena noticia.

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

No empieces por el serializer. Empieza por la pregunta del método: **qué es
distinto entre los dos entornos**, si el código es el mismo commit. La lista corta
es siempre la misma —motor, orden de ejecución, paralelismo, datos previos y
**reloj**— y se descarta de la más barata a la más cara.

La más barata de todas cuesta una línea y no toca la suite:

```bash
node -e "console.log(Intl.DateTimeFormat().resolvedOptions().timeZone, new Date().getTimezoneOffset())"
```

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

Lee el assert que falla y hazte la pregunta incómoda: **la cadena literal con la
que compara, ¿de dónde salió?** Nadie la calculó a mano.

Después mira cómo construye su `createdAt` la fixture de ese test, en
`test/fixtures/index.js`, y vuelve a leer el ejercicio 25 de la
[Fase 1](01-mongo-en-30-min.md). Está advertido desde el primer capítulo del
curso, sobre el seed — y acabó pasando en los tests.

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

`new Date("2021-03-01 23:30")`, ¿qué instante produce en tu máquina? ¿Y el mismo
string en un contenedor configurado en UTC?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```
```

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**En qué capa vivía**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** El test tiene grabado el huso horario de quien lo escribió, en
dos mitades que por separado parecen inocentes:

```js
// test/fixtures/index.js
createdAt: new Date("2021-03-01 23:30")          // ← string SIN zona
```

```js
// test/lib/serializers.test.js
expect(out.createdAt).toBe("2021-03-02T04:30:00.000Z");   // ← salida copiada
```

Un string de fecha sin zona lo interpreta el motor de JavaScript **en la zona
local del proceso**. En una máquina en `America/Bogota` (UTC-5), esas 23:30 son
las 04:30 UTC del día siguiente; en el runner, configurado en UTC, son las 23:30
del mismo día. Dos entornos, dos instantes, dos ISO distintos — y el serializer
funciona perfectamente en los dos casos.

Por eso **no es un test inestable**: es determinista en cada sitio, y da resultados
distintos porque está midiendo dos relojes. Reproducirlo en tu máquina cuesta una
variable de entorno:

```bash
TZ=UTC npx jest test/lib/serializers.test.js
```

```
FAIL  test/lib/serializers.test.js
  ● serializeTicket (la frontera del contrato) › las fechas salen como ISO string

    Expected: "2021-03-02T04:30:00.000Z"
    Received: "2021-03-01T23:30:00.000Z"
```

**Parche mínimo.** El del viernes a las seis: que la fecha diga en qué zona está.

```js
// test/fixtures/index.js
// La zona va explícita: sin la Z, el instante depende de la máquina que corre.
createdAt: new Date("2021-03-01T23:30:00Z")
```

```js
// test/lib/serializers.test.js
expect(out.createdAt).toBe("2021-03-01T23:30:00.000Z");
```

**La refactorización correcta.** Son los dos arreglos que pedía el enunciado, y el
orden importa:

1. **Primero, fijar el reloj de la suite**, que es el arreglo del *sistema*: el
   `globalSetup` deja de depender de cómo esté configurada la máquina que corre
   los tests. Es la misma medicina que la fase aplicó al binario del motor —
   *lo que no está escrito en el repositorio, no existe*—, ahora aplicada al huso.

   ```js
   // test/globalSetup.js
   module.exports = async function () {
     process.env.TZ = "UTC";                 // la suite corre siempre en el mismo huso
     // …el memory-server con su binary.version fijado…
   };
   ```

2. **Después, quitar los literales dependientes de zona** de todas las fixtures,
   no solo de la que falló. Un `grep` los encuentra en un minuto:

   ```bash
   grep -rn 'new Date("' test/ | grep -v 'Z"'
   ```

Si haces solo el 1, el test se pone verde y las fixtures siguen mintiendo el día
que alguien corra la suite fuera del runner. Si haces solo el 2, arreglas este
test y el siguiente vuelve a nacer torcido. El 1 sin el 2 es tapar; el 2 sin el 1
es arreglar un caso.

**Prueba de regresión.** Dos, y la primera es la que impide la reincidencia:

```js
// test/lib/clock.test.js — el guardián, hermano del que fija la versión del motor
it("la suite corre en UTC", function () {
  expect(new Date().getTimezoneOffset()).toBe(0);
});
```

```js
// test/lib/serializers.test.js — el caso, ahora sin depender del reloj de nadie
test("una fecha con zona explícita se serializa igual en cualquier máquina", function () {
  const out = serializeTicket(makeTicket({ createdAt: new Date("2021-03-01T23:30:00Z") }));
  expect(out.createdAt).toBe("2021-03-01T23:30:00.000Z");
});
```

Y la comprobación que cierra el caso, porque reproduce el entorno del compañero
sin pedirle nada al runner:

```bash
TZ=America/Bogota npx jest && TZ=UTC npx jest      # verde las dos veces
```

**Prevención.** El `TZ` fijado en el `globalSetup` y el test guardián; el `grep`
de arriba como paso del checklist de revisión; y —esto es lo que se lleva uno al
sistema de verdad— **la zona del contenedor declarada en el compose de la
[Fase 14](14-operacion.md)**, por el mismo motivo. Un backend que calcula fechas
según cómo venga configurada la máquina anfitriona tiene el mismo bug, solo que
sin un test que lo delate.

**Por qué llegó a producción.** Por la práctica más natural del mundo: el assert
se escribió **copiando lo que salió**. Corres el test, ves el valor recibido, lo
pegas como esperado y queda verde. Es lo que hace todo el mundo cuando escribe el
test después del código, y funciona mientras el equipo entero comparta huso — que
es exactamente lo que pasaba. El pipeline fue el primer entorno del proyecto
configurado de otra forma, y por eso el síntoma llegó disfrazado de "problema de
CI": el pipeline no rompió nada, solo fue el primero en decir la verdad.

Nadie se equivocó al escribir el assert. El sistema permitía que un test dependiera
de configuración invisible, y el arreglo es que deje de permitirlo.

**Si tu causa fue distinta a ésta.** El síntoma "verde acá, rojo allá" tiene tres
sospechosos más, y los tres son plausibles:

- **La versión del binario sin fijar** — la causa que recorre la
  [pieza forense de la Fase 13](forense-fase-13.md). Se distingue por dos señas:
  falla **intermitentemente** (una de cada tres corridas, no siempre) y revienta
  en asserts de `$ne` o del upsert que colisiona, no en fechas.
- **Orden y paralelismo.** Si `npx jest --runInBand` pasa y en paralelo falla, no
  es el reloj: es aislamiento entre suites.
- **El presupuesto de tiempo.** El duelo de 20 rondas con dos núcleos y cuatro
  workers puede pasarse de los 5 s por defecto de Jest. Ahí el rojo dice
  `Exceeded timeout`, que es un mensaje honesto y conviene leerlo.

Si tu fix fue subir el timeout, marcar el test como flaky o forzar `--runInBand`
en el pipeline, tapaste el síntoma en una capa más arriba: los tres esconden el
rojo sin tocar la variable suelta.

> 📄 El recorrido completo de este síntoma, con las salidas literales y los
> callejones, en [`forense-fase-13.md`](forense-fase-13.md).

</details>

---

## 🪞 Retrospectiva

Cuando cierres varios incidentes, vuelve acá y llénala. No es un formalismo: la
lista de causas raíz de un backend tiene forma, y verla es lo que convierte doce
casos sueltos en criterio.

| ID | Capa donde vivía | Pista que lo resolvió | Cuánto tardaste | Lo habrías visto antes si… |
|---|---|---|---|---|
| 01 | | | | |
| 02 | | | | |
| 03 | | | | |
| 04 | | | | |
| 05 | | | | |
| 06 | | | | |
| 07 | | | | |
| 08 | | | | |
| 09 | | | | |
| 10 | | | | |
| 11 | | | | |
| 12 | | | | |

Tres preguntas para cuando la tabla esté llena:

- **¿Cuántos resolviste sin abrir un archivo de la aplicación?** En este curso son
  más de la mitad: se resuelven en `mongosh`, en un `explain()` o leyendo un
  documento crudo. Ése es el número que justifica todo el track — el backend no se
  depura en el código, se depura en los datos.
- **¿Cuántos eran modelado disfrazado de rendimiento?** El síntoma llega siempre
  como "esto va lento" y la causa está en una decisión de forma que se tomó meses
  antes. Saber traducir uno en otro es la mitad de este curso.
- **¿Cuántos los habría evitado el contrato, si alguien lo hubiera leído antes de
  escribir el endpoint?** Los de la categoría Contrato, sí — pero mira también los
  otros: el contrato dice qué forma tiene un ticket, y varias causas raíz de acá
  son un documento que dejó de tener esa forma sin que nadie se enterara.

---

## 📌 Pendientes

Lo que salió de los incidentes y no se arregla en este curso, con el motivo.

- **La consistencia entre colecciones sigue siendo tuya** (incidentes 05 y 08). Sin
  claves foráneas, nada impide que un `assignee` apunte a un usuario que ya no
  está. El validator de la Fase 4 comprueba forma, no referencias; las
  transacciones de la Fase 6 protegen una operación, no el histórico. Es el precio
  del modelo, no un defecto de tu implementación, y así lo firma
  [el veredicto de la Fase 15](15-el-veredicto-honesto.md).
- **El `schemaVersion` sin migración de verdad** (incidente 08). El curso deja los
  documentos conviviendo en dos versiones y la aplicación tolerándolas. Es lo
  correcto para aprender, y es deuda para un sistema real: alguien tiene que
  decidir cuándo se termina la migración y quién apaga el código de compatibilidad.
- **La seguridad se paga a medias** (incidente 10 y toda la Fase 11). El curso pone
  bcrypt, JWT firmado y validación en la frontera, y `SECURITY-NOTES.md` cierra
  cuatro deudas. Lo que queda —rate limiting, autorización por recurso, cabeceras,
  uploads hostiles— vive en [`a04-seguridad.md`](a04-seguridad.md) como apéndice
  opcional, y opcional significa que si no lo haces, no está.
- **El anuncio en tiempo real sigue sin garantías de entrega** (incidente 11). El
  servidor emite después de escribir, que era la deuda que había que pagar; pero un
  cliente desconectado durante el emit se pierde el evento y solo se entera al
  recargar. La solución real es una cola o un `since` en el reconnect, y ninguna de
  las dos entra en un curso de Mongo.
- **El reloj y la zona horaria del proceso** (incidente 12). Se fija en la suite y
  se declara en el compose de la Fase 14, pero el sistema sigue calculando fechas
  con la zona del proceso. El día que un reporte tenga que agrupar "por día" para
  un negocio que no vive en UTC, eso es una decisión de producto y hay que tomarla
  a propósito.

> 🧭 Los cinco pendientes tienen algo en común, y conviene decirlo en voz alta:
> **ninguno es un bug.** Son los límites de hasta dónde llega este curso, cada uno
> con su nombre y su motivo. Un backend que sabe cuáles son sus límites es
> mantenible; uno que cree no tenerlos es el que produce los incidentes de este
> cuaderno.
