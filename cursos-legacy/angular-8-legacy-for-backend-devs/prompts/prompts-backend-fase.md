# 🅰️ Prompts iniciales por fase — Track BE 🔥
## Tutorial Angular 8 — Laboratorio clínico · Backend en Java 8 + Spring Boot 2.1 + MongoDB

Cada sección es el prompt completo de la fase, listo para copiar al chat que la
redacta. Los valores están rellenados con los de `propuesta-fases-backend.md` §5,
§6 y §7; si alguna vez cambian allí, se cambian aquí después y **nunca al revés**.

**Un chat, un archivo.** Si un chat no produce entregable, o sobra o se salió de
alcance.

> ⚠️ **Antes del primer chat del track.** Sube al Project Knowledge, además de los
> documentos del track base, **`prompts/propuesta-fases-backend.md`**. Sin él
> ninguna fase BE puede justificar qué deuda cobra, y esa justificación es el
> criterio que decide qué entra en cada fase.

> 📝 **Adaptación declarada respecto de `prompts-extendidos-fases.md`.** Los
> prompts del track base repiten íntegro el protocolo de tres pasos en cada
> bloque. Aquí va **comprimido a seis líneas** al final de cada prompt, por una
> razón práctica: nueve fases con el protocolo completo hacen un archivo que nadie
> relee. El protocolo no cambia —preguntas antes de escribir, redacción,
> autoverificación contra §14 de la guía—; solo se enuncia más corto. La versión
> larga vive en `prompts-extendidos-fases.md` y sigue siendo la referencia.

---

## # Fase be00 — El contrato: auditoría del mock

```markdown
Este es el chat de la **Fase be00 — 📜 El contrato: auditoría del mock**, del
track BE opcional 🔥 del tutorial Angular 8 + LabCore. Su único entregable es
`be00-el-contrato-auditoria-del-mock.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad, en este orden: (1) `prompts/propuesta-fases-backend.md`,
(2) `prompts/alcance-del-proyecto.md`, (3)
`prompts/guia-de-estilo-y-convenciones.md` incluida su sección del track BE,
(4) `prompts/plantillas-de-capitulo.md`, (5) `00-historia-del-sistema.md`
—en particular la sección "La otra mitad del sistema — el backend"—, (6) las
fases 0-11 del track base ya escritas y aprobadas, (7) decisiones de este chat.
`_deprecado-tutorial-angular8.md` **no cuenta**.

La plantilla de fase (9 secciones, bloque 🏷️ del cierre, bloque 📌 de autoría)
se sigue literal, sin secciones extra ni reordenadas.

Reglas del track que no se negocian:
- **El frontend NO SE TOCA.** Ni un componente, ni un slice de NgRx, ni un
  effect, ni el interceptor, ni `environment.apiUrl`. El backend se adapta al
  contrato existente, nunca al revés.
- **Código en inglés, comentarios en español con tildes.** También en Java:
  paquetes, clases, campos, nombres de colección y de campo BSON.
- **Nada de Java moderno gratuito.** Sin `var`, sin `record`, sin `List.of`,
  sin text blocks, sin reactive. Lo posterior a Java 8 va marcado 🔥 como
  comparación.
- **Mongo no es el villano.** Una parte del dominio de un laboratorio sí es
  documental: un hemograma y un perfil lipídico no comparten forma. El equipo
  de 2019 acertó en eso y generalizó desde ahí. Guía del repositorio: cada
  familia gana en algún sitio.
- **El cierre lleva el bloque 🏷️**, con el namespace propio del track:
  `be-fase-00-el-contrato-auditoria-del-mock`, prefijo de commit `be00:`.

## Identidad de esta fase

- Fase be00 de be08 — 📜 El contrato: auditoría del mock
- Horas: **6h**
- Depende de: **Fase 11 del track base terminada** (`fase-11-trazabilidad-audit-log`)
- Habilita: be01
- Apéndices de apoyo: ninguno todavía
- Incidentes reservados: ninguno
- Estado: **Opcional 🔥** — no ocupa calendario del track base

## Alcance

- **Propósito (una línea):** Saber exactamente qué promete el servidor que se va
  a apagar, antes de escribir una línea de Java.
- **Qué entra:** capturar el tráfico real con la pestaña Network recorriendo las
  fases 5 a 11 del track base —**capturarlo, no leer el código del mock**—;
  inventariar las cinco colecciones (`patients`, `orders`, `samples`, `results`,
  `referenceRanges`) y el `POST /login`; documentar el dialecto de json-server
  que el frontend consume de verdad (`?patientId=1`, el 404 con cuerpo vacío, el
  `id` entero autoincremental, el objeto creado que devuelve el POST); los cinco
  modos del inyector de caos con sus dos vías de activación (variable `CHAOS` y
  header); y la separación entre régimen estricto —lo que no puede cambiar— y
  régimen de crecimiento —lo que el backend puede añadir sin romper nada—.
- **Qué NO entra:** una sola línea de Java. Esta fase audita y documenta.
- **Entregables dentro del entregable:** `CONTRACT.md` y `smoke.sh` ejecutable,
  que a partir de aquí es el juez de todas las fases.
- **Aquí se cuenta de dónde salió el backend**, apoyándote en la sección nueva de
  `00-historia-del-sistema.md`: lo escribió otro frente del equipo contratado de
  2019, quedó congelado y sin dueño, y ahora lo heredaste tú.
- **Y aquí va la defensa de Mongo**, antes de la primera factura. Si el track
  presenta la decisión de 2019 como una estupidez, el alumno no aprende nada.
- **Pieza forense:** dos peticiones que el alumno juraría que son iguales y que
  difieren en un header o en el orden de los parámetros. El contrato no es lo que
  uno recuerda.
- **Deuda del track base que cobra:** ninguna todavía. Prepara el terreno para
  cobrarlas todas.
- **Ejercicios:** 25-28, con al menos un tercio de diagnóstico, todos anclados al
  dominio del laboratorio.

## Pendientes que pueden bloquear esta fase

- Nada bloqueante: el stack está cerrado y medido en `propuesta-fases-backend.md`
  §5, con fecha de verificación.
- Decide y déjalo escrito: el formato exacto de `CONTRACT.md`. Propongo una tabla
  por recurso con método, ruta, parámetros aceptados, forma de la respuesta y
  códigos de error observados.

## Audiencia

Dev backend senior que ya terminó once fases de Angular de este mismo curso.
**No** le expliques qué es HTTP, un contrato de API, CORS ni un JWT. Sí explícale
qué tiene de particular auditar un contrato que nadie escribió.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes. Devuélveme: (a) preguntas
bloqueantes numeradas, marcando cuáles puedes asumir con un valor por defecto;
(b) tu lectura del alcance y si las 6h cuadran; (c) un esbozo de la sección 5;
(d) cualquier contradicción con el track base — dímela, no la resuelvas.
**Paso 2 — Redacción**, cuando yo responda. Si aparece una duda nueva, **para y
pregunta** en vez de rellenar con un supuesto plausible.
**Paso 3 — Autoverificación** contra el checklist de §14 de la guía de estilo,
reportada en lista corta. Presta atención especial a: el frontend intacto, cada
💸 con su fase de cobro declarada, y la defensa de Mongo presente.
```

---

## # Fase be01 — Java 8, Spring Boot 2.1 y la forma del monolito

```markdown
Este es el chat de la **Fase be01 — ☕ Java 8, Spring Boot 2.1 y la forma del
monolito**, del track BE opcional 🔥 del tutorial Angular 8 + LabCore. Su único
entregable es `be01-java-spring-y-la-forma-del-monolito.md`.

## Marco (no lo repitas, aplícalo)

El mismo de be00: `propuesta-fases-backend.md` manda, la plantilla de 9 secciones
se sigue literal, el frontend no se toca, código en inglés y comentarios en
español, nada de Java posterior al 8 salvo marcado 🔥, y el bloque 🏷️ del cierre
con `be-fase-01-…` y prefijo `be01:`. Añade a las fuentes: **be00 ya cerrada y
aprobada**, y su `CONTRACT.md`.

## Identidad de esta fase

- Fase be01 de be08 — ☕ Java 8, Spring Boot 2.1 y la forma del monolito
- Horas: **8h**
- Depende de: be00 — el contrato ya está auditado y escrito
- Habilita: be02
- Apéndices de apoyo: **bea-01** (Java y Spring para quien no escribe Java),
  **bea-02** (receta de imagen y compose)
- Incidentes reservados: **be-01**
- Estado: Opcional 🔥

## Alcance

- **Propósito (una línea):** Levantar el monolito de 2019 y dejarlo respondiendo
  en el puerto 3000, con el caos reimplementado y sin tocar la base todavía.
- **Qué entra:** el `pom.xml` y el layout en `server/`; `@RestController`,
  `@Service` y `@Repository` con la arquitectura en capas; la cadena de filtros
  (CORS hacia el 4200, logging, `X-Request-Id`, manejo de excepciones con
  `@ControllerAdvice`); el apagado ordenado; `GET /health` como primer endpoint
  vivo; y la **reimplementación del inyector de caos** con los cinco modos
  idénticos a los del mock, apagado por defecto, con la variable `CHAOS` y el
  header. La regla de precedencia —gana la última orden recibida, y el arranque
  cuenta como orden— se escribe aquí.
- **Qué NO entra (se difiere a be03):** cualquier acceso a MongoDB. Esta fase
  sirve datos fijos o en memoria.
- **Prueba de fuego de la fase:** el alumno tiene que poder repetir el ejercicio
  3 de la Fase 4 del track base —`CHAOS=latency=3000`, spinner de tres segundos
  medido en Network— contra el backend nuevo. Si no puede, la fase está mal.
- **Pieza forense:** una excepción no capturada dentro de un controller. Sin
  `@ControllerAdvice`, Spring devuelve su página de error por defecto **con el
  stack trace adentro** — y en un sistema clínico eso es un hallazgo de
  auditoría, no una molestia.
- **Deuda del track base que cobra:** ninguna directamente; monta el andamiaje
  que permite cobrarlas.
- **Ejercicios:** 28-30.

## Pendientes que pueden bloquear esta fase

- 🪦 **Cerrado (10/09/2026): `2.1.18.RELEASE`**, última de la línea 2.1, del
  29/10/2020, EOL el 1/11/2020. Su BOM fija Spring 5.1.19, Spring Data
  Lovelace-SR21, Jackson 2.9.10.20200824, Tomcat 9.0.39, JUnit 4.12 y el driver
  `mongodb` **3.8.2** — que es el dato que `be07` necesita. Ver §5.5 de la
  propuesta. No hay pendientes bloqueantes en esta fase.

## Audiencia

Dev backend senior que **puede no haber escrito Java nunca**. No le expliques qué
es una clase, la inyección de dependencias ni un middleware. Sí explícale lo que
Java y Spring hacen distinto: las excepciones checked, el classpath, las
anotaciones como configuración, y el modelo de un hilo por petición de Spring MVC
—que es la diferencia conceptual con Node y con Go—. Toda la sintaxis se delega a
`bea-01`: enlaza, no reexpliques.

## Cómo quiero que trabajes

Protocolo de tres pasos: (1) preguntas bloqueantes numeradas, lectura del alcance
con las 8h, esbozo de la sección 5 y contradicciones detectadas — **sin redactar
todavía**; (2) redacción cuando yo responda, parando a preguntar si aparece una
duda nueva; (3) autoverificación contra §14 de la guía, en lista corta. Vigila
especialmente que el caos quede con paridad exacta con el del mock.
```

---

## # Fase be02 — Lo que hay de verdad guardado: medir la deriva

```markdown
Este es el chat de la **Fase be02 — 🔬 Lo que hay de verdad guardado: medir la
deriva**, del track BE opcional 🔥 del tutorial Angular 8 + LabCore. Su único
entregable es `be02-medir-la-deriva-de-esquema.md`.

## Marco (no lo repitas, aplícalo)

El mismo de be00 y be01. Añade a las fuentes: **be01 ya cerrada**. Bloque 🏷️ con
`be-fase-02-…` y prefijo `be02:`.

## Identidad de esta fase

- Fase be02 de be08 — 🔬 Lo que hay de verdad guardado: medir la deriva
- Horas: **10h**
- Depende de: be01
- Habilita: be03
- Apéndices de apoyo: **bea-04** (agregaciones como instrumento de medida),
  **bea-05** (índices y `explain`), **bea-03** (embeber o referenciar),
  **bea-12** (datos de prueba y volumen — de ahí sale el dump sintético)
- Incidentes reservados: **be-02**, **be-03**
- Estado: Opcional 🔥

## Alcance

- **Propósito (una línea):** Descubrir, midiendo y no suponiendo, que el modelo
  Java describe un sistema que no existe.
- **Esta es la fase que cambia el ánimo del track, y la primera que no construye
  nada.** Hasta aquí el alumno escribió `@Document class Patient` con cinco
  campos tipados y todo parecía JPA. Ahora se le entrega un dump de la colección
  real de producción y se le pide que **cuente cuántas formas distintas del
  documento de paciente existen**. Son cinco, y ninguna la dice el modelo Java.
- **Qué entra:** el framework de agregación **como instrumento de medida, no como
  API** — `$objectToArray` sobre `$$ROOT` para inventariar claves, `$group` para
  contar formas, `$type` para encontrar el campo que a veces es `String` y a
  veces `Number`—; la búsqueda de referencias rotas con `$lookup` (órdenes que
  apuntan a pacientes que ya no están); y la conversación incómoda sobre por qué
  el repository de Spring **devolvió objetos perfectamente válidos** sobre datos
  que no lo son.
- **Qué NO entra:** arreglar nada. Esta fase mide. La contención es be08.
- **Secciones narrativas obligatorias:** 🪞 *"Tu instinto relacional dice «el
  esquema está en la base»… y esta vez se equivoca"* — el esquema está en el
  código Java, en el código Java **anterior**, y en el script de importación que
  alguien corrió una vez en 2020; los tres siguen vigentes al mismo tiempo.
  Y 🩻 *"Esto sí funciona igual"*: un índice sigue siendo un índice, y
  `explain()` sigue diciéndote si lo usaste.
- **Pieza forense:** el `null` que en Java llega como `null` y en la base es tres
  cosas distintas — campo ausente, campo con valor `null`, y campo con string
  vacío. Nómbralo explícitamente como la misma conversación que `strict: true`
  tiene en el frontend, vista desde el otro lado.
- **Deuda que cobra:** la deriva de esquema y la integridad referencial que nadie
  tenía. Ninguna de las dos se ve desde el navegador.
- **Ejercicios:** 30-35. Es una de las fases densas: aquí caben ejercicios de
  medición pura, que son los mejores del track.

## Pendientes que pueden bloquear esta fase

- 🪦 **Cerrado al escribir la fase (10/09/2026).** El dump es de 4.820 pacientes
  en cinco formas fechadas, 37 órdenes huérfanas, `birthDate` partido 3908/912
  entre `string` y `date`, y `email` en tres poblaciones (1630 ausente / 912
  `null` / 247 cadena vacía). Está en `be02` §5.3 y replicado en §11 de la
  propuesta. Generador determinista en `bea-12`; el dump vive en **una base
  aparte** de la semilla del alumno.

## Audiencia

Dev backend senior con reflejo relacional intacto. Esta fase existe para
romperle ese reflejo con números, no con argumentos.

## Cómo quiero que trabajes

Protocolo de tres pasos, igual que en be01. En el paso 1 quiero además **las
agregaciones concretas** que vas a usar, escritas, antes de redactar: son el
corazón de la fase y si están mal, la fase no enseña nada.
```

---

## # Fase be03 — La costura: de `db.json` a Mongo, y el reemplazo

```markdown
Este es el chat de la **Fase be03 — 🗄️ La costura: de `db.json` a Mongo, y el
reemplazo**, del track BE opcional 🔥 del tutorial Angular 8 + LabCore. Su único
entregable es `be03-la-costura-y-el-reemplazo.md`.

## Marco (no lo repitas, aplícalo)

El mismo del track. Añade: **be02 ya cerrada**. Bloque 🏷️ con `be-fase-03-…` y
prefijo `be03:`.

## Identidad de esta fase

- Fase be03 de be08 — 🗄️ La costura: de `db.json` a Mongo, y el reemplazo
- Horas: **10h**
- Depende de: be02
- Habilita: be04
- Apéndices de apoyo: **bea-03**, **bea-05**
- Incidentes reservados: **be-04**, **be-05**
- Estado: Opcional 🔥

## Alcance

- **Propósito (una línea):** Apagar el mock y que la aplicación no se entere.
- **Es la bisagra del track.** La señal de éxito se enuncia en una línea y se
  verifica: *"apagué `npm run mock`, levanté el contenedor en el 3000, y la única
  forma de notar el cambio fue que la lista de pacientes tardó 40 ms más."*
- **Qué entra:** el mapeo `@Document` de las cinco entidades; los repositories
  con query methods; la **traducción `ObjectId` ↔ `id` entero**, que es incómoda
  y obligatoria porque el frontend guarda enteros en el store —trátala como
  contenido, no como detalle de implementación—; la paginación de servidor que el
  backend nunca expuso, servida **en el dialecto de json-server**; la siembra
  desde el `db.json` que el alumno ya tiene; y el `POST /login` absorbido con el
  mismo formato de token que firmaba el mock, para que el interceptor de la Fase
  3 del track base no note nada.
- **Qué NO entra:** auditoría (be04), transacciones (be05), rangos versionados
  (be06). Aquí solo se sirve el contrato.
- **La semilla sale del `db.json` del propio alumno**, no de un dump. Que los
  datos que aparecen tras el reemplazo sean exactamente los que vio en el track
  base es la mitad del efecto de la fase.
- **Pieza forense:** el primer `smoke.sh` en rojo. Un `id` que salió como
  `"5f4a...c2"` en vez de `1` y una pantalla en blanco. El contrato es el juez.
- **Deuda del track base que cobra:** 💸 3 — paginar, filtrar y ordenar se hacía
  en el navegador porque el backend nunca expuso paginación.
- **Ejercicios:** 30-32.

## Pendientes que pueden bloquear esta fase

- 🪦 **Cerrado al escribir la fase (10/09/2026):** colección `counters` con
  `findAndModify` + `$inc` al estilo de 2019, más un índice **único** sobre
  `legacyId` como red. Ni `ObjectId` truncado ni hash. La fase muestra antes el
  `max + 1` ingenuo y **mide la carrera** —que en json-server no existe porque
  Node tiene un solo hilo y en Spring MVC sí, con doscientos—, que es el
  incidente `be-04`. El límite de `findAndModify` (atómico sobre **un**
  documento) queda nombrado ahí para que `be05` lo recoja.

## Audiencia

Dev backend senior. Ya midió la deriva en be02 y sabe qué hay guardado de verdad;
ahora tiene que servirlo respetando un contrato que no diseñó.

## Cómo quiero que trabajes

Protocolo de tres pasos. En el paso 1 quiero explícitamente **tu plan para la
traducción de identificadores**: es donde esta fase se rompe.
```

---

## # Fase be04 — El audit log que escribía el navegador

```markdown
Este es el chat de la **Fase be04 — 📜 El audit log que escribía el navegador**,
del track BE opcional 🔥 del tutorial Angular 8 + LabCore. Su único entregable es
`be04-el-audit-log-que-escribia-el-navegador.md`.

## Marco (no lo repitas, aplícalo)

El mismo del track. Añade: **be03 ya cerrada**, y la Fase 11 del track base
(`11-trazabilidad-audit-log.md`) más el incidente 17 de `cuaderno-incidentes.md`,
que son el material que esta fase viene a explicar desde el otro lado. Bloque 🏷️
con `be-fase-04-…` y prefijo `be04:`.

## Identidad de esta fase

- Fase be04 de be08 — 📜 El audit log que escribía el navegador
- Horas: **8h**
- Depende de: be03
- Habilita: be05
- Apéndices de apoyo: **bea-08** (tiempo, zonas y fechas en Mongo)
- Incidentes reservados: **be-06**, **be-07**
- Estado: Opcional 🔥

## Alcance

- **Propósito (una línea):** Poner la identidad y el reloj donde siempre
  debieron estar, sin tocar el frontend que hoy los pone mal.
- **El punto de partida está escrito en el track base:** el audit log lo escribe
  el frontend, el actor sale del token que vive en `localStorage`, el timestamp
  sale del reloj de la máquina del operador, y si la escritura del asiento falla,
  la mutación ya ocurrió y nadie se entera. Se decidió así **porque el backend
  estaba congelado**. Ya no lo está.
- **Qué entra:** identidad de verdad en el servidor —el actor sale del token
  validado, no de un campo del body—; el reloj del servidor como única autoridad;
  y el asiento de auditoría escrito **por el backend, en el mismo camino que la
  mutación**.
- **La restricción que hace interesante la fase:** el frontend no se toca, así
  que sigue mandando *sus* asientos. Durante be04 **conviven las dos bitácoras** y
  el alumno mide la divergencia: cuántos asientos el navegador nunca envió,
  cuántos tienen un actor distinto, cuántos tienen una hora que difiere en más de
  un minuto. **Ese número es el entregable de la fase.**
- **Qué NO entra:** decidir cuál de las dos bitácoras es la buena a efectos
  legales. Esa conversación es de be08.
- **Pieza forense:** un asiento con actor correcto y hora del futuro, porque el
  operador tenía el reloj adelantado. Es el incidente 17 del cuaderno base visto
  desde el servidor — y ahí deja de sentirse injusto: se explica.
- **Deuda del track base que cobra:** 💸 1.
- **Ejercicios:** 28-30.

## Pendientes que pueden bloquear esta fase

- 🪦 **Cerrado al escribir la fase (10/09/2026), con una inversión declarada
  respecto de lo que proponía este prompt.** El asiento del cliente se acepta —
  tirarlo destruiría la evidencia— pero **la colección aparte es la del
  servidor**, `auditLogServer`, no la del cliente: `auditLog` se queda intacta y
  `GET /auditLog` sigue devolviendo exactamente lo que devolvía. El motivo es de
  contrato: si el servidor escribiera en `auditLog`, la timeline de la Fase 11
  mostraría asientos que el navegador nunca escribió, con otro formato de `id` y
  otro actor, y eso es cambiar el comportamiento observable sin haberlo decidido.
  El patrón es *shadow write* y está nombrado como tal en la fase.
- 🪦 **Segunda decisión cerrada, y no estaba en este prompt:** el backend
  **verifica la firma del token y NO verifica la expiración**. Rechazar por `exp`
  es un `401`, y un `401` cierra la sesión con un TTL de 120 s sin refresh: sería
  apagar el producto. La decisión va fechada en `CONTRACT.md` con su condición de
  revisión.

## Audiencia

Dev backend senior. La lección no es técnica: es que una deuda del frontend
puede ser el síntoma de una frontera organizacional.

## Cómo quiero que trabajes

Protocolo de tres pasos. En el paso 1 dime **cómo vas a medir la divergencia** y
con qué datos, porque sin ese número la fase es una opinión.
```

---

## # Fase be05 — La cadena de custodia y la transacción que no existe ⭐

```markdown
Este es el chat de la **Fase be05 — ⛓️ La cadena de custodia y la transacción que
no existe**, del track BE opcional 🔥 del tutorial Angular 8 + LabCore. Su único
entregable es `be05-la-cadena-de-custodia-y-la-transaccion.md`.

## Marco (no lo repitas, aplícalo)

El mismo del track. Añade: **be04 ya cerrada**, la Fase 7 del track base
(`07-muestras-custodia.md`) y los incidentes 11 y 17 del cuaderno base. Bloque 🏷️
con `be-fase-05-…` y prefijo `be05:`.

## Identidad de esta fase

- Fase be05 de be08 — ⛓️ La cadena de custodia y la transacción que no existe
- Horas: **10h**
- Depende de: be04
- Habilita: be06
- Apéndices de apoyo: **bea-07** (transacciones, replica sets y el standalone),
  **bea-09** (Cassandra: la tentación y el acierto que nadie tuvo)
- Incidentes reservados: **be-08**, **be-09**
- Estado: Opcional 🔥 — **es la fase insignia del track**

## Alcance

- **Propósito (una línea):** Descubrir que la garantía que el dominio exige no la
  da la topología que alguien eligió en 2019, y contener el daño sin rehacer el
  despliegue.
- **El artefacto central del track, ya medido** (`propuesta-fases-backend.md`
  §5.2). Sobre `mongo:4.0` standalone, con una operación real dentro de la
  transacción, el servidor responde:
  `Transaction numbers are only allowed on a replica set member or mongos`
  (código 20). **No lo argumentes: enséñalo.** El propio mensaje enuncia la tesis
  del track — la capacidad existía en el producto y una decisión de despliegue la
  dejó fuera de alcance.
- ⚠️ **Detalle de método que hay que respetar al escribir la fase:** en el shell,
  `startTransaction()` es perezoso y no lanza nada; el rechazo llega en la primera
  operación de la sesión. Una prueba mal escrita da un falso "permitida". Esto ya
  pasó al verificar el stack — que no vuelva a pasar en el material.
- **Qué entra:** el intento honesto de abrir la transacción y su rechazo; la
  comprobación de que la capacidad sí existe en el producto; la agregación que
  encuentra las custodias con eslabón huérfano **que ya están en producción** —el
  número, no la sospecha—; y las tres salidas realistas, costeadas: convertir a
  replica set (qué implica en un sistema en decomisión), escritura idempotente
  con documento único, o **libro de correcciones**.
- **La contención que gana, y es contabilidad:** lo roto no se arregla
  sobrescribiendo, se compensa con un asiento nuevo. En un dominio regulado es la
  única opción legal, y el alumno tiene que poder defenderlo ante un auditor.
- **Qué NO entra:** el retrofit de validación y el read-model, que son de be08.
- **Pieza forense:** los dos documentos de la escritura a medias, con el
  `X-Request-Id` que los une y el log de `mongod` donde se ve que el segundo nunca
  llegó.
- **Deuda del track base que cobra:** 💸 2.
- **Ejercicios:** 30-35, incluido el 🔴 adversarial de Cassandra que remite a
  `bea-09`.

## Pendientes que pueden bloquear esta fase

- Nada bloqueante: el mensaje literal, el código de error y el método de prueba
  están medidos y con fecha en `propuesta-fases-backend.md` §5.2.

## Audiencia

Dev backend senior con reflejo de transacción intacto. Esta fase no le enseña qué
es una transacción: le enseña qué haces cuando no tienes ninguna y el dominio
exige una.

## Cómo quiero que trabajes

Protocolo de tres pasos. En el paso 1 quiero **el guion exacto de la
demostración** del rechazo, incluido el detalle del `startTransaction()` perezoso.
Es la pieza más citada del track y no puede salir mal.
```

---

## # Fase be06 — Los rangos versionados y la historia que se sobrescribió

```markdown
Este es el chat de la **Fase be06 — 🧬 Los rangos versionados y la historia que se
sobrescribió**, del track BE opcional 🔥 del tutorial Angular 8 + LabCore. Su
único entregable es `be06-los-rangos-y-la-historia-perdida.md`.

## Marco (no lo repitas, aplícalo)

El mismo del track. Añade: **be05 ya cerrada** y la Fase 8 del track base
(`08-resultados-rangos.md`), que es de donde sale todo el material de rangos
versionados. Bloque 🏷️ con `be-fase-06-…` y prefijo `be06:`.

## Identidad de esta fase

- Fase be06 de be08 — 🧬 Los rangos versionados y la historia que se sobrescribió
- Horas: **10h**
- Depende de: be05
- Habilita: be07
- Apéndices de apoyo: **bea-08** (tiempo y fechas), **bea-03**
- Incidentes reservados: **be-10**
- Estado: Opcional 🔥 — **es la fase más incómoda del track**

## Alcance

- **Propósito (una línea):** Contestar la pregunta del auditor, descubrir que no
  se puede, y saber exactamente desde cuándo.
- **La pregunta que abre la fase:** *"¿qué rango de glucosa estaba vigente el 12
  de marzo de 2020?"*. Un sistema clínico tiene que poder responder eso. El de
  2019 hacía `$set` sobre el documento del rango, así que **el histórico se
  sobrescribió**. Es dato bitemporal —tiempo de vigencia y tiempo de registro— y
  no hay forma de reconstruirlo: solo de dejar de perderlo desde hoy.
- **Qué entra:** el modelo bitemporal correcto y por qué el de 2019 no lo era; la
  reconstrucción parcial desde lo que sí sobrevivió; el corte —versionado
  append-only desde hoy—; y la medición de cuántos resultados históricos no se
  pueden reinterpretar.
- **El giro que vale toda la fase:** lo que sobrevivió es el `rangeVersionApplied`
  que la Fase 8 del track base guarda en cada resultado validado. **El frontend
  salvó lo que el backend perdió.** Escríbelo con esas palabras.
- ⚰️ **Autopsia de anti-patrón obligatoria:** `$set` sobre un documento que
  representa una versión. Antes: 3 versiones de glucosa en la base, 14 meses de
  historia irrecuperable. Después: N versiones, 0 pérdidas, y un `effectiveTo`
  que se escribe en vez de borrarse. Con números en las dos columnas.
- **Qué NO entra:** la declaración formal de lo irrecuperable, que es el
  entregable de be08. Aquí se produce el inventario; allí se firma.
- **Pieza forense:** un resultado validado en 2020 cuyo `rangeVersionApplied`
  apunta a una versión que ya no existe con esos límites. El puntero sobrevivió;
  el destino no.
- **Deuda del track base que cobra:** 💸 4.
- **Ejercicios:** 30-35.

## Pendientes que pueden bloquear esta fase

- 🪦 **Cerrado al escribir la fase (10/09/2026): se declara entero y se implementa
  la mitad.** Append-only sobre `referenceRanges` (solo se puede escribir
  `effectiveTo`, nunca los valores), más `recordedAt`/`recordedBy` como medio eje
  de tiempo de registro, más una guarda de inmutabilidad en la aplicación. El eje
  de registro completo **no** se implementa, con tres razones escritas: no
  recupera nada, encarece cada lectura de un sistema con dos años de vida, y no
  tendría consumidor porque el frontend no se toca. La declaración va fechada en
  `CONTRACT.md` con su condición de revisión.

## Audiencia

Dev backend senior. Probablemente nunca haya implementado datos bitemporales y
casi seguro haya sufrido el problema sin saber cómo se llama.

## Cómo quiero que trabajes

Protocolo de tres pasos. En el paso 1, dime **qué se puede reconstruir y qué no**,
con el razonamiento: es la decisión que gobierna la fase entera.
```

---

## # Fase be07 — La subida que nadie decidió: 4.0 → 4.4 → 6.0 → 7.0

```markdown
Este es el chat de la **Fase be07 — 📅 La subida que nadie decidió**, del track BE
opcional 🔥 del tutorial Angular 8 + LabCore. Su único entregable es
`be07-la-subida-que-nadie-decidio.md`.

## Marco (no lo repitas, aplícalo)

El mismo del track. Añade: **be06 ya cerrada**, y `00-convencion-de-git-y-tags.md`
—porque esta fase produce un incidente que **no tiene commit**, y eso hay que
decirlo sin romper la convención—. Bloque 🏷️ con `be-fase-07-…` y prefijo `be07:`.

## Identidad de esta fase

- Fase be07 de be08 — 📅 La subida que nadie decidió: 4.0 → 4.4 → 6.0 → 7.0
- Horas: **8h**
- Depende de: be06
- Habilita: be08
- Apéndices de apoyo: **bea-02** (el `.env` y el compose), **bea-10** (riesgo de
  licencia)
- Incidentes reservados: **be-11** ⭐
- Estado: Opcional 🔥

## Alcance

- **Propósito (una línea):** Investigar un incidente cuyo `git log` está vacío.
- **La asimetría que funda la fase**, ya escrita en `00-historia-del-sistema.md`:
  a la infraestructura la actualizan, a la aplicación no. La base tenía dueño —un
  proveedor con calendario propio—; el código no tenía ninguno.
- **Qué entra:** la tabla de evidencia con los cuatro escalones, sus fechas y sus
  ventanas de mantenimiento; el upgrade ejecutado **cambiando una línea del
  `.env`**; el inventario de lo que se rompió; y el descubrimiento central — el
  driver de 2019 (`mongo-java-driver` 3.8.2) **conecta perfectamente con Mongo
  7.0**, medido servidor por servidor, así que nadie tocó nunca el `pom.xml`.
- ⚠️ **Alcance de lo medido, y es contenido:** la verificación cubre el handshake
  y un comando (`buildInfo`). **Si cada operación que la aplicación usa se
  comporta igual tras cuatro saltos mayores, eso no lo sabe nadie — averiguarlo
  es el trabajo del alumno en esta fase.** Dilo con esas palabras.
- **Los tickets que el salto entrega gratis:** el shell `mongo` desapareció en
  6.0 (medido), así que todo runbook, script y `docker exec … mongo --eval`
  escrito en 2019 está roto.
- **Los dos matices que evitan el cuento, obligatorios los dos:** (1) nada se
  rompió a lo grande precisamente porque MongoDB es muy bueno en compatibilidad
  hacia atrás — el 95% siguió funcionando y por eso nadie miró; **la excelencia
  del proveedor es lo que permitió el abandono**; (2) los fallos se concentran
  donde alguien esquivó el framework: `spring-data` absorbe casi todo, lo que no
  absorbe es el `mongoTemplate` con un `Document` armado a mano.
- **El remate que cierra el círculo con be05:** nadie convierte un standalone en
  replica set durante un bump de versión. La topología de 2019 sobrevive intacta.
  La transacción sigue siendo imposible en 2026 — y ahora, además, el manual dice
  que se puede.
- **Pieza forense ⭐:** el incidente cuyo `git log` está vacío. El alumno hace lo
  que hace siempre —`git log`, `git blame`, revisar el último despliegue— y no
  encuentra nada, **porque no hay nada**. El cambio no está en el árbol de
  fuentes: está en `MONGO_TAG` del `.env`.
- **Ejercicios:** 28-30.

## Pendientes que pueden bloquear esta fase

- 🪦 **Cerrado al escribir la fase (10/09/2026), verificado contra el registro:**
  `4.0.28`, `4.4.30`, `6.0.28` y `7.0.41` son los últimos parches visibles de cada
  línea a esa fecha. La propia fase declara que van a cambiar y convierte esa
  comprobación en su ejercicio 2 — un tag flotante que apunta hoy a un parche y
  mañana a otro **es** el tema del capítulo.

## Audiencia

Dev backend senior con el reflejo de `git blame` muy entrenado. Esta fase existe
para romperlo.

## Cómo quiero que trabajes

Protocolo de tres pasos. En el paso 1 dime **cómo vas a presentar el incidente sin
que el alumno adivine el truco en el primer párrafo**: si lo hace, la fase pierde
su mejor material.
```

---

## # Fase be08 — La contención medida y la declaración de lo irrecuperable

```markdown
Este es el chat de la **Fase be08 — 🧯 La contención medida y la declaración de lo
irrecuperable**, del track BE opcional 🔥 del tutorial Angular 8 + LabCore. Su
único entregable es `be08-la-contencion-y-lo-irrecuperable.md`.

## Marco (no lo repitas, aplícalo)

El mismo del track. Añade: **be00 a be07 cerradas**, porque esta fase consume los
números que todas produjeron. Bloque 🏷️ con `be-fase-08-…` y prefijo `be08:`.

## Identidad de esta fase

- Fase be08 de be08 — 🧯 La contención medida y la declaración de lo irrecuperable
- Horas: **10h**
- Depende de: todas las anteriores
- Habilita: nada. Es el cierre del track.
- Apéndices de apoyo: **bea-06** (`$jsonSchema` sobre datos sucios),
  **bea-11** (mapa de deuda del track BE)
- Incidentes reservados: **be-12**
- Estado: Opcional 🔥

## Alcance

- **Propósito (una línea):** Entregar un plan de contención medido y un documento
  que un auditor pueda leer — y defender por qué **no** se migra.
- **El cierre no es código**, pero llega con tres piezas construidas y medidas:
  1. **Retrofit de `$jsonSchema` en modo `warn`.** Poner validación sobre datos
     sucios es un tema en sí mismo: primero se mide cuánto rechazaría, se decide
     qué se tolera, y solo entonces se sube a `error`. El número de documentos que
     no pasan es la mitad del contenido.
  2. **Outbox hacia un Postgres de lectura** (`postgres:16.9`), solo para lo
     normativo y el dashboard. *Strangler* por read-model, **nunca por
     reescritura**: el sistema operativo sigue en Mongo hasta que muera. Se mide
     la latencia del outbox y se declara la ventana de inconsistencia.
  3. **El libro de correcciones** de be05, ya en producción.
- **El entregable escrito, que es lo más valioso del track:** la **declaración de
  lo irrecuperable**. Qué historia se perdió, desde cuándo, por qué, y qué se le
  contesta al auditor. Firmada, fechada, con números.
- **El árbol de veredicto honesto**, con las cuatro opciones costeadas: migrar a
  relacional (el coste real, no el optimista), convertir a replica set, contener y
  documentar, o no hacer nada. Con la regla que gobierna la fase: **la respuesta
  correcta depende de la fecha de decomisión, no de la calidad del código**.
  LabCore tiene dos años.
- **Aquí se cierra también la estrategia de pruebas del track** (⚠️ pendiente 2 de
  §5.5 de la propuesta): qué se prueba contra un Mongo real, qué no, y por qué. La
  decisión se toma **midiendo el tiempo de ciclo**, que es el criterio que ya
  gobierna el resto del track.
- **Y el cierre honesto obligatorio:** dónde Mongo de verdad ganó. El panel de
  resultados **es** un documento y modelarlo en tablas habría dolido. Pon el
  número de las dos columnas, o el track no ha entendido su propio criterio.
- **Ejercicios:** 25-28, con peso en los 🔴: escribir y defender el documento es
  el ejercicio final.

## Pendientes que pueden bloquear esta fase

- 🪦 **Cerrado al escribir la fase (10/09/2026): el `mongo:4.0` del compose**, con
  limpieza entre pruebas. Los dos tiempos de ciclo están medidos (~4 s contra
  ~31 s), pero el criterio que decide es otro y apareció al medir:
  `MongoDBContainer` arranca un **replica set de un nodo**, o sea que las pruebas
  tendrían transacciones y producción no. Java 8 no era el obstáculo —
  Testcontainers 1.21.4 sigue compilando a *class file* 52, verificado—.

## Audiencia

Dev backend senior que va a tener que defender esta decisión ante alguien que
prefiere el rewrite. Dale los números para hacerlo.

## Cómo quiero que trabajes

Protocolo de tres pasos. En el paso 1 quiero **el índice del documento de
declaración de lo irrecuperable**: es el entregable real de la fase y del track.
```

---

## 🧾 Recordatorio de cierre del track

**Las nueve fases están escritas (10/09/2026).** Quedan dos piezas fuera de este
archivo:

1. ~~**`prompts-backend-apendice.md`** — los doce apéndices `bea-01` … `bea-12`.~~ ✅ **escritos (10/09/2026)**.
2. ~~**`cuaderno-incidentes-be.md`**~~ ✅ **escrito (10/09/2026)**, con los doce
   incidentes reservados en los prompts de arriba (`be-01` … `be-12`), con IDs
   propios y sin mezclarse con el cuaderno base.
3. ~~**Las adiciones de encuadre de §10 de `propuesta-fases-backend.md`**, que se
   hacen **antes** de escribir `be00`.~~ ✅ **Hechas** (10/09/2026): los ocho
   documentos de §10 ya están tocados —README con su sección y su tabla de nueve
   fases, `00-historia-del-sistema.md`, la guía de estilo (§16),
   `alcance-del-proyecto.md`, `00-convencion-de-git-y-tags.md` (§10),
   `propuesta-fases-y-alcance.md` (§9), `cuaderno-incidentes.md` y el `CLAUDE.md`
   del repositorio—. **No hay que rehacerlas**; lo que queda es actualizar el
   estado de cada archivo a medida que las fases se escriban.

Y una nota de método para las tandas: **los nombres de archivo y los tags de las
nueve fases están fijados en §9 de la propuesta**. Si un chat propone otro nombre,
gana la propuesta.
