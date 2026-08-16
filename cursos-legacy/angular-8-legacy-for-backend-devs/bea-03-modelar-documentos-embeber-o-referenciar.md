# 📎 Apéndice bea-03 — Modelar documentos: ¿embeber o referenciar?

> Tutorial Angular 8 — Laboratorio clínico · 🔥 Track BE · Consulta rápida · **3 horas**
> Usado por: be02, be03, be06 · Versiones cubiertas: MongoDB 4.0 y 7.0, `spring-data-mongodb` 2.1

**Esto no se lee de corrido.** Se entra con una entidad concreta delante y la pregunta *"¿esto va dentro o va aparte?"*, se sale con una respuesta y con el precio de esa respuesta anotado.

Resuelve una cosa: **poner nombre y criterio a la decisión que el equipo de 2019 tomó cinco veces sin escribirla.** Porque la tomó —hay cinco entidades y cinco respuestas— y en ningún sitio consta por qué.

**Qué queda fuera:** el sharding y todo lo de escala horizontal, porque LabCore es un `mongod` suelto y no va a dejar de serlo (ver [`bea-07`](./bea-07-transacciones-replica-sets-y-el-standalone.md)); los índices, que son de [`bea-05`](./bea-05-indices-y-explain-en-mongodb.md); y las transacciones, que son de `bea-07`.

---

## Índice

- [1. El criterio, en una frase](#1-el-criterio-en-una-frase)
- [2. 📖 Diccionario de traducción](#2--diccionario-de-traducción)
- [3. El límite de 16 MB, y qué pasa mucho antes](#3-el-límite-de-16-mb-y-qué-pasa-mucho-antes)
- [4. El arreglo que crece sin techo](#4-el-arreglo-que-crece-sin-techo)
- [5. La referencia manual, y por qué no hay claves foráneas](#5-la-referencia-manual-y-por-qué-no-hay-claves-foráneas)
- [6. `$lookup` y lo que cuesta de verdad](#6-lookup-y-lo-que-cuesta-de-verdad)
- [7. Las cinco entidades de LabCore, con veredicto](#7-las-cinco-entidades-de-labcore-con-veredicto)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-8)

---

## 1. El criterio, en una frase

> 🧭 **Se embebe lo que se lee junto y se escribe junto. Se referencia todo lo demás.**

Las dos mitades son necesarias y la segunda se olvida siempre. Un dato que **se lee** siempre con su padre pero que **se escribe** por su cuenta —porque crece, porque lo actualiza otro proceso, porque lo edita otra pantalla— embebido es una fuente de conflictos de escritura y de documentos que crecen sin control.

Del criterio salen tres preguntas que se contestan mirando el código del cliente, no el diagrama:

1. **¿Alguien pide esto sin su padre?** Si sí, referenciar. Si la respuesta es "hoy no, pero…", referenciar igual: ese "hoy no" caduca.
2. **¿Cuántos hay, y hay techo?** Uno o "unos pocos con techo conocido" se embebe. "Los que haya" se referencia, sin excepción.
3. **¿Se escriben a la vez?** Si el hijo cambia sin que el padre cambie, cada escritura del hijo reescribe el documento del padre entero. Piénsalo dos veces.

> 🧠 **Y la razón por la que esto importa más aquí que en un motor relacional:** al embeber estás eligiendo **la unidad de atomicidad**. La escritura de un documento es atómica siempre y en cualquier topología; lo que cae en documentos distintos no tiene ninguna garantía conjunta —y en LabCore, que es un standalone, tampoco la puede tener con transacciones—. **Embeber no es solo una decisión de rendimiento: es la única forma que tiene este sistema de que dos cosas pasen juntas.** Esa frase es media fase `be05`.

---

## 2. 📖 Diccionario de traducción

En las dos direcciones, porque las dos hacen falta: para leer el sistema y para explicárselo a alguien.

**De relacional a documental**

| Lo que dirías | Lo que hay aquí | Matiz |
|---|---|---|
| Tabla | Colección | Sin esquema impuesto: ver `be02` |
| Fila | Documento | Puede tener campos que otras filas no tienen |
| Columna | Campo | Puede no existir, y ausente ≠ `null` |
| Clave primaria | `_id` | `ObjectId` por defecto. En LabCore hay además `legacyId`, ver `be03` |
| Clave foránea | Un campo con el `_id` de otro | **Sin ninguna comprobación.** Nadie garantiza que exista |
| `JOIN` | `$lookup` en una agregación | Devuelve un **arreglo**, no multiplica filas |
| Tabla de unión (N:M) | Un arreglo de referencias en uno de los dos lados | Se elige el lado por el patrón de lectura |
| Tercera forma normal | No aplica como objetivo | Aquí se desnormaliza a propósito, y se paga en escritura |
| `ON DELETE CASCADE` | **No existe.** Lo haces tú | Y si no lo haces, salen las 37 huérfanas de `be02` |
| Vista | Una agregación guardada, o un read-model | El de `be08` es lo segundo |
| `CHECK` / `NOT NULL` | `$jsonSchema`, si alguien lo puso | Ver [`bea-06`](./bea-06-jsonschema-sobre-datos-sucios.md) |

**De documental a relacional** — cómo se le explica un documento embebido a alguien que piensa en tablas:

> *"Es como si la fila de la orden trajera dentro, ya materializadas, las filas de sus líneas de detalle. No hay `JOIN` porque no hay dos tablas: hay una sola fila que contiene su propia jerarquía. Lo ganas en lectura —una sola ida a disco— y lo pagas en que esas líneas no existen fuera de su orden: no se pueden consultar solas sin recorrer todas las órdenes, y actualizar una reescribe la fila entera."*

Y la frase que más ayuda a un relacional, porque reordena la intuición entera:

> 🧠 *"En SQL modelas **la verdad** y las consultas se adaptan. Aquí modelas **la consulta** y la verdad se reparte."* Ninguna de las dos es mejor: la primera aguanta preguntas que nadie previó, la segunda contesta muy rápido las que sí. LabCore es un sistema con seis años de preguntas imprevistas, y ahí está buena parte de lo que `be02` midió.

---

## 3. El límite de 16 MB, y qué pasa mucho antes

Un documento de MongoDB no puede pasar de **16 MB**. Es un límite duro del formato BSON y no se configura.

Suena enorme y lo es: un documento de paciente de LabCore ocupa unos 300 bytes. Harían falta cincuenta mil campos como los que tiene para acercarse. **Por eso el límite casi nunca es el problema real**, y tratarlo como si lo fuera es lo que hace que la gente lo ignore hasta el día que se lo come.

Lo que muerde mucho antes son tres cosas:

**El documento se lee entero, siempre.** Aunque pidas dos campos con una proyección, el servidor lee el documento completo de disco. Un documento de 2 MB del que usas 200 bytes te cuesta 2 MB de lectura en cada consulta.

**El documento se reescribe entero al actualizarlo.** Un `$push` a un arreglo de diez mil elementos reescribe los diez mil. Y si el documento creció más de lo que cabía en su sitio, el motor tiene que moverlo, con el coste de actualizar todos sus índices.

**Y viaja entero por la red hasta tu aplicación**, donde Jackson lo convierte a objetos Java. Ese coste no sale en ningún `explain()`.

> 💡 **La regla práctica, mucho más útil que el límite oficial:** *si un documento pasa de unos cuantos kilobytes o su arreglo pasa de unos cientos de elementos, la decisión de embeber hay que volver a mirarla.* No porque falle, sino porque ya estás pagando por ella en cada lectura.

```javascript
// Los documentos más grandes de una colección, que es lo que hay que mirar
// cuando algo va lento sin explicación aparente.
db.samples.aggregate([
  { $project: { legacyId: 1, bytes: { $bsonSize: '$$ROOT' } } },
  { $sort: { bytes: -1 } },
  { $limit: 5 }
]);
// ⚠️ $bsonSize existe desde MongoDB 4.4. En el mongo:4.0 de LabCore no está,
// y la alternativa es Object.bsonsize(doc) en el shell, documento a documento.
// Es otro ejemplo de be07: el operador que existe "en MongoDB" no existe en TU
// MongoDB.
```

---

## 4. El arreglo que crece sin techo

El error clásico del modelado documental, y el único de esta página que es verdaderamente un error y no una decisión con precio.

```javascript
// El anti-patrón, en su forma pura.
{
  _id: ObjectId("…"),
  legacyId: 8801,
  status: "processed",
  // Y aquí, todos los eventos de custodia. Y mañana también. Y dentro de
  // tres años, los de tres años.
  custodyEvents: [ { … }, { … }, { … }, … ]
}
```

Por qué es un error y no una preferencia: **el documento crece de forma no acotada por el uso normal del sistema**. Cada evento reescribe el documento entero, cada lectura de la muestra trae la historia completa aunque solo quieras su estado, y el día que alguien automatice algo —un analizador que reporte cada minuto— el crecimiento deja de ser lineal en el trabajo humano.

> ⚰️ **Autopsia del patrón, en abstracto:** un arreglo embebido que crece con el tiempo empieza costando cero y termina costando todo, **sin que nadie note el cruce**. No hay un día en que falle: hay una curva. Cuando duele, ya hay millones de documentos con la forma equivocada y cambiarla es una migración.

**Y ahora lo interesante: LabCore no cometió este error, y lo esquivó dos veces.**

La primera, en la auditoría. La Fase 11 del track base dice, con todas las letras, que *"el asiento no vive dentro de la muestra: vive en su propia colección, apunta a la muestra por id, y nadie lo edita nunca"*. Es exactamente la decisión correcta, tomada por el equipo del frontend, y es la razón de que la bitácora de LabCore siga siendo consultable seis años después.

La segunda, en la custodia, y aquí la cosa se pone más interesante porque **la solución tiene su propio precio**. En vez de un arreglo, LabCore aplanó la cadena en pares de campos fijos dentro del documento de la muestra:

```javascript
{
  legacyId: 8801, status: "processed",
  collectedBy: "analista1", collectedAt: ISODate("…"),
  receivedBy:  "analista2", receivedAt:  ISODate("…"),
  processedBy: "analista1", processedAt: ISODate("…")
}
```

Y el componente de la Fase 7 reconstruye la línea de tiempo leyendo esos campos en orden (`custodyEvents()`). Ventajas reales: el documento **no puede crecer** —la cadena tiene cinco eslabones y siempre va a tener cinco—, y cada transición es **una sola escritura atómica**, que en un standalone sin transacciones no es poca cosa.

Lo que se pagó, y hay que saber decirlo:

- **No caben dos eventos del mismo tipo.** Una muestra que se recibe, se devuelve y se vuelve a recibir tiene un solo `receivedBy`: el último. El primero se pierde sin dejar rastro.
- **No se pueden consultar los eventos solos.** *"¿Qué hizo `analista2` el martes?"* obliga a recorrer todas las muestras mirando seis campos, en vez de filtrar una colección de eventos.
- **Y añadir un eslabón nuevo es un cambio de esquema**, no un dato más. Si mañana aparece "en tránsito", hay dos campos nuevos en el modelo, en el documento y en la pantalla.
- **Y el hueco**: una muestra con `processedBy` y sin `receivedBy` describe una cadena rota que nada impide escribir. Son las 23 de `be05` §5.4.

> 🧭 **La tercera opción, que es la que un sistema con futuro elegiría:** una colección `custodyLinks` aparte, un documento por eslabón, referenciando la muestra. Crece sin límite sin que ningún documento crezca, se consulta sola, admite eventos repetidos, y admite eslabones nuevos sin tocar nada. **Lo que cuesta es que registrar un traspaso pasa a ser dos escrituras** —la muestra y el eslabón— y aquí volvemos a `be05`: dos escrituras sin transacción.
>
> Esa colección **no existe en LabCore hoy**. Es la propuesta de `be05`, no un hallazgo de la auditoría, y conviene no confundirlas al leer el material.

---

## 5. La referencia manual, y por qué no hay claves foráneas

```javascript
// Una orden apunta a su paciente. Y eso es todo lo que hay.
{ legacyId: 4021, patientId: 7, status: "in_process" }
```

`patientId: 7` es una convención entre tú y tú. El motor **no comprueba** que el paciente 7 exista al insertar, no impide borrarlo después, y no tiene forma de avisarte cuando la referencia se rompe.

Por qué es así, sin dramatismo: imponer integridad referencial exige comprobaciones que cruzan documentos, y eso choca de frente con el modelo de escrituras de MongoDB —atómicas por documento— y con el diseño distribuido del producto. Es una elección coherente, no un olvido. **Lo que no es coherente es elegirla sin saber que la estás eligiendo**, que es lo que pasó en 2019.

El precio, medido: **37 órdenes de LabCore apuntan a un paciente que no existe** (`be02` §5.5). En un motor relacional ese número sería cero por construcción, y la agregación que lo mide sería innecesaria.

Lo que se hace en su lugar, en orden de coste creciente:

| Estrategia | Qué implica | Cuándo |
|---|---|---|
| **No hacer nada** | Las referencias se rompen y alguien lo descubre en `be02` | Lo que hizo LabCore |
| **Comprobar al escribir** | Un `findById` antes de insertar. No es atómico: alguien puede borrar en medio | Lo razonable en un sistema en decomisión |
| **Borrado lógico** | Nada se borra nunca (`active: false`). Las referencias no se rompen porque el destino sigue ahí | **Lo que LabCore ya hace con pacientes** (Fase 5) |
| **Detector periódico** | La agregación de `be02` §5.5 corriendo cada semana | El patrón de `be05` §5.6 |
| **Embeber** | Si el hijo no puede existir sin el padre, quizá no debería ser un documento aparte | La conversación que de verdad hay que tener |

> 💡 **Fíjate en la tercera fila, porque es un acierto de LabCore que suele pasar desapercibido.** La baja lógica de pacientes no se puso ahí por integridad referencial —se puso porque el negocio quiere conservar la historia clínica—, pero el efecto secundario es que **un paciente dado de baja no rompe sus órdenes**. Las 37 huérfanas no vienen de borrados: vienen de la importación de 2020, que metió órdenes cuyos pacientes nunca llegaron. Esa distinción la mide el ejercicio 10 de `be02` y cambia por completo la hipótesis.

---

## 6. `$lookup` y lo que cuesta de verdad

```javascript
// El JOIN. Con dos diferencias que hay que tener claras.
db.orders.aggregate([
  { $lookup: {
      from: 'patients',          // la otra colección
      localField: 'patientId',
      foreignField: 'legacyId',
      as: 'patient'              // <- el resultado es un ARREGLO
  }}
]);
```

**Diferencia 1: devuelve un arreglo y no multiplica documentos.** Un `LEFT JOIN` que casa con tres filas te da tres filas; aquí te da un documento con un arreglo de tres. Es más fácil de razonar y más incómodo de leer.

**Diferencia 2: un arreglo vacío es la respuesta normal cuando no hay nada.** No hay error, no hay `NULL` sospechoso: hay `[]`. Por eso la agregación que encuentra referencias rotas es un `$match: { patient: { $size: 0 } }`.

Lo que cuesta, que es la pregunta que trae aquí a la gente:

- **Por cada documento de entrada, una búsqueda en la otra colección.** Si `foreignField` **no tiene índice**, eso es un recorrido completo por cada documento, y el producto se dispara. Con índice es una búsqueda y es barato. **La diferencia entre un `$lookup` aceptable y uno inutilizable es un índice**, y es lo primero que hay que comprobar (ver [`bea-05`](./bea-05-indices-y-explain-en-mongodb.md)).
- **Filtra antes de cruzar.** Un `$match` delante del `$lookup` reduce el número de búsquedas; detrás, ya las hiciste todas. Es el mismo instinto que tienes en SQL, y aquí importa más porque no hay un planificador que lo reordene por ti.
- **Y el tipo tiene que coincidir.** Un `patientId` entero contra un `legacyId` guardado como cadena en algunos documentos **no casa y no avisa**: sale arreglo vacío. Es el error del §6 de `be02` y vuelve a aparecer en `be04`.

> 🧭 **El criterio que zanja la discusión de "¿y no será mejor embeber para evitar el `$lookup`?":** un `$lookup` en una consulta que se ejecuta tres veces al día para un informe es perfectamente aceptable. El mismo `$lookup` en la pantalla que se abre cuarenta veces por hora es el que había que evitar embebiendo. **No se decide por la operación: se decide por su frecuencia.**

---

## 7. Las cinco entidades de LabCore, con veredicto

La tabla que resume las cinco decisiones de 2019. La columna de la derecha es la que hay que poder defender.

| Entidad | Qué se hizo | Veredicto | Qué se pagó |
|---|---|---|---|
| **Paciente** | Colección propia, documento plano | ✅ Correcto | Nada. Es una entidad con vida propia que se consulta sola |
| **Orden** | Colección propia, referencia al paciente por `patientId` | ⚠️ Correcto con reserva | Las 37 huérfanas. La referencia era la decisión buena; **faltó el detector** |
| **Muestra** | Colección propia, referencia a la orden, **custodia aplanada adentro** | ⚠️ Discutible | No caben eventos repetidos, no se consultan los eventos solos, y 23 cadenas rotas |
| **Resultado** | Colección propia, referencia a la muestra, **`rangeVersionApplied` desnormalizado** | ✅ Acierto grande | Nada — y **salvó la fase `be06`**: es el único rastro que sobrevivió al `$set` de los rangos |
| **Rango de referencia** | Colección propia, una versión por documento | ✅ La forma es correcta | El modelo estaba bien; **lo que falló fue mutarlo** (`be06` §4.2). Un acierto de modelado arruinado por una operación |

> 🧠 **La fila del resultado merece pararse.** Guardar `rangeVersionApplied` dentro del resultado es desnormalización pura: es un dato que "ya está" en la colección de rangos. Un purista relacional lo habría quitado en una revisión. Y es exactamente lo que permitió, seis años después, saber contra qué versión se juzgó cada informe cuando la colección de rangos ya había perdido su historia.
>
> **La lección no es "desnormaliza siempre".** Es que congelar un dato que participó en una **decisión** —un veredicto, un precio, un cálculo firmado— no es redundancia: es evidencia. Un precio en una factura no es una copia del precio del catálogo; es el precio al que se vendió. La misma distinción, con otro sustantivo.

Y la fila de los rangos, que es la contraria y cierra la idea: **el modelo estaba bien y la operación lo rompió**. Ningún criterio de modelado protege de un `$set` sobre un documento que representa un hecho fechado. Por eso `be06` termina con una guarda de inmutabilidad y no con un rediseño.

---

## 🧭 Cuándo usar qué

| Situación | Decisión | Por qué |
|---|---|---|
| Uno a uno, siempre leídos juntos | **Embeber** | Una lectura, una escritura atómica |
| Uno a pocos, con techo conocido y estable | **Embeber** | Los tres teléfonos de un paciente, no sus órdenes |
| Uno a muchos sin techo | **Referenciar** | El arreglo que crece es el error clásico |
| El hijo se consulta sin el padre | **Referenciar** | Si no, hay que recorrer todos los padres |
| El hijo cambia y el padre no | **Referenciar** | Si no, cada cambio reescribe el padre entero |
| Dos cosas tienen que pasar juntas o ninguna | **Embeber, si se puede** | Es la única atomicidad disponible en un standalone |
| Un dato que participó en una decisión firmada | **Copiarlo (desnormalizar)** | No es redundancia: es evidencia |
| Muchos a muchos | **Referenciar** por el lado que más se consulta | Y aceptar que el otro lado es un `$lookup` |
| Un hecho fechado (versión, precio, asiento) | **Documento propio, inmutable** | Y nunca mutarlo: ver `be06` |

---

## ⚠️ Advertencias

**Casi toda la literatura sobre modelado en MongoDB está escrita para sistemas nuevos.** Habla de elegir, y tú no eliges: heredaste cinco decisiones tomadas en 2019 por gente que ya no está. Este apéndice sirve para **entender y defender** esas decisiones, y para saber cuál tiene arreglo barato y cuál no. Rediseñar el modelo de un sistema con dos años de vida es lo que `be08` desaconseja con números.

**Un cambio de modelo es una migración de datos**, y en una base sin esquema impuesto eso significa que durante un tiempo —o para siempre, si nadie termina— **conviven las dos formas**. Es literalmente lo que `be02` mide: cinco formas del documento de paciente, cada una con una migración que nadie terminó.

**El límite de 16 MB no es el criterio.** Si tu argumento para no embeber es "podría llegar a 16 MB", el argumento es débil y probablemente estés eligiendo mal por el motivo equivocado. El criterio es el techo y la frecuencia de escritura, y muerde mucho antes.

**Y `$lookup` no es un `JOIN` del que fiarte a ciegas.** Sin índice en `foreignField` es cuadrático, y el síntoma es una agregación que tarda tres segundos sobre datos que caben en memoria. Antes de culpar a Mongo, comprueba el índice.

---

## 📚 Referencias

- MongoDB — modelos de datos y patrones de relación, con las dos formas: https://www.mongodb.com/docs/v4.0/core/data-model-design/
- Relaciones uno a muchos, con los tres tamaños (*one-to-few*, *one-to-many*, *one-to-squillions*), que es la mejor formulación del criterio que hay: https://www.mongodb.com/blog/post/6-rules-of-thumb-for-mongodb-schema-design-part-1
- Límites de BSON, incluido el de 16 MB: https://www.mongodb.com/docs/v4.0/reference/limits/
- `$lookup`: https://www.mongodb.com/docs/v4.0/reference/operator/aggregation/lookup/
- Catálogo de patrones de modelado de MongoDB (*attribute*, *bucket*, *outlier*, *schema versioning*): https://www.mongodb.com/blog/post/building-with-patterns-a-summary — ⚠️ el de *schema versioning* es el que LabCore no aplicó, y leerlo explica media fase `be02`.
- Spring Data MongoDB 2.1 — mapeo de documentos y `@DBRef` (que este track **no** usa, y conviene saber por qué: hace una consulta extra por cada referencia, de forma invisible): https://docs.spring.io/spring-data/mongodb/docs/2.1.x/reference/html/#mapping-usage
- Pramod Sadalage y Martin Fowler, *NoSQL Distilled* (2012), capítulo 3 — el concepto de **agregado**, que es el nombre teórico de lo que decide esta página.
- Eric Evans, *Domain-Driven Design* (2003), capítulo 6 — de donde viene la palabra "agregado" y el criterio de la frontera de consistencia. Es la misma idea, quince años antes y sin bases de datos de por medio.

> ⚠️ URLs y contenidos cambian; verifícalos. Y ojo con la documentación sin versión: `$bsonSize` es de 4.4 y en el `mongo:4.0` de LabCore no existe, aunque la página "current" lo dé por descontado.

---

## 🧪 Ejercicios (8)

1. Para cada una de las cinco entidades de LabCore, contesta las tres preguntas del §1 mirando el código del frontend. Compara tus respuestas con la tabla de veredictos.
2. Mide el tamaño de los cinco documentos más grandes de `samples` en tu volcado. Si estás en `mongo:4.0`, `$bsonSize` no existe: resuélvelo con `Object.bsonsize()` y anota la diferencia.
3. Corre el `$lookup` de órdenes contra pacientes **sin** índice en `legacyId` y cronométralo. Crea el índice, repítelo, y anota los dos tiempos.
4. Escribe la consulta *"¿qué hizo `analista2` el martes?"* contra el modelo aplanado de custodia. Anota cuántos campos tienes que mirar y sobre cuántos documentos.
5. **Diagnóstico.** Provoca un `$lookup` que devuelva todo vacío cruzando dos campos de tipos distintos. Explica por qué no hay error.
6. **Diseño.** Modela la colección `custodyLinks` que `be05` propone: qué campos, qué índices, y qué consultas nuevas habilita. Después escribe qué se rompe del contrato si la aplicación empezara a usarla — pista: nada, porque el frontend no la conoce.
7. **Diagnóstico.** Busca en `results` el campo desnormalizado que salvó `be06`. Escribe en tres líneas por qué no es redundancia, usando el ejemplo del precio en una factura.
8. **Adversarial.** Alguien propone embeber las muestras dentro de su orden "para evitar un `$lookup`". Calcula cuántas muestras tiene una orden en tu volcado (media y máximo), decide, y defiende la decisión con los dos números delante.

---

> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida y el modelo que describe lo escriben las fases —`be03` sobre todo—, así que lo que salga de leerlo se commitea con el prefijo de la fase desde la que llegaste (`be02: …`, `be03: …`, `be06: …`). Si una medición merece conservarse, como los dos tiempos del ejercicio 3, va en el mensaje de un tag anotado `ej/bea-03/3`. La convención completa está en [`00-convencion-de-git-y-tags.md`](./00-convencion-de-git-y-tags.md) §10.
