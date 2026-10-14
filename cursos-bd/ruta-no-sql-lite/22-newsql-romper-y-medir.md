# ⚡ Fase 22 — NewSQL: la luz en el COMMIT, la fila que pelean tres países, y cuándo no hace falta

> **Curso:** Ruta NoSQL Lite · Fase 22 de 26 · Bloque IV — Cuando el dato no cabe en un nodo · **10 h**
> **Familia:** NewSQL · **Motor:** CockroachDB v26.3.2 `cockroachdb/cockroach@sha256:bc15746ef2c2…`, nueve nodos en
> tres regiones simuladas (`newsql-global`)
> **Línea base:** PostgreSQL 18.6 `pgvector/pgvector@sha256:2ba9ca5f2e7d…`, bien jugado: un primario en Bogotá y una
> réplica de lectura en Quito, por *streaming* (`compose.replica.yaml`)
> **Entorno de ejecución:** TypeScript (`pg` 8.23.0)
> **Volumen:** `workOrder-10k` (`datasetSha256` `5a107518d726…`) sin lecturas, el expediente de `HC-2157` y las dos
> órdenes de escenario de la [Fase 21](21-newsql-levantar-y-modelar.md)
> **Depende de:** Fase 21 · **Habilita:** [Fase 23](23-poliglota-el-diseno.md)
> **Apéndices de apoyo:** [`a02`](a02-compose-de-la-ruta.md), [`a04`](a04-el-arnes-de-medida.md),
> [`a09`](a09-catalogo-de-errores.md), [`a10`](a10-licencias-y-riesgo.md)
> **Fecha de verificación ejecutada:** 11/10/2026, en macOS arm64
> **Objetivo:** resolver la apuesta contra Postgres con réplica de lectura, medir la latencia de cada trabajo del
> expediente por región, provocar la contención sobre una misma fila desde tres países hasta que el sistema deja
> de avanzar, y decidir cuándo esta familia hace falta y cuándo sobra. Cierra el Bloque IV con su boss.

---

## 🧭 1. Dónde estamos

La [Fase 21](21-newsql-levantar-y-modelar.md) contó fronteras. Con el esquema de la Fase 01 copiado, las 1990 filas
del operador estatal tenían copias en tres países y la rutina del Coca mandaba sus seis escrituras a Colombia.
Con la autoridad en la clave y la ubicación restringida, el expediente quedó en Ecuador, salvo las 43 piezas que
son de Cóndor por diseño. Esas cuentas eran regiones y réplicas, no milisegundos.

Esta fase es **la única excepción declarada del curso donde el tiempo sí es el argumento**, y conviene decir por
qué: la latencia entre regiones no depende del hardware sino de la distancia, y ningún índice la baja. Tampoco
es una red real: la inyecta `cockroach demo`, fija y reproducible, y aquí se dice su valor medido antes de usarla.
Con esa regla, la fase pone milisegundos a cada frontera, enfrenta la familia con la mejor jugada de Postgres,
pelea una misma fila desde tres países hasta que el sistema deja de avanzar sin que nada haya fallado, y cierra el
bloque con el encargo de Lucía.

---

## 🎯 2. Objetivos de esta fase

1. Medir **la física del laboratorio**: el viaje entre cada par de regiones, en el servidor.
2. Ponerle milisegundos a cada trabajo del expediente, **sentencia por sentencia y con el `COMMIT`**, con el
   esquema copiado y con la autoridad en la clave.
3. Resolver la apuesta contra **un Postgres en Bogotá con réplica en Quito**, y cortar el enlace entre los dos.
4. Pelear **la misma fila desde dos y tres regiones** con concurrencia creciente, contar reintentos y ver quién
   espera.
5. Escribir **el reintento** como parte del modelo de programación, y su costo.
6. Decidir con números **cuándo NO usar NewSQL**, y resolver el boss del Bloque IV.

🧰 **Miniproyecto de esta familia:** [Barlovento — una carga entregada dos veces en dos países](h-mini-10-newsql-barlovento.md).
Opcional, fuera de las horas del curso, y no entra a la bitácora.

---

## 🪞 3. La apuesta

> 🪞 **Apuesta antes de ejecutar.** **Un Postgres de un nodo con réplica de lectura resuelve el expediente de
> `HC-2157` a una fracción del costo y de la latencia de CockroachDB.** Se juzga así, decidido antes de medir:
> Postgres bien jugado —primario en Bogotá, réplica en Quito, cada transacción en un solo viaje— contra el diseño
> final de la Fase 21; su latencia es la de su servidor más los viajes del cliente a otro país, por el viaje que
> el demo mide entre esas dos regiones, porque Postgres no tiene red simulada. **Latencia ganada** si Postgres
> queda a 0,5× o menos en 2 de los 3 trabajos; **costo ganado** si sus nodos son un tercio o menos. La residencia
> no entra: se reporta aparte, como incumplimiento legal.
>
> **Mi predicción, escrita a las 19:49 del 11/10/2026, antes de medir nada de la fase: la gano**, en 3 de 3
> trabajos, con 2 nodos contra 9, y con la réplica sirviendo un expediente atrasado.

**Resultado, en la sección 4.2: la apuesta, ganada; mi predicción, acertada.** Casi siempre es verdad, y esa es la
lección. Lo que Postgres no puede dar es lo que la apuesta dejó fuera a propósito.

---

## 📐 4. La medición contra la línea base

Todo desde `src/`. `newsql-global` va solo, con **una base por demo recién creado** (el porqué está en
[`a02`](a02-compose-de-la-ruta.md)), y el par de Postgres es un proyecto aparte, como el anillo de Cassandra:

```bash
docker compose -f lab/compose.replica.yaml up -d --wait              # primario en Bogotá, réplica en Quito
node 21-newsql-levantar-y-modelar/load.ts --target primario --db expediente
cd lab && docker compose --profile newsql-global up -d --wait --force-recreate && cd ..
node 21-newsql-levantar-y-modelar/load.ts --target global --db condor --schema autoridad
node 21-newsql-levantar-y-modelar/placement.ts --db condor --schema autoridad --keep
node 22-newsql-romper-y-medir/latency.ts --db condor --schema autoridad   # 4.1
node 22-newsql-romper-y-medir/bet.ts                                     # 4.2, la apuesta
node 22-newsql-romper-y-medir/partition.ts                               # 4.2, el enlace cortado
node 22-newsql-romper-y-medir/contention.ts --target global --kind rmw   # 4.3 y 5
```

### 4.1 La física, y lo que cuesta cada trabajo

La latencia se mide **en el servidor y sentencia por sentencia**, nunca con el reloj del cliente sobre un lote.
En CockroachDB, `SHOW LAST QUERY STATISTICS` después de cada sentencia —incluido el `COMMIT`, que no tiene
`EXPLAIN`— devuelve cuánto tardó el servidor en atenderla (`lastStatement()` en `lab/harness/crdb-explain.ts`).
`latency.ts` mide primero la física: leer una aeronave por su clave desde cada puerta, en cada región, mediana de
cinco.

| Desde \ hacia | Colombia | Ecuador | Perú |
|---|---|---|---|
| Colombia (`us-east1`) | 0,9 ms | 68,1 ms | 66,3 ms |
| Ecuador (`us-west1`) | 68,2 ms | 0,5 ms | 149,6 ms |
| Perú (`europe-west1`) | 66,7 ms | 149,1 ms | 0,5 ms |

**Cada viaje entre Colombia y los otros dos cuesta unos 67 ms, y entre Ecuador y Perú, 149.** Son los valores del
demo, no de Sudamérica: Bogotá–Quito por fibra es bastante menos. Lo que importa es la forma: **una sentencia
cuesta lo que sus viajes**, y la sección 6.4 de la Fase 21 ya los había contado. Con los mismos tres trabajos de
esa fase, mediana de cinco vueltas tras una de calentamiento:

| Trabajo (desde) | Esquema de la Fase 01, copiado | La autoridad en la clave, restringido |
|---|---|---|
| la autoridad pide el expediente (Ecuador) | 650 ms | **167 ms** |
| el Coca firma la rutina (Ecuador) | 1019 ms | **486 ms** |
| Bogotá firma la inspección mayor (Colombia) | **124 ms** | 565 ms |

Con la autoridad en la clave, el expediente cuesta casi entero **una sentencia**: lo instalado hoy, 136 ms, que son
dos viajes a Colombia por la pieza. La rutina del Coca paga 69 ms por cada movimiento —la clave foránea a la pieza—,
138 por cada pieza que actualiza y 69 por el `COMMIT`, que confirma en las dos regiones que escribió.

La última fila parece contradecir a la Fase 21, y no lo hace. En esta carga, el balanceador dejó el único rango de
la copia con su leaseholder **en Colombia**: la inspección de Bogotá escribe al lado y solo paga el quórum (66 ms en
el `COMMIT`). **Es rápida porque incumple el contrato**: escribe filas ecuatorianas en Colombia. Con la autoridad
en la clave, Bogotá paga 70 ms por sentencia porque cada fila va a Ecuador, que es donde la ley dice que vaya.

> 🧭 **La latencia de una transacción distribuida se calcula antes de medirla**: viajes por sentencia, por el RTT
> entre regiones, más el `COMMIT`. Si el número medido no se parece a la cuenta, hay una comprobación que no sabías
> que existía.

### 4.2 La mejor jugada de Postgres, y la apuesta

Postgres bien jugado para Cóndor no es un nodo cualquiera: es **un primario en Bogotá y una réplica de lectura en
Quito**, por *streaming*, cada uno en su red y con un enlace entre las dos (`compose.replica.yaml`), y cada
transacción mandada **en un solo viaje**. Postgres no tiene latencia simulada, así que `bet.ts` mide su servidor —el
reloj del cliente sobre la red local de Docker, una transacción por viaje— y le suma los viajes a otro país por el
RTT que midió el demo. CockroachDB va con sus números de la sección 4.1, y además en un solo viaje, como control.

| Trabajo | Postgres | CockroachDB, autoridad en la clave | Postgres / CockroachDB |
|---|---|---|---|
| el expediente desde Ecuador | réplica en Quito: 3,3 ms | 167 ms (en un viaje: 168) | 0,02 |
| la rutina del Coca | primario en Bogotá: 1,0 ms + 1 viaje = 68,8 ms | 486 ms (en un viaje: 492) | 0,14 |
| la inspección de Bogotá | primario en Bogotá: 1,1 ms | 565 ms (en un viaje: 563) | 0,00 |

**Latencia: Postgres a menos de 0,5× en los tres trabajos.** Costo: dos nodos contra nueve (sección 4.5). **La
apuesta, ganada**, y la predicción con ella.

Dos lecturas de la tabla importan más que el resultado. La primera: **CockroachDB en un solo viaje tarda lo
mismo** que sentencia por sentencia. Su costo no está entre el cliente y la base: está **dentro** del clúster, entre
regiones. La segunda: Postgres mandado sentencia por sentencia desde el Coca serían 8 viajes, **543 ms**, más que
CockroachDB. La mejor jugada de Postgres depende de que la aplicación junte la transacción en un viaje, y eso es una
decisión de código, no de motor.

**Y la residencia, que la apuesta dejó fuera.** El primario está en Bogotá: cada firma del Coca guarda filas
ecuatorianas en Colombia, y la réplica las copia de vuelta. **Postgres gana todo lo que la apuesta mide y pierde lo
único que el contrato pide.** Ponerlo en Quito no lo arregla: entonces las órdenes colombianas viven en Ecuador.

**Lo que hace la réplica cuando se corta el enlace** (`partition.ts`). Se desconecta el primario del enlace,
Bogotá firma la inspección, y Quito sigue leyendo:

```text
  1.1 s · cliente de Quito → primario: psql: error: could not translate host name "primario" to address: Name or service not known
  1.9 s · Bogotá firmó WO-F21-0002 en el primario, sin error
  1.9 s · réplica: ve la orden 0 · receptor streaming
 60.7 s · réplica: ve la orden 0 · receptor sin receptor
 75.9 s · durante el corte · lecturas en Quito 73 · sin la firma de Bogotá 73 · con error 0
 80.3 s · la réplica ve la orden 4.2 s después de reponer el enlace · receptor streaming
```

**73 lecturas en Quito durante el corte, ninguna con la firma de Bogotá, ninguna con error**, y la réplica
diciendo `streaming` durante casi un minuto (el `wal_receiver_timeout` de Postgres es de 60 s). Quito no puede
escribir —no llega al primario— pero **puede leer, sin aviso, un expediente que ya no es cierto**: la inspección
mayor no está. Es el "sigue funcionando, pero mal" que el miniproyecto de Barlovento describe con una carga
entregada dos veces. Repuesto el enlace, la firma llegó en 4,2 s.

### 4.3 La misma fila desde tres países

El motor 1 de `HC-2157` (`SN-0005382`) es una pieza, y vive en Colombia. Cada vuelo le suma horas, y los vuelos
aterrizan en los tres países. `contention.ts` pone trabajadores en cada puerta a sumar horas durante 20 s por
escalón, con 1, 2, 4, 8 y 16 por región, y comprueba al final que las horas sumadas sean exactamente las
confirmadas. La transacción es la de la aplicación: **leer las horas, escribir las horas + 1, confirmar**, en
`SERIALIZABLE` y con el reintento de la sección 4.4. La latencia es la de cada transacción vista por un cliente
que está en la misma máquina que su puerta: el servidor más el *loopback*, transacción por transacción.

| Trabajadores (tres regiones) | Confirmadas/s | Reintentos por confirmada | Se rindieron | p50 Colombia | p50 Ecuador | p50 Perú |
|---|---|---|---|---|---|---|
| 3 | 26,9 | 0,11 | 2 | 33 ms | 7,2 s | 7,0 s |
| 6 | 41,1 | 0,33 | 4 | 38 ms | 7,0 s | 7,4 s |
| 12 | **44,4** | 0,84 | 8 | 48 ms | 7,2 s | 8,1 s |
| 24 | 38,9 | 1,88 | 16 | 72 ms | 8,6 s | 8,0 s |
| 48 | 29,3 | **4,32** | 32 | 197 ms | 13,4 s | 11,3 s |

Las horas sumadas coincidieron con las confirmadas en todos los escalones: **`SERIALIZABLE` no pierde ninguna**.
Lo que la tabla muestra es **a quién castiga la contención**. Colombia, al lado de la fila, confirma en decenas de
milisegundos. Ecuador y Perú esperan **siete segundos o más** por cada hora que suman. Su transacción lee, y su
escritura llega a Colombia un viaje después, cuando un trabajador colombiano ya escribió una versión más nueva:
el motor la rechaza (`WriteTooOldError`), y la de Ecuador vuelve a empezar, y vuelve a llegar tarde. Cada trabajador
remoto se rindió una vez por escalón —veinte intentos seguidos sin confirmar—. Con dos regiones (Colombia y Ecuador)
la forma es la misma: el máximo, 30,9/s con 8 trabajadores, y a 32, 20,0/s con 4,31 reintentos por confirmada.

La misma suma como **una sola sentencia** (`UPDATE … SET hours_since_new = hours_since_new + 1`) cambia el reparto:

| Trabajadores (tres regiones) | Confirmadas/s | Reintentos | p50 Colombia | p50 Ecuador | p50 Perú | p99 |
|---|---|---|---|---|---|---|
| 3 | 21,5 | 0 | 91 ms | 202 ms | 197 ms | 253 ms |
| 12 | 16,9 | 0 | 681 ms | 768 ms | 776 ms | 862 ms |
| 48 | **7,4** | 0 | 3,6 s | 9,7 s | 7,2 s | **15,0 s** |

Sin reintentos y **pareja entre países**: las sentencias esperan su turno en la fila en lugar de pelearla. Pero cada
turno retiene la fila mientras viaja la confirmación, así que el techo es bajo y la cola crece con cada trabajador.

**La referencia sin geografía**, el primario de Postgres con los clientes en la misma máquina: leer y escribir en
`SERIALIZABLE`, unas **200/s** con hasta 1,71 reintentos por confirmada; la sentencia única en `READ COMMITTED`,
**unas 820/s** sin pérdidas. Y la forma de la aplicación en `READ COMMITTED`, el valor por defecto de Postgres: **390
confirmadas por segundo y, a 48 trabajadores, 178 horas sumadas de 7832 confirmadas**. Pierde actualizaciones a
montones, sin un solo error. El *write skew* de la Fase 21, a escala.

### 4.4 El reintento es parte del programa

En `SERIALIZABLE`, un `40001` no es una falla: es el motor diciendo que lo que la transacción leyó ya no vale. La
respuesta es repetirla **entera**, desde el `BEGIN` (`withRetry` en `retry.ts`):

```ts
for (let attempt = 1; attempt <= maxAttempts; attempt++) {
  try { await db.query("BEGIN"); const out = await work(db); await db.query("COMMIT"); return out; }
  catch (e: any) {
    await db.query("ROLLBACK").catch(() => {});
    if (e.code !== "40001") throw e;
    await new Promise((ok) => setTimeout(ok, Math.random() * Math.min(1000, 5 * 2 ** attempt)));
  }
}
return undefined;   // se rindió: el llamador decide qué le dice al técnico
```

Cuatro decisiones van en esas líneas. **Todo lo que hay dentro de `work` tiene que poder repetirse**: un correo, una
llamada a otro sistema o un número de orden pedido afuera no pueden ir ahí. **La espera crece y lleva azar**, para
que los que chocaron no vuelvan a chocar al mismo tiempo. **Hay un límite**, y rendirse es un resultado que la
aplicación tiene que saber contar: la sección 4.3 tuvo 32 en un escalón. Y **el reintento cuesta**: a 48
trabajadores, 4,32 intentos perdidos por cada confirmada, cada uno con sus viajes entre regiones. CockroachDB
reintenta solo, en el servidor, las sentencias únicas que todavía no devolvieron nada al cliente: por eso la forma
de una sola sentencia no tuvo ningún reintento visible.

### 4.5 El costo, en nodos

El costo se cuenta en lo que hay que tener prendido, con las cifras de la documentación de cada motor y sin
precios de nube, que cambian cada mes. Para sobrevivir a la caída de una zona en cada región, el diseño de la Fase
21 pide **tres nodos por región, nueve**. La guía de producción de CockroachDB pide **no menos de 4 vCPU por nodo**
y **4 GiB de RAM por vCPU**: **36 vCPU y 144 GiB**, como mínimo. La mejor jugada de Postgres son **dos nodos**, y
para unas novecientas órdenes al mes, dos vCPU por nodo es holgado (declarado, no medido: en el laboratorio, con el
expediente cargado, ocuparon 54 y 64 MiB). **Dos de nueve nodos y 4 de 36 vCPU**: el criterio de costo de la apuesta, ganado.

A eso se suma lo que no está en la tabla. La licencia de CockroachDB para un clúster pide una clave: gratuita por
debajo de diez millones de dólares de facturación anual y con telemetría obligatoria, de pago por encima
([`a10`](a10-licencias-y-riesgo.md)). Cóndor tendría que decir de qué lado está. Y la operación: tres regiones que
actualizar, vigilar la ubicación de las réplicas —la Fase 21 mostró que se mueven solas— y el código del reintento
en cada transacción. Postgres pide lo suyo: la conmutación del primario a la réplica no viene sola.

---

## 💥 5. El punto de rotura

**La transacción distribuida con contención alta.** La escalera de la sección 4.3 es la rotura, y no tiene un
umbral limpio: tiene una forma. Hasta 12 trabajadores, más trabajadores es más trabajo hecho (de 26,9 a 44,4
confirmadas/s). Desde ahí, **cada trabajador más resta**: a 48, 29,3 confirmadas/s, **4,32 intentos perdidos por
cada confirmada**, 32 transacciones que se rindieron, y los trabajadores de Ecuador y Perú con una mediana de **11
a 13 s** por hora sumada. Ninguna sentencia falló; el sistema hace cada vez menos, y lo poco que hace lo hace del
lado de la fila. El motivo, literal (E-75 en [`a09`](a09-catalogo-de-errores.md)):

```text
40001 restart transaction: TransactionRetryWithProtoRefreshError: WriteTooOldError: write for key /Table/113/1/"SN-0005382"/0 at timestamp 1791779703.716998341,0 too old; must write at or above 1791779703.717719424,2: "sql txn" meta={id=3dbc81cc key=/Table/113/1/"SN-0005382"/0 iso=Serializable pri=0.00692988 epo=0 ts=1791779703.717719424,2 min=1791779703.716998341,0 seq=0} lock=true stat=PENDING rts=1791779703.716998341,0 gul=1791779704.216998341,0 obs={n1@1791779703.716998341,0 n3@1791779703.721078466,0}
```

El número total cambia entre corridas, y conviene decirlo: el mismo escalón de 48 en otro demo, el del boss, dio
**154,8 confirmadas/s** con 1,53 reintentos y 35 que se rindieron. Lo que no cambió es a quién castiga: Colombia en
13 ms y Ecuador y Perú en **12,6 y 9,6 s**.

> 💥 **Rotura — la fila que pelean tres países** · CockroachDB 26.3.2, nueve nodos, `SERIALIZABLE` · leer y
> escribir sobre una fila de Colombia desde las tres regiones · verificado el 11/10/2026: el máximo a 12
> trabajadores (44,4/s), y a 48, 29,3/s con 4,32 reintentos por confirmada y una mediana remota de 11–13 s. La
> forma atómica no reintenta nunca, pero cae a 7,4/s con un p99 de 15 s.

**Y el reloj, que la Fase 21 dejó sin verificar.** En dos demos de esta fase, uno quieto y otro moviendo réplicas,
un nodo se mató solo (E-76):

```text
F261012 02:03:51.913580 36826 1@rpc/peer.go:524  [T1,Vsystem,n8,rnode=6,raddr=127.0.0.1:26362,class=system,rpc] 1  clock synchronization error: this node is more than 400ms away from at least half of the known nodes (0 of 1 are within the offset)
```

Es la regla de la sección 6.5 de la Fase 21 en acción: un nodo que no puede confiar en su reloj prefiere apagarse
a servir una lectura que puede estar mal. **Lo que no fue es un reloj desfasado**: los nueve nodos comparten el de tu
máquina. Desde adentro, un latido que llega tarde —por una pausa del proceso o de la VM— se ve igual que un reloj
adelantado, y el motor no puede distinguirlos. La causa exacta de cada pausa no se pudo confirmar. El demo no
acepta la opción que desactiva el chequeo, y en un clúster de verdad no se desactiva.

**Lo que no se pudo provocar: la región caída.** Con la ubicación restringida, perder Ecuador debería dejar el
expediente sin servicio, con error, en vez de dejarlo servir mal. El demo no deja apagar sus nodos: `cockroach node
drain --shutdown` no llega a ellos (`error reading server preface`). **Queda sin verificar**, y es el ejercicio
opcional.

---

## 🚑 6. Salir de aquí

Cuando NewSQL ya duele, en orden de costo:

1. **La sentencia.** Una suma que se escribe como `hours = hours + 1` no necesita leer antes: cero reintentos y la
   misma espera para los tres países (sección 4.3). Toda transacción de leer y escribir que pueda ser una sentencia
   debería serlo, y la que no, debería leer con `SELECT … FOR UPDATE` para hacer cola en vez de pelear.
2. **El modelo.** Una fila que tres países escriben no debería ser una fila. **Las horas partidas por región**
   —una fila por región, cada una en su país, sumadas al leer, como el G-Counter de la
   [Fase 19](19-offline-levantar-y-modelar.md)— lo resuelve: **701 a 1920 confirmadas/s, cero reintentos**, las
   horas exactas, y una mediana de 2 a 30 ms **en los tres países** (Perú tardó 131 ms en los primeros escalones,
   mientras su fila recién creada se mudaba a Perú). Leer las horas pasa a costar una suma de tres filas. Y la región de la fila caliente es la de quien más la escribe:
   la pieza del motor de un avión ecuatoriano podría vivir en Ecuador.
3. **La frontera.** Lo que de verdad necesita ser atómico entre países es poco: la firma que libera la aeronave al
   servicio. Las lecturas del expediente, los reportes, las horas y el inventario de cada base son locales. **Un
   Postgres por país, y NewSQL solo para la firma**, es la salida que el miniproyecto de Barlovento defiende, y la
   más barata de las que quitan la contención en vez de esconderla.
4. **La arquitectura.** Si no hay ley que obligue y una región basta, Postgres con réplica, como en la sección 4.2.

---

## ❓ 7. Las cinco preguntas, respondidas para NewSQL

1. **Frontera transaccional.** Es la pregunta que decide la familia: NewSQL vale si la frontera cruza países
   **y** no se puede estrechar. Su precio es un viaje entre regiones por cada sentencia que cruza, y los 486 ms de la
   rutina del Coca.
2. **Estabilidad de las consultas.** No pide nada nuevo: es SQL. Pide que **cada consulta diga su región**, o recorre
   las tres (Fase 21).
3. **Unidad de lectura.** La fila y su rango, como en Postgres; lo nuevo es que cada rango tiene país.
4. **Saltos de la relación típica.** Los de Postgres, pero un `JOIN` o una clave foránea que cruza de país cuesta un
   viaje: 136 ms leer lo instalado de una aeronave ecuatoriana, porque la pieza vive en Colombia.
5. **Exactitud contra parecido.** Exacta, serializable, sin réplicas atrasadas en las votantes: es la única familia
   del curso que no cambia exactitud por nada. Cambia latencia.

---

## ⚖️ 8. Veredicto honesto: cuándo NO usar esto

**No uses NewSQL si una región te basta.** Contra la mejor jugada de Postgres, CockroachDB tardó **50 veces más** en
servir el expediente en Quito (167 ms contra 3,3), **siete veces más** en la rutina del Coca (486 contra 69) y
**quinientas veces más** en la inspección de Bogotá (565 contra 1,1), con **nueve nodos contra dos**. La apuesta
estaba hecha para que la familia la perdiera, y la perdió.

**No lo uses para una fila que pelean varios países.** Con tres regiones escribiendo la misma fila, el máximo fue
44 confirmadas/s y la mediana de los lejanos, siete segundos; Postgres, sin geografía, hace 820/s con la misma suma
en una sentencia. Si la contención es parte del dominio, se parte la fila o se estrecha la frontera, no se compra un
motor.

**No lo uses para esconder una aplicación que no reintenta.** En `SERIALIZABLE`, el `40001` es parte del contrato.
Y en `READ COMMITTED`, que lo evita, Postgres sumó 178 horas de 7832: el problema es la forma de la transacción, no
el motor.

**Úsalo cuando necesites ACID de verdad sobre varias regiones, o cuando la ley decide dónde vive cada fila.** Es el
caso de Cóndor: Postgres ganó todo lo que la apuesta midió, y perdió lo único que el contrato pide —el primario en
Bogotá guarda cada firma ecuatoriana en Colombia, y la réplica de Quito sirvió durante el corte un expediente sin la
inspección mayor, sin ningún error—. Con la autoridad en la clave y una super región (la Fase 21 midió que la
documentación la prefiere), el expediente vive en Ecuador, se escribe desde dos países y nunca se lee viejo. **Y
aun así, solo para la parte que lo necesita**: la firma que cruza, no las lecturas de todos los días.

---

## ⚠️ 9. Errores comunes y diagnóstico

**La transacción que pierde siempre contra la de al lado** (E-75): `40001 … WriteTooOldError …`. 🩺 Una fila
escrita desde varias regiones; el remoto llega tarde a cada escritura. Salir: la sentencia atómica, `FOR UPDATE`, o
la fila partida (sección 6).

**El nodo que se mata solo** (E-76): `clock synchronization error: this node is more than 400ms away …`. 🩺 Un
reloj desfasado, o en el laboratorio una pausa larga. Salir: en el laboratorio, recrear el demo y volver a cargar;
en producción, NTP y nunca apagar el chequeo.

**La réplica que no avisa.** Sin mensaje del lado de las lecturas: el del log de la réplica es `could not connect
to the primary server` (E-77), y nadie lo lee. 🩺 `pg_stat_wal_receiver` vacío, o `now() -
pg_last_xact_replay_timestamp()` creciendo con el primario escribiendo. Salir: que la aplicación sepa qué tan vieja
es la réplica antes de responder, o no leer de ella lo que decide algo.

**Postgres `SERIALIZABLE` que rechaza una suma** (E-79): `could not serialize access due to concurrent update`, en
un `UPDATE` de una sola sentencia. 🩺 En Postgres, `SERIALIZABLE` no reintenta solo. Salir: `withRetry`, o esa
sentencia en `READ COMMITTED`, donde es segura.

**El entero que llega como texto** (E-78): `could not parse "47311111111111111111" as type int`. 🩺 El `INT` de
CockroachDB es de 8 bytes y `pg` lo devuelve como texto: `"4731" + 1` es `"47311"`. Salir: `Number()` o `BigInt()`
antes de sumar.

---

## 📋 10. Checklist de validación

```text
[ ] La apuesta escrita con hora antes de medir, y juzgada con su criterio: ganada, 3 de 3 y 2 nodos contra 9
[ ] La matriz: ~67 ms entre Colombia y los otros dos, ~149 entre Ecuador y Perú
[ ] latency.ts: 167 / 486 / 565 ms con la autoridad en la clave, y por qué la copia es más rápida en Bogotá
[ ] CockroachDB en un solo viaje tarda lo mismo; Postgres sentencia por sentencia desde el Coca, 543 ms
[ ] partition.ts: lecturas sin error y sin la firma de Bogotá durante todo el corte
[ ] contention.ts: el máximo a 12 trabajadores, la caída a 48, y los p50 remotos en segundos
[ ] READ COMMITTED leer-y-escribir en Postgres: horas perdidas sin un error
[ ] withRetry escrito, y lo que no puede ir dentro de la transacción
[ ] M-66 a M-71 en la bitácora, E-75 a E-79 en a09, la apuesta 11
```

---

## 🧪 11. Ejercicios (26)

Desde `src/`, con `newsql-global` y la base de la autoridad restringida (sección 4), salvo donde se diga. Los
ejercicios con el par de Postgres levantan `compose.replica.yaml` y cargan el primario con `load.ts`.

### 🟢 Fácil — reproducir (1–6)

#### 🟢 Ejercicio 1 — Tu física

Corre `latency.ts` y compara tu matriz con la de la sección 4.1.

**Objetivo:** los nueve valores, y el RTT entre cada par de regiones restando la lectura local.

#### 🟢 Ejercicio 2 — Una sentencia, explicada

Toma "UPDATE pieza instalada" de la rutina del Coca (138 ms en la sección 4.1).

**Objetivo:** cuántos viajes a Colombia son, y cuál es cada uno, con su `EXPLAIN ANALYZE`.

#### 🟢 Ejercicio 3 — El COMMIT

Firma la rutina del Coca y pide `SHOW LAST QUERY STATISTICS` después del `COMMIT`.

**Objetivo:** su latencia, y por qué no es cero si todas las sentencias ya escribieron.

#### 🟢 Ejercicio 4 — La réplica, por dentro

Con el par de Postgres arriba, `pg_stat_replication` en el primario y `pg_stat_wal_receiver` en la réplica.

**Objetivo:** el estado de cada uno, y en qué columna se ve el atraso.

#### 🟢 Ejercicio 5 — Cortar y reponer

Corre `partition.ts`.

**Objetivo:** cuántas lecturas sin la firma de Bogotá hizo Quito, y cuánto tardó la réplica en notar el corte.

#### 🟢 Ejercicio 6 — Un escalón

`contention.ts --kind rmw --steps 4`.

**Objetivo:** confirmadas por segundo, reintentos y la mediana de cada país, contra la fila de 12 de la sección 4.3.

### 🟡 Intermedio — medir de otra forma (7–13)

#### 🟡 Ejercicio 7 — Desde Perú

Pide el expediente de `HC-2157` desde la puerta de Perú, sentencia por sentencia.

**Objetivo:** la latencia de cada una, y por qué cuesta más que desde Colombia.

#### 🟡 Ejercicio 8 — Postgres en Quito

Cambia `bet.ts` para que el primario esté en Quito y la réplica en Bogotá.

**Objetivo:** la tabla de la sección 4.2 otra vez, y qué filas quedan entonces fuera de su país.

#### 🟡 Ejercicio 9 — Sentencia por sentencia

Mide en el par de Postgres la rutina del Coca mandada sentencia por sentencia, sumando un RTT por viaje.

**Objetivo:** que llegues a los ~543 ms de la sección 4.2, y la línea de código que la vuelve un solo viaje.

#### 🟡 Ejercicio 10 — Dos regiones

Repite la escalera con `--regions CO,PE`.

**Objetivo:** el máximo y la caída, y si cambia algo que el lejano sea Perú y no Ecuador.

#### 🟡 Ejercicio 11 — La fila en Ecuador

Mueve la fila caliente: suma horas a una orden de `HC-2157` (una fila de Ecuador) en lugar del motor.

**Objetivo:** quién gana ahora la contención, con las medianas por país.

#### 🟡 Ejercicio 12 — `FOR UPDATE`

Agrega a `contention.ts` una forma que lea con `SELECT … FOR UPDATE`.

**Objetivo:** reintentos y medianas por país contra leer-y-escribir y contra la atómica.

#### 🟡 Ejercicio 13 — Las horas perdidas

Corre la forma de leer-y-escribir en `READ COMMITTED` contra CockroachDB.

**Objetivo:** horas sumadas contra confirmadas, comparado con Postgres en la sección 4.3.

### 🟠 Difícil — diagnosticar y decidir (14–20)

#### 🟠 Ejercicio 14 — Un reintento que no se puede repetir

Agrega dentro de la transacción de `withRetry` una llamada que registra en un archivo "hora sumada".

**Objetivo:** cuántas líneas tiene el archivo contra las horas confirmadas, y dónde tiene que ir esa llamada.

#### 🟠 Ejercicio 15 — Rendirse bien

Cambia `withRetry` para que se rinda por tiempo (dos segundos) y no por intentos.

**Objetivo:** la tabla de 48 trabajadores otra vez, y qué le dice la aplicación al técnico de Ecuador.

#### 🟠 Ejercicio 16 — El atraso que importa

Escribe la lectura del expediente en Quito que sabe qué tan vieja es su réplica y se niega a responder si pasa de
un umbral.

**Objetivo:** que durante el corte de `partition.ts` responda con un error explícito en vez de con datos viejos.

#### 🟠 Ejercicio 17 — El reloj en la carga

Repite la escalera de la sección 4.3 con `docker stats` cada 5 s.

**Objetivo:** la memoria del demo en cada escalón, y si el último se acerca a lo que mató a otros demos.

#### 🟠 Ejercicio 18 — La cuenta antes de medir

Escribe, antes de correrla, la latencia esperada de la firma de Bogotá con el esquema de la autoridad: viajes por
sentencia por RTT.

**Objetivo:** tu cuenta y la medida, a menos de un 20 % una de otra, o la comprobación que no habías contado.

#### 🟠 Ejercicio 19 — Copia y autoridad, en milisegundos

Con la copia en un demo nuevo, corre `latency.ts --schema copy` y mira dónde quedó su leaseholder.

**Objetivo:** explicar con tu leaseholder por qué tu tabla se parece, o no, a la de la sección 4.1.

#### 🟠 Ejercicio 20 — El costo de Cóndor

Con los mínimos de la sección 4.5 y los precios de hoy de un proveedor que elijas, calcula el costo mensual de las
dos opciones.

**Objetivo:** las dos cifras con su fuente y su fecha, y cuántos años de Postgres paga un año de clúster.

### 🔴 Muy difícil — romper y decidir (21–26)

#### 🔴 Ejercicio 21 — La frontera estrecha

Diseña Cóndor con un Postgres por país y NewSQL solo para la firma que libera la aeronave.

**Objetivo:** qué tablas van en cada uno, qué proporción de las escrituras de `workOrder-10k` cruzaría países, y
cómo se ve la firma de Bogotá.

#### 🔴 Ejercicio 22 — La fila partida, con lectura

Con la forma partida de la sección 6, mide además lo que cuesta **leer** las horas del motor desde cada país.

**Objetivo:** la latencia de la suma desde Colombia, Ecuador y Perú, y si para el técnico importa más esa o la de
escribir.

#### 🔴 Ejercicio 23 — La firma doble

Haz que el Coca y Bogotá firmen a la vez dos órdenes que retiran **la misma pieza** de `HC-2157`.

**Objetivo:** que solo una confirme, en Postgres con réplica y en CockroachDB, y qué pasa en Postgres si el corte
de `partition.ts` ocurre en el medio.

#### 🔴 Ejercicio 24 — La región que se cae

Con `cockroach demo` interactivo (`docker compose attach newsql-global`, y `\demo shutdown 4`, 5 y 6), apaga Ecuador
y pide el expediente desde Perú y la firma desde Bogotá.

**Objetivo:** el error literal y en cuánto tiempo llega, con la ubicación restringida y con la de defecto; o, si no
lo logras, por qué.

#### 🔴 Ejercicio 25 — El segundo operador estatal

Lucía firma con un operador estatal peruano. Repite la apuesta para su expediente, desde Lima.

**Objetivo:** la tabla de la sección 4.2 con Perú, y si la conclusión cambia con 149 ms entre Quito y Lima.

#### 🔴 Ejercicio 26 — El veredicto para tu empresa

Elige un sistema que conozcas con datos en más de un país.

**Objetivo:** las cinco preguntas de la sección 7 respondidas para él, con la operación que de verdad necesitaría
ser atómica entre países, y su proporción.

### 🔥 Opcionales

- **YugabyteDB** con el mismo expediente y `latency.ts` apuntando a su puerto de Postgres: la misma tabla de la
  sección 4.1.
- **Toxiproxy** delante de la réplica de Postgres, con 67 ms de latencia inyectada, para medir el atraso real de la
  réplica en lugar de suponerlo.

---

## 📚 12. Referencias

> ⚠️ Las URLs y sus contenidos cambian, y la documentación de CockroachDB cubre la última versión. Esta fase se
> verificó con CockroachDB 26.3.2 y PostgreSQL 18.6.

- **Errores de reintento** — https://www.cockroachlabs.com/docs/stable/transaction-retry-error-reference —
  `WriteTooOldError`, `RETRY_SERIALIZABLE` y lo que hay que hacer con cada uno.
- **Contención en transacciones** — https://www.cockroachlabs.com/docs/stable/performance-best-practices-overview —
  la fila caliente, `SELECT … FOR UPDATE` y por qué una sentencia es mejor que leer y escribir.
- **Recomendaciones de producción** — https://www.cockroachlabs.com/docs/stable/recommended-production-settings —
  vCPU y RAM por nodo, de donde sale la sección 4.5.
- **Topologías multi-región** — https://www.cockroachlabs.com/docs/stable/topology-patterns — cuántos nodos pide cada
  meta de supervivencia.
- **Replicación en streaming de PostgreSQL** — https://www.postgresql.org/docs/18/warm-standby.html — el primario, la
  réplica, `wal_receiver_timeout` y lo que la réplica no sabe.
- **El aislamiento en PostgreSQL 18** — https://www.postgresql.org/docs/18/transaction-iso.html — por qué
  `SERIALIZABLE` rechaza una suma concurrente y `READ COMMITTED` pierde la que se lee antes.
- **Kleppmann, *Designing Data-Intensive Applications*** (O'Reilly, 2017) — capítulo 5 (las réplicas atrasadas y
  "leer lo que escribí"), capítulo 7 (*lost update* y *write skew*) y capítulo 8 (relojes y pausas de proceso: el
  nodo que no sabe si se detuvo él o el mundo).
- **Corbett y otros, *Spanner*** (OSDI 2012) —
  https://www.usenix.org/conference/osdi12/technical-sessions/presentation/corbett — la latencia de confirmar entre
  continentes, contada por quienes la pagan.
- **Bailis y otros, *Highly Available Transactions: Virtues and Limitations*** (VLDB 2014) —
  https://arxiv.org/abs/1302.0309 — qué garantías se pueden tener sin coordinar entre regiones, y cuáles no.

**Orden sugerido:** los errores de reintento antes de la sección 4.3; el capítulo 7 de Kleppmann antes de la 4.4; la
replicación en streaming antes de cortar el enlace; Bailis al cerrar la fase, antes del boss.

---

## 🏁 13. Resultado de la fase

```text
newsql-global (nueve nodos, en memoria)   condor con la autoridad en la clave y la ubicación restringida
condor-replica (compose.replica.yaml)     primario en Bogotá (15440) y réplica en Quito (15441), base expediente
lab/data/f22-latency-*.json               la matriz y los tres trabajos, por esquema
```

Le pusiste milisegundos a cada frontera: 67 ms por viaje entre Colombia y los otros dos países, 167, 486 y 565 ms
para los tres trabajos del expediente, y un costo que vive dentro del clúster y no en la aplicación. Perdiste la
apuesta como familia —Postgres con réplica es a la vez más rápido y más barato— y entendiste por qué no alcanza:
guarda las filas ecuatorianas en Colombia, y durante un corte sirve un expediente viejo sin avisar. Peleaste una
fila desde tres países hasta que el sistema hizo cada vez menos, y viste que el lejano es el que paga. Y viste un
nodo apagarse solo por no poder confiar en su reloj.

> **La señal de que quedó bien:** *"Puedo decir, para una operación de mi sistema, cuántos viajes entre regiones
> cuesta, quién gana cuando dos países la pelean, y si de verdad necesita ser atómica entre países, o si la puedo
> dejar local y pagar la distancia solo en la parte que la ley obliga."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-22-newsql-romper-y-medir -m "F22 cerrada: apuesta 11 ganada y predicha (Postgres con réplica a 0,02/0,14/0,00× en los tres trabajos, 2 nodos contra 9); RTT del demo 67 ms Colombia–Ecuador/Perú y 149 Ecuador–Perú; con la autoridad en la clave 167/486/565 ms; la réplica sirve 73 lecturas viejas sin error durante un corte; contención: máximo 44/s a 12 trabajadores, 29/s y 4,32 reintentos a 48, remotos a 7–13 s; READ COMMITTED pierde 7654 de 7832 horas; un nodo se mata por 'clock synchronization error'; boss IV"
> ```
>
> Commits de la fase con prefijo `f22:`, los de ejercicio `f22 ej21: …`.

---

### 💀 Boss del Bloque IV — "La estación del Coca"

> *"El mes que viene firmo con el segundo operador estatal, el peruano. Seis aviones con base en Iquitos, la rutina
> en el Coca porque nos queda de paso, y la mayor en Bogotá. En el Coca no hay señal la mitad del día; los aviones
> nuevos vienen con registro de parámetros en toda la flota, a un dato por segundo; y su contrato dice lo mismo que
> el de los ecuatorianos: sus registros no salen del Perú. Cada uno de ustedes me ha explicado una base de datos que
> resuelve una parte. Yo necesito saber **qué va en cada una, qué se rompe primero, y cuánto me cuesta**, antes de
> firmar algo que no podamos cumplir."*
>
> — Lucía Arango, gerente

**El sistema, tal como podría ser.** Las tres familias del bloque, cada una con su rotura ya medida en el curso:
columnar ancha para los parámetros ([Fase 18](18-columnar-romper-y-medir.md)), offline-first para las tabletas del
Coca ([Fase 20](20-offline-romper-y-medir.md)) y NewSQL para el expediente (esta fase). Las tres no caben juntas en
la máquina de laboratorio —`newsql-global` va solo, y Cassandra con su heap fijado pide su propio espacio
([`a02`](a02-compose-de-la-ruta.md))—, así que **las roturas se provocan una por una**, con los guiones del curso:

```bash
node 18-columnar-romper-y-medir/unbounded.ts --steps 1,2              # perfil columnar, solo
node 20-offline-romper-y-medir/pingpong.ts --rounds 3                 # perfil offline
node 22-newsql-romper-y-medir/contention.ts --target global --kind rmw --steps 16   # newsql-global, solo
```

**Qué hay que entregar.** Un informe para Lucía, de no más de dos páginas, con:

1. **El reparto**: qué dato del operador peruano va en qué motor —los parámetros, lo que el técnico registra sin
   señal en el Coca, el expediente que se firma en tres países—, o en Postgres, con las cinco preguntas respondidas
   para cada uno.
2. **Las tres roturas, provocadas y medidas** con su número y su mensaje literal: la partición sin cota, la
   sincronización que no converge y la fila que pelean tres países. Para cada una, **qué decisión del reparto la
   evita** y con qué número lo demuestras.
3. **Las decisiones que no son técnicas**, escritas para que alguien las firme: residencia contra supervivencia de
   una región (E-74 en [`a09`](a09-catalogo-de-errores.md)), qué es lo único que tiene que ser atómico entre países, y
   qué hace el técnico del Coca cuando una resolución queda en disputa.
4. **El costo**: nodos por motor y por región, y lo que cuesta operar cada uno.

**Criterios de aceptación.**

```text
[ ] Cada dato del operador tiene su motor y su región, y lo que vive en Perú está dicho fila por fila
[ ] Las tres roturas están provocadas en el laboratorio, cada una con su número y su mensaje literal
[ ] Cada rotura tiene la decisión del reparto que la evita, medida: la misma prueba sin romperse
[ ] La operación que cruza países está aislada y es una sola; el informe dice qué proporción de las escrituras es
[ ] El informe dice qué pasa con el expediente peruano si Perú queda sin servicio, y quién lo decidió
[ ] El costo está en nodos y en vCPU, con la fuente de cada mínimo
```

**Pistas, si te atascas**, de la más suave a la más directa: la sección 6 de esta fase, sobre la frontera; la
sección 5 de la Fase 18, sobre el bucket; la sección 6 de la Fase 20, sobre quién resuelve; y el miniproyecto de
Barlovento, que es el mismo problema con contenedores.

> 🏷️ **Tag del boss:** `boss-bloque-4` · la solución no se publica.

> 🏆 **El Hangar, opcional.** Si lo vienes construyendo, el Bloque IV le añade **la geografía**: los parámetros de
> vuelo con su bucket de tiempo, el formulario del técnico que funciona sin señal, y el expediente con su autoridad
> en la clave. Y le añade una regla para lo que sigue: **cada dato dice en qué país puede vivir**. Quien no lo siguió
> no ha perdido nada del curso.
