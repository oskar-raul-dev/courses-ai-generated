# 🧬 Miniproyecto 07 · Vectorial — Cumbre Roja

> **Familia:** vectorial · **Motor:** Qdrant · **Línea base:** PostgreSQL con `pgvector`
> **Cierra:** el minicurso vectorial (Fases 15–16) · **Empresa:** ☕ Cumbre Roja
> **Estado:** opcional · **No entra a la bitácora de medición**
> ⚠️ **Es uno de los dos miniproyectos con veredicto incómodo.** Ver
> [`miniproyectos.md`](miniproyectos.md) §3.1.

---

## 🏢 La empresa

Cumbre Roja es una cooperativa de dos mil trescientos caficultores que en 2018 dejó de venderle
a un intermediario, montó su propia trilladora y empezó a exportar con marca propia. Hoy vende a
cuatro países y a once compradores, y el negocio cambió de naturaleza sin que casi nadie lo
notara: **antes vendían café; ahora venden un perfil.**

Un comprador especializado no pide "café de Colombia". Pide un perfil de taza: un rango de
puntaje, unas notas concretas, un cuerpo, una acidez. Y lo pide **otra vez el año siguiente**,
igual, aunque la cosecha haya sido distinta. Esa es la promesa que Cumbre Roja tiene que
cumplir, y es la que decide si el comprador vuelve.

La calidad se decide en una mesa de catación. Cada lote que entra se tuesta, se prepara y se
prueba, y alguien escribe unas líneas: *"panela y mora madura, cuerpo sedoso, acidez cítrica
media, retrogusto largo a chocolate"*. Van **catorce mil lotes al año**, y ocho años de esas
notas en una tabla.

## ⚰️ El dolor

**La pregunta del negocio vive en la cabeza de una persona, y esa persona se jubila.**

*"¿Qué lote se parece a este?"* es literalmente la operación central: cuando entra un pedido
con un perfil, hay que encontrar en bodega los lotes que se le acercan y armar la mezcla que lo
alcanza. Hoy eso lo hace **Dora Lucía Betancur**, catadora principal, sesenta y un años,
veintitrés en el oficio. Se acuerda. Dice *"eso se parece a lo que compramos en el Tambo hace
dos años"* y acierta.

La decisión que dejó esto así fue perfectamente razonable. Cuando montaron el sistema de
catación, alguien propuso estandarizar las notas en una lista cerrada de descriptores para poder
buscarlas. La mesa de catación dijo que no, y tenía razón: **una lista cerrada empobrece la
nota**, obliga al catador a elegir la etiqueta menos mala, y lo que se pierde es exactamente el
matiz que distingue un lote de ochenta y tres puntos de uno de ochenta y siete. Así que las
notas se quedaron en texto libre, que es lo correcto.

Lo que nadie resolvió fue cómo buscar en texto libre. Y el texto libre, sin forma de buscarlo,
es un archivo muerto de ciento doce mil notas.

**La factura tiene fecha.** En la cosecha de 2025 un comprador alemán pidió repetir el perfil de
un contenedor de 2023. Se armó la mezcla con lo que el equipo recordaba y con lo que decía el
puntaje. **El comprador rechazó el contenedor**: el puntaje era el mismo y el perfil no. Costó
la devolución, el reproceso y —lo que de verdad dolió— la renegociación del contrato del año
siguiente a la baja. Después, revisando a mano, encontraron tres lotes en bodega que habrían
armado esa mezcla. Estaban ahí todo el tiempo.

## 🎯 El encargo

**Lo pide Dora Lucía Betancur, catadora principal, y lo pide así:**

> *"Yo me voy en dos años y esto no está escrito en ninguna parte. Necesito poder pegar la nota
> de un contrato viejo, o la que me manda el comprador en su correo, y que la máquina me saque
> los lotes que tengo en bodega que se le parecen. **No que me saque el mejor puntaje** — eso ya
> lo sé hacer. Que me saque los que se le parecen, aunque tengan dos puntos menos."*

## 🧩 Lo que se construye

Un buscador por parecido sobre las notas de catación, con la pieza que lo hace utilizable:

- **El corpus vectorizado:** ocho años de notas, convertidas a embeddings con un modelo pequeño
  y fijado. El modelo entra como caja cerrada y no se entrena nada — esto no es un curso de IA
  y conviene decirlo en el propio miniproyecto.
- **La búsqueda por parecido** contra la nota de referencia, que puede ser un lote histórico o
  el texto que mandó el comprador por correo.
- **El filtro por metadatos**, que es donde esta familia se vuelve útil de verdad: solo lo que
  hay en bodega, solo de esta cosecha, solo de esta altura, solo de estas variedades. Sin filtro,
  el resultado es interesante y no sirve.
- **La evaluación**, que aquí no es opcional: un conjunto de casos con la respuesta conocida,
  armado **con Dora antes de montar nada**. Ella dice qué lote se parece a cuál; el sistema se
  mide contra eso.
- Y el mismo caso con `pgvector` al lado, porque es el rival real de esta familia.

## 📐 Lo que se observa

- **Recall contra la respuesta de Dora**, que es la única verdad disponible y vale más que
  cualquier métrica sintética.
- **Recall contra velocidad** al mover los parámetros del índice: la métrica propia de la
  familia y su trampa — se puede ser rapidísimo devolviendo basura.
- **El efecto del filtro por metadatos** sobre la calidad del resultado, medido con y sin él.
- **La memoria que ocupa el índice** con el corpus completo, que es el número que decide si esto
  cabe en la máquina que tiene la cooperativa.

## 💥 Dónde se rompe

**El índice que no cabe en memoria, y el recall que se desploma al bajar los parámetros para que
quepa.** Es el punto de rotura de la familia y hay que llegar a él a propósito: reduce los
parámetros hasta que entre, mide el recall otra vez, y mira qué le quedó.

Y el segundo, que es el que le va a pasar a Cumbre Roja de verdad: **el día que cambien de
modelo de embeddings.** Eso es una reindexación completa del corpus y una invalidación de todo
lo que haya guardado. Averigua cuánto dura y escríbelo, porque es la decisión que nadie toma
informado.

## ⚖️ El veredicto que tiene que salir — y es incómodo

**Vectorial gana, pero no gana solo.** El parecido semántico es lo que encuentra el lote que
Dora encontraba de memoria, y no hay forma honesta de conseguir eso con búsqueda por palabras:
"panela" y "azúcar morena" no comparten un carácter y son casi lo mismo en una taza. Hasta aquí
la familia se defiende sola.

**Pero vectorial sin filtro por metadatos devuelve poesía.** Los diez lotes más parecidos del
histórico son inútiles si ocho ya se vendieron y uno es de otra cosecha. **Lo que le sirve a la
cooperativa es la combinación**, y el miniproyecto está mal resuelto si termina presentando el
buscador semántico como la respuesta en vez de como la mitad de la respuesta.

Y el tercer veredicto, que es el de la familia entera: **para lo exacto, la búsqueda exacta.**
*"Lotes de variedad caturra con puntaje mayor a ochenta y cuatro"* no necesita vectores, ya
existe, es más barata y acierta más. Si en tu diseño esa consulta pasa por el motor vectorial,
lo estás usando mal.

## 🧰 El stack

Es el otro miniproyecto con **Python**, y por una razón que conviene que el código demuestre:
Python manda en la **ingesta** de embeddings, no en la consulta.

| Pieza | Qué se usa | Nota |
|---|---|---|
| Ingesta de embeddings | **Python** | Es donde vive el ecosistema, y es el único tramo donde hace falta |
| Consulta, arnés y evaluación | **TypeScript** | Los motores exponen REST y gRPC: **el mito de que "esto es de Python" se cae aquí**, y el miniproyecto lo demuestra |
| Motor | **Qdrant** · perfil `vectorial` | `qdrant-client` desde Python para cargar, API HTTP desde TypeScript para consultar |
| Modelo de embeddings | **`intfloat/multilingual-e5-small`**, fijado por revisión en `a06` | El mismo ONNX en Python (ingesta) y en `transformers.js` (consulta). Entra como caja cerrada: **no se entrena nada**. Ojo con los prefijos `query:`/`passage:` |
| Línea base | **PostgreSQL** con `pgvector` · perfil `base` | Índice HNSW, y el mismo filtro por metadatos en `WHERE` |
| Drivers | `psycopg` desde Python · `pg` desde TypeScript | |
| Evaluación | Conjunto de casos en JSON, **armado con la catadora antes de montar el índice** | Es la pieza que decide si el miniproyecto vale algo |
| Medición | Recall contra la respuesta humana y contra fuerza bruta · memoria del índice · recall contra velocidad al mover los parámetros | |
| Datos | Generador del curso | Ocho años de notas de catación en prosa, con vocabulario de taza real y metadatos de cosecha, altura y variedad |
| Entregable | `src/h-mini-07-vectorial-cumbre-roja/` | |

**Qué NO entra:** entrenar o ajustar modelos, ingeniería de prompts, y cualquier modelo de
lenguaje en el camino de la consulta. **Esto no es un curso de IA**: es un índice de vecinos
aproximados y su compromiso, y el documento debe decirlo con esas palabras.

> ⚠️ **Ninguna versión ni digest se escribe aquí.** Viven en `a02` y se fijan ejecutando, en la
> sesión de verificación de laboratorio. Este stack nombra piezas, no números.
>
> 🧭 **Dos reglas del curso que este miniproyecto no puede saltarse.** El **arnés de medida y el
> generador de datos son TypeScript siempre** (`a06`): son el instrumento, y un instrumento
> con dos implementaciones deja de ser un instrumento. Y **se habla con los motores
> directamente**: nada de ORM, ODM ni cliente de alto nivel (`a06`), porque esas capas esconden
> justo lo que queremos medir.

---

## 🔗 El puente con Cóndor

Es la **Fase 15**: los reportes de piloto de Cóndor son el mismo problema con otra prosa.
*"Ruido metálico al bajar tren, intermitente"* y *"golpeteo al extender"* son el mismo evento
escrito por dos personas distintas, y hoy esa conexión vive en la memoria de Freddy Manrique
igual que la de los lotes vive en la de Dora.

El paralelo que conviene señalar en la fase es el que incomoda: **las dos empresas tienen el
mismo riesgo operativo y no es tecnológico.** El conocimiento que hace funcionar el negocio
está en una persona que se va a ir, y nadie lo ha escrito. Esta familia no lo escribe tampoco
—no lo transforma en conocimiento— pero sí hace **buscable** el rastro que esa persona fue
dejando durante veinte años sin saberlo. Eso es todo lo que hace, y es bastante.

Y tres cosas que las Fases 15 y 16 midieron sobre Cóndor y que este miniproyecto tiene que tener en
cuenta desde el primer día:

- **Con pocos datos, Qdrant no construye el índice.** Por debajo de `indexing_threshold` busca
  recorriendo todo, y acierta siempre. Ciento doce mil notas pueden quedar cerca de ese umbral: mira
  `indexed_vectors_count` antes de medir nada "del índice".
- **El filtro por metadatos es donde `pgvector` y Qdrant dejan de ser intercambiables.** Con un filtro
  del 8 % de un millón de reportes, `pgvector` devolvió 1 fila de 10 por defecto y acertó la mitad con su
  recorrido iterativo; Qdrant acertó 0,995. *"Solo lo que hay en bodega, de esta cosecha"* es justo un
  filtro así: mide su selectividad antes de elegir motor.
- **La memoria no se lee en `docker stats`.** Los dos motores leen sus datos a través de la caché del
  sistema operativo, y `docker stats` la resta. El número que decide si cabe en la máquina de la
  cooperativa está en el cgroup del contenedor.

## 📋 Criterios de aceptación

```text
[ ] El conjunto de evaluación se armó con la catadora ANTES de montar el índice
[ ] El modelo de embeddings está fijado y declarado, y no se entrena nada
[ ] Está medido el recall contra la respuesta humana, no solo contra fuerza bruta
[ ] El filtro por metadatos está implementado, y está medido el resultado con y sin él
[ ] Está medido el compromiso recall contra velocidad al mover los parámetros del índice
[ ] Está montado el mismo caso con pgvector y comparado en recall y en memoria
[ ] Está cronometrada la reindexación completa por cambio de modelo
[ ] El veredicto dice explícitamente qué consultas NO deben pasar por el motor vectorial
```
