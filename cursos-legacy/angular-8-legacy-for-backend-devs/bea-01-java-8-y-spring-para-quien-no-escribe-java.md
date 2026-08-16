# 📎 Apéndice bea-01 — Java 8 y Spring para quien no escribe Java

> Tutorial Angular 8 — Laboratorio clínico · 🔥 Track BE · Consulta rápida · **4 horas**
> Usado por: be01 principalmente, y de consulta en todas las demás · Versiones cubiertas: Java 8 (`eclipse-temurin:8-jdk`), Spring Boot 2.1.18.RELEASE, Spring Framework 5.1.19, Maven 3.8

**Esto no se lee de corrido.** Se entra buscando por qué el compilador se queja de algo que en tu lenguaje no existiría, o qué significa una anotación que acabas de ver, y se sale.

Resuelve una cosa: **que un senior de otro lenguaje pueda leer y escribir el backend de LabCore sin haber escrito Java nunca.** No enseña Java: enseña el Java que hay en este proyecto, que es Java 8 de 2019 sin una línea moderna.

**Qué queda fuera, a propósito:** Spring WebFlux y todo lo reactivo —LabCore es un monolito de un hilo por petición y nombrar WebFlux solo confunde—; Java 9 en adelante (módulos, `var`, `record`, text blocks), que aparece marcado 🔥 cuando vale la pena comparar y nunca como la forma en que el sistema está escrito; Gradle; JPA e Hibernate, que **no están en este stack** y son la primera cosa que la gente asume al oír "Spring"; y todo lo específico de MongoDB, que vive en [`bea-03`](./bea-03-modelar-documentos-embeber-o-referenciar.md), [`bea-04`](./bea-04-agregaciones-como-instrumento-de-medida.md) y [`bea-05`](./bea-05-indices-y-explain-en-mongodb.md).

> 🧭 **Lo conceptual ya está dicho en otro sitio.** La fase [`be01`](./be01-java-spring-y-la-forma-del-monolito.md) §4.1 explica en cuatro párrafos **por qué** el classpath, las excepciones checked, las anotaciones y el modelo de hilos son distintos de lo que conoces. Este apéndice no repite ese razonamiento: da el detalle operativo, la sintaxis y los comandos. Si vienes de cero, lee aquella sección primero y vuelve aquí.

---

## Índice

- [1. El mapa: qué es cada cosa, en tu idioma](#1-el-mapa-qué-es-cada-cosa-en-tu-idioma)
- [2. Paquetes, carpetas y el classpath](#2-paquetes-carpetas-y-el-classpath)
- [3. Maven: los seis comandos y el `pom.xml`](#3-maven-los-seis-comandos-y-el-pomxml)
- [4. La sintaxis que vas a leer en LabCore](#4-la-sintaxis-que-vas-a-leer-en-labcore)
- [5. Excepciones: checked y unchecked](#5-excepciones-checked-y-unchecked)
- [6. Anotaciones: configuración disfrazada de sintaxis](#6-anotaciones-configuración-disfrazada-de-sintaxis)
- [7. Spring: el contexto, los beans y los tres estereotipos](#7-spring-el-contexto-los-beans-y-los-tres-estereotipos)
- [8. Un hilo por petición, en la práctica](#8-un-hilo-por-petición-en-la-práctica)
- [9. `Optional`, y por qué en 2019 se usaba a medias](#9-optional-y-por-qué-en-2019-se-usaba-a-medias)
- [10. Leer un stack trace](#10-leer-un-stack-trace)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-10)

---

## 1. El mapa: qué es cada cosa, en tu idioma

Lo primero, para orientarse. La columna de la izquierda es lo que vas a ver en LabCore.

| En Java / Spring | Lo que ya conoces | Matiz que importa |
|---|---|---|
| `pom.xml` | `package.json`, `go.mod`, `composer.json` | Declara dependencias **y** el ciclo de construcción entero |
| `~/.m2/repository` | `node_modules`, pero **global por máquina** | Compartido por todos tus proyectos. De ahí el volumen `m2` de [`bea-02`](./bea-02-receta-de-imagen-y-compose.md) |
| `mvn spring-boot:run` | `npm start`, `go run` | Compila y arranca. No hay modo interpretado |
| `@RestController` | un router con sus handlers | Es una marca: alguien la escanea al arrancar |
| `@Service` | tu capa de lógica | No hace nada por sí misma; es un `@Component` con nombre |
| `@Repository` | tu capa de datos | Además traduce excepciones del driver a las de Spring |
| `@Autowired` | inyección de dependencias | En 2019 se ponía en el campo; hoy, en el constructor |
| El contexto de Spring | un contenedor de DI | Se construye **una vez al arrancar**, y ahí se decide casi todo |
| `application.properties` | `.env`, `config.json` | Con precedencia definida: variables de entorno pisan al archivo |
| `javax.servlet.Filter` | un middleware de Express | Mismo concepto. `chain.doFilter(...)` es `next()` |
| `HandlerInterceptor` | un middleware **de tu framework** | Corre más tarde: solo sobre lo que pasa por Spring MVC |
| Un `.jar` | un paquete publicado | Es un `.zip` con clases compiladas y un manifiesto |
| El classpath | la resolución de `require` | **Plano.** No hay rutas: hay un conjunto de clases y un orden |

---

## 2. Paquetes, carpetas y el classpath

Un paquete es un nombre con puntos —`com.andina.labcore.web`— y **tiene que coincidir con la ruta de carpetas**: `src/main/java/com/andina/labcore/web/`. No es una convención: si no coinciden, no compila.

```java
// La primera línea de todo archivo .java del proyecto.
package com.andina.labcore.web;

// Y las importaciones. Java no tiene "import todo de esta carpeta": cada
// clase que uses de fuera de tu paquete se nombra una por una. Tu editor lo
// hace solo, y por eso los archivos de LabCore empiezan con veinte líneas de
// import que nadie lee.
import com.andina.labcore.model.Patient;
import org.springframework.web.bind.annotation.GetMapping;
```

**El classpath** es la lista plana de sitios donde el runtime busca clases: tus clases compiladas más todos los `.jar` de tus dependencias. Maven la construye a partir del `pom.xml` y ahí se acaba la magia.

Lo que hay que saber de él son dos consecuencias prácticas:

- **Si dos `.jar` traen la misma clase, gana uno y no hay aviso.** No falla la compilación, no falla el arranque: falla en tiempo de ejecución, con un `NoSuchMethodError` que no se parece en nada a su causa. Es el equivalente al infierno de versiones de `node_modules`, con la diferencia de que aquí no hay carpetas anidadas que salven el día: **solo puede haber una versión de cada clase**.
- **Por eso existen los BOM**, como el `spring-boot-starter-parent` de LabCore: un conjunto de versiones ya comprobadas entre sí. Es también la razón de que el driver de Mongo sea invisible en el `pom.xml`, que es media fase `be07`.

```bash
# Ver el classpath real, con todas las dependencias transitivas:
docker compose run --rm api mvn -f server/pom.xml dependency:tree

# Y buscar de dónde sale una clase duplicada cuando algo huele a eso:
docker compose run --rm api mvn -f server/pom.xml dependency:tree -Dverbose | grep -i conflict
```

---

## 3. Maven: los seis comandos y el `pom.xml`

```bash
mvn -f server/pom.xml compile            # compilar
mvn -f server/pom.xml test               # compilar y correr pruebas
mvn -f server/pom.xml package            # generar el .jar
mvn -f server/pom.xml spring-boot:run    # arrancar la aplicación
mvn -f server/pom.xml dependency:tree    # ver el árbol de dependencias
mvn -f server/pom.xml -o …               # modo sin red, con lo que ya está en caché
```

Con eso llegas al final del track. En el contenedor, delante va `docker compose run --rm api`.

El `pom.xml` tiene cuatro partes y solo dos importan al principio:

```xml
<!-- 1. El parent: de aquí sale el BOM con cientos de versiones coherentes.
        Cambiar esta línea cambia el driver de Mongo, Jackson y Tomcat a la
        vez, que es lo que en be07 nadie se atrevió a hacer. -->
<parent>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-parent</artifactId>
  <version>2.1.18.RELEASE</version>
</parent>

<!-- 2. Las dependencias. SIN versión cuando el BOM ya la fija — que es casi
        siempre, y por eso una dependencia CON versión llama la atención: o
        no está en el BOM, o alguien la sobrescribió a propósito. -->
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-web</artifactId>
</dependency>
```

> 💡 **La regla de lectura de un `pom.xml` ajeno:** mira primero las dependencias **que sí llevan versión**. Son las decisiones que alguien tomó a mano, y por tanto las que tienen una historia detrás. Las demás las decidió el parent.

> ⚠️ **El árbol de dependencias es el problema; la sintaxis del XML no.** Nadie pierde una tarde con las etiquetas. Se pierde con una dependencia transitiva que arrastra una versión incompatible de otra cosa, y eso se diagnostica con `dependency:tree` y con paciencia.

---

## 4. La sintaxis que vas a leer en LabCore

Lo mínimo para no tropezar. Todo lo de abajo aparece literalmente en el código del track.

```java
// Una clase, con sus campos privados y sus getters. Sin Lombok: LabCore no
// lo usa, y el getter explícito es lo que le da a un breakpoint dónde
// ponerse. Es verboso a propósito.
public class Patient {

    private Integer id;              // Integer, no int: puede ser null
    private String fullName;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
}
```

**`int` contra `Integer`** es la primera trampa y no tiene equivalente en la mayoría de los lenguajes de los que vienes: `int` es un valor primitivo y **no puede ser `null`**; `Integer` es un objeto y sí. Un documento de Mongo al que le falta un campo numérico se mapea a `null`, así que **todos los campos numéricos de los modelos de LabCore son `Integer`**. Declarar `int` ahí produce una `NullPointerException` al leer un documento viejo, que es exactamente el escenario de `be02`.

```java
// Genéricos: la parte entre < > es el tipo de lo que hay dentro.
List<Patient> patients = new ArrayList<Patient>();
Map<String, Object> changes = new HashMap<String, Object>();

// 🔥 En Java 7+ se puede abreviar con el "diamante": new ArrayList<>().
// LabCore escribe el tipo completo porque así se escribía; las dos formas
// son válidas en Java 8 y vas a ver las dos.
```

```java
// Una interfaz y su implementación. Spring Data lleva esto al extremo: la
// interfaz del repositorio NO tiene implementación escrita por nadie, se
// genera al arrancar a partir del nombre de los métodos (be03 §5.3).
public interface PatientRepository extends MongoRepository<Patient, String> {
    Patient findByLegacyId(Integer legacyId);
}
```

```java
// Clase anónima: una implementación de una interfaz escrita en el sitio.
// Es como se escribían los callbacks antes de las lambdas, y es lo que vas
// a ver en el código de 2019.
app.addListener(new ApplicationListener<ContextClosedEvent>() {
    public void onApplicationEvent(ContextClosedEvent event) {
        log.info("cerrando");
    }
});

// 🔥 Java 8 ya permitía la lambda equivalente —event -> log.info("cerrando")—
// y LabCore casi no la usa. No es un descuido del material: es 2019, cuando
// medio equipo venía de Java 7 y el estilo tardó años en cambiar.
```

```java
// final en un campo significa "se asigna una vez, en el constructor". Es la
// forma normal de una dependencia inyectada, y el compilador te garantiza
// que nadie la reasigna después.
private final PatientService patientService;
```

---

## 5. Excepciones: checked y unchecked

La diferencia que más sorprende a quien viene de Go, de JavaScript o de Python.

**Unchecked** (`RuntimeException` y sus hijas): se lanzan y suben. Nadie te obliga a nada. Es lo que conoces.

**Checked** (todo lo demás que hereda de `Exception`): **el compilador te obliga** a capturarlas o a declararlas en la firma del método. No es una convención ni un aviso: no compila.

```java
// Declararla y que suba. Es la opción correcta la mayoría de las veces.
public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
        throws IOException, ServletException {
    chain.doFilter(req, res);
}

// O capturarla.
try {
    Thread.sleep(config.latency);
} catch (InterruptedException e) {
    // ⚠️ Y AQUÍ está el patrón que hay que reconocer en cualquier código
    // legacy de Java: el catch vacío. Alguien solo quería compilar.
    //
    // Con InterruptedException es especialmente grave: tragársela sin
    // restaurar la marca de interrupción rompe el apagado ordenado de
    // be01 §5.9, y el síntoma —"el servidor no termina de pararse"— no se
    // parece en nada a esta línea.
    Thread.currentThread().interrupt();
}
```

> 🧭 **La regla al leer código de 2019:** cada `catch` vacío o con un `log.debug` solitario es una pista de que alguien peleaba con el compilador, no de que ese caso estuviera pensado. No los arregles todos al pasar; anótalos, y arregla el que esté en el camino del ticket que tienes entre manos.

Las tres que vas a encontrar seguro en este track: `IOException` (escribir una respuesta), `ServletException` (la cadena de filtros) e `InterruptedException` (dormir un hilo).

---

## 6. Anotaciones: configuración disfrazada de sintaxis

Una anotación **no ejecuta nada**. Es una marca que se queda en la clase compilada y que alguien —el arranque de Spring, casi siempre— lee para decidir qué hacer.

```java
@RestController                 // "registra esta clase como controlador HTTP"
@RequestMapping("/patients")    // "y su prefijo de ruta es /patients"
public class PatientController {

    @GetMapping("/{id}")        // "este método atiende GET /patients/{id}"
    public Patient findById(@PathVariable("id") Integer id) { … }
}
```

De ahí salen las dos consecuencias que hay que interiorizar, y las dos producen el mismo síntoma:

**Una anotación en una clase que Spring no escanea es un comentario caro.** El escaneo arranca en el paquete de la clase con `@SpringBootApplication` y baja; una clase fuera de `com.andina.labcore` no existe para Spring. No falla nada: el endpoint devuelve 404 y el código está ahí, delante de tus ojos.

**Una anotación sin la infraestructura que la implementa tampoco hace nada.** `@Transactional` sin un gestor de transacciones no abre ninguna transacción **y no se queja** — es el ejercicio 12 de `be05` y es de los silencios más caros del ecosistema.

```bash
# El diagnóstico para las dos: arrancar con --debug y leer el informe de
# auto-configuración, donde Spring imprime qué registró y qué no.
docker compose run --rm api mvn -f server/pom.xml spring-boot:run \
  -Dspring-boot.run.arguments=--debug
```

---

## 7. Spring: el contexto, los beans y los tres estereotipos

**El contexto** es un mapa de objetos que Spring construye una vez al arrancar. Cada objeto de ese mapa es un **bean**. Casi todo lo que puede salir mal en un arranque de Spring es "no encuentro un bean que alguien pide" o "encuentro dos y no sé cuál".

**Los tres estereotipos** son la misma anotación con tres nombres, y la diferencia es de intención, no de comportamiento —salvo `@Repository`, que sí añade algo:

```java
@RestController   // capa HTTP. Devuelve objetos, Jackson los convierte a JSON
@Service          // lógica de negocio. Es un @Component con un nombre que se lee
@Repository       // acceso a datos. Y ADEMÁS traduce las excepciones del driver
                  // a la jerarquía de Spring, que es lo que permite que tu
                  // service no sepa si abajo hay Mongo o cualquier otra cosa
```

**La inyección**, en las dos formas que vas a ver:

```java
// La de 2019: sobre el campo. Funciona por reflexión y es lo que hay en
// media internet de aquella época.
// 💸 El problema no es estético: una clase así no se puede instanciar en una
// prueba sin arrancar Spring entero, porque no hay forma de pasarle la
// dependencia. LabCore lo hace en varios sitios y no se paga.
@Autowired
private PatientService patientService;

// La correcta, y la que usa el track: por constructor. El campo puede ser
// final, la clase se puede construir a mano en una prueba, y si falta una
// dependencia el fallo es en el arranque y no en la primera petición.
private final PatientService patientService;

@Autowired
public PatientController(PatientService patientService) {
    this.patientService = patientService;
}
```

> 💡 **Con un solo constructor, `@Autowired` es opcional desde Spring 4.3** y puede omitirse. El track lo escribe para que se vea qué está pasando.

**El ciclo de vida de un bean**, en lo que importa: se construye al arrancar → se inyectan sus dependencias → se llama a lo anotado con `@PostConstruct` → vive como **singleton** (una sola instancia para toda la aplicación) → al apagar, `@PreDestroy`.

> ⚠️ **Singleton es el ámbito por defecto, y eso tiene una consecuencia que muerde:** un campo mutable en un `@Service` es **estado compartido entre todas las peticiones concurrentes**. En un lenguaje de un proceso por petición esto no existe; aquí sí, y es la fuente número uno de bugs imposibles de reproducir. Un service guarda dependencias y nada más.

---

## 8. Un hilo por petición, en la práctica

El porqué conceptual está en [`be01`](./be01-java-spring-y-la-forma-del-monolito.md) §4.1. Aquí, lo operativo.

```properties
# El pool de Tomcat embebido. 200 hilos por defecto en Boot 2.1.
server.tomcat.max-threads=200
```

Doscientas peticiones simultáneas ocupadas —esperando, durmiendo, o bloqueadas en una consulta lenta— y la petición 201 se queda en cola. Incluido el `/health` del que depende el despliegue, que es lo que convierte un problema de latencia en una caída.

Tres consecuencias prácticas, las tres presentes en el track:

```java
// 1. Lo que vive en un ThreadLocal tiene que limpiarse SIEMPRE, en un
//    finally. El hilo vuelve al pool y el siguiente que lo tome heredaría
//    el valor. Con un actor de auditoría adentro, eso no es un bug de logs:
//    es un asiento firmado por quien no fue. (be04 §5.1)
try {
    RequestContext.setActor(actor);
    chain.doFilter(request, res);
} finally {
    RequestContext.clear();
}

// 2. El MDC de los logs funciona por la misma razón, y se limpia igual.
//    (be01 §5.6)

// 3. "No responder" cuesta un hilo. La traducción ingenua de un
//    middleware de Express que hace return sin responder es Thread.sleep,
//    y doscientas de esas tumban el servidor. La forma correcta es un
//    servlet asíncrono, que suelta el hilo y deja la conexión abierta.
//    (be01 §5.7)
AsyncContext asyncContext = request.startAsync();
asyncContext.setTimeout(0);
```

> 🧠 **La regla que resume las tres:** *en este modelo, el hilo es un recurso compartido y reutilizado.* Todo lo que le cuelgues se limpia, y todo lo que lo bloquee se cuenta.

---

## 9. `Optional`, y por qué en 2019 se usaba a medias

`Optional<T>` llegó en Java 8 (2014) para que un método pudiera decir "puede que no haya nada" en la firma en vez de devolver `null` y confiar en que el que llama se acuerde.

```java
// Spring Data lo devuelve en findById desde la versión 2.0:
Optional<Patient> maybe = repository.findById(id);

Patient patient = maybe.orElse(null);                       // el atajo de 2019
Patient p2 = maybe.orElseThrow(() -> new NotFoundException(id));  // lo correcto
```

Y por qué en LabCore está a medias, que es lo que vas a encontrar: en 2019 `Optional` llevaba cinco años existiendo, la mitad del equipo venía de Java 7, y el consejo oficial —usarlo **como tipo de retorno** y no como campo ni como parámetro— no estaba tan asentado. Así que hay métodos que lo devuelven, otros que devuelven `null`, y unos cuantos `.get()` sin comprobar que son una `NoSuchElementException` esperando su turno.

> 🧭 **Al leer código de LabCore, la pregunta útil no es "¿por qué no usaron `Optional` en todas partes?" sino "¿qué devuelve este método cuando no hay nada?"**, y contestarla mirando el código y no suponiendo. `null` y `Optional.empty()` conviven en el mismo archivo más veces de las que parece razonable, y eso es 2019, no descuido.

---

## 10. Leer un stack trace

Es una habilidad en sí misma y se aprende en diez minutos. Un stack trace de Java se lee **de arriba hacia abajo para saber qué pasó, y de abajo hacia arriba para saber por qué**.

```
com.mongodb.MongoCommandException: Command failed with error 20 (IllegalOperation):
'Transaction numbers are only allowed on a replica set member or mongos'
	at com.mongodb.internal.connection.ProtocolHelper.getCommandFailureException(…)
	at com.mongodb.internal.connection.InternalStreamConnection.receiveCommandMessageResponse(…)
	... 47 more
	at com.andina.labcore.service.SampleService.processSample(SampleService.java:64)
	at com.andina.labcore.web.SampleController.transition(SampleController.java:41)
Caused by: java.lang.IllegalStateException: …
	at com.andina.labcore.service.SampleService.copyOf(SampleService.java:112)
```

Cómo se lee, en orden:

1. **La primera línea** es el tipo de excepción y su mensaje. Es lo que copias en el buscador y lo que pegas en el ticket.
2. **Busca la primera línea que empiece por tu paquete** —`com.andina.labcore`—. Ahí es donde tu código llamó a lo que falló, y es el sitio donde vas a poner el breakpoint. Las cuarenta líneas anteriores son las tripas de una librería y casi nunca importan.
3. **`... 47 more`** significa "el resto es igual que el trace anterior". No se ha perdido nada.
4. **`Caused by:` es lo que de verdad pasó.** Y cuando hay varios, **el último es el origen**. Es el error de lectura más común: la gente investiga la excepción de arriba, que casi siempre es una envoltura genérica del framework.

> 💡 **En este track tienes un atajo que no siempre vas a tener:** cada línea de log lleva el `X-Request-Id` del filtro de `be01` §5.6. Busca ese identificador en el log y tienes la petición entera, de la entrada al fallo, sin adivinar cuál de las trazas simultáneas era la tuya.

---

## 🧭 Cuándo usar qué

| Situación | Qué hacer | Por qué |
|---|---|---|
| Un endpoint devuelve 404 y el código está ahí | `--debug` y leer el mapeo de rutas | Casi siempre es escaneo de paquetes |
| `NoSuchMethodError` en ejecución | `dependency:tree -Dverbose` | Dos versiones de la misma clase en el classpath |
| Una anotación "no hace nada" | Buscar el bean que la implementa | `@Transactional` sin gestor es el caso canónico |
| Un campo numérico revienta con `null` | Cambiar `int` por `Integer` | Un documento viejo sin ese campo |
| Un bug que no se reproduce con un solo usuario | Buscar campos mutables en los `@Service` | Singleton + concurrencia |
| Necesitas la dependencia en una prueba | Inyección por constructor | Por campo no se puede sin arrancar Spring |
| El servidor "no termina de pararse" | Buscar `catch (InterruptedException)` vacíos | Rompen el apagado ordenado |
| Un stack trace de sesenta líneas | Ir al último `Caused by:` y a tu paquete | El resto son tripas |

---

## ⚠️ Advertencias

**Casi toda la documentación de Spring que vas a encontrar asume Boot 3 y Java 17.** Y no es una diferencia cosmética: en Boot 3, el paquete `javax.*` pasó a llamarse `jakarta.*`, así que un `import javax.servlet.Filter` copiado de aquí no compila allá y al revés tampoco. Media anotación cambió de sitio, la configuración de seguridad se reescribió entera, y los ejemplos de `RestTemplate` fueron sustituidos por otros. **La referencia de este track es la de Boot 2.1**, y la URL tiene que llevar la versión adentro:

```
https://docs.spring.io/spring-boot/docs/2.1.18.RELEASE/reference/htmlsingle/
https://docs.spring.io/spring/docs/5.1.19.RELEASE/spring-framework-reference/
```

Si una URL de Spring no lleva número de versión, estás leyendo la última. Suele ser otro producto.

**Java 8 llegó a fin de soporte público hace años**, y el track lo usa a propósito porque es lo que corre LabCore. Nada de lo que aprendas aquí te impide escribir Java moderno mañana; lo que este apéndice te da es la capacidad de **leer** el que ya existe, que es el trabajo del track.

**Y no busques JPA.** Al decir "Spring" casi todo el mundo piensa en `@Entity`, `EntityManager` y Hibernate. Nada de eso está en este stack: aquí hay `spring-data-mongodb`, que se le parece en la superficie —repositorios derivados del nombre del método— y no comparte ni el motor ni las garantías. Mezclar la documentación de los dos es una fuente de confusión garantizada.

---

## 📚 Referencias

**Documentación oficial, con la versión en la URL**

- Spring Boot 2.1.18 — referencia completa: https://docs.spring.io/spring-boot/docs/2.1.18.RELEASE/reference/htmlsingle/
- Spring Framework 5.1.19 — el capítulo *Core* (contexto, beans, inyección): https://docs.spring.io/spring/docs/5.1.19.RELEASE/spring-framework-reference/core.html
- Spring Framework 5.1.19 — *Web MVC*, filtros y `@ControllerAdvice`: https://docs.spring.io/spring/docs/5.1.19.RELEASE/spring-framework-reference/web.html
- Java 8 — API de `Optional`: https://docs.oracle.com/javase/8/docs/api/java/util/Optional.html
- Java 8 — tutorial oficial de excepciones, con la distinción checked/unchecked: https://docs.oracle.com/javase/tutorial/essential/exceptions/
- Maven — introducción al POM y a la gestión de dependencias: https://maven.apache.org/guides/introduction/introduction-to-the-pom.html
- Servlet 3.1 — `Filter` y `AsyncContext`: https://javaee.github.io/javaee-spec/javadocs/javax/servlet/Filter.html

**Libros**

- Craig Walls, *Spring in Action*, **5ª edición** (2018) — es la que cubre Boot 2.0/2.1. La 6ª describe Boot 3 y no aplica.
- Joshua Bloch, *Effective Java*, 3ª ed. (2018) — los ítems 9 (`try-with-resources`), 55 (`Optional`) y 69-77 (excepciones) son los que más rendimiento dan para leer este código.
- Brian Goetz, *Java Concurrency in Practice* (2006) — capítulo 7, cancelación e interrupción. Es la explicación completa del `Thread.currentThread().interrupt()`.

> ⚠️ URLs y contenidos cambian; verifícalos. Y con Spring, además, el buscador te va a llevar por defecto a la documentación más nueva: comprueba siempre que la URL diga `2.1.18.RELEASE` o `5.1.19.RELEASE`.

---

## 🧪 Ejercicios (10)

1. Corre `mvn dependency:tree` sobre `server/pom.xml` y cuenta cuántas dependencias hay en total frente a cuántas están declaradas en el archivo. Anota los dos números.
2. Busca en ese árbol el driver de MongoDB y anota su versión. Después búscalo en el `pom.xml`. Explica en una línea por qué no está.
3. Cambia un campo `Integer` de `Patient` por `int`, arranca, y lee un documento al que le falte ese campo. Captura el stack trace y localiza la primera línea de tu paquete.
4. Mueve una clase anotada con `@RestController` a un paquete fuera de `com.andina.labcore`. Arranca, pide su endpoint, y anota qué devuelve. Arráncalo con `--debug` y encuentra la prueba de que no se registró.
5. Escribe un `@Service` con un campo mutable que cuente peticiones sin sincronizar. Lánzale cincuenta peticiones concurrentes y anota el contador final. Explica el número.
6. Captura una `InterruptedException` y trágatela sin restaurar la interrupción. Comprueba qué le pasa al apagado ordenado de `be01` §5.9. Después arréglalo.
7. Cambia una inyección por campo a inyección por constructor y escribe una prueba que instancie la clase a mano, sin arrancar Spring. Anota qué era imposible antes.
8. **Diagnóstico.** Provoca un `NoSuchMethodError` añadiendo una dependencia con una versión distinta de una que ya está en el árbol. Diagnostícalo con `dependency:tree -Dverbose`.
9. **Diagnóstico.** Toma el stack trace más largo que hayas producido en el track y señala, en orden: el tipo, la primera línea de tu paquete, y el último `Caused by:`. Escribe en dos líneas qué pasó.
10. Baja `server.tomcat.max-threads` a 5, lanza veinte peticiones lentas concurrentes, y comprueba que `/health` deja de responder. Anota a partir de cuántas y por qué.

---

> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida y el código que explica lo escriben las fases —`be01` sobre todo—, así que lo que salga de leerlo se commitea con el prefijo de la fase desde la que llegaste (`be01: …`). Si un experimento merece conservarse, como los números del ejercicio 10, va en el mensaje de un tag anotado `ej/bea-01/10`. La convención completa está en [`00-convencion-de-git-y-tags.md`](./00-convencion-de-git-y-tags.md) §10.
