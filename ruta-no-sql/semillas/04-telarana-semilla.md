# 🕸️ Proyecto Telaraña — Semilla del curso (Grafo: la relación como ciudadano de primera clase; recorridos de profundidad variable)

## 🎯 Motivación

Hay una clase de pregunta que el modelo relacional puede responder pero para la
que nunca fue diseñado: *"partiendo de este nodo, ¿qué nodos alcanzo en `k`
saltos a través de cualquier tipo de relación, y por qué camino?"*, donde `k`
no se conoce de antemano. En SQL esa pregunta se escribe con un CTE recursivo,
y cada nivel de profundidad es, en el fondo, un JOIN más contra un conjunto de
resultados que crece y que el optimizador no puede acotar bien porque no sabe
cuántos saltos vas a necesitar. El costo no crece de forma lineal con la
profundidad: se dispara. El modelo relacional guarda las relaciones como filas
en tablas puente y reconstruye cada recorrido en tiempo de consulta; el modelo
de grafo guarda la **relación misma** como una estructura física de primera
clase —un puntero indexado entre dos nodos— de modo que atravesar una arista es
una operación de costo prácticamente constante, sin importar a qué profundidad
estés. Esa es toda la diferencia, y es puramente física: no es que SQL "no
pueda", es que paga en cada salto un peaje que el grafo no paga.

El matiz que este curso no te va a dejar olvidar es **dónde** aparece esa
ventaja. No aparece en un JOIN de dos tablas: ahí SQL gana sin despeinarse, y
montar un motor de grafo para eso es el error que vas a aprender a no cometer.
Aparece exactamente cuando la profundidad del recorrido es **variable y alta**,
y cuando el patrón de la consulta es el recorrido mismo (caminos, ciclos,
componentes, vecindarios) y no la agregación tabular. El objetivo es que sepas
medir la frontera, no intuirla.

Para un ingeniero senior que viene de años de SQL, dominar el modelo de grafo
suma tres cosas concretas a su criterio. Primero, la capacidad de abordar
proyectos que hoy descarta o resuelve mal: detección de fraude por anillos,
motores de recomendación por relaciones de comportamiento, permisos jerárquicos
profundos, análisis de redes. Segundo, dejar de cometer el error inverso —el
CTE recursivo de siete niveles anidado en una vista que nadie se atreve a tocar,
resolviendo a mano y lento lo que un motor de grafo hace nativo—. Y tercero, y
más valioso, la sobriedad de saber **cuándo no** sacar el grafo del cajón: un
motor de grafo para lo que es un JOIN de dos saltos es sobre-ingeniería cara de
operar. La herramienta correcta, medida, defendida con números.

---

## 🏗️ El dominio: detección de fraude sobre transacciones financieras sintéticas

Telaraña construye un sistema de detección de fraude sobre un conjunto
**sintético** de transacciones financieras entre cuentas. No hay datos reales
ni confidencialidad que preservar: el dataset se genera para exhibir justo los
patrones que el fraude real produce y que el grafo detecta bien.

El sistema persigue dos familias de señal, y las dos son, por naturaleza,
problemas de recorrido:

La primera son los **anillos de dinero**: grupos de cuentas que se transfieren
fondos entre sí en círculo (`A → B → C → A`), a veces con más saltos y con
montos que rotan para disfrazar el origen. Detectar un anillo es, literalmente,
buscar ciclos en el grafo de transacciones — un problema para el que SQL no
tiene una primitiva cómoda y el grafo sí.

La segunda son las **señales indirectas de identidad**: cuentas que no están
conectadas de forma obvia (no se transfieren dinero directamente) pero comparten
atributos que las delatan como una misma mano —mismo dispositivo, misma
dirección física, mismo teléfono, mismo patrón horario de actividad—. Aquí el
grafo modela cada atributo compartido como un nodo o una arista, y el fraude
emerge como un vecindario densamente conectado que ninguna consulta por igualdad
directa habría agrupado.

### Las entidades y sus relaciones

El modelo de grafo del dominio se arma con pocos tipos de nodo y varios tipos de
arista. La tabla fija el vocabulario (en inglés en el código, como toda la ruta):

| Tipo de nodo | Qué representa | Atributos ilustrativos |
|---|---|---|
| `Account` | una cuenta del sistema | `accountId`, `openedAt`, `status` |
| `Device` | un dispositivo desde el que se opera | `deviceId`, `fingerprint` |
| `Address` | una dirección física o de facturación | `addressId`, `zip` |
| `Phone` | un número de teléfono | `phoneId` |

| Tipo de arista | Conecta | Semántica |
|---|---|---|
| `TRANSFERRED_TO` | `Account → Account` | una transferencia (con `amount`, `at`, `txId`) |
| `USED_DEVICE` | `Account → Device` | la cuenta operó desde ese dispositivo |
| `REGISTERED_AT` | `Account → Address` | la cuenta declaró esa dirección |
| `HAS_PHONE` | `Account → Phone` | la cuenta declaró ese teléfono |

Un anillo de fraude es un ciclo de aristas `TRANSFERRED_TO`. Una identidad
compartida encubierta es un camino corto entre dos `Account` que pasa por un
`Device`, `Address` o `Phone` común. Ambas cosas son recorridos; ninguna es una
agregación tabular. Por eso el dominio **exhibe** el patrón de acceso del grafo
de forma natural y no forzada: no elegimos el fraude porque "queda bien con
grafos", lo elegimos porque el fraude *es* estructura relacional profunda.

### El marco de 5 preguntas, aplicado ANTES de modelar

Antes de escribir una sola línea de Cypher, el mismo interrogatorio que ordena
toda decisión de arquitectura:

| Pregunta | Veredicto para Telaraña |
|---|---|
| ¿Qué se lee junto? | vecindarios y caminos: dado un nodo, sus aristas y las de sus vecinos hasta profundidad `k` — nunca "un nodo aislado" |
| ¿Quién custodia la forma / las invariantes? | la arista es la entidad de valor; las invariantes son de conectividad (no hay transferencia sin dos cuentas), no de esquema fijo |
| ¿Cuánto se une en caliente? | muchísimo, y a profundidad variable: la consulta central *es* la unión repetida — justo lo que el JOIN de SQL paga caro |
| ¿Dónde viven las invariantes? | en la topología: un ciclo, un vecindario denso, un camino más corto — propiedades del grafo, no de una fila |
| ¿Qué pide la operación? | lectura de recorridos de profundidad alta y variable, escritura de aristas en flujo continuo, latencia baja para detección casi en vivo |

**Veredicto: vota grafo 5-0** para las consultas de recorrido profundo. Con una
honestidad que el curso repite hasta el cansancio: **ese 5-0 es para las
consultas de recorrido**. Para "dame el saldo de esta cuenta" o "lista las
transferencias del último día por monto", el grafo no vota nada especial y un
relacional bien indexado gana. El dominio no es "todo grafo": es "grafo donde
hay recorrido, relacional donde hay tabla". Telaraña te enseña a ver la costura.

### El villano: el grafo donde bastaba un JOIN

El anti-patrón que este curso disecciona con autopsia medida es **usar un motor
de grafo para recorridos de 1-2 saltos que SQL resuelve sin esfuerzo**. Es el
espejo exacto del fanboy de la ruta, en su versión pro-grafo: el equipo que,
deslumbrado por Cypher, modela en Neo4j un catálogo con dos niveles de categoría
y una relación producto-proveedor, y termina operando un motor de grafo entero
—con su backup propio, su guardia propia, su curva de aprendizaje— para
consultas que un `JOIN` de dos tablas en Postgres resolvía en un milisegundo y
sin sumar superficie operativa.

El villano tiene nombre y forma concreta en el curso: una base de fraude
"modelada como grafo" donde el 90% de las consultas reales son de un salto
(`¿desde qué dispositivo operó esta cuenta?`) y jamás explotan la profundidad.
Se mide su costo —operativo y de latencia— contra el mismo caso resuelto en
Postgres, y se muestra con números que ahí el grafo **pierde**. La lección no es
"el grafo es malo": es que la ventaja del grafo es condicional a la profundidad,
y cobrar el peaje operativo de un motor de grafo sin usar esa profundidad es
tirar dinero. La autopsia vive en la última fase.

---

## 📐 Stack (2026, estable y moderno)

Todo el stack es open source, de acceso gratuito en entorno de desarrollo, y
**enteramente contenerizado**: cada motor levanta con Docker/Podman desde la
Fase 0, sin instalación nativa. Las versiones se fijaron verificando la última
estable a agosto de 2026 (ver nota al pie de la tabla).

| Componente | Versión / elección | Rol |
|---|---|---|
| Neo4j | **2026.07.x** (Community); **5.26 LTS** como alternativa conservadora | motor de grafo principal; Cypher como lenguaje de consulta |
| Memgraph | **3.x** (última estable, imagen `memgraph-mage`) | rival de grafo in-memory, Cypher-compatible; contraste disco vs memoria |
| Amazon Neptune | — (referencia gestionada, **no operado**) | representante del modelo de grafo administrado en la nube; se estudia su diseño sin costo de cuenta |
| PostgreSQL | **18** | control relacional obligatorio: CTE recursivos como rival del recorrido |
| Node.js | **24 LTS** (Active LTS) | runtime del arnés, del generador de datos y de la API |
| Lenguaje | **TypeScript** (última estable) | tipado en todo el código de soporte |
| Driver Neo4j | `neo4j-driver` (última 6.x para Node) | acceso a Neo4j desde el arnés |
| Driver Memgraph | vía protocolo Bolt (mismo `neo4j-driver` o `mgclient`) | acceso a Memgraph |
| Driver Postgres | `pg` (node-postgres, última) | acceso a Postgres desde el arnés |
| Docker / Podman | última | orquestación de todos los motores |

> ⚠️ **Verificar antes de clavar versiones.** Neo4j pasó a *Calendar Versioning*
> en 2025: hoy la línea viva es `2026.0x` y `5.26` es la LTS checkpoint. Memgraph
> se mueve rápido en la línea `3.x`. Node 24 es la Active LTS vigente (26 es
> Current, aún no LTS). PostgreSQL 18 es la mayor estable. Confirma cada número
> en la Fase 0 antes de fijarlo en `docker-compose`; no claves versiones de
> memoria.

### Por qué Neo4j como motor principal

Neo4j es la referencia de la categoría y donde Cypher —el lenguaje de consulta
de grafos más legible y extendido— nació y madura. Para un curso cuyo objetivo
es enseñar el **modelo**, no el producto, Cypher es el mejor vehículo: expresa
patrones de grafo (`MATCH (a)-[:TRANSFERRED_TO*1..5]->(a)`) de forma tan directa
que la sintaxis casi desaparece detrás de la idea. Además, la Community Edition
es gratuita y corre en un contenedor sin fricción.

### Por qué Memgraph como rival de grafo

Para que el curso no compare solo "grafo vs relacional" sino también **grafo vs
grafo**, Memgraph aporta el contraste más instructivo: es Cypher-compatible
(las mismas consultas, otro motor) pero in-memory y en C++, pensado para
streaming de eventos y analítica en tiempo real, frente al enfoque de
persistencia en disco de Neo4j. Medir la misma detección de anillos en ambos
—con el mismo arnés— revela cuándo la latencia en memoria compensa y cuándo el
modelo de persistencia de Neo4j es suficiente. La detección de fraude casi en
vivo es justamente el terreno donde ese contraste se siente.

### Por qué Neptune solo como referencia

Amazon Neptune representa el modelo de grafo **gestionado**: no operas la
infraestructura, pagas por no hacerlo. Se incluye conceptualmente —diseño,
modelo de costos, cuándo conviene— pero no se opera en el curso, para no atar el
aprendizaje a una cuenta cloud de pago. Es la pieza que obliga a discutir el
costo operativo real de un motor de grafo, que es exactamente el eje del villano.

### Por qué PostgreSQL como control relacional

Postgres 18 no es decorado: es el rival que hace honesto todo el curso. Los CTE
recursivos de SQL son la forma correcta y legítima de hacer recorridos en el
mundo relacional, y para profundidades bajas **ganan**. Construir el mismo
recorrido en ambos lados y medirlo es lo que convierte "el grafo es mejor para
esto" de eslogan en dato. Sin Postgres al lado, el curso sería propaganda.

### Por qué TypeScript + Node LTS

El arnés `vs.ts`, el generador de datos y la API de consulta se escriben en
TypeScript sobre Node 24 LTS: multiplataforma (Linux, macOS, Windows vía WSL),
con drivers maduros para los tres motores (`neo4j-driver`, `pg`), y con el
tipado que hace legible un arnés que compara resultados heterogéneos. No hay
nada en el modelo de grafo que pida otro lenguaje; Cypher vive en strings
tipados y el resto es orquestación, donde TS brilla.

Vale la pena registrar la deliberación, porque es tentadora: como Neo4j está
escrito en Java, surge la idea de mover el arnés a un lenguaje JVM (Kotlin,
Clojure) para estar "en el ecosistema natural" del motor. Se descarta para el
núcleo del curso por tres razones. Primero, el curso no interactúa con Neo4j en
Java: interactúa por **Bolt**, el protocolo de red, con el driver oficial de JS
como ciudadano de primera clase — desde el cliente, Neo4j es tan "de Java" como
Postgres es "de C", es decir, irrelevante para elegir el lenguaje del arnés. Y
el otro motor de grafo del curso, Memgraph, está escrito en **C++**, no en la
JVM, y también habla Bolt: el argumento "el motor es JVM" solo cubriría a la
mitad del dueto, y ni siquiera a la capa que se toca. Segundo, y decisivo por la
doctrina de la ruta: pedirle a un lector senior-de-SQL que aprenda a la vez el
modelo de grafo (el objetivo) **y** un Lisp funcional o Kotlin (una segunda
montaña) viola el principio de recalibrar **un instinto a la vez**. El lenguaje
del arnés debe desaparecer detrás de Cypher, no competir con él por la atención.
Tercero, un arnés de benchmark es secuencial por diseño —correr consultas en
paralelo contamina la medición—, así que arquitecturas de concurrencia como el
modelo de actores no añaden capacidad, solo complejidad que el problema no pide:
sería el villano del curso aplicado al curso mismo. Lo que sí hay de legítimo en
la intuición —que el ecosistema **oficial y más rico de Neo4j vive en la JVM**,
sobre todo para GDS e integraciones avanzadas— se recoge, pero como apéndice 🔥
opcional (ver Apéndice F), no como base del curso.

### Validación y tooling transversal

El generador de datos sintéticos produce el **mismo dataset semántico** en las
dos formas —nodos+aristas para los motores de grafo, tablas+tablas puente para
Postgres— con anillos y señales de identidad sembrados de forma controlada (sabes
cuántos anillos plantaste y de qué profundidad, así puedes verificar recall). El
arnés `scripts/vs.ts` corre sobre ese dataset. La validación de la forma de los
datos vive en Zod (aplicación) del lado del generador, para que ambos mundos
partan de la misma verdad.

---

## ⚖️ El método del "vs": un arnés, no anécdotas

Desde la Fase 0 se monta `scripts/vs.ts`: un arnés que ejecuta **la misma
consulta semántica** —"encuentra todos los anillos de hasta `k` saltos", "halla
las cuentas a distancia ≤ `d` que comparten dispositivo"— contra los motores en
juego, cronometra cada corrida, repite para promediar, y acumula los resultados
en `BENCHMARKS.md`. Ningún "vs" del curso se narra sin medir primero, y cada
medición registra la profundidad `k`, porque la tesis entera del curso es que el
veredicto **depende de `k`**.

Los duelos que atraviesan el curso:

1. **Neo4j vs PostgreSQL (CTE recursivo)** — grafo vs relacional, el eje
   central. Se mide el mismo recorrido a profundidad creciente (`k = 1, 2, 3, 4,
   5, …`) para encontrar el punto exacto donde SQL deja de rendir y el grafo
   despega. Ese punto es el entregable estrella del curso.
2. **Neo4j vs Memgraph** — grafo vs grafo, disco vs memoria. Misma Cypher, misma
   detección, distinta latencia y distinto perfil de recursos.
3. **Neptune (documentado)** — no se cronometra, se analiza: costo operativo y
   de gestión frente a operar Neo4j uno mismo.

---

## 🌳 Estructura de fases

Doce fases: la 0 monta el laboratorio contenerizado y el generador; la 11 hace
la autopsia del villano y el veredicto honesto. El número se ajusta a que el
modelo tiene un "punto de inflexión" que merece varias fases dedicadas (el
recorrido a profundidad creciente es el corazón del curso).

| # | Fase | Núcleo | "Vs" de la fase |
|---|---|---|---|
| **0** | 🧪 El laboratorio de tres motores | Compose con Neo4j + Memgraph + Postgres. Generador que siembra el mismo dataset en grafo y en tablas, con anillos y señales controlados. Nace `vs.ts` | — (montaje) |
| **1** | 📖 De tablas a nodos y aristas | El diccionario de traducción SQL ↔ Cypher; modelar el dominio en ambos lados | Modelado: tabla puente vs arista de primera clase |
| **2** | 🩻 Lo que SÍ viaja igual | Índices, selectividad, `EXPLAIN`/`PROFILE`, el `WHERE` por propiedad: tu instinto relacional intacto | Consulta de un salto: Neo4j vs Postgres (empate honesto) |
| **3** | 🪞 El primer recorrido: uno, dos, tres saltos | `MATCH` con longitud fija; aquí el instinto SQL empieza a temblar | CTE recursivo vs Cypher a `k` fijo — se mide dónde empatan |
| **4** | ⭐ Profundidad variable: donde el grafo despega | `*1..k` y caminos de longitud desconocida; la curva de costo por profundidad | El "vs" estrella: SQL vs grafo a `k` creciente, punto de quiebre medido |
| **5** | 🔁 Anillos: buscar ciclos | Detección de ciclos `TRANSFERRED_TO` de longitud variable | Ciclos en Cypher vs el CTE recursivo con control de visitados en SQL |
| **6** | 🧭 Caminos más cortos y ponderados | `shortestPath`, caminos con peso (`amount`), algoritmos de camino | Camino más corto: primitiva nativa vs simulación relacional |
| **7** | 🕵️ Señales indirectas de identidad | Vecindarios densos vía `Device`/`Address`/`Phone` compartidos | Grafo vs `JOIN` múltiple + `GROUP BY` en SQL |
| **8** | 📊 Algoritmos de grafo (GDS/MAGE) | PageRank, comunidades (Louvain), centralidad para priorizar sospechosos | Neo4j GDS vs Memgraph MAGE — grafo vs grafo en analítica |
| **9** | ⚡ Neo4j vs Memgraph, cara a cara | Misma detección, disco vs memoria; perfil de latencia y recursos | El duelo grafo-grafo completo, medido |
| **10** | 🌐 El grafo administrado: Neptune y el costo de operar | Diseño de Neptune, modelo de costos, cuándo gestionar conviene | Operar vs pagar por no operar (análisis, no cronómetro) |
| **11** | ⚰️ La autopsia del villano y ⚖️ el veredicto | La base "grafo" de consultas de un salto, medida contra Postgres; árbol de decisión de cuándo NO usar grafo | El villano medido: grafo pierde el caso de 1-2 saltos |

### Fase 0 — El laboratorio de tres motores

Levanta con un solo `docker compose up` los tres motores (Neo4j, Memgraph,
Postgres) y deja corriendo el generador de datos. El generador produce, de una
misma semilla, el dataset en forma de grafo (para Neo4j y Memgraph) y en forma
relacional normalizada (para Postgres), sembrando un número **conocido** de
anillos de profundidades variadas y de identidades compartidas, para que el
recall sea verificable. Nace `scripts/vs.ts` con su primer duelo trivial (un
conteo) solo para probar el cableado. No se modela fraude todavía: se monta la
mesa.

### Fase 1 — De tablas a nodos y aristas

Presenta el **📖 diccionario de traducción SQL ↔ Cypher** y modela el dominio de
fraude en los dos paradigmas en paralelo: en Postgres, `accounts`,
`transfers`, `devices` y las tablas puente; en grafo, los nodos y aristas de la
sección de dominio. El punto pedagógico es que en relacional la relación es una
fila en una tabla puente que se reconstruye por JOIN, y en grafo es una entidad
física con identidad propia. Todavía sin recorridos: solo el mapeo de formas.

### Fase 2 — Lo que SÍ viaja igual

El **🩻 recuadro de tranquilidad**: casi todo tu instinto de rendimiento SQL
sigue valiendo. Los índices importan (un índice sobre `accountId` en el grafo es
tan decisivo como en la tabla), la selectividad manda, `PROFILE` en Cypher es tu
`EXPLAIN ANALYZE`, y una consulta de un solo salto con filtro por propiedad
rinde parecido en ambos. Se mide y se confirma el empate para bajar la ansiedad
antes de que el instinto se rompa en la fase siguiente.

### Fase 3 — El primer recorrido: uno, dos, tres saltos

El **🪞 instinto falsable**: le pedimos al lector que prediga, con su cronómetro
mental de SQL, cuánto costará "todas las cuentas a 3 saltos de esta". Se escribe
el CTE recursivo y el `MATCH` de longitud fija, se mide, y se registra el
veredicto. A `k` bajo el resultado suele sorprender por lo parejo: la fase
prepara el terreno mostrando que el grafo **no** gana gratis a poca profundidad.

### Fase 4 — Profundidad variable: donde el grafo despega ⭐

La fase central. Cypher `*1..k` con longitud desconocida frente al CTE recursivo
que tiene que gestionar a mano el conjunto de visitados y explota
combinatoriamente. Se corre el arnés a `k = 1, 2, 3, 4, 5, 6` y se dibuja la
curva: el punto donde las dos líneas se cruzan es el hallazgo que el curso
persigue. Aquí vive el "vs" estrella y el número que el lector se va a llevar
tatuado.

### Fase 5 — Anillos: buscar ciclos

Detección de ciclos de `TRANSFERRED_TO` de longitud variable —el corazón del
producto de fraude—. En Cypher, un patrón de ciclo con retorno al nodo de
partida; en SQL, un CTE recursivo con control explícito de visitados para no
entrar en bucle infinito. Se mide la diferencia y se discute por qué el control
de ciclos es nativo en un lado y artesanal en el otro.

### Fase 6 — Caminos más cortos y ponderados

`shortestPath` y caminos ponderados por `amount`: encontrar la ruta más corta o
más "pesada" de dinero entre dos cuentas. La primitiva de camino más corto es
nativa en el grafo y una pesadilla de implementar en SQL puro. Se mide y se
nombra la asimetría.

### Fase 7 — Señales indirectas de identidad

El segundo eje del fraude: cuentas sin conexión directa que comparten `Device`,
`Address` o `Phone`. En grafo es un vecindario a 2 saltos vía el atributo
compartido; en SQL es un `JOIN` múltiple con `GROUP BY` y `HAVING COUNT(*) > 1`.
Se mide cuál escala mejor a medida que crecen los atributos compartidos y el
número de cuentas.

### Fase 8 — Algoritmos de grafo (GDS/MAGE)

Sube un nivel: PageRank para rankear cuentas por influencia en la red, detección
de comunidades (Louvain) para agrupar anillos, centralidad para priorizar
sospechosos. Se usan la librería GDS de Neo4j y MAGE de Memgraph, y se contrasta
grafo contra grafo en analítica de red — algo que en SQL simplemente no existe
como primitiva.

### Fase 9 — Neo4j vs Memgraph, cara a cara

El duelo grafo-grafo completo: la misma detección de anillos e identidades,
ejecutada en Neo4j (disco) y Memgraph (memoria), con el perfil de latencia,
throughput de ingesta de aristas nuevas y consumo de recursos. Cuándo la
detección casi en vivo justifica el motor en memoria y cuándo la persistencia de
Neo4j basta.

### Fase 10 — El grafo administrado: Neptune y el costo de operar

Sin operar Neptune, se analiza su diseño y su modelo de costos para plantear la
pregunta que el villano necesita: ¿cuánto cuesta —en dinero y en guardia— tener
un motor de grafo en producción? Es el puente conceptual hacia la autopsia:
operar un grafo no es gratis, y esa factura es la que el villano ignora.

### Fase 11 — La autopsia del villano y el veredicto ⚰️⚖️

Se construye deliberadamente la base "grafo" del villano: fraude modelado en
Neo4j donde el 90% de las consultas reales son de un salto. Se mide de punta a
punta contra el mismo caso en Postgres —latencia **y** costo operativo— y se
muestra con números que ahí el grafo pierde. Cierra con el **⚖️ árbol de
decisión honesto**: cuándo NO usar grafo (recorridos superficiales, consultas
tabulares, volumen que un `JOIN` indexado resuelve, equipos sin apetito de
operar otro motor), y cuándo sí (profundidad variable y alta, caminos, ciclos,
comunidades). El veredicto tiene dos manos, como toda la ruta.

### Apéndices

- **A) Arranque de motores vía contenedores.** `docker compose up` paso a paso,
  puertos, credenciales por defecto de cada motor, healthchecks.
- **B) `docker-compose.yml` de trabajo.** El archivo completo con Neo4j,
  Memgraph, Postgres y volúmenes; variantes Docker y Podman.
- **C) Guía rápida de Cypher para quien viene de SQL.** `MATCH`/`WHERE`/`RETURN`
  como `SELECT`, patrones de camino, `*min..max`, agregaciones; la tabla de
  traducción ampliada.
- **D) El generador de datos.** Cómo se siembran anillos de profundidad conocida
  y señales de identidad, cómo verificar recall, cómo escalar el volumen.
- **E) Troubleshooting de setup.** Puertos ocupados, memoria de Memgraph, límites
  de Neo4j Community, drivers Bolt y versiones incompatibles.
- **F) 🔥 Telaraña desde la JVM (opcional).** Para el lector que ya vive en la
  JVM y quiere ver el mismo dominio desde el ecosistema natural de Neo4j: el
  driver oficial Java/Kotlin, GDS explotado desde su hábitat de origen (donde
  históricamente es más rico que desde otros lenguajes), y cómo se ve la misma
  detección de anillos con estructuras de un lenguaje JVM. Es explícitamente
  **fuera del núcleo** —ni el arnés `vs.ts` ni las fases lo usan, para no
  imponer una segunda curva de aprendizaje ni contaminar las mediciones— y sirve
  como el equivalente-grafo de un recuadro "esto también existe": honra que el
  ecosistema JVM de Neo4j es real y potente, sin hacerlo requisito. No introduce
  el modelo de actores: un arnés de benchmark es secuencial por diseño y ese
  patrón no aplica aquí.

---

## 📓 Artefactos acumulativos

**`INSTINTOS.md`** recoge, fase a fase, cada instinto relacional que el curso
pone a prueba: se escribe la **predicción** ("un recorrido de 5 saltos en SQL
costará parecido a uno de 2, solo un poco más"), se ejecuta el cronómetro, y se
registra el **veredicto medido** ("falso: el costo se disparó ~40× entre `k=2` y
`k=5`; ver `BENCHMARKS.md#fase-4`"). El documento crece como un cuaderno de
recalibración: al final del curso el lector tiene el mapa de qué instintos SQL
sobreviven (los de la Fase 2) y cuáles se rompen (los de recorrido profundo), con
la evidencia al lado.

**`BENCHMARKS.md`** es el registro de todo "vs" ejecutado con `scripts/vs.ts`:
cada entrada lleva la consulta semántica, los motores comparados, la profundidad
`k`, los tiempos (con repeticiones y dispersión), el tamaño del dataset y la
fecha. Nada entra a este documento sin haber pasado por el arnés. Es el
contrapeso empírico de `INSTINTOS.md`: uno dice lo que creíamos, el otro lo que
midió el reloj. La curva de la Fase 4 —costo vs profundidad para los dos
paradigmas— es su gráfico insignia.

---

## 📚 Referencias por fase (semilla)

> ⚠️ **Todas las URLs, títulos e IDs de video de abajo deben verificarse antes de
> usarse.** No se inventan números de página, DOIs ni identificadores de video.
> Se listan las fuentes oficiales por tema; confirma que la versión de la doc
> coincide con la fijada en el stack (Neo4j CalVer 2026.0x / Cypher 5, Memgraph
> 3.x, PostgreSQL 18).

**Oficiales, comunes a todo el curso**
- Neo4j (manual actual): https://neo4j.com/docs/
- Cypher (manual del lenguaje): https://neo4j.com/docs/cypher-manual/current/
- Neo4j Graph Data Science (GDS): https://neo4j.com/docs/graph-data-science/current/
- Memgraph (docs): https://memgraph.com/docs
- MAGE (algoritmos de Memgraph): https://memgraph.com/docs/advanced-algorithms
- Amazon Neptune (docs): https://docs.aws.amazon.com/neptune/
- PostgreSQL 18 — CTE recursivos: https://www.postgresql.org/docs/18/queries-with.html
- `neo4j-driver` (Node): https://neo4j.com/docs/javascript-manual/current/
- node-postgres (`pg`): https://node-postgres.com/

**Por fase (además de las oficiales)**
- **Fase 0–1 (setup y modelado):** doc de Docker Compose (https://docs.docker.com/compose/) y la guía de modelado de grafos de Neo4j. Orden sugerido: Compose → modelo de datos de Neo4j → tabla de traducción propia.
- **Fase 2 (lo que viaja igual):** Neo4j indexing y `PROFILE`; Postgres `EXPLAIN`. Orden: `PROFILE` de Cypher → comparar con `EXPLAIN ANALYZE`.
- **Fase 3–4 (recorridos y profundidad):** Cypher variable-length patterns; Postgres recursive queries. Orden: patrones `*min..max` de Cypher → CTE recursivo de Postgres → medir.
- **Fase 5–6 (ciclos y caminos):** Cypher path functions y `shortestPath`; GDS path finding. Orden: `shortestPath` → algoritmos de caminos en GDS.
- **Fase 7 (identidad indirecta):** patrones de vecindario en Cypher; `GROUP BY`/`HAVING` en Postgres.
- **Fase 8 (algoritmos):** GDS (PageRank, Louvain) y MAGE equivalentes. Orden: catálogo de GDS → equivalente en MAGE.
- **Fase 9 (Neo4j vs Memgraph):** guías de rendimiento de ambos; storage modes de Memgraph.
- **Fase 10 (Neptune):** Neptune developer guide y su pricing (verificar, cambia seguido).
- **Fase 11 (autopsia y veredicto):** relee el modelado de la Fase 1 y los benchmarks acumulados.

**Libros y video**
- Libros y screencasts sobre grafos y Cypher existen y son útiles, pero **no se
  citan títulos, autores, páginas ni IDs de video sin verificarlos primero**. Al
  redactar cada fase, busca la edición vigente y confirma la referencia exacta
  antes de incluirla.

---

## 🧪 Nota sobre ejercicios

Cada fase lleva entre **20 y 40 ejercicios** graduados 🟢🟡🟠🔴, todos anclados
al dominio de fraude (cuentas, transferencias, anillos, dispositivos,
direcciones), nunca abstractos. Distribución sugerida para ~30 por fase: ~8 🟢
(calientan: escribir un `MATCH` simple, un filtro por propiedad), ~9 🟡 (un
recorrido de longitud fija, una tabla de traducción), ~7 🟠 (un ciclo de
longitud variable, medir con el arnés), ~5 🔴 (integrar varias fases, medir un
punto de quiebre, comparar grafo vs SQL a profundidad creciente), más los 🔥
opcionales aparte.

Al menos un puñado por fase son de **diagnóstico**: se entrega un Cypher o un CTE
que da resultado incorrecto o lento (un ciclo sin control de visitados que cuelga
en SQL, un `*1..10` que explota en memoria, un índice faltante que hace lento un
recorrido) y se pide **reproducir y localizar**, no solo construir. Son los que
mejor enseñan el modelo, porque el fallo suele estar en el instinto trasplantado
del paradigma anterior.

---

## 🧩 Decisiones pendientes de confirmar antes de redactar la Fase 0

- [ ] **Dataset semilla:** ¿100% sintético generado (recomendado por defecto,
      para controlar profundidad de anillos y verificar recall) o un dataset
      público de transacciones adaptado? Propuesta por defecto: sintético
      generado, por el control sobre el recall.
- [ ] **¿Memgraph entra desde la Fase 0 o más tarde?** Propuesta: montado desde
      la Fase 0 (levanta gratis en contenedor) pero el "vs" grafo-grafo serio se
      concentra en las fases 8–9; antes solo se lo tiene disponible.
- [ ] **¿Neptune se documenta o se toca?** Propuesta por defecto: solo se
      documenta (diseño y costos), sin cuenta cloud, para no atar el curso a AWS
      de pago. Confirmar.
- [ ] **Versión de Neo4j:** ¿línea CalVer `2026.0x` (más nueva) o `5.26 LTS`
      (más conservadora y estable)? Propuesta: `2026.0x` para Cypher 5 al día,
      con `5.26 LTS` documentada como alternativa. Verificar la última en Fase 0.
- [ ] **Formato de fase:** ¿se mantiene la plantilla de 9 secciones del esqueleto
      de la ruta o se ajusta por ser un curso muy centrado en un solo eje
      (profundidad)? Propuesta: mantener las 9 secciones.
- [ ] **Driver de Memgraph:** ¿se usa el mismo `neo4j-driver` vía Bolt (menos
      dependencias) o `mgclient` nativo? Propuesta: `neo4j-driver` por Bolt para
      no duplicar tooling. Verificar compatibilidad en Fase 0.
- [ ] **Alcance de GDS/MAGE (Fase 8):** ¿solo PageRank + Louvain o se suma
      centralidad y similitud? Propuesta: PageRank + Louvain como núcleo, el
      resto como 🔥 opcional.
- [x] **Lenguaje del arnés y la JVM:** resuelto. TS/Node para el núcleo; la
      variante JVM (Kotlin/Clojure, GDS desde su hábitat) vive como Apéndice F
      🔥 opcional, no como base. Sin modelo de actores (el arnés es secuencial).
      Queda abierto solo *qué lenguaje JVM* usa el apéndice (Kotlin por cercanía
      a la audiencia, o Clojure por el REPL como laboratorio) — decidir al
      redactar el apéndice, no bloquea la Fase 0.

---

## 💭 Consideraciones adicionales

### La nota especial del modelo: la ventaja es condicional a la profundidad

Este es el punto que distingue a Telaraña de un tutorial de grafos entusiasta.
La ventaja del grafo **no es universal**: aparece solo cuando la profundidad del
recorrido es variable y alta. Un JOIN de dos tablas lo gana SQL sin esfuerzo, y
el curso lo mide para demostrarlo, no para insinuarlo. Por eso la Fase 4 es el
corazón: no dice "el grafo es más rápido", dice "a partir de tal profundidad, en
tal dataset, el grafo despega y SQL colapsa — aquí está la curva". Todo el curso
se organiza para que el lector salga sabiendo **dónde está la frontera**, no con
una bandera. Nombrar explícitamente esta condicionalidad, y medirla, es la
diferencia entre enseñar criterio y hacer marketing.

### Costo operativo del modelo

Un motor de grafo en producción es una superficie operativa propia y completa:
backups con su formato, monitoreo específico, guardia que entienda Cypher y el
modelo de memoria (crítico en Memgraph), y una curva de aprendizaje para el
equipo que hoy solo sabe SQL. Ese costo es real y el curso lo nombra en cada
decisión —la Fase 10 (Neptune) existe en parte para ponerle número—. La regla de
la ruta se aplica entera: no sumas un motor de grafo hasta que los recorridos
profundos lo exijan, porque la factura de operarlo no desaparece cuando el hype
se enfría.

### El lenguaje del arnés y la tentación de la JVM

Como Neo4j está escrito en Java, es natural preguntarse si el curso debería
vivir en un lenguaje JVM (Kotlin, Clojure). La decisión —registrada aquí para
que no se reabra en cada fase— es **no** para el núcleo, y el razonamiento
completo está en la subsección "Por qué TypeScript + Node LTS" del stack. En
resumen: el curso habla con los motores por Bolt, no por Java; Memgraph es C++;
el driver JS de Neo4j es oficial y de primera clase; y sumar un lenguaje nuevo
obligaría al lector a escalar dos montañas a la vez (el modelo de grafo y el
lenguaje), rompiendo el principio de recalibrar un instinto por vez. El modelo
de actores, en particular, no tiene lugar: un arnés de benchmark es secuencial
por diseño y paralelizarlo contaminaría la medición. Lo legítimo de la intuición
—que el ecosistema JVM de Neo4j, sobre todo GDS, es rico— se atiende en el
**Apéndice F (🔥 opcional)**, no en la base.

### Límites de la analogía con SQL

El modelo de grafo rompe más hábitos mentales que casi cualquier otro de la ruta,
y hay que avisarlo. "Arista" no es "fila de tabla puente": tiene identidad,
dirección, propiedades y un costo de traversal constante que la fila no tiene.
"Recorrido de profundidad variable" no tiene equivalente cómodo en SQL, y forzar
la analogía confunde. El curso honra el instinto relacional donde aplica (Fase 2)
y avisa con claridad dónde deja de aplicar (Fases 3–7), sin pretender que Cypher
es "SQL con otra sintaxis" — no lo es.

### Validación contra un mercado real (productizable: ✅ Fuerte)

La detección de fraude por grafos es un mercado maduro y activo: plataformas
comerciales de fraud analytics, equipos de riesgo en fintech y banca, y
soluciones de identidad usan exactamente estos patrones (anillos, comunidades,
señales indirectas) en producción. El proyecto se valida contra esa realidad: lo
que Telaraña construye —detección de anillos y de identidades compartidas, medida
y defendida— es la versión pedagógica de un producto que empresas reales venden
hoy. Eso ancla el aprendizaje a una necesidad de negocio verificable y le da al
lector un portafolio con contraparte en el mercado, no un ejercicio de
laboratorio.
