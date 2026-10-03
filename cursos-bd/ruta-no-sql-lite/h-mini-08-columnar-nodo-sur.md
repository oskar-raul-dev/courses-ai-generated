# 🏛️ Miniproyecto 08 · Columnar ancha — Nodo Sur

> **Familia:** columnar ancha · **Motor:** Cassandra · **Línea base:** PostgreSQL particionado
> **Cierra:** el minicurso de columnar ancha (Fases 17–18) · **Empresa:** 📡 Nodo Sur
> **Estado:** opcional · **No entra a la bitácora de medición**

---

## 🏢 La empresa

Nodo Sur es el proveedor de internet por fibra de
[`h-mini-02-clave-valor-nodo-sur.md`](h-mini-02-clave-valor-nodo-sur.md): ciento sesenta mil
suscriptores en cuatro departamentos, crecidos barrio a barrio más rápido de lo que la
plataforma aguantaba.

Su red produce un dato que no para nunca: **registros de tráfico**. Cada sesión de cada equipo
genera entradas con origen, destino, volumen, duración y nodo por el que pasó. Se guardan por
tres motivos distintos, y esos tres motivos son todo el miniproyecto porque **cada uno consulta
de una forma incompatible con las otras dos**.

## ⚰️ El dolor

**Una sola tabla sirviendo a tres consumidores que no se parecen en nada.**

El soporte pregunta por suscriptor: *"este señor dice que anoche no le servía, muéstrame su
tráfico de ayer por hora"*. La ingeniería de red pregunta por nodo: *"dame los que más
consumieron en este nodo entre las ocho y las once de anoche"*. Y el área legal pregunta por
rango de fechas y por dirección, cuando llega un requerimiento formal.

En 2016, con cuatro mil suscriptores, alguien creó una tabla `flow` en Postgres, particionada
por día, con índices sobre suscriptor y sobre nodo. Fue la decisión correcta: cubría los tres
casos, cabía, y no había que operar nada nuevo.

Hoy esa tabla recibe **cientos de millones de filas al día** y los tres consumidores se estorban.
La consulta del soporte tarda minutos cuando el cliente está al teléfono. La de ingeniería se
corre de madrugada porque de día compite. Y los índices —que son tres, sobre una tabla que solo
crece— ocupan más que los datos.

Y hubo una decisión más, también razonable, que empeoró todo: cuando un suscriptor pide que
borren sus datos, **se borra fila por fila**. Es lo que hay que hacer y es lo que dice la ley.
Nadie previó lo que eso le hace a una tabla de este tamaño.

**La factura tiene fecha.** En febrero de 2026 llegó un requerimiento legal con plazo de
respuesta de cinco días hábiles sobre un rango de tres meses. La consulta no terminó. Hubo que
correrla por tramos, de noche, durante siete días, y pedir una prórroga. Nelson lo resumió en
una frase que quedó dando vueltas: *"tenemos el dato y no lo podemos sacar; para el caso es lo
mismo que no tenerlo"*.

## 🎯 El encargo

**Lo pide Nelson Aguirre, líder de plataforma.**

> *"No me digas que particione mejor, que eso ya lo hice dos veces. Lo que necesito saber es si
> esto se arregla con el motor que tengo o si de verdad se me acabó. Y si se me acabó, quiero
> **saber exactamente qué gano y qué pierdo**, porque lo que me cuentan de Cassandra es que
> escala, y eso no me sirve como argumento para la junta."*

## 🧩 Lo que se construye

El mismo histórico de tráfico, modelado de las dos maneras que importan:

- **Modelado por entidad**, que es lo que hay hoy y es lo que hace todo el mundo la primera vez:
  una tabla de flujos y varios índices. Hay que construirlo **también en Cassandra**, mal a
  propósito, porque el anti-patrón de esta familia solo se entiende ejecutándolo.
- **Modelado por consulta**, que es el cambio de paradigma: una tabla por patrón de acceso
  —`flows_by_subscriber`, `flows_by_node`, `flows_by_address_range`— con la misma información
  escrita tres veces, a propósito y sin culpa.
- **La comparación contra Postgres particionado bien jugado**, que es el rival real y el que
  decide si esto vale el componente.

## 📐 Lo que se observa

- **Particiones tocadas y SSTables leídas** por cada una de las tres consultas, en cada modelo.
- **La amplificación de escritura**: cuántas estructuras se actualizan al registrar un flujo en
  el modelo por consulta, que es el precio que se paga por la lectura barata.
- **El hot spot**, provocado a propósito: usa el nodo como clave de partición y observa qué le
  pasa a la partición del nodo principal, que concentra buena parte del tráfico de la red.
- **El costo de borrar**: los tombstones que deja una supresión por suscriptor y qué le hacen a
  las lecturas siguientes de esa partición.

## 💥 Dónde se rompe

**La partición que crece sin cota.** Si eliges como clave algo que no acota el crecimiento —el
nodo, sin componente de tiempo— la partición crece para siempre y termina tumbando el nodo que
la tiene. Provócalo y mira cómo se manifiesta.

Y el que más enseña de los dos: **`ALLOW FILTERING`**. Escribe la consulta que no previste, mira
cómo el motor se niega, anota el mensaje literal, y después ponlo y mide lo que cuesta. Es el
momento en que se entiende que **no es un defecto del motor, es el trato**: una consulta nueva
es una tabla nueva más un backfill, y eso hay que saberlo antes de firmar.

## ⚖️ El veredicto que tiene que salir

**Aquí la familia gana, y gana de verdad** — es uno de los pocos casos del curso donde el dato ya
no cabe en un nodo y no es una hipótesis. Pero el veredicto útil no es ese: es **el reparto**.

**Las consultas del soporte y del área legal se van**, porque son conocidas, estables y se
repiten idénticas mil veces al día. Ese es exactamente el trato de esta familia y Nodo Sur lo
cumple.

**Las de ingeniería de red no deberían irse**, y esta es la parte incómoda. La ingeniería
*explora*: cambia el criterio, cruza dimensiones, prueba una hipótesis y la descarta. **No
conoce sus consultas de antemano**, que es justamente la pregunta que esta familia exige
responder que sí. Meterlas aquí significa una tabla nueva cada vez que a alguien se le ocurre
algo, y el resultado previsible es `ALLOW FILTERING` puesto para que "funcione".

Lo que esas consultas necesitan es otra cosa: una exportación periódica a formato columnar y
análisis embebido encima — exactamente lo del
[miniproyecto 03](h-mini-03-analitico-bengala.md). **Dos familias, dos preguntas distintas,
sobre el mismo dato.** Reconocer eso es el objetivo real de este encargo.

## 🧰 El stack

| Pieza | Qué se usa | Nota |
|---|---|---|
| Entorno | **Node + TypeScript** | |
| Motor | **Cassandra** · perfil `columnar` | Con el heap fijado por el `compose.yaml` de la ruta. ScyllaDB habla el mismo CQL y el modelado no cambiaría, pero se descartó por licencia (alcance §12, 16) |
| CLI | `cqlsh` | Y `nodetool` para mirar tablas, histogramas y compactaciones |
| Driver | `cassandra-driver` de Node | |
| Línea base | **PostgreSQL** con particionado declarativo · perfil `base` | Más la tabla con tres índices de hoy, construida como villano |
| Modelado | **Tabla por consulta**: `flows_by_subscriber`, `flows_by_node`, `flows_by_address_range` | La misma información escrita tres veces, a propósito y sin culpa |
| Medición | `TRACING ON` (particiones tocadas, SSTables leídas, tombstones) · `nodetool tablestats` · `EXPLAIN (ANALYZE, BUFFERS)` | |
| Datos | Generador del curso | **Distribución de tráfico desigual por nodo**: un generador uniforme esconde justo el hot spot que hay que encontrar |
| Entregable | `src/h-mini-08-columnar-nodo-sur/` | |

**Qué NO entra:** clúster de varios nodos reales —el curso corre en una máquina y eso se
declara—, reparaciones, ni afinación de compactación como disciplina. `ALLOW FILTERING` sí
entra, y entra para medir lo que cuesta, no para usarlo.

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

Es la **Fase 17**: la telemetría de vuelo de Cóndor cuando las ciento cuarenta aeronaves tengan
registro y no solo treinta. Misma forma de dato, mismo régimen de escritura, misma decisión de
clave de partición.

Pero el puente que más vale es al revés, y conviene decirlo en la fase: **Cóndor todavía no
está aquí, y ese es el punto.** Treinta aeronaves caben de sobra en Postgres particionado, y
proponer esta familia hoy en Cóndor sería el anti-patrón que el propio curso declara. La
pregunta que el lector tiene que saber contestar al terminar no es *"¿cómo se modela en
columnar ancha?"* sino **"¿a qué volumen me toca?"** — y eso se contesta con una medición, no
con una intuición.

## 📋 Criterios de aceptación

```text
[ ] Está construido el modelo por entidad, mal a propósito, y medido
[ ] Están las tres tablas por consulta, con la información escrita tres veces
[ ] Está medida la amplificación de escritura del modelo por consulta
[ ] Está provocado el hot spot con una clave de partición mal elegida, y medido
[ ] Está anotado el mensaje literal de ALLOW FILTERING, y medido lo que cuesta ponerlo
[ ] Está medido el efecto de los tombstones tras una supresión por suscriptor
[ ] Está montado el mismo caso en Postgres particionado, bien jugado
[ ] El veredicto reparte: qué consulta se va, cuál se queda, y cuál pertenece a otra familia
```
