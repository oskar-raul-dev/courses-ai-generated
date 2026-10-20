# 📓🔥 Cuaderno de incidentes — Track BE

> Tutorial React 16 — La Esclusa, la consola de Jewel Locks · **Track BE opcional 🔥** · Documento vivo
> El changelog es `git log -- cuaderno-incidentes-be.md`
> El tiempo ya está contado dentro de las 86 h del track BE; no es un bloque aparte

Este es el cuaderno del **track opcional de backend**. Los dieciocho incidentes
de acá ocurren del otro lado del cable: en el binario de Go, en PostgreSQL, en el
contenedor o en el pipeline. Su rango de IDs —`be-01` a `be-18`— está reservado
en `cuaderno-incidentes.md` y **nunca se reasigna**.

> 📝 **Por qué este archivo existe aparte.** `cuaderno-incidentes.md` se declara
> "el único archivo de incidentes del curso", y esa frase se escribió antes de que
> el track BE existiera. Se **diverge a propósito** y por dos razones: el track BE
> es opcional, y un alumno que solo hace las 98 horas del track base no debería
> encontrarse dieciocho incidentes de Go y Postgres intercalados entre los suyos;
> y los IDs `be-NN` conviven con los `01`–`21` sin colisionar precisamente porque
> están en rangos distintos. El cuaderno base conserva la reserva y apunta acá.
>
> La estructura, las reglas y el tono son **exactamente los mismos**. Lo que
> cambia son las herramientas —logs, `psql`, `pg_stat_activity`, `EXPLAIN`,
> `go test -race`, `docker`— y una pregunta que encabeza cada enunciado: **de
> qué lado del cable está la causa**.

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
incidente(be-09): abre — otra vez más Esclusas de Oro que stock, y el contador dice que sobran
incidente(be-09): repro — 50 jugadores a la vez con k6 sobre la rueda de medición: 1.500 entregadas
incidente(be-09): hipótesis descartada — no es el juego: la misma clave no se repite en la bitácora
incidente(be-09): causa — takeStock lee el stock sin FOR UPDATE y escribe el valor calculado en Go
incidente(be-09): fix — vuelve el SELECT ... FOR UPDATE sobre la fila del stock
incidente(be-09): cierre — TestStockNeverExceeded contra Postgres y post-mortem
```

Y si el incidente deja el laboratorio roto a propósito, el par de tags de
`00-convencion-de-git-y-tags.md`: `inc/be-09/esclusas-de-mas-roto` e
`inc/be-09/esclusas-de-mas-fix`.

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
| "Entregamos más de lo que había" | la bitácora contra el contador | concurrencia | be-09 |
| "Quedó en proceso para siempre" | quién cierra los pedidos, y con qué fecha | concurrencia | be-10 |
| "Siguió girando tras el cierre" | quién evalúa la hora, y con qué | autoridad del reloj | be-12 |
| "Cobran el giro gratis antes de tiempo" | de dónde sale la hora del reclamo | autoridad del reloj | be-18 |
| "La cuenta no cuadra" | de cuándo son los datos que entraron | contrato, transacción | be-13, be-14 |
| "Verde en la suite, rojo en PROD" | contra qué motor corre la suite | pruebas | be-15 |
| "La imagen de ayer no arranca" | qué cambió si el código no cambió | despliegue | be-16 |
| "Siempre salen los mismos premios" | la versión de Go, y quién siembra el generador | aleatorio | be-17 |

Dos advertencias. La primera: la última columna son **candidatos**, no un
diagnóstico — `be-13` y `be-14` comparten síntoma y no comparten causa. La segunda,
y es la propia de este track: **seis de estos dieciocho tienen un hermano en el
cuaderno base con el mismo síntoma y otra causa raíz**, así que antes de dar por
cerrada una hipótesis conviene preguntarse si el síntoma que estás viendo no será
el de la otra orilla. El cruce está en la sección de hermanos, más abajo.

---

## 📋 Índice

| ID | Fase | Síntoma reportado | Categoría | Dif. | Estado |
|---|---|---|---|---|---|
| be-01 | be01 | La trazabilidad funciona en Network pero no en la consola | 🔥 contrato | 🟡 | ⬜ |
| be-02 | be00 | El premio entregado no tiene rueda | 🔥 contrato | 🟠 | ⬜ |
| be-03 | be01 | A ratos la consola da error de red, y el servidor nunca se cayó | 🔥 despliegue | 🟡 | ⬜ |
| be-04 | be02 (desde be03) | Las ruedas aparecen con la hora corrida | 🔥 base de datos | 🟠 | ⬜ |
| be-05 | be02 (desde be03) | Todo funciona hasta que hay gente | 🔥 base de datos | 🔴 | ⬜ |
| be-06 | be03 | El tablero dice que nadie compró giros | 🔥 contrato | 🟠 | ⬜ |
| be-07 | be03 | Faltan datos en las conciliaciones | 🔥 contrato | 🔴 | ⬜ |
| be-08 | be04 | A Yariela la saca de la sesión a las ocho de la noche, y a Itzel nunca | 🔥 autenticación | 🟡 | ⬜ |
| be-09 ⭐ | be05 | Otra vez más Esclusas de Oro que stock, y el contador dice que sobran | 🔥 concurrencia | 🔴 | ⬜ |
| be-10 | be05 | Un giro quedó "en proceso" para siempre | 🔥 concurrencia | 🟡 | ⬜ |
| be-11 | be06 | A los jugadores de Chile la rueda les cierra una hora antes | 🔥 tiempo | 🟡 | ⬜ |
| be-12 | be06 | Giros anotados después del cierre | 🔥 tiempo | 🟢 | ⬜ |
| be-13 | be07 | La conciliación y el reporte de la tienda no dan lo mismo | 🔥 dinero | 🟡 | ⬜ |
| be-14 | be07 | Acreditamos la compra dos veces | 🔥 transacciones | 🟡 | ⬜ |
| be-15 ⭐ | be08 | La suite lleva tres semanas en verde y ayer se rompió producción | 🔥 contrato | 🔴 | ⬜ |
| be-16 | be09 | La imagen de ayer no arranca y el código no cambió | 🔥 despliegue | 🟠 | ⬜ |
| be-17 | be05 | Cada vez que reiniciamos, la rueda da los mismos premios | 🔥 aleatorio | 🟠 | ⬜ |
| be-18 ➕ | be06 | Hay jugadores que cobran el giro gratis cada hora | 🔥 tiempo | 🟡 | ⬜ |

**Categorías propias del track:** 🔥 base de datos · 🔥 transacciones · 🔥
concurrencia · 🔥 despliegue · 🔥 contrato · 🔥 aleatorio. Se suman a las del
cuaderno base, de donde salen autenticación, tiempo y dinero.

**⭐** marca los dos más formativos: las Esclusas de Oro de más (`be-09`) y la
suite que autorizó un despliegue roto (`be-15`).

### Los hermanos del track base

Seis de estos dieciocho comparten síntoma con un incidente del cuaderno base y
tienen **otra causa raíz**. Ese paralelo es deliberado y es de lo más formativo
que ofrece el track: resolverlos en pareja te enseña más que resolver doce
sueltos.

| Track base | Track BE | Qué cambia |
|---|---|---|
| 11 — la compensación doble ⭐ | **be-09** ⭐ | Allá el store y un chequeo en dos pasos; acá el mismo chequeo en dos pasos, dentro de una transacción que no excluye |
| 16 — seguimos enviando giros de una rueda que ya cerró | **be-12** | Allá el reloj del navegador; acá la autoridad temporal del servidor |
| 18 — la conciliación da un centavo de diferencia | **be-13** | Allá el redondeo; acá el cliente calculando con datos viejos |
| 20 — el test pasa en mi máquina y falla en la de al lado | **be-15** ⭐ | Allá el entorno; acá el **motor** de la base |
| 08 — me saca a login al azar mientras estoy trabajando | **be-08** | Allá el `401` del caos; acá un `exp` real sin renovación |
| 19 — el dashboard se arrastra al final de la Semana del Canal | **be-05** | Allá memoización; acá el pool de conexiones agotado |

---

# 🧪 Incidentes

Ordenados por ID, que es también el orden sugerido. El ID nunca se reasigna.

---

## Incidente be-01 — La trazabilidad funciona en Network pero no en la consola

> **Fase:** be01 · **Categoría:** 🔥 contrato · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 30-45 min

### 🎫 El ticket

> "Estoy probando el binario nuevo desde la consola del navegador, con `fetch`,
> para que soporte le pueda pasar a Juliana el id de cada petición. El header
> está: lo veo en la pestaña de red. Pero `r.headers.get('X-Request-Id')` me da
> `null`. A un compañero sí le sale el id, así que a lo mejor es algo de mi
> Chrome."

**Reportado por:** el equipo de Juliana
**Ambiente:** desarrollo

### 🎯 Qué se te pide

Determinar por qué el header **se ve** y no **se lee**, de qué lado del cable está
la causa y por qué al compañero sí le sale. Después, el fix y la prueba que lo
habría atrapado.

### 🔧 Preparación

```bash
git checkout incidente/be-01
cd server && PORT=3011 go run ./cmd/api     # el binario de la rama, en el puerto de transición
# En otra terminal, como siempre:
CHAOS_LEVEL=off npm run mock:all            # el mock sigue en el 3001
npm start
```

Con la consola abierta en `localhost:3000`, pide `/health` al binario desde la
consola del navegador, igual que en `be01` §5.7.

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

El header llega: lo estás viendo. Así que el backend lo mandó. La pregunta no es si
el dato viaja, sino **quién tiene permiso para leerlo** una vez que llegó.

Y el detalle del reporte que parece ruido y no lo es: *"a un compañero sí le
sale"*. ¿Contra qué servidor está probando esa persona?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Evalúa las dos cosas a mano, una detrás de la otra:

```javascript
fetch('http://localhost:3011/health')
  .then(r => console.log('binario:', r.headers.get('X-Request-Id')));
fetch('http://localhost:3001/wheels')
  .then(r => console.log('mock:', r.headers.get('X-Request-Id')));
```

Después compara en Network los headers de **respuesta** completos de las dos
peticiones, no solo el que buscas. Hay uno que está en una y no en la otra.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

En una petición de origen cruzado, ¿qué headers de respuesta le entrega el
navegador a JavaScript, y cuáles se guarda para sí? ¿Qué tiene que declarar el
servidor para ampliar esa lista, y quién lo declara en el mock?

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
DevTools pero **inaccesible desde código**, salvo que la respuesta lo declare
explícitamente:

```
Access-Control-Expose-Headers: X-Request-Id
```

El `corsMiddleware` del binario de la rama perdió esa línea. El header sale, Network
lo muestra, y `r.headers.get('X-Request-Id')` vale `null`. Medido en el navegador
contra la rama: `null` desde el `3011` y el id completo desde el `3001`, en la misma
consola y en el mismo segundo.

📝 **Y la pista del compañero era real, no ruido.** Esa persona está probando
contra el **mock**, y el mock expone el header en `mock/requestIdMiddleware.js`
desde la Fase 2. Es exactamente lo que `be00` registró como `C-05`: esa línea es
contrato aunque no figure en ninguna tabla de rutas, y un reemplazo que emite el
header y olvida exponerlo deja la trazabilidad visible en Network y muda en el
código. Dos servidores, dos comportamientos, mismo cliente. Es el "en mi máquina
anda" de manual, y por eso el reporte lo mencionaba.

**Parche mínimo**

Devolver la línea al middleware de CORS:

```go
w.Header().Set("Access-Control-Expose-Headers", requestIDHeader)
```

**La corrección correcta**

La misma línea, más las dos defensas que faltaban: la verificación 11 de
`server/smoke.sh` corrida **contra el binario** y no solo contra el mock
(`BASE_URL=http://localhost:3011 ./server/smoke.sh`), y una prueba de handler que
falle si alguien vuelve a tocar el middleware.

**Prueba de regresión**

Sobre la **respuesta real**, que es donde el navegador mira. Comprobarlo en el
preflight no sirve: ahí el header no cuenta.

```go
// server/internal/http/cors_test.go

package httpapi

import (
	"net/http/httptest"
	"strings"
	"testing"
)

// be-01: el X-Request-Id no basta con que viaje; la respuesta real tiene que exponerlo.
func TestRequestIDIsExposedToTheBrowser(t *testing.T) {
	req := httptest.NewRequest("GET", "/health", nil)
	req.Header.Set("Origin", "http://localhost:3000")
	rec := httptest.NewRecorder()

	NewRouter(Config{AllowedOrigin: "http://localhost:3000", ChaosLevel: "off"}).ServeHTTP(rec, req)

	if rec.Header().Get("X-Request-Id") == "" {
		t.Fatal("la respuesta no trae X-Request-Id")
	}
	if !strings.Contains(rec.Header().Get("Access-Control-Expose-Headers"), "X-Request-Id") {
		t.Fatalf("X-Request-Id viaja pero no está expuesto: Access-Control-Expose-Headers=%q",
			rec.Header().Get("Access-Control-Expose-Headers"))
	}
}
```

En la rama falla con `X-Request-Id viaja pero no está expuesto:
Access-Control-Expose-Headers=""`; en `fase-be01-go-y-la-forma-del-monolito`
pasa. Motor: ninguno. Es una prueba de handler y no toca la base.

**Prevención**

El `smoke.sh` contra el binario en cada fase y la prueba de arriba. Las dos son
necesarias: el `smoke.sh` atrapa "el ambiente está mal configurado" y la prueba
atrapa "alguien tocó el middleware".

**Por qué llegó a producción**

Porque el síntoma es invisible desde el lado que lo produce. El header está ahí;
nada en el servidor sugiere que falte algo, y `curl` lo muestra perfecto. Y del
lado del cliente, `null` o `undefined` en un `console.debug` es exactamente lo que
se ve cuando no pasa nada: no hay error, no hay advertencia, no hay señal.

A eso se suma que **funcionaba para quien probaba contra el mock**, lo que convierte
el problema en "algo de tu Chrome" y desvía la investigación hacia el navegador,
que es justo el lado que no tiene la culpa.

**Si tu causa fue distinta a esta**

- *"Se lee con la clave mal escrita"* — plausible: hay librerías que distinguen
  mayúsculas. Compruébalo: `Headers.get` de `fetch` no distingue, y `axios`
  normaliza a minúsculas; el interceptor de la Fase 2 usa `'x-request-id'`.
  Descartada por lectura, pero era una hipótesis correcta de formular.
- *"El binario no siempre pone el header"* — se descarta mirando diez peticiones
  en Network o con `curl -D -`: está en todas.
- *"Hay que exponerlo en el preflight"* — el `OPTIONS` ya lo trae en la fase y no
  cambia nada: el navegador mira `Access-Control-Expose-Headers` en la respuesta
  real. Agregarlo solo ahí deja el bug intacto.
- Si concluiste *"hay que loguearlo en el servidor y correlacionar por hora"*,
  tapaste el síntoma: funciona, y te deja sin trazabilidad en el cliente para
  siempre.

</details>

---

## Incidente be-02 — El premio entregado no tiene rueda

> **Fase:** be00 · **Categoría:** 🔥 contrato · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45-60 min

### 🎫 El ticket

> "Anoche cerramos la Esclusa de Oro y el stock bajó, o sea que la gente se
> ganó el avatar. Pero abro el tablero de esa rueda y dice cero giros, y en
> probabilidades dice *Sin alarma*. ¿Cero giros con el stock bajando? Si mañana
> alguien en el Discord vuelve con lo de *la rueda está arreglada*, no tengo un
> solo número para contestarle."

**Reportado por:** Itzel, operación
**Ambiente:** PROD

### 🎯 Qué se te pide

Encontrar dónde se pierden los giros entre el juego y el tablero, y de qué lado del
cable está la causa. El entregable es el hallazgo registrado en `server/CONTRACT.md`
con la forma canónica de la fila y su comando de reproducción; el fix real llega en
`be05`.

### 🔧 Preparación

```bash
CHAOS_LEVEL=off npm run mock:all
npm start
# Haz girar al juego: veinte giros de la jugadora 42, como los manda el celular.
for i in $(seq 1 20); do
  curl -s -o /dev/null -X POST -H 'Content-Type: application/json' \
       -d "{\"idempotencyKey\":\"k-be02-$i\"}" localhost:3001/players/42/spins
done
```

Después abre el tablero y elige la Esclusa de Oro.

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

*"El stock bajó y el tablero no lo ve"* dice que hay dos cosas que deberían contar
lo mismo y no lo hacen. Una la escribe el juego; la otra la lee la consola. Antes de
mirar el tablero, mira **qué escribió el juego**.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```bash
curl -s localhost:3001/stock/1 | jq .remaining
curl -s 'localhost:3001/spinLog?wheelId=1' | jq length
curl -s 'localhost:3001/spinLog?idempotencyKey=k-be02-1' | jq .
```

Compara esa fila, campo por campo, con una de las que trae la Rueda de fin de mes
(`?wheelId=4`), y busca en Network qué le pide el tablero al servidor.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si el tablero pide `GET /spinLog?wheelId=1` y la fila no tiene `wheelId`, ¿qué
devuelve json-server? ¿Y qué código de estado?

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

**La bitácora tiene dos escritores, y cada uno escribe una forma distinta de la
misma fila.**

- Las filas que trae `mock/db.json` desde la Fase 8 —la Rueda de fin de mes, la
  Semana del Canal sembrada— tienen la forma completa: `wheelId`, `playerId`,
  `landedSegment`, `deliveredPrize`, `origin`, `idempotencyKey` y `createdAt`.
- El giro de 2019, el que llama el juego, escribe solo cuatro campos:

```javascript
db.get("spinLog")
  .push({ playerId, idempotencyKey, landedSegment: "esclusa-de-oro", createdAt: new Date().toISOString() })
  .write(); // viaje 3
```

El tablero de la Fase 9 pide `GET /spinLog?wheelId=1`, y json-server filtra por un
campo que esas filas no tienen: devuelve `200` con `[]`. Medido: después de los
veinte giros, `stock.remaining` está en 980 —veinte Esclusas de Oro entregadas—,
`GET /spinLog?wheelId=1` devuelve cero filas, y las tarjetas dicen *Giros 0 · 0
gratis · 0 pagos* y *Probabilidades: Sin alarma, χ² = 0.00*. La alarma no suena
porque no hay datos que auditar, y eso se ve igual que una rueda honesta.

Es el hallazgo **`C-03`** de `be00`.

📝 **Nota de época.** La rueda de 2019 no tenía bitácora: anotaba lo que el jugador
recibía y nada más (`00-historia-del-sistema.md` §5). El giro del mock imita esa
pobreza, y la forma completa la trajo la conciliación de la Fase 8, que necesitaba
saber de qué rueda era cada giro. Dos equipos, con años de diferencia, escribieron
la misma colección sin un contrato que dijera qué tiene una fila. No es descuido de
nadie: es lo que pasa cuando la forma de un dato vive en la cabeza de quien lo
escribe.

**Parche mínimo**

Ninguno en `be00`: se documenta. En `CONTRACT.md`, régimen estricto:

> `GET /spinLog?wheelId=<id>` — cada fila tiene la forma completa: `id`, `wheelId`,
> `playerId`, `landedSegment`, `deliveredPrize`, `origin`, `idempotencyKey`,
> `createdAt`. El giro de hoy (`POST /players/:id/spins`) **no la cumple**: escribe
> filas sin `wheelId`, `origin` ni `deliveredPrize`, y el tablero y la conciliación
> no las ven. Reproducción: los veinte giros de arriba y `GET /spinLog?wheelId=1`.

**La corrección correcta**

En `be05`, cuando el giro sea una sola operación que escribe el hecho completo en
`spin_log`: la rueda y su versión de pesos, el segmento en que cayó, el premio
entregado, el origen y la clave de idempotencia, en la misma transacción que
descuenta el saldo y el stock. Hasta entonces, `be03` reimplementa el giro tal cual,
con su fila pobre incluida: el contrato obliga a la forma que el juego espera, no a
la que el tablero querría.

**Prueba de regresión**

La escribe la suite de contrato de `be08`, sobre el giro de `be05`, y su criterio cabe
en una línea: **un giro de la jugadora 42 con una clave nueva aparece en
`GET /spinLog?wheelId=1`, con `wheelId`, `origin` y `deliveredPrize` llenos**. Contra
el giro de hoy falla en la primera condición: la fila existe, pero no en esa rueda.
Motor: PostgreSQL. Toca la base, aunque no las cuatro áreas críticas.

**Prevención**

El contrato escrito de `be00` con la forma de la fila, y la prueba de arriba. Y una
regla de diseño que esta colección enseña: **una colección, una forma, un dueño**.
Que dos procesos escriban la misma tabla está bien; que cada uno decida qué columnas
llenar, no.

**Por qué llegó a producción**

Porque el fallo **no produce ningún error**. El giro responde `200`, el juego
entrega el avatar, el stock baja. El tablero recibe `200` con un array vacío, que es
una respuesta perfectamente válida para una rueda sin giros. Y la auditoría de
probabilidades, con cero giros, dice *Sin alarma*: el único indicador pensado para
detectar una rueda rara es justo el que se queda callado cuando no hay datos.

**Si tu causa fue distinta a esta**

- *"El tablero calcula mal"* — es la hipótesis obvia, y la que Itzel asumió. Se
  descarta mirando la respuesta en Network: el servidor **devolvió** cero filas, y el
  tablero las contó bien.
- *"Los giros no se guardaron"* — se descarta con `GET /spinLog?idempotencyKey=…`:
  están, sin rueda.
- *"La caché del navegador"* — con *Disable cache* activado da lo mismo.
- Si concluiste *"hay que filtrar por segmento en vez de por rueda"*, cuidado: el
  slug `esclusa-de-oro` existe en más de una rueda (la Rueda de fin de mes también
  lo tiene), y el tablero mezclaría giros de las dos.

</details>

---

## Incidente be-03 — A ratos la consola da error de red, y el servidor nunca se cayó

> **Fase:** be01 · **Categoría:** 🔥 despliegue · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 30-45 min

### 🎫 El ticket

> "Desde que probamos el servidor nuevo, a ratos abro el asistente de envíos y
> sale *Network Error* debajo de la búsqueda. No siempre: a veces la lista sale
> bien. Si escribo un nombre, aparece y sigo trabajando. Juliana dice que el
> servidor no se cayó en ningún momento, y en la pantalla de *Ruedas* todo va
> normal."

**Reportado por:** Yariela, soporte
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducirlo a voluntad —que es la mitad del trabajo—, determinar por qué el
cliente ve un **error de red** y no un `500`, y por qué "a ratos". Después, el fix.

### 🔧 Preparación

```bash
git checkout incidente/be-03
cd server && PORT=3011 go run ./cmd/api
```

La rama adelanta un `GET /players` en memoria, para probar el asistente contra el
binario antes de que exista la base. Pídelo desde la consola del navegador (con la
consola abierta en `localhost:3000`) o con `curl`, con y sin filtro, igual que lo
pide el asistente.

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

*"Network Error"* y *"el servidor no se cayó"* son dos datos muy concretos. Un `500`
no es un error de red: llega con status, con cuerpo y con headers. Un error de red
es lo que ve el cliente cuando **no llega ninguna respuesta**.

¿Qué tendría que pasarle a un servidor vivo para que no conteste?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Mira la **terminal del servidor** mientras reproduces, no el navegador. Y compara
dos peticiones:

```bash
curl -v localhost:3011/players?name_like=ju
curl -v localhost:3011/players
```

Después abre el asistente de la Fase 5 y mira en Network qué pide al abrirse, y qué
pide si empiezas a escribir antes de que pase medio segundo (`searchPlayerEpic`,
Fase 6).

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

En Go, ¿qué hace `net/http` con un pánico dentro de un handler cuando nadie lo
recupera? ¿Y qué middleware de la cadena de `be01` debería haberlo convertido en un
`500`?

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

Dos cosas, y las dos hacen falta. La primera: el handler indexa la query sin mirar
si el parámetro vino:

```go
query := strings.ToLower(r.URL.Query()["name_like"][0])
```

Cuando el asistente se abre, `searchPlayerEpic` pide todos los jugadores, **sin**
`name_like`, y ese `[0]` sobre un slice vacío entra en pánico: `index out of range
[0] with length 0`. La segunda: la rama sacó `recoverMiddleware` de la cadena.

Sin `recover`, `net/http` recupera el pánico por su cuenta, y lo hace a su manera:
escribe `http: panic serving 127.0.0.1:50674: runtime error: index out of range [0]
with length 0` en el log, con el stack, y **cierra la conexión sin responder**. El
proceso sigue vivo —por eso Juliana tiene razón—, pero el cliente no recibe nada.
Medido en el navegador: `fetch` lanza `TypeError: Failed to fetch` y `axios`
entrega `Network Error` con `error.response` en `undefined`. Sin status, sin cuerpo
y **sin `X-Request-Id`**, que tampoco aparece en la línea del log: no hay con qué
cruzar el ticket con el servidor.

📝 **Y el "a ratos" tiene explicación, y está en el frontend.** `searchPlayerEpic`
espera 300 ms (`debounceTime`) antes de pedir. Si Yariela empieza a escribir antes
de que pasen, la búsqueda vacía nunca sale, y lo que sale lleva `name_like`: todo
funciona. Si abre el asistente y espera, sale `GET /players` a secas, y revienta.
Mismo servidor, misma pantalla, distinto ritmo de quien la usa.

**Parche mínimo**

Devolver `recoverMiddleware` a su lugar en `NewRouter`, entre `cors` y `chaos`. Con
eso, la misma petición responde `500` con `{"error":"Error interno del servidor"}` y
su `X-Request-Id`, y el log escribe `[req-id 8bb18bf70c5e58bb] PÁNICO en GET
/players: runtime error: index out of range [0] with length 0`, **con el mismo id**.
El asistente ya no dice *Network Error*: dice *El servidor tuvo un problema*, y
Yariela tiene un id para pegar en el ticket.

**La corrección correcta**

Además del `recover`, arreglar el pánico. Un pánico recuperado sigue siendo un
bug: el `recover` convierte el silencio en un `500`, no hace que la petición
funcione.

```go
query := strings.ToLower(r.URL.Query().Get("name_like")) // "" si no vino: todos los jugadores
```

Con eso, `GET /players` devuelve `200` con todos los jugadores, que es lo que el
contrato de `be00` dice que hace el mock.

**Prueba de regresión**

```go
// server/internal/http/panic_test.go

package httpapi

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

// be-03: lo que pide el asistente al abrir (GET /players sin name_like) no puede
// romper el handler, y si algo entra en pánico, el cliente recibe un 500 legible.
func TestPlayersWithoutFilterAnswers(t *testing.T) {
	rec := httptest.NewRecorder()
	NewRouter(Config{AllowedOrigin: "http://localhost:3000", ChaosLevel: "off"}).
		ServeHTTP(rec, httptest.NewRequest("GET", "/players", nil))
	if rec.Code != http.StatusOK {
		t.Fatalf("GET /players sin filtro respondió %d", rec.Code)
	}
}

func TestPanicBecomesReadable500(t *testing.T) {
	boom := http.HandlerFunc(func(http.ResponseWriter, *http.Request) { panic("explota a propósito") })
	handler := requestIDMiddleware(loggingMiddleware(corsMiddleware("http://localhost:3000")(recoverMiddleware(boom))))

	rec := httptest.NewRecorder()
	handler.ServeHTTP(rec, httptest.NewRequest("GET", "/boom", nil))

	if rec.Code != http.StatusInternalServerError {
		t.Fatalf("un pánico respondió %d, se esperaba 500", rec.Code)
	}
	if rec.Header().Get("X-Request-Id") == "" || rec.Header().Get("Access-Control-Allow-Origin") == "" {
		t.Fatal("el 500 tiene que llevar su X-Request-Id y los headers de CORS")
	}
}
```

En la rama, la primera falla; con las dos correcciones, pasan las dos. La segunda
prueba el middleware solo, armado a mano: que `NewRouter` no lo vuelva a perder lo
cuida la suite de contrato de `be08`, que golpea el router entero. Motor: ninguno.

**Prevención**

El `recover` en la cadena, las dos pruebas, y una regla de revisión que cuesta poco:
**ningún acceso por índice a algo que viene del cliente** sin mirar antes su
longitud. `Query().Get` existe justamente para no tener que hacerlo.

**Por qué llegó a producción**

Porque nada se cayó. Sin muerte del proceso no hay reinicio, sin reinicio no hay
alerta, y una conexión cerrada se confunde con "internet estuvo lento". La línea
del log existía, pero sin id y entre cientos de líneas normales, y nadie sabía qué
petición buscar. Y el ritmo de quien usa la pantalla —esperar o escribir rápido—
hacía que el error apareciera y desapareciera sin patrón aparente.

El diagnóstico, además, se desvía con facilidad hacia el lado equivocado: quien
viene de Node espera que un error en el handler sea un `500`, porque Express lo es;
y quien conoce algo de Go espera que un pánico tumbe el proceso. Ninguna de las dos
cosas pasa acá, y las dos intuiciones mandan a buscar donde no es.

**Si tu causa fue distinta a esta**

- *"Es el `timeout` del caos"* — plausible, porque también da error de red. Se
  descarta con `CHAOS_LEVEL=off` (el binario arranca así por defecto) y con la línea
  `http: panic serving` en el log, que el caos no produce.
- *"Es CORS"* — un header de CORS que falta también termina en *Network Error* en
  el navegador. Se descarta con `curl -v`: la respuesta no llega nunca (`Empty reply
  from server`), con o sin navegador de por medio.
- *"El servidor se reinicia"* — se descarta pidiendo `/health` justo después: responde,
  y el log no tiene ninguna línea de arranque nueva.
- Si tu fix fue *"poner un `try/catch` en el epic"*, tapaste el síntoma en el
  cliente y dejaste el pánico vivo en el servidor.

</details>

---

## Incidente be-04 — Las ruedas aparecen con la hora corrida

> **Fase:** be02 (se reproduce desde be03) · **Categoría:** 🔥 base de datos · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45-60 min

### 🎫 El ticket

> "Desde que cambiaron el servidor en UAT, la tabla de ruedas dice que la
> Esclusa de Oro cierra el 1 de enero de 2031 a la 1 de la mañana. Yo la
> programé para el 31 de diciembre a las 8 de la noche, como todas. ¿La corrijo
> a mano? No quiero que cierre cinco horas tarde."

**Reportado por:** Itzel, operación
**Ambiente:** UAT

### 🎯 Qué se te pide

Determinar si la rueda **cierra** a otra hora o solo **se muestra** a otra hora, de qué lado del cable está la causa, y qué habría pasado si Itzel la "corregía" a mano. Después, el fix y la prueba que ya existía y nadie corrió.

### 🔧 Preparación

```bash
git checkout incidente/be-04          # sale de fase-be03: no cambia ni una línea
cd server
export DATABASE_URL="postgres://esclusa:esclusa@localhost:5432/esclusa?sslmode=disable"   # tal como está en UAT
go run ./cmd/api
```

Y la consola, como siempre, contra el binario en el `3001`.

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

El frontend no cambió: el diff de la rama contra la fase está vacío. Así que si la tabla muestra otra cosa, lo que cambió es **lo que llega**. Y la rama tampoco cambió el backend. ¿Qué queda?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```bash
curl -s -H "Authorization: Bearer $TOKEN" 'localhost:3001/wheels/1' | jq -r .closesAt
psql "$DATABASE_URL" -c 'SHOW TimeZone;'
```

Convierte las dos fechas a UTC a mano. Después compara el `DATABASE_URL` de UAT con el de tu máquina.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

`TIMESTAMPTZ` guarda un instante. ¿En qué zona lo **devuelve**? ¿Y quién decide esa zona: la columna, el servidor de base, o la sesión?

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

Ninguna línea de código. El `DATABASE_URL` de UAT no tiene `timezone=America/Panama`, así que la sesión de Postgres queda en la zona del servidor de base, que en `postgres:13` es `Etc/UTC`. `TIMESTAMPTZ` guarda el instante y lo devuelve **en la zona de la sesión**, y `lib/pq` lo entrega a Go con ese huso. Medido contra la rama: la tabla de ruedas muestra `2031-01-01T01:00:00Z` donde la fase muestra `2030-12-31T20:00:00-05:00`.

**Es el mismo instante.** La rueda cierra exactamente cuando tenía que cerrar: la guarda de cierre de la Fase 7 compara instantes y no se entera. Lo que cambió es la **representación**, y `WheelTable` y el formulario la muestran tal cual llega.

El peligro no es el bug: es la corrección. Si Itzel escribe a mano `2030-12-31T20:00:00Z` "para que diga las 8", la rueda pasa a cerrar a las 3 de la tarde de Panamá, cinco horas antes de lo anunciado en el Discord. La representación equivocada invita a dañar el dato correcto.

Es la Divergencia 0 de `be02`, llegada como ticket vago.

**Parche mínimo**

El parámetro en el DSN de UAT:

```bash
DATABASE_URL="postgres://…/esclusa?sslmode=disable&timezone=America/Panama"
```

Medido: `SHOW TimeZone` pasa de `Etc/UTC` a `America/Panama`, y `closesAt` vuelve a salir con `-05:00`.

**La corrección correcta**

Que la representación no dependa de una variable que alguien puede olvidar en un ambiente. Eso es `be06`: el proceso en UTC, la zona de la sesión fijada por el backend (D29), y la decisión escrita de quién es la autoridad del reloj.

**Prueba de regresión**

Ya existía: es la verificación 3 de `server/smoke.sh`, *"wheel.closesAt trae offset"*. Contra la rama falla; contra la fase, pasa. El incidente no es que faltara la prueba: es que en UAT **nadie la corrió con el `DATABASE_URL` de UAT**. La prevención es correrla en cada ambiente después de cada despliegue, que es exactamente lo que `be09` pone en el pipeline.

Motor: PostgreSQL. Toca zonas horarias: la regla del motor de `be08` dice que contra SQLite no vale.

**Por qué llegó a producción**

Porque la consola **funciona**: compara instantes, y los instantes están bien. Nada falla, nada avisa. Y porque el valor que se ve raro tiene una explicación tentadora —"el servidor nuevo guarda mal la hora"— que lleva a corregir el dato en vez de la representación.

**Si tu causa fue distinta a esta**

- *"Go guarda la hora en UTC"* — se descarta con `psql`: el instante guardado es el mismo con las dos configuraciones, y cambiar la sesión cambia la salida sin tocar la tabla.
- *"El navegador está en otra zona"* — la tabla muestra la cadena cruda que llegó; Network la muestra igual, y Network no tiene zona.
- *"Hay que convertir en el frontend"* — tocaría la consola, y el contrato (`be00`) dice que `closesAt` llega con offset. El que se desvió es el backend.

</details>

---

## Incidente be-05 — Todo funciona hasta que hay gente

> **Fase:** be02 (se reproduce desde be03) · **Categoría:** 🔥 base de datos · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 60-90 min

### 🎫 El ticket

> "Anoche, con la caída de las 7, Itzel y yo compensamos a todos los
> afectados, y como éramos dos, varios casos los mandamos las dos y nos salía
> *ya compensado*. En algún momento la consola dejó de responder: no cargaban
> las ruedas, no cargaba nada. Juliana reinició el servidor y volvió. En las
> pruebas nunca pasa."

**Reportado por:** Yariela, soporte
**Ambiente:** PROD

### 🎯 Qué se te pide

Reproducirlo a voluntad, encontrar qué recurso se agota y por qué solo con "gente", y explicar qué tenía de distinto la noche del evento. Después, el fix y la prueba que lo atrapa.

### 🔧 Preparación

```bash
git checkout incidente/be-05
cd server && go run ./cmd/seed -file ../mock/db.json && go run ./cmd/api
```

La noche del evento, en una terminal: un envío de un caso, y después el mismo caso veinte y tantas veces, como dos operadoras compensando la misma lista.

```bash
H='Content-Type: application/json'; A="Authorization: Bearer $TOKEN"
curl -s -X POST -H "$H" -H "$A" -d '{"grantId":"g-1","caseId":"C-7","prize":"vidas-5","reason":"caída"}' localhost:3001/players/42/grants
for i in $(seq 1 27); do
  curl -s -o /dev/null --max-time 3 -w '%{http_code} ' -X POST -H "$H" -H "$A" \
       -d "{\"grantId\":\"g-$i\",\"caseId\":\"C-7\",\"prize\":\"vidas-5\",\"reason\":\"caída\"}" localhost:3001/players/42/grants
done; echo
```

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

"Dejó de responder todo" y "reiniciar lo arregla" son dos datos muy concretos. Algo se acumula dentro del proceso y no se libera. Y la condición no es "mucha gente": es una clase de respuesta que esa noche se repitió mucho.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Con la consola ya colgada:

```sql
SELECT state, count(*) FROM pg_stat_activity WHERE datname = 'esclusa' GROUP BY state;
```

Y pide `/health`. Después cuenta cuántas respuestas `409` diste antes del primer cuelgue, y compáralo con `SetMaxOpenConns` en `internal/storage`.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Un `*sql.Rows` devuelve su conexión cuando lo cierra `Close`, cuando `Next` llega al final, o cuando se cancela su contexto (`be02` §4). Busca una consulta que no cumpla ninguna de las tres.

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

El chequeo de caso de `SendGrant` se reescribió para "mirar solo si hay una fila":

```go
rows, err := s.db.Query(s.db.Rebind(`
	SELECT id FROM grants WHERE player_id = ? AND case_id = ?`), g.PlayerID, g.CaseID)
// …
if rows.Next() {
	return Grant{}, ErrCaseGranted
}
```

Dos faltas juntas. `Query` sin contexto, y una salida temprana sin `rows.Close()`. Cuando el caso **no** existe, `Next` devuelve `false` y el `Rows` se cierra solo: no pasa nada, y por eso las pruebas —que mandan casos nuevos— nunca lo ven. Cuando el caso **ya** existe, el `return` sale con el `Rows` abierto, nadie lo cierra, y como no hay contexto que se cancele, la conexión queda tomada para siempre.

Medido contra la rama: veinticinco respuestas `409` y después `000` (el cliente corta a los 3 s). `GET /wheels` se cuelga, `/health` responde `503` a los 2 s (el `Ping` espera una conexión que no llega) y `pg_stat_activity` muestra **25 conexiones `idle`**: para Postgres están ociosas, para el pool de Go están tomadas. Veinticinco es `SetMaxOpenConns(25)`.

La noche del evento tuvo lo que las pruebas no tienen: dos operadoras mandando la misma lista, o sea muchos `409`. "Hasta que hay gente" era, en realidad, "hasta que hay casos repetidos".

**Parche mínimo**

```go
defer rows.Close()
```

**La corrección correcta**

La consulta con contexto (`QueryContext`, guía §16.3) y, mejor todavía, sin `Rows`: `GetContext` sobre un `count(*)` o un `EXISTS`, que es como estaba en la fase. Una pregunta de sí o no no necesita un cursor.

**Prueba de regresión**

Con un pool chico, para que el agotamiento llegue rápido:

```go
// server/internal/player/pool_test.go

package player_test

import (
	"context"
	"errors"
	"os"
	"testing"
	"time"

	"github.com/interoceanic-games/esclusa-api/internal/player"
	"github.com/interoceanic-games/esclusa-api/internal/storage"
)

// be-05: veinte envíos del mismo caso, con un pool de tres conexiones. Cada uno
// tiene que volver con ErrCaseGranted, y al final no puede quedar ninguna tomada.
func TestDuplicateGrantsDoNotDrainThePool(t *testing.T) {
	db, err := storage.Open(context.Background(), os.Getenv("TEST_DATABASE_URL"))
	if err != nil {
		t.Skip("necesita TEST_DATABASE_URL (Postgres): ", err)
	}
	defer db.Close()
	db.SetMaxOpenConns(3)
	db.MustExec(`DELETE FROM grants WHERE case_id = 'C-POOL'`)
	db.MustExec(`INSERT INTO players (id, name, status) VALUES (9001, 'Prueba del pool', 'active') ON CONFLICT (id) DO NOTHING`)

	svc := player.NewService(db, 0)
	g := player.Grant{GrantID: "g-0", PlayerID: 9001, CaseID: "C-POOL", Prize: "vidas-5", Reason: "caída"}
	if _, err := svc.SendGrant(context.Background(), g); err != nil {
		t.Fatal(err)
	}
	for i := 1; i <= 20; i++ {
		done := make(chan error, 1)
		go func() { _, err := svc.SendGrant(context.Background(), g); done <- err }()
		select {
		case err := <-done:
			if !errors.Is(err, player.ErrCaseGranted) {
				t.Fatalf("envío %d: %v", i, err)
			}
		case <-time.After(3 * time.Second):
			t.Fatalf("el envío duplicado %d se colgó: el pool está agotado (en uso: %d)", i, db.Stats().InUse)
		}
	}
	if inUse := db.Stats().InUse; inUse != 0 {
		t.Fatalf("quedaron %d conexiones tomadas", inUse)
	}
}
```

En la rama falla con `el envío duplicado 4 se colgó: el pool está agotado (en uso: 3)`; en `fase-be03-crud-y-el-reemplazo` pasa. Motor: PostgreSQL, contra `esclusa_test`.

**Prevención**

La prueba, la regla de contexto en toda consulta, y `db.Stats()` en el log o en `/health`: un `InUse` que crece y no baja es el aviso que esa noche no hubo.

**Por qué llegó a producción**

Porque la fuga solo existe en un camino —el caso repetido— que las pruebas no recorren, y porque `defer rows.Close()` falta en un bucle que recorre todo y no pasa nada, así que el olvido sobrevive a la revisión hasta el día que alguien agrega un `return` temprano. Y porque el síntoma —todo colgado, reiniciar lo arregla— se parece mucho a "la base estaba lenta".

**Si tu causa fue distinta a esta**

- *"Postgres llegó a `max_connections`"* — se descarta con `pg_stat_activity`: 25 conexiones, no 100, todas de este proceso.
- *"Es la demora de entrega del juego"* — `GRANT_DELIVERY_MS` retiene cada petición 800 ms, pero sin conexión tomada; y los `409` ni siquiera llegan a esperar.
- *"El caos"* — con `CHAOS_LEVEL=off` se reproduce igual.
- Si tu fix fue *"subir `SetMaxOpenConns` a 100"*, compraste setenta y cinco casos repetidos más antes del mismo cuelgue.

</details>

---

## Incidente be-06 — El tablero dice que nadie compró giros

> **Fase:** be03 · **Categoría:** 🔥 contrato · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45-60 min

### 🎫 El ticket

> "Desde el cambio de servidor, el tablero de la Rueda de fin de mes dice
> 10.000 giros, 10.000 gratis y 0 pagos. Pero los ingresos netos dicen 135,60
> dólares, y la tienda nos cobró la comisión de 40 compras. ¿Regalamos todo o
> cobramos? No puedo cerrar el mes con esto."

**Reportado por:** Licda. Marisol De Gracia, contadora
**Ambiente:** desarrollo

### 🎯 Qué se te pide

Determinar de qué lado del cable está la causa y por qué **ninguna prueba la detectó**. Después, el fix y la prueba que faltaba.

### 🔧 Preparación

```bash
git checkout incidente/be-06
cd server && go run ./cmd/seed -file ../mock/db.json && go run ./cmd/api
npm start
```

Abre el tablero y elige la Rueda de fin de mes.

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

El frontend no cambió. Así que si la tarjeta cuenta distinto, lo que cambió es **lo que llega**. Mira el JSON crudo antes de mirar el componente.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```bash
curl -s -H "Authorization: Bearer $TOKEN" 'localhost:3001/spinLog?wheelId=4' | jq '.[0]'
```

Compáralo con lo que devolvía el mock, campo por campo. Fíjate en el **tipo** de cada valor, no solo en si el campo está. Después lee `summarizeSpins` en `dashboardMath.js`.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

En JavaScript, ¿`row.origin === "paid"` es verdadero para `"paid"`? ¿Y para `{"String":"paid","Valid":true}`? ¿Qué rama del `if` toman los dos?

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

El campo `Origin` de `spin.Spin` pasó de `*string` a `sql.NullString`. La historia es verosímil: alguien lo declaró `string`, el primer giro de 2019 —que no tiene origen— hizo fallar el `Scan` con `converting NULL to string is unsupported`, y `sql.NullString` es la forma directa de que un `NULL` entre. Escanea perfecto. Y serializa así:

```json
"origin": {"String": "paid", "Valid": true}
```

`summarizeSpins` cuenta un giro como pago si `row.origin === "paid"`, y un objeto nunca es igual a un texto: **todo** cae en la rama de los gratis. Medido contra la rama: la tarjeta dice *Giros 10000 · 10000 gratis · 0 pagos*, al lado de *Ingresos netos US$135,60*, que salen de otra fuente (el reporte de la tienda). Las filas del giro de 2019, sin origen, salen `{"String":"","Valid":false}`. **No hay un solo error en consola.**

Es el Caso A de la pieza forense de `be03`.

**Parche mínimo**

Volver al puntero con `omitempty`:

```go
Origin *string `json:"origin,omitempty" db:"origin"`
```

`sqlx` lo escanea igual de bien, un `nil` se omite como en el mock y un valor sale como texto.

**La corrección correcta**

La misma, más la prueba que compara **JSON** y no structs, y una regla para los tipos de las respuestas: ningún `sql.NullX` cruza la frontera del contrato. Si una columna es anulable, el campo del struct que se serializa es un puntero.

**Prueba de regresión**

```go
// server/internal/spin/spin_json_test.go

package spin_test

import (
	"encoding/json"
	"strings"
	"testing"

	"github.com/interoceanic-games/esclusa-api/internal/spin"
)

// be-06: el JSON de una fila de la bitácora, comparado como texto. Una prueba
// que compare structs no ve la diferencia; la consola sí.
func TestSpinSerializesLikeTheMock(t *testing.T) {
	var row spin.Spin
	if err := json.Unmarshal([]byte(`{"id":1,"wheelId":4,"playerId":1538,"landedSegment":"sin-premio",
		"deliveredPrize":"sin-premio","origin":"paid","idempotencyKey":"k","createdAt":"2026-08-01T05:00:00.000Z"}`), &row); err != nil {
		t.Fatalf("la fila del mock no entra en spin.Spin: %v", err)
	}
	out, _ := json.Marshal(row)
	if !strings.Contains(string(out), `"origin":"paid"`) {
		t.Fatalf("origin no sale como texto: %s", out)
	}
	var poor spin.Spin // la fila del giro de 2019: sin origen
	out, _ = json.Marshal(poor)
	if strings.Contains(string(out), `"origin"`) {
		t.Fatalf("una fila sin origen no puede traer la clave origin: %s", out)
	}
}
```

En la rama falla antes de llegar a la comparación: `json: cannot unmarshal string into Go struct field Spin.origin of type sql.NullString`, que es la misma incompatibilidad vista desde el otro lado. En la fase, pasa. Motor: ninguno.

**Prevención**

La prueba, la regla de los punteros, y la comparación de lecturas contra el mock que `be03` hizo campo por campo: corrida después de este cambio, la diferencia salta en la primera fila.

**Por qué llegó a producción**

Porque el arreglo del `Scan` **funcionó**: el error desapareció, las pruebas del store pasaron —comparan structs, y el struct tiene el dato—, `curl` devuelve algo que se ve razonable si no sabes qué buscar. Y porque el síntoma vive en una cuenta que nadie revisa hasta fin de mes.

**Si tu causa fue distinta a esta**

- *"La siembra perdió el origen"* — se descarta con `psql`: `SELECT origin, count(*) FROM spin_log WHERE wheel_id = 4 GROUP BY origin` da 7.566 `free` y 2.434 `paid`.
- *"El tablero calcula mal"* — el frontend no cambió, y con el mock la misma tarjeta dice *7566 gratis · 2434 pagos*.
- Si tu fix fue *"comparar `row.origin.String` en la consola"*, tocaste el frontend para adaptarlo a un backend roto: el contrato dice al revés.

</details>

---

## Incidente be-07 — Faltan datos en las conciliaciones

> **Fase:** be03 · **Categoría:** 🔥 contrato · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 60-90 min

### 🎫 El ticket

> "Para el cierre del semestre necesito, por cada rueda conciliada, qué compras
> de la tienda no estaban acreditadas y cuáles se acreditaron dos veces. Eso lo
> veíamos en la pantalla de conciliación el día que se conciliaba. Ahora saco el
> registro de las ruedas conciliadas desde el cambio de servidor, y las dos
> listas están vacías. En agosto había una de cada lado, yo misma las anoté en
> papel. ¿Y ese registro de dónde salió?"

**Reportado por:** Licda. Marisol De Gracia, contadora
**Ambiente:** PROD

### 🎯 Qué se te pide

Determinar qué se perdió, **desde cuándo**, y si es recuperable. Este incidente no termina necesariamente en un fix: parte del entregable es decidir qué se le responde a la contadora.

### 🔧 Preparación

```bash
git checkout incidente/be-07
cd server
psql "$DATABASE_URL" -c 'DROP SCHEMA public CASCADE; CREATE SCHEMA public;'   # base limpia
migrate -path migrations/postgres -database "$DATABASE_URL" up
go run ./cmd/seed -file ../mock/db.json
go run ./cmd/api
# Concilia la Rueda de fin de mes desde la consola, con Network abierto.
```

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

Las dos listas, ¿**salieron** del navegador? Mira el cuerpo del `POST /wheels/4/reconciliation` en Network, no la respuesta.

Si el dato viajó y no está guardado, el problema está del lado del servidor. Y "desde el cambio de servidor" tiene una fecha: ¿qué cambió entonces?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```bash
curl -s -H "Authorization: Bearer $TOKEN" localhost:3001/wheels/4/reconciliation | jq .purchases
psql "$DATABASE_URL" -c '\d reconciliations'
migrate -path migrations/postgres -database "$DATABASE_URL" version
```

Compara las columnas de la tabla con los campos del cuerpo que mandó `reconcileWheel` (Fase 8).

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si un `INSERT` nombra ocho columnas y el cuerpo trae once campos, ¿qué pasa con los otros tres? ¿Falla, avisa, o devuelve `201`?

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

En esta rama la migración `000003_reconciliation_full_shape` no existe —`migrate version` dice `2`— y el `INSERT` de `Reconcile` nombra solo las columnas que la tabla de `be02` tenía. La consola manda `bandAlarms`, `purchases.missingInApi` y `purchases.duplicatedInApi`; el handler los decodifica; el service los ignora al insertar; la respuesta es `201`.

Medido contra la rama, con la conciliación hecha desde la consola: el cuerpo que salió del navegador trae `bandAlarms`, `chi2`, `chi2Alarm`, `counts`, `purchases` y `spins`; la tabla tiene diez columnas y ninguna de las tres listas; y el registro guardado dice `"missingInApi": []` y `"duplicatedInApi": []`. Con la fase y la misma conciliación, el registro dice `"missingInApi": ["tok-ago-31"]` y `"duplicatedInApi": ["tok-ago-17"]`: los dos descuadres de agosto que la contadora anotó en papel.

Es el Caso B de la pieza forense de `be03`.

**Parche mínimo**

Aplicar la migración `000003` y volver a nombrar las tres columnas en el `INSERT`. Eso arregla **de acá en adelante**.

**La corrección correcta, y la respuesta a la contadora**

Lo que se perdió no se recupera desde la base: nunca se guardó. Hay que decirlo así, sin rodeos. Lo que sí se puede hacer es **recalcularlo**: las listas salen de cruzar las compras acreditadas con el reporte de la tienda (Fase 8), y los dos insumos siguen existiendo. Recalcular en el servidor es exactamente lo que hace `be07`; hasta entonces, la contadora puede volver a abrir la pantalla de conciliación, que recalcula en el navegador.

El entregable incluye esa respuesta por escrito: qué se perdió, desde cuándo (la fecha del despliegue que no aplicó la `000003`), qué se puede reconstruir y cómo.

**Prueba de regresión**

Lo que se manda es lo que queda guardado:

```go
// server/internal/reconciliation/shape_test.go

package reconciliation_test

import (
	"context"
	"os"
	"reflect"
	"testing"

	"github.com/interoceanic-games/esclusa-api/internal/reconciliation"
	"github.com/interoceanic-games/esclusa-api/internal/storage"
	"github.com/interoceanic-games/esclusa-api/internal/wheel"
)

// be-07: lo que la consola manda es lo que queda guardado. Los tres campos que
// el INSERT podría olvidar se comparan al volver a leer.
func TestReconciliationKeepsEveryField(t *testing.T) {
	db, err := storage.Open(context.Background(), os.Getenv("TEST_DATABASE_URL"))
	if err != nil {
		t.Skip("necesita TEST_DATABASE_URL (Postgres): ", err)
	}
	defer db.Close()
	db.MustExec(`DELETE FROM reconciliations WHERE wheel_id = 9002`)
	db.MustExec(`DELETE FROM wheels WHERE id = 9002`)
	db.MustExec(`INSERT INTO wheels (id, name, closes_at, status) VALUES (9002, 'Prueba', '2026-08-31T20:00:00-05:00', 'ended')`)
	db.MustExec(`INSERT INTO wheel_versions (wheel_id, version) VALUES (9002, 1)`)

	svc := reconciliation.NewService(db, wheel.NewStore(db))
	sent := reconciliation.Reconciliation{Spins: 3, Counts: []int{1, 1, 1}, BandAlarms: []string{"sin-premio"},
		Purchases: reconciliation.Totals{MissingInAPI: []string{"tok-ago-31"}, DuplicatedInAPI: []string{"tok-ago-17"}}}
	if _, _, err := svc.Reconcile(context.Background(), 9002, sent); err != nil {
		t.Fatal(err)
	}
	got, err := svc.Find(context.Background(), 9002)
	if err != nil {
		t.Fatal(err)
	}
	if !reflect.DeepEqual(got.BandAlarms, sent.BandAlarms) ||
		!reflect.DeepEqual(got.Purchases.MissingInAPI, sent.Purchases.MissingInAPI) ||
		!reflect.DeepEqual(got.Purchases.DuplicatedInAPI, sent.Purchases.DuplicatedInAPI) {
		t.Fatalf("se guardó otra cosa: mandé %+v, leí %+v", sent, got)
	}
}
```

En la rama falla con `se guardó otra cosa`, y la línea muestra las dos listas llenas a la ida y vacías a la vuelta; en la fase, pasa. Motor: PostgreSQL. Toca la base, aunque no las cuatro áreas críticas.

**Prevención**

La prueba, y una regla de despliegue: el binario no arranca si la versión de migraciones de la base es menor que la que el código espera. Es una comprobación de una línea en `main.go`, y es `be09`.

**Por qué llegó a producción**

Porque el fallo **no produce ningún error**. El `201` confirma el éxito, la pantalla muestra la conciliación entera —la calculó el navegador—, y la rueda queda conciliada. El dato se pierde en el momento de guardarse, y el síntoma aparece meses después, cuando alguien pide el registro.

**Si tu causa fue distinta a esta**

- *"La consola no manda las listas"* — se descarta en Network: el cuerpo las trae, con `tok-ago-31` y `tok-ago-17` adentro.
- *"El reporte de la tienda cambió"* — el `3002` devuelve el mismo `GET /earnings`, y la pantalla de conciliación, que lo cruza en el navegador, sigue mostrando los dos descuadres.
- Si tu respuesta a la contadora fue *"los datos están, hay que buscarlos mejor"*, no: no están, y decirlo es parte del trabajo.

</details>

---

## Incidente be-08 — A Yariela la saca de la sesión a las ocho de la noche, y a Itzel nunca

> **Fase:** be04 · **Categoría:** 🔥 autenticación · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 30-45 min

### 🎫 El ticket

> "Desde que cambiaron el login, todos los días a las ocho de la noche la
> consola me manda a la pantalla de entrar, justo cuando cierra la rueda y más
> trabajo hay. Pierdo lo que estaba escribiendo en el asistente. A Itzel no le
> pasa nunca. ¿Es mi computadora?"

**Reportado por:** Yariela, soporte
**Ambiente:** PROD

### 🎯 Qué se te pide

Explicar el patrón —por qué a las ocho, por qué a ella y no a Itzel— con evidencia, y decidir qué se arregla y qué se declara.

### 🔧 Preparación

Ninguna línea de código: la rama `incidente/be-08` sale de `fase-be04-identidad-real-jwt-y-un-cve` sin cambios. Lo que se acorta es el tiempo, para no esperar doce horas:

```bash
git checkout incidente/be-08
cd server && JWT_TTL=3m go run ./cmd/api
```

Entra a la consola, trabaja, y vuelve a hacer clic pasados tres minutos.

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

"Todos los días a la misma hora" y "a una persona sí y a otra no" no son azar: el caos de la Fase 3 reparte sus `401` al azar. Esto tiene reloj. ¿Qué tiene hora en este sistema desde `be04`?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Decodifica la segunda parte del token de Yariela y mira `iat` y `exp`. Después pregúntale a qué hora entra a trabajar, y a Itzel cada cuánto vuelve a iniciar sesión. Y busca el `401` en el log del servidor.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿Cuánto vive un token? ¿Qué hace la consola cuando vence? ¿Y quién lo renueva?

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

El token vive `JWT_TTL`, doce horas por defecto, y **nadie lo renueva**: no hay *refresh token* (`be04` §4.5). Yariela entra a las 8 de la mañana; su token vence a las 8 de la noche, y la primera petición después recibe `401`. El interceptor de la Fase 2 hace lo que tiene que hacer con un `401`: cierra la sesión y manda a `/login`. Itzel cierra sesión y vuelve a entrar después del almuerzo, así que su token vence a medianoche, cuando ya no trabaja.

Medido con la rama y `JWT_TTL=3m`: a los tres minutos y diez segundos, el primer clic termina en `/login`, la sesión guardada desaparece, y el log del servidor dice `401: token inválido o expirado: token is expired by 11.080124218s`. El cliente recibió `Token inválido o expirado`, igual que con un token falsificado: el servidor sabe la diferencia y la consola no.

Que pase justo en el cierre de la rueda es casualidad del horario de Yariela, y por eso duele: es la hora en que más trabajo hay.

**Parche mínimo**

Ninguno de código. El sistema hace lo correcto: un token que expira es una propiedad de seguridad. Lo que sí se puede hacer hoy es operativo: que soporte vuelva a entrar antes del cierre del evento, y que el asistente avise. Decirlo así es parte de la respuesta.

**La corrección correcta**

El *refresh token*, que exige tocar el frontend más allá de `authService.js` y por eso el track decidió no hacerlo (`D27`, `be04` ejercicio 31). La deuda 💸 está viva en `bea-09`, con su motivo y con este síntoma escrito tal cual: *"al vencer el token, el operador pierde lo que estuviera haciendo"*.

**Prueba de regresión**

No hay regresión que probar: no se arregló nada. Lo que sí existe es la prueba de que un token vencido se rechaza (`be08`), que es la propiedad que este incidente **no** debe romper. Si alguien "arregla" el ticket alargando `JWT_TTL` a un mes, esa prueba sigue pasando y el riesgo cambia de lugar: un token robado sirve un mes.

**Prevención**

Que la decisión esté escrita donde la busca quien recibe el ticket: el mapa de deuda, y el `JWT_TTL` documentado en la configuración con su consecuencia. Y medir cuántos `401` por vencimiento hay por día, que es lo que diría si la deuda empezó a costar.

**Por qué llegó a producción**

Porque **no es un error**: es una decisión de alcance con un síntoma que nadie escribió en lenguaje de operador. "El token dura doce horas" no dice "te va a sacar a las ocho de la noche".

**Si tu causa fue distinta a esta**

- *"Es el caos del 401"* — se descarta con `CHAOS_LEVEL=off` y con el patrón: el caos no tiene hora.
- *"La computadora de Yariela tiene la hora mal"* — el `exp` lo verifica el servidor contra su reloj, no contra el del navegador.
- Si tu fix fue *"guardar la contraseña en el navegador y volver a entrar sola"*, cambiaste un problema de experiencia por uno de seguridad.

</details>

---

## Incidente be-09 ⭐ — Otra vez más Esclusas de Oro que stock, y el contador dice que sobran

> **Fase:** be05 · **Categoría:** 🔥 concurrencia · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 90-120 min
> ⭐ **Uno de los dos más formativos del track** · Hermano del incidente **11** del track base, con otra causa raíz

### 🎫 El ticket

> "Volvimos a sacar la Esclusa de Oro, otra vez mil, y a la hora de la
> notificación pasó lo de 2025. En el Discord hay muchas más capturas del avatar
> de las que puede haber, y la gente ya está preguntando. Lo raro es que el
> contador de la consola dice que todavía quedan casi novecientas. ¿Entregamos de
> más o no? Y si sí, ¿cómo es que sobran?"

**Reportado por:** Itzel, operación
**Ambiente:** PROD

### 🎯 Qué se te pide

Determinar cuántas Esclusas se entregaron de verdad, por qué el contador no lo refleja, y qué cambió desde `be05`, donde esto estaba resuelto. Después, el fix, y la respuesta a una pregunta incómoda: **la prueba que debía atraparlo existe; ¿por qué no lo atrapó?**

### 🔧 Preparación

```bash
git checkout incidente/be-09
cd server
migrate -path migrations/postgres -database "$DATABASE_URL" drop -f
migrate -path migrations/postgres -database "$DATABASE_URL" up
go run ./cmd/seed -file ../mock/db.json
psql "$DATABASE_URL" < load/rueda-de-medicion.sql
go run ./cmd/api
```

Y en otra terminal, la noche de la notificación (`bea-11` si nunca usaste k6):

```bash
docker run --rm -i --network <red-del-backend> -e BASE_URL=http://api:3001 \
  -e SCENARIO=notificacion -e VUS=200 grafana/k6:1.5.0 run - < load/giro.js
```

**Caos:** `off`. Acá estorba: un `500` aleatorio se confunde con lo que buscas.

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

La consola no gira: gira el juego. Y el ticket trae **dos números que no pueden ser verdad a la vez**: más ganadores que stock, y stock que sobra. Uno de los dos miente. ¿Cuál de las dos fuentes es un hecho y cuál es un estado?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```bash
psql "$DATABASE_URL" < load/medicion.sql
git log --oneline fase-be05-giro-concurrente..HEAD -- internal/spin/
TEST_DATABASE_URL="…/esclusa_test" go test -race -run Stock -v ./internal/spin/
```

Lee el diff del último commit con la Fase 5 del track base al lado. Y después corre la carga con `SCENARIO=pico -e RATE=50`.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Dos transacciones leen `remaining = 5` a la vez y escriben las dos `4`. ¿Cuántas Esclusas se entregaron? ¿Cuántas descontó el contador?

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

Un commit de optimización en `takeStock`, con un motivo que suena razonable y que las mediciones de `be05` respaldan a medias: *"sin FOR UPDATE: bloqueaba, y bajo carga el p95 subía"*. El commit hizo dos cosas a la vez:

```diff
 		var remaining int
 		err = tx.GetContext(ctx, &remaining, tx.Rebind(`
-			SELECT remaining FROM stock WHERE id = ?`+s.db.ForUpdate()), stockID)
+			SELECT remaining FROM stock WHERE id = ?`), stockID)
 …
-				UPDATE stock SET remaining = remaining - 1 WHERE id = ?`), stockID); err != nil {
+				UPDATE stock SET remaining = ? WHERE id = ?`), remaining-1, stockID); err != nil {
```

Quitar el `FOR UPDATE` deja el *check-then-act* de 2019 **dentro de una transacción**, que en `READ COMMITTED` no excluye a nadie (`be05` §4.2). Y escribir el valor calculado en Go en vez de `remaining - 1` convierte cada choque en una **actualización perdida**: dos giros leen `5`, entregan los dos, y los dos escriben `4`. El contador baja una vez por cada choque, no una por cada Esclusa.

Medido contra la rama, con la rueda de medición (1.000 de stock, 1.500 giros):

| Carga | Esclusas entregadas | Stock que dice el contador |
|---|---|---|
| `pico`, 50 por segundo | 1.000 | 0 |
| `notificacion`, 50 jugadores | 1.500 | 874 |
| `notificacion`, 200 jugadores | 1.500 | 904 |

Con la notificación, **todos** los giros se llevaron la Esclusa y el contador quedó en casi novecientas: la evidencia del exceso se borró a sí misma. Es la cifra del ticket. Y a 50 por segundo parejos, el ritmo del pico de 2025, la rama da **exactamente** bien.

**Parche mínimo**

Revertir el commit: el `FOR UPDATE` antes de decidir, y el descuento relativo (`remaining = remaining - 1`). Con eso, la misma carga da 1.000 Esclusas, 500 sustitutos y stock en 0.

**La corrección correcta**

El parche, más que la prueba de concurrencia corra **contra Postgres** en el pipeline (`be08`), y que la medición con k6 use la forma de la noche, no llegadas parejas. Si el p95 de verdad molesta, la respuesta medida es la escritura condicional de `be05` (`UPDATE … WHERE remaining > 0`), no quitar el bloqueo.

**Prueba de regresión**

**Ya existía**, en `server/internal/spin/race_test.go`:

```go
// Carrera 3: mil quinientos giros contra un stock de mil. Mil Esclusas de Oro
// y quinientos sustitutos, ni una más.
func TestStockNeverExceeded(t *testing.T) {
	for _, locking := range strategies {
		t.Run(string(locking), func(t *testing.T) {
			db := openPostgres(t)
			measurementWheel(t, db, 1000, 300, 5)
			svc := spin.NewService(db, locking, 0, 30*time.Second)

			errs := race(1500, func(i int) error {
				_, err := svc.Spin(context.Background(), int64(i%300+1), fmt.Sprintf("stock-%d", i))
				return err
			})
			got := count(errs)
			var golden, substitutes, remaining int
			db.Get(&golden, `SELECT count(*) FROM spin_log WHERE delivered_prize = 'esclusa-de-oro'`)
			db.Get(&substitutes, `SELECT count(*) FROM spin_log WHERE delivered_prize = 'set-gemas-plata'`)
			db.Get(&remaining, `SELECT remaining FROM stock WHERE wheel_id = 900`)
			if got["ok"] != 1500 || golden != 1000 || substitutes != 500 || remaining != 0 {
				t.Fatalf("%v · entregadas %d, sustitutos %d, stock %d (esperado 1000, 500, 0)", got, golden, substitutes, remaining)
			}
			t.Logf("%s: %v · entregadas %d · sustitutos %d · stock %d", locking, got, golden, substitutes, remaining)
		})
	}
}
```

Contra Postgres, en la rama falla la estrategia pesimista con *"entregadas 1500, sustitutos 0, stock 916"* (918 y 919 en otras corridas) y la condicional pasa; en la fase pasan las dos. Motor: PostgreSQL, contra `esclusa_test`.

**Prevención**

La prueba ya estaba. Lo que faltaba es que **corriera**: sin `TEST_DATABASE_URL`, las carreras hacen `t.Skip` y `go test ./...` sale verde en 0,003 s. Y si alguien la apunta a SQLite, también sale verde: medido, la rama de este incidente da 1.000 entregadas y stock en 0 contra SQLite, porque su pool de una conexión serializa todo. La prevención es la regla del motor de `be08` en el pipeline, y una línea en la revisión de código: **un cambio que quita un bloqueo trae su prueba de concurrencia corrida contra Postgres, y su medición con la forma de la noche.**

**Por qué llegó a producción**

Porque **todo lo que se miró dio bien**. La suite local pasó (las carreras se saltaron). El autor del commit midió con k6 a ritmo parejo y el stock salió exacto, con mejor p95. La revisión vio una simplificación con un número que la respaldaba. Y el contador de la consola, que es lo que operación mira, dice que sobran.

**Si tu causa fue distinta a esta**

- *"El juego mandó claves repetidas"* — se descarta con `medicion.sql`: cero claves con dos giros. La clave repetida está resuelta, y no es esto.
- *"El stock inicial estaba mal cargado"* — se descarta con la bitácora: 1.500 filas con la Esclusa entregada, y el stock sembrado en 1.000.
- *"Es el caos"* — con `CHAOS_LEVEL=off` se reproduce igual.
- Si tu fix fue *"un `CHECK (remaining >= 0)` en la tabla"*: no alcanza. Con actualizaciones perdidas el contador nunca llega a negativo; acá quedó en 904.

</details>

---

## Incidente be-10 — Un giro quedó "en proceso" para siempre

> **Fase:** be05 · **Categoría:** 🔥 concurrencia · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45-60 min

### 🎫 El ticket

> "Un jugador escribe que tocó girar, la rueda empezó a girar y la app se
> cerró. Ahora, cada vez que entra, le sale 'giro en proceso' y no puede volver
> a girar, y el giro ya se le descontó. Le dije que esperara. Ya pasaron dos días.
> Ese día hubo un reinicio del servidor a media tarde."

**Reportado por:** Yariela, soporte
**Ambiente:** PROD

### 🎯 Qué se te pide

Explicar por qué el giro no se cierra solo, por qué la consulta del runbook no lo encuentra, y qué hay que hacer con **este** jugador además de arreglar el código.

### 🔧 Preparación

```bash
git checkout incidente/be-10
cd server && go build -o /tmp/api ./cmd/api
psql "$DATABASE_URL" -c "UPDATE players SET free_spins = 5 WHERE id = 42"
SPIN_DELIVERY_MS=5000 /tmp/api &
curl -s -X POST -d '{"idempotencyKey":"corte-1"}' localhost:3001/players/42/spins &
sleep 2; kill -9 %1          # el reinicio de media tarde, durante la entrega
SPIN_DELIVERY_MS=5000 /tmp/api &
curl -s -X POST -d '{"idempotencyKey":"corte-1"}' localhost:3001/players/42/spins
```

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

La app del jugador reintenta con la misma clave: eso está bien, es para lo que la clave existe. El que contesta "en proceso" es el servidor. ¿Quién, en el servidor, tendría que haber dicho "este ya no está en proceso"?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```sql
SELECT * FROM spin_requests WHERE idempotency_key = 'corte-1';
SELECT * FROM spin_log WHERE idempotency_key = 'corte-1';
SELECT count(*) FROM spin_requests WHERE status = 'processing' AND processing_until < now();
```

Y busca `[barrido]` en el log, después de un minuto.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

`NULL < now()` no es ni verdadero ni falso. ¿Y qué pasa con una fila que ninguna consulta encuentra, si además nadie la busca?

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

Dos faltas juntas, y las dos importan. El giro se decide en una transacción y se entrega en el juego fuera de ella (`be05` §4.4); entre las dos cosas, el pedido está en `processing` con una fecha límite. Esta rama cambió las dos mitades del mecanismo que lo cierra:

```diff
-		until := time.Now().UTC().Add(s.processing)
+		// El juego reintenta cuando quiera; el pedido no necesita fecha límite. 💸
 …
-			VALUES (?, ?, 'processing', ?)
+			VALUES (?, ?, 'processing', NULL)
```

```diff
-	sweepCtx, stopSweep := context.WithCancel(context.Background())
-	defer stopSweep()
-	go spins.RunSweeper(sweepCtx, cfg.SpinSweepEvery)
```

Sin fecha límite, `repeated` nunca considera vencido el pedido y responde `409 giro en proceso` para siempre. Sin barrido, nadie lo cierra. Y la consulta obvia del runbook, `WHERE processing_until < now()`, **no encuentra nada**, porque `NULL < now()` es `NULL`: ese es el hallazgo dentro del hallazgo.

Medido con el binario, la entrega en 5 s y `kill -9` a los 2 s: el pedido queda `processing|NULL`, la bitácora tiene **una** fila y el saldo bajó de 5 a 4. Al reiniciar, `409 giro en proceso`; a los 40 s, la consulta del runbook devuelve 0 filas, el reintento sigue en `409`, y el log no tiene ninguna línea `[barrido]`. Con la fase, la misma secuencia termina distinto: el barrido cierra el pedido 8 s después de su vencimiento (`[barrido] 1 giros en proceso vencidos, entregados y cerrados`) y el reintento devuelve `200` con **el mismo premio** que había salido antes del corte.

**Parche mínimo**

Restaurar la fecha límite y el arranque del barrido. Con eso, los pedidos nuevos se cierran solos.

**La corrección correcta, y el jugador**

El parche no toca los pedidos que ya están colgados con `processing_until` en `NULL`: el barrido tampoco los ve. Hay que encontrarlos con la consulta correcta y darles una fecha que ya pasó, para que el barrido haga su trabajo —entregar lo que dice la bitácora— en su próxima vuelta:

```sql
UPDATE spin_requests SET processing_until = now()
WHERE status = 'processing' AND processing_until IS NULL;
```

Nunca a mano, con un `INSERT` en el inventario o devolviendo el saldo: el giro **ya salió**, está en la bitácora, y lo correcto es entregar ese, no otro. Y la deuda que queda declarada: una columna que la lógica necesita no nula y la tabla admite nula.

**Prueba de regresión**

```go
// server/internal/spin/processing_test.go

package spin_test

import (
	"context"
	"testing"
	"time"

	"github.com/interoceanic-games/esclusa-api/internal/spin"
)

// be-10: el proceso muere entre decidir y entregar. Pasado el plazo, la misma
// clave tiene que devolver el giro que ya salió, y el barrido tiene que poder
// encontrarlo con la consulta del runbook.
func TestSpinCutDuringDeliveryRecovers(t *testing.T) {
	db := openPostgres(t)
	measurementWheel(t, db, 1000, 1, 5)
	svc := spin.NewService(db, spin.Pessimistic, time.Hour, 200*time.Millisecond)

	// El corte: el contexto se cancela mientras el juego "recibe" el premio.
	ctx, cut := context.WithTimeout(context.Background(), 50*time.Millisecond)
	defer cut()
	if _, err := svc.Spin(ctx, 1, "corte"); err == nil {
		t.Fatal("la entrega no se cortó")
	}

	time.Sleep(300 * time.Millisecond) // vence processing_until
	var stuck int
	db.Get(&stuck, `SELECT count(*) FROM spin_requests WHERE status = 'processing' AND processing_until < now()`)
	if stuck != 1 {
		t.Fatalf("el runbook no encuentra el giro colgado: %d filas", stuck)
	}

	retry := spin.NewService(db, spin.Pessimistic, 0, 200*time.Millisecond)
	r, err := retry.Spin(context.Background(), 1, "corte")
	if err != nil {
		t.Fatalf("la misma clave, pasado el plazo: %v", err)
	}
	var rows int
	db.Get(&rows, `SELECT count(*) FROM spin_log WHERE idempotency_key = 'corte'`)
	if rows != 1 || r.LandedSegment != "esclusa-de-oro" {
		t.Fatalf("el reintento giró otra vez o devolvió otra cosa: %d filas, %+v", rows, r)
	}
}
```

En la rama falla con *"el runbook no encuentra el giro colgado: 0 filas"*; en la fase, pasa. Usa los ayudantes de `race_test.go` (`openPostgres`, `measurementWheel`). Motor: PostgreSQL.

**Prevención**

La prueba, un `CHECK ((status = 'processing') = (processing_until IS NOT NULL))` en la tabla, y en el runbook la consulta que no depende de la fecha: *"pedidos en `processing` creados hace más de N minutos"*, por `created_at`.

**Por qué llegó a producción**

Porque el camino feliz no pasa por ahí. Sin cortes, el pedido se cierra en la misma petición y nadie extraña al barrido. Hace falta que el proceso muera **durante** la entrega, y eso pasa un día de despliegue a media tarde, con un solo jugador afectado que escribe a soporte dos días después.

**Si tu causa fue distinta a esta**

- *"El juego reintenta mal"* — reintenta con la misma clave, que es lo correcto; con una clave nueva giraría otra vez y el jugador tendría dos giros por un toque.
- *"La transacción quedó abierta"* — se descarta en `pg_stat_activity`: nada en `idle in transaction`. La transacción confirmó; lo que quedó abierto es el **pedido**, que es otra cosa.
- Si tu fix fue *"borrar la fila de `spin_requests`"*: el reintento gira **de nuevo**, con un sorteo nuevo. El jugador se queda con un giro que no recibió y otro que sí, y la bitácora tiene dos hechos para un toque.

</details>

---

## Incidente be-11 — A los jugadores de Chile la rueda les cierra una hora antes

> **Fase:** be06 · **Categoría:** 🔥 tiempo · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45-60 min
> · Termina en diagnóstico y decisión, no en un commit

### 🎫 El ticket

> "Varios jugadores de Chile dicen que la rueda se les cierra una hora antes que
> a todo el mundo. Y hoy me pasó a mí en la consola: el giro de la Esclusa de
> Oro me sale '(cerrada)' y todavía faltan treinta minutos. ¿Es el horario de
> verano de Chile?"

**Reportado por:** Yariela, soporte
**Ambiente:** PROD

### 🎯 Qué se te pide

Evaluar la teoría del ticket —el ticket trae una, como casi siempre—, encontrar la causa real, y decidir **qué se puede arreglar y qué no**. Este incidente termina en una conversación, no en un commit.

### 🔧 Preparación

Sin rama: el incidente vive en `fase-be06-hora-dura-y-la-autoridad-del-reloj`, con la consola y el binario en el `3001`.

```bash
git checkout fase-be06-hora-dura-y-la-autoridad-del-reloj
psql "$DATABASE_URL" -c "UPDATE wheels SET closes_at = now() + interval '30 minutes' WHERE id = 1"
# La máquina afectada: adelanta el reloj del sistema una hora (desactiva la
# sincronización automática). Después abre la consola y ve a Envíos.
# Al terminar, el reloj en automático y:
# psql "$DATABASE_URL" -c "UPDATE wheels SET closes_at = '2030-12-31T20:00:00-05:00' WHERE id = 1"
```

⚠️ Poner `TZ` no reproduce este incidente: `isWheelClosed` compara instantes, y una comparación de instantes no depende de la zona. Confundir zona con hora es justamente la teoría del ticket.

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

Empieza por la teoría del ticket, porque descartarla es rápido. ¿Qué guarda el servidor del cierre, un instante o una hora local? ¿Y qué compara la consola?

Descartada esa, queda la pregunta interesante: ¿con qué reloj se decide en cada lado?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

En la máquina afectada, en la consola del navegador:

```javascript
new Date().toISOString()
```

Y en cualquier respuesta del `3001`, en Network, el header `X-Server-Time`. Después manda el mismo giro con `curl`, desde una máquina con la hora bien.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si el servidor dice que faltan treinta minutos y el navegador dice que ya pasó, ¿quién está equivocado? ¿Y qué se puede arreglar sin tocar la consola?

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

**Tu decisión**

---

<details>
<summary>✅ <b>Solución de referencia</b></summary>

**Lo que se ve**

La rueda 1 cierra a las 03:40 UTC. Con el navegador una hora adelante, la consola ve las 04:11 y el servidor, las 03:11:

```json
{ "status": 201, "serverTime": "2026-10-20T03:11:14.428Z", "consoleNow": "2026-10-20T04:11:12.853Z" }
```

En el asistente de envíos, la opción *Giro en Esclusa de Oro (cerrada)* está deshabilitada. El mismo envío, mandado con `curl` al servidor, responde **`201`** y queda anotado (`C-BE11 spin:1`). Los dos lados aplican la misma regla —`now >= closesAt`— con relojes distintos.

**Causa raíz**

El reloj de la máquina, adelantado una hora. No hay ningún componente roto: el servidor decide bien, la consola calcula bien con el dato que tiene, y el dato que tiene está mal por causas ajenas al software. Para los jugadores es lo mismo con el reloj del celular. El juego cuenta con su propio reloj cuánto falta, y un celular con la hora puesta a mano, o con una base de zonas vieja, cuenta mal. Una base de zonas vieja hace lo mismo con una ley nueva: la imagen de Go del laboratorio, con la base 2023c, todavía pone a Asunción en `-04` en julio de 2025, una hora antes de la que rige desde que Paraguay dejó el horario de verano (`be06` §4.2).

**Por qué no es el horario de verano**

El cierre es un instante (`TIMESTAMPTZ`, `be06` §4.1), y Santiago cambiando de `-04` a `-03` no mueve ningún instante. Si el horario de verano fuera la causa, les pasaría a todos los jugadores de Chile el mismo día y a ninguno de Panamá. Y Yariela, en Panamá, lo vio en su consola.

**La asimetría que hay que entender y explicar**

Con el reloj **adelantado**, la consola cierra antes, y el jugador o la operadora **pierden un giro legítimo**: molesto. Con el reloj **atrasado**, la consola ofrece el giro y el servidor lo rechaza con `409`: mensaje confuso, **datos correctos**. Antes de `be06`, el segundo caso anotaba un envío de una rueda cerrada. **Una interfaz confusa es un problema; una base de datos mentirosa es un incidente.**

**La corrección correcta**

Que la consola deje de mirar su propio reloj: un interceptor que guarde el desfase contra `X-Server-Time` y un `serverNow()` en `closing.js`. La mitad del servidor **ya está hecha**; la de la consola choca con la regla del track y con `D27` (`be06` §5.6). Y el juego pinta la cuenta regresiva con `nextFreeSpinAt` y el `closesAt` del servidor, restando el desfase que mida: eso es del equipo de Carlos.

⚠️ Medir el desfase como *hora del servidor − hora local* incluye la latencia de la red. Corregirla —descontar la mitad de la ida y vuelta— es media implementación de NTP.

**Prueba de regresión**

No hay bug del backend que probar. Lo que sí se prueba es que **el servidor no depende del reloj del cliente**, que es lo que acota el daño: `TestClientClockDoesNotGrantFreeSpins` (incidente `be-18`) y la tabla de bordes de `be06` §5.5. Motor: PostgreSQL.

**Prevención**

1. **El desfase, medido.** Una métrica agregada de cuántas consolas y cuántos celulares tienen la hora corrida y cuánto (`be06`, ejercicio 23). Es el número que decidiría si vale la pena pagar la deuda del `serverNow`.
2. **La sincronización automática en las máquinas del estudio.** Es la prevención real, y no es técnica: es de operación.

**Por qué llegó a producción**

Porque **el sistema funciona correctamente** y aun así alguien pierde un giro. Es el tipo de incidente donde *"no es un bug"* es técnicamente cierto y operativamente inútil. Lo que faltaba era no depender de un dato que no controlamos, y esa dependencia estaba declarada como deuda desde la Fase 7.

**Si tu causa fue distinta a esta**

- *"Es el horario de verano de Chile"*: es **la hipótesis correcta de formular**, porque es lo primero que hay que descartar. Se cae con dos datos: el cierre es un instante, y la operadora que lo vio está en Panamá.
- *"El servidor cierra antes de tiempo"*: se descarta con `curl` desde una máquina con la hora bien. El servidor sigue aceptando.
- *"El barrido pasó la rueda a `ended` antes"*: es buena hipótesis, y se descarta mirando `status` y `closes_at` en la base.
- Si tu fix fue **restar una hora en la consola**, arreglaste esa máquina y rompiste todas las demás.

</details>

---

## Incidente be-12 — Giros anotados después del cierre

> **Fase:** be06 · **Categoría:** 🔥 tiempo · **Dificultad:** 🟢
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 30-45 min

### 🎫 El ticket

> "Concilié la rueda de anoche y en la bitácora hay giros con hora de después
> del cierre. No muchos, pero hay. ¿No era que ahora eso lo controlaba el
> servidor?"

**Reportado por:** Itzel, live-ops
**Ambiente:** PROD

### 🎯 Qué se te pide

Encontrar por qué el servidor deja girar después del cierre, cuantificar cuántos giros, y explicar por qué el número cambia de una noche a otra.

### 🔧 Preparación

```bash
git checkout incidente/be-12
cd server && go build -o /tmp/api ./cmd/api && /tmp/api &
psql "$DATABASE_URL" -f load/rueda-de-medicion.sql
# La rueda de medición cierra a los 5 s de empezar la carga:
psql "$DATABASE_URL" -c "UPDATE wheels SET closes_at = now() + interval '5 seconds' WHERE id = 900"
docker run --rm -i --network <red-del-backend> -e BASE_URL=http://api:3001 -e RATE=50 -e KEYS=750 \
  grafana/k6:1.5.0 run - < load/giro.js
```

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

El juego no sabe cuándo cierra la rueda: gira cuando el jugador toca. El que tiene que decir *"ya cerró"* es el servidor. ¿Qué mira el servidor para saber si la rueda está abierta?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```sql
SELECT count(*) FILTER (WHERE l.created_at <  w.closes_at) AS antes,
       count(*) FILTER (WHERE l.created_at >= w.closes_at) AS despues
FROM spin_log l JOIN wheels w ON w.id = l.wheel_id WHERE l.wheel_id = 900 GROUP BY w.closes_at;
```

Y en el log, la línea `[cierre]`: ¿a qué hora cerró la rueda el barrido?

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Corre la carga tres veces y compara el número de *después*. Si cambia mucho, ¿de qué depende? ¿Cada cuánto pasa el barrido?

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

**Lo que se ve**

Tres corridas de k6 a 50 giros por segundo, con la rueda 900 cerrando a los 5 segundos y el barrido cada 10:

```text
giros de la 900 antes del cierre: 117 · después: 108 · el último, 4.30 s después
giros de la 900 antes del cierre: 117 · después: 61 · el último, 2.40 s después
giros de la 900 antes del cierre: 117 · después: 5 · el último, 0.18 s después
```

Con `fase-be06-…`, la misma carga: `después: 0`. Los giros de después del cierre fueron a la otra rueda abierta.

**Causa raíz**

El giro elige la rueda por su estado, y confía en que el barrido la pase a `ended` a tiempo:

```diff
 	for _, w := range wheels {
-		// Instantes con Before, nunca componentes de fecha ni ==. En el
-		// instante exacto del cierre la rueda ya está cerrada: el mismo borde
-		// que isWheelClosed de la Fase 7 (now >= closesAt).
-		if !now.Before(w.ClosesAt) {
-			continue
-		}
+		// El barrido de cierre ya pasa las ruedas vencidas a ended: si dice
+		// live, está abierta.
```

Entre el instante del cierre y la próxima vuelta del barrido, la rueda dice `live` y gira. Esa ventana dura entre 0 y `WHEEL_CLOSE_EVERY`, según en qué momento del ciclo cae el cierre: por eso 108, 61 y 5. El peor caso, a 50 giros por segundo y con el barrido cada 10 s, son unos 500.

**Parche mínimo**

Volver a poner la comparación con el reloj dentro de `liveWheel`. Es la que tiene `be06` §5.3.

**Prueba de regresión**

`TestSpinRespectsClosing`, que ya está en `server/internal/spin/clock_test.go`. En la rama falla en los tres casos de después del cierre:

```text
clock_test.go:49: con ahora=2030-01-01T00:00:00Z: esperaba no hay rueda activa, obtuve <nil>
clock_test.go:49: con ahora=2030-01-01T00:00:00.001Z: esperaba no hay rueda activa, obtuve <nil>
clock_test.go:49: con ahora=2029-12-31T19:00:00-05:00: esperaba no hay rueda activa, obtuve <nil>
--- FAIL: TestSpinRespectsClosing (0.61s)
```

En la fase, pasa. Motor: PostgreSQL.

**Prevención**

La regla de `be06`, escrita como regla: **el barrido mantiene el estado al día; la decisión la toma el reloj, dentro de la transacción**. Y en la conciliación, la consulta de la Pista 2 como alarma: cualquier giro con `created_at >= closes_at` es un incidente.

**Por qué llegó a producción**

Porque el barrido funcionaba. Las ruedas pasaban a `ended` solas, la consola las mostraba cerradas, y nadie miró qué pasaba en los segundos entre el cierre y la vuelta del barrido. Con poca carga, cinco giros en una noche no se ven; con la carga de un cierre de evento, son cien.

**Si tu causa fue distinta a esta**

- *"El reloj del servidor está atrasado"*: se descarta con `X-Server-Time` contra `date -u`, y porque el número cambia entre corridas con el mismo reloj.
- *"El juego manda giros viejos que llegan tarde"*: el `created_at` lo pone la base al anotar; un giro que llega tarde se anota tarde y se tendría que rechazar igual.
- Si tu fix fue *"correr el barrido cada segundo"*, achicaste la ventana sin cerrarla, y pagaste una consulta por segundo para eso.

</details>

---

## Incidente be-13 — La conciliación y el reporte de la tienda no dan lo mismo

> **Fase:** be07 · **Categoría:** 🔥 dinero · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45-60 min

### 🎫 El ticket

> "La conciliación de la Rueda de fin de mes dice que a la API le falta acreditar
> una compra, la tok-ago-31. Pero esa compra está acreditada: el jugador tiene sus
> giros y Yariela lo confirmó ayer. ¿Cuál de los dos números le mando a los
> socios?"

**Reportado por:** Marisol, contabilidad
**Ambiente:** PROD

### 🎯 Qué se te pide

Explicar cómo una conciliación guardada puede decir algo que ya no era cierto cuando se guardó, y corregirlo de forma que no dependa de cuándo cada quien abrió la pantalla.

### 🔧 Preparación

```bash
git checkout incidente/be-13
cd server && go build -o /tmp/api ./cmd/api && /tmp/api &
npm run mock:googleplay & npm start
```

Con la sesión de Marisol (`mdegracia`), abre *Conciliación* y elige la Rueda de fin de mes: `tok-ago-31` aparece como cobrada por la tienda y no acreditada. **Sin cerrar la pantalla**, en otra terminal, la tienda confirma el pago y el juego avisa:

```bash
curl -s -X POST -H 'Content-Type: application/json' -d '{"purchaseToken":"tok-ago-31","method":"card"}' localhost:3002/purchases
curl -s -X POST -H 'Content-Type: application/json' -d '{"purchaseToken":"tok-ago-31","productId":"spins-10"}' localhost:3001/players/42/purchases
```

Después aprieta *Conciliar rueda*.

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

La compra está acreditada en la base: `SELECT * FROM purchases WHERE purchase_token = 'tok-ago-31'`. La conciliación guardada dice que no. ¿Quién calculó la conciliación, y con qué datos?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

En Network, el cuerpo del `POST /wheels/4/reconciliation`. Compáralo con `GET /purchases` en este momento. Y busca en el log del backend alguna línea sobre esa conciliación.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿Cuándo pidió la consola las compras? ¿Y cuándo se acreditó `tok-ago-31`?

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

**Lo que se ve**

Lo guardado en la rama, con `GET /wheels/4/reconciliation`:

```json
{"chargedCents":15960,"feeCents":2400,"netCents":13560,"missingInApi":["tok-ago-31"],"duplicatedInApi":["tok-ago-17"]}
```

Y `tok-ago-31` acreditada en `purchases` desde antes de conciliar. Con la fase, la misma secuencia guarda `missingInApi: []`, y el log dice:

```text
[req-id b1af1ff9de301f25] la conciliación de la rueda 4 que mandó la consola difiere de la del servidor: missingInApi: consola [tok-ago-31], servidor []
```

**Causa raíz**

El servidor guarda la conciliación que calculó la consola:

```diff
-	r, err := s.Recalculate(ctx, wheelID)
-	if err != nil {
-		return wheel.Wheel{}, Reconciliation{}, nil, err
-	}
-	diffs := differences(client, r)
-	w, saved, err := s.record(ctx, wheelID, r)
-	return w, saved, diffs, err
+	// La consola ya hizo la cuenta, con las mismas funciones de la Fase 8 que el
+	// servidor tiene portadas: recalcular sería hacer dos veces lo mismo.
+	w, saved, err := s.record(ctx, wheelID, client)
+	return w, saved, nil, err
```

El argumento del commit es cierto a medias. Las funciones son las mismas —sobre la bitácora sembrada, la consola y el servidor dan lo mismo campo por campo (`be07` §5.6)—, pero **los datos no**. La consola pidió `GET /purchases` cuando Marisol abrió la pantalla, y no recargó antes de conciliar. La compra se acreditó en el medio. La consola no mintió: no tenía los datos.

**Parche mínimo**

Volver a recalcular en el servidor, como en `be07` §5.6. Y la conciliación que ya se guardó mal no se edita: se anota. La rueda está en `reconciled`, y lo correcto es una conciliación nueva como hecho, con su fecha, y la vieja como historia (ejercicio 27 de `be07`).

**Prueba de regresión**

```go
// server/internal/reconciliation/stale_client_test.go (extracto)

	// Lo que la consola cargó antes de que tok-ago-31 se acreditara.
	stale := reconciliation.Reconciliation{Purchases: reconciliation.Totals{ChargedCents: 198, FeeCents: 30, NetCents: 168,
		MissingInAPI: []string{"tok-ago-31"}, DuplicatedInAPI: []string{}}}
	svc := reconciliation.NewService(db, wheel.NewStore(db), report)
	if _, _, _, err := svc.Reconcile(context.Background(), 4, stale); err != nil {
		t.Fatal(err)
	}
	saved, err := svc.Find(context.Background(), 4)
	…
	if len(saved.Purchases.MissingInAPI) != 0 {
		t.Fatalf("la conciliación guardó como faltante una compra acreditada: %v", saved.Purchases.MissingInAPI)
	}
```

La prueba arma una rueda terminada, dos compras acreditadas y un reporte de la tienda falso con las dos, y concilia con el cuerpo viejo. En la rama falla con *"la conciliación guardó como faltante una compra acreditada: [tok-ago-31]"*; en la fase, pasa. Motor: PostgreSQL.

**Prevención**

**El dinero no se valida: se recalcula** (`be07` §4.2). Y la diferencia, al log, con el `X-Request-Id`: es la línea que le contesta a Marisol en dos minutos.

**Por qué llegó a producción**

Porque casi siempre da igual. La conciliación se hace con la rueda cerrada, y la bitácora de una rueda cerrada ya no cambia. Lo que sí cambia son las compras: un pago en efectivo tarda hasta 48 horas en confirmarse (historia §8), y alguien concilia en el medio.

**Si tu causa fue distinta a esta**

- *"La tienda reportó mal"*: el reporte de la tienda tiene `tok-ago-31`, y la consola también la ve cobrada. El que se quedó atrás es el lado de la API, en la foto de la consola.
- *"La compra se acreditó dos veces"*: `SELECT count(*) FROM purchases WHERE purchase_token = 'tok-ago-31' AND duplicate_of IS NULL` da 1. Eso es el `be-14`.
- Si tu fix fue *"que la consola recargue antes de conciliar"*, achicaste la ventana sin cerrarla, y tocaste el frontend.

</details>

---

## Incidente be-14 — Acreditamos la compra dos veces

> **Fase:** be07 · **Categoría:** 🔥 transacciones · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45-60 min

### 🎫 El ticket

> "Una jugadora compró dos paquetes de 10 y tiene 60 giros pagos. No se queja,
> claro. Pero en la consola hay dos compras, no seis, y en el log del API hay
> errores de 'duplicate key' de esa misma tarde."

**Reportado por:** Yariela, soporte
**Ambiente:** PROD

### 🎯 Qué se te pide

Explicar cómo una restricción única que funciona —hay una compra por token— convive con el triple de giros, cuantificar a cuántos jugadores les pasó, y arreglarlo.

### 🔧 Preparación

```bash
git checkout incidente/be-14
cd server && go build -o /tmp/api ./cmd/api && /tmp/api &
npm run mock:googleplay
```

Y la compra de la pieza forense de `be07`, pasos 1 a 3: una con tarjeta y otra en efectivo, cada una avisada dos veces por el juego y con la notificación duplicada.

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

Google Play avisa más de una vez, y el juego reintenta: eso está bien, para eso existe el `purchaseToken`. Si cada aviso suma giros, el problema es qué hace el servidor con un aviso repetido.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```sql
SELECT purchase_token, count(*) FROM purchases WHERE player_id = 43 GROUP BY 1;
SELECT paid_spins FROM players WHERE id = 43;
```

Y en el log, las líneas `ERROR`: ¿qué sentencia falló, y qué había pasado antes de ella en la misma petición?

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

El índice único rechazó la segunda compra. ¿Rechazó también los giros?

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

**Lo que se ve**

Seis avisos por compra. La rama responde `200` al primero y `500` a cada repetición que llega cuando la compra ya está:

```text
tok-card-…|43|1
tok-efecty-…|43|1
giros pagos de María R.: 60
[req-id 1f19dbaad6ca53d7] ERROR en POST /purchases/notifications: anotando la compra tok-card-…: pq: duplicate key value violates unique constraint "purchases_unique_token"
```

Una compra por token, como manda el índice, y **60** giros donde la fase da **20**.

**Causa raíz**

La acreditación son tres pasos cortos, cada uno con su conexión, y los giros van **antes** que la compra:

```diff
-	err := s.db.WithTx(ctx, func(tx *sqlx.Tx) error {
-		…
-		res, err := tx.ExecContext(ctx, tx.Rebind(`
-			INSERT INTO purchases (…) VALUES (?, ?, ?, ?)
-			ON CONFLICT (purchase_token) WHERE duplicate_of IS NULL DO NOTHING`), …)
-		…
-		if n, _ := res.RowsAffected(); n == 0 {
-			…
-			return nil // ya estaba acreditada: no se suma nada
-		}
-		res, err = tx.ExecContext(ctx, tx.Rebind(`
-			UPDATE players SET paid_spins = paid_spins + ? WHERE id = ?`), c.Spins, r.PlayerID)
-		…
-	})
+	// Tres pasos cortos, sin transacción larga: cada uno con su conexión, y el
+	// UNIQUE del token cuida que no haya dos compras. Funcionó durante meses.
+	… SELECT spins FROM packages …
+	… UPDATE players SET paid_spins = paid_spins + ? …
+	… INSERT INTO purchases (…) VALUES (?, ?, ?, ?)
```

El índice único hace su trabajo: la segunda compra no entra. Pero los giros de ese aviso **ya se sumaron**, en otra sentencia y en otra transacción. El `23505` llega tarde, y además vuelve como `500`: Google Play reintenta lo que no recibió con éxito, y cada reintento suma diez giros más.

**Cuántos son**

```sql
SELECT p.id, p.name, p.paid_spins, sum(k.spins) AS comprados
FROM players p
JOIN purchases u ON u.player_id = p.id AND u.duplicate_of IS NULL
JOIN packages k ON k.product_id = u.product_id
GROUP BY p.id HAVING p.paid_spins > sum(k.spins);
```

```text
 id |   name   | paid_spins | comprados
 43 | María R. |         60 |        20
```

Ojo con lo que esa consulta **no** ve: un jugador que ya gastó los giros de más. Para eso hace falta la bitácora, y el `purchase_token` de los giros pagos, que es deuda de `be07`.

**Parche mínimo**

La transacción de `be07` §5.3: la compra se reclama primero con `ON CONFLICT … DO NOTHING`, y los giros se suman solo si la compra entró, en la misma transacción. Un aviso repetido responde lo mismo que el primero, con `200`.

**Los datos**

Los giros de más no se corrigen restando a mano en `players`: el saldo es una proyección (`be05`), y una resta sin rastro es otra cifra que nadie puede explicar. Se decide con Itzel y con Marisol qué hacer, y lo que se haga queda anotado como hecho.

**Prueba de regresión**

`TestDuplicateNotificationCreditsOnce`, que ya está en `server/internal/purchase/service_test.go`. En la rama falla con:

```text
respuesta 0 distinta: {…}, anotando la compra tok-be07-1: pq: duplicate key value violates unique constraint "purchases_unique_token"
```

En la fase, pasa: *"51 avisos · 1 compra · 10 giros"*. Motor: PostgreSQL.

**Prevención**

Lo que se tiene que cumplir junto va en una transacción, y lo que se reclama se reclama primero. Y una regla para leer el código de cualquier pago: **si hay un `UNIQUE`, pregúntate qué pasó antes de que salte.**

**Por qué llegó a producción**

Porque con un aviso por compra funciona perfecto. Las repeticiones llegan cuando la red falla o cuando Google Play no recibe la respuesta a tiempo, y la primera señal es un jugador que no se queja.

**Si tu causa fue distinta a esta**

- *"El índice único no funciona"*: funciona, porque hay una compra por token. Lo que no está protegido es lo que pasó antes del `INSERT`.
- *"Una carrera: dos avisos a la vez"*: la reproducción es secuencial, un aviso después del otro, y da 60 igual. Con la transacción de `be07`, cincuenta avisos a la vez dan diez giros.
- Si tu fix fue *"ignorar el 23505"*, el aviso repetido responde bien y los giros siguen sumándose.

</details>

---

## Incidente be-15 ⭐ — La suite lleva tres semanas en verde y ayer se rompió producción

> **Fase:** be08 · **Categoría:** 🔥 contrato · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 60-90 min
> ⭐ **Uno de los dos más formativos del track** · Hermano del incidente **20** del track base, con otra causa raíz

### 🎫 El ticket

> "Ayer desplegamos y dejó de funcionar crear ruedas: Itzel arma la de la Semana
> del Canal y le sale error del servidor. Lo raro es que la suite estaba verde,
> el pipeline pasó, y en las máquinas de los tres que trabajamos en eso funciona
> perfecto. Volvimos a la versión anterior, pero no sabemos qué pasó y no nos
> atrevemos a volver a desplegar."

**Reportado por:** el propio equipo
**Ambiente:** PROD (y no se reproduce en desarrollo)

### 🎯 Qué se te pide

Explicar cómo una suite verde puede autorizar un despliegue roto. El fix es menor; **lo que importa es el diagnóstico y lo que se cambia después para que no vuelva a pasar**.

### 🔧 Preparación

```bash
git checkout incidente/be-15
cd server
go test ./...           # verde, sin TEST_DATABASE_URL
```

Ahora corre lo mismo contra Postgres. Ahí empieza el incidente.

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

*"En nuestras máquinas funciona"* + *"la suite está verde"* + *"en producción no"* tienen un factor común que no es el código, porque el código es el mismo en los tres sitios. ¿Qué es distinto entre tu máquina y producción? Haz la lista completa antes de seguir.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```bash
go test -v ./... | grep -c SKIP                          # ¿qué no corrió?
TEST_DATABASE_URL="postgres://…/esclusa_test?sslmode=disable" go test ./... -count=1
git log --oneline fase-be08-pruebas-y-la-regla-del-motor..incidente/be-15
```

Y mira el error de producción entero, sin recortar: la última parte nombra al culpable.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Hay **dos** commits desde la fase, y cada uno solo es inofensivo. `res.LastInsertId()` funciona en un motor y no en el otro. ¿En cuál corren tus pruebas desde el primer commit, y en cuál corre producción?

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

**Lo que se ve**

En la rama, sin `TEST_DATABASE_URL`, todo `ok`:

```text
ok  	github.com/interoceanic-games/esclusa-api/internal/http	0.004s
ok  	github.com/interoceanic-games/esclusa-api/internal/player	0.003s
ok  	github.com/interoceanic-games/esclusa-api/internal/purchase	0.016s
ok  	github.com/interoceanic-games/esclusa-api/internal/reconciliation	0.003s
ok  	github.com/interoceanic-games/esclusa-api/internal/spin	0.236s
ok  	github.com/interoceanic-games/esclusa-api/internal/wheel	0.039s
```

Contra Postgres, el store de ruedas cae:

```text
--- FAIL: TestCreateAndFind (0.13s)
    store_test.go:50: Create devolvió error: creando la rueda "Esclusa de Oro": LastInsertId is not supported by this driver
```

Y el binario, contra Postgres, responde `500` al alta de una rueda:

```text
[req-id 81576bdaa8f5086d] ERROR en POST /wheels: creando la rueda "Rueda de prueba": LastInsertId is not supported by this driver
```

**Causa raíz**

**Dos commits razonables, uno detrás del otro.** El primero hace que la suite *"corra en cualquier máquina"*: `OpenPostgres` salta en vez de fallar cuando no hay `TEST_DATABASE_URL`, y `MustPostgres` también. Desde ahí, en las máquinas sin Postgres —y en el pipeline, si no lo tiene—, lo que necesita Postgres se salta, y lo que vale en los dos motores corre contra SQLite. El segundo cambia `RETURNING` por `LastInsertId` en el alta de ruedas, que es la forma "obvia" de recuperar el id y la que sale en la mitad de los tutoriales:

```diff
-	err = tx.GetContext(ctx, &id, tx.Rebind(`
-		INSERT INTO wheels (name, timezone, closes_at, status)
-		VALUES (?, ?, ?, ?)
-		RETURNING id`), w.Name, w.Timezone, w.ClosesAt, w.Status)
+	res, err := tx.ExecContext(ctx, tx.Rebind(`
+		INSERT INTO wheels (name, timezone, closes_at, status)
+		VALUES (?, ?, ?, ?)`), w.Name, w.Timezone, w.ClosesAt, w.Status)
+	…
+	id, err := res.LastInsertId()
```

`mattn/go-sqlite3` lo implementa. **`lib/pq` no**, y no es un bug del driver: el protocolo de Postgres no ofrece ese dato. El store de ruedas corre en los dos motores desde `be02`, así que su prueba pasó contra SQLite. La suite de contrato, que sí habría corrido contra Postgres, se saltó.

> 🧠 **Y lo incómodo: la suite no falló en detectar el problema. La suite lo autorizó.** No tener suite te deja desconfiado; una suite verde te da **permiso para desplegar**, y ese permiso es exactamente lo que el equipo no tenía derecho a recibir.

Es el hermano del **incidente 20 del track base** —*"el test pasa en mi máquina y falla en la de al lado"*—, con la causa desplazada del **entorno** al **motor**.

**Parche mínimo**

Volver a `RETURNING`, que funciona en los dos motores (`D18` fija SQLite ≥ 3.35, la versión donde llegó). Y revertir el primer commit.

**La corrección correcta**

Arreglar el `LastInsertId` es media hora. Lo que hay que cambiar es **cómo se prueba**, y eso es `be08`:

> 🧭 **La regla del motor (`D18`).** SQLite vale para pruebas que no tocan concurrencia, bloqueos, zonas horarias ni SQL específico del motor. En cuanto una prueba toca cualquiera de las cuatro, **corre contra PostgreSQL o no vale**.

Y el mecanismo que la hace cumplir, que es lo que el primer commit desarmó:

```go
func MustPostgres(t *testing.T, db *storage.DB, why string) {
	t.Helper()
	if db.Dialect != storage.Postgres {
		t.Fatalf("esta prueba requiere PostgreSQL porque %s.\n"+ …
```

📖 **`t.Skip` es la forma en que una suite miente.** Y `(cached)` es la segunda.

**Prueba de regresión**

Dos, y ninguna es nueva. **El par contradictorio de `be08`** (`make test-engine`), que muestra exactamente esta trampa con `TestA_LastInsertId`. Y una que faltaba: **el alta de una rueda en la suite de contrato** (ejercicio 13 de `be08`), que corre contra Postgres con la aplicación entera. La suite de contrato siembra la base directo con el `db.json`, así que nunca llamaba a `Create`: por eso no lo habría atrapado aunque hubiera corrido.

**Prevención**

1. **`OpenPostgres` y `MustPostgres` fallan.** Cualquier propuesta de *"que salte, así corre en cualquier lado"* es la propuesta de este incidente.
2. **El pipeline corre contra Postgres**, con `services: postgres:13` (`be09`). Que la suite pudiera pasar sin un Postgres levantado era el agujero real.
3. **La suite de contrato cubre las escrituras**, no solo las lecturas.
4. El mecanismo del ejercicio 28 de `be08`: algo que **impida** agregar una prueba de base sin `testsupport`.

**Por qué llegó a producción**

Porque usar SQLite en memoria para las pruebas es una práctica **extendida y razonable**, y que la suite corra en cualquier máquina suena a una mejora. Quien hizo cada commit tenía buenos motivos. Lo que faltaba era que el límite —hasta dónde vale ese motor— fuera un mecanismo y no una costumbre.

Y la asimetría que lo hace grave: un falso **negativo** se investiga. Un falso **positivo** —verde en SQLite, roto en Postgres— **no produce ninguna señal**.

**Si tu causa fue distinta a esta**

- *"Es la configuración de producción"* — la del incidente 20 del track base. Se descarta levantando Postgres en local: se reproduce al instante.
- *"Falló la migración"* — se descarta mirando la versión del esquema, que `be09` además comprueba al arrancar.
- *"Es la versión de Go"* — el pipeline corre en `golang:1.19.13`, el mismo de siempre.
- Si tu fix fue **solo** volver a `RETURNING`, arreglaste este caso y dejaste intacta la condición que lo produjo. La próxima diferencia entre motores va a pasar por el mismo agujero, y `bea-03` documenta siete.

</details>

---

## Incidente be-16 — La imagen de ayer no arranca y el código no cambió

> **Fase:** be09 · **Categoría:** 🔥 despliegue · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45-60 min

### 🎫 El ticket

> "La imagen que construimos ayer no arranca en el servidor: el contenedor se
> levanta y se muere solo. La de anteayer funciona bien. Comparamos el código de
> Go y no hay ni una línea de diferencia. La construcción terminó sin un solo
> aviso."

**Reportado por:** el propio equipo
**Ambiente:** UAT

### 🎯 Qué se te pide

Encontrar qué cambió si el código no cambió, y arreglar la construcción para que no pueda volver a pasar.

### 🔧 Preparación

```bash
git checkout incidente/be-16
docker build --no-cache -t esclusa:sospechosa server/
docker run --rm -e DATABASE_URL="…" -e JWT_SECRET="…" esclusa:sospechosa
```

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

Ni siquiera es el cable: es la **imagen**. *"El código de Go no cambió"* descarta la aplicación y deja tres sospechosos: la receta de construcción, la máquina que construye y las imágenes base. `git log -p` sobre la rama, y no solo sobre `*.go`.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Lee el error del contenedor **entero**. Y compila el mismo binario fuera de la imagen, con la misma línea del `Dockerfile`, en `golang:1.19.13`:

```bash
ldd /tmp/api
go version -m /tmp/api | grep CGO_ENABLED
```

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si el binario pide una biblioteca dinámica y la imagen no la tiene, ¿qué archivo es el que "no existe"? No es el binario.

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

**Lo que se ve**

La construcción con `--no-cache` termina sin un aviso. El contenedor sale con código 255:

```text
exec /api: no such file or directory
```

sobre un binario que está en la imagen. Y el mismo binario, compilado afuera con la línea del `Dockerfile`:

```text
CGO_ENABLED=1
	linux-vdso.so.1 (0x0000ffffa685c000)
	libc.so.6 => /lib/aarch64-linux-gnu/libc.so.6 (0x0000ffffa6670000)
```

Con la fase, el binario dice `CGO_ENABLED=0` y `not a dynamic executable`, y el contenedor arranca.

**Causa raíz**

**El binario volvió a tener cgo, y la imagen de ejecución no tiene `libc`.** El commit de la rama no toca Go: cambia una línea del `Dockerfile`, con un buen motivo —*"la demo de la Semana del Canal corre sin Postgres: la imagen trae SQLite"*—:

```diff
-RUN CGO_ENABLED=0 go build -ldflags "-s -w" -o /out/api ./cmd/api
+# La demo de la Semana del Canal corre sin Postgres: la imagen trae SQLite.
+RUN CGO_ENABLED=1 go build -tags sqlite -ldflags "-s -w" -o /out/api ./cmd/api
```

Con `-tags sqlite` entra `mattn/go-sqlite3`, que exige cgo; con cgo, el binario enlaza contra la `glibc` de `golang:1.19.13` (Debian 12). Y la imagen de ejecución es distroless *static*, que no tiene `libc` porque el binario de `be09` no la necesitaba. **El archivo que no existe es la biblioteca que el binario pide**, no el binario.

📝 **Y hay dos hermanas de esta causa**, con síntomas parecidos:
- **Arquitectura:** una imagen `arm64` en un servidor `amd64` → `exec format error`, otro mensaje.
- **Zonas horarias:** en una imagen `scratch`, `time.LoadLocation` devuelve `unknown time zone` con el proceso ya arrancado. En distroless *static* no pasa: trae la base de zonas.

**Parche mínimo**

Revertir la línea. La demo sin Postgres no se arregla con una imagen distinta: se levanta con el compose de `be09`, que trae su Postgres.

**La corrección correcta**

La de `be09`, con su giro: **el binario de producción no tiene por qué traer un driver de SQLite**. Si alguien necesita de verdad una imagen con SQLite, es otra imagen, con otra base —distroless *base*, con `glibc`, como la versión A de `bea-02`— y otro nombre. No la misma imagen con una bandera cambiada.

**Prueba de regresión**

En el pipeline, no en `go test`. El paso que ya está (`CGO_ENABLED=0 go build`) no lo atrapa, porque compila con su propia línea y no con la del `Dockerfile`. Lo que falta es **construir la imagen y arrancarla**:

```yaml
- name: La imagen tiene que arrancar
  run: |
    docker build --no-cache -t esclusa:ci ./server
    docker run --rm --entrypoint /api esclusa:ci 2>&1 | grep -q "DATABASE_URL" \
      || { echo "la imagen no arranca: revisa cgo y la imagen de ejecución"; exit 1; }
```

Sin base, el binario sano muere con *"configuración inválida: required key DATABASE_URL missing value"*: es la prueba de que el proceso **arrancó**. El roto muere antes, con *"no such file or directory"*.

**Prevención**

1. **El paso de arriba.** Construir la imagen no es probarla.
2. **`docker build --no-cache` en el pipeline.** La caché de capas es una optimización de desarrollo y una fuente de falsos positivos en CI.
3. **Imágenes base fijadas por digest** (`D38`) y **publicación por `sha`**: sin eso, "la imagen de ayer" y "la de anteayer" no se pueden comparar.
4. **`smoke.sh` contra el contenedor**, no solo contra `go run`.

**Por qué llegó a producción**

Porque el cambio era **una mejora** para alguien, y la construcción terminó sin un solo aviso. El pipeline **construía** la imagen y no la **ejecutaba**. Y el error es ilegible: *"no such file or directory"* sobre un archivo que existe manda a cualquiera a revisar rutas y permisos durante un buen rato, que es justo donde no está el problema.

**Si tu causa fue distinta a esta**

- *"Es la arquitectura"* — es la hermana, y da `exec format error`.
- *"Cambió la imagen base sin que nadie la tocara"* — plausible con etiquetas móviles. Con el digest de `D38` se descarta mirando el `FROM`.
- *"Falta la base de zonas"* — daría un error de zona con el proceso ya arrancado, y distroless *static* la trae.
- Si tu fix fue **cambiar la imagen de ejecución por una con `glibc`**, funciona… y metiste en producción un driver de SQLite que no usa, con cgo, 81 MB y la compilación de 27 segundos que `be09` midió.

</details>

---

## Incidente be-17 — Cada vez que reiniciamos, la rueda da los mismos premios

> **Fase:** be05 · **Categoría:** 🔥 aleatorio · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45-60 min

### 🎫 El ticket

> "En el Discord alguien publicó que después de cada mantenimiento los primeros
> giros del día salen siempre iguales: vidas-5, gemas básico, sin premio,
> vidas-2… Varios lo probaron y les dio lo mismo, y ya hay quien dice que hay que
> girar justo después del reinicio. La conciliación de la Rueda de fin de mes
> dio perfecta, así que no sé qué responder. ¿Es casualidad?"

**Reportado por:** Itzel, operación
**Ambiente:** PROD

### 🎯 Qué se te pide

Decidir si es casualidad, con evidencia. Si no lo es, encontrar la causa, explicar por qué la conciliación de probabilidades **no podía** verla, y escribir la prueba que sí.

### 🔧 Preparación

```bash
git checkout incidente/be-17
cd server && go build -o /tmp/api ./cmd/api
psql "$DATABASE_URL" -c "UPDATE players SET free_spins = 4000 WHERE id = 42"
/tmp/api &
for i in $(seq 1 10); do
  curl -s -X POST -d "{\"idempotencyKey\":\"arranque1-$i\"}" localhost:3001/players/42/spins | jq -r .landedSegment
done
kill %1; /tmp/api &
# …y lo mismo con arranque2-$i
```

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

El juego muestra lo que el servidor responde: `landedSegment` viene en la respuesta del giro. Si los diez primeros de dos arranques coinciden, coinciden en el servidor. ¿Qué tiene el servidor que se reinicia con el proceso?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

`internal/spin/random.go`, con su historial. Y la documentación de la versión de Go que corre en producción, no la de tu editor:

```bash
go version
go doc math/rand.Seed
```

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿Con qué semilla arranca el generador global de `math/rand` si nadie llama a `rand.Seed`? ¿Y en qué versión de Go cambió eso?

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

Un commit que "simplificó" el sorteo para usar el generador global de `math/rand`:

```diff
-type Drawer struct {
-	mu  sync.Mutex
-	rng *rand.Rand
-}
+// Usa el generador global de math/rand: ya es seguro entre goroutines, así
+// que no hace falta ni el mutex ni una fuente propia.
+type Drawer struct{}
 …
-	d.mu.Lock()
-	n := d.rng.Intn(10000)
-	d.mu.Unlock()
+	n := rand.Intn(10000)
```

La mitad del razonamiento es correcta: el generador global sí es seguro entre goroutines, y `go test -race` no tiene nada que decir. La otra mitad está en la documentación de Go 1.19.13, la versión congelada del curso, y dice exactamente esto:

```
If Seed is not called, the generator behaves as if seeded by Seed(1).
```

Y en la del paquete: *"Top-level functions … use a default shared Source that produces a deterministic sequence of values each time a program is run."* **Cada arranque del binario sortea la misma secuencia.** Go 1.20 cambió eso y siembra el generador global al azar: compilada con `golang:1.20.14`, **la misma rama** pasa la prueba de regresión de abajo, con dos secuencias distintas. Quien escribió el commit tenía razón en su versión de Go, y no en la que corre producción.

Medido con el binario de la rama, dos arranques de 2.000 giros cada uno sobre la Esclusa de Oro: los diez primeros son `vidas-5 set-gemas-basico sin-premio vidas-2 sin-premio sin-premio vidas-2 sin-premio sin-premio vidas-2` en los dos, y **las 2.000 posiciones coinciden**. Con la fase, coinciden 357 de 2.000, lo que se espera por azar con esos pesos.

**Por qué la conciliación no lo ve**

Porque mide **frecuencias**, y las frecuencias son perfectas. El χ² de cada arranque contra los pesos publicados —el mismo cálculo de `oddsAudit`— dio **6,04** en los dos, lejos del valor crítico de 14,067. La secuencia es una buena secuencia pseudoaleatoria; el problema es que es **siempre la misma**. Ninguna prueba sobre la distribución puede ver una falla en la imprevisibilidad, y eso es lo que el ticket describe: un jugador que gira justo después del mantenimiento sabe qué va a salir.

**Parche mínimo**

Volver a la fuente propia sembrada desde `crypto/rand`, con su mutex. Un `rand.Seed(time.Now().UnixNano())` al arrancar también corta la repetición, pero deja la semilla en un número que se puede adivinar aproximando la hora del arranque, y desde Go 1.20 `rand.Seed` está marcada como obsoleta.

**La corrección correcta**

La de la fase (`D37`), y una decisión escrita: `math/rand` no sirve para nada donde predecir el resultado tenga valor —la documentación lo dice, *"unsuitable for security-sensitive work"*—. Si el sorteo tuviera que resistir a un atacante con la secuencia en la mano, el generador es `crypto/rand`, con su costo medido.

**Prueba de regresión**

Un arranque es un proceso, así que la prueba se relanza a sí misma dos veces y compara:

```go
// server/internal/spin/random_test.go — la regresión de be-17

package spin

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
	"testing"
)

// Dos arranques del binario no pueden sortear la misma secuencia. Un arranque
// es un proceso: la prueba se vuelve a lanzar a sí misma dos veces, cada una
// sortea diez segmentos, y compara lo que imprimieron.
func TestTwoBootsDrawDifferentSequences(t *testing.T) {
	if os.Getenv("SPIN_DRAW_CHILD") == "1" {
		d := NewDrawer()
		segments := []Segment{{SegmentID: "a", WeightBp: 1000}, {SegmentID: "b", WeightBp: 1000},
			{SegmentID: "c", WeightBp: 1000}, {SegmentID: "d", WeightBp: 1000}, {SegmentID: "e", WeightBp: 1000},
			{SegmentID: "f", WeightBp: 1000}, {SegmentID: "g", WeightBp: 1000}, {SegmentID: "h", WeightBp: 1000},
			{SegmentID: "i", WeightBp: 1000}, {SegmentID: "j", WeightBp: 1000}}
		var out []string
		for i := 0; i < 10; i++ {
			out = append(out, d.Draw(segments).SegmentID)
		}
		fmt.Println("SECUENCIA", strings.Join(out, ""))
		return
	}

	boot := func() string {
		cmd := exec.Command(os.Args[0], "-test.run=^TestTwoBootsDrawDifferentSequences$", "-test.count=1")
		cmd.Env = append(os.Environ(), "SPIN_DRAW_CHILD=1")
		out, err := cmd.CombinedOutput()
		if err != nil {
			t.Fatalf("el arranque falló: %v\n%s", err, out)
		}
		for _, line := range strings.Split(string(out), "\n") {
			if strings.HasPrefix(line, "SECUENCIA ") {
				return strings.TrimPrefix(line, "SECUENCIA ")
			}
		}
		t.Fatalf("el arranque no imprimió su secuencia:\n%s", out)
		return ""
	}
	first, second := boot(), boot()
	t.Logf("arranque 1: %s · arranque 2: %s", first, second)
	if first == second {
		t.Fatalf("dos arranques sortearon la misma secuencia: %s", first)
	}
}
```

En la rama falla con *"dos arranques sortearon la misma secuencia: ihbecbecad"*; en la fase, pasa. Motor: ninguno. Con diez segmentos de 1.000 bp, que dos arranques honestos coincidan en los diez por azar tiene probabilidad de una en diez mil millones.

**Prevención**

La prueba, y una regla de revisión: **la versión de Go del `go.mod` manda sobre la costumbre de quien revisa.** Un cambio que depende de un comportamiento de la biblioteca estándar se lee con la documentación de esa versión. Y en el mapa de deuda (`bea-09`), la subida de Go anotada con esta consecuencia: el día que se suba, este incidente deja de reproducirse, y la prueba tiene que seguir pasando.

**Por qué llegó a producción**

Porque nada de lo que se mira lo ve. `go test -race` pasa, la suite pasa, la conciliación da perfecta y el tablero muestra la rueda honesta. El commit parecía una simplificación correcta, y en una versión de Go más nueva lo era. Lo vio la comunidad, comparando capturas, que es exactamente como se descubrió la rueda que se acomodaba en 2025.

**Si tu causa fue distinta a esta**

- *"La rueda está arreglada, como la de 2025"* — se descarta con el χ²: 6,04, sin alarma, y los pesos no cambiaron. La de 2025 cambiaba las **proporciones**; esta las respeta y repite el **orden**.
- *"Es el caché del juego"* — se descarta con `curl`: la API devuelve la misma secuencia sin juego de por medio.
- *"Es casualidad"* — dos mil de dos mil posiciones iguales no son casualidad, y la fase lo muestra: 357.

</details>

---

## Incidente be-18 ➕ — Hay jugadores que cobran el giro gratis cada hora

> **Fase:** be06 · **Categoría:** 🔥 tiempo · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 30-45 min

### 🎫 El ticket

> "En el Discord se están pasando un truco: adelantas el reloj del celular y te
> dan otro giro gratis. Uno mandó captura con tres en una hora. Y el mes pasado
> esto no pasaba."

**Reportado por:** Yariela, soporte
**Ambiente:** PROD

### 🎯 Qué se te pide

Encontrar por qué el servidor acepta el reloj del celular, decir cuántos jugadores lo están usando, y qué hacer con ellos además de arreglar el código.

### 🔧 Preparación

```bash
git checkout incidente/be-18
cd server && go build -o /tmp/api ./cmd/api && /tmp/api &
curl -s -X POST localhost:3001/players/43/free-spins
curl -s -X POST -d '{"idempotencyKey":"be18-1"}' localhost:3001/players/43/spins
# El celular, cuatro horas y un minuto adelante:
ADELANTE=$(date -u -v+4H -v+1M +%Y-%m-%dT%H:%M:%SZ)   # en Linux: date -u -d '+4 hours 1 minute' …
curl -s -X POST -H "X-Client-Now: $ADELANTE" localhost:3001/players/43/free-spins
curl -s -X POST -d '{"idempotencyKey":"be18-2"}' localhost:3001/players/43/spins
```

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable</summary>

El celular no puede cambiar el reloj del servidor. Si el truco funciona, el servidor está **leyendo** la hora del celular en algún lado. ¿Dónde?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

En Network, o con `curl -v`, las cabeceras que manda el juego al reclamar. Y en la base:

```sql
SELECT id, name, next_free_spin_at, now() FROM players WHERE next_free_spin_at > now() + interval '4 hours';
```

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

`git log -p fase-be06-hora-dura-y-la-autoridad-del-reloj..incidente/be-18`. Lee el mensaje del commit: ¿qué problema quería resolver?

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

**Lo que se ve**

```text
{"playerId":43,"freeSpins":1,"nextFreeSpinAt":"2026-10-20T07:09:46.986Z"} → 200
{"landedSegment":"set-gemas-basico",…,"origin":"free",…} → 200
== el celular, cuatro horas y un minuto adelante: X-Client-Now: 2026-10-20T07:10:47Z
{"playerId":43,"freeSpins":1,"nextFreeSpinAt":"2026-10-20T11:10:47.000Z"} → 200
{"landedSegment":"vidas-2",…,"origin":"free",…} → 200
```

En `spin_log`, dos giros gratis de la misma jugadora con **16 ms** de diferencia en el reloj del servidor (`03:09:46.995` y `03:09:47.011`). Con la fase, el segundo reclamo responde `409 todavía no`.

**Causa raíz**

El commit de la rama (*"la cuenta regresiva del juego y la del servidor, con la misma hora"*) hace que el handler use la hora del celular si viene en una cabecera:

```diff
+	// El juego manda la hora del celular: si viene, se usa esa.
+	if clientNow, perr := time.Parse(time.RFC3339, r.Header.Get("X-Client-Now")); perr == nil {
+		claimed, err = h.spins.ClaimFreeAt(r.Context(), id, clientNow)
+	} else {
+		claimed, err = h.spins.ClaimFree(r.Context(), id)
+	}
```

La escritura condicional de `be06` sigue ahí y sigue siendo correcta: compara `next_free_spin_at <= ?`. Lo que cambió es **quién pone el `?`**. El problema que quería resolver era real, porque la cuenta regresiva del juego no coincidía con la del servidor, pero se resolvió del lado equivocado.

Un detalle de la reproducción: con el celular **cuatro horas exactas** adelante, el truco no funciona, porque `nextFreeSpinAt` lleva milisegundos y la cabecera no, así que queda unos milisegundos antes. Hace falta pasarse un poco, y los jugadores se pasan.

**Cuántos son**

Un `next_free_spin_at` a más de cuatro horas del reloj del servidor solo puede venir de un reloj ajeno:

```text
43|María R.|11:16:32|03:15:32
```

Con la fase, la misma consulta no devuelve nada.

**Parche mínimo**

Borrar la lectura de la cabecera: el handler llama a `ClaimFree`, que usa `s.clock.Now()`.

**Los datos**

Los giros que salieron son hechos y quedan en la bitácora (`D35`): no se borran ni se editan. Lo que sí se corrige es el `next_free_spin_at` envenenado, que además deja al jugador sin su giro honesto hasta la hora falsa:

```sql
UPDATE players SET next_free_spin_at = now() + interval '4 hours'
WHERE next_free_spin_at > now() + interval '4 hours';
```

Qué hacer con los giros de más es una decisión de producto, de Itzel, no tuya.

**Prueba de regresión**

```go
// server/internal/http/free_spin_test.go (extracto)

	if code := claim(""); code != http.StatusOK {
		t.Fatalf("el primer reclamo: %d", code)
	}
	if code := claim(now.Add(4 * time.Hour).Format(time.RFC3339)); code != http.StatusConflict {
		t.Fatalf("con el celular cuatro horas adelante: %d (esperaba 409)", code)
	}
```

La prueba arma el router con un `clock.Fixed`, reclama una vez sin cabecera y otra con `X-Client-Now` cuatro horas adelante, y exige `409` y un solo giro en el saldo. En la rama falla con *"con el celular cuatro horas adelante: 200 (esperaba 409)"*; en la fase, pasa. Motor: PostgreSQL.

**Prevención**

La regla de `be06`, sin excepción: **ninguna hora del cliente entra a una decisión**. Para la cuenta regresiva, el servidor ya manda `nextFreeSpinAt` y `X-Server-Time`; el juego resta el desfase para pintar, y el servidor no le pregunta a nadie. Y la consulta de *"Cuántos son"* como alarma diaria.

**Por qué llegó a producción**

Porque en las pruebas nadie adelanta el reloj, y el celular de quien lo probó tenía la hora bien: con la cabecera correcta, el comportamiento es idéntico al de la fase. El truco no está en el código. Lo encuentra el primer jugador que sospecha de un contador.

**Si tu causa fue distinta a esta**

- *"El barrido o el reloj del servidor"*: el reloj del servidor se ve en `X-Server-Time`, y el barrido de `be06` cierra ruedas; no toca el giro gratis.
- *"Una carrera: dos reclamos a la vez"*: la escritura condicional lo impide (`be06` §5.5, cincuenta reclamos, uno suma), y los dos giros de la bitácora están separados por un reclamo cada uno.
- Si tu fix fue *"rechazar la cabecera si difiere mucho del servidor"*, sigues dejando que el cliente decida dentro de tu tolerancia. La cabecera no se valida: no se lee.

</details>

---

# 🪞 Retrospectiva del track BE

Se llena al terminar los dieciocho, de una sola vez, releyendo tu propio
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

- **Las ramas existen.** Las catorce `incidente/be-NN` con código están en el repo de prueba, cada una reproduce su
  síntoma y su corrección lo quita; `be-04`, `be-08` y `be-11` son de diff vacío y `be-02` no tiene rama.
- **Cobertura por categoría**, al cerrar la reescritura: contrato 5, tiempo 3, base de datos 2, concurrencia 2,
  despliegue 2, autenticación 1, dinero 1, transacciones 1, aleatorio 1. Dinero y transacciones quedaron con uno cada
  uno, pero `be-13` y `be-14` son los dos lados de la misma fase (`be07`).
- **Reparto por dificultad:** 🟢 1 · 🟡 8 · 🟠 5 · 🔴 4. El único 🟢 es `be-12`, que con la carga y la consulta de la
  pista se resuelve rápido; su valor es la conversación sobre el barrido como regla.
- **`be-11` termina en una decisión, no en un commit**, y es de los que más se van a discutir: su respuesta es *"el
  servidor hizo lo correcto, y esto es lo que cuesta pagar la deuda del reloj de la consola"*. Si la revisión editorial
  lo suaviza, se pierde lo mejor que tiene.
- **Los seis hermanos están cruzados en los dos cuadernos**: acá en el índice, y allá en los incidentes 08, 11, 16, 18,
  19 y 20 del cuaderno base.
- **Ningún incidente depende de datos generados con faker.** Es deliberado: un conjunto aleatorio arruinaría la
  reproducibilidad (`bea-10`). `be-09` y `be-12` usan la rueda de medición de `be05`, que es SQL fijo.
- **Las regresiones viven en la suite desde `be08`** (`be08` §5.5). Las ramas de `be-10` y `be-17` salen de `be05`, con
  la firma de `spin.NewService` de esa fase; sus regresiones portadas están en la fase final.
