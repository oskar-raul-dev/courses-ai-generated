# 🪞 Instintos

> **Curso:** Ruta NoSQL Lite · documento vivo
> **Qué es:** cada punto del curso donde **el instinto relacional falla**, con la medición que lo
> demuestra. Es el documento que mejor resume la ruta entera, y el que más sentido tiene leer solo.
> **Formato de cada entrada:** el instinto en tu voz ·
> por qué es razonable · dónde se rompe · la medición que lo prueba, con enlace a la
> [bitácora](bitacora-de-medicion.md) · y **la pregunta del instrumento** que lo habría anticipado.
> **Estado:** completo el 12/10/2026, con los diez, uno por familia. Los 🪞 del capstone —*"lo que está en Postgres
> ya es la fuente de verdad"*, *"si las dos escrituras salen bien, los dos motores quedan iguales"* y *"Postgres
> alcanza para todo"*— viven en sus fases ([23](23-poliglota-el-diseno.md), [24](24-poliglota-la-costura.md) y
> [25](25-poliglota-la-factura.md)), porque no son de ninguna familia.

---

> 🧭 **Un instinto que falla no es un instinto malo.** Cada uno de estos funciona en relacional, y
> por eso es razonable llevarlo a otra familia. Lo que este documento registra es el punto exacto
> donde deja de funcionar, con el número delante.

---

## Índice

| # | Familia | El instinto | Fase |
|---|---|---|---|
| 1 | documental | *"Normalizo, que para eso aprendí"* | [03](03-documental-levantar-y-modelar.md) |
| 2 | clave-valor | *"Le pongo un índice secundario"* | [05](05-clave-valor-levantar-y-modelar.md) |
| 4 | analítico embebido | *"Si habla SQL, es lo mismo que Postgres"* | [07](07-analitico-levantar-y-modelar.md) |
| 5 | series temporales | *"Una tabla con índice en la fecha ya es una serie temporal"* | [09](09-series-levantar-y-modelar.md) |
| 6 | búsqueda | *"Un `LIKE '%junta%'` ya busca"* | [11](11-busqueda-levantar-y-modelar.md) |
| 7 | grafos | *"Eso es una tabla de adyacencia con un `JOIN` recursivo"* | [13](13-grafos-levantar-y-modelar.md) |
| 3 | vectorial | *"Esto es buscar con `LIKE`, pero mejor"* | [15](15-vectorial-levantar-y-modelar.md) |
| 8 | columnar ancha | *"Primero modelo el dominio y luego escribo las consultas"* | [17](17-columnar-levantar-y-modelar.md) |
| 9 | offline-first | *"Sincronizo cuando vuelva la conexión y ya"* | [19](19-offline-levantar-y-modelar.md) |
| 10 | NewSQL | *"Si habla SQL y es ACID, es Postgres con más nodos"* | [21](21-newsql-levantar-y-modelar.md) |

---

## 🍃 1 · "Normalizo, que para eso aprendí"

- **El instinto, en tu voz:** una colección por entidad, referencias por `_id`, y los cruces cuando
  haga falta.
- **Por qué es razonable:** la normalización evita la redundancia, y la redundancia es lo que se
  desincroniza. En Postgres funciona porque el `JOIN` se resuelve en el servidor, en un viaje.
- **Dónde se rompe:** en Mongo, la ficha normalizada y armada desde la aplicación cuesta **25 viajes**
  donde la embebida cuesta **1**; `$lookup` baja a un viaje pero, sin índice en el campo ajeno, recorre
  **1 000 000** de documentos por ficha. El cruce no es gratis: se decide al modelar.
- **La medición:** [M-02](bitacora-de-medicion.md#m-02--la-ficha-completa-de-una-aeronave-de-cuatro-maneras) y
  [M-03](bitacora-de-medicion.md#m-03--lo-que-lookup-examina-por-dentro).
- **La pregunta que lo habría anticipado:** la 3, **¿cuál es la unidad de lectura?**
- **Y el matiz de la Fase 04:** en Postgres, la misma ficha en una consulta también cuesta un viaje
  (50 filas examinadas). El instinto no falla por normalizar; falla por creer que en documental se
  consulta como en SQL.

## 🔑 2 · "Le pongo un índice secundario"

- **El instinto, en tu voz:** las sesiones se buscan por identificador, pero la pantalla de
  supervisión necesita las de un técnico: un índice sobre `technicianId` y listo.
- **Por qué es razonable:** en Postgres es una línea, y desde ese momento cada escritura lo mantiene
  sola, en la misma transacción que la fila.
- **Dónde se rompe:** Valkey no tiene índices secundarios. Sin la clave, las sesiones de un técnico
  cuestan un `SCAN` de **100 000 claves en 202 viajes**; con un set escrito a mano, **2 viajes**. Pero
  el set es otra estructura que mantiene tu código, y el TTL no pasa por tu código: tras vencer 1000
  sesiones, el set sigue con **1000 miembros y ninguno existe**.
- **La medición:** [M-07](bitacora-de-medicion.md#m-07--sesiones-el-índice-escrito-a-mano-y-lo-que-deja-atrás-el-ttl).
- **La pregunta que lo habría anticipado:** la 2, **¿conoces tus consultas de antemano, y son
  estables?** En clave-valor, cada consulta nueva es otra estructura que mantener a mano.

## 🧬 3 · "Esto es buscar con `LIKE`, pero mejor"

- **El instinto, en tu voz:** un `LIKE` que entiende sinónimos y faltas de ortografía: recibe un texto
  y devuelve los reportes que tratan de eso.
- **Por qué es razonable:** los dos reciben un texto y devuelven reportes, y el vector encuentra
  *"golpeteo al extender"* cuando buscas *"ruido metálico"*, cosa que `LIKE` no hace.
- **Dónde se rompe:** el vector no devuelve un conjunto, devuelve un orden, y siempre devuelve k. Arriba
  es impecable —**100 de 100** del tipo de avería correcto—, pero pedidos tantos como hay de ese tipo,
  acierta **728 de 1258**; una receta de arepas devuelve **10** reportes; y una matrícula buscada por
  parecido encuentra **4 de 186**.
- **La medición:** [M-11](bitacora-de-medicion.md#m-11--like-contra-vectores-y-la-búsqueda-exacta-hecha-por-parecido).
- **La pregunta que lo habría anticipado:** la 5, **¿exactitud o parecido?** Es la primera familia del
  curso que devuelve las parecidas, y se evalúa contra una verdad de referencia, no contra un error.

## 🦆 4 · "Si habla SQL, es lo mismo que Postgres"

- **El instinto, en tu voz:** DuckDB recibe mi SQL y me devuelve lo mismo que Postgres; es Postgres sin
  servidor.
- **Por qué es razonable:** el mismo archivo `cost_per_hour.sql` corre sin cambiar un carácter en los dos
  y devuelve las mismas 15 filas, al centavo.
- **Dónde se rompe:** en lo que se lee para contestar. Tres columnas de 50 M lecturas: **203 MiB en
  DuckDB, 4439 MiB en Postgres**; con el mejor índice que admite la consulta, 1884. Y un valor que no
  existe: 0 bytes contra 4439 MiB. Mismo lenguaje, otra disposición de los bytes en el disco.
- **La medición:** [M-15](bitacora-de-medicion.md#m-15--el-costo-por-hora-volada-el-mismo-sql-en-los-dos-motores) y
  [M-16](bitacora-de-medicion.md#m-16--tres-columnas-sobre-50-millones).
- **La pregunta que lo habría anticipado:** la 3, **¿cuál es la unidad de lectura?** Pocas columnas de
  todas las filas es la rebanada para la que una base por filas no está hecha. Es la tesis del curso al
  revés: la etiqueta no decide, el modelo de acceso sí.

## ⏱️ 5 · "Una tabla con índice en la fecha ya es una serie temporal"

- **El instinto, en tu voz:** las lecturas tienen fecha; un índice en `(aircraft, ts)` y otro en `ts`, y
  ya puedo consultar cualquier rango.
- **Por qué es razonable:** **para leer, es correcto.** Sobre 50 M lecturas, la tabla normal tocó menos
  páginas que la hypertable para una aeronave (155 contra 218) y las mismas para la flota en un mes
  (11 040 contra 10 733), con el índice forzado.
- **Dónde se rompe:** al borrar y al resumir. Borrar el primer año: **8 823 630 filas y 1254 MiB de WAL**,
  y la tabla del mismo tamaño, contra **52 chunks y 3,1 MiB**. Mantener el roll-up diario tras un vuelo:
  **50 000 090 lecturas leídas** contra 2420.
- **La medición:** [M-21](bitacora-de-medicion.md#m-21--leer-por-tiempo),
  [M-22](bitacora-de-medicion.md#m-22--el-roll-up-diario-y-lo-que-cuesta-mantenerlo) y
  [M-23](bitacora-de-medicion.md#m-23--borrar-el-primer-año).
- **La pregunta que lo habría anticipado:** la 2, **¿conoces tus consultas de antemano?** Borrar y
  resumir por tiempo son consultas conocidas desde el primer día, y modelar para ellas es partir por
  tiempo.

## 🔍 6 · "Un `LIKE '%junta%'` ya busca"

- **El instinto, en tu voz:** para buscar en el catálogo, `ILIKE` con comodines a los dos lados; si un día
  es lento, un índice.
- **Por qué es razonable:** encuentra lo que contiene el texto, y en un catálogo pequeño contesta al
  instante.
- **Dónde se rompe:** en lo que encuentra y en lo que lee. Con lo que escribe Sandra —*"juntas toricas
  tren"*, *"oring del tren"*— `LIKE` devuelve **0 de 10 287** leyendo el millón; el `ILIKE '%junta%'` que sí
  devuelve algo trae 72 485, y al menos 62 198 de ellas no son la pieza buscada. OpenSearch: **10 287 de 10 287**, con analizadores
  que entienden plural, tildes y jerga. Y un patrón que empieza con `%` no usa B-tree.
- **La medición:** [M-28](bitacora-de-medicion.md#m-28--las-búsquedas-de-sandra).
- **La pregunta que lo habría anticipado:** la 5, **¿exactitud o parecido?** Sandra quiere exactitud sobre
  lo que quiso decir, no sobre lo que tecleó.

## 🕸️ 7 · "Eso es una tabla de adyacencia con un `JOIN` recursivo"

- **El instinto, en tu voz:** un grafo son nodos y aristas; en Postgres, una tabla de aristas con índice y
  un `JOIN`, recursivo si hace falta.
- **Por qué es razonable:** **con saltos conocidos, acierta.** La directiva en sus dos mitades: Postgres
  examina 1413 y 1801 filas; Neo4j hace 2655 y 5952 accesos.
- **Dónde se rompe:** en qué hay en la tabla. La estadía de una pieza en una aeronave, con sus fechas, no
  existía en el esquema; derivarla en la consulta examinó **4 939 732 filas** donde guardarla como relación
  —en el grafo, o en `part_stint`— recorre unas **94 000**. Y la segunda mitad del instinto, *"hasta que la
  profundidad es desconocida"*, es la apuesta de la Fase 14.
- **La medición:** [M-34](bitacora-de-medicion.md#m-34--la-directiva-con-saltos-conocidos) y
  [M-35](bitacora-de-medicion.md#m-35--la-estadía-derivada-o-guardada).
- **La pregunta que lo habría anticipado:** la 4, **¿cuántos saltos tiene tu relación típica, y los conoces
  de antemano?**

## 🏛️ 8 · "Primero modelo el dominio y luego escribo las consultas"

- **El instinto, en tu voz:** entidades, relaciones, normalizar; las consultas vienen después, y el
  planificador encuentra el camino.
- **Por qué es razonable:** en relacional funciona: un modelo normalizado contesta preguntas que nadie había
  pensado. Y para las preguntas que siguen la clave, Postgres particionado iguala la forma de Cassandra: tres
  particiones y 9666 filas para 9666, a 5 M y a 50 M.
- **Dónde se rompe:** en columnar ancha **cada consulta nueva es una tabla nueva más un backfill**. La cuarta
  pregunta de Cóndor costó leer **5 000 000 de filas para escribir 62 486**, y una escritura más en cada carga.
  Modelada por entidades, con `ALLOW FILTERING`, la consulta de siempre lee **la tabla entera**: 5 000 000 de
  filas para 9666, y a 10 M ya no contesta: el nodo cancela la lectura a los 5 s
  ([Fase 18](18-columnar-romper-y-medir.md)).
- **La medición:** [M-41](bitacora-de-medicion.md#m-41--tres-preguntas-tres-tablas-y-postgres-particionado),
  [M-42](bitacora-de-medicion.md#m-42--el-backfill-de-una-consulta-nueva) y
  [M-45](bitacora-de-medicion.md#m-45--la-entidad-con-allow-filtering-en-tres-volúmenes) y
  [M-51](bitacora-de-medicion.md#m-51--allow-filtering-hasta-que-deja-de-contestar).
- **La pregunta que lo habría anticipado:** la 2, **¿conoces tus consultas de antemano, y son estables?**

---

## 📴 9 · "Sincronizo cuando vuelva la conexión y ya"

- **El instinto, en tu voz:** la tableta guarda lo que pasa sin señal y, cuando vuelve la red, lo manda al
  servidor, como un `INSERT` que llegó tarde.
- **Por qué es razonable:** en relacional el servidor serializa: el segundo que escribe recibe un error o espera, y
  el conflicto no llega a existir. Y con un solo técnico por orden, sincronizar es exactamente eso.
- **Dónde se rompe:** el conflicto **es el caso normal**. En un viaje de tres días con dos técnicos, **dos de las
  cuatro órdenes** terminaron con dos hojas, y en `workOrder-10k` **4138 de las 10 000 órdenes** tienen más de un
  técnico. No llega con un error: llega como dos revisiones perdedoras que ninguna lectura normal devuelve, con seis
  ediciones de Jairo adentro. Resuelto con "el último que escribe gana", se lleva **9 de las 19** de Freddy.
- **La medición:** [M-54](bitacora-de-medicion.md#m-54--el-viaje-de-freddy-cinco-maneras-de-terminarlo) y
  [M-55](bitacora-de-medicion.md#m-55--el-mismo-viaje-contra-postgres-como-servidor).
- **La pregunta que lo habría anticipado:** la 1, **¿dónde está la frontera transaccional?** En la tableta, alrededor
  de cada edición que un técnico hizo sin ver a nadie, y no de la orden.

---

## ⚡ 10 · "Si habla SQL y es ACID, es Postgres con más nodos"

- **El instinto, en tu voz:** CockroachDB habla el protocolo de Postgres y es serializable: corro mi esquema, el
  motor reparte los datos entre los nodos, y tengo lo mismo de siempre en varios países.
- **Por qué es razonable:** en lo que el SQL expresa, es literal. El esquema de la Fase 01 entra con dos líneas
  menos, las consultas devuelven lo mismo, el driver es el mismo, y la anomalía que el `SERIALIZABLE` de Postgres
  rechaza también la rechaza aquí. Es primo del 4: allí el SQL era el mismo y cambiaba cómo se lee; aquí cambia
  **dónde vive cada fila**.
- **Dónde se rompe:** en todo lo que el SQL no dice. Copiado tal cual, el esquema quedó en **un solo rango con un
  votante en cada país**: las **1990 filas** del operador estatal ecuatoriano con copias en Colombia y Perú, el
  expediente atendido en una carga por un nodo peruano, y cada escritura de la rutina del Coca esperando a un segundo
  país para confirmar. Ni la región por fila alcanza sola: con la ubicación por defecto, las 1990 siguen con copias
  no votantes afuera, y cada `INSERT` pregunta en las tres regiones si la clave ya existe. A eso se suman el `40001`
  por defecto y un reloj que reinició **cinco de cinco** lecturas.
- **La medición:** [M-62](bitacora-de-medicion.md#m-62--una-posición-una-pieza-cuatro-aislamientos),
  [M-63](bitacora-de-medicion.md#m-63--dónde-viven-las-filas-del-operador-estatal),
  [M-64](bitacora-de-medicion.md#m-64--qué-regiones-toca-cada-trabajo-del-expediente) y
  [M-65](bitacora-de-medicion.md#m-65--el-reinicio-por-incertidumbre-del-reloj).
- **La pregunta que lo habría anticipado:** la 1, **¿dónde está la frontera transaccional?**, y con ella, de quién
  es cada fila que cae adentro: el expediente es una sola unidad, tiene dueño legal, y se escribe desde dos países.
