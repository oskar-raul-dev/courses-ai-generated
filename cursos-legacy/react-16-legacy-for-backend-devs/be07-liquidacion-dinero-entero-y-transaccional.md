# 💰 Fase be07 — Liquidación: dinero entero y transaccional

> Tutorial React 16 — Rifas y chances · **Track BE opcional 🔥** · Fase be07 de be09 · **6 horas**
> Depende de: be06 — el cierre ya lo decide el servidor · Habilita: be08 — Pruebas y la regla del motor

---

## 🎯 1. Propósito

El apéndice `A10` enseñó aritmética en centavos enteros y la Fase 8 la aplicó
bien: nada de floats, redondeo explícito, partes que suman exactamente el todo.
Ese trabajo está hecho y esta fase no lo repite.

Lo que falta es la otra mitad, y es la que de verdad protege la plata: **hoy toda
esa disciplina vive en el navegador**. El servidor recibe unos números por HTTP y
los guarda sin preguntar. Si alguien manda un `margin` que no cuadra, se guarda.
Si el cálculo se hace con la mitad de los datos, se guarda. Si el proceso se cae a
mitad de la liquidación, la base queda con el dinero repartido y la rifa sin
liquidar.

> 🧭 **El dinero no se valida: se recalcula.** Un total que llega por la red es
> una **afirmación del cliente**, exactamente igual que la identidad en `be04` y
> la hora en `be06`. Es la tercera vez que el track dice lo mismo, y no es
> casualidad: es el patrón.

Al terminar, la liquidación va a ser una transacción que o cuadra al centavo o no
ocurre, idempotente ante reintentos, con el reparto registrado como **hechos
inmutables** —la misma forma que `sales` estrenó en `be05`— y con la base
garantizando lo que hasta hoy solo garantizaba una función de JavaScript.

> 🩻 **Lectura previa obligatoria:** la Fase 8 del track base y el apéndice `A10`.
> Las reglas de redondeo, el tratamiento del residuo y los nombres salen de ahí y
> **no se reinventan**. Si algo de `A10` no se puede sostener del lado del
> servidor, esta fase lo dice en voz alta en vez de cambiarlo en silencio.

---

## ✅ 2. Qué queda listo al terminar

- [ ] Migración `000006`: existe `prize_payouts`, el registro inmutable de a quién
      le tocó cuánto, con la restricción que impide pagar dos veces al mismo
      ganador de la misma liquidación.
- [ ] El servidor **recalcula** `totalCollected`, `prizeAmount` y `margin` desde
      `sales` y desde la rifa, y sus números son los que se guardan.
- [ ] La discrepancia entre lo que calculó el cliente y lo que calculó el
      servidor queda registrada en el log con su `X-Request-Id`.
- [ ] La liquidación entera —recalcular, insertar, repartir, marcar la rifa como
      `settled`— ocurre en **una transacción**.
- [ ] La liquidación es **idempotente**: un segundo `POST /settlements` sobre la
      misma rifa devuelve la liquidación existente, no un error ni un duplicado.
- [ ] `prizeShare` está portado a Go con **exactamente** la misma política de
      residuo que `A10`, y hay una prueba que verifica que las partes suman el
      todo para cientos de combinaciones.
- [ ] La transacción verifica antes de confirmar que la suma de los pagos es
      igual al premio, y **aborta** si no cuadra.
- [ ] Está documentado en `server/evidence/dinero.md` qué garantiza cada capa y
      qué de `A10` no se pudo sostener igual del lado del servidor.
- [ ] `./server/smoke.sh` sigue entero y el frontend sigue sin tocarse.

---

## 🚫 3. Qué queda fuera por ahora

- **El dashboard y sus métricas** → la Fase 9 del track base queda fuera del
  contrato obligatorio. Un `GET /stats` es pendiente 🔥 de `be09` y **ninguna
  fase depende de él**; las métricas se siguen calculando en el navegador.
- **Pagos reales.** No hay pasarela, no hay transferencias, no hay conciliación
  bancaria. `prize_payouts` registra a quién le corresponde cuánto; que el dinero
  se mueva es otro sistema y otro curso.
- **Impuestos, retenciones y comisiones.** El dominio tiene recaudo, premio y
  margen. Agregar más conceptos no enseñaría nada nuevo sobre aritmética entera.
- **Reversar una liquidación.** Un registro inmutable no se borra; se compensa
  con otro registro. El diseño de esa compensación es el ejercicio 27.

---

## 🧠 4. Conceptos mínimos

Sabes de transacciones y sabes que los floats no sirven para dinero. Vamos a lo
que esta fase agrega.

### 4.1 `BIGINT` y por qué no `NUMERIC`

`be02` fijó `BIGINT` para todos los montos, y conviene justificarlo porque
Postgres ofrece algo aparentemente mejor: `NUMERIC`, decimal exacto de precisión
arbitraria.

`NUMERIC` es correcto y es más lento —es aritmética por software—, pero la razón
para no usarlo acá es otra y es más fuerte: **`A10` ya decidió que la unidad
mínima del sistema es el centavo entero**, y el frontend trabaja así. Un
`NUMERIC(12,2)` en la base con enteros de centavos en el cliente crea una
conversión en la frontera, y las conversiones en la frontera son donde se pierden
los centavos. Un `BIGINT` de centavos a los dos lados del cable no necesita
convertir nada.

📖 **La regla, en una línea:** el tipo de la columna tiene que ser el mismo
concepto que el tipo del código. Si el código dice "centavos enteros", la columna
dice `BIGINT`.

> ⚠️ `BIGINT` llega hasta unos 92 mil billones de centavos. Para rifas de barrio
> sobra con holgura. Menciono el límite porque un `INTEGER` de 32 bits **no**
> alcanza: se agota en unos 21 millones de pesos, que es un mal día de ventas.
> `be02` puso `BIGINT` y esa elección tiene un porqué.

### 4.2 Recalcular no es desconfiar del frontend: es saber quién tiene los datos

El cliente calcula `totalCollected` con los números que tiene cargados en el
store. Esa lista puede estar desactualizada —otra pestaña vendió tres números
hace un minuto—, incompleta o filtrada. **No es mala fe: es que el cliente no
tiene los datos.**

El servidor sí: la tabla `sales` es la verdad, y `be05` la hizo confiable.
Recalcular desde ahí no es una medida de seguridad, es la única forma de que el
número sea correcto.

Qué hacer entonces con lo que manda el cliente es una decisión, y esta fase la
toma explícita:

> 🧭 **Se recalcula todo, gana el servidor, y la diferencia se registra.** No se
> rechaza la petición con un `400` "sus números no cuadran": eso rompería el
> contrato y además culparía al cliente de algo que no puede hacer bien. Se
> recalcula, se guarda lo correcto y **se deja un rastro de la discrepancia**,
> que es información de diagnóstico valiosísima.

Es exactamente lo que `be06` hizo con `settledAt`. Tercera vez que aparece el
patrón, y ya se puede nombrar: **el cliente propone, el servidor dispone, y la
diferencia se mide.**

### 4.3 La idempotencia, que acá no es un lujo

El mock de la Fase 3 falla a propósito, y la Fase 8 tiene un ejercicio 🔴 sobre
qué hacer cuando el `POST /settlements` falla y hay que reintentar. Con caos
encendido, este escenario es rutina: la petición llega al servidor, la
liquidación se crea, y la respuesta se pierde. El cliente reintenta.

Sin idempotencia hay dos finales posibles y los dos son malos: dos liquidaciones
para la misma rifa, o un error que deja al usuario sin saber si se liquidó o no.

La mitad barata ya está desde `be02`: `settlements.raffle_id` es `UNIQUE`. Falta
la otra mitad, que es **qué se hace cuando esa restricción salta**. Y la respuesta
correcta no es un error:

📖 **Una operación idempotente responde lo mismo la primera vez y la quinta.** Si
la rifa ya está liquidada, se devuelve **la liquidación existente** con el mismo
código de éxito. El cliente no tiene forma de distinguir su reintento de un
primer intento, y esa indistinguibilidad es justamente la propiedad.

Y hay un matiz que hace falta pensar: ¿y si el segundo `POST` trae números
distintos? Con recálculo del lado del servidor, la pregunta se disuelve — los
números no vienen del cuerpo. Es un buen ejemplo de cómo una decisión de diseño
elimina una familia entera de casos borde en vez de obligarte a manejarlos.

### 4.4 Registro inmutable en vez de campo actualizable

Es el mismo cambio de forma que `be05`, aplicado al dinero, y conviene verlo
junto:

| Como estado | Como hecho |
|---|---|
| `raffle_numbers.status = 'sold'` | una fila en `sales` |
| `settlements.paid = true` | una fila en `prize_payouts` |

Un campo que se pisa no puede responder *cuándo*, *quién* ni *cuánto* — y en
dinero, esas tres preguntas se hacen siempre, normalmente meses después y
normalmente por alguien de contabilidad. Un registro que se acumula responde las
tres y además **se puede restringir con índices**, que es lo que convierte una
convención en una imposibilidad.

Regla práctica para el resto de tu carrera: **si un dato puede aparecer en un
reclamo, modélalo como hecho.**

---

## 💻 5. Implementación y código comentado

### 5.1 La migración: el reparto como hechos

```sql
-- server/migrations/postgres/000006_prize_payouts.up.sql

-- A quién le corresponde cuánto, una fila por beneficiario. Inmutable:
-- nada de esta tabla se actualiza jamás. Si hay que corregir, se compensa
-- con otro registro (ejercicio 27).
CREATE TABLE prize_payouts (
    id             BIGSERIAL   PRIMARY KEY,
    settlement_id  BIGINT      NOT NULL REFERENCES settlements(id) ON DELETE RESTRICT,
    -- El número ganador que da derecho al pago. Se guarda el número y no
    -- solo el participante porque el número ES el título: si mañana se
    -- corrige a quién pertenecía, el derecho no cambia de número.
    number         TEXT        NOT NULL,
    participant_id BIGINT      REFERENCES participants(id),
    -- Centavos enteros, coherente con A10 y con el resto del esquema.
    amount         BIGINT      NOT NULL CHECK (amount >= 0),
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),

    -- Un número no puede cobrar dos veces la misma liquidación. Misma
    -- idea que el UNIQUE de sales en be05: no es una validación, es una
    -- imposibilidad.
    CONSTRAINT prize_payouts_unique_number UNIQUE (settlement_id, number)
);

CREATE INDEX prize_payouts_by_settlement ON prize_payouts (settlement_id);

-- ON DELETE RESTRICT y no CASCADE, a propósito: borrar una liquidación que
-- tiene pagos registrados tiene que fallar y hacer ruido. En dinero, el
-- borrado en cascada silencioso es exactamente lo que no quieres.
```

### 5.2 La aritmética, portada de `A10` sin cambiarle una regla

```go
// server/internal/settlement/math.go
package settlement

import "errors"

// Este archivo es el gemelo en Go de src/features/settlements/settlementMath.js
// (Fase 8) y del apéndice A10. Las reglas NO se rediseñan: si algo difiere,
// es un bug de esta traducción, no una mejora.
//
// 🧭 Coherencia obligatoria con A10:
//   - todo en centavos enteros, nunca floats
//   - división entera para la parte, resto explícito
//   - el resto se reparte de a un centavo entre los PRIMEROS, en orden
//     determinista
//   - las partes suman EXACTAMENTE el todo

var ErrInvalidShare = errors.New("prizeShare requiere enteros no negativos y al menos un ganador")

// TotalCollected: recaudo = números vendidos × precio unitario.
// Multiplicar enteros no pierde precisión; lo único que hay que vigilar es
// el desbordamiento, y BIGINT / int64 dan margen de sobra (§4.1).
func TotalCollected(soldCount int64, numberPrice int64) int64 {
	return soldCount * numberPrice
}

// PrizeAmount replica la regla de negocio de calculatePrize (Fase 8):
// solo se paga premio si el número ganador se vendió. Si no se vendió, la
// casa no paga. Es una decisión de dominio explícita, no un caso borde.
func PrizeAmount(basePrize int64, winnerSold bool) int64 {
	if !winnerSold {
		return 0
	}
	return basePrize
}

// Margin puede ser NEGATIVO y no se fuerza a cero: un margen negativo es
// información, no un error. Idéntico a calculateMargin de la Fase 8.
func Margin(totalCollected, prizeAmount int64) int64 {
	return totalCollected - prizeAmount
}

// PrizeShare reparte el premio entre N ganadores sin perder ni inventar un
// centavo. Traducción literal de prizeShare de A10 §4.
//
// La "injusticia" de que los primeros se lleven el centavo extra es
// deliberada y está discutida en A10: repartir al azar sería más justo y
// destruiría el determinismo, y un cálculo de dinero que no da el mismo
// resultado dos veces no se puede auditar ni probar.
//
// El orden lo fija quien llama, y acá lo fija el ORDEN DE VENTA (sales.id
// ascendente): quien compró primero cobra el centavo de más. Es una regla
// explícita del dominio, defendible ante un reclamo, y sale de un dato que
// existe gracias a be05.
func PrizeShare(prizeAmount int64, winners int) ([]int64, error) {
	if prizeAmount < 0 || winners <= 0 {
		return nil, ErrInvalidShare
	}

	base := prizeAmount / int64(winners)      // división entera
	remainder := prizeAmount % int64(winners) // 0 .. winners-1

	shares := make([]int64, winners)
	for i := range shares {
		shares[i] = base
		if int64(i) < remainder {
			shares[i]++ // los primeros `remainder` reciben un centavo extra
		}
	}
	return shares, nil
}

// SumShares existe para poder AFIRMAR la propiedad, no solo confiar en ella.
func SumShares(shares []int64) int64 {
	var total int64
	for _, s := range shares {
		total += s
	}
	return total
}
```

> 🧠 **Un detalle que Go hace mejor que JavaScript, y conviene notarlo.** En JS,
> `prizeShare` tiene que comprobar `Number.isInteger` en tiempo de ejecución
> porque un `number` puede traer decimales. En Go, `int64` **es** entero: el
> compilador impide que llegue otra cosa. Una clase entera de bugs desaparece por
> el sistema de tipos.
>
> Y lo que Go hace **peor**: `int64` desborda en silencio. Si `soldCount *
> numberPrice` se pasa, no hay excepción — el número da la vuelta y queda
> negativo. En JS habrías perdido precisión, que también es malo, pero de forma
> más ruidosa. Ninguno de los dos lenguajes te protege gratis; los dos exigen que
> sepas qué estás haciendo. Está anotado en `dinero.md` como lo que `A10` no
> puede sostener igual de este lado, y el ejercicio 24 lo mide.

### 5.3 La liquidación: una transacción, o nada

```go
// server/internal/settlement/service.go

// Create liquida una rifa.
//
// La transacción más grande del track. Adentro pasan seis cosas y o pasan
// todas o no pasa ninguna:
//   1. se bloquea la rifa y se verifica que se pueda liquidar
//   2. se recalculan los montos desde sales (nunca desde el cuerpo)
//   3. se inserta la liquidación
//   4. se reparte el premio en prize_payouts
//   5. se verifica que las partes sumen el todo
//   6. se marca la rifa como settled
func (s *Service) Create(ctx context.Context, in Settlement) (Settlement, error) {
	settledBy := httpapi.UserIDFrom(ctx)
	if settledBy == 0 {
		return Settlement{}, ErrUnauthenticated
	}

	var result Settlement

	err := s.store.WithTx(ctx, func(tx Tx) error {
		// (1) Bloqueo sobre la rifa. Acá sí FOR UPDATE y no FOR SHARE
		// (a diferencia de be06): vamos a MODIFICAR la rifa, y además
		// queremos que dos liquidaciones simultáneas de la misma rifa se
		// serialicen en vez de pelear.
		raffle, err := tx.FindRaffleForUpdate(ctx, in.RaffleID)
		if err != nil {
			return err
		}

		// (1b) IDEMPOTENCIA. Ya bloqueada la rifa, si existe liquidación
		// se devuelve esa. No es un error: es un reintento, y con el caos
		// de la Fase 3 encendido es el caso normal, no el excepcional.
		existing, err := tx.FindSettlementByRaffle(ctx, in.RaffleID)
		if err == nil {
			log.Printf("[req-id %s] liquidación %d ya existía para la rifa %d: se devuelve la misma",
				httpapi.RequestIDFrom(ctx), existing.ID, in.RaffleID)
			result = existing
			return nil
		}
		if !errors.Is(err, ErrNotFound) {
			return err
		}

		// La transición resolved → settled la custodia el service, igual
		// que en be04. Una rifa abierta no se liquida.
		if raffle.Status != "resolved" {
			return fmt.Errorf("la rifa está en %q y no en \"resolved\": %w",
				raffle.Status, raffle.ErrIllegalTransition)
		}

		// (2) RECÁLCULO. Los números salen de la base, no del cuerpo.
		// Esta es la deuda 💸 que la fase cobra: hasta hoy, la aritmética
		// de A10 vivía solo en el navegador y la base no garantizaba nada.
		sold, err := tx.ListSales(ctx, in.RaffleID)
		if err != nil {
			return err
		}
		winners := filterByNumber(sold, in.WinningNumber)

		totalCollected := TotalCollected(int64(len(sold)), raffle.NumberPrice)
		prizeAmount := PrizeAmount(raffle.BasePrize, len(winners) > 0)
		margin := Margin(totalCollected, prizeAmount)

		// La discrepancia se REGISTRA, no se rechaza (§4.2). Cuando alguien
		// reporte "el total que vi no es el que quedó guardado", esta línea
		// es la respuesta.
		if in.TotalCollected != totalCollected || in.PrizeAmount != prizeAmount || in.Margin != margin {
			log.Printf("[req-id %s] discrepancia en la rifa %d — cliente: total=%d premio=%d margen=%d | servidor: total=%d premio=%d margen=%d",
				httpapi.RequestIDFrom(ctx), in.RaffleID,
				in.TotalCollected, in.PrizeAmount, in.Margin,
				totalCollected, prizeAmount, margin)
		}

		// (3) La liquidación, con los números del servidor y el instante
		// del servidor (be06).
		created, err := tx.InsertSettlement(ctx, Settlement{
			RaffleID:       in.RaffleID,
			WinningNumber:  in.WinningNumber,
			IsWinnerSold:   len(winners) > 0,
			SoldCount:      len(sold),
			TotalCollected: totalCollected,
			PrizeAmount:    prizeAmount,
			Margin:         margin,
			SettledAt:      timePtr(s.clock.Now()),
		})
		if err != nil {
			return err
		}

		// (4) El reparto. Con un solo ganador es trivial; con varios es
		// donde A10 gana su sueldo. El orden lo fija sales.id ascendente:
		// quien compró primero se lleva el centavo extra.
		shares, err := PrizeShare(prizeAmount, len(winners))
		if err != nil && len(winners) > 0 {
			return err
		}
		for i, w := range winners {
			if err := tx.InsertPayout(ctx, created.ID, w.Number, w.ParticipantID, shares[i]); err != nil {
				return err
			}
		}

		// (5) LA ASERCIÓN QUE HACE QUE ESTO SEA DINERO Y NO UN CRUD.
		//
		// Comprobar la propiedad DENTRO de la transacción significa que un
		// reparto que no cuadre no llega a existir: el Rollback lo borra.
		// Sin esta línea, un bug futuro en PrizeShare produciría dinero
		// mal repartido y confirmado, que es un incidente contable, no un
		// bug de software.
		if got := SumShares(shares); len(winners) > 0 && got != prizeAmount {
			return fmt.Errorf("el reparto no cuadra: las partes suman %d y el premio es %d", got, prizeAmount)
		}

		// (6) La rifa queda liquidada. En la MISMA transacción: es lo que
		// hace imposible el escenario de la pieza forense —dinero repartido
		// y rifa sin liquidar—.
		if err := tx.UpdateRaffleStatus(ctx, in.RaffleID, "settled"); err != nil {
			return err
		}

		result = created
		return nil
	})
	if err != nil {
		return Settlement{}, err
	}
	return result, nil
}
```

> 🧠 **Fíjate en el paso 6 y compáralo con el frontend.** El thunk de la Fase 8
> hace `POST /settlements` y **después** despacha `raffleSettled` en el store.
> Dos operaciones separadas: si la segunda no ocurre —o si el usuario recarga
> antes—, el store y la base pueden discrepar. Del lado del servidor las dos son
> una sola cosa. **La misma secuencia, con y sin atomicidad, en las dos orillas:**
> compáralas en `dinero.md`, es uno de los contrastes más claros del track.

### 5.4 La prueba que verifica la propiedad, no los casos

```go
// server/internal/settlement/math_test.go

// La propiedad de A10 —las partes suman exactamente el todo— no se prueba
// con tres ejemplos: se prueba con muchos, porque el bug vive en el resto
// y el resto solo aparece cuando el premio no es divisible.
func TestPrizeShareSumaExactamenteElTodo(t *testing.T) {
	for prize := int64(0); prize <= 1000; prize++ {
		for winners := 1; winners <= 17; winners++ {
			shares, err := PrizeShare(prize, winners)
			if err != nil {
				t.Fatalf("premio=%d ganadores=%d: %v", prize, winners, err)
			}
			if got := SumShares(shares); got != prize {
				t.Errorf("premio=%d ganadores=%d: las partes suman %d", prize, winners, got)
			}
			// La segunda propiedad, que se olvida siempre: nadie puede
			// diferir de otro en más de un centavo. Sin esto, un reparto
			// que le da todo al primero también "sumaría el todo".
			if max(shares)-min(shares) > 1 {
				t.Errorf("premio=%d ganadores=%d: reparto desbalanceado %v", prize, winners, shares)
			}
		}
	}
}

// Y el que amarra las dos orillas: los mismos casos del test de
// settlementMath.js de la Fase 8, con los mismos números y los mismos
// resultados esperados. Si esta tabla y la de JavaScript divergen, hay un
// sistema con dos verdades sobre el dinero.
func TestCoherenciaConElFrontend(t *testing.T) {
	casos := []struct{ prize int64; winners int; quiere []int64 }{
		{100, 3, []int64{34, 33, 33}}, // el ejemplo literal de A10 §4
		{0, 1, []int64{0}},            // el ganador no se vendió
		{500000, 1, []int64{500000}},  // el caso del curso base
		{7, 4, []int64{2, 2, 2, 1}},
	}
	// …
}
```

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. Confiar en los montos del cuerpo.** Síntoma: ninguno, hasta que el store
está desactualizado y se guarda un recaudo que no corresponde. Causa: guardar lo
que llegó. Fix: recalcular desde `sales`. **La regla operativa: ningún monto que
se guarde puede haber cruzado la red.**

**2. Repartir con `float64`.** Síntoma: un centavo que aparece o desaparece, muy
de vez en cuando. Causa: `prizeAmount / float64(winners)` y redondeo. Fix: la
división entera de `A10`. Si ves un `float64` en un archivo que habla de dinero,
es un bug aunque todavía no haya fallado.

**3. Verificar el cuadre después del `Commit`.** Síntoma: se detecta que el
reparto no cuadra… y ya está guardado. Causa: la aserción fuera de la
transacción. Fix: adentro, como en el paso 5. La diferencia entre detectar y
**prevenir** es dónde va esa línea.

**4. Tratar el reintento como error.** Síntoma: con caos encendido, el usuario ve
"esta rifa ya fue liquidada" y no sabe si su liquidación se guardó. Causa: el
`23505` traducido a error. Fix: idempotencia — devolver la existente.

**5. Marcar la rifa como liquidada fuera de la transacción.** Síntoma: rifas en
`settled` sin liquidación, o al revés. Causa: dos operaciones que deberían ser
una. Fix: el paso 6 adentro. Es exactamente el bug que la pieza forense provoca.

**6. `INTEGER` en vez de `BIGINT`.** Síntoma: montos negativos absurdos en rifas
grandes. Causa: desbordamiento silencioso a los ~21 millones de pesos. Fix:
`BIGINT` (que `be02` ya puso) y una comprobación de rango en el cálculo. El
ejercicio 24 lo provoca.

### 🩻 Pieza forense de esta fase

**Una liquidación interrumpida a la mitad.**

*Preparación.* Deja una rifa en `resolved` con veinte números vendidos, uno de
ellos el ganador.

*Paso 1 — sin transacción.* Escribe una versión de `Create` que ejecute los seis
pasos **sin** `WithTx`, cada uno con su propia conexión. Mete un `panic` entre el
paso 4 (el reparto) y el paso 6 (marcar la rifa):

```go
// Solo para la pieza forense.
if os.Getenv("BOOM_MID_SETTLEMENT") == "1" {
    panic("se cayó el proceso a mitad de la liquidación")
}
```

Liquida desde la aplicación con `BOOM_MID_SETTLEMENT=1` y después mira la base:

```sql
SELECT s.id, s.raffle_id, s.prize_amount, r.status
FROM settlements s JOIN raffles r ON r.id = s.raffle_id
WHERE s.raffle_id = 1;

SELECT * FROM prize_payouts WHERE settlement_id = (SELECT id FROM settlements WHERE raffle_id = 1);
```

Ahí está el desastre, y vale la pena mirarlo con calma: **existe la liquidación,
existen los pagos, y la rifa sigue en `resolved`.** El dinero está repartido y la
rifa no está liquidada.

Ahora piensa en las consecuencias, que es la parte que importa: alguien va a ver
esa rifa como pendiente y la va a liquidar otra vez. La `UNIQUE` la va a frenar
—gracias, `be02`— pero el operador va a ver un error incomprensible sobre una
rifa que él ve sin liquidar. Nadie va a entender nada, y el rastro de por qué
pasó desapareció con el proceso.

*Paso 2 — con transacción.* Restaura `WithTx` y repite exactamente lo mismo. El
`recover` de `be01` atrapa el pánico, el `defer tx.Rollback()` revierte, y la base
queda **idéntica** a como estaba. Compruébalo con las mismas dos consultas: cero
filas en las dos.

**Ese es el valor entero de una transacción, en dos comandos.** No es una
abstracción académica: es la diferencia entre un martes normal y una tarde
reconstruyendo a mano quién cobró qué.

*Paso 3 — el reintento, que ahora es aburrido.* Con el caos en `high`, liquida
una rifa y deja que la respuesta se pierda. El frontend reintenta. Comprueba en
la base que hay **una** liquidación y **un** juego de pagos, y en el log la línea
de "ya existía: se devuelve la misma". Idempotencia: el reintento dejó de ser un
problema y pasó a ser rutina.

*Paso 4 — rompe el cuadre a propósito.* Cambia `PrizeShare` para que el resto no
se reparta (quita el `shares[i]++`) y liquida una rifa con tres ganadores y un
premio no divisible. La aserción del paso 5 dispara, la transacción revierte, y
**la base queda limpia**. Anota qué habría pasado sin esa aserción: tres pagos que
suman menos que el premio, confirmados, y un descuadre que nadie detecta hasta
que alguien sume a mano.

*Paso 5 — la discrepancia cliente-servidor.* Con la aplicación abierta en dos
pestañas, vende tres números en la primera y liquida en la segunda **sin
recargar**. El cliente calcula con datos viejos. Busca en el log la línea de
`discrepancia`: ahí está, con los dos totales y su `X-Request-Id`.

Esto no es un bug del frontend. Es la demostración de que **el cliente no puede
calcular esto bien**, por más cuidado que ponga, porque no tiene los datos. Pega
esa línea en `dinero.md`: es el argumento entero de §4.2 en tres líneas de log.

---

> 📓🔥 De esta fase salen los incidentes **be-13** y **be-14** de `cuaderno-incidentes-be.md`. El be-13 es hermano del **18** del track base: allá el cálculo arruina datos correctos; acá el cálculo está bien y lo que falla es de cuándo son los datos que entraron.

---

## 🧪 7. Ejercicios (29)

**🟢 Fácil (1–7)**

1. Aplica la migración `000006` y verifica la restricción de `prize_payouts` insertando dos pagos para el mismo número.
2. Liquida una rifa desde la aplicación y comprueba en la base que hay una fila en `settlements` y una en `prize_payouts`.
3. Comprueba que `POST /settlements` dos veces sobre la misma rifa devuelve la misma liquidación, con el mismo `id`.
4. Verifica que la rifa quedó en `settled` y que ocurrió en la misma transacción.
5. Corre `TestPrizeShareSumaExactamenteElTodo` y comprueba que pasa para las 17.000 combinaciones.
6. Liquida una rifa cuyo número ganador **no** se vendió y comprueba que el premio es `0` y no hay pagos.
7. Corre `./server/smoke.sh` y confirma que sigue entero.

**🟡 Intermedio (8–16)**

8. Porta `PrizeShare` y verifica con la tabla de `TestCoherenciaConElFrontend` que da exactamente lo mismo que `settlementMath.js`.
9. **Diagnóstico.** Ejecuta el paso 5 de la pieza forense (dos pestañas) y encuentra la línea de discrepancia en el log.
10. Implementa el recálculo desde `sales` y comprueba que los montos guardados no dependen del cuerpo, mandando un `POST` con montos inventados.
11. **Diagnóstico.** Manda un `POST /settlements` con `margin: 999999` y determina qué se guarda y qué queda en el log.
12. Escribe la prueba que verifica que liquidar dos veces no crea dos filas, con las dos peticiones concurrentes.
13. **Diagnóstico.** Quita el bloqueo `FOR UPDATE` sobre la rifa y lanza dos liquidaciones simultáneas. Describe qué pasa y quién te salva.
14. Agrega a `prize_payouts` el `sold_by` del vendedor del número ganador, aprovechando `sales`. Justifica si eso es información útil o ruido.
15. **Diagnóstico.** Liquida una rifa en estado `open` y comprueba que la transición ilegal la frena el service de `be04`, no el handler.
16. Verifica que el `settledAt` guardado es el del servidor y no el del cliente, y encuentra en el log el desfase (`be06`).

**🟠 Difícil (17–25)**

17. **Diagnóstico.** Ejecuta los pasos 1 y 2 de la pieza forense y escribe el informe de la liquidación interrumpida, con las consultas y sus salidas en los dos casos.
18. **Diagnóstico.** Ejecuta el paso 4 (romper el cuadre) y documenta qué habría pasado sin la aserción. Estima cuánto tardaría alguien en detectarlo en producción.
19. Implementa el caso de varios ganadores de punta a punta: vende el mismo número a… espera, no puedes. Explica por qué `be05` hace imposible que dos personas tengan el número ganador, y rediseña el escenario multi-ganador de forma que tenga sentido en este dominio (pista: mira qué pasaría si la lotería devolviera dos números ganadores).
20. Argumenta si `PrizeShare` debería ordenar por antigüedad de compra, por id de participante, o por número. Decide, impleméntalo, y defiende la elección como se la defenderías a alguien que se quedó sin el centavo extra.
21. **Diagnóstico.** Compara la secuencia del thunk de la Fase 8 (`POST` y después `dispatch`) con la transacción del servidor. Construye el escenario donde el store y la base discrepan, y determina si hoy es posible y por qué.
22. Escribe la consulta que audita todas las liquidaciones existentes y reporta cualquiera cuyos pagos no sumen su `prizeAmount`. Debería devolver cero filas; déjala en `dinero.md` como consulta de auditoría.
23. **Diagnóstico.** Determina qué pasa si alguien borra una fila de `sales` después de liquidar. ¿Se detecta? ¿Con qué consulta? Argumenta si `sales` debería ser inmutable a nivel de permisos y no solo por convención.
24. **Diagnóstico.** Provoca el desbordamiento de `int64` con un `numberPrice` absurdo y un `soldCount` enorme. Determina qué se guarda, y agrega la comprobación de rango que lo impide. Compara el comportamiento con lo que haría el `number` de JavaScript.
25. Escribe `dinero.md`: qué garantiza cada capa (frontend, servicio, base), qué de `A10` no se pudo sostener igual de este lado, y qué invariantes se pueden verificar con una consulta.

**🔴 Muy difícil (26–29)**

26. Diseña la prueba basada en propiedades que verifique, para entradas generadas al azar, que recaudo, premio y margen siempre cumplen `margin == totalCollected - prizeAmount` y que los pagos suman el premio. Explica por qué esta clase de prueba es especialmente apropiada para dinero.
27. Diseña el mecanismo de **corrección** de una liquidación errónea sin borrar nada: qué tabla, qué campos, cómo se calcula el saldo vigente, y cómo se presenta. Argumenta por qué la contabilidad lleva cuatrocientos años haciéndolo con asientos de compensación y no con un `UPDATE`.
28. **Diagnóstico + regresión.** Ticket: *"la liquidación de la rifa de agosto dice que recaudamos 340.000 y el listado de ventas suma 355.000"*. Enumera las causas candidatas ordenadas por probabilidad —incluida la posibilidad de que ninguna sea un bug—, di cómo descartas cada una con una consulta, y escribe la regresión.
29. **Post-mortem.** Escribe el post-mortem de *"repartimos el premio dos veces"* según la guía §13, ubicando la causa raíz en la falta de idempotencia ante un reintento del cliente con el mock caótico. La prevención tiene que distinguir la restricción de la base, el comportamiento idempotente y la consulta de auditoría, y explicar qué cubre cada uno.

**🔥 Opcionales**

- 🔥 Implementa el `GET /stats` que la Fase 9 calcula hoy en el navegador —margen total, top de números, liquidaciones por día— y mide cuánto más rápido es agregarlo en SQL con veinte mil ventas. Después responde la pregunta incómoda: ¿mereció la pena, sabiendo que ningún cliente lo consume?
- 🔥 Agrega un `CHECK` a nivel de base que impida que `margin` difiera de `total_collected - prize_amount`. Discute si una invariante debe vivir en la base, en el código, o en las dos.
- 🔥 Reescribe los montos como `NUMERIC(14,2)` en una rama y mide qué cambia: rendimiento, código de conversión y riesgo de perder centavos en la frontera. Decide con datos.

---

## 📚 8. Referencias

**Documentación oficial**
- https://www.postgresql.org/docs/13/datatype-numeric.html — rangos de `BIGINT` y semántica de `NUMERIC`, para el debate de §4.1.
- https://www.postgresql.org/docs/13/tutorial-transactions.html y https://www.postgresql.org/docs/13/sql-begin.html — atomicidad, que es lo que la pieza forense demuestra.
- https://www.postgresql.org/docs/13/ddl-constraints.html — `CHECK`, `UNIQUE` y `ON DELETE RESTRICT`.
- https://pkg.go.dev/math/bits#Add64 — para la comprobación de desbordamiento del ejercicio 24.
- https://martinfowler.com/eaaDev/AccountingNarrative.html y https://martinfowler.com/eaaDev/AccountingEntry.html — los patrones contables detrás de §4.4 y del ejercicio 27. Son de hace veinte años y no han envejecido un día.

**Libros**
- *Patterns of Enterprise Application Architecture* (Martin Fowler) — el patrón *Money* y por qué el dinero merece un tipo propio.
- *Designing Data-Intensive Applications* (Kleppmann) — el capítulo 7, otra vez: la definición precisa de atomicidad es la que hace entender la pieza forense.

**Video / apoyo**
- Busca "floating point money bugs" y "event sourcing vs CRUD" en YouTube. Lo segundo es el pariente grande de §4.4: no lo necesitas acá, pero conocerlo aclara por qué modelar hechos escala mejor que modelar estados.

**Orden de lectura sugerido:** relee `A10` §2 y §4 primero, que es de donde sale
todo lo de esta fase → el artículo de *Accounting Entry* de Fowler, que explica
§4.4 mejor que yo → la documentación de transacciones de Postgres si la pieza
forense te deja con dudas → y el capítulo 7 de Kleppmann cuando quieras la teoría
completa.

> ⚠️ URLs, títulos y ediciones pueden haber cambiado: verifícalos. Las
> referencias a libros son de memoria y pueden ser inexactas. La documentación de
> Postgres tiene una versión por URL; fija el 13. Cualquier discrepancia de
> versiones la resuelve `prompts/decisiones-y-versiones.md` §7.

---

## 🚀 9. Cierre y conexión con la siguiente fase

El dominio está completo del lado del servidor. La aritmética de `A10` vive
ahora a los dos lados del cable con las mismas reglas y las mismas pruebas; los
montos se recalculan desde los hechos en vez de creerle a nadie; el reparto
cuadra al centavo y la transacción lo verifica antes de confirmar; liquidar dos
veces es imposible y reintentar es aburrido; y quién cobró cuánto quedó escrito
en un registro que no se pisa.

Tres deudas del track base pagadas en tres fases seguidas, y siempre la misma
forma: **el cliente propone, el servidor dispone, y la diferencia se mide.**
Identidad en `be04`, reloj en `be06`, dinero en `be07`.

`be08` cambia de tema. Ya no se agrega comportamiento: se demuestra que el que
hay es cierto. Pruebas de handlers con `httptest`, la suite de contrato que
verifica el checklist de `be00` endpoint por endpoint, integración contra Postgres
en contenedor, concurrencia con goroutines, `go test -race` — y el contenido
central, que es una regla y su demostración: **una prueba que pasa en SQLite y
falla en Postgres, y otra que hace exactamente lo contrario**. Toda la evidencia
que vienes acumulando desde `be02` converge ahí.

> **La señal de que quedó bien:** *"puedo matar el proceso en cualquier
> milisegundo de una liquidación y la base nunca queda a medias."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-be07-liquidacion-dinero-entero-y-transaccional -m "be07 cerrada: \
> prize_payouts como registro inmutable con su restricción; montos recalculados desde sales; \
> discrepancia cliente-servidor registrada; liquidación en una sola transacción; \
> idempotencia ante reintentos; PrizeShare coherente con A10 y probado por propiedad; \
> aserción de cuadre dentro de la transacción; server/evidence/dinero.md escrito"
> ```
>
> Los commits de la fase llevan su prefijo (`be07: …`) y los de ejercicio su
> número (`be07 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/be07/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

*(Fuera de lo que lee el estudiante.)*

- **Registrar en `prompts/diccionario-codigo-ingles.md` §7bis.1** la entidad
  `PrizePayout` / `prize_payouts`, y en §7bis.2 los nombres de la aritmética
  (`TotalCollected`, `PrizeAmount`, `Margin`, `PrizeShare`), que son la
  traducción literal de los de `settlementMath.js` y **tienen que seguir
  siéndolo**.
- **Coherencia con `A10`, verificada y con una excepción.** Las reglas se
  portaron sin cambios; lo único que no se sostiene igual es el desbordamiento:
  `int64` desborda en silencio donde el `number` de JS pierde precisión de forma
  más ruidosa. Está anotado en `dinero.md` y medido en el ejercicio 24. Si `A10`
  se revisa alguna vez, esto debería aparecer allá también.
- **Tres cambios observables acumulados** que `CONTRACT.md` recoge y `be08` debe
  verificar: el `settledAt` del servidor (`be06`), los montos recalculados
  (`be07`) y la idempotencia del `POST /settlements` (`be07`). Los tres son
  deliberados y los tres tienen su motivo escrito.
- **El `GET /stats` sigue siendo pendiente 🔥 de `be09`** y ninguna fase depende
  de él. El ejercicio 🔥 de esta fase lo adelanta, con la pregunta honesta de si
  merece la pena construir algo que ningún cliente consume.
- **`be08` hereda de esta fase:** la prueba por propiedades de `PrizeShare` (que
  es la única del track que prueba una propiedad y no casos), la consulta de
  auditoría del ejercicio 22 y la tabla de coherencia con el frontend. Esa última
  es candidata a correr en CI: es la que detecta que alguien cambie una regla en
  una sola orilla.
- **`be09` hereda para el veredicto:** que las tres fases del dominio —`be05`,
  `be06`, `be07`— no agregaron **ni una dependencia** al `go.mod`. Concurrencia,
  tiempo y dinero se resolvieron con la biblioteca estándar y el motor. Es un
  dato para el veredicto honesto y dice mucho sobre dónde vive la complejidad
  real.
- **Deudas declaradas:** 💸 `sales` es inmutable por convención y no por permisos
  (ejercicio 23); 💸 no hay mecanismo de corrección de una liquidación errónea
  (ejercicio 27 lo diseña, no lo implementa); 💸 no hay comprobación de
  desbordamiento en el cálculo del recaudo hasta que el alumno la agrega.
- **Reserva para el cuaderno de incidentes:** `be-13` — *"la liquidación dice
  340.000 y las ventas suman 355.000"* (categoría 🔥 dinero, dificultad 🟠), el
  ejercicio 28; y `be-14` — *"repartimos el premio dos veces"* (categoría 🔥
  transacciones, dificultad 🔴), el ejercicio 29, que es el hermano del incidente
  18 del track base —*la liquidación da un centavo de diferencia*— resuelto en la
  otra capa y con consecuencias mucho peores.
