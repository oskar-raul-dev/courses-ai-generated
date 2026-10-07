# 🔑 Fase 05 — Clave-valor: el foso que se reserva una vez, modelado sin una sola consulta

> **Curso:** Ruta NoSQL Lite · Fase 05 de 25 · Bloque I — Los dos que ya usas · **10 h**
> **Familia:** clave-valor · **Motor:** Valkey 9.1.2 `valkey/valkey@sha256:418652cfb58e…`
> **Línea base:** PostgreSQL 18.6 `pgvector/pgvector@sha256:2ba9ca5f2e7d…` (tabla `UNLOGGED`, en la Fase 06)
> **Entorno de ejecución:** TypeScript
> **Volumen:** `workOrder-1m` (`datasetSha256` `11a67c65fb22…`), con 100 000 sesiones de terminal
> sobre sus 908 técnicos
> **Depende de:** Fase 04 · **Habilita:** Fase 06
> **Apéndices de apoyo:** [`a01`](a01-laboratorio-contenerizado.md), [`a02`](a02-compose-de-la-ruta.md),
> [`a03`](a03-clis-de-los-motores.md), [`a04`](a04-el-arnes-de-medida.md), [`a05`](a05-el-dominio-de-flota.md),
> [`a06`](a06-lenguajes-y-drivers.md)
> **Fecha de verificación ejecutada:** 29/09/2026, en macOS arm64
> **Objetivo:** modelar las reservas, los candados, las sesiones y la cola de Cóndor de forma que
> **cada operación sea un comando sobre una clave conocida**, y medir lo que cuesta cada vez que el
> diseño necesita algo más que la clave.

---

## 🧭 1. Dónde estamos

La documental fue la familia de la ficha: un agregado que se lee entero. Esta es la del otro extremo:
no hay agregado, ni esquema, ni consultas. **Hay una clave, y detrás de ella un valor.** Es el modelo
de acceso más puro del curso, y las familias que vienen después son, en el fondo, clave-valor con algo
encima.

Cóndor la necesita por el segundo dolor de su historia: **tres puestos con foso en Villavicencio y dos
grupos pidiendo el mismo el mismo día**, y órdenes de trabajo que dos técnicos abren a la vez desde
dos terminales. Las dos cosas tienen la misma forma: alguien gana, el otro se entera de que perdió, y
la decisión dura lo justo.

Valkey es el fork de la última versión BSD de Redis, respaldado por la Linux Foundation
([`a10`](a10-licencias-y-riesgo.md) cuenta por qué el curso lo prefiere). Para lo que esta fase enseña
son intercambiables: el mismo protocolo, los mismos comandos, y la instancia del laboratorio todavía
se anuncia como `redis_version:7.2.4` junto a su `valkey_version:9.1.2`.

Igual que en la Fase 03, **esta fase no compara contra Postgres**: la tabla `UNLOGGED` es la línea
base de la [Fase 06](06-clave-valor-romper-y-medir.md).

---

## 🎯 2. Objetivos de esta fase

1. Cargar **100 000 sesiones** del terminal de plataforma en **100 viajes**, con su TTL y su índice
   secundario escrito a mano, y medir su memoria: **206 bytes por sesión**.
2. Resolver la reserva del puesto con foso con un solo comando atómico, y demostrar que el segundo
   grupo recibe `null`.
3. Tomar y soltar el candado de una orden abierta desde dos terminales, con **liberación por token**:
   el terminal ajeno no puede soltarlo.
4. Montar la cola de pendientes por base (sorted set) y el registro de eventos (stream con grupo de
   consumidores) con las **16 440** órdenes del último mes.
5. Medir el 🪞 de la fase: buscar sin la clave cuesta **202 viajes** y recorrer 100 000 claves; con la
   segunda estructura, **2 viajes**, y esa estructura hay que mantenerla a mano.
6. Reproducir la situación 3: Valkey como almacén primario pierde **1 000 000 de órdenes de 1 000 000**
   con la persistencia por defecto y un `SIGKILL`.

---

## 🚫 3. Qué NO entra todavía

- **La comparación contra la tabla `UNLOGGED` de Postgres** —viajes, memoria por sesión y qué se
  pierde al reiniciar—. Es la apuesta de la [Fase 06](06-clave-valor-romper-y-medir.md).
- **`maxmemory`, políticas de evicción y el error de memoria llena.** Fase 06.
- **RDB contra AOF medidos uno contra otro.** Aquí se ve solo la configuración por defecto; la Fase 06
  compara las tres.
- **Replicación, Sentinel y cluster.** Fuera del alcance del curso. El laboratorio es un
  nodo, y todo lo que se dice de atomicidad vale para un nodo.
- **Módulos** (búsqueda, JSON, filtros de Bloom). La imagen del curso no trae ninguno: `MODULE LIST`
  solo muestra `lua`. La búsqueda de texto es la Fase 11.
- **Pub/Sub.** No entra al curso: no guarda nada, y el stream de la sección 6.8 cubre el caso de
  Cóndor.

---

## 🏗️ 4. Levantar el motor

La receta está en [`a02`](a02-compose-de-la-ruta.md): un servicio sin configuración propia, el
healthcheck es `valkey-cli ping`, y el volumen `clave-valor-data` lo declara el compose porque la
imagen no lo hace. Desde la raíz del curso:

```bash
cd src/lab && docker compose --profile clave-valor up -d --wait && cd ..
node lab/generator/src/generate.ts --focus workOrder --volume 1m
node 05-clave-valor-levantar-y-modelar/model.ts --dataset lab/data/workOrder-1m
```

```text
dataset workOrder-1m (11a67c65fb22…)

sesiones: 100000 en 100 viajes · 206 bytes por sesión, con su entrada en el índice · MEMORY USAGE de una: 160 bytes
sesiones de T-002: sin índice, SCAN de 100000 claves en 202 viajes → 111 · con el set a mano: 111 en 2 viajes
índice a mano tras vencer 1000 sesiones por TTL: el set sigue con 1000 miembros, de los que existen 0

reserva de slot:VVC:foso-1:2026-10-06: grupo-motores → OK · grupo-estructuras → null · dueño: grupo-motores
candado de WO-0000001: terminal-2 → OK · terminal-5 → null · liberar con token ajeno → 0 · con el propio → 1
cola y eventos: 16440 órdenes del último mes · 112 bytes por orden (entrada en la cola + evento) · la más antigua en VVC: WO-0983562 · XREADGROUP entregó 5 eventos a yamile
```

`model.ts` empieza con `FLUSHALL`: **borra la instancia entera**. Las secciones 6 a 8 leen esa salida.

> ⚠️ **Los bytes por entrada de cola varían en uno o dos entre corridas** (112 y 113 en la
> verificación). Salen de restar `used_memory` antes y después, y el asignador de memoria no es
> exacto a ese nivel. Las cifras de sesión, con 100 000 entradas, no se movieron.

---

## 📖 5. El diccionario de la familia

| Relacional | Clave-valor (Valkey) | Dónde se rompe el paralelo |
|---|---|---|
| tabla | prefijo de clave (`session:`, `slot:`) | no existe como objeto: es una convención de nombres, y nadie la hace cumplir |
| fila | el valor de una clave (un hash, aquí) | se lee y se escribe **por la clave**, nunca por su contenido |
| clave primaria | la clave | es **la única vía de acceso** |
| índice secundario | otra estructura, escrita y mantenida a mano (sección 7) | ninguna escritura la actualiza por ti |
| `WHERE` | no existe | `SCAN MATCH` filtra por el **nombre** de la clave, no por lo que guarda |
| `UNIQUE` + `INSERT` que falla | `SET … NX` | el segundo no recibe un error: recibe `null` |
| `DELETE` periódico por fecha | TTL (`EXPIRE`, `PX`) | lo borra el motor, sin consulta y sin que nadie lo programe |
| tabla-cola con `SKIP LOCKED` | sorted set, stream con grupo de consumidores | cada uno es una estructura con sus propios comandos |
| transacción | `MULTI`/`EXEC` o un script Lua | atómico, pero **sin rollback** |
| `EXPLAIN` | no existe | el costo lo dice la complejidad documentada de cada comando: O(1), O(log N), O(N) |

Y en la otra dirección, que es la que se usa al volver a Postgres: una **clave** es una fila buscada
por clave primaria, un **TTL** es una columna `expires_at` más un proceso que borra, un **`SET NX`** es
un `INSERT … ON CONFLICT DO NOTHING` que te dice si ganaste, y un **sorted set** es una tabla con un
índice sobre la puntuación. La Fase 06 mide esa traducción. El diccionario completo está en
[`a08`](a08-diccionario-y-glosario.md).

> 🩻 **Esto sí funciona igual.** Los viajes siguen siendo la métrica que manda, y agrupar sigue siendo
> la forma de bajarlos: un pipeline de Valkey es la misma idea que el `jsonb_to_recordset` de la
> [Fase 01](01-el-dominio-de-flota-y-el-arnes.md). Recorrer todo sigue siendo caro: `SCAN` es el
> `Seq Scan` de esta familia. Y la unicidad por clave es la misma garantía que una clave primaria.

---

## 🧩 6. Modelar Cóndor a la manera clave-valor

### 6.1 Sin la clave, no hay consulta

La frase de la familia se entiende mejor probándola que leyéndola. Con 100 000 sesiones cargadas,
*"¿qué sesiones están abiertas en Villavicencio?"* no tiene comando. No hay `WHERE`, no hay
`FT.SEARCH` en esta imagen:

```text
> FT.SEARCH idx *
ERR unknown command 'FT.SEARCH', with args beginning with: 'idx' '*'
```

Lo único que existe es pedir **una clave por su nombre**. Todo lo demás es recorrer claves o
consultar una estructura que alguien escribió antes, a propósito, para contestar esa pregunta.

Eso invierte el orden del diseño: **primero las preguntas, y de cada una sale una clave**. La pregunta
2 de la [Fase 02](02-las-cinco-preguntas.md) —¿conoces tus consultas de antemano?— aquí es un
requisito. Una pregunta que nadie previó no es una consulta lenta: es una consulta que no existe.

### 6.2 El nombre de la clave es el esquema

Si la clave es la única vía de acceso, **su nombre es el modelo**. Las claves de esta fase siguen la
convención `entidad:identificador`, con los dos puntos como separador, que es la de la documentación
de Valkey y la de casi todo el mundo:

| Clave | Tipo | Qué contesta |
|---|---|---|
| `session:0000042` | hash | los datos de una sesión |
| `technician:T-002:sessions` | set | qué sesiones tiene abiertas un técnico |
| `slot:VVC:foso-1:2026-10-06` | string | quién tiene el foso 1 de Villavicencio ese día |
| `lock:workOrder:WO-0000001` | string | qué terminal edita esa orden ahora |
| `queue:VVC` | sorted set | las órdenes pendientes de Villavicencio, de la más antigua a la más nueva |
| `events:workOrder` | stream | qué les pasó a las órdenes, en orden |

La reserva, `slot:VVC:foso-1:2026-10-06`, lleva **la pregunta entera en el nombre** —base, puesto y
día—: no se busca, se construye. **Si puedes construir la clave, tienes la respuesta en un comando; si
no puedes, no la tienes.** Y la convención no la comprueba nadie: si un servicio escribe `sessions:42`
y otro lee `session:0000042`, los dos funcionan y ninguno encuentra lo del otro. **El esquema se mudó
a los nombres**, como en la Fase 03 se había mudado al código.

### 6.3 Las sesiones del terminal de plataforma: un hash con TTL

Cada técnico abre sesión en un terminal de la plataforma al empezar el turno, y la sesión muere a
las ocho horas. Es el caso de libro: se lee siempre por su identificador, se puede perder sin
drama —el técnico vuelve a entrar— y tiene fecha de vencimiento.

Una sesión es un **hash**: un pequeño diccionario de campos bajo una clave, que se lee entero o
campo a campo.

```text
> HSET session:9000042 technicianId T-043 hangarId IQT terminal plataforma-6 openedAt 2026-09-29T06:00:00Z
4
> EXPIRE session:9000042 28800
1
> TTL session:9000042
28800
> HGETALL session:9000042
technicianId
T-043
hangarId
IQT
terminal
plataforma-6
openedAt
2026-09-29T06:00:00Z
```

(El `4` del `HSET` son los campos nuevos que creó. El identificador está fuera del rango que carga
`model.ts`, para no pisar sus sesiones.) `model.ts` hace esto mismo para 100 000
sesiones, repartidas entre los 908 técnicos del dataset, y en cada sesión manda tres comandos:
`HSET`, `EXPIRE` y el `SADD` al índice de la sección 7. Son 300 000 comandos, y cuestan **100
viajes** porque viajan en pipelines de mil sesiones.

> 📐 **Medición — sesiones del terminal** · 100 000 sesiones · `valkey/valkey@sha256:418652cfb58e…` ·
> verificado el 29/09/2026
>
> | Qué | Valor |
> |---|---|
> | viajes para cargar 100 000 sesiones (300 000 comandos) | **100** |
> | memoria por sesión, con su entrada en el índice (`used_memory` antes y después) | **206 bytes** |
> | `MEMORY USAGE` de una sesión sola | 160 bytes |
> | codificación interna (`OBJECT ENCODING`) | `listpack` |
>
> Reproducir: `node 05-clave-valor-levantar-y-modelar/model.ts --dataset lab/data/workOrder-1m`

Las dos cifras de memoria miden cosas distintas. `MEMORY USAGE` es lo que ocupa **una clave con su
valor**; la resta de `used_memory` es lo que la instancia creció **por cada sesión**, incluido su
miembro en el set del técnico y la entrada del TTL. Para dimensionar vale la segunda: **206 bytes por
sesión, unos 20 MB por cada cien mil**. El `listpack` es una codificación compacta para hashes
pequeños; según la documentación, pasado un umbral de campos o de tamaño se convierte en tabla hash.
Ese umbral no se midió aquí: lo busca el ejercicio 12.

### 6.4 El TTL es parte del modelo, no la limpieza

En Postgres, que una sesión venza es un dato —una columna `expires_at`— más un proceso que alguien
tiene que acordarse de programar. En Valkey, **el vencimiento es una propiedad de la clave**: se
declara al escribir, y el motor la borra solo.

El TTL no es la limpieza que se añade al final: **es parte de la respuesta**. Una sesión existe si y
solo si no venció, y la pregunta *"¿sigue vigente?"* se contesta con `EXISTS`, sin comparar fechas.

Y tiene una consecuencia que la sección 7 cobra: **el TTL borra la clave, y solo la clave**. Todo lo
que apunte a ella desde otra estructura queda apuntando a nada.

### 6.5 La reserva del puesto con foso: el primero gana

Dos grupos piden el foso 1 de Villavicencio para el 6 de octubre. El modelo entero es un comando:

```text
> SET slot:VVC:foso-1:2026-10-06 grupo-motores NX PX 43200000
OK
> SET slot:VVC:foso-1:2026-10-06 grupo-estructuras NX PX 43200000
(nil)
> GET slot:VVC:foso-1:2026-10-06
grupo-motores
```

`NX` es *"solo si no existe"* y `PX`, el vencimiento en milisegundos. **No hay forma de que los dos
reciban `OK`**: Valkey ejecuta los comandos de uno en uno, y cada uno es atómico. No se lee primero
para ver si está libre, que es justo lo que produce las reservas dobles: leer, decidir y escribir en
tres pasos deja un hueco entre el primero y el tercero.

**Perder la reserva es un resultado normal, no un error**: un código que ignora el valor de retorno
de `SET NX` reserva dos veces sin que nada falle.

Y la reserva es un *string*, no un hash. Si alguien la trata como hash, el error es inmediato:

```text
> HGET slot:VVC:foso-1:2026-10-06 owner
WRONGTYPE Operation against a key holding the wrong kind of value
```

Es el único tipo que Valkey comprueba: **el tipo de la estructura, no su contenido**.

### 6.6 El candado de la orden abierta: soltar solo lo propio

La orden `WO-0000001` está abierta en el terminal 2, y un técnico intenta abrirla en el terminal 5. El
candado es la misma idea que la reserva —`SET NX PX`—, con una diferencia que importa: **el valor es
un token del dueño**, y soltar el candado exige presentarlo.

```typescript
const a = await v.set(lock, "terminal-2", "PX", 30000, "NX");   // "OK"
const b = await v.set(lock, "terminal-5", "PX", 30000, "NX");   // null
```

Para soltarlo no basta un `DEL`. Si el terminal 2 tarda más de 30 segundos, su candado vence, el
terminal 5 toma uno nuevo, y cuando el 2 termina y hace `DEL`… **borra el candado del 5**. Por eso la
liberación compara el token y borra en un solo paso, con un script Lua que Valkey ejecuta de forma
atómica:

```lua
if redis.call("GET", KEYS[1]) == ARGV[1] then return redis.call("DEL", KEYS[1]) else return 0 end
```

```text
candado de WO-0000001: terminal-2 → OK · terminal-5 → null · liberar con token ajeno → 0 · con el propio → 1
```

(Valkey conserva `redis.call` por compatibilidad.) El token del laboratorio es el nombre del terminal;
en un sistema real es un valor aleatorio por adquisición. Y **el vencimiento del candado es una
apuesta**: si la edición dura más que el TTL, el candado ya no protege nada, y ningún comando avisa.
Esa apuesta, perdida, es el boss de la [Fase 06](06-clave-valor-romper-y-medir.md).

### 6.7 La cola de pendientes: un sorted set por base

Cada base tiene su cola de órdenes pendientes, y se atienden de la más antigua a la más nueva. Un
**sorted set** es un conjunto donde cada miembro tiene una puntuación y se mantiene ordenado por ella:
el miembro es la orden, y la puntuación, su instante de apertura en milisegundos.

`model.ts` mete en las colas las **16 440 órdenes del último mes** de `workOrder-1m`, repartidas por
base. La de Villavicencio queda con 2509:

```text
> ZRANGE queue:VVC 0 2 WITHSCORES
WO-0983562
1788220841000
WO-0983563
1788220914000
WO-0983564
1788221356000
> ZPOPMIN queue:VVC
WO-0983562
1788220841000
> ZCARD queue:VVC
2508
```

`ZPOPMIN` saca la más antigua **en un solo comando**: dos planeadores a la vez nunca reciben la misma
orden, que en Postgres pide un `SELECT … FOR UPDATE SKIP LOCKED`. Lo que el sorted set no tiene es
**memoria de lo entregado**: si el planeador saca la orden y se cae antes de asignarla, la orden no
está en ningún sitio.

### 6.8 El registro de eventos: un stream con grupo de consumidores

Un **stream** es un registro de solo añadir: cada entrada tiene un identificador que crece con el
tiempo y un puñado de campos. `model.ts` añade un evento `opened` por cada una de las 16 440 órdenes,
y crea un **grupo de consumidores**, `planeacion`, que reparte los eventos entre quienes los leen:

```typescript
await v.xgroup("CREATE", "events:workOrder", "planeacion", "0");
await v.xreadgroup("GROUP", "planeacion", "yamile", "COUNT", 5, "STREAMS", "events:workOrder", ">");
```

Yamile recibió 5 eventos, y el grupo recuerda que se los entregó y que no los ha confirmado:

```text
> XINFO GROUPS events:workOrder
name planeacion · consumers 1 · pending 5 · last-delivered-id 1790740688954-4 · entries-read 5 · lag 16435
```

(La salida real sale en líneas alternas de nombre y valor; aquí va en una sola.) `pending 5` es lo que
el sorted set no tenía: **lo entregado y no confirmado**. Cuando Yamile procesa un evento, lo confirma
con `XACK`, y `pending` baja a 4. Si Yamile se cae, sus eventos siguen pendientes a su nombre y otro
consumidor puede reclamarlos. `lag 16435` son los que el grupo aún no ha entregado a nadie.

Dos errores aparecen en cuanto se usa, y los dos entran en [`a09`](a09-catalogo-de-errores.md):

```text
> XREADGROUP GROUP planeacion yamile COUNT 1 STREAMS events:workOrder >
NOGROUP No such key 'events:workOrder' or consumer group 'planeacion' in XREADGROUP with GROUP option
> XGROUP CREATE events:workOrder planeacion 0
BUSYGROUP Consumer Group name already exists
```

El primero es leer antes de crear el grupo; el segundo, crearlo dos veces, que es lo que hace un
servicio en cada arranque, y es inofensivo. **Cola y eventos juntos ocupan unos 112 bytes por
orden**: el mes entero, menos de 2 MB.

### 6.9 Cuándo cada estructura

| Estructura | Para qué en Cóndor | La operación que la justifica | Lo que no hace |
|---|---|---|---|
| string | reserva, candado | `SET NX PX`: ganar o perder en un comando | nada más que guardar un valor |
| hash | sesión | leer o cambiar un campo sin reescribir el resto | buscar por un campo |
| set | índice a mano de sesiones por técnico | pertenencia y miembros, O(1) por miembro | vencer sus miembros |
| sorted set | cola de pendientes por base | `ZPOPMIN`: sacar el más antiguo, atómico | recordar lo entregado |
| stream | registro de eventos de órdenes | grupo de consumidores con pendientes y `XACK` | borrar por antigüedad sin que se lo pidas |

La regla: **se elige la estructura por la operación que tiene que ser atómica**, no por la forma del
dato.

### 6.10 Los viajes: pipeline, paralelo y autopipelining

En esta familia cada operación es un comando, y es fácil multiplicar **los viajes** sin darse cuenta. El arnés cuenta
los viajes como **escrituras al socket** del cliente ([`a04`](a04-el-arnes-de-medida.md)), y
`trips.ts` lee 100 sesiones de cuatro maneras:

```text
100 lecturas de sesión (100 existen) · escrituras al socket:
   una a una con await: 100 · pipeline: 1 · Promise.all: 100 · Promise.all con autopipelining: 1
```

Uno a uno con `await` es el N+1 de esta familia: 100 envíos y 100 esperas en serie. El pipeline
manda los 100 en una escritura. `Promise.all` hace 100 escrituras **sin esperar una respuesta para
mandar la siguiente**: el contador del arnés mide envíos, no esperas, y conviene saberlo. Y con
`enableAutoPipelining: true`, iovalkey junta lo pedido en el mismo ciclo del bucle de eventos: **el
mismo código que `Promise.all`, un solo envío.**

Un pipeline **no es una transacción**: otro cliente puede colarse entre dos de sus comandos. Para que
no se cuele nadie está `MULTI`/`EXEC` o un script Lua, como el del candado.

### 6.11 Todo vive en RAM

La última decisión de modelado no se ve en ningún comando: **cada byte está en memoria**. Las
sesiones ocupan unos 20 MB y la cola del mes menos de 2: datos pequeños, con vencimiento, que se
pueden reconstruir, que es el uso para el que la familia existe. **Un millón de órdenes de trabajo
como hash ocupa 170,9 MB**, y eso ya es otra cosa: la sección 8 cuenta qué pasa cuando alguien lo
decide.

> 🧠 **El patrón a memorizar.** En clave-valor no se modela la entidad ni la lectura: se modela **la
> pregunta**, y cada pregunta es una clave que se puede construir sin buscar. Lo que tiene duración
> lleva TTL, lo que tiene que ganar uno solo es un `SET NX`, y cualquier segunda forma de llegar al
> dato es otra estructura que tú mantienes.

---

## 🪞 7. Tu instinto relacional dice… y esta vez se equivoca

> 🪞 **"Le pongo un índice secundario."** Las sesiones se buscan por identificador, pero la pantalla de
> supervisión necesita las de un técnico: un índice sobre `technicianId` y listo.

Es el instinto más sano de un senior relacional: en Postgres es una línea, y desde ese momento **cada
escritura lo mantiene sola**.

En Valkey no hay índices secundarios. Hay dos caminos, y los dos se midieron con las sesiones del
técnico `T-002`:

| Cómo | Viajes | Qué recorre | Encuentra |
|---|---|---|---|
| sin índice: `SCAN` de todas las `session:*` y un `HGET` de cada una | **202** | las 100 000 claves | 111 |
| con el set `technician:T-002:sessions`, escrito a mano | **2** | 111 miembros | 111 |

El `SCAN` es el `Seq Scan`: crece con la instancia, no con la respuesta. El set contesta en dos
viajes, pero **no es un índice: es otra estructura, y la escribes tú**. Cada `HSET` necesita su
`SADD`; cada cambio de técnico, un `SREM` y un `SADD`; y cada vencimiento…

Aquí se rompe el instinto. El TTL borra la sesión, pero **no toca el set**. `model.ts` crea 1000
sesiones de un técnico con un TTL de un segundo, las mete en su set y espera:

```text
índice a mano tras vencer 1000 sesiones por TTL: el set sigue con 1000 miembros, de los que existen 0
```

**Mil entradas en el índice, cero sesiones detrás.** En Postgres, un índice nunca apunta a una fila
que no existe, porque la misma transacción que borra la fila borra su entrada. En Valkey, la
coherencia entre las dos estructuras es **tu código**, y el TTL no llama a tu código. El índice a
mano hay que limpiarlo al leer (descartar los miembros que ya no existen), darle su propio
vencimiento, o cambiarlo por un sorted set con el vencimiento como puntuación y borrar por rango.
Ninguna de las tres es gratis, y ninguna se midió aquí: el ejercicio 19 las compara.

**El instinto no se equivoca en querer la segunda vía de acceso: se equivoca en creer que alguien más
la mantiene.** La pregunta del instrumento que lo habría anticipado es la 2: si las consultas no son
conocidas y estables, cada una nueva es otra estructura que mantener a mano. Este instinto entra en
[`INSTINTOS.md`](INSTINTOS.md) con la medición M-07.

---

## ⚰️ 8. La situación 3: elegiste bien la familia y la modelaste como relacional

**La decisión, con su mejor argumento.** *"Ya tenemos Valkey para las sesiones y las reservas. El
estado de las órdenes de trabajo también se lee siempre por su identificador, se cambia a cada rato
y tiene que ser rápido. Metámoslo ahí también, y nos ahorramos una base."*

**Por qué era razonable.** El acceso es de verdad por clave: la familia estaba bien elegida. Lo que se
trató como relacional fue **la durabilidad**: se asumió que lo escrito queda escrito.

**Qué pasó después, con número.** `primary-store.ts` carga el millón de órdenes de `workOrder-1m` como
hash, con la configuración por defecto de la imagen, y mata el contenedor con `SIGKILL`:

```text
persistencia: save "3600 1 300 100 60 10000" · appendonly no
cargadas 1000000 órdenes como hash en 6.4 s · memoria 170.90M · último guardado hace 7 s
tras SIGKILL: sobreviven 0 de 1000000
tras esperar 65 s: último guardado hace 14 s
5000 órdenes nuevas escritas después del guardado y SIGKILL: sobreviven 1000000 de 1005000
```

La primera línea es la configuración que nadie leyó. Sin AOF, Valkey guarda **instantáneas** (RDB):
tras una hora si hubo un cambio, cinco minutos si hubo cien, un minuto si hubo diez mil. El millón se
cargó en 6,4 segundos y el contenedor cayó a los 7: **antes del primer guardado. Sobreviven cero.**
La segunda prueba espera al guardado, escribe 5000 órdenes más y vuelve a matar: **las 5000 nuevas se
pierden**. Es la forma normal de este fallo: se pierde **lo último**, justo lo que nadie ha visto
todavía en otro sitio.

> ⚠️ **Qué simula este experimento y qué no.** `docker kill --signal=KILL` mata el proceso de Valkey;
> el sistema operativo y el disco siguen vivos. Es la caída de un proceso, no la de una máquina ni un
> corte de luz, que pueden perder además lo que el sistema operativo aún no escribió al disco. Eso no
> se midió en el curso.

**Cuánto costó salir.** La cuenta que duele no es migrar a otro motor: es que **lo perdido no está en
ningún otro sitio**. Una sesión perdida se repite entrando otra vez; una orden abierta perdida se
reconstruye con papeles, correos y memoria, que es el `FLOTA_CONTROL.xlsx` del que el proyecto quería
salir.

**La pregunta que lo habría evitado es la 1: ¿dónde está la frontera transaccional?** La orden de
trabajo es parte de la frontera de Cóndor —se abre, se firma, se cierra— y la frontera tiene que vivir
en un motor que la haga durable. Valkey puede ser rápido **al lado** de la fuente de verdad, nunca en
su lugar.

**Antes y después, con números:**

| | Dónde vive la orden | Tras `SIGKILL` antes del guardado | Tras `SIGKILL` después del guardado |
|---|---|---|---|
| antes: Valkey como almacén primario | un hash, sin AOF | **0 de 1 000 000** | 1 000 000 de 1 005 000 |
| después: Postgres como fuente de verdad, Valkey para el candado | una fila | 1 000 000 (a07, tabla normal) | todas |

La columna de Postgres sale de [`a07`](a07-postgres-linea-base.md), que midió la misma caída sobre una
tabla normal y sobre una `UNLOGGED` con 100 000 filas: la normal las conserva todas. Qué cambia con
AOF, y cuánto, es la Fase 06.

---

## ⚠️ 9. Errores comunes y diagnóstico

**Tratar una clave como si fuera de otro tipo** (E-26 en [`a09`](a09-catalogo-de-errores.md)):
`WRONGTYPE Operation against a key holding the wrong kind of value`. 🩺 `TYPE <clave>` dice qué es
de verdad. Casi siempre son dos partes del código que usan el mismo prefijo para cosas distintas: la
salida es separar los prefijos.

**Leer de un grupo que no existe** (E-27): `NOGROUP No such key 'events:workOrder' or consumer group
'planeacion' in XREADGROUP with GROUP option`. 🩺 `XINFO GROUPS <stream>`. El grupo se crea antes de
leer, y con `MKSTREAM` si el stream puede no existir todavía.

**Crear un grupo que ya existe** (E-28): `BUSYGROUP Consumer Group name already exists`. 🩺 No es un
fallo: el servicio lo crea en cada arranque. Se captura ese mensaje y se sigue.

**Una consulta que no existe** (E-29): `ERR unknown command 'FT.SEARCH', with args beginning with:
…`. 🩺 `MODULE LIST`. La imagen del curso no trae módulos de búsqueda; si la pregunta necesita
buscar por contenido, no es de esta familia (sección 6.1).

**El índice a mano que miente.** No da error: devuelve miembros cuya clave ya no existe. 🩺 Compara
`SCARD` del set con cuántos de sus miembros responden a `EXISTS`. Si la diferencia crece, algo vence
o se borra sin pasar por el código que mantiene el set (sección 7).

**Las órdenes que no sobrevivieron.** Tampoco da error: la instancia arranca vacía o con lo del último
guardado. 🩺 `CONFIG GET save`, `CONFIG GET appendonly` e `INFO persistence` (`rdb_last_save_time`).
Si `appendonly` es `no`, lo escrito desde el último guardado se pierde con el proceso (sección 8).

---

## 📋 10. Checklist de validación

```text
[ ] model.ts verificó workOrder-1m (11a67c65fb22…) y cargó 100 000 sesiones en 100 viajes
[ ] Sé por qué 206 bytes por sesión y 160 de MEMORY USAGE no se contradicen
[ ] La reserva del foso: el primero recibe OK y el segundo null, sin leer antes
[ ] El candado solo lo suelta quien presenta su token: 0 con el ajeno, 1 con el propio
[ ] ZPOPMIN saca la orden más antigua de queue:VVC en un comando
[ ] XINFO GROUPS muestra 5 pendientes tras el XREADGROUP, y 4 tras un XACK
[ ] trips.ts da 100 · 1 · 100 · 1, y sé qué mide el contador en el caso de Promise.all
[ ] Buscar las sesiones de un técnico: 202 viajes con SCAN, 2 con el set
[ ] Tras vencer 1000 sesiones, el set sigue con 1000 miembros y ninguno existe
[ ] primary-store.ts: 0 de 1 000 000 antes del guardado, y 5000 perdidas después
[ ] El 🪞 de esta fase está en INSTINTOS.md, M-07 y M-08 en la bitácora, E-26 a E-29 en a09
```

---

## 🧪 11. Ejercicios (24)

Salvo donde se indique, contra el perfil `clave-valor` con las sesiones de `model.ts` cargadas. El
código de la fase está en `src/05-clave-valor-levantar-y-modelar/`. `model.ts` y `primary-store.ts`
empiezan borrando la instancia.

### 🟢 Fácil — claves y estructuras (1–7)

#### 🟢 Ejercicio 1 — Tu carga

Ejecuta `model.ts` con `--sessions 10000` y con el valor por defecto.

**Pregunta:** ¿cuántos viajes cuesta cada carga, y por qué la memoria por sesión casi no cambia?

#### 🟢 Ejercicio 2 — Una sesión en `valkey-cli`

Abre la sesión `session:0000042` con `HGETALL`, mira su `TTL` y su `OBJECT ENCODING`.

**Objetivo:** explicar qué quiere decir `listpack` y por qué el TTL no es 28 800.

#### 🟢 Ejercicio 3 — La reserva

Reserva el foso 2 de Villavicencio para mañana desde dos `valkey-cli` a la vez.

**Objetivo:** que uno reciba `OK` y el otro `(nil)`, y encontrar cuánto le queda a la reserva con
`PTTL`.

#### 🟢 Ejercicio 4 — `WRONGTYPE`

Pide `HGET` sobre una reserva, `ZRANGE` sobre una sesión y `GET` sobre una cola.

**Objetivo:** el mensaje literal de cada una, y el comando que te habría dicho el tipo antes.

#### 🟢 Ejercicio 5 — La cola

Con `ZRANGE queue:BOG 0 4 WITHSCORES`, lee las cinco órdenes más antiguas de Bogotá.

**Pregunta:** ¿qué representa la puntuación, y cómo la conviertes a una fecha legible?

#### 🟢 Ejercicio 6 — Los pendientes

Lee tres eventos más con `XREADGROUP` como `yamile`, confirma uno con `XACK` y mira `XINFO GROUPS`.

**Objetivo:** que `pending` suba y baje como esperas, y explicar qué es `lag`.

#### 🟢 Ejercicio 7 — Cuatro formas de leer

Ejecuta `trips.ts`.

**Objetivo:** reproducir 100 · 1 · 100 · 1, y explicar con tus palabras por qué `Promise.all` no son
100 esperas en serie aunque el contador diga 100.

### 🟡 Intermedio — modelar con la clave (8–14)

#### 🟡 Ejercicio 8 — Las claves de Cóndor

Diseña las claves para *"¿qué técnico tiene asignado el turno de noche en Neiva el 12 de octubre?"* y
para *"¿qué aeronaves están ahora en el hangar de Iquitos?"*.

**Objetivo:** que cada pregunta se conteste construyendo una clave, sin `SCAN`. Di qué escritura
mantiene cada una.

#### 🟡 Ejercicio 9 — La reserva de varios días

Un grupo necesita el foso 1 del 6 al 8 de octubre: los tres días o ninguno.

**Objetivo:** hacerlo atómico con un script Lua, y demostrar que si uno de los tres días ya estaba
tomado, no queda ninguno reservado.

#### 🟡 Ejercicio 10 — El candado sin token

Cambia la liberación del candado por un `DEL` simple. Con dos scripts, reproduce el caso de la
sección 6.6: el terminal 2 tarda más que el TTL y al terminar borra el candado del 5.

**Objetivo:** la secuencia de comandos, con su salida, que lo demuestra.

#### 🟡 Ejercicio 11 — Pipeline no es transacción

Manda en un pipeline `HSET` de una sesión y `SADD` a su índice, y desde otro cliente lee entre los dos.

**Pregunta:** ¿lo consigues? Repite con `MULTI`/`EXEC`. ¿Qué garantiza cada uno, y qué no garantiza
ninguno de los dos?

#### 🟡 Ejercicio 12 — El umbral del `listpack`

Añade campos a una sesión de uno en uno hasta que `OBJECT ENCODING` cambie.

**Objetivo:** encontrar el umbral en esta versión, compararlo con `CONFIG GET hash-max-listpack-*` y
medir con `MEMORY USAGE` el salto de tamaño.

#### 🟡 Ejercicio 13 — `KEYS` contra `SCAN`

Cuenta las sesiones de la instancia con `KEYS session:*` y con un bucle de `SCAN`.

**Pregunta:** ¿por qué la documentación prohíbe `KEYS` en producción, si da el mismo resultado? Lee
la complejidad de los dos comandos.

#### 🟡 Ejercicio 14 — La cola con memoria

Cambia la cola de Villavicencio para que una orden sacada y no asignada no se pierda: con el stream,
o con dos sorted sets (pendientes y en curso).

**Objetivo:** matar el consumidor entre sacar y asignar, y demostrar que la orden sigue localizable.

### 🟠 Difícil — coherencia a mano (15–20)

#### 🟠 Ejercicio 15 — El segundo índice

Añade un índice por base: las sesiones abiertas en cada hangar.

**Objetivo:** medir cuántos viajes y cuánta memoria añade a la carga de 100 000 sesiones, y listar
cada escritura del sistema que ahora tiene que tocar tres estructuras.

#### 🟠 Ejercicio 16 — El técnico que cambia de base

Una sesión pasa de `VVC` a `BOG` a mitad de turno.

**Objetivo:** actualizar la sesión y los dos índices de forma que nadie vea la sesión en las dos bases
ni en ninguna. Justifica si usas `MULTI`/`EXEC` o Lua.

#### 🟠 Ejercicio 17 — Reclamar lo pendiente

Simula que `yamile` se cae con eventos sin confirmar, y que `hernan` los reclama con `XAUTOCLAIM`.

**Objetivo:** que ningún evento quede sin procesar ni se procese dos veces, y explicar qué pasa si
`yamile` vuelve y confirma tarde.

#### 🟠 Ejercicio 18 — La guardia de la situación 3

Ejecuta `primary-store.ts` y cronometra cuándo ocurre el primer guardado con `INFO persistence`.

**Pregunta:** con las reglas `3600 1 300 100 60 10000`, ¿cuánto puede perder, como máximo, un sistema
que escribe 50 órdenes por minuto? ¿Y uno que escribe 50 000?

#### 🟠 Ejercicio 19 — Tres formas de limpiar el índice

Implementa las tres salidas de la sección 7: limpiar al leer, dar TTL al set, y un sorted set con el
vencimiento como puntuación.

**Objetivo:** medir para cada una los viajes de leer las sesiones de un técnico, y cuántas entradas
fantasma quedan tras vencer 1000 sesiones.

#### 🟠 Ejercicio 20 — El stream que no para de crecer

Añade a `events:workOrder` los eventos de todo el año, no solo del último mes, y mide su memoria.

**Objetivo:** acotarlo con `XADD … MAXLEN ~` o `XTRIM` y decidir qué número pones, con el costo en
bytes de cada opción.

### 🔴 Muy difícil — decidir qué no va aquí (21–24)

#### 🔴 Ejercicio 21 — La autopsia completa

Escribe la autopsia de la situación 3 con los cinco pasos de la Fase 00.

**Objetivo:** la factura en órdenes perdidas para un día normal de Cóndor, calculada con el ritmo de
apertura de `workOrder-1m` y las reglas de guardado.

#### 🔴 Ejercicio 22 — Lo que no es de esta familia

Toma las diez pantallas de Cóndor que conoces por la historia y di, para cada una, si su pregunta se
puede construir como clave.

**Objetivo:** una tabla con la clave, o con la razón por la que no existe. Ninguna fila sin
justificar.

#### 🔴 Ejercicio 23 — La reserva que dura una semana

Planeación pide reservar fosos con dos meses de antelación, y cancelar, y ver el calendario del mes.

**Pregunta:** ¿qué parte de eso sigue siendo clave-valor, y qué parte ya es una tabla? Diseña la
frontera y justifica cada lado.

#### 🔴 Ejercicio 24 — Candado contra `SELECT FOR UPDATE`

Diseña el candado de la orden abierta en Postgres, con `SELECT … FOR UPDATE NOWAIT` o con un
candado consultivo.

**Objetivo:** contar los viajes de tomar y soltar en cada motor, y decir qué pasa en cada uno si el
terminal se cae con el candado tomado. (La Fase 06 mide la línea base completa.)

---

## 📚 12. Referencias

> ⚠️ Las URLs y sus contenidos cambian, y la documentación de Valkey cubre la última versión. Esta
> fase se verificó con Valkey 9.1.2 e iovalkey 0.4.0.

- **Comandos de Valkey** — https://valkey.io/commands/ — cada comando con su complejidad. Es el
  `EXPLAIN` de esta familia.
- **Tipos de datos** — https://valkey.io/topics/data-types/ — string, hash, set, sorted set y stream.
- **Streams** — https://valkey.io/topics/streams-intro/ — grupos de consumidores, pendientes y
  reclamación.
- **Persistencia** — https://valkey.io/topics/persistence/ — RDB y AOF en la voz del proyecto. Leer
  antes de la sección 8.
- **Pipelining** — https://valkey.io/topics/pipelining/
- **Martin Kleppmann, *How to do distributed locking*** —
  https://martin.kleppmann.com/2016/02/08/how-to-do-distributed-locking.html — por qué un candado con
  vencimiento es una apuesta. Leer antes del boss de la Fase 06.
- **iovalkey** — https://github.com/valkey-io/iovalkey — autopipelining y `defineCommand`.

**Orden sugerido:** los tipos de datos antes de la sección 6; los streams durante la 6.8; la
persistencia y Kleppmann antes de la Fase 06.

---

## 🏁 13. Resultado de la fase

Tienes Cóndor en Valkey como lo pide la familia: una clave por pregunta, y los números que lo
sostienen. **100 000 sesiones en 100 viajes y 206 bytes cada una**, una reserva y un candado que se
ganan en un comando, y una cola y un registro que no pierden lo entregado. Y tienes el costo de salir
de la clave: **202 viajes** sin la segunda estructura, y **1000 entradas fantasma** con ella.

```text
Valkey (clave-valor)
├── session:NNNNNNN            hash + TTL 8 h      ← terminal de plataforma
├── technician:T-NNN:sessions  set, a mano         ← supervisión (miente tras el TTL)
├── slot:BASE:foso-N:FECHA     string, NX PX       ← reserva del puesto con foso
├── lock:workOrder:WO-NNNNNNN  string, NX PX, token ← orden abierta en un terminal
├── queue:BASE                 sorted set          ← pendientes por base
└── events:workOrder           stream + grupo      ← registro de eventos
```

> **La señal de que quedó bien:** *"Para cada pregunta de Cóndor que resuelvo aquí, puedo escribir la
> clave sin buscarla, y sé qué pasa con ella cuando el proceso muere."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-05-clave-valor-levantar-y-modelar -m "F05 cerrada: 100k sesiones en 100 viajes y 206 B; reserva y candado atómicos; cola y stream; índice a mano medido; situación 3 reproducida"
> ```
>
> Commits de la fase con prefijo `f05:`, los de ejercicio `f05 ej17: …`.
