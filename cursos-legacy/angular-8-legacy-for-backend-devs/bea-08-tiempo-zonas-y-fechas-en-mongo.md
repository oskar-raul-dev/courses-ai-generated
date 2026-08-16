# 📎 Apéndice bea-08 — Tiempo, zonas y fechas en Mongo

> Tutorial Angular 8 — Laboratorio clínico · 🔥 Track BE · Consulta rápida · **3 horas**
> Usado por: be04, be06 · Versiones cubiertas: MongoDB 4.0 y 7.0, Java 8 (`java.time` y `java.util.Date`)

**Esto no se lee de corrido.** Se entra con una fecha que no cuadra —sale un día antes, sale en el futuro, un rango devuelve menos de lo que debería— y se sale sabiendo en cuál de las cuatro representaciones está el problema.

Resuelve una cosa: **que las fechas de LabCore signifiquen lo mismo en la base, en el servidor y en el navegador.**

**Qué queda fuera:** las librerías de tiempo de terceros. El track base declara que LabCore nunca adoptó ninguna —ni Moment, ni date-fns, ni Joda— y contradecirlo rompería la ficción. Aquí hay `Date` de JavaScript, `java.util.Date` y `java.time`, que es lo que hay de verdad.

---

## El anclaje: lo que ya decidió el track base

Antes de nada, lo que no se discute porque ya está decidido y funcionando:

- El `db.json` guarda **todas** las fechas con desplazamiento explícito: `"2019-09-02T08:15:00-05:00"`. Nunca `Z`, nunca fecha desnuda.
- La Fase 2 fijó **`America/Bogota`** como zona de la aplicación.
- Y el track base declara que **las fechas se comparan con `Date` pelado**, y que eso es correcto el 95 % de los días.

Este apéndice explica **el 5 % restante desde el servidor**, que es donde ese 5 % se convierte en un asiento de auditoría con hora imposible.

---

## Índice

- [1. Las cuatro representaciones que conviven](#1-las-cuatro-representaciones-que-conviven)
- [2. UTC como única verdad](#2-utc-como-única-verdad)
- [3. `BSON Date` y lo que **no** guarda](#3-bson-date-y-lo-que-no-guarda)
- [4. Comparar fechas: la trampa del orden de tipos](#4-comparar-fechas-la-trampa-del-orden-de-tipos)
- [5. Java 8: `java.time` y el `java.util.Date` de 2019](#5-java-8-javatime-y-el-javautildate-de-2019)
- [6. La conversión en el borde, y dónde ponerla](#6-la-conversión-en-el-borde-y-dónde-ponerla)
- [7. El reloj del cliente como fuente de bugs](#7-el-reloj-del-cliente-como-fuente-de-bugs)
- [8. Horario de verano: Colombia no, y aun así](#8-horario-de-verano-colombia-no-y-aun-así)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-8)

---

## 1. Las cuatro representaciones que conviven

En LabCore, hoy, el mismo instante puede estar guardado de cuatro formas distintas. Reconocerlas de un vistazo es la mitad del trabajo.

| # | Forma | Ejemplo | De dónde sale | ¿Tiene dueño? |
|---|---|---|---|---|
| 1 | **Cadena con desplazamiento** | `"2019-09-02T08:15:00-05:00"` | El `db.json` y el `seed.js` | — |
| 2 | **Cadena UTC (`Z`)** | `"2026-09-10T15:04:05.123Z"` | `new Date().toISOString()` del navegador | El reloj del operador |
| 3 | **`BSON Date`** | `ISODate("2026-09-10T15:04:05.123Z")` | Los 912 documentos de `be02`, y todo lo que escribe `be04` | El reloj del servidor |
| 4 | **Cadena de fecha suelta** | `"1984-03-12"` | `birthDate` de casi todos los pacientes | — |

Las dos primeras son **cadenas que parecen fechas**: no se comparan como fechas, no se ordenan como fechas y el motor no las entiende como fechas. La tercera es una fecha de verdad. Y la cuarta es un caso aparte que conviene tener claro:

> 🧠 **`birthDate` no es un instante: es una fecha de calendario.** El día que alguien nació es el mismo día esté donde esté, y convertirlo a un instante UTC le añade una hora que no existe. Guardarlo como `"1984-03-12"` —una cadena— **es correcto**, aunque duela mirarlo. Lo incorrecto es lo que pasó en 2021, cuando alguien convirtió 912 de ellos a `BSON Date` y ahora hay dos poblaciones que no se comparan entre sí.
>
> La regla general: *un instante* (cuándo pasó algo) va en `BSON Date`; *una fecha de calendario* (un cumpleaños, una fecha de vigencia normativa) puede ir como cadena `YYYY-MM-DD`, y **elegir una y documentarla vale más que elegir la mejor**.

---

## 2. UTC como única verdad

La regla, en tres líneas:

> 🧭 **Se guarda el instante en UTC. La zona horaria es una decisión de presentación y se aplica al pintar.** Nunca al guardar, nunca al comparar, nunca al agrupar sin decirlo.

Por qué esto no es purismo: una zona horaria es una función del tiempo —cambia por decreto, tiene historia, y la del año que viene todavía no se ha decidido—. Un instante no cambia nunca. Guardar el instante y aplicar la zona al final significa que **si mañana el gobierno cambia el huso, tus datos siguen siendo correctos**; guardar hora local significa que dejan de serlo retroactivamente.

Y el error que la gente comete creyendo que lo hace bien:

```javascript
// "Guardo el desplazamiento, así conservo la zona."
"2019-09-02T08:15:00-05:00"
```

No conservas la zona: conservas **el desplazamiento de aquel día**. Son cosas distintas. Con un país sin horario de verano —Colombia— coinciden, así que funciona. Con datos de un proveedor en un país que sí lo tiene, el mismo `-05:00` significa dos zonas distintas según el mes. Funciona **por suerte y no por diseño**, y saber que estás en ese caso es lo que hace que no te sorprenda el día que dejes de estarlo.

---

## 3. `BSON Date` y lo que **no** guarda

```
BSON Date = un entero de 64 bits con signo
          = milisegundos desde el 1 de enero de 1970, UTC
```

Y eso es todo. Lo que **no** guarda, que es lo que sorprende:

- ❌ **No guarda la zona horaria.** Ni la de origen, ni ninguna.
- ❌ **No guarda el desplazamiento.**
- ❌ **No distingue "fecha" de "instante".** Un `BSON Date` a medianoche es un instante, no un día.
- ❌ **No guarda precisión mayor que el milisegundo.**

> ⚠️ **Y la consecuencia que engaña a todo el mundo:** el shell **imprime** un `ISODate(...)` con una `Z` al final, y eso parece decir "está guardado en UTC". No: está guardado como un número, y la `Z` es cómo el shell decidió mostrártelo. Si tu cliente estuviera configurado en otra zona, el mismo dato se imprimiría distinto **sin que nada haya cambiado en la base**.

Cómo se pinta en una zona concreta, cuando de verdad hace falta:

```javascript
// $dateToString con timezone (desde MongoDB 3.6). Es la forma correcta de
// agrupar "por día en Bogotá": la conversión se hace en la agregación, no
// guardando hora local.
db.auditLog.aggregate([
  { $group: {
      _id: { $dateToString: { format: '%Y-%m-%d',
                              date: '$timestamp',
                              timezone: 'America/Bogota' } },
      asientos: { $sum: 1 }
  }},
  { $sort: { _id: 1 } }
]);
```

> 💡 **Ese `timezone` es la línea que separa un informe correcto de uno que reparte mal los asientos de la noche.** Sin él, `$dateToString` agrupa en UTC, y todo lo ocurrido entre las 19:00 y las 24:00 de Bogotá cae en el día siguiente. Cinco horas de cada día en la casilla equivocada, todos los días, sin ningún error.

---

## 4. Comparar fechas: la trampa del orden de tipos

Esta es la sección que explica el ejercicio 20 de `be02`, y es el fallo más silencioso de todo el track.

En BSON, **los tipos se ordenan entre sí antes de ordenarse dentro de cada tipo**. El orden relevante aquí es:

```
… < Números < Cadenas < Objetos < … < Fechas < …
```

O sea: **cualquier cadena es "menor" que cualquier fecha**, sin mirar su contenido. De ahí sale esto:

```javascript
// La colección tiene 3.908 birthDate como cadena y 912 como Date (be02 §5.4).

// Consulta 1: "nacidos después del 2000".
db.patients.find({ birthDate: { $gt: ISODate('2000-01-01') } });
// ← Solo puede devolver documentos de tipo Date. Los 3.908 de tipo cadena
//   quedan fuera ENTEROS, tengan la fecha que tengan.

// Consulta 2: la misma idea con una cadena.
db.patients.find({ birthDate: { $gt: '2000-01-01' } });
// ← Ahora solo los 3.908. Los 912 de tipo Date quedan fuera enteros.
```

**Ninguna de las dos falla. Las dos devuelven menos de lo que deberían.**

> 🧠 **Y por eso esta consulta es peor que una que falla.** Un error se arregla; un reporte que sale corto se firma. Alguien mira el número, le parece razonable, y lo manda. La única defensa es medir el `$type` de un campo **antes** de escribir un rango sobre él, siempre, y el pipeline está en [`bea-04`](./bea-04-agregaciones-como-instrumento-de-medida.md).

Lo mismo pasa al ordenar: un `sort({ birthDate: 1 })` sobre las dos poblaciones pone **todas** las cadenas antes que **todas** las fechas, aunque una cadena diga 2010 y una fecha diga 1950. El resultado se ve ordenado a trozos y nadie sospecha del tipo.

---

## 5. Java 8: `java.time` y el `java.util.Date` de 2019

Java 8 trajo `java.time` (2014) y es lo correcto. LabCore usa las dos cosas, y saber cuál estás mirando importa.

```java
// Lo correcto, y lo que usa el track a partir de be04:
Instant now = Instant.now();                         // un instante, UTC, sin zona
LocalDate birthDate = LocalDate.parse("1984-03-12"); // una fecha de calendario
ZonedDateTime inBogota = now.atZone(ZoneId.of("America/Bogota"));    // para pintar

// Lo de 2019, que sigue vivo en medio código:
java.util.Date date = new java.util.Date();
```

Las tres cosas que hay que saber de `java.util.Date` para leer el código viejo sin tropezar:

**Es mutable.** Un `Date` que pasas a otro método puede volver cambiado. Es la razón principal de que `java.time` sea inmutable de arriba abajo.

**No tiene zona, pero su `toString()` sí.** Y esta es la trampa de verdad:

```java
java.util.Date d = new java.util.Date(1757516645123L);
System.out.println(d);
// Imprime la hora en la zona POR DEFECTO DE LA JVM. En el contenedor, UTC.
// En el portátil de un desarrollador en Bogotá, cinco horas menos.
// El MISMO objeto, dos salidas distintas, y ninguna es "la fecha guardada".
```

> ⚠️ **Ese `toString()` es responsable de una cantidad desproporcionada de "en mi máquina sale bien".** Un log escrito con `Date` dice una hora en el contenedor y otra en el portátil de quien lo depura. Por eso `be04` guarda `Instant` y el `ServerClock` usa `Clock.systemUTC()` explícitamente: no porque el contenedor no esté en UTC —suele estarlo—, sino porque **depender del valor por defecto de la JVM es depender de algo que nadie declaró**.

```java
// Compruébalo en tu propia pila. Es el ejercicio 4.
System.out.println(TimeZone.getDefault().getID());
System.out.println(ZoneId.systemDefault());
```

Y el mapeo con Spring Data MongoDB 2.1, que es lo que decide qué acaba en la base:

| Tipo Java | Se guarda como | Nota |
|---|---|---|
| `java.util.Date` | `BSON Date` | Directo |
| `java.time.Instant` | `BSON Date` | Directo. **Es el que usa `be04`** |
| `java.time.LocalDate` | `BSON Date` a medianoche | ⚠️ Le inventa una hora. Ver abajo |
| `String` | `String` | Lo que hace el `birthDate` de casi todos |

> ⚠️ **`LocalDate` es la trampa sutil.** Se guarda como un instante a medianoche —y según la versión y los convertidores, en UTC o en la zona por defecto—. Un cumpleaños guardado así en un sistema configurado en `America/Bogota` y leído en UTC **sale un día antes**. Es el clásico "la fecha se mueve un día" y casi nunca se diagnostica a la primera. Para fechas de calendario, la cadena `YYYY-MM-DD` es más tonta y no miente.

---

## 6. La conversión en el borde, y dónde ponerla

La regla que evita el 90 % de los problemas de esta página:

> 🧭 **Convierte una sola vez, en el borde, y por dentro maneja siempre instantes.** Entra una cadena → se convierte a `Instant` en cuanto cruza la frontera. Sale un `Instant` → se formatea en la zona que corresponda justo antes de emitirlo. En el medio, **nunca** hay cadenas de fecha.

En LabCore, los tres bordes están identificados y conviene tenerlos en la cabeza:

| Borde | Qué entra | Qué se hace |
|---|---|---|
| **HTTP → servidor** | Cadenas del frontend (`Z` o `-05:00`) | Se convierten a `Instant` en el controller o en el service |
| **Servidor → Mongo** | `Instant` | Spring Data lo guarda como `BSON Date`. Nada que hacer |
| **Servidor → HTTP** | `Instant` | Jackson lo serializa. **Y aquí hay una decisión** |

```java
// La decisión del borde de salida, y en LabCore está tomada por el contrato:
// los campos de fecha que el frontend ya consume viajan EXACTAMENTE como
// viajaban con json-server. Cambiar el formato de salida "para mejorarlo" es
// romper el contrato, aunque el formato nuevo sea mejor.
//
// Los campos NUEVOS —los de auditLogServer, por ejemplo— no tienen esa
// restricción porque nadie los consume: ahí se usa ISO-8601 en UTC y punto.
```

> 💡 **Y el corolario incómodo de ese cuadro:** el `-05:00` del `db.json` **no se arregla**. Es lo que el frontend ha visto siempre, está en el régimen estricto de `CONTRACT.md`, y normalizarlo a `Z` cambiaría lo que la pantalla muestra. Se documenta, se convierte en el borde, y se sigue.

---

## 7. El reloj del cliente como fuente de bugs

Literalmente el incidente 17 del cuaderno base, y el `be-07` del cuaderno del track BE.

```javascript
// Lo que hace el AuditEffect del frontend (Fase 11):
const timestamp = new Date().toISOString();
```

Esa línea produce un ISO-8601 **impecablemente formado** a partir del reloj y la zona del sistema operativo del operador. Si el portátil tiene la hora adelantada veinte minutos, el resultado es un UTC perfecto y veinte minutos falso.

> 🧠 **El formato no valida el contenido.** Ninguna comprobación de esquema, ningún `$jsonSchema`, ninguna validación de Java habría rechazado ese asiento: es una cadena ISO válida que representa un instante que existe. Lo único que la delata es **tener otra fuente con la que compararla**, y eso es lo que `be04` construye.

Las tres formas en que un reloj de cliente miente, en orden de dificultad para detectarlas:

| Síntoma | Qué es | Cómo se detecta |
|---|---|---|
| Asiento en el **futuro** | Reloj adelantado | Fácil: comparar con el reloj del servidor |
| Asiento en el **pasado** | Reloj atrasado | Difícil: parece un evento antiguo legítimo |
| Asientos **desordenados** | Dos operadores con relojes distintos | Muy difícil: la secuencia es plausible |

Y la defensa, que no es técnica sino de diseño:

> 🧭 **El "cuándo" de un hecho de negocio lo pone el servidor. Siempre.** No porque su reloj sea exacto —es *un* reloj, sincronizado por NTP con la suerte que tenga—, sino porque **es uno solo y tiene dueño**. Cuarenta operadores tienen cuarenta relojes y ninguno responde por el suyo. Esa es toda la ventaja, y alcanza.
>
> Si por alguna razón hace falta conservar la hora del cliente —y a veces hace falta: es cuándo el operador *cree* que hizo algo—, se guarda **en un campo aparte y con otro nombre**, nunca en el mismo. `reportedAt` y `recordedAt` no son sinónimos y mezclarlos destruye la única información útil que tenía el par.

---

## 8. Horario de verano: Colombia no, y aun así

Colombia **no** tiene horario de verano. `America/Bogota` es UTC−05:00 todo el año, y por eso el `-05:00` del `db.json` funciona.

Con una nota histórica que parece trivia y no lo es: **Colombia sí lo tuvo una vez**, durante la crisis energética de 1992-1993. Si alguna fecha de tu sistema cae en esa ventana —y las fechas de nacimiento de los pacientes cubren décadas—, la base de datos de zonas horarias lo sabe y aplica el desplazamiento de entonces. Un cálculo de edad hecho con `java.time` y uno hecho restando cadenas pueden diferir en un día para alguien nacido en esos meses.

> 💡 Es un caso de una persona entre miles y no justifica ningún trabajo. Lo que sí justifica es la regla general: **nunca calcules un desplazamiento a mano.** `ZoneId.of("America/Bogota")` consulta la base de datos IANA, que tiene la historia completa de todos los cambios por decreto de todos los países. Restar cinco horas a mano es correcto hoy, para Colombia, y falso en general.

Dónde te muerde igual aunque tú no tengas horario de verano:

- **Datos de un proveedor extranjero** —un fabricante de analizadores con soporte en otra zona, un archivo de resultados externo—: sus marcas de tiempo sí cruzan cambios de horario.
- **Un contenedor con la zona mal puesta**: el proceso cree estar en otro sitio.
- **Una biblioteca con la base de zonas desactualizada**: los cambios de huso los deciden gobiernos, a veces con semanas de aviso, y una JVM vieja tiene la tabla de cuando se publicó.

---

## 🧭 Cuándo usar qué

| Situación | Qué usar |
|---|---|
| Cuándo ocurrió un hecho | `Instant` en Java, `BSON Date` en la base, **reloj del servidor** |
| Una fecha de calendario (cumpleaños, vigencia) | Cadena `YYYY-MM-DD`. Nunca `LocalDate` mapeado a `Date` |
| Pintarlo para un operador | `ZonedDateTime` con `America/Bogota`, **en el borde de salida** |
| Agrupar por día en un informe | `$dateToString` **con `timezone`** |
| Un campo que ya consume el frontend | Lo que el contrato diga. No se normaliza |
| La hora que dice el cliente | Campo aparte, con otro nombre. Nunca mezclada |
| Comparar un rango de fechas | **Mide el `$type` primero.** Siempre |
| Calcular un desplazamiento | `ZoneId`, nunca aritmética a mano |
| Un log | `Instant` formateado explícitamente, no `Date.toString()` |

---

## ⚠️ Advertencias

**El shell y los logs mienten sobre la zona, no sobre el dato.** Un `ISODate(...)` en pantalla y un `Date.toString()` en un log están aplicando una zona —la del cliente o la de la JVM— que nadie declaró. Antes de concluir que una fecha está mal guardada, comprueba en qué zona la estás mirando.

**El contenedor no tiene por qué estar en tu zona.** Las imágenes base suelen venir en UTC, así que el servidor piensa en UTC y el operador en Bogotá. Eso está bien y es lo que se quiere; lo que no se quiere es que **el código dependa** de cuál sea, y por eso `be04` fija `Clock.systemUTC()` en vez de confiar en el valor por defecto.

**Una cadena que parece una fecha no es una fecha.** No se compara, no se ordena y no se agrupa como tal. En una colección donde el mismo campo es cadena en unos documentos y `Date` en otros —que es el caso de `birthDate` en LabCore—, **toda consulta de rango devuelve una de las dos poblaciones y ninguna advertencia**.

**Y la de fondo: el `-05:00` del `db.json` se queda.** Es deuda declarada, está en el régimen estricto del contrato, y arreglarlo cambiaría lo que ve el usuario. Documentar por qué algo feo se queda vale más que arreglarlo mal.

---

## 📚 Referencias

- MongoDB — el tipo `Date` de BSON y lo que guarda: https://www.mongodb.com/docs/v4.0/reference/bson-types/#date
- Orden de comparación entre tipos BSON, que explica la trampa del §4: https://www.mongodb.com/docs/v4.0/reference/bson-type-comparison-order/
- `$dateToString` y su opción `timezone`: https://www.mongodb.com/docs/v4.0/reference/operator/aggregation/dateToString/
- Operadores de fecha de la agregación (`$year`, `$dayOfYear`, `$dateFromString`…), todos con `timezone`: https://www.mongodb.com/docs/v4.0/reference/operator/aggregation-date/
- Java 8 — el paquete `java.time`, con la distinción entre `Instant`, `LocalDate` y `ZonedDateTime`: https://docs.oracle.com/javase/8/docs/api/java/time/package-summary.html
- Java 8 — `Clock`, y por qué inyectarlo: https://docs.oracle.com/javase/8/docs/api/java/time/Clock.html
- Spring Data MongoDB 2.1 — conversores de `java.time`: https://docs.spring.io/spring-data/mongodb/docs/2.1.x/reference/html/#mapping-conversion
- La base de datos de zonas horarias de IANA, que es de donde sale la historia completa de los husos: https://www.iana.org/time-zones
- RFC 3339, el formato que el navegador produce correctamente con un dato incorrecto: https://www.rfc-editor.org/rfc/rfc3339
- Martin Kleppmann, *Designing Data-Intensive Applications* (2017), capítulo 8 §*Unreliable Clocks* — doce páginas y la explicación completa de por qué un timestamp de cliente no es un dato de negocio.

> ⚠️ URLs y contenidos cambian; verifícalos. Y con las zonas horarias, además, **cambia el dato**: los husos los deciden gobiernos y la tabla de tu JVM es la del día que se publicó.

---

## 🧪 Ejercicios (8)

1. Busca en tu volcado un documento de cada una de las cuatro representaciones del §1 e imprímelas juntas. Anota cuál es cuál sin mirar la tabla.
2. Guarda un `Instant` desde el servidor y léelo en el shell. Después cambia la zona de tu cliente y vuelve a leerlo. Anota que el dato no cambió y la salida sí.
3. Escribe el `$dateToString` que agrupa asientos por día **en Bogotá** y el mismo sin `timezone`. Compara los dos resultados y cuenta cuántos asientos cambian de día.
4. Imprime `TimeZone.getDefault()` dentro del contenedor y en tu máquina. Anota los dos valores y explica qué habría pasado si el código dependiera de ese valor.
5. **Diagnóstico.** Reproduce la trampa del §4: escribe la consulta "nacidos después del 2000" de las dos formas y anota los dos recuentos. Después calcula a mano cuál debería ser el número real y explica la diferencia con el orden de tipos BSON.
6. **Diagnóstico.** Adelanta el reloj de tu máquina veinticinco minutos, valida un resultado desde la aplicación, y compara el asiento del cliente con el del servidor. Después atrásalo veinte minutos y repite. Anota cuál de los dos casos te costó más detectar y por qué.
7. Guarda una fecha de nacimiento como `LocalDate` a través de Spring Data y mírala en la base. Anota qué hora le inventó y en qué zona. Después decide, con argumentos, si `birthDate` debería seguir siendo una cadena.
8. Toma el asiento con hora imposible del ejercicio 6 y escribe la consulta que lo encontraría **sin** tener el asiento del servidor al lado: solo con el propio `auditLog` del cliente. Anota qué se puede detectar así y qué no — la respuesta es la mitad del valor de `be04`.

---

> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida y el código que explica lo escriben **be04** y **be06**, así que lo que salga de leerlo se commitea con el prefijo de la fase desde la que llegaste (`be04: …`, `be06: …`). Los números del ejercicio 3 y del 5 sí merecen conservarse: van en `MEASUREMENTS.md`, porque son del tipo que un informe cita. La convención completa está en [`00-convencion-de-git-y-tags.md`](./00-convencion-de-git-y-tags.md) §10.
