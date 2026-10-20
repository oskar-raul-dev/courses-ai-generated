# 💰 Fase be07 — Compras y conciliación

> Tutorial React 16 — La Esclusa, la consola de Jewel Locks · **Track BE opcional 🔥** · Fase be07 de be09 · **6 horas**
> Depende de: be06 — el reloj ya lo decide el servidor · Habilita: be08 — Pruebas y la regla del motor

---

## 🎯 1. Propósito

*"Si Google avisa dos veces, ¿le damos los giros dos veces?"* La pregunta es de Marisol, y es la pregunta correcta. Los giros pagos se venden por Google Play —10 por US$0,99 y 500 por US$20,99 (historia §8)—, y una compra le llega al backend por dos caminos: el juego, que avisa al terminar el pago, y la notificación de la tienda, que puede llegar antes, después o dos veces. Un pago en efectivo en Efecty o en OXXO tarda de minutos a 48 horas en confirmarse (historia §8): hasta entonces, no hay nada que acreditar.

Hoy el backend no acredita compras. `be02` dejó la tabla `purchases` **sin** `UNIQUE` sobre el token, a propósito: la conciliación de la Fase 8 encontró una compra acreditada dos veces (`tok-ago-17`), y ese es el dato que hay. Y la conciliación, que Marisol hace en la consola, el servidor la guarda **tal como llega** (`be00`, C-07): con los números que la consola tenía cargados cuando alguien apretó el botón.

Esta fase cierra el dominio con tres piezas:

1. **La compra, una vez.** Giros y compra en una transacción, idempotente por `purchaseToken`: el juego, la notificación y sus repeticiones responden lo mismo y acreditan una sola vez.
2. **La conciliación, en el servidor.** Los conteos de la bitácora en SQL (`GROUP BY wheel_version, landed_segment`), `oddsAudit` y el cruce de compras de la Fase 8 portados a Go sin cambiarles una regla, y el reporte de la tienda pedido al `3002`. Itzel quiere contestar la reseña de *"la rueda está arreglada"* con un número que no haya calculado su navegador.
3. **La protección de duplicados.** La rueda que se acomoda (historia §5) se reemplaza por la que el incidente 21 del cuaderno base recomendó: la rueda gira con los pesos publicados, y si cae en un avatar que el jugador ya tiene, se entrega el sustituto.

> 🧭 **El dinero no se valida: se recalcula.** Un total que llega por la red es una **afirmación del cliente**, igual que la identidad en `be04` y la hora en `be06`. Es la tercera vez que el track dice lo mismo, y ya se puede nombrar: **el cliente propone, el servidor dispone, y la diferencia se mide.**

> 🩻 **Lectura previa obligatoria:** la Fase 8 del track base (`oddsAudit.js` y `reconciliationMath.js`), el apéndice `A14` y el incidente 21 del cuaderno base. Las reglas y los nombres salen de ahí y **no se reinventan**.

---

## ✅ 2. Qué queda listo al terminar

- [ ] Migración `000008`: `purchases.player_id`; `purchases.duplicate_of` marca la repetición histórica; `UNIQUE (purchase_token) WHERE duplicate_of IS NULL`; y `purchase_requests`, el pedido de la compra.
- [ ] `POST /players/:id/purchases` (el juego) y `POST /purchases/notifications` (Google Play) verifican la compra en el `3002`, acreditan giros y compra en **una** transacción, y responden **lo mismo** la primera vez y la quinta. Un pago pendiente responde `202` y no acredita.
- [ ] Cincuenta notificaciones simultáneas de la misma compra acreditan una vez, y un fallo a mitad de la transacción no deja nada.
- [ ] `POST /wheels/:id/reconciliation` recalcula todo en el servidor, guarda lo suyo y deja en el log lo que difiere de la consola. Sobre la bitácora sembrada, los dos cálculos coinciden campo por campo.
- [ ] `GET /wheels/:id/audit` audita cada versión de pesos con SQL y `oddsAudit` portado.
- [ ] El giro entrega el sustituto de un avatar repetido, sin gastar stock, y una simulación de 10.000 giros mide que la rueda sigue cayendo según la tabla publicada.
- [ ] El arnés de `be05` se ajusta a la protección (un giro por jugador) y sus invariantes siguen en pie con k6.
- [ ] Existe `server/evidence/compras-y-conciliacion.md`, `CONTRACT.md` dice lo que cambió, `./server/smoke.sh` pasa entero (24 verificaciones), y `git diff pre-backend-go..HEAD -- . ':!server' ':!src/api/authService.js'` no devuelve nada.

---

## 🚫 3. Qué queda fuera por ahora

- **De qué compra sale cada giro pago.** El giro descuenta saldo pago sin anotar el `purchase_token` (`be05`). Llenarlo exige consumir las compras en orden, con su propio bloqueo, y no entra en las 6 horas de la fase. 💸 Deuda declarada en 5.8, con su precio.
- **Reembolsos y compras anuladas.** Google Play avisa también cuando una compra se reembolsa. Un hecho no se borra: se compensa con otro. El diseño es el ejercicio 27.
- **Autenticar al juego y firmar la notificación.** Las dos rutas son públicas, como el giro. 💸 `bea-08`.
- **El mock de Google Play.** No se reescribe en Go, ni ahora ni nunca (`D36`). El backend le habla por HTTP, como a cualquier tercero.
- **Pagos reales, impuestos y retenciones.** El dominio tiene cobro, comisión y neto. Agregar más conceptos no enseñaría nada nuevo sobre aritmética entera.

---

## 🧠 4. Conceptos mínimos

Sabes de transacciones y sabes que los floats no sirven para dinero. Vamos a lo que esta fase agrega.

### 4.1 `BIGINT` de centavos, a los dos lados del cable

`be02` fijó `BIGINT` para los montos, y conviene justificarlo porque Postgres ofrece algo aparentemente mejor: `NUMERIC`, decimal exacto de precisión arbitraria. La razón para no usarlo no es que sea más lento, que lo es: es que **`A10` ya decidió que la unidad del sistema es el centavo entero**, y la consola trabaja así. Un `NUMERIC(12,2)` en la base con enteros de centavos en el cliente crea una conversión en la frontera, y las conversiones en la frontera son donde se pierden los centavos.

📖 **El tipo de la columna tiene que ser el mismo concepto que el tipo del código.** Si el código dice "centavos enteros", la columna dice `BIGINT`. Un `INTEGER` de 32 bits se agota en 2.147.483.647 centavos, unos 21 millones de dólares. La prueba de 5.7 hace fallar la acreditación justamente así, con el saldo de giros pagos (`INTEGER`) en el borde: `pq: integer out of range`.

### 4.2 Recalcular no es desconfiar: es saber quién tiene los datos

La consola calcula la conciliación con lo que tiene cargado en el store. Esa foto puede ser vieja: Marisol abrió la pantalla, y mientras la tenía abierta el pago en efectivo que faltaba se confirmó. **No es mala fe: es que el cliente no tiene los datos.** El servidor sí.

Qué hacer con lo que manda la consola es una decisión, y esta fase la toma:

> 🧭 **Se recalcula todo, gana el servidor, y la diferencia se registra.** No se rechaza la petición con un `400` *"sus números no cuadran"*: eso rompería el contrato y culparía a la consola de algo que no puede hacer bien. Se recalcula, se guarda lo correcto y **se deja el rastro de la diferencia** en el log, con el `X-Request-Id` que la consola ya imprime.

### 4.3 La idempotencia: la misma respuesta, no un error

La compra llega por dos caminos y cualquiera puede repetirse: el juego reintenta con la señal mala, y Google Play reintenta lo que no recibió con un `2xx`. Sin idempotencia hay dos finales posibles y los dos son malos: dos acreditaciones, o un error que deja al juego sin saber si acreditó.

📖 **Una operación idempotente responde lo mismo la primera vez y la quinta.** Si la compra ya está acreditada, se devuelve la compra con el mismo `200`. Por eso la respuesta es **el hecho de la compra** —token, paquete, jugador, giros, instante— y no el saldo, que cambia cada vez que el jugador gira.

Y una regla de `be05` que vuelve: **la red va fuera de la transacción.** Preguntarle a la tienda si cobró es una llamada HTTP a un tercero con su propio perfil de fallo. Se pregunta antes, y la transacción solo escribe.

### 4.4 La historia no se borra: se anota

El `UNIQUE (purchase_token)` que `be02` no puso ya no se puede poner tal cual. La compra repetida de la Fase 8 está en la tabla:

```text
ERROR:  could not create unique index "purchases_token_key"
DETAIL:  Key (purchase_token)=(tok-ago-17) is duplicated.
```

Borrarla para que el índice entre sería borrar un hecho, y la conciliación de la Fase 8 la usa para mostrar `duplicatedInApi`. La salida es marcarla —`duplicate_of` apunta a la primera— y crear el índice **parcial**: `UNIQUE (purchase_token) WHERE duplicate_of IS NULL`. Protege todo lo que entre desde hoy y deja la historia como está.

### 4.5 Lo que se audita es dónde cae la rueda

La rueda que se acomoda (historia §5) cambiaba los pesos de cada jugador, y la tabla del juego solo era verdad para quien no tenía nada. El incidente 21 del cuaderno base lo midió: el avatar común, publicado al 15 %, salía en el 5 % de los giros. La protección con sustituto (`D34`) deja los pesos quietos y cambia **lo que se entrega**. La bitácora guarda las dos cosas, y la auditoría cuenta `landed_segment`, nunca `delivered_prize`: lo que se audita es la rueda. Por eso la protección se puede verificar con la misma conciliación que destapó la regla vieja.

---

## 💻 5. Implementación y código comentado

### 5.1 La migración

<<<archivo:server/migrations/postgres/000008_purchases_and_protection.up.sql>>>

Sobre la base sembrada, la migración deja `tok-ago-17` con su primera fila (`17`) y la repetición marcada (`18 → 17`), y crea el índice parcial. La de SQLite es la misma, con los índices parciales que SQLite también tiene. Y la siembra, que reemplaza las compras enteras, inserta la repetición ya marcada.

Los sustitutos de la protección los publica la siembra, como el de la Esclusa de Oro en `be05`, y son **los mismos** que usa la bitácora sembrada de la Fase 8:

<<<fragmento:server/internal/seed/seed.go|var publishedSubstitutes = map[string]*string{|}>>>

### 5.2 La tienda, como un tercero

<<<fragmento:server/internal/purchase/play.go|// HTTPPlay habla con la tienda|	return json.NewDecoder(res.Body).Decode(out)
}>>>

Un cliente HTTP propio, con su timeout (`PLAY_TIMEOUT`, 3 s), y los errores de la tienda traducidos a errores del dominio: un `404` es *"Google Play no conoce esa compra"*, y cualquier otro problema es *"Google Play no responde"*, que el handler devuelve como `502`. Quien reintenta es el juego o la notificación, no el servidor.

### 5.3 La compra, en una transacción

<<<fragmento:server/internal/purchase/service.go|// credit acredita la compra|	return c, nil
}>>>

La compra se **reclama** con el índice parcial, igual que la clave del giro en `be05`: el `INSERT … ON CONFLICT DO NOTHING` de la segunda notificación espera a que la primera confirme, y después no inserta nada. Cero filas quiere decir *"ya estaba"*, y la respuesta se arma con la compra que ya está. El `ON CONFLICT` lleva el `WHERE` del índice: sin él, Postgres no encuentra la restricción.

```text
ERROR:  there is no unique or exclusion constraint matching the ON CONFLICT specification
```

### 5.4 Los dos avisos

<<<fragmento:server/internal/purchase/service.go|// Register es lo que manda el juego|	return s.credit(ctx, r)
}>>>

El juego anota el **pedido** —qué jugador compró qué paquete— y la notificación, que solo trae el token, lo encuentra ahí. Si la notificación llega antes que el juego, no hay pedido, y el handler responde `404`: Google Play reintenta lo que no recibió con éxito, y para la próxima el juego ya avisó.

<<<fragmento:server/internal/http/handlers.go|func writePurchase(|		writeJSON(w, http.StatusOK, c)
	}
}>>>

### 5.5 La protección de duplicados, dentro del giro

El paso 4 de `decide` deja de ser solo el stock:

<<<fragmento:server/internal/spin/service.go|// deliverable decide qué se entrega|	return delivered, nil
}>>>

El avatar se reclama en el inventario con la misma forma que la clave y que la compra. Y se reclama **antes** del stock: a quien ya tiene la Esclusa de Oro se le entrega el sustituto sin gastar una de las mil.

### 5.6 La conciliación, en el servidor

Las cuentas de la Fase 8, portadas sin cambiarles una regla:

<<<fragmento:server/internal/reconciliation/audit.go|// OddsAudit concilia lo observado|	return a
}>>>

Los conteos salen de la base. Las filas sembradas no traen versión —el mock no la guardaba (`be02`)— y cuentan como de la versión 1, la única que tuvieron esas ruedas:

<<<fragmento:server/internal/reconciliation/reconciliation.go|	err := s.db.SelectContext(ctx, &rows, s.db.Rebind(`|		ORDER BY v.version, sg.id`), wheelID, wheelID)>>>

Y al conciliar, el servidor recalcula, guarda lo suyo y devuelve la diferencia para el log:

<<<fragmento:server/internal/reconciliation/reconciliation.go|func (s *Service) Reconcile(|	return w, saved, diffs, err
}>>>

Sobre la bitácora sembrada de la Rueda de fin de mes, la consola —con `oddsAudit` y `reconcilePurchases` de la Fase 8— y el servidor dan lo mismo en todos los campos:

```text
{"spins":10000,"counts":[3017,1962,1515,1483,1040,784,142,57],"chi2":4.487666666666667,"chi2Alarm":false,"bandAlarms":[],
 "purchases":{"chargedCents":15960,"feeCents":2400,"netCents":13560,"missingInApi":["tok-ago-31"],"duplicatedInApi":["tok-ago-17"]}}
```

El mismo χ² hasta el último decimal: los dos hacen la misma división, con los mismos enteros. Y el log no tiene ninguna línea *"difiere"*.

### 5.7 Las pruebas

<<<fragmento:server/internal/purchase/service_test.go|// La notificación que llega dos veces|	t.Logf("51 avisos · %d compra · %d giros", rows, spins)
}>>>

```bash
TEST_DATABASE_URL="postgres://esclusa:esclusa@localhost:5432/esclusa_test?sslmode=disable" \
  go test -count=1 -race -p 1 -v ./...
```

```text
    service_test.go:92: 51 avisos · 1 compra · 10 giros
--- PASS: TestDuplicateNotificationCreditsOnce (0.20s)
    service_test.go:105: falló: acreditando los giros de tok-be07-2: pq: integer out of range
--- PASS: TestCreditIsAllOrNothing (0.15s)
--- PASS: TestPendingPurchaseWaits (0.15s)
--- PASS: TestRepeatedPrizeGetsSubstitute (0.14s)
```

`TestCreditIsAllOrNothing` es la que verifica la transacción con un fallo **real**: con el saldo de giros pagos en 2.147.483.640, el `UPDATE` revienta **después** de anotar la compra, y el `ROLLBACK` se la lleva. No queda una compra sin giros.

Y la simulación de la protección: 10.000 giros de 800 jugadores sobre los pesos de la Rueda de fin de mes, con dieciséis goroutines a la vez:

```text
sin-premio        peso  3000 · cayó  3056
vidas-2           peso  2000 · cayó  1906
avatar-comun      peso  1500 · cayó  1497
set-gemas-basico  peso  1500 · cayó  1464
vidas-5           peso  1000 · cayó  1005
set-gemas-plata   peso   800 · cayó   848
avatar-raro       peso   150 · cayó   156
esclusa-de-oro    peso    50 · cayó    68
giros 10000 · χ² 15.96 (alarma true) · banda [] · sustitutos entregados 814 · avatares repetidos 0
```

Esa primera corrida **dio alarma**: χ² = 15,96, por encima del valor crítico de 14,067. Antes de concluir nada, se repitió veinte veces: ninguna alarma, con χ² entre 2,55 y 13,99, y entre 745 y 879 sustitutos por corrida. Una de 21 es exactamente la tasa de falsas alarmas del χ² con α = 0,05 (`D32`, `A14` §5), y la banda de ±3σ no marcó ningún segmento en ninguna. Por eso la prueba no exige *"sin alarma"*: exige que ningún jugador reciba dos veces el mismo avatar y que el χ² no pase de tres veces el valor crítico. Una prueba estadística que falla una de cada veinte corridas es una prueba que alguien desactiva.

### 5.8 Lo que la protección le hace al arnés de `be05`, y la deuda que queda

La rueda de medición de `be05` tenía 300 jugadores con 5 giros cada uno. Con la protección, el segundo giro de quien ya tiene la Esclusa de Oro recibe el sustituto **sin tocar el stock**: 1.500 giros de 300 jugadores entregan 300 Esclusas, y la fila caliente deja de estarlo. El arnés pasa a 1.500 jugadores con un giro cada uno (`server/load/rueda-de-medicion.sql`, `PLAYERS` en `giro.js`, y la carrera del stock en `race_test.go`). Con eso, k6 a 50 giros por segundo y con 200 jugadores a la vez, en las dos estrategias, vuelve a dar las invariantes de `be05`: **1.500 giros, 1.000 Esclusas, 500 sustitutos, 0 claves con dos giros, stock en 0, 0 saldos negativos**.

> 💸 **Deuda declarada: los giros pagos no dicen de qué compra salieron.** `spin_log.purchase_token` sigue nulo en los giros nuevos, y el prorrateo de la Fase 8 —el precio de un paquete repartido entre sus giros— solo funciona sobre la bitácora sembrada. Pagarla exige consumir las compras de cada jugador en orden, con la fila de la compra bloqueada mientras se descuenta: un `purchases.spins_left`, el bloqueo de `be05` sobre otra fila, y la carrera correspondiente en `race_test.go`. No entra en las 6 horas de esta fase. Va a `bea-09` y al veredicto de `be09`.

### 5.9 El contrato cambió: actualízalo

Agrega a `server/CONTRACT.md` la conciliación recalculada, `GET /wheels/:id/audit`, las dos rutas de compra con sus respuestas y el cambio declarado del giro (el sustituto del avatar repetido). Y a `smoke.sh`, dos verificaciones que no escriben nada: una notificación sin pedido devuelve `404`, y la auditoría de la rueda 4 trae la versión 1 con sus 10.000 giros. Son **24**.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. Acreditar en pasos sueltos y confiar en el `UNIQUE`.** Síntoma: el jugador tiene giros de más, y la segunda notificación responde `500` con `duplicate key value violates unique constraint`. Causa: los giros se suman en una sentencia y la compra se anota en otra; el índice rechaza la segunda compra cuando los giros **ya se sumaron**. Medido: dos compras de 10 giros, avisadas por el juego y la notificación dos veces, dieron **60** giros pagos en vez de 20. Fix: la compra y los giros en una transacción, y la compra primero. Es el incidente `be-14`.

**2. Guardar lo que manda el cliente.** Síntoma: la conciliación guardada no coincide con el reporte de la tienda, y nadie se equivocó. Causa: la consola calculó con datos de cuando abrió la pantalla. Fix: recalcular en el servidor (5.6). Es el incidente `be-13`.

**3. Un `UNIQUE` de tabla sobre una tabla con historia.** Síntoma: la migración falla con `23505 … (tok-ago-17) is duplicated` y queda sucia. Causa: el duplicado que la Fase 8 encontró. Fix: marcar la repetición y crear el índice parcial (4.4). Nunca borrar la fila para que el índice entre.

**4. `ON CONFLICT` sin el predicado del índice parcial.** Síntoma: `there is no unique or exclusion constraint matching the ON CONFLICT specification`. Fix: `ON CONFLICT (purchase_token) WHERE duplicate_of IS NULL`.

**5. Preguntarle a la tienda dentro de la transacción.** Síntoma: con la tienda lenta, todo se arrastra. Causa: la llamada HTTP con filas bloqueadas. Fix: preguntar antes, escribir después (`be05` §4.4).

**6. Responder distinto al reintento.** Síntoma: el juego muestra *"error"* en una compra que sí se acreditó. Causa: el segundo aviso devuelve `409` *"ya existe"*, o el saldo actual en vez del hecho de la compra. Fix: la misma respuesta, con los datos de la compra.

**7. Auditar lo entregado en vez de dónde cayó la rueda.** Síntoma: con la protección, el avatar común sale *"menos de lo publicado"*. Causa: contar `delivered_prize`. Fix: la auditoría cuenta `landed_segment` (4.5).

**8. Tomar la alarma del χ² por un bug.** Síntoma: una corrida de la simulación alarma y alguien "arregla" el sorteo. Causa: el χ² con α = 0,05 alarma en una de cada veinte corridas de una rueda honesta. Fix: repetir antes de concluir, y mirar la banda (5.7).

### 🩻 Pieza forense de esta fase

**La compra de punta a punta, con la tienda de verdad.** El binario con `PLAY_URL` apuntando al `3002`, que la consola ya levanta con `npm run mock:googleplay`.

*Paso 1 — la tienda cobra.* Una compra con tarjeta, confirmada al instante, y otra en efectivo, pendiente durante `PLAY_PENDING_MS` (3 s):

```bash
curl -s -X POST -H 'Content-Type: application/json' -d '{"purchaseToken":"tok-card-1","method":"card"}' localhost:3002/purchases
curl -s -X POST -H 'Content-Type: application/json' -d '{"purchaseToken":"tok-efecty-1","method":"cash"}' localhost:3002/purchases
```

*Paso 2 — el juego avisa, dos veces cada una.*

```bash
curl -s -X POST -H 'Content-Type: application/json' -d '{"purchaseToken":"tok-card-1","productId":"spins-10"}' localhost:3001/players/43/purchases
```

```text
{"purchaseToken":"tok-card-…","productId":"spins-10","playerId":43,"state":"credited","spins":10,"creditedAt":"2026-10-20T03:29:11.418Z"} → 200
{"purchaseToken":"tok-card-…","productId":"spins-10","playerId":43,"state":"credited","spins":10,"creditedAt":"2026-10-20T03:29:11.418Z"} → 200
{"purchaseToken":"tok-efecty-…","productId":"spins-10","playerId":43,"state":"pending"} → 202
{"purchaseToken":"tok-efecty-…","productId":"spins-10","playerId":43,"state":"pending"} → 202
```

*Paso 3 — la notificación, duplicada.* El mock guarda las notificaciones en vez de empujarlas, así que las reenvías tú, cada evento tal como llegó:

```bash
for T in tok-card-1 tok-efecty-1; do
  curl -s -o /dev/null -X POST -H 'Content-Type: application/json' -d "{\"purchaseToken\":\"$T\"}" localhost:3002/notifications
  curl -s -o /dev/null -X POST -H 'Content-Type: application/json' -d "{\"purchaseToken\":\"$T\"}" localhost:3002/notifications
  curl -s localhost:3002/notifications/$T | jq -c '.[]' | while read -r EV; do
    curl -s -X POST -H 'Content-Type: application/json' -d "$EV" localhost:3001/purchases/notifications; echo
  done
done
```

Las cuatro respuestas son `200` con `state: "credited"`, y la de efectivo trae su propio `creditedAt`: se acreditó cuando la tienda la confirmó, no cuando el juego avisó.

*Paso 4 — la base.*

```text
tok-card-…|43|1
tok-efecty-…|43|1
giros pagos de María R.: 20
```

Seis avisos por compra, una fila por compra, 20 giros. **Esta es la escena que resume la fase.**

*Paso 5 — la conciliación que difiere.* Abre la conciliación de la Rueda de fin de mes con la sesión de Marisol (`mdegracia`): `tok-ago-31` aparece como cobrada por la tienda y no acreditada. Sin cerrar la pantalla, acredítala como en los pasos 1 y 2 (con el jugador 42), y después aprieta *Conciliar rueda*. La consola no recargó, y mandó su foto vieja. En el log del backend:

```text
[req-id b1af1ff9de301f25] la conciliación de la rueda 4 que mandó la consola difiere de la del servidor: missingInApi: consola [tok-ago-31], servidor []
```

Y lo guardado es lo del servidor: `missingInApi: []`. La consola no mintió; no tenía los datos, y ahora queda escrito cuánto se equivocaba.

---

> 📓🔥 De esta fase salen los incidentes **be-13** y **be-14** de `cuaderno-incidentes-be.md`. El be-13 es hermano del **18** del track base: allá el redondeo de un centavo; acá el cliente calculando con datos viejos. Y la protección de duplicados es el arreglo que el incidente **21** del cuaderno base dejó escrito como trabajo del API.

---

## 🧪 7. Ejercicios (29)

**🟢 Fácil (1–8)**

1. Aplica la migración `000008` y comprueba en `psql` la fila de `tok-ago-17` con su `duplicate_of`, y el índice `purchases_unique_token` con su `WHERE`.
2. Intenta crear un `UNIQUE (purchase_token)` de tabla dentro de una transacción y copia el error. Después `ROLLBACK`.
3. Haz los pasos 1 y 2 de la pieza forense con una compra con tarjeta y comprueba que las dos respuestas son idénticas.
4. Avisa una compra de un paquete que no existe y una que la tienda no conoce. Anota los dos códigos y sus mensajes.
5. Manda una notificación de un token que el juego nunca avisó y explica por qué la respuesta es `404` y no `200`.
6. Pide `GET /wheels/4/audit` y compara sus conteos con los del tablero de la Fase 9.
7. Gira tres veces con un jugador en la rueda de medición y comprueba en `spin_log` que la segunda y la tercera entregan el sustituto.
8. Corre `./server/smoke.sh` y confirma las 24 verificaciones.

**🟡 Intermedio (9–19)**

9. Corre las pruebas de 5.7 con `-race` contra Postgres y anota lo que imprime cada una.
10. Corre la simulación de 5.7 diez veces y anota el χ² de cada corrida. ¿Cuántas alarmas esperabas? ¿Cuántas hubo?
11. **Diagnóstico.** Quita el `WHERE duplicate_of IS NULL` del `ON CONFLICT` y corre las pruebas. Copia el error y explica qué busca Postgres.
12. Haz el paso 5 de la pieza forense y encuentra la línea del log con el `X-Request-Id` que imprimió la consola.
13. **Diagnóstico.** Mueve la llamada a la tienda **dentro** de la transacción de `credit` y pon el `3002` con `CHAOS_LEVEL=high`. Mide qué le pasa al tiempo de una acreditación y a las demás.
14. Concilia la Rueda de fin de mes con la consola y con `curl` mandando un cuerpo inventado. Comprueba que lo guardado es lo mismo en los dos casos.
15. Escribe la consulta que encuentra jugadores con más giros pagos que los que compraron. Pruébala después del incidente `be-14`.
16. **Diagnóstico.** Cuenta `delivered_prize` en vez de `landed_segment` en la auditoría y corre la simulación. Explica por qué el avatar común da alarma.
17. Mide cuántos sustitutos entrega la protección en la simulación según cuántos giros tiene cada jugador: 5, 13 y 50.
18. Reproduce con el arnés viejo de `be05` (300 jugadores con 5 giros) la medición de k6 y explica las cifras que salen.
19. **Diagnóstico.** Haz que la notificación llegue **antes** que el aviso del juego. Sigue el recorrido hasta que la compra se acredite, y di cuántos `404` hicieron falta.

**🟠 Difícil (20–25)**

20. **Diagnóstico.** Reproduce el incidente `be-14` con el binario y explica, paso por paso, por qué el índice único no lo evitó.
21. Implementa los reembolsos como hecho: una tabla `purchase_refunds` y la compensación de los giros. Decide qué pasa si el jugador ya gastó los giros.
22. Haz que `GET /wheels/:id/audit` audite también una rueda con dos versiones de pesos, con giros en las dos. Explica por qué un solo χ² para las dos versiones no tendría sentido.
23. Escribe una prueba que mida, con la regla vieja de la rueda que se acomoda (`--accommodating` de la Fase 8) y con la nueva, cuántos jugadores reciben dos veces el mismo avatar. Compara con las cifras del incidente 21.
24. Diseña la alarma de la conciliación: qué diferencia entre la consola y el servidor merece despertar a alguien, y cuál es ruido.
25. Pon una demora de 2 s y después de 4 s en las respuestas del `3002` (en una rama descartable del mock) y mide qué pasa con la acreditación. Decide si el `PLAY_TIMEOUT` de 3 s es razonable, y qué ve el juego cuando se cumple.

**🔴 Muy difícil (26–29)**

26. Paga la deuda de 5.8: `purchases.spins_left`, el consumo en orden de compra dentro de `decide`, y la carrera en `race_test.go` con cincuenta giros pagos a la vez de un jugador con dos compras.
27. Diseña los reembolsos completos: la notificación de anulación de Google Play, la compensación como hecho, la conciliación que la ve, y qué hace la protección de duplicados si se reembolsa un giro que entregó un avatar.
28. Argumenta por escrito si la conciliación debería seguir guardándose en una tabla o calcularse siempre al vuelo desde la bitácora. Mide el costo de la consulta con la Semana del Canal sembrada (180.000 filas) y decide.
29. **Post-mortem.** Escribe el post-mortem de *"acreditamos la compra dos veces"* según los ocho puntos del post-mortem de `cuaderno-incidentes.md`. La prevención tiene que explicar por qué el índice único no bastaba, sin culpar a quien lo puso.

**🔥 Opcionales**

- 🔥 Haz que el mock del `3002` empuje las notificaciones al backend en vez de guardarlas, en una rama descartable, y mide si cambia algo de lo que hace el servidor.
- 🔥 Calcula el χ² en SQL, con una sola consulta, y compáralo con el de Go. Decide dónde debería vivir con el criterio de `be02`.
- 🔥 Simula la regla vieja de la rueda que se acomoda en el backend, detrás de una bandera, y concilia las dos con `GET /wheels/:id/audit`.

---

## 📚 8. Referencias

**Documentación oficial**
- https://www.postgresql.org/docs/13/indexes-partial.html — los índices parciales, con el ejemplo de unicidad condicional.
- https://www.postgresql.org/docs/13/sql-insert.html#SQL-ON-CONFLICT — `ON CONFLICT` con el predicado del índice (`index_predicate`).
- https://www.postgresql.org/docs/13/datatype-numeric.html — `BIGINT`, `INTEGER` y `NUMERIC`, con sus rangos.
- https://developer.android.com/google/play/billing/rtdn-reference — las notificaciones en tiempo real de Google Play. Viajan por Cloud Pub/Sub, que entrega *al menos una vez*.
- https://developer.android.com/google/play/billing/integrate — el flujo del lado del servidor: verificar la compra antes de acreditar.
- https://pkg.go.dev/net/http#Client — `Timeout`, y por qué un cliente sin timeout es una deuda.

**Libros**
- *Designing Data-Intensive Applications* (Martin Kleppmann) — el capítulo 11, sobre procesar eventos que pueden llegar más de una vez, y el 12 sobre la corrección de extremo a extremo.

**Video / apoyo**
- Busca "idempotency keys payments API" y "Google Play Real-time developer notifications". Verifica que los ejemplos de Google Play sean de la Billing Library vigente: el flujo cambió varias veces.

**Orden de lectura sugerido:** `A14` §5 antes de la simulación → `indexes-partial.html` para 4.4 → la referencia de las notificaciones de Google Play → el capítulo 11 de Kleppmann para entender por qué *"al menos una vez"* es la norma y no la excepción.

> ⚠️ URLs, títulos y ediciones pueden haber cambiado: verifícalos. Las referencias a libros y videos son de memoria y pueden ser inexactas. La documentación de Postgres tiene una versión por URL; fija el 13. Las cifras de esta fase son de las corridas del 19/10/2026 en la máquina del autor. Cualquier discrepancia de versiones la resuelve `00-decisiones-y-versiones.md` §7.

---

## 🚀 9. Cierre y conexión con la siguiente fase

La compra se acredita una vez. El juego, la notificación y sus repeticiones reciben la misma respuesta, y un fallo a mitad de la transacción no deja ni una compra sin giros ni giros sin compra. La conciliación la calcula quien tiene los datos, y lo que la consola tenía cargado queda en el log como diferencia medida, no como verdad guardada. Y la rueda que se acomoda se reemplazó por la que deja la tabla de probabilidades diciendo la verdad: la simulación lo mide, y la misma conciliación que destapó la regla vieja verifica la nueva.

Quedan dos deudas 💸 con precio: los giros pagos no dicen de qué compra salieron, y las rutas de la compra no autentican a quien llama.

`be08` toma todo lo que el track construyó y le pregunta lo incómodo: **¿cuánto de esto está probado de verdad?** Las pruebas de carrera, las de la hora y las de la compra corren contra Postgres; la suite que corre contra SQLite está verde y no dice nada sobre ninguna de las tres. Esa es la regla del motor, y la evidencia la fueron dejando `be05`, `be06` y esta fase.

> **La señal de que quedó bien:** *"puedo mandar la misma notificación diez veces, y conciliar desde una pestaña vieja, y la base dice lo mismo."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-be07-compras-y-conciliacion -m "be07 cerrada: \
> compra idempotente por purchaseToken (juego y notificación), giros y compra en una transacción; \
> conciliación recalculada en el servidor, igual a la de la consola; \
> auditoría por versión en SQL; protección de duplicados con sustituto; \
> purchase_token de los giros pagos, deuda declarada"
> ```
>
> Los commits de la fase llevan su prefijo (`be07: …`) y los de ejercicio su número (`be07 ej26: …`). Si un ejercicio merece su propio marcador va en `ej/be07/26`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` / `-fix`, con el ID que le reserva `cuaderno-incidentes-be.md`. Todo eso está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

*(Fuera de lo que lee el estudiante.)*

- **`D34` se cumple entera**: el sustituto por stock agotado (`be05`) y por premio repetido (esta fase), con la bitácora guardando dónde cayó y qué se entregó. La simulación mide las proporciones. **`D33`**: la auditoría por versión. **`D36`**: el `3002` sigue siendo el tercero.
- **El arnés de `be05` cambió** (un giro por jugador). `be08` hereda la carrera del stock y k6 con esa forma; las cifras de `be05` siguen siendo las de su tag.
- **Cambios observables** que `CONTRACT.md` recoge: la conciliación recalculada, el sustituto del avatar repetido, las dos rutas de compra y `GET /wheels/:id/audit`. Que `be08` verifique los cuatro.
- **Deudas declaradas:** 💸 `purchase_token` de los giros pagos (5.8); 💸 las rutas de compra públicas (`bea-08`); 💸 los reembolsos (ejercicio 27); 💸 el prorrateo sigue en la consola. Van a `bea-09` y al veredicto de `be09`.
- **`be08` hereda** `TestDuplicateNotificationCreditsOnce`, `TestCreditIsAllOrNothing` y la simulación de la protección, que tiene que seguir sin exigir *"sin alarma"*.
- **Reserva para el cuaderno de incidentes:** `be-13` — *la conciliación y el reporte de la tienda no dan lo mismo* (🔥 dinero, 🟡); `be-14` — *acreditamos la compra dos veces* (🔥 transacciones, 🟡).
