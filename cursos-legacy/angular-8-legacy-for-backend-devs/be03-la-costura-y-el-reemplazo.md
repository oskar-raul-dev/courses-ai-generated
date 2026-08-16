# 🗄️ Fase be03 — La costura: de `db.json` a Mongo, y el reemplazo

> Tutorial Angular 8 — Laboratorio clínico · 🔥 Track BE · Fase be03 de be08 · **10 horas**
> Depende de: be02 — ya sabes qué hay guardado de verdad
> Habilita: be04
> Apéndices de apoyo: [bea-03 (embeber o referenciar)](./bea-03-modelar-documentos-embeber-o-referenciar.md) · [bea-05 (índices y `explain`)](./bea-05-indices-y-explain-en-mongodb.md) · [bea-02 (imagen y compose)](./bea-02-receta-de-imagen-y-compose.md) · [Incidentes asociados](./cuaderno-incidentes-be.md): be-04, be-05

---

## 🎯 1. Propósito

Apagar el mock y que la aplicación no se entere.

Esta es la bisagra del track. Todo lo anterior fue preparación —auditar, levantar, medir— y todo lo que sigue se apoya en que esto haya salido bien. La señal de éxito se enuncia en una línea, se verifica, y no admite matices:

> *"Apagué `npm run mock`, levanté el contenedor en el puerto 3000, y la única forma de notar el cambio fue que la lista de pacientes tardó cuarenta milisegundos más."*

No hay nada elegante en esta fase. Hay una traducción de identificadores que es incómoda y obligatoria, una semilla que sale de tu propio `db.json`, un dialecto ajeno que hay que reproducir, y un `smoke.sh` que va a ponerse en rojo antes de ponerse en verde. Lo que sí hay es la posición exacta en la que trabaja un equipo de mantenimiento de verdad: **servir datos que ya sabes que están sucios, respetando un contrato que no diseñaste, sin poder tocar al cliente**.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `spring-boot-starter-data-mongodb` está en el `pom.xml` y el servidor arranca conectado a `mongo:4.0`, con `GET /health` reportando también el estado de la base.
- [ ] Las cinco entidades están mapeadas con `@Document` y sus repositorios responden con query methods, sin una sola consulta escrita a mano.
- [ ] La traducción de identificadores funciona en las dos direcciones: por dentro `ObjectId`, por fuera **el entero que el frontend espera**, y ningún `ObjectId` aparece jamás en una respuesta.
- [ ] `npm run seed` sigue siendo el semillero, y un comando siembra Mongo **desde tu propio `db.json`**, conservando los identificadores enteros que ya tenías.
- [ ] `POST /login` lo sirve Java, con el mismo formato de token, los mismos claims y el mismo TTL, y el interceptor de la Fase 3 del track base no nota nada.
- [ ] Con `npm run mock` **apagado**, `./smoke.sh` pasa **entero** contra el backend de Java, incluidas las afirmaciones de identidad, de forma y del `404` con cuerpo `{}`.
- [ ] Usas la aplicación Angular durante quince minutos —pacientes, órdenes, muestras, resultados, entrega, bitácora— sin tocar un solo archivo del frontend y sin encontrar una diferencia.
- [ ] Los índices sobre `documentId` y `legacyId` existen, y tienes el `before/after` del `explain` con los cuatro números de `be02` al lado de los nuevos.
- [ ] El backend expone paginación de servidor en el dialecto de json-server (`_page`, `_limit`, `_sort`, `_order`, `X-Total-Count`), **nadie la llama todavía**, y sabes explicar por qué eso está bien.

---

## 🚫 3. Qué NO entra todavía

- **Auditoría del lado del servidor.** `/auditLog` sigue aceptando lo que el navegador le mande, con su `id` de cadena incluido, exactamente como json-server → **be04**.
- **Transacciones.** Hay dos escrituras que deberían ser una y hoy no lo son. Se anotan y se dejan rotas → **be05**, que es donde se descubre que la topología no las permite.
- **Rangos versionados y modelo bitemporal** → **be06**.
- **Cambiar el frontend para que consuma la paginación nueva.** El frontend no se toca. La paginación existe y no la llama nadie: eso es régimen de crecimiento y es correcto.
- **Limpiar los datos sucios de `be02`.** Se sirven tal cual. Un backend de mantenimiento sirve lo que hay, y lo que hay tiene cinco formas.
- **Validación con `$jsonSchema`** → **be08**.

---

## 🧠 4. Concepto mínimo

### 4.1 La regla que gobierna la fase entera

> 🧭 **El contrato manda sobre la elegancia.** Cada vez que en esta fase tengas que elegir entre lo que un backend nuevo haría y lo que `CONTRACT.md` dice, gana `CONTRACT.md`. Sin excepciones y sin discusión, porque la discusión ya se tuvo: el frontend no se toca.

Esto va a doler tres veces, y conviene saber dónde antes de empezar: el `id` entero, la respuesta sin envoltorio, y el `404` con cuerpo `{}`. Las tres son cosas que ningún diseñador de API elegiría hoy, y las tres son innegociables.

### 4.2 La traducción de identificadores, que es el corazón de la fase

MongoDB pone en cada documento un `_id` de tipo `ObjectId`: doce bytes, que se ven como `5f4a1c8e9b2d3a4f5c6d7e8f`. Es una buena decisión del producto —se genera en el cliente, es único sin coordinación, lleva la marca de tiempo adentro— y es completamente incompatible con lo que tienes delante.

Porque el frontend de LabCore guarda enteros. Los guarda en el store de NgRx, los compara con `===`, los concatena en URLs (`'/samples/' + sampleId`), y los usa como claves de diccionario. `CONTRACT.md` lo tiene en el régimen estricto con el archivo que lo exige al lado. **No hay ninguna versión de esta fase en la que el frontend acepte un `ObjectId`.**

Así que hay dos identificadores y hay que decidir cómo conviven. Las opciones reales son tres:

| Opción | Cómo | Por qué **no** |
|---|---|---|
| `ObjectId` truncado a entero | tomar bytes del `ObjectId` y convertirlos | Colisiona. No es una opinión: es aritmética, y colisiona en silencio |
| Hash del `documentId` | derivar el entero del dato | Cambia si el dato cambia, y un identificador que cambia no es un identificador |
| **Dos campos: `_id` interno + `legacyId` entero** | el `ObjectId` para Mongo, un entero propio para el mundo | Es la que se elige |

La tercera es la que habría hecho el equipo de 2019 y es la correcta aquí, con una condición: **el `ObjectId` no sale nunca**. Ni en una respuesta, ni en un log que alguien pegue en un ticket, ni en un mensaje de error. Desde fuera, LabCore tiene identificadores enteros y punto.

> 🧠 **Esto no es un detalle de implementación: es contenido.** Cada vez que un sistema se reemplaza por otro con un modelo de identidad distinto, aparece exactamente esta costura, y casi siempre se resuelve mal —filtrando el identificador nuevo "solo en un sitio", que es como empiezan todas—. Trátala como lo que es: una frontera con una regla, y una prueba que la vigila.

### 4.3 De dónde sale el entero: `max + 1`, y por qué aquí sí explota

json-server asigna el `id` como *el máximo existente más uno*. Es lo que el contrato promete y lo que el frontend ha visto siempre. La traducción directa a Java es de cuatro líneas:

```java
// La traducción ingenua. Léela y busca el problema antes de seguir.
Integer next = repository.findTopByOrderByLegacyIdDesc().getLegacyId() + 1;
patient.setLegacyId(next);
repository.save(patient);
```

Ese código es correcto en json-server y está roto en Spring. **Y la diferencia no está en el código: está en el modelo de ejecución.** json-server corre en el bucle de eventos de Node, con un solo hilo: entre el `max` y el `save` no puede colarse nadie. Spring MVC atiende con doscientos hilos, y entre esas dos líneas caben todos los que quieran. Dos peticiones concurrentes leen el mismo máximo, calculan el mismo siguiente, y guardan dos pacientes con el mismo `id`.

> 🪞 **Tu instinto dice "esto lo resuelve una secuencia de la base"… y aquí no hay ninguna.** No existe `SERIAL`, no existe `AUTO_INCREMENT`, no existe una secuencia. Lo que sí existe es una operación atómica sobre un documento —`findAndModify` con `$inc`— y con eso se construye a mano lo que en un motor relacional te venía puesto. **Una colección de contadores**, que es exactamente lo que habría hecho el equipo de 2019 y lo que vas a escribir en el §5.4.
>
> Y esa solución trae su propio límite, que conviene ver ahora aunque se cobre en `be05`: la atomicidad de `findAndModify` cubre **un** documento. El contador queda a salvo. Lo que no queda a salvo es cualquier operación que necesite escribir **dos** documentos y que los dos cuenten o ninguno.

### 4.4 La paginación que el sistema nunca tuvo — 💸 3

En el track base, paginar, filtrar y ordenar se hace **en el navegador**, con la colección entera en memoria. La Fase 5 lo declara como deuda y explica el porqué: el backend nunca expuso paginación, así que no había alternativa.

Ya no es cierto. A partir de esta fase la hay, y la forma correcta de introducirla es la única que respeta la regla del track: **implementarla en el servidor y no llamarla desde el cliente**. Régimen de crecimiento puro. El servidor entiende `_page`, `_limit`, `_sort` y `_order`; devuelve la colección entera cuando no le mandas nada, que es lo que el frontend hace hoy; y añade `X-Total-Count` en la cabecera, que nadie lee.

> 🧭 **La deuda no se paga: se hace pagable.** Esa distinción es del repositorio entero y aquí se ve muy bien. LabCore tiene dos años de vida y tocar los siete slices de NgRx para consumir paginación es un proyecto que nadie va a aprobar. Lo que sí cuesta cuatro horas es dejar el otro lado listo, medido y documentado, para que el día que alguien tenga presupuesto la conversación sea *"hay que tocar el frontend"* y no *"hay que rehacer los dos lados"*.

Hay un detalle mecánico que se olvida siempre y produce media hora de confusión: **una cabecera personalizada de respuesta no es visible para JavaScript a menos que el servidor la exponga**. `X-Total-Count` viaja, aparece en la pestaña Network, y `HttpResponse.headers.get('X-Total-Count')` devuelve `null` si falta `Access-Control-Expose-Headers`. Está en el §5.7.

### 4.5 Qué hace el backend con los datos sucios

En `be02` mediste cinco formas del documento de paciente. Esta fase sirve datos limpios —la semilla sale de tu `db.json`— y aun así la pregunta hay que contestarla, porque el día que este backend apunte a la base real se la va a encontrar:

**No se limpia nada, y se sirve lo que hay.** Un documento de la forma **C** se convierte en un `Patient` con `fullName` en `null`, viaja al navegador, y la fila sale sin nombre. Es lo que hace el sistema hoy y es lo que tiene que seguir haciendo, porque cualquier otra cosa —rellenar el hueco con `name`, rechazar el documento, lanzar una excepción— es **cambiar el comportamiento observable** sin haberlo decidido.

Lo que sí se hace es lo que ninguna capa hacía: **contarlo**. Un contador de documentos leídos que no encajan en la forma esperada, en el log y nada más. No cambia una respuesta, no rompe nada, y convierte una deriva invisible en una línea que alguien puede mirar. Es la contención más barata del track y está en el §5.8.

> 🧠 **La regla de oro de un reemplazo:** primero se replica el comportamiento, incluidos los defectos; después se mide; y solo entonces se discute qué se arregla. Invertir ese orden es lo que convierte una migración en un incidente.

---

## 💻 5. Código mínimo con comentarios

Nueve piezas. Se sugiere hacerlas en este orden: sin la traducción de identificadores resuelta, nada de lo demás se puede probar.

### 5.1 La conexión, y el driver que llegó solo

```xml
<!-- Lo único que se añade al pom.xml de be01. Fíjate en lo que NO tiene:
     versión. La trae el BOM del parent 2.1.18.RELEASE, y con ella llega
     mongo-java-driver 3.8.2 — el mismo que va a seguir conectando contra
     Mongo 7.0 en be07 sin que nadie toque este archivo. -->
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-data-mongodb</artifactId>
</dependency>
```

```properties
# La URI sale del entorno, con un valor por defecto para correr fuera del
# contenedor. En compose, MONGO_URI apunta al servicio "db".
spring.data.mongodb.uri=${MONGO_URI:mongodb://localhost:27017}/labcore

# Que Spring Data NO cree índices por las anotaciones @Indexed al arrancar.
# En 2.1 el valor por defecto es "true" y es una trampa conocida: crear un
# índice al arrancar sobre una colección grande bloquea el arranque el tiempo
# que tarde. Los índices se crean a mano y se miden (§5.6).
spring.data.mongodb.auto-index-creation=false
```

> ⚠️ Comprueba el arranque **antes** de escribir nada más. Un `docker compose up -d db` olvidado produce, en Boot 2.1, un arranque aparentemente correcto que falla en la primera consulta: el driver conecta de forma perezosa. El servidor te dirá que está `UP` y no lo está.

### 5.2 El modelo: dos identificadores y una frontera

```java
package com.andina.labcore.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

// La colección se llama "patients", igual que en el db.json y que en la ruta.
// No es estética: el contrato lo exige y CONTRACT.md lo tiene en el régimen
// estricto.
@Document(collection = "patients")
public class Patient {

    // El identificador de Mongo. Existe, es un ObjectId, y NO SALE NUNCA de
    // esta clase hacia el mundo: @JsonIgnore es la frontera del §4.2, escrita
    // en una línea. Si algún día un ObjectId aparece en una respuesta, será
    // porque alguien quitó esta anotación o porque creó otra clase sin ella.
    @Id
    @JsonIgnore
    private String id;

    // El identificador del CONTRATO: el entero que el frontend guarda en el
    // store, compara con === y concatena en URLs. Hacia afuera se llama "id"
    // porque así se llama en el db.json; hacia adentro se llama legacyId
    // para que nadie los confunda al leer el código.
    @JsonProperty("id")
    private Integer legacyId;

    private String documentId;
    private String fullName;
    private String birthDate;
    private String email;
    private Boolean active;

    @JsonIgnore
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public Integer getLegacyId() { return legacyId; }
    public void setLegacyId(Integer legacyId) { this.legacyId = legacyId; }

    // … el resto de getters y setters, igual que en be01
}
```

**Detalles con intención**

- `@JsonIgnore` va **en el campo y en el getter**. Es cinturón y tirantes, y hay una razón: según cómo esté configurado Jackson, la anotación del campo puede no aplicarse a la propiedad derivada del getter. Es exactamente el tipo de detalle que produce una fuga de `ObjectId` un martes.
- `@JsonProperty("id")` sobre `legacyId` resuelve **las dos direcciones**: serializa como `id` y deserializa un `id` entrante hacia `legacyId`. Eso último importa en `/auditLog`, donde el cliente manda su propio identificador.
- El campo se llama `legacyId` y no `externalId` ni `publicId` a propósito. **El nombre lleva la fecha de caducidad puesta**: quien lo lea en 2028 sabrá que existe por compatibilidad y no por diseño.

> 💡 **La prueba de que la frontera aguanta no es leer el código: es una afirmación en `smoke.sh`.** Añade una que falle si el patrón `[0-9a-f]{24}` aparece en cualquier respuesta. Una anotación se puede quitar sin querer; una prueba en rojo, no.

### 5.3 El repositorio: query methods y nada más

```java
package com.andina.labcore.repository;

import com.andina.labcore.model.Patient;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;

// La interfaz no tiene implementación: Spring Data la genera a partir de los
// NOMBRES de los métodos. findByLegacyId se convierte en {legacyId: ?}, y
// findByDocumentId en {documentId: ?}. Es lo que en 2019 hacía que esto se
// sintiera como JPA, y es también lo que escondió el COLLSCAN de be02: el
// método no menciona ningún índice, así que nadie se pregunta si lo hay.
public interface PatientRepository extends MongoRepository<Patient, String> {

    Patient findByLegacyId(Integer legacyId);

    // El filtro del dialecto de json-server: /patients?documentId=CC-…
    // Devuelve lista aunque el resultado sea único, porque el contrato dice
    // que ese endpoint devuelve un ARREGLO. El validador asíncrono del
    // formulario decide "ya existe" mirando length > 0.
    List<Patient> findByDocumentId(String documentId);

    // Para el max+1 del §5.4, en su versión ingenua. Se escribe, se mide, y
    // se sustituye. Está aquí para que el ejercicio 18 pueda romperlo.
    Patient findTopByOrderByLegacyIdDesc();
}
```

> 🩻 **Esto sí funciona igual.** Un repositorio derivado del nombre del método es la misma idea que ya conoces de Spring Data JPA, con el mismo mecanismo y las mismas trampas. Lo que cambia es lo que hay debajo: aquí no hay ningún planificador que te avise de que la consulta que acabas de generar recorre la colección entera. **La comodidad es idéntica; la red de seguridad, no.**

### 5.4 El contador, que es una secuencia hecha a mano

```java
package com.andina.labcore.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.FindAndModifyOptions;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Service;

import java.util.Map;

// La secuencia que MongoDB no tiene. Una colección "counters" con un
// documento por entidad, y una operación atómica que incrementa y devuelve
// el valor nuevo en un solo viaje.
//
// Es el patrón canónico de 2019 y es lo que el equipo original habría
// escrito. Funciona porque findAndModify es atómico A NIVEL DE DOCUMENTO:
// dos hilos que lleguen a la vez se serializan en el servidor y cada uno se
// lleva un número distinto. No hay carrera posible AQUÍ.
//
// Lo que esa garantía NO cubre es cualquier cosa que necesite escribir dos
// documentos y que los dos cuenten o ninguno. Ese límite es de be05, y este
// archivo es donde conviene verlo por primera vez.
@Service
public class CounterService {

    private final MongoTemplate mongoTemplate;

    @Autowired
    public CounterService(MongoTemplate mongoTemplate) {
        this.mongoTemplate = mongoTemplate;
    }

    public Integer nextValue(String entityName) {
        Query query = new Query(Criteria.where("_id").is(entityName));
        Update update = new Update().inc("seq", 1);

        // returnNew(true): queremos el valor DESPUÉS del incremento.
        // upsert(true): la primera vez el documento no existe y se crea.
        // Las dos juntas son lo que hace que esto sea una secuencia y no un
        // "leer y escribir" con otro nombre.
        FindAndModifyOptions options = new FindAndModifyOptions()
                .returnNew(true)
                .upsert(true);

        Map counter = mongoTemplate.findAndModify(query, update, options, Map.class, "counters");
        return ((Number) counter.get("seq")).intValue();
    }
}
```

**El patrón a memorizar:** cuando el motor no te da la garantía que necesitas, la pregunta correcta no es *"¿cómo la simulo?"* sino *"¿qué garantía **sí** me da, y alcanza?"*. Aquí la garantía disponible es la atomicidad de una escritura sobre un documento, y alcanza justo para una secuencia. En `be05` la misma pregunta va a tener la respuesta contraria, y por eso hay que hacérsela siempre en este orden.

La siembra tiene que dejar los contadores en el valor correcto, o el primer paciente nuevo pisa uno existente:

```java
// Al sembrar, el contador arranca en el máximo que ya existe. Un contador
// que empieza en cero sobre una colección con datos produce claves
// duplicadas en la primera escritura, y el índice único del §5.6 lo va a
// rechazar con un error que apunta al sitio equivocado.
counters.set("patients", maxLegacyIdDe(patients));
```

### 5.5 La siembra, desde tu propio `db.json`

```java
package com.andina.labcore.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.boot.CommandLineRunner;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.stereotype.Component;

import java.io.File;
import java.util.List;
import java.util.Map;

// Siembra desde el db.json del PROPIO alumno, no desde un volcado. Que los
// datos que aparezcan tras el reemplazo sean exactamente los que viste en el
// track base es la mitad del efecto de esta fase: si salieran otros, el
// cambio se notaría y la prueba no probaría nada.
//
// Solo siembra si la colección está vacía. Un runner que borra y recarga en
// cada arranque es cómodo durante media hora y después te hace perder lo que
// creaste desde la interfaz — que es justo lo que hay que poder crear para
// comprobar que el reemplazo funciona.
@Component
public class SeedRunner implements CommandLineRunner {

    private final MongoTemplate mongoTemplate;

    public SeedRunner(MongoTemplate mongoTemplate) {
        this.mongoTemplate = mongoTemplate;
    }

    public void run(String... args) throws Exception {
        if (mongoTemplate.collectionExists("patients")
                && mongoTemplate.getCollection("patients").count() > 0) {
            return;
        }

        ObjectMapper mapper = new ObjectMapper();
        Map<String, List<Map<String, Object>>> db =
                mapper.readValue(new File("../db.json"), Map.class);

        // La clave de toda la siembra, en una línea: el "id" entero del
        // db.json se guarda como legacyId. El _id de Mongo lo pone el driver.
        // Así, el paciente 7 del track base sigue siendo el paciente 7.
        seed("patients", db.get("patients"));
        seed("orders", db.get("orders"));
        seed("samples", db.get("samples"));
        seed("results", db.get("results"));
        seed("referenceRanges", db.get("referenceRanges"));
        // auditLog NO se siembra: nace vacío y se llena usando el sistema,
        // igual que en la Fase 11 del track base. Sembrarlo con asientos
        // falsos arruinaría el ejercicio de ver nacer un asiento.
    }

    private void seed(String collection, List<Map<String, Object>> documents) {
        if (documents == null) {
            return;
        }
        for (Map<String, Object> document : documents) {
            document.put("legacyId", document.remove("id"));
            mongoTemplate.insert(document, collection);
        }
        // Y el contador arranca donde termina la semilla. Ver §5.4.
    }
}
```

> ⚠️ **`db.json` está fuera de `server/`, en la raíz del proyecto.** La ruta relativa `../db.json` funciona al correr con `mvn spring-boot:run` desde `server/` y **no** funciona dentro del contenedor, donde el directorio de trabajo es otro. Es el primer choque real con el empaquetado y lo resuelve [`bea-02`](./bea-02-receta-de-imagen-y-compose.md) con un volumen. Que la ruta esté escrita a pelo aquí es una 💸 declarada: lo correcto sería una propiedad de configuración, y **en este track no se paga** porque el semillero es andamiaje del curso, no código de LabCore.

### 5.6 Los índices, con el `before/after` de `be02`

```javascript
// El índice que be02 midió y no creó. Ahora sí, y con las dos mediciones
// pegadas en MEASUREMENTS.md una al lado de la otra.
db.patients.createIndex({ documentId: 1 });

// Y el del identificador del contrato. ÚNICO, a propósito: es la red que
// atrapa el bug del §5.4 si el contador falla. Un índice único no es solo
// una optimización, es una restricción de integridad — la única que este
// sistema va a tener.
db.patients.createIndex({ legacyId: 1 }, { unique: true });
```

El antes y el después de la consulta que dispara el validador asíncrono con cada tecla:

| Medición | Antes (be02) | Después |
|---|---|---|
| `stage` | `COLLSCAN` | `IXSCAN` |
| `totalDocsExamined` | 4.820 | 1 |
| `executionTimeMillis` | 12 | 0 |

Doce milisegundos contra cero. **Y esa es exactamente la razón de que nadie lo arreglara en seis años**: doce milisegundos no se sienten. El argumento para crear el índice no es el número de hoy, es la derivada: el mismo `COLLSCAN` con cien veces más datos es más de un segundo, por tecla, en la pantalla que más se usa del sistema. Anota las dos cosas —el número y el razonamiento— porque en `be08` vas a necesitar defender por qué unas deudas se pagan y otras no, y esta es de las baratas.

### 5.7 La paginación que nadie llama todavía

```java
// El controller sigue siendo el mismo de be01, con cuatro parámetros nuevos
// y todos opcionales. Sin ninguno, devuelve la colección entera — que es
// exactamente lo que el frontend pide hoy y lo que CONTRACT.md promete.
@GetMapping
public ResponseEntity<List<Patient>> findAll(
        @RequestParam(name = "documentId", required = false) String documentId,
        @RequestParam(name = "_page", required = false) Integer page,
        @RequestParam(name = "_limit", required = false) Integer limit,
        @RequestParam(name = "_sort", required = false) String sort,
        @RequestParam(name = "_order", required = false) String order) {

    PageResult<Patient> result = patientService.find(documentId, page, limit, sort, order);

    // El cuerpo sigue siendo el ARREGLO DESNUDO, con o sin paginación. El
    // total viaja en una cabecera, que es como lo hace json-server y por
    // tanto lo que el contrato admite. Un envoltorio {data, total} sería más
    // limpio y rompería la aplicación entera.
    return ResponseEntity.ok()
            .header("X-Total-Count", String.valueOf(result.getTotal()))
            .body(result.getItems());
}
```

Y la línea que hace que esa cabecera sirva de algo:

```java
// En CorsFilter, junto a las otras tres. Sin esto, X-Total-Count viaja, se
// ve en la pestaña Network, y response.headers.get('X-Total-Count') devuelve
// null desde JavaScript. El navegador la recibe y no la entrega. Es media
// hora de desconcierto garantizada, y le pasa a todo el mundo una vez.
response.setHeader("Access-Control-Expose-Headers", "X-Total-Count, X-Request-Id");
```

> 🧭 **Y aquí no se toca el frontend.** Lo que se hace es escribir en `CONTRACT.md`, en la sección de régimen de crecimiento, exactamente cómo se consumiría: qué parámetros, qué cabecera, y qué archivos del frontend habría que tocar el día que alguien lo apruebe. Eso es una deuda **hecha pagable**, y es el entregable de escritura de esta fase.

### 5.8 El contador de deriva: la contención más barata del track

```java
// Nada de esto cambia una respuesta. Cuenta, y ya.
//
// Un documento leído al que le falta un campo obligatorio del modelo se
// sirve IGUAL —el contrato manda— y se suma a un contador que sale en el
// log cada N lecturas. Convierte la deriva invisible de be02 en una línea
// que alguien puede mirar un lunes.
if (patient.getFullName() == null) {
    driftCounter.increment("patients.fullName.missing");
}
```

```
[labcore] deriva acumulada en esta sesión: patients.fullName.missing=718
```

**Detalles con intención**

- Va en el **service**, no en el repositorio ni en el controller. En el repositorio no tendría contexto de negocio; en el controller ya sería tarde para saber de qué colección vino.
- **No lanza, no rechaza y no arregla.** La tentación de poner ahí un valor por defecto —`fullName = documentId`, por ejemplo— es fuerte y hay que resistirla: eso es cambiar el comportamiento observable, y además hace desaparecer la evidencia.
- El número que ese contador escupe tiene que **coincidir** con el que mediste en `be02` con la agregación. Si no coincide, uno de los dos está mal, y averiguar cuál es un ejercicio mejor que la mayoría de los que están abajo.

### 5.9 El login absorbido

```java
// POST /login, con jjwt 0.9.1. Lo único que tiene que coincidir con el mock
// es la FORMA: HS256, los claims sub/role/fullName, el TTL de 120 segundos,
// y la respuesta {token, expiresIn}. La librería es otra y da igual.
//
// Los tres usuarios están escritos a mano, igual que en el mock: analista1,
// analista2 y supervisor1, con sus roles. No hay colección de usuarios en
// LabCore, y ese es un hallazgo de be00 que sigue vigente.
//
// 💸 Y el secreto de firma va literal en el código, igual que en el mock de
// la Fase 3. Lo correcto sería una variable de entorno, y no por purismo:
// un secreto en el repositorio está en el historial de git para siempre, y
// rotarlo exige un despliegue. En este track NO SE PAGA, por dos razones
// escritas: el secreto es de mentira y de dominio público —está impreso en
// el material del curso—, y el sistema no tiene ningún mecanismo de gestión
// de secretos al que llevarlo. be04 vuelve a usar este mismo valor para
// verificar la firma, así que si algún día se mueve, se mueve en los dos
// sitios a la vez.
String token = Jwts.builder()
        .setSubject(user.getUsername())
        .claim("role", user.getRole())
        .claim("fullName", user.getFullName())
        .setExpiration(new Date(System.currentTimeMillis() + TTL_SECONDS * 1000L))
        .signWith(SignatureAlgorithm.HS256, JWT_SECRET.getBytes("UTF-8"))
        .compact();
```

> ⚠️ **Y ningún endpoint lo verifica.** Sigue siendo así, sigue estando en `CONTRACT.md`, y la afirmación de `smoke.sh` que lo comprueba sigue en verde. No es un olvido de esta fase: es la cláusula que `be04` va a medir y que nadie puede cambiar sin decidir, antes, qué le pasa al operador cuando su sesión muera a los dos minutos.

> **Prueba de fuego.** Apaga `npm run mock` —de verdad, cierra la terminal— y levanta `docker compose up -d`. Corre `./smoke.sh`: entero en verde. Ahora abre la aplicación Angular y haz el recorrido de la sesión de captura de `be00`, los once pasos, cronometrando. Crea un paciente y confirma en Mongo que su `legacyId` es el siguiente entero, no un `ObjectId`. Da de baja a otro y confirma que sigue existiendo con `active: false`. Valida un resultado y comprueba que el asiento aparece en `auditLog` con el `id` de cadena que generó el navegador. Por último, mide la lista de pacientes en Network y compárala con lo que tardaba el mock: la diferencia tiene que caber en una frase, y esa frase es el propósito de la fase.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Síntoma: la pantalla de pacientes sale en blanco y la respuesta parece correcta.**
Causa: se está serializando el `ObjectId` como `id`. El frontend recibe `"id": "5f4a1c8e9b2d3a4f5c6d7e8f"` donde esperaba `1`, y todo lo que compara identificadores deja de casar. Fix mínimo: `@JsonIgnore` sobre el `_id` y `@JsonProperty("id")` sobre `legacyId`. Es la pieza forense de abajo.

**Síntoma: `E11000 duplicate key error` al crear un paciente.**
Causa: el contador arrancó en cero sobre una colección ya sembrada. Fix mínimo: sembrar el contador con el máximo existente, §5.4. Y agradece el error: sin el índice único, en vez de un error habrías tenido dos pacientes con el `id` 7 y un bug de datos que nadie encuentra en meses.

**Síntoma: `X-Total-Count` se ve en Network y JavaScript lo lee como `null`.**
Causa: falta `Access-Control-Expose-Headers`. Fix mínimo: §5.7. No es un bug del cliente ni del servidor: es CORS haciendo exactamente lo que se le pidió.

**Síntoma: el `PATCH` de baja lógica guarda `active: false` y borra el resto de los campos.**
Causa: se implementó el `PATCH` como un reemplazo del documento en vez de una actualización parcial. Fix mínimo: `$set` de los campos recibidos, nunca `save()` de un objeto construido solo con el delta. Y comprueba lo que devuelve: el contrato exige el **documento completo** después del cambio.

**Síntoma: el arranque dice `UP` y la primera consulta falla.**
Causa: el driver conecta de forma perezosa y `/health` no comprueba la base. Fix mínimo: que `/health` haga un `ping` de verdad. Es el ejercicio 6 y es la diferencia entre una sonda de salud y una decorativa.

### Pieza forense de esta fase

**El primer `smoke.sh` en rojo.**

Va a pasar, y conviene provocarlo a propósito en vez de sufrirlo: quita el `@JsonIgnore` del `id` y el `@JsonProperty("id")` del `legacyId`, arranca, y corre el guion.

```
== Contrato de LabCore contra http://localhost:3000 ==
  ok   GET /patients responde (200)
  ok   GET /patients es un arreglo
  FALLA el id de un paciente es entero — el cuerpo no casó con /"id"\s*:\s*[0-9]+/
         recibido: [{"id":"5f4a1c8e9b2d3a4f5c6d7e8f","documentId":"CC-10324567
```

Y ahora, el recorrido completo del síntoma, que es lo que hace que esto sea una pieza forense y no un mensaje de error:

1. **En el servidor.** El log dice `GET /patients -> 200 (8 ms)`. Todo bien. El servidor hizo su trabajo, respondió rápido y sin excepciones. **No hay nada que mirar aquí**, y ese es el primer hallazgo.
2. **En Network.** `200 OK`, JSON válido, veinticinco objetos con todos sus campos. Un desarrollador que mire esto y no sepa qué busca concluye que la respuesta es correcta. Lo es, para cualquier definición razonable de "correcta" que no incluya el contrato.
3. **En Redux DevTools.** `[Patients] Load Patients Success` con veinticinco pacientes en el payload. El store se llenó. **También correcto.**
4. **En la pantalla.** La tabla se pinta. Y al hacer clic en una fila, no pasa nada: la ruta `/patients/5f4a1c8e…` no casa con ningún parámetro numérico, o casa y el selector no encuentra a nadie porque compara `5f4a1c8e…` con enteros. El síntoma aparece **cuatro capas después de la causa** y no se parece en nada a ella.

Las cuatro preguntas del método forense, contestadas:

- **¿Qué se ve?** Una pantalla que carga y no navega.
- **¿Qué capa lo produce?** La serialización, en el servidor. Cuatro capas más arriba del síntoma.
- **🧬 ¿Lo escribió el sistema o llegó roto en el dato?** Ninguna de las dos: el dato está perfecto en la base y el sistema funciona. Lo que está roto es **el contrato**, que no es ni una cosa ni la otra, y por eso ninguna herramienta de las dos puntas lo detecta.
- **¿Con qué se demuestra?** Con `smoke.sh` en rojo, en diez segundos, señalando la afirmación exacta. Sin él, esto son dos horas de bisección entre cuatro capas.

> 🧠 **Esa última línea es el argumento entero de `be00`.** El contrato no está para documentar: está para que un fallo de contrato se manifieste como un fallo de contrato y no como una pantalla que no navega.

🧨 **Rompe a propósito, segunda parte.** Con todo en verde, cambia una sola cosa: que `GET /patients` devuelva `{ "data": [...], "total": 25 }` en vez del arreglo desnudo. Es objetivamente un diseño mejor. Corre `smoke.sh`, mira qué afirmación cae, y después abre la aplicación y anota en qué capa aparece el primer síntoma visible. Escribe en dos líneas por qué "mejor" y "compatible" son dimensiones distintas.

---

## 🧪 7. Ejercicios (31)

**🟢 Fácil (1–8)**

1. Añade el starter de Mongo, arranca contra `mongo:4.0` y confirma con `mvn dependency:tree | grep mongo` que el driver es `3.8.2` y que nadie escribió esa versión en el `pom.xml`.
2. Mapea `Patient` con los dos identificadores y comprueba con `curl` que ningún `ObjectId` aparece en la respuesta.
3. Añade a `smoke.sh` la afirmación que falla si el patrón de 24 caracteres hexadecimales aparece en cualquier respuesta. Confirma que se pone en rojo al quitar el `@JsonIgnore`.
4. Siembra desde tu `db.json` y confirma en `mongo` que el paciente con `legacyId: 1` es el mismo que veías en el track base, campo por campo.
5. Crea los dos índices del §5.6 y anota el `explain` antes y después en `MEASUREMENTS.md`.
6. Haz que `GET /health` compruebe la base de verdad con un `ping`, y demuéstralo apagando el contenedor de Mongo con el servidor arriba.
7. Implementa `POST /login` y compara el token que emite con uno del mock, claim por claim, en jwt.io.
8. Corre `smoke.sh` contra el mock y contra Java, y guarda las dos salidas. Esa comparación es el entregable de la fase.

**🟡 Intermedio (9–17)**

9. Mapea las cuatro entidades restantes con sus repositorios y sus filtros por igualdad. Confirma con `curl` los cuatro parámetros del contrato.
10. Implementa el `PATCH` como actualización parcial y comprueba que devuelve el documento **completo**. Después impleméntalo mal —como reemplazo— y anota exactamente qué pierde la muestra en la pantalla de custodia.
11. Implementa `/auditLog` conservando el `id` de cadena que manda el cliente. Valida un resultado desde la aplicación y confirma que el asiento se guardó con el identificador que generó el navegador.
12. Implementa la paginación del §5.7 con su `X-Total-Count`, y compruébala solo con `curl`. **No toques el frontend.**
13. **Diagnóstico.** Llama a `/patients?_page=2&_limit=10` desde la consola del navegador y lee `X-Total-Count` con JavaScript. Falla. Arréglalo y explica en una frase por qué la cabecera se veía en Network.
14. Implementa el contador de deriva del §5.8 y comprueba que su número coincide con el que midió `be02` sobre el mismo conjunto de datos.
15. **Diagnóstico.** Siembra con el contador en cero sobre una colección con datos y provoca el `E11000`. Lee el mensaje entero y explica por qué señala al índice y no a la causa.
16. Mide con `curl -w` la lista de pacientes contra el mock y contra Java, diez veces cada uno. Anota la mediana de los dos y escribe la frase del §1 con tu número real.
17. **Diagnóstico.** Un `$lookup` o un filtro devuelve vacío donde debería devolver datos. Comprueba el tipo de los campos que estás cruzando —recuerda `be02` §6— y explica por qué el silencio es peor que un error.

**🟠 Difícil (18–25)**

18. **Diagnóstico.** Implementa el `max + 1` ingenuo del §4.3 y provoca la carrera: veinte `POST /patients` concurrentes con `xargs -P 20`. Cuenta cuántos identificadores duplicados salieron. Repítelo con el índice único puesto y anota qué cambia —no el número de duplicados, sino **quién se entera**—.
19. Sustituye el `max + 1` por el `CounterService` y repite el ejercicio 18. Confirma cero duplicados sobre mil peticiones concurrentes, y explica en dos líneas qué garantía exacta te da `findAndModify` y qué garantía **no** te da.
20. **Diagnóstico.** Carga en una base aparte el volcado sucio de `be02`, apunta el backend ahí, y usa la aplicación. Documenta las tres pantallas que se ven raras, en qué se nota cada una, y confirma que **ninguna** produce una excepción en el servidor.
21. Escribe la sección de `CONTRACT.md` que explica cómo se consumiría la paginación desde el frontend: parámetros, cabecera, y los archivos exactos que habría que tocar. Estima las horas. Ese documento es la deuda 💸 3 hecha pagable.
22. **Diagnóstico.** Provoca la fuga de `ObjectId` en un solo endpoint —el de resultados, por ejemplo, con una clase nueva a la que se le olvidó la anotación— y comprueba que `smoke.sh` la atrapa. Después piensa en un caso que **no** atraparía y añade la afirmación que falta.
23. Mide el arranque completo del sistema —`docker compose up` desde cero hasta el primer `200`— y compáralo con `npm run mock`. Anota los dos números y decide, con la fecha de decomisión delante, si esa diferencia es un problema.
24. **Diagnóstico + diseño.** El `PATCH` de transición de muestra y la escritura del asiento de auditoría son hoy dos peticiones independientes, y el frontend hace la segunda solo si la primera responde bien. Escribe la secuencia exacta, señala en qué punto una caída deja el sistema inconsistente, y estima cuántas veces al año pasaría. **No lo arregles**: es `be05`, y la conclusión de esa fase es que no se puede arreglar como crees.
25. **Diagnóstico.** Alguien "mejora" el `404` para que devuelva `{"message":"Paciente no encontrado"}`. Es mejor. Corre `smoke.sh`, anota qué cae, y busca en el frontend qué código depende de ese cuerpo vacío. Después decide qué haces y escribe la razón.

**🔴 Muy difícil (26–31)**

26. **Adversarial.** Escribe la lista completa de todo lo que este backend hace **distinto** del mock y que `smoke.sh` no detecta: cabeceras, orden de los campos en el JSON, comportamiento ante un cuerpo malformado, ante un método no permitido, ante un parámetro desconocido. Prueba cada uno. Después decide cuáles entran en el contrato y añade las afirmaciones que hagan falta.
27. **Diagnóstico.** Con el sistema entero en Java, reproduce el incidente 17 del cuaderno base —el asiento de auditoría con actor equivocado— y comprueba que **sigue pasando exactamente igual**. Explica por qué reemplazar el backend no arregló nada, y qué haría falta. Ese párrafo es la entrada de `be04`.
28. **Diseño.** El `SeedRunner` lee `db.json` de una ruta relativa que no funciona dentro del contenedor. Resuélvelo de las tres formas posibles —volumen, recurso empaquetado, o variable de entorno con la ruta— e implementa una. Justifica la elección pensando en quién va a correr esto dentro de dos años.
29. **Adversarial.** Argumenta bien la posición contraria a toda la fase: *"esto es una capa de compatibilidad que va a sobrevivir al sistema; sería más limpio cambiar el frontend ahora que hay presupuesto para tocar el backend"*. Dale sus mejores razones. Después refútala con el número del ejercicio 21 y con el que sacaste en el ejercicio 26 de `be00`.
30. **Diagnóstico y escritura.** Escribe el post-mortem de ocho puntos del incidente **be-05** —la pantalla que carga y no navega— con el formato del cuaderno, sin culpabilización, y con el test de regresión que lo habría atrapado en diez segundos.
31. **La medición que cierra la fase.** Documenta el reemplazo completo en una página: qué se apagó, qué se levantó, qué pasó con los datos, qué se midió antes y después, y qué **no** cambió a propósito. Dirigida a alguien que tenga que aprobar el despliegue. Es el segundo capítulo del documento de `be08`, y es el único de los nueve que puede empezar con una buena noticia.

**🔥 Opcionales**

- 🔥 Implementa el filtro por igualdad de forma genérica —cualquier campo, como hace json-server— en vez de un parámetro declarado por recurso. Después decide si lo dejas, sabiendo que expone la forma interna de los documentos a quien pruebe parámetros al azar.
- 🔥 Añade `_embed` y `_expand` de json-server con `$lookup`, y mide cuánto tarda `/orders?_expand=patient` sobre el volcado grande de `bea-12`. Nadie lo llama; el ejercicio es la medición.
- 🔥 Escribe el mismo mapeo con `MongoTemplate` a pelo, sin repositorios derivados, y compara las dos versiones en líneas y en legibilidad. Anota cuál te habría dejado ver el `COLLSCAN` de `be02` antes.

---

## 📚 8. Referencias

**Documentación oficial**

- Spring Data MongoDB 2.1 — referencia de la versión que trae Boot 2.1.18: https://docs.spring.io/spring-data/mongodb/docs/2.1.x/reference/html/ ⚠️ La documentación actual describe la 4.x, con una API de repositorios bastante distinta.
- Query methods derivados del nombre, con la tabla de palabras clave soportadas: https://docs.spring.io/spring-data/mongodb/docs/2.1.x/reference/html/#mongodb.repositories.queries
- MongoDB 4.0 — `findAndModify`, que es lo que sostiene el `CounterService`: https://www.mongodb.com/docs/v4.0/reference/command/findAndModify/
- El patrón oficial de secuencia con una colección de contadores: https://www.mongodb.com/docs/v4.0/tutorial/create-an-auto-incrementing-field/
- `ObjectId` — qué son esos doce bytes y por qué llevan un timestamp: https://www.mongodb.com/docs/v4.0/reference/method/ObjectId/
- Índices únicos y el error `E11000`: https://www.mongodb.com/docs/v4.0/core/index-unique/
- MDN — `Access-Control-Expose-Headers`, la línea del §5.7: https://developer.mozilla.org/es/docs/Web/HTTP/Headers/Access-Control-Expose-Headers
- json-server 0.16.3 — la sección de paginación y ordenamiento, que es el dialecto que reproduces: https://github.com/typicode/json-server/tree/v0.16.3#routes

**Libros y artículos de referencia**

- Martin Fowler, *StranglerFigApplication*: https://martinfowler.com/bliki/StranglerFigApplication.html — esta fase es el primer corte real de la higuera, y `be08` es donde se decide que no va a haber más.
- Sam Newman, *Monolith to Microservices* (2019), capítulo 3 — el patrón de *branch by abstraction* y la sección sobre bases de datos compartidas. Lo relevante aquí es su insistencia en que el reemplazo se verifica con tráfico, no con revisión de código.
- Pramod Sadalage y Martin Fowler, *NoSQL Distilled* (2012), capítulo 8 — identificadores y claves en bases de documentos. Doce páginas que explican por qué la costura del §4.2 aparece siempre.

**Video y apoyo**

- Charlas de la época sobre Spring Data MongoDB y el mapeo de documentos (2018-2020): https://www.youtube.com/results?search_query=spring+data+mongodb+2019 — ⚠️ verifica la fecha: lo posterior a 2022 usa `record`, Kotlin y una API de agregación distinta.

**Orden de lectura sugerido:** la página de la secuencia autoincremental **antes** de escribir el `CounterService`, porque es literalmente el patrón que vas a implementar → el capítulo de query methods mientras escribes los repositorios, como referencia abierta → `Access-Control-Expose-Headers` justo cuando el ejercicio 13 falle, no antes → Fowler sobre la higuera al final, cuando el reemplazo ya funcione y quieras saber cómo se llama lo que acabas de hacer.

> ⚠️ URLs y contenidos cambian. Con Spring Data el riesgo es alto: casi todo lo que encuentres describe la 3.x o la 4.x, donde `MongoRepository` cambió de firma y donde `auto-index-creation` tiene otro valor por defecto.

---

## 🚀 9. Cierre y conexión con la siguiente fase

El mock está apagado. Lo que responde en el 3000 es Java, contra Mongo, con los datos que tú mismo sembraste, y la aplicación Angular no cambió ni un archivo. Esa es la frase que resume el track y ya la puedes decir.

Lo que hiciste no fue "migrar a MongoDB": fue **reproducir un contrato ajeno sobre una tecnología distinta sin permiso para tocar al consumidor**, que es el trabajo real de un equipo de mantenimiento y el único que este track pretende enseñar. La costura de identificadores, la paginación que nadie llama, el contador de deriva que no arregla nada: las tres son formas de la misma disciplina.

Ahora empiezan las facturas. **be04** toma la deuda 💸 1 —el audit log lo escribe el navegador, el actor sale de un token que vive en `localStorage`, el timestamp sale del reloj del operador— y hace lo único que se puede hacer con el frontend intacto: pone la identidad y el reloj donde debieron estar **sin quitar los otros**, deja convivir las dos bitácoras, y mide la divergencia. Cuántos asientos el navegador nunca envió, cuántos tienen otro actor, cuántos tienen una hora imposible. Ese número es el entregable, y es el primero del track que va a incomodar a alguien fuera del equipo.

> **La señal de que quedó bien:** *"apagué el mock, levanté el contenedor, y la única forma de notar el cambio fue que la lista de pacientes tardó cuarenta milisegundos más."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en verde y `git status` limpio:
>
> ```bash
> git tag -a be-fase-03-la-costura-y-el-reemplazo -m "be03 cerrada: cinco entidades mapeadas; traduccion ObjectId<->legacyId con frontera probada; contador atomico; siembra desde db.json propio; login absorbido; indices con before/after; paginacion en dialecto json-server sin consumidor; smoke.sh entero en verde contra Java"
> ```
>
> Los commits de la fase llevan su prefijo (`be03: …`) y los de ejercicio su número (`be03 ej18: …`). El track BE usa el namespace `be-fase-*`. Todo eso está en [`00-convencion-de-git-y-tags.md`](./00-convencion-de-git-y-tags.md) §10.

---

## 📌 Pendientes sugeridos

- **[A] La generación del `id` entero queda cerrada aquí:** colección `counters` con `findAndModify` y `$inc`, al estilo de 2019, más un índice único sobre `legacyId` como red. **No** `ObjectId` truncado ni hash. Ninguna fase posterior lo cambia sin declararlo.
- **[B] La frontera del `ObjectId` se vigila con una prueba, no con una convención.** La afirmación del patrón hexadecimal de 24 caracteres en `smoke.sh` es obligatoria a partir de esta fase.
- **[C] El volcado sucio de `be02` vive en una base aparte** y no se mezcla con la semilla del alumno. Es la decisión que mantiene reproducibles las mediciones de `be02` mientras la aplicación corre sobre datos limpios. Si `be08` necesita las dos a la vez, lo declara.
- **[D] La ruta `../db.json` del `SeedRunner`** no funciona dentro del contenedor. Lo resuelve `bea-02` con un volumen, y el ejercicio 28 lo pone sobre la mesa. Si `bea-02` se retrasa, la fase corre con Maven local.
- **[E] Las dos escrituras que deberían ser una** —la transición de muestra y su asiento— quedan explícitamente rotas, medidas en el ejercicio 24 y **no arregladas**. Es material de `be05` y adelantarlo destruye el hallazgo de esa fase.
- **[G] El secreto de firma del JWT** va literal en el código y se declara como 💸 en §5.9. `be04` usa el mismo valor; si se mueve a una variable de entorno, se mueve en los dos sitios en el mismo cambio.
- **[F] El contador de deriva del §5.8** produce un número que tiene que coincidir con el de `be02`. Si en algún momento divergen, hay un error de medición en uno de los dos y hay que resolverlo antes de `be08`, que consume los dos.

### Reservas para el cuaderno de incidentes

| ID | Título propuesto | Categoría | Dificultad |
|---|---|---|---|
| **be-04** | *"Dos pacientes con el mismo número"* | Concurrencia / identidad | 🔴 |
| **be-05** | *"La pantalla que carga y no navega"* | Contrato / serialización | 🟠 |

**be-04** llega como *"Recepción dice que el paciente 41 aparece dos veces, con nombres distintos"*. La causa es la carrera del `max + 1` bajo el modelo de hilos de Spring, y la única razón de que en json-server no pasara es que Node tiene un solo hilo. El post-mortem tiene que llegar a la regla general: **portar código correcto a otro modelo de ejecución puede volverlo incorrecto sin que una sola línea cambie**. El test de regresión son las veinte peticiones concurrentes del ejercicio 18.

**be-05** llega como *"desde el despliegue del martes la lista de pacientes se ve, pero al hacer clic no pasa nada"*. La causa es un `ObjectId` serializado como `id`. Es el incidente que `smoke.sh` resuelve en diez segundos y que sin él cuesta dos horas, y por eso vale como demostración del valor de `be00` más que cualquier argumento.
