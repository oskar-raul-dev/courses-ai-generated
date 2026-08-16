# 📜 Fase be04 — El audit log que escribía el navegador

> Tutorial Angular 8 — Laboratorio clínico · 🔥 Track BE · Fase be04 de be08 · **8 horas**
> Depende de: be03 — el backend sirve el contrato desde Mongo y el mock está apagado
> Habilita: be05
> Apéndices de apoyo: [bea-08 (tiempo, zonas y fechas en Mongo)](./bea-08-tiempo-zonas-y-fechas-en-mongo.md) · [Incidentes asociados](./cuaderno-incidentes-be.md): be-06, be-07

---

## 🎯 1. Propósito

Poner la identidad y el reloj donde siempre debieron estar, **sin tocar el frontend que hoy los pone mal**.

El punto de partida está escrito en el track base y conviene releerlo entero antes de empezar. El audit log de LabCore lo escribe el navegador: el actor sale del token que vive en `localStorage`, el timestamp sale del reloj de la máquina del operador, y si la escritura del asiento falla, la mutación ya ocurrió y nadie se entera. Es el incidente 17 del cuaderno base, el que se siente injusto — porque lo es.

Y se decidió así por una razón que ya no existe: **el backend estaba congelado y era de otro equipo**. Pedirle un endpoint nuevo en 2021 no era una conversación que se pudiera tener. Ahora el backend es tuyo, lleva dos fases funcionando, y esa conversación se puede tener contigo mismo.

Lo que **no** se puede es arreglarlo del todo, y ahí está la fase. El frontend no se toca, así que sigue mandando sus asientos con su actor y su hora. Durante `be04` conviven las dos bitácoras y tú mides la distancia entre ellas.

> 🧠 **El entregable de esta fase no es código: es un número.** Cuántos asientos el navegador nunca envió, cuántos tienen un actor distinto del real, y cuántos tienen una hora que difiere de la del servidor en más de un minuto. Sin ese número, todo lo que puedas decir sobre la trazabilidad de LabCore es una opinión — y a un auditor no se le contesta con opiniones.

---

## ✅ 2. Qué queda listo al terminar

- [ ] El backend resuelve el actor **desde el token**, no desde un campo del cuerpo, y ese actor viaja disponible a toda la petición sin que ninguna capa tenga que pasárselo a la siguiente.
- [ ] Tienes escrita y fechada la decisión sobre la firma y la expiración del token: qué se verifica, qué no, y por qué **no verificar la expiración es hoy la opción correcta**.
- [ ] Toda mutación registrable escribe su propio asiento **en el servidor**, con el reloj del servidor, en el mismo camino que la mutación.
- [ ] Las dos bitácoras conviven: `GET /auditLog` sigue devolviendo **exactamente** lo que devolvía —los asientos del navegador— y el frontend no nota nada.
- [ ] `MEASUREMENTS.md` tiene las tres mediciones de divergencia con su agregación, su fecha y su número: asientos ausentes, actores discrepantes y desfases de reloj mayores de un minuto.
- [ ] Puedes mostrar un asiento del cliente con **hora del futuro** y explicar, sin culpar a nadie, exactamente cómo se produjo.
- [ ] Sabes decir cuántas representaciones distintas del tiempo conviven hoy en LabCore, y cuál es la buena.
- [ ] `./smoke.sh` sigue entero en verde, incluida la afirmación de que `/auditLog` conserva el `id` de cadena que manda el cliente.

---

## 🚫 3. Qué NO entra todavía

- **Decidir cuál de las dos bitácoras es la buena a efectos legales.** Esa conversación necesita los ocho números del track y la fecha de decomisión encima de la mesa → **be08**.
- **Apagar la bitácora del cliente.** Requeriría tocar el frontend. No se toca.
- **Hacer que la mutación y su asiento sean atómicos.** Son dos documentos, y hoy si el segundo falla el primero se queda escrito. Se anota, se mide, y **no se arregla** → **be05**, que es donde se descubre por qué no se puede arreglar como crees.
- **Rellenar hacia atrás los asientos que faltan.** No se puede: si el navegador nunca lo envió, el dato no existe en ninguna parte. Se cuenta y se declara → el inventario alimenta **be08**.
- **Los rangos versionados y su historia perdida** → **be06**.

---

## 🧠 4. Concepto mínimo

### 4.1 Las tres cosas que un asiento de auditoría promete, y las tres que LabCore rompe

Un asiento de auditoría contesta cuatro preguntas: **quién**, **qué**, **cuándo** y **contra qué estado**. Para que la respuesta valga ante alguien de fuera, hacen falta tres propiedades, y LabCore falla en las tres por el mismo motivo estructural.

**Que el "quién" no lo declare el interesado.** Hoy el actor sale de un campo que arma el navegador leyendo un token de `localStorage`. Cualquiera con las herramientas de desarrollador abiertas puede escribir otro. No hace falta mala fe para que se rompa: basta un token viejo de otra sesión.

**Que el "cuándo" venga de un reloj que alguien controle.** Hoy viene de `new Date()` en la máquina del operador. Un portátil con la hora adelantada veinte minutos produce asientos que ocurren antes de la causa que los produjo.

**Que el asiento y el hecho sean inseparables.** Hoy son dos peticiones HTTP y la segunda es opcional en la práctica: si falla, la primera ya ocurrió. **El hueco en la bitácora nace ahí**, y es silencioso.

> 📝 **Nota de época, y va sin ironía.** Las tres decisiones eran razonables en 2021 dadas las restricciones reales: un backend congelado, de otro equipo, y una auditoría que pedía trazabilidad para ayer. La alternativa correcta —un endpoint que escribiera el asiento del lado del servidor— exigía una conversación organizacional que nadie podía tener. **La deuda técnica no siempre nace de la ignorancia; a veces nace de una frontera de equipos**, y esa es la lección que hace que esta fase valga más que su código.

### 4.2 La decisión incómoda: verificar la firma y **no** verificar la expiración

Aquí hay una trampa, y hay que verla antes de caer en ella.

Si el backend va a sacar el actor del token, tiene que leer el token. Y en cuanto lo lee, la tentación es hacer lo correcto: verificar la firma, verificar la expiración, y rechazar con `401` lo que no cuadre. Es lo que haría cualquiera. Y **rompería la aplicación en dos minutos**, literalmente: el TTL del token es de 120 segundos, no hay refresh, y el interceptor de la Fase 3 reacciona a cualquier `401` cerrando la sesión. El operador que esté validando resultados vuelve a la pantalla de login a mitad de la tarea, cada dos minutos, para siempre.

La decisión, entonces, se parte en dos y se escribe:

| Comprobación | ¿Se hace? | Por qué |
|---|---|---|
| **Firma HS256** | **Sí** | El backend emite los tokens desde `be03` y conoce el secreto. Un token no firmado por nosotros no dice nada de nadie, y usar su `sub` como actor sería peor que no tener actor |
| **Expiración (`exp`)** | **No** | Rechazar por expiración es un `401`, y un `401` cierra la sesión. Con TTL de 120 s y sin refresh, eso es apagar el producto |
| **Ausencia de token** | Se registra `actor: "system"` | Es lo que hace hoy el frontend cuando no hay sesión, y el contrato manda |

> 🧭 **Y la parte que hace que esto sea ingeniería y no una excusa: la decisión se escribe con su fecha, su razón y su condición de revisión.** *"No verificamos la expiración porque el cliente no puede renovar el token. Se revisa el día que el frontend tenga refresh, o el día que el sistema se decomisione — lo que ocurra primero."* Una decisión así, escrita, es una decisión. La misma sin escribir es un descuido que alguien va a descubrir en una auditoría y va a llamar de otra manera.

Fíjate además en lo que **no** cambia: la cláusula de `CONTRACT.md` que dice que ningún endpoint de datos rechaza una petición sin `Authorization` sigue vigente, y su afirmación en `smoke.sh` sigue en verde. Leer el token para saber quién es no es lo mismo que exigirlo para dejar pasar.

### 4.3 El reloj: cuatro tiempos en un solo sistema

Antes de escribir nada, el inventario. Hoy, en LabCore, conviven cuatro representaciones del tiempo, y solo una tiene dueño:

1. **El `-05:00` del `db.json`** — `"2019-09-02T08:15:00-05:00"`. Cadena, con desplazamiento explícito de `America/Bogota`. Es la de los datos sembrados.
2. **La `Z` del navegador** — `new Date().toISOString()` produce `"2026-09-10T15:04:05.123Z"`. Cadena, en UTC, calculada a partir del reloj **y de la zona** de la máquina del operador.
3. **El `BSON Date`** de los 912 documentos que midió `be02` — un entero de milisegundos desde 1970, sin zona porque no la necesita.
4. **El reloj del servidor**, que a partir de esta fase entra en escena y es el único que alguien controla.

Las conversiones entre esas cuatro no son inocentes, y `bea-08` las cubre entera. Lo mínimo para trabajar hoy:

> 🧠 **Un `BSON Date` no guarda zona horaria y no la necesita: guarda un instante.** La zona es una propiedad de la *presentación*, no del dato. El error clásico —y está en LabCore— es guardar cadenas con desplazamiento y creer que eso "conserva la zona". Conserva el desplazamiento de aquel día, que con horario de verano no es lo mismo; Colombia no lo tiene, así que aquí funciona por suerte y no por diseño. Guardar el instante en UTC y decidir la zona al pintarlo es lo correcto, y es lo que el servidor va a hacer.

Y la trampa sutil, la que produce el incidente **be-07**: `toISOString()` del navegador **sí** convierte a UTC correctamente… usando el reloj y la zona del sistema operativo del operador. Si el portátil tiene la hora adelantada veinte minutos, el resultado es un UTC impecablemente formado y veinte minutos falso. **El formato no valida el contenido.** Un asiento con hora del futuro no tiene ningún error de sintaxis.

### 4.4 Por qué conviven las dos bitácoras, y por qué eso es la fase

La solución obvia sería que el servidor escribiera el asiento bueno y descartara el del navegador. No se hace, y hay dos razones, una de contrato y otra mucho mejor.

**La de contrato:** `GET /auditLog` alimenta la timeline de la Fase 11. Si el servidor empezara a meter sus propios asientos en esa colección, la pantalla mostraría entradas que el navegador nunca escribió —con otro formato de `id`, otro actor, otra hora—, y eso es cambiar el comportamiento observable sin haberlo decidido.

**La buena:** si tiras los asientos del cliente, **destruyes la evidencia que esta fase quiere medir**. La pregunta *"¿cuánto miente la bitácora que llevamos usando cinco años?"* solo se puede contestar teniendo las dos y comparándolas. Y esa pregunta es la que un auditor va a hacer.

Así que se aceptan los dos y se guardan por separado:

| Colección | Quién escribe | Qué se sirve en `GET /auditLog` |
|---|---|---|
| `auditLog` | el navegador, como siempre, con su `id` de cadena | **esto, y solo esto** |
| `auditLogServer` | el backend, en el mismo camino que la mutación | nada — no se expone |

> 🧭 **El patrón se llama *shadow write* y merece la pena tener el nombre.** El sistema nuevo escribe en paralelo al viejo sin que nadie lo consuma, durante el tiempo necesario para medir si dice lo mismo. Cuando se decide cortar —en `be08`— la decisión llega con datos y no con fe. Es el mismo movimiento que hiciste con la paginación en `be03`: **construir el otro lado y no conectarlo todavía**.

---

## 💻 5. Código mínimo con comentarios

Siete piezas. Las tres primeras montan la identidad y el reloj; las tres siguientes escriben la sombra; la última mide.

### 5.1 El actor, resuelto en un filtro

```java
package com.andina.labcore.filter;

import com.andina.labcore.auth.RequestContext;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import java.io.IOException;

// Resuelve QUIÉN está haciendo la petición, y no rechaza a nadie.
//
// Esta es la diferencia entre autenticación y este filtro: aquí no se decide
// si pasa, solo se averigua quién es. La cláusula de CONTRACT.md que dice
// que ningún endpoint de datos exige Authorization sigue intacta, y su
// afirmación en smoke.sh sigue en verde.
public class ActorFilter implements Filter {

    // El mismo secreto con el que be03 firma. Literal, igual que en el mock:
    // el sistema entero es andamiaje del curso. En LabCore de verdad esto
    // viviría en una variable de entorno, y esa 💸 está declarada en be03.
    private static final String JWT_SECRET = "lab-clinico-secreto-de-curso";

    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        String actor = "system";

        String header = request.getHeader("Authorization");
        if (header != null && header.startsWith("Bearer ")) {
            try {
                // parseClaimsJws VERIFICA LA FIRMA. Un token que no firmamos
                // nosotros lanza aquí y el actor se queda en "system", que es
                // exactamente lo que queremos: mejor anónimo que suplantado.
                Claims claims = Jwts.parser()
                        .setSigningKey(JWT_SECRET.getBytes("UTF-8"))
                        .parseClaimsJws(header.substring(7))
                        .getBody();
                actor = claims.getSubject();

            } catch (io.jsonwebtoken.ExpiredJwtException e) {
                // ---------------------------------------------------------
                // DECISIÓN FECHADA — 10/09/2026.
                //
                // Un token vencido SÍ nos dice quién es: su firma es válida y
                // lo emitimos nosotros. Lo aceptamos como identidad y NO
                // devolvemos 401, porque el TTL es de 120 segundos, no hay
                // refresh, y el interceptor de la Fase 3 cierra la sesión con
                // cualquier 401. Rechazar aquí es apagar el producto.
                //
                // Se revisa el día que el frontend tenga refresh, o el día de
                // la decomisión. Lo que ocurra primero.
                // ---------------------------------------------------------
                actor = e.getClaims().getSubject();

            } catch (Exception e) {
                // Firma inválida, token corrupto, algoritmo distinto. No se
                // usa nada de lo que venga adentro: queda "system".
                actor = "system";
            }
        }

        try {
            RequestContext.setActor(actor);
            chain.doFilter(request, res);
        } finally {
            // Igual que el MDC de be01, y por la misma razón: el hilo vuelve
            // al pool y el siguiente que lo tome heredaría este actor. En un
            // sistema con auditoría, eso no es un bug de logs: es un asiento
            // firmado por quien no fue.
            RequestContext.clear();
        }
    }

    public void init(FilterConfig filterConfig) { }

    public void destroy() { }
}
```

**Detalles con intención**

- El filtro se registra con orden **4**, después del caos. Que una petición rota por el inyector no llegue a resolver actor es correcto: nunca va a escribir nada.
- **`"system"` es el valor por defecto y no es casual**: es la misma palabra que usa el `AuditEffect` del frontend cuando no hay sesión, y la Fase 11 dice que esa palabra en la timeline es el núcleo del incidente 17. Mantenerla es lo que hace comparables las dos bitácoras.
- El `catch` de expiración y el genérico hacen cosas **distintas** a propósito. Colapsarlos en uno solo —un `catch (Exception)` que ponga `"system"`— sería más corto y borraría la identidad de todo el que lleve más de dos minutos sin recargar, que es casi todo el mundo.

```java
package com.andina.labcore.auth;

// El actor de la petición en curso, sin tener que pasarlo por parámetro
// desde el controller hasta el service. Funciona porque Spring MVC es un
// hilo por petición (be01 §4.1); en un modelo reactivo esto no vale.
//
// 💸 Un ThreadLocal es estado global disfrazado, y hace más difícil probar
// el service de forma aislada. Lo correcto sería un bean con ámbito de
// petición inyectado. En este track no se paga: son quince líneas contra
// una cadena de firmas atravesando cuatro capas, y el sistema tiene dos
// años de vida.
public final class RequestContext {

    private static final ThreadLocal<String> ACTOR = new ThreadLocal<String>();

    public static void setActor(String actor) { ACTOR.set(actor); }

    public static String getActor() {
        String actor = ACTOR.get();
        return actor == null ? "system" : actor;
    }

    public static void clear() { ACTOR.remove(); }

    private RequestContext() { }
}
```

### 5.2 El reloj, con dueño

```java
package com.andina.labcore.audit;

import org.springframework.stereotype.Component;

import java.time.Clock;
import java.time.Instant;

// El reloj del servidor, detrás de un bean. No es ceremonia: un Instant.now()
// esparcido por cinco servicios es imposible de probar, y esta fase produce
// mediciones de tiempo que hay que poder reproducir.
//
// El instante se guarda en UTC y NADA MÁS. La zona America/Bogota es una
// decisión de presentación y vive en el frontend, que ya la tiene desde la
// Fase 2. Ver bea-08.
@Component
public class ServerClock {

    private final Clock clock = Clock.systemUTC();

    public Instant now() {
        return Instant.now(clock);
    }
}
```

> ⚠️ **El reloj del servidor tampoco es la verdad absoluta, y conviene decirlo antes de apoyarse en él.** Es *un* reloj, el de un contenedor, sincronizado por NTP con la suerte que tenga el anfitrión. Lo que lo hace mejor que el del navegador no es que sea exacto: es que **es uno solo y tiene dueño**. Cuarenta operadores tienen cuarenta relojes y ninguno responde por el suyo. Esa es toda la ventaja, y alcanza.

### 5.3 El asiento del servidor

```java
package com.andina.labcore.audit;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;

// La bitácora en la sombra. Misma forma que el asiento del cliente para que
// las dos sean comparables campo a campo, con tres diferencias deliberadas.
@Document(collection = "auditLogServer")
public class ServerAuditEntry {

    // Aquí SÍ se usa el ObjectId como identificador y no hay legacyId: esta
    // colección no se expone en ninguna ruta, así que no tiene contrato que
    // respetar. Es la única del sistema que puede permitirse ser correcta.
    @Id
    private String id;

    // Diferencia 1: el instante, no una cadena. BSON Date, UTC, del reloj
    // del servidor. Comparable, ordenable, y sin depender de cómo se
    // formateó en el origen.
    private Instant timestamp;

    // Diferencia 2: el actor sale del token verificado, no de un campo del
    // cuerpo. Es el mismo nombre de usuario del frontend —analista1,
    // supervisor1— para que las dos bitácoras se puedan cruzar.
    private String actor;

    private String action;
    private String entityType;
    private String entityId;

    // Diferencia 3: el identificador de petición. Es lo que permite, ante
    // una escritura a medias, saber qué documentos venían del mismo hecho.
    // En be05 esto deja de ser una comodidad y pasa a ser la única prueba.
    private String requestId;

    private Object before;
    private Object after;

    // … getters y setters
}
```

### 5.4 La escritura, en el mismo camino que la mutación

```java
package com.andina.labcore.service;

// Fragmento del service de muestras. El asiento se escribe AQUÍ, dentro de
// la misma petición que hace la mutación, y no en un effect del navegador
// que puede no llegar nunca.
public Sample transition(Integer legacyId, String newStatus) {

    Sample sample = repository.findByLegacyId(legacyId);
    if (sample == null) {
        throw new NotFoundException("sample " + legacyId);
    }

    Sample before = copyOf(sample);
    sample.setStatus(newStatus);
    repository.save(sample);

    // El asiento, inmediatamente después. Actor del token, hora del
    // servidor, y el before de verdad — que el asiento del cliente no tiene
    // porque el payload de la acción *Success no lo lleva (Fase 11 §5.5).
    //
    // ⚠️ Y AQUÍ ESTÁ EL PROBLEMA DE be05, escrito para que se vea venir:
    // son DOS escrituras y no hay nada que las una. Si el proceso se cae
    // entre estas dos líneas, la muestra queda transicionada y el asiento no
    // existe. Es exactamente el mismo hueco que tenía el frontend, movido
    // veinte centímetros. NO SE ARREGLA HOY. Se anota y se mide.
    auditService.record("[Samples] Transition Sample Success",
                        "sample", String.valueOf(legacyId), before, sample);

    return sample;
}
```

**El patrón a memorizar:** mover una escritura del cliente al servidor **reduce** la ventana de fallo —de una red inestable y un navegador que se puede cerrar, a dos líneas contiguas del mismo proceso— pero no la cierra. Reducir una ventana es una mejora real y hay que saber contarla como lo que es: *"pasamos de perder asientos cuando el operador cierra el portátil a perderlos solo si el proceso se cae entre dos escrituras"*. Eso es honesto y es defendible. Decir "lo arreglamos" no lo sería.

### 5.5 `GET /auditLog` no cambia. Nada.

```java
// El endpoint que alimenta la timeline de la Fase 11 sigue leyendo de la
// colección del cliente y solo de ella. Ni un asiento del servidor se cuela.
//
// Es la línea más importante de la fase y no hace nada: es la que garantiza
// que el operador vea exactamente lo mismo que veía ayer. Si algún día la
// timeline mezcla las dos, el frontend habrá cambiado de comportamiento sin
// que nadie lo decidiera.
@GetMapping("/auditLog")
public List<Map<String, Object>> findAll() {
    return clientAuditRepository.findAllOrderByTimestamp();
}
```

### 5.6 Las tres mediciones de divergencia

Aquí está el entregable. Las tres agregaciones van a `MEASUREMENTS.md` con su número.

**Medición 1 — asientos que el navegador nunca envió.**

```javascript
// Por cada asiento del servidor, buscar el del cliente que corresponda:
// misma acción, misma entidad, y una hora que caiga en una ventana
// razonable. Los que no encuentran pareja son los que se perdieron.
//
// La ventana de dos minutos no es arbitraria y hay que declararla: tiene que
// ser mayor que el desfase de reloj típico y menor que el intervalo entre
// dos operaciones sobre la misma entidad. Con una ventana mal elegida, esta
// medición miente en las dos direcciones.
db.auditLogServer.aggregate([
  { $lookup: {
      from: 'auditLog',
      let: { a: '$action', e: '$entityId', t: '$timestamp' },
      pipeline: [
        { $match: { $expr: { $and: [
            { $eq: ['$action', '$$a'] },
            { $eq: ['$entityId', '$$e'] },
            { $lt: [ { $abs: { $subtract: [ { $toLong: { $toDate: '$timestamp' } },
                                            { $toLong: '$$t' } ] } }, 120000 ] }
        ]}}}
      ],
      as: 'delCliente'
  }},
  { $match: { delCliente: { $size: 0 } } },
  { $count: 'asientosQueElNavegadorNuncaEnvio' }
]);
```

**Medición 2 — actores que no coinciden.**

```javascript
// Los que SÍ encontraron pareja, pero con otro nombre. Cada uno de estos es
// un asiento firmado por quien no fue.
{ $match: { $expr: { $ne: ['$actor', { $arrayElemAt: ['$delCliente.actor', 0] }] } } },
{ $group: { _id: { servidor: '$actor', cliente: { $arrayElemAt: ['$delCliente.actor', 0] } },
            n: { $sum: 1 } } }
```

Una salida típica, y la fila que importa es la última:

```
{ "_id": { "servidor": "analista1", "cliente": "system"     }, "n": 46 }
{ "_id": { "servidor": "system",    "cliente": "analista1"  }, "n":  3 }
{ "_id": { "servidor": "supervisor1","cliente": "analista2" }, "n":  1 }
```

Los 46 primeros son benignos y tienen explicación: el navegador no tenía sesión activa —el token caducó— y escribió `"system"` mientras el servidor sí supo quién era. **La última fila no es benigna**: la bitácora dice que `analista2` validó algo que validó `supervisor1`. Un solo asiento. En un dominio regulado, un solo asiento así es el hallazgo.

**Medición 3 — el desfase de reloj.**

```javascript
// La diferencia, en segundos, entre la hora que puso el navegador y la que
// puso el servidor para el mismo hecho. El signo importa: negativo es un
// reloj atrasado, positivo es un asiento que dice haber ocurrido DESPUÉS de
// registrarse, y los que superan el par de segundos que tarda la red son
// relojes desincronizados y nada más.
{ $project: {
    actor: 1,
    desfaseSegundos: { $divide: [
        { $subtract: [ { $toLong: { $toDate: { $arrayElemAt: ['$delCliente.timestamp', 0] } } },
                       { $toLong: '$timestamp' } ] }, 1000 ] }
}},
{ $bucket: {
    groupBy: '$desfaseSegundos',
    boundaries: [-3600, -300, -60, -5, 5, 60, 300, 3600],
    default: 'fuera-de-rango',
    output: { asientos: { $sum: 1 } }
}}
```

```
{ "_id": -300,             "asientos":    2 }
{ "_id": -5,               "asientos": 1184 }   <- lo normal: latencia de red
{ "_id": 5,                "asientos":   17 }
{ "_id": 60,               "asientos":    9 }   <- más de un minuto adelantado
{ "_id": "fuera-de-rango", "asientos":    1 }   <- este
```

Ese último. Un solo asiento, fuera del rango de una hora. Es la pieza forense.

### 5.7 `AUDIT-DIVERGENCE.md` — el documento de la fase

Una página, con los tres números, la ventana declarada y **el alcance de lo que se puede afirmar**. Ese último punto es lo que separa una medición de una acusación:

````markdown
## Alcance de estas mediciones

- Cubren el periodo desde que el backend escribe su propia bitácora
  (10/09/2026) hasta hoy. **De todo lo anterior no se puede afirmar nada**:
  no hay con qué comparar. Ese hueco es el inventario que va a be08.
- La ventana de correlación es de 120 s, declarada en la medición 1. Con otra
  ventana, los tres números cambian.
- Un asiento sin pareja **no demuestra** que el navegador no lo envió: pudo
  enviarlo fuera de la ventana. Demuestra que no se pudo emparejar, que es
  una afirmación más débil y es la única que sostienen los datos.
````

> **Prueba de fuego.** Adelanta el reloj de tu máquina veinticinco minutos —solo el del sistema operativo, el servidor sigue en hora—, recarga la aplicación, y valida un resultado. Abre la timeline: el asiento aparece con una hora que todavía no ha llegado. Ahora mira `auditLogServer`: el mismo hecho, con la hora buena. Corre la medición 3 y confirma que ese asiento cae en `fuera-de-rango`. Devuelve la hora de tu máquina. **Eso es el incidente 17 del cuaderno base, reproducido a voluntad y explicado en tres minutos** — y ahí deja de sentirse injusto.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Síntoma: la aplicación cierra sesión sola cada dos minutos desde el despliegue.**
Causa: alguien puso el `401` ante el token expirado. Fix mínimo: revertir, y leer la decisión fechada del §4.2. Es el error que esta fase existe para que **no** cometas, y por eso el `catch` de expiración está separado del genérico.

**Síntoma: los asientos del servidor salen todos con `actor: "system"`.**
Causa: el `ActorFilter` está registrado después del dispatcher, o el token viaja y la firma no valida porque el secreto del filtro no es el mismo con el que `be03` firma. Fix mínimo: un `log.debug` con el resultado del parseo; si la excepción es de firma y no de expiración, es el secreto.

**Síntoma: un asiento aparece firmado por el operador anterior.**
Causa: falta el `RequestContext.clear()` en el `finally`. Fix mínimo: ponerlo. Y anótalo en el post-mortem con las palabras exactas, porque es lo mismo que pasó con el MDC en `be01` y la segunda vez ya no es mala suerte.

**Síntoma: la medición 1 da un número enorme y absurdo.**
Causa: se están comparando cadenas con `Instant`. El asiento del cliente guarda `timestamp` como cadena ISO y el del servidor como `BSON Date`; sin `$toDate`, la comparación no significa nada. Fix mínimo: el `$toDate` del §5.6. **Y mide siempre el `$type` de los dos campos antes de cruzarlos** — es la misma lección de `be02` §6, y va a volver a pasar.

**Síntoma: la timeline muestra asientos con formato raro.**
Causa: se colaron asientos del servidor en `GET /auditLog`. Fix mínimo: el §5.5. Es un cambio de comportamiento observable, o sea una rotura de contrato, aunque el JSON sea válido.

### Pieza forense de esta fase

**El asiento con el actor correcto y la hora del futuro.**

Del `$bucket` del §5.6 sale un asiento en `fuera-de-rango`. Esta es su historia completa, reconstruida solo con lo que hay en la base:

```
auditLog        (cliente)   timestamp: 2026-09-08T14:47:11.000Z   actor: analista1
auditLogServer  (servidor)  timestamp: 2026-09-08T13:22:04.881Z   actor: analista1
                            requestId: 7f3a9c02
```

Ochenta y cinco minutos de diferencia, mismo actor, mismo hecho. Las cuatro preguntas del método:

- **¿Qué se ve?** Un informe que, según la bitácora, se validó a las 14:47. El turno de `analista1` terminó a las 14:00. Alguien de Calidad lo notó.
- **¿Qué capa lo produce?** Ninguna del sistema. Lo produce **el reloj de una máquina**, y esa máquina no está en el diagrama de arquitectura.
- **🧬 ¿Lo escribió el sistema o llegó roto en el dato?** Llegó roto, y llegó **bien formado**: `"2026-09-08T14:47:11.000Z"` es un ISO 8601 impecable. Ninguna validación de formato lo habría rechazado, porque no hay nada que rechazar.
- **¿Con qué se demuestra?** Con el asiento del servidor al lado. Sin esta fase, no había con qué: la única hora que existía era la falsa, y la conversación con Calidad se resolvía preguntándole a `analista1` si se acordaba.

Y el remate, que es el que hay que escribir en el post-mortem:

> 🧠 **El incidente 17 del track base se siente injusto porque, desde el navegador, lo es: no hay ninguna prueba disponible que exculpe al operador.** Desde el servidor deja de serlo. No porque el sistema se haya arreglado —el asiento falso sigue ahí y va a seguir ahí— sino porque ahora hay **una segunda fuente** y la discrepancia se puede señalar. La trazabilidad no consiste en tener el dato correcto: consiste en poder demostrar cuál de los dos lo es.

🧨 **Rompe a propósito.** Con el sistema entero funcionando, apaga el contenedor de Mongo justo después de que una transición de muestra se haya guardado y antes de que se escriba su asiento. La forma fácil de conseguirlo: un `Thread.sleep(5000)` temporal entre las dos escrituras del §5.4 y un `docker compose stop db` en medio. Después, con la base arriba otra vez, busca la muestra: está transicionada. Busca su asiento: no existe. **Ni en la bitácora del cliente ni en la del servidor.** Anota lo que acabas de ver y guárdalo: es el punto de partida exacto de `be05`.

---

## 🧪 7. Ejercicios (29)

**🟢 Fácil (1–8)**

1. Implementa el `ActorFilter` y comprueba con `curl` que una petición con token válido resuelve el actor y una sin token resuelve `"system"`.
2. Manda un token con la firma manipulada —cambia un carácter del final— y confirma que el actor cae a `"system"` y **no** que la petición se rechaza.
3. Espera a que un token caduque (120 s) y comprueba que la petición sigue funcionando y que el actor se conserva. Anota qué `catch` se ejecutó.
4. Escribe la decisión del §4.2 en `CONTRACT.md` con su fecha, su razón y su condición de revisión. Es un entregable, no un comentario.
5. Implementa `ServerClock` y comprueba que el `timestamp` de un asiento del servidor se guarda como `BSON Date` y no como cadena. Verifícalo en `mongo` con `$type`.
6. Genera cinco mutaciones desde la aplicación y confirma que cada una dejó **dos** asientos: uno en `auditLog` y otro en `auditLogServer`.
7. Confirma que `GET /auditLog` devuelve exactamente los mismos campos que antes de esta fase, y que `smoke.sh` sigue entero en verde.
8. Cuenta los cuatro formatos de tiempo del §4.3 en tu propia base, con una consulta por cada uno.

**🟡 Intermedio (9–17)**

9. Escribe la medición 1 completa y anota el número en `MEASUREMENTS.md`, con la ventana declarada.
10. Repite la medición 1 con ventanas de 10 s, 120 s y 600 s. Anota los tres números y explica cuál elegirías y por qué. Esa justificación vale más que el número.
11. Escribe la medición 2 y produce la tabla de pares actor-servidor / actor-cliente. Explica cada fila.
12. Escribe la medición 3 con su `$bucket` y anota la distribución. Identifica cuál es el rango "sano" y por qué no está centrado en cero.
13. **Diagnóstico.** Provoca el caso de los 46 asientos benignos: deja caducar el token, haz una mutación sin recargar, y comprueba que el cliente escribe `"system"` mientras el servidor escribe tu usuario. Explica por qué el frontend no sabe quién es y el backend sí.
14. Redacta `AUDIT-DIVERGENCE.md` con los tres números y, sobre todo, con la sección de alcance del §5.7.
15. **Diagnóstico.** Quita el `RequestContext.clear()` y lanza peticiones concurrentes con dos tokens distintos. Cuenta cuántos asientos salen firmados por quien no fue. Vuelve a ponerlo.
16. Añade el `requestId` al asiento del servidor y comprueba que coincide con la cabecera `X-Request-Id` de la respuesta de esa misma petición.
17. **Diagnóstico.** Cruza `auditLogServer` con los `validatedBy` de la colección `results`. Cuenta cuántos resultados tienen un `validatedBy` que no coincide con el actor del asiento correspondiente. Ese cruce es el que un auditor haría primero.

**🟠 Difícil (18–24)**

18. Reproduce la prueba de fuego del reloj adelantado y captura los dos asientos. Documenta el caso entero en `AUDIT-DIVERGENCE.md` con las cuatro preguntas del método forense.
19. **Diagnóstico.** Adelanta el reloj **hacia atrás** veinte minutos y repite. Anota qué cambia en la timeline y por qué un asiento en el pasado es más difícil de detectar que uno en el futuro.
20. **Diagnóstico.** Con `CHAOS=fail=500@100` activo solo para la petición de auditoría —usa la cabecera `X-Chaos` desde la consola—, dispara una validación. La mutación ocurre, el asiento del cliente falla. Comprueba que el del servidor **sí** está. Escribe en dos líneas qué mejoró exactamente y qué no.
21. Mide el coste de la escritura del asiento: cronometra `PATCH /samples/:id` con y sin la escritura de auditoría, cien veces cada uno. Anota la mediana y decide si ese coste es aceptable. Es el tipo de número que `be08` va a necesitar.
22. **Diagnóstico + diseño.** Los asientos del servidor guardan el `before` de verdad y los del cliente lo guardan siempre en `null` (Fase 11 §5.5). Escribe la consulta que reconstruye el `before` de un asiento del cliente cruzando con el del servidor, y explica hasta dónde llega esa reconstrucción hacia atrás en el tiempo. La respuesta —"hasta el 10 de septiembre de 2026 y ni un día más"— es material de `be08`.
23. **Adversarial.** Escribe la petición que suplanta a otro usuario en la bitácora del cliente: un `POST /auditLog` con `actor: "supervisor1"` desde `curl`, sin token. Confirma que se acepta. Después comprueba qué escribió el servidor para esa misma petición. Documenta la diferencia — es el argumento de una página que `be08` va a usar.
24. **Diagnóstico.** Ejecuta el 🧨 de la sección 6 y documenta el estado inconsistente resultante: la muestra transicionada sin ningún asiento. Escribe qué consulta lo detectaría **después** del hecho, y cuánto tiempo tarda en correr sobre la colección entera.

**🔴 Muy difícil (25–29)**

25. **Diseño.** Propón tres formas de cerrar la ventana del §5.4 —el hueco entre la mutación y su asiento— sin tocar el frontend, con su costo y su riesgo. **No implementes ninguna.** Guarda el documento: `be05` va a demostrar que una de las tres es imposible en esta topología, y quieres tener escrita tu intuición de hoy para compararla.
26. **Adversarial.** Argumenta bien la posición contraria: *"la bitácora del cliente lleva cinco años sirviendo y ninguna auditoría la ha rechazado; escribir una segunda es duplicar el almacenamiento y el trabajo para resolver un problema hipotético"*. Dale sus mejores razones, incluida la de que hasta hoy no hay ni un solo hallazgo formal. Después refútala con la fila de la medición 2 que no es benigna, y con lo que un abogado diría de un registro que el propio interesado puede escribir.
27. **Diagnóstico y escritura.** Escribe el post-mortem de ocho puntos del incidente **be-07** —el informe validado a las 14:47 por alguien que salió a las 14:00— sin culpabilización, y con el detalle que lo hace enseñable: **la persona no hizo nada mal**. Incluye qué habría hecho falta para detectarlo antes y por qué nadie lo hizo.
28. **Diseño.** Con los tres números en la mano, escribe el correo de media página que le mandarías al responsable de Calidad. Tiene que decir qué se sabe, qué no se puede saber del periodo anterior, y qué se propone. Sin tecnicismos y sin minimizar. Es el ejercicio más difícil de la fase y el que más se parece a un lunes real.
29. **La medición que cierra la fase.** Añade a `MEASUREMENTS.md` la estimación del hueco histórico: cuántos asientos calculas que faltan en los cinco años anteriores, con qué método lo estimas y con qué margen de error. Es una extrapolación y hay que marcarla como tal en cada línea. `be08` la va a citar y tiene que poder defenderla.

**🔥 Opcionales**

- 🔥 Implementa un endpoint interno `GET /internal/audit-divergence` que devuelva las tres mediciones en vivo. No lo expongas al frontend ni lo metas en `smoke.sh`: es una herramienta de diagnóstico y quien la use tiene que saber lo que mira.
- 🔥 Escribe el asiento del servidor con `MongoTemplate` y `WriteConcern.MAJORITY` explícito. Sobre un standalone no cambia nada. Anota por qué no cambia nada y guarda la anotación: es el tema de `be05` y de `bea-07`.
- 🔥 Añade al asiento un campo `clockSkewMs` calculado en el servidor —la diferencia entre su reloj y el `timestamp` que llegó del cliente—. Con eso, la medición 3 deja de necesitar un cruce. Discute si vale la pena guardar un dato derivado para ahorrar una agregación.

---

## 📚 8. Referencias

**Documentación oficial**

- MongoDB 4.0 — tipo `Date` de BSON y lo que **no** guarda: https://www.mongodb.com/docs/v4.0/reference/bson-types/#date
- `$lookup` con `let` y `pipeline`, que es la forma correlacionada que usa la medición 1 y que **existe desde la 3.6**: https://www.mongodb.com/docs/v4.0/reference/operator/aggregation/lookup/#join-conditions-and-subqueries-on-a-joined-collection
- `$bucket`: https://www.mongodb.com/docs/v4.0/reference/operator/aggregation/bucket/
- jjwt 0.9.1 — `parseClaimsJws` y `ExpiredJwtException`, que es la que hace posible la decisión del §4.2: https://github.com/jwtk/jjwt/tree/0.9.1
- Java 8 — `Clock`, `Instant` y por qué inyectar el reloj: https://docs.oracle.com/javase/8/docs/api/java/time/Clock.html
- RFC 3339 / ISO 8601 — el formato que el navegador produce correctamente con un dato incorrecto: https://www.rfc-editor.org/rfc/rfc3339

**Libros y artículos de referencia**

- Martin Kleppmann, *Designing Data-Intensive Applications* (2017), capítulo 8, sección *Unreliable Clocks* — es la explicación completa de por qué un timestamp de cliente no es un dato de negocio. Doce páginas, y son las que hay que leer antes del ejercicio 27.
- Martin Fowler, *EventSourcing* y *Audit Trail*: https://martinfowler.com/eaaDev/EventSourcing.html — útil para ver qué habría cambiado si LabCore hubiera guardado los hechos en vez de los estados. No es una recomendación: es una comparación.
- ISO 15189 (laboratorios clínicos) y las guías de FDA 21 CFR Part 11 sobre registros electrónicos — no hace falta leerlas enteras; sí saber que existen y que su requisito central es exactamente el del §4.1: que el registro no lo pueda alterar el interesado.

**Video y apoyo**

- Charlas sobre *clock skew* y ordenación de eventos en sistemas distribuidos (2016-2021): https://www.youtube.com/results?search_query=clock+skew+distributed+systems — el problema de LabCore es el caso más simple posible del mismo fenómeno, con cuarenta relojes en vez de cuarenta nodos.

**Orden de lectura sugerido:** Kleppmann cap. 8 §*Unreliable Clocks* **antes** de escribir la medición 3 → `bea-08` mientras escribes el `ServerClock`, como referencia abierta → la página de `$lookup` correlacionado cuando la medición 1 te dé un número absurdo → las normas al final, solo para saber cómo se llama fuera de la ingeniería lo que acabas de medir.

> ⚠️ URLs y contenidos cambian. Con jjwt, además: la API cambió por completo en 0.10 y casi todo lo que encuentres describe la nueva. La tuya es la **0.9.1**.

---

## 🚀 9. Cierre y conexión con la siguiente fase

La identidad y el reloj ya están donde debían estar, y el frontend no se enteró. La bitácora vieja sigue viva, la nueva escribe en la sombra, y por primera vez en cinco años existe una forma de contestar con números la pregunta *"¿y esto quién lo hizo de verdad?"*.

Lo que esta fase enseña no es técnico y conviene decirlo en voz alta: **una deuda del frontend puede ser el síntoma de una frontera organizacional**. Nadie decidió que el navegador escribiera la auditoría porque le pareciera buena arquitectura. Lo decidió porque el otro equipo no estaba disponible, y esa restricción se convirtió, cinco años después, en una propiedad del sistema que nadie recordaba haber elegido. Cuando en tu trabajo veas una decisión técnica que no tiene sentido técnico, la pregunta correcta casi nunca es *"¿quién programó esto?"* sino *"¿quién no estaba en la reunión?"*.

Y queda una cosa abierta, a propósito, con el 🧨 de la sección 6 apuntándola: **la mutación y su asiento son dos escrituras y nada las une**. La solución que cualquiera propondría —una transacción— es exactamente lo que `be05` va a intentar. El intento es honesto y el servidor lo va a rechazar con un mensaje de error que enuncia la tesis del track entero. Esa fase es la insignia, y empieza donde esta termina.

> **La señal de que quedó bien:** *"la bitácora sigue diciendo lo que decía, pero ahora tengo una segunda que dice la verdad — y tengo el número exacto de veces que las dos no coinciden."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en verde y `git status` limpio:
>
> ```bash
> git tag -a be-fase-04-el-audit-log-que-escribia-el-navegador -m "be04 cerrada: actor desde token verificado sin exigir exp (decision fechada); reloj del servidor; bitacora en la sombra; GET /auditLog intacto; tres mediciones de divergencia en MEASUREMENTS.md; AUDIT-DIVERGENCE.md con su alcance"
> ```
>
> Los commits de la fase llevan su prefijo (`be04: …`) y los de ejercicio su número (`be04 ej18: …`). Todo eso está en [`00-convencion-de-git-y-tags.md`](./00-convencion-de-git-y-tags.md) §10.

---

## 📌 Pendientes sugeridos

- **[A] La decisión de firma sí / expiración no queda cerrada aquí**, fechada y con condición de revisión escrita en `CONTRACT.md`. Ninguna fase posterior la cambia sin resolver antes qué le pasa al operador cuando su sesión muera a los dos minutos.
- **[B] La ventana de correlación de 120 s** gobierna las tres mediciones. Si `be08` la cambia, los tres números cambian y hay que rehacerlos juntos, nunca por separado.
- **[C] `auditLogServer` no se expone en ninguna ruta y no tiene `legacyId`.** Es la única colección del sistema sin contrato que respetar. Si alguna fase necesita exponerla, tendrá que decidir su identidad primero.
- **[D] La ventana entre la mutación y su asiento** queda abierta a propósito, medida en el ejercicio 24 y **no cerrada**. Es el material de `be05` y adelantarlo destruye el hallazgo de esa fase.
- **[E] El `ThreadLocal` de `RequestContext`** es estado global y complica probar el service aislado. Declarado como 💸 y no pagado. Si `be08` decide una estrategia de pruebas que lo estorbe, se revisa ahí y no antes.
- **[F] La estimación del hueco histórico** (ejercicio 29) es una extrapolación y tiene que llegar a `be08` marcada como tal en cada línea. Un número estimado que se cita como medido es la forma más fácil de perder un argumento delante de un auditor.

### Reservas para el cuaderno de incidentes

| ID | Título propuesto | Categoría | Dificultad |
|---|---|---|---|
| **be-06** | *"La muestra que cambió de estado sin que nadie lo apuntara"* | Trazabilidad / escrituras no atómicas | 🟠 |
| **be-07** | *"El informe firmado a las 14:47 por alguien que salió a las 14:00"* | Relojes / evidencia | 🔴 |

**be-06** llega como *"la muestra 4021 está en `processed` y la timeline no muestra cuándo pasó"*. La causa es la ventana del §5.4: la mutación se escribió y el asiento no. Se resuelve a partir de esta fase, y el post-mortem tiene que terminar sin arreglo, con la frase que abre `be05`: *reducir una ventana no es cerrarla*.

**be-07** es el bueno, y es el incidente 17 del cuaderno base visto desde el servidor. Llega como una queja de Calidad, no como un ticket técnico. El post-mortem tiene que llegar a las dos conclusiones incómodas: que **el operador no hizo nada mal**, y que el sistema no puede distinguir un reloj desincronizado de una firma falsificada — porque los dos producen exactamente el mismo dato, bien formado.
