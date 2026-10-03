# 🎯 Alcance del proyecto
## Ruta SQL — La base que nadie diseñó

> **Qué es este documento:** la fuente de verdad de **qué** enseña el curso, a quién y con
> qué límites. Lo que no esté aquí no está en el curso.
> **Fecha de esta versión:** 30 de septiembre de 2026. Sale de la propuesta de diseño, que queda
> como registro en `_desechable-propuesta-ruta.md` y no se cita.
> **Precedencia:** manda este documento. Después viene
> [`guia-de-estilo-y-convenciones.md`](guia-de-estilo-y-convenciones.md), que decide **cómo** se
> escribe, y después las dos propuestas de alcance. Las plantillas y los prompts se actualizan
> siempre al final. Por encima de todos está el `CLAUDE.md` del repositorio, en lo que este curso
> no haya declarado como excepción (§12).
> **Estado de las decisiones:** todas cerradas por Oskar el 30/09/2026 (§12). Su registro vive en
> [`propuesta-fases-y-alcance.md`](propuesta-fases-y-alcance.md) §12. Lo que depende de la
> verificación de laboratorio (versiones, digests y conteos de los perfiles) se fija en `a02` y
> `a05` cuando esa verificación esté hecha.

---

## 1. 🧭 En una frase

**Un curso que enseña a mirar una base de datos relacional como un problema de optimalidad con
tradeoffs, tomando el sistema de un laboratorio clínico que nadie diseñó y rediseñándolo con
mediciones propias en tres motores.**

No forma DBA de ningún producto. Forma la capacidad de mirar un esquema y decir *"esta tabla
necesita esta restricción por esta razón, este índice cuesta esto en cada escritura, este nivel de
aislamiento deja pasar esta anomalía, y esta parte del sistema no es relacional"*, con la medición
encima de la mesa.

---

## 2. 🔥 El problema que resuelve

La Ruta NoSQL Lite afirma en su primera fase que *"la mayoría de las veces gana Postgres"*, y no lo
demuestra: su trabajo es buscar los casos donde no alcanza. **Este curso es el que se gana esa
frase.**

El villano es el mismo en los dos cursos: **elegir sin entender el modelo de acceso**. Aquí se ve
desde el otro lado, y tiene dos caras que en el fondo son una sola:

- **"Mongo por moda."** Descartar lo relacional sin saber lo que ofrece.
- **"La base es un pote donde creo tablas."** Usar lo relacional sin saber lo que ofrece. Es la cara
  más frecuente entre seniors y la más cara, porque se disfraza de experiencia: veinte años de
  `SELECT *` desde un ORM no enseñan qué nivel de aislamiento tiene la conexión.

Las dos son la misma decisión, tomada por el mismo motivo malo: lo que se usó para decidir fue
*qué me resulta familiar*, y no *qué modelo de acceso tiene este dominio*.

Laboratorio Alameda (§7) agrega una tercera variante, la más común en la pequeña empresa
latinoamericana: **nadie decidió nada**. Un contador competente armó en Access "tablas unidas por
rayitas con un formulario arriba", y durante veinticinco años eso alcanzó. El curso respeta esa
historia, porque funcionó, y la usa como material, porque cada tabla incómoda tiene un año y una
razón.

> ⚠️ **El antagonista no puede ser una persona.** Ni Rubén, que hizo "la base" de noche y sin
> cobrar, ni Florencia, que propone Mongo con un argumento que en parte es correcto, ni Verónica,
> que quiere meterlo todo en el Oracle corporativo. En la mesa está la decisión, y nunca la persona.

Y una honestidad que va dicha pronto: **"esto no es relacional" a veces es la respuesta correcta.**
El curso la da con el mismo rigor que todo lo demás, y el Bloque IV existe para eso.

---

## 3. 🎓 Objetivo pedagógico

Al terminar, el estudiante puede hacer cinco cosas que antes no podía:

1. **Diseñar un esquema que defienda sus propias reglas**: restricciones, tipos y claves que
   documentan el negocio y que el motor hace cumplir, en lugar de un parser que lo adivina.
2. **Leer y explicar un plan de ejecución** en Postgres, MySQL y Oracle: lecturas lógicas, filas
   estimadas contra reales, método de join, y qué decisión de diseño lo produjo.
3. **Elegir un nivel de aislamiento y una estrategia de bloqueo** sabiendo qué anomalía deja pasar
   cada uno en cada motor, y demostrarlo con dos sesiones concurrentes.
4. **Decidir con medición qué parte de un sistema no es relacional**, y qué versión de "lo NoSQL"
   del propio motor (`jsonb`, búsqueda, CTE recursivos) alcanza antes de sumar otro motor.
5. **Migrar un sistema en producción sin pararlo**: qué se migra primero, cómo conviven dos
   modelos, cómo se reconcilia y cómo se presenta la decisión ante un comité.

Lo que **no** es objetivo: administrar ningún motor en producción, aprobar una certificación de
producto, ni tunear parámetros de servidor más allá de lo que explica una decisión de diseño.

---

## 4. 👥 Perfil del estudiante

Ingeniero de software con experiencia, que usa bases relacionales todos los días y casi siempre a
través de un ORM o de una capa de acceso. Sabe escribir SQL, sabe qué es un índice y qué es una
transacción. **Lo que probablemente no sabe es lo que cuestan**: qué hace un índice en cada
`INSERT`, qué deja pasar su nivel de aislamiento, por qué el optimizador eligió ese plan.

**Lo que se da por sabido y no se explica jamás:** qué es SQL, qué es una tabla, un índice, una
transacción, un join, una CLI, Docker, un contenedor o JSON.

**Lo que se explica con cero ambigüedad**, aunque el lector sea senior: qué es exactamente una
dependencia funcional, qué significa cada campo de un `EXPLAIN`, qué es MVCC por dentro, qué
anomalía deja pasar cada nivel de aislamiento en cada motor, qué hace un *page split* y por qué
un UUIDv4 los provoca.

> 🧭 ***"Como para un bebé"* significa aquí ninguna caja negra prematura, no menos profundidad.** El
> lector sabe qué es un índice; el curso le enseña qué le cuesta. Si una frase obliga al lector a
> suponer algo, está mal escrita.

**Requisitos de entrada:** Docker o Podman funcionando, **16 GB de RAM** (Oracle Free no entra en
menos junto a los otros dos motores; el número exacto sale de la verificación de laboratorio), y
soltura leyendo Python. Java 21 aparece solo en el 💀 boss del puente y en el apéndice opcional
del Access de museo, los dos fuera de las 252 h.

---

## 5. 🎯 El instrumento: las cinco preguntas, desde el lado relacional

Se heredan de la Ruta NoSQL Lite y se responden desde el otro lado. Es lo que cose las dos rutas:
cada una es el contrapeso de la otra. Se presentan enteras en F02 y **reaparecen en el veredicto de
cada fase**, respondidas para lo que la fase acaba de enseñar.

1. **¿Dónde está la frontera transaccional?** Aquí pasa a ser **la carta más fuerte de lo
   relacional**. El folio fiscal correlativo, el resultado corregido con su auditoría y la factura
   con sus prácticas son invariantes que cruzan filas y tablas. Un motor relacional las defiende
   con una transacción y una restricción. Fuera de él, se defienden con código que alguien tiene
   que acordarse de mantener.
2. **¿Conoces tus consultas de antemano?** Aquí se vuelve **ventaja estructural**: el SQL ad hoc
   sobre un modelo normalizado responde preguntas que todavía no existen. El cruce epidemiológico
   que el ministerio va a pedir el año que viene no se puede modelar hoy. Tampoco hace falta.
3. **¿Cuál es la unidad de lectura?** Es la pregunta que Florencia contesta bien. Un informe de
   laboratorio *es* una unidad de lectura evidente, y el curso lo concede con números. La pregunta
   de verdad es si esa unidad también es la de escritura, la de auditoría y la de facturación.
4. **¿Cuántos saltos tiene tu relación típica, y los conoces?** La jerarquía de prácticas y la cadena
   de derivaciones son uno o dos saltos conocidos, y `WITH RECURSIVE` los resuelve. Lo que rompe al
   motor relacional es buscar un patrón de profundidad desconocida, y en Alameda no aparece.
5. **¿Necesitas exactitud o parecido?** La deduplicación de pacientes es **parecido**: `PEREZ PEDRO`
   y `PERES PEDRO JOSE` pueden ser la misma persona. Es el único lugar del curso donde el motor
   relacional tiene que hacer algo que no es su naturaleza, y `pg_trgm` muestra hasta dónde llega.

Y la pieza que cierra F02 y vuelve en el Bloque VI: **"ya está en producción, ¿ahora qué?"**, el
triaje de una base heredada que no se puede parar ni un día.

---

## 6. 📐 Cómo se mide: la forma, no la velocidad

Se hereda el principio de la NoSQL Lite. Un tiempo caduca con la versión, con el hardware y con la
carga de la máquina; una medida estructural no. *"Esta consulta lee 48.213 bloques para devolver
12 filas"* seguirá siendo cierto dentro de cinco años. *"Tarda 340 ms"* no lo es ni mañana en otra
máquina.

Lo que el curso mide:

- **lecturas lógicas** (`BUFFERS` en Postgres, `consistent gets` en Oracle, contadores `Handler_%`
  y el `EXPLAIN ANALYZE` de MySQL);
- **filas examinadas contra devueltas**, y **filas estimadas contra reales** en cada nodo del plan;
- **la forma del plan**: método de join, orden, qué índice usó y cuál ignoró;
- **tamaño**: de la fila, de la tabla, de cada índice, de la base entera y de lo que se respalda;
- **amplificación de escritura**: bytes de WAL o de redo por fila escrita, *page splits*, índices
  tocados por `UPDATE`;
- **concurrencia**: filas y relaciones bloqueadas, esperas, reintentos por fallo de serialización,
  anomalías observadas contra esperadas.

Los tiempos se anotan **como contexto, nunca como argumento**, con la máquina y la versión al lado.

### 6.1 Qué no se publica, y por qué aquí es obligación

**Las licencias de Oracle y de SQL Server prohíben divulgar resultados de benchmark sin permiso
del fabricante** (la llamada cláusula DeWitt). Ejecutarlos en privado está permitido; publicarlos
no. Eso convierte el principio de la forma en una regla con tres niveles:

| Motor | Qué se publica |
|---|---|
| PostgreSQL y MySQL | receta, apuesta y **resultado** |
| Oracle y SQL Server | la **apuesta falsable completa**: hipótesis, condiciones y comando, **sin resolver**. La resuelve el lector en su máquina. El mecanismo se explica citando la documentación oficial |
| MongoDB (F20) | receta, apuesta y resultado, como en la NoSQL Lite |

La zona gris son **los planes de ejecución** de Oracle y de SQL Server. Mientras no se decida otra
cosa (D6), se publica la **estructura** del plan (las operaciones y su orden, tal como la muestra
`EXPLAIN PLAN` sin ejecutar) y nunca sus estadísticas de ejecución (lecturas, filas reales,
tiempos). Esas últimas son parte de la apuesta que resuelve el lector.

Las corridas privadas del autor sirven para escribir bien la prosa y validar que la receta
funciona, y **viven fuera del repositorio**.

### 6.2 Las dos anclas

- 🪞 **Una apuesta falsable por fase**, escrita antes de ejecutar y nunca editada después. **La
  apuesta perdida se publica igual que la ganada**, y con más gusto.
- 💥 **Un punto de rotura por fase**: el volumen, la concurrencia o el dato sucio exacto con que el
  diseño se rompe, con el mensaje de error literal y lo que costó salir.

---

## 7. 🧪 El dominio: Laboratorio Alameda

Un dominio único para todo el curso. La empresa, su gente, su genealogía y su inventario viven en
[`00-historia-de-alameda.md`](../00-historia-de-alameda.md), que es **la fuente de todo lo
narrativo**. Este apartado fija solo lo que el modelo de datos necesita.

**Laboratorio Alameda** es un laboratorio de análisis clínicos de Córdoba (Argentina), fundado en
1996, absorbido por la Clínica Mediterránea en 2011 y por la red Horizonte Salud en 2022. Hoy es el
laboratorio central de la red para el interior del país y procesa unos 3.000 protocolos por día.
Su sistema, "la base", empezó en Access 97, pasó a SQL Server Express por el asistente de
*upsizing* y convive con un portal PHP sobre MySQL y con el SIH de la red, construido sobre Oracle.

> ⚠️ **El curso no enseña bioquímica, facturación sanitaria ni derecho argentino.** Nomenclador,
> obras sociales, débitos y factura electrónica están simplificados hasta el punto exacto en que
> le sirven al modelo de datos. Si algo choca con la realidad del oficio, gana el modelo de datos,
> y el glosario (`a07`) traduce los términos para quien no es de Argentina.

**Las entidades del modelo nuevo**, con nombres fijos en inglés y en `snake_case` en los tres
motores:

- `patient`: la persona. **No es su documento**, y no tiene documento como clave.
- `identity_document`: tipo, país emisor y número, con vigencia. Una persona tiene varios a lo
  largo del tiempo.
- `lab_order`: el **protocolo**, la orden que entra al laboratorio. Su número visible es
  `protocol_number`.
- `order_item`: la práctica solicitada dentro de un protocolo.
- `practice`: la práctica del nomenclador, con sus códigos (`INOS`, `NBU`, `NBU 2012`) como catálogo
  versionado.
- `analyte`: la **determinación**, lo que mide un equipo (glucemia, hematocrito), con su unidad.
- `result`: el valor informado de una determinación en un protocolo, con su historia de
  correcciones.
- `reference_range`: el rango de referencia por sexo, edad y método, con vigencia.
- `specimen`: la muestra, que viaja entre sedes.
- `payer`: la **obra social** o prepaga.
- `agreement`: el **convenio** entre un pagador y el laboratorio, con precios y vigencia.
- `site`: la sede (el laboratorio central y los centros de extracción).
- `physician`: el médico derivante.
- `invoice`: el comprobante fiscal, con su numeración correlativa por punto de venta.
- `appointment`: el turno.

**El esquema heredado se carga tal cual**, en el esquema `legacy` de cada motor. Los nombres de sus
tablas y columnas son datos de la historia y se conservan exactamente como salieron de "la caja"
(`legacy."Pacientes"`, `legacy."ResultadoItem"`, `legacy."Precios_2002_09"`). Es la única excepción a
la regla de identificadores en inglés, y se declara en la guía.

**La frontera transaccional del dominio es el comprobante fiscal**: el número que exige el web
service del organismo recaudador tiene que ser el último autorizado más uno, sin huecos y sin
duplicados. El curso la vuelve a encontrar en el Bloque III, en el V y en el capstone.

**Cómo ilumina cada bloque, sin forzar nada:**

| Bloque | La parte de Alameda que le toca |
|---|---|
| I · El modelo | `PEREZ PEDRO DNI 23456789`, las 71 tablas anchas y el EAV, `Precios_2002_09` |
| II · La física | el frontal Access que trae tablas enteras por ODBC, el portal enumerado, el 1,1 TB de PDF |
| III · La concurrencia | `DMax + 1`, `UltimoNumero` y el error del web service fiscal; el formulario abierto al almuerzo |
| IV · Lo NoSQL en SQL | la propuesta de Florencia: el informe como documento |
| V · La base en la red | la exportación que termina a las 9:40, la interfaz con el SIH, la app que abre el portal de 2013 |
| VI · El árbitro | las tres propuestas ante el comité, y la migración sin parar un día |

### 7.1 La caja, y los volúmenes

**El lector no recibe una base, recibe "la caja"**: el volcado que Matías armó en un fin de semana
(historia §3, 2026). Trae cada tabla de `ALAMEDA` en CSV (un par en Latin-1, a propósito), el DDL
de T-SQL que generó SSMS, los módulos VBA de Rubén como `.bas`, la versión en T-SQL del parser,
el `.accdb` de turnos exportado a CSV con el multivalor separado por punto y coma, las planillas
que llegan de afuera (padrones, NBU, convenios, la planilla de notificación de la pandemia) y, en
lugar del terabyte de imágenes, un CSV con el nombre y el tamaño de cada archivo.

**Los datos son sintéticos, con semilla determinista, y reproducen la suciedad**: nombres con el
DNI adentro, recién nacidos con el DNI de la madre, fechas de nacimiento en el futuro, valores con
coma y con punto, duplicados plausibles. **El generador conoce la verdad**: sabe qué registros son
la misma persona y qué valor quiso escribir cada equipo. Eso permite medir la calidad de una
deduplicación o de una limpieza contra un dato cierto, y es una de las piezas más valiosas del
curso.

**Tres perfiles de volumen** (D4), y **el laboratorio trabaja por defecto con S y M**:

- **S**, el perfil por defecto de `lab load`, para los ejemplos y el desarrollo;
- **M**, donde se hacen las mediciones publicadas;
- **L**, opcional y nunca por defecto. Ninguna fase lo exige: si un punto de rotura necesita más
  volumen, la fase publica lo que salió con M y deja L como ejercicio 🔥.

La historia habla de 1,9 millones de pacientes y 140 millones de `ResultadoItem`, y eso no entra
en un laboratorio de 16 GB junto a Oracle. El perfil M apunta a unos 200.000 pacientes y unos
15 millones de filas de resultados, con una condición que manda sobre el número: **M tiene que
entrar en 16 GB con los tres motores arriba**. Si en la verificación de laboratorio no entra, se
achica M; no se sube el requisito de memoria. Los conteos finales se fijan en `a05`. Las
proporciones de la historia se conservan: el porcentaje de duplicados, de pacientes nacidos en el
futuro, de valores no numéricos.

---

## 8. 🗄️ Los motores y su reparto

No simétricos. Tres manuales de producto en paralelo no enseñan a decidir: cada motor entra donde
su mecanismo interno **cambia la decisión**.

| Motor | Rol | Por qué está |
|---|---|---|
| 🐘 **PostgreSQL** | laboratorio principal e hilo conductor | abierto, arm64 nativo, `jsonb`, SSI real, restricciones de exclusión, PostgREST |
| 🏛️ **Oracle** (edición Free) | caso de estudio | *undo*, el `SERIALIZABLE` que es *snapshot isolation*, hints y *baselines*, JSON Relational Duality Views, ORDS; y el SIH de la red |
| 🐬 **MySQL** (8.4 LTS) | contraste recurrente | InnoDB *clustered* (el caso UUID sin emulación y sin cláusula DeWitt), *gap locks*, JSON sin GIN, DDL online, el portal de 2013 |
| 🪟 **SQL Server** | **track opcional** | concurrencia pesimista por defecto contra RCSI, Query Store, Data API builder; es "la base" en su motor original |
| 🍃 **MongoDB** | invitado de F20 | la propuesta de Florencia, medida en su terreno |

**MariaDB queda fuera**, con una nota en el diccionario: ya divergió de MySQL lo suficiente (JSON
como alias de `LONGTEXT`, GTID incompatible) como para no representarlo, y lo que tiene de
atractivo lo cubren Oracle y SQL Server.

**Ninguna versión de esta tabla está verificada.** Las versiones y los digests se fijan
ejecutando, en la verificación de laboratorio (tanda P8), y quedan escritos en `a02` con su fecha.
Hasta entonces ningún documento del curso publica un número de versión. Dos riesgos declarados:
que la imagen de Oracle Free funcione en arm64 sin emulación, y que la de SQL Server arranque con
Rosetta en Docker Desktop **y** en Podman.

---

## 9. 🧰 El stack del laboratorio

**El lenguaje más simple que encaje en la narrativa.** Sin dogma, pero con un default:

- **SQL es el lenguaje del curso.** Casi todo se resuelve en el motor, y cuando no se puede, eso ya
  es un hallazgo.
- **Python para todo lo demás**: el generador y la carga de la caja, la lectura de los Excel, el
  port del parser, el arnés de medición y las simulaciones de concurrencia (dos recepcionistas
  pidiendo folio a la vez son dos hilos). Se gestiona con `uv` y un `uv.lock`, como en la Lite.
- **Java 21 solo donde la narrativa lo pide**, y en dos lugares, los dos opcionales: el 💀 **boss
  del puente** (§13), que es el mundo de la red (un servicio chico, hecho sin demasiada ingeniería,
  con ActiveMQ Artemis y mensajes que imitan HL7 v2), y el **Access de museo** (`a10`), porque
  Jackcess es Java. Nunca como segunda vía para lo mismo.
- **PostgREST reemplaza el código de aplicación** en F23. El cliente de la app se simula con `curl`
  o con un script corto de Python.
- **El curso no requiere Access, ni Windows, ni SQL Server.** Access existe en la historia y, como
  pieza opcional, en `a10`.

Esto se aparta de la NoSQL Lite (TypeScript por defecto) a propósito: aquí el protagonista es el
motor, no la aplicación.

**Contenedores:** Docker Compose como camino principal, **cada receta con su equivalente Podman**, y
sin Kubernetes en ninguna parte.

**El Access de museo.** El taller `taller/accdb-museo/` comprobó el 29/09/2026 que se puede
generar un `.accdb` real sin Office (Jackcess), consultarlo con SQL (UCanAccess) y ejecutar el
`.bas` de Rubén en LibreOffice Basic sin interfaz, y que el parser **depende de la configuración
regional de la PC** (40 de 40 aserciones en `es-AR`, 31 de 40 en `en-US`). Ese material pasa a
`a10` y a `src/a10-el-access-de-museo/` en su tanda. **Nadie lo necesita para hacer el curso**: el
insumo oficial es la caja en CSV.

---

## 10. ✅ Lo que está dentro del alcance

- Cargar un sistema heredado sucio tal cual y rediseñarlo con restricciones que el motor hace
  cumplir.
- Normalización de la 1FN a la 5FN con dependencias reales, la 6FN y el modelado temporal, y el
  criterio de cuándo normalizar estorba.
- Identidad de entidad: claves naturales contra sustitutas, maestro de pacientes y deduplicación
  medida contra la verdad del generador.
- Diseño físico: páginas, *heap* contra *clustered*, identificadores, índices y su costo,
  estadísticas, particionado como diseño y qué va en la base.
- El optimizador en tres motores y el tuning de consultas.
- Aislamiento, MVCC, bloqueos y DDL online, comparados entre motores.
- JSON, búsqueda, CTE recursivos y vectores dentro del motor relacional, y dónde se rompen.
- Integración entre bases: lote contra flujo, CDC, *outbox*, colas en la base e idempotencia.
- La base como producto: PostgREST, seguridad por fila y el esquema como contrato.
- La migración sin parar y la decisión defendida ante un comité.
- El ⚰️ anti-patrón de cada tema con números antes y después, y el ⚖️ veredicto de cuándo **no**.

## 11. 🚫 Lo que está fuera del alcance

- **Operación en producción** (D2): réplicas, alta disponibilidad, respaldo y PITR, *tuning* de
  servidor. Se nombran cuando explican una decisión de diseño, nunca como tema. El respaldo de seis
  horas de Alameda se resuelve como problema de **modelo** (qué va en la base), y se mide por
  tamaño.
- **Kubernetes y orquestación**, ni aquí ni en los apéndices.
- **Pedagogía de Docker.** Los apéndices dan la receta; el mecanismo está en
  `cursos-contenedores-cloud-infra/docker-container-legacy/` y se enlaza.
- **Servicios gestionados de nube** (RDS, Aurora, Atlas, Autonomous). Se mencionan en los
  veredictos y no se levantan.
- **MariaDB** (§8), y cualquier comparativa de producto que no cambie una decisión.
- **ORMs.** Se nombran cuando producen el problema (el N+1, el hi/lo), y el curso trabaja siempre
  con el SQL que generan.
- **Programación en PL/pgSQL, PL/SQL o T-SQL como tema.** Aparecen donde la lógica en la base es
  la decisión en discusión (F23), no como lenguaje a aprender.
- **Miniproyectos de otras empresas** (D5): todo el curso gira alrededor de Alameda.

---

## 12. ⚖️ Decisiones cerradas

Si una sesión futura quiere cambiar una, primero la cambia aquí y después en todo lo demás, nunca
al revés. De la 13 en adelante son las que cerró Oskar el 30/09/2026 (registro en
[`propuesta-fases-y-alcance.md`](propuesta-fases-y-alcance.md) §12).

1. **Idioma:** español latinoamericano neutro con tuteo. Código, comandos, nombres de archivo,
   identificadores y salida de terminal en inglés; comentarios de código en español con tildes.
2. **Dominio único: Laboratorio Alameda** (§7), con la historia como fuente de verdad narrativa.
3. **Motores no simétricos** (§8): Postgres principal, Oracle caso de estudio, MySQL contraste,
   SQL Server track opcional, MongoDB invitado de F20. MariaDB fuera.
4. **Se mide la forma, no la velocidad** (§6), con una apuesta falsable y un punto de rotura por
   fase.
5. **Regla de publicación por licencia** (§6.1): resultados de Oracle y SQL Server nunca
   publicados; sus apuestas van sin resolver.
6. **Nada se publica sin haberse ejecutado.** Lo que no se verificó se declara con esas palabras.
7. **Imágenes fijadas por digest**, con fecha de verificación visible y en un solo sitio (`a02`).
8. **Punto de partida: la caja en CSV** (§7.1). Sin Access, sin Windows y sin SQL Server como
   requisito.
9. **Stack: SQL + Python con `uv`**; Java 21 solo en el boss del puente y en `a10` (§9).
10. **Carga horaria: 252 h ≈ 21 semanas a 12 h semanales**, la misma de la NoSQL Lite.
11. **Ejercicios: 20–30 por fase**, con la exención de F00 y F02 (12) por ser fases de criterio.
12. **Apéndices transversales**, diez, de receta y no de pedagogía.
13. **D1 · Estructura:** 27 fases (F00–F26) en siete bloques, con un Bloque I de seis fases de
    8 h. Detalle en la propuesta de fases.
14. **D2 · Operación fuera**, salvo el particionado como diseño y la pregunta de qué va en la base
    (F09).
15. **D3 · El puente Java con Artemis es un 💀 boss**, no el laboratorio de F22. F22 enseña la
    integración dentro de la base (SQL + Python); el boss mide si hacía falta un broker.
16. **D4 · Perfiles S, M y L, con S y M por defecto**, y M acotado por la memoria de un equipo de
    16 GB (§7.1).
17. **D5 · Sin miniproyectos de otras empresas**: todo el curso gira alrededor de Alameda.
18. **D6 · El repositorio se trata como público** a efectos de la regla de publicación, y de los
    planes de Oracle y SQL Server se publica solo la estructura (§6.1).
19. **D7 · Nombre:** Ruta SQL, en `cursos-bd/ruta-sql/`. En texto visible, siempre "Ruta SQL".
20. **D8 · Track SQL Server:** cinco fases `ss01`–`ss05` y un apéndice `ssa-01`, unas 40 h fuera
    de las 252.
21. **D9 · Boss:** cinco de bloque (I a V), el 💀 boss del puente en Java y el boss global
    acumulativo **"Un martes"** (§13).
22. **D10 · Nombres:** en inglés, con la convención habitual del mundo SQL (`snake_case`, tablas en
    singular) y **palabras completas**, sin abreviar, mientras quepan en el límite del motor más
    restrictivo (guía §5). El esquema `legacy` conserva los nombres originales de la caja.
23. **D11 · Java 21 LTS**, solo en el boss del puente y en `a10`.
24. **D12 · Versiones:** la última estable de cada motor, o la última LTS donde el fabricante
    publica una línea LTS, **a la fecha de la verificación de laboratorio**. Se fijan por digest
    en `a02` y no se persiguen después.
25. **D13 · `legacy` se carga donde hace falta**: en Postgres siempre; en MySQL y en Oracle, solo
    las tablas que pide cada fase (`a05`).
26. **D14 a D16:** el arnés de carreras determinista (`lab race`), el Access de museo como `a10`
    opcional y el punto de rotura de las fases de plan como precipicio del plan, con la línea que
    cambió.

**Excepciones declaradas al `CLAUDE.md` del repositorio**, con su porqué:

- **`BENCHMARKS.md` se sustituye por `bitacora-de-medicion.md`**, por dos motivos. Uno es de fondo:
  el curso mide la forma y no la velocidad, y un archivo de latencias es justo el artefacto que
  envejece mal. El otro es legal: **las entradas de Oracle y SQL Server no pueden llevar resultado**
  (§6.1), y un `BENCHMARKS.md` con la mitad de las filas vacías sería peor que ninguno.
- **"Verificar todo 'mejor que' contra `BENCHMARKS.md`" no aplica a Oracle ni a SQL Server.** Allí
  una comparación se sostiene con la documentación oficial y con la apuesta sin resolver, y se dice
  así en el texto.
- **Los apéndices son transversales al curso**, no por fase ni por bloque.
- **`INSTINTOS.md` se mantiene y es central.**

---

## 13. 🏆 Los proyectos boss

- 🏆 **"Un martes" — el boss global.** El `LEEME.txt` de Matías termina con *"cualquier cosa me
  llaman, pero no los martes que es día de facturación"*. El boss global es la base nueva de
  Alameda construida bloque a bloque, y termina cuando **la facturación de un martes corre entera
  sobre ella** mientras la vieja sigue viva al lado. Opcional, acumulativo y fuera de las 252 h.
- 💀 **El boss de bloque.** Un encargo interno de Alameda o de Horizonte que solo se resuelve
  cruzando las fases del bloque. Lo pide alguien de la historia, con nombre, tiene una consecuencia
  si sale mal y **empieza con un sistema roto**. Si cabe en tres líneas, era un 🔴 con mejor nombre.

| Bloque | 💀 Boss | Lo pide |
|---|---|---|
| I | **La señora que es tres pacientes**: la historia completa de una paciente crónica repartida entre un DNI, una Libreta Cívica y el protocolo de su nieto recién nacido | Norma Castellani |
| II | **El portal de 2018**: el portal nuevo no puede ser enumerable, y la consulta del médico derivante no puede traerse la tabla entera | Verónica Colombo |
| III | **Una tarde de julio**: tres cajas, un web service fiscal que rechaza y una muestra asignada dos veces | Matías Ledesma |
| IV | **El informe en la app**: servir el informe como documento sin perder la fuente relacional | Florencia Marchetti |
| V | **Las 9:40**: la exportación nocturna y la notificación de doce horas pasadas a flujo, y el portal servido por la API con seguridad por fila | Verónica Colombo |
| V ☕ | **El puente**: la interfaz con el SIH en Java 21 y ActiveMQ Artemis, con mensajes que imitan HL7 v2, duplicados, fuera de orden y un mensaje veneno. Cierra con **¿hacía falta un broker?**, medido contra la cola en Postgres de F22 | Matías Ledesma |

El Bloque V lleva dos boss: el del bloque, en SQL y Python, y el del puente, **el único lugar del
camino base donde se escribe Java**. Los dos van al cierre de F23. El Bloque 0 no lleva boss, y el
Bloque VI tampoco: el capstone ya es el encargo.

---

## 14. 🎯 Criterios de éxito

El curso está bien si:

- **Cada fase cierra con un número medido que sorprendió a quien la escribió.** Si cierra con *"la
  documentación dice que"*, se reescribe (salvo en Oracle y SQL Server, donde eso es lo único
  publicable, y se dice).
- **Al menos una apuesta se pierde en público** y se cuenta entera.
- **Florencia gana en algún sitio con número**, y el curso lo concede sin letra chica.
- **Un lector que solo hace el Bloque 0 y el I** sale con un esquema de pacientes que defiende sus
  reglas, y con la medición de cuánto rechaza.
- **El catálogo de errores llega a cincuenta entradas con mensaje literal**, repartidas entre los
  tres motores.
- **Matías podría operar lo que el curso le deja.** Si la solución exige un equipo que Alameda no
  tiene, el veredicto lo dice.

---

## 15. 🗺️ Relación con el resto del repositorio

- **`cursos-bd/ruta-no-sql-lite/`** es el contrapeso. Esta ruta hereda su instrumento (las cinco
  preguntas), su forma de medir y su arnés como idea, y la enlaza desde F02, F20 y F21. **No la
  modifica.**
- **`cursos-bd/ruta-no-sql/`** es el diseño de los cursos profundos por familia; no se cita.
- **`cursos-contenedores-cloud-infra/docker-container-legacy/`** es la infraestructura de
  laboratorio: aquí se dan recetas y el mecanismo se enlaza.
- **El curso de C# y su Cordillera Media** cuentan la historia del *código* heredado (FoxPro y
  SQL Server). Alameda cuenta la del *modelo de datos*, y por eso el curso evita repetir el origen
  xBase.
