# ☕ Fase be01 — Java 8, Spring Boot 2.1 y la forma del monolito

> Tutorial Angular 8 — Laboratorio clínico · 🔥 Track BE · Fase be01 de be08 · **8 horas**
> Depende de: be00 — el contrato ya está auditado y escrito
> Habilita: be02
> Apéndices de apoyo: [bea-01 (Java y Spring para quien no escribe Java)](./bea-01-java-8-y-spring-para-quien-no-escribe-java.md) · [bea-02 (receta de imagen y compose)](./bea-02-receta-de-imagen-y-compose.md) · [Incidentes asociados](./cuaderno-incidentes-be.md): be-01

---

## 🎯 1. Propósito

Levantar el monolito de 2019 con tus propias manos y dejarlo respondiendo en el puerto 3000, con el inyector de caos reimplementado con paridad exacta y **sin tocar la base de datos todavía**.

Al terminar esta fase tienes un servidor de Java que sirve datos en memoria y que, desde la pestaña Network, es indistinguible del mock de la Fase 4 en todo lo que el contrato declara. No sirve datos reales —eso es `be03`— pero ya tiene la forma del sistema que heredaste: las capas, la cadena de filtros, el manejo de excepciones, el apagado, y el caos.

Hay un criterio de éxito que no es del track BE sino del track base, y es el que manda: **tienes que poder repetir el ejercicio 3 de la Fase 4** —arrancar con `CHAOS=latency=3000`, abrir `/patients`, y medir un spinner de tres segundos en Network— contra este servidor nuevo. Si no puedes, la fase está mal hecha, por muy limpio que haya quedado el Java.

> 🧠 **Reimplementar un sistema no es escribirlo mejor: es escribirlo *igual*, incluidos sus defectos, y solo entonces discutir cuáles se arreglan.** El modo de caos que ignora en silencio un nombre mal escrito es un defecto. Se copia tal cual. La conversación sobre arreglarlo llega después de que el reemplazo esté en verde, nunca antes.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `server/` existe dentro de tu proyecto, con su `pom.xml` fijado en Spring Boot **2.1.18.RELEASE** y Java 8, y `mvn spring-boot:run` arranca el servidor en el puerto **3000**.
- [ ] `GET /health` responde `200` con `{"status":"UP"}`, y sabes explicar por qué esa ruta la escribiste tú en vez de encender Actuator.
- [ ] Con `npm run mock` **apagado** y el servidor de Java arriba, `./smoke.sh` pasa las afirmaciones de forma, de estado y de identidad de `be00`. Las que no pasen están anotadas en `CONTRACT.md` con la fase donde se resuelven.
- [ ] Una excepción no capturada dentro de un controller devuelve `500` con el cuerpo `{"message":"..."}` del contrato, **sin stack trace y sin HTML**, y puedes demostrarlo apagando el `@ControllerAdvice` y volviéndolo a encender.
- [ ] `GET /patients/999999` devuelve `404` con el cuerpo exacto `{}`, no con el JSON de error por defecto de Spring.
- [ ] Los cinco modos de caos funcionan con paridad exacta contra la matriz de `CONTRACT.md`, por las dos vías —variable `CHAOS` y cabecera `X-Chaos`—, con el header ganando siempre, y apagados por defecto.
- [ ] `CHAOS=latency=3000 mvn spring-boot:run`, abres `/patients` en la aplicación Angular sin tocar un solo archivo del frontend, y mides tres segundos de spinner en Network.
- [ ] `Ctrl+C` sobre el servidor no corta a la mitad una petición en vuelo, y puedes demostrarlo con una petición de tres segundos y un `curl` que la ve terminar.
- [ ] Cada respuesta lleva `X-Request-Id`, y ese mismo identificador aparece en la línea de log de esa petición.

---

## 🚫 3. Qué NO entra todavía

- **MongoDB, en cualquier forma.** Ni el driver, ni `@Document`, ni una conexión. Los datos de esta fase están en memoria, escritos a mano, y se pierden al reiniciar → **be03**.
- **Autenticación de verdad.** `POST /login` firma un token y ningún endpoint lo verifica, exactamente como hoy. Eso es una cláusula del contrato de `be00`, no un descuido → la conversación es de **be04**.
- **Paginación, filtrado y ordenamiento de servidor.** El filtro por igualdad (`?patientId=1`) sí, porque está en el régimen estricto. Lo demás → **be03**.
- **El audit log escrito por el servidor** → **be04**. Hoy `/auditLog` es una lista en memoria que acepta lo que le manden, igual que json-server.
- **Transacciones, índices y todo lo que necesite una base** → **be05** y siguientes.
- **Pruebas automatizadas del backend.** Hay `smoke.sh` y nada más. La estrategia de pruebas se decide midiendo en **be08**.

---

## 🧠 4. Concepto mínimo

Este capítulo asume que sabes qué es una clase, la inyección de dependencias y un middleware. No los explica. Explica lo que Java y Spring hacen **distinto** de lo que ya conoces, que es donde de verdad se pierde el tiempo cuando uno llega de otro lenguaje. La sintaxis va entera en [`bea-01`](./bea-01-java-8-y-spring-para-quien-no-escribe-java.md): cuando algo de aquí abajo te resulte opaco, ábrelo ahí y vuelve.

### 4.1 Las cuatro cosas que Java hace distinto

**El classpath, que es la respuesta a la mitad de tus futuros "no encuentra la clase".** En Node, `require` resuelve archivos por ruta. En Java no hay rutas: hay un conjunto plano de clases empaquetadas en `.jar`, y el orden en que aparecen decide cuál gana. Maven lo construye a partir del `pom.xml` y ahí termina la magia. Cuando dos dependencias traen versiones distintas de la misma clase, no hay error: gana una y te enteras en tiempo de ejecución.

**Las excepciones *checked*, que no existen en ningún otro lenguaje que hayas usado.** El compilador te obliga a declarar o capturar ciertas excepciones. La consecuencia práctica en un sistema de 2019 no es teórica: verás `try/catch` vacíos por todas partes, escritos por alguien que solo quería compilar. Ese patrón —el `catch` que se traga el error— es el generador de "no pasó nada y sin embargo no funciona" más productivo del ecosistema.

**Las anotaciones son configuración, no sintaxis.** `@RestController` no hace nada por sí misma: es una marca que un escáner encuentra al arrancar y que dispara el registro del bean. Esto tiene una consecuencia contraintuitiva: **una anotación en un archivo que Spring no escanea es un comentario caro**. La mitad de los "mi endpoint devuelve 404 y el código está ahí" son eso.

**Y el modelo de hilos, que es la diferencia conceptual grande.** Spring MVC atiende **un hilo por petición**, tomado de un pool de tamaño fijo —200 en el Tomcat embebido por defecto—. El hilo se ocupa cuando entra la petición y se libera cuando la respuesta sale. En Node hay un solo hilo y un bucle de eventos; una petición dormida ahí no cuesta nada más que memoria. Aquí una petición dormida **cuesta un hilo**, y doscientas peticiones dormidas cuestan el servidor entero.

> 🧠 **Guarda esa última frase, porque el inyector de caos la va a cobrar.** El modo `timeout` del mock es un `return` sin responder: en Express es gratis. La traducción ingenua a Java —dormir el hilo— es una bomba de relojería, y la traducción correcta obliga a usar servlets asíncronos. Es el mejor ejemplo del track de que **portar código no es traducirlo línea por línea**, y ocupa el §5.7.

### 4.2 Spring Boot 2.1, y por qué justo esa

La versión está fijada y verificada: **2.1.18.RELEASE**, publicada el **29 de octubre de 2020**, la **última de la línea 2.1**, que llegó a fin de soporte el 1 de noviembre de 2020.

Eso encaja con la ficción y conviene decir cómo. El equipo contratado arrancó en 2019 con lo que había —la 2.1 salió en octubre de 2018 y era lo estable—, y el sistema recibió su último parche de framework en 2020, poco antes de que el frente se fuera. Desde entonces, nada. **El backend de LabCore corre hoy sobre un framework sin soporte desde hace seis años**, y esa frase es la mitad del argumento de `be08`.

Lo que esa versión arrastra, medido en su propio `spring-boot-dependencies`:

| Pieza | Versión que fija Boot 2.1.18 | Por qué importa aquí |
|---|---|---|
| Spring Framework | `5.1.19.RELEASE` | El núcleo. Nada de lo que leas sobre Boot 3 aplica |
| Spring Data | tren `Lovelace-SR21` | En `be03` decide qué sabe hacer tu repository |
| **`mongodb` (driver)** | **`3.8.2`** | **No lo eligió nadie: viene con el BOM.** Es exactamente el driver que `propuesta-fases-backend.md` §5.2 midió contra Mongo 4.0 a 8.0 |
| Jackson | `2.9.10.20200824` | Serializa tus respuestas. Sus defaults **son** parte del contrato |
| Tomcat embebido | `9.0.39` | 200 hilos por defecto. Ver §4.1 |
| JUnit | `4.12` | JUnit 4, no 5. Lo de la época |

> 🧠 **Esa fila del driver es la primera pista de `be07` y conviene subrayarla ahora.** Nadie en LabCore eligió `mongo-java-driver` 3.8.2: llegó dentro del BOM de Spring Boot, y como el `pom.xml` no se tocó nunca, el driver tampoco. Cuando en `be07` descubras que la base subió cuatro versiones mayores y el driver de 2019 sigue conectando sin quejarse, vas a entender por qué **nadie miró**: no había una línea que mirar.

> 📝 **Nota de época.** Boot 2.1 no tiene apagado ordenado. La propiedad `server.shutdown=graceful` llegó en **Boot 2.3** (2020). Un sistema de 2019 que quisiera apagar sin cortar peticiones tenía que escribirlo a mano, y por eso el §5.9 de esta fase tiene treinta líneas que hoy serían una propiedad. No es folclore: es la razón de que muchos despliegues de esa época cortaran respuestas a la mitad en cada arranque nuevo y nadie supiera por qué.

### 4.3 La forma del monolito: tres capas y una cadena de filtros

La arquitectura no tiene misterio y no lo tenía en 2019: **controller → service → repository**. El controller habla HTTP y no sabe nada del dominio; el service tiene las reglas; el repository habla con el almacén, que hoy es un `HashMap` y en `be03` será Mongo. La gracia de respetar esa frontera desde hoy es exactamente esa: **`be03` cambia una capa y ninguna otra se entera**.

Alrededor de las tres capas va la cadena de filtros, que es la parte que ya conoces con otro nombre. Un `javax.servlet.Filter` es lo mismo que un middleware de Express, con una diferencia de la que depende media fase:

> 🩻 **Esto sí funciona igual.** La petición entra, atraviesa una fila de funciones, y cada una decide si sigue o si responde. `chain.doFilter(request, response)` es `next()`. Un filtro que no llama a `doFilter` y no responde deja la petición colgada, exactamente igual que en Express.

> 🪞 **Tu instinto de Express dice "el orden es el orden de las líneas"… y esta vez se equivoca.** En Express el orden es el de los `app.use()`. En Spring, los filtros se descubren por escaneo y el orden es **el que declares**, con `@Order` o con un `FilterRegistrationBean`. Si no declaras nada, el orden es indeterminado y funciona hasta el día que deja de funcionar. Por eso el §5.4 registra los tres filtros a mano, con su número, aunque sea más código: **un orden implícito no es un orden**.

### 4.4 El contrato manda sobre los defaults del framework

Spring Boot trae opiniones, y tres de ellas chocan de frente con `CONTRACT.md`. Descubrirlas ahora cuesta media hora; descubrirlas en `be03` cuesta un día de pantalla en blanco.

**El 404 de Spring no es el 404 de json-server.** Spring devuelve `{"timestamp":"…","status":404,"error":"Not Found","path":"/patients/999999"}`. El contrato dice cuerpo `{}`. Hay que forzarlo.

**La página de error blanca —el *Whitelabel Error Page*— es HTML.** Ante una excepción no capturada, Spring responde `500` con una página HTML, y en algunas configuraciones con el stack trace adentro. El `catchError` del frontend espera JSON con `message`. Y en un sistema clínico un stack trace en la respuesta no es una molestia: es un hallazgo de auditoría.

**Jackson decide qué campos aparecen.** Por defecto serializa los `null`, que es lo que el contrato necesita: `email: null` y `validatedAt: null` viajan y el frontend los lee. Basta que alguien ponga `spring.jackson.default-property-inclusion=non_null` "para limpiar la respuesta" y esos campos desaparecen. Por eso el §5.2 lo declara **explícitamente**, aunque sea el valor por defecto: en un contrato, lo que no está escrito no existe.

Hay una cuarta diferencia, y esta **no** rompe nada, que es justo lo interesante: json-server responde `Content-Type: application/json` y Spring responde `application/json;charset=UTF-8`. `HttpClient` de Angular parsea las dos igual. Es una diferencia observable que **no** está en el régimen estricto, y saber distinguirla de las tres anteriores es el criterio que esta fase entrena.

---

## 💻 5. Código mínimo con comentarios

Diez piezas. Primero el andamiaje del proyecto, después la cadena de filtros, después el caos, y al final el apagado.

Todo vive en `server/`, dentro del mismo proyecto del alumno. El frontend sigue en la raíz, sin moverse ni un archivo.

```
server/
├── pom.xml
└── src/main/
    ├── java/com/andina/labcore/
    │   ├── LabCoreApplication.java
    │   ├── config/      FilterConfig.java · GracefulShutdown.java
    │   ├── filter/      CorsFilter.java · RequestIdFilter.java · ChaosFilter.java
    │   ├── chaos/       ChaosConfig.java · ChaosParser.java
    │   ├── error/       ApiExceptionHandler.java · NotFoundException.java
    │   ├── model/       Patient.java · Order.java · …
    │   ├── repository/  InMemoryPatientRepository.java · …
    │   ├── service/     PatientService.java · …
    │   └── web/         HealthController.java · PatientController.java · …
    └── resources/       application.properties
```

### 5.1 `pom.xml` — el archivo que nadie volvió a tocar

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <!-- El "parent" de Spring Boot no es herencia de código: es herencia de
       VERSIONES. Trae un BOM que fija cientos de dependencias coherentes
       entre si, y por eso mas abajo se declaran artefactos SIN version.
       Cambiar este numero cambia el driver de Mongo, Jackson y Tomcat de
       golpe — que es exactamente lo que en be07 nadie se atrevió a hacer. -->
  <parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>2.1.18.RELEASE</version>
    <relativePath/>
  </parent>

  <groupId>com.andina</groupId>
  <artifactId>labcore-server</artifactId>
  <version>1.0.0-SNAPSHOT</version>
  <name>LabCore Server</name>

  <properties>
    <!-- Java 8. No es nostalgia: es lo que corría la máquina de 2019 y lo
         que sigue corriendo hoy. Todo lo posterior aparece marcado 🔥 como
         comparación, nunca como la forma en que LabCore está escrito. -->
    <java.version>1.8</java.version>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
  </properties>

  <dependencies>
    <!-- Web: Spring MVC + Tomcat embebido + Jackson. Es todo lo que hace
         falta en be01. spring-boot-starter-data-mongodb NO entra todavía:
         esta fase sirve datos en memoria y esa frontera es deliberada. -->
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
    </dependency>

    <!-- El firmador del token. jjwt 0.9.1 es la de la época y funciona en
         Java 8 sin dependencias extra. El mock usaba jsonwebtoken 8.5.1 del
         lado de Node; lo que tiene que coincidir no es la librería, es la
         FORMA del token: HS256, los claims sub/role/fullName, y el TTL. -->
    <dependency>
      <groupId>io.jsonwebtoken</groupId>
      <artifactId>jjwt</artifactId>
      <version>0.9.1</version>
    </dependency>

    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-test</artifactId>
      <scope>test</scope>
    </dependency>
  </dependencies>

  <build>
    <plugins>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
      </plugin>
    </plugins>
  </build>
</project>
```

**Detalles con intención**

- **Ninguna dependencia lleva versión propia salvo `jjwt`**, que no está en el BOM. Esa asimetría es la que explica `be07` entera: lo que gestiona el BOM sube cuando sube el parent, y lo que no, se queda donde lo dejaron. Como aquí nadie subió el parent, no subió nada.
- Sin `spring-boot-starter-security`. En 2019 LabCore no lo tenía, y añadirlo hoy encendería un filtro que exige autenticación en todo — que es justo lo que el contrato dice que **no** pasa. Añadirlo "porque es lo correcto" rompería la aplicación en dos minutos. Literalmente dos: el TTL del token.
- 💸 **Sin `spring-boot-starter-validation`.** LabCore valida a mano dentro del service, con `if`, y devuelve `400` con un `message`. Lo correcto hoy sería `@Valid` con anotaciones de Bean Validation. **En este track no se paga**: el sistema tiene dos años de vida y la validación a mano funciona. Se declara y se sigue.

### 5.2 `application.properties` — cuatro líneas, tres del contrato

```properties
# El puerto es cláusula del régimen estricto: environment.apiUrl del frontend
# apunta aquí y el frontend no se toca.
server.port=3000

# La página de error HTML de Spring, apagada. El contrato dice que un error
# es JSON con "message". Ver el @ControllerAdvice del §5.8.
server.error.whitelabel.enabled=false

# Nunca, jamás, incluir el stack trace en la respuesta. En Boot 2.1 el valor
# por defecto de esta propiedad es "never", y aun así se escribe: en un
# sistema clínico, un stack trace filtrado es un hallazgo de auditoría, y lo
# que no está declarado se lo lleva el próximo que "limpie" la configuración.
server.error.include-stacktrace=never

# Jackson serializa los null. Es el valor por defecto y por eso mismo se
# declara: el contrato depende de que "email": null viaje, y de que
# "validatedAt": null exista en la respuesta aunque no tenga valor.
spring.jackson.default-property-inclusion=always
```

**El patrón a memorizar:** en un sistema que reemplaza a otro, **los valores por defecto se declaran igual que los que cambias**. Un default no es una decisión: es una decisión de otro, que puede cambiar cuando suba una versión. Las dos últimas líneas de ese archivo no cambian nada hoy y son las dos más importantes.

### 5.3 El arranque

```java
package com.andina.labcore;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

// @SpringBootApplication es tres anotaciones en una: configuración,
// autoconfiguración y escaneo de componentes. El escaneo arranca en el
// paquete de ESTA clase y baja. Una clase con @RestController fuera de
// com.andina.labcore no existe para Spring: no falla, simplemente no está.
@SpringBootApplication
public class LabCoreApplication {

    public static void main(String[] args) {
        SpringApplication.run(LabCoreApplication.class, args);
    }
}
```

### 5.4 `FilterConfig` — el orden, escrito

```java
package com.andina.labcore.config;

import com.andina.labcore.filter.ChaosFilter;
import com.andina.labcore.filter.CorsFilter;
import com.andina.labcore.filter.RequestIdFilter;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

// El orden de los filtros es la lógica del servidor, igual que en el
// server.js del mock. Se registra a mano, con número explícito, en vez de
// dejarlo al escaneo: un orden implícito funciona hasta el día que Spring
// descubre los beans en otro orden y entonces nadie entiende nada.
@Configuration
public class FilterConfig {

    // 1. CORS primero, SIEMPRE. Tiene que poner las cabeceras y cortar el
    //    preflight antes de que nada más pueda demorar o romper la petición.
    //    Si el OPTIONS atravesara el caos con latency=3000, cada petición con
    //    cabecera personalizada tardaría el doble y el síntoma sería
    //    imposible de explicar. Es la misma razón que en el mock (Fase 4).
    @Bean
    public FilterRegistrationBean<CorsFilter> corsFilter() {
        FilterRegistrationBean<CorsFilter> registration =
                new FilterRegistrationBean<CorsFilter>(new CorsFilter());
        registration.addUrlPatterns("/*");
        registration.setOrder(1);
        return registration;
    }

    // 2. El identificador de petición, antes del log y del caos: queremos
    //    poder correlacionar incluso lo que se rompe a propósito.
    @Bean
    public FilterRegistrationBean<RequestIdFilter> requestIdFilter() {
        FilterRegistrationBean<RequestIdFilter> registration =
                new FilterRegistrationBean<RequestIdFilter>(new RequestIdFilter());
        registration.addUrlPatterns("/*");
        registration.setOrder(2);
        return registration;
    }

    // 3. El caos, después del log y antes de todo lo que responde datos,
    //    incluido /login. El mock tomó esta misma decisión en la Fase 4 y la
    //    razón se copia con ella: el modo "expired" no tiene sentido si el
    //    login es inmune, y un login lento es el síntoma que más se reporta.
    @Bean
    public FilterRegistrationBean<ChaosFilter> chaosFilter() {
        FilterRegistrationBean<ChaosFilter> registration =
                new FilterRegistrationBean<ChaosFilter>(new ChaosFilter());
        registration.addUrlPatterns("/*");
        registration.setOrder(3);
        return registration;
    }
}
```

### 5.5 `CorsFilter` — a mano, y por el mismo motivo que en el mock

```java
package com.andina.labcore.filter;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

// CORS escrito a mano y no con @CrossOrigin ni con CorsRegistry. Es más
// código, y es la única forma de que el modo "nocors" del inyector de caos
// pueda QUITAR la cabecera después: con la configuración declarativa habría
// que desmontar el mecanismo entero. Misma decisión que el mock, misma razón.
public class CorsFilter implements Filter {

    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        // Los tres valores salen de CONTRACT.md, no de la memoria. X-Chaos
        // tiene que estar en Allow-Headers: si se cae de esta lista, el
        // navegador rechaza toda petición con caos por cabecera y el mensaje
        // de error habla de CORS en vez de hablar de tu cabecera.
        response.setHeader("Access-Control-Allow-Origin", "http://localhost:4200");
        response.setHeader("Access-Control-Allow-Headers",
                "Content-Type, Authorization, X-Chaos");
        response.setHeader("Access-Control-Allow-Methods",
                "GET, POST, PUT, PATCH, DELETE, OPTIONS");

        // El preflight se responde aquí y no sigue viajando. 204, sin cuerpo.
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            response.setStatus(HttpServletResponse.SC_NO_CONTENT);
            return;
        }

        chain.doFilter(request, response);
    }

    public void init(FilterConfig filterConfig) { }

    public void destroy() { }
}
```

**Detalles con intención**

- `init` y `destroy` vacíos: en Java 8 la interfaz `Filter` **no** tiene métodos `default`, así que hay que implementarlos aunque no hagan nada. Es el tipo de fricción que en `bea-01` tiene su sección; aquí solo se señala.
- El origen está escrito literal, `http://localhost:4200`. Es una 💸 declarada: lo correcto sería una propiedad de configuración. **En este track no se paga**, porque el sistema tiene un solo origen y meterlo en `application.properties` invitaría a que alguien lo cambie en un ambiente y no en otro — que es exactamente el incidente 19 del track base.

### 5.6 `RequestIdFilter` — el hilo que une los dos lados

```java
package com.andina.labcore.filter;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.UUID;

// Un identificador por petición, propagado a los logs y devuelto en la
// respuesta. Es la pieza que hace posible que un ticket diga "me pasó esto"
// con un identificador que se puede buscar en el log del servidor.
public class RequestIdFilter implements Filter {

    private static final Logger log = LoggerFactory.getLogger(RequestIdFilter.class);
    private static final String HEADER = "X-Request-Id";

    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        // Si el cliente manda uno, se respeta. Así, el día que alguien
        // instrumente el frontend, el identificador atraviesa el sistema
        // entero. Hoy no lo manda nadie y lo generamos nosotros.
        String requestId = request.getHeader(HEADER);
        if (requestId == null || requestId.isEmpty()) {
            requestId = UUID.randomUUID().toString().substring(0, 8);
        }

        // El MDC es un mapa por hilo que el patrón de log puede imprimir.
        // Funciona porque Spring MVC es un hilo por petición: en un modelo
        // reactivo esto no vale y hay que propagar el contexto a mano.
        MDC.put("requestId", requestId);
        response.setHeader(HEADER, requestId);

        long startedAt = System.currentTimeMillis();
        try {
            chain.doFilter(request, response);
        } finally {
            // El finally NO es opcional. Si una excepción sube y no limpiamos
            // el MDC, el hilo vuelve al pool contaminado y la siguiente
            // petición que lo tome loguea el requestId de otra persona. Ese
            // bug es muy difícil de creer cuando lo ves y muy fácil de causar.
            long elapsed = System.currentTimeMillis() - startedAt;
            String chaos = request.getHeader("X-Chaos");
            if (chaos == null) {
                chaos = System.getenv("CHAOS") == null ? "-" : System.getenv("CHAOS");
            }
            log.info("{} {} -> {} ({} ms) | chaos: {}",
                    request.getMethod(), request.getRequestURI(),
                    response.getStatus(), elapsed, chaos);
            MDC.remove("requestId");
        }
    }

    public void init(FilterConfig filterConfig) { }

    public void destroy() { }
}
```

**El patrón a memorizar:** todo lo que se guarda en un contexto por hilo se limpia en un `finally`. El pool reutiliza hilos, y un contexto sucio produce un log que atribuye una petición a otra persona — que en un sistema con auditoría no es un bug de logs, es evidencia falsa.

### 5.7 El caos, con paridad exacta

Dos archivos, igual que en el mock: uno lee la intención, otro la ejecuta.

```java
package com.andina.labcore.chaos;

// Traducción literal de chaos-config.js de la Fase 4. La forma del objeto y
// el formato de la cadena son los mismos, y eso NO es pereza: es el contrato.
// Las prácticas de diagnóstico de las Fases 4 a 12 escriben esas cadenas tal
// cual, y si aquí cambiara el formato, el track base dejaría de funcionar.
public class ChaosConfig {

    public int latency = 0;
    public int failStatus = 0;
    public int failRate = 0;
    public boolean malformed = false;
    public boolean timeout = false;
    public boolean expired = false;
    public boolean nocors = false;
}
```

```java
package com.andina.labcore.chaos;

import javax.servlet.http.HttpServletRequest;

public class ChaosParser {

    // Formato, idéntico al del mock:
    //   latency=2000   fail=500@30   malformed   timeout   expired   nocors
    public static ChaosConfig parse(String rawValue) {
        ChaosConfig config = new ChaosConfig();
        if (rawValue == null || rawValue.trim().isEmpty()) {
            return config;
        }

        String[] parts = rawValue.split(",");
        for (int i = 0; i < parts.length; i++) {
            String part = parts[i].trim();

            if (part.startsWith("latency=")) {
                config.latency = toInt(part.split("=")[1], 0);
            } else if (part.startsWith("fail=")) {
                // "500@30" -> status 500, 30 por ciento. Sin @ se asume 100%.
                String[] pieces = part.split("=")[1].split("@");
                config.failStatus = toInt(pieces[0], 500);
                config.failRate = pieces.length > 1 ? toInt(pieces[1], 100) : 100;
            } else if (part.equals("malformed")) {
                config.malformed = true;
            } else if (part.equals("timeout")) {
                config.timeout = true;
            } else if (part.equals("expired")) {
                config.expired = true;
            } else if (part.equals("nocors")) {
                config.nocors = true;
            }
            // 💸 Un modo desconocido se ignora EN SILENCIO. Escribe
            // "latencia=2000" y el servidor arranca contento, sin caos y sin
            // avisar. Es un defecto heredado del mock y se copia tal cual:
            // el reemplazo tiene que comportarse igual, incluso mal. Lo
            // correcto sería fallar al arrancar; en este track no se paga, y
            // el ejercicio 24 discute qué costaría arreglarlo.
        }
        return config;
    }

    // La precedencia entre FUENTES: la cabecera gana sobre la variable de
    // entorno, y no se combinan. Es la primera línea de la matriz de
    // CONTRACT.md y la que permite tener el servidor sano y romper una sola
    // petición desde la consola del navegador.
    public static ChaosConfig resolve(HttpServletRequest request) {
        String headerValue = request.getHeader("X-Chaos");
        if (headerValue != null && !headerValue.isEmpty()) {
            return parse(headerValue);
        }
        return parse(System.getenv("CHAOS"));
    }

    private static int toInt(String raw, int fallback) {
        try {
            return Integer.parseInt(raw.trim());
        } catch (NumberFormatException e) {
            return fallback;
        }
    }
}
```

Y el filtro, donde está la única traducción que **no** es literal:

```java
package com.andina.labcore.filter;

import com.andina.labcore.chaos.ChaosConfig;
import com.andina.labcore.chaos.ChaosParser;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Random;

public class ChaosFilter implements Filter {

    private static final Random RANDOM = new Random();

    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;
        ChaosConfig config = ChaosParser.resolve(request);

        // Modo nocors: quita la cabecera que puso el filtro 1. La respuesta
        // sale bien formada del servidor y el navegador la descarta igual,
        // que es justo lo que la hace confusa.
        if (config.nocors) {
            response.setHeader("Access-Control-Allow-Origin", null);
        }

        // ---------------------------------------------------------------
        // Modo timeout. AQUÍ es donde portar deja de ser traducir.
        //
        // En Express, "no responder" es un return: no cuesta nada porque hay
        // un solo hilo y un bucle de eventos. En Spring MVC hay un hilo por
        // petición, y dormirlo cuesta un hilo del pool. Con el pool en 200,
        // doscientas peticiones colgadas dejan el servidor sin atender NADA
        // — incluido el /health del que depende el despliegue.
        //
        // La forma correcta es un servlet asíncrono: startAsync() suelta el
        // hilo y deja la conexión abierta. setTimeout(0) significa "nunca
        // expira", que es exactamente la promesa del modo timeout: la
        // petición se queda en pending para siempre.
        // ---------------------------------------------------------------
        if (config.timeout) {
            AsyncContext asyncContext = request.startAsync();
            asyncContext.setTimeout(0);
            return;
        }

        // La latencia envuelve al resto: primero se espera, después se
        // decide. Al revés, un 500 con latencia saldría instantáneo y el
        // escenario "el servidor tarda y ADEMÁS falla" no se podría
        // reproducir. Mismo orden que el mock.
        if (config.latency > 0) {
            try {
                Thread.sleep(config.latency);
            } catch (InterruptedException e) {
                // Restaurar la marca de interrupción y salir. Tragarse una
                // InterruptedException sin restaurarla es el clásico de Java
                // que rompe el apagado ordenado del §5.9.
                Thread.currentThread().interrupt();
                return;
            }
        }

        // La precedencia entre MODOS: expired -> fail -> malformed. No es la
        // única opción razonable; es la que está escrita en el mock y por eso
        // es la que vale. Está en CONTRACT.md y se comprueba con smoke.sh.
        if (config.expired) {
            writeJson(response, 401, "{\"message\":\"Token expirado\"}");
            return;
        }

        if (config.failStatus > 0 && rollsAgainst(config.failRate)) {
            writeJson(response, config.failStatus,
                    "{\"message\":\"Fallo inyectado por el middleware de caos\",\"chaos\":true}");
            return;
        }

        if (config.malformed) {
            // 200 a propósito. El status miente y el cuerpo también. Es el
            // modo que ningún catchError del frontend detecta, porque desde
            // el punto de vista de HTTP no pasó nada.
            writeJson(response, 200,
                    "{\"data\":{\"items\":\"no-soy-un-arreglo\"},\"total\":null}");
            return;
        }

        chain.doFilter(request, response);
    }

    private void writeJson(HttpServletResponse response, int status, String body)
            throws IOException {
        response.setStatus(status);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(body);
    }

    // Devuelve true el porcentaje de las veces indicado. Con 100 siempre;
    // con 0, nunca. Math.random() del mock traducido: fail=500@30 NO es
    // reproducible, y es a propósito — los bugs intermitentes tampoco lo son.
    private boolean rollsAgainst(int ratePercent) {
        if (ratePercent <= 0) {
            return false;
        }
        return RANDOM.nextInt(100) < ratePercent;
    }

    public void init(FilterConfig filterConfig) { }

    public void destroy() { }
}
```

**Detalles con intención**

- El cuerpo de los tres modos que responden está escrito como **cadena literal**, no serializado desde un objeto. Es feo y es deliberado: son bytes del contrato, medidos en `be00`, y quiero que un `grep` sobre el repositorio los encuentre. Un objeto serializado por Jackson podría cambiar de forma si alguien toca la configuración de Jackson, y ese es justo el tipo de acoplamiento invisible que esta fase evita.
- `response.setHeader(name, null)` para quitar una cabecera es específico de Tomcat y no es portable a otros contenedores de servlets. Está declarado aquí y anotado en 📌 Pendientes: es una de las pocas cosas del track que dependen del contenedor concreto.
- La `InterruptedException` se restaura en vez de tragarse. Es el ejemplo canónico del `catch` vacío de §4.1, puesto donde de verdad importa: sin ese `interrupt()`, el apagado del §5.9 no puede desalojar los hilos dormidos.

> ⚠️ **El modo `timeout` con `startAsync()` deja conexiones abiertas que nadie cierra jamás.** Es fiel al mock y es igual de peligroso: cada una consume un socket y algo de memoria hasta que reinicies el proceso. En un servidor de verdad esto sería inaceptable; en un inyector de caos apagado por defecto y que solo se enciende a mano, es el comportamiento correcto. Lo importante es que **sepas** que es un fuga y que la enciendas a sabiendas. El ejercicio 22 mide cuántas hacen falta para tumbar el proceso.

### 5.8 El manejo de errores: `@ControllerAdvice` y el `404` del contrato

```java
package com.andina.labcore.error;

// Excepción propia del dominio. Sin mensaje al usuario: el contrato dice que
// un 404 va con cuerpo {} y punto.
public class NotFoundException extends RuntimeException {

    public NotFoundException(String message) {
        super(message);
    }
}
```

```java
package com.andina.labcore.error;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

// La red de seguridad de todo el servidor. Sin esto, una excepción no
// capturada dentro de un controller sale por la página de error de Spring:
// HTML, con el status dentro del cuerpo y — según la configuración — con el
// stack trace adentro. El catchError del frontend espera JSON con "message",
// así que HTML es una pantalla en blanco; y un stack trace en la respuesta de
// un sistema clínico es un hallazgo de auditoría, no una molestia.
@ControllerAdvice
public class ApiExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(ApiExceptionHandler.class);

    // El 404 del contrato: cuerpo {} EXACTAMENTE. No el JSON de error de
    // Spring, no un cuerpo vacío. Lo medimos en be00 contra json-server y
    // smoke.sh lo afirma.
    @ExceptionHandler(NotFoundException.class)
    public ResponseEntity<Map<String, Object>> handleNotFound(NotFoundException e) {
        // Se loguea con el requestId que puso el filtro 2, y NO se le cuenta
        // al cliente: hacia afuera, {} ; hacia adentro, todo.
        log.warn("recurso no encontrado: {}", e.getMessage());
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(new HashMap<String, Object>());
    }

    // Cualquier otra cosa. La forma del cuerpo la copia del inyector de caos
    // del mock, que es lo único que el frontend ha visto nunca como error de
    // servidor: un objeto con "message".
    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, Object>> handleAnything(Exception e) {
        // El stack trace va al log del servidor, entero, con su requestId.
        // Es la única copia que existe y es la que vas a leer en el ticket.
        log.error("error no controlado", e);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Collections.<String, Object>singletonMap(
                        "message", "Error interno del servidor"));
    }
}
```

> ⚠️ **Un `@ControllerAdvice` no captura lo que se rompe en un filtro.** Los filtros corren *antes* de que Spring MVC entre en escena, así que una excepción en `ChaosFilter` sale por el contenedor, no por aquí, y vuelve a ser HTML. Es el error de razonamiento más común con esta anotación y la razón de que el ejercicio 17 exista.

### 5.9 El apagado ordenado, escrito a mano porque en 2019 no había otra

```java
package com.andina.labcore.config;

import org.apache.catalina.connector.Connector;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.web.embedded.tomcat.TomcatConnectorCustomizer;
import org.springframework.boot.web.embedded.tomcat.TomcatServletWebServerFactory;
import org.springframework.context.ApplicationListener;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.event.ContextClosedEvent;

import java.util.concurrent.Executor;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

// Apagado ordenado, versión 2019. En Boot 2.3+ esto es una sola propiedad
// (server.shutdown=graceful). En 2.1 no existe, y sin esto un Ctrl+C corta a
// la mitad las peticiones en vuelo: el navegador ve la conexión caerse y el
// frontend lo reporta como un error de red que nadie sabe explicar.
//
// Lo que hace: al recibir el evento de cierre, PAUSA el conector (deja de
// aceptar conexiones nuevas) y espera a que el pool termine lo que tiene.
@Configuration
public class GracefulShutdown implements ApplicationListener<ContextClosedEvent>,
        TomcatConnectorCustomizer {

    private static final Logger log = LoggerFactory.getLogger(GracefulShutdown.class);
    private static final int WAIT_SECONDS = 20;

    private volatile Connector connector;

    public void customize(Connector connector) {
        this.connector = connector;
    }

    public void onApplicationEvent(ContextClosedEvent event) {
        if (this.connector == null) {
            return;
        }
        this.connector.pause();
        Executor executor = this.connector.getProtocolHandler().getExecutor();
        if (executor instanceof ThreadPoolExecutor) {
            try {
                ThreadPoolExecutor pool = (ThreadPoolExecutor) executor;
                pool.shutdown();
                if (!pool.awaitTermination(WAIT_SECONDS, TimeUnit.SECONDS)) {
                    // Veinte segundos y se corta. Es una decisión, no un
                    // límite técnico: más allá de eso, quien reinicia el
                    // servicio empieza a pensar que se colgó y lo mata a mano,
                    // que es peor que cortar ordenadamente.
                    log.warn("el pool no terminó en {} s; se corta", WAIT_SECONDS);
                }
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }
    }

    @Bean
    public TomcatServletWebServerFactory tomcatFactory() {
        TomcatServletWebServerFactory factory = new TomcatServletWebServerFactory();
        factory.addConnectorCustomizers(this);
        return factory;
    }
}
```

> 💡 Una petición con `CHAOS=latency=3000` es el banco de pruebas perfecto de este archivo: lanza el `curl`, cuenta hasta uno, y haz `Ctrl+C` en el servidor. Con el apagado ordenado, el `curl` termina con su respuesta. Sin él —coméntalo y repite—, el `curl` muere con `curl: (52) Empty reply from server`. Esa diferencia es la fase entera en dos comandos.

### 5.10 Una capa vertical completa, para ver la forma

Solo pacientes. Las otras cuatro colecciones son el mismo molde y son el ejercicio 8.

```java
package com.andina.labcore.model;

// POJO plano: campos, getters y setters. Sin Lombok — LabCore no lo usa, y
// en un sistema que se lee más de lo que se escribe, el getter explícito es
// lo que hace que un breakpoint tenga dónde ponerse.
// Los NOMBRES salen del db.json, no del gusto de nadie: el contrato exige
// documentId, fullName, birthDate, y camelCase.
public class Patient {

    private Integer id;
    private String documentId;
    private String fullName;
    private String birthDate;
    private String email;
    private Boolean active;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getDocumentId() { return documentId; }
    public void setDocumentId(String documentId) { this.documentId = documentId; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    // Fecha como String, no como LocalDate. Duele y es deliberado: el
    // contrato dice "1984-03-12" y cualquier conversión introduce zona
    // horaria donde hoy no la hay. El tratamiento serio de fechas es de
    // bea-08 y de be04; aquí se transporta lo que llega.
    public String getBirthDate() { return birthDate; }
    public void setBirthDate(String birthDate) { this.birthDate = birthDate; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public Boolean getActive() { return active; }
    public void setActive(Boolean active) { this.active = active; }
}
```

```java
package com.andina.labcore.web;

import com.andina.labcore.error.NotFoundException;
import com.andina.labcore.model.Patient;
import com.andina.labcore.service.PatientService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

// El controller habla HTTP y nada más: recibe, delega, devuelve. Sin reglas
// de negocio adentro. En el frontend de LabCore el componente gordo hace lo
// contrario y el track base vive de eso; aquí la frontera se respeta desde
// el primer día por una razón práctica: en be03 cambia la capa de abajo y
// esta no se entera.
@RestController
@RequestMapping("/patients")
public class PatientController {

    private final PatientService patientService;

    @Autowired
    public PatientController(PatientService patientService) {
        this.patientService = patientService;
    }

    // El filtro por igualdad del dialecto de json-server: ?documentId=CC-…
    // Es un parámetro OPCIONAL y por eso required=false: la misma ruta sirve
    // la colección entera y la búsqueda, igual que hace json-server.
    @GetMapping
    public List<Patient> findAll(
            @RequestParam(name = "documentId", required = false) String documentId) {
        return patientService.findAll(documentId);
    }

    @GetMapping("/{id}")
    public Patient findById(@PathVariable("id") Integer id) {
        // El NotFoundException lo convierte el @ControllerAdvice en un 404
        // con cuerpo {}, que es lo que dice el contrato.
        return patientService.findById(id);
    }

    // 201 con el objeto creado entero, incluido el id nuevo. El effect de
    // pacientes del frontend cuenta con recibirlo.
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Patient create(@RequestBody Patient patient) {
        return patientService.create(patient);
    }

    @PutMapping("/{id}")
    public Patient replace(@PathVariable("id") Integer id, @RequestBody Patient patient) {
        return patientService.replace(id, patient);
    }

    // PATCH devuelve el documento COMPLETO tras el cambio, no el delta ni un
    // 204. La baja lógica del frontend manda {"active": false} y espera el
    // paciente entero de vuelta para meterlo en el store.
    @PatchMapping("/{id}")
    public Patient patch(@PathVariable("id") Integer id,
                         @RequestBody java.util.Map<String, Object> changes) {
        return patientService.patch(id, changes);
    }
}
```

```java
package com.andina.labcore.repository;

import com.andina.labcore.model.Patient;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

// El almacén de be01: un mapa en memoria. Se pierde al reiniciar y está bien
// que se pierda — el objetivo de esta fase es la FORMA del servidor, no la
// persistencia. En be03 esta clase entera se sustituye por un repository de
// Spring Data y ninguna otra capa se entera. Esa es la prueba de que las
// fronteras están bien puestas.
@Repository
public class InMemoryPatientRepository {

    private final Map<Integer, Patient> store = new LinkedHashMap<Integer, Patient>();

    // El id entero autoincremental del dialecto de json-server. Aquí es un
    // AtomicInteger y funciona porque hay un solo proceso y una sola memoria.
    // En be03, con una base de verdad, esta línea se convierte en una
    // colección de contadores — y trae consigo el problema de concurrencia
    // que be05 recoge. Anótalo: es la misma decisión, con otro costo.
    private final AtomicInteger sequence = new AtomicInteger(3);

    public List<Patient> findAll() {
        return new ArrayList<Patient>(store.values());
    }

    public Patient findById(Integer id) {
        return store.get(id);
    }

    public Patient save(Patient patient) {
        if (patient.getId() == null) {
            patient.setId(sequence.incrementAndGet());
        }
        store.put(patient.getId(), patient);
        return patient;
    }
}
```

Y el `/health`, que es de una línea y tiene una decisión detrás:

```java
package com.andina.labcore.web;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Collections;
import java.util.Map;

// /health escrito a mano en vez de encender Actuator, por tres razones que
// conviene tener escritas:
//  1. En Boot 2.x el endpoint de Actuator vive en /actuator/health, no en
//     /health, y el compose de bea-02 y el smoke.sh apuntan a /health.
//  2. Actuator expone bastante más que salud, y todo lo que expone hay que
//     revisarlo antes de que llegue a un ambiente con datos de pacientes.
//  3. La salud que le importa a este sistema —¿responde Mongo?— no existe
//     todavía. Se añade en be03, y ahí sí vale la pena la conversación.
@RestController
public class HealthController {

    @GetMapping("/health")
    public Map<String, String> health() {
        return Collections.singletonMap("status", "UP");
    }
}
```

> **Prueba de fuego.** Apaga `npm run mock`. Arranca el servidor con `cd server && mvn spring-boot:run`. Corre `./smoke.sh` y anota qué pasa y qué no. Después arranca `CHAOS=latency=3000 mvn spring-boot:run`, levanta la aplicación Angular **sin tocar un solo archivo**, entra a `/patients` y cronometra el spinner en la pestaña Network: tres segundos. Por último, con el servidor sano, manda desde la consola del navegador `fetch('http://localhost:3000/patients', { headers: { 'X-Chaos': 'fail=500@100' } })` y confirma que **esa** petición falla y que recargar la pantalla funciona igual de bien. Si las tres cosas se cumplen, el reemplazo tiene la forma correcta aunque todavía no tenga datos.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Síntoma: el endpoint devuelve `404` y el código está ahí, delante de tus ojos.**
Causa: la clase está fuera del paquete que Spring escanea, o le falta `@RestController`, o el `@RequestMapping` de la clase y el del método se concatenan a algo que no esperabas (`/patients` + `/patients` = `/patients/patients`). Fix mínimo: arranca con `--debug` y busca en el informe de auto-configuración el mapeo de rutas; Spring lo imprime entero. La ruta que no aparece ahí no existe.

**Síntoma: el filtro de caos no se ejecuta nunca y no hay ningún error.**
Causa: se registró con un orden posterior al del dispatcher, o su patrón de URL no cubre la ruta. Fix mínimo: un `log.info` como primera línea del filtro y una petición de prueba. Es el mismo error del ejercicio 19 de la Fase 4 del track base, con otra sintaxis: **el orden de la cadena es la lógica del servidor**, y equivocarse de posición no produce un error sino un silencio.

**Síntoma: la aplicación Angular funciona con `curl` pero no con el navegador.**
Causa: CORS. Casi siempre, el filtro registrado después del caos, o `X-Chaos` fuera de `Allow-Headers`. Fix mínimo: mira si la petición fallida es un `OPTIONS`. Si el `OPTIONS` no aparece en el log del servidor, no llegó; si aparece con `200` en vez de `204`, alguien lo dejó pasar hacia abajo.

**Síntoma: `Ctrl+C` deja peticiones cortadas y el frontend reporta errores de red fantasma.**
Causa: falta el apagado ordenado, o una `InterruptedException` capturada y tragada en algún punto impide que el pool termine. Fix mínimo: `Thread.currentThread().interrupt()` en todos los `catch (InterruptedException)`. No es un detalle de estilo: es lo que hace que el apagado funcione.

**Síntoma: `smoke.sh` falla solo en la afirmación del `404` con cuerpo `{}`.**
Causa: el controller devuelve `null` o lanza una excepción distinta de `NotFoundException`, y Spring responde con su JSON de error por defecto. Fix mínimo: que la capa de servicio lance siempre `NotFoundException`, y comprobar que el `@ControllerAdvice` está en un paquete escaneado.

### Pieza forense de esta fase

**El `500` que llegó con un stack trace adentro.**

Comenta la anotación `@ControllerAdvice` de `ApiExceptionHandler` —una sola línea—, reinicia, y provoca una excepción real: pide `GET /patients/abc`, donde `abc` no se puede convertir al `Integer` que el controller declara. Después mira, en este orden:

1. **La pestaña Network.** El `Content-Type` de la respuesta, el código de estado, y el cuerpo. Vas a ver `text/html` donde el contrato promete `application/json`.
2. **La pantalla de la aplicación.** El `catchError` del effect se ejecuta, porque el status es un error de verdad; lo que no puede es sacar un `message` de una página HTML. El mensaje que ve el operador es el genérico, o ninguno.
3. **El cuerpo de la respuesta, entero.** Con `server.error.include-stacktrace=never` no hay traza; quítala de `application.properties`, reinicia y repite. Ahora el nombre de tus paquetes, la versión de Spring y la ruta de tus archivos viajan al navegador.

Las tres preguntas del método forense del track, contestadas por escrito:

- **¿Qué prometió el contrato?** Cuerpo JSON con `message`. `CONTRACT.md` lo dice y `be00` lo midió contra el mock.
- **¿Qué entregó el servidor?** HTML, con o sin traza según una propiedad que nadie declaró.
- **¿Quién se entera?** Nadie. El status es `500` y el frontend "maneja" el error. El fallo de contrato es invisible desde el navegador hasta que alguien mira el cuerpo.

> 🧠 **Ese último punto es la lección.** Un fallo de contrato que produce un síntoma visible se arregla en una tarde. El que se disfraza de comportamiento razonable sobrevive años. Por eso `smoke.sh` afirma **formas** y no solo códigos de estado — y por eso el ejercicio 25 de `be00`, el del servidor impostor, era el que de verdad medía la calidad de tu contrato.

🧨 **Rompe a propósito, segunda parte.** Provoca ahora una excepción **dentro de `ChaosFilter`** (por ejemplo, un `Integer.parseInt` sobre una cadena que no es número, quitando el `try/catch` de `toInt`). Comprueba que el `@ControllerAdvice`, aunque esté activo, **no la captura**: los filtros corren antes de Spring MVC. Anota qué devuelve el servidor y por qué. Ese es el incidente **be-01**.

---

## 🧪 7. Ejercicios (29)

**🟢 Fácil (1–8)**

1. Crea `server/` con el `pom.xml` del §5.1 y confirma con `mvn -q dependency:tree | head -40` que el driver de Mongo **todavía no está** en el árbol. Anota qué starter lo traería.
2. Arranca el servidor y comprueba con `curl -i localhost:3000/health` el código, el cuerpo y el `Content-Type`. Compáralo con lo que devuelve el mock en la misma ruta.
3. Añade un `log.info` al arranque que imprima el puerto y el valor de `CHAOS`. Arranca con y sin la variable y confirma las dos salidas.
4. Corre `curl -i localhost:3000/patients/999999` y confirma que el cuerpo es exactamente `{}`. Después comenta el `@ExceptionHandler(NotFoundException.class)` y anota qué devuelve Spring por su cuenta.
5. Comprueba que `X-Request-Id` viaja en la respuesta y que el mismo valor aparece en la línea de log. Manda tú uno con `curl -H 'X-Request-Id: mio-123'` y confirma que se respeta.
6. Arranca con `CHAOS=latency=1500` y mide con `curl -w '%{time_total}\n' -o /dev/null -s` tres peticiones distintas, incluido `POST /login`. Confirma que las tres tardan lo mismo.
7. Manda una petición con `X-Chaos: expired` estando `CHAOS` sin definir, y otra con `CHAOS=expired` sin cabecera. Confirma que las dos vías producen el mismo `401` con el mismo cuerpo.
8. Replica el molde vertical del §5.10 para `referenceRanges`: modelo, repositorio en memoria, servicio y controller, con los datos del `db.json`. Confirma con `curl` que `GET /referenceRanges` devuelve el arreglo desnudo.

**🟡 Intermedio (9–17)**

9. Completa las tres colecciones que faltan —`orders`, `samples`, `results`— con sus filtros por igualdad (`?patientId=`, `?orderId=`, `?sampleId=`) y haz que `smoke.sh` pase esas afirmaciones.
10. Implementa `POST /login` con `jjwt`, firmando HS256 con los mismos tres claims y el mismo TTL de 120 segundos. Decodifica el token en jwt.io y compáralo campo por campo con uno emitido por el mock.
11. Implementa `/auditLog` como una lista en memoria que **respete el `id` de cadena** que manda el cliente. Confirma con la afirmación 7 de `smoke.sh`.
12. Cambia `spring.jackson.default-property-inclusion` a `non_null`, reinicia y abre la pantalla de resultados de la aplicación. Anota qué se rompe, y devuélvelo a `always`. Escribe en dos líneas por qué esa propiedad está declarada aunque sea el valor por defecto.
13. **Diagnóstico.** Cambia el orden del filtro de CORS de `1` a `4` en `FilterConfig` y reinicia. Anota qué deja de funcionar, qué dice la consola del navegador y por qué `curl` sigue funcionando perfectamente.
14. **Diagnóstico.** Quita `X-Chaos` de `Access-Control-Allow-Headers` y manda la petición B de la pieza forense de `be00`. Anota el mensaje exacto del navegador y explica por qué señala al lugar equivocado.
15. Escribe una afirmación en `smoke.sh` que verifique el `Content-Type` de una respuesta de éxito. Decide, y justifica por escrito, si `application/json;charset=UTF-8` debe hacerla fallar o no.
16. **Diagnóstico.** Arranca con `CHAOS=latencia=3000` —mal escrito, con la `i`— y explica por qué el servidor arranca contento y no pasa nada. Localiza la línea exacta del `ChaosParser` responsable.
17. **Diagnóstico.** Provoca una excepción dentro de `ChaosFilter` y comprueba que el `@ControllerAdvice` no la captura. Anota el cuerpo y el `Content-Type` de la respuesta, y explica por qué en una frase.

**🟠 Difícil (18–24)**

18. Implementa el apagado ordenado del §5.9 y demuéstralo con la receta del 💡: `curl` con latencia de tres segundos, `Ctrl+C` al segundo uno. Anota la salida del `curl` con y sin el apagado activo.
19. **Diagnóstico.** Traduce el modo `timeout` de la forma **ingenua** —`Thread.sleep(Long.MAX_VALUE)` en vez de `startAsync()`— y lanza cincuenta peticiones concurrentes con `xargs -P`. Mide cuándo `GET /health` deja de responder. Anota el número de hilos que te hizo falta y compáralo con el `server.tomcat.max-threads` por defecto.
20. Con la versión correcta (`startAsync`), repite el ejercicio 19 y mide hasta dónde llegas. Explica qué recurso se agota ahora, que ya no es el pool de hilos.
21. **Diagnóstico.** Un compañero reporta que "el log mezcla peticiones: veo el `requestId` de otra persona". Reprodúcelo quitando el `MDC.remove` del `finally` y lanzando peticiones concurrentes. Explica por qué el pool de hilos convierte un olvido de limpieza en evidencia falsa.
22. Mide cuántas peticiones con `X-Chaos: timeout` hacen falta para que el proceso deje de aceptar conexiones nuevas. Documenta el número, el recurso que se agotó y la contramedida que **no** vas a aplicar, con su razón.
23. **Diagnóstico + diseño.** `smoke.sh` pasa contra el mock y falla contra tu servidor en tres afirmaciones. Para cada una decide, por escrito, si el fallo es un defecto de tu implementación o una cláusula del contrato que `be00` documentó mal. Corrige el que corresponda en cada caso —el código o el `CONTRACT.md`— y explica el criterio con el que decidiste.
24. Haz que un modo de caos desconocido **falle al arrancar** en vez de ignorarse. Después revierte el cambio y escribe las tres consecuencias que tendría para las prácticas del track base. Esta es la forma canónica del ejercicio del track: implementar la mejora, medir su costo, y decidir no aplicarla con argumentos.

**🔴 Muy difícil (25–29)**

25. **Adversarial.** Sin mirar el código del mock, escribe una batería de diez peticiones que distinga tu servidor del mock por su comportamiento observable. Después decide cuáles de esas diez diferencias son violaciones del contrato y cuáles son régimen de crecimiento. Añade al `CONTRACT.md` las que hacen falta.
26. **Diagnóstico.** El frontend recibe `200` con un cuerpo que no puede leer, y no es el modo `malformed`. Provócalo de verdad: haz que `PatientController.findAll` devuelva un `Map` con la lista adentro en vez del arreglo desnudo. Recorre el camino completo —Network, el reducer, la plantilla— y anota en qué capa aparece el primer síntoma y cuántas capas más abajo está la causa.
27. **Diseño.** Añade el filtro que valida el token en todas las rutas de datos —el que el 🔥 opcional de `be00` te hizo escribir en Express—, ahora en Java. Enciéndelo, usa la aplicación durante tres minutos sin recargar, y documenta con capturas qué le pasa al operador. Después apágalo y escribe el párrafo que le mandarías al dueño del producto explicando por qué "arreglar la seguridad" cuesta más que un filtro. Ese párrafo es material de `be04`.
28. **Adversarial.** Mide el arranque en frío del servidor (`mvn spring-boot:run` desde cero) y compáralo con `npm run mock`. Anota los dos números. Después argumenta, en media página, cuánto de esa diferencia le importa a un equipo de mantenimiento y cuánto no, distinguiendo el ciclo de desarrollo del despliegue en producción. Es el mismo criterio —tiempo de ciclo— con el que `be08` va a decidir la estrategia de pruebas.
29. **Diagnóstico y escritura.** Reproduce el incidente `be-01` de punta a punta —excepción en el filtro, respuesta HTML, pantalla sin mensaje— y escribe el post-mortem de ocho puntos del formato del cuaderno, sin culpabilización. Incluye el test de regresión que lo habría atrapado: una afirmación de `smoke.sh` que compruebe el `Content-Type` de un error.

**🔥 Opcionales**

- 🔥 Escribe el mismo `ChaosFilter` como un `HandlerInterceptor` de Spring MVC en vez de como un `Filter`. Anota qué deja de funcionar (pista: los recursos que no pasan por el dispatcher) y por qué el filtro es la elección correcta aquí.
- 🔥 Compara el `ChaosParser` de esta fase con lo que sería con Java 17: `record`, `switch` con patrones, text blocks. Escribe las dos versiones lado a lado y anota cuántas líneas se ahorran. Después contesta la única pregunta que importa: qué cuesta llevar LabCore a Java 17, y si un sistema con dos años de vida lo justifica.
- 🔥 Instrumenta el frontend para que mande su propio `X-Request-Id`… y no lo hagas. El frontend no se toca. En su lugar, escribe en `CONTRACT.md` qué ganaría el diagnóstico si se pudiera, y déjalo como recomendación fechada para quien herede el sistema.

---

## 📚 8. Referencias

**Documentación oficial**

- Spring Boot 2.1.x — documentación de referencia de la línea exacta que corre aquí: https://docs.spring.io/spring-boot/docs/2.1.18.RELEASE/reference/htmlsingle/ ⚠️ Es la única que aplica. Todo lo que encuentres sobre Boot 3.x describe otro producto.
- Anuncio de Spring Boot 2.1.18, con la frase "this is the last release in the 2.1 line": https://spring.io/blog/2020/10/29/spring-boot-2-1-18-available-now/
- Spring Framework 5.1 — Web MVC, filtros y `@ControllerAdvice`: https://docs.spring.io/spring/docs/5.1.19.RELEASE/spring-framework-reference/web.html
- Servlet 3.1 — `Filter` y `AsyncContext`, que es lo que sostiene el modo `timeout`: https://javaee.github.io/javaee-spec/javadocs/javax/servlet/AsyncContext.html
- Maven — introducción al POM y a la gestión de dependencias por BOM: https://maven.apache.org/guides/introduction/introduction-to-dependency-mechanism.html
- Jackson — anotaciones y política de inclusión de propiedades: https://github.com/FasterXML/jackson-annotations/wiki/Jackson-Annotations
- jjwt 0.9.1 — la API del firmador, que cambió bastante en 0.10+: https://github.com/jwtk/jjwt/tree/0.9.1

**Libros y artículos de referencia**

- Craig Walls, *Spring in Action*, 5ª edición (2018) — es la edición que cubre Boot 2.0/2.1. Las posteriores describen otro framework.
- Brian Goetz, *Java Concurrency in Practice* (2006) — capítulo 7, cancelación e interrupción. Es la explicación completa de por qué `Thread.currentThread().interrupt()` no es opcional.
- Michael Nygard, *Release It!*, 2ª ed. (2018) — el capítulo de patrones de estabilidad explica, con incidentes reales, por qué un pool de hilos agotado es el modo de fallo más común de un servidor Java. El ejercicio 19 es una versión doméstica de eso.

**Video y apoyo**

- Charlas de la época (2018-2020) sobre el ciclo de vida de un filtro y el arranque de Spring Boot: https://www.youtube.com/results?search_query=spring+boot+filter+order+2019 — ⚠️ verifica la fecha: lo posterior a 2022 va a hablar de WebFlux, de `RouterFunction` y de GraalVM, que no existen en tu stack.

**Orden de lectura sugerido:** `bea-01` entero **antes** de escribir la primera línea, si Java te es ajeno → el capítulo de Web MVC de Spring 5.1, solo las secciones de filtros y de manejo de excepciones → el anuncio de la 2.1.18, que se lee en dos minutos y explica media fase → Goetz cap. 7 cuando llegues al ejercicio 19, que es cuando su argumento se vuelve concreto → Nygard, después, para saber qué nombre tiene lo que acabas de reproducir.

> ⚠️ URLs, títulos y contenidos cambian o desaparecen; verifícalos. Con Spring, además, el buscador te va a llevar por defecto a la documentación de la versión más nueva: comprueba siempre que la URL diga `2.1.18.RELEASE` o `5.1.19.RELEASE`.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Tienes un servidor de Java que se comporta como el mock en todo lo que el contrato declara, y que además ya tiene la forma del sistema de 2019: tres capas, una cadena de filtros con el orden escrito, un manejador de excepciones que no filtra tripas, un apagado que no corta peticiones, y un inyector de caos con paridad exacta. Todo sobre datos que se pierden al reiniciar, y eso es exactamente lo que tenía que pasar.

La frontera que acabas de respetar es la que hace posible lo siguiente. En `be03`, el `InMemoryPatientRepository` desaparece y en su lugar entra un repository de Spring Data contra Mongo, **y ninguna otra clase se toca**. Si tuvieras que cambiar el controller, la frontera estaba mal puesta.

Pero antes de conectar la base hay que mirar qué hay dentro de ella, y ese es el giro del track. **be02** no construye nada: te entrega un dump de la colección real de producción y te pide que cuentes cuántas formas distintas del documento de paciente existen. El `Patient` de cinco campos tipados que acabas de escribir describe un sistema que no existe, y medirlo —con agregaciones, no con opiniones— es la fase que cambia el ánimo de todo lo que sigue.

> **La señal de que quedó bien:** *"apagué el mock, levanté Java en el mismo puerto, y la aplicación Angular no se enteró de nada — ni siquiera cuando le inyecté tres segundos de latencia para comprobar que el caos también se había mudado."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en verde y `git status` limpio:
>
> ```bash
> git tag -a be-fase-01-java-spring-y-la-forma-del-monolito -m "be01 cerrada: server/ con Boot 2.1.18 en el 3000; tres capas; cadena de filtros ordenada; 404 {} y errores JSON; caos con paridad exacta por las dos vías; apagado ordenado; smoke.sh contra Java"
> ```
>
> Los commits de la fase llevan su prefijo (`be01: …`) y los de ejercicio su número (`be01 ej19: …`). El track BE usa el namespace `be-fase-*` para que `git tag -l 'fase-*'` siga siendo el índice limpio del track base. Todo eso está en [`00-convencion-de-git-y-tags.md`](./00-convencion-de-git-y-tags.md) §10.

---

## 📌 Pendientes sugeridos

- **[A] `response.setHeader(name, null)` para quitar una cabecera es específico de Tomcat.** Funciona porque el contenedor embebido es Tomcat 9.0.39 y está fijado en el BOM. Si alguna vez se cambia a Jetty o Undertow, el modo `nocors` deja de funcionar en silencio. Anotado en `CONTRACT.md`; no se abstrae hoy.
- **[B] El apéndice `bea-02`** (receta de imagen y compose) tiene que existir para que esta fase se pueda hacer dentro del contenedor. Mientras no exista, la fase corre con Maven local y el enlace queda como deuda declarada.
- **[C] `bea-01`** debe cubrir, como mínimo: paquetes y `pom.xml`, excepciones checked, el ciclo de vida de las anotaciones, `@Autowired` por constructor, y el modelo de un hilo por petición. Esta fase enlaza a esos cinco puntos y no reexplica ninguno.
- **[D] El TTL del token de 120 segundos** viene del mock y se copia. Es cómodo para la clase e insostenible en producción. No se toca hasta `be04`, donde la conversación sobre identidad se tiene entera y con el frontend intacto como restricción.
- **[E] El `AtomicInteger` como generador de `id`** funciona con un proceso y una memoria. En `be03` se convierte en una colección de contadores al estilo de 2019, y ahí aparece el problema de concurrencia que `be05` recoge. La decisión ya está tomada en la propuesta §11; esta fase solo deja el gancho.
- **[F] Las cinco colecciones en memoria duplican datos del `db.json`.** Es duplicación consciente y temporal: en `be03` la semilla sale del `db.json` del propio alumno y estas clases se vacían. Si `be02` o `be03` se retrasan, revisar que la duplicación no haya derivado.

### Reservas para el cuaderno de incidentes

| ID | Título propuesto | Categoría | Dificultad |
|---|---|---|---|
| **be-01** | *"El servidor dice 500 y la pantalla no dice nada"* | Contrato / manejo de errores | 🟠 |

El ticket llega como *"desde ayer, cuando falla algo, no sale el mensaje de error, sale la pantalla vacía"*. La causa es una excepción lanzada **dentro de un filtro**, que el `@ControllerAdvice` no captura porque los filtros corren antes de Spring MVC: la respuesta sale como HTML y el `catchError` del frontend no encuentra `message`. Se resuelve a partir de esta fase. El post-mortem tiene que llegar a la regla general —*el manejador de excepciones de tu framework solo cubre lo que pasa por tu framework*— y el test de regresión es una afirmación de `Content-Type` en `smoke.sh`.
