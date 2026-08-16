# 📎 Apéndice bea-07 — Transacciones, replica sets y el standalone

> Tutorial Angular 8 — Laboratorio clínico · 🔥 Track BE · Consulta rápida · **4 horas**
> Usado por: be05 ⭐ · Versiones cubiertas: MongoDB 4.0 (sin transacciones útiles aquí) y 7.0

**Esto no se lee de corrido.** Se entra con una pregunta muy concreta —*"¿puedo hacer que estas dos escrituras pasen juntas?"*— y se sale con la respuesta, que en LabCore es no, y con las tres cosas que se hacen en su lugar.

Resuelve una cosa: **entender exactamente qué garantía te da tu topología de despliegue, y qué haces cuando no te da la que necesitas.**

**Qué queda fuera:** el sharding y las transacciones distribuidas, porque LabCore es un `mongod` suelto y las dos cosas están a dos decisiones de distancia; y **montar un replica set paso a paso** — aquí se explica qué implica convertir uno y qué cuesta, no se monta, porque la base de LabCore es un servicio gestionado y esa operación no la ejecuta el equipo.

---

## El dato que abre el apéndice

Medido el **8/09/2026** sobre `mongo:4.0` standalone, con una operación real dentro de la transacción:

```
RESULTADO: RECHAZADA
codigo:  20
mensaje: Transaction numbers are only allowed on a replica set member or mongos
```

> 🧠 **El propio mensaje de error enuncia la tesis del track.** La capacidad existía en el producto —MongoDB tiene transacciones multidocumento desde la 4.0, que es exactamente la versión que corre LabCore— y **una decisión de despliegue de 2019 la dejó fuera de alcance**. Nadie eligió no tener transacciones. Alguien eligió levantar un proceso suelto en vez de un replica set, y esa elección sigue gobernando lo que el sistema puede prometerle a un auditor.

---

## Índice

- [1. ⚠️ Antes de nada: la prueba que da un falso positivo](#1-️-antes-de-nada-la-prueba-que-da-un-falso-positivo)
- [2. 🪞 Tu instinto dice `BEGIN … COMMIT`… y esta vez se equivoca](#2--tu-instinto-dice-begin--commit-y-esta-vez-se-equivoca)
- [3. Lo que sí tienes siempre: el documento como unidad atómica](#3-lo-que-sí-tienes-siempre-el-documento-como-unidad-atómica)
- [4. Qué añade una transacción multidocumento](#4-qué-añade-una-transacción-multidocumento)
- [5. Por qué exigen replica set](#5-por-qué-exigen-replica-set)
- [6. `writeConcern` y `readConcern`, en llano](#6-writeconcern-y-readconcern-en-llano)
- [7. Qué cuesta convertir un standalone](#7-qué-cuesta-convertir-un-standalone)
- [8. Sustituto 1: idempotencia con clave de operación](#8-sustituto-1-idempotencia-con-clave-de-operación)
- [9. Sustituto 2: el asiento compensatorio](#9-sustituto-2-el-asiento-compensatorio)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-9)

---

## 1. ⚠️ Antes de nada: la prueba que da un falso positivo

Esto va primero porque es lo que más veces se hace mal, y porque **ya se cometió una vez al verificar el stack de este track**.

```javascript
// MAL. Esto NO demuestra nada, y parece que sí.
var session = db.getMongo().startSession();
session.startTransaction();          // <- no lanza. Ni un aviso.
print('transacción permitida');      // <- se imprime. Y es mentira.
```

`startTransaction()` es **perezoso**: no habla con el servidor. Se limita a marcar la sesión como "en transacción" del lado del cliente. El rechazo llega en la **primera operación real** de esa sesión, porque es esa operación la que viaja con un número de transacción adentro, y es el servidor el que lo rechaza.

```javascript
// BIEN. Con una operación real adentro.
var session = db.getMongo().startSession();
var col = session.getDatabase('labcore').samples;

session.startTransaction();
try {
  col.updateOne({ legacyId: 501 }, { $set: { status: 'processed' } });
  session.commitTransaction();
  print('RESULTADO: PERMITIDA');
} catch (e) {
  print('RESULTADO: RECHAZADA');
  print('código:  ' + e.code);
  print('mensaje: ' + e.errmsg);
}
```

> 🧭 **El patrón a memorizar, y sirve mucho más allá de MongoDB:** *una prueba que no ejerce la operación no prueba la capacidad.* Un `connect()` perezoso, un `beginTransaction()` que no viaja, un cliente que solo resuelve DNS al primer uso: la familia de falsos positivos que produce comprobar la **preparación** en vez de la **ejecución** es enorme, y todos se ven igual de verdes en un informe.

---

## 2. 🪞 Tu instinto dice `BEGIN … COMMIT`… y esta vez se equivoca

Vienes de un mundo donde la pregunta es *"¿cómo abro una transacción?"*, y la respuesta es una línea que siempre funciona. Aquí la pregunta es otra:

> **¿Mi despliegue me deja tener una?**

Y lo desconcertante es que tu instinto es **correcto**: una transacción es exactamente lo que hace falta para el invariante de la cadena de custodia, la solución que propones es la buena, y el código que escribes está bien. Lo que falla no es tu razonamiento — es un parámetro de arranque de hace siete años.

```java
// Este código es correcto. Tres líneas de configuración y una anotación.
@Bean
public MongoTransactionManager transactionManager(MongoDbFactory dbFactory) {
    return new MongoTransactionManager(dbFactory);
}

@Transactional
public Sample processSample(Integer sampleLegacyId) { … }
```

Que el código correcto sea trivial es parte del contenido: **lo que hay que aprender aquí no es a escribir transacciones, es a averiguar si las tienes y qué hacer cuando no.**

---

## 3. Lo que sí tienes siempre: el documento como unidad atómica

Antes de hablar de lo que falta, lo que hay. Y hay más de lo que la gente cree.

> 🧭 **Una escritura sobre un documento es atómica, siempre, en cualquier topología y desde la versión 1.** Por compleja que sea: varios campos, arreglos, subdocumentos anidados, operadores condicionales. O se aplica entera o no se aplica ninguna parte.

```javascript
// Todo esto es UNA operación atómica. No hay estado intermedio visible.
db.samples.updateOne(
  { legacyId: 8801, status: 'in_process' },      // ← y el filtro también cuenta
  { $set: { status: 'processed',
            processedBy: 'analista1',
            processedAt: new Date() },
    $inc: { transitions: 1 } }
);
```

Dos consecuencias prácticas que hay que tener muy presentes:

**El filtro forma parte de la atomicidad.** Ese `status: 'in_process'` del filtro convierte la operación en un *compare-and-set*: si otro hilo ya la movió, el filtro no casa y no se escribe nada. Es la forma de hacer una transición de estado segura sin transacción, y es gratis.

**Y por eso embeber es una decisión de consistencia**, no solo de rendimiento: al meter dos cosas en el mismo documento estás eligiendo que se escriban juntas. Es lo que dice [`bea-03`](./bea-03-modelar-documentos-embeber-o-referenciar.md), y en un standalone es **la única forma de que dos cosas pasen juntas**.

Lo que **no** cubre: dos documentos. Dos colecciones. Un documento y su contador. Ahí termina la garantía, y ahí empieza `be05`.

---

## 4. Qué añade una transacción multidocumento

Llegaron en **MongoDB 4.0** (junio de 2018) para replica sets, y en **4.2** para clústeres fragmentados. Lo que dan:

- **Atomicidad sobre varios documentos y varias colecciones.** Todo o nada.
- **Aislamiento de instantánea** (`snapshot`): dentro de la transacción ves la base como estaba al empezar, sin lecturas sucias.
- **`abortTransaction()`**, que deshace lo escrito hasta ese punto.

Y lo que traen consigo, que casi nunca se cuenta:

| Límite | Valor por defecto | Qué significa |
|---|---|---|
| Duración máxima | **60 s** (`transactionLifetimeLimitSeconds`) | Una transacción larga se aborta sola |
| Tamaño en el oplog | 16 MB en 4.0 | En 4.2 se reparte en varias entradas |
| Conflictos de escritura | Fallan con error transitorio | **Hay que reintentar**, y eso es código tuyo |

> ⚠️ **Ese último es el que sorprende a quien viene de un motor relacional con bloqueos:** aquí dos transacciones que tocan el mismo documento no esperan una a otra — **una falla** con `TransientTransactionError` y quien la lanzó tiene que reintentarla. Spring Data no reintenta por ti. Una transacción sin política de reintento es una transacción que funciona hasta que hay concurrencia.

---

## 5. Por qué exigen replica set

No es una restricción comercial ni una decisión arbitraria, y saber el mecanismo ayuda a no discutirlo.

Una transacción multidocumento necesita **sesiones** y **números de transacción**, y los dos se construyeron sobre el **oplog** —el *operations log*, la bitácora circular donde un nodo primario apunta cada escritura para que los secundarios la repliquen—. El oplog es también lo que permite deshacer, coordinar el punto de instantánea y garantizar el orden.

**Un standalone no tiene oplog.** No replica nada, así que no lo necesita, así que no lo crea. Y sin oplog no hay dónde apoyar la transacción.

De ahí sale el detalle que hace la situación de LabCore casi cómica:

> 🧠 **Un replica set de un solo nodo tiene oplog, y por tanto tiene transacciones.** No hace falta un segundo servidor, ni alta disponibilidad, ni más recursos: hace falta que el proceso se haya arrancado diciendo que pertenece a un conjunto. `mongod --replSet rs0` más un `rs.initiate()`.
>
> La diferencia entre el LabCore que tiene transacciones y el que no es **un parámetro de arranque**.

```bash
# La demostración completa, en dos comandos. Misma imagen, misma versión.
docker run -d --name mongo-rs -p 27018:27017 mongo:4.0 --replSet rs0
docker exec mongo-rs mongo --eval 'rs.initiate()'
# Y ahora el guion de arriba responde PERMITIDA.
```

Y por qué en 2019 nadie lo hizo, que merece decirse sin condescendencia: un replica set de un nodo era una configuración rara que casi nadie usaba —sonaba a error de configuración—, el equipo no necesitaba alta disponibilidad para arrancar, y las transacciones multidocumento tenían **un año de vida**. Que hoy el consejo estándar sea "levanta siempre un replica set, aunque sea de un nodo" es en buena parte *consecuencia* de casos como este.

---

## 6. `writeConcern` y `readConcern`, en llano

Se citan siempre junto a las transacciones y **no son transacciones**. Confundirlos es el malentendido número uno del tema.

**`writeConcern` responde a: ¿cuándo me contestas que ya está guardado?**

| Valor | Significa | En un standalone |
|---|---|---|
| `w: 1` | El nodo lo aceptó (en memoria) | Lo normal |
| `j: true` | Además está en el **diario** del disco | **Sí importa**: sobrevive a un corte de luz |
| `w: "majority"` | La mayoría de los nodos lo tiene | **No significa nada**: hay un nodo, y él es la mayoría |
| `wtimeout` | Cuánto esperar antes de rendirse | Con un nodo, irrelevante |

**`readConcern` responde a: ¿qué versión de los datos quiero leer?**

| Valor | Significa |
|---|---|
| `local` | Lo último que este nodo tiene. El valor por defecto |
| `majority` | Solo lo que ya no se puede perder en una conmutación |
| `snapshot` | Una foto consistente. **Solo dentro de una transacción** |

> 🧠 **Y aquí está la confusión que hay que desactivar:** poner `w: "majority"` **no** te da atomicidad multidocumento. Puedes tener la escritura de la muestra perfectamente durable y replicada, y perder igual la de la orden. **Durabilidad y atomicidad son ejes distintos** — uno responde "¿se guardó bien?" y el otro "¿se guardaron las dos?". Es el ejercicio 18 de `be05` y conviene hacerlo, porque leerlo no convence a nadie.

En LabCore, lo único de esta sección que cambia algo es `j: true`. Lo demás es vocabulario que hay que saber para no asentir cuando alguien lo use mal en una reunión.

---

## 7. Qué cuesta convertir un standalone

La pregunta que `be08` tiene que responder con números. **Técnicamente casi nada; organizacionalmente, todo.**

**Lo técnico**, y es corto: se para el proceso, se arranca con `--replSet rs0`, se ejecuta `rs.initiate()`, y los datos siguen ahí. No hay migración, no hay volcado, no hay reescritura.

**Lo que cambia y hay que revisar:**

| Qué | Impacto |
|---|---|
| **Ventana de parada** | Un reinicio. Minutos, no horas |
| **El oplog** | Se crea y ocupa disco (por defecto, ~5 % del espacio libre). Hay que dimensionarlo |
| **La cadena de conexión** | Puede llevar `replicaSet=rs0`. Con un nodo funciona igual sin él, y conviene decidirlo, no descubrirlo |
| **La estrategia de respaldo** | Cambia: aparece la posibilidad de respaldo desde el oplog, y las herramientas se comportan distinto |
| **Lo que se habilita** | Transacciones **y** *change streams*, que abren otra conversación |
| **Alta disponibilidad** | **Ninguna.** Un nodo sigue siendo un punto único de fallo. No confundir una cosa con la otra |

**Y lo organizacional, que es lo que de verdad cuesta:** la base de LabCore es un **servicio gestionado**, con un proveedor, un contrato y un calendario de mantenimiento. Convertirla no es un comando: es un ticket, una ventana negociada, y alguien que apruebe. Dos días de trabajo y semanas de calendario ajeno.

> 🧭 **Por eso `be08` lo recomienda y no lo ejecuta**, y por eso la recomendación se escribe así: *"convertir la base a replica set es dos días de trabajo y semanas de calendario ajeno; si el sistema tuviera cinco años por delante, sería lo primero. Con dos, es una decisión de quien paga el contrato y no del equipo."*

---

## 8. Sustituto 1: idempotencia con clave de operación

Si no puedes hacer que dos escrituras sean atómicas, haz que **repetirlas no haga daño**. Entonces puedes reintentar hasta que salgan las dos.

El patrón, en tres piezas:

```javascript
// 1. Una clave que identifique la OPERACIÓN, no el documento. En LabCore
//    está a mano: el X-Request-Id del filtro de be01.
{ opKey: "9d4e1f7a", entityType: "sample", entityId: "8801", … }

// 2. Un índice único sobre esa clave. Es lo que convierte un reintento en
//    un no-op en vez de en un duplicado.
db.custodyLinks.createIndex({ opKey: 1 }, { unique: true });
```

```java
// 3. Y la escritura, que tolera el choque.
try {
    repository.insert(link);
} catch (DuplicateKeyException e) {
    // Ya estaba: este reintento llega de una petición que sí se aplicó.
    // NO es un error, y tratarlo como tal es el fallo clásico del patrón.
    log.debug("operación {} ya aplicada", link.getOpKey());
}
```

Lo que se gana y lo que no:

- ✅ Un reintento —del cliente, de un reconciliador, de un proceso que se cayó— no duplica nada.
- ✅ Se puede reintentar **indefinidamente**, que es lo que permite converger.
- ❌ **No da atomicidad.** Entre las dos escrituras sigue habiendo un instante en que solo está la primera. Lo que da es que ese estado sea **transitorio y reparable** en vez de permanente.
- ❌ Y exige que alguien reintente: sin un reconciliador, una operación a medias se queda a medias para siempre.

> 🧠 **La palabra correcta para lo que consigues es *convergencia*, no atomicidad.** El sistema llega al estado bueno, pero no de golpe y no necesariamente rápido. Es una propiedad más débil, tiene nombre, y se defiende perfectamente ante un auditor **si la declaras**. Lo que no se puede es llamarlo "arreglado".

---

## 9. Sustituto 2: el asiento compensatorio

El que elige `be05`, y el único que un dominio regulado admite del todo.

La idea es de contabilidad y tiene quinientos años: **un libro no se corrige tachando, se corrige con un asiento nuevo** que deja constancia de que hubo un error, de cuándo se detectó, de quién lo detectó y de qué se hizo. El asiento original se queda.

```javascript
// Lo que NO se hace: arreglar el estado y seguir.
db.orders.updateOne({ legacyId: 4021 }, { $set: { status: 'partial_results' } });
// El sistema queda consistente y NADIE puede demostrar que estuvo mal.

// Lo que sí: un asiento en el libro, con la evidencia congelada.
db.corrections.insertOne({
  detectedAt: ISODate("…"), detectedBy: "system:CustodyIntegrityDetector",
  entityType: "order", entityId: "4021", reason: "order-behind-samples",
  evidence: { …el documento tal como estaba… },
  status: "pending"
});
// …y después la corrección, con su propio asiento de auditoría diciendo que
// la escribió una corrección y no una persona.
```

> 🧭 **La regla, escrita para citarla:** *lo roto no se arregla sobrescribiendo, se compensa con un asiento nuevo.* A un auditor no le sirve un sistema consistente: le sirve uno **que puede demostrar cómo llegó a serlo**.
>
> Y el corolario práctico, que vale con base de datos o sin ella: **la corrección tiene que costar más que el error para que el sistema sea auditable.** Si arreglar un dato es un `updateOne` de una línea que no deja rastro, la verdad del sistema es la del último que escribió.

El diseño completo del libro —append-only por construcción, detector idempotente, evidencia congelada— está en [`be05`](./be05-la-cadena-de-custodia-y-la-transaccion.md) §5.6 y §5.7. Aquí solo el porqué.

---

## 🧭 Cuándo usar qué

| Situación | Qué usar |
|---|---|
| Varios campos de **un** documento | Nada: ya es atómico |
| Transición de estado sin pisar a otro | El estado esperado **en el filtro** (*compare-and-set*) |
| Un contador | `findAndModify` con `$inc`. Atómico sobre un documento |
| Dos documentos, y **hay** replica set | Transacción, con política de reintento |
| Dos documentos, y **no** hay replica set | Idempotencia + reconciliador, o asiento compensatorio |
| Un dominio regulado, algo ya salió mal | **Asiento compensatorio.** No hay alternativa |
| Que sobreviva a un corte de luz | `j: true` |
| "Que sea seguro" en un standalone | `w: "majority"` **no hace nada**. Ver §6 |
| Comprobar si tienes transacciones | El guion del §1, **con una operación adentro** |

---

## ⚠️ Advertencias

**Casi todo lo que encuentres sobre transacciones en MongoDB da por supuesto un replica set**, porque desde hace años es la configuración por defecto de todo el mundo, incluidos los servicios gestionados y las imágenes de desarrollo. Que un artículo no mencione el requisito no significa que no exista — significa que su autor no se lo encontró nunca.

**Y hay una trampa concreta con esto, que `be08` §5.5 documenta:** `MongoDBContainer` de Testcontainers arranca la base **como replica set de un nodo**. Si escribes tus pruebas contra él, `@Transactional` pasa en verde en el pipeline y es rechazado con el código 20 en producción. *Un entorno de pruebas mejor que producción no es un entorno de pruebas.*

**Una transacción no arregla un mal modelo.** Si dos documentos tienen que cambiar siempre juntos, la primera pregunta es si deberían ser el mismo documento ([`bea-03`](./bea-03-modelar-documentos-embeber-o-referenciar.md)). La transacción es la respuesta cuando embeber no es posible, no la primera opción.

**Y las transacciones tienen coste.** Aislamiento de instantánea, coordinación y oplog no son gratis, y en MongoDB la diferencia entre una escritura suelta y la misma dentro de una transacción es medible. Antes de recomendar convertir a replica set "para poder usarlas en todas partes", mide el sobrecoste — es el 🔥 segundo del §7.

---

## 📚 Referencias

- MongoDB 4.0 — transacciones, con la lista de requisitos donde figura el replica set: https://www.mongodb.com/docs/v4.0/core/transactions/
- Atomicidad de documento único, que es la garantía que **sí** tienes siempre: https://www.mongodb.com/docs/v4.0/core/write-operations-atomicity/
- `writeConcern`: https://www.mongodb.com/docs/v4.0/reference/write-concern/
- `readConcern`: https://www.mongodb.com/docs/v4.0/reference/read-concern/
- Convertir un standalone en replica set — el procedimiento oficial: https://www.mongodb.com/docs/v4.0/tutorial/convert-standalone-to-replica-set/
- El oplog y su dimensionamiento: https://www.mongodb.com/docs/v4.0/core/replica-set-oplog/
- Errores transitorios de transacción y el patrón de reintento: https://www.mongodb.com/docs/v4.0/core/transactions-in-applications/
- Spring Data MongoDB 2.1 — `MongoTransactionManager`: https://docs.spring.io/spring-data/mongodb/docs/2.1.x/reference/html/#mongo.transactions
- Pat Helland, *Life beyond Distributed Transactions: an Apostate's Opinion*: https://queue.acm.org/detail.cfm?id=3025012 — la posición en la que estás, argumentada doce años antes de que la tuvieras.
- Martin Kleppmann, *Designing Data-Intensive Applications* (2017), capítulo 7 — y en particular *Weak Isolation Levels*, que explica por qué "tenemos transacciones" tampoco significa siempre lo que la gente cree.
- Gregor Hohpe y Bobby Woolf, *Enterprise Integration Patterns* (2003) — el patrón de *compensating transaction*.

> ⚠️ URLs y contenidos cambian; verifícalos. Y comprueba la versión de la documentación: los límites de duración y de tamaño de transacción se han movido entre versiones mayores.

---

## 🧪 Ejercicios (9)

1. Ejecuta el guion perezoso del §1 y después el correcto. Anota las dos salidas lado a lado y escribe en una línea por qué la primera es peligrosa.
2. Levanta `mongo:4.0` con `--replSet rs0`, inicia el conjunto, y corre el mismo guion. Confirma `PERMITIDA` sin cambiar una línea de código.
3. Escribe una transición de estado con el estado esperado **en el filtro** y comprueba que dos ejecuciones seguidas solo aplican una. Es *compare-and-set* sin transacción.
4. **Diagnóstico.** Escribe una operación con `w: "majority"` en el standalone de LabCore. Comprueba que se acepta. Después provoca una escritura a medias y confirma que `majority` no la impidió. Explica la diferencia entre durabilidad y atomicidad con tus dos resultados delante.
5. Sobre el replica set del ejercicio 2, abre una transacción y déjala más de 60 segundos sin confirmar. Anota el error exacto y qué pasó con lo escrito.
6. **Diagnóstico.** Sobre el mismo replica set, lanza dos transacciones concurrentes que toquen el mismo documento. Anota cuál falla, con qué error, y qué habría que escribir para que el sistema se recuperara solo.
7. Implementa el patrón de idempotencia del §8 con el `X-Request-Id` como `opKey`. Reintenta la misma operación cinco veces y confirma que solo hay un documento.
8. **Diagnóstico.** Quita el índice único del `opKey` y repite el ejercicio 7. Anota cuántos duplicados salen y escribe por qué el índice no es una optimización sino la mitad del patrón.
9. Mide el sobrecoste de una transacción sobre el replica set: cien transiciones con y sin `@Transactional`, mediana y percentil 95. Anota los números — son los que `be08` necesita para costear la conversión.

---

> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida y el código que explica lo escribe **be05**, así que lo que salga de leerlo se commitea con el prefijo de la fase desde la que llegaste (`be05: …`). La medición del ejercicio 9 sí merece conservarse: va en `MEASUREMENTS.md`, porque el árbol de veredicto de `be08` la cita. La convención completa está en [`00-convencion-de-git-y-tags.md`](./00-convencion-de-git-y-tags.md) §10.
