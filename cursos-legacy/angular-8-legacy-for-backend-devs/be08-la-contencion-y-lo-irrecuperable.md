# 🧯 Fase be08 — La contención medida y la declaración de lo irrecuperable

> Tutorial Angular 8 — Laboratorio clínico · 🔥 Track BE · Fase be08 de be08 · **10 horas** · cierre del track
> Depende de: be00 a be07 cerradas — esta fase consume los números que todas produjeron
> Habilita: nada. Es el final.
> Apéndices de apoyo: [bea-06 (`$jsonSchema` sobre datos sucios)](./bea-06-jsonschema-sobre-datos-sucios.md) · [bea-11 (mapa de deuda del track BE)](./bea-11-mapa-de-deuda-del-track-be.md) · [bea-09 (Cassandra: la tentación)](./bea-09-cassandra-la-tentacion-y-el-acierto-que-nadie-tuvo.md) y [bea-10 (riesgo de licencia)](./bea-10-riesgo-de-licencia-sspl.md), los dos en el árbol de veredicto de §5.6 · [Incidentes asociados](./cuaderno-incidentes-be.md): be-12

---

## 🎯 1. Propósito

Entregar un plan de contención medido y un documento que un auditor pueda leer — y defender por escrito por qué **no** se migra.

Ocho fases produjeron números. Esta no produce ninguno: los gasta. Y termina con el entregable más valioso del track, que no es código sino una página firmada que dice qué historia se perdió, desde cuándo, por qué, y qué se le contesta a quien pregunte.

Llegas con tres piezas por construir y una decisión por tomar. Las piezas son un retrofit de validación sobre datos sucios, un outbox hacia un read-model, y el libro de correcciones que ya lleva tres fases funcionando. La decisión es la del título, y tiene una regla que la gobierna entera:

> 🧭 **La respuesta correcta depende de la fecha de decomisión, no de la calidad del código.** LabCore tiene dos años. Si tuviera diez, media de las decisiones de esta fase se invertirían — y saber decir en qué punto exacto se invierten es lo que separa a alguien que decide de alguien que opina.

Hay una tentación grande al llegar aquí, después de haber medido cinco formas de documento, 37 órdenes huérfanas, 23 cadenas rotas y catorce meses de historia perdida: escribir el documento que recomienda rehacerlo todo. **Esa es la conclusión fácil y es la equivocada**, y demostrar por qué es lo que esta fase pide.

---

## ✅ 2. Qué queda listo al terminar

- [ ] Tienes los ocho números del track en una sola tabla, cada uno con su fase, su medición y su fecha.
- [ ] `$jsonSchema` está aplicado en modo `warn` sobre las dos colecciones críticas, **con el número de documentos que rechazaría medido antes de aplicarlo**, y la decisión de qué se tolera está escrita.
- [ ] El outbox hacia `postgres:16.9` funciona, alimenta el read-model de lo normativo y del dashboard, y tienes **medida y declarada** su ventana de inconsistencia.
- [ ] `smoke.sh` sigue entero en verde y **no toca Postgres ni una vez**. El read-model no participa del contrato.
- [ ] El libro de correcciones de `be05` está en producción, y los permisos de la cuenta de la aplicación ya no le dejan mutar `referenceRanges`.
- [ ] La estrategia de pruebas está decidida **midiendo**, con los dos tiempos de ciclo anotados, y con el hallazgo que cambió el criterio.
- [ ] El árbol de veredicto está escrito, con las cuatro opciones costeadas y la recomendación argumentada contra la fecha de decomisión.
- [ ] **`IRRECOVERABLE.md` existe, firmado y fechado**, y lo puede leer alguien que no sea ingeniero.
- [ ] El cierre honesto está escrito: dónde ganó MongoDB de verdad, con el número de las dos columnas.

---

## 🚫 3. Qué NO entra

- **Migrar nada a Postgres.** El read-model es de lectura, no participa del contrato, y el sistema operativo sigue en Mongo hasta que muera. Si en algún momento alguien propone moverle escrituras, esa propuesta está mal por definición.
- **Convertir a replica set.** Se recomienda con su procedimiento y su coste; ejecutarlo es decisión de quien paga el contrato con el proveedor.
- **Reparar los 37 veredictos de `be06` ni las 23 cadenas de `be05`.** Se declaran. Cualquier acción sobre ellos pasa por el libro de correcciones y por una decisión de Calidad, no de ingeniería.
- **Tocar el frontend.** Última vez que se dice: no se toca. El track entero se hizo sin cambiar un archivo de la aplicación Angular, y esa restricción fue lo que lo hizo enseñable.
- **Cerrar la deuda.** Esta fase no la cierra: la deja **medida, contenida y declarada**, que es una cosa distinta y hay que saber decirlo así.

---

## 🧠 4. Concepto mínimo

### 4.1 Contener no es arreglar, y hay cuatro verbos

El vocabulario de esta fase, porque usar el verbo equivocado en un documento firmado es lo que hace que el documento no valga:

| Verbo | Qué significa | Ejemplo del track |
|---|---|---|
| **Prevenir** | El problema ya no puede ocurrir | La guarda de inmutabilidad de `be06`: ya no se puede mutar un rango desde la aplicación |
| **Detectar** | Puede ocurrir, y te enteras | El detector de `be05`: las cadenas rotas se encuentran en la siguiente pasada |
| **Compensar** | Ocurrió, y queda un asiento de lo que se hizo | El libro de correcciones |
| **Declarar** | No se puede hacer nada, y consta por escrito | Los catorce meses de `be06` |

> 🧠 **Los cuatro son resultados legítimos. El único resultado ilegítimo es no saber en cuál estás.** Un equipo que cree haber prevenido algo que solo detecta está a un incidente de una sorpresa; uno que declara lo que podría haber prevenido está regalando calidad. La mitad del trabajo de esta fase es clasificar correctamente cada uno de los ocho hallazgos del track en una de esas cuatro casillas.

### 4.2 Estrangular por read-model, nunca por reescritura

El patrón de la higuera estranguladora —construir lo nuevo al lado de lo viejo e ir moviendo tráfico— es el que se usa para reemplazar un sistema sin apagarlo. En `be03` hiciste el primer corte, y salió bien.

Aquí **no se hace un segundo corte**, y la razón hay que tenerla clara antes de escribir una línea de Postgres.

Lo que entra es un **read-model**: una copia derivada, de solo lectura, alimentada desde Mongo, que sirve dos cosas que Mongo sirve mal —consultas normativas con muchos cruces, y agregaciones del dashboard sobre rangos de fechas—. El sistema operativo no se entera: sigue escribiendo en Mongo, sigue leyendo de Mongo, sigue sirviendo el contrato desde Mongo.

Lo que **no** entra es mover escrituras. Y los motivos, en orden:

1. **El contrato vive en Mongo.** Mover escrituras significa que el contrato pasa a depender de dos almacenes y de la sincronización entre ellos. Eso no es simplificar: es multiplicar los modos de fallo justo en el sistema que menos capacidad tiene de diagnosticarlos.
2. **Dos años.** Una migración de escrituras es un proyecto de meses con un riesgo alto sobre un sistema que factura. La aritmética de `00-historia-del-sistema.md` sigue mandando: pagar una deuda que tarda un mes en un sistema al que le quedan veinticuatro es, muchas veces, la decisión equivocada.
3. **Y la que más pesa: no hay quien lo pida.** Ninguno de los ocho hallazgos del track se resuelve migrando. Los cinco esquemas se resuelven validando, la transacción se resuelve con topología, la historia perdida no se resuelve. **Una migración no arregla nada de lo que mediste**, y eso es un dato, no una opinión.

> 🧭 **El criterio, escrito para que se pueda citar:** *un read-model se justifica por una consulta que el almacén principal sirve mal. Una migración de escrituras se justifica por una garantía que el almacén principal no da y que el negocio necesita.* Aquí hay lo primero y no hay lo segundo — la garantía que falta, la transacción, se arregla con una línea de configuración del despliegue, no cambiando de motor.

### 4.3 Qué es una declaración de lo irrecuperable

Es un documento corto que dice, sobre cada pieza de historia que el sistema no conserva: **qué se perdió, desde cuándo, cómo lo sabemos, qué consecuencia tiene, y qué se hace a partir de ahora**. Va firmado, va fechado, y va dirigido a alguien concreto.

Suena a burocracia y no lo es. Es la diferencia entre dos conversaciones con un auditor:

> — *¿Pueden demostrar contra qué rango se validó este resultado de 2020?*
> — *No lo sé, déjame investigar.*

frente a:

> — *¿Pueden demostrar contra qué rango se validó este resultado de 2020?*
> — *No. Está declarado en este documento desde septiembre de 2026, con la ventana exacta, el número de resultados afectados, el método con el que lo determinamos, y las medidas que tomamos para que no vuelva a ocurrir.*

**La segunda respuesta no arregla nada y cambia el resultado de la auditoría.** No porque haga desaparecer el problema, sino porque demuestra control: un equipo que sabe qué no sabe es un equipo fiable. Un equipo que se entera del problema en la reunión, no.

> 🧠 **Y el corolario que hay que interiorizar: escribir esto es más difícil que arreglar la mayoría de los bugs que has arreglado en tu vida**, porque exige decir "no se puede" sin excusarse y sin dramatizar, con el número exacto delante. Es la habilidad que este track entero venía a entrenar, y los ejercicios 🔴 de esta fase son casi todos de escritura por eso.

### 4.4 ⚖️ La regla de la fecha de decomisión

La fase entera se resuelve con una pregunta y su respuesta cambia todo:

> **¿Cuánto le queda a este sistema?**

Con **diez años por delante**, casi todas las deudas del track se pagan: se convierte a replica set, se normaliza el esquema, se implementa el modelo bitemporal completo, se migra lo relacional a un motor relacional. Todas se amortizan.

Con **dos años**, casi ninguna. No porque no sean reales —las mediste—, sino porque el retorno de pagarlas no cabe en el tiempo que queda, y el riesgo de tocar un sistema sin pruebas es inmediato mientras el beneficio es diferido.

> ⚖️ **El punto de equilibrio no es una intuición: se calcula, y calcularlo es el ejercicio 22.** Para cada deuda: coste de pagarla (horas + riesgo) contra coste de convivir con ella (incidentes al año × coste por incidente). El cociente da un número de años, y ese número comparado con la vida restante decide. Casi todas las deudas de LabCore dan entre cuatro y nueve años. **Con dos, ninguna entra.**
>
> Y la excepción que sí entra —y por eso es la única recomendación fuerte del documento final— es la conversión a replica set: dos días de trabajo contra una garantía que el dominio exige. Se paga en meses, no en años.

---

## 💻 5. Código mínimo con comentarios

Seis piezas, y dos de ellas son documentos.

### 5.1 El inventario: los ocho números

Primero, todo junto. Esta tabla es el esqueleto del documento final y se construye copiando de `MEASUREMENTS.md`, sin recalcular nada.

| # | Hallazgo | Número | Fase | Casilla (§4.1) |
|---|---|---|---|---|
| 1 | Formas distintas del documento de paciente | **5** | be02 | Detectar |
| 2 | Órdenes que apuntan a un paciente inexistente | **37** | be02 | Detectar |
| 3 | Poblaciones distintas de "sin correo" | **3** (1630/906/247) | be02 | Declarar |
| 4 | Asientos de auditoría con actor discrepante no benigno | **1** | be04 | Prevenir (desde 10/09/2026) |
| 5 | Cadenas de custodia con eslabón huérfano | **23** | be05 | Compensar |
| 6 | Órdenes que se quedaron atrás de sus muestras | **9** | be05 | Detectar + compensar |
| 7 | Veredictos históricos que no se pueden reproducir | **37** | be06 | **Declarar** |
| 8 | Versiones mayores de base subidas sin decisión del equipo | **4** | be07 | Declarar |

> ⚠️ **Regla de higiene del documento final, y es la que más veces se rompe:** ninguno de estos números se recalcula al escribir el informe. Se **cita** con su fecha y su fase. Un número recalculado sobre una base que ha cambiado desde entonces no coincide con el de `MEASUREMENTS.md`, y en cuanto dos documentos de la misma empresa dan cifras distintas del mismo hecho, los dos dejan de servir.

### 5.2 El retrofit de `$jsonSchema`: medir antes de aplicar

Poner validación sobre datos sucios es un tema en sí mismo y `bea-06` lo cubre entero. Lo que esta fase hace es el procedimiento correcto, que tiene tres pasos y **el primero no toca la base**.

**Paso 1 — medir cuánto rechazaría.** Antes de aplicar nada:

```javascript
// El esquema candidato, escrito primero como una CONSULTA. Se cuenta cuántos
// documentos NO lo cumplirían, y ese número decide si el esquema es
// aplicable o si hay que aflojarlo.
//
// Esto es lo contrario de lo que hace casi todo el mundo, que aplica el
// esquema en warn y después mira el log. El problema de eso es que el log
// solo te enseña lo que se ESCRIBE; los documentos viejos que nadie toca no
// aparecen nunca, y son exactamente los que van a reventar el día que subas
// el nivel a error.
db.patients.count({ $or: [
  { documentId: { $exists: false } },
  { documentId: { $not: { $type: 'string' } } },
  { fullName:   { $exists: false } },
  { birthDate:  { $not: { $type: 'string' } } }
]});
```

```
1630
```

Mil seiscientos treinta documentos no pasarían el esquema "obvio". Son las formas **C** y **D** de `be02` —718 sin `fullName` y 912 con `birthDate` de tipo `date`—, o sea un tercio de la colección. **Aplicar ese esquema en modo `error` dejaría el sistema sin poder actualizar a un tercio de sus pacientes.**

**Paso 2 — decidir qué se tolera, y escribirlo.** El esquema no se afloja "hasta que pase todo": se afloja **por hallazgo**, con la razón al lado.

```javascript
db.runCommand({
  collMod: 'patients',
  validator: { $jsonSchema: {
    bsonType: 'object',
    // Solo documentId. fullName queda FUERA de required a propósito: 718
    // documentos de la importación de 2020 no lo tienen y nunca lo van a
    // tener. Exigirlo bloquearía su mantenimiento sin recuperar el dato.
    required: ['documentId'],
    properties: {
      documentId: { bsonType: 'string' },
      // birthDate admite los DOS tipos, porque los dos existen (be02 §5.4).
      // Es feo y es honesto: el esquema describe lo que hay, no lo que
      // querríamos. Un esquema que miente sobre los datos no protege nada.
      birthDate: { bsonType: ['string', 'date'] },
      active: { bsonType: ['bool', 'null'] }
    }
  }},
  // warn: registra y DEJA PASAR. Nada se rompe hoy.
  validationAction: 'warn',
  // moderate: solo valida documentos que ya cumplían. Los viejos se pueden
  // seguir actualizando aunque no pasen — que es justo lo que hace posible
  // aplicar esto un martes sin avisar a nadie.
  validationLevel: 'moderate'
});
```

**Paso 3 — subir a `error`, colección por colección y nunca todo a la vez.** Y solo cuando el log de `warn` lleve semanas limpio. El criterio que se escribe: *"se sube a `error` cuando pasen treinta días sin un solo aviso nuevo"*. Sin un criterio escrito, la subida se decide por corazonada un viernes — que es el incidente **be-12**.

> 🧭 **El patrón general, y vale para cualquier validación retroactiva en cualquier sistema:** *primero se cuenta cuántos no pasan, después se decide qué se tolera con la razón escrita, y solo entonces se endurece.* Invertir ese orden —aplicar y ver qué pasa— funciona en un sistema con datos limpios y es un incidente en uno con seis años encima.

### 5.3 El outbox y el read-model

```java
// El outbox: cada escritura relevante deja un evento en una colección, y un
// proceso lo lleva a Postgres. Es de una sola dirección y de solo lectura al
// otro lado.
//
// 💸 El evento se escribe en el mismo camino que la mutación, sin
// transacción — sí, otra vez el problema de be05. Y aquí SÍ es aceptable,
// por una razón que hay que saber decir: el read-model es DERIVADO. Si un
// evento se pierde, el reconciliador lo detecta comparando totales y
// reconstruye. Perder un derivado es recuperable; perder un hecho no lo es.
// Esa distinción es la que decide dónde una escritura no atómica es
// tolerable y dónde no.
@Document(collection = "outbox")
public class OutboxEvent {
    @Id private String id;
    private String aggregate;     // patients | orders | samples | results | ranges
    private String aggregateId;
    private Instant occurredAt;
    private Object payload;
    private boolean published;
}
```

```sql
-- El read-model en postgres:16.9. Solo lo normativo y el dashboard.
--
-- Fíjate en lo que NO hay: ni un paciente completo, ni una orden completa.
-- Solo lo que hace falta para las dos consultas que Mongo sirve mal. Un
-- read-model que replica el modelo entero deja de ser un read-model y se
-- convierte en una migración a medias, que es lo peor de los dos mundos.
CREATE TABLE result_verdicts (
  result_id        integer PRIMARY KEY,
  analyte          text        NOT NULL,
  value            numeric     NOT NULL,
  validated_at     timestamptz NOT NULL,
  range_version    integer,
  -- Aquí sí se congelan los límites aplicados, que es lo que be06 ej.32
  -- propuso y que aquí tiene sentido porque este almacén es derivado:
  -- desnormalizar en un read-model no es deuda, es su función.
  range_low        numeric,
  range_high       numeric,
  verdict          text        NOT NULL
);

CREATE INDEX ON result_verdicts (analyte, validated_at);
```

**La ventana de inconsistencia, medida y declarada:**

```
Latencia del outbox (p50 / p95 / máx), 1.000 eventos:
  publicación:      120 ms / 480 ms / 2,1 s
  ventana declarada: 5 segundos

Significa: el dashboard puede mostrar datos con hasta 5 segundos de retraso
respecto de la aplicación. Para un dashboard operativo de turno es
irrelevante; para una consulta normativa que alguien cite en un informe, NO
lo es, y por eso el informe se genera contra Mongo y no contra el read-model.
```

> 🧠 **Ese último párrafo es el entregable real del §5.3.** Una ventana de inconsistencia sin declarar es una bomba; declarada, es una característica del sistema que se puede tener en cuenta al decidir qué consulta va a qué almacén. **La consistencia eventual no es un defecto: es un contrato, y los contratos se escriben.**

### 5.4 Los permisos: la contención que sí previene

```javascript
// La guarda de be06 §5.6 vive en la aplicación y el shell la esquiva. Esto
// es lo que la convierte en prevención de verdad: la cuenta con la que la
// aplicación se conecta pierde el permiso de actualizar referenceRanges.
//
// Crear versiones nuevas (insert) sigue permitido. Mutar las existentes, no.
// Nótese lo que esto implica: el $set del §4.2 de be06 habría FALLADO, en
// 2020, con un error de permisos, y alguien habría tenido que preguntar por
// qué. Toda la fase be06 existe porque nadie puso esta línea hace siete años.
db.createRole({
  role: 'labcoreApp',
  privileges: [
    { resource: { db: 'labcore', collection: 'referenceRanges' },
      actions: ['find', 'insert'] },          // <- sin 'update', sin 'remove'
    { resource: { db: 'labcore', collection: '' },
      actions: ['find', 'insert', 'update', 'remove'] }
  ],
  roles: []
});
```

> ⚠️ **Y la limitación honesta, que va en el documento:** esto protege contra el error, no contra la intención. Quien tenga la cuenta administrativa puede hacer lo que quiera, y en LabCore esa cuenta la tiene el proveedor y la tienen dos personas del equipo. La contención razonable de un sistema con dos años de vida llega hasta aquí; ir más allá —auditoría de accesos administrativos, separación de funciones— es un proyecto de seguridad y se recomienda sin ejecutarlo.

### 5.5 La estrategia de pruebas, decidida midiendo

⚠️ Este era el último pendiente abierto del track (`propuesta-fases-backend.md` §5.5) y se cierra aquí, con el criterio que gobierna el resto: **midiendo el tiempo de ciclo**.

Las dos opciones y sus números:

| | Testcontainers | El `mongo:4.0` del compose |
|---|---|---|
| Arranque por clase de prueba | ~4 s | 0 s (ya está arriba) |
| Suite completa (18 pruebas, 6 clases) | ~31 s | ~4 s |
| Aislamiento entre pruebas | total | limpieza manual entre pruebas |
| Reproducible en CI limpio | sí | requiere levantar el compose |
| Java 8 | **sí** — verificado: Testcontainers 1.21.4 compila a *class file* 52 | — |

El tiempo de ciclo favorece claramente la segunda. Pero la decisión **no se toma por eso**, porque al medir apareció algo que la cambia:

> 🧠 **`MongoDBContainer` de Testcontainers arranca la base como replica set de un solo nodo**, para que las transacciones funcionen en las pruebas. Compruébalo tú antes de creerlo —es el ejercicio 12—, y después piensa en lo que significa para LabCore: **tus pruebas correrían sobre una topología que da garantías que producción no da.** Un `@Transactional` verde en el pipeline y rechazado con el código 20 en producción. Es el peor tipo de prueba que existe: una que pasa por un motivo que no se cumple donde importa.

**Decisión, escrita y fechada:** las pruebas corren contra el `mongo:4.0` del `compose.yaml`, con limpieza entre pruebas, **porque es la misma topología de producción**. El tiempo de ciclo lo confirma; la paridad topológica lo decide. Si alguna vez LabCore se convierte a replica set, se revisa — y entonces Testcontainers pasa a ser la opción correcta.

> 🧭 **Y la regla general que sale de aquí, que es de las más caras de aprender:** *un entorno de pruebas que es mejor que producción no es un entorno de pruebas.* Cualquier diferencia —más memoria, menos latencia, datos limpios, una topología más capaz— es una clase de fallo que el pipeline no puede ver.

### 5.6 ⚖️ El árbol de veredicto honesto

Las cuatro opciones, costeadas, con la fecha de decomisión como eje.

**A. Migrar a un motor relacional.** El coste real, no el optimista: rehacer las cinco entidades, reescribir todas las consultas, migrar seis años de datos con cinco formas distintas —y decidir qué hacer con los 1.630 documentos que no encajan—, reescribir el `SeedRunner`, y validar que el contrato sigue cumpliéndose. **Estimación honesta: 4 a 6 meses** con un equipo de dos, más el riesgo de un sistema sin una sola prueba de regresión al empezar. **Qué arregla de los ocho hallazgos: dos** (la integridad referencial y, en parte, la deriva de esquema). No arregla la historia perdida, ni la auditoría del navegador, ni la atomicidad —que sí tendría, pero que ya se puede tener por otra vía mucho más barata—. **Veredicto: no.** Y no por MongoDB: por aritmética.

**B. Convertir a replica set.** Dos días de trabajo, semanas de calendario ajeno, riesgo técnico bajo. **Arregla la atomicidad de golpe** y desactiva la trampa de `be07` —el `@Transactional` que el manual promete y el despliegue niega—. **Veredicto: sí, y es la única recomendación fuerte del documento.** Se paga en meses.

**C. Contener y documentar.** Es lo que acabas de hacer en las tres fases anteriores y en esta. Coste ya pagado. No arregla nada de lo perdido y evita que la lista crezca. **Veredicto: hecho.**

**D. No hacer nada.** Tiene defensa y hay que dársela: el sistema factura, lleva siete años sin un incidente grave por estas causas, y le quedan dos. **Veredicto: no, por un solo motivo** — los 37 veredictos irreproducibles de `be06` son un hallazgo de auditoría con o sin nosotros, y la diferencia entre que los encuentre un auditor y que los hayamos declarado nosotros no cuesta nada y lo cambia todo.

> 📚 **Las dos opciones que alguien va a proponer en esa reunión y no están en el árbol** tienen su apéndice, y los dos se escribieron para este momento: cambiar de motor "porque escala" se contesta con números en [`bea-09`](./bea-09-cassandra-la-tentacion-y-el-acierto-que-nadie-tuvo.md), y "cambiemos de base por el tema de la licencia" se contesta en [`bea-10`](./bea-10-riesgo-de-licencia-sspl.md). Ninguna de las dos mueve el veredicto; las dos hay que saber contestarlas sin improvisar.

> ⚖️ **Y la frase que resume el árbol, que es la que va en el documento:** *no migramos porque migrar no arregla lo que está roto. Convertimos a replica set porque eso sí lo arregla, cuesta dos días, y su ausencia es una trampa para el próximo que llegue. Todo lo demás está contenido, medido y declarado.*

### 5.7 `IRRECOVERABLE.md` — el entregable del track

El índice del documento. Cinco secciones y una página y media, porque un documento que no se lee no protege a nadie:

````markdown
# Declaración de historia irrecuperable — LabCore
Laboratorios Andina S.A.S. · Sistema de gestión de laboratorio clínico
Fecha: 10 de septiembre de 2026 · Responsable: [nombre y cargo]
Dirigido a: Calidad, Dirección Técnica, y a quien herede este sistema

## 1. Alcance y método
Qué se revisó, con qué herramientas, en qué periodo, y **qué NO se revisó**.
Esta sección va primero a propósito: un lector tiene que poder juzgar la
solidez de lo que sigue antes de leerlo.

## 2. Lo que el sistema no puede demostrar
Una fila por hallazgo. Qué se perdió · desde cuándo · cómo lo sabemos ·
si es medido o inferido · cuántos registros afecta.

## 3. Consecuencia práctica
Qué preguntas concretas no se pueden contestar hoy, con ejemplos reales.
"No podemos demostrar contra qué límites se validó un resultado de glucosa
entre junio de 2019 y agosto de 2020. Son 1.204 resultados, de los cuales 37
tendrían hoy un veredicto distinto."

## 4. Qué se hizo, desde cuándo, y qué garantiza
Las cuatro casillas del §4.1, con fecha de entrada en vigor de cada medida.
Aquí se dice **prevenir / detectar / compensar** con precisión, sin inflar.

## 5. Qué queda pendiente y quién tiene que decidirlo
La conversión a replica set, con su coste y su dueño. Y la fecha de
revisión de este documento.
````

Las tres reglas de redacción, que son la mitad de la nota del ejercicio final:

1. **Ni una palabra técnica sin explicar.** El lector es Calidad, no tu equipo.
2. **Lo medido y lo inferido, en columnas separadas**, con el método de cada inferencia. La regla viene de `be06` y aquí se cobra.
3. **Ninguna frase que culpe a una persona.** Ni al equipo de 2019, ni a quien hizo el `$set`, ni a Operaciones. Todas las decisiones fueron razonables con la información del momento, y un documento que busca culpables deja de ser un documento técnico y pasa a ser un problema de otro tipo.

### 5.8 El cierre honesto: dónde ganó MongoDB, con números

Un track que termina enumerando ocho problemas y no dice dónde la decisión de 2019 acertó no ha entendido su propio criterio. Así que el número de la otra columna.

**El panel de resultados es un documento.** No es una metáfora: mira la forma real de los datos.

| Tipo de examen | Forma del resultado |
|---|---|
| Hemograma (CBC) | 11 analitos con sus banderas |
| Perfil lipídico (LIP) | 4 analitos más un índice calculado |
| Cultivo | un texto libre y un antibiograma de longitud variable |
| TSH | un número |

Esos cuatro no comparten forma y no la van a compartir nunca. En un motor relacional hay tres caminos y los tres duelen: una tabla por tipo de examen —y cada examen nuevo es una migración—, una tabla de pares clave-valor —y pierdes el tipo y la consulta se vuelve ilegible—, o una tabla ancha con cincuenta columnas nulas.

Y ahora el número que lo cierra:

```
Tipos de examen añadidos al catálogo entre 2019 y 2026:   14
Migraciones de esquema que costaron:                       0
Despliegues del backend que costaron:                      0
```

**Catorce.** Con una tabla por tipo de examen habrían sido catorce migraciones, cada una con su ventana y su despliegue — sobre un backend congelado, sin dueño, y de otro equipo. **No se habrían hecho.** El laboratorio habría dejado de poder ofrecer exámenes nuevos, o los habría metido a martillazos en la forma de otro, que es peor que cualquier cosa que hayas medido en este track.

> 🧠 **Y el veredicto del track entero, en dos frases:** *la decisión de 2019 fue correcta para el panel de resultados y equivocada para pacientes, órdenes, custodias y rangos.* Un hemograma es un documento; una orden médica es una fila con claves foráneas que a alguien le importan. El equipo vio lo primero, acertó, y **generalizó desde ahí a todo el sistema** — que es un error de rango, no de criterio, y es el error más fácil de cometer con cualquier tecnología que funcione muy bien en algo.
>
> La pregunta que había que hacerse no era *"¿qué base de datos usamos?"* sino *"¿qué modelo de acceso tiene cada parte de mi dominio?"*. Y esa pregunta admite **respuestas distintas dentro del mismo sistema**, que es justo lo que casi nadie se permite.

> **Prueba de fuego.** Con todo aplicado, haz tres comprobaciones. Una: corre `smoke.sh` y confirma que sigue entero en verde y que **no toca Postgres** — grep sobre el guion para estar seguro. Dos: usa la aplicación Angular quince minutos, el recorrido de once pasos de `be00`, y confirma que un usuario no puede distinguir este sistema del que había antes de que empezara el track. Tres: dale `IRRECOVERABLE.md` a alguien que no sea programador y pídele que te explique con sus palabras qué se perdió y qué se hizo. **Si no puede, el documento está mal escrito**, y reescribirlo es más importante que cualquier cosa que quede por programar.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Síntoma: al subir `$jsonSchema` a `error`, la aplicación deja de poder actualizar pacientes antiguos.**
Causa: se subió el nivel sin haber medido cuántos documentos no pasan, o con `validationLevel: strict` en vez de `moderate`. Fix mínimo: bajar a `warn` inmediatamente y empezar por el paso 1 del §5.2. Es el incidente **be-12**.

**Síntoma: el dashboard muestra números distintos de los de la aplicación.**
Causa: la ventana de inconsistencia del outbox, funcionando exactamente como se declaró. Fix mínimo: ninguno — **es el comportamiento correcto**. Lo que hay que arreglar es que no estuviera escrito donde el usuario pudiera verlo.

**Síntoma: los números del informe final no coinciden con `MEASUREMENTS.md`.**
Causa: se recalcularon sobre una base que ha cambiado. Fix mínimo: citar, no recalcular, con la fecha de cada medición. Y si de verdad hace falta volver a medir, se anota como una **medición nueva** con su fecha, no se sustituye la anterior.

**Síntoma: el read-model empieza a recibir escrituras "solo para una cosa".**
Causa: alguien tenía prisa. Fix mínimo: revertir. No hay versión buena de esto: en cuanto una escritura va a Postgres, el contrato depende de dos almacenes y `smoke.sh` deja de poder decidir nada.

**Síntoma: las pruebas pasan y producción falla con el código 20.**
Causa: las pruebas corren sobre el replica set que levanta `MongoDBContainer`. Fix mínimo: la decisión del §5.5. Es la lección de *un entorno de pruebas mejor que producción no es un entorno de pruebas*, cobrada.

### Pieza forense de esta fase

**El viernes que subimos la validación a `error`.**

No es un bug del sistema: es un incidente de **procedimiento**, y por eso cierra el track. El síntoma llega el lunes:

> *"Desde el viernes por la tarde, Recepción no puede actualizar los datos de algunos pacientes. Da error al guardar. Con otros funciona perfectamente."*

**Lo que la hace difícil: falla con unos pacientes y con otros no**, sin patrón visible para quien lo reporta. Recepción atiende a quien llega, así que los casos no tienen ninguna relación entre sí.

Las cuatro preguntas:

- **¿Qué se ve?** Un guardado que falla con un mensaje del servidor poco claro, en una fracción de los pacientes.
- **¿Qué capa lo produce?** La base. Y es la primera vez en todo el track que la respuesta es esa: en `be03` era la serialización, en `be05` el hueco entre escrituras, en `be07` la imagen del contenedor. Aquí es una regla de validación que alguien activó.
- **🧬 ¿Lo escribió el sistema o llegó roto en el dato?** **Llegó roto en 2019 y no pasó nada durante siete años.** El dato lleva ahí desde entonces; lo que cambió es que hoy alguien decidió mirarlo. El incidente no lo causó el dato ni el código: lo causó **una decisión de endurecer**, tomada sin medir.
- **¿Con qué se demuestra?** Cruzando los pacientes que fallan con las cinco formas de `be02`. Los que fallan son exactamente los 1.630 de las formas C y D. El número ya estaba medido desde `be02` — **el incidente era predecible con una consulta de una línea que nadie corrió**.

> 🧠 **Y por eso este es el incidente que cierra el track: el trabajo de ocho fases estaba hecho, el número estaba medido, y aun así el incidente ocurrió — porque medir y consultar lo medido antes de actuar son dos disciplinas distintas.** `MEASUREMENTS.md` no sirve de nada si nadie lo abre antes de tocar producción. La contramedida no es técnica: es que el procedimiento de endurecimiento del §5.2 tenga el paso 1 como paso obligatorio y escrito.

🧨 **Rompe a propósito.** Sube el validador a `error` con `validationLevel: strict` en una copia de la base, intenta actualizar un paciente de la forma C, y captura el mensaje exacto que devuelve la aplicación. Después mide cuánto tarda un desarrollador que no conozca esta fase en relacionar ese mensaje con el `collMod` del viernes. Si tardó más de veinte minutos, el mensaje de error del `@ControllerAdvice` de `be01` necesita más contexto — y arreglarlo es el último commit útil del track.

---

## 🧪 7. Ejercicios (27)

**🟢 Fácil (1–6)**

1. Construye la tabla del §5.1 copiando de `MEASUREMENTS.md`. Confirma que cada número tiene su fase y su fecha, y que ninguno lo recalculaste.
2. Clasifica los ocho hallazgos en las cuatro casillas del §4.1. Justifica cada uno en una línea.
3. Mide, con la consulta del paso 1 del §5.2, cuántos pacientes no pasarían un esquema "obvio". Anota el número y compáralo con las cinco formas de `be02`.
4. Aplica el validador en `warn` con `moderate` y comprueba que no se rompe nada. Usa la aplicación cinco minutos para confirmarlo.
5. Levanta `postgres:16.9` desde el compose y crea la tabla del read-model. Confirma que `smoke.sh` no la toca.
6. Escribe el criterio de subida a `error` —treinta días sin avisos nuevos, o el que decidas— y déjalo en `CONTRACT.md` con tu nombre.

**🟡 Intermedio (7–14)**

7. Implementa el outbox y el publicador, y mide la latencia sobre mil eventos. Anota p50, p95 y máximo.
8. Declara la ventana de inconsistencia con un margen sobre tu p95 medido y justifica el margen.
9. **Diagnóstico.** Provoca una divergencia entre Mongo y el read-model matando el publicador a mitad. Escribe el reconciliador que la detecta comparando totales.
10. Aplica el rol del §5.4 y comprueba que la aplicación ya no puede hacer `update` sobre `referenceRanges` y sí puede insertar una versión nueva.
11. Mide la suite de pruebas con las dos estrategias del §5.5 y anota los dos tiempos de ciclo.
12. **Diagnóstico.** Comprueba tú mismo si `MongoDBContainer` arranca un replica set: levántalo y corre `db.serverStatus().repl`. Anota el resultado y qué implica para tus pruebas.
13. Escribe una prueba que **pase** con Testcontainers y **falle** contra el compose. Que exista esa prueba es la demostración del §5.5.
14. **Diagnóstico.** Comprueba si alguna de las mediciones de `be02` da hoy un número distinto del que anotaste entonces. Si alguna cambió, escríbela como medición nueva con su fecha — no sustituyas la vieja.

**🟠 Difícil (15–21)**

15. **Diagnóstico.** Ejecuta la pieza forense completa: sube a `error` con `strict` en una copia, provoca el fallo, y cruza los pacientes afectados con las cinco formas. Confirma que son exactamente 1.630.
16. Escribe el esquema `$jsonSchema` definitivo para `results` —la colección más crítica— con la misma disciplina del §5.2. Mide antes, decide qué toleras, y escribe la razón de cada tolerancia.
17. **Diagnóstico.** Mide cuánto ocupa el read-model y cuánto tarda la consulta del dashboard en Postgres contra la misma en Mongo. Si Postgres no gana con claridad, **quita el read-model**: no se justifica.
18. Escribe el procedimiento de endurecimiento —los tres pasos del §5.2— como un documento operativo que alguien pueda seguir sin haber leído esta fase.
19. **Diseño.** Calcula el punto de equilibrio de tres deudas del track: coste de pagarla contra coste de convivir con ella, en años. Compara con los dos años de vida restante y anota cuáles entran.
20. **Diagnóstico.** Repasa `bea-11` —el mapa de deuda del track BE— y comprueba que cada deuda declarada en las ocho fases está ahí, con su fase de origen y su casilla del §4.1. Las que falten, añádelas.
21. **Escritura.** Redacta la sección 4 de `IRRECOVERABLE.md`: qué se hizo, desde cuándo, y qué garantiza cada medida. Usa los verbos del §4.1 con precisión y no infles ni uno.

**🔴 Muy difícil (22–27)**

22. **Diseño y defensa.** Escribe el árbol de veredicto completo del §5.6 con **tus** estimaciones, no las del capítulo. Cada una justificada. Después defiéndelo, por escrito, contra las dos objeciones que de verdad te van a hacer: *"si está tan mal, hay que rehacerlo"* y *"si lleva siete años funcionando, no toques nada"*.
23. **Adversarial.** Argumenta la migración a relacional lo mejor que puedas: con sus beneficios reales, su coste honesto, y la circunstancia en la que sería la decisión correcta. Tiene que ser un argumento que te costaría refutar. Después refútalo con la regla del §4.4 y con el número del §5.8 — y señala exactamente qué tendría que cambiar en la fecha de decomisión para que tu refutación dejara de valer.
24. **Escritura.** Redacta `IRRECOVERABLE.md` entero, las cinco secciones, página y media. Es el entregable del track.
25. **Defensa.** Entrégaselo a alguien que no sea programador y pídele que te explique con sus palabras qué se perdió y qué se hizo. Anota qué no entendió y reescribe esas partes. Repite hasta que lo entienda a la primera. **Este ejercicio no se puede hacer solo y es el más importante del track.**
26. **Diagnóstico y escritura.** Escribe el post-mortem de ocho puntos del incidente **be-12** con el formato del cuaderno. El punto difícil es la contramedida: no es técnica, y explicar por qué un procedimiento escrito vale más que un `if` es lo que cierra el track.
27. **El cierre honesto.** Escribe la página *"Dónde acertó la decisión de 2019"*, con el número de las dos columnas del §5.8. Tiene que ser tan rigurosa como la de los hallazgos y tiene que convencer a alguien que haya leído las ocho fases anteriores y llegue predispuesto en contra. Si no puedes escribirla con honestidad, vuelve a `be00` §4.2: algo se torció por el camino.

**🔥 Opcionales**

- 🔥 Implementa el reconciliador del outbox como un trabajo programado y mide cuántas divergencias encuentra en una semana de uso normal. El número —probablemente cero— también es un dato para el documento.
- 🔥 Escribe la versión de `IRRECOVERABLE.md` que habría hecho falta en 2021, cuando la auditoría pidió trazabilidad. Compárala con la de hoy y anota qué información ya no se puede reconstruir. Es un ejercicio deprimente y es el mejor argumento a favor de escribir estas cosas a tiempo.
- 🔥 Calcula qué habría costado hacerlo bien en 2019: replica set desde el principio, `$jsonSchema` desde el primer día, rangos append-only, auditoría en el servidor. En horas. Compara ese número con lo que ha costado este track. La diferencia, con su fecha, es lo que vale la pena enseñarle a quien esté arrancando un sistema hoy.

---

## 📚 8. Referencias

**Documentación oficial**

- MongoDB 4.0 — validación de esquema, `validationLevel` y `validationAction`: https://www.mongodb.com/docs/v4.0/core/schema-validation/
- `collMod`, que es como se aplica sobre una colección existente: https://www.mongodb.com/docs/v4.0/reference/command/collMod/
- Control de acceso basado en roles y `createRole`, para el §5.4: https://www.mongodb.com/docs/v4.0/core/authorization/
- PostgreSQL 16 — documentación de la versión del read-model: https://www.postgresql.org/docs/16/index.html
- Testcontainers — `MongoDBContainer` y su inicialización: https://java.testcontainers.org/modules/databases/mongodb/ ⚠️ **Compruébalo en ejecución** antes de apoyarte en cualquier afirmación sobre cómo arranca.

**Libros y artículos de referencia**

- Martin Fowler, *StranglerFigApplication*: https://martinfowler.com/bliki/StranglerFigApplication.html — y la advertencia que casi nadie cita: la higuera funciona cuando hay un destino claro. Aquí no lo hay, y por eso solo se hace read-model.
- Chris Richardson, patrón *Transactional Outbox*: https://microservices.io/patterns/data/transactional-outbox.html — con la nota de que aquí es un outbox **sin** la parte transaccional, y por qué eso es aceptable para un derivado.
- Michael Feathers, *Working Effectively with Legacy Code* (2004) — el capítulo 2 y su distinción entre cambiar para añadir y cambiar para entender. Todo este track fue lo segundo.
- Martin Kleppmann, *Designing Data-Intensive Applications* (2017), capítulo 12 — el cierre sobre integridad de datos y auditabilidad. Es la mejor exposición que hay de por qué un sistema que puede demostrar lo que hizo vale más que uno que lo hace bien.
- `bea-11` — el mapa de deuda del track BE, hermano de `a12` del track base. Se cierra con esta fase.

**Video y apoyo**

- Charlas sobre *strangler fig* y modernización de sistemas heredados (2018-2023): https://www.youtube.com/results?search_query=strangler+fig+legacy+modernization — ⚠️ casi todas terminan con la migración completada. Ninguna cuenta el caso mayoritario, que es el de LabCore: un sistema que se contiene y se apaga.

**Orden de lectura sugerido:** `bea-06` **antes** de tocar `$jsonSchema`, porque el procedimiento importa más que la sintaxis → Richardson sobre el outbox mientras lo implementas → Kleppmann cap. 12 antes de escribir `IRRECOVERABLE.md`, que es cuando su argumento se vuelve práctico → Feathers cap. 2 al terminar, para poner nombre a lo que hiciste durante ochenta horas.

> ⚠️ URLs y contenidos cambian; verifícalos. Y una última advertencia de este track: la literatura sobre modernización está escrita casi entera por gente que modernizó con éxito y lo contó. El sesgo de supervivencia es enorme, y el caso de LabCore —contener, documentar y apagar— es mucho más común de lo que la bibliografía sugiere y está mucho peor documentado.

---

## 🚀 9. Cierre del track

Ochenta horas, nueve fases, y el frontend no cambió ni un archivo.

Lo que tienes ahora no es un backend mejor: es un backend **conocido**. Sabes qué promete, qué hay guardado de verdad, qué garantías da tu despliegue y cuáles no, qué historia se perdió y desde cuándo, y qué se ha estado moviendo sin que nadie lo decidiera. Y tienes escrito todo eso de forma que la persona que herede el sistema dentro de dos años —o el auditor que llegue el mes que viene— no tenga que empezar por donde tú empezaste.

El criterio de éxito del track no era *"el alumno aprendió MongoDB"*. Era esto, y ahora se puede verificar:

- Tomaste un contrato de API existente y lo reimplementaste sin romper a quien lo consume.
- Sabes **medir** la forma real de una colección en vez de suponerla desde el modelo del código.
- Sabes qué garantía te da y cuál no te da tu topología de despliegue, y puedes citar el mensaje de error que lo demuestra.
- Sabes distinguir un dato que se puede reconstruir de uno que se perdió, y sabes escribir la diferencia en un documento que un auditor va a leer.
- Y sabes defender, con la fecha de decomisión en la mano y con números, **cuándo migrar es la respuesta equivocada**.

Nada de eso depende de MongoDB, de Java ni de un laboratorio clínico. Cambia el motor, el lenguaje y el dominio, y el método aguanta entero: auditar el contrato antes de tocar nada, medir en vez de suponer, intentar la solución correcta y documentar su rechazo, costear las salidas, contener lo que se pueda, y **declarar en voz alta lo que no**.

Queda una cosa por decir, y es la que conviene llevarse por encima de las demás. Durante ocho fases mediste los errores de un equipo que se fue en 2021 y que no puede defenderse. Todas sus decisiones fueron razonables con la información que tenían: Mongo resolvía un dolor real, el standalone era lo normal en 2019, el audit log en el navegador era la única forma de conseguir trazabilidad con un backend ajeno, y el `$set` sobre el rango era lo que su modelo mental indicaba. **Lo que falló no fue el criterio: fue que nadie volvió a mirar.** Dentro de siete años, alguien va a medir lo que tú escribiste este mes con herramientas que todavía no existen, y va a encontrar cosas. La única diferencia que puedes elegir hacer hoy es dejarle escrito **por qué** decidiste lo que decidiste.

> **La señal de que quedó bien:** *"levanté el backend de 2019 con mis propias manos, medí lo que costó, contuve lo que se podía contener, y escribí por qué no vamos a arreglar el resto. Y el frontend nunca se enteró de nada."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en verde y `git status` limpio:
>
> ```bash
> git tag -a be-fase-08-la-contencion-y-lo-irrecuperable -m "be08 cerrada: ocho numeros inventariados y clasificados; jsonSchema en warn con el rechazo medido antes; outbox y read-model con ventana declarada; permisos que impiden mutar rangos; estrategia de pruebas decidida por paridad topologica; arbol de veredicto costeado; IRRECOVERABLE.md firmado; cierre honesto con el numero de las dos columnas"
> ```
>
> Y cuando ese tag esté puesto, el track BE está cerrado: `git tag -l 'be-fase-*'` tiene que devolver nueve líneas, y `git tag -l 'fase-*'` sigue devolviendo las catorce del track base, limpias. Esa separación es toda la razón de que el namespace exista. La convención completa está en [`00-convencion-de-git-y-tags.md`](./00-convencion-de-git-y-tags.md) §10.

---

## 📌 Pendientes sugeridos

- **[A] La estrategia de pruebas queda cerrada aquí** —el `mongo:4.0` del compose, por paridad topológica— y con ella se cierra el último ⚠️ de `propuesta-fases-backend.md` §5.5. Se revisa **solo** si LabCore se convierte a replica set.
- **[B] La conversión a replica set es la única recomendación fuerte del track** y queda fuera de él, con su procedimiento operativo (`be05` ej. 23) y su dueño identificado. Si se ejecuta, hay que revisar: la estrategia de pruebas, la nota de `be07` sobre la topología, y el árbol de veredicto.
- **[C] `IRRECOVERABLE.md` tiene fecha de revisión.** Un documento de este tipo sin fecha de revisión caduca en silencio, que es exactamente el fallo que el track lleva ocho fases documentando.
- **[D] Los 37 veredictos de `be06` y las 23 cadenas de `be05`** siguen sin tocarse, declarados. Cualquier acción futura sobre ellos pasa por el libro de correcciones y por Calidad.
- **[E] `bea-11` (mapa de deuda del track BE) se cierra con esta fase** y tiene que contener las deudas declaradas en las nueve. El ejercicio 20 lo verifica; si falta alguna, el mapa no sirve.
- **[F] El cuaderno `cuaderno-incidentes-be.md`** tiene ya sus doce IDs reservados (`be-01` a `be-12`) por las nueve fases. Es lo único del track que queda por escribir.

### Reservas para el cuaderno de incidentes

| ID | Título propuesto | Categoría | Dificultad |
|---|---|---|---|
| **be-12** | *"Desde el viernes no podemos guardar algunos pacientes"* | Procedimiento / validación retroactiva | 🔴 |

Es la pieza forense de la sección 6, y cierra el cuaderno igual que la fase cierra el track. Llega como un fallo intermitente sin patrón —falla con unos pacientes y con otros no— y lo que lo hace formativo es que **el número que lo explicaba estaba medido desde `be02`**: los 1.630 documentos de las formas C y D. Nadie lo consultó antes de endurecer.

El post-mortem tiene que llegar a la conclusión que el track lleva ochenta horas construyendo: **medir no sirve de nada si nadie abre la medición antes de actuar**, y la contramedida no es un `if` ni una prueba, es un procedimiento escrito con un paso obligatorio. Es el único incidente del cuaderno cuya causa raíz no está en el código ni en los datos, y por eso va el último.
