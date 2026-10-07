# 🔑 Fase 06 — Clave-valor: romper la memoria, medirla contra una tabla `UNLOGGED` y decidir cuándo no

> **Curso:** Ruta NoSQL Lite · Fase 06 de 25 · Bloque I — Los dos que ya usas · **10 h**
> **Familia:** clave-valor · **Motor:** Valkey 9.1.2 `valkey/valkey@sha256:418652cfb58e…`
> **Línea base:** PostgreSQL 18.6 `pgvector/pgvector@sha256:2ba9ca5f2e7d…` (tabla `UNLOGGED`)
> **Entorno de ejecución:** TypeScript
> **Volumen:** 100 000 sesiones de terminal, las de la [Fase 05](05-clave-valor-levantar-y-modelar.md)
> **Depende de:** Fase 05 · **Habilita:** Fase 07
> **Apéndices de apoyo:** [`a04`](a04-el-arnes-de-medida.md), [`a07`](a07-postgres-linea-base.md),
> [`a09`](a09-catalogo-de-errores.md), [`a10`](a10-licencias-y-riesgo.md)
> **Fecha de verificación ejecutada:** 29/09/2026, en macOS arm64
> **Objetivo:** medir Valkey contra la tabla `UNLOGGED` que un senior pondría en su lugar, llevar la
> memoria hasta que no cabe, y escribir con números por qué clave-valor va **al lado** de la fuente de
> verdad y nunca en su lugar.

---

## 🧭 1. Dónde estamos

La [Fase 05](05-clave-valor-levantar-y-modelar.md) modeló Cóndor sin una sola consulta: sesiones con
TTL, una reserva y un candado que se ganan en un comando, una cola y un registro. Y dejó dos cuentas
abiertas: **202 viajes** cada vez que el diseño necesita algo más que la clave, y **un millón de
órdenes perdidas** cuando alguien usó Valkey como almacén primario.

Falta la comparación que justifica tener un motor más. No contra un Postgres cualquiera, sino contra
el que se usaría para lo mismo: una tabla `UNLOGGED`, que no escribe en el WAL y que
[`a07`](a07-postgres-linea-base.md) ya midió ante una caída. Si Postgres hace lo mismo con los mismos
viajes, **la razón para operar Valkey tiene que ser otra**, y esta fase la busca.

Esta fase **mide** la apuesta, **rompe** la memoria —qué pasa cuando los datos no caben— y
**decide**. Cierra además el Bloque I con su boss, que cruza las dos familias del bloque: una orden
de trabajo que entró dos veces con un candado de Valkey por medio.

---

## 🎯 2. Objetivos de esta fase

1. Medir la misma sesión en Valkey y en una tabla `UNLOGGED` bien indexada: viajes por operación,
   memoria por sesión y cómo vence cada una.
2. Resolver la apuesta, escrita antes de medir, y publicarla ganada o perdida.
3. Llenar la memoria con `maxmemory` y reproducir las dos formas de romperse: el error literal con
   `noeviction`, y la **evicción silenciosa** de **100 187 claves** con `allkeys-lru`.
4. Medir qué sobrevive a un `SIGKILL` con RDB, AOF `everysec` y AOF `always`, y decir qué no simula ese
   experimento.
5. Contestar las cinco preguntas para clave-valor y escribir cuándo no usarla.

> 🧰 **Miniproyecto de esta familia:** [Nodo Sur — el estado caliente que vive en la base de datos
> fría](h-mini-02-clave-valor-nodo-sur.md). Opcional, fuera de las horas del curso, y no entra a la
> bitácora.

---

## 🪞 3. La apuesta

> 🪞 **Apuesta antes de ejecutar.** Creo que **una tabla `UNLOGGED` de Postgres con la sesión indexada
> por clave resuelve cada operación en los mismos viajes que Valkey y ocupa menos de 3× su memoria por
> sesión**; lo que de verdad las separa es qué se pierde al reiniciar.

Escrita el 29/09/2026, antes de ejecutar `measure.ts`. Es una apuesta **de forma**: viajes y bytes, no
milisegundos. La latencia no se midió, y no hace falta para decidir: en este curso el tiempo solo es
argumento en la Fase 22. **Resultado, en la sección 4.3: ganada en las
dos cifras, y por más de lo que esperaba en la memoria.**

---

## 📐 4. La medición contra la línea base

### 4.1 La línea base, bien jugada

La tabla de Postgres no es un hombre de paja. Tiene la clave de la sesión como clave primaria, un
índice sobre el vencimiento para poder borrar las vencidas sin recorrer la tabla, y es `UNLOGGED`
porque una sesión se puede perder: es exactamente lo que [`a07`](a07-postgres-linea-base.md) recomienda
para este caso.

```sql
CREATE UNLOGGED TABLE session_unlogged (
  session_id text PRIMARY KEY, technician_id text NOT NULL, hangar_id text NOT NULL,
  terminal text NOT NULL, expires_at timestamptz NOT NULL
);
CREATE INDEX ON session_unlogged (expires_at);
```

Las dos se cargan con las mismas 100 000 sesiones, generadas por la misma función, y se miden con el
arnés: viajes contados en el cliente —escrituras al socket en Valkey, llamadas a `query` en Postgres
([`a04`](a04-el-arnes-de-medida.md))— y memoria por sesión.

```bash
cd src/lab && docker compose --profile clave-valor --profile base up -d --wait && cd ..
node 06-clave-valor-romper-y-medir/measure.ts
```

`measure.ts` borra la instancia de Valkey, **reinicia los dos contenedores** para la prueba de reinicio
y cambia la configuración de memoria de Valkey, que deja como estaba al terminar.

### 4.2 Viajes, memoria y vencimiento

```text
apuesta · 100000 sesiones
   viajes para leer una sesión:  Valkey 1 · Postgres 1
   viajes para abrir una sesión: Valkey 1 (HSET + EXPIRE en pipeline) · Postgres 1
   memoria por sesión: Valkey 156 bytes · Postgres UNLOGGED 116 bytes (tabla 77 + índices 39) → 0.74×
   vencimiento: Valkey por TTL, sin consulta · Postgres, DELETE de las vencidas: Index Scan, 1000 filas
```

> 📐 **Medición — la sesión en Valkey y en `UNLOGGED`** · 100 000 sesiones ·
> `valkey/valkey@sha256:418652cfb58e…` y `pgvector/pgvector@sha256:2ba9ca5f2e7d…` · verificado el 29/09/2026
>
> | | Valkey | Postgres `UNLOGGED` |
> |---|---|---|
> | viajes para leer una sesión | 1 | 1 |
> | viajes para abrir una sesión, con su vencimiento | 1 | 1 |
> | bytes por sesión | **156** (RAM, `used_memory`) | **116** (77 de tabla + 39 de índices) |
> | cómo vence | el motor la borra por TTL | un `DELETE` periódico, por índice |
>
> Reproducir: `node 06-clave-valor-romper-y-medir/measure.ts --only apuesta`

**Los viajes empatan.** Leer una sesión es un `HGETALL` o un `SELECT` por clave primaria: un viaje en
los dos. Abrirla con su vencimiento es un `HSET` y un `EXPIRE` en un pipeline, o un `INSERT` con su
`expires_at`: un viaje en los dos.

**La memoria la gana Postgres.** 116 bytes contra 156, un cociente de 0,74. Hay que leer bien qué se
compara: en Valkey son bytes de **RAM** que la instancia creció; en Postgres son bytes de **relación**
—las páginas de la tabla y de sus dos índices—, que viven en disco y se cachean en memoria compartida.
No son lo mismo, y por eso la apuesta decía *"menos de 3×"* y no *"igual"*. Pero el orden de magnitud
sí es comparable: **una tabla de Postgres no es un derroche de espacio frente a un hash en memoria**.

> ⚠️ **Esta cifra de Valkey se midió mal la primera vez.** Una versión anterior de `measure.ts` restaba
> `used_memory` sin limpiar antes la instancia, y dio **91 bytes por sesión**: la resta arrastraba
> memoria que el asignador había liberado en pruebas anteriores. Con `FLUSHALL SYNC` y `MEMORY PURGE`
> antes de medir, da 155 o 156 según la corrida. El comentario en el script lo cuenta, y es la razón
> de que toda medición de memoria del curso empiece desde una instancia limpia.

**El vencimiento es la primera diferencia de verdad.** En Valkey, la sesión vence sola. En Postgres,
alguien tiene que ejecutar el `DELETE` de las vencidas —aquí, con su índice, un `Index Scan` que borró
1000 filas—, y **hasta que lo ejecuta, la sesión vencida sigue ahí**: toda lectura tiene que filtrar
por `expires_at > now()` o devuelve sesiones muertas. Es un proceso más que programar, y es el que en
el miniproyecto de Nodo Sur no termina antes de las seis de la mañana.

### 4.3 El resultado de la apuesta

> 🪞 **Resultado.** **Ganada en las dos cifras.** Los viajes empatan, 1 contra 1 para leer y para
> escribir. Y la memoria no llega a 3×: **Postgres ocupa 0,74 veces lo que Valkey**, menos, no más.
> Esperaba que la tabla perdiera por poco, y ganó.
>
> La tercera parte, *"lo que las separa es qué se pierde al reiniciar"*, se sostiene, pero **no en la
> dirección que el instinto espera**. Lo cuenta la sección 4.4.

Es un resultado incómodo para la razón con la que casi todo el mundo añade Valkey —*"las sesiones en
Postgres son pesadas"*—, y hay que decirlo con esas palabras: **en forma, una tabla `UNLOGGED` bien
indexada hace lo mismo que Valkey para una sesión**. Lo que Valkey da es el vencimiento sin proceso
aparte, y lo que da la sección 4.4.

### 4.4 Qué se pierde al reiniciar, y quién pierde más

`measure.ts` reinicia los dos motores de dos formas: un apagado limpio (`docker compose stop`) y una
caída (`docker kill --signal=KILL`). Antes de la caída, Valkey guarda una instantánea con `SAVE` y
recibe 1000 sesiones más que ya no se guardan.

```text
   tras un apagado limpio: Valkey 100001 claves · Postgres 99001 filas
   tras SIGKILL, con 100000 sesiones guardadas y 1000 nuevas sin guardar: Valkey 100000 claves · Postgres UNLOGGED: ver a07, se vacía
```

**Tras un apagado limpio, los dos conservan todo.** Valkey guarda al recibir la señal de parada, y
Postgres escribe las páginas de una tabla `UNLOGGED` en el apagado limpio. (Las cifras no coinciden
porque Postgres tiene 1000 filas menos: las que borró el `DELETE` de la sección 4.2; las dos tienen
además la sesión nueva que se abrió al medir viajes.)

**Tras la caída, pierde más Postgres.** Valkey arranca con su última instantánea: **100 000 de
101 000**, pierde solo lo escrito después de guardar. La tabla `UNLOGGED` arranca **vacía**: la
recuperación tras una caída vacía toda tabla `UNLOGGED`, que es lo que [`a07`](a07-postgres-linea-base.md)
midió con 100 000 filas (100 000 antes, **0** después). `measure.ts` no lo repite: remite a esa
medición.

Esa es la separación real, y es el revés de lo que se suele creer. *"Valkey es volátil y Postgres
durable"* es cierto para una tabla normal; **para una `UNLOGGED`, la caída la vacía entera**, y Valkey
con su instantánea conserva más. Si las sesiones se pueden perder enteras, las dos sirven. Si perder
todas las sesiones a la vez —todos los técnicos fuera de sus terminales al mismo tiempo— es un
problema, la `UNLOGGED` es la peor de las dos opciones, y la tabla normal, con su WAL, la mejor.

### 4.5 La reserva y el candado, en Postgres

La apuesta midió la sesión. Para no dejar la reserva y el candado de la Fase 05 sin línea base,
`extra.ts` los hace en Postgres: la reserva como una fila con clave primaria `(hangar, puesto, día)` e
`INSERT … ON CONFLICT DO NOTHING RETURNING`, y el candado con `pg_try_advisory_lock`.

```text
reserva: grupo-motores → 1 fila (1 viaje) · grupo-estructuras → 0 filas · dueño: grupo-motores
candado: terminal-2 → true (1 viaje) · terminal-5 → false · soltarlo desde terminal-5 → false · terminal-2 se cae y terminal-5 lo intenta → true
```

La misma forma que en Valkey: **un viaje, y quien pierde recibe cero filas o `false`**, no un error.
El candado consultivo tiene además dos diferencias que valen oro para la Fase 05:

- **Solo lo suelta quien lo tomó**, sin script: el terminal 5 intenta soltarlo y recibe `false`.
- **Está atado a la conexión, no a un TTL.** Cuando el terminal 2 se cae —aquí, su conexión terminada
  con `pg_terminate_backend`—, el candado se suelta solo, y el terminal 5 lo consigue. No hay que
  adivinar cuánto dura una edición.

El reverso también es honesto: si el terminal 2 se cuelga **con la conexión viva**, el candado
consultivo no vence nunca, y el de Valkey sí. Ninguno es mejor en abstracto; **cada uno apuesta a un
fallo distinto**, y el boss de esta fase muestra qué pasa cuando la apuesta es la equivocada.

### 4.6 RDB contra AOF: lo que sobrevive a la caída del proceso

La situación 3 de la Fase 05 perdió el millón de órdenes con la persistencia por defecto. Aquí, las tres
configuraciones una contra otra. Cada configuración en un contenedor
propio, con la persistencia en la línea de comandos: 50 000 sesiones escritas y un `SIGKILL`
inmediato.

```text
RDB por defecto: 50000 sesiones escritas y SIGKILL inmediato → sobreviven 0
AOF everysec: 50000 sesiones escritas y SIGKILL inmediato → sobreviven 50000
AOF always: 50000 sesiones escritas y SIGKILL inmediato → sobreviven 50000
```

Con RDB, se pierde todo lo posterior a la última instantánea: aquí, todo. Con AOF, cada escritura se
añade a un registro, y el proceso muerto no se lleva nada.

> ⚠️ **Por qué `everysec` y `always` empatan aquí, y qué no se midió.** `SIGKILL` mata el proceso,
> pero el sistema operativo sigue vivo: lo que Valkey ya escribió al archivo está en la caché del
> sistema y llega al disco igual. La diferencia entre las dos opciones es **cuándo se fuerza el disco**
> (`fsync`): una vez por segundo o en cada escritura. Esa diferencia solo aparece si cae **la
> máquina**, no el proceso: un corte de luz o un kernel colgado. Eso no se reprodujo en el
> laboratorio, y la documentación de Valkey habla de perder hasta un segundo con `everysec`. **No lo
> publicamos como medido.**

El resultado es un veredicto a medias: **con AOF, Valkey sobrevive a la caída de su proceso**,
cosa que ni la `UNLOGGED` ni el RDB por defecto hacen. Lo que no sabemos, porque no se midió, es cuánto
pierde con `everysec` ante la caída de la máquina.

### 4.7 Lo que la apuesta no midió

Cuatro cosas quedan fuera, y conviene nombrarlas antes de usar el resultado. **La latencia**: ni un
milisegundo en esta fase, por diseño. **La concurrencia**: todo se midió con uno o dos clientes, y un
día de pago de Nodo Sur son miles. **La memoria de Postgres en memoria**: los 116 bytes son de
relación, y cuántas de esas páginas viven en `shared_buffers` es el ejercicio 24. **Las escrituras
repetidas sobre la misma clave**, como un contador o una sesión que se refresca en cada petición, donde
Postgres deja una tupla muerta por cada `UPDATE` y Valkey no: son los ejercicios 9 y 25. Cualquiera de
las cuatro podría mover el veredicto, y ninguna se publica como medida.

---

## 💥 5. El punto de rotura

Valkey guarda todo en RAM, y la RAM se acaba. El límite se declara con `maxmemory`, y lo que pasa al
llegar a él lo decide `maxmemory-policy`. Para que el punto de rotura quepa en el laboratorio,
`measure.ts` fija **16 MB** —un modelo a escala de la RAM de una máquina— y escribe sesiones en lotes
de mil hasta que algo pasa. La imagen trae `maxmemory 0` (sin límite) y `noeviction`.

> 💥 **Rotura, con `noeviction`.** La escritura falla en el lote que empieza en la sesión
> **100 000**, con este mensaje:
>
> ```text
> OOM command not allowed when used memory > 'maxmemory'.
> ```
>
> Las lecturas siguen funcionando; toda escritura que pida memoria falla. **Es la rotura buena**:
> ruidosa, con mensaje, y nada se perdió.

La otra rotura es la que asusta. Con `allkeys-lru`, al llegar al límite Valkey **borra las claves
menos usadas para hacer sitio**, sin error. Antes de llenar, `measure.ts` escribe una reserva sin TTL
—`slot:VVC:foso-1:2026-10-06`, que alguien cree persistente— y después 200 000 sesiones:

```text
maxmemory 16mb, allkeys-lru, 200000 sesiones escritas: quedan 99814 claves · evicted_keys 100187 · la reserva sin TTL: desapareció · ningún error
maxmemory 16mb, volatile-lru: quedan 99648 claves · la reserva sin TTL: grupo-motores · escritura: sin error
```

> 📐 **Medición — la memoria llena** · `maxmemory 16mb`, sesiones de la Fase 05 ·
> `valkey/valkey@sha256:418652cfb58e…` · verificado el 29/09/2026
>
> | Política | Qué pasa al llegar al límite | Error | La reserva sin TTL |
> |---|---|---|---|
> | `noeviction` | falla la escritura en torno a la sesión 100 000 | **sí**, `OOM command not allowed…` | intacta |
> | `allkeys-lru` | **100 187 claves borradas** de 200 000 escritas | ninguno | **desapareció** |
> | `volatile-lru` | se borran solo claves con TTL | ninguno | intacta |
>
> Reproducir: `node 06-clave-valor-romper-y-medir/measure.ts --only memoria`

**Cien mil claves desaparecieron y nadie recibió un error.** Entre ellas, la reserva del foso, que no
tenía TTL porque *"las reservas no vencen"*. Es la **evicción silenciosa**: con `allkeys-lru`, todo lo
que está en la instancia es caché a los ojos de Valkey, se haya escrito como caché o no. La única
huella es un contador, `evicted_keys`, en `INFO stats`.

`volatile-lru` protege la reserva porque solo desaloja claves con TTL, pero no es gratis: **las
sesiones se desalojaron antes de vencer**, y un técnico con la sesión abierta hace una hora la pierde
igual, sin error. Las cifras de claves restantes varían unos cientos entre corridas (en la
verificación, 99 814 y 100 342 con `allkeys-lru`): el LRU de Valkey es aproximado, por muestreo.

**Lo que se cambia para salir** depende de qué había en la instancia. Si todo es reconstruible, la
evicción es la función y `allkeys-lru` es correcta. Si hay algo que no lo es, **no debería estar en esa
instancia**: o se separa en otra con `noeviction`, o sale de Valkey. Subir `maxmemory` solo aplaza la
misma decisión.

---

## 🚑 6. Salir de aquí

Cuando un Valkey ya duele, la escalera se sube en orden de costo:

1. **Configuración.** Mira `CONFIG GET maxmemory*`, `CONFIG GET save` y `CONFIG GET appendonly`. La
   imagen del curso arranca sin límite de memoria, sin AOF y con instantáneas cada minuto como muy
   pronto: si nadie las decidió, se decidieron solas. Con AOF, una caída del proceso no perdió nada en
   la sección 4.6.
2. **Modelo.** Todo lo que tiene duración lleva TTL; lo que no es reconstruible no se mezcla con lo que
   sí; y cada índice a mano tiene su forma de limpiarse (Fase 05, sección 7). Una reserva sin TTL en una
   instancia con `allkeys-lru` es un error de modelo, no de configuración.
3. **Motor.** Si lo que había en Valkey era estado que no se puede perder —órdenes, reservas firmes—,
   va a Postgres. Con los números de la sección 4: los mismos viajes y menos bytes. Si era estado
   perdible y el problema era operar un componente más, `UNLOGGED` lo hace con el mismo número de
   viajes.
4. **Arquitectura.** Valkey al lado de la fuente de verdad, como caché o como coordinación, alimentado
   desde ella y reconstruible desde ella (Fase 24). Es el peldaño más
   caro, y el triaje de la [Fase 02](02-las-cinco-preguntas.md) dice cómo subirlo sin parar el negocio.

---

## ❓ 7. Las cinco preguntas, respondidas para clave-valor

1. **Frontera transaccional.** Clave-valor la tiene del tamaño **de un comando**: un `SET NX`, un
   `ZPOPMIN`, un script Lua. Todo lo que cruce dos motores —un candado en Valkey que protege una
   escritura en Mongo— queda fuera de cualquier frontera, y es exactamente el boss de esta fase. Si la
   frontera de tu dominio es más grande que un comando, no vive aquí.
2. **Consultas conocidas.** Obligatorias. Sin la clave no hay consulta, y cada consulta nueva es otra
   estructura mantenida a mano: 202 viajes sin ella, 2 con ella y 1000 entradas fantasma tras el TTL
   (Fase 05).
3. **Unidad de lectura.** Una clave. Si la unidad es una clave, es la familia más directa que hay; si
   es cualquier cosa más grande, cada lectura es un recorrido.
4. **Saltos.** Ninguno. Cada salto es otra clave que la aplicación tiene que construir y pedir.
5. **Exactitud o parecido.** Exactitud, por nombre exacto de clave. Ni siquiera un prefijo se busca
   sin recorrer.

---

## ⚖️ 8. Veredicto honesto: cuándo NO usar esto

> ⚖️ **Clave-valor es un efecto, no una causa.** Se pone **al lado** de la fuente de verdad, nunca en
> su lugar. **No la uses** como almacén primario de nada que no puedas reconstruir: con la configuración
> por defecto, una caída del proceso se llevó **1 000 000 de órdenes de 1 000 000** (Fase 05). **No la
> uses** con una política de evicción para datos que alguien cree persistentes: `allkeys-lru` borró
> **100 187 claves** y una reserva sin un solo error. **No la uses** cuando las preguntas no se conocen
> de antemano: cada una es otra estructura que mantienes a mano. **Y no la añadas por las sesiones**
> que solo se abren y se leen: una tabla `UNLOGGED` bien indexada hace lo mismo en **los mismos viajes
> y en 0,74× los bytes**. Si la sesión se refresca en cada petición, la cuenta cambia —cada refresco es
> una tupla muerta en Postgres— y esa cuenta no se midió aquí (sección 4.7).
>
> **Úsala** cuando lo que ganas es lo que Postgres no hace sin un proceso aparte: vencimiento por TTL
> sin `DELETE` programado, una cola con `ZPOPMIN` o un stream con grupo de consumidores, un contador que
> se incrementa miles de veces por segundo sin generar una tupla muerta por incremento (esto último no
> se midió aquí: es el territorio del miniproyecto). Y úsala sabiendo que **cada una de esas cosas
> depende de una configuración** —`maxmemory`, política, persistencia— que la imagen no decide por ti.

**El coste de un componente más en el diagrama**, contado con lo que este curso tuvo que hacer para
tenerlo: un servicio en el compose con su digest fijado, un volumen que la imagen no declara y que hubo
que comprobar a mano ([`a02`](a02-compose-de-la-ruta.md)), un driver más con su propia forma de
importarse ([`a06`](a06-lenguajes-y-drivers.md)), una licencia que en su linaje ya cambió dos veces
([`a10`](a10-licencias-y-riesgo.md)), tres decisiones de configuración que no tienen buen valor por
defecto, y **seis mensajes de error nuevos** en [`a09`](a09-catalogo-de-errores.md). Los 10 MiB de RAM
en reposo son lo más barato de la lista.

Para Cóndor, el veredicto es claro: **las reservas y los candados pueden vivir en Postgres**, con la
misma forma y sin componente nuevo. Valkey entra si la cola o el registro de eventos de la Fase 05 lo
justifican, y entra **al lado** de la fuente de verdad.

---

## ⚠️ 9. Errores comunes y diagnóstico

**La memoria llena, con `noeviction`** (E-30 en [`a09`](a09-catalogo-de-errores.md)):
`OOM command not allowed when used memory > 'maxmemory'.` 🩺 `INFO memory` —`used_memory` contra
`maxmemory`— y `CONFIG GET maxmemory-policy`. La salida no es subir el límite: es decidir qué no
debería estar ahí (sección 5).

**Las claves que desaparecen sin error.** No hay mensaje. 🩺 `INFO stats`, `evicted_keys`: si es
mayor que cero, Valkey borró claves para hacer sitio. Y `CONFIG GET maxmemory-policy`: si empieza por
`allkeys`, cualquier clave es candidata.

**La instancia que arranca vacía.** No hay mensaje. 🩺 `CONFIG GET appendonly` e `INFO persistence`
(`rdb_last_save_time`, `aof_enabled`). Recuerda que `CONFIG SET appendonly yes` **no sobrevive a un
reinicio** si no se escribe en la configuración: la primera versión de la prueba de persistencia de
esta fase lo aprendió así, y por eso cada configuración corre en un contenedor con la persistencia en
la línea de comandos.

**Una clave duplicada contra un índice único** (E-31): `E11000 duplicate key error collection:
condor_boss.workOrder index: pirepId_1 dup key: { pirepId: "PR-BOSS-1" } (code 11000)`. Apareció al
verificar el boss. 🩺 El mensaje nombra el índice y el valor repetido. No es un fallo del motor: es un
segundo intento que perdió la carrera, y la aplicación tiene que tratarlo como resultado.

**La tabla `UNLOGGED` vacía tras un arranque.** 🩺 En el log de Postgres, `database system was not
properly shut down; automatic recovery in progress` ([`a07`](a07-postgres-linea-base.md)). No es un
fallo: es el contrato de `UNLOGGED`.

---

## 📋 10. Checklist de validación

```text
[ ] measure.ts --only apuesta: 1 y 1 viajes en los dos motores, ~156 contra 116 bytes por sesión
[ ] Sé por qué los bytes de Valkey y los de Postgres no miden lo mismo, y por qué la cifra se compara igual
[ ] Sé por qué la primera medición dio 91 bytes y qué la corrigió
[ ] La apuesta está escrita antes de la medición, con su resultado
[ ] Tras SIGKILL: Valkey conserva su última instantánea; la UNLOGGED se vacía (a07)
[ ] extra.ts: la reserva y el candado en Postgres cuestan un viaje, y el candado se suelta al caer la conexión
[ ] maxmemory 16mb con noeviction: tengo el mensaje literal del OOM
[ ] Con allkeys-lru desaparecieron unas 100 000 claves y la reserva sin TTL, sin error
[ ] RDB 0, AOF everysec 50 000, AOF always 50 000, y sé qué no simula el SIGKILL
[ ] Puedo decir en una frase cuándo NO usar clave-valor, con los números de esta fase
[ ] M-09 y M-10 están en la bitácora, la apuesta 2 en su tabla, E-30 y E-31 en a09
```

---

## 🧪 11. Ejercicios (26)

Salvo donde se indique, con los perfiles `clave-valor` y `base` arriba. El código está en
`src/06-clave-valor-romper-y-medir/`.

### 🟢 Fácil — reproducir (1–7)

#### 🟢 Ejercicio 1 — La apuesta, en tu máquina

Ejecuta `measure.ts --only apuesta`.

**Objetivo:** reproducir 1 · 1 viajes y bytes por sesión dentro de ±2 de 156 y 116. Si los tuyos
difieren más, di por qué.

#### 🟢 Ejercicio 2 — La tabla por dentro

Con `pg_table_size` y `pg_indexes_size`, separa los 116 bytes de Postgres en tabla, clave primaria e
índice de vencimiento.

**Pregunta:** ¿cuál de los tres podrías quitar, y qué perderías?

#### 🟢 Ejercicio 3 — El OOM

Con `maxmemory 1mb` y `noeviction`, escribe sesiones desde `valkey-cli` hasta el error.

**Objetivo:** el mensaje literal y el valor de `used_memory` en ese momento.

#### 🟢 Ejercicio 4 — `evicted_keys`

Repite la prueba de `allkeys-lru` y lee `INFO stats` antes y después.

**Objetivo:** encontrar la cifra de claves desalojadas y comprobar que ningún comando devolvió error.

#### 🟢 Ejercicio 5 — La configuración que nadie leyó

Lee `CONFIG GET save`, `appendonly`, `maxmemory` y `maxmemory-policy` de la instancia del laboratorio.

**Pregunta:** para cada uno, ¿qué pasa en producción si nadie lo cambia?

#### 🟢 Ejercicio 6 — `UNLOGGED` ante la caída

Repite la prueba de [`a07`](a07-postgres-linea-base.md) con la tabla `session_unlogged` de esta fase.

**Objetivo:** 100 000 antes y 0 después de `docker kill --signal=KILL`, con la línea del log que lo
explica.

#### 🟢 Ejercicio 7 — El candado consultivo

Ejecuta `extra.ts` y lee la vista `pg_locks` mientras el terminal 2 tiene el candado.

**Objetivo:** encontrar la fila del candado consultivo y a qué proceso pertenece.

### 🟡 Intermedio — medir de otra forma (8–14)

#### 🟡 Ejercicio 8 — Una tabla normal

Cambia `session_unlogged` por una tabla normal y repite la apuesta.

**Objetivo:** los bytes por sesión, y qué cambia ante un `SIGKILL`. ¿Cambia algo en viajes?

#### 🟡 Ejercicio 9 — La sesión que se refresca

Nodo Sur refresca el vencimiento en cada petición. Haz 10 000 refrescos en Valkey (`EXPIRE`) y en
Postgres (`UPDATE … SET expires_at`).

**Objetivo:** viajes en los dos, y cuántas tuplas muertas deja Postgres (`pg_stat_user_tables`).

#### 🟡 Ejercicio 10 — El `DELETE` de las vencidas

Vence 50 000 sesiones en Postgres y bórralas de una vez, y después en lotes de 1000.

**Pregunta:** ¿cuántas filas examina cada forma, y cuál dejarías correr a mediodía?

#### 🟡 Ejercicio 11 — `volatile-ttl`

Repite la prueba de memoria con `volatile-ttl`.

**Objetivo:** qué claves desaloja primero, y si la reserva sin TTL sobrevive.

#### 🟡 Ejercicio 12 — `maxmemory-samples`

Repite `allkeys-lru` con `maxmemory-samples` en 1, 5 y 10.

**Objetivo:** cuántas claves quedan en cada caso, y explicar por qué el LRU de Valkey es aproximado.

#### 🟡 Ejercicio 13 — El tamaño del AOF

Tras escribir 50 000 sesiones con AOF, compara el tamaño del archivo con el del RDB.

**Objetivo:** los dos tamaños, y qué hace `BGREWRITEAOF`.

#### 🟡 Ejercicio 14 — La cola en Postgres

Haz la cola de pendientes de la Fase 05 en una tabla, con `SELECT … FOR UPDATE SKIP LOCKED`.

**Objetivo:** viajes para sacar la orden más antigua, comparados con `ZPOPMIN`, y el índice que
necesita la tabla para no recorrerse.

### 🟠 Difícil — diagnosticar y decidir (15–21)

#### 🟠 Ejercicio 15 — La reserva que no vence

Con `allkeys-lru` y la instancia llena, encuentra qué reservas de foso desaparecieron.

**Objetivo:** un diagnóstico que no dependa de haber visto el experimento: solo con `INFO`, `SCAN` y
la tabla de reservas de otro sistema.

#### 🟠 Ejercicio 16 — Dos instancias

Separa la instancia en dos: una con `noeviction` para reservas y candados, otra con `allkeys-lru` para
sesiones.

**Objetivo:** repetir la prueba de memoria y demostrar que la reserva sobrevive. Cuenta lo que añadiste
al compose.

#### 🟠 Ejercicio 17 — El candado que no vence

Con `extra.ts` como base, cuelga el terminal 2 sin cerrar su conexión.

**Objetivo:** demostrar que el candado consultivo no se suelta nunca, y proponer cómo detectarlo desde
`pg_stat_activity`.

#### 🟠 Ejercicio 18 — La caída de la máquina

Diseña un experimento que distinga `appendfsync everysec` de `always`. Pista: hay que matar la VM de
Docker, no el contenedor.

**Objetivo:** el diseño con su predicción escrita. Si lo ejecutas, publica el resultado aunque no
coincida.

#### 🟠 Ejercicio 19 — El costo de una política

Nodo Sur tiene 160 000 suscriptores y una sesión por cada uno. Con los bytes por sesión de esta fase,
dimensiona `maxmemory`.

**Pregunta:** ¿qué política eliges, y qué pasa el día de pago, con cuatro veces el tráfico, si te
quedas corto?

#### 🟠 Ejercicio 20 — El pipeline contra la transacción

Abre una sesión en Postgres y en Valkey con su entrada en el índice del técnico, de forma atómica.

**Objetivo:** viajes en los dos, y qué garantiza cada uno si el cliente se cae entre las dos
escrituras.

#### 🟠 Ejercicio 21 — La autopsia de la instancia compartida

Un equipo metió caché, sesiones y reservas en la misma instancia con `allkeys-lru`.

**Objetivo:** los cinco pasos de la Fase 00, con la factura calculada con los números de la sección 5.

### 🔴 Muy difícil — autopsias y romper (22–26)

#### 🔴 Ejercicio 22 — Nada en Valkey

Rediseña todo lo de la Fase 05 —sesiones, reserva, candado, cola y registro— sin Valkey.

**Objetivo:** una tabla por pieza, con viajes por operación medidos. Di qué pieza te costó más, y si
ese costo justifica el componente.

#### 🔴 Ejercicio 23 — El registro de eventos en Postgres

Reemplaza el stream con grupo de consumidores por una tabla y `LISTEN`/`NOTIFY`, o por una tabla con
cursor por consumidor.

**Objetivo:** reproducir pendientes y confirmación, y medir qué pasa con los eventos si el consumidor
se cae.

#### 🔴 Ejercicio 24 — La memoria de verdad

Mide los bytes por sesión de Postgres **en memoria**: con `pg_buffercache`, las páginas de
`session_unlogged` en `shared_buffers` tras leer todas las sesiones.

**Pregunta:** ¿cambia el cociente de 0,74? ¿Cuál de las dos cifras de Postgres es la justa para comparar
con Valkey?

#### 🔴 Ejercicio 25 — La apuesta del contador

Escribe una apuesta nueva, antes de medir, sobre un contador que se incrementa 100 000 veces: `INCR` en
Valkey contra `UPDATE … SET n = n + 1` en Postgres.

**Objetivo:** medirla en viajes, tuplas muertas y bytes, y publicar el resultado se gane o se pierda.

#### 🔴 Ejercicio 26 — El veredicto de Cóndor

Con los números de las Fases 05 y 06, decide qué de Cóndor iría a Valkey, si algo.

**Objetivo:** un documento de una página con la decisión, cada pieza justificada con un número de esta
fase y la factura operativa escrita al lado.

---

## 📚 12. Referencias

> ⚠️ Las URLs y sus contenidos cambian, y la documentación de Valkey cubre la última versión. Esta
> fase se verificó con Valkey 9.1.2 y PostgreSQL 18.6.

- **Persistencia en Valkey** — https://valkey.io/topics/persistence/ — RDB, AOF y `appendfsync`. Leer
  antes de la sección 4.6.
- **Valkey como caché LRU** — https://valkey.io/topics/lru-cache/ — `maxmemory`, las políticas y por qué
  el LRU es aproximado.
- **`UNLOGGED` en PostgreSQL** — https://www.postgresql.org/docs/current/sql-createtable.html — la
  cláusula y su contrato ante una caída.
- **Candados consultivos** — https://www.postgresql.org/docs/current/explicit-locking.html#ADVISORY-LOCKS
- **Martin Kleppmann, *How to do distributed locking*** —
  https://martin.kleppmann.com/2016/02/08/how-to-do-distributed-locking.html — el argumento de los
  *fencing tokens*. Leer antes del boss.
- **Martin Kleppmann, *Designing Data-Intensive Applications*** (O'Reilly) — el capítulo de
  transacciones, para las fronteras que cruzan dos sistemas.

**Orden sugerido:** [`a07`](a07-postgres-linea-base.md) antes de la sección 4; la persistencia y el LRU
antes de las secciones 4.6 y 5; Kleppmann antes del boss.

---

## 🏁 13. Resultado de la fase

Mediste Valkey contra la tabla que lo reemplaza y el resultado es incómodo: **mismos viajes, y Postgres
con menos bytes**. Rompiste la memoria de las dos formas —con error a las 100 000 sesiones y en
silencio con 100 187 claves desalojadas— y viste que la persistencia por defecto no guarda nada de lo
último. Lo que queda a favor de Valkey es real y tiene nombre: el vencimiento sin proceso, la cola, el
stream, y una configuración que hay que decidir a sabiendas.

> **La señal de que quedó bien:** *"Puedo decir qué de Cóndor pondría en Valkey y qué no, con un número
> de esta fase para cada pieza, y sé qué configuración le exigiría antes de encenderlo."*

> 🏷️ **Tag:** `fase-06-clave-valor-romper-y-medir` · prefijo de commit `f06:`

---

### 💀 Boss del Bloque I — "La orden que entró dos veces"

> **Lo pide:** Yamile Cruz, coordinadora de planeación · **Entregable:** informe con medición y
> arreglo mínimo, con comandos reproducibles · **Fuera de las horas del curso** · Tag
> `boss-bloque-1`

> *"Hace tres meses, el reporte de un piloto sobre el tren de nariz del HK-5339 terminó en dos órdenes
> de trabajo. Dos. Con dos técnicos asignados, dos pedidos de repuesto y una llamada del operador
> preguntando por qué le cobramos dos veces la inspección. Me dijeron que eso no podía pasar, porque
> hay un candado: cuando un terminal abre la orden, el otro espera. Y pasó.*
>
> *No quiero que me digan que fue mala suerte. Quiero saber **cuántas veces pasa**, **por qué**, y
> **qué es lo mínimo que hay que cambiar** para que no vuelva a pasar. Si la respuesta es que el candado
> no sirve, díganmelo con un número. Tengo que explicárselo a Lucía, y ella va a preguntar si hay más
> órdenes así que nadie ha visto."*

**El sistema, tal como está.** `src/06-clave-valor-romper-y-medir/boss/sistema-roto.ts` reproduce lo que
hacen los terminales de plataforma: las órdenes de trabajo viven en Mongo; los candados, en Valkey.
Cuando llega un reporte de piloto, cada terminal que lo atiende toma un candado sobre el reporte,
comprueba en Mongo que no haya ya una orden para él, la crea si no existe y suelta el candado. El script
hace que dos terminales atiendan cada reporte a la vez, 200 reportes seguidos, y cuenta:

```bash
cd src/lab && docker compose --profile documental --profile clave-valor up -d --wait && cd ..
node 06-clave-valor-romper-y-medir/boss/sistema-roto.ts
```

```text
200 reportes, dos terminales cada uno: 291 órdenes creadas · reportes con la orden duplicada: 91
```

En las corridas de verificación, **entre 91 y 98 de cada 200 reportes** terminaron con la orden
duplicada. El script no trae la respuesta, y el comentario de cabecera pide no arreglarlo ahí.

**Lo que tiene que tener el informe:**

1. **La medición del fallo**: cuántos duplicados de cada 200, en al menos tres corridas, con el comando
   exacto.
2. **La secuencia que lo produce**: los pasos de los dos terminales, en orden, que terminan en dos
   órdenes. Tiene que poder reproducirse, no solo explicarse.
3. **Qué frontera se disolvió**: dónde empieza y dónde termina lo que debería ser atómico, y en qué
   motor vive cada parte. Con la pregunta 1 de la Fase 02 en la mano.
4. **El arreglo mínimo**: el cambio más pequeño que lleva los duplicados a **cero**, medido con el mismo
   script en al menos tres corridas. "Mínimo" quiere decir que Yamile pueda entender el cambio en una
   frase.
5. **Lo que el arreglo no arregla**: qué sigue sin estar protegido después de tu cambio, y si hace falta
   el candado.
6. **La pregunta de Lucía**: cómo encontrar las órdenes duplicadas que ya existen en la base, con la
   consulta y su resultado sobre `condor_boss`.

**Cómo se evalúa:**

| Criterio | Suficiente | Bien resuelto |
|---|---|---|
| Medición | una corrida con su número | tres o más, con el rango y el comando |
| Causa | "el candado vence" | la secuencia exacta, con los instantes de cada paso de cada terminal |
| Frontera | se nombra | se dibuja: qué está en Valkey, qué en Mongo, y qué no está en ninguno |
| Arreglo | los duplicados bajan | **cero** en tres corridas, con el mensaje que ahora recibe el terminal que pierde |
| Honestidad | — | dice qué sigue sin protección y qué no se midió |

> 🧭 **Pistas, si te atascas**, de menos a más: lee otra vez la sección 6.6 de la Fase 05; mide cuánto
> dura el trabajo del terminal con el candado tomado y compáralo con el TTL; pregúntate qué motor sabe
> de verdad si una orden ya existe para ese reporte.

> 🏆 **El Hangar**, opcional. Si sigues el boss global, el Bloque I le deja dos piezas: la ficha de
> aeronave documental de las Fases 03 y 04, y la coordinación de las Fases 05 y 06 —reservas de puesto
> y candados de edición—, cada una con su veredicto escrito sobre si vive en su motor o en Postgres. Si
> no lo sigues, no te falta nada del curso.
