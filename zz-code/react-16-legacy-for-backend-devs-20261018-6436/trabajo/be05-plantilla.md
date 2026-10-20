# ⭐ Fase be05 — El giro concurrente, resuelto donde se resuelve

> Tutorial React 16 — La Esclusa, la consola de Jewel Locks · **Track BE opcional 🔥** · Fase be05 de be09 · **12 horas**
> Depende de: be04 — ya hay identidad real detrás de cada envío · Habilita: be06 — Hora dura y la autoridad del reloj

---

## 🎯 1. Propósito

*"Mil. Teníamos mil, y entregamos 1.047."* Así lo resume Itzel, y tiene razones para desconfiar de la próxima edición limitada: la noche del 15 de agosto de 2025, entre las 7:00 y las 8:00 p. m., el giro de 2019 entregó cuarenta y siete Esclusas de Oro que no existían, y les dio dos premios a jugadores que tenían un solo giro (`00-historia-del-sistema.md` §3, *Hoy*). Ese giro sigue vivo: `be03` lo reimplementó tal cual, el mismo `if` traducido de JavaScript a Go, y la deuda 💸 quedó escrita en el código con su fecha de pago. Es esta.

La Fase 5 del track base estudió las carreras donde el frontend puede estudiarlas: en el store, con el doble clic de una operadora y dos envíos que se cruzan. Hizo bien su trabajo, y dejó dicha una verdad incómoda en el incidente 11:

> 🧭 **Ninguna carrera de este dominio se resuelve en el cliente.** Se puede mitigar, disimular y hasta volver improbable. Resolver, no. La ventana entre *"comprobé"* y *"anoté"* solo se cierra donde hay un único árbitro.

Esta fase la cierra donde se cierra. El giro de 2019 tiene **tres carreras**, y las tres tienen que quedar resueltas por la base, no por un `if`:

1. **La clave repetida.** El juego reintenta con la señal mala, y la misma `idempotencyKey` llega dos veces. Hoy da dos giros.
2. **El saldo.** Dos toques con un giro de saldo leen los dos `1`, y los dos giran.
3. **El stock.** El último premio de edición limitada lo leen varios giros a la vez, y todos lo ganan.

Y una cuarta, que no es del giro pero es del mismo tipo: **el caso del envío manual**, que `be03` chequea con un `count(*)` antes de anotar. El incidente 11 la mandó al backend, y esta fase la paga.

Hay algo que esta fase te va a pedir y que casi nunca se hace: **medir**. Bloqueo pesimista contra optimista, sobre la misma carga, con k6 (`bea-11`). No *"el optimista escala mejor"* porque lo dice un artículo: tus números, tu máquina, tu carga. Y vas a descubrir algo más incómodo que cualquier cifra: **el arnés que no reproduce la noche dice que el código roto está bien.**

> 🩻 **Antes de empezar, vuelve a leer la Fase 5 del track base y su incidente 11.** No es una sugerencia. El valor de lo que sigue está en el contraste: allá, la guarda de origen y el rollback hacen lo único que se puede hacer desde la consola; acá, la base hace lo que la consola no puede.

---

## ✅ 2. Qué queda listo al terminar

- [ ] Migración `000006`: `spin_log` con `UNIQUE (idempotency_key)` y un disparador que rechaza `UPDATE`, `DELETE` y `TRUNCATE` (D35); la tabla `spin_requests` para el estado del pedido; el sustituto de los premios de edición limitada; y `UNIQUE (player_id, case_id)` en `grants`.
- [ ] Girar es **una transacción**: reclamar la clave, descontar el saldo, sortear, descontar el stock y anotar el hecho ocurren juntos o no ocurren. La entrega en el juego va **fuera** de ella.
- [ ] La misma clave da **un solo giro**, y la segunda petición recibe el mismo resultado. El saldo nunca queda negativo. El stock nunca se excede: con stock en cero se entrega el sustituto publicado.
- [ ] Un pedido que quedó en proceso porque el proceso murió se cierra solo: lo encuentra la consulta del runbook y lo cierra el barrido.
- [ ] El envío manual reclama el caso **antes** de entregar, y el `409` de un caso repetido lo produce la base.
- [ ] Existen las pruebas de las tres carreras, con barrera, y pasan con `go test -race` contra Postgres en las dos estrategias.
- [ ] Existe `server/evidence/concurrencia.md` con la comparación **medida** con k6 entre el giro de 2019, el pesimista y el optimista, en las dos formas de carga.
- [ ] La transacción esperando quedó vista en `pg_stat_activity`, con la captura pegada en ese mismo archivo.
- [ ] Está anotado qué pasa con la misma carrera contra **SQLite**, y por qué eso condena a `be08`.
- [ ] `server/CONTRACT.md` dice lo que cambió en el giro y en el envío, y `./server/smoke.sh` pasa entero.
- [ ] `git diff pre-backend-go..HEAD -- . ':!server' ':!src/api/authService.js'` no devuelve nada: el frontend sigue sin tocarse.

---

## 🚫 3. Qué queda fuera por ahora

- **Reintentos en el cliente.** La consola no se toca, y el juego no es tuyo. Si una estrategia necesita que el cliente reintente distinto de como ya reintenta, esa estrategia no sirve acá, y esa restricción es lo que obliga a resolverlo bien.
- **La hora de cierre** → `be06`. Hoy se puede girar en una rueda pasada su `closesAt` y el backend no dice nada. Y el giro gratis cada cuatro horas, también.
- **Las compras y la protección de duplicados por inventario** → `be07`. Acá el giro descuenta saldo pago sin saber de qué compra salió (`purchaseToken` queda nulo), y el sustituto solo cubre el stock agotado, no el premio que el jugador ya tiene.
- **`go test -race` como suite y la regla del motor** → `be08`. Acá se **recoge la evidencia** de que SQLite no demuestra nada sobre concurrencia; convertirla en regla es la otra fase.
- **Colas, particionado y *sharding*.** Si tu solución para un stock de mil necesita infraestructura nueva, sobredimensionaste el problema.

---

## 🧠 4. Conceptos mínimos

Tienes años de SQL y de transacciones. Lo que sigue no explica qué es `BEGIN`: explica por qué el giro de `be03` está roto aunque parezca correcto, por qué envolverlo en una transacción no lo arregla, y qué opciones reales hay.

### 4.1 Las tres carreras, con precisión

Este es el giro de 2019, como lo dejó `be03`:

<<<fragmento:/Users/oskar/Developer/Learning/courses-ia-generated/zz-code/react-16-legacy-for-backend-devs-20261018-6436/trabajo/be05-extra/be04-spin.go|// NaiveSpin es el giro de 2019|	return GoldenSegment, nil
}>>>

Tres viajes a la base, y entre el primero y el segundo hay una ventana. En esa ventana cabe **otra ejecución completa**: dos giros leen `remaining = 1`, los dos deciden que hay, los dos descuentan, los dos ganan. Es un *check-then-act*: verificar una condición y actuar sobre ella en dos operaciones separadas. Es el mismo error conceptual que `if (!file.exists()) file.create()` en cualquier lenguaje, y la solución nunca es *"verificar mejor"*: es **hacer que la verificación y la acción sean una sola cosa indivisible**.

Pero las tres carreras no son iguales, y medirlas lo deja claro. Con el arnés de esta fase (5.7), contra este código:

- **La clave repetida no es una carrera.** A 50 giros por segundo —el ritmo del pico de 2025—, con cada clave enviada dos veces separada por 20 ms, salieron **500 claves con dos premios** sobre 1.500. No hace falta que las dos peticiones coincidan en el tiempo: nadie mira la clave. Es la ausencia de una regla, y la arregla cualquier cosa que la mire.
- **El stock sí es una carrera, y es tímida.** Con las mismas 3.000 peticiones a 50, 500 y hasta 1.000 por segundo **en llegadas parejas**, el stock quedó exacto en las tres corridas: cada petición dura medio milisegundo y casi nunca se solapa con otra. Con la forma de la noche de verdad —la notificación de las 7:00 llegando a todos a la vez, cada jugador girando apenas recibe la respuesta—, salieron **entre 1.030 y 1.032** Esclusas con 50 jugadores simultáneos y **entre 1.077 y 1.088** con 200, en tres corridas de cada una. Las 1.047 de la historia caen ahí en medio.

> 🧠 **Lo que hace peligroso a este bug es que no se reproduce cuando lo buscas.** Con dos pestañas y dos clics no pasa nunca. A 1.000 giros por segundo parejos, tampoco. Pasa la noche del evento grande, con la forma exacta de esa noche, y llega como un ticket que dice *"creo que entregamos de más, ¿puede ser?"*.

### 4.2 Por qué la transacción sola no alcanza

El primer instinto es envolver los tres viajes en `BEGIN … COMMIT` y darlo por resuelto. No lo resuelve, y entender por qué es el corazón de la fase.

PostgreSQL usa `READ COMMITTED` por defecto. En ese nivel, cada sentencia ve una foto de los datos confirmados **en el momento en que esa sentencia empieza**. Dos transacciones que hacen `SELECT remaining` ven las dos `1`, porque ninguna confirmó nada todavía. La transacción da atomicidad —o pasan todas las escrituras o ninguna— pero **no da exclusión mutua**. Medido con el incidente `be-09`, que es exactamente esto: una transacción sin bloqueo entregó **1.500 Esclusas de un stock de 1.000**, y el contador quedó en **874**. Las escrituras se pisaron entre ellas, y la evidencia se borró a sí misma.

Hay que sumar una de estas tres cosas:

**Bloqueo pesimista.** `SELECT … FOR UPDATE` toma un bloqueo sobre la fila. La segunda transacción que pida la misma fila **espera** hasta que la primera confirme o revierta; al despertar, ve el dato ya actualizado. Es explícito, predecible, y serializa el acceso a esa fila.

**Escritura condicional.** No se lee antes: se escribe con la condición en el `WHERE` —`UPDATE stock SET remaining = remaining - 1 WHERE id = $1 AND remaining > 0`— y se mira cuántas filas cambiaron. Si son cero, no había. La base evalúa la condición sobre el dato vigente, de forma atómica. En la literatura se le llama *optimista*; en Postgres, como vas a medir en `bea-05` §4, el perdedor **también espera** a que la fila que otro está escribiendo se confirme. Lo que se ahorra es la lectura previa, no la espera.

**Una restricción de la base.** Se diseña el esquema para que el estado imposible **no se pueda representar**. Un `UNIQUE` no se burla con ninguna combinación de tiempos: es la base la que se niega. Es la única de las tres que sigue protegiendo el día que alguien escriba un `INSERT` desde `psql`, desde un script de migración o desde el servicio nuevo que nadie te avisó que existía.

### 4.3 El problema de diseño que hay que resolver primero: hecho contra estado

Antes de escribir código conviene ver qué defensas están disponibles, porque no todas lo están para todo.

**La clave repetida admite la defensa más fuerte**, pero solo si el giro es una fila nueva. Hoy `spin_log` ya es eso —una fila por giro—, así que basta con declarar la clave única. **El saldo y el stock, en cambio, son contadores**: una fila que ya existe y se actualiza. Un `UNIQUE` no puede protegerlos, porque no hay segunda fila que rechazar: hay una misma fila que se actualiza dos veces, y actualizar dos veces no viola ninguna restricción. Para ellos quedan el bloqueo o la escritura condicional.

> 🧭 **Decisión de esta fase (`D28`): el giro se modela como un hecho, no como un estado.** Cada giro es una fila nueva en `spin_log`, con `UNIQUE (idempotency_key)`. El saldo y el stock siguen existiendo —el contrato y el tablero los necesitan—, pero cambian de naturaleza: pasan de ser **la verdad** a ser una **proyección** de la verdad, mantenida en la misma transacción. Si mañana hay duda sobre un saldo, se reconstruye desde la bitácora; al revés, no.

📖 **Un estado es un campo que se pisa. Un hecho es una fila que se agrega.** Los estados pierden historia y no se pueden restringir; los hechos se acumulan, se auditan y se protegen con índices. Cuando algo tiene consecuencias —dinero, inventario, un premio de edición limitada—, modélalo como hecho.

Y hay una consecuencia que `be07` te va a agradecer: la conciliación de probabilidades de la Fase 8 solo sirve si la bitácora es la que se escribió el día del giro. Por eso `D35` va un paso más allá del `UNIQUE`: **`spin_log` no se actualiza ni se borra**, y lo garantiza un disparador de la base, no la disciplina de quien escriba el próximo `UPDATE`.

Eso deja una pregunta abierta: si la bitácora no se actualiza, ¿dónde vive lo que sí cambia de estado durante un giro? En una tabla aparte, `spin_requests`, y la razón es el punto siguiente.

### 4.4 Entregar fuera de la transacción

Un giro no termina en la base: el premio se **entrega en el juego**, y eso, en producción, es una llamada de red. Una regla que vale para el resto de tu carrera: **una transacción nunca espera a la red**. Mientras esperas dos segundos a un servicio externo, tienes las filas del saldo y del stock bloqueadas, y cada giro de ese jugador —y del premio caliente— hace cola detrás.

Así que el giro se parte en dos: **decidir** —en una transacción, rápido, con todo lo que tiene que pasar junto— y **entregar** —fuera de ella—. Entre las dos cosas, el pedido está *en proceso*, y eso es un estado: va en `spin_requests`, con una fecha límite (`processing_until`). Si el proceso muere entre decidir y entregar, el hecho ya está en la bitácora; lo que falta es entregarlo. Dos mecanismos lo cierran:

- **La repetición de la misma clave**, pasada la fecha límite, devuelve lo que la bitácora dice que salió y lo entrega. **Nunca vuelve a sortear.**
- **Un barrido** periódico busca los pedidos vencidos, los entrega y los cierra, aunque el jugador nunca reintente.

📝 La entrega queda *al menos una vez*: si el proceso muere después de entregar y antes de cerrar el pedido, el barrido entrega de nuevo. El juego reconoce el giro por su clave y no lo acredita dos veces. Es el mismo trato que hace cualquier sistema de mensajería, y conviene decirlo en voz alta en vez de prometer *exactamente una vez*.

### 4.5 Niveles de aislamiento, sin misticismo

Tres niveles importan en Postgres, y la diferencia práctica es corta:

- **`READ COMMITTED`** (el de por defecto): cada sentencia ve lo confirmado al empezar *esa sentencia*. Permite el *check-then-act* de 4.1.
- **`REPEATABLE READ`**: toda la transacción ve la misma foto. No arregla lo nuestro; arregla que dos lecturas iguales devuelvan lo mismo.
- **`SERIALIZABLE`**: Postgres vigila los conflictos y **aborta** una de las transacciones con `40001` si el resultado no habría podido ocurrir en ningún orden secuencial (medido en `bea-05` §2).

`SERIALIZABLE` resuelve las tres carreras sin `FOR UPDATE`. Su precio es que **alguien tiene que reintentar**, porque una transacción abortada no es un error de negocio: es *"vuelve a intentarlo"*. El juego ya reintenta con la misma clave, así que reintentar sería seguro; pero el juego no es tuyo y no se toca, y un `40001` no puede llegarle como un error que el jugador vea. El reintento tendría que vivir en el servidor, con su límite y su espera. Vas a implementarlo en el ejercicio 29, para poder decir con números por qué no se eligió.

---

## 💻 5. Implementación y código comentado

### 5.1 La migración: el hecho, el pedido y el sustituto

<<<archivo:server/migrations/postgres/000006_spin_as_fact.up.sql>>>

La versión de SQLite (`migrations/sqlite/000006_spin_as_fact.up.sql`) dice lo mismo en su dialecto: un índice único en vez de `ADD CONSTRAINT`, y `RAISE(ABORT, …)` dentro de dos disparadores en vez de una función.

> ⚠️ **Antes de correrla en una base con historia, mira si hay claves repetidas.** El giro de 2019 las produjo a montones, y un `UNIQUE` no se puede crear sobre datos que ya lo violan:
>
> ```sql
> SELECT idempotency_key, count(*) FROM spin_log GROUP BY 1 HAVING count(*) > 1;
> ```
>
> Medido sobre una base donde corrió el arnés contra el giro de 2019: **509 claves repetidas**, y la migración se detiene en su primera línea con `ERROR: 23505: could not create unique index "spin_log_unique_key"` y `DETAIL: Key (idempotency_key)=(k6-89) is duplicated.`; `migrate version` queda en `6 (dirty)`. La migración falla entera —`golang-migrate` la deja marcada como sucia— y eso es lo que tiene que pasar: decidir qué hacer con la historia duplicada es una decisión de negocio, no algo que una migración resuelve en silencio. En la base sembrada desde el `db.json` no hay ninguna.

Dos detalles que no son de estilo. El sustituto (`D34`) es una columna nueva en `wheel_segments`, y el único que lo tiene es la Esclusa de Oro: `set-gemas-plata`. El mock nunca conoció los sustitutos y el `db.json` es del track base, que no se toca, así que los publica la siembra del backend (`publishedSubstitutes`, en `internal/seed`). Una versión nueva de los pesos lo hereda de la anterior, porque la consola no lo edita. Y `spin_requests.processing_until` admite `NULL` en la tabla, pero el código nunca lo escribe así: esa diferencia es el incidente `be-10`.

### 5.2 Dos piezas de `storage`: la transacción y la costura del bloqueo

<<<fragmento:server/internal/storage/storage.go|// WithTx corre fn dentro de una transacción|	return " FOR UPDATE"
}>>>

`WithTx` es el único lugar del backend donde se abre una transacción a mano, y su `defer tx.Rollback()` es lo que impide el error más caro de esta fase (§6, error 4). `ForUpdate` es la costura de `be02` aplicada al bloqueo: SQLite no tiene `FOR UPDATE`, y la pieza forense de esta fase mide qué pasa cuando no lo tiene.

Y la otra mitad de la costura, que traduce lo que la base contesta:

<<<archivo:server/internal/storage/errors.go>>>

### 5.3 El giro, en una transacción

El tipo `Service` cambia de forma: guarda el sorteo, la estrategia de bloqueo y los dos tiempos de la entrega. El punto de entrada es corto, y dice en su comentario las tres carreras y quién las resuelve:

<<<fragmento:server/internal/spin/service.go|// Spin es el giro de be05|	return r, nil
}>>>

`decide` es el corazón de la fase. Léelo despacio, en orden, porque **el orden es parte de la corrección**:

<<<fragmento:server/internal/spin/service.go|// decide hace todo lo que tiene que pasar junto|	return r, fresh, err
}>>>

> 🧠 **El paso 0 está ahí por un deadlock que apareció al medir.** La primera versión de este código reclamaba la clave primero y bloqueaba el saldo después. Contra la prueba de 50 giros con saldo de 1, **48 de las 50 peticiones** terminaron en `pq: deadlock detected`, y la de 1.500 giros contra el stock tuvo 7. El log de Postgres lo explicaba sin rodeos: dos procesos esperándose el uno al otro sobre `SELECT free_spins, paid_spins FROM players WHERE id = $1 FOR UPDATE`. El `INSERT` en `spin_requests` verifica la clave foránea a `players`, y para eso toma un bloqueo `FOR KEY SHARE` sobre la fila del jugador. Dos giros del mismo jugador lo toman los dos —es compartido— y después los dos piden `FOR UPDATE`, que choca con el `KEY SHARE` del otro. Ninguno puede avanzar. Se arregla de dos maneras, las dos medidas: bloquear el saldo **antes** de insertar (lo que hace el código, porque *"bloquear siempre en el mismo orden"* es una regla que sirve en cualquier motor), o pedir `FOR NO KEY UPDATE`, que no choca con `KEY SHARE`. Con cualquiera de las dos, cero deadlocks. Está reproducido con dos terminales en `bea-05` §7.

La repetición de una clave, que nunca vuelve a sortear:

<<<fragmento:server/internal/spin/service.go|// repeated responde una clave que ya existe|	return s.findResult(ctx, tx, key)
}>>>

El saldo, en las dos estrategias:

<<<fragmento:server/internal/spin/service.go|type balance struct|	return origin, nil
}

>>>

Y el stock, con el sustituto cuando no queda:

<<<fragmento:server/internal/spin/service.go|// takeStock descuenta una unidad|	return *landed.Substitute, nil
}>>>

> ⚠️ **Fíjate en lo que el stock agotado ya no hace.** El contrato de `be00` decía `409 agotado`. Ahora el giro responde `200`, con `landedSegment` en la Esclusa de Oro y `deliveredPrize` en el sustituto. Es un **cambio declarado** del contrato (5.8), y es el correcto: un `409` hace que el jugador vuelva a girar, y volver a girar hasta que no salga el premio agotado es **cambiar la probabilidad publicada** sin decirlo. La rueda siguió cayendo donde los pesos dicen; lo que cambió es qué se entrega. `409 agotado` queda solo para un segmento sin sustituto publicado.

### 5.4 El sorteo

<<<archivo:server/internal/spin/random.go>>>

`*rand.Rand` no es seguro entre goroutines, y con miles de giros a la vez el mutex no es opcional. Quítalo y corre `go test -race` sobre un sorteo concurrente: el detector lo marca en la primera vuelta, dentro de `math/rand.(*rngSource).Uint64()`, con una lectura y una escritura de dos goroutines sobre la misma dirección (`WARNING: DATA RACE`). Sin `-race`, el código *funciona*: sortea, y nadie ve nada.

### 5.5 Entregar fuera, y el barrido

<<<archivo:server/internal/spin/delivery.go>>>

Y en `main.go`, el barrido arranca con su propio contexto y muere en el apagado ordenado de `be01`:

<<<fragmento:server/cmd/api/main.go|	// be05: el giro, y el barrido|	log.Printf("giro: bloqueo %s, entrega %d ms, en proceso hasta %s", cfg.SpinLocking, cfg.SpinDeliveryMs, cfg.SpinProcessingTTL)>>>

Cuatro variables nuevas en `internal/config`: `SPIN_LOCKING` (`pessimistic` u `optimistic`, y el binario no arranca con otro valor), `SPIN_DELIVERY_MS` (`0` por defecto), `SPIN_PROCESSING_TTL` (`30s`) y `SPIN_SWEEP_EVERY` (`10s`).

Medido con el binario, con la entrega en 5 s y `kill -9` a los 2 s de empezar a entregar: el pedido queda en `processing` con su `processing_until`, la bitácora tiene la fila, y el saldo bajó de 5 a 4. Al reiniciar, la misma clave recibe `409 giro en proceso`. Treinta segundos después del giro, el pedido venció; el barrido lo encontró en su vuelta siguiente, ocho segundos más tarde, lo entregó y lo cerró (`[barrido] 1 giros en proceso vencidos, entregados y cerrados`), y la misma clave devolvió `200` con **el mismo premio** que había salido antes del corte.

### 5.6 El envío manual: reclamar antes de entregar

<<<fragmento:server/internal/player/player.go|	// be05: anotar PRIMERO, entregar DESPUÉS|	time.Sleep(s.delivery) // entregar en el juego, ya con el caso reclamado>>>

El orden importa tanto como el índice. `be03` comprobaba, **entregaba** y anotaba: con el `UNIQUE` y ese orden, la segunda petición del mismo caso fallaría al anotar… cuando el premio ya se entregó dos veces en el juego. Medido con tres envíos del mismo caso a la vez y la demora de entrega de 800 ms: uno responde `201` a los 0,81 s, y los otros dos responden `409` a los 0,005 s, sin haber entregado nada.

### 5.7 La medición: k6 contra los tres giros

Implementar las dos estrategias y medirlas es el trabajo que hace valiosa la fase. Los números dependen de la máquina, de la forma de la carga y de cuánto dura la transacción: no copies conclusiones de un artículo. Si nunca usaste k6, `bea-11` tiene lo mínimo para correr y leer este arnés.

El arnés vive en `server/load/`. La rueda de medición hace que **todos** los giros caigan en la fila caliente:

<<<archivo:server/load/rueda-de-medicion.sql>>>

El script, con sus dos formas de carga:

<<<archivo:server/load/giro.js>>>

Y lo que se cuenta después, en SQL, porque las respuestas HTTP no dicen cuántas Esclusas salieron:

<<<archivo:server/load/medicion.sql>>>

La corrida, desde una base recién migrada y sembrada con la rueda de medición (el giro de 2019 corre sobre el esquema de `be04`, sin el `UNIQUE`: con él, la clave repetida saldría protegida por accidente):

```bash
docker run --rm -i --network <red-del-backend> -e BASE_URL=http://api:3001 \
  -e SCENARIO=notificacion -e VUS=200 grafana/k6:1.5.0 run - < server/load/giro.js
psql "$DATABASE_URL" < server/load/medicion.sql
```

| Carga | Giro | Esclusas entregadas | Claves con dos giros | Stock final | p95 del giro |
|---|---|---|---|---|---|
| `pico`, 50 por segundo | 2019 | 1.000 | 500 | 0 | 5,78 ms |
| `pico`, 50 por segundo | Pesimista | 1.000 (+ 500 sustitutos) | 0 | 0 | 7,67 ms |
| `pico`, 50 por segundo | Condicional | 1.000 (+ 500 sustitutos) | 0 | 0 | 8,46 ms |
| `notificacion`, 50 jugadores | 2019 | 1.030 a 1.032 | 510 a 514 | −30 a −32 | 56 a 62 ms |
| `notificacion`, 50 jugadores | Pesimista | 1.000 (+ 500 sustitutos) | 0 | 0 | 75 a 107 ms |
| `notificacion`, 50 jugadores | Condicional | 1.000 (+ 500 sustitutos) | 0 | 0 | 68 a 108 ms |
| `notificacion`, 200 jugadores | 2019 | 1.077 a 1.088 | 522 a 525 | −77 a −88 | 192 a 281 ms |
| `notificacion`, 200 jugadores | Pesimista | 1.000 (+ 500 sustitutos) | 0 | 0 | 333 a 509 ms |
| `notificacion`, 200 jugadores | Condicional | 1.000 (+ 500 sustitutos) | 0 | 0 | 266 a 375 ms |

*Corridas del 19/10/2026: tres por fila en `notificacion` (el rango va de la menor a la mayor) y una en `pico`. 3.000 peticiones por corrida, 1.500 claves enviadas dos veces, stock de 1.000. Postgres 13.23, Go 1.19.13 y `grafana/k6:1.5.0` en contenedores de la misma red, en un portátil arm64. Con `pico` a 500 y 1.000 por segundo, el giro de 2019 dio lo mismo que a 50: stock exacto y 500 claves dobles.*

Lo que dicen estas cifras, en orden de importancia:

1. **Los dos giros de esta fase cumplen las tres invariantes en todas las corridas**: 1.500 giros anotados, 1.000 Esclusas, 500 sustitutos, ninguna clave con dos giros, stock en cero, ningún saldo negativo. El de 2019 no cumple ninguna con la notificación, y la de la clave repetida no la cumple ni a 50 por segundo.
2. **Los `409` de los giros de esta fase son reintentos que llegaron mientras su giro estaba en proceso**, no fallos: los 1.500 giros quedaron anotados en todas las corridas, así que ningún primer intento se perdió. A 50 por segundo, el reintento llega cuando el primero ya terminó y recibe la repetición con `200`.
3. **El pesimista paga su espera, y no tanto como dicen.** Con 50 jugadores a la vez los rangos de las dos estrategias se pisan (75 a 107 ms contra 68 a 108): con tres corridas no hay diferencia que defender. Con 200, la escritura condicional quedó más baja en las tres corridas, con rangos que casi se tocan (266 a 375 ms contra 333 a 509). Y el giro de 2019 es el más rápido de todos, porque hace menos: no espera a nadie, y por eso entrega de más.

> 🧭 **El criterio, que vale más que los números.** El pesimista brilla cuando la colisión es **probable** y el trabajo perdido sería caro; la escritura condicional, cuando la colisión es **rara** y el trabajo perdido es barato. En Postgres la diferencia es menor de lo que dicen los artículos, porque el `UPDATE` condicional también espera la fila. Para el giro —donde la Esclusa de Oro es la fila caliente una noche al año, y el resto del tiempo nadie colisiona—, las dos sirven.
>
> Y aun así esta fase se queda con el pesimista como camino principal (`D28`), por una razón que no es de rendimiento: **el `FOR UPDATE` se puede ver**, en la base y en el código. En `pg_stat_activity` (§6) se ve esperar —la escritura condicional también, medido en `bea-05` §6—, y en el código está escrito **antes** de la decisión que protege: cualquiera que lea `decide` sabe qué fila está tomada mientras se elige el premio. Cuando tengas la intuición construida, el ejercicio 22 te pide que elijas de verdad, con tus números.

Las pruebas de las tres carreras están en `server/internal/spin/race_test.go`. La barrera es lo que hace que la carrera ocurra:

<<<fragmento:server/internal/spin/race_test.go|// race suelta n goroutines a la vez|	return errs
}>>>

Y la del stock, en las dos estrategias:

<<<fragmento:server/internal/spin/race_test.go|// Carrera 3: mil quinientos giros|	}
}>>>

```bash
TEST_DATABASE_URL="postgres://esclusa:esclusa@localhost:5432/esclusa_test?sslmode=disable" \
  go test -count=1 -race -v ./internal/spin/
```

Las cinco pasan en las dos estrategias: la misma clave da una fila y deja el saldo en 99; con saldo de 1, una pasa y 49 reciben `sin giros`; 1.500 giros contra 1.000 de stock dan 1.000 Esclusas, 500 sustitutos y stock en 0; y la bitácora rechaza el `UPDATE` y el `DELETE` (`pq: spin_log solo se agrega: UPDATE rechazado`). Contra la rama de `be-09` la del stock falla con *"entregadas 1500, sustitutos 0, stock 919"*: **una prueba de concurrencia que pasa contra el código vulnerable no es una prueba.**

### 5.8 El contrato cambió: actualízalo

Como en `be04`, lo observable cambió y `server/CONTRACT.md` lo dice en la misma fase:

<<<fragmento:server/CONTRACT.md|Cambios de be05 en el giro|antes** de entregar en el juego.>>>

Y `smoke.sh` suma una verificación —*"un giro sin saldo devuelve 409 y no deja fila"*—, con lo que pasa de 18 a 19. La consola no se enteró de nada: el recorrido completo de Cypress de `be03` y la prueba de humo de la Fase 10 pasan igual contra este binario en el `3001`, y el `git diff` del checklist sale vacío.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. Envolver en una transacción y darlo por resuelto.** Síntoma: el bug sigue, y con la carga pareja ni siquiera se ve. Causa: `READ COMMITTED` no da exclusión mutua (4.2). Fix: `FOR UPDATE`, la escritura condicional o `SERIALIZABLE`. Es el error más común de esta fase y el más peligroso, porque **parece** arreglado: el incidente `be-09` es exactamente esto, y a 50 giros por segundo da cifras perfectas.

**2. `FOR UPDATE` sobre la consulta equivocada, o tarde.** Síntoma: no protege. Causa: bloquear la rueda en vez del stock, o leer el stock y bloquearlo después. Fix: el bloqueo va sobre **la fila que se va a modificar** y **antes** de decidir. Regla: si entre el `FOR UPDATE` y el `UPDATE` hay una decisión basada en una lectura anterior, el bloqueo llegó tarde.

**3. El deadlock que trae la clave foránea.** Síntoma: `pq: deadlock detected` intermitente, solo con giros del mismo jugador a la vez. Causa: el `INSERT` en una tabla hija toma `FOR KEY SHARE` sobre la fila padre, y un `FOR UPDATE` posterior sobre esa fila choca con el `KEY SHARE` de otra transacción (5.3). Fix: bloquear el padre **antes** de insertar en la hija, o `FOR NO KEY UPDATE` si no vas a tocar la clave. Medido: 48 de 50 deadlocks en la carrera del saldo, cero con cualquiera de los dos arreglos. Postgres detecta el deadlock y mata a una de las dos al cabo de `deadlock_timeout` (un segundo): el síntoma es un error, no un cuelgue, pero esa prueba tardó 43 segundos en vez de 0,3.

**4. Transacciones que nadie cierra.** Síntoma: el pool se agota, todo se cuelga, y `pg_stat_activity` se llena de `idle in transaction`. Causa: un `return` de error que se saltó el `Commit` y el `Rollback`. Fix: `WithTx` con `defer tx.Rollback()`. **Nunca** manejes transacciones a mano en un handler.

**5. Una petición de red dentro de la transacción.** Síntoma: el giro funciona perfecto y el sistema entero se arrastra cuando el juego tarda en responder. Causa: entregar el premio con las filas del saldo y del stock bloqueadas. Fix: decidir dentro, entregar fuera, y un estado intermedio que alguien cierra (4.4).

**6. Medir con la forma equivocada.** Síntoma: el arnés dice que el giro de 2019 está bien. Causa: llegadas parejas (`constant-arrival-rate`) donde la noche real fue una avalancha; o una prueba de Go sin barrera, que lanza las goroutines escalonadas. Fix: la barrera del `WaitGroup` en las pruebas, y el escenario `notificacion` en k6. Medido: a 1.000 giros por segundo parejos, el giro de 2019 entregó **exactamente** 1.000 Esclusas; con 50 jugadores a la vez, entre 1.030 y 1.032.

**7. Un `*rand.Rand` compartido sin mutex.** Síntoma: ninguno visible; el sorteo devuelve números. Causa: `rand.New` no es seguro entre goroutines. Fix: el mutex de 5.4, y `go test -race` en la suite, que lo marca en la primera corrida.

**8. `migrate drop` y las funciones.** Síntoma: después de recrear la base con `migrate drop -f`, la `000006` falla con `pq: function "spin_log_append_only" already exists with same argument types` y queda sucia. Causa: `drop` borra las tablas del esquema, no sus funciones. Fix: `CREATE OR REPLACE FUNCTION` en la migración, que es como está escrita.

### 🩻 Pieza forense de esta fase

**Ver el bloqueo, no imaginarlo.** Es la pieza forense más visual del track y la que más vale la pena hacer despacio.

*Paso 1 — reproduce el bug con el giro de 2019.* Con el binario de `be04` en el `3001`, el stock de la Esclusa en 1.000 y la base sin el `UNIQUE`, corre el escenario `notificacion` con 50 usuarios virtuales y cuenta con `medicion.sql`. Cuando veas **más de mil**, tienes el bug reproducido a voluntad, que es la mitad del trabajo de cualquier diagnóstico. Después repite con el escenario `pico` a 1.000 por segundo y mira cómo desaparece: ese contraste es la lección del error 6.

*Paso 2 — mira el bloqueo en vivo, con la API de verdad.* Levanta el binario de esta fase con `SPIN_DELIVERY_MS=2000`, siembra la rueda de medición, y abre una terminal de `psql` que retenga el stock tres segundos:

```sql
BEGIN;
SELECT remaining FROM stock WHERE wheel_id = 900 FOR UPDATE;
SELECT pg_sleep(3);
COMMIT;
```

Durante esos tres segundos, gira con `curl` desde otra terminal, y medio segundo después repite **la misma clave**, como el juego con la señal mala:

```bash
curl -s -D - -X POST -d '{"idempotencyKey":"forense-1"}' localhost:3001/players/10001/spins
```

Los dos `curl` **se quedan colgados**. No fallaron ni devolvieron un dato viejo: están esperando. En una tercera terminal:

```sql
SELECT pid, state, wait_event_type, wait_event,
       left(regexp_replace(query, '\s+', ' ', 'g'), 60) AS consulta
FROM pg_stat_activity
WHERE datname = 'esclusa' AND state <> 'idle' AND pid <> pg_backend_pid()
ORDER BY xact_start;
```

```
 pid  | state  | wait_event_type |  wait_event   |                           consulta
------+--------+-----------------+---------------+--------------------------------------------------------------
 4950 | active | Timeout         | PgSleep       | SELECT pg_sleep(3);
 4943 | active | Lock            | transactionid |  SELECT remaining FROM stock WHERE id = $1 FOR UPDATE
 4951 | active | Lock            | transactionid |  SELECT free_spins, paid_spins FROM players WHERE id = $1 FO
```

Ahí están: el `SELECT … FOR UPDATE` del stock del primer giro y el del saldo del reintento, los dos con `wait_event_type = 'Lock'` y `wait_event = 'transactionid'`. **Eso son dos giros bloqueados, en pantalla.** Y la consulta que de verdad vas a usar a las tres de la mañana:

```sql
SELECT blocked.pid AS bloqueado, blocking.pid AS bloqueante,
       left(regexp_replace(blocked.query, '\s+', ' ', 'g'), 45) AS espera,
       left(regexp_replace(blocking.query, '\s+', ' ', 'g'), 45) AS culpable
FROM pg_stat_activity blocked
JOIN pg_stat_activity blocking ON blocking.pid = ANY(pg_blocking_pids(blocked.pid));
```

```
 bloqueado | bloqueante |                    espera                     |                   culpable
-----------+------------+-----------------------------------------------+-----------------------------------------------
      4943 |       4950 |  SELECT remaining FROM stock WHERE id = $1 FO | SELECT pg_sleep(3);
      4951 |       4943 |  SELECT free_spins, paid_spins FROM players W |  SELECT remaining FROM stock WHERE id = $1 FO
```

Una cadena: la terminal de `psql` bloquea al primer giro en el stock, y el primer giro bloquea al reintento en el saldo, por el paso 0 de `decide`. Guarda esta consulta: es de las tres o cuatro que conviene tener a mano para siempre. Cuando la primera terminal confirma, el primer giro sigue, entrega y responde `200` (3,92 s en la corrida del autor: la espera más los dos segundos de la entrega); el reintento obtiene el saldo, encuentra su clave en proceso y responde `409 giro en proceso` (1,38 s). Pega las dos salidas en `server/evidence/concurrencia.md`.

*Paso 3 — el remate, y lo que condena a `be08`.* Corre la carrera del stock contra SQLite, primero con el código de esta fase y después con el de la rama `incidente/be-09`, que no bloquea. La costura de 5.2 omite el `FOR UPDATE`, el pool de SQLite tiene una sola conexión (`be02`), y las dos dan lo mismo: **1.000 entregadas y stock en 0, en verde**. Contra Postgres, la rama de `be-09` entrega 1.500. Anótalo bien, porque es la evidencia entera de `be08`: SQLite serializa todo el acceso a la base por diseño, así que **una suite verde contra SQLite no dice nada sobre la concurrencia de este código**. No la demuestra ni la desmiente.

*El círculo, con concurrencia.* Toma el `X-Request-Id` de un reintento que recibió `409 giro en proceso`, búscalo en el log del backend, y ahí encuentra su línea, con el tiempo que tardó. En la corrida del autor, el reintento traía `X-Request-Id: 8cfd75d1c5f3c7d9`, y el log decía `[req-id 8cfd75d1c5f3c7d9] POST /players/10001/spins → 409 (28 bytes) en 1.37561s`: esperó más de un segundo, en la fila de un giro que ya estaba en curso, para enterarse de que su giro era ese. En `be00` ese id no llegaba a ninguna parte; ahora te dice qué le pasó a un toque concreto de un jugador concreto.

---

> 📓🔥 De esta fase salen los incidentes **be-09** ⭐, **be-10** y **be-17** de `cuaderno-incidentes-be.md`. El be-09 es el hermano del ⭐ **11** del track base y el cruce más formativo del curso: allá la carrera vive en el store y en un chequeo en dos pasos; acá vive dentro de una transacción que parece protegerla.

---

## 🧪 7. Ejercicios (33)

**🟢 Fácil (1–8)**

1. Aplica la migración `000006` y comprueba en `psql` que `spin_log` tiene `spin_log_unique_key`, que existen los dos disparadores y la tabla `spin_requests`, y que `grants` tiene `grants_unique_case`.
2. Intenta un `UPDATE` y un `DELETE` sobre `spin_log` desde `psql` y copia los dos mensajes de error. Después intenta un `TRUNCATE`.
3. Dale cinco giros gratis a un jugador y gira con `curl`. Comprueba en `spin_log` la fila con `origin = 'free'`, y que el saldo bajó a cuatro.
4. Repite la misma clave con `curl` y comprueba que la respuesta es idéntica y que la bitácora sigue teniendo una sola fila.
5. Gira con un jugador sin saldo y comprueba el `409 sin giros`. Después con un jugador que no existe: `404`.
6. Manda dos veces el mismo caso desde la consola, con el asistente de envíos, y comprueba que el segundo recibe el `409` del contrato.
7. Corre `./server/smoke.sh` y confirma las 19 verificaciones en verde.
8. Ejecuta el paso 2 de la pieza forense y pega la salida de `pg_stat_activity`.

**🟡 Intermedio (9–19)**

9. Corre `race_test.go` con `-race` contra Postgres y anota las cifras que imprime cada prueba en cada estrategia.
10. **Diagnóstico.** Corre la prueba del stock contra la rama `incidente/be-09` y comprueba que falla. Si pasa, tu prueba está mal: encuentra por qué.
11. **Diagnóstico.** Quita la barrera de la prueba del stock y determina cuántas corridas hacen falta para que la rama de `be-09` falle. Explica qué te dice ese número sobre las pruebas de concurrencia en general.
12. Corre el arnés con `SPIN_LOCKING=optimistic` y comprueba que las invariantes de `medicion.sql` son las mismas.
13. Mide las dos estrategias con 2, 10 y 50 usuarios virtuales en el escenario `notificacion` y llena la tabla de 5.7 con tus cifras.
14. **Diagnóstico.** Con el pesimista y 200 usuarios virtuales, mira `pg_stat_activity` durante la corrida y anota cuántos backends esperan `Lock` en el peor momento.
15. Pon `SPIN_DELIVERY_MS=3000`, gira, mata el proceso durante la entrega y reinicia. Mide cuánto tarda la misma clave en devolver `200`, y explica de qué dos variables depende ese tiempo.
16. **Diagnóstico.** Con la misma preparación, detén el barrido (comenta su arranque) y determina qué pasa con un jugador que no reintenta nunca. Explica por qué la comprobación de `expired` en `repeated` hace falta además del barrido, y por qué el barrido hace falta además de ella.
17. Verifica que `Ctrl+C` detiene el barrido antes de que el proceso muera, y que el log lo dice.
18. **Diagnóstico.** Deja un `BEGIN` con un `SELECT … FOR UPDATE` sobre el stock sin `COMMIT` desde `psql` y observa el efecto sobre los giros. Encuéntralo con `pg_stat_activity` y termínalo con `pg_terminate_backend`.
19. Escribe en `server/evidence/concurrencia.md` la consulta de bloqueos del paso 2, con una explicación de cada columna.

**🟠 Difícil (20–29)**

20. **Diagnóstico.** Ejecuta el paso 3 de la pieza forense completo y escribe el informe que `be08` va a citar. Distingue con precisión entre "no existe `FOR UPDATE`" y "la base serializa todo".
21. Reproduce el deadlock de 5.3: invierte los pasos 0 y 1 de `decide`, corre la carrera del saldo y captura el mensaje de Postgres. Arréglalo de las dos maneras y mide las dos.
22. **Decide.** Con tus mediciones, elige la estrategia definitiva del backend y defiéndela por escrito en `concurrencia.md`. Tiene que citar tus números, no un artículo.
23. **Diagnóstico.** Mete la entrega **dentro** de la transacción, con `SPIN_DELIVERY_MS=200`. Corre el escenario `notificacion` con 50 usuarios virtuales y compara el p95 con el de 5.7. Explica por qué "nunca una petición de red dentro de una transacción" es una regla y no una preferencia.
24. Haz que el `409 giro en proceso` deje en el log (no en la respuesta) el `X-Request-Id` de la petición que está en curso con esa clave. Argumenta por qué esa información no puede ir en la respuesta.
25. **Diagnóstico.** Las mediciones con 300 jugadores no dicen nada sobre el saldo, porque cada uno gira cinco veces y rara vez dos a la vez. Genera diez mil jugadores con el generador de `bea-10`, apunta el arnés a ellos y repite el ejercicio 13. Compara y explica.
26. Implementa un `pg_try_advisory_lock` que evite que el barrido corra en dos réplicas a la vez, y demuestra que funciona levantando dos procesos.
27. **Diagnóstico.** ¿Qué pasa si el jugador corta la conexión justo después del `INSERT` en `spin_log` y antes del `COMMIT`? Averígualo, mira el estado de la base, y explica el papel de `r.Context()` en el resultado.
28. Diseña la prueba que detectaría una regresión el día que alguien quite el `FOR UPDATE` del saldo "porque estaba de más". Que falle de forma inequívoca y rápida.
29. Implementa la variante `SERIALIZABLE` con reintento **del lado del servidor**, mídela contra las otras dos con el arnés, y explica con precisión por qué el reintento tiene que estar acá y no en el juego.

**🔴 Muy difícil (30–33)**

30. **El contraste, que es el corazón de la fase.** Escribe un documento comparando cómo aborda la Fase 5 del track base el envío doble y cómo lo aborda esta: qué garantiza cada capa, qué puede y qué no puede prometer la consola, y qué pasaría si el backend estuviera arreglado y la consola no —y al revés—. Sé concreto sobre lo que Yariela ve en cada combinación.
31. Argumenta si `players.free_spins` y `paid_spins` deberían existir ahora que la bitácora es la verdad. Escribe la consulta que reconstruye un saldo desde `spin_log` y las compras, mide su costo con la Semana del Canal sembrada (180.000 giros), y decide.
32. **Diagnóstico + regresión.** Ticket: *"en la Semana del Canal entregamos 1.012 Esclusas, pero el panel de stock dice que quedan 31"*. Explica por qué la combinación de las dos cifras es una pista y no ruido, reconstruye la causa y escribe la prueba de regresión que la habría atrapado.
33. **Post-mortem.** Escribe el post-mortem de la noche de la Esclusa de Oro según los ocho puntos del post-mortem de `cuaderno-incidentes.md`. La sección de prevención tiene que distinguir tres niveles —la restricción o el bloqueo de la base, la prueba de concurrencia con barrera y el arnés con la forma de la noche— y explicar por qué hacen falta los tres.

**🔥 Opcionales**

- 🔥 Implementa *"dame cualquier premio de edición limitada disponible"* con `SELECT … FOR UPDATE SKIP LOCKED` sobre varias filas de stock. Explica por qué ahí `SKIP LOCKED` es exactamente lo correcto, y por qué en el giro —que cae en un segmento concreto— sería un desastre silencioso.
- 🔥 Mide el costo del `UNIQUE (idempotency_key)` en la escritura: inserta cien mil giros con y sin la restricción y compara. Después decide si el costo cambia algo.
- 🔥 Reproduce la carrera del envío desde dos consolas en dos navegadores, con el caos en `high` para ensanchar la ventana, contra el binario de `be04` y contra el de esta fase. Compara lo que ve Yariela en cada caso.

---

## 📚 8. Referencias

**Documentación oficial**
- https://www.postgresql.org/docs/13/transaction-iso.html — niveles de aislamiento, con los ejemplos de anomalías. Es la referencia central de la fase.
- https://www.postgresql.org/docs/13/explicit-locking.html — `FOR UPDATE`, `FOR NO KEY UPDATE`, `FOR KEY SHARE` y la tabla de conflictos entre modos de bloqueo de fila: el deadlock de 5.3 está escrito en esa tabla.
- https://www.postgresql.org/docs/13/sql-insert.html#SQL-ON-CONFLICT — la cláusula con la que se reclama la clave.
- https://www.postgresql.org/docs/13/plpgsql-trigger.html — los disparadores de `D35`, incluido el de `TRUNCATE`.
- https://www.postgresql.org/docs/13/monitoring-stats.html — `pg_stat_activity` y `pg_blocking_pids`, la pieza forense.
- https://www.postgresql.org/docs/13/errcodes-appendix.html — los SQLSTATE: `23505`, `23503`, `40001` y `40P01` son los de hoy.
- https://www.sqlite.org/lockingv3.html y https://www.sqlite.org/rescode.html#busy — por qué SQLite no puede con esto.
- https://pkg.go.dev/database/sql#Tx — el manejo de transacciones en Go, y por qué el `defer Rollback` es idiomático.
- https://pkg.go.dev/math/rand#Rand — la frase *"not safe for concurrent use"*, que justifica el mutex de 5.4.
- https://go.dev/doc/articles/race_detector — `-race`: qué detecta, qué no, y cuánto cuesta.
- https://grafana.com/docs/k6/latest/using-k6/scenarios/executors/ — `constant-arrival-rate` y `shared-iterations`. La página es de la versión vigente: cambia `latest` por la `v1.5.x` antes de creerle.

**Libros**
- *Designing Data-Intensive Applications* (Martin Kleppmann) — el capítulo 7 es, sin competencia, el mejor texto sobre esto. Su tratamiento del *write skew* y de las anomalías de serialización cubre exactamente lo que esta fase hace con las manos. El capítulo 11 tiene la entrega *al menos una vez* de 4.4.
- *PostgreSQL 14 Internals* (Egor Rogov) — los modos de bloqueo de fila, por dentro. Disponible libremente en PDF; verifica la versión.

**Video / apoyo**
- Busca "PostgreSQL SELECT FOR UPDATE explained" y "idempotency keys API design" en YouTube. Verifica que los ejemplos de bloqueo sean de Postgres: la semántica de MySQL es distinta y mezclarlas confunde más que ayuda.

**Orden de lectura sugerido:** `transaction-iso.html` §13.2 primero, que explica por qué `READ COMMITTED` permite el bug → `explicit-locking.html` §13.3.2, con la tabla de conflictos a la vista → la pieza forense con las tres terminales → `bea-05` para el panorama completo de concurrencia en Postgres → `bea-11` antes de tocar el arnés.

> ⚠️ URLs, títulos y ediciones pueden haber cambiado: verifícalos. Las referencias a libros son de memoria y pueden ser inexactas. La documentación de Postgres tiene una versión por URL; fija el 13. Las cifras de k6 de esta fase son de las corridas del 19/10/2026 en la máquina del autor: las tuyas van a ser otras, y lo que tiene que coincidir son las invariantes. Cualquier discrepancia de versiones la resuelve `00-decisiones-y-versiones.md` §7.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Ya no se pueden entregar 1.047 Esclusas de Oro de un stock de mil, y sabes exactamente por qué: no porque el código lo verifique mejor, sino porque **la base no puede representar el estado imposible**, o porque la fila caliente se bloquea antes de decidir. La misma clave da un solo giro, el saldo nunca es negativo, el stock agotado entrega su sustituto sin tocar la probabilidad publicada, y la bitácora es la que se escribió el día del giro. Tienes una prueba que falla contra el código vulnerable, un arnés que reproduce la forma de la noche, y —lo que más va a durar— la evidencia medida de dos estrategias y el criterio para elegir entre ellas.

Y tienes la respuesta a la pregunta que abría la fase. La consola de la Fase 5 no estaba mal escrita: estaba haciendo lo único que se puede hacer desde ahí, que es mejorar la experiencia mientras el servidor decide. La guarda de origen y el rollback siguen valiendo —hacen que la interfaz responda bien— y ahora tienen detrás algo que de verdad protege.

`be06` mueve la segunda autoridad al servidor: **el reloj**. Hoy la hora de cierre la evalúa la consola contra un campo de texto, y el giro gratis cada cuatro horas todavía no existe. Un reloj de cliente es un reloj que el jugador controla, y en la Esclusa de Oro hay jugadores en Panamá, que no cambia de hora, y en Chile y Paraguay, que sí.

> **La señal de que quedó bien:** *"puedo explicar, sin hablar de mi código, por qué es imposible entregar una Esclusa de más, y puedo mostrar el giro esperando su turno en `pg_stat_activity`."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-be05-giro-concurrente -m "be05 cerrada: \
> migración 000006 (UNIQUE de la clave, bitácora de solo inserción, spin_requests, \
> sustituto, UNIQUE del caso del envío); giro en una transacción con FOR UPDATE \
> y variante condicional; entrega fuera de la transacción con barrido; \
> envío que reclama el caso antes de entregar; carreras con -race; \
> arnés de k6 en server/load y comparación medida en server/evidence/concurrencia.md; \
> bloqueo observado en pg_stat_activity; evidencia de SQLite para be08"
> ```
>
> Los commits de la fase llevan su prefijo (`be05: …`) y los de ejercicio su número (`be05 ej30: …`). Si un ejercicio merece su propio marcador va en `ej/be05/30`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` / `-fix`, con el ID que le reserva `cuaderno-incidentes-be.md`. Todo eso está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

*(Fuera de lo que lee el estudiante.)*

- **`D28` se cumple con el giro como hecho en `spin_log`** y el estado del pedido en `spin_requests`; **`D35`, con el disparador**; **`D34`, a medias**: el sustituto por stock agotado nace acá, y el del premio repetido es de `be07`.
- **`D37` se cumple sin explicarse**: el sorteo usa una fuente propia sembrada desde `crypto/rand`, y el texto no dice por qué. La prueba de dos arranques **no** está en la fase: es la regresión de `be-17` (DR-02).
- **El cambio de contrato del stock agotado** (`409` → `200` con sustituto) tiene que constar en `bea-09` como deuda cobrada, y en el veredicto de `be09`.
- **`players.free_spins` y `paid_spins` pasaron de verdad a proyección.** `be07` los acredita con las compras en la misma transacción; cualquier consulta de negocio sobre giros va contra `spin_log`.
- **`be06` hereda dos cosas:** el giro ya es transaccional, así que la comprobación del cierre por reloj es una línea dentro de `decide`; y el barrido es el precedente del trabajo que va a cerrar ruedas por reloj.
- **`be07` hereda `spin_log` inmutable**, `WithTx` y `purchaseToken` nulo en los giros pagos: el prorrateo por compra lo tiene que llenar el giro desde allá.
- **`be08` hereda dos entregables directos:** `race_test.go` (que ya falla contra el código vulnerable, que es la propiedad que lo hace válido) y el informe de SQLite del paso 3. Que no los reescriba desde cero. Y el arnés de k6 como nivel de carga.
- **Deudas declaradas:** 💸 el barrido corre en todas las réplicas (ejercicio 26; `be09` decide si hace falta); 💸 el giro del juego sigue sin autenticación (`bea-08`); 💸 la rueda activa se elige como la `live` que cierra primero, porque el juego no manda la rueda.
- **Reserva para el cuaderno de incidentes:** `be-09` ⭐ — *el stock de la Esclusa sin `FOR UPDATE`* (🔥 concurrencia, 🔴, hermano del 11); `be-10` — *el giro en proceso para siempre* (🔥 concurrencia, 🟡); y `be-17` — *la rueda da los mismos premios después de cada reinicio* (🔥 aleatorio, 🟠), que esta fase reserva sin contar.
