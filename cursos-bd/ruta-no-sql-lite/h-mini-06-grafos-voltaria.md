# 🕸️ Miniproyecto 06 · Grafos — Voltaria

> **Familia:** grafos · **Motor:** Neo4j · **Línea base:** PostgreSQL con `WITH RECURSIVE`
> **Cierra:** el minicurso de grafos (Fases 13–14) · **Empresa:** ⚡ Voltaria
> **Estado:** opcional · **No entra a la bitácora de medición**

---

## 🏢 La empresa

Voltaria es la distribuidora eléctrica de
[`h-mini-04-series-voltaria.md`](h-mini-04-series-voltaria.md): novecientos mil clientes, doce
años, tres adquisiciones y una red que nadie ha terminado de dibujar entera.

Hay una propiedad de esa red que decide este miniproyecto completo y conviene entenderla antes
de seguir, porque sin ella el problema parece más fácil de lo que es.

**La red se opera como un árbol, pero no es un árbol.** En condiciones normales, cada
transformador cuelga de un circuito y cada circuito de una subestación, en forma radial: la
corriente baja y no hay bucles. Pero entre circuitos vecinos hay **puntos de enlace normalmente
abiertos** —interruptores que existen precisamente para poder cerrarlos cuando algo falla y
alimentar un tramo desde el otro lado—. La topología física tiene mallas y ciclos; la topología
eléctrica de este momento es el árbol que resulta de cómo están los interruptores **ahora
mismo**.

Dicho de otra forma: **la estructura de los datos es una función del estado**, y el estado
cambia varias veces al día.

## ⚰️ El dolor

**La pregunta más frecuente de la empresa se contesta por radio.**

*"Voy a abrir este seccionador. ¿Quién se queda sin luz?"* La respuesta hoy es llamar al
supervisor de zona, que conoce su zona, y confiar. Y la inversa, que es peor: entran cuarenta
llamadas de gente sin servicio y hay que deducir qué elemento común las alimenta a todas, para
saber a dónde mandar la cuadrilla. Eso también se hace por radio, con un plano en papel.

La decisión que lo causó fue razonable y es la que habría tomado cualquiera. En 2017 modelaron
la red como corresponde en relacional: una tabla de elementos y una tabla de conexiones con
origen y destino. Y como recorrer eso en cada consulta salía caro, añadieron lo sensato: **un
proceso nocturno que precalcula, para cada cliente, de qué transformador y de qué circuito
cuelga**, y lo guarda en una columna.

Funciona de maravilla y es rapidísimo. El problema es de fondo y no de rendimiento: **esa
columna es verdad a las tres de la mañana y mentira a las nueve**, porque a las ocho alguien
cerró un enlace para librar un tramo y doscientos clientes cambiaron de circuito sin que la
tabla se enterara. Nadie lo nota hasta que algo depende de ello.

**La factura tiene fecha.** En abril de 2026 se programó un corte para mantenimiento y se avisó
a los clientes que decía la tabla precalculada. Se cortó el servicio a **un hospital** que
llevaba tres semanas alimentado desde otro circuito por una maniobra que nadie había deshecho.
No pasó nada grave —la planta de emergencia entró—, pero el informe al regulador lo escribió el
gerente y la frase que quedó fue: *"la empresa desconocía la configuración vigente de su propia
red"*.

## 🎯 El encargo

**Lo pide Amparo Villalba, jefa del centro de control.**

> *"Quiero tres respuestas y las quiero con la red como está **hoy**, no como estaba anoche. A
> quién dejo sin luz si abro esto. Dónde está la falla si me llaman estos cuarenta. Y la que
> nadie me ha podido dar nunca: **si se me cae este tramo, qué maniobras tengo que hacer para
> devolverle la luz a la mayor cantidad de gente sin sobrecargar nada.** Esa última la resuelvo
> con la experiencia de tres personas, y dos se jubilan este año."*

## 🧩 Lo que se construye

La red como grafo de verdad —elementos como nodos, conexiones como relaciones con propiedades,
y el estado del interruptor como propiedad de la relación— y las tres consultas de Amparo, en
las dos tecnologías:

- **Aguas abajo:** dado un elemento, qué clientes quedan sin servicio si se abre. Es descender,
  con el estado vigente aplicado.
- **Aguas arriba:** dado un conjunto de clientes afectados, el elemento común más cercano que
  los alimenta a todos. Es ascender y converger.
- **La reconfiguración:** dado un tramo sin energía, **los caminos alternativos posibles** a
  través de los enlaces normalmente abiertos, con su costo en maniobras y su efecto en carga.
  Profundidad desconocida, caminos múltiples, y un grafo con ciclos.

Y las tres escritas también en `WITH RECURSIVE`, bien jugadas, con corte de ciclos y con los
índices correctos. Sin eso, la comparación es propaganda.

## 📐 Lo que se observa

- **Filas o `db hits` examinados** por cada consulta y por cada profundidad, en las dos.
- **Dónde está el cruce**, si es que lo hay: a partir de qué salto una gana a la otra.
- **Qué cuesta que el estado sea vigente** — es decir, aplicar el estado de los interruptores
  en tiempo de consulta en vez de precalcular — en las dos tecnologías.
- **Cuál de las tres consultas no se puede escribir razonablemente en SQL**, que es el dato que
  de verdad decide.

## 💥 Dónde se rompe

**La consulta sin límite de profundidad sobre un grafo con ciclos.** La red mallada los tiene
por diseño, y una travesía sin corte los recorre para siempre. Provócalo en los dos motores y
mira cómo se manifiesta en cada uno — porque se manifiesta distinto, y eso enseña más que el
error en sí.

Y el segundo: **el producto cartesiano de Cypher**, que llega con su aviso literal cuando
escribes dos patrones sin conectar. Anótalo.

## ⚖️ El veredicto que tiene que salir

Este es el miniproyecto donde el curso pone a prueba su propia apuesta, y el resultado tiene
que publicarse tal como salga.

**Las dos primeras consultas las aguanta Postgres, y probablemente mejor de lo que tu instinto
dice.** Aguas abajo es descender un árbol y aguas arriba es ascender por uno: un `WITH
RECURSIVE` con el índice correcto llega mucho más lejos de lo que la gente cree, y la
profundidad de una red de distribución no es tan grande como parece. Si el miniproyecto termina
diciendo que el grafo gana esas dos, **hay que sospechar de la medición antes que del
instinto**.

**La tercera es donde el grafo no es más cómodo: es que lo otro no se escribe.** Buscar todos
los caminos alternativos hasta un tramo, a través de una malla con ciclos, con profundidad
desconocida y evaluando el costo de cada camino, no es un `WITH RECURSIVE` difícil — es una
cosa que en SQL se convierte en escribir un motor de grafos dentro de la aplicación. Ahí está
el argumento real de la familia y es el único que hace falta.

Y el veredicto honesto que cierra: **si Voltaria solo necesitara las dos primeras, no
necesitaría un grafo.** Necesitaría dejar de precalcular una columna a las tres de la mañana.
Ese es el arreglo de escalón 1 y cuesta días, no trimestres — y decirlo es parte del trabajo.

## 🧰 El stack

| Pieza | Qué se usa | Nota |
|---|---|---|
| Entorno | **Node + TypeScript** | |
| Motor | **Neo4j Community** · perfil `grafos` | `cypher-shell` para explorar, driver oficial para el servicio |
| Lenguaje | **Cypher** | Lo justo para el dominio: patrones, travesía con límite, caminos |
| Línea base | **PostgreSQL** · perfil `base` | `WITH RECURSIVE` con su índice y con **detección de ciclos declarada**, no a mano |
| Driver | `neo4j-driver` y `pg` | |
| Modelado | El estado del interruptor como **propiedad de la relación** | Es lo que hace que la topología se calcule en tiempo de consulta y no de madrugada |
| Medición | `PROFILE` y sus `db hits` · `EXPLAIN (ANALYZE, BUFFERS)` | Filas examinadas por profundidad, en las dos, sobre el mismo grafo |
| Datos | Generador del curso | Red **radial en operación y mallada en infraestructura**, con enlaces normalmente abiertos y estado que se puede cambiar entre consultas |
| Entregable | `src/h-mini-06-grafos-voltaria/` | |

**Qué NO entra:** la biblioteca de algoritmos de grafo —PageRank, detección de comunidades— que
es 🔥 opcional y pertenece al curso profundo; clúster de Neo4j; y cualquier visualización de la
red. Lo que sí entra, y es obligatorio, es que **la versión relacional esté bien escrita**:
ganarle a un `WITH RECURSIVE` mal hecho no demuestra nada.

> ⚠️ **Ninguna versión ni digest se escribe aquí.** Viven en `a02` y se fijan ejecutando, en la
> sesión de verificación de laboratorio. Este stack nombra piezas, no números.
>
> 🧭 **Dos reglas del curso que este miniproyecto no puede saltarse.** El **arnés de medida y el
> generador de datos son TypeScript siempre** (alcance §9): son el instrumento, y un instrumento
> con dos implementaciones deja de ser un instrumento. Y **se habla con los motores
> directamente**: nada de ORM, ODM ni cliente de alto nivel (`a06`), porque esas capas esconden
> justo lo que queremos medir.

---

## 🔗 El puente con Cóndor

Es la **Fase 13**, y el paralelo es más profundo de lo que parece a primera vista.

La trazabilidad de Cóndor —*"¿en qué aeronaves estuvo instalada alguna vez una pieza de este
lote?"*— y la reconfiguración de Voltaria son el mismo tipo de problema: **la estructura no es
un árbol fijo, es lo que resulta de una historia de eventos.** En Cóndor los eventos son
instalaciones y retiros a lo largo de los años; en Voltaria son maniobras a lo largo del día.
En los dos casos, precalcular la respuesta produce un dato que es verdad ayer y mentira hoy —y
en los dos casos alguien ya lo precalculó, porque es lo que uno hace.

Si el lector solo se lleva una cosa de este miniproyecto, que sea esa: **cuando la relación
tiene historia, la tabla precalculada es una fotografía, y las decisiones no se toman con
fotografías.**

## 📋 Criterios de aceptación

```text
[ ] El estado de los interruptores se aplica en tiempo de consulta, no precalculado
[ ] Las tres consultas están escritas en Cypher y en WITH RECURSIVE, las dos bien jugadas
[ ] La versión relacional tiene su índice y su corte de ciclos, y su plan está leído
[ ] Está medido el costo por profundidad en las dos, y está escrito dónde se cruzan si se cruzan
[ ] Está escrito, con argumento, cuál de las tres consultas no se escribe razonablemente en SQL
[ ] Está provocado el recorrido infinito sobre el ciclo, en los dos motores
[ ] Está anotado el aviso literal de producto cartesiano de Cypher
[ ] El veredicto reconoce explícitamente qué aguanta Postgres, con el número delante
```
