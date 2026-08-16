# 🅰️ Prompts iniciales por apéndice — Track BE 🔥
## Tutorial Angular 8 — Laboratorio clínico · Backend en Java 8 + Spring Boot 2.1 + MongoDB

Cada sección es el prompt completo del apéndice, listo para copiar al chat que lo
redacta. Los valores están rellenados con los de `propuesta-fases-backend.md` §8;
si alguna vez cambian allí, se cambian aquí después y **nunca al revés**.

Las horas de los apéndices **no cuentan** en ningún calendario: son consulta bajo
demanda, igual que `a01`-`a13` del track base.

---

## 🧱 Marco común a todos los apéndices del track BE

Este bloque va **al principio de cada prompt de abajo**; se repite a propósito
para que cada sección se pueda copiar sola.

```markdown
## Marco (no lo repitas, aplícalo)

Fuentes de verdad: `prompts/propuesta-fases-backend.md` §8 (manda sobre el
alcance de este apéndice), `prompts/alcance-del-proyecto.md`,
`prompts/guia-de-estilo-y-convenciones.md`, y la **plantilla de apéndice** de
`prompts/plantillas-de-capitulo.md`, que es deliberadamente laxa: encabezado,
índice de salto rápido, secciones cortas con ejemplo mínimo ejecutable, tabla de
"cuándo usar qué", advertencias si aplica, referencias y 5-10 ejercicios cortos.

Un apéndice **no se lee de corrido**: se entra por el índice buscando algo
concreto y se sale. Escríbelo pensando en alguien con el jefe mirando por encima
del hombro, no en alguien estudiando el domingo.

Reglas del track que no cambian: el frontend no se toca; código en inglés y
comentarios en español con tildes; nada de Java posterior al 8 salvo marcado 🔥;
**autocontención estricta** —este track no remite a ningún otro curso del
catálogo, ni siquiera al de contenedores—; y coherencia de la ficción de LabCore
(guía §11), con el backend fechado en 2019 y descrito en
`00-historia-del-sistema.md`.

El cierre lleva su bloque 🏷️ (guía §8.1) en la variante negativa que corresponde
a un apéndice: **sin tag propio**, porque el código que explica lo escriben las
fases, diciendo con qué prefijo se commitea lo que salga de leerlo (`beNN: …`, el
de la fase desde la que se llegó). Enlaza `00-convencion-de-git-y-tags.md`; no lo
reexpliques.

## Regla anti-solapamiento

Un apéndice **no repite lo que ya explica una fase: enlaza**. Antes de escribir,
dime qué partes de tu esquema crees que ya viven en las fases que lo usan y
propón si las enlazas o las reescribes desde otro ángulo. Si no tienes el
entregable de esa fase a la vista, pídemelo.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes. Devuélveme: (a) preguntas
bloqueantes, sobre todo **versiones exactas a cubrir** —nada de dar una versión
por buena de memoria; se toma de `propuesta-fases-backend.md` §5—; (b) el índice
de salto rápido que propones; (c) qué crees que ya está en las fases y cómo
piensas evitar repetirlo.
**Paso 2 — Redacción**, cuando yo responda.
**Paso 3 — Autoverificación** contra el checklist de §14 de la guía, en lista
corta.
```

---

## # Apéndice bea-01 — Java 8 y Spring para quien no escribe Java

```markdown
Este es el chat del **Apéndice bea-01 — Java 8 y Spring para quien no escribe
Java**, del track BE opcional 🔥 del tutorial Angular 8 + LabCore. Su único
entregable es `bea-01-java-8-y-spring-para-quien-no-escribe-java.md`.

[Pega aquí el Marco común del track BE]

## Identidad

- Apéndice bea-01 — Java 8 y Spring para quien no escribe Java
- Horas de referencia: **4h** (no cuentan en ningún calendario)
- Versiones cubiertas: Java 8 (`eclipse-temurin:8-jdk`), Spring Boot 2.1.x,
  Maven 3.8
- Usado por: **be01** principalmente, y de consulta en todas las demás
- Estado: Base

## Alcance

- **Qué problema resuelve (una línea):** que un senior de otro lenguaje pueda
  leer y escribir el backend de LabCore sin haber escrito Java nunca.
- **Secciones esperadas:** paquetes y el classpath; Maven y la anatomía del
  `pom.xml` (y por qué el árbol de dependencias es el problema, no la sintaxis);
  excepciones checked frente a unchecked, que es lo que más sorprende a quien
  viene de Go o de JavaScript; anotaciones como configuración; inyección de
  dependencias en Spring y los tres estereotipos (`@RestController`, `@Service`,
  `@Repository`); el ciclo de vida de un bean; **el modelo de un hilo por
  petición de Spring MVC**, que es la diferencia conceptual grande con Node y con
  Go; `Optional` y por qué en 2019 se usaba a medias; y cómo se lee un stack
  trace de Java, que es una habilidad en sí misma.
- **Qué queda explícitamente fuera:** Spring WebFlux y todo lo reactivo; Java 9+
  (módulos, `var`, `record`, text blocks) salvo como nota 🔥; Gradle; JPA e
  Hibernate —que no están en este stack y nombrarlos confunde—; y todo lo
  específico de Mongo, que vive en `bea-03`, `bea-04` y `bea-05`.
- **Advertencias obligatorias:** casi toda la documentación de Spring en línea
  asume Boot 3 y Java 17, donde `javax.*` pasó a ser `jakarta.*` y media
  anotación cambió de paquete. La referencia de este track es la de Boot 2.1, y
  hay que citarla con la versión en la URL.
- **Ejercicios:** 8-10 cortos, de consulta, contra el laboratorio propio.
```

---

## # Apéndice bea-02 — Receta de imagen y compose

```markdown
Este es el chat del **Apéndice bea-02 — Receta de imagen y compose**, del track
BE opcional 🔥 del tutorial Angular 8 + LabCore. Su único entregable es
`bea-02-receta-de-imagen-y-compose.md`.

[Pega aquí el Marco común del track BE]

## Identidad

- Apéndice bea-02 — Receta de imagen y compose
- Horas de referencia: **3h**
- Versiones cubiertas: `maven:3.8-eclipse-temurin-8`, `mongo:4.0` → `mongo:7.0`,
  `postgres:16.9` (solo para be08), Docker Compose v2
- Usado por: **be01**, **be07**, **be08**
- Estado: Base — **es el apéndice más delicado del track**

## Alcance

- **Qué problema resuelve (una línea):** levantar toda la pila con cuatro
  comandos, sin que el alumno instale un JDK, Maven, Mongo ni `mongosh`.
- ⚠️ **Autocontención absoluta.** Este es el único punto donde el track toca
  contenedores. Tiene que funcionar de principio a fin **sin remitir a ningún
  otro curso del catálogo**, ni siquiera para los contenedores. Si algo necesita
  explicación larga, se pone resuelto en el compose y se explica en dos líneas.
- **Secciones esperadas:** los cuatro comandos del arranque (`docker compose up
  -d`, `curl localhost:3000/health`, `docker compose logs -f api`, `docker
  compose down`); el `compose.yaml` completo y copiable, tal como está en
  `propuesta-fases-backend.md` §5.3; **el volumen `m2`** y por qué es lo que hace
  aceptable el ciclo de iteración —la primera vez tarda porque Maven baja el
  árbol, y a partir de ahí no—; **el `.env` con `MONGO_TAG`** y la nota de que la
  versión de la base vive fuera del código fuente, que es lo que hace posible la
  fase be07; publicar el 27017 bajo demanda para `mongosh`; y los tres errores
  que salen siempre.
- **Qué queda explícitamente fuera:** multi-stage y optimización de imagen —no
  hace falta, el laboratorio corre con la imagen de Maven directamente—;
  Kubernetes; y cualquier discusión de arquitectura de contenedores.
- **Advertencias obligatorias:** el JDK 8 para *macOS* aarch64 no existe; el de
  *Linux*/aarch64 sí, y como todo corre en contenedor es irrelevante. Dilo
  explícitamente, porque es la duda que todo el mundo tiene en un Mac.
- **Dato verificado que hay que citar con fecha:** todas las imágenes de la tabla
  de `propuesta-fases-backend.md` §5.2 corren arm64 nativo, comprobado el
  8/09/2026 sobre Docker Desktop 29.6.2. **Nada necesita emulación.**
- **Ejercicios:** 6-8 cortos.
```

---

## # Apéndice bea-03 — Modelar documentos: ¿embeber o referenciar?

```markdown
Este es el chat del **Apéndice bea-03 — Modelar documentos: ¿embeber o
referenciar?**, del track BE opcional 🔥 del tutorial Angular 8 + LabCore. Su
único entregable es `bea-03-modelar-documentos-embeber-o-referenciar.md`.

[Pega aquí el Marco común del track BE]

## Identidad

- Apéndice bea-03 — Modelar documentos: ¿embeber o referenciar?
- Horas de referencia: **3h**
- Versiones cubiertas: MongoDB 4.0 y 7.0, `spring-data-mongodb` 2.1
- Usado por: **be02**, **be03**, **be06**
- Estado: Base

## Alcance

- **Qué problema resuelve (una línea):** poner nombre y criterio a la decisión que
  el equipo de 2019 tomó cinco veces sin escribirla.
- **Secciones esperadas:** el criterio de acceso —se embebe lo que se lee junto y
  se escribe junto—; el límite de 16 MB por documento y qué pasa cuando se acerca;
  **los arreglos que crecen sin techo**, que es el error clásico y el que LabCore
  cometió con la cadena de custodia; la referencia manual y por qué Mongo no
  tiene claves foráneas; `$lookup` y qué cuesta de verdad; y la tabla de "cuándo
  usar qué" aplicada a las cinco entidades del dominio, con el veredicto de cada
  una y qué se pagó por la decisión de 2019.
- 📖 **Diccionario de traducción obligatorio**, en las dos direcciones: qué es una
  `JOIN` aquí, qué es una tabla de unión, qué le pasa a la tercera forma normal, y
  —al revés— cómo se le explica un documento embebido a alguien que piensa en
  tablas.
- **Qué queda explícitamente fuera:** sharding y todo lo de escala horizontal
  —LabCore es un `mongod` suelto y no va a dejar de serlo—; los índices, que son
  de `bea-05`; y las transacciones, que son de `bea-07`.
- **Ejercicios:** 8 cortos, todos sobre el modelo real del laboratorio.
```

---

## # Apéndice bea-04 — Agregaciones como instrumento de medida

```markdown
Este es el chat del **Apéndice bea-04 — Agregaciones como instrumento de
medida**, del track BE opcional 🔥 del tutorial Angular 8 + LabCore. Su único
entregable es `bea-04-agregaciones-como-instrumento-de-medida.md`.

[Pega aquí el Marco común del track BE]

## Identidad

- Apéndice bea-04 — Agregaciones como instrumento de medida
- Horas de referencia: **4h**
- Versiones cubiertas: MongoDB 4.0 (y las diferencias que trae 7.0)
- Usado por: **be02** sobre todo, **be05**, **be06**
- Estado: Base

## Alcance

- **Qué problema resuelve (una línea):** usar el framework de agregación para
  **auditar una colección**, no para servir pantallas.
- 🧭 **El ángulo del apéndice, que lo diferencia de cualquier tutorial de Mongo:**
  aquí las agregaciones no son la API de consulta del sistema. Son el
  instrumento con el que se descubre qué hay guardado de verdad. Si el apéndice
  se puede resumir como *"aquí se explica el aggregation framework"*, está mal
  escrito.
- **Secciones esperadas:** el pipeline y sus etapas básicas; **`$objectToArray`
  sobre `$$ROOT`** para inventariar las claves que existen de verdad, que es la
  técnica central del track; `$group` para contar formas distintas del mismo
  documento; `$type` para encontrar el campo que a veces es `String` y a veces
  `Number`; `$lookup` para encontrar referencias rotas; `$facet` para sacar varias
  mediciones en una pasada; y cómo se exporta el resultado a algo que se pueda
  pegar en un informe de auditoría.
- **Qué queda explícitamente fuera:** `$graphLookup`, ventanas, series
  temporales, y todo lo que llegó después de 4.0 salvo como nota 🔥 —el sistema de
  2019 no lo tenía—.
- **Advertencias obligatorias:** la documentación de MongoDB en línea es la de la
  versión actual y varias etapas cambiaron de comportamiento; cita siempre la URL
  con versión. Y el shell cambió: `mongo` hasta 4.4, `mongosh` desde 6.0.
- **Ejercicios:** 8-10, todos de medición sobre el dump sucio de be02.
```

---

## # Apéndice bea-05 — Índices y `explain()` en MongoDB

```markdown
Este es el chat del **Apéndice bea-05 — Índices y `explain()` en MongoDB**, del
track BE opcional 🔥 del tutorial Angular 8 + LabCore. Su único entregable es
`bea-05-indices-y-explain-en-mongodb.md`.

[Pega aquí el Marco común del track BE]

## Identidad

- Apéndice bea-05 — Índices y `explain()` en MongoDB
- Horas de referencia: **3h**
- Versiones cubiertas: MongoDB 4.0 y 7.0
- Usado por: **be02**, **be03**, **be05**
- Estado: Base

## Alcance

- **Qué problema resuelve (una línea):** saber si la consulta que el repository de
  Spring generó por ti usó un índice o barrió la colección entera.
- 🩻 **Sección "Esto sí funciona igual" obligatoria:** un índice sigue siendo un
  índice, la selectividad sigue mandando, y un `COLLSCAN` sigue siendo lo mismo
  que un *full table scan*. El lector viene de SQL: honra lo que ya sabe antes de
  contarle lo que cambia.
- **Secciones esperadas:** índices simples, compuestos y la **regla ESR**
  (igualdad, orden, rango) para ordenar sus campos; índices parciales y TTL;
  índices multiclave sobre arreglos y su trampa; cómo se lee un `explain()` y qué
  campos importan de verdad; **el `COLLSCAN` que el repository de Spring
  escondía**, que es el gancho del apéndice; y qué índices tiene LabCore de verdad
  contra los que debería tener.
- **Qué queda explícitamente fuera:** índices de texto y geoespaciales; perfilado
  continuo en producción; y el tuning fino, que en un sistema en decomisión no se
  hace.
- **Ejercicios:** 8 cortos, con medición antes y después en cada uno.
```

---

## # Apéndice bea-06 — `$jsonSchema` sobre datos sucios

```markdown
Este es el chat del **Apéndice bea-06 — `$jsonSchema` sobre datos sucios**, del
track BE opcional 🔥 del tutorial Angular 8 + LabCore. Su único entregable es
`bea-06-jsonschema-sobre-datos-sucios.md`.

[Pega aquí el Marco común del track BE]

## Identidad

- Apéndice bea-06 — `$jsonSchema` sobre datos sucios
- Horas de referencia: **3h**
- Versiones cubiertas: MongoDB 4.0 y 7.0
- Usado por: **be08**
- Estado: Base

## Alcance

- **Qué problema resuelve (una línea):** poner validación sobre una colección que
  lleva siete años sin ninguna, sin tumbar producción.
- 🧭 **El ángulo:** el problema no es escribir el esquema. Es que el 12% de los
  documentos que ya están guardados no lo cumplen, y el sistema tiene que seguir
  funcionando mañana.
- **Secciones esperadas:** la sintaxis mínima de `$jsonSchema`; `validationLevel`
  (`off` / `moderate` / `strict`) y `validationAction` (`warn` / `error`), que son
  dos ejes distintos y todo el mundo los confunde; **el procedimiento de subida
  por escalones** —medir cuánto rechazaría, decidir qué se tolera, subir a `warn`,
  observar los logs, y solo entonces `error`—; qué pasa con los documentos viejos
  cuando alguien los actualiza bajo `moderate`; y cómo se convive con excepciones
  declaradas.
- **Qué queda explícitamente fuera:** migrar o limpiar los datos sucios. En un
  sistema regulado lo roto no se sobrescribe: se compensa. Esa es la doctrina de
  be05 y aquí se respeta, se enlaza, y no se contradice.
- **Ejercicios:** 6-8, todos con el número de documentos rechazados como criterio
  de éxito.
```

---

## # Apéndice bea-07 — Transacciones, replica sets y el standalone

```markdown
Este es el chat del **Apéndice bea-07 — Transacciones, replica sets y el
standalone**, del track BE opcional 🔥 del tutorial Angular 8 + LabCore. Su único
entregable es `bea-07-transacciones-replica-sets-y-el-standalone.md`.

[Pega aquí el Marco común del track BE]

## Identidad

- Apéndice bea-07 — Transacciones, replica sets y el standalone
- Horas de referencia: **4h**
- Versiones cubiertas: MongoDB 4.0 (sin transacciones útiles aquí) y 7.0
- Usado por: **be05** ⭐
- Estado: Base — **es el apéndice que sostiene la fase insignia**

## Alcance

- **Qué problema resuelve (una línea):** entender exactamente qué garantía te da
  tu topología de despliegue, y qué haces cuando no te da la que necesitas.
- **El dato medido que abre el apéndice**, con su fecha (8/09/2026): sobre
  `mongo:4.0` standalone, con una operación real dentro de la transacción, el
  servidor responde `Transaction numbers are only allowed on a replica set member
  or mongos`, código 20.
- ⚠️ **Detalle de método obligatorio:** en el shell, `startTransaction()` es
  perezoso y no lanza nada; el rechazo llega en la primera operación de la sesión.
  Una prueba mal escrita da un falso "permitida". Escríbelo como advertencia
  destacada: es un error que ya se cometió al verificar el stack.
- **Secciones esperadas:** la escritura de un documento como unidad atómica, que
  es la garantía que sí tienes siempre; qué añaden las transacciones
  multi-documento y desde qué versión; **por qué exigen replica set** y qué cuesta
  convertir un standalone —con la nota de que en un sistema en decomisión ese
  coste casi nunca se paga—; `writeConcern` y `readConcern` en lenguaje llano;
  **la idempotencia como sustituto**, con el patrón de clave de operación; y **el
  asiento compensatorio**, que es contabilidad y es la salida que el track elige.
- 🪞 **Sección obligatoria "Tu instinto dice… y esta vez se equivoca":** el lector
  viene de `BEGIN … COMMIT`. Aquí la pregunta no es cómo abrir una transacción,
  es si tu despliegue te deja tener una.
- **Qué queda explícitamente fuera:** sharding y transacciones distribuidas;
  configurar un replica set paso a paso —se explica qué implica, no se monta—.
- **Ejercicios:** 8-10.
```

---

## # Apéndice bea-08 — Tiempo, zonas y fechas en Mongo

```markdown
Este es el chat del **Apéndice bea-08 — Tiempo, zonas y fechas en Mongo**, del
track BE opcional 🔥 del tutorial Angular 8 + LabCore. Su único entregable es
`bea-08-tiempo-zonas-y-fechas-en-mongo.md`.

[Pega aquí el Marco común del track BE]

## Identidad

- Apéndice bea-08 — Tiempo, zonas y fechas en Mongo
- Horas de referencia: **3h**
- Versiones cubiertas: MongoDB 4.0 y 7.0, Java 8 (`java.time`)
- Usado por: **be04**, **be06**
- Estado: Base

## Alcance

- **Qué problema resuelve (una línea):** que las fechas de LabCore signifiquen lo
  mismo en la base, en el servidor y en el navegador.
- **El anclaje al track base:** el `db.json` del curso guarda todas las fechas con
  offset explícito `-05:00`, nunca `Z` ni fecha desnuda, y la Fase 2 fijó
  `America/Bogota` como zona de la aplicación. El track base también declara que
  **las fechas se comparan con `Date` pelado** y que eso es correcto el 95% de los
  días. Este apéndice explica el 5% restante desde el servidor.
- **Secciones esperadas:** UTC como única verdad; **`BSON Date` y lo que no
  guarda** —no guarda zona, y eso sorprende a todo el mundo—; `java.time` en Java
  8 y por qué en 2019 medio código seguía con `java.util.Date`; la conversión en
  el borde y dónde ponerla; el reloj del cliente como fuente de bugs, que es
  literalmente el incidente 17 del cuaderno base; y el horario de verano, que en
  Colombia no aplica pero en los datos de un proveedor sí.
- **Qué queda explícitamente fuera:** librerías de tiempo de terceros —el track
  base declara que LabCore nunca adoptó ninguna, y contradecirlo rompería la
  ficción—.
- **Ejercicios:** 8 cortos, con al menos dos de diagnóstico sobre un asiento con
  hora imposible.
```

---

## # Apéndice bea-09 — Cassandra: la tentación y el acierto que nadie tuvo 🔴

```markdown
Este es el chat del **Apéndice bea-09 — Cassandra: la tentación y el acierto que
nadie tuvo**, del track BE opcional 🔥 del tutorial Angular 8 + LabCore. Su único
entregable es `bea-09-cassandra-la-tentacion-y-el-acierto-que-nadie-tuvo.md`.

[Pega aquí el Marco común del track BE]

## Identidad

- Apéndice bea-09 — Cassandra: la tentación y el acierto que nadie tuvo 🔴
- Horas de referencia: **4h**
- Versiones cubiertas: Apache Cassandra ⚠️ (fija la versión contra el registro,
  no de memoria)
- Usado por: **be05** (ejercicio 🔴 adversarial), **be08** (árbol de veredicto)
- Estado: Base — **es uno de los dos apéndices que impiden que el track sea un
  curso de Mongo**

## Alcance

- **Qué problema resuelve (una línea):** demostrar con números que la alternativa
  de moda es peor aquí, y admitir con la misma honestidad dónde sí era la
  respuesta.
- **Son dos mitades del mismo círculo, y las dos son obligatorias.**
  1. 🔴 **La tentación.** El nuevo arquitecto propone Cassandra "porque escala".
     Se modela contra el patrón de acceso real de LabCore —lecturas por paciente,
     por orden, por rango de fecha, con dos o tres claves de acceso distintas— y
     se **mide** que es peor, porque en Cassandra la tabla se diseña por consulta
     y aquí hay demasiadas consultas. El resultado no se argumenta: se mide.
  2. 📝 **El acierto que nadie tuvo.** Dónde Cassandra **sí** era la respuesta y
     nadie la usó: la telemetría del analizador, decenas de miles de lecturas por
     hora, serie temporal pura, escritura masiva, lectura por rango. Cierra el
     círculo — **no es que la tecnología fuera mala: estaba en el módulo
     equivocado.**
- 🧭 **La regla que el apéndice deja escrita, que es la tesis del repositorio:**
  el modelo de acceso manda sobre el producto. Cada familia gana en algún sitio.
- **Qué queda explícitamente fuera:** montar un clúster de Cassandra. El alumno no
  levanta nada; modela, compara y mide sobre el papel con el patrón de acceso
  documentado. Dilo explícitamente al principio para que nadie espere un
  laboratorio.
- **Nota para el registro, en dos párrafos:** RethinkDB. Era excelente, la
  decisión fue buena, la empresa cerró en 2016 ⚠️ y perdiste igual. *"Elegiste
  bien y perdiste igual"* es una lección de seniority que casi nadie enseña.
- **Ejercicios:** 6-8, todos de modelado y comparación, ninguno de instalación.
```

---

## # Apéndice bea-10 — Riesgo de licencia: SSPL y compañía

```markdown
Este es el chat del **Apéndice bea-10 — Riesgo de licencia: SSPL y compañía**,
del track BE opcional 🔥 del tutorial Angular 8 + LabCore. Su único entregable es
`bea-10-riesgo-de-licencia-sspl.md`.

[Pega aquí el Marco común del track BE]

## Identidad

- Apéndice bea-10 — Riesgo de licencia: SSPL y compañía
- Horas de referencia: **3h**
- Versiones cubiertas: no aplica — es un apéndice de contexto legal y de decisión
- Usado por: **be07**, **be08** (árbol de veredicto)
- Estado: Base — **es el otro apéndice que impide que el track sea un curso de
  Mongo**

## Alcance

- **Qué problema resuelve (una línea):** enseñar a leer una licencia **antes** de
  elegir un producto, y a reconocer una deuda técnica que ningún refactor arregla.
- 🧭 **La lección que no da ninguna otra pieza del track:** *tu deuda técnica la
  creó un abogado.*
- **Secciones esperadas:** el cambio de MongoDB a **SSPL** en 2018 ⚠️ y qué
  significa exactamente para una empresa que solo *usa* el producto —que es el
  caso de LabCore, y la respuesta corta es "casi nada", y hay que decirlo así de
  claro para no fabricar alarma—; el caso de **Elasticsearch**; el precedente de
  **Akka pasando de Apache 2.0 a BSL en septiembre de 2022** ⚠️, que es el más
  espectacular porque de un día para otro seguir actualizando costaba dinero;
  cómo se lee la licencia de una dependencia y dónde mirar; y qué preguntas hace
  un equipo antes de adoptar algo.
- **Todo lo de esta sección va marcado ⚠️ hasta que se verifique con fecha y
  fuente oficial.** Es material legal: citar de memoria aquí es peor que no
  citar. Pídeme las verificaciones que necesites en el paso 1.
- **Qué queda explícitamente fuera:** asesoría legal. El apéndice enseña a
  detectar el riesgo y a escalarlo, no a resolverlo. Dilo en el cierre con esas
  palabras.
- **Ejercicios:** 6 cortos, de lectura de licencias reales de dependencias del
  propio `pom.xml`.
```

---

## # Apéndice bea-11 — Mapa de deuda del track BE

```markdown
Este es el chat del **Apéndice bea-11 — Mapa de deuda del track BE**, del track
BE opcional 🔥 del tutorial Angular 8 + LabCore. Su único entregable es
`bea-11-mapa-de-deuda-del-track-be.md`.

[Pega aquí el Marco común del track BE]

## Identidad

- Apéndice bea-11 — Mapa de deuda del track BE
- Horas de referencia: **2h**
- Usado por: **be08**. ⚠️ **Corregido al escribirlo (10/09/2026):** este prompt decía "hermano de `a12-mapa-de-deuda-tecnica.md` del track base", y ese archivo **no existe en este curso** —`a12` es el de arm64/Apple Silicon y el track base no consolida su deuda en ningún apéndice—. El apéndice se escribió sin hermano y con la divergencia declarada dentro
- Estado: Base — **se escribe al final, cuando las nueve fases están cerradas**

## Alcance

- **Qué problema resuelve (una línea):** dejar por escrito qué quedó feo a
  propósito en el backend que el alumno acaba de construir, qué lo vuelve
  exigible, y en qué orden se pagaría.
- **Secciones esperadas:** el inventario completo de las 💸 declaradas en las nueve
  fases, cada una con la fase que la declaró y el motivo por el que no se paga; el
  criterio que las ordena —qué se paga primero si mañana hubiera presupuesto—; y
  las que **no se pagan nunca**, con su razón, que en un sistema con dos años de
  decomisión son la mayoría.
- **Regla de coherencia dura:** cada 💸 que aparezca aquí tiene que existir
  literalmente en alguna fase, y cada 💸 de las fases tiene que aparecer aquí.
  Si al escribirlo encuentras una que no cuadra, **no la inventes ni la borres**:
  dímelo, porque significa que una fase está mal.
- **Qué queda explícitamente fuera:** las deudas del track base, que se declaran
  con 💸 dentro de cada fase que las contrajo. No se repiten aquí. ⚠️ No hay un
  mapa consolidado del track base al que enlazar: ver la corrección de arriba.
- **Ejercicios:** 5-6, de priorización argumentada.
```

---

## # Apéndice bea-12 — Datos de prueba y volumen 🔥

```markdown
Este es el chat del **Apéndice bea-12 — Datos de prueba y volumen**, del track BE
opcional 🔥 del tutorial Angular 8 + LabCore. Su único entregable es
`bea-12-datos-de-prueba-y-volumen.md`.

[Pega aquí el Marco común del track BE]

## Identidad

- Apéndice bea-12 — Datos de prueba y volumen 🔥 (opcional dentro del track)
- Horas de referencia: **3h**
- Usado por: **be02**, **be05**
- Estado: Opcional 🔥

## Alcance

- **Qué problema resuelve (una línea):** conseguir volumen suficiente para que las
  mediciones del track digan algo, sin que los datos generados arruinen las
  pruebas.
- **Secciones esperadas:** la semilla desde el `db.json` del propio alumno, que es
  la fuente por defecto de todo el track; la generación del **dump sucio de be02**
  —cinco formas del documento de paciente, órdenes huérfanas— documentada para que
  sea reproducible; volumen sintético para que `be02` y `be05` midan sobre algo
  real; **datos deterministas con semilla fija**; y la sección que justifica el
  apéndice entero: **por qué un dataset aleatorio arruina una prueba de
  regresión**. El faker es una herramienta de carga y de medición, no de aserción.
- **Qué queda explícitamente fuera:** anonimización de datos reales de pacientes.
  Se nombra el problema —es un dominio regulado— y se remite al equipo de
  cumplimiento, sin dar receta.
- **Advertencia obligatoria:** los datos generados nunca entran a una colección que
  el `smoke.sh` audite. Si lo hacen, el contrato deja de ser verificable.
- **Ejercicios:** 6-8.
```

---

## 🧾 Recordatorio de cierre del track

✅ **El track BE está completo (10/09/2026):** nueve fases, doce apéndices y
`cuaderno-incidentes-be.md` con sus doce incidentes. Nada queda pendiente.

1. ~~**`cuaderno-incidentes-be.md`**~~ ✅ escrito, con los doce IDs `be-01` …
   `be-12` y la escala **6 🟠 · 6 🔴** declarada con su razón: no hay incidentes
   🟢 ni 🟡 porque para llegar aquí hay que haber cerrado once fases del track
   base y sus veintiún incidentes.
2. ~~**Las adiciones de encuadre de §10 de `propuesta-fases-backend.md`**~~
   ✅ hechas antes de `be00`.
