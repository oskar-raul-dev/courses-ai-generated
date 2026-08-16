# 📓🔥 Cuaderno de incidentes — Track BE

> Tutorial React 16 — Rifas y chances · **Track BE opcional 🔥** · Documento vivo
> El changelog es `git log -- cuaderno-incidentes-be.md`
> El tiempo ya está contado dentro de las 84 h del track BE; no es un bloque aparte

Este es el cuaderno del **track opcional de backend**. Los dieciséis incidentes
de acá ocurren del otro lado del cable: en el binario de Go, en PostgreSQL, en el
contenedor o en el pipeline. Su rango de IDs —`be-01` a `be-16`— está reservado
en `cuaderno-incidentes.md` y **nunca se reasigna**.

> 📝 **Por qué este archivo existe aparte.** `cuaderno-incidentes.md` se declara
> "el único archivo de incidentes del curso", y esa frase se escribió antes de que
> el track BE existiera. Se **diverge a propósito** y por dos razones: el track BE
> es opcional, y un alumno que solo hace las 96 horas del track base no debería
> encontrarse dieciséis incidentes de Go y Postgres intercalados entre los suyos;
> y los IDs `be-NN` conviven con los `01`–`20` sin colisionar precisamente porque
> están en rangos distintos. El cuaderno base conserva la reserva y apunta acá.
>
> La estructura, las reglas y el tono son **exactamente los mismos**. Lo que
> cambia son las herramientas, y está registrado en
> `prompts/plantilla-de-incidente-be.md`.

**Prerrequisito:** haber terminado la fase que cada incidente indica. Adelantarte
no es imposible, pero vas a pelear con herramientas que todavía no conoces —y en
concurrencia, con un bug que no vas a poder ni reproducir.

---

## 🧭 Cómo se trabaja un incidente

Igual que en el cuaderno base, así que si vienes de allá puedes saltar a la
sección siguiente. Lees el ticket, reproduces, investigas, escribes tu
diagnóstico en el bloque "Tu investigación", y **recién entonces** abres la
solución para compararla.

Las pistas están escalonadas: la primera te dice **de qué lado del cable** mirar,
la segunda **qué** mirar, la tercera casi te lo cuenta. Ábrelas en orden y solo
cuando estés realmente trabado — trabado quiere decir veinte minutos sin una idea
nueva.

Regla del archivo: se **agrega**, no se corrige. Una hipótesis falsa no se borra:
se marca como descartada, con la evidencia que la tumbó al lado.

> 🧭 **La distinción que atraviesa los dos cuadernos.** Cada fix se escribe dos
> veces: el **parche mínimo** —lo que aplicarías un viernes a las seis— y la
> **corrección correcta** —lo que harías con calma y pruebas.
>
> Y acá se le suma una pregunta propia, que es la primera de todas: **¿de qué lado
> del cable está la causa?** El track base solo podía mirar una orilla. Vas a
> descubrir que buena parte de lo que parecía del frontend no lo era — y también
> lo contrario, que es más incómodo.

### La pregunta que cambia todo el método

Antes de abrir un archivo, siempre:

1. **¿La petición salió?** Si no está en Network, el bug es del cliente y el
   backend no tiene nada que ver.
2. **¿Qué volvió?** Código, cuerpo y `X-Request-Id`.
3. **¿Qué dice el log del backend para ese id?**

Ese corte —Network primero, log después— ahorra más tiempo que cualquier
herramienta, y el `X-Request-Id` es lo que permite cruzarlo sin perder el hilo
(`bea-07` §7).

### Convención de commits

```
incidente(be-09): abre — vendimos tres números dos veces, y solo los redondos
incidente(be-09): repro — 20 clientes concurrentes sobre el 0500, dos ganan
incidente(be-09): hipótesis descartada — no es el frontend, curl sin navegador lo reproduce
incidente(be-09): causa — SellNumber lee, decide y escribe sin transacción ni bloqueo
incidente(be-09): fix — transacción con SELECT ... FOR UPDATE sobre raffle_numbers
incidente(be-09): cierre — prueba de concurrencia contra Postgres y post-mortem
```

Y si el incidente deja el laboratorio roto a propósito, el par de tags de
`00-convencion-de-git-y-tags.md`: `inc/be-09/venta-doble-roto` e
`inc/be-09/venta-doble-fix`.

---

## 🩺 Entrar por el síntoma

El método de las tres preguntas de arriba te dice **de qué lado del cable** está la
causa. Esta tabla es el paso siguiente: una vez que sabes que es de este lado, por
dónde empezar a mirar.

| Lo que llega en el ticket | Primero mira | Capa más probable | Candidatos |
|---|---|---|---|
| "En Network sí, en la consola no" | el header, en las dos orillas | contrato | be-01 |
| "Falta un dato que sí cargamos" | el `INSERT` real, en `psql` | store, esquema | be-02, be-07 |
| "Se cae solo y vuelve" | `docker logs`, el código de salida | despliegue | be-03, be-16 |
| "La hora salió corrida" | el tipo de la columna, en `\d` | esquema, zona | be-04, be-11 |
| "Anda hasta que hay gente" | `pg_stat_activity` | pool, transacción | be-05 |
| "A veces sale en blanco" | `go test -race` | concurrencia | be-06 |
| "Los saca de la sesión" | el `exp` del token, decodificado | autenticación | be-08 |
| "Se vendió dos veces" | los índices de la tabla, en `\d` | base de datos | be-09 |
| "Quedó reservado para siempre" | qué proceso libera, y cuándo | transacciones | be-10 |
| "Siguió vendiendo tras el cierre" | quién evalúa la hora | autoridad del reloj | be-12 |
| "La cuenta no cuadra" | de cuándo son los datos que entraron | contrato, transacción | be-13, be-14 |
| "Verde en la suite, rojo en PROD" | contra qué motor corre la suite | pruebas | be-15 |
| "La imagen de ayer no arranca" | qué cambió si el código no cambió | despliegue | be-16 |

Dos advertencias. La primera: la última columna son **candidatos**, no un
diagnóstico — `be-13` y `be-14` comparten síntoma y no comparten causa. La segunda,
y es la propia de este track: **seis de estos dieciséis tienen un hermano en el
cuaderno base con el mismo síntoma y otra causa raíz**, así que antes de dar por
cerrada una hipótesis conviene preguntarse si el síntoma que estás viendo no será
el de la otra orilla. El cruce está en la sección de hermanos, más abajo.

---

## 📋 Índice

| ID | Fase | Síntoma reportado | Categoría | Dif. | Estado |
|---|---|---|---|---|---|
| be-01 | be00 | La trazabilidad funciona en Network pero no en la consola | 🔥 contrato | 🟡 | ⬜ |
| be-02 | be00 | El número ganador no tiene dueño | 🔥 contrato | 🟠 | ⬜ |
| be-03 | be01 | El backend se cae solo y vuelve, tres veces al día | 🔥 despliegue | 🟡 | ⬜ |
| be-04 | be02 | Las rifas se crean con la hora corrida | 🔥 base de datos | 🟠 | ⬜ |
| be-05 | be02 | Todo funciona hasta que hay gente | 🔥 base de datos | 🔴 | ⬜ |
| be-06 | be03 | El comprador aparece en blanco, pero solo a veces | 🔥 contrato | 🟠 | ⬜ |
| be-07 | be03 | Faltan datos en las liquidaciones de agosto | 🔥 contrato | 🔴 | ⬜ |
| be-08 | be04 | A algunos los saca de la sesión al mediodía y a otros nunca | 🔥 autenticación | 🟡 | ⬜ |
| be-09 ⭐ | be05 | Vendimos tres números dos veces, y solo los redondos | 🔥 transacciones | 🔴 | ⬜ |
| be-10 | be05 | Un número quedó reservado para siempre | 🔥 transacciones | 🟡 | ⬜ |
| be-11 | be06 | A los vendedores de la costa se les cierra la rifa una hora antes | 🔥 tiempo | 🟠 | ⬜ |
| be-12 | be06 | Vendimos doscientos números después del cierre | 🔥 tiempo | 🔴 | ⬜ |
| be-13 | be07 | La liquidación dice 340.000 y las ventas suman 355.000 | 🔥 dinero | 🟠 | ⬜ |
| be-14 | be07 | Repartimos el premio dos veces | 🔥 transacciones | 🔴 | ⬜ |
| be-15 ⭐ | be08 | La suite lleva tres semanas en verde y ayer se rompió producción | 🔥 contrato | 🔴 | ⬜ |
| be-16 | be09 | La imagen de ayer no arranca y el código no cambió | 🔥 despliegue | 🟠 | ⬜ |

**Categorías propias del track:** 🔥 base de datos · 🔥 transacciones · 🔥
despliegue · 🔥 contrato. Se suman a las del cuaderno base, de donde salen
autenticación, tiempo y dinero.

**⭐** marca los dos más formativos: la venta duplicada (`be-09`) y la suite que
autorizó un despliegue roto (`be-15`).

### Los hermanos del track base

Seis de estos dieciséis comparten síntoma con un incidente del cuaderno base y
tienen **otra causa raíz**. Ese paralelo es deliberado y es de lo más formativo
que ofrece el track: resolverlos en pareja te enseña más que resolver doce
sueltos.

| Track base | Track BE | Qué cambia |
|---|---|---|
| 11 — el `0347` vendido dos veces ⭐ | **be-09** ⭐ | Allá se diagnostica en el store; acá se resuelve con un índice único y una transacción |
| 16 — la rifa siguió vendiendo tras el cierre | **be-12** | Allá el reloj del navegador; acá la autoridad temporal del servidor |
| 18 — la liquidación da un centavo de diferencia | **be-13** | Allá el redondeo; acá el cliente calculando con datos viejos |
| 20 — el test pasa en mi máquina y falla en la de al lado | **be-15** ⭐ | Allá el entorno; acá el **motor** de la base |
| 08 — la sesión se cae sola *(auth, track base)* | **be-08** | Allá el `401` del caos; acá un `exp` real sin renovación |
| 19 — el dashboard se arrastra al final del día | **be-05** | Allá memoización; acá el pool de conexiones agotado |

---

# 🧪 Incidentes

Ordenados por ID, que es también el orden sugerido. El ID nunca se reasigna.

---

## Incidente be-01 — La trazabilidad funciona en Network pero no en la consola

> **Fase:** be00 · **Categoría:** 🔥 contrato · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 30-45 min

### 🎫 El ticket

> "Soporte nos pidió que cuando un usuario reporte un error le pasemos el id de
> la petición, ese que sale en la consola. El problema es que casi nunca sale.
> Yo lo veo en la pestaña de red, ahí está el header, pero en la consola no
> aparece nada. Un compañero dice que a él sí le sale, así que a lo mejor es
> algo de mi Chrome."

**Reportado por:** soporte
**Ambiente:** desarrollo y UAT

### 🎯 Qué se te pide

Determinar por qué el header **se ve** y no **se lee**, y de qué lado del cable
está la causa. No hace falta arreglarlo todavía: `be01` lo va a pagar. Lo que sí
hace falta es que quede registrado en `server/CONTRACT.md` como hallazgo, con su
evidencia.

### 🔧 Preparación

```bash
CHAOS_LEVEL=off npm run mock:api        # el mock con el middleware de X-Request-Id
npm start                                # la app en el 3000
```

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

El header llega: lo estás viendo. Así que el backend hizo su parte. La pregunta
no es si el dato viaja, sino **quién tiene permiso para leerlo** una vez que
llegó.

Y el detalle del reporte que parece ruido y no lo es: *"a un compañero sí le
sale"*. ¿Qué tiene distinto la máquina de esa persona?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Abre la consola del navegador y evalúa a mano, con la aplicación cargada:

```javascript
fetch('http://localhost:3001/raffles')
  .then(r => console.log('leído:', r.headers.get('X-Request-Id')));
```

Compara ese resultado con lo que muestra la pestaña Network para esa **misma**
petición. Después mira los headers de **respuesta** completos, no solo el que
buscas.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

En una petición de origen cruzado, ¿qué headers de respuesta le entrega el
navegador a JavaScript, y cuáles se guarda para sí? ¿Qué tiene que declarar el
servidor para ampliar esa lista?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz**

CORS. En una petición de origen cruzado, el navegador **solo entrega a JavaScript
un puñado de headers de respuesta seguros** (`Content-Type`, `Cache-Control` y
unos pocos más). Cualquier otro —incluido `X-Request-Id`— queda visible en
DevTools pero **inaccesible desde código**, salvo que el servidor lo declare
explícitamente:

```
Access-Control-Expose-Headers: X-Request-Id
```

El mock de la Fase 2 pone el header y **no** lo expone. Por eso
`response.headers['x-request-id']` vale `undefined` en el interceptor de
`apiClient`, y el `console.debug` nunca imprime.

Es el hallazgo **`C-05`** de `be00`.

📝 **Y la pista del compañero era real, no ruido.** A quien le funciona es porque
está usando el `proxy` del dev server de CRA: con él, las peticiones salen al
`3000` y no hay origen cruzado, así que CORS no interviene y todos los headers
son legibles. Dos entornos, dos comportamientos, mismo código. Es el "en mi
máquina anda" de manual, y por eso el reporte lo mencionaba.

**Parche mínimo**

Ninguno en esta fase: `be00` **no escribe código**. El entregable es el registro
del hallazgo en `server/CONTRACT.md`, dentro del régimen estricto, con las dos
evidencias: la captura del header en Network y la consola sin la línea del
interceptor.

Y la verificación 9 de `server/smoke.sh`, que hoy **falla a propósito**:

```bash
check "X-Request-Id expuesto a CORS (C-05)" "1" \
  "$(curl -s -D - -o /dev/null -X OPTIONS "$BASE/raffles" \
     -H 'Origin: http://localhost:3000' -H 'Access-Control-Request-Method: GET' \
     | grep -ci 'access-control-expose-headers:.*x-request-id')"
```

**La corrección correcta**

Una línea en el middleware de CORS de `be01`:

```go
w.Header().Set("Access-Control-Expose-Headers", requestIDHeader)
```

Con eso, la verificación 9 pasa a verde y la trazabilidad funciona de verdad.

**Prueba de regresión**

Vive en la suite de contrato de `be08`, y se verifica sobre el **preflight**:

```go
func TestExposeRequestID(t *testing.T) {
	req := httptest.NewRequest("OPTIONS", "/raffles", nil)
	req.Header.Set("Origin", "http://localhost:3000")
	req.Header.Set("Access-Control-Request-Method", "GET")
	rec := httptest.NewRecorder()

	newRouter(testConfig).ServeHTTP(rec, req)

	// No basta con que el header viaje: tiene que estar EXPUESTO.
	require.Contains(t,
		rec.Header().Get("Access-Control-Expose-Headers"), "X-Request-Id")
}
```

Motor: ninguno. Es una prueba de handler y no toca la base.

**Prevención**

La verificación del `smoke.sh`, que corre en cada fase desde `be03`, y la prueba
de contrato de arriba. Las dos son necesarias: el `smoke.sh` atrapa "el ambiente
está mal configurado" y la prueba atrapa "alguien tocó el middleware".

**Por qué llegó a producción**

Porque el síntoma es invisible desde el lado que lo produce. El backend hizo todo
bien y el header está ahí; nada en el servidor sugiere que falte algo. Y del lado
del cliente, `undefined` en un `console.debug` es exactamente lo que se ve cuando
no pasa nada — no hay error, no hay advertencia, no hay señal.

A eso se suma que **funcionaba en la máquina de algunas personas** por el proxy
del dev server, lo que convierte el problema en "algo de tu Chrome" y desvía la
investigación durante semanas.

**Si tu causa fue distinta a esta**

- *"El interceptor lee la clave mal"* — plausible: los navegadores normalizan los
  headers a minúsculas y `response.headers['X-Request-Id']` con mayúsculas sí
  daría `undefined`. Compruébalo: en `axios`, `response.headers` ya normaliza, y
  el interceptor de la Fase 2 usa `'x-request-id'` correctamente. Descartada por
  lectura, pero era una hipótesis correcta de formular.
- *"El mock no siempre pone el header"* — se descarta mirando diez peticiones en
  Network: está en todas.
- Si concluiste *"hay que loguearlo en el servidor y correlacionar por hora"*,
  tapaste el síntoma: funciona, y te deja sin trazabilidad en el cliente para
  siempre.

</details>

---

## Incidente be-02 — El número ganador no tiene dueño

> **Fase:** be00 · **Categoría:** 🔥 contrato · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45-60 min

### 🎫 El ticket

> "Salió el sorteo de la rifa 1 y el número ganador fue el 0347. Está vendido,
> eso lo vemos, pero cuando entramos a ver a quién se lo vendimos no aparece
> nadie. Miramos otras rifas y algunos números sí tienen comprador y otros no,
> y no encontramos el patrón. Los vendedores juran que siempre ponen el
> comprador."

**Reportado por:** tesorería
**Ambiente:** PROD

### 🎯 Qué se te pide

Encontrar el patrón que tesorería no encontró y determinar de qué lado del cable
está la causa. El entregable es el hallazgo registrado en `server/CONTRACT.md`
con la forma canónica del cuerpo — el fix real llega en `be04`.

### 🔧 Preparación

```bash
CHAOS_LEVEL=off npm run mock:api
npm start
# Vende números por los DOS caminos que ofrece la aplicación.
```

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

*"Algunos sí y otros no, sin patrón"* casi nunca significa que no haya patrón:
significa que el patrón no está donde lo buscaron. Tesorería miró **los números**.
Mira tú **cómo se vendieron**.

La aplicación tiene más de un camino para vender. ¿Cuántos?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Abre Network, vende un número desde el tablero, y vende otro provocando el camino
del `sellNumberEpic` de la Fase 6. Compara los **cuerpos** de las dos peticiones
`POST /raffles/:id/numbers/:number/sell`, campo por campo.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si el servidor lee `req.body.participantId` y el cliente manda `participant`,
¿qué guarda el servidor? ¿Y qué código de estado devuelve?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz**

**Dos clientes mandan dos cuerpos distintos al mismo endpoint.**

- El thunk `sellNumber` de la Fase 5 y el de la Fase 7 mandan `{ participantId }`.
- El `sellNumberEpic` de la Fase 6 manda `{ participant }`.

Y el mock lee:

```javascript
record.assign({ status: "sold", participantId: req.body.participantId ?? null })
```

Así que la variante de la Fase 6 **guarda `null` en silencio**. La venta se
registra, el número queda `sold`, el servidor responde `200`, y el comprador
desaparece. No hay error en ninguna capa.

Es el hallazgo **`C-03`** de `be00`.

📝 **Nota de época.** Esto es lo que pasa cuando dos personas implementan el mismo
caso de uso en momentos distintos —la Fase 5 con un thunk, la Fase 6 con un epic—
sin un contrato escrito que arbitre. No es descuido de nadie en particular: es la
consecuencia previsible de no tener el contrato en ninguna parte, que es
exactamente el vacío que `be00` viene a llenar.

**Parche mínimo**

Ninguno en `be00`: se documenta. En `CONTRACT.md`, régimen estricto:

> `POST /raffles/:raffleId/numbers/:number/sell` — cuerpo canónico
> `{"participantId": <número|null>}`. El `sellNumberEpic` de la Fase 6 manda
> `{"participant": …}`; el backend **debe aceptarlo sin explotar** y lo ignora,
> igual que hacía el mock. Cambiar ese comportamiento rompería el contrato
> observable.

**La corrección correcta**

En `be03`, el handler acepta las dos formas explícitamente y lo dice en un
comentario:

```go
var body struct {
	ParticipantID *int64          `json:"participantId"`
	Participant   json.RawMessage `json:"participant"`   // la variante de la Fase 6
}
```

Y la causa raíz se paga en **`be04`**: cuando la identidad venga de
`req.Context()` y no del cuerpo, el problema desaparece por construcción para el
vendedor. Para el **participante** —el comprador— no: ese sí es un dato del
negocio que el cliente tiene que mandar, y unificarlo exigiría tocar el epic de
la Fase 6, lo que choca con la regla del track.

💸 Queda como deuda declarada. La forma correcta sería que el frontend mande un
solo cuerpo, y eso está fuera de `D27`.

**Prueba de regresión**

En la suite de contrato de `be08`:

```go
func TestSellAceptaLasDosFormasDelCuerpo(t *testing.T) {
	// La canónica: guarda el participante.
	srv.POST(t, "/raffles/1/numbers/0347/sell", token,
		`{"participantId":7}`).ExpectStatus(200)
	require.Equal(t, int64(7), participantIDOf(t, 1, "0347"))

	// La de la Fase 6: NO explota, y guarda null. Este test fija el
	// comportamiento actual como esperado — es lo que impide que alguien
	// lo "arregle" y rompa el epic de la Fase 6.
	srv.POST(t, "/raffles/1/numbers/1500/sell", token,
		`{"participant":{"name":"Ana"}}`).ExpectStatus(200)
	require.Nil(t, participantIDOf(t, 1, "1500"))
}
```

Motor: PostgreSQL. Toca la base, aunque no las cuatro áreas críticas.

**Prevención**

El contrato escrito de `be00` con el cuerpo canónico, y la prueba de arriba. Y a
futuro: una sola función de cliente por caso de uso. Que la Fase 5 y la Fase 6
llamen al mismo endpoint desde dos sitios distintos es la condición que hizo
posible la divergencia.

**Por qué llegó a producción**

Porque el fallo **no produce ningún error**. `req.body.participantId ?? null` es
código defensivo bienintencionado: evita un `undefined` y a cambio convierte un
dato faltante en un dato válido. El `200` confirma el éxito, la UI pinta el
número vendido, y el problema aparece meses después, cuando alguien reclama un
premio.

**Si tu causa fue distinta a esta**

- *"El vendedor no puso el comprador"* — es la hipótesis obvia y la que
  tesorería asumió. Se descarta mirando el cuerpo en Network: el dato **iba** en
  la petición.
- *"Se pierde en la base"* — no hay base todavía; es un archivo JSON.
- Si concluiste *"hay que validar que `participantId` no sea nulo y devolver
  `400`"*, cuidado: la Fase 5 manda `participantId: null` a propósito, porque el
  curso base no tiene formulario de comprador. Ese `400` rompería la venta normal.

</details>

---

## Incidente be-03 — El backend se cae solo y vuelve, tres veces al día

> **Fase:** be01 · **Categoría:** 🔥 despliegue · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 30-45 min

### 🎫 El ticket

> "Desde que pasamos al backend nuevo, un par de veces al día la aplicación se
> queda muerta unos segundos: cualquier cosa que hagas da error de red, y
> después vuelve sola. No es siempre a la misma hora ni con la misma pantalla.
> El equipo de infraestructura dice que el contenedor se está reiniciando pero
> que ellos no lo tocan."

**Reportado por:** el propio equipo
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducirlo a voluntad —que es la mitad del trabajo— y determinar por qué el
cliente ve un **error de red** y no un `500`. Después, el fix.

### 🔧 Preparación

```bash
git checkout incidente/be-03
cd server && PORT=3011 go run ./cmd/api
```

La rama trae un handler que revienta con ciertos datos. Encuéntralo tú.

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

*"Error de red"* y *"vuelve sola"* son dos datos muy concretos. Un `500` no es un
error de red: llega con status, con cuerpo y con headers. Un error de red es lo
que ve el cliente cuando **no llega nada**.

¿Qué tendría que pasarle al servidor para que no llegue nada, y para que unos
segundos después vuelva a responder?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Mira la **terminal del servidor** mientras reproduces, no el navegador. Y fíjate
en si el proceso sigue vivo después: `curl localhost:3011/health`.

Con `curl -v` sobre la petición que falla, compara el mensaje con el de un `500`
normal (puedes provocar uno con `CHAOS_LEVEL=high`).

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

En Go, ¿qué le pasa al proceso cuando un handler entra en pánico y nadie lo
recupera? ¿Y en Node con Express?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz**

Un `panic` dentro de un handler, sin `recoverMiddleware` en la cadena.

En Go, **un pánico que nadie recupera desenrolla toda la pila y termina el
proceso**. No muere esa petición: muere el servidor entero, con todas las
conexiones de todos los usuarios. El orquestador lo reinicia unos segundos
después, y de ahí el "vuelve sola".

Por eso el cliente ve un error de red y no un `500`: **no hay nadie que responda**.
`axios` entrega un `Network Error` sin `error.response`, o sea sin status, sin
cuerpo y **sin `X-Request-Id`** — todo el aparato de diagnóstico que `be00`
levantó desaparece justo cuando más falta hace.

📝 **La diferencia cultural, que es la lección del incidente.** En Express, un
`throw` síncrono dentro de un handler lo atrapa el framework: responde `500` y el
proceso sigue. Quien viene de Node asume esa red de seguridad. Go no la trae, y
`gorilla/mux` tampoco: **el middleware de recuperación es tuyo y es obligatorio**.

**Parche mínimo**

```go
// server/internal/http/middleware.go
func recoverMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// defer corre al salir, pase lo que pase — también con pánico.
		// Es la única forma de que recover() llegue a ejecutarse.
		defer func() {
			if rec := recover(); rec != nil {
				// El id es lo que vuelve diagnosticable el pánico: ata el
				// 500 que vio el usuario con esta línea del log.
				log.Printf("[req-id %s] PÁNICO en %s %s: %v",
					RequestIDFrom(r.Context()), r.Method, r.URL.Path, rec)
				// Mensaje genérico: nunca se filtra el detalle interno.
				writeError(w, http.StatusInternalServerError, "Error interno del servidor")
			}
		}()
		next.ServeHTTP(w, r)
	})
}
```

Y su **posición en la cadena**, que es la mitad del fix:

```
requestID → logging → cors → recover → chaos → rutas
```

`recover` va **por dentro** de `logging` y de `cors`: por dentro de `logging`
para que el `500` quede registrado con su duración, y por dentro de `cors` para
que la respuesta de error lleve los headers de origen cruzado. Un `500` sin
headers de CORS es, para el navegador, un error de red opaco — o sea, volverías
a ver el mismo síntoma con otra causa.

**La corrección correcta**

Además del `recover`, arreglar el pánico. Un pánico recuperado sigue siendo un
bug: el `recover` evita que se lleve el servidor por delante, no que la petición
falle. Localízalo con el stack trace:

```go
log.Printf("[req-id %s] PÁNICO: %v\n%s",
	RequestIDFrom(r.Context()), rec, debug.Stack())
```

⚠️ El stack trace va **al log**, nunca al cliente: revela rutas, nombres de
paquete y estructura interna (`bea-08` §4).

**Prueba de regresión**

```go
func TestPanicoDevuelve500YNoTumbaElProceso(t *testing.T) {
	r := mux.NewRouter()
	r.HandleFunc("/boom", func(http.ResponseWriter, *http.Request) {
		panic("explota a propósito")
	})
	handler := buildChain(r)   // la cadena completa

	rec := httptest.NewRecorder()
	handler.ServeHTTP(rec, httptest.NewRequest("GET", "/boom", nil))

	require.Equal(t, 500, rec.Code)
	require.Contains(t, rec.Body.String(), "Error interno del servidor")
	// La otra mitad: que la respuesta sea legible desde el navegador.
	require.NotEmpty(t, rec.Header().Get("Access-Control-Allow-Origin"))
	require.NotEmpty(t, rec.Header().Get("X-Request-Id"))
	// Si el proceso hubiera muerto, este test no habría llegado hasta acá.
}
```

Motor: ninguno.

**Prevención**

El middleware, la prueba, y una alerta sobre reinicios del contenedor: **un
proceso que se reinicia solo es siempre un incidente**, aunque el orquestador lo
disimule. Que "vuelve sola" se haya normalizado durante días es parte del
problema.

**Por qué llegó a producción**

Porque el orquestador hace bien su trabajo. Un reinicio automático convierte una
caída total en unos segundos de indisponibilidad, y unos segundos de
indisponibilidad se confunden con "internet estuvo lento". Sin una alerta sobre
reinicios, el sistema estuvo **fallando de la forma más grave posible** —muriendo
entero— y el síntoma parecía menor.

Y el diagnóstico se desvió porque el equipo venía de Node, donde ese síntoma es
imposible: el framework atrapa los `throw` y el proceso no se cae. Es un buen
recordatorio de que las intuiciones no cruzan de lenguaje.

**Si tu causa fue distinta a esta**

- *"Es el `timeout` del caos"* — plausible, porque también da error de red. Se
  descarta comprobando `CHAOS_LEVEL=off` y que el proceso **muere**, cosa que el
  caos no hace.
- *"Se cae la base y el pool se agota"* — daría `500`, no error de red, y el
  proceso seguiría vivo. Es el incidente `be-05`.
- Si tu fix fue *"que el orquestador reinicie más rápido"*, tapaste el síntoma de
  la forma más costosa posible.

</details>

---

## Incidente be-04 — Las rifas se crean con la hora corrida

> **Fase:** be02 · **Categoría:** 🔥 base de datos · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45-60 min

### 🎫 El ticket

> "Creo una rifa que cierra a las 10 de la noche, la guardo, y cuando vuelvo a
> abrirla dice que cierra a las 3 de la mañana del día siguiente. Si la edito y
> la vuelvo a guardar, se queda igual. Lo raro es que en la pantalla del listado
> se ve bien. Pasó desde que cambiamos el servidor."

**Reportado por:** supervisor
**Ambiente:** desarrollo

### 🎯 Qué se te pide

Determinar si el **instante** guardado es correcto o si de verdad se movió — no
es lo mismo, y confundirlo lleva a arreglar lo que no está roto. Después, decidir
dónde va el fix: ¿código, esquema o configuración?

### 🔧 Preparación

```bash
git checkout incidente/be-04
docker start rifas-pg
cd server && migrate -path migrations/postgres -database "$DATABASE_URL" up
go run ./cmd/seed -file ../mock/db.json
PORT=3011 go run ./cmd/api
```

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

Antes de nada, contesta esta pregunta con una consulta: *¿el instante que hay en
la base es el mismo que se guardó?* Un instante puede **representarse** de
muchas formas sin cambiar de valor.

`22:00-05:00` y `03:00+00:00` del día siguiente, ¿son horas distintas o la misma
escrita de dos maneras?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```sql
SHOW TimeZone;
SELECT closes_at FROM raffles WHERE id = 1;
SELECT closes_at AT TIME ZONE 'America/Bogota' FROM raffles WHERE id = 1;
```

Y del otro lado, el JSON crudo:

```bash
curl -s localhost:3011/raffles/1 | jq -r .closesAt
```

Compáralo con lo que devolvía el mock antes del cambio.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

`TIMESTAMPTZ` no guarda ninguna zona horaria: guarda un instante y lo **muestra**
en la zona de la sesión. ¿En qué zona está tu sesión, y quién la fijó?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz**

**El instante no se movió.** `2026-08-30T22:00:00-05:00` y
`2026-08-31T03:00:00Z` son **exactamente el mismo momento**, escrito en dos
zonas distintas.

`TIMESTAMPTZ` guarda un instante en UTC y lo convierte a la zona de la **sesión**
al leerlo. El contenedor de Postgres arranca con `TimeZone = UTC`, así que
devuelve `03:00+00`, `lib/pq` lo entrega como un `time.Time` en UTC, y
`encoding/json` lo serializa con `Z`. El mock devolvía la cadena literal del
`db.json`, con su `-05:00`.

Así que hay **dos hechos y solo uno es un problema**:

1. El dato es correcto. Nada que arreglar. ✅
2. La **representación** cambió respecto de lo que devolvía el mock, y el
   contrato de `be00` fija el offset. ⚠️

Y por eso el listado se ve bien: la UI hace `new Date(closesAt)`, que interpreta
las dos formas igual y muestra la hora local correcta. El único sitio donde se
nota es donde alguien lee la cadena cruda — el formulario de edición.

Es el **error común nº 2 de `be03`** y la Divergencia 2 de `be02`, vistas desde el
ticket.

**Parche mínimo**

Configuración, no código: fijar la zona de la sesión.

```go
// server/internal/storage/storage.go, en Open()
if dialect == Postgres {
	if _, err := db.ExecContext(ctx, "SET TIME ZONE 'America/Bogota'"); err != nil {
		return nil, fmt.Errorf("fijando la zona de la sesión: %w", err)
	}
}
```

Con eso, `GET /raffles/1` vuelve a devolver `2026-08-30T22:00:00-05:00`, byte a
byte como el mock.

**La corrección correcta**

La de `be06`, que es una **política** y no un parche: dos zonas con jerarquía
explícita y un porqué para cada una.

| Qué | Valor | Para qué |
|---|---|---|
| Proceso Go | `TZ=UTC` | Decidir y comparar instantes |
| Sesión de base | `America/Bogota` | **Solo** serializar la salida |

> 🧭 El instante es la verdad; el offset de la serialización es cosmética. La
> zona de presentación no participa en ninguna decisión.

Lo importante es que la zona quede **fijada explícitamente** y no heredada del
host: un backend cuyo comportamiento depende de cómo esté configurada la máquina
falla distinto en cada ambiente.

**Prueba de regresión**

```go
func TestClosesAtConservaElOffsetDelContrato(t *testing.T) {
	var r map[string]interface{}
	srv.GET(t, "/raffles/1", token).ExpectStatus(200).JSON(t, &r)

	// El contrato de be00 fija offset, no "Z".
	require.Regexp(t, `[+-]\d{2}:\d{2}$`, r["closesAt"])
}

func TestElInstanteNoSeMueve(t *testing.T) {
	original, _ := time.Parse(time.RFC3339, "2026-08-30T22:00:00-05:00")
	created, err := store.Create(ctx, raffle.Raffle{ClosesAt: original, /* … */ })
	require.NoError(t, err)

	found, err := store.FindByID(ctx, created.ID)
	require.NoError(t, err)
	// Equal compara el INSTANTE. Con == compararías también huso y reloj
	// monótono, y fallaría por motivos que no son los del test.
	require.True(t, found.ClosesAt.Equal(original))
}
```

Motor: **PostgreSQL obligatorio**. Toca zonas horarias, que es una de las cuatro
áreas de la regla del motor (`D18`). En SQLite este par de pruebas no significa
nada: no hay tipo fecha.

**Prevención**

La política escrita, las dos pruebas, y —la más eficaz— el ejercicio 22 de
`be06`: correr la suite entera con `TZ=Asia/Tokyo`. Si algo falla, hay una
comparación mirando componentes de fecha. Ese paso debería estar en CI.

**Por qué llegó a producción**

Porque **el dato nunca estuvo mal** y todos los indicadores decían que sí. El
supervisor vio una hora distinta y reportó, con toda la razón, que la hora había
cambiado. Cualquiera habría empezado buscando dónde se suma o resta tiempo — y no
hay ninguna línea así en todo el sistema.

Es el caso arquetípico de un bug donde **la primera media hora se gasta
confirmando qué está realmente roto**. Aquí lo roto era la representación, no el
valor, y esa distinción no se le puede pedir a quien reporta.

**Si tu causa fue distinta a esta**

- *"Alguien suma 5 horas en algún lado"* — la hipótesis natural. Se descarta con
  `git grep -n "Add(.*Hour"`: no hay ninguna.
- *"El navegador convierte mal"* — se descarta mirando el JSON crudo con `curl`:
  el offset ya viene distinto del servidor.
- Si tu fix fue **restar cinco horas al guardar**, acabas de introducir el bug de
  verdad: ahora el instante sí se mueve, y en el próximo ambiente con otra zona
  se moverá otra vez y en otra dirección.

</details>

---

## Incidente be-05 — Todo funciona hasta que hay gente

> **Fase:** be02 · **Categoría:** 🔥 base de datos · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 60-90 min
> · Hermano del incidente **19** del track base, con otra causa raíz

### 🎫 El ticket

> "En la mañana todo va perfecto. Como a las cinco de la tarde, que es cuando se
> vende más, la aplicación se pone lentísima y al rato ya no responde nada:
> queda todo cargando. Si reiniciamos el servidor, vuelve a funcionar de una y
> aguanta un par de horas. Probamos en la mañana con las mismas pantallas y no
> pasa."

**Reportado por:** supervisor
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducirlo **sin esperar a las cinco de la tarde** —esa es la parte difícil— y
determinar qué recurso se agota. El fix, y una prueba que lo habría atrapado.

### 🔧 Preparación

```bash
git checkout incidente/be-05
docker start rifas-pg
cd server && PORT=3011 SQL_DEBUG=1 go run ./cmd/api
```

Vas a necesitar carga. Un bucle basta:

```bash
for i in $(seq 1 200); do curl -s -o /dev/null localhost:3011/raffles & done; wait
```

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

*"Reiniciamos y vuelve"* es el dato más informativo del ticket: significa que algo
**se acumula** en el proceso y no se libera. No es la base —esa no se reinició— ni
el frontend.

*"Queda todo cargando"* también dice mucho: las peticiones no fallan, **esperan**.
¿Esperando qué?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Mientras el sistema está lento, desde otra terminal:

```sql
SELECT count(*), state FROM pg_stat_activity
WHERE datname = 'rifas' GROUP BY state;
```

Y desde Go, si instrumentas: `db.Stats()` te da `OpenConnections`, `InUse` y
`WaitCount`. Compáralos con `SetMaxOpenConns(25)`.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

`*sql.DB` es un pool. ¿Qué le pasa a una conexión cuando abres un `*sql.Rows` y
nunca lo cierras? ¿Y qué diferencia hay entre `Query` y los `Get`/`Select` de
`sqlx`?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz**

Un `*sql.Rows` sin cerrar. La rama trae esto:

```go
// ❌ Cada llamada retiene una conexión del pool PARA SIEMPRE.
rows, err := s.db.QueryContext(ctx, query)
if err != nil {
	return nil, err
}
// falta: defer rows.Close()
for rows.Next() { … }
return raffles, nil
```

`Query` devuelve un `Rows` que **mantiene tomada su conexión** hasta que se cierra
—explícitamente o al agotar el iterador—. Un `return` anticipado, un `break`, o
simplemente olvidar el `defer`, y esa conexión no vuelve al pool nunca.

Con `SetMaxOpenConns(25)`, hacen falta 25 llamadas para agotarlo. A partir de la
26, **cada petición espera indefinidamente** una conexión que no va a liberarse.
De ahí el síntoma exacto: no falla, **espera**. Y reiniciar el proceso vacía el
pool, lo que explica por qué "vuelve de una".

📝 **Y por eso solo pasa a las cinco.** El agotamiento no depende del tiempo sino
del **número de llamadas** a esa ruta. En la mañana se llega a 25 en tres horas;
a las cinco, en veinte minutos. El patrón horario es una consecuencia del tráfico,
no una causa — y buscar "qué pasa a las cinco" es el desvío que este ticket
invita a tomar.

**Parche mínimo**

```go
rows, err := s.db.QueryContext(ctx, query)
if err != nil {
	return nil, err
}
// Sin excepción, en la línea siguiente. Cualquier camino de salida —error,
// break, return anticipado— pasa por acá.
defer rows.Close()
```

**La corrección correcta**

No usar `Query` a mano cuando `sqlx` ya resuelve el caso:

```go
// Select cierra el Rows por ti. Es una de las razones de usar sqlx y no
// database/sql pelado: elimina por construcción toda una clase de fugas.
raffles := []Raffle{}
if err := s.db.SelectContext(ctx, &raffles, query); err != nil {
	return nil, fmt.Errorf("listando rifas: %w", err)
}
```

Regla operativa que vale la pena adoptar: **si un archivo de store contiene
`QueryContext`, tiene que tener un `defer rows.Close()` tres líneas más abajo.**
Es un `grep` de revisión de código.

**Prueba de regresión**

```go
func TestElPoolNoSeAgota(t *testing.T) {
	db := testsupport.OpenPostgres(t)
	testsupport.MustPostgres(t, db, "mide el comportamiento real del pool de conexiones")
	db.SetMaxOpenConns(5)   // pool pequeño: la fuga aparece enseguida

	store := raffle.NewStore(db)
	for i := 0; i < 50; i++ {   // 10× el tamaño del pool
		ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
		_, err := store.List(ctx)
		cancel()
		// Con la fuga, a partir de la sexta iteración esto es
		// "context deadline exceeded": la conexión nunca llega.
		require.NoError(t, err, "iteración %d: el pool se agotó", i)
	}
	require.Zero(t, db.Stats().InUse, "quedaron conexiones tomadas")
}
```

Motor: **PostgreSQL obligatorio**. Con SQLite el pool es de una sola conexión
(`be02`) y el test no significa nada.

**Prevención**

Tres capas, y las tres hacen falta:

1. La prueba de arriba, con un pool pequeño.
2. **Exportar `db.Stats()`** —`InUse` y `WaitCount`— y alertar cuando `InUse` se
   acerque al máximo. Es la señal temprana: sube durante horas antes de que algo
   falle.
3. Timeouts en el contexto de cada consulta. No evitan la fuga, pero convierten
   "esperar para siempre" en un error con mensaje, que es diagnosticable.

**Por qué llegó a producción**

Porque **el código funciona perfectamente hasta que no**. No hay error, no hay
advertencia, no hay degradación gradual visible: el sistema va bien con 24
llamadas y se cuelga con 26. Ninguna prueba funcional lo detecta, porque cada
prueba hace una llamada y el pool se recicla entre ellas.

Y el reporte apuntaba a la hora, que es la correlación visible pero no la causa.
Un equipo puede pasar días buscando "qué proceso corre a las cinco".

**Si tu causa fue distinta a esta**

- *"Es un problema de rendimiento de la consulta"* — se descarta mirando
  `SQL_DEBUG`: las consultas que **sí** se ejecutan tardan lo mismo que en la
  mañana. Lo lento es esperar el turno.
- *"La base se queda sin conexiones"* — cerca, y vale la pena distinguirlo: si el
  límite lo pusiera Postgres (`max_connections`), verías `too many connections`
  como **error**. Acá no hay error: hay espera, y eso apunta al pool del cliente.
- *"Hay un deadlock"* — daría `deadlock detected` en el log y Postgres mataría una
  de las transacciones. No es el caso.
- Si tu fix fue **subir `SetMaxOpenConns`**, compraste tiempo: ahora se cuelga a
  las siete en vez de a las cinco.

</details>

---

## Incidente be-06 — El comprador aparece en blanco, pero solo a veces

> **Fase:** be03 · **Categoría:** 🔥 contrato · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45-60 min

### 🎫 El ticket

> "Desde el cambio de servidor, el tablero se ve raro: números que están libres
> aparecen como si tuvieran comprador. Y cuando entras al detalle no hay ningún
> nombre. Los vendedores no confían en la pantalla y están anotando en papel."

**Reportado por:** vendedor
**Ambiente:** desarrollo

### 🎯 Qué se te pide

Determinar de qué lado del cable está la causa y por qué **ningún test la
detectó**. Después el fix, y la prueba que faltaba.

### 🔧 Preparación

```bash
git checkout incidente/be-06
cd server && go run ./cmd/seed -file ../mock/db.json && go run ./cmd/api
npm start
```

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

El frontend no cambió: `git diff pre-backend-go..HEAD -- . ':!server'` está
vacío. Así que si la pantalla se ve distinta, lo que cambió es **lo que llega**.

Mira el JSON crudo antes de mirar el componente.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```bash
curl -s localhost:3001/raffles/1/numbers | jq '.[0]'
```

Compáralo con lo que devolvía el mock, campo por campo. Fíjate en el **tipo** de
cada valor, no solo en si el campo está.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

En JavaScript, ¿`if (numero.participantId)` es verdadero para `null`? ¿Y para
`{"Int64":0,"Valid":false}`?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz**

`sql.NullInt64` serializado a JSON.

```go
// ❌ Escanea perfecto desde la base y produce esto:
//    {"raffleId":1,"number":"0347","status":"available",
//     "participantId":{"Int64":0,"Valid":false}}
type RaffleNumber struct {
	ParticipantID sql.NullInt64 `json:"participantId" db:"participant_id"`
}
```

El mock devolvía `null`. El backend devuelve **un objeto**. Y como en JavaScript
cualquier objeto es *truthy*, todo `if (number.participantId)` del tablero pasa a
ser verdadero **para todos los números**, incluidos los disponibles. De ahí que
aparezcan "con comprador"; y como el objeto no tiene nombre, el detalle sale en
blanco.

**Sin un solo error en consola.** El JSON es válido, la petición es `200`, y el
componente hace exactamente lo que le pidieron.

**Parche mínimo**

Un puntero:

```go
// nil serializa a null, que es lo que el contrato de be00 exige. Y el
// puntero además distingue "no hay participante" de "el participante es
// el cero", que es una distinción del dominio, no un detalle de Go.
ParticipantID *int64 `json:"participantId" db:"participant_id"`
```

`sqlx` lo escanea igual de bien. Es un cambio de una palabra.

**La corrección correcta**

La misma, más la regla general: **`sql.NullX` sirve para escanear, no para
serializar**. Si un tipo de `database/sql` cruza hasta la etiqueta JSON, es un
bug esperando su turno. Lo mismo vale para `sql.NullString`, `sql.NullTime` y
compañía.

**Prueba de regresión**

Y acá está lo que hace especial a este incidente:

```go
// ❌ ESTA PRUEBA NO LO ATRAPA, aunque parezca que sí.
func TestFindOneDevuelveElNumero(t *testing.T) {
	n, err := store.FindOne(ctx, 1, "0347")
	require.NoError(t, err)
	require.Equal(t, "available", n.Status)   // pasa con las dos versiones
}

// ✅ Esta sí. El problema no está en los datos: está en la SERIALIZACIÓN.
// Hay que comparar el JSON, no el struct.
func TestParticipantIdNuloLlegaComoNull(t *testing.T) {
	body := srv.GET(t, "/raffles/1/numbers", token).ExpectStatus(200).Raw()

	require.Contains(t, string(body), `"participantId":null`)
	// El centinela: si aparece "Valid", alguien volvió a meter un sql.NullX.
	require.NotContains(t, string(body), `"Valid":`)
}
```

📖 **La lección transferible:** un test que deserializa a un struct tipado **no
puede detectar un problema de contrato**, porque convierte lo que llegue a lo que
el struct dice. En pruebas de contrato hay que mirar los bytes, o deserializar a
`map[string]interface{}`.

Motor: PostgreSQL.

**Prevención**

La prueba de contrato, y un `grep` en la revisión de código:
`grep -rn "sql.Null" internal/*/[a-z]*.go` — cada resultado tiene que estar en un
struct que **no** se serialice.

**Por qué llegó a producción**

Porque `sql.NullInt64` es **la respuesta correcta a la pregunta equivocada**.
Quien lo escribió resolvía "cómo escaneo una columna anulable", y esa es
exactamente su función. El error está en que ese tipo llegó a la frontera del
contrato, y nada en el compilador ni en las pruebas señala ese cruce.

Y la suite estaba verde: todas las pruebas de `be02` comparaban structs, que es
lo natural. El bug vivía en el único sitio que nadie estaba mirando.

**Si tu causa fue distinta a esta**

- *"El seed no cargó los participantes"* — no hay participantes en el `db.json`;
  es correcto que no haya ninguno. La hipótesis es razonable y se descarta con un
  `SELECT`.
- *"El componente cambió"* — se descarta con el `git diff` del contrato.
- Si tu fix fue **cambiar el componente para que compruebe
  `participantId?.Valid`**, arreglaste la pantalla y rompiste la regla del track:
  el frontend no se toca, y además el día que el backend devuelva `null` correcto,
  volverías a romperlo.

</details>

---

## Incidente be-07 — Faltan datos en las liquidaciones de agosto

> **Fase:** be03 · **Categoría:** 🔥 contrato · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 60-90 min

### 🎫 El ticket

> "Nos pidieron el informe de cierre del semestre y necesitamos, por rifa,
> cuántos números se vendieron y si el ganador estaba vendido. Eso lo veíamos
> antes en la pantalla de liquidación. Ahora sacamos los datos y esos dos campos
> no están en ninguna parte. Las liquidaciones de marzo sí los tienen; las de
> agosto en adelante, no. Nadie tocó nada de liquidaciones."

**Reportado por:** tesorería
**Ambiente:** PROD

### 🎯 Qué se te pide

Determinar qué se perdió, **desde cuándo**, y si es recuperable. Este incidente
no termina necesariamente en un fix: parte del entregable es decidir qué se le
responde a tesorería.

### 🔧 Preparación

```bash
git checkout incidente/be-07
cd server && migrate -path migrations/postgres -database "$DATABASE_URL" up
go run ./cmd/api
# Liquida una rifa desde la aplicación, con Network abierto.
```

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

Los campos que faltan, ¿**salieron** del navegador? Mira el cuerpo del
`POST /settlements` en Network, no la respuesta.

Si el dato viajó y no está guardado, el problema está del lado del servidor. Y
"desde agosto" tiene una fecha: ¿qué cambió entonces?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```bash
curl -s localhost:3001/settlements | jq '.[0]'
```

Compara los campos de esa respuesta con el cuerpo que manda `createSettlement`
(Fase 8). Y después:

```sql
\d settlements
```

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si un `INSERT` solo nombra cinco columnas y el cuerpo trae ocho campos, ¿qué pasa
con los otros tres? ¿Falla, avisa, o devuelve `201`?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz**

El esquema de `be02` se diseñó **sin medir el cuerpo real** del
`POST /settlements`.

El thunk `createSettlement` de la Fase 8 manda ocho campos:

```json
{ "raffleId": 1, "winningNumber": "0347", "isWinnerSold": true, "soldCount": 42,
  "totalCollected": 21000000, "prizeAmount": 50000000, "margin": -29000000,
  "settledAt": "2026-08-30T22:05:11.031Z" }
```

Y la tabla tiene sitio para cinco: `raffle_id`, `winning_number`,
`total_collected`, `prize_amount`, `margin`. Los otros tres —`isWinnerSold`,
`soldCount`, `settledAt`— **el `INSERT` ni los nombra**.

El resultado es lo peor que puede pasar: **no falla nada**. El `201` sale bien, la
aplicación festeja, el slice guarda la liquidación completa (la que tiene en
memoria), y el dato se pierde en el momento de guardarse. El síntoma aparece seis
meses después, cuando alguien pregunta.

"Desde agosto" es la fecha del reemplazo de `be03`: `json-server` guardaba el
JSON entero, campos incluidos, porque no tenía esquema. **La rigidez del esquema
es lo correcto y es también lo que hizo visible un hueco que antes no existía.**

📝 Y por eso las de marzo sí los tienen: están en el `db.json` viejo.

**¿Es recuperable?** `soldCount` e `isWinnerSold` sí, reconstruyéndolos desde los
números vendidos de cada rifa. `settledAt` no: ese instante no está en ninguna
parte. Eso es lo que hay que responderle a tesorería, y conviene decirlo así de
claro.

**Parche mínimo**

Una migración. El fix **va en el esquema**, no en el código:

```sql
-- server/migrations/postgres/000003_settlement_full_shape.up.sql
ALTER TABLE settlements ADD COLUMN is_winner_sold BOOLEAN     NOT NULL DEFAULT false;
ALTER TABLE settlements ADD COLUMN sold_count     INTEGER     NOT NULL DEFAULT 0;
-- 💸 settledAt lo calcula el CLIENTE (new Date() en el thunk). Se guarda tal
-- cual llega porque cambiarlo sería cambiar el contrato. La autoridad del
-- reloj se cobra en be06.
ALTER TABLE settlements ADD COLUMN settled_at     TIMESTAMPTZ;
```

Más los tres campos en el `INSERT` del store. Y el `down` correspondiente, con su
trampa: SQLite no soporta `DROP COLUMN` hasta la 3.35, y con restricciones incluso
después.

**La corrección correcta**

Además de la migración, el **backfill** de lo recuperable:

```sql
-- soldCount se puede reconstruir desde los números vendidos.
UPDATE settlements s SET sold_count = (
    SELECT count(*) FROM raffle_numbers n
    WHERE n.raffle_id = s.raffle_id AND n.status = 'sold')
WHERE sold_count = 0;
```

⚠️ Y con una advertencia honesta en el informe: ese número es el de **hoy**, no el
del día de la liquidación. Si después se vendió algo más, no coinciden. Un dato
reconstruido no es el dato original y hay que etiquetarlo como tal.

**Prueba de regresión**

```go
func TestSettlementGuardaLosOchoCamposDelContrato(t *testing.T) {
	body := `{"raffleId":1,"winningNumber":"0347","isWinnerSold":true,
	          "soldCount":42,"totalCollected":21000000,"prizeAmount":50000000,
	          "margin":-29000000,"settledAt":"2026-08-30T22:05:11Z"}`

	srv.POST(t, "/settlements", token, body).ExpectStatus(201)

	var s settlement.Settlement
	require.NoError(t, db.Get(&s, `SELECT * FROM settlements WHERE raffle_id = 1`))

	// La aserción que importa: lo que ENTRÓ está en la base. Un test que
	// solo comprobara el 201 pasaría con el bug intacto.
	require.Equal(t, 42, s.SoldCount)
	require.True(t, s.IsWinnerSold)
	require.NotNil(t, s.SettledAt)
}
```

Motor: PostgreSQL.

**Prevención**

Una prueba de contrato por endpoint que verifique que **todo campo que entra se
persiste o se descarta a propósito**. Y una regla de proceso más barata que
cualquier prueba: **el esquema se diseña con el cuerpo real de las peticiones al
lado**, medido en Network, no deducido leyendo el slice. Es exactamente lo que
`be00` predica y lo que `be02` no aplicó del todo.

**Por qué llegó a producción**

Porque **ignorar campos desconocidos es el comportamiento por defecto de casi
todo**: `encoding/json` los descarta sin avisar y SQL solo escribe las columnas
que nombras. Los dos hacen lo razonable, y de la suma sale una pérdida silenciosa.

No hubo ningún síntoma durante seis meses. No hay error que buscar, no hay alerta
que configurar, no hay usuario que se queje — hasta que alguien necesita el dato y
ya no está. Es la clase de bug que solo se previene **antes**, y esa es la
lección: los bugs de contrato que duelen no son los que fallan, son los que pasan.

**Si tu causa fue distinta a esta**

- *"El frontend dejó de mandarlos"* — se descarta en Network: van en el cuerpo.
- *"Se perdieron al migrar los datos"* — se descarta comparando con el `db.json`:
  las viejas los tienen; las nuevas nacieron sin ellos.
- Si concluiste *"hay que guardar el JSON entero en una columna `jsonb` por si
  acaso"*, es una respuesta defendible y vale la pena discutirla: resuelve la
  pérdida y renuncia a que el esquema te avise. Cuál prefieres depende de si el
  dato es de negocio o de auditoría.

</details>

---

## Incidente be-08 — A algunos los saca de la sesión al mediodía y a otros nunca

> **Fase:** be04 · **Categoría:** 🔥 autenticación · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 30-45 min
> · Hermano del incidente **08** del track base, con otra causa raíz

### 🎫 El ticket

> "Hay dos o tres personas a las que se les cierra la sesión sola casi todos los
> días, siempre más o menos a la misma hora, y pierden lo que estaban haciendo.
> A la mayoría no le pasa nunca. Ya probamos con otro navegador y con otra
> máquina y sigue igual. ¿Será que tienen la cuenta mal configurada?"

**Reportado por:** soporte
**Ambiente:** PROD

### 🎯 Qué se te pide

Explicar el patrón —por qué a unos sí y a otros no, y por qué siempre a la misma
hora— y decidir si hay algo que arreglar. **Ojo con la última parte.**

### 🔧 Preparación

```bash
git checkout incidente/be-08
cd server && JWT_TTL=3m go run ./cmd/api   # tres minutos, para no esperar horas
npm start
```

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

*"Siempre a la misma hora"* suena a algo programado. Pero fíjate: la pregunta no
es a qué hora **se cierra** la sesión, sino a qué hora **empezó**.

Y "a la mayoría no le pasa nunca" es igual de informativo: ¿qué hacen distinto
esas personas durante el día?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Pega el token en https://jwt.io y mira el claim `exp`. Conviértelo a hora local y
compáralo con el `iat`.

Después, en el log del backend, busca los `401` de esas personas y mira qué dice
el mensaje.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si el token dura una hora y alguien entra a las 8 y trabaja sin cerrar el
navegador, ¿a qué hora vence? ¿Y alguien que entra y sale cinco veces al día?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz**

El JWT expira y **no hay renovación**. El sistema funciona exactamente como se
diseñó.

Cuando el `exp` pasa, el middleware de `be04` devuelve `401`, y el interceptor de
respuesta de la Fase 2 —escrito mucho antes, para el `401` que inyectaba el
caos— dispara el logout global. El usuario aterriza en el login sin explicación y
pierde lo que estuviera haciendo.

El patrón se explica solo en cuanto lo ves:

- **A quienes les pasa** entran a primera hora y **no cierran el navegador en todo
  el día**. Su token vence `JWT_TTL` después del login: siempre a la misma hora,
  todos los días.
- **A quienes no les pasa** hacen logout o cierran el navegador varias veces, así
  que renuevan el token sin darse cuenta cada vez que vuelven a entrar.

No tiene nada que ver con la cuenta, ni con el navegador, ni con la máquina — y
por eso las tres pruebas de soporte no encontraron nada.

📝 `bea-04` §5: **un JWT es autocontenido y no se puede revocar ni renovar solo.**
Esa es su gracia y su límite.

**Parche mínimo**

Ninguno en el código. Y esta es la parte incómoda del incidente:

> 🧭 **El sistema hizo lo correcto.** Un token que expira es una propiedad de
> seguridad, no un fallo. Lo que falta es la **renovación**, y está declarada como
> deuda 💸 viva en `bea-09` §1 con su motivo escrito.

Lo que sí se puede hacer hoy, y hay que hacerlo:

1. **Responderle a soporte con la explicación real**, para que dejen de buscar en
   la configuración de las cuentas.
2. **Subir `JWT_TTL`** si la ventana operativa lo justifica —una jornada de ventas
   dura más de una hora—. Es configuración, no código, y no rompe nada.
3. **Registrar el caso** como el disparador de la deuda, que es precisamente lo
   que `bea-09` pide vigilar.

**La corrección correcta**

*Refresh tokens*: un token corto para las peticiones y uno largo para renovarlo.
Diseño completo en el ejercicio 31 de `be04`.

⚠️ Y por qué no se hace acá: exige que **el cliente** llame al endpoint de
renovación, o sea tocar `apiClient.js`, sus dos interceptores y probablemente
`authSlice.js`. Eso es media capa de red del frontend, y **choca con la regla del
track y con `D27`**, cuya única excepción está acotada a `authService.js`.

Decidir no pagar una deuda y escribir por qué es una forma legítima de
administrarla. Lo que no sería legítimo es que el usuario y soporte no sepan que
existe.

**Prueba de regresión**

No hay regresión que probar —no hay bug— pero sí una prueba que **fija el
comportamiento como esperado**, que es lo que impide que alguien lo "arregle"
quitando el `exp`:

```go
func TestTokenVencidoSeRechaza(t *testing.T) {
	signer, _ := auth.NewSigner(testSecret, -1*time.Minute)  // ya nació vencido
	token, err := signer.Sign(2, "organizador@rifas.test")
	require.NoError(t, err)

	_, err = signer.Verify(token)
	require.ErrorIs(t, err, auth.ErrInvalidToken)
}

func TestTokenSinExpiracionNoSeEmite(t *testing.T) {
	// Un token sin exp es una llave maestra permanente. Que esto sea
	// imposible de construir es la prevención.
	_, err := auth.NewSigner(testSecret, 0)
	require.Error(t, err)
}
```

Motor: ninguno.

**Prevención**

No es técnica, y por eso es la parte interesante: **documentar el comportamiento
esperado** en un sitio donde soporte lo encuentre. Un incidente que consume horas
de tres equipos para concluir "funciona como está diseñado" es un fallo de
comunicación, no de código.

Y una mejora de experiencia que **sí** cabría del lado del servidor: distinguir en
el log un token **vencido** de uno **inválido**. Al cliente se le sigue devolviendo
el mismo `401` —no tiene por qué saber la diferencia— pero quien diagnostica sí la
necesita.

**Por qué llegó a producción**

Porque nadie se preguntó **qué le pasa a un usuario cuando el token vence**. Se
decidió la duración, se implementó la expiración, se probó que un token vencido
se rechaza — y no se probó el recorrido completo desde la silla del usuario. La
consecuencia visible de una decisión correcta puede seguir siendo un problema
operativo.

**Si tu causa fue distinta a esta**

- *"El caos está inyectando `401`"* — es la hipótesis natural viniendo del track
  base, donde ese síntoma era exactamente eso. Se descarta con `CHAOS_LEVEL=off`
  y comprobando que el patrón horario persiste. **Es el hermano del incidente 08
  del cuaderno base: mismo síntoma, causa distinta.**
- *"El secreto rota y los tokens dejan de validar"* — daría un fallo masivo y
  simultáneo, no individual y escalonado.
- *"Se cae la base y devuelve `401`"* — no: sin base, `/health` da `503` y las
  rutas dan `500`.
- Si tu fix fue **quitar el `exp`**, cambiaste un problema de experiencia por un
  agujero de seguridad permanente.

</details>

---

## Incidente be-09 ⭐ — Vendimos tres números dos veces, y solo los redondos

> **Fase:** be05 · **Categoría:** 🔥 transacciones · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 90-120 min
> ⭐ **Uno de los dos más formativos del track** · Hermano del incidente **11** del track base, con otra causa raíz

### 🎫 El ticket

> "En el sorteo del sábado tuvimos tres reclamos: tres personas con el mismo
> número que otra persona. Los números eran el 0500, el 1000 y el 2000. Nos
> llamó la atención que fueran justo los redondos, así que revisamos y esos son
> los que más piden. Tuvimos que devolver plata. En el sistema el número aparece
> vendido una sola vez, con el último comprador."

**Reportado por:** tesorería
**Ambiente:** PROD

### 🎯 Qué se te pide

Reproducirlo **a voluntad** —que acá es la mitad del trabajo y no es trivial—,
explicar por qué el sesgo hacia los números redondos es una pista y no ruido, y
aplicar el fix. Y una pregunta más: ¿por qué el sistema muestra una sola venta?

### 🔧 Preparación

```bash
git checkout incidente/be-09
cd server && migrate -path migrations/postgres -database "$DATABASE_URL" up
go run ./cmd/seed -file ../mock/db.json
CHAOS_LEVEL=off go run ./cmd/api
```

Vas a necesitar clientes concurrentes de verdad. Dos pestañas no bastan.

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

Antes que nada, descarta una orilla: reproduce **sin navegador**. Si `curl`
también lo produce, el frontend queda fuera de la investigación y te ahorras la
mitad del terreno.

Y sobre los números redondos: no son especiales para el software. Son especiales
para las **personas**. ¿Qué tiene de particular un número que mucha gente quiere
al mismo tiempo?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Lanza veinte ventas simultáneas sobre el mismo número y cuenta cuántas devuelven
`200`:

```bash
for i in $(seq 1 20); do
  curl -s -o /dev/null -w "%{http_code}\n" \
    -X POST localhost:3001/raffles/1/numbers/0500/sell \
    -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
    -d '{"participantId":null}' &
done; wait
```

Después mira `SellNumber` en `server/internal/rafflenumber/service.go` y cuenta
cuántas operaciones separadas hay entre leer el estado y escribirlo.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si dos transacciones leen `status = 'available'` **antes** de que ninguna
escriba, ¿qué decide cada una? ¿Y qué garantiza `READ COMMITTED` exactamente —
atomicidad, o exclusión mutua?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz**

Un **check-then-act** sin transacción ni bloqueo. `SellNumber` hace tres
operaciones separadas:

```go
current, _ := s.store.FindOne(ctx, raffleID, number)  // (1) lee: "available"
if current.Status == "sold" { return ErrAlreadySold } // (2) decide
return s.store.MarkSold(ctx, raffleID, number, …)     // (3) escribe
```

Entre (1) y (3) **cabe otra ejecución completa**. Dos vendedores leen
`available`, los dos deciden que se puede, los dos escriben, **los dos reciben
`200`**. No hay error en ninguna capa.

Y como vender era un `UPDATE` sobre una fila que ya existe, la segunda escritura
**pisa** a la primera: en la base queda una sola venta, con el último comprador.
De ahí que el sistema muestre una y tesorería tenga dos reclamos. **La evidencia
del bug se destruyó a sí misma.**

📝 **El sesgo hacia los redondos es la pista principal, no ruido.** La ventana de
la carrera dura microsegundos: para que dos peticiones caigan dentro, tienen que
ser casi simultáneas. Eso solo ocurre con los números que **muchas personas
quieren a la vez**, y los redondos son exactamente esos. El patrón no está en el
código: está en el comportamiento humano que activa el código.

Es el mismo síntoma del **incidente 11 del track base**. Allá se estudia desde el
store, con doble clic y peticiones que se cruzan, y se mitiga con corrección
optimista y rollback. Acá se ve la verdad incómoda: **ninguna race condition de
venta se resuelve en el cliente.** Se puede hacer improbable. Resolver, no.

**Parche mínimo**

No hay parche mínimo honesto, y decirlo es parte de la respuesta. Envolver los
tres pasos en una transacción **no arregla nada**: `READ COMMITTED` da atomicidad,
no exclusión mutua, y las dos transacciones siguen leyendo `available`. Es el
error más peligroso de este incidente porque **parece** arreglado y baja la
frecuencia lo suficiente como para que las pruebas manuales pasen.

Lo mínimo que de verdad protege es una transacción **con bloqueo**:

```go
err := s.store.WithTx(ctx, func(tx Tx) error {
	// FOR UPDATE toma un bloqueo exclusivo sobre la fila. La segunda
	// transacción que pida la misma fila SE QUEDA ESPERANDO —no lee un dato
	// viejo, no falla: espera— hasta que esta confirme. Al despertar, lee
	// el estado ya actualizado y decide bien.
	current, err := tx.FindOneForUpdate(ctx, raffleID, number)
	if err != nil {
		return err
	}
	if current.Status == "sold" {
		return ErrAlreadySold
	}
	return tx.MarkSold(ctx, raffleID, number, participantID)
})
```

**La corrección correcta**

La de `be05`, que además de bloquear cambia el **modelo**:

> 🧭 **La venta se modela como un hecho, no como un estado** (`D28`). Cada venta
> es una fila nueva en `sales` con `UNIQUE (raffle_id, number)`.

Y eso importa por dos razones, las dos visibles en este incidente:

1. **Un `UNIQUE` no puede proteger un `UPDATE`** sobre una fila que ya existe: no
   hay segunda fila que rechazar. Con el modelo de estado, la defensa más fuerte
   —una restricción de la base— sencillamente no estaba disponible.
2. **Los hechos no se pisan.** Con `sales`, la segunda venta habría fallado *y*
   habría quedado el rastro de que alguien lo intentó. Con el modelo de estado, la
   evidencia se perdió.

```sql
CONSTRAINT sales_unique_number_per_raffle UNIQUE (raffle_id, number)
```

```go
// El 409 deja de ser un if: lo produce la BASE. Nuestro código puede
// equivocarse en las condiciones de carrera; la restricción, no.
var pqErr *pq.Error
if errors.As(err, &pqErr) && pqErr.Code == "23505" {
	return ErrAlreadySold
}
```

Cinturón y tirantes, y hacen falta los dos: el `FOR UPDATE` protege **este**
camino; el `UNIQUE` protege los que escribirá otra persona dentro de dos años sin
leer nada de esto.

**Prueba de regresión**

```go
func TestVentaConcurrenteSoloUnGanador(t *testing.T) {
	db := testsupport.OpenPostgres(t)
	testsupport.MustPostgres(t, db, "verifica el bloqueo de fila bajo concurrencia real")

	const contenders = 20
	// La BARRERA es lo que hace válida la prueba: sin ella las goroutines
	// se lanzan escalonadas, la carrera no ocurre, y el test pasa contra el
	// código vulnerable.
	var start sync.WaitGroup
	start.Add(1)
	var wg sync.WaitGroup
	errs := make([]error, contenders)

	for i := 0; i < contenders; i++ {
		wg.Add(1)
		go func(i int) {
			defer wg.Done()
			start.Wait()
			_, errs[i] = svc.SellNumber(ctxConUsuario(1), 1, "0500", nil)
		}(i)
	}
	start.Done()
	wg.Wait()

	ganadores := 0
	for _, err := range errs {
		if err == nil {
			ganadores++
		} else if !errors.Is(err, ErrAlreadySold) {
			t.Fatalf("error inesperado: %v", err)
		}
	}
	require.Equal(t, 1, ganadores)

	// La verificación que de verdad importa: la BASE. Un servicio que
	// devolviera un solo 200 y hubiera insertado dos filas pasaría todas
	// las aserciones de arriba.
	var ventas int
	require.NoError(t, db.Get(&ventas,
		`SELECT count(*) FROM sales WHERE raffle_id=1 AND number='0500'`))
	require.Equal(t, 1, ventas)
}
```

Motor: **PostgreSQL obligatorio**. Toca concurrencia y bloqueos: dos de las cuatro
áreas de la regla del motor. En SQLite `FOR UPDATE` es un error de sintaxis, y sin
él aparece `SQLITE_BUSY` porque la base se serializa entera. **La concurrencia no
se puede probar contra SQLite ni siquiera mal.**

⚠️ Y la propiedad que hace válida esta prueba: **falla contra el código de
`be03`**. Si pasa contra el código vulnerable, la prueba está mal — arréglala
antes de confiar en ella.

**Prevención**

Tres niveles, y hacen falta los tres:

1. **La restricción de la base.** Protege todos los caminos, incluidos los que no
   existen todavía y los `INSERT` desde `psql` a las tres de la mañana.
2. **La prueba de concurrencia con barrera**, corriendo en CI contra Postgres.
3. **El criterio de revisión de código:** cualquier secuencia leer → decidir →
   escribir sobre un recurso compartido es sospechosa hasta que se demuestre que
   está dentro de una transacción con bloqueo.

**Por qué llegó a producción**

Porque **no se reproduce cuando lo buscas**. La ventana dura microsegundos: con
dos pestañas y dos clics no pasa nunca. Pasa el día del sorteo grande, con cien
vendedores, sobre los tres números que todo el mundo quiere.

Ninguna prueba funcional lo detecta, porque las pruebas funcionales hacen una
llamada por vez. Y una prueba de concurrencia **sin barrera de salida** tampoco:
pasa contra el código roto, que es la forma más traicionera de tener cobertura.

A eso se sumó que la evidencia se destruyó sola —la base muestra una venta— así
que durante días el equipo estuvo investigando si tesorería se había equivocado.
El código funcionaba correctamente el 99,99 % de las veces, que es exactamente
la frecuencia que hace que nadie sospeche del código.

**Si tu causa fue distinta a esta**

- *"Es el doble clic del vendedor"* — es la mitigación que estudia la Fase 5 del
  track base, y es una hipótesis excelente. Se descarta reproduciéndolo con `curl`,
  sin navegador: el bug está del lado del servidor y ninguna guarda de cliente lo
  cierra.
- *"Falta un índice único"* — vas bien, y no alcanza solo: con el modelo de estado
  de `be03`, la venta es un `UPDATE` y no hay unicidad que violar. Hay que cambiar
  el modelo. Si llegaste hasta acá, llegaste a `D28`.
- *"Es el caos inyectando reintentos"* — se descarta con `CHAOS_LEVEL=off`.
- Si tu fix fue **envolver en una transacción sin bloqueo**, léelo otra vez: bajó
  la frecuencia y no cerró la ventana. Es el peor resultado posible, porque parece
  arreglado.

</details>

---

## Incidente be-10 — Un número quedó reservado para siempre

> **Fase:** be05 · **Categoría:** 🔥 transacciones · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 30-45 min

### 🎫 El ticket

> "El 1500 de la rifa 3 aparece apartado desde el martes y nadie lo compró. Un
> cliente lo quiere y no lo podemos vender: el sistema dice que está reservado.
> ¿Se puede liberar a mano? Nos ha pasado con cuatro o cinco números este mes."

**Reportado por:** vendedor
**Ambiente:** PROD

### 🎯 Qué se te pide

Explicar cómo un número llega a ese estado y decidir dónde debe vivir la
expiración. Y un detalle que parece menor y no lo es: **¿el estado bloqueado es
correcto o es basura?**

### 🔧 Preparación

```bash
git checkout incidente/be-10
cd server && go run ./cmd/api
npm start
# Reserva un número desde el tablero y cierra la pestaña antes de comprar.
```

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

Reserva un número y **cierra la pestaña**. Espera. ¿Se libera?

Ahora pregúntate quién lo iba a liberar: ¿qué proceso, corriendo dónde?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```sql
SELECT number, status, reserved_until FROM raffle_numbers
WHERE raffle_id = 3 AND status = 'reserved';
```

Mira la columna `reserved_until`. ¿Tiene valor? ¿Y quién lo lee?

Después busca en el frontend dónde se cancela una reserva (Fase 5, `setTimeout`;
Fase 6, un epic).

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si quien vence la reserva es un temporizador del navegador, ¿qué pasa cuando el
navegador se cierra?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz**

**La reserva la expiraba el cliente.** La Fase 5 del track base lo hace con un
`setTimeout` y la Fase 6 con un epic; el backend solo marcaba `status =
'reserved'` y se olvidaba.

Si el usuario cierra la pestaña, se le acaba la batería o pierde la conexión, ese
temporizador muere con él y **nadie libera el número jamás**. La columna
`reserved_until` existía en el esquema desde `be02` y no la leía nadie.

Es una deuda 💸 declarada desde el mock de la Fase 3, con esta nota textual:
*"un backend serio expiraría del lado del servidor, porque el cliente puede
cerrar el navegador y dejar el número bloqueado para siempre"*. Está así **para
que el problema se vea**, y este ticket es el problema viéndose.

Y la respuesta a la pregunta incómoda: **el estado no es basura, es correcto**. La
reserva se hizo bien; lo que falta es quién la caduca. Por eso liberar a mano es
un parche legítimo y no una corrupción de datos.

**Parche mínimo**

Liberar a mano lo que está atascado, que es lo que pide el vendedor:

```sql
UPDATE raffle_numbers
SET status = 'available', reserved_until = NULL
WHERE status = 'reserved' AND reserved_until < now();
```

⚠️ Antes de correrlo: si `reserved_until` está en `NULL` —porque nadie lo
escribía— esa consulta **no libera nada**. Ese es el hallazgo dentro del hallazgo.
En ese caso hay que acotar por otro criterio y decirlo en el runbook:

```sql
-- Con reserved_until sin poblar, se usa la antigüedad como aproximación.
-- Es un parche, y hay que anotarlo como tal.
UPDATE raffle_numbers SET status = 'available'
WHERE status = 'reserved' AND raffle_id = 3 AND number = '1500';
```

**La corrección correcta**

La de `be05`, en dos piezas que se complementan:

```go
// 1. La reserva escribe su vencimiento.
until := time.Now().Add(s.reservationTTL)
reserved, err = tx.MarkReserved(ctx, raffleID, number, until)
```

```go
// 2. Un worker las vence. Y sabe morir: el select sobre ctx.Done() lo
//    conecta con el apagado ordenado de be01 — un worker que no termina
//    convierte un Shutdown limpio en un proceso zombi.
for {
	select {
	case <-ctx.Done():
		return
	case <-ticker.C:
		n, err := store.ExpireReservations(ctx)   // un solo UPDATE, idempotente
		if err != nil {
			log.Printf("[expiry] error venciendo reservas: %v", err)
			continue
		}
		if n > 0 {
			log.Printf("[expiry] %d reservas vencidas y liberadas", n)
		}
	}
}
```

Y la tercera pieza, que es la que casi siempre se olvida: **una reserva vencida
cuenta como disponible aunque el barrido todavía no haya pasado.**

```go
expired := current.ReservedUntil != nil && current.ReservedUntil.Before(time.Now())
if current.Status != "available" && !(current.Status == "reserved" && expired) {
	return ErrNotAvailable
}
```

> 🧭 **La verdad es el reloj, no el último barrido.** Si dependieras del worker,
> la ventana entre ejecuciones sería un agujero funcional: un número vencido hace
> diez segundos seguiría sin poder venderse.

**Prueba de regresión**

```go
func TestReservaVencidaSePuedeVender(t *testing.T) {
	// Reserva que nació vencida: el reloj inyectado de be06 hace esto
	// trivial de montar, y sin él habría que esperar de verdad.
	reservarConVencimiento(t, 1, "1500", time.Now().Add(-time.Minute))

	// Sin esperar al worker: el servicio ya debe considerarlo disponible.
	_, err := svc.SellNumber(ctxConUsuario(1), 1, "1500", nil)
	require.NoError(t, err)
}

func TestElWorkerLiberaLasVencidas(t *testing.T) {
	reservarConVencimiento(t, 1, "0347", time.Now().Add(-time.Minute))

	n, err := store.ExpireReservations(context.Background())
	require.NoError(t, err)
	require.Equal(t, int64(1), n)
	require.Equal(t, "available", statusOf(t, 1, "0347"))
}
```

Motor: PostgreSQL.

**Prevención**

El worker, la comprobación de vencimiento en el servicio, y —lo que convierte
esto en operable— **una consulta de vigilancia**: cuántos números llevan
reservados más de `reservationTTL`. Si ese número no es cero, el worker no está
corriendo. Es la clase de métrica que cuesta una consulta y evita el ticket
entero.

💸 Y una deuda que este fix introduce y hay que declarar: **el worker corre en
todas las réplicas**. No rompe nada —el `UPDATE` es idempotente— pero es trabajo
repetido. `bea-09` §3 lo recoge, y la solución es un `pg_advisory_lock`.

**Por qué llegó a producción**

Porque la expiración en el cliente **funciona en el camino feliz**, que es el que
se prueba. Reservar y comprar funciona; reservar y esperar funciona; reservar y
**desaparecer** es el camino que nadie ejecuta a propósito y que los usuarios
ejecutan todo el día.

Y el daño es acumulativo y silencioso: cuatro o cinco números al mes no disparan
ninguna alarma, pero no se recuperan solos y el inventario se degrada mes a mes.

**Si tu causa fue distinta a esta**

- *"El usuario lo reservó y no lo compró"* — es exactamente lo que pasó, y no es
  la causa: la causa es que el sistema no previó ese caso. Distinguir "qué hizo el
  usuario" de "qué falló en el sistema" es el trabajo.
- *"Se cayó el epic de la Fase 6"* — plausible si el flujo pasó por ahí, y se
  descarta reproduciéndolo con la pestaña cerrada: sin navegador no hay epic que
  caerse.
- Si tu fix fue **un script manual que corre cada noche**, resuelve el síntoma y
  es defendible como parche. Pero deja una ventana de hasta 24 horas y vive fuera
  del sistema, donde nadie lo mantiene ni lo monitorea.

</details>

---

## Incidente be-11 — A los vendedores de la costa se les cierra la rifa una hora antes

> **Fase:** be06 · **Categoría:** 🔥 tiempo · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45-60 min

### 🎫 El ticket

> "Los muchachos de la costa dicen que a ellos la rifa se les cierra una hora
> antes que a los del interior: cuando todavía se puede vender, a ellos ya no
> les sale el botón. Debe ser el tema de las zonas horarias, ¿no? Nos están
> reclamando porque pierden ventas."

**Reportado por:** supervisor
**Ambiente:** PROD

### 🎯 Qué se te pide

Evaluar la teoría del reporte —y el reporte trae una, como casi siempre—,
encontrar la causa real, y decidir **qué se puede arreglar y qué no**. Este
incidente termina en una conversación, no en un commit.

### 🔧 Preparación

```bash
git checkout incidente/be-11
cd server && go run ./cmd/api
npm start
# Para simular la máquina afectada, adelanta el reloj del sistema una hora
# (desactivando la sincronización automática).
```

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

Empieza por la teoría del reporte, porque descartarla es rápido: **Colombia
entera está en UTC−5, todo el año, sin horario de verano.** No hay dos zonas.

Descartada esa, queda la pregunta interesante: la hora de cierre, ¿la evalúa el
mismo reloj para todo el mundo?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

En la máquina afectada, en la consola del navegador:

```javascript
new Date().toISOString()
```

Y compáralo con la hora del servidor:

```bash
curl -s -D - -o /dev/null localhost:3001/health | grep -i 'x-server-time'
```

Después mira qué reloj usa `isPastClosing` (Fase 7, `src/features/raffles/closing.js`).

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si el frontend esconde el botón y el backend seguiría aceptando la venta, ¿quién
está equivocado? ¿Y qué pierde el usuario exactamente?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz**

**El reloj de esas máquinas está adelantado una hora.** No es la zona horaria: es
la hora.

La teoría del reporte era razonable y es falsa: Colombia es una sola zona
(UTC−5) y no tiene horario de verano. Y aunque hubiera varias, **no importaría**:
`isPastClosing` compara instantes (`new Date(closesAt).getTime()` contra
`new Date().getTime()`), y una comparación de instantes es independiente de la
zona en que esté configurado el equipo.

Lo que sí importa es el **reloj**. `new Date()` devuelve la hora del sistema
operativo del usuario. Si esa hora está adelantada —sincronización desactivada,
una máquina que se configuró a mano, un equipo que estuvo apagado y arrancó con la
hora de la BIOS— la interfaz calcula que la rifa ya cerró y esconde el botón,
mientras el servidor sabe perfectamente que todavía no.

📝 **Y la geografía era una correlación, no una causa.** Un lote de equipos que se
compró junto y se configuró junto comparte el mismo problema de sincronización.
El reporte agrupó por región porque es lo visible; agrupar por lote de compra
habría dado la misma lista.

**Parche mínimo**

No hay parche en el código. Lo que hay es un diagnóstico y dos acciones:

1. **Sincronizar el reloj** de esas máquinas (activar NTP). Resuelve el caso hoy.
2. **Confirmar que no se perdió ninguna venta indebidamente aceptada**: no. El
   servidor nunca se equivocó — este es el escenario "reloj adelantado" de
   `be06` §7, el que solo cuesta ventas perdidas, no datos corruptos.

> 🧭 **La asimetría que hay que entender y explicar.** Con el reloj **adelantado**,
> la UI cierra antes y el usuario **pierde una venta legítima**: molesto. Con el
> reloj **atrasado**, la UI ofrece el botón y el backend rechaza con `409`:
> mensaje confuso, **datos correctos**.
>
> Antes de `be06`, el segundo caso vendía un número de una rifa cerrada. **Una
> interfaz confusa es un problema; una base de datos mentirosa es un incidente.**

**La corrección correcta**

Que el frontend deje de mirar su propio reloj: el `serverNow` que la Fase 7 dejó
anotado como deuda 💸 y que su ejercicio 27 preguntaba qué fase debería pagar.

La **mitad barata ya está hecha** — `be06` publica la hora del servidor en cada
respuesta:

```go
w.Header().Set("X-Server-Time", s.clock.Now().Format(time.RFC3339Nano))
```

Hoy no lo consume nadie. Está puesto igual, y no es un adorno: es el punto donde
la deuda se vuelve barata de pagar. La otra mitad —un interceptor que guarde el
desfase y una función `serverNow()` que lo aplique— son unas treinta líneas en
`apiClient.js` y `closing.js`, y **choca con la regla del track y con `D27`**.

⚠️ Y un detalle técnico que conviene conocer: medir el desfase como *hora del
servidor − hora local* incluye la latencia de la red. La corrección seria
—descontar la mitad del tiempo de ida y vuelta— es media implementación de NTP, y
explica por qué sincronizar relojes es más difícil de lo que parece.

**Prueba de regresión**

No hay bug del backend que probar. Lo que sí se prueba es que **el servidor no
depende del reloj del cliente**, que es lo que hace que el daño sea acotado:

```go
func TestElServidorIgnoraLaHoraDelCliente(t *testing.T) {
	// Una hora antes del cierre, según el reloj del servidor.
	svc := newServiceWithClock(t, fixedClock{closesAt.Add(-time.Hour)})

	// El cliente puede mandar lo que quiera: no hay ningún campo de hora
	// en el cuerpo de una venta, y aunque lo hubiera, no se leería.
	_, err := svc.SellNumber(ctxConUsuario(1), 1, "0347", nil)
	require.NoError(t, err)
}
```

Motor: PostgreSQL. Toca zonas horarias.

**Prevención**

Tres cosas, en orden de coste:

1. **La línea de log del desfase** que `be06` ya registra al liquidar. Convierte
   este ticket en un diagnóstico de dos minutos: *"el cliente dice las 22:03 y el
   servidor las 21:03"*.
2. **La métrica agregada** del ejercicio 23 de `be06`: cuántos usuarios tienen el
   reloj desfasado y cuánto. Es el argumento que decidiría si vale la pena pagar
   la deuda del `serverNow`. 💸 Hoy solo hay líneas sueltas de log.
3. **Sincronización de reloj en el aprovisionamiento** de los equipos. Es la
   prevención real y no es técnica: es de operación.

**Por qué llegó a producción**

Porque **el sistema está funcionando correctamente** y aun así alguien pierde
dinero. No hay ningún componente roto: el backend decide bien, el frontend
calcula bien con el dato que tiene, y el dato que tiene está mal por causas
ajenas al software.

Es el tipo de incidente donde la respuesta *"no es un bug"* es técnicamente cierta
y operativamente inútil. Lo que faltaba era **no depender de un dato que no
controlamos**, y esa dependencia estaba declarada como deuda desde la Fase 7
—con su nota de época y todo— sin que nadie le hubiera puesto una fecha.

**Si tu causa fue distinta a esta**

- *"Es la zona horaria"* — la teoría del reporte, y es **la hipótesis correcta de
  formular**: es lo primero que hay que descartar. Se cae con dos datos: Colombia
  es una sola zona, y la comparación es de instantes.
- *"El backend cierra antes de tiempo"* — se descarta con `curl` desde una máquina
  con el reloj bien: el servidor sigue aceptando ventas.
- *"El worker de cierre marcó la rifa como `closed` antes"* — buena hipótesis, y
  se descarta mirando `status` y `closes_at` en la base.
- Si tu fix fue **restar una hora en el cliente**, arreglaste esas máquinas y
  rompiste todas las demás.

</details>

---

## Incidente be-12 — Vendimos doscientos números después del cierre

> **Fase:** be06 · **Categoría:** 🔥 tiempo · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 60-90 min
> · Hermano del incidente **16** del track base, con otra causa raíz

### 🎫 El ticket

> "Al liquidar la rifa del 30 nos dio que se recaudaron 1.100.000 pesos pero el
> corte que hicimos a la hora del cierre decía 900.000. Revisando, hay como
> doscientos números con hora de venta posterior a las diez de la noche, que es
> cuando cerraba. Uno de esos es el ganador. No sabemos si pagar el premio."

**Reportado por:** tesorería
**Ambiente:** PROD

### 🎯 Qué se te pide

Determinar cómo entraron esas ventas, si el premio se debe pagar, y qué hace
falta para que no vuelva a pasar. Es el incidente con más consecuencias del
track: hay dinero y hay una decisión de negocio que depende de tu diagnóstico.

### 🔧 Preparación

```bash
git checkout incidente/be-12
cd server && go run ./cmd/api
npm start
# Pon una rifa a cerrar en dos minutos y sigue vendiendo pasada la hora.
```

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

Prueba lo más directo: pasada la hora de cierre, manda una venta con `curl`,
**sin navegador**. Si entra, la interfaz no tiene nada que ver.

Y si entra: ¿quién estaba comprobando la hora, y dónde vive ese código?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```bash
grep -rn "closesAt\|ClosesAt" server/internal/
grep -rn "isPastClosing" src/
```

Cuenta cuántas comprobaciones de la hora de cierre hay en cada orilla.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si la única guarda vive en el cliente, ¿qué la evita? Un reloj mal, una pestaña
abierta desde antes del cierre, o `curl`. ¿Cuál de las tres es la más probable
con doscientos números?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz**

**El backend nunca comprobó la hora de cierre.** La única guarda vivía en el
cliente: `isPastClosing(raffle.closesAt)` en el tablero y en el epic de la Fase 7.

Cualquiera de estas tres cosas la esquiva:

1. **Una pestaña abierta desde antes del cierre**, con el estado de la rifa
   cacheado en el store. Es la más probable con doscientos números: los
   vendedores no recargan la página.
2. **Un reloj de cliente atrasado** — el escenario espejo de `be-11`.
3. **Cualquier cliente que no sea el navegador.** `curl` no ejecuta
   `isPastClosing`.

Y el resultado no es un error: son doscientas ventas **aceptadas y confirmadas**,
con su `200`, indistinguibles de las legítimas salvo por el `sold_at`.

Es el mismo síntoma del **incidente 16 del track base**, donde la causa es que el
frontend compara mal la fecha. Acá la causa es más profunda: **no hay nada que
comparar del lado que decide**.

**Sobre el premio.** El diagnóstico no lo decide, pero sí lo informa, y esa
distinción importa: la venta ganadora fue **aceptada por el sistema**. Quien la
compró hizo todo bien y recibió una confirmación. Que el sistema no debiera
haberla aceptado es un problema de la empresa, no del comprador. Tu entregable es
la evidencia —`sold_at` contra `closes_at`, con precisión de segundos, y en qué
orden llegaron— para que negocio decida con datos.

**Parche mínimo**

Comprobar la hora en el servidor, y comprobarla **dentro de la transacción de
venta**:

```go
err := s.store.WithTx(ctx, func(tx Tx) error {
	// FOR SHARE y no FOR UPDATE: solo necesitamos que nadie CAMBIE la
	// closesAt mientras vendemos, no bloquear a los demás vendedores entre
	// sí. Un FOR UPDATE acá serializaría todas las ventas de la rifa
	// contra una sola fila y tiraría a la basura lo que consiguió be05.
	raffle, err := tx.FindRaffleForShare(ctx, raffleID)
	if err != nil {
		return err
	}

	now := s.clock.Now()
	// Comparación de INSTANTES. El borde (now == closesAt → no se vende)
	// se hereda de isPastClosing: dos capas que contesten distinto en el
	// borde producen el ticket más difícil de diagnosticar que existe.
	if !now.Before(raffle.ClosesAt) {
		return fmt.Errorf("cerró a las %s y ahora son las %s: %w",
			raffle.ClosesAt.Format(time.RFC3339), now.Format(time.RFC3339),
			ErrRaffleClosed)
	}
	// … el resto de be05
})
```

⚠️ **La posición no es estilo.** Comprobar antes de abrir la transacción reabre
el mismo *check-then-act* que `be05` acaba de cerrar: entre "vi que estaba
abierta" y "vendí" cabe el cierre. La ventana es pequeña y justo por eso el bug
sería intermitente.

Y el handler traduce a `409`, no a `400`: la petición está bien formada, el estado
del recurso no la permite. El frontend heredado ya sabe mostrar un `409` como
conflicto, así que **maneja este caso nuevo sin saber que existe**.

**La corrección correcta**

La de `be06` completa, que son tres piezas:

1. La comprobación dentro de la transacción (arriba).
2. Un **worker que cierra por reloj**, para que el estado refleje la realidad
   aunque nadie pida nada. Sin él, una rifa cerrada a las 22:00 sigue diciendo
   `open` hasta que alguien intente venderle algo — y el `pollingEpic` de la Fase
   7 no arrancaría a buscar el resultado.
3. La **política de zonas** explícita: proceso en UTC, sesión de base en
   `America/Bogota` solo para serializar.

> ⚠️ Y una advertencia sobre la pieza 2: el worker mantiene el estado al día,
> **no es la regla**. Usar `status = 'open'` como comprobación de la hora dura
> deja colarse las ventas de los segundos entre un tick y el siguiente. La que
> manda es el reloj.

**Prueba de regresión**

```go
func TestSellNumberRespetaLaHoraDura(t *testing.T) {
	closesAt := mustParse(t, "2026-08-30T22:00:00-05:00")

	casos := []struct {
		nombre string
		ahora  time.Time
		quiere error
	}{
		{"un segundo antes", closesAt.Add(-time.Second), nil},
		{"un milisegundo antes", closesAt.Add(-time.Millisecond), nil},
		{"el instante exacto", closesAt, ErrRaffleClosed},
		{"un milisegundo después", closesAt.Add(time.Millisecond), ErrRaffleClosed},
		// El que de verdad importa: el mismo instante escrito en otra zona.
		// Si este pasa, ninguna comparación mira componentes de fecha.
		{"el mismo instante en UTC",
			mustParse(t, "2026-08-31T03:00:00Z"), ErrRaffleClosed},
	}

	for _, c := range casos {
		t.Run(c.nombre, func(t *testing.T) {
			svc := newServiceWithClock(t, fixedClock{c.ahora})
			_, err := svc.SellNumber(ctxConUsuario(1), 1, "0347", nil)
			require.ErrorIs(t, err, c.quiere)
		})
	}
}
```

Motor: **PostgreSQL obligatorio**. Zonas horarias.

📖 Y fíjate en lo que hace posible esta prueba: el **reloj inyectado**. Con
`time.Now()` dentro del servicio, los casos del borde —un milisegundo antes, un
milisegundo después— no se pueden escribir. Que `be06` haya hecho el reloj una
dependencia no es purismo: es lo que convierte "difícil de probar" en cinco
líneas.

**Prevención**

La prueba de bordes, el worker, y una consulta de auditoría que debería correr
después de cada cierre:

```sql
-- Ventas posteriores al cierre. Tiene que devolver cero filas.
SELECT s.raffle_id, s.number, s.sold_at, r.closes_at
FROM sales s JOIN raffles r ON r.id = s.raffle_id
WHERE s.sold_at > r.closes_at;
```

Si esta consulta hubiera existido, el problema se habría detectado la primera
noche y no en la liquidación.

**Por qué llegó a producción**

Porque la guarda **existía y funcionaba** — en el lugar equivocado. Quien escribió
`isPastClosing` hizo un buen trabajo: función pura, comparación de instantes,
probada, con el borde decidido. Todo correcto. Y toda esa calidad estaba del lado
que el usuario controla.

El sistema pasó meses sin fallar porque el camino feliz —vendedor con reloj bien,
página recargada— respeta la guarda. El fallo necesita una condición que nadie
prueba: seguir usando una pestaña que se abrió antes del cierre.

Y el descubrimiento tardó porque **no hay síntoma en el momento**. La venta se
acepta, el vendedor cobra, el comprador se va contento. El descuadre aparece en la
liquidación, semanas después, cuando ya hay dinero repartido y un premio en
disputa.

**Si tu causa fue distinta a esta**

- *"Los relojes de los vendedores están mal"* — es una de las tres vías y es
  **insuficiente como causa**: aunque todos los relojes estuvieran perfectos,
  `curl` seguiría entrando. La causa es la ausencia de guarda en el servidor.
- *"El worker de cierre no corrió"* — no existía. Y aunque existiera, el estado no
  es la regla: el reloj lo es.
- *"La `closesAt` está mal guardada"* — se descarta comparando con lo que muestra
  la UI: es la misma.
- Si tu fix fue **comprobar la hora en el handler** en vez de en la transacción,
  cerraste el 99 % del agujero y dejaste una ventana intermitente. Es defendible
  como hotfix de un viernes; anótalo como tal.

</details>

---

## Incidente be-13 — La liquidación dice 340.000 y las ventas suman 355.000

> **Fase:** be07 · **Categoría:** 🔥 dinero · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45-60 min
> · Hermano del incidente **18** del track base, con otra causa raíz

### 🎫 El ticket

> "La liquidación de la rifa de agosto quedó en 340.000 de recaudo. Cuando
> contamos los números vendidos y multiplicamos por el precio nos da 355.000.
> Son 15.000 de diferencia, o sea tres números. No es un centavo de redondeo,
> son tres números enteros que no aparecen en la cuenta."

**Reportado por:** tesorería
**Ambiente:** PROD

### 🎯 Qué se te pide

Encontrar los tres números y explicar por qué no entraron. Y una pregunta que
decide todo lo demás: **¿el número guardado está mal, o está bien y lo que está
mal es otra cosa?**

### 🔧 Preparación

```bash
git checkout incidente/be-13
cd server && go run ./cmd/api
npm start
# Abre la aplicación en DOS pestañas sobre la misma rifa.
```

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

"No es un centavo de redondeo, son tres números enteros" es un dato excelente:
descarta toda la familia de bugs de aritmética. `A10` y `be07` usan enteros de
centavos y las partes suman el todo.

Entonces la pregunta no es *cómo se calculó*, sino **con qué datos**. ¿Quién hizo
la cuenta?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Mira el **cuerpo** del `POST /settlements` en Network. ¿De dónde salieron
`totalCollected` y `soldCount`?

Y en el backend:

```sql
SELECT count(*) FROM sales WHERE raffle_id = 1;
SELECT sold_count, total_collected FROM settlements WHERE raffle_id = 1;
```

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si el navegador calcula con los números que tiene cargados en el store, y otra
persona vendió tres números hace diez minutos sin que esa pestaña se enterara,
¿qué total manda?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz**

**El cliente calculó el recaudo y el servidor lo guardó sin preguntar.**

El thunk `createSettlement` de la Fase 8 hace las cuentas con los números que
tiene en el store, y las manda en el cuerpo:

```javascript
const totalCollected = calculateTotalCollected({
  soldCount: soldNumbers.length,        // ← los que ESTA pestaña conoce
  numberPrice: raffle.numberPrice,
});
```

Si otra persona vendió tres números después de que esa pestaña cargara el
tablero, el store está desactualizado y el total sale corto. El backend recibe
`340000`, lo guarda tal cual, y devuelve `201`.

**No es mala fe ni un bug del frontend: el cliente no tiene los datos.** Puede
tener una foto de hace diez minutos; el servidor tiene la verdad.

Reprodúcelo en dos minutos: dos pestañas sobre la misma rifa, vende tres números
en la primera, liquida en la segunda **sin recargar**.

Es el hermano del **incidente 18 del track base** —*"la liquidación da un centavo
de diferencia"*—, donde la causa es el redondeo. Acá la aritmética es impecable y
lo que falla es la **fuente de los datos**. Mismo síntoma, distinta capa, y por
eso el detalle del ticket —"no es un centavo, son tres números"— es la pista que
separa los dos casos.

**Parche mínimo**

Recalcular en el servidor:

```go
sold, err := tx.ListSales(ctx, in.RaffleID)
if err != nil {
	return err
}
totalCollected := TotalCollected(int64(len(sold)), raffle.NumberPrice)
```

**La corrección correcta**

La de `be07`: recalcular **todo** —`totalCollected`, `prizeAmount`, `margin`— desde
`sales`, y **registrar la discrepancia** en vez de rechazar la petición:

```go
if in.TotalCollected != totalCollected || in.PrizeAmount != prizeAmount || in.Margin != margin {
	log.Printf("[req-id %s] discrepancia en la rifa %d — cliente: total=%d premio=%d margen=%d | servidor: total=%d premio=%d margen=%d",
		httpapi.RequestIDFrom(ctx), in.RaffleID,
		in.TotalCollected, in.PrizeAmount, in.Margin,
		totalCollected, prizeAmount, margin)
}
```

> 🧭 **Por qué se registra y no se rechaza.** Un `400` "sus números no cuadran"
> rompería el contrato y además culparía al cliente de algo que no puede hacer
> bien. Se recalcula, se guarda lo correcto, y queda el rastro — que es
> información de diagnóstico valiosísima el día que alguien pregunte por qué el
> total que vio no es el que quedó guardado.

📖 Y es la tercera vez que el track dice lo mismo, así que ya se puede nombrar:
**el cliente propone, el servidor dispone, y la diferencia se mide.** Identidad en
`be04`, reloj en `be06`, dinero en `be07`.

**Prueba de regresión**

```go
func TestLosMontosSeRecalculanYNoSeLeenDelCuerpo(t *testing.T) {
	seedRaffleConVentas(t, 1, 71, /* numberPrice */ 500000)   // 35.500.000

	// El cliente manda cifras inventadas.
	body := `{"raffleId":1,"winningNumber":"0347","isWinnerSold":true,
	          "soldCount":68,"totalCollected":34000000,"prizeAmount":0,
	          "margin":34000000,"settledAt":"2026-08-30T22:05:11Z"}`
	srv.POST(t, "/settlements", token, body).ExpectStatus(201)

	var s settlement.Settlement
	require.NoError(t, db.Get(&s, `SELECT * FROM settlements WHERE raffle_id = 1`))

	// Lo guardado sale de la base, no del cuerpo.
	require.Equal(t, 71, s.SoldCount)
	require.Equal(t, int64(35500000), s.TotalCollected)
}
```

Motor: PostgreSQL.

**Prevención**

La regla operativa, que vale más que la prueba: **ningún monto que se guarde puede
haber cruzado la red**. Si un campo de dinero se lee de un cuerpo de petición, es
un bug aunque todavía no haya fallado.

Y la consulta de auditoría del ejercicio 22 de `be07`, que debería devolver cero
filas siempre:

```sql
SELECT s.raffle_id, s.total_collected,
       (SELECT count(*) * r.number_price FROM sales v WHERE v.raffle_id = s.raffle_id) AS recalculado
FROM settlements s JOIN raffles r ON r.id = s.raffle_id
WHERE s.total_collected <> (SELECT count(*) * r.number_price FROM sales v WHERE v.raffle_id = s.raffle_id);
```

**Por qué llegó a producción**

Porque el frontend hace la cuenta **bien**. `A10` y la Fase 8 son ejemplares:
enteros de centavos, redondeo explícito, partes que suman el todo, con sus
pruebas. Toda esa disciplina es correcta y no sirve de nada si la entrada está
desactualizada.

Es un error de **arquitectura**, no de implementación, y por eso ninguna revisión
de código lo detecta: cada archivo, leído solo, está bien. Solo se ve preguntando
*"¿quién es el dueño de este dato?"*, y esa pregunta no se hace leyendo un diff.

**Si tu causa fue distinta a esta**

- *"Es el redondeo"* — la hipótesis del incidente 18 del track base, y el propio
  ticket la descarta: 15.000 pesos no son un redondeo. Que tesorería lo
  especificara es un reporte de calidad excepcional.
- *"Se borraron ventas"* — se descarta contando `sales`: están todas.
- *"Se vendieron después del cierre"* — ese es `be-12`, y el síntoma sería el
  contrario: la liquidación diría **más**, no menos.
- Si tu fix fue **recargar el tablero antes de liquidar**, reduces la ventana y no
  la cierras: entre la recarga y el `POST` cabe otra venta. Y además exige que el
  usuario se acuerde.

</details>

---

## Incidente be-14 — Repartimos el premio dos veces

> **Fase:** be07 · **Categoría:** 🔥 transacciones · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 60-90 min

### 🎫 El ticket

> "En la rifa del 15 el premio salió dos veces en el reporte de pagos. La
> persona que liquidó dice que le dio error la primera vez y volvió a darle, que
> siempre hace eso. Y hay otra rifa donde pasó al revés: aparece el pago
> registrado pero la rifa sigue como pendiente de liquidar, y cuando intentamos
> liquidarla otra vez da un error raro que nadie entiende."

**Reportado por:** tesorería
**Ambiente:** PROD

### 🎯 Qué se te pide

Son **dos síntomas y hay que decidir si es un bug o dos**. Reproduce los dos,
explica el error "raro" del segundo caso, y arregla.

### 🔧 Preparación

```bash
git checkout incidente/be-14
cd server && CHAOS_LEVEL=high go run ./cmd/api    # el caos hace habitual el reintento
npm start
```

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

*"Le dio error y volvió a darle"* es el dato que abre el primer caso. Con el caos
encendido, un `timeout` significa que **la petición pudo haber llegado igual**.

El segundo caso es distinto: pago registrado, rifa sin liquidar. ¿Qué tienen que
ser esas dos operaciones para que ese estado sea imposible?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```sql
SELECT id, raffle_id FROM settlements WHERE raffle_id = 15;
SELECT count(*) FROM prize_payouts WHERE settlement_id IN (…);
SELECT status FROM raffles WHERE id = 15;
```

Y en el código, cuenta cuántas operaciones separadas hace `Create` y con cuántas
conexiones.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si el proceso muere entre insertar los pagos y marcar la rifa como liquidada,
¿qué queda en la base? ¿Y qué pasa cuando alguien reintenta sobre esa rifa?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz**

**Son dos bugs, y comparten origen: la liquidación no es una operación única.**

`Create` ejecuta seis pasos, cada uno con su propia conexión y sin transacción:
verificar, recalcular, insertar la liquidación, repartir el premio, comprobar el
cuadre, y marcar la rifa como `settled`.

**Caso 1 — el premio repartido dos veces.** Con el caos en `high`, la petición
llega, la liquidación se crea, y la respuesta se pierde. El usuario reintenta, y
como no hay comportamiento idempotente, se ejecuta otra vez. Sin el `UNIQUE
(raffle_id)` de `be02` habría dos liquidaciones; con él, salta el `23505` y el
usuario recibe un error incomprensible sobre una rifa que él ve sin liquidar. En
el caso reportado, los pagos ya se habían insertado en el primer intento.

**Caso 2 — pago sin liquidación.** El proceso murió entre el paso 4 y el paso 6.
Quedó la liquidación, quedaron los pagos, y la rifa siguió en `resolved`: **el
dinero repartido y la rifa sin liquidar.** El "error raro" del reintento es
exactamente el `23505` del `UNIQUE`, que hace bien su trabajo y comunica fatal.

📖 **Y ese es el valor entero de una transacción, visto desde el ticket.** No es
una abstracción académica: es la diferencia entre un martes normal y una tarde
reconstruyendo a mano quién cobró qué.

**Parche mínimo**

Una transacción alrededor de los seis pasos:

```go
err := s.store.WithTx(ctx, func(tx Tx) error {
	// … los seis pasos, todos con tx
})
```

Con eso, el caso 2 desaparece: el `recover` de `be01` atrapa el pánico, el
`defer tx.Rollback()` revierte, y la base queda **idéntica** a como estaba.
Compruébalo con las mismas consultas: cero filas en las dos.

**La corrección correcta**

La transacción **más la idempotencia**, que es lo que cierra el caso 1:

```go
// Ya bloqueada la rifa, si existe liquidación se devuelve ESA. No es un
// error: es un reintento, y con el caos de la Fase 3 encendido es el caso
// normal, no el excepcional.
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
```

📖 **Una operación idempotente responde lo mismo la primera vez y la quinta.** El
cliente no puede distinguir su reintento de un primer intento, y esa
indistinguibilidad **es** la propiedad. El reintento deja de ser un problema y
pasa a ser rutina.

Y el paso que hace que esto no pueda romperse por otro lado, dentro de la misma
transacción:

```go
// La aserción que convierte esto en dinero y no en un CRUD. Comprobar el
// cuadre DENTRO de la transacción significa que un reparto que no cuadre no
// llega a existir: el Rollback lo borra.
if got := SumShares(shares); len(winners) > 0 && got != prizeAmount {
	return fmt.Errorf("el reparto no cuadra: las partes suman %d y el premio es %d", got, prizeAmount)
}
```

**Prueba de regresión**

```go
func TestLiquidacionEsIdempotente(t *testing.T) {
	primera := srv.POST(t, "/settlements", token, cuerpoValido).ExpectStatus(201)
	segunda := srv.POST(t, "/settlements", token, cuerpoValido).ExpectStatus(201)

	// Mismo id: es la misma liquidación, no una nueva.
	require.Equal(t, idOf(primera), idOf(segunda))

	var liquidaciones, pagos int
	require.NoError(t, db.Get(&liquidaciones, `SELECT count(*) FROM settlements WHERE raffle_id=1`))
	require.NoError(t, db.Get(&pagos, `SELECT count(*) FROM prize_payouts`))
	require.Equal(t, 1, liquidaciones)
	require.Equal(t, 1, pagos)
}

func TestLiquidacionInterrumpidaNoDejaRastro(t *testing.T) {
	// Falla en el paso 6, después de repartir.
	svc := newServiceConFalloEn(t, "UpdateRaffleStatus")

	_, err := svc.Create(ctxConUsuario(1), liquidacionValida)
	require.Error(t, err)

	// Todo o nada: ni liquidación, ni pagos, ni rifa a medio marcar.
	var liquidaciones, pagos int
	db.Get(&liquidaciones, `SELECT count(*) FROM settlements WHERE raffle_id=1`)
	db.Get(&pagos, `SELECT count(*) FROM prize_payouts`)
	require.Zero(t, liquidaciones)
	require.Zero(t, pagos)
	require.Equal(t, "resolved", statusOf(t, 1))
}
```

Motor: **PostgreSQL obligatorio**. Transacciones y bloqueos.

**Prevención**

Cuatro capas, cada una cubriendo lo que las otras no:

1. **La transacción** — que no exista el estado intermedio.
2. **El `UNIQUE (raffle_id)`** — que no exista la segunda liquidación, venga por
   donde venga.
3. **El comportamiento idempotente** — que el reintento sea aburrido.
4. **La consulta de auditoría**: liquidaciones cuyos pagos no sumen su
   `prizeAmount`, y rifas con liquidación pero sin estado `settled`. Las dos
   deberían devolver cero filas siempre.

**Por qué llegó a producción**

Por dos motivos que se refuerzan.

El primero: **el reintento del usuario es un comportamiento esperado y nadie lo
diseñó**. "Me dio error y volví a darle" es lo que hace todo el mundo, con
cualquier sistema. Con un mock que falla a propósito —el caos de la Fase 3— eso
pasó de ser excepcional a rutinario, y aun así la idempotencia no se consideró.

El segundo: **el caso 2 no se puede reproducir a propósito sin quererlo**. Nadie
mata el proceso a mitad de una liquidación en desarrollo. Es un fallo que solo
aparece cuando la infraestructura hace lo que la infraestructura hace: reiniciar,
desplegar, quedarse sin memoria.

Y el error que veía el operador —el `23505`— era técnicamente correcto y
completamente inútil: le hablaba de una restricción de unicidad sobre una rifa
que él veía sin liquidar.

**Si tu causa fue distinta a esta**

- *"El usuario liquidó dos veces por error"* — es la mitad del caso 1 y no es la
  causa: la causa es que el sistema no está preparado para que eso pase, cuando es
  exactamente lo que va a pasar.
- *"Falta el `UNIQUE`"* — está desde `be02`. Y protege contra la segunda
  liquidación, no contra el estado intermedio del caso 2.
- *"Es un problema de concurrencia"* — plausible y distinto: dos liquidaciones
  simultáneas de la misma rifa. Se cubre con el `FOR UPDATE` sobre la rifa, que va
  en el mismo fix. Buena hipótesis.
- Si tu fix fue **devolver un mensaje más claro ante el `23505`**, mejoraste la
  comunicación y no arreglaste nada: la rifa sigue con dinero repartido y sin
  liquidar.

</details>

---

## Incidente be-15 ⭐ — La suite lleva tres semanas en verde y ayer se rompió producción

> **Fase:** be08 · **Categoría:** 🔥 contrato · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 60-90 min
> ⭐ **Uno de los dos más formativos del track** · Hermano del incidente **20** del track base, con otra causa raíz

### 🎫 El ticket

> "Ayer desplegamos y dejó de funcionar crear rifas: cualquier intento da error
> del servidor. Lo raro es que la suite estaba verde, el pipeline pasó, y en las
> máquinas de los tres que trabajamos en eso funciona perfecto. Volvimos a la
> versión anterior y ya está bien, pero no sabemos qué pasó y no nos atrevemos a
> volver a desplegar."

**Reportado por:** el propio equipo
**Ambiente:** PROD (y no se reproduce en desarrollo)

### 🎯 Qué se te pide

Explicar cómo una suite verde puede autorizar un despliegue roto. El fix es
menor; **lo que importa es el diagnóstico y lo que se cambia después para que no
vuelva a pasar**.

### 🔧 Preparación

```bash
git checkout incidente/be-15
cd server
make test-unit          # verde
go test ./...           # verde, contra SQLite
```

Ahora corre lo mismo contra Postgres. Ahí empieza el incidente.

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

*"En nuestras máquinas funciona"* + *"la suite está verde"* + *"en producción no"*
tienen un factor común que no es el código, porque el código es el mismo en los
tres sitios.

¿Qué es distinto entre tu máquina y producción? Haz la lista completa antes de
seguir.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```bash
go test ./... -count=1                                   # ¿contra qué motor?
TEST_DATABASE_URL="postgres://…/rifas_test" go test ./... -count=1
```

Y mira el error de producción entero, sin recortar. La primera línea nombra al
culpable.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

`res.LastInsertId()` funciona en un motor y no en el otro. ¿En cuál corren tus
pruebas y en cuál corre producción?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz**

**Las pruebas corren contra SQLite y producción contra PostgreSQL.**

Alguien reemplazó `RETURNING` por `LastInsertId` — que es la forma "obvia" de
recuperar el id recién insertado y la que sale en la mitad de los tutoriales:

```go
// ❌ Compila, y funciona en SQLite.
res, err := s.db.ExecContext(ctx, query, …)
id, err := res.LastInsertId()
```

`mattn/go-sqlite3` lo implementa. **`lib/pq` no**, y no es un bug del driver: el
protocolo de Postgres sencillamente no ofrece ese dato. Devuelve:

```
LastInsertId is not supported by this driver
```

Así que **todo** `POST /raffles` responde `500` en cualquier ambiente con
Postgres. Y la suite —que corría contra SQLite en memoria, porque es rápido y no
necesita contenedor— pasó en verde.

> 🧠 **Y acá está lo que hay que entender, que es más incómodo que el bug: la
> suite no falló en detectar el problema. La suite lo autorizó.** No tener suite
> te deja desconfiado y prudente; una suite verde te da **permiso para
> desplegar**, y ese permiso es exactamente lo que el equipo no tenía derecho a
> recibir.

Es el hermano del **incidente 20 del track base** —*"el test pasa en mi máquina y
falla en la de al lado"*—, con la causa raíz desplazada del **entorno** al
**motor**.

**Parche mínimo**

```go
// RETURNING funciona en los dos motores, y por eso D18 fija SQLite >= 3.35:
// es marzo de 2021, cuando llegó la sentencia. La cota no es un número
// redondo elegido al azar.
query := s.db.Rebind(`
	INSERT INTO raffles (name, lottery_id, closes_at, number_price, base_prize, status)
	VALUES (?, ?, ?, ?, ?, ?)
	RETURNING id, name, lottery_id, closes_at, number_price, base_prize, status`)

var created Raffle
err := s.db.GetContext(ctx, &created, query, …)
```

**La corrección correcta**

Arreglar el `LastInsertId` es media hora. Lo que hay que cambiar es **cómo se
prueba**, y eso es el contenido de `be08`:

> 🧭 **La regla del motor (`D18`).** SQLite vale para pruebas que no tocan
> concurrencia, bloqueos, zonas horarias ni SQL específico del motor. En cuanto
> una prueba toca cualquiera de las cuatro, **corre contra PostgreSQL o no vale**.

Y el mecanismo que la hace cumplir, que es la parte que de verdad importa:

```go
// FALLA, no salta. Un t.Skip produce una suite verde que no probó lo que
// dice probar, y nadie lee los SKIP de una salida que termina en "ok".
func mustPostgres(t *testing.T, db *storage.DB, motivo string) {
	t.Helper()
	if db.Dialect != storage.Postgres {
		t.Fatalf("esta prueba requiere PostgreSQL porque %s.\n"+
			"Levanta el contenedor y exporta TEST_DATABASE_URL.\n"+
			"Ver D18 y server/evidence/regla-del-motor.md", motivo)
	}
}
```

📖 **`t.Skip` es la forma en que una suite miente.** Y `(cached)` es la segunda:
`go test` sin `-count=1` puede decir `ok` sin haber ejecutado nada.

**Prueba de regresión**

No es una prueba: es **el par contradictorio** de `be08`, que va al repositorio
con su explicación.

```go
// PRUEBA A — pasa en SQLite, FALLA en Postgres.
// Documenta la trampa. NO debe correr en CI: el código correcto usa RETURNING.
func TestA_LastInsertId(t *testing.T) {
	db := testsupport.OpenAny(t)
	res, err := db.Exec(db.Rebind(`INSERT INTO participants (name) VALUES (?)`), "Ana")
	require.NoError(t, err)
	id, err := res.LastInsertId()
	require.NoError(t, err, "lib/pq no implementa LastInsertId: usa RETURNING")
	require.Greater(t, id, int64(0))
}

// PRUEBA B — FALLA en SQLite, pasa en Postgres.
// Prueba legítima del sistema. Corre SOLO contra Postgres.
func TestB_ComparacionDeInstantes(t *testing.T) {
	db := testsupport.OpenAny(t)
	insertRaffle(t, db, "Rifa fin de mes", "2026-08-30T22:00:00-05:00")

	var nombres []string
	require.NoError(t, db.Select(&nombres, db.Rebind(
		`SELECT name FROM raffles WHERE closes_at > ?`), "2026-08-31T01:00:00Z"))
	require.Len(t, nombres, 1,
		"si esto falla, el motor está comparando cadenas y no instantes")
}
```

Las dos son correctas y se contradicen. **No se arreglan: se clasifican**, y esa
clasificación vive en `server/evidence/regla-del-motor.md`.

**Prevención**

1. **`mustPostgres` en toda prueba que toque las cuatro áreas.**
2. **El pipeline corre contra Postgres**, con `services: postgres:13`. Que la
   suite pudiera pasar sin un Postgres levantado era el agujero real.
3. **Un paso de CI que verifique la regla** (`make test-engine-rule`).
4. Y el mecanismo del ejercicio 29 de `be08`: algo que **impida** agregar una
   prueba de concurrencia sin `mustPostgres` — una etiqueta de compilación, una
   convención verificada por un script, lo que sea, pero verificable.

**Por qué llegó a producción**

Porque usar SQLite en memoria para las pruebas es una práctica **extendida y
razonable**: arranca en milisegundos, no necesita contenedor, cada caso tiene su
base limpia. Quien la eligió tenía buenos motivos y para la mitad de la suite
seguía siendo la decisión correcta.

Lo que faltaba era el **límite escrito**: hasta dónde vale ese motor y qué pasa
cuando una prueba lo cruza. Sin ese límite, la frontera se cruza sola, poco a
poco, sin que nadie tome una decisión — y el día que se cruza en algo importante,
no hay ninguna señal.

Y la asimetría que lo hace grave: un falso **negativo** —una prueba que falla y
pasaría en producción— es molesto pero se investiga. Un falso **positivo** —verde
en SQLite, roto en Postgres— **no produce ninguna señal**. Nadie investiga una
prueba que pasa.

**Si tu causa fue distinta a esta**

- *"Es un problema de configuración de producción"* — la hipótesis natural con
  *"en mi máquina funciona"*, y la del incidente 20 del track base. Se descarta
  levantando Postgres en local: se reproduce al instante.
- *"Falló la migración"* — se descarta comprobando la versión del esquema, que
  `be09` además verifica al arrancar.
- *"Es la versión de Go del runner"* — se descarta: el pipeline corre
  `container: golang:1.19`, el mismo de siempre.
- Si tu fix fue **solo** cambiar `LastInsertId` por `RETURNING`, arreglaste este
  caso y dejaste intacta la condición que lo produjo. La próxima diferencia entre
  motores va a pasar por el mismo agujero, y hay siete documentadas en `bea-03`.

</details>

---

## Incidente be-16 — La imagen de ayer no arranca y el código no cambió

> **Fase:** be09 · **Categoría:** 🔥 despliegue · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45-60 min

### 🎫 El ticket

> "La imagen que construimos ayer no arranca en el servidor: se levanta el
> contenedor y se muere solo. La de anteayer funciona bien. Comparamos el código
> y no hay ni un commit de diferencia en la aplicación. En la máquina de quien
> la construyó arranca perfecto."

**Reportado por:** el propio equipo
**Ambiente:** UAT

### 🎯 Qué se te pide

Encontrar qué cambió si el código no cambió, y arreglar la construcción para que
sea **reproducible**. Hay más de una causa posible: identifica la tuya con
evidencia, no por descarte.

### 🔧 Preparación

```bash
git checkout incidente/be-16
cd server
docker build -t rifas:sospechosa .
docker run --rm rifas:sospechosa
```

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

Ni siquiera es el cable: es la **imagen**. Y el dato clave es *"el código no
cambió"*, que descarta la aplicación y deja tres sospechosos: la receta de
construcción, la máquina que construye, y las **imágenes base**.

¿Qué versión exacta de la imagen base usa tu Dockerfile? ¿Y qué versión usaba
anteayer?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Lee el error del contenedor **entero**, sin recortar. Después:

```bash
docker run --rm --entrypoint file rifas:sospechosa /usr/local/bin/api
docker image inspect rifas:sospechosa --format '{{.Architecture}} {{.Os}}'
docker history rifas:sospechosa
```

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si el binario está enlazado dinámicamente contra `glibc` y el runtime usa `musl`,
¿qué archivo es el que "no existe"? Pista: no es el binario.

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz**

**El binario tiene cgo y el runtime cambió de `libc`.**

Alguien tocó el Dockerfile para "aligerar la imagen" y cambió el runtime de
`debian:bullseye-slim` a `alpine`. El código de la aplicación no cambió — el
ticket dice la verdad. Lo que cambió fue la receta.

Y el error es el más desconcertante que existe:

```
exec /usr/local/bin/api: no such file or directory
```

sobre un binario que puedes listar, ver y que tiene permisos de ejecución. **El
archivo que no existe es la `libc` que el binario espera**, no el binario:

```bash
docker run --rm --entrypoint file rifas:sospechosa /usr/local/bin/api
# ELF 64-bit LSB executable, dynamically linked,
# interpreter /lib64/ld-linux-x86-64.so.2
```

El builder es Debian (`glibc`); Alpine usa `musl`. El binario arrastra cgo porque
`mattn/go-sqlite3` lo exige y su `import` está en un archivo sin etiqueta de
compilación — o sea, **el binario de producción lleva un driver de SQLite que no
usa jamás**.

**Por qué funcionaba en la máquina de quien construyó:** no ejecutó la imagen; o
la ejecutó con una caché de capas anterior al cambio. `docker build` sin
`--no-cache` puede reutilizar capas viejas y esconder exactamente esta clase de
problema.

📝 **Y hay dos hermanas de esta causa** que producen síntomas parecidos y conviene
reconocer:
- **Arquitectura:** imagen construida en un Mac con Apple Silicon (`arm64`)
  ejecutándose en un runner `amd64` → `exec format error`.
- **Zonas horarias:** con una imagen mínima sin `/usr/share/zoneinfo`,
  `time.LoadLocation("America/Bogota")` devuelve `unknown time zone` **solo dentro
  del contenedor**.

**Parche mínimo**

Volver al runtime compatible:

```dockerfile
# Mientras haya cgo, builder y runtime tienen que compartir libc. Punto.
FROM debian:bullseye-slim
```

**La corrección correcta**

La de `be09`, y tiene un giro que vale la pena entender: **la pregunta estaba mal
planteada**. No era *qué imagen base aguanta cgo*, sino **por qué el binario de
producción tiene un driver de SQLite**.

SQLite solo se usa en pruebas. Se saca de la compilación con una etiqueta:

```go
// server/internal/storage/driver_sqlite.go
//go:build sqlite

package storage

import _ "github.com/mattn/go-sqlite3"
```

⚠️ La línea `//go:build` va **antes del `package` y separada por una línea en
blanco**, o el compilador la trata como un comentario cualquiera. Es un error
silencioso: compila igual, con cgo, y solo lo notas midiendo.

Y entonces:

```dockerfile
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags "-s -w" -o /out/api ./cmd/api

FROM gcr.io/distroless/static-debian11:nonroot
```

Binario estático, imagen de ~2 MB, sin `libc` que emparejar. Y `D19` —abierta
desde `be02`— cerrada con una medición en vez de con una opinión.

**Prueba de regresión**

En el pipeline, no en `go test`:

```yaml
- name: El binario de producción tiene que ser estático
  run: |
    CGO_ENABLED=0 go build -o /tmp/api ./cmd/api
    # Si aparece "dynamically linked", alguien volvió a meter cgo.
    file /tmp/api | grep -q "statically linked" || {
      echo "El binario quedó enlazado dinámicamente: revisa las etiquetas de compilación"
      exit 1
    }

- name: La imagen tiene que arrancar
  run: |
    docker build --no-cache -t rifas:ci ./server
    docker run -d --name smoke -p 3001:3001 -e DATABASE_URL="$DB" rifas:ci
    sleep 3 && curl -fsS localhost:3001/health
```

**Prevención**

1. **El paso de CI de arriba.** Es lo que impide que la decisión de `D19` se
   deshaga sola dentro de seis meses.
2. **`docker build --no-cache` en el pipeline.** La caché es una optimización de
   desarrollo y una fuente de falsos positivos en CI.
3. **Fijar la plataforma** (`--platform linux/amd64`) para que construir en un
   Mac y desplegar en un servidor den lo mismo.
4. **Etiquetar por `sha`** y no por `latest`: sin eso, "la imagen de ayer" y "la
   de anteayer" no son identificables, y media hora del diagnóstico se va en
   averiguar qué se desplegó.
5. **Correr `smoke.sh` contra el contenedor**, no solo contra `go run`. Es la
   diferencia entre "el código funciona" y "lo que vamos a desplegar funciona".

**Por qué llegó a producción**

Porque el cambio era **una mejora**. Alguien vio una imagen de 80 MB, la cambió
por una de 15, comprobó que el `docker build` terminaba sin errores, y lo subió.
Todo razonable.

El pipeline **construía** la imagen y no la **ejecutaba**: verificaba que el
Dockerfile fuera válido, no que el resultado arrancara. Es una distinción que
parece obvia dicha así y que falta en la mayoría de los pipelines.

Y el error final era ilegible. *"No such file or directory"* sobre un archivo que
existe manda a cualquiera a revisar rutas y permisos durante un buen rato — que
es justo donde no está el problema.

**Si tu causa fue distinta a esta**

- *"Es la arquitectura"* — es la hermana, y produce `exec format error`, no
  `no such file or directory`. El mensaje exacto los distingue.
- *"Falta `tzdata`"* — la otra hermana. Daría un error de zona horaria en tiempo
  de ejecución, con el proceso ya arrancado.
- *"Cambió la imagen base sin que nadie lo tocara"* — plausible y muy real si el
  Dockerfile usa una etiqueta móvil (`golang:1.19` puede apuntar a una imagen
  distinta que hace un mes). Se comprueba con `docker image inspect` y sus
  digests, y refuerza la conclusión: **fija versiones y no confíes en etiquetas
  móviles**.
- Si tu fix fue **instalar `gcc` y `musl-dev` en el builder de Alpine**, funciona…
  y ahora el binario no corre en Debian. Cambiaste de sitio el problema.

</details>

---

# 🪞 Retrospectiva del track BE

Se llena al terminar los dieciséis, de una sola vez, releyendo tu propio
`git log`.

- **Cuántos abriste, cuántos cerraste, cuántos quedaron ⚪.**
- **Cuántas veces tu causa raíz coincidió con la de referencia**, y en cuáles no.
  El patrón importa más que el número.
- **En qué capa te costó más**: handler, service, store, esquema, transacción,
  infraestructura. Si la respuesta es "transacciones", estás en buena compañía.
- **Cuántas veces empezaste buscando del lado equivocado del cable**, y qué dato
  del ticket te habría ahorrado ese desvío.
- **Los seis hermanos.** Compara tu diagnóstico del incidente BE con el del track
  base. ¿Habrías llegado a la causa de acá teniendo solo las herramientas de allá?
  Esa respuesta es la tesis del track, medida contigo mismo.
- **Qué pista abriste antes de tiempo y por qué.** Sin culpa: es un dato sobre
  dónde te falta confianza.
- **Tu checklist de diagnóstico de backend**, la de una página, escrita con lo que
  aprendiste acá. Es lo único de este archivo que te llevas al trabajo real.

> **La señal de que quedó bien:** cuando te llegue un ticket que dice "a veces no
> anda", tu primera reacción no sea abrir el código, sino preguntar *"¿la petición
> salió, qué volvió, y qué dice el log para ese `X-Request-Id`?"*.

---

# 📌 Pendientes que salieron de los incidentes

*(Fuera de lo que lee el estudiante.)*

- **Las ramas `incidente/be-NN` no existen todavía.** Cada incidente declara su
  preparación con una rama que hay que crear en el repositorio del alumno —o
  reescribir la sección `🔧 Preparación` para que el estado roto se produzca con
  un `git revert` o con una edición guiada. Es el trabajo pendiente más concreto
  de este archivo.
- **Cobertura por categoría**, revisada al cerrar: contrato 5, transacciones 3,
  tiempo 2, base de datos 2, despliegue 2, autenticación 1, dinero 1. **Despliegue
  quedó algo servido y dinero apenas con uno**; si se amplía el rango en el
  futuro, por ahí conviene crecer.
- **Reparto por dificultad:** 🟡 4 · 🟠 6 · 🔴 6. Sin ninguno 🟢, y es
  deliberado: no hay incidentes de backend fáciles en este dominio, y fabricar uno
  artificialmente sería peor que no tenerlo.
- **Seis terminan sin fix en el código**, que era el objetivo: `be-01` y `be-02`
  registran hallazgos, `be-08` y `be-11` concluyen que el sistema hizo lo
  correcto, `be-07` termina en una conversación con tesorería y `be-12` en una
  decisión de negocio. Ese desenlace es real y casi nunca se practica.
- **`be-08` y `be-11` son los dos que más se van a discutir**, porque su respuesta
  es *"no se arregla, y aquí está por qué"*. Si la revisión editorial los suaviza,
  se pierde lo mejor que tienen.
- **Los seis hermanos del track base están cruzados en el índice**, pero el
  cuaderno base **no los referencia de vuelta** porque sus veinte enunciados
  siguen sin redactar. Cuando se escriban, conviene añadir la referencia cruzada
  en los incidentes 08, 11, 16, 18, 19 y 20.
- **Ningún incidente depende de datos generados con faker.** Es deliberado: un
  conjunto aleatorio arruinaría la reproducibilidad (`bea-10` §7). `be-09` y
  `be-05` se benefician del volumen para reproducirse más rápido, pero no lo
  exigen.
- **Nada de esto reemplaza a `cuaderno-incidentes.md`**, cuyos veinte incidentes
  del track base siguen siendo el hueco declarado más grande del curso.
