# ⛓️ Fase be05 — La cadena de custodia y la transacción que no existe

> Tutorial Angular 8 — Laboratorio clínico · 🔥 Track BE · Fase be05 de be08 · **10 horas** · ⭐⭐ **la fase insignia del track**
> Depende de: be04 — la mutación y su asiento ya se escriben los dos en el servidor, y siguen sin estar unidos
> Habilita: be06
> Apéndices de apoyo: [bea-07 (transacciones, replica sets y el standalone)](./bea-07-transacciones-replica-sets-y-el-standalone.md) · [bea-09 (Cassandra: la tentación y el acierto que nadie tuvo)](./bea-09-cassandra-la-tentacion-y-el-acierto-que-nadie-tuvo.md) · [Incidentes asociados](./cuaderno-incidentes-be.md): be-08, be-09

---

## 🎯 1. Propósito

Descubrir que la garantía que el dominio exige no la da la topología que alguien eligió en 2019, y contener el daño sin rehacer el despliegue.

`be04` terminó con una ventana abierta a propósito: una muestra que cambia de estado escribe tres documentos —la muestra, la orden que se empuja detrás, y el asiento de auditoría— y **nada los une**. Si el proceso se cae entre el primero y el segundo, el sistema queda mintiendo: una muestra procesada cuya orden dice que sigue en proceso, o peor, un cambio de custodia sin registro.

La solución es obvia y tiene nombre desde 1981: una transacción. MongoDB las soporta desde la 4.0, que es exactamente la versión que corre en LabCore. Así que esta fase empieza escribiéndola, con toda honestidad, esperando que funcione.

Y el servidor contesta esto:

```
Transaction numbers are only allowed on a replica set member or mongos
```

> 🧠 **No lo argumentes: enséñalo.** Ese mensaje —código 20, medido sobre `mongo:4.0` standalone con una operación real dentro de la transacción— enuncia la tesis del track entero en una línea: **la capacidad existía en el producto, y una decisión de despliegue de 2019 la dejó fuera de alcance**. Nadie eligió no tener transacciones. Alguien eligió levantar un `mongod` suelto en vez de un replica set, hace siete años, por la tarde, y esa decisión sigue gobernando lo que el sistema puede prometerle a un auditor en 2026.

Lo que sigue después del rechazo es la fase de verdad: medir cuántas cadenas ya están rotas, costear las tres salidas realistas, y elegir la única que un dominio regulado admite.

---

## ✅ 2. Qué queda listo al terminar

- [ ] Tienes el invariante de la custodia **escrito en una frase**, con los tres documentos que participan y qué significa que uno se escriba sin los otros.
- [ ] Escribiste la transacción de verdad, con `MongoTransactionManager` y `@Transactional`, y tienes capturado el error del servidor con su código y su mensaje literal.
- [ ] Demostraste que **la capacidad sí existe en el producto**: el mismo código, sin cambiar una línea, funciona contra un `mongo:4.0` iniciado como replica set de un solo nodo.
- [ ] Sabes por qué una prueba mal escrita de esto da un falso *"permitida"*, y puedes explicar en qué momento exacto llega el rechazo.
- [ ] Tienes el número de **cadenas de custodia con un eslabón huérfano que ya están en producción**, medido con una agregación y anotado en `MEASUREMENTS.md`. El número, no la sospecha.
- [ ] Tienes las tres salidas costeadas por escrito —convertir a replica set, escritura idempotente con reconciliador, o libro de correcciones— con horas, riesgo y quién tendría que aprobarlas.
- [ ] El **libro de correcciones** está implementado y corriendo: lo roto no se sobrescribe, se compensa con un asiento nuevo, y puedes defender esa decisión ante un auditor.
- [ ] Puedes mostrar los dos documentos de una escritura a medias, unidos por su `X-Request-Id`, y el log de `mongod` donde se ve que el segundo nunca llegó.

---

## 🚫 3. Qué NO entra todavía

- **Convertir la base a replica set.** Se costea, se documenta y **no se hace**: la base es un servicio gestionado con un proveedor que tiene calendario propio, y esa conversación es de `be08` — con el matiz de `be07`, donde vas a descubrir quién ha estado tomando decisiones sobre esa base sin consultarte.
- **El retrofit de validación con `$jsonSchema` y el read-model** → **be08**.
- **Arreglar las cadenas rotas sobrescribiéndolas.** Es lo que no se hace, y es la mitad del contenido de la fase.
- **Los rangos versionados** → **be06**. Hay una pérdida de historia peor que esta y todavía no la has visto.
- **Tocar el frontend.** Sigue sin tocarse. Las cadenas rotas se ven en la timeline de la Fase 7 exactamente igual que se veían: con un hueco.

---

## 🧠 4. Concepto mínimo

### 4.1 El invariante, escrito en una frase

Antes de hablar de transacciones hay que decir qué se está protegiendo, porque *"que los datos sean consistentes"* no es un invariante: es un deseo.

> 🧭 **El invariante de LabCore:** *cuando una muestra pasa a `processed`, su orden avanza a `partial_results` y queda un asiento con quién y cuándo. Las tres cosas ocurren, o no ocurre ninguna.*

Esa frase la impone el dominio, no la tecnología. Un laboratorio clínico regulado tiene que poder demostrar la cadena de custodia completa de una muestra: quién la tomó, quién la recibió, quién la procesó, a qué hora cada uno. Un eslabón que falta no es un dato incompleto — es **una muestra cuya integridad no se puede certificar**, y sobre la que técnicamente no se debería emitir un informe.

Y ahora los tres documentos que participan, que es donde está el problema:

| Documento | Qué cambia | Colección |
|---|---|---|
| La muestra | `status`, `processedBy`, `processedAt` | `samples` |
| La orden | `status`: `in_process` → `partial_results` | `orders` |
| El asiento | uno nuevo, con actor y hora del servidor | `auditLogServer` |

**Tres documentos, tres colecciones, un solo hecho de negocio.** En MongoDB, una escritura es atómica **a nivel de documento** y ahí termina la garantía. Tres escrituras son tres oportunidades de que el sistema se caiga en medio.

> 🪞 **Tu instinto relacional dice "esto es un `BEGIN` y un `COMMIT`"… y tiene razón.** Esa es la parte que desconcierta de esta fase: tu instinto es correcto, la solución que propones es la correcta, y el sistema te la va a negar por un motivo que no tiene nada que ver con la corrección de tu idea. **Aprender a trabajar donde tu instinto correcto no se puede aplicar** es una habilidad distinta de aprender una tecnología nueva, y es la que este track entrena.

### 4.2 Lo que una transacción te da, y lo que ya tenías sin ella

Conviene ser preciso, porque en el ecosistema de MongoDB hay mucha confusión entre tres cosas distintas que se citan juntas. `bea-07` las desarrolla; el resumen operativo:

**Atomicidad de documento único.** La tienes siempre, en cualquier topología, desde la versión 1. Una actualización de un documento, por compleja que sea —varios campos, arreglos, subdocumentos—, o se aplica entera o no se aplica. Es lo que hace correcto el `CounterService` de `be03`.

**Durabilidad (`writeConcern`).** Responde a *"¿cuándo me contestas que ya está guardado?"*. En un standalone, `w: 1` con `j: true` significa "escrito en el diario del disco". Es una garantía real y **no tiene nada que ver con la atomicidad de varios documentos**: puedes tener la escritura perfectamente durable de la muestra y perder la de la orden igual.

**Atomicidad multidocumento (transacciones).** Es lo que hace falta aquí, llegó en la 4.0, y **exige replica set o clúster fragmentado**. No por capricho: una transacción necesita el mecanismo de sesiones y números de transacción, que se construyó sobre el oplog, que es la bitácora de replicación. **Un standalone no tiene oplog, así que no tiene dónde apoyar la transacción.**

> 🩻 **Esto sí funciona igual, y es lo que hace que no te sientas perdido:** una vez que la transacción existe, se comporta como esperas —aislamiento de instantánea, todo o nada, `abort` que deshace— y `@Transactional` de Spring la maneja con la misma anotación que ya usas. **El modelo mental es idéntico; lo que cambia es el requisito de infraestructura para poder usarlo**, y ese requisito es invisible desde el código.

### 4.3 Por qué un standalone y no un replica set: la decisión de 2019

De `00-historia-del-sistema.md`, y merece la pena releerlo con lo que ya sabes:

Se levantó un `mongod` suelto, no un replica set. Se contrató como servicio gestionado. Y nadie volvió a revisarlo.

En 2019 esa decisión era **defendible**. Un replica set de un solo nodo era una configuración rara que casi nadie usaba —se veía como "una réplica sin réplicas", que suena a error de configuración—; el equipo no necesitaba alta disponibilidad para arrancar; y las transacciones multidocumento acababan de salir, en junio de 2018, así que nadie las daba por sentadas todavía.

Lo que hoy hace que duela no es la decisión: es que **nunca se revisó**. Entre 2018 y 2026, las transacciones pasaron de novedad a expectativa básica. La documentación de MongoDB dice desde hace años que se pueden usar. El manual dice que se puede. Y en LabCore no se puede, por una línea de configuración de hace siete años que nadie escribió en ningún documento.

> 📝 **Nota de época que hay que decir sin ironía.** Que hoy el consejo estándar sea "levanta siempre un replica set, aunque sea de un nodo" es en buena parte *consecuencia* de casos como este. Lo que en 2019 parecía una complicación innecesaria resultó ser el requisito de entrada a la mitad de las capacidades del producto. **Nadie lo sabía en 2019 y todo el mundo lo sabe en 2026** — y esa asimetría, que es la esencia del trabajo con sistemas heredados, no se arregla culpando a quien decidió con la información que tenía.

### 4.4 La contención que gana es contabilidad

Adelanto el final, porque la fase se entiende mejor sabiendo a dónde va.

Cuando encuentres las cadenas rotas, la reacción natural va a ser arreglarlas: un script que ponga la orden en el estado que le corresponde, y listo. **En un dominio regulado, eso es exactamente lo que no se puede hacer.**

La razón es de contabilidad, no de informática, y tiene quinientos años. Un libro contable no se corrige tachando: se corrige con un **asiento de compensación**, que deja constancia de que hubo un error, de cuándo se detectó, de quién lo detectó y de qué se hizo. El asiento original se queda. Un libro donde las líneas se pueden reescribir no es un libro: es un borrador, y no prueba nada.

> 🧭 **La regla que gobierna el §5.7 y buena parte de `be08`:** *lo roto no se arregla sobrescribiendo, se compensa con un asiento nuevo.* Un `$set` sobre un documento histórico destruye la evidencia de que hubo un problema, y a un auditor no le sirve un sistema consistente: le sirve un sistema **que puede demostrar cómo llegó a serlo**.

Y hay un corolario práctico que vale para cualquier sistema, con base de datos o sin ella: **la corrección tiene que costar más que el error para que el sistema sea auditable**. Si arreglar un dato es un `UPDATE` de una línea que no deja rastro, la verdad del sistema es la del último que escribió.

---

## 💻 5. Código mínimo con comentarios

Ocho piezas. La primera y la segunda son el intento honesto; la tercera y la cuarta, la demostración; el resto, la contención.

### 5.1 El intento honesto

```java
package com.andina.labcore.config;

import com.mongodb.MongoClient;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.mongodb.MongoDbFactory;
import org.springframework.data.mongodb.MongoTransactionManager;

// Spring Data MongoDB 2.1 (tren Lovelace, el que trae Boot 2.1.18) soporta
// transacciones. Basta declarar el gestor y el @Transactional de siempre
// empieza a funcionar contra Mongo. Tres líneas.
//
// Que sean tres líneas es parte del contenido: el código correcto es
// trivial. Lo que falla no está aquí.
@Configuration
public class TransactionConfig {

    @Bean
    public MongoTransactionManager transactionManager(MongoDbFactory dbFactory) {
        return new MongoTransactionManager(dbFactory);
    }
}
```

```java
package com.andina.labcore.service;

import org.springframework.transaction.annotation.Transactional;

// El invariante del §4.1, escrito como cualquiera lo escribiría.
//
// Las tres escrituras dentro de una transacción: la muestra, la orden que se
// empuja detrás, y el asiento. Si algo falla en medio, no queda nada.
@Transactional
public Sample processSample(Integer sampleLegacyId) {

    Sample sample = sampleRepository.findByLegacyId(sampleLegacyId);
    Sample before = copyOf(sample);

    // 1. La muestra pasa a processed, con quién y cuándo.
    sample.setStatus("processed");
    sample.setProcessedBy(RequestContext.getActor());
    sample.setProcessedAt(Date.from(serverClock.now()));
    sampleRepository.save(sample);

    // 2. La orden avanza detrás. Es la regla de la Fase 8 del track base:
    //    la última muestra procesada empuja la orden a partial_results.
    Order order = orderRepository.findByLegacyId(sample.getOrderId());
    if (allSamplesProcessed(order)) {
        order.setStatus("partial_results");
        orderRepository.save(order);
    }

    // 3. El asiento, con el actor y el reloj de be04.
    auditService.record("[Samples] Transition Sample Success",
                        "sample", String.valueOf(sampleLegacyId), before, sample);

    return sample;
}
```

Ese código está bien. Ejecutarlo produce esto:

```
com.mongodb.MongoCommandException: Command failed with error 20 (IllegalOperation):
'Transaction numbers are only allowed on a replica set member or mongos'
on server db:27017
```

Un `500`, con su `X-Request-Id`, y ninguna de las tres escrituras aplicada. **Que la transacción falle entera es, irónicamente, la única atomicidad que consigues: la de no hacer nada.**

### 5.2 El detalle de método que hay que respetar

⚠️ **Esto ya pasó una vez al verificar el stack del track y no puede volver a pasar en el material.**

Si compruebas esto en el shell de Mongo, la forma ingenua da un resultado **falso**:

```javascript
// MAL. Esto NO demuestra nada y parece que sí.
var session = db.getMongo().startSession();
session.startTransaction();          // <- no lanza. Ni un aviso.
print('transacción permitida');      // <- se imprime. Y es mentira.
```

`startTransaction()` es **perezoso**: no habla con el servidor. Se limita a marcar la sesión como "en transacción" en el cliente. El rechazo llega en la **primera operación real** que se intente dentro de esa sesión, porque es esa operación la que viaja con un número de transacción adentro y es el servidor el que lo rechaza.

La forma correcta, y la única que se escribe en el material:

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
  print('codigo:  ' + e.code);
  print('mensaje: ' + e.errmsg);
}
```

```
RESULTADO: RECHAZADA
codigo:  20
mensaje: Transaction numbers are only allowed on a replica set member or mongos
```

**El patrón a memorizar, y sirve mucho más allá de MongoDB:** *una prueba que no ejerce la operación no prueba la capacidad.* Un `connect()` perezoso, un `beginTransaction()` que no viaja, un cliente que solo resuelve DNS al primer uso: la familia de falsos positivos que produce comprobar la preparación en vez de la ejecución es enorme, y todos se ven igual de verdes en un informe.

### 5.3 La demostración de que la capacidad sí existe

Este paso es el que impide que la fase se lea como *"MongoDB no tiene transacciones"*, que sería falso y traicionaría el criterio del repositorio. La misma imagen, la misma versión, el mismo código:

```bash
# El MISMO mongo:4.0, arrancado como replica set de un solo nodo.
docker run -d --name mongo-rs -p 27018:27017 mongo:4.0 --replSet rs0
docker exec mongo-rs mongo --eval 'rs.initiate()'

# Y ahora, el guion del §5.2 exactamente igual, contra el 27018:
docker exec mongo-rs mongo --eval '<el mismo guion>'
```

```
RESULTADO: PERMITIDA
```

> 🧠 **Ahí está la tesis del track, demostrada en dos comandos.** Misma versión del producto, mismo código de la aplicación, mismo driver. Lo único que cambia es **cómo se arrancó el proceso**. La capacidad estaba comprada, instalada y disponible; una decisión de despliegue de 2019 la dejó fuera de alcance y nadie lo escribió en ninguna parte.
>
> Y el corolario incómodo, que conviene anotar para `be08`: **convertir un standalone en replica set de un nodo es, técnicamente, casi trivial**. Un parámetro de arranque y un `rs.initiate()`. Que en LabCore no sea trivial no es un problema técnico — es que la base es un servicio gestionado, con un proveedor, una ventana de mantenimiento y un contrato. El coste no está en la informática.

### 5.4 Lo que ya está roto: la medición

Antes de decidir qué hacer, cuántas veces pasó. Esta agregación es la más importante de la fase.

```javascript
// Muestras con la cadena de custodia rota: tienen un eslabón posterior sin
// el anterior. La cadena canónica de la Fase 7 es
//   scheduled -> collected -> received -> in_process -> processed
// y cada paso deja su par <quién, cuándo>. Un documento con processedBy y
// sin receivedBy describe una muestra que se procesó sin haberse recibido.
//
// Eso no es un dato incompleto: es una muestra sobre la que no se puede
// certificar la custodia, y sobre la que se emitieron informes igual.
db.samples.aggregate([
  { $match: {
      $or: [
        { processedBy: { $ne: null }, receivedBy: null },
        { receivedBy:  { $ne: null }, collectedBy: null },
        { status: 'processed', processedAt: null }
      ]
  }},
  { $group: { _id: '$status', samples: { $sum: 1 } } }
]);
```

Y la otra mitad, la que mide el invariante entre colecciones:

```javascript
// Órdenes que se quedaron atrás: todas sus muestras están procesadas y
// ellas siguen diciendo in_process. Es la escritura 2 del §5.1 que no
// llegó a ocurrir.
db.orders.aggregate([
  { $match: { status: 'in_process' } },
  { $lookup: { from: 'samples', localField: 'legacyId',
               foreignField: 'orderId', as: 'samples' } },
  { $match: { $expr: { $and: [
      { $gt: [ { $size: '$samples' }, 0 ] },
      { $eq: [ { $size: { $filter: { input: '$samples', as: 'm',
                  cond: { $ne: ['$$m.status', 'processed'] } } } }, 0 ] }
  ]}}},
  { $count: 'ordersLeftBehind' }
]);
```

Los dos números, juntos, en `MEASUREMENTS.md`:

```
M-11 · Muestras con eslabón huérfano:        23
M-12 · Órdenes que se quedaron atrás:         9
```

Veintitrés y nueve, sobre seis años. **No son muchos, y esa es la parte incómoda.** Un número pequeño es el peor escenario posible para conseguir presupuesto: no duele lo bastante para que nadie lo priorice, y duele exactamente lo suficiente para que un auditor lo encuentre. Anótalo tal cual, sin inflarlo: `be08` va a necesitar el número honesto, no el que convence.

> 💡 Cruza las 23 con `auditLogServer` y con el `X-Request-Id`. Las que tengan asiento cuentan una historia —hubo un intento, algo falló después— y las que no, otra: llegaron así de la importación de 2020, y entonces no son un problema de transacciones sino de `be02`. **Separar esas dos poblaciones antes de contar es lo que distingue una medición de un titular.**

### 5.5 Las tres salidas, costeadas

Ninguna es gratis y ninguna resuelve todo. La tabla va entera a `be08`.

| Salida | Qué implica | Coste | Riesgo | Quién aprueba |
|---|---|---|---|---|
| **A. Convertir a replica set** | Un parámetro de arranque y un `rs.initiate()`. En un servicio gestionado: un ticket, una ventana de mantenimiento, un cambio de cadena de conexión, y revisar la estrategia de respaldo, que cambia | 2 días de trabajo, más el calendario del proveedor —semanas— | Bajo técnicamente. Alto organizacionalmente: **la base no es tuya** | El proveedor y quien paga el contrato |
| **B. Idempotencia + reconciliador** | Clave única por `(requestId, entityType, entityId)` para que un reintento no duplique, más un proceso que detecta divergencias y las corrige | 5 días | Medio: introduce consistencia eventual donde el dominio espera inmediata, y hay que declarar la ventana | El equipo |
| **C. Libro de correcciones** | Detectar y **compensar** con asientos nuevos, sin sobrescribir nada. No previene: documenta y repara dejando rastro | 3 días | Bajo. No cambia el despliegue ni el modelo de consistencia | El equipo |

**Se implementa la C, y se hace por tres razones que hay que saber decir en este orden:**

1. **Es la única que un dominio regulado admite del todo.** Las otras dos también dejarían rastro si se hacen bien, pero la C tiene el rastro como *propósito*, no como efecto secundario.
2. **No depende de nadie de fuera.** La A necesita al proveedor; la C se hace el lunes.
3. **Y no cierra ninguna puerta.** Es compatible con la A y con la B: el día que se convierta a replica set, el libro de correcciones sigue sirviendo para todo lo que se rompió antes.

La A **se documenta y se recomienda** en `be08`, con esta frase o parecida: *"convertir la base a replica set es dos días de trabajo y semanas de calendario ajeno; si el sistema tuviera cinco años por delante, sería lo primero. Con dos, es una decisión de quien paga el contrato y no del equipo."*

### 5.6 El detector

```java
package com.andina.labcore.integrity;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

// Corre cada hora y busca lo que el §5.4 mide a mano. No arregla nada: crea
// una corrección PENDIENTE, con su evidencia. La decisión de aplicarla es de
// una persona, y esa distinción es el diseño entero.
//
// 💸 @Scheduled dentro del propio monolito, sin bloqueo distribuido. Con una
// sola instancia es correcto; con dos, dos detectores compitiendo. Lo
// correcto sería un lock o un job externo. En este track no se paga: LabCore
// corre en una instancia y va a seguir corriendo en una hasta que muera.
@Component
public class CustodyIntegrityDetector {

    @Scheduled(fixedDelayString = "PT1H")
    public void detect() {
        for (Sample sample : sampleRepository.findWithBrokenChain()) {

            // La idempotencia del detector: una corrección por hallazgo, no
            // una por ejecución. Sin esta comprobación, en una semana hay
            // ciento sesenta y ocho correcciones del mismo problema y el
            // libro deja de ser legible, que es lo único que tenía que ser.
            if (correctionRepository.existsByEntityAndReason(
                    "sample", sample.getLegacyId(), "broken-custody-chain")) {
                continue;
            }

            Correction correction = new Correction();
            correction.setDetectedAt(serverClock.now());
            correction.setDetectedBy("system:CustodyIntegrityDetector");
            correction.setEntityType("sample");
            correction.setEntityId(String.valueOf(sample.getLegacyId()));
            correction.setReason("broken-custody-chain");
            // La evidencia, entera y congelada. Si dentro de un año alguien
            // discute el hallazgo, tiene que poder ver el documento tal como
            // estaba cuando se detectó, no como está ahora.
            correction.setEvidence(snapshotOf(sample));
            correction.setStatus("pending");
            correctionRepository.save(correction);
        }
    }
}
```

### 5.7 El libro de correcciones

```java
package com.andina.labcore.integrity;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;

// El libro. Append-only por convención y por disciplina: no hay ni un
// método de actualización en su repositorio, y esa ausencia es el diseño.
//
// Un asiento se "cierra" añadiendo OTRO asiento que lo referencia. Nunca
// editando el primero. Es la regla contable del §4.4, escrita en clases.
@Document(collection = "corrections")
public class Correction {

    @Id
    private String id;

    private Instant detectedAt;
    private String detectedBy;

    private String entityType;
    private String entityId;
    private String reason;

    // El documento tal como estaba al detectarlo. Congelado.
    private Object evidence;

    // pending | applied | dismissed. El estado NO se muta: un cambio de
    // estado es un asiento nuevo con "supersedes" apuntando al anterior.
    private String status;

    // Quién decidió, cuándo y por qué. En "dismissed" es obligatorio: un
    // hallazgo descartado sin razón escrita es un hallazgo escondido.
    private String decidedBy;
    private Instant decidedAt;
    private String rationale;

    private String supersedes;

    // … getters y setters. Sin setters de mutación en el repositorio:
    // save() solo se usa para insertar.
}
```

Y la aplicación de una corrección, que es donde la regla se hace visible:

```java
// Aplicar una corrección NO significa borrar el problema. Significa:
//   1. escribir el estado correcto en la entidad,
//   2. escribir un asiento en auditLogServer que diga que lo escribió una
//      corrección y no una persona,
//   3. añadir al libro un asiento nuevo que cierra el anterior.
//
// Tres escrituras. Sí: exactamente el mismo problema que esta fase vino a
// resolver, y sigue sin transacción. La diferencia es que ahora, si se cae
// en medio, el detector lo vuelve a encontrar en la siguiente pasada y no
// se pierde nada. Eso NO es atomicidad: es convergencia, y hay que llamarla
// por su nombre.
public void apply(String correctionId, String decidedBy, String rationale) {
    // …
}
```

> 🧠 **Esa última nota es lo más honesto de la fase y conviene subrayarla.** No conseguiste atomicidad. Conseguiste que **la falta de atomicidad deje de acumular daño**, porque cualquier estado intermedio se detecta y se vuelve a intentar. Es una propiedad más débil, tiene nombre —convergencia, consistencia eventual— y se defiende perfectamente ante un auditor **si la declaras**. Lo que no se puede hacer es llamarlo "arreglado".

> **Prueba de fuego.** Provoca una escritura a medias de verdad: pon un `Thread.sleep(8000)` entre las escrituras 1 y 2 del §5.1 (con la transacción desactivada), lanza la transición, y en esos ocho segundos haz `docker compose stop db`. Levanta la base otra vez y mira: la muestra está en `processed`, la orden sigue en `in_process`. Ahora espera al detector —o llámalo a mano— y comprueba que aparece un asiento `pending` en `corrections` con la evidencia congelada. Aplícalo, y comprueba las tres escrituras: la orden corregida, el asiento en `auditLogServer` que dice `system` y no una persona, y el asiento nuevo en el libro que cierra el anterior **sin borrarlo**. Esa secuencia completa es la fase.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Síntoma: la prueba dice que las transacciones están permitidas y no lo están.**
Causa: `startTransaction()` sin una operación real dentro. Fix mínimo: el guion del §5.2. Es el error que más veces se comete con esto y produce un informe verde que es falso.

**Síntoma: `@Transactional` no hace nada y no falla.**
Causa: falta el bean `MongoTransactionManager`, y sin él Spring no encuentra gestor para Mongo. Fix mínimo: el §5.1. Y anota la lección: **una anotación sin su infraestructura es un comentario caro** — la misma frase de `be01` §4.1, cobrada en otro sitio.

**Síntoma: `@Transactional` no hace nada aunque el bean esté.**
Causa: el método se llama desde dentro de la misma clase, así que la llamada no pasa por el proxy de Spring. Es el clásico de la autoinvocación y se lleva una tarde entera si no lo conoces.

**Síntoma: el detector crea cientos de correcciones del mismo problema.**
Causa: falta la comprobación de idempotencia del §5.6. Fix mínimo: ponerla. Y ojo, porque el fallo es peor de lo que parece: **un libro de correcciones ilegible es equivalente a no tener libro**.

**Síntoma: la corrección se aplicó y el hallazgo sigue apareciendo.**
Causa: se corrigió el síntoma —el estado de la orden— y no la condición que el detector busca. Fix mínimo: comprobar que la consulta del detector y la acción de la corrección hablan del mismo hecho. Es un buen recordatorio de que un detector y su remedio son dos definiciones de lo mismo y tienen que coincidir.

### Pieza forense de esta fase

**Los dos documentos de la escritura a medias, unidos por su `X-Request-Id`.**

Reproduce la prueba de fuego y después reconstruye el incidente **sin saber de antemano lo que pasó**, que es como te va a llegar.

**Paso 1 — el síntoma.** Un analista reporta: *"la orden 4021 dice que está en proceso pero sus dos muestras ya están procesadas"*. Es todo lo que hay.

**Paso 2 — los documentos.**

```javascript
db.samples.find({ orderId: 4021 }, { legacyId: 1, status: 1, processedAt: 1 });
// { legacyId: 8801, status: "processed", processedAt: ISODate("2026-09-10T18:22:41Z") }
// { legacyId: 8802, status: "processed", processedAt: ISODate("2026-09-10T18:22:41Z") }

db.orders.find({ legacyId: 4021 }, { status: 1 });
// { status: "in_process" }
```

**Paso 3 — el asiento, que es lo que convierte esto en forense.**

```javascript
db.auditLogServer.find({ entityId: "8802" });
// { action: "[Samples] Transition Sample Success", actor: "analista1",
//   timestamp: ISODate("2026-09-10T18:22:41Z"), requestId: "9d4e1f7a" }
```

Hay asiento de la muestra. **No hay ningún asiento de la orden.** Y hay un `requestId`.

**Paso 4 — el log del servidor, buscando ese identificador.**

```
[labcore] 9d4e1f7a PATCH /samples/8802 -> ... (nunca se cerró esta línea)
```

La línea de entrada está y la de salida no. La petición empezó y no terminó nunca: el proceso murió en medio.

**Paso 5 — el log de `mongod`, la última pieza.**

```
2026-09-10T18:22:41Z I COMMAND  [conn17] update labcore.samples ... 3ms
2026-09-10T18:22:44Z I CONTROL  [signalProcessingThread] got signal 15 (Terminated)
```

La actualización de la muestra llegó. **La de la orden no aparece en ninguna parte**, porque el proceso de la aplicación se cayó antes de emitirla.

Las cuatro preguntas, contestadas con evidencia y no con hipótesis:

- **¿Qué se ve?** Una orden que contradice a sus muestras.
- **¿Qué capa lo produce?** Ninguna capa: **el hueco entre dos capas**, en el instante entre dos escrituras.
- **🧬 ¿Lo escribió el sistema o llegó roto en el dato?** Lo escribió el sistema, correctamente, la mitad de las veces que hacía falta. Los dos documentos son válidos por separado; lo inválido es la relación entre ellos, y **ninguna de las dos escrituras podía saberlo**.
- **¿Con qué se demuestra?** Con el `requestId` uniendo las tres fuentes —la base, el log de la aplicación y el log de `mongod`—. Sin ese identificador, esto es una conjetura razonable. Con él, es una reconstrucción.

> 🧠 **Guarda esa última frase, porque es la que justifica el filtro de treinta líneas que escribiste en `be01` y que entonces parecía burocracia.** Un identificador de petición no sirve de nada el 99 % de los días. El día que sirve, es la diferencia entre reconstruir un incidente y opinar sobre él.

🧨 **Rompe a propósito.** Con el detector corriendo, provoca **diez** escrituras a medias seguidas y déjalo trabajar. Después mira el libro: ¿diez asientos o uno? Si son diez, ¿son distinguibles entre sí? ¿Podría alguien de Calidad leerlo? Ese ejercicio de legibilidad importa más que la corrección del código: un libro de correcciones que nadie puede leer es un `console.log` con persistencia.

---

## 🧪 7. Ejercicios (33)

**🟢 Fácil (1–8)**

1. Declara el `MongoTransactionManager`, anota `processSample` con `@Transactional`, ejecútalo y captura el error completo. Guarda la salida literal: es la cita más usada del track.
2. Reproduce el falso positivo del §5.2 —`startTransaction()` sin operación— y después la versión correcta. Anota las dos salidas lado a lado.
3. Levanta el `mongo:4.0` como replica set de un nodo y corre el mismo guion. Confirma `PERMITIDA` y anota que no cambiaste ni una línea de código.
4. Escribe el invariante del §4.1 en `CONTRACT.md`, en una frase, con los tres documentos que participan.
5. Corre la agregación de eslabones huérfanos y anota el número en `MEASUREMENTS.md`.
6. Corre la de órdenes que se quedaron atrás y anota el suyo.
7. Comprueba con `db.serverStatus().repl` qué devuelve tu base standalone, y con la del replica set. Anota la diferencia y por qué explica todo lo demás.
8. Implementa `Correction` y su repositorio **sin ningún método de actualización**. Comprueba que compila y que no hay forma de mutar un asiento.

**🟡 Intermedio (9–18)**

9. Implementa el detector con su comprobación de idempotencia y provócalo tres veces sobre el mismo problema. Confirma que hay una sola corrección.
10. Implementa `apply()` con sus tres escrituras y comprueba las tres en la base.
11. **Diagnóstico.** Separa las 23 muestras rotas en dos poblaciones: las que tienen asiento en `auditLogServer` y las que no. Explica qué historia cuenta cada grupo y por qué el segundo probablemente no es un problema de transacciones.
12. **Diagnóstico.** Quita el bean del gestor de transacciones dejando el `@Transactional`. Comprueba que **no falla y no hace nada**. Explica en dos líneas por qué ese silencio es peor que el error 20.
13. **Diagnóstico.** Provoca la autoinvocación: llama a `processSample` desde otro método de la misma clase. Confirma que la transacción no se abre y explica por qué el proxy no interviene.
14. Mide el coste del detector: cronométralo sobre la colección entera y calcula qué pasaría con diez veces más muestras. Decide si una vez por hora es la frecuencia correcta.
15. Escribe la consulta que un auditor pediría: *"muéstrame todas las correcciones aplicadas sobre muestras en el último trimestre, con quién las decidió y por qué"*. Si la respuesta no cabe en una pantalla legible, el diseño del libro está mal.
16. **Diagnóstico.** Aplica una corrección y después búscala en `auditLogServer`. Confirma que el actor dice `system` y no una persona. Explica por qué esa distinción importa más que la corrección misma.
17. Escribe la tabla de las tres salidas del §5.5 con tus propias estimaciones de horas, justificando cada una. No copies las del capítulo: las tuyas tienen que salir de tu proyecto.
18. **Diagnóstico.** Con `writeConcern` `{w:1, j:true}` explícito, repite la prueba de fuego. Comprueba que **no cambia nada** y explica en tres líneas la diferencia entre durabilidad y atomicidad, que es la confusión más común de todo el tema.

**🟠 Difícil (19–26)**

19. **Diagnóstico.** Ejecuta la pieza forense completa, los cinco pasos, y escribe la reconstrucción con las cuatro preguntas. Incluye las tres fuentes: base, log de la aplicación y log de `mongod`.
20. **Diagnóstico.** Provoca una escritura a medias **sin matar el proceso**: haz que la escritura de la orden lance una excepción. Comprueba que el resultado es el mismo estado inconsistente y explica por qué un `try/catch` alrededor no lo arregla.
21. Implementa la salida **B** —clave única por `(requestId, entityType, entityId)` y reintento— en una rama aparte. Mide qué pasa cuando el cliente reintenta la misma petición dos veces. Después decide si la dejas conviviendo con la C o no.
22. **Diagnóstico.** Con el sistema apuntando al replica set del ejercicio 3, ejecuta la transición cien veces con fallos inyectados en medio y confirma que **no aparece ni un estado inconsistente**. Ese contraste, medido, es el argumento de la salida A en `be08`.
23. **Diseño.** Escribe el procedimiento operativo de conversión a replica set: pasos, ventana necesaria, qué cambia en la cadena de conexión, qué pasa con los respaldos, y cómo se revierte si sale mal. Una página. Es lo que le mandarías al proveedor, y es un entregable de `be08`.
24. **Diagnóstico + escritura.** Cruza las 23 muestras rotas con los informes emitidos: ¿cuántas tienen un PDF entregado (`status: delivered` en su orden)? Ese número es el que hay que llevar a Calidad, y es una conversación distinta de la técnica.
25. Haz el 🧨 de la sección 6 —diez escrituras a medias— y evalúa la legibilidad del libro. Reescribe lo que haga falta para que una persona no técnica pueda leerlo. Documenta qué cambiaste.
26. **Diagnóstico.** Encuentra una operación del sistema que **sí** sea segura hoy, y explica por qué: un solo documento. El `CounterService` de `be03` es un buen candidato. Escribir por qué algo funciona es más difícil que escribir por qué algo falla, y es lo que hace falta para saber dónde no hay que preocuparse.

**🔴 Muy difícil (27–33)**

27. **Adversarial — Cassandra.** El nuevo arquitecto propone migrar a Cassandra "porque escala y no tiene estos problemas". Antes de opinar, modela el dominio de LabCore contra su patrón de acceso real y **mide**: cuántas tablas harían falta si se diseña una por consulta, qué pasa con las consultas que hoy son un `$lookup`, y qué garantía transaccional te daría (menos que la que tienes). Apóyate en [`bea-09`](./bea-09-cassandra-la-tentacion-y-el-acierto-que-nadie-tuvo.md). Escribe la respuesta con números. Y después escribe la segunda mitad, que es la honesta: **dónde sí era la respuesta correcta y nadie la usó** —la telemetría del analizador, serie temporal pura—. No era mala la tecnología: estaba en el módulo equivocado.
28. **Adversarial.** Argumenta bien la posición contraria a la fase: *"veintitrés muestras en seis años es una tasa de error de 0,0004; cualquier proceso manual de un laboratorio tiene una tasa peor; esto es sobreingeniería"*. Dale sus mejores razones, con los números reales. Después refútala con el único argumento que importa en un dominio regulado, que no es estadístico.
29. **Diseño.** El detector corre cada hora. Diseña qué pasaría con dos instancias de la aplicación: qué se rompe, cómo se arregla, y cuánto cuesta. Después decide, con la fecha de decomisión delante, si lo implementas. La respuesta correcta probablemente sea que no, y hay que saber escribir por qué.
30. **Diagnóstico y escritura.** Escribe el post-mortem de ocho puntos del incidente **be-08** con el formato del cuaderno, sin culpabilización, y con el test de regresión — que en este caso no puede ser una prueba unitaria, y explicar por qué es parte del ejercicio.
31. **Escritura.** Redacta el párrafo del documento de `be08` que le explica a un auditor por qué el sistema no puede garantizar la atomicidad de la cadena de custodia, qué se hizo en su lugar, y por qué eso es defendible. Máximo doscientas palabras, sin una sola palabra técnica que no expliques.
32. **Adversarial.** Alguien propone "aprovechar y arreglar las 23 de una vez" con un script que ponga cada muestra en el estado correcto. Escríbelo. Después enumera exactamente qué evidencia se destruiría y qué le contestarías a un auditor que preguntara *"¿cómo sé que esas 23 estaban mal y no las corrigieron para tapar otra cosa?"*. Decide, y escribe la decisión.
33. **La medición que cierra la fase.** Con todo lo anterior, escribe la página *"Qué garantías da hoy LabCore sobre la cadena de custodia"*, dirigida a alguien técnico de fuera. Tiene que decir qué está garantizado, qué está solo detectado, qué no se puede afirmar, y desde cuándo cada cosa. Es el capítulo central del documento de `be08` y el más difícil de escribir sin exagerar en ninguna de las dos direcciones.

**🔥 Opcionales**

- 🔥 Implementa el invariante con `$merge` o con una escritura única que meta la orden y la muestra en el mismo documento. Mide qué se rompe del contrato al hacerlo y por qué esa solución, siendo correcta en el papel, no se puede aplicar aquí.
- 🔥 Mide el coste de una transacción en el replica set del ejercicio 3: cien transiciones con y sin transacción, mediana y percentil 95. Anota el sobrecosto. Es un dato que la salida A necesita y que casi nadie mide antes de decidir.
- 🔥 Lee el código de `be03` buscando **todas** las operaciones que escriben más de un documento. Haz la lista completa. Probablemente sean más de las que recuerdas, y esa lista es el verdadero alcance del problema de esta fase.

---

## 📚 8. Referencias

**Documentación oficial**

- MongoDB 4.0 — transacciones, con la lista de requisitos donde figura el replica set: https://www.mongodb.com/docs/v4.0/core/transactions/
- Atomicidad de documento único, que es la garantía que **sí** tienes siempre: https://www.mongodb.com/docs/v4.0/core/write-operations-atomicity/
- `writeConcern` y por qué no es lo mismo que una transacción: https://www.mongodb.com/docs/v4.0/reference/write-concern/
- Convertir un standalone en replica set — el procedimiento oficial del ejercicio 23: https://www.mongodb.com/docs/v4.0/tutorial/convert-standalone-to-replica-set/
- Spring Data MongoDB 2.1 — soporte de transacciones y `MongoTransactionManager`: https://docs.spring.io/spring-data/mongodb/docs/2.1.x/reference/html/#mongo.transactions
- Spring — por qué `@Transactional` no funciona en la autoinvocación: https://docs.spring.io/spring/docs/5.1.19.RELEASE/spring-framework-reference/data-access.html#transaction-declarative

**Libros y artículos de referencia**

- Martin Kleppmann, *Designing Data-Intensive Applications* (2017), capítulo 7 completo — *Transactions*. Es la referencia definitiva y el capítulo 7 §*Weak Isolation Levels* explica por qué "tenemos transacciones" tampoco significa siempre lo que la gente cree.
- Pat Helland, *Life beyond Distributed Transactions: an Apostate's Opinion* (2007): https://queue.acm.org/detail.cfm?id=3025012 — el artículo que fundó la idea de trabajar sin transacciones distribuidas. Es exactamente la posición en la que estás, escrita doce años antes.
- Gregor Hohpe y Bobby Woolf, *Enterprise Integration Patterns* (2003) — el patrón de *compensating transaction*, que es lo que el libro de correcciones implementa con otro nombre.
- Sobre el asiento de compensación en contabilidad, que es de donde viene todo esto: cualquier manual de partida doble sirve, y leer veinte páginas de uno hace más por entender esta fase que otro artículo de bases de datos.

**Video y apoyo**

- Charlas de MongoDB World 2018-2019 sobre la llegada de las transacciones multidocumento: https://www.youtube.com/results?search_query=mongodb+multi+document+transactions+4.0 — útiles para ver el contexto de la época y entender por qué en 2019 nadie las daba por sentadas.

**Orden de lectura sugerido:** la página oficial de transacciones **antes** de escribir el §5.1, para poder decir que lo intentaste sabiendo lo que hacías → Helland justo después del rechazo, que es cuando su argumento se entiende → Kleppmann cap. 7 mientras costeas las tres salidas → Hohpe y Woolf al escribir el libro de correcciones → el tutorial de conversión, solo cuando llegues al ejercicio 23.

> ⚠️ URLs y contenidos cambian. Y con este tema, un aviso concreto: **casi todo lo que encuentres sobre transacciones en MongoDB da por supuesto un replica set**, porque desde hace años es la configuración por defecto de todo el mundo. Que un artículo no mencione el requisito no significa que no exista.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Escribiste la transacción correcta, el servidor la rechazó, y demostraste en dos comandos que la capacidad estaba ahí desde el principio. Después mediste lo que ya estaba roto —23 y 9, números pequeños e incómodos—, costeaste las tres salidas, e implementaste la única que un dominio regulado admite del todo: no arreglar tachando, sino compensar dejando rastro.

Lo que te llevas no es una técnica de MongoDB. Es la secuencia completa de trabajo cuando el sistema no puede darte la garantía que el dominio exige: **nombrar el invariante, intentar la solución correcta, documentar el rechazo con su evidencia, medir el daño real, costear las salidas, elegir la que no depende de nadie, y declarar en voz alta qué quedó sin garantizar.** Esa secuencia sirve igual sin MongoDB, sin Java y sin laboratorio.

Y queda un cabo suelto que `be07` va a recoger, así que anótalo: **nadie convierte un standalone en replica set durante un bump de versión**. La topología de 2019 sobrevive intacta a todo lo que le pase a la base, y eso significa que la transacción va a seguir siendo imposible en 2026 — con el agravante de que, para entonces, el manual va a decir que se puede.

Antes de eso, **be06**: los rangos de referencia versionados y una pregunta de auditor que parece fácil. *"¿Qué rango de glucosa estaba vigente el 12 de marzo de 2020?"*. Un sistema clínico tiene que poder contestarla. El de 2019 hacía `$set` sobre el documento del rango, así que el histórico se sobrescribió. Aquí perdiste 23 cadenas de custodia; allí vas a perder catorce meses de historia, y esa sí que no se puede reconstruir.

> **La señal de que quedó bien:** *"sé exactamente qué garantía no me da mi despliegue, tengo el mensaje de error que lo demuestra, y tengo un libro donde consta cada vez que eso me costó algo."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en verde y `git status` limpio:
>
> ```bash
> git tag -a be-fase-05-la-cadena-de-custodia-y-la-transaccion -m "be05 cerrada: invariante escrito; transaccion intentada y rechazada (codigo 20, capturado); capacidad demostrada sobre replica set de un nodo; 23 eslabones huerfanos y 9 ordenes atrasadas medidos; tres salidas costeadas; libro de correcciones append-only con detector idempotente"
> ```
>
> Los commits de la fase llevan su prefijo (`be05: …`) y los de ejercicio su número (`be05 ej27: …`). Todo eso está en [`00-convencion-de-git-y-tags.md`](./00-convencion-de-git-y-tags.md) §10.

---

## 📌 Pendientes sugeridos

- **[A] La salida A —convertir a replica set— queda documentada y no ejecutada**, con su procedimiento operativo del ejercicio 23. Es una recomendación fechada para `be08`, no una tarea del track. Ninguna fase la ejecuta sin decidir antes de quién es la base.
- **[B] El libro de correcciones es append-only por disciplina, no por el motor.** Nada impide un `$set` desde el shell. `be08` decide si eso se refuerza con `$jsonSchema` o si se queda en convención documentada — y esa decisión es de las que un auditor pregunta.
- **[C] El `@Scheduled` sin bloqueo distribuido** es correcto con una instancia y solo con una. Declarado como 💸 y no pagado. Si alguna vez se despliegan dos, se rompe en silencio.
- **[D] La lista completa de operaciones multidocumento** (🔥 tercero) tiene que existir antes de `be08`: es el alcance real del problema y hoy solo está medido el caso de la custodia.
- **[E] La convergencia no es atomicidad** y esa distinción tiene que llegar a `be08` sin suavizar. Todo el valor del documento final depende de no llamar "arreglado" a lo que está "detectado y compensado".
- **[F] Las 23 muestras rotas no se tocan.** Se detectan, se compensan si procede, y la evidencia original se conserva. Si `be08` propone limpiarlas, tendrá que responder primero la pregunta del ejercicio 32.

### Reservas para el cuaderno de incidentes

| ID | Título propuesto | Categoría | Dificultad |
|---|---|---|---|
| **be-08** | *"La orden que contradice a sus muestras"* | Atomicidad / escrituras parciales | 🔴 |
| **be-09** | *"Arreglamos las veintitrés y ahora nadie sabe qué pasó"* | Evidencia / correcciones destructivas | 🔴 |

**be-08** es la pieza forense de la sección 6 entregada como ticket: *"la orden 4021 dice en proceso y sus dos muestras están procesadas"*. La resolución no es un fix: es una reconstrucción con tres fuentes y un `requestId`, y termina en una corrección compensatoria. El post-mortem tiene que llegar a la frase del §4.1 —tres documentos, un hecho— y a por qué el test de regresión no puede ser una prueba unitaria.

**be-09** es el contrario y el más formativo de los dos: alguien **ya corrió** el script de limpieza del ejercicio 32 antes de que llegaras. Las cadenas están consistentes, no hay libro de correcciones, y Calidad pregunta cuántas muestras estuvieron afectadas y durante cuánto tiempo. La respuesta correcta es *"no se puede saber"*, y el trabajo del incidente es demostrar por qué y escribir qué se hace a partir de ahora. Es el mejor argumento del track a favor de la regla del §4.4, porque se aprende por ausencia.
