# 🕰️ Fase be06 — Hora dura, zonas horarias y la autoridad del reloj

> Tutorial React 16 — Rifas y chances · **Track BE opcional 🔥** · Fase be06 de be09 · **8 horas**
> Depende de: be05 — la venta ya está protegida · Habilita: be07 — Liquidación transaccional

---

## 🎯 1. Propósito

`be05` movió al servidor la autoridad sobre **quién se queda con un número**.
Esta fase mueve la otra autoridad que el sistema tenía prestada al navegador:
**la del reloj**.

Hoy, la regla más dura del negocio —*no se vende un número después de `closesAt`,
ni un segundo*— la evalúa `isPastClosing(closesAt, new Date())` en el cliente. Y
`new Date()` es la hora del equipo del usuario. Un reloj de cliente es un reloj
que el usuario controla: se adelanta con dos clics en el panel de configuración
del sistema operativo, y con eso se compra un número de una rifa cerrada.

> 🧭 **La regla de negocio la aplica quien tiene el dato, no quien tiene la
> pantalla.** El frontend puede —y debe— decidir si muestra el botón. Solo el
> servidor puede decidir si la venta ocurre.

La Fase 7 del track base lo dijo con todas las letras y dejó la deuda 💸 anotada:
*"si el usuario tiene la hora mal, el cierre se corre con ella… sincronizar
contra el reloj del servidor es lo correcto en producción y queda pendiente"*.
Incluso dejó el ejercicio 27 preguntando qué fase debería pagarlo. Es esta.

Y de paso vas a entender qué hace **realmente** PostgreSQL con `TIMESTAMPTZ`, que
es donde casi todo el mundo —incluido gente con quince años de SQL— tiene un
modelo mental equivocado.

> 🩻 **Lectura previa obligatoria:** la Fase 7 del track base. Y ten a mano la
> Divergencia 2 de `be02`, que ya midió lo que acá se explica.

---

## ✅ 2. Qué queda listo al terminar

- [ ] Está decidida y documentada la política de zona horaria del proceso y de la
      sesión de base, y el `closesAt` que sale por la API es **idéntico** al que
      devolvía el mock.
- [ ] La hora de cierre se evalúa **en el servidor**, dentro de la misma
      transacción que la venta, y una venta tardía devuelve `409` con un mensaje
      que el frontend ya sabe mostrar.
- [ ] Existe una prueba que vende un milisegundo antes y un milisegundo después
      del cierre, con un reloj inyectado y no con `time.Now()`.
- [ ] Hay un trabajo que cierra por reloj las rifas cuya `closesAt` pasó, y la
      transición `open → closed` que `be04` custodiaba por orden ahora también se
      dispara por tiempo.
- [ ] `POST /settlements` sella `settledAt` con el reloj del servidor, y el
      desfase contra el que mandó el cliente queda registrado en el log.
- [ ] Existe `server/evidence/reloj.md` con la medición del desfase
      cliente-servidor y la evidencia de la pieza forense.
- [ ] La deuda 💸 que **no** se paga —el frontend sigue mirando su propio reloj
      para pintar la UI— está declarada con lo que costaría pagarla.
- [ ] `./server/smoke.sh` sigue entero y el frontend sigue sin tocarse.

---

## 🚫 3. Qué queda fuera por ahora

- **El mock de lotería del `3002`.** No se reescribe en Go, ni ahora ni nunca. Es
  un proveedor externo, tiene su propio perfil de fallo, y el `pollingEpic` de la
  Fase 7 le habla con una instancia de `axios` aparte. **Esa frontera se
  conserva**, y conservarla es contenido: un backend propio no absorbe a sus
  proveedores porque le quede cómodo.
- **Que el frontend consuma un `serverNow`.** Requeriría tocar `apiClient.js` y
  sus interceptores, y eso excede la excepción `D27`. Se declara como deuda viva
  con su costo estimado (§5.6).
- **Librerías de fecha.** Ni en el backend ni en el frontend. `time` de la
  biblioteca estándar alcanza y sobra.
- **Horarios recurrentes o programación de cierres.** Una rifa tiene un instante
  de cierre y ya. Si aparecen reglas de calendario —"todos los viernes a las
  22:00 hora local"—, ahí sí hace falta guardar la zona además del instante, y
  eso es una conversación distinta que `bea-06` deja planteada.

---

## 🧠 4. Conceptos mínimos

Sabes qué es UTC y has sufrido zonas horarias. Vamos directo a las tres cosas que
casi nadie tiene bien.

### 4.1 `TIMESTAMPTZ` no guarda ninguna zona horaria

Empecemos por el malentendido, porque es el que produce las facturas.

`TIMESTAMP WITH TIME ZONE` **no almacena una zona horaria**. El nombre es
desafortunado hasta el punto de ser engañoso. Lo que guarda es un **instante**,
internamente en UTC, con la misma cantidad de bytes que un `TIMESTAMP` normal. La
zona aparece solo en dos momentos:

- **Al entrar:** si el valor trae offset, Postgres lo usa para convertir a UTC. Si
  **no** lo trae, asume la zona de la sesión (`SHOW TimeZone`).
- **Al salir:** convierte el instante a la zona de la sesión y lo muestra así.

De ahí se sigue la propiedad que hace correcto usarlo: **dos valores que
representan el mismo instante son iguales**, sin importar con qué offset se
escribieron. `'2026-08-30 22:00:00-05'` y `'2026-08-31 03:00:00+00'` son el mismo
dato, y `=` los declara iguales.

Y el contraste, que es lo que hay que tener grabado:

📖 **`TIMESTAMPTZ` guarda un instante. `TIMESTAMP` guarda un número que parece
una fecha.** Un `TIMESTAMP` sin zona es "las 22:00" sin decir de dónde: no
identifica ningún momento del universo, y compararlo con otro es comparar dos
opiniones. Ordenar por él da resultados sin sentido en cuanto hay más de una
zona en juego.

> 🧭 **La regla operativa, sin excepciones para este dominio.** Todo instante va
> en `TIMESTAMPTZ`. `TIMESTAMP` sin zona solo sirve para fechas de calendario
> —un cumpleaños, un feriado— que no son instantes y que este sistema no tiene.
>
> ⚠️ Y el detalle que muerde: **la zona de la sesión afecta a la salida**. Dos
> aplicaciones leyendo la misma fila pueden ver `22:00-05:00` y `03:00+00:00`, y
> las dos tienen razón. Si tu código compara *strings* de fecha, acabas de heredar
> un bug que depende de la configuración del servidor. Es, exactamente, la
> Divergencia 2 de `be02` — y también el error común nº 2 de `be03`, que tapamos
> con una línea en el DSN y que ahora toca resolver de verdad.

### 4.2 El instante es la verdad; el offset de la serialización es cosmética

El contrato de `be00` fija que `closesAt` sale como `"2026-08-30T22:00:00-05:00"`,
con offset y no con `Z`. Y `be05` te enseñó que el frontend compara instantes con
`new Date(...).getTime()`, así que **el offset con el que se serialice le da
exactamente igual**: `Z` o `-05:00` producen el mismo `Date`.

Entonces, ¿por qué respetar el formato? Por dos razones que no son la corrección
semántica:

1. **Verificabilidad.** El criterio de `be03` fue que la respuesta sea idéntica a
   la del mock. Una diferencia cosmética consume la misma atención que una real
   cuando estás diagnosticando, y no hay ninguna razón para regalarla.
2. **Legibilidad humana.** Cualquiera que mire un log o una respuesta a las tres
   de la mañana lee `22:00-05:00` sin hacer aritmética.

> 🧭 **Decisión de la fase.** El proceso corre en **UTC** (`TZ=UTC`), todas las
> comparaciones internas se hacen entre instantes, y la sesión de base fija
> `TimeZone=America/Bogota` **solo para que la serialización de salida coincida
> con el contrato**. Se registra así, con esa jerarquía explícita: la zona de
> presentación no participa en ninguna decisión.

### 4.3 Dónde se aplica una regla de tiempo

Hay tres lugares donde se puede comprobar que una rifa cerró, y los tres son
necesarios y distintos:

**En la interfaz**, para no ofrecer lo imposible. Es cortesía, no protección: el
usuario controla ese reloj.

**En el servicio, dentro de la transacción de venta.** Es **la** protección, y
por eso va exactamente ahí: no en el handler, no antes de abrir la transacción,
sino junto a las demás comprobaciones y bajo el mismo bloqueo que `be05` montó.
Si se comprueba antes, hay una ventana entre "comprobé que estaba abierta" y
"vendí" — el mismo *check-then-act* de `be05`, con el reloj en vez del estado.

**En un trabajo periódico**, para que el estado del sistema refleje la realidad
aunque nadie pida nada. Sin él, una rifa cuyo cierre pasó a las 22:00 sigue
diciendo `open` hasta que alguien intente venderle algo.

Fíjate en la simetría con `be05`: la comprobación en la transacción es el
`FOR UPDATE`, y el trabajo periódico es el hermano del *worker* que vence
reservas. Los patrones se repiten porque los problemas se repiten.

### 4.4 El reloj es una dependencia, y se inyecta

Una función que llama a `time.Now()` por dentro **no se puede probar** en sus
casos interesantes, que son justamente los bordes: un milisegundo antes del
cierre, un milisegundo después, el instante exacto.

La solución es tratar el reloj como lo que es —una dependencia externa, igual que
la base— y pasarlo:

```go
// Clock existe para poder mentirle al servicio en las pruebas.
// Una interfaz de un solo método puede parecer exagerada; es lo que
// convierte "esto es difícil de probar" en un test de cuatro líneas.
type Clock interface {
	Now() time.Time
}

type systemClock struct{}
func (systemClock) Now() time.Time { return time.Now().UTC() }

// fixedClock, para pruebas: el tiempo se para donde tú quieras.
type fixedClock struct{ t time.Time }
func (c fixedClock) Now() time.Time { return c.t }
```

Y un detalle de Go que conviene conocer antes de que te muerda: `time.Now()`
devuelve un valor con **reloj monótono** adjunto, pensado para medir duraciones.
Ese reloj no sobrevive a una ida y vuelta a la base ni a una serialización, y hace
que `==` entre dos `time.Time` que representan el mismo instante devuelva
`false`. **Para comparar instantes se usa `Equal`, `Before` y `After`, nunca los
operadores.**

---

## 💻 5. Implementación y código comentado

### 5.1 La política de zona, escrita en un solo lugar

```go
// server/cmd/api/main.go (extracto)

func main() {
	// El proceso vive en UTC. No es cosmética: fija que time.Now() dentro
	// del backend sea siempre el mismo instante expresado igual, sin
	// importar cómo esté configurada la máquina del alumno, el contenedor
	// o el runner de CI. Un backend cuyo comportamiento depende de la
	// configuración regional del host es un backend que falla distinto en
	// cada ambiente.
	os.Setenv("TZ", "UTC")

	cfg, err := config.Load()
	// …
}
```

```go
// server/internal/storage/storage.go (extracto de Open, rama Postgres)

// La sesión de base se fija explícitamente. NO es lo mismo que la zona del
// proceso y no cumple la misma función:
//
//   - el proceso en UTC   → decide y compara instantes
//   - la sesión en Bogotá → SERIALIZA la salida con el offset -05:00 que
//                           el contrato de be00 fija
//
// Que estén separadas y nombradas evita el error clásico: creer que
// cambiar una arregla lo que hace la otra. Y fijarlas explícitamente evita
// el error peor: que el comportamiento dependa de cómo esté configurado el
// Postgres que te tocó.
if dialect == Postgres {
	if _, err := db.ExecContext(ctx, "SET TIME ZONE 'America/Bogota'"); err != nil {
		return nil, fmt.Errorf("fijando la zona de la sesión: %w", err)
	}
}
```

> 📝 Esto **reemplaza** el parche del error común nº 2 de `be03` —aquel
> `?timezone=…` metido en el DSN para que el `closesAt` volviera con el offset
> correcto—. Aquello tapaba un síntoma sin decidir nada; esto es una política con
> dos niveles y una razón para cada uno.

### 5.2 La hora dura, dentro de la transacción de venta

```go
// server/internal/rafflenumber/service.go

var ErrRaffleClosed = errors.New("la rifa ya cerró")

func (s *Service) SellNumber(ctx context.Context, raffleID int64, number string, participantID *int64) (RaffleNumber, error) {
	soldBy := httpapi.UserIDFrom(ctx)
	if soldBy == 0 {
		return RaffleNumber{}, ErrUnauthenticated
	}

	var sold RaffleNumber
	err := s.store.WithTx(ctx, func(tx Tx) error {
		// 🧭 LA HORA SE COMPRUEBA ACÁ ADENTRO, y la posición no es un
		// detalle de estilo.
		//
		// Comprobar antes de abrir la transacción reabre exactamente el
		// check-then-act que be05 acaba de cerrar: entre "vi que estaba
		// abierta" y "vendí" cabe el cierre. La ventana es pequeña y
		// justamente por eso el bug sería intermitente, que es la peor
		// clase de bug.
		raffle, err := tx.FindRaffleForShare(ctx, raffleID)
		if err != nil {
			return err
		}

		now := s.clock.Now()

		// Comparación de INSTANTES con After. Nunca strings, nunca
		// componentes de fecha, nunca ==.
		//
		// El borde: si now == closesAt exactamente, ¿se vende? El track
		// base ya lo decidió en isPastClosing con `>=`, o sea NO se vende.
		// Se replica esa decisión, y se replica a propósito: dos capas que
		// contestan distinto en el borde producen el ticket más difícil de
		// diagnosticar que existe.
		if !now.Before(raffle.ClosesAt) {
			return fmt.Errorf("cerró a las %s y ahora son las %s: %w",
				raffle.ClosesAt.Format(time.RFC3339), now.Format(time.RFC3339), ErrRaffleClosed)
		}

		// A partir de acá, exactamente lo de be05.
		current, err := tx.FindOneForUpdate(ctx, raffleID, number)
		if err != nil {
			return err
		}
		if current.Status == "sold" {
			return ErrAlreadySold
		}
		if err := tx.InsertSale(ctx, raffleID, number, participantID, soldBy); err != nil {
			return err
		}
		sold, err = tx.MarkSold(ctx, raffleID, number, participantID)
		return err
	})
	if err != nil {
		return RaffleNumber{}, err
	}
	return sold, nil
}
```

> 🧠 **`FOR SHARE` y no `FOR UPDATE` sobre la rifa.** Solo necesitamos que nadie
> **cambie** la `closesAt` mientras vendemos, no bloquear a los demás vendedores
> entre sí. `FOR UPDATE` sobre la rifa serializaría **todas** las ventas de esa
> rifa contra una sola fila, y acabaríamos de tirar a la basura la granularidad
> que `be05` consiguió. Es el error común nº 4 de `be05` disfrazado de prudencia.

Y el handler, que traduce el error nuevo:

```go
case errors.Is(err, rafflenumber.ErrRaffleClosed):
	// 409 y no 400: la petición está bien formada, el estado del recurso
	// no permite lo que pide. Es la misma semántica del 409 de venta
	// duplicada, y eso importa porque toReadableError de la Fase 5 ya
	// mapea 409 al type 'conflict' y muestra el message. El frontend
	// heredado maneja este caso nuevo sin saber que existe.
	writeError(w, http.StatusConflict, "La rifa ya cerró: no se pueden vender más números")
```

### 5.3 El trabajo que cierra por reloj

```go
// server/internal/raffle/closing.go

// StartClosingWorker cierra las rifas cuya hora pasó.
//
// Sin esto, una rifa cerrada a las 22:00 sigue diciendo "open" hasta que
// alguien intente venderle algo. El estado del sistema tiene que reflejar
// la realidad aunque nadie pregunte — y en este dominio importa el doble,
// porque el pollingEpic de la Fase 7 arranca a buscar el resultado del
// sorteo cuando la rifa cierra.
func StartClosingWorker(ctx context.Context, store Store, clock Clock, every time.Duration) {
	go func() {
		ticker := time.NewTicker(every)
		defer ticker.Stop()
		for {
			select {
			case <-ctx.Done():
				log.Println("[closing] worker detenido")
				return
			case <-ticker.C:
				closed, err := store.CloseExpiredRaffles(ctx, clock.Now())
				if err != nil {
					log.Printf("[closing] error cerrando rifas: %v", err)
					continue
				}
				for _, id := range closed {
					log.Printf("[closing] rifa %d cerrada por reloj", id)
				}
			}
		}
	}()
}
```

```sql
-- CloseExpiredRaffles. Una sola sentencia, sin leer antes, idempotente.
--
-- El WHERE status = 'open' hace dos trabajos: filtra, y garantiza que la
-- transición sea exactamente la que be04 declaró legal (open → closed).
-- No hay forma de que este UPDATE produzca una transición ilegal, y eso es
-- mejor que confiar en que quien lo escribió se acordara de la tabla.
UPDATE raffles
SET status = 'closed', updated_at = now()
WHERE status = 'open' AND closes_at <= $1
RETURNING id;
```

> ⚠️ **Esto es comportamiento nuevo y observable**, igual que el *enforcement* de
> autenticación de `be04`: el mock nunca cerró una rifa solo. Va al **régimen de
> crecimiento** porque nada del frontend se rompe —la Fase 7 ya trata como
> cerrada cualquier rifa cuya `closesAt` pasó, así que el `status` que llega
> ahora **coincide** con lo que la UI ya calculaba— pero mídelo en el recorrido
> antes de darlo por bueno y anótalo en `CONTRACT.md`.
>
> Y algo que conviene notar: con este *worker*, el `status: 'closed'` y el
> `isPastClosing` del cliente por fin dicen lo mismo. La Fase 7 necesitaba las dos
> condiciones (`selectIsRaffleClosedByStatus(id) || isPastClosing(closesAt)`)
> precisamente porque el backend no cerraba nada. Sigue necesitándolas —el
> *worker* tarda hasta un tick— pero ahora la redundancia protege un desfase de
> segundos en vez de una mentira permanente.

### 5.4 El `settledAt` que ahora sella el servidor

`be03` descubrió que el cuerpo de `POST /settlements` trae un `settledAt`
calculado con `new Date().toISOString()` en el navegador, y lo guardó tal cual con
una deuda 💸 anotada. Se paga acá.

```go
// server/internal/settlement/service.go

func (s *Service) Create(ctx context.Context, in Settlement) (Settlement, error) {
	serverNow := s.clock.Now()

	// El instante en que ocurre un hecho de negocio lo fija quien lo
	// registra, no quien lo pide. Si el cliente manda su propia hora, se
	// MIDE la diferencia y se registra — pero no se usa.
	if in.SettledAt != nil {
		skew := serverNow.Sub(*in.SettledAt)
		if skew < -30*time.Second || skew > 30*time.Second {
			// Un desfase grande no es un error del usuario: es un dato de
			// diagnóstico valiosísimo. Cuando alguien reporte "me cerró la
			// rifa antes de tiempo", esta línea del log es la primera que
			// hay que buscar.
			log.Printf("[req-id %s] desfase de reloj: el cliente dice %s, el servidor %s (%s de diferencia)",
				httpapi.RequestIDFrom(ctx), in.SettledAt.Format(time.RFC3339),
				serverNow.Format(time.RFC3339), skew)
		}
	}
	in.SettledAt = &serverNow

	return s.store.Insert(ctx, in)
}
```

> ⚠️ **Esto cambia un valor observable**, y hay que decirlo sin adornos: el
> `settledAt` que vuelve en la respuesta ya no es el que mandó el cliente. Lo
> aceptamos porque es exactamente la autoridad que la fase reclama, y porque el
> único consumidor de ese campo es el ejercicio 🔥 de series temporales de la
> Fase 9 — que además **mejora**: agrupar por un reloj de servidor es correcto y
> agrupar por relojes de clientes distintos no lo es.
>
> Regístralo en `CONTRACT.md` como cambio deliberado, con su motivo. Es la clase
> de decisión que en seis meses alguien va a cuestionar, y va a merecer una
> respuesta escrita.

### 5.5 Probar el borde, con el reloj en la mano

```go
// server/internal/rafflenumber/closing_test.go

func TestSellNumberRespetaLaHoraDura(t *testing.T) {
	closesAt := mustParse(t, "2026-08-30T22:00:00-05:00")

	casos := []struct {
		nombre string
		ahora  time.Time
		quiere error
	}{
		{"un segundo antes", closesAt.Add(-time.Second), nil},
		{"un milisegundo antes", closesAt.Add(-time.Millisecond), nil},
		// El borde exacto. La decisión (no se vende) se hereda de
		// isPastClosing en la Fase 7, y este test es lo que impide que
		// alguien la cambie sin darse cuenta de que hay otra capa que
		// depende de ella.
		{"el instante exacto", closesAt, rafflenumber.ErrRaffleClosed},
		{"un milisegundo después", closesAt.Add(time.Millisecond), rafflenumber.ErrRaffleClosed},

		// Y el que de verdad importa: la misma hora de pared, otra zona.
		// Si este test pasa, ninguna comparación de tu código está mirando
		// componentes de fecha. Si falla, encontraste el bug de medianoche
		// antes que un usuario.
		{"el mismo instante escrito en UTC",
			mustParse(t, "2026-08-31T03:00:00Z"), rafflenumber.ErrRaffleClosed},
	}

	for _, c := range casos {
		t.Run(c.nombre, func(t *testing.T) {
			svc := newServiceWithClock(t, fixedClock{c.ahora})
			_, err := svc.SellNumber(ctxConUsuario(1), 1, "0347", nil)
			if !errors.Is(err, c.quiere) {
				t.Errorf("con ahora=%s: esperaba %v, obtuve %v", c.ahora, c.quiere, err)
			}
		})
	}
}
```

### 5.6 La deuda que **no** se paga, y su precio

El backend ya no se puede engañar. El frontend, sí.

Con el reloj del navegador adelantado tres horas, la interfaz va a mostrar la
rifa como cerrada antes de tiempo y va a ocultar el botón de vender. El usuario
no puede comprar algo que sí estaba disponible. Nada se corrompe —el servidor
nunca se enteró— pero el usuario pierde una venta legítima y no entiende por qué.

Pagarlo requiere que el servidor mande su hora y que **el cliente la use**: el
`serverNow` que la Fase 7 dejó anotado. La primera mitad es gratis y la vamos a
hacer; la segunda toca `apiClient.js` y sus interceptores, y eso excede la
excepción `D27`.

```go
// La mitad que sí podemos: el servidor publica su hora en cada respuesta.
// El header Date es estándar de HTTP y ya viaja; agregamos uno explícito y
// con precisión de milisegundos porque el Date tiene resolución de segundo.
//
// Hoy NADIE lo consume. Se pone igual, y no es un adorno: es el punto
// exacto donde la deuda se vuelve barata de pagar. El día que alguien
// pueda tocar el frontend, el trabajo del lado del servidor ya está hecho.
w.Header().Set("X-Server-Time", s.clock.Now().Format(time.RFC3339Nano))
```

> 💸 **Deuda declarada: el frontend sigue mirando su propio reloj para pintar la
> interfaz.** Consecuencia: con el reloj del cliente desfasado, la UI ofrece o
> esconde el botón de venta en el momento equivocado, aunque el servidor decida
> siempre bien. Costo de pagarla: un interceptor de respuesta que guarde el
> desfase contra `X-Server-Time` y una función `serverNow()` que lo aplique —
> unas treinta líneas en `apiClient.js` y `closing.js`. **No se hace porque
> tocaría el frontend**, y ampliar la excepción `D27` una segunda vez la
> convertiría en una licencia general. Va al mapa de deuda de `bea-09` y al
> veredicto honesto de `be09`.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. Comparar componentes de fecha.** Síntoma: la rifa cierra una hora antes, o
deja vender pasada la medianoche, y solo para algunos usuarios. Causa: alguien
extrajo el día o la hora en vez de comparar instantes. Fix: `Before` / `After`
sobre `time.Time`. Es el mismo error que el track base documenta en su Fase 7
—`getHours()`— reencarnado en Go, y aparece siempre que alguien intenta "hacerlo
más legible".

**2. `==` entre dos `time.Time`.** Síntoma: un test falla comparando dos fechas
que se ven idénticas en el mensaje de error. Causa: el reloj monótono adjunto, y
la zona. Fix: `Equal`. Regla: **en Go, `time.Time` no se compara con
operadores**, jamás.

**3. Comprobar la hora fuera de la transacción.** Síntoma: cada tanto se cuela una
venta unos milisegundos tarde. Causa: el *check-then-act* de `be05`, con el reloj
en vez del estado. Fix: mover la comprobación adentro, como en 5.2. Corrección
mínima frente a refactorización: mover tres líneas es la corrección; discutir si
el reloj debería ser parte del `Tx` es la refactorización, y no hace falta.

**4. Guardar en `TIMESTAMP` sin zona.** Síntoma: todo funciona en desarrollo y
las horas se corren en producción. Causa: el servidor de desarrollo está en la
misma zona que tú y el de producción está en UTC, así que la ambigüedad no se
nota hasta que se nota. Fix: `TIMESTAMPTZ` siempre. Y desconfía del `down` de una
migración que cambie el tipo: la conversión **reinterpreta** los datos existentes.

**5. Dejar que la zona de la sesión decida algo.** Síntoma: el mismo dato produce
resultados distintos según quién consulte. Causa: comparar contra un literal de
fecha sin offset, que Postgres interpreta en la zona de la sesión. Fix: pasar
siempre instantes por placeholder desde Go, nunca literales de fecha en el SQL.

**6. Confiar en que el *worker* cerró a tiempo.** Síntoma: una venta se cuela
segundos después del cierre. Causa: usar `status = 'open'` como la comprobación de
la hora dura. Fix: las dos condiciones, y la que manda es el reloj. **El *worker*
mantiene el estado al día; no es la regla.**

### 🩻 Pieza forense de esta fase

**Adelanta el reloj del navegador y mira cómo las dos capas se contradicen.**

Es la demostración de una sola pantalla de por qué la autoridad temporal vive del
lado del servidor.

*Preparación.* Toma una rifa abierta y pon su `closesAt` unos minutos en el
futuro:

```sql
UPDATE raffles SET closes_at = now() + interval '5 minutes' WHERE id = 1;
```

*Paso 1 — el reloj adelantado.* Adelanta el reloj del sistema operativo **una
hora** (desactiva la sincronización automática) y recarga la aplicación.

La rifa aparece **cerrada**. `isPastClosing` compara contra `new Date()`, que
ahora miente. El botón de vender no está. Anótalo: **el usuario acaba de perder
una venta legítima y el sistema no tiene forma de saberlo**.

*Paso 2 — el servidor no se enteró.* Sin tocar el reloj, desde otra máquina o
con `curl`:

```bash
curl -s -X POST localhost:3001/raffles/1/numbers/1500/sell \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -d '{"participantId":null}' | jq
```

`200`. Se vendió. El servidor sabe qué hora es.

*Paso 3 — ahora al revés, que es el caso peligroso.* **Atrasa** el reloj del
navegador una hora y espera a que la rifa cierre de verdad. La interfaz sigue
mostrando el botón de vender, el usuario hace clic con toda confianza, y el
backend responde `409` con "La rifa ya cerró".

**Esta es la escena que resume la fase.** Antes de `be06`, ese clic habría
funcionado: se habría vendido un número de una rifa cerrada, y el desajuste
habría aparecido semanas después, en la liquidación, cuando los números vendidos
no cuadraran con la recaudación. Ahora el usuario ve un mensaje raro y **los
datos están bien**. Una interfaz confusa es un problema; una base de datos
mentirosa es un incidente.

*Paso 4 — mide el desfase.* Restaura tu reloj y compara:

```bash
curl -s -D - -o /dev/null localhost:3001/health | grep -i 'x-server-time\|^date'
date -u +%Y-%m-%dT%H:%M:%SZ
```

Anota la diferencia en `server/evidence/reloj.md`. En tu máquina van a ser
milisegundos. En la máquina de un usuario con la sincronización apagada pueden ser
minutos u horas, y esa es la magnitud contra la que hay que diseñar.

*Paso 5 — el desfase, en el log.* Liquida una rifa con el reloj adelantado y
busca en el log la línea de `desfase de reloj` de 5.4. Ese es el rastro que
convierte un ticket de *"me cerró antes de tiempo"* en un diagnóstico de dos
minutos: el reloj del cliente estaba mal y quedó registrado.

*Paso 6 — el círculo, otra vez.* Sigue el `X-Request-Id` de la venta rechazada
por hora desde la consola del navegador hasta el log del backend, y comprueba que
ahí está la razón exacta —`cerró a las … y ahora son las …`— con las dos horas.
En `be00` ese id no llegaba a ninguna parte. Ahora te dice, en una línea, por qué
el sistema dijo que no.

*Rompe a propósito.* Cambia `!now.Before(raffle.ClosesAt)` por
`now.After(raffle.ClosesAt)` y corre el test de 5.5. Un solo caso falla: el borde
exacto. Piensa cuánto habría tardado en aparecer sin ese test, y qué habría dicho
el ticket.

---

> 📓🔥 De esta fase salen los incidentes **be-11** y **be-12** de `cuaderno-incidentes-be.md`. El be-12 es hermano del **16** del track base: allá el navegador interpreta mal el instante; acá lo interpreta bien y aun así no debería ser él quien decida.

---

## 🧪 7. Ejercicios (31)

**🟢 Fácil (1–8)**

1. Comprueba con `SHOW TimeZone` cuál es la zona de tu sesión, y verifica que el arranque del backend la fija.
2. Inserta la misma rifa con `-05:00` y con `Z` (el mismo instante) y comprueba con `=` que Postgres las considera iguales.
3. Verifica que el `closesAt` que devuelve `GET /raffles/1` sale con offset `-05:00` y no con `Z`.
4. Intenta vender en una rifa ya cerrada con `curl` y comprueba que devuelve `409` con su mensaje.
5. Pon una rifa a cerrar en un minuto y observa en el log al *worker* cerrarla.
6. Comprueba que el header `X-Server-Time` viaja en las respuestas.
7. Ejecuta el paso 4 de la pieza forense y anota tu desfase real.
8. Corre `./server/smoke.sh` y confirma que sigue entero.

**🟡 Intermedio (9–19)**

9. Escribe el test de la tabla de 5.5 y comprueba que los cinco casos pasan.
10. **Diagnóstico.** Cambia el borde a `After` y determina qué caso falla y por qué. Explica qué habría pasado en producción.
11. Implementa `Clock` e inyéctalo en los dos servicios. Comprueba que ninguno llama a `time.Now()` por dentro (`grep` incluido en la respuesta).
12. **Diagnóstico.** Compara dos `time.Time` con `==` en un test y observa el fallo. Investiga con `%+v` qué trae adjunto el valor.
13. Cambia la columna `closes_at` a `TIMESTAMP` sin zona en una migración de prueba y determina qué se rompe. Revierte.
14. **Diagnóstico.** Cambia la zona de la sesión a `UTC` y compara la respuesta de `GET /raffles/1` con la del contrato. ¿Se rompe algo en la aplicación? Razona la respuesta antes de probarla.
15. Ejecuta los pasos 1 a 3 de la pieza forense y documenta las dos contradicciones con capturas.
16. Haz que el *worker* de cierre corra cada cinco segundos y verifica que la aplicación refleja el cierre sin recargar. Explica qué mecanismo del frontend lo hace visible.
17. **Diagnóstico.** Detén el *worker*, deja pasar la hora de cierre e intenta vender. Determina qué protege la venta cuando el estado dice `open`.
18. Verifica en el log el desfase que registra `POST /settlements` con el reloj adelantado.
19. **Diagnóstico.** Determina qué pasa si `closes_at` es `NULL` o corrupto. Compara tu comportamiento con el de `isPastClosing`, que devuelve `true` (cerrado) ante una fecha inválida. Si difieren, decide cuál gana y por qué "cerrado" es el default seguro.

**🟠 Difícil (20–27)**

20. **Diagnóstico.** Mueve la comprobación de la hora fuera de la transacción y construye el escenario donde se cuela una venta tardía. Mide cuántos intentos hacen falta para reproducirlo.
21. Cambia `FOR SHARE` por `FOR UPDATE` sobre la rifa y mide qué le pasa a la venta concurrente con 50 contendientes. Explica el resultado con lo que aprendiste en `be05`.
22. **Diagnóstico.** Simula un servidor en otra zona: arranca el proceso con `TZ=Asia/Tokyo` y corre la suite entera. Si algo falla, encontraste una comparación que mira componentes de fecha. Si no falla nada, explica por qué eso es la prueba de que la política de 5.1 funciona.
23. Diseña e implementa el registro del desfase cliente-servidor como métrica agregada, no solo como línea de log. Argumenta qué decisión operativa tomarías con ese número.
24. **Diagnóstico.** Con el horario de verano en la mesa: elige una zona que lo tenga (`America/Santiago`, por ejemplo), pon un `closesAt` justo en el salto, y determina qué pasa. Explica por qué guardar un instante te salva de este problema y guardar "hora local + zona" no.
25. Argumenta por escrito si el *worker* de cierre debería existir o si bastaría con calcular el estado al vuelo. Mide el costo de la consulta con volumen y decide, recordando que el `status` es contrato.
26. **Diagnóstico.** Adelanta el reloj del **servidor** (no el del cliente) y describe qué se rompe. Compara la gravedad con el caso del cliente adelantado y saca la conclusión sobre dónde hay que sincronizar el reloj de verdad.
27. Implementa la mitad de frontend del `serverNow` en una rama descartable —el interceptor y la función— y **mídela**: cuántas líneas, cuántos archivos. Después argumenta si eso cabía o no en la excepción `D27`, con el número en la mano.

**🔴 Muy difícil (28–31)**

28. **Diagnóstico + regresión.** Ticket: *"a los vendedores de la costa se les cierra la rifa una hora antes que a los del interior"*. Enumera las cinco causas candidatas ordenadas por probabilidad, di cómo descartas cada una con una sola consulta o una sola línea de log, y escribe la prueba de regresión de la que sobreviva.
29. Diseña la política de tiempo completa del sistema como documento para quien entre nuevo: qué se guarda, en qué tipo, en qué zona corre cada proceso, quién decide, cómo se serializa y qué está prohibido. Máximo una página, y tiene que poder aplicarse sin leer código.
30. Argumenta si el sistema debería guardar, además del instante, la **zona en que se expresó** el cierre. Construye el caso de negocio que lo haría necesario —una regla recurrente— y decide si este dominio lo tiene. Deja la conclusión en `bea-06`.
31. **Post-mortem.** Escribe el post-mortem de *"vendimos doscientos números después del cierre y nadie lo notó hasta la liquidación"* según la guía §13, ubicando la causa raíz en la autoridad del reloj. La prevención tiene que explicar por qué una validación en el frontend no habría bastado, sin culpar a quien la escribió.

**🔥 Opcionales**

- 🔥 Implementa un endpoint `GET /time` que devuelva el instante del servidor y mide la ida y vuelta desde el navegador para estimar el desfase corrigiendo la latencia. Es media implementación de NTP y explica por qué sincronizar relojes es más difícil de lo que parece.
- 🔥 Reescribe el *worker* de cierre como un `pg_cron` o un `LISTEN/NOTIFY` y compara: menos código en Go, más dependencia del motor. Decide con el criterio de `be02`.
- 🔥 Instrumenta cuántas ventas se rechazan por hora dura en un día de laboratorio y decide si ese número, en producción, sería una señal de reloj desfasado o de comportamiento normal.

---

## 📚 8. Referencias

**Documentación oficial**
- https://www.postgresql.org/docs/13/datatype-datetime.html — el capítulo entero. §8.5.1.3 (`TIMESTAMP` vs `TIMESTAMPTZ`) es exactamente el malentendido de 4.1.
- https://wiki.postgresql.org/wiki/Don%27t_Do_This#Don.27t_use_timestamp_.28without_time_zone.29 — la misma idea, en cinco líneas y sin diplomacia.
- https://pkg.go.dev/time — y en particular la nota sobre el reloj monótono, que explica el error común nº 2.
- https://pkg.go.dev/time#Time.Equal — por qué existe y por qué `==` no sirve.
- https://www.rfc-editor.org/rfc/rfc3339 — el formato. Corto y vale la pena leerlo entero una vez en la vida.
- https://www.iana.org/time-zones — la base de datos de zonas. Cambia varias veces al año, por decisiones políticas, y eso es contenido: **las zonas horarias no son un problema técnico, son un problema legal con consecuencias técnicas**.

**Libros**
- *Designing Data-Intensive Applications* (Martin Kleppmann) — la sección sobre relojes del capítulo 8 (*Unreliable Clocks*) es el mejor texto sobre por qué no se puede confiar en el reloj de nadie, y su idea de "los relojes son intervalos de confianza, no puntos" cambia cómo se diseña.

**Video / apoyo**
- Busca "The Problem with Time & Timezones" (Computerphile) — diez minutos, y es la mejor introducción que existe al tema. Y "Postgres timestamptz explained", que en `be02` te sugerimos guardar: es el momento de verlo.

**Orden de lectura sugerido:** el "Don't Do This" del wiki de Postgres primero,
que son cinco líneas y fija la regla → el vídeo de Computerphile, para la
intuición → `datatype-datetime.html` §8.5 para el detalle → la nota del reloj
monótono en `pkg.go.dev/time` cuando un test te falle sin motivo aparente →
`bea-06` para el panorama completo.

> ⚠️ URLs, títulos y ediciones pueden haber cambiado: verifícalos. Las
> referencias a libros y videos son de memoria y pueden ser inexactas. La
> documentación de Postgres tiene una versión por URL; fija el 13. Cualquier
> discrepancia de versiones la resuelve `prompts/decisiones-y-versiones.md` §7.

---

## 🚀 9. Cierre y conexión con la siguiente fase

El reloj cambió de dueño. La hora de cierre la evalúa el servidor, dentro de la
misma transacción que protege la venta, comparando instantes y no cadenas. Las
rifas se cierran solas cuando les toca. El `settledAt` lo sella quien registra el
hecho. Y el desfase del cliente, que antes era invisible, ahora deja una línea en
el log que convierte un ticket confuso en un diagnóstico de dos minutos.

Queda una deuda 💸 viva y declarada con su precio: la interfaz sigue pintándose
con el reloj del navegador. El servidor ya publica su hora en `X-Server-Time` —la
mitad barata está hecha— y la otra mitad espera al día en que se pueda tocar el
frontend.

`be07` cierra el dominio con lo que no perdona: **el dinero**. La aritmética en
centavos enteros que enseñó `A10` y aplicó la Fase 8 vive hoy solo en el
navegador, sin que la base garantice nada. Vas a ver el cálculo del premio dentro
de una transacción, un reparto que cuadra al centavo con una política explícita
para el residuo, una liquidación idempotente, y la trazabilidad como registro
inmutable en vez de campo actualizable — que es exactamente la forma que `sales`
estrenó en `be05`. Y la pieza forense va a ser una liquidación interrumpida a la
mitad: con transacción no pasa nada, sin ella la base queda con el dinero
repartido y la rifa sin liquidar.

> **La señal de que quedó bien:** *"puedo adelantar el reloj de mi máquina todo lo
> que quiera y el sistema sigue sabiendo qué hora es."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-be06-hora-dura-y-la-autoridad-del-reloj -m "be06 cerrada: \
> política de zona decidida (proceso en UTC, sesión en America/Bogota para serializar); \
> hora dura evaluada en el servidor dentro de la transacción de venta; \
> 409 de rifa cerrada con el mensaje que el frontend ya muestra; \
> Clock inyectable y prueba de los bordes; worker que cierra por reloj; \
> settledAt sellado por el servidor con el desfase registrado; \
> X-Server-Time publicado; deuda del reloj del cliente declarada con su precio"
> ```
>
> Los commits de la fase llevan su prefijo (`be06: …`) y los de ejercicio su
> número (`be06 ej28: …`). Si un ejercicio merece su propio marcador va en
> `ej/be06/28`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

*(Fuera de lo que lee el estudiante.)*

- **Registrar en `prompts/decisiones-y-versiones.md` §7** la política de tiempo:
  proceso en `TZ=UTC`, sesión de base en `America/Bogota` **solo** para
  serializar, todo instante en `TIMESTAMPTZ`, comparación por instantes, y el
  borde del cierre (`now >= closesAt` → cerrado) heredado de `isPastClosing`.
  Afecta a `be07`, `be08` y `be09`.
- **Dos cambios observables que esta fase introduce** y que `CONTRACT.md` tiene
  que recoger: las rifas ahora se cierran solas (régimen de crecimiento,
  compatible con lo que la Fase 7 ya calculaba) y el `settledAt` que vuelve es el
  del servidor (**cambio deliberado de un valor observable**, con su motivo). El
  segundo es el precedente de "a veces el contrato cambia a propósito"; que
  `be08` verifique los dos.
- **La deuda 💸 del reloj del cliente queda viva y con precio estimado** (~30
  líneas en dos archivos del frontend). Es la segunda deuda que el track decide
  **no** pagar, junto con el *refresh token* de `be04`. Las dos tienen que
  aparecer en `bea-09` y en el veredicto honesto de `be09`, y las dos tienen la
  misma causa: la regla que ordena el track. Decirlo así, junto, es más honesto
  que declararlas por separado.
- **`X-Server-Time` es régimen de crecimiento sin consumidor.** Que `bea-06`
  explique cómo se usaría, y que `be09` lo mencione en el veredicto como ejemplo
  de "trabajo hecho para que la deuda sea barata de pagar después".
- **`be07` hereda:** el `Clock` inyectable (lo necesita para la idempotencia y
  para sellar la liquidación), `sales` como registro inmutable, y el `WithTx`.
  Su transacción es la más grande del track.
- **`be08` hereda dos pruebas difíciles de escribir y muy fáciles de romper:** la
  tabla de bordes de 5.5 y el ejercicio 22 (`TZ=Asia/Tokyo` sobre la suite
  entera). Esa segunda debería correr en CI: es la que detecta cualquier
  comparación por componentes de fecha que alguien introduzca en el futuro.
- **Deudas declaradas:** 💸 el *worker* de cierre corre en todas las réplicas
  (mismo caso que el de reservas de `be05`, mismo `pg_advisory_lock`); 💸 no hay
  métrica agregada del desfase, solo líneas de log (ejercicio 23).
- **Reserva para el cuaderno de incidentes:** `be-11` — *"a los vendedores de la
  costa se les cierra la rifa una hora antes"* (categoría 🔥 tiempo, dificultad
  🟠), que es el ejercicio 28; y `be-12` — *"vendimos doscientos números después
  del cierre y nos enteramos en la liquidación"* (categoría 🔥 tiempo, dificultad
  🔴), que es el escenario que esta fase vuelve imposible y que sirve para
  entender qué se estaba arriesgando.
