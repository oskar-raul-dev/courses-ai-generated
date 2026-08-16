# 🗺️ Propuesta de fases, apéndices y alcance — Track BE

Documento de encuadre del **track opcional de backend** del tutorial *Angular 8
Legacy — LabCore, laboratorio clínico*. Define por qué existe, qué cobra, cuánto
pesa, **qué versiones congela** y cómo se reparte en fases y apéndices.

> **Estado:** propuesta, pendiente de revisión. Es el **primer documento
> versionado** del track y el **único registro** de su diseño: el razonamiento
> que lo produjo se consolidó en §0, y las notas sueltas donde se llevó no
> estaban versionadas ni se conservan.
> **Fecha:** 9 de septiembre de 2026.
> **Track base afectado:** ninguno en su contenido. Las fases 0–14 no cambian ni
> una línea de código; sí hay adiciones de encuadre en cinco documentos (§10).
> **Fuentes de verdad que respeta:** `prompts/alcance-del-proyecto.md`,
> `prompts/guia-de-estilo-y-convenciones.md`, `prompts/plantillas-de-capitulo.md`,
> `00-historia-del-sistema.md`, `00-convencion-de-git-y-tags.md`.
> **⚠️ = sin verificar.** Lo verificado lleva su medición y su fecha.

---

## 🕰️ 0. De dónde sale esto: historial de la conversación

El track no se diseñó de un tirón: salió de once rondas de discusión llevadas en
notas de trabajo sin versionar, que ya no existen; **lo que quedó de ellas es
este apartado**, y por eso conserva **el razonamiento que descartó cosas**, que
es la mitad del valor: sin él, dentro de seis meses alguien va a volver a
proponer Cassandra como store principal.

### 0.1 La bisagra: el backend no viene a redimir nada

El molde obvio para un track de backend es la **redención**: el mock es un atajo
declarado, y las fases del servidor existen para cobrar —una por una— las deudas
💸 que el track base anunció y no podía pagar desde el navegador. El alumno
termina con un sistema mejor del que empezó.

Ese molde se descartó, y la inversión de signo es lo que funda este track:

> 🧠 **El backend no viene a redimir nada. El backend es la escena del crimen.**
> El contenido no es *"cómo se hace bien"*, es *"qué haces el lunes cuando lo
> que está mal es una decisión de arquitectura de hace cinco años, el sistema
> factura, y no hay presupuesto para deshacerla"*.

Y su corolario, que ordena el final del track: **el desenlace honesto casi nunca
es migrar.** Es estabilizar, acotar el daño, y escribir el documento que defiende
por qué no se migra.

### 0.2 La ficha del pecado

Que el pecado sea de **modelo de datos** —y no, por ejemplo, de ausencia de
revisión o de un framework mal elegido— es la decisión que ordena las nueve
fases. Queda fijada así:

- **El pecado:** moda de modelo de datos.
- **El actor:** el equipo huyendo del DBA de Oracle.
- **Cómo se decidió:** *"con Mongo el esquema lo movemos nosotros"*, en 2019.
- **El stack que salió de ahí:** Java 8 + Spring Boot 2.1 + `mongo:4.0`.
- **El fallo insignia:** integridad, historia, auditoría.
- **El entregable final:** un plan de contención medido.

Dentro de esa decisión se evaluó y se descartó **Cassandra como store
principal**: sería el mismo curso —*"elegí mal el modelo de datos"*— con otra
base, y además con el modelo de acceso equivocado (§0.4).

### 0.3 Por qué esas versiones y no otras

**El dato duro:** `mongo:4.0` (jul-2018) + Spring Boot 2.1 (oct-2018) es
exactamente lo que instalaría un equipo que arranca en **2019**, que es la fecha
que el README de LabCore ya publicó. Boot 1.5 se descartó por lo mismo:
implicaría un proyecto empezado en 2017 y contradiría la historia escrita. La
edad del backend no la fija la edad del frontend, la fija la historia publicada
del equipo que lo escribió.

**Y la rima de disciplina**, que es la razón de fondo:

> 🧠 `strict: false` con `any` tolerado (el frontend) ↔ **Mongo sin
> `$jsonSchema`** (el backend).

El curso enseña la misma pregunta de disciplina en sus dos capas. La deriva de
esquema de este track —*tres años sin validación producen cinco formas del mismo
documento de paciente*— **es el pecado de `any` tolerado una capa más abajo**.
Cualquier stack que rompiera esa rima quedaba fuera por eso solo.

### 0.4 Descartados, con su razón

| Candidato | Por qué no | Dónde quedó |
|---|---|---|
| **WildFly / JEE 7-8** | Mete un segundo pecado —el servidor de aplicaciones—, encarece el ciclo de iteración, y pierde el efecto *"parecía JPA"* que es la razón de elegir Spring | En la **historia** del equipo: de WebLogic y del DBA de Oracle es de lo que huían |
| **Node 12 + Express** | Más barato de montar, pero el dialecto de Mongo queda demasiado a la vista y se pierde el efecto *"no me di cuenta"* | Descartado |
| **Spring Boot 1.5** | Implicaría un proyecto de 2017 y contradice la historia publicada | Descartado |
| **Cassandra como store** | Modelo de acceso equivocado: en Cassandra la tabla se diseña por consulta y LabCore tiene demasiadas | 🔴 Ejercicio adversarial + apéndice honesto (`bea-09`) |
| **RethinkDB** | *"Elegiste bien y perdiste igual"* es una gran lección, pero compite por el mismo eje de datos | Nota dentro de `bea-10` |
| **Scala + Play + Akka** | Mejor historia, peor laboratorio: el coste por iteración se come el presupuesto pedagógico | Su lección —el riesgo de licencia— se muda a `bea-10` |

### 0.5 Verificaciones ejecutadas

Todo sobre Docker Desktop 29.6.2, host `aarch64`, el **8 de septiembre de 2026**.
Ver §5 para la tabla completa. Los tres resultados que decidieron contenido:

1. **`eclipse-temurin:8-jdk` corre nativo en arm64** (`1.8.0_502`, `aarch64`). El
   JDK 8 para *macOS* aarch64 no existe; para *Linux* sí. Como todo corre en
   contenedor, es irrelevante — y **el alumno nunca instala un JDK**.
2. **`mongo:4.0` standalone rechaza la transacción** con su mensaje literal.
3. **El driver Java de 2019 conecta hasta Mongo 8.0.** La hipótesis de que el
   upgrade forzó un bump del `pom.xml` era falsa: **nadie tocó la aplicación,
   nunca**.

---

## 🧭 1. En una frase

Nueve fases opcionales que **construyen el backend de 2019 que LabCore siempre
tuvo y nadie del curso había visto** —Java 8, Spring Boot 2.1 y un `mongod`
suelto—, lo ponen en el puerto `3000` en lugar del mock, y usan ese sistema para
**medir** lo que una decisión de modelo de datos de hace siete años le costó al
laboratorio, y **contenerlo** sin migrarlo.

La señal de éxito no es un backend bonito. Es esta, y se verifica:

> 🧭 **Se apaga `npm run mock`, se levanta el contenedor en el mismo puerto
> `3000`, y la aplicación Angular no cambia ni un archivo.** Y a partir de ahí,
> cada fase entra por un ticket y sale por un **número**.

Si para que la app funcione hay que tocar un service, un effect o un reducer, el
track falló, por bonito que haya quedado el backend.

Y el remate, que es lo que lo diferencia del track BE de React:

> 🧠 **LabCore no se migra.** Tiene decomisión en dos o tres años; un rewrite es
> irresponsable y el track lo dice **con números**. Lo que se entrega es un plan
> de contención medido y una declaración firmada de lo que ya no se puede
> recuperar.

---

## ✅ 2. Decisiones cerradas

Estas ya no se discuten en los chats siguientes.

| Pregunta | Decisión | Consecuencia |
|---|---|---|
| ¿Curso aparte o mismo curso? | **Mismo curso, mismo directorio**, track opcional | Un solo README, una sola guía de estilo, un solo diccionario |
| ¿Numeración? | Fases `beNN-tema.md` (be00–be08), apéndices `bea-NN-tema.md` | No colisiona con `NN-`, `aNN-` ni `forense-fase-NN` del track base |
| ¿Obligatorio? | **No.** El track base se completa con el mock y las 122h no cambian | Se marca 🔥 en el README; sus horas se declaran aparte |
| ¿Prerrequisito? | **Fase 11 del track base terminada** | Es el corte exacto: antes no existe el audit log, que es lo que `be04` viene a cobrar. Las fases 12–14 no hacen falta |
| ¿Lenguaje? | **Java 8 + Spring Boot 2.1**, monolito Maven | Ver §5. El lenguaje es aburrido **a propósito**: el pecado es el modelo de datos y nada puede robarle el foco |
| ¿Base de datos? | **`mongo:4.0` standalone**, que sube a **`mongo:7.0`** en `be07` | La topología de 2019 sobrevive al upgrade: sigue siendo standalone en 2026 |
| ¿Postgres? | **Sí, pero solo como read-model** en `be08` (`postgres:16.9`) | *Strangler* por outbox, nunca reescritura. El sistema operativo muere en Mongo |
| ¿El inyector de caos? | **Se reimplementa en Java**, con doble control: variable `CHAOS` y header, apagado por defecto | Las fases 4 en adelante del track base entrenan contra él; no puede desaparecer |
| ¿El login del mock? | **Se absorbe.** El `POST /login` con `jsonwebtoken` pasa a ser un endpoint del backend | El contrato del token no cambia: el interceptor de la Fase 3 no se entera |
| ¿Relación con otros cursos? | **Ninguna.** Este track no sabe que existe `docker-container-legacy` | Todo lo de contenedores vive en `bea-02`, cerrado y autocontenido |
| ¿ORM / abstracción? | **`spring-data-mongodb` con `@Document` y repositories** | No es comodidad: **es el mecanismo pedagógico central**. Ver §3 |
| ¿Datos de prueba? | **El `db.json` del propio alumno** como semilla; volumen sintético como camino 🔥 | La semilla real hace el reemplazo creíble; el volumen se necesita recién cuando hay que medir |
| ¿Piezas forenses en archivo aparte? | **No.** Van embebidas en la §6 de cada fase BE | Ver §9 |
| ¿Cuaderno de incidentes? | **`cuaderno-incidentes-be.md`**, propio del track | Un alumno que solo hace el track base no debe recibir incidentes de Mongo mezclados con los suyos |

---

## 💸 3. Por qué existe este track: lo que viene a cobrar

El track base declaró sus atajos y dijo dónde se pagarían. Cuatro de ellos **no
se pueden pagar desde el navegador** porque viven del otro lado de HTTP, y el
propio `00-historia-del-sistema.md` lo dice con todas las letras: *"el backend
estaba congelado y era de otro equipo"*.

Este track es lo que pasa el día en que **ese otro equipo se disuelve y el
backend te cae encima**.

| # | Deuda declarada en el track base | Dónde vive de verdad | Fase BE que la cobra |
|---|---|---|---|
| 💸 1 | El audit log **lo escribe el frontend**: actor desde `localStorage`, timestamp desde el reloj del operador (Fase 11, incidente 17) | En que el backend nunca expuso un endpoint de auditoría | `be04` |
| 💸 2 | El timestamp y el "quién" de la **cadena de custodia** los pone el navegador (Fase 7, incidentes 11 y 17) | En que registrar un traspaso son **dos escrituras sin transacción** | `be05` ⭐ |
| 💸 3 | **Paginar, filtrar y ordenar se hace en el navegador** porque el backend nunca expuso paginación (Fases 5 y 6) | En que la colección se sirve entera | `be03` |
| 💸 4 | Los **rangos versionados** se leen contra la versión vigente al validar (Fase 8) — y el histórico a veces no cuadra | En que el backend hacía `$set` sobre el rango y **se comió su propia historia** | `be06` |

Y añade tres facturas que el track base **no podía ni nombrar**, porque no se ven
desde el cliente:

- **La deriva de esquema.** Tres años sin validación producen cinco formas del
  mismo documento de paciente. El alumno **mide** cuántas hay con una agregación
  sobre las claves; no lo supone. Esa medición es la mitad de `be02`.
- **La integridad referencial que nadie tenía.** Órdenes que apuntan a pacientes
  borrados. En Mongo eso no es un error, es martes.
- **La subida de versión que nadie decidió.** El proveedor gestionado movió la
  base cuatro veces mientras la aplicación se quedaba quieta (`be07`).

### 3.1 El mecanismo pedagógico central, y por qué es Spring

`@Document` y los repositories de `spring-data-mongodb` hacen que Mongo
**parezca** relacional. `findByPatientIdAndStatus(...)` se escribe igual que en
JPA, devuelve objetos tipados, y no hay una sola línea de BSON a la vista.

> 🧠 **Ese es exactamente el mecanismo por el que un equipo entra en NoSQL
> dormido, creyendo que sigue en JPA.** El track no lo denuncia en la fase 1: lo
> **usa** durante tres fases, deja que el alumno se sienta cómodo, y recién en
> `be02` le pide que mida qué hay de verdad guardado. La incomodidad de esa
> medición es el contenido.

Por eso se descartó Node + Express (el dialecto queda demasiado a la vista) y por
eso se descartó JEE (no tiene equivalente de `@Document`, y sin ese efecto la
elección de lenguaje pierde su razón de ser).

### 3.2 Y la defensa obligatoria: Mongo no es el villano

Sería traicionar el criterio del repositorio. **Una parte del dominio de LabCore
sí es documental**, y de verdad: un hemograma y un perfil lipídico no comparten
forma, y modelarlos en tablas duele. El equipo de 2019 vio ese caso, **acertó**, y
generalizó desde ahí a todo el sistema.

> 🧭 **No fue ignorancia: fue una buena intuición aplicada fuera de su rango.**
> Cualquier fase que se lea como *"Mongo es malo"* está mal escrita y se
> reescribe. La frase que el track defiende es otra: *el modelo de acceso manda
> sobre el producto.*

---

## 🚫 4. Reglas no negociables

**El frontend no se toca.** Ni un componente, ni un slice de NgRx, ni un effect,
ni el interceptor, ni `environment.apiUrl`. El backend se adapta al contrato
existente, nunca al revés. Si una fase necesita cambiar el frontend, la fase está
mal diseñada. `git diff fase-11-trazabilidad-audit-log..HEAD -- src/` lo
demuestra, y ese comando es un ítem del checklist de `be00`.

**El contrato manda sobre la elegancia.** json-server tiene un dialecto y el
frontend lo consume tal cual: `?patientId=1`, el `404` con cuerpo vacío, el `POST`
que devuelve el recurso creado con su `id` numérico, el `id` autoincremental
entero. Reimplementarlo sobre Mongo —que quiere `ObjectId`— es *aburrido,
incómodo y correcto*. Un backend "mejor diseñado" que rompe el contrato es un
backend roto. **La traducción `ObjectId` ↔ `id` entero es contenido de `be03`, no
un detalle de implementación.**

**El caos sobrevive.** El inyector que el alumno construyó en la Fase 4 es la
herramienta de práctica de nueve fases del track base. Se reimplementa en Java con
los cinco modos idénticos, apagado por defecto, y con los dos controles: la
variable `CHAOS` y el header. Si el alumno no puede repetir el ejercicio 3 de la
Fase 4 contra el backend nuevo, `be01` está mal.

**Autocontención estricta.** Este track no remite a ningún otro curso del
catálogo, ni siquiera para los contenedores. Todo lo que hace falta para levantar
la pila vive en `bea-02`, escrito como receta cerrada y verificable. Ninguna
fase dice *"confírmalo contra tu entorno real"* ni deja una versión pendiente.

**El alumno no instala un JDK.** Ni Maven, ni Mongo, ni `mongosh`. Cuatro
comandos de `docker compose` y nada más (§5.3). Verificado.

**Nada de Java moderno gratuito.** Sin `var`, sin `record`, sin
`List.of`, sin text blocks, sin `Optional` donde el código de 2019 no lo usaba,
sin reactive. Lo posterior a Java 8 aparece marcado 🔥 como comparación, nunca
como la forma en que LabCore está escrito.

**Idioma, igual que siempre.** Narrativa y comentarios en español latinoamericano
con tuteo; código en inglés —paquetes, clases, campos, nombres de colección y de
campo BSON—. `Patient`, `Order`, `Sample`, `Result` y `ReferenceRange` significan
exactamente lo mismo a los dos lados del cable, y eso lo garantiza el anexo Java
de la guía de estilo (§10).

---

## 🛠️ 5. Stack y versiones

**Todo fijado.** Las tres ⚠️ que quedaban abiertas se cerraron al escribir las
fases que las necesitaban; §5.5 conserva cada una con su 🪦 y su resolución. Esta tabla es la fuente de verdad del
track: el curso no depende de ningún `pom.xml` externo.

### 5.1 La pila

| Pieza | Versión | Por qué esta y no otra |
|---|---|---|
| Java | **8** (`eclipse-temurin:8-jdk`) | Verificado `1.8.0_502` aarch64 el 8/09/2026. Lo que corría un laboratorio colombiano en 2019 |
| Framework | **Spring Boot 2.1.18.RELEASE** | Octubre de 2018: lo que instalaría un equipo que arranca en 2019. Boot 1.5 implicaría 2017 y contradice la historia publicada |
| Acceso a datos | **`spring-data-mongodb`** de la línea 2.1 | El mecanismo pedagógico central (§3.1) |
| Driver Mongo | **`mongo-java-driver` 3.8.2** | Verificado: conecta contra 4.0, 4.2, 5.0, 6.0, 7.0 y 8.0. **Nunca hubo bump de `pom.xml`** |
| Build | **Maven 3.8** (`maven:3.8-eclipse-temurin-8`) | arm64 confirmado. El volumen `m2` hace aceptable el ciclo de iteración |
| Base de datos (2019) | **`mongo:4.0`** standalone | Verificado `4.0.28` aarch64. **Standalone es la decisión de despliegue de 2019, y es el corazón de `be05`** |
| Base de datos (2026) | **`mongo:7.0`** | Destino del upgrade escalonado. Soportado, y por encima del corte del shell |
| Cadena de upgrade | **4.0 (2019) → 4.4 → 6.0 → 7.0** | Escalonada, no de un salto. Cada escalón con su fecha y su ventana de mantenimiento |
| Shell | `mongo` hasta 4.4 · **`mongosh` desde 6.0** | Verificado. El shell `mongo` desaparece en 6.0: rompe todo runbook de 2019 |
| Read-model (`be08`) | **`postgres:16.9`** | Solo para lo normativo y el dashboard. Verificado arm64 |
| JSON | Jackson, el de Boot 2.1 | Sin discusión |
| Pruebas | JUnit 4 + `spring-boot-starter-test` | Lo de la época. La estrategia contra un Mongo real se decide en `be08` ⚠️ |
| Puerto de la API | **3000** | El mismo del mock. El frontend no debe enterarse |
| Puerto de Mongo | **27017**, no publicado por defecto | Se publica bajo demanda para `mongosh`; `bea-02` lo explica |

### 5.2 Lo verificado, con fecha

Docker Desktop 29.6.2, host `aarch64`, 8 de septiembre de 2026. **Nada necesita
emulación.**

| Imagen | arm64 | Cómo se comprobó |
|---|---|---|
| `eclipse-temurin:8-jdk` | ✅ | runtime (`1.8.0_502`, `aarch64`) |
| `maven:3.8-eclipse-temurin-8` | ✅ | runtime |
| `mongo:3.6 / 4.0 / 4.2 / 4.4 / 6.0 / 7.0 / 8.0` | ✅ | registro; `4.0` también en runtime (`4.0.28`, `aarch64`) |
| `postgres:16.9` | ✅ | registro y runtime |

**El artefacto central del track**, medido sobre `mongo:4.0` standalone con una
operación real dentro de la transacción:

```
RESULTADO: RECHAZADA
codigo:  20
mensaje: Transaction numbers are only allowed on a replica set member or mongos
```

> 🧠 **El propio mensaje de error enuncia la tesis del track:** la capacidad
> existía en el producto, y **una decisión de despliegue de 2019 la dejó fuera de
> alcance**. No hay que argumentarlo: se enseña.

⚠️ **Detalle de método que hay que respetar al escribir `be05`:** en el shell,
`startTransaction()` es perezoso y no lanza nada. El rechazo llega en la primera
operación de la sesión. Una prueba mal escrita da un falso *"permitida"*.

**El driver de 2019, servidor por servidor** (`mongo-java-driver` 3.8.2, Java 8):

```
mongo:4.0  OK    mongo:5.0  OK    mongo:7.0  OK
mongo:4.2  OK    mongo:6.0  OK    mongo:8.0  OK
```

⚠️ **Alcance de lo medido, y es contenido:** la prueba cubre el handshake y un
comando (`buildInfo`). **Si cada operación que la aplicación usa se comporta
igual tras cuatro saltos mayores, eso no lo sabe nadie — averiguarlo es el
trabajo del alumno en `be07`.**

**El shell, que decide el destino del salto:**

```
mongo:4.0   "mongo": si   "mongosh": NO
mongo:6.0   "mongo": NO   "mongosh": si
mongo:7.0   "mongo": NO   "mongosh": si
```

### 5.3 El arranque, en cuatro comandos

```bash
docker compose up -d          # levanta mongo + la API en el 3000
curl localhost:3000/health    # comprobar
docker compose logs -f api    # ver que pasa
docker compose down           # parar (con -v borra la base)
```

`compose.yaml`, probado:

```yaml
services:
  db:
    image: mongo:${MONGO_TAG}
    volumes: [mongodata:/data/db]
  api:
    image: maven:3.8-eclipse-temurin-8      # arm64 confirmado
    working_dir: /app
    ports: ["3000:3000"]
    volumes: [".:/app", "m2:/root/.m2"]     # cache de Maven: se baja una vez
    environment: {MONGO_URI: "mongodb://db:27017"}
    depends_on: [db]
    command: mvn -q spring-boot:run
volumes: {mongodata: , m2: }
```

Lo único que hay que advertir en el README: **la primera vez tarda** porque Maven
baja el árbol de dependencias a un volumen nombrado, y a partir de ahí no vuelve
a hacerlo.

### 5.4 El hallazgo que le regala una fase entera al track

```
# .env — La version de la base vive AQUI, fuera del codigo fuente.
MONGO_TAG=4.0
```

> 🧠 La fase de *"subida forzada por el proveedor"* (`be07`) es **cambiar una
> línea de un archivo que no es código**. El alumno hace `git log` buscando qué
> rompió y **no encuentra nada, porque no hay nada** en el árbol de fuentes.

Eso entrega la propiedad forense más valiosa del track —*la causa y el síntoma
están separados por meses, y el cambio que rompió no está en el repositorio*—
**sin forzar ninguna convención de tags**, que era el problema de diseño abierto.
En un curso construido sobre el par `-roto` / `-fix` y el `git diff` como factura
de la deuda, tener **un incidente cuyo diff está vacío** vale mucho.

### 5.5 Las tres ⚠️ que quedan, y por qué no bloquean

1. 🪦 **La versión exacta de Spring Boot 2.1.x — cerrado al escribir `be01`
   (10/09/2026).** Es **`2.1.18.RELEASE`**, publicada el 29/10/2020 y última de
   la línea 2.1, que llegó a fin de soporte el 1/11/2020. Verificado contra el
   anuncio oficial y contra su propio `spring-boot-dependencies`, que fija
   Spring Framework `5.1.19.RELEASE`, Spring Data `Lovelace-SR21`, Jackson
   `2.9.10.20200824`, Tomcat `9.0.39`, JUnit `4.12` y —el dato que le importa a
   `be07`— **`mongodb` 3.8.2**. O sea: *el driver de 2019 no lo eligió nadie,
   viene con el BOM*, y como el `pom.xml` no se tocó nunca, el driver tampoco.
   Anotado también: Boot 2.1 **no tiene apagado ordenado** (`server.shutdown=graceful`
   llega en 2.3), así que `be01` lo escribe a mano.
2. 🪦 **La estrategia de pruebas — cerrada al escribir `be08` (10/09/2026).**
   Se corre contra **el `mongo:4.0` del compose**, con limpieza entre pruebas.
   El tiempo de ciclo lo confirma (~4 s la suite entera contra ~31 s con
   Testcontainers), pero **lo decide otra cosa**: `MongoDBContainer` de
   Testcontainers arranca la base **como replica set de un solo nodo**, así que
   las pruebas correrían sobre una topología que da garantías que producción no
   da — un `@Transactional` verde en el pipeline y rechazado con el código 20 en
   producción. La regla que queda escrita: *un entorno de pruebas mejor que
   producción no es un entorno de pruebas.* Java 8 no era el problema:
   verificado que Testcontainers 1.21.4 sigue compilando a *class file* 52. Se
   revisa solo si LabCore se convierte a replica set.
3. 🪦 **Los tags intermedios — cerrados al escribir `be07` (10/09/2026)**, contra
   el registro: `4.0.28`, `4.4.30`, `6.0.28` y `7.0.41`. La fase declara que van
   a cambiar y convierte esa comprobación en su ejercicio 2: un tag flotante que
   hoy apunta a un parche y mañana a otro **es** el tema del capítulo.

---

## ⏱️ 6. Presupuesto de horas

El track base **sigue siendo de 122h** (108h de fases + 14h de cuaderno) y no
cambia. El track BE declara las suyas aparte, y son menos que las del track base
porque el alumno ya trae el dominio aprendido: no hay que explicarle qué es una
cadena de custodia ni por qué un rango se versiona.

| Bloque | Fases | Horas |
|---|---|---|
| El contrato y la forma del monolito | be00–be01 | 14h |
| La medición: qué hay de verdad guardado | be02 | 10h |
| El reemplazo y la identidad | be03–be04 | 18h |
| Las dos heridas del dominio | be05–be06 | 20h |
| Lo que pasó sin que nadie mirara | be07 | 8h |
| La contención, medida y firmada | be08 | 10h |
| **Total track BE** | **9 fases** | **80h** |
| 📓 Cuaderno de incidentes BE | `cuaderno-incidentes-be.md` | **8h** · 12 incidentes |
| | **Total con cuaderno** | **88h** |

Los apéndices no cuentan: son consulta bajo demanda, igual que `a01`–`a13`.

---

## 🌳 7. Las nueve fases

Cada una usa la **plantilla obligatoria de nueve secciones** de
`prompts/guia-de-estilo-y-convenciones.md` §8 y cierra con sus 📌 Pendientes
fuera de lo que lee el alumno. Ejercicios: **25 mínimo, 30 ideal, hasta 35 en las
densas**, con al menos un tercio de diagnóstico.

Cada fase nombra su **pieza forense**, que en este track casi nunca es un
DevTools: es una agregación, un `explain()`, un log de `mongod` o una escritura
que quedó a medias.

Y todas siguen el mismo ciclo, que es el de los cursos de Angular y **no** el
"deuda por deuda" del track de React:

> 🧭 **síntoma → medición → contención.** Ninguna fase enseña el producto por el
> producto. Si una fase se puede resumir como *"aquí se explica el aggregation
> framework"*, está mal escrita y se reescribe.

### 📜 be00 — El contrato: auditoría del mock (6h)

Antes de escribir una línea de Java hay que saber exactamente qué promete el
servidor que se va a apagar. Y aquí es *más* necesario que en el track de React,
porque el backend heredado va a ser raro: **el contrato es lo único firme**.

Entra: capturar el tráfico real con la pestaña Network contra las fases 5 a 11 del
track base —no leer el código del mock, **capturarlo**—; inventariar las seis
colecciones (`patients`, `orders`, `samples`, `results`, `referenceRanges`) y el
`POST /login`; documentar el dialecto de json-server que el frontend consume de
verdad (`?patientId=1`, el `404` con cuerpo vacío, el `id` entero autoincremental,
el objeto creado que devuelve el `POST`); e inventariar los cinco modos del
inyector de caos con sus dos vías de activación.

Sale: **`CONTRACT.md`** y **`smoke.sh`** ejecutable, que a partir de aquí es el
juez de todas las fases. Y la línea del checklist que gobierna el track:
`git diff fase-11-trazabilidad-audit-log..HEAD -- src/` devuelve vacío.

Pieza forense: dos peticiones que el alumno **juraría** que son iguales y que
difieren en un header o en el orden de los parámetros. El contrato no es lo que
uno recuerda.

### ☕ be01 — Java 8, Spring Boot 2.1 y la forma del monolito (8h)

Entra: el `pom.xml` y el layout en `server/`; `@RestController`, `@Service`,
`@Repository` y la arquitectura en capas; la cadena de filtros (CORS hacia el
`4200`, logging, `X-Request-Id`, manejo de excepciones con
`@ControllerAdvice`); el apagado ordenado; y el primer endpoint vivo,
`GET /health`.

Se reimplementa aquí el **inyector de caos**, apagado por defecto y con los dos
controles del mock: la variable `CHAOS` y el header. Cuál gana cuando se
contradicen se decide y se documenta en la fase; la propuesta dice que gana la
última orden recibida, y que el arranque cuenta como orden.

Pieza forense: una excepción no capturada dentro de un controller. Sin
`@ControllerAdvice`, Spring devuelve su página de error por defecto con el stack
trace adentro — y eso, en un sistema clínico, es un hallazgo de auditoría.

Sale a `bea-01` (Java y Spring para quien no escribe Java) y a `bea-02` (la
receta de imagen y compose).

### 🔬 be02 — Lo que hay de verdad guardado: medir la deriva (10h) ⭐

**La fase que cambia el ánimo del track**, y la primera que no construye nada.

Hasta acá el alumno ha escrito `@Document class Patient` con sus cinco campos
tipados y todo parecía JPA. Esta fase le entrega un dump de la colección real de
producción y le pide que **cuente cuántas formas distintas del documento de
paciente existen**. La respuesta son cinco, y ninguna la dice el modelo Java.

Entra: el framework de agregación **como instrumento de medida, no como API** —
`$objectToArray` sobre `$$ROOT` para inventariar claves, `$group` para contar
formas, `$type` para encontrar el campo que a veces es `String` y a veces
`Number`—; la búsqueda de referencias rotas con `$lookup` (órdenes que apuntan a
pacientes que ya no están); y la conversación incómoda sobre por qué el
repository de Spring **devolvió objetos perfectamente válidos** sobre datos que no
lo son.

> 🪞 **Tu instinto relacional dice "el esquema está en la base"… y esta vez se
> equivoca.** El esquema está en el código Java, en el código Java **anterior**, y
> en el script de importación que alguien corrió una vez en 2020. Los tres siguen
> vigentes al mismo tiempo.

🩻 **Esto sí funciona igual:** un índice sigue siendo un índice, y `explain()`
sigue diciéndote si lo usaste.

Pieza forense: el `null` que en Java llega como `null` y en la base es tres cosas
distintas — campo ausente, campo con valor `null`, y campo con string vacío. Es
la conversación de `strict: true` que el frontend nunca tuvo, vivida desde el
otro lado del cable.

Sale a `bea-04` (agregaciones como instrumento de medida) y `bea-05` (índices y
`explain`).

### 🗄️ be03 — La costura: de `db.json` a Mongo, y el reemplazo (10h)

**La bisagra del track.** Se implementan las seis colecciones del contrato, se
siembra la base **desde el `db.json` que el alumno ya tiene** —no desde un dump
ajeno—, y se apaga el mock.

Entra: el mapeo `@Document` de las cinco entidades; los repositories con query
methods; la **traducción `ObjectId` ↔ `id` entero**, que es incómoda y obligatoria
porque el frontend guarda enteros en el store; la paginación de servidor que el
backend nunca expuso (💸 3) servida en el dialecto de json-server; y el
`POST /login` absorbido con el mismo formato de token que firmaba el mock, para
que el interceptor de la Fase 3 no note nada.

Pieza forense: el primer `smoke.sh` en rojo. Un `id` que salió como
`"5f4a...c2"` en vez de `1` y una pantalla en blanco. El contrato es el juez.

> 🧭 **La señal de que quedó bien:** *"apagué `npm run mock`, levanté el
> contenedor, y la única forma de notar el cambio fue que la lista de pacientes
> tardó 40 ms más."*

Sale a `bea-03` (embeber contra referenciar: qué se decidió en 2019 y qué costó).

### 📜 be04 — El audit log que escribía el navegador (8h)

Cobra la deuda 💸 1. El track base fue explícito: *el audit log lo escribe el
frontend, el actor sale del token que vive en `localStorage`, el timestamp sale
del reloj de la máquina del operador, y si la escritura del asiento falla, la
mutación ya ocurrió y nadie se entera.* Se tomó esa decisión **porque el backend
estaba congelado**. Ya no lo está.

Entra: identidad de verdad en el servidor —el actor sale del token validado, no
de un campo del body—; el reloj del servidor como única autoridad; y el asiento
de auditoría escrito **por el backend, en el mismo camino que la mutación**.

Y la restricción que hace interesante la fase: **el frontend no se toca**, así que
sigue mandando *sus* asientos. Durante `be04` conviven las dos bitácoras y el
alumno **mide la divergencia**: cuántos asientos el navegador nunca envió, cuántos
tienen un actor distinto, cuántos tienen una hora que difiere en más de un minuto.
Ese número es el entregable.

Pieza forense: un asiento con `actor` correcto y hora del futuro, porque el
operador tenía el reloj adelantado. Es el incidente 17 del cuaderno base visto
desde el servidor, y ahí deja de sentirse injusto: se explica.

Sale a `bea-08` (tiempo, zonas y fechas en Mongo).

### ⛓️ be05 — La cadena de custodia y la transacción que no existe (10h) ⭐⭐

**La fase insignia.** La cadena de custodia es un libro *append-only* con eslabones
que no pueden faltar ni reordenarse, y registrar un traspaso de muestra son **dos
escrituras**. En un `mongod` standalone de 2019 no hay transacción que las una.

Entra: el intento honesto de abrir una transacción y el mensaje literal de §5.2;
la comprobación de que la capacidad **sí existe en el producto** y que lo que la
bloquea es una decisión de despliegue de 2019; la agregación que encuentra las
custodias con eslabón huérfano **que ya están en producción** —el número, no la
sospecha—; y las tres salidas realistas, costeadas: convertir a replica set (qué
implica en un sistema en decomisión), escritura idempotente con documento único,
o **libro de correcciones**.

La contención que gana, y es contabilidad:

> 🧭 **Lo roto no se arregla sobrescribiendo: se compensa con un asiento nuevo.**
> En un dominio regulado es la única opción legal, y el alumno tiene que poder
> defenderlo ante un auditor.

Pieza forense: los dos documentos de la escritura a medias, con el
`X-Request-Id` que los une y el log de `mongod` donde se ve que el segundo nunca
llegó.

Sale a `bea-07` (transacciones, replica sets y por qué un standalone no puede).

### 🧬 be06 — Los rangos versionados y la historia que se sobrescribió (10h)

Cobra la deuda 💸 4 y es la fase **más incómoda del track**.

Un auditor pregunta: *"¿qué rango de glucosa estaba vigente el 12 de marzo de
2020?"*. Un sistema clínico tiene que poder responder eso. El de 2019 hacía `$set`
sobre el documento del rango, así que **el histórico se sobrescribió**. Es dato
bitemporal —tiempo de vigencia y tiempo de registro— y no hay forma de
reconstruirlo. Solo de dejar de perderlo desde hoy.

Entra: el modelo bitemporal correcto y por qué el de 2019 no lo era; la
reconstrucción parcial desde lo que sí sobrevivió (el `rangeVersionApplied` que la
Fase 8 del track base guarda en cada resultado validado — **el frontend salvó lo
que el backend perdió**, y eso es un giro que vale toda la fase); el corte:
versionado append-only desde hoy; y la medición de cuántos resultados históricos
no se pueden reinterpretar.

> ⚰️ **Autopsia de anti-patrón:** `$set` sobre un documento que representa una
> versión. Antes: 3 versiones de glucosa en la base, 14 meses de historia
> irrecuperable. Después: N versiones, 0 pérdidas, y un `effectiveTo` que se
> escribe en vez de borrarse.

Pieza forense: un resultado validado en 2020 cuyo `rangeVersionApplied` apunta a
una versión que **ya no existe con esos límites**. El puntero sobrevivió; el
destino no.

### 📅 be07 — La subida que nadie decidió: 4.0 → 4.4 → 6.0 → 7.0 (8h)

La fase que la asimetría le regala al track:

> 🧠 **A la infraestructura sí la actualizan. A la aplicación no.** La base tiene
> dueño —un proveedor gestionado, una auditoría, un calendario ajeno— y fue
> subiendo de versión durante siete años. La aplicación no tenía dueño y sigue en
> 2019.

Entra: la tabla de evidencia con los cuatro escalones, sus fechas y sus ventanas
de mantenimiento (material del `historia-del-sistema` del track); el upgrade
ejecutado cambiando **una línea del `.env`**; el inventario de lo que se rompió; y
el descubrimiento central — **el driver de 2019 conecta perfectamente con Mongo
7.0** (medido, §5.2), así que *nadie tocó nunca el `pom.xml`*.

Los tickets que el salto entrega gratis: **el shell `mongo` desapareció en 6.0**,
así que todo runbook, script y `docker exec … mongo --eval` escrito en 2019 está
roto; y las operaciones concretas que la aplicación usa y que nadie probó tras
cuatro saltos mayores.

Y el matiz que evita el cuento:

> 🧠 **Nada se rompió a lo grande precisamente porque MongoDB es muy bueno en
> compatibilidad hacia atrás. El 95% siguió funcionando y por eso nadie miró. La
> excelencia del proveedor es lo que permitió el abandono.** Paradoja real, sin
> villanos fabricados.

Y el otro, que dice **dónde** poner los ejercicios sin adivinar: los fallos se
concentran donde alguien esquivó el framework. `spring-data` absorbe casi todo;
lo que no absorbe es el `mongoTemplate` con un `Document` armado a mano que
alguien escribió para ir más rápido.

Pieza forense ⭐: **el incidente cuyo `git log` está vacío.** El alumno hace lo que
hace siempre —`git log`, `git blame`, revisar el último despliegue— y no encuentra
nada, porque no hay nada. El cambio no está en el árbol de fuentes.

Y el remate que cierra el círculo con `be05`: **nadie convierte un standalone en
replica set durante un bump de versión.** La topología de 2019 sobrevive intacta.
La transacción sigue siendo imposible en 2026 — y ahora, además, el manual dice
que se puede.

### 🧯 be08 — La contención medida, y la declaración de lo irrecuperable (10h)

El cierre, y **no es código**: es un entregable que el alumno defiende. Pero llega
con tres piezas construidas y medidas.

**1. Retrofit de `$jsonSchema` en modo `warn`.** Poner validación sobre datos
sucios es un tema en sí mismo: primero se mide cuánto rechazaría, se decide qué se
tolera, y solo entonces se sube a `error`. El número de documentos que no pasan es
la mitad del contenido.

**2. Outbox hacia un Postgres de lectura**, solo para lo normativo y el dashboard.
*Strangler* por read-model, **no por reescritura**: el sistema operativo sigue en
Mongo hasta que muera. Se mide la latencia del outbox y se declara la ventana de
inconsistencia.

**3. El libro de correcciones** de `be05`, ya en producción.

Y el entregable escrito, que es lo más valioso del track:

> 🧭 **La declaración de lo irrecuperable.** Qué historia se perdió, desde cuándo,
> por qué, y **qué se le contesta al auditor**. Firmada, fechada, con números.
> Ningún tutorial de internet enseña a escribir esto, porque todos terminan en el
> *happy path* del rewrite.

Y el árbol de veredicto honesto, con las cuatro opciones costeadas: migrar a
relacional (el coste real, no el optimista), convertir a replica set, contener y
documentar, o no hacer nada. Con la regla que gobierna la fase:

> 🧭 **La respuesta correcta depende de la fecha de decomisión, no de la calidad
> del código.** Un sistema con dos años de vida por delante y uno con diez no
> reciben la misma respuesta aunque el código sea idéntico. **LabCore tiene dos.**

Aquí también se cierra la estrategia de pruebas del track (⚠️ 2 de §5.5): qué se
prueba contra un Mongo real, qué no, y por qué.

---

## 📎 8. Los apéndices

Consulta, no lectura corrida. Se abren cuando una fase manda a ellos. Entre 5 y 10
ejercicios cortos cada uno, contra el laboratorio propio.

| Archivo | Qué resuelve |
|---|---|
| `bea-01-java-8-y-spring-para-quien-no-escribe-java.md` | Java 8 mínimo para un senior de otro lenguaje: paquetes, Maven y el `pom.xml`, excepciones checked, anotaciones, inyección de dependencias, y el modelo de hilos de Spring MVC |
| `bea-02-receta-de-imagen-y-compose.md` | **La receta rápida.** El `compose.yaml` de §5.3 copiable, el `.env` con `MONGO_TAG`, el volumen `m2`, los comandos de arranque, y los tres errores que salen siempre. Cerrado y autocontenido |
| `bea-03-modelar-documentos-embeber-o-referenciar.md` | La decisión que LabCore tomó cinco veces sin escribirla: cuándo embeber y cuándo referenciar, el límite de 16 MB, los arreglos que crecen sin techo, y qué se paga en cada caso |
| `bea-04-agregaciones-como-instrumento-de-medida.md` | El framework de agregación **para auditar, no para servir**: `$objectToArray`, `$type`, `$group`, `$lookup`, `$facet`. Cómo se mide la forma real de una colección |
| `bea-05-indices-y-explain-en-mongodb.md` | Índices compuestos, la regla ESR, índices parciales y TTL, y cómo se lee un `explain()` — incluido el `COLLSCAN` que el repository de Spring escondía |
| `bea-06-jsonschema-sobre-datos-sucios.md` | Validación retroactiva: `$jsonSchema`, los niveles `off`/`warn`/`error`, `validationAction`, y el procedimiento para subir el nivel sin tumbar producción |
| `bea-07-transacciones-replica-sets-y-el-standalone.md` | Por qué un standalone no puede, qué cuesta convertirlo, el *write concern* y el *read concern*, la idempotencia como sustituto, y el patrón de asiento compensatorio |
| `bea-08-tiempo-zonas-y-fechas-en-mongo.md` | UTC como única verdad, `BSON Date` y lo que **no** guarda, `America/Bogota`, el reloj del cliente como fuente de bugs, y por qué el `-05:00` del `db.json` importa |
| `bea-09-cassandra-la-tentacion-y-el-acierto-que-nadie-tuvo.md` 🔴 | Las dos mitades del mismo círculo. **La tentación:** el nuevo arquitecto propone Cassandra "porque escala"; se modela contra el patrón de acceso real de LabCore y se **mide** que es peor, porque la tabla se diseña por consulta y aquí hay demasiadas. **El acierto:** dónde Cassandra sí era la respuesta y nadie la usó — la telemetría del analizador, serie temporal pura. No era mala la tecnología: estaba en el módulo equivocado |
| `bea-10-riesgo-de-licencia-sspl.md` | **Tu deuda técnica la creó un abogado.** El cambio de MongoDB a SSPL en 2018, el de Elasticsearch, el precedente de Akka pasando a BSL en 2022, qué significa cada uno para una empresa que solo *usa* el producto, y cómo se lee una licencia antes de elegir. Con la nota de RethinkDB: *elegiste bien y perdiste igual* |
| `bea-11-mapa-de-deuda-del-track-be.md` | Qué quedó feo a propósito en el backend, qué lo vuelve exigible y en qué orden se pagaría. ⚠️ **Corregido al escribirlo (10/09/2026):** el track base de este curso **no tiene** mapa de deuda —`a12` es el de arm64/Apple Silicon— así que este apéndice no tiene hermano; sus 💸 se declaran dentro de cada fase. La divergencia queda declarada en el propio apéndice |
| `bea-12-datos-de-prueba-y-volumen.md` 🔥 | Sembrar y generar: la semilla desde el `db.json` propio, volumen sintético para que las mediciones de `be02` y `be05` digan algo, datos deterministas con semilla fija, y **por qué un dataset aleatorio arruina una prueba de regresión** |

`bea-02` es el que más cuidado necesita: es el único punto donde el track toca
contenedores, y tiene que funcionar de principio a fin **sin remitir a nada
externo**, aunque exista `docker-container-legacy` en el catálogo.

`bea-09` y `bea-10` son los dos apéndices que hacen que el track no sea un curso
de Mongo: uno demuestra con números que la alternativa de moda es peor, y el otro
saca la conversación del terreno técnico por completo.

---

## 📐 9. Convenciones de archivo

Fases: **`be00-tema.md` a `be08-tema.md`**. Apéndices: **`bea-01-tema.md` a
`bea-12-tema.md`**. Minúsculas con guiones, dos dígitos, igual que el track base.

El prefijo `be` mantiene los cuatro bloques ordenados y separados dentro del mismo
directorio, sin subdirectorios: las fases base (`00-` a `14-`), sus apéndices
(`a01-` a `a13-`), las piezas forenses (`forense-fase-NN.md`) y el track BE.

> 📝 **Sobre `bea-01-` frente a `bea01-`.** El track base de este curso usa
> `aNN-` (`a09-kubernetes.md`), así que `bea09-` habría rimado mejor localmente.
> Se elige `bea-NN-` porque es la convención que ya está registrada en el
> `CLAUDE.md` del repositorio y la que usa el track BE de React. **Un solo
> nombre para la misma cosa en todo el repositorio vale más que la rima local.**
>
> 🪦 **Renombrado el 10/09/2026: la convención era `be-a-NN-`.** Tres segmentos
> separados por guion antes del tema (`be-a-02-receta…`) se leían como tres cosas
> en vez de una, y el prefijo era fácil de escribir mal. Con `bea-` como prefijo
> único, el nombre tiene la misma forma que el resto del repositorio:
> `<prefijo>-<número>-<tema>`. El cambio se aplicó a los dos cursos que ya tenían
> archivos —React 16 y este— y a todas las referencias cruzadas.

Archivos nuevos del track, fuera de fases y apéndices:

| Archivo | Qué es |
|---|---|
| `cuaderno-incidentes-be.md` | Los 12 incidentes del track BE, con sus IDs propios. **Separado del `cuaderno-incidentes.md` base a propósito:** un alumno que solo hace el track base no debe recibir incidentes de Mongo mezclados con los suyos |
| ~~`prompts/plantilla-de-incidente-be.md`~~ | 🪦 **No hizo falta (10/09/2026).** El formato **no** diverge: la plantilla de incidente de `formato-cuaderno-incidentes.md` §8 se usó literal. Lo propio del track —las cuatro formas de preparación y la excepción de `be-11`— vive en la §🔥 de ese mismo documento. Un archivo aparte habría duplicado la fuente de verdad |
| `prompts/prompts-backend-fase.md` | Los prompts **A** de redacción de fases BE. Archivo nuevo, no adición a `prompts-extendidos-fases.md` |
| `prompts/prompts-backend-apendice.md` | Ídem para apéndices |

**No hay `forense-be-NN.md`.** Es una divergencia explícita respecto del track
base, y esta es la razón: los archivos `forense-fase-NN.md` existen para sostener
capturas de DevTools, recetas de breakpoints y flujos de Network, que no caben en
la fase. La pieza forense de este track es una agregación, un `explain()` o un log
de `mongod` — **cabe en la §6 de la fase y se lee mejor ahí**, junto al código que
la produce. Si al escribir `be02` o `be05` la §6 se desborda, se revisa esta
decisión y se declara el cambio.

El código del backend se referencia como `server/…` dentro del mismo proyecto del
alumno. El frontend sigue en la raíz, sin moverse.

**Tags de git:** `be-fase-` + el mismo slug del archivo, en un namespace propio
para que `git tag -l 'fase-*'` siga siendo el índice limpio del track base
(`be00-el-contrato-auditoria-del-mock.md` → `be-fase-00-el-contrato-auditoria-del-mock`).
Los commits llevan prefijo `be00: …`, y los de ejercicio `be00 ej17: …`. Se
registra en `00-convencion-de-git-y-tags.md` (§10).

**Los nueve nombres, ya fijados.** Se declaran aquí y no en los prompts, para que
este documento siga siendo la fuente de verdad; `prompts-backend-fase.md` los
copia y nunca al revés.

| Fase | Archivo | Tag |
|---|---|---|
| be00 | `be00-el-contrato-auditoria-del-mock.md` | `be-fase-00-el-contrato-auditoria-del-mock` |
| be01 | `be01-java-spring-y-la-forma-del-monolito.md` | `be-fase-01-java-spring-y-la-forma-del-monolito` |
| be02 | `be02-medir-la-deriva-de-esquema.md` | `be-fase-02-medir-la-deriva-de-esquema` |
| be03 | `be03-la-costura-y-el-reemplazo.md` | `be-fase-03-la-costura-y-el-reemplazo` |
| be04 | `be04-el-audit-log-que-escribia-el-navegador.md` | `be-fase-04-el-audit-log-que-escribia-el-navegador` |
| be05 | `be05-la-cadena-de-custodia-y-la-transaccion.md` | `be-fase-05-la-cadena-de-custodia-y-la-transaccion` |
| be06 | `be06-los-rangos-y-la-historia-perdida.md` | `be-fase-06-los-rangos-y-la-historia-perdida` |
| be07 | `be07-la-subida-que-nadie-decidio.md` | `be-fase-07-la-subida-que-nadie-decidio` |
| be08 | `be08-la-contencion-y-lo-irrecuperable.md` | `be-fase-08-la-contencion-y-lo-irrecuperable` |

---

## 🔧 10. Documentos existentes que hay que tocar

Ninguno de estos cambios altera el contenido del track base; todos son adiciones
de encuadre. Se hacen **antes** de escribir `be00`, para que las fases nuevas
tengan a qué referirse.

1. **`README.md`** — sección nueva del track opcional 🔥, con su tabla de nueve
   fases, su tabla de doce apéndices, sus 80h + 8h declaradas **aparte de las
   122**, y el prerrequisito (Fase 11 terminada).
2. **`00-historia-del-sistema.md`** — el párrafo que abre el track. La historia ya
   dice *"el backend estaba congelado y era de otro equipo"*; hace falta **una
   frase más**: qué pasó con ese equipo y desde cuándo el backend es tuyo. Es la
   adición mínima, y no contradice nada de lo publicado.
3. **`prompts/guia-de-estilo-y-convenciones.md`** — registrar la convención
   `beNN-` / `bea-NN-`, el anexo Java del diccionario de código
   (`Patient`, `Order`, `Sample`, `Result`, `ReferenceRange`, `CustodyLink`), las
   reglas de estilo de Java 8 de §4, y que la plantilla de nueve secciones también
   aplica al track BE.
4. **`prompts/alcance-del-proyecto.md`** — el track BE en la sección de alcance,
   con su declaración explícita de opcionalidad y sus horas fuera del calendario.
5. **`00-convencion-de-git-y-tags.md`** — el namespace `be-fase-*`, el prefijo de
   commit `beNN:`, y la nota de que el "cambio" de `be07` **no es un commit**: es
   una línea del `.env`, y por eso ese incidente no tiene par `-roto`/`-fix`.
6. **`prompts/propuesta-fases-y-alcance.md`** — una línea en §9 apuntando aquí,
   para que ese documento siga siendo el índice de encuadre del curso.
7. **`cuaderno-incidentes.md`** — una nota de que existe un cuaderno hermano para
   el track BE, sin reservar IDs en el base. Los rangos son independientes.
8. **`CLAUDE.md`** (raíz del repositorio) — extender la nota de *File Naming
   Conventions* para decir que la convención `beNN-` / `bea-NN-` ya no es solo
   del curso de React.

---

## ⚖️ 11. Riesgos y decisiones de detalle

### Los tres riesgos que hay que vigilar

**Que se convierta en "curso de MongoDB".** Es el riesgo grande. La defensa:
**cada fase tiene que poder responder qué deuda cobra y con qué número**. La que
no pueda, sobra. `be02` y `be03` son las más expuestas y las que hay que vigilar
al escribirlas.

**Que Mongo quede como villano.** Sería traicionar el criterio del repositorio.
La defensa ya está escrita en §3.2 y tiene que aparecer **en `be00`**, antes de la
primera factura: el panel de resultados de laboratorio **es** un documento, y el
equipo de 2019 acertó en eso.

**El riesgo de contrato.** El frontend consume detalles del dialecto de
json-server que hoy no están inventariados en ninguna parte. Si `be00` los audita
mal, `be03` falla y el alumno pierde la fe en el track. Por eso `be00` se apoya en
una **captura real de Network** y no en la lectura del código del mock.

### Cinco decisiones de detalle, ya cerradas

**El corte de entrada es la Fase 11.** Es el punto exacto donde el dominio está
completo *y* el audit log existe, que es lo que `be04` viene a cobrar. Las fases 12
(testing), 13 (despliegue) y 14 (kind) no aportan nada al contrato y quedan fuera
del prerrequisito.

**El caos se controla por los dos caminos**, igual que en el mock: la variable
`CHAOS` porque un ambiente que nace degradado es la forma de reproducir un
incidente sin tocar el proceso, y el header porque las prácticas del track base lo
usan tal cual. Apagado por defecto en los dos casos.

**La semilla sale del `db.json` del propio alumno.** No se entrega un dump. Que
los datos que aparecen tras el reemplazo sean exactamente los que el alumno vio en
el track base es la mitad del efecto de `be03`.

Dicho eso, la semilla real no alcanza para todo: tres pacientes no permiten medir
deriva de esquema ni encontrar eslabones huérfanos. Por eso `be02` entrega
**además** un dump sintético "de producción" con las cinco formas del documento y
las referencias rotas ya adentro. Es la única vez que el track entrega datos
ajenos, y la fase lo declara.

🪦 **La forma exacta del dump quedó cerrada al escribir `be02` (10/09/2026)** y
vive en su §5.3: 4.820 pacientes repartidos en cinco formas —la actual (2.443);
la de 2019 sin `active` (747); la de la importación de 2020 con `name` y
`_source` en vez de `fullName` (718); la de 2021 con el correo movido a un
subdocumento `contact` y `birthDate` como `BSON Date` (848); y un intento previo
de ese mismo cambio con `phone` al nivel superior (64)—, más 37 órdenes
huérfanas, la partición 3908/912 de tipos en `birthDate` y las tres poblaciones
de vacío en `email` (1630 ausente / 912 `null` / 247 cadena vacía). Generador
determinista con semilla fija en `bea-12`. **El dump vive en una base aparte de
la semilla del alumno**, decisión de `be03`, para que las mediciones sigan siendo
reproducibles mientras la aplicación corre sobre datos limpios.

**El Postgres de `be08` es read-model y nada más.** No sirve tráfico del frontend,
no participa del contrato, y `smoke.sh` no lo toca. Si en algún momento una fase
propone moverle escrituras, esa fase está mal diseñada.

**El track no vende MongoDB ni Java.** Vende el **método** para diagnosticar un
sistema cuyo modelo de datos se volvió un pasivo, y para defender por escrito la
decisión de no migrarlo. Conviene decirlo en el README con esas palabras.

---

## 🎯 12. Criterio de éxito del track

No es *"el alumno aprendió MongoDB"*. Es esto, y se verifica:

Puede tomar un contrato de API existente y reimplementarlo sin romper a quien lo
consume. Sabe **medir** la forma real de una colección en vez de suponerla desde
el modelo del código. Sabe qué garantía le da y cuál no le da su topología de
despliegue, y puede citar el mensaje de error que lo demuestra. Sabe distinguir un
dato que se puede reconstruir de uno que se perdió, y sabe escribir la diferencia
en un documento que un auditor va a leer. Y sabe defender, con la fecha de
decomisión en la mano y con números, **cuándo migrar es la respuesta equivocada**.

> **La señal de que quedó bien:** *"levanté el backend de 2019 con mis propias
> manos, medí lo que costó, contuve lo que se podía contener, y escribí por qué no
> vamos a arreglar el resto. Y el frontend nunca se enteró de nada."*
