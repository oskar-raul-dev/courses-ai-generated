# 🕰️ Fase be06 — Hora dura, zonas horarias y la autoridad del reloj

> Tutorial React 16 — La Esclusa, la consola de Jewel Locks · **Track BE opcional 🔥** · Fase be06 de be09 · **8 horas**
> Depende de: be05 — el giro ya es una transacción · Habilita: be07 — Compras y conciliación

---

## 🎯 1. Propósito

*"Hay jugadores que cobran el giro gratis cada hora, y dicen que es adelantando el reloj del celular."* Yariela lo lee en el Discord cada tanto, y no tiene con qué contestar. La regla es de la historia (§9): **un giro gratis cada 4 horas**. El encargo de Juliana la puso en la lista de lo que el API nuevo tiene que garantizar, con una frase que esta fase convierte en código: *el reloj del celular no puede mandar* (historia §3, *Hoy*).

`be05` movió al servidor la autoridad sobre **qué sale en un giro**. Esta fase mueve la otra autoridad que el sistema tenía prestada: **la del reloj**. Hoy hay tres reglas de tiempo en la Esclusa, y ninguna la decide el servidor:

1. **El cierre de la rueda.** La Fase 7 del track base lo evalúa en la consola, con `isWheelClosed(wheel, now)` y el reloj del navegador. El giro del juego, en el backend, mira solo si la rueda dice `live`, y la rueda dice `live` hasta que alguien la pase a mano a `ended`.
2. **El envío de un giro de una rueda cerrada.** La guarda de la Fase 7 (`closedWheelRejection`) vive en un epic de la consola. `curl` no ejecuta epics.
3. **El giro gratis cada cuatro horas.** Todavía no existe en el backend.

> 🧭 **La regla de negocio la aplica quien tiene el dato, no quien tiene la pantalla.** La consola puede —y debe— decidir si ofrece la opción. Solo el servidor puede decidir si el giro ocurre. Un reloj de cliente es un reloj que el usuario controla: el de la operadora, con dos clics en el sistema operativo; el del jugador, con dos toques en el celular.

Y de paso vas a entender qué hace **realmente** PostgreSQL con `TIMESTAMPTZ`, que es donde casi todo el mundo tiene un modelo mental equivocado, y por qué los jugadores de Chile —que cambian la hora dos veces al año— y los de Paraguay —que dejaron de cambiarla en 2024— no necesitan ningún código especial, siempre que guardes lo correcto.

> 🩻 **Lectura previa obligatoria:** la Fase 7 del track base (`closing.js` y `closedWheelGuard.js`), y la decisión `D29`. Ten a mano el incidente `be-04`, que ya mostró lo que pasa cuando la zona de la sesión no se fija.

---

## ✅ 2. Qué queda listo al terminar

- [ ] La política de zona está en el código, en un solo lugar: el proceso en UTC y la sesión de base en `America/Panama` **solo** para serializar. El `closesAt` sale con `-05:00` aunque el `DATABASE_URL` no diga nada de zonas.
- [ ] El cierre se evalúa **en el servidor**, dentro de la transacción del giro y con la rueda en `FOR SHARE`. Una rueda cuyo `closesAt` pasó no gira, aunque todavía diga `live`.
- [ ] Un envío de premio `spin:<wheelId>` de una rueda cerrada responde `409` con el mismo mensaje que la consola ya muestra, y no se anota.
- [ ] Hay un barrido que pasa a `ended` las ruedas `live` cuyo cierre pasó. El barrido mantiene el estado al día; **no es la regla**.
- [ ] Migración `000007`: `players.next_free_spin_at`. `POST /players/:id/free-spins` suma un giro gratis si ya pasaron las 4 horas **del servidor**, con una escritura condicional.
- [ ] El reloj es una dependencia (`clock.Clock`) y hay pruebas de los bordes con un reloj fijo: un milisegundo antes del cierre, el instante exacto, un milisegundo después, y el mismo instante escrito en Panamá. También la carrera de cincuenta reclamos y la noche en que Santiago adelanta la hora.
- [ ] La suite pasa entera con `TZ=Asia/Tokyo`.
- [ ] Toda respuesta trae `X-Server-Time`, expuesto a CORS.
- [ ] Existe `server/evidence/reloj.md` con la medición de la zona en el pool, del desfase y de la base de zonas de cada imagen.
- [ ] La deuda 💸 que **no** se paga —la consola sigue mirando su propio reloj para pintar— está declarada con su precio.
- [ ] `server/CONTRACT.md` dice lo que cambió, `./server/smoke.sh` pasa entero (22 verificaciones), y `git diff pre-backend-go..HEAD -- . ':!server' ':!src/api/authService.js'` no devuelve nada.

---

## 🚫 3. Qué queda fuera por ahora

- **El mock de Google Play del `3002`.** No se reescribe en Go, ni ahora ni nunca. Es un tercero con su propio perfil de fallo, y el `pollingEpic` de la Fase 7 le habla con una instancia de `axios` aparte. **Esa frontera se conserva**, y conservarla es contenido.
- **Que la consola consuma la hora del servidor.** Requeriría tocar `apiClient.js` y `closing.js`, y eso excede la excepción `D27`. Se declara como deuda viva con su costo (5.6).
- **Lo que pinta el juego.** La cuenta regresiva del giro gratis la dibuja Jewel Locks, en Unity. El servidor le manda el instante (`nextFreeSpinAt`); cómo lo pinte es del equipo de Carlos.
- **Librerías de fecha.** Ni en el backend ni en el frontend: `time` de la biblioteca estándar alcanza.
- **Reglas recurrentes.** Una rueda tiene un instante de cierre y ya. Si aparece *"todos los viernes a las 8:00 p. m. hora local"*, ahí sí hace falta guardar la zona además del instante, y esa conversación la deja planteada `bea-06`.
- **Las compras** → `be07`.

---

## 🧠 4. Conceptos mínimos

Sabes qué es UTC y has sufrido zonas horarias. Vamos directo a las cuatro cosas que casi nadie tiene bien.

### 4.1 `TIMESTAMPTZ` no guarda ninguna zona horaria

Empecemos por el malentendido, porque es el que produce los tickets.

`TIMESTAMP WITH TIME ZONE` **no almacena una zona horaria**. El nombre es desafortunado hasta el punto de ser engañoso. Lo que guarda es un **instante**, internamente en UTC, con los mismos ocho bytes que un `TIMESTAMP` sin zona. La zona aparece solo en dos momentos:

- **Al entrar:** si el valor trae offset, Postgres lo usa para convertir a UTC. Si **no** lo trae, asume la zona de la sesión (`SHOW TimeZone`).
- **Al salir:** convierte el instante a la zona de la sesión y lo muestra así.

De ahí se sigue la propiedad que hace correcto usarlo: **dos valores que representan el mismo instante son iguales**, sin importar con qué offset se escribieron. `'2026-08-30 20:00:00-05'` y `'2026-08-31 01:00:00+00'` son el mismo dato, y `=` los declara iguales.

📖 **`TIMESTAMPTZ` guarda un instante. `TIMESTAMP` guarda un número que parece una fecha.** Un `TIMESTAMP` sin zona es "las 8:00 p. m." sin decir de dónde: no identifica ningún momento, y compararlo con otro es comparar dos opiniones.

Y esto es lo que hace que Chile no necesite código especial. La noche del sábado 5 de septiembre de 2026, Santiago pasa de `-04` a `-03`: el reloj de pared salta de las 24:00 a la 01:00. Un jugador de Santiago que reclama el giro gratis a las 11:30 p. m. puede volver a reclamarlo **cuatro horas después**, que en su reloj de pared son las 4:30 a. m.: **cinco horas** de pared. La prueba de 5.5 lo mide así:

```text
reclamó 2026-09-05 23:30 -04:00 · el siguiente 2026-09-06 04:30 -03:00 · en el reloj de pared: 5h0m0s
```

No hay nada que corregir: son cuatro horas de verdad. El instante no sabe que Chile existe.

> 🧭 **La regla operativa, sin excepciones para este dominio.** Todo instante va en `TIMESTAMPTZ`. `TIMESTAMP` sin zona solo sirve para fechas de calendario —un cumpleaños, un feriado— que no son instantes y que este sistema no tiene.

### 4.2 Las zonas las decide una ley, y la base de zonas llega tarde

Paraguay usaba horario de verano: `-04` en invierno y `-03` en verano. En octubre de 2024 una ley lo dejó en `-03` todo el año. Eso no es un dato de cultura general: es un cambio en la **base de zonas** (la *tz database* de IANA), y cada imagen de tu sistema trae la suya, congelada el día que se construyó. El mismo instante, el 1 de julio de 2025 a las 12:00 UTC, en las dos imágenes del laboratorio:

| Imagen | Versión de la base de zonas | `America/Asuncion` |
|---|---|---|
| `postgres:13` (13.23) | 2025b | 09:00 (−03) |
| `golang:1.19.13` | 2023c | 08:00 (−04) |

**Una hora de diferencia entre dos capas del mismo sistema**, y las dos *"tienen razón"* según su base. La de Go es de antes de la ley.

📖 Las zonas horarias no son un problema técnico: son un **problema legal con consecuencias técnicas**. Si tu sistema solo compara instantes, una base de zonas vieja no le cambia ninguna decisión: solo cambia cómo se **muestra** una hora local. Por eso la regla de 4.3 importa tanto. El día que un proceso convierta instantes a la hora local de un jugador para **decidir** algo, la versión de la base de zonas de la imagen pasa a ser parte del contrato, y hay que anotarla como se anota una dependencia.

### 4.3 El instante es la verdad; el offset de la serialización es cosmética

El contrato de `be00` fija que `closesAt` sale como `"2030-12-31T20:00:00-05:00"`, con offset y no con `Z`. Y la Fase 7 compara instantes con `Date.parse(...)`, así que **el offset con el que se serialice le da exactamente igual**: `Z` o `-05:00` producen el mismo instante.

¿Por qué respetar el formato, entonces? Por verificabilidad —el criterio de `be03` fue que la respuesta sea idéntica a la del mock, y una diferencia cosmética consume la misma atención que una real cuando diagnosticas— y por legibilidad: cualquiera que mire un log a las tres de la mañana lee `20:00-05:00` sin hacer aritmética.

> 🧭 **Decisión de la fase (`D29`).** El proceso corre en **UTC**, todas las comparaciones internas se hacen entre instantes, y la sesión de base fija `TimeZone=America/Panama` **solo para que la serialización de salida coincida con el contrato**. La zona de presentación no participa en ninguna decisión.

### 4.4 Dónde se aplica una regla de tiempo, y por qué el reloj se inyecta

Hay tres lugares donde se puede comprobar que una rueda cerró, y los tres son necesarios y distintos:

**En la interfaz**, para no ofrecer lo imposible. Es cortesía, no protección: el usuario controla ese reloj. La Fase 7 ya lo hace, y deshabilita la opción del giro de una rueda cerrada.

**En el servicio, dentro de la transacción del giro.** Es **la** protección, y por eso va exactamente ahí: no en el handler, no antes de abrir la transacción, sino junto a las demás decisiones de `decide`. Si se comprueba antes, entre *"vi que estaba abierta"* y *"giré"* cabe el cierre: el mismo *check-then-act* de `be05`, con el reloj en vez del saldo.

**En un barrido periódico**, para que el estado refleje la realidad aunque nadie pida nada. Sin él, una rueda que cerró a las 8:00 p. m. sigue diciendo `live` hasta que alguien la cierre a mano. Fíjate en la simetría con `be05`: la comprobación dentro de la transacción es el `FOR UPDATE`, y el barrido es el hermano del que cierra giros en proceso.

Y para probar los bordes, el reloj tiene que ser una dependencia. Una función que llama a `time.Now()` por dentro **no se puede probar** en sus casos interesantes, que son justamente un milisegundo antes, el instante exacto y un milisegundo después. La solución es tratarlo como lo que es —una dependencia externa, igual que la base— y pasarlo:

<<<archivo:server/internal/clock/clock.go>>>

Un detalle de Go que conviene conocer antes de que te muerda: `time.Now()` devuelve un valor con **reloj monótono** adjunto, pensado para medir duraciones. Ese reloj no sobrevive a una ida y vuelta a la base ni a una serialización, y hace que `==` entre dos `time.Time` que representan el mismo instante devuelva `false`. **Para comparar instantes se usan `Equal`, `Before` y `After`, nunca los operadores** (`bea-06` §3).

---

## 💻 5. Implementación y código comentado

### 5.1 La política de zona, escrita en un solo lugar

`be03` fijó la zona de la sesión con `timezone=America/Panama` en el `DATABASE_URL`, y el incidente `be-04` mostró qué pasa si alguien la olvida: `2031-01-01T01:00:00Z` donde el contrato dice `2030-12-31T20:00:00-05:00`. Esa línea de configuración era la corrección mínima; ahora se decide en el código:

<<<fragmento:server/internal/storage/storage.go|// PresentationZone es la zona|return u.String(), nil
}>>>

`Open` la aplica a todo DSN de Postgres antes de abrir el pool. ¿Por qué en el DSN y no con un `SET TIME ZONE` después de abrir, que parece más directo? Porque un pool no es una conexión. Medido con 200 consultas concurrentes contra un pool de 25:

| Cómo se fija la zona | `America/Panama` | `Etc/UTC` |
|---|---|---|
| `SET TIME ZONE` una vez, al abrir el pool | 9 | 191 |
| `timezone=America/Panama` en el DSN (`storage.Open`) | 200 | 0 |

El `SET` vale para la conexión que lo ejecutó. `lib/pq` manda los parámetros del DSN en el arranque de **cada** sesión, también las que el pool abra dentro de una hora.

Y el proceso, en UTC:

<<<fragmento:server/cmd/api/main.go|func main() {|clk := clock.System{}>>>

`time.Local = time.UTC`, y no `os.Setenv("TZ", "UTC")`, que es lo que casi todo el mundo escribe. Con `TZ=Asia/Tokyo` en el entorno y un paquete que usa la hora local en su `init`:

```text
nada     init: 11:56 JST · main: 11:56 JST
setenv   init: 11:56 JST · main: 11:56 JST
local    init: 11:56 JST · main: 02:56 UTC
```

`os.Setenv` en `main` llega tarde: Go resolvió `time.Local` la primera vez que alguien la usó, y no la vuelve a leer.

### 5.2 La migración: el giro gratis

<<<archivo:server/migrations/postgres/000007_server_clock.up.sql>>>

La de SQLite es la misma columna con `TIMESTAMP`, que para SQLite es un nombre y no un tipo (`bea-06` §6).

### 5.3 El cierre, dentro del giro

`decide`, de `be05`, elegía la rueda con `WHERE w.status = 'live'`. Ahora el paso 3 llama a una función que mira el reloj:

<<<fragmento:server/internal/spin/service.go|		// 3. La rueda activa, su versión vigente y el sorteo.|			return err
		}
>>>

<<<fragmento:server/internal/spin/service.go|// liveWheel elige la rueda del giro|	return liveWheel{}, ErrNoLiveWheel
}>>>

Tres decisiones están en esas líneas. La comparación es `!now.Before(w.ClosesAt)`: en el instante exacto del cierre, la rueda ya cerró, **el mismo borde que `isWheelClosed`** de la Fase 7 (`now >= closesAt`). Dos capas que contestan distinto en el borde producen el ticket más difícil de diagnosticar que existe. La comparación se hace en Go y no en el `WHERE`, porque en SQLite `closes_at` es texto y comparar texto con offsets distintos da resultados opuestos a los de Postgres (`bea-06` §6). Y `now` es el mismo instante con que `decide` reclamó la clave: **un giro, un reloj**.

> 🧠 **`FOR SHARE` y no `FOR UPDATE` sobre la rueda.** Solo hace falta que nadie **cambie** `closes_at` ni el estado mientras se gira, no que los giros se esperen entre sí. `FOR UPDATE` sobre la rueda pondría **todos** los giros en fila detrás de una sola fila, y tiraría a la basura la granularidad que `be05` midió. `FOR SHARE` deja pasar a los demás lectores y hace esperar al barrido y al `PUT` de la consola. Es el error común nº 2 de `be05` disfrazado de prudencia; el ejercicio 21 lo mide.

Si ninguna rueda `live` está abierta según el reloj, el giro responde lo que ya respondía sin rueda activa: `409` con `{ "error": "no hay rueda activa" }`. Y si hay otra abierta, gira en esa: la rueda activa es *la `live` que cierra primero entre las que no cerraron*.

El envío manual recibe la misma regla. Hasta ahora, un envío `spin:4` se anotaba aunque la Rueda de fin de mes hubiera terminado hace semanas, y la única defensa era el epic de la Fase 7:

<<<fragmento:server/internal/player/player.go|	err = s.db.WithTx(ctx, func(tx *sqlx.Tx) error {|				return fmt.Errorf("leyendo la rueda %d: %w", wheelID, err)
			}
		}>>>

El mensaje es **el mismo** que muestra `closedWheelRejection`: *"La rueda ya cerró: no se envían giros de ella."* El handler lo traduce a `409`, que `toReadableError` de la Fase 5 ya mapea a `conflict`. La consola maneja el caso nuevo sin saber que existe.

### 5.4 El barrido que cierra por reloj, y el giro gratis

<<<archivo:server/internal/wheel/closing.go>>>

`main.go` lo arranca con el mismo contexto que el barrido de `be05`, y se detiene igual en el apagado. `WHEEL_CLOSE_EVERY` vale 10 segundos por defecto.

> ⚠️ **Esto es comportamiento nuevo y observable**: el mock nunca cerró una rueda solo. Va al **régimen de crecimiento** porque nada de la consola se rompe —la Fase 7 ya trata como cerrada cualquier rueda cuyo `closesAt` pasó, así que el `status` que llega ahora **coincide** con lo que la UI ya calculaba—, y queda en `CONTRACT.md`.

Y el giro gratis:

<<<archivo:server/internal/spin/free.go>>>

Es la escritura condicional de `be05` (`bea-05` §4), con el reloj en el `WHERE`. La alternativa que parece más legible —leer `next_free_spin_at`, comparar en Go y escribir— reabre la ventana del saldo de 2019, y la prueba de 5.5 lo dice con un número: cincuenta reclamos en el mismo instante, **uno** suma.

El handler es público, como el giro: lo pide el juego, que no tiene sesión de la consola. No lee el cuerpo ni ninguna cabecera de hora.

<<<fragmento:server/internal/http/handlers.go|// POST /players/:id/free-spins|		writeJSON(w, http.StatusOK, claimed)
	}
}>>>

### 5.5 Probar el borde, con el reloj en la mano

<<<fragmento:server/internal/spin/clock_test.go|// El cierre de la rueda de medición|				t.Fatalf("con ahora=%s: esperaba %v, obtuve %v", c.now.Format(time.RFC3339Nano), c.want, err)
			}
		})
	}
}>>>

<<<fragmento:server/internal/spin/clock_test.go|// Cincuenta reclamos en el mismo instante|	t.Logf("%v · saldo %d", got, free)
}>>>

```bash
TEST_DATABASE_URL="postgres://esclusa:esclusa@localhost:5432/esclusa_test?sslmode=disable" \
  go test -count=1 -race -p 1 -v ./...
```

```text
--- PASS: TestSpinRespectsClosing (0.62s)
--- PASS: TestFreeSpinEveryFourHours (0.12s)
    clock_test.go:96: map[ok:1 todavía no:49] · saldo 1
--- PASS: TestFreeSpinClaimRace (0.15s)
    clock_test.go:119: reclamó 2026-09-05 23:30 -04:00 · el siguiente 2026-09-06 04:30 -03:00 · en el reloj de pared: 5h0m0s
--- PASS: TestFreeSpinAcrossChileDST (0.13s)
--- PASS: TestCloseExpired (0.11s)
```

`-p 1` porque los paquetes `spin` y `wheel` migran la misma base de prueba: en paralelo se pisarían. La prueba del barrido, `TestCloseExpired`, también pasa contra SQLite: compara en Go. Y la suite entera pasa con `TZ=Asia/Tokyo`, que es la prueba de que ninguna comparación mira la zona del proceso.

**Rompe a propósito.** Cambia `!now.Before(w.ClosesAt)` por `now.After(w.ClosesAt)` y corre `TestSpinRespectsClosing`. Fallan exactamente dos casos —**el instante exacto** y **el mismo instante escrito en Panamá**— y pasan los otros tres. Piensa cuánto habría tardado en aparecer sin esa tabla, y qué habría dicho el ticket.

### 5.6 La deuda que **no** se paga, y su precio

El backend ya no se puede engañar. La consola, sí.

Con el reloj del navegador una hora adelante, la consola marca como `(cerrada)` una rueda a la que le quedan treinta minutos, y no deja mandar el giro. Nada se corrompe —el servidor nunca se enteró—, pero Yariela no puede compensar a un jugador con algo que sí estaba disponible, y no entiende por qué. Es el incidente `be-11`.

Pagarlo requiere que el servidor mande su hora y que **la consola la use**. La primera mitad es gratis y la hace esta fase:

<<<fragmento:server/internal/http/middleware.go|// serverTimeHeader publica la hora|		})
	}
}>>>

> 💸 **Deuda declarada: la consola sigue mirando su propio reloj para pintar.** Con el reloj de la operadora desfasado, la UI ofrece o esconde el giro de una rueda en el momento equivocado, aunque el servidor decida siempre bien. Costo de pagarla: un interceptor de respuesta que guarde el desfase contra `X-Server-Time` y una función `serverNow()` que lo aplique, en `apiClient.js` y `closing.js`. **No se hace porque tocaría el frontend**, y ampliar la excepción `D27` una segunda vez la convertiría en una licencia general. Va al mapa de deuda de `bea-09` y al veredicto de `be09`. El juego tiene la misma deuda, y ahí ni siquiera es nuestra: el servidor ya le manda `nextFreeSpinAt`.

### 5.7 El contrato cambió: actualízalo

Agrega a `server/CONTRACT.md` lo que esta fase cambió: el giro que comprueba el cierre, el `409` del envío de una rueda cerrada, `POST /players/:id/free-spins`, `X-Server-Time` y el barrido de cierre. Y a `smoke.sh`, tres verificaciones: el envío de `spin:4` (la Rueda de fin de mes, que terminó) da `409` con el mensaje exacto, el reclamo de un jugador inexistente da `404`, y `X-Server-Time` viaja y está expuesto. Ninguna escribe nada. Son **22**.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. Comparar componentes de fecha.** Síntoma: la rueda cierra una hora antes, o deja girar pasada la medianoche, y solo para algunos. Causa: alguien extrajo el día o la hora en vez de comparar instantes. Fix: `Before` / `After` sobre `time.Time`. Es el `getHours()` de la Fase 7 reencarnado en Go, y aparece siempre que alguien intenta "hacerlo más legible".

**2. `==` entre dos `time.Time`.** Síntoma: una prueba falla comparando dos fechas que se ven idénticas en el mensaje. Causa: el reloj monótono adjunto, y la zona. Fix: `Equal`. En Go, `time.Time` no se compara con operadores, jamás.

**3. Comprobar la hora fuera de la transacción.** Síntoma: cada tanto se cuela un giro unos milisegundos tarde. Causa: el *check-then-act* de `be05`, con el reloj en vez del saldo. Fix: la comprobación adentro, como en 5.3.

**4. Creer que el barrido es la regla.** Síntoma: giros anotados en una rueda **después** de su cierre, más o menos según la hora. Causa: el giro mira `status = 'live'` y confía en que el barrido la cierre a tiempo. Medido con k6 a 50 giros por segundo y el barrido cada 10 s, en tres corridas: **108, 61 y 5** giros después del cierre, según en qué momento del ciclo cerró la rueda. Con la regla en el giro: **0**. Es el incidente `be-12`.

**5. `SET TIME ZONE` sobre un pool.** Síntoma: el `closesAt` sale a veces con `-05:00` y a veces con `Z`, y `smoke.sh` pasa o falla según la corrida. Causa: el `SET` vale para una conexión, no para el pool (5.1: 9 de 200). Fix: la zona en los parámetros de arranque de la sesión, en el DSN.

**6. `os.Setenv("TZ", …)` en `main`.** Síntoma: el proceso sigue formateando en la zona del contenedor. Causa: `time.Local` ya se resolvió. Fix: `time.Local = time.UTC`, o mejor aún, que nada decida con la hora local.

**7. Leer la hora del cliente.** Síntoma: hay jugadores con un giro gratis cada vez que lo piden. Causa: una cabecera, un campo del cuerpo o un parámetro con la hora del celular, usado *"para que la cuenta regresiva coincida"*. Fix: la hora la pone el servidor, y el juego pinta con `nextFreeSpinAt`. Es el incidente `be-18`.

**8. Guardar en `TIMESTAMP` sin zona.** Síntoma: todo funciona en desarrollo y las horas se corren en producción. Causa: el servidor de desarrollo está en tu zona y el de producción en UTC. Fix: `TIMESTAMPTZ` siempre, y desconfía del `down` de una migración que cambie el tipo: la conversión **reinterpreta** los datos existentes.

### 🩻 Pieza forense de esta fase

**El reloj del servidor, de punta a punta.** Con el barrido cada 5 segundos para no esperar:

```bash
WHEEL_CLOSE_EVERY=5s go run ./cmd/api
```

*Paso 1 — el giro gratis de María R.* Ella juega desde Chile. Reclama dos veces seguidas:

```bash
curl -s -X POST localhost:3001/players/43/free-spins
curl -s -X POST localhost:3001/players/43/free-spins
```

```text
{"playerId":43,"freeSpins":1,"nextFreeSpinAt":"2026-10-20T06:57:31.365Z"} → 200
{"error":"todavía no","nextFreeSpinAt":"2026-10-20T06:57:31.365Z"} → 409
```

El segundo dice cuándo, en un instante. Si el juego pinta la cuenta regresiva restando el reloj del celular a ese instante, la cuenta puede mentir; el servidor, no.

*Paso 2 — una rueda que cierra en ocho segundos.* Dale saldo a Juan P. y pon la Esclusa de Oro a cerrar:

```sql
UPDATE players SET free_spins = 5 WHERE id = 42;
UPDATE wheels SET closes_at = now() + interval '8 seconds' WHERE id = 1;
```

Gira antes y después del cierre, y mira el estado en la base entre medio:

```text
== Antes del cierre
{"landedSegment":"sin-premio","deliveredPrize":"sin-premio","origin":"free","wheelId":1,"wheelVersion":1} → 200
== Pasado el cierre
{"error":"no hay rueda activa"} → 409
status ahora = live
status después del barrido = ended
```

**Esta es la escena que resume la fase.** El giro de después del cierre se rechazó **con la rueda todavía en `live`**: el barrido no había pasado. El barrido la cerró tres segundos más tarde. Si la regla fuera el estado, ese giro habría salido.

*Paso 3 — el envío.* Desde la consola, o con `curl` y el token, manda un `spin:1`:

```text
{"error":"La rueda ya cerró: no se envían giros de ella."} → 409
```

*Paso 4 — mide el desfase.* Compara la hora del servidor con la de tu máquina:

```bash
curl -s -D - -o /dev/null localhost:3001/health | grep -i 'x-server-time\|^date'
date -u +%Y-%m-%dT%H:%M:%SZ
```

```text
X-Server-Time: 2026-10-20T02:57:31.385Z
Date: Tue, 20 Oct 2026 02:57:31 GMT
date -u: 2026-10-20T02:57:31Z
```

En el mismo Docker, el mismo segundo. En el celular de un jugador con la hora puesta a mano pueden ser horas, y esa es la magnitud contra la que hay que diseñar. Anótalo en `server/evidence/reloj.md`.

*Paso 5 — el círculo.* Busca en el log del binario el `X-Request-Id` del giro rechazado y la línea del barrido:

```text
[req-id ff7e62b5c6a0146e] POST /players/42/spins → 409 (32 bytes) en 2.989ms
[cierre] rueda 1 cerrada por reloj
```

El rechazo es de las 02:57:41 y el cierre por el barrido, de las 02:57:44. Tres segundos en los que el estado decía una cosa y la regla, otra.

---

> 📓🔥 De esta fase salen los incidentes **be-11**, **be-12** y **be-18** de `cuaderno-incidentes-be.md`. El be-11 es la deuda de 5.6 haciéndose notar; el be-12 es el barrido tomado por regla; el be-18 es el reloj del celular, y es el más corto de reproducir: una cabecera.

---

## 🧪 7. Ejercicios (30)

**🟢 Fácil (1–8)**

1. Comprueba con `SHOW TimeZone` en `psql` cuál es la zona de tu sesión. Después abre el binario sin `timezone=` en el `DATABASE_URL` y comprueba con `curl` que `closesAt` sigue saliendo con `-05:00`.
2. Inserta en `psql` el mismo instante con `-05:00` y con `Z` y comprueba con `=` que Postgres los considera iguales.
3. Reclama el giro gratis de un jugador dos veces con `curl` y copia las dos respuestas.
4. Manda con `curl` un envío `spin:4` y comprueba el `409` con su mensaje.
5. Pon una rueda a cerrar en un minuto y mira en el log al barrido cerrarla.
6. Comprueba que `X-Server-Time` viaja en una respuesta de error (un `404`) además de en las buenas.
7. Ejecuta el paso 4 de la pieza forense y anota tu desfase.
8. Corre `./server/smoke.sh` y confirma las 22 verificaciones.

**🟡 Intermedio (9–19)**

9. Corre las pruebas de 5.5 con `-race` contra Postgres y anota lo que imprime cada una.
10. **Diagnóstico.** Haz el *rompe a propósito* de 5.5 y explica por qué fallan exactamente esos dos casos.
11. Busca con `grep` todas las llamadas a `time.Now()` del backend. Justifica cada una que quede fuera de `clock.System`.
12. **Diagnóstico.** Compara dos `time.Time` con `==` en una prueba y mira el fallo. Investiga con `%+v` qué trae adjunto el valor.
13. Cambia `closes_at` a `TIMESTAMP` sin zona en una migración de prueba y determina qué se rompe. Revierte.
14. **Diagnóstico.** Abre el pool con un `SET TIME ZONE` después de `Open` y corre `smoke.sh` diez veces. Cuenta cuántas falla la verificación del offset, y explica el número con el tamaño del pool.
15. Escribe la prueba que mide 4.2: el mismo instante en `America/Asuncion` según Go y según Postgres, dentro de tus contenedores. Anota la versión de la base de zonas de cada imagen (`head -1 /usr/share/zoneinfo/tzdata.zi`).
16. Pon el barrido cada 5 segundos y determina si la consola refleja el cierre sin recargar. Si lo refleja, encuentra qué mecanismo del frontend lo hace visible; si no, qué haría falta.
17. **Diagnóstico.** Detén el barrido, deja pasar el cierre e intenta girar. Determina qué protege el giro cuando el estado dice `live`.
18. Corre la suite con `TZ=Asia/Tokyo` y con `TZ=America/Santiago`. Si algo falla, encontraste una comparación que mira la zona del proceso.
19. **Diagnóstico.** Determina qué pasa si `closes_at` es ilegible en SQLite. Compara con `isWheelClosed`, que devuelve cerrada ante una fecha inválida, y decide cuál gana.

**🟠 Difícil (20–26)**

20. **Diagnóstico.** Mueve la comprobación del cierre fuera de la transacción y construye el escenario donde se cuela un giro tardío. Mide cuántos intentos hacen falta.
21. Cambia `FOR SHARE` por `FOR UPDATE` sobre la rueda y corre el escenario `notificacion` de `giro.js` con 50 jugadores. Compara el p95 con el de `be05` y explica el resultado.
22. Reproduce el error común 4 con k6 (`RATE=50`), con el barrido cada 10 s. Corre tres veces, explica por qué el número cambia tanto, y calcula el peor caso.
23. Registra el desfase entre `X-Server-Time` y la hora que traiga el cliente como métrica agregada, sin usarla para decidir nada. Argumenta qué decisión operativa tomarías con ese número.
24. Argumenta por escrito si el barrido de cierre debería existir o si bastaría con calcular el estado al vuelo en `GET /wheels`. Recuerda que el `status` es contrato.
25. **Diagnóstico.** Adelanta el reloj del **servidor** (no el del cliente) en el contenedor y describe qué se rompe. Compara la gravedad con la del cliente adelantado y concluye dónde hay que sincronizar el reloj de verdad.
26. Implementa la mitad de frontend del `serverNow` en una rama descartable —el interceptor y la función— y **mídela**: cuántas líneas, cuántos archivos. Argumenta si cabía o no en la excepción `D27`, con el número en la mano.

**🔴 Muy difícil (27–30)**

27. **Diagnóstico + regresión.** Ticket: *"a los jugadores de Chile la rueda les cierra una hora antes"*. Enumera las causas candidatas ordenadas por probabilidad, di cómo descartas cada una con una sola consulta o una sola línea de log, y escribe la prueba de regresión de la que sobreviva.
28. Diseña la política de tiempo completa del sistema como documento para quien entre nuevo: qué se guarda, en qué tipo, en qué zona corre cada proceso, quién decide, cómo se serializa, qué versión de la base de zonas trae cada imagen y qué está prohibido. Una página, aplicable sin leer código.
29. Argumenta si el giro gratis debería contarse en **ventanas** de hora local del jugador (a las 0, 4, 8…) en vez de cuatro horas desde el anterior. Construye el caso de producto que lo pediría, di qué tendrías que guardar, y qué pasa la noche del cambio de hora en Santiago y con una base de zonas vieja para Asunción.
30. **Post-mortem.** Escribe el post-mortem de *"hay jugadores que cobran el giro gratis cada hora"* según los ocho puntos del post-mortem de `cuaderno-incidentes.md`, con la causa raíz en la autoridad del reloj. La prevención tiene que explicar por qué una validación en el juego no habría bastado, sin culpar a quien la escribió.

**🔥 Opcionales**

- 🔥 Implementa `GET /time` y mide la ida y vuelta desde el navegador para estimar el desfase corrigiendo la latencia. Es media implementación de NTP, y explica por qué sincronizar relojes es más difícil de lo que parece.
- 🔥 Reescribe el barrido de cierre con `pg_cron` y compara: menos código en Go, más dependencia del motor. Decide con el criterio de `be02`.
- 🔥 Compila el binario con `-tags timetzdata` (o importa `time/tzdata`) y compara la versión de la base de zonas que queda adentro con la de la imagen. Decide cuál de las dos quieres que mande.

---

## 📚 8. Referencias

**Documentación oficial**
- https://www.postgresql.org/docs/13/datatype-datetime.html — el capítulo entero. §8.5.1.3 es exactamente el malentendido de 4.1.
- https://www.postgresql.org/docs/13/runtime-config-client.html#GUC-TIMEZONE — `TimeZone` como parámetro de sesión.
- https://wiki.postgresql.org/wiki/Don%27t_Do_This#Don.27t_use_timestamp_.28without_time_zone.29 — la misma idea, en cinco líneas y sin diplomacia.
- https://pkg.go.dev/time — la nota sobre el reloj monótono, y `Local`.
- https://pkg.go.dev/time/tzdata — la base de zonas embebida en el binario.
- https://www.rfc-editor.org/rfc/rfc3339 — el formato. Corto, y vale la pena leerlo entero una vez.
- https://www.iana.org/time-zones — la base de zonas, con sus versiones. El archivo `NEWS` de cada versión dice qué país cambió qué, y por qué ley.

**Libros**
- *Designing Data-Intensive Applications* (Martin Kleppmann) — la sección sobre relojes del capítulo 8 (*Unreliable Clocks*): los relojes son intervalos de confianza, no puntos.

**Video / apoyo**
- Busca "The Problem with Time & Timezones" (Computerphile): diez minutos, y la mejor introducción que existe al tema.

**Orden de lectura sugerido:** el "Don't Do This" del wiki de Postgres → el vídeo de Computerphile → `datatype-datetime.html` §8.5 → la nota del reloj monótono cuando una prueba te falle sin motivo aparente → `bea-06` para el panorama completo.

> ⚠️ URLs, títulos y ediciones pueden haber cambiado: verifícalos. Las referencias a libros y videos son de memoria y pueden ser inexactas. La documentación de Postgres tiene una versión por URL; fija el 13. Las cifras de esta fase son de las corridas del 19/10/2026 en la máquina del autor. Cualquier discrepancia de versiones la resuelve `00-decisiones-y-versiones.md` §7.

---

## 🚀 9. Cierre y conexión con la siguiente fase

El reloj cambió de dueño. El cierre lo evalúa el servidor, dentro de la misma transacción que decide el giro, comparando instantes y no cadenas. Las ruedas se cierran solas cuando les toca, y un barrido atrasado no deja girar tarde. El giro gratis cada cuatro horas existe, lo cuenta el servidor, y cincuenta reclamos a la vez suman uno. Y la zona dejó de ser una línea de configuración: es una política escrita en el código, con su porqué medido.

Queda una deuda 💸 viva y con precio: la consola sigue pintando con el reloj del navegador. El servidor ya publica su hora en `X-Server-Time`; la otra mitad espera al día en que se pueda tocar el frontend.

`be07` cierra el dominio con lo que no perdona: **el dinero**. La compra que llega dos veces —por el juego y por la notificación de Google Play— tiene que acreditar una sola vez, giros e ingreso juntos. La conciliación de la Fase 8, que hoy calcula la consola con lo que tiene cargado, la recalcula el servidor en SQL. Y la rueda que se acomoda (historia §5) se reemplaza por la protección con sustituto, que deja la tabla de probabilidades diciendo la verdad.

> **La señal de que quedó bien:** *"puedo adelantar el reloj de mi máquina, o el del celular, todo lo que quiera, y el sistema sigue sabiendo qué hora es."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-be06-hora-dura-y-la-autoridad-del-reloj -m "be06 cerrada: \
> proceso en UTC y sesión en America/Panama solo para serializar; \
> cierre comprobado en el servidor dentro de la transacción del giro; \
> barrido de cierre por reloj; 409 del envío de una rueda cerrada; \
> giro gratis cada 4 h con el reloj del servidor; \
> Clock inyectable y prueba de los bordes; X-Server-Time publicado; \
> deuda del reloj de la consola declarada"
> ```
>
> Los commits de la fase llevan su prefijo (`be06: …`) y los de ejercicio su número (`be06 ej27: …`). Si un ejercicio merece su propio marcador va en `ej/be06/27`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` / `-fix`, con el ID que le reserva `cuaderno-incidentes-be.md`. Todo eso está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

*(Fuera de lo que lee el estudiante.)*

- **`D29` se cumple** con `time.Local = time.UTC` en `main.go` y la zona de presentación forzada en el DSN por `storage.Open`. La decisión decía *"fija `TZ=UTC`"*: medido, `os.Setenv` llega tarde; se corrigió el texto de `D29`.
- **Paraguay**, en `D29` y en `be05` §9, figuraba con horario de verano. Ya no lo tiene (ley de octubre de 2024; tzdata 2025a, para los instantes desde el 22/03/2025). La imagen `golang:1.19.13` trae la base 2023c y todavía no lo sabe: lo publica 4.2.
- **Cambios observables** que `CONTRACT.md` recoge: el cierre en el giro, el `409` del envío de una rueda cerrada, el giro gratis, `X-Server-Time` y el barrido. Que `be08` verifique los cinco.
- **La deuda 💸 del reloj de la consola queda viva** y con precio (un interceptor y `serverNow()`, en `apiClient.js` y `closing.js`). Es la segunda que el track decide **no** pagar, junto con el *refresh token* de `be04`. Las dos van a `bea-09` y al veredicto de `be09`.
- **`be07` hereda** el `Clock` inyectable (para sellar la compra y la conciliación) y el `FOR SHARE` sobre la rueda.
- **`be08` hereda** la tabla de bordes de 5.5 y la corrida con `TZ=Asia/Tokyo`, que debería estar en CI. Las regresiones de `be-10` y `be-17` usan la firma vieja de `spin.NewService`: `be08` las porta.
- **Deudas declaradas:** 💸 el barrido de cierre corre en todas las réplicas (como el de `be05`); 💸 no hay métrica agregada del desfase (ejercicio 23); 💸 la versión de la base de zonas de la imagen de Go no está fijada (opcional de §7).
- **Reserva para el cuaderno de incidentes:** `be-11` — *a los jugadores de Chile la rueda les cierra una hora antes* (🔥 tiempo, 🟡; diff vacío); `be-12` — *giros después del cierre* (🔥 tiempo, 🟢); `be-18` ➕ — *hay jugadores que cobran el giro gratis cada hora* (🔥 tiempo).
