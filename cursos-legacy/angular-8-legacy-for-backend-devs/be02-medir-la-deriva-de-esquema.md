# 🔬 Fase be02 — Lo que hay de verdad guardado: medir la deriva

> Tutorial Angular 8 — Laboratorio clínico · 🔥 Track BE · Fase be02 de be08 · **10 horas** · ⭐ pieza central
> Depende de: be01 — el monolito responde en el 3000 con datos en memoria
> Habilita: be03
> Apéndices de apoyo: [bea-02 (imagen y compose)](./bea-02-receta-de-imagen-y-compose.md) · [bea-04 (agregaciones como instrumento de medida)](./bea-04-agregaciones-como-instrumento-de-medida.md) · [bea-05 (índices y `explain`)](./bea-05-indices-y-explain-en-mongodb.md) · [bea-03 (embeber o referenciar)](./bea-03-modelar-documentos-embeber-o-referenciar.md) · [bea-12 (datos de prueba y volumen)](./bea-12-datos-de-prueba-y-volumen.md) · [Incidentes asociados](./cuaderno-incidentes-be.md): be-02, be-03

---

## 🎯 1. Propósito

Descubrir, midiendo y no suponiendo, que el modelo Java que escribiste en `be01` describe un sistema que no existe.

Esta fase no construye nada. Es la primera del track que no deja código funcionando, y es a propósito: **antes de conectar la base hay que mirar qué hay dentro de ella**, y lo que hay no se parece a `Patient.java`.

Hasta aquí todo se portaba bien. Escribiste una clase con seis campos tipados, un repositorio, un controller, y todo parecía JPA con otro nombre. Ahora se te entrega un volcado de la colección real de producción —seis años de operación— y se te hace una sola pregunta:

> **¿Cuántas formas distintas del documento de paciente existen en esa colección?**

Son cinco. Ninguna la dice el modelo Java. Y la parte incómoda no es que existan: es que **el repository de Spring te devolvió objetos perfectamente válidos sobre todas ellas, sin una sola excepción**.

> 🧠 **La deriva de esquema no produce errores. Produce campos vacíos.** Un sistema que falla te avisa. Un sistema que silenciosamente te entrega `null` donde había un dato te deja escribir seis años de código encima antes de que alguien note que la pantalla de un paciente de 2019 sale sin nombre.

---

## ✅ 2. Qué queda listo al terminar

- [ ] Tienes `mongo:4.0` corriendo desde el `compose.yaml` y el volcado sintético de producción cargado en la base `labcore`, con las cinco colecciones y sus volúmenes reales.
- [ ] Puedes contestar, con una agregación y no con una suposición, **cuántas claves distintas** aparecen en la colección `patients` y **con qué frecuencia** aparece cada una.
- [ ] Tienes el inventario de **las cinco formas** del documento de paciente, cada una con su recuento, y una hipótesis fechada sobre qué era del sistema en el momento en que se escribió cada forma.
- [ ] Sabes cuántos documentos tienen `birthDate` como `string` y cuántos como `date`, y puedes demostrar que el `Patient.java` de `be01` los lee **todos** sin quejarse.
- [ ] Tienes el número exacto de **órdenes huérfanas** —las que apuntan a un `patientId` que no existe— y el de resultados que cuelgan de muestras inexistentes.
- [ ] Sabes decir, con tres números distintos, cuántos pacientes "no tienen correo", y por qué esa pregunta admite tres respuestas correctas.
- [ ] `MEASUREMENTS.md` existe, con cada medición, la agregación exacta que la produjo, la fecha y el número. **Sin interpretación**: los números primero, el juicio en `be08`.
- [ ] Puedes explicar por qué `findByDocumentId` hizo un `COLLSCAN` sobre la colección entera y por qué nadie lo notó nunca.

---

## 🚫 3. Qué NO entra todavía

- **Arreglar nada.** Ni un `$set`, ni una migración, ni un script de normalización. Esta fase mide. La contención medida es de **be08**, y hay una razón dura: **una corrección aplicada antes de haber medido destruye la evidencia de lo que había**.
- **Servir estos datos a la aplicación.** El backend de `be01` sigue con sus listas en memoria. La costura entre Mongo y el contrato es de **be03**.
- **Índices nuevos.** Se mide el `COLLSCAN` y se explica; crear el índice es de `be03`, donde ya hay tráfico real que lo justifique.
- **Validación con `$jsonSchema`.** Poner un esquema sobre datos sucios es un tema en sí mismo y va entero en **be08** con el apéndice `bea-06`.
- **La conversación sobre migrar a relacional.** Vas a terminar esta fase con ganas de tenerla. Aguántala hasta `be08`, cuando tengas los ocho números en la mano en vez de dos.

---

## 🧠 4. Concepto mínimo

### 4.1 🪞 Tu instinto relacional dice "el esquema está en la base"… y esta vez se equivoca

En el mundo del que vienes, la pregunta *"¿qué forma tienen los pacientes?"* tiene una respuesta y está en un solo sitio: `DESCRIBE patients`. El motor la conoce porque el motor la impone. Si un dato no cabe, no entra.

Aquí no hay ningún sitio así. Y el error es creer que entonces el esquema "no existe": existe, y está en **tres lugares a la vez**, los tres vigentes.

**Está en el código Java de hoy.** `Patient.java` declara seis campos, y esa declaración gobierna todo lo que el sistema escribe **desde hoy**.

**Está en el código Java de ayer.** La versión de esa misma clase que corría en 2019 tenía cinco campos y ninguno se llamaba `active`. Todo lo que se escribió en aquel entonces tiene esa forma, y sigue ahí. El esquema viejo no se fue a ninguna parte: **se quedó dentro de los documentos que creó**.

**Y está en el script de importación que alguien corrió una vez en 2020**, cuando entró la sede que venía del sistema anterior. Ese script no lo escribió el equipo de la aplicación, no está en el repositorio, y nadie recuerda quién lo tenía. Metió documentos con los nombres de campo del sistema de origen. Esos documentos también siguen ahí.

> 🧭 **La regla que gobierna la fase:** en una base sin esquema impuesto, **el esquema es la unión de todos los esquemas que alguna vez estuvieron vigentes**. No hay migración implícita. Lo que se escribió con la forma de 2019 tiene la forma de 2019 hasta que alguien la toque, y nadie la toca.

### 4.2 🩻 Esto sí funciona igual

No todo se te da vuelta, y conviene decir qué se conserva antes de que el capítulo te desoriente.

**Un índice sigue siendo un índice.** Un B-tree, sobre un campo, que convierte un recorrido completo en una búsqueda. Mismo concepto, misma matemática, mismos costos de escritura.

**`explain()` sigue diciéndote si lo usaste.** Cambian los nombres —`COLLSCAN` donde dirías *full table scan*, `IXSCAN` donde dirías *index seek*— y el JSON es más feo, pero la pregunta que contesta es exactamente la misma.

**Un recorrido completo sobre una colección grande sigue siendo caro**, y sigue siendo el primer sospechoso cuando algo tarda.

**Y la integridad referencial sigue importándole a alguien.** Esa es la parte incómoda: que el motor no la imponga no significa que el negocio no la necesite. La necesita igual. Lo único que cambió es **quién tiene que garantizarla**, y la respuesta —nadie— es lo que vas a medir hoy.

### 4.3 El framework de agregación como instrumento de medida

Aquí el marco mental que hace útil esta fase. El framework de agregación de MongoDB se enseña casi siempre como una **API para servir datos**: un `$match`, un `$group`, y devuelves un reporte. En este track no lo vas a usar para eso ni una vez.

Lo vas a usar como **instrumento de medida**: una tubería que no le contesta a un usuario sino a ti, y cuya salida no va a una pantalla sino a `MEASUREMENTS.md`.

Cuatro operadores hacen el 90% del trabajo, y la referencia completa está en [`bea-04`](./bea-04-agregaciones-como-instrumento-de-medida.md):

- **`$objectToArray`** convierte un documento en un arreglo de pares `{k, v}`. Es la llave maestra: permite tratar **los nombres de los campos como datos**, que es exactamente lo que necesitas cuando el problema es que no sabes qué campos hay.
- **`$type`** devuelve el tipo BSON de un valor. Es lo que encuentra el campo que a veces es `string` y a veces `date`.
- **`$group`** cuenta. Aplicado sobre la lista de claves de cada documento, cuenta **formas**.
- **`$lookup`** cruza dos colecciones. Aplicado y después filtrado por resultado vacío, encuentra **referencias rotas**.

> 🧠 **El giro conceptual, y es el que hay que llevarse:** en una base relacional, la forma de los datos es *metadato* y se consulta con un lenguaje aparte (`INFORMATION_SCHEMA`, `DESCRIBE`). Aquí la forma de los datos **es dato**, y se consulta con el mismo lenguaje con el que consultas todo lo demás. Eso es una pérdida —nadie te la impone— y una ganancia —puedes medirla con las herramientas que ya tienes—. La ganancia solo sirve si alguien mira.

### 4.4 Por qué Spring te devolvió objetos válidos sobre datos que no lo son

Esta es la conversación incómoda de la fase, y conviene tenerla antes de las mediciones para que los números signifiquen algo.

Cuando `spring-data-mongodb` lee un documento y lo convierte a tu `Patient`, hace dos cosas y las dos son razonables por separado:

- **Un campo que está en el documento y no en la clase se ignora.** Silenciosamente. Es lo que permite que el régimen de crecimiento de `CONTRACT.md` funcione.
- **Un campo que está en la clase y no en el documento queda en `null`.** Sin aviso, porque el objeto se construye igual.

Junta las dos y tienes el mecanismo: un documento de la forma de 2020, con `name` en vez de `fullName`, se convierte en un `Patient` **perfectamente válido** cuyo `fullName` es `null` y cuyo `name` se descartó por el camino. Ninguna excepción. Ningún log. El objeto existe, tiene su `id`, viaja al controller, se serializa, llega al navegador, y la pantalla muestra una fila con el nombre vacío.

> 🧠 **El mapeo no valida: traduce lo que puede y calla lo que no.** Y esa es exactamente la propiedad que hizo posible que seis años de deriva pasaran inadvertidos. No hubo un día en que el sistema se rompiera. Hubo seis años de pantallas con un campo vacío que alguien reportó tres veces y que se cerraron como "no reproducible" porque el paciente que el que reportaba tenía delante sí tenía nombre.

Y aquí está la simetría que hay que nombrar en voz alta, porque es la misma conversación del track base vista desde el otro lado del cable:

> 🪞 En el frontend, `strict: false` y `any` significan que **nadie valida la forma de lo que llega**. En el backend, el mapeo permisivo significa que **nadie valida la forma de lo que hay guardado**. Es la misma decisión —tolerar— tomada dos veces por dos equipos distintos, y el resultado combinado es un sistema en el que un dato malformado puede viajar desde la base hasta la pantalla sin encontrar **ni una sola** comprobación en el camino. `strict: true` en el frontend y `$jsonSchema` en el backend son la misma frase dicha en dos idiomas.

---

## 💻 5. Código mínimo con comentarios

Nada de Java en esta fase salvo un experimento al final. Todo lo demás es shell y agregaciones.

### 5.1 Levantar la base y cargar el volcado

El `compose.yaml` completo, con su `.env` y sus tres errores típicos, vive en [`bea-02`](./bea-02-receta-de-imagen-y-compose.md). Aquí solo lo que hace falta:

```bash
# La versión de la base vive en el .env, FUERA del código fuente. Recuérdalo:
# en be07 esa línea va a ser el incidente entero.
cat .env
# MONGO_TAG=4.0

docker compose up -d db
docker compose exec db mongo --eval 'db.version()'
# 4.0.28
```

El volcado se entrega con la fase, en `dump/`. Se carga así:

```bash
# Cinco colecciones, cinco archivos. mongoimport viene dentro de la imagen.
for c in patients orders samples results referenceRanges; do
  docker compose exec -T db mongoimport \
    --db labcore --collection "$c" --drop --jsonArray < "dump/$c.json"
done
```

> ⚠️ **Esta es la única vez en todo el track que se te entregan datos ajenos, y la fase lo declara.** El volcado es **sintético**: lo genera `dump/generate-dump.js` con una semilla fija, está documentado en [`bea-12`](./bea-12-datos-de-prueba-y-volumen.md), y es reproducible byte a byte. La razón de que no salga de tu `db.json` es aritmética: veinticinco pacientes no tienen deriva de esquema porque los generó **un solo** programa **una sola** vez. La deriva necesita años y equipos distintos, y eso hay que fabricarlo. A partir de `be03` la semilla vuelve a ser la tuya.
>
> Y como es sintético, tiene la propiedad que un volcado real no tiene: **sabemos la respuesta**. Cuando midas cinco formas, hay cinco de verdad. Un ejercicio de medición sobre datos cuya respuesta nadie conoce no enseña a medir: enseña a creerse el primer número que sale.

Lo primero, siempre, es el tamaño de lo que tienes delante:

```javascript
// Cuántos documentos hay en cada colección. Es la primera medida y la que
// pone en escala todas las demás: "300 huérfanas" significa cosas muy
// distintas sobre 1.000 documentos que sobre 100.000.
db.getCollectionNames().forEach(function (name) {
  print(name + ': ' + db.getCollection(name).count());
});
```

### 5.2 El inventario de claves: qué campos existen de verdad

La primera agregación del track, y la más útil de todas.

```javascript
// Inventario de claves de la colección "patients".
//
// La idea: $objectToArray convierte cada documento en un arreglo de pares
// {k, v}. Al hacer $unwind de ese arreglo, cada CLAVE se vuelve una fila. Y
// una vez que las claves son filas, contarlas es un $group de toda la vida.
//
// Esto es lo que en una base relacional serían dos líneas de
// INFORMATION_SCHEMA. Aquí es esto, y funciona sobre CUALQUIER colección
// sin saber nada de ella de antemano.
db.patients.aggregate([
  { $project: { pairs: { $objectToArray: '$$ROOT' } } },
  { $unwind: '$pairs' },
  { $group: { _id: '$pairs.k', apariciones: { $sum: 1 } } },
  { $sort: { apariciones: -1 } }
]);
```

Una salida como esta —los números son los del volcado que se entrega— es la fase entera en veinte líneas:

```
{ "_id": "_id",         "apariciones": 4820 }
{ "_id": "documentId",  "apariciones": 4820 }
{ "_id": "birthDate",   "apariciones": 4820 }
{ "_id": "fullName",    "apariciones": 4102 }   <- no está en todos
{ "_id": "active",      "apariciones": 3355 }   <- ni de lejos
{ "_id": "email",       "apariciones": 3190 }
{ "_id": "contact",     "apariciones":  912 }   <- ¿y esto qué es?
{ "_id": "name",        "apariciones":  718 }   <- ¿¿y esto??
{ "_id": "_source",     "apariciones":  718 }
{ "_id": "phone",       "apariciones":   64 }
```

**Detalles con intención**

- `$$ROOT` es el documento entero. Sin él tendrías que nombrar los campos, que es justo lo que no puedes hacer.
- **Las dos líneas que importan son `name` y `contact`**, y no porque sean muchas: porque **no existen en `Patient.java`**. Cada una es un pedazo de historia del sistema que el código actual no sabe leer. Los 718 documentos con `name` son la importación de 2020. Los 912 con `contact` son un cambio de 2021 que se aplicó a los nuevos y a nadie más.
- `fullName` aparece 4.102 veces sobre 4.820 documentos. La resta —718— es exactamente el otro número. Cuando dos mediciones independientes suman el total, tienes una hipótesis; cuando no suman, tienes un tercer caso que todavía no viste.
- `email` aparece 3.190 veces, y 4.820 − 3.190 = 1.630. Esa resta **no** cuadra con ninguna forma sola: son dos (718 + 912). Guárdala, porque es la mitad de la pieza forense del §5.6.
- `phone` aparece 64 veces **al nivel superior**, y `contact.phone` no aparece en este inventario porque `$objectToArray` solo abre el primer nivel. Los subdocumentos necesitan otra pasada, y ese es el ejercicio 9.

### 5.3 Contar formas, no campos

Saber qué claves existen no es saber cuántas formas hay. Para eso hay que agrupar por **el conjunto de claves de cada documento**, y ahí aparece el primer detalle traicionero.

```javascript
// Las FORMAS del documento de paciente, con su recuento.
//
// OJO con el orden: en BSON las claves están ordenadas por inserción, así
// que {a,b} y {b,a} son arreglos distintos y $group los contaría como dos
// formas. Por eso hay un $unwind + $sort + $group intermedio: es la manera
// de obtener una lista de claves CANÓNICA (ordenada alfabéticamente) sin
// $sortArray, que no existe en Mongo 4.0.
db.patients.aggregate([
  { $project: { pairs: { $objectToArray: '$$ROOT' } } },
  { $unwind: '$pairs' },
  { $sort: { '_id': 1, 'pairs.k': 1 } },
  { $group: { _id: '$_id', claves: { $push: '$pairs.k' } } },
  { $group: { _id: '$claves', documentos: { $sum: 1 } } },
  { $sort: { documentos: -1 } }
]);
```

Y esta es la respuesta a la pregunta con la que abrió la fase:

| # | Forma (claves, sin `_id`) | Documentos | Hipótesis de origen |
|---|---|---|---|
| **A** | `documentId, fullName, birthDate, email, active` | 2.379 | La actual. Lo que `Patient.java` cree que hay |
| **B** | `documentId, fullName, birthDate, email` | 747 | **Era 1 (2019).** `active` no existía: la baja lógica llegó después |
| **C** | `documentId, name, birthDate, _source` | 718 | **La importación de 2020.** `name`, no `fullName`. Y **sin correo**: el sistema de origen no lo traía |
| **D** | `documentId, fullName, birthDate, contact, active` | 912 | **Era 3 (2021).** El correo se movió a un subdocumento… para los nuevos |
| **E** | `documentId, fullName, birthDate, email, phone, active` | 64 | Un intento anterior del mismo cambio, con `phone` al nivel superior. Duró tres semanas |

> 🧠 **Esas cinco filas son cinco decisiones de producto, cada una razonable el día que se tomó, y ninguna acompañada de una migración.** Ese es el patrón, y no es de MongoDB: es de cualquier sistema donde cambiar la forma de los datos nuevos sea barato y cambiar la de los viejos sea un proyecto. Lo que MongoDB hizo fue quitar la fricción que en un motor relacional te habría **obligado** a decidir qué hacer con los 747 documentos viejos. La fricción era el mecanismo de defensa, y era lo que el equipo de 2019 quería quitarse de encima. Lo consiguieron.

**El patrón a memorizar:** *un cambio de forma sin migración no es un cambio: es una bifurcación.* A partir de ese día hay dos poblaciones y todo el código que las lea tiene que saber leer las dos, para siempre, aunque nadie lo escriba en ninguna parte.

### 5.4 El campo que a veces es una cosa y a veces otra

Las formas cuentan claves. El tipo es otra dimensión, y es la que de verdad rompe código.

```javascript
// ¿De qué tipo es birthDate? La pregunta suena tonta hasta que la contestas.
db.patients.aggregate([
  { $group: { _id: { $type: '$birthDate' }, documentos: { $sum: 1 } } },
  { $sort: { documentos: -1 } }
]);
```

```
{ "_id": "string", "documentos": 3908 }
{ "_id": "date",   "documentos":  912 }
```

Novecientos doce documentos guardan la fecha de nacimiento como `BSON Date` y el resto como cadena `"1984-03-12"`. Son exactamente los 912 de la forma **D**: quien hizo aquel cambio de 2021 tocó dos cosas a la vez —el correo y el enlace de la fecha— y solo declaró una.

Ahora la parte que hay que ver con los propios ojos, porque leída no impresiona:

```javascript
// Un documento de cada tipo, lado a lado.
db.patients.find({ birthDate: { $type: 'string' } }, { documentId: 1, birthDate: 1 }).limit(1);
db.patients.find({ birthDate: { $type: 'date'   } }, { documentId: 1, birthDate: 1 }).limit(1);
```

```
{ "_id": ..., "documentId": "CC-1032456789", "birthDate": "1984-03-12" }
{ "_id": ..., "documentId": "CC-1098765432", "birthDate": ISODate("1991-11-02T00:00:00Z") }
```

**Y el `Patient.java` de `be01` lee los dos sin quejarse**, porque su `birthDate` es un `String` y el convertidor de Spring Data hace la conversión que puede. El segundo llega al navegador como `"1991-11-02T00:00:00Z"` y el primero como `"1984-03-12"`. Dos formatos distintos en la misma columna de la misma tabla de la pantalla, y ninguna excepción en ninguna capa.

> ⚠️ **Y hay una consecuencia peor que la cosmética, que es la que hay que anotar en `MEASUREMENTS.md`:** una consulta por rango de fechas de nacimiento —"pacientes menores de 18 años", que el dashboard podría querer— compara cadenas contra fechas. En BSON, los tipos se ordenan entre sí antes de ordenarse dentro de cada tipo, así que **una fecha y una cadena nunca se comparan como esperas**: la consulta no falla, devuelve menos filas. Un reporte que sale corto y no se queja. Búscalo en el ejercicio 20.

### 5.5 Las referencias que nadie garantizó

```javascript
// Órdenes que apuntan a un paciente que no está.
//
// $lookup es el JOIN, con dos diferencias que importan: devuelve un ARREGLO
// (no multiplica filas) y no hay ninguna restricción que impida que ese
// arreglo salga vacío. El $match de abajo es, literalmente, "las que no
// encontraron a nadie".
db.orders.aggregate([
  { $lookup: {
      from: 'patients',
      localField: 'patientId',
      foreignField: 'legacyId',   // el id entero del contrato; ver be03
      as: 'patient'
  }},
  { $match: { patient: { $size: 0 } } },
  { $count: 'orphanOrders' }
]);
```

```
{ "orphanOrders": 37 }
```

Treinta y siete órdenes médicas apuntan a un paciente que no existe. Las preguntas que hay que contestar **por escrito** en `MEASUREMENTS.md`, y ninguna es retórica:

1. ¿Se borraron esos pacientes, o nunca existieron? (Pista: cruza con `_source`. Si los huérfanos se concentran en la importación de 2020, no se borró nada: llegaron rotos.)
2. ¿Qué muestra hoy la pantalla de órdenes para esas treinta y siete? Ábrela y míralo. La respuesta —una columna vacía, sin error— es el incidente **be-02**.
3. ¿Cuántas de esas órdenes tienen resultados **validados** colgando? Porque una orden huérfana sin resultados es basura; una con un resultado validado es **un informe clínico emitido a un paciente que el sistema no puede identificar**, y eso tiene otro nombre en una auditoría.

Repite la medición hacia abajo en la cadena —muestras que apuntan a órdenes que no están, resultados que apuntan a muestras que no están— y anota los tres números juntos. La forma de esa tabla dice más que los números sueltos: si la rotura se concentra en un eslabón, hubo un evento; si está repartida, hubo seis años.

> 💡 En una base relacional, esta agregación es innecesaria porque la respuesta es siempre cero: la clave foránea no dejó entrar la fila. Merece la pena decirlo sin dramatismo: **eso es lo que se compró con la velocidad de esquema de 2019**. No fue gratis; fue a plazos, y esta es una de las cuotas.

### 5.6 La pieza forense: el `null` que es tres cosas

Aquí está el material más transferible de la fase, y el más fácil de equivocar.

Pregunta de negocio, trivial: *¿a cuántos pacientes no les podemos mandar el informe por correo?*

```javascript
// Intento 1, el que hace todo el mundo. Y está MAL.
db.patients.count({ email: null });     // 2536
```

```javascript
// Intento 2: los tres casos, separados.
db.patients.count({ email: { $exists: false } });      // 1630  campo AUSENTE
db.patients.count({ email: { $type: 'null' } });       //  906  campo con valor null
db.patients.count({ email: '' });                      //  247  cadena vacía
```

Mira los números. `1630 + 906 = 2536`, que es exactamente lo que devolvió el intento 1: **`{ email: null }` en MongoDB significa "el campo es null O el campo no existe"**. No es un error del motor; es su semántica documentada, y es la que hace que una consulta razonable dé un número razonable que resulta ser la suma de dos poblaciones distintas. Y los 247 de la cadena vacía **no están en ninguno de los dos**: se quedan fuera de la cuenta y son, en la práctica, el mismo problema de negocio.

La respuesta correcta a la pregunta del negocio es **2.783**, y no la da ninguna consulta de una línea.

Los tres casos son tres historias distintas, y esa es la parte que hay que llevarse:

- **Ausente (1.630):** documentos de las formas **C** y **D**. En la C el sistema de origen no traía correo; en la D el correo está, pero un nivel más abajo, dentro de `contact`. Dos historias distintas que la misma consulta mete en el mismo saco.
- **`null` (906):** el campo existe y está vacío. Alguien lo escribió explícitamente: un formulario que envió el campo sin valor. **Hubo una interacción.**
- **Cadena vacía (247):** alguien escribió algo, lo borró, y guardó. Es un `null` distinto: es un `null` con intención.

Y ahora el remate, que es donde la fase se cierra sobre sí misma:

> 🧠 **Las tres llegan a tu `Patient.java` como el mismo `null`.** El getter devuelve `null` en los tres casos y el objeto es indistinguible. **La información de qué tipo de vacío era se destruye en el mapeo**, y una vez destruida no se puede recuperar desde Java: hay que bajar a la agregación. Esa es, exactamente, la misma conversación que `strict: true` tiene en el frontend —¿`undefined` y `null` son lo mismo?— vista desde el otro lado del cable y con seis años de datos encima.

🧨 **Rompe a propósito.** Levanta el backend de `be01`, apúntalo a estos datos con un repositorio de prueba, y pide los tres grupos por su `documentId`. Serializa las tres respuestas y compáralas byte a byte. Después contesta: ¿qué tendría que cambiar en el modelo Java para poder distinguirlas? Y la pregunta de verdad: **¿querrías distinguirlas?** El coste de esa distinción se paga en todas las capas, para siempre, y solo hay dos o tres sitios donde importa. Esa es la forma canónica de una decisión de mantenimiento, y no tiene respuesta obvia.

### 5.7 El `COLLSCAN` que el repository escondía

```javascript
// La consulta que el validador asíncrono del formulario dispara con cada
// tecla que el operador escribe en el campo de documento.
db.patients.find({ documentId: 'CC-1032456789' }).explain('executionStats');
```

De toda esa salida —que `bea-05` desmenuza— importan cuatro líneas:

```
"stage": "COLLSCAN",
"nReturned": 1,
"totalDocsExamined": 4820,
"executionTimeMillis": 12
```

**Examinó 4.820 documentos para devolver 1.** Y tardó doce milisegundos, que es la razón exacta de que nadie lo haya notado nunca: con este volumen, el recorrido completo es más rápido que la percepción humana. Con diez veces más datos son ciento veinte milisegundos, y con cien veces, más de un segundo — por cada tecla.

> 🩻 **Esto sí funciona igual, y por eso se te da bien.** El diagnóstico es idéntico al que harías en cualquier motor relacional: `explain`, mirar si hubo índice, mirar la relación entre documentos examinados y devueltos. Que esa relación sea 4820:1 significa lo mismo aquí que allá. **Tu instinto de índices está intacto y no hay que recalibrarlo.** Lo único que cambió es que aquí nadie te obligó a crear la clave primaria alternativa que el negocio necesita.

El índice **no se crea en esta fase**. Se mide, se anota en `MEASUREMENTS.md` con los cuatro números, y se crea en `be03`, cuando el backend sirva tráfico de verdad y el `before/after` signifique algo.

### 5.8 `MEASUREMENTS.md` — el archivo que `be08` va a consumir

Formato fijo, sin adornos y **sin interpretación**. Cada medición, cuatro campos:

````markdown
### M-04 · Órdenes huérfanas

- **Pregunta:** ¿cuántas órdenes apuntan a un paciente inexistente?
- **Agregación:** [el pipeline exacto, copiable]
- **Fecha:** 2026-09-10 · **Base:** `labcore` sobre `mongo:4.0.28`, volcado `dump/` semilla 20190902
- **Resultado:** `37` sobre `4180` órdenes (0,89 %)
- **Notas:** 31 de las 37 tienen `_source: legacy-import` en su rastro. 6 no.
````

Tres reglas para este archivo, y las tres tienen motivo:

1. **La agregación va copiada entera**, no descrita. Dentro de seis meses vas a querer volver a correrla y comparar, y una descripción no se ejecuta.
2. **La fecha y la versión de la base van siempre.** En `be07` la base va a subir cuatro versiones mayores y vas a querer saber cuál de estos números se midió antes y cuál después.
3. **Ni una palabra de juicio.** Nada de "preocupante", "inaceptable" ni "hay que arreglar". Los números aquí; el juicio, firmado y fechado, en `be08`. Un documento de medición contaminado de opinión deja de servir como prueba justo cuando más falta hace.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Síntoma: el conteo de formas da veintitantas en vez de cinco.**
Causa: falta el `$sort` intermedio del §5.3 y estás agrupando por listas de claves en orden de inserción, así que la misma forma con las claves en otro orden cuenta aparte. Fix mínimo: el `$unwind` + `$sort` + `$group` que canoniza el orden. Y anota el hallazgo: **el orden de las claves en un documento BSON es significativo y se conserva**, cosa que en un JSON de JavaScript casi nunca te importó.

**Síntoma: `{ email: null }` devuelve más de lo que esperas.**
Causa: la semántica de `null` en el lenguaje de consulta incluye el campo ausente. No es un bug. Fix mínimo: `$type: 'null'` cuando quieras decir *"existe y vale null"*, y `$exists: false` cuando quieras decir *"no está"*. Escríbelo en `MEASUREMENTS.md` porque lo vas a volver a olvidar.

**Síntoma: `$lookup` devuelve arreglos vacíos para todo.**
Causa: `localField` y `foreignField` no son del mismo tipo. Un `patientId` entero contra un `legacyId` que quedó guardado como cadena en algunos documentos **no casa**, y no avisa. Fix mínimo: mide primero el `$type` de los dos campos, siempre, antes de creerte el resultado de un cruce.

**Síntoma: una medición da un número distinto cada vez que la corres.**
Causa: cargaste el volcado sin `--drop` y tienes documentos duplicados. Fix mínimo: recargar. Y la lección de fondo, que `bea-12` desarrolla: **un conjunto de datos no determinista arruina una medición y arruina una prueba de regresión**. La semilla fija del generador no es una comodidad, es un requisito.

### Pieza forense de esta fase

Está en el §5.6 y es **el `null` que en Java llega como `null` y en la base es tres cosas distintas**. No la repetimos aquí; lo que sí va aquí es cómo se cierra, que es lo que la convierte en forense y no en curiosidad:

**El método, aplicado.** Las cuatro preguntas del track forense, contestadas sobre este caso concreto:

1. **¿Qué se ve?** Una pantalla de pacientes donde algunas filas no tienen correo, y un reporte de "pacientes sin correo" cuyo total nunca cuadra con el que da Operaciones.
2. **¿Qué capa lo produce?** Ninguna. Ese es el hallazgo: no hay una capa culpable. El dato entró vacío de tres maneras distintas a lo largo de seis años y todas las capas lo transportaron correctamente.
3. **🧬 ¿Lo escribió el sistema o llegó roto en el dato?** Las tres cosas a la vez, y por eso hay tres poblaciones. Esta pregunta —la propia del track— es la que separa un bug de una deriva.
4. **¿Con qué se demuestra?** Con las tres consultas del §5.6 y sus tres números, que suman el cuarto. Un argumento; tres números.

Esta fase **no tiene archivo `forense-fase-NN.md`**: la pieza forense del track BE es una agregación y vive junto al código que la produce ([guía §16.2](./prompts/guia-de-estilo-y-convenciones.md)).

---

## 🧪 7. Ejercicios (33)

**🟢 Fácil (1–9)**

1. Carga el volcado y confirma los cinco recuentos de colección. Anótalos en `MEASUREMENTS.md` como M-01.
2. Corre el inventario de claves del §5.2 sobre `patients` y reproduce la tabla. Confirma que `fullName` + `name` suman el total de documentos.
3. Corre el mismo inventario sobre `orders`, `samples` y `results`. Anota qué colección tiene **menos** deriva y aventura por qué.
4. Cuenta las formas del documento de paciente con el pipeline del §5.3 y confirma que son cinco.
5. Encuentra los 718 documentos con `_source: "legacy-import"` y comprueba que **todos** tienen `name` y **ninguno** tiene `fullName`.
6. Corre el `$type` sobre `birthDate` y confirma la partición 3908 / 912. Después hazlo sobre `documentId` y anota si hay sorpresas.
7. Muestra un documento de cada una de las cinco formas, lado a lado, en `MEASUREMENTS.md`. Es el anexo más consultado del archivo.
8. Corre el `explain('executionStats')` del §5.7 y anota las cuatro líneas que importan.
9. `$objectToArray` solo abre el primer nivel. Escribe la agregación que inventaría las claves **dentro** de `contact` y anota cuántas variantes tiene ese subdocumento.

**🟡 Intermedio (10–19)**

10. Mide las órdenes huérfanas y cruza el resultado con `_source`: ¿cuántas de las 37 vienen de la importación de 2020? Anota qué cambia esa proporción en tu hipótesis.
11. Repite la medición de huérfanos hacia abajo: muestras sin orden, resultados sin muestra. Presenta los tres números en una tabla y escribe una frase sobre su forma.
12. De las órdenes huérfanas, cuenta cuántas tienen al menos un resultado en estado `validated`. Ese número, y no el 37, es el que va en el correo al jefe.
13. Reproduce el ejercicio de los tres `null` del §5.6 y confirma que `1630 + 906 = 2536`. Escribe en dos líneas por qué esa suma es una demostración y no una coincidencia.
14. Escribe la consulta que devuelve el número **correcto** de pacientes sin correo utilizable —los tres casos juntos— en un solo pipeline. Compárala en legibilidad con las tres consultas separadas y decide cuál va a `MEASUREMENTS.md`.
15. Usa `$facet` para obtener en **una sola pasada** el recuento de formas, la partición por tipo de `birthDate` y los tres casos de `email`. Mide el tiempo de las dos versiones —una pasada contra tres— sobre esta colección y anota si la diferencia justifica la complejidad.
16. **Diagnóstico.** Toma un paciente de la forma **C** (`name`, sin `fullName`), búscalo en la pantalla de pacientes de la aplicación y describe exactamente qué ve el operador. Después localiza en qué capa se perdió el nombre.
17. **Diagnóstico.** Un compañero dice que su `$lookup` "no encuentra nada". Reprodúcelo cruzando por un campo cuyo tipo difiera entre las dos colecciones, y explica por qué el resultado es un arreglo vacío y no un error.
18. **Diagnóstico.** El validador de documento duplicado del formulario "a veces no detecta el duplicado". Busca en `patients` los `documentId` que aparezcan más de una vez con `$group` + `$match`, y después mira si alguno difiere solo en el guion (`CC-10…` contra `CC10…`). Anota cuántos pares hay.
19. Crea el índice sobre `documentId` en una copia de la colección, vuelve a correr el `explain`, y anota los cuatro números otra vez. **No lo crees en la colección principal**: `be03` lo hace con su before/after.

**🟠 Difícil (20–27)**

20. **Diagnóstico.** Escribe la consulta "pacientes nacidos después del 1 de enero de 2000" y ejecútala. Cuenta cuántos devuelve. Después cuenta a mano cuántos debería devolver, sumando las dos poblaciones de tipo. Explica la diferencia usando el orden de tipos de BSON, y anota por qué esta consulta **es peor que una que falla**.
21. Escribe la agregación que, para cada forma del documento, dé el rango de fechas de creación de los documentos que la tienen. Con eso, fecha las cinco formas y compara tu resultado con las hipótesis del §5.3. Anota en cuál te equivocaste.
22. **Diagnóstico.** Sobre `results`, mide cuántos tienen `rangeVersionApplied` en `null` estando en estado `validated`. Ese número es un adelanto de `be06`: son resultados firmados sin decir contra qué norma. No lo arregles; anótalo y ponle nombre.
23. **Diagnóstico.** El repositorio de `be01` devuelve `Patient` con `fullName: null` para 718 documentos y ninguna excepción. Escribe la prueba mínima que lo demuestra, y después responde: ¿qué configuración de Spring Data habría hecho fallar esa lectura? Impleméntala en una rama, mide cuántas lecturas de la colección real reventarían, y **revierte**.
24. Mide el tamaño en disco de `patients` con `db.patients.stats()` y calcula cuánto ocupan los 718 documentos de la importación con su `_source` redundante. Contesta si eliminar ese campo valdría la pena, con el número delante.
25. **Diagnóstico + diseño.** Los 912 documentos con `contact` embebido y los 3.908 con `email` al nivel superior son la misma información en dos sitios. Apoyándote en [`bea-03`](./bea-03-modelar-documentos-embeber-o-referenciar.md), escribe las tres opciones —normalizar hacia arriba, normalizar hacia abajo, o leer las dos formas para siempre— con su costo en horas y su riesgo. Recomienda una y defiéndela sabiendo que el sistema tiene dos años de vida.
26. **Diagnóstico.** Genera con `bea-12` un volcado diez veces más grande y repite las mediciones del §5.2, §5.5 y §5.7. Anota cuáles escalan linealmente y cuál no. La que no, es la que va a doler en producción.
27. Escribe una agregación que detecte **formas nuevas**: dado el conjunto de cinco formas conocidas, que devuelva los documentos que no encajan en ninguna. Ese pipeline es el que dejarías corriendo cada semana en un sistema vivo, y es la mitad de lo que `$jsonSchema` hará en `be08` de forma declarativa.

**🔴 Muy difícil (28–33)**

28. **Adversarial.** Alguien propone arreglar la deriva con un script de normalización que ponga las 4.820 filas en la forma **A**. Escríbelo. Después, **antes de correrlo**, enumera qué información se destruiría de forma irreversible —piensa en los tres tipos de `null` y en `_source`—, y decide. Si decides no correrlo, escribe el párrafo que se lo explica a quien lo propuso.
29. **Diagnóstico.** Toma las 37 órdenes huérfanas y reconstruye, solo con lo que hay en la base, la historia más probable de cómo llegaron ahí. Usa fechas, `_source` y la forma de los documentos vecinos. Presenta la hipótesis con su evidencia y, sobre todo, **con lo que la refutaría**.
30. **Diseño.** El equipo tiene ocho horas al trimestre para deuda de datos. Ordena todas las mediciones de esta fase por *(daño si no se toca) / (costo de tocarlo)*, y defiende el primer puesto contra alguien que sostenga que lo primero es la integridad referencial. La fecha de decomisión es parte del argumento.
31. **Adversarial.** Argumenta bien la posición contraria a la fase: *"esto no es deriva, es evolución sana; el sistema lleva seis años funcionando y los cinco formatos conviven sin incidentes graves"*. Dale sus mejores razones —incluida la de que ninguna de estas mediciones corresponde a un ticket abierto— y después refútala con el único argumento que no admite réplica: el que un auditor usaría.
32. **Diagnóstico y escritura.** Escribe el post-mortem de ocho puntos del incidente **be-03** —el reporte de "pacientes sin nombre" que se cerró tres veces como no reproducible— con el formato del cuaderno y sin culpabilización. Incluye el test de regresión: la agregación semanal del ejercicio 27.
33. **La medición que cierra la fase.** Con todo lo anterior en `MEASUREMENTS.md`, escribe una sola página titulada *"Qué hay de verdad guardado en LabCore"*, dirigida a alguien técnico que no ha visto la base. Solo hechos y números, sin recomendaciones. Esa página es el primer capítulo del documento que vas a firmar en `be08`, y la escribes ahora porque ahora tienes los datos frescos y todavía no tienes una tesis que defender.

**🔥 Opcionales**

- 🔥 Reescribe tres de las agregaciones de esta fase usando `$expr` y compara la legibilidad. Anota cuáles quedan mejor y cuáles peor.
- 🔥 Exporta el resultado del inventario de claves a CSV y dibuja las cinco formas en una línea de tiempo. Es la imagen que vas a poner en la presentación de `be08`, y es la que hace entender el problema a alguien que no lee agregaciones.
- 🔥 Corre las mismas mediciones sobre `mongo:7.0` cambiando una línea del `.env` y anota qué agregación deja de funcionar y cuál cambia de salida. Guarda ese resultado sin mirarlo mucho: es el material de `be07` y ahí lo vas a necesitar.

---

## 📚 8. Referencias

**Documentación oficial**

- MongoDB 4.0 — referencia del framework de agregación, que es la versión que corre tu base: https://www.mongodb.com/docs/v4.0/aggregation/ ⚠️ La documentación "current" describe operadores que **no existen** en 4.0 (`$sortArray`, `$getField`, `$function`). Comprueba siempre el selector de versión.
- `$objectToArray`: https://www.mongodb.com/docs/v4.0/reference/operator/aggregation/objectToArray/
- `$type` como operador de consulta y como operador de agregación —son dos cosas distintas con el mismo nombre—: https://www.mongodb.com/docs/v4.0/reference/operator/query/type/
- Comparación y orden de tipos BSON, que es lo que explica el ejercicio 20: https://www.mongodb.com/docs/v4.0/reference/bson-type-comparison-order/
- `$lookup`: https://www.mongodb.com/docs/v4.0/reference/operator/aggregation/lookup/
- `explain()` y sus tres modos: https://www.mongodb.com/docs/v4.0/reference/method/cursor.explain/
- Spring Data MongoDB 2.1 — el capítulo de mapeo, que explica por qué un campo sobrante se ignora y uno faltante queda en `null`: https://docs.spring.io/spring-data/mongodb/docs/2.1.x/reference/html/#mapping-chapter

**Libros y artículos de referencia**

- Martin Kleppmann, *Designing Data-Intensive Applications* (2017), capítulo 4 — *schema-on-read* contra *schema-on-write*. Son doce páginas y son la teoría completa de esta fase: la elección no es "con esquema o sin esquema", es **cuándo** se aplica.
- Pramod Sadalage y Martin Fowler, *NoSQL Distilled* (2012), capítulos 3 y 8 — el concepto de *agregado* y la migración de esquema en bases sin esquema declarado. Escrito en el momento exacto en que se tomaban decisiones como la de LabCore.
- Michael Feathers, *Working Effectively with Legacy Code* (2004), capítulo 16 — *"I don't understand the code well enough to change it"*. El método es el de esta fase: caracterizar antes de tocar.

**Video y apoyo**

- Charlas de MongoDB World (2018-2021) sobre patrones de versionado de documentos —*schema versioning pattern*—: https://www.youtube.com/results?search_query=mongodb+schema+versioning+pattern — es la solución que LabCore **no** aplicó, y verla explica por qué un campo `schemaVersion` en cada documento habría convertido esta fase en una consulta de una línea.

**Orden de lectura sugerido:** Kleppmann cap. 4 **antes** de medir nada, porque da el vocabulario → `bea-04` mientras escribes las agregaciones, como referencia abierta al lado → la página de orden de tipos BSON justo antes del ejercicio 20, que sin ella no tiene solución → Sadalage y Fowler al final, cuando los números ya estén en `MEASUREMENTS.md` y quieras saber si esto le pasó solo a tu equipo (no).

> ⚠️ URLs y contenidos cambian. Con MongoDB, además, el mayor riesgo del track: **casi toda la documentación y todas las respuestas de foros que encuentres describen versiones muy posteriores a la 4.0**. Un operador que "existe" según la web puede no existir en tu base, y el error que devuelve no siempre lo dice claro.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Terminas esta fase sin haber escrito una línea de producción y con lo más valioso que produce el track: **números**. Cinco formas, 912 fechas de otro tipo, 37 órdenes huérfanas, tres poblaciones distintas de vacío, y un `COLLSCAN` de 4.820 a 1.

Y con algo que no es un número y pesa más: el reflejo de **no volver a suponer la forma de una colección a partir del modelo del código**. Ese reflejo es lo que esta fase venía a instalar, y es lo único de todo el track que sirve igual en cualquier base y en cualquier lenguaje.

**be03** es la bisagra: apagas el mock, levantas el contenedor en el puerto 3000, y la aplicación no se entera. Todo lo que mediste hoy se convierte allí en una decisión concreta: cómo se traduce un `ObjectId` a un `id` entero, qué hace el backend cuando lee un documento de la forma **C**, y cómo se sirve una paginación que el sistema nunca tuvo sin cambiar ni una línea del frontend. Vas a servir datos que ya sabes que están sucios, y esa es exactamente la posición de un equipo de mantenimiento de verdad.

> **La señal de que quedó bien:** *"ya no le pregunto al código qué forma tienen los datos. Se lo pregunto a los datos, y tengo el pipeline guardado para volver a preguntárselo dentro de seis meses."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en verde y `git status` limpio:
>
> ```bash
> git tag -a be-fase-02-medir-la-deriva-de-esquema -m "be02 cerrada: volcado cargado; 5 formas medidas y fechadas; particion de tipos de birthDate; 37 órdenes huérfanas; los tres nulls; COLLSCAN documentado; MEASUREMENTS.md con 8 mediciones"
> ```
>
> Los commits de la fase llevan su prefijo (`be02: …`) y los de ejercicio su número (`be02 ej20: …`). El track BE usa el namespace `be-fase-*`. Todo eso está en [`00-convencion-de-git-y-tags.md`](./00-convencion-de-git-y-tags.md) §10.

---

## 📌 Pendientes sugeridos

- **[A] La forma del volcado sintético queda cerrada aquí** —cinco formas del documento de paciente con los recuentos de la tabla del §5.3, 37 órdenes huérfanas, la partición 3908/912 de `birthDate` y las tres poblaciones de `email`—, con el generador determinista documentado en `bea-12`. Ninguna fase posterior cambia esos números sin actualizar `MEASUREMENTS.md` y esta tabla a la vez.
- **[B] `bea-12` tiene que existir antes que esta fase se pueda hacer**, porque de ahí sale `generate-dump.js`. Es el apéndice más urgente del track junto con `bea-02`.
- **[C] El campo `legacyId`** aparece en el `$lookup` del §5.5 y su definición completa es de `be03` (la traducción `ObjectId` ↔ `id` entero). Aquí se usa como dato del volcado. Si `be03` decide otro nombre, esta fase se edita.
- **[D] El índice sobre `documentId` se mide aquí y se crea en `be03`.** Si `be03` se retrasa, no adelantarlo: el valor pedagógico está en el before/after con tráfico real.
- **[E] Los resultados `validated` con `rangeVersionApplied` en `null`** (ejercicio 22) son material de `be06` y aquí solo se cuentan. No sacar conclusiones todavía: la explicación completa necesita la historia de los rangos.
- **[F] El generador del volcado y el `seed.js` del track base coexisten** y hacen cosas distintas. Vigilar que nadie los mezcle: uno produce datos limpios para el frontend, el otro datos sucios para medir.

### Reservas para el cuaderno de incidentes

| ID | Título propuesto | Categoría | Dificultad |
|---|---|---|---|
| **be-02** | *"La orden sin paciente"* | Integridad referencial | 🟠 |
| **be-03** | *"Los pacientes sin nombre que nadie pudo reproducir"* | Deriva de esquema | 🔴 |

**be-02** llega como *"en la lista de órdenes hay filas donde la columna del paciente sale vacía, pero solo algunas y no siempre las mismas"*. La causa es una orden huérfana y el hecho de que el selector cruzado del frontend devuelve `undefined` sin quejarse. Se puede resolver a partir de esta fase.

**be-03** es el bueno, y llega como un ticket reabierto tres veces: *"un usuario dice que hay pacientes sin nombre; lo revisamos y no pudimos reproducirlo"*. No se reproduce porque quien lo revisó buscó pacientes recientes, y los 718 afectados son todos de la importación de 2020. El post-mortem tiene que llegar a la regla: **"no reproducible" casi siempre significa "no reproducible con los datos que yo miré"**, y en un sistema con deriva, los datos que miras son los más nuevos.
