# 💸 Apéndice bea-09 — Mapa de deuda del track BE

> Tutorial React 16 — Rifas y chances · **Track BE opcional 🔥** · Consulta rápida · ~2 horas
> Lo referencia `be09`; **cualquier fase que declare una deuda 💸 la registra acá**

---

Este es el hermano de `A12`. Misma estructura, mismo criterio, otra capa: allá la
deuda del frontend, acá la del backend.

Cada entrada tiene las mismas cuatro partes, y **la tercera es la que importa**:

- **Qué se hizo en su lugar** — lo que está en el código hoy.
- **Por qué se dejó** — el razonamiento de quien decidió. Sin esto la entrada es
  inútil: dentro de un año nadie recordará si fue criterio o pereza.
- **Qué la vuelve exigible** — el **disparador**. La condición concreta que
  convierte esta deuda en un bug con fecha.
- **Fase** — dónde está documentada en detalle.

> 🧭 **El trabajo no es pagar todo: es vigilar los disparadores.** Mientras el
> disparador no ocurra, pagar la deuda es trabajo sin retorno — peor, es *riesgo*
> sin retorno, porque estás tocando código que funciona.

Y el tono, que en este apéndice importa tanto como el contenido: **una deuda
declarada y medida es una decisión de ingeniería; una deuda oculta es un
problema.** Nada de lo que sigue es un descuido, y nada de lo que sigue merece
autoflagelación.

---

## 🧭 Índice de salto rápido

1. [Las dos que el track decide NO pagar](#1-las-dos-que-el-track-decide-no-pagar)
2. [Identidad y seguridad](#2-identidad-y-seguridad)
3. [Datos y consistencia](#3-datos-y-consistencia)
4. [Operación](#4-operación)
5. [Andamiaje del curso](#5-andamiaje-del-curso)
6. [La que no se puede pagar](#6-la-que-no-se-puede-pagar)
7. [✅ Las que ya se pagaron](#7--las-que-ya-se-pagaron)
8. [🧩 Cuándo usar qué: el orden si esto fuera a producción](#-cuándo-usar-qué-el-orden-si-esto-fuera-a-producción)

---

## 1. Las dos que el track decide NO pagar

Van juntas y aparte del resto, porque **tienen la misma causa** y separarlas
oscurecería lo único interesante de las dos: no se dejaron por falta de tiempo,
se dejaron por una regla.

> 🧭 **La regla que ordena el track:** el frontend heredado no se toca. La única
> excepción está negociada, escrita y acotada a un archivo (`D27`). Estas dos
> deudas se pagarían tocando el frontend, y ampliar la excepción una segunda vez
> la convertiría en una licencia general.

### 💸 Sin *refresh token*: el JWT vence y el usuario cae al login

**`be04`.** El token tiene vida larga en el laboratorio (`JWT_TTL`, 12 h) y corta
en UAT y producción (1 h). Cuando vence, el interceptor de la Fase 2 recibe un
`401`, dispara el logout global, y el usuario pierde lo que estuviera haciendo.

Se dejó porque implementar renovación exige que **el cliente** llame a un
endpoint nuevo: tocar `apiClient.js`, sus dos interceptores y probablemente
`authSlice.js`. Eso es media capa de red del frontend, no un archivo.

**Se vuelve exigible** en cuanto el sistema tenga usuarios reales trabajando
sesiones largas —un día de ventas dura más de una hora— o el día que se pueda
tocar el frontend. El diseño completo está en el ejercicio 31 de `be04`; el
apéndice `bea-04` §5 explica por qué un JWT no se puede revocar y qué cuesta
cada alternativa.

### 💸 El frontend se pinta con el reloj del navegador

**`be06`.** El servidor ya es la autoridad temporal: rechaza toda venta posterior
a `closesAt` y publica su hora en `X-Server-Time`. Pero la interfaz sigue
calculando `isPastClosing` contra `new Date()`, o sea contra el reloj del
usuario.

Consecuencia medida, y no es simétrica: con el reloj **adelantado**, la UI cierra
antes de tiempo y el usuario **pierde una venta legítima**; con el reloj
**atrasado**, la UI ofrece el botón y el backend responde `409` — mensaje confuso,
**datos correctos**.

Se dejó por la misma razón que la anterior. Y se hizo **la mitad barata**: el
header ya viaja. Pagar la otra mitad son unas treinta líneas —un interceptor que
guarde el desfase y una función `serverNow()` que lo aplique— repartidas en
`apiClient.js` y `closing.js`. El ejercicio 27 de `be06` pide medirlo de verdad.

**Se vuelve exigible** cuando aparezca el primer reporte de *"me cerró la rifa
antes de tiempo"* que no sea un error del servidor. Hoy ese caso deja rastro en
el log (`be06` §5.4), que es exactamente lo que lo hace diagnosticable en dos
minutos en vez de en una tarde.

> 🧠 **Y lo que estas dos enseñan, que vale más que su solución:** decidir **no**
> pagar una deuda y escribir por qué es una forma perfectamente respetable de
> administrarla. Muy superior a pagarla a escondidas, saltándose la regla que el
> equipo acordó.

---

## 2. Identidad y seguridad

### 💸 Sin autorización a nivel de objeto

**`be04`, detallada en `bea-08` §2.** Cualquier usuario autenticado puede editar,
cerrar o liquidar **cualquier** rifa. Las rifas no tienen dueño: no hay columna
`owner_id` y nadie pregunta. Lo único que existe es la línea de log que registra
quién hizo el cambio.

Se dejó porque el dominio del curso no tiene el concepto de propiedad —la Fase 4
del track base crea rifas sin autor— e inventarlo habría cambiado el contrato de
`be00`. Añadirlo del lado del servidor sin que el frontend lo mande es posible
(el `owner_id` saldría del token), pero no había regla de negocio que lo pidiera.

**Se vuelve exigible** el día que haya más de un vendedor con intereses
distintos, o el primer requisito del tipo *"que Beto no pueda liquidar las rifas
de Ana"*. La defensa está diseñada en `bea-08` §2, cuesta una migración y una
comprobación en el servicio, y **exige una prueba por operación sensible** porque
este fallo no produce ningún síntoma hasta que alguien lo aprovecha.

### 💸 Sin límite de intentos en `POST /login`

**`be04`, detallada en `bea-08` §5.** Se pueden probar contraseñas
indefinidamente. La única mitigación es que `bcrypt` con costo 10 hace cada
intento lento — lo que también significa que un atacante paralelo consume tu CPU.

Se dejó porque un limitador serio necesita decidir por qué se agrupa (IP, email o
los dos) y dónde vive el contador, y la respuesta cambia si hay más de una
réplica. Nada de eso enseñaba algo sobre reemplazar un mock.

**Se vuelve exigible** con el primer despliegue accesible desde fuera de una red
de confianza. ⚠️ Y hay una trampa que hay que resolver antes: el frontend
heredado **no sabe manejar un `429`** y lo mostraría como error genérico.

### 💸 `numberPrice` y `basePrize` se leen del cuerpo del `PUT`

**Descubierta al escribir `bea-08` §3.** El CRUD de la Fase 4 manda la rifa
entera en cada `PUT`, así que el precio del número y el premio base llegan desde
el cliente y se guardan. Combinado con la deuda anterior —sin propiedad—, un
vendedor podría bajar el precio de una rifa ajena.

Se dejó porque rechazar esos campos rompería el `PUT` del contrato, que manda la
entidad completa. La defensa correcta no es rechazar: es **una regla de dominio**
—el precio no cambia después de la primera venta— que el servicio puede aplicar
sin que el cliente se entere.

**Se vuelve exigible** junto con la propiedad, o antes si aparece cualquier
auditoría de recaudo. La implementación es el ejercicio 7 de `bea-08`
(`ErrPriceLocked`) y cuesta seis líneas.

### 💸 El token vive en `localStorage`

**Heredada de la Fase 2, y no se puede pagar desde acá.** Es accesible por
cualquier script de la página, así que un XSS se lleva la sesión. La alternativa
—una cookie `HttpOnly`— cambia el vector (protege de XSS, abre CSRF) y **exige
tocar el frontend**.

**Se vuelve exigible** con el primer hallazgo de XSS, o con cualquier requisito
de cumplimiento que lo prohíba explícitamente. Está también en `A12` del track
base, desde la otra orilla; el análisis completo es el ejercicio 30 de `be04`.

### 💸 `JWT_SECRET` sin rotación

**`be09`.** El secreto se inyecta por variable de entorno y no rota nunca.
Rotarlo hoy invalida **todas** las sesiones de golpe.

Se dejó porque rotar en caliente exige aceptar dos secretos a la vez durante una
ventana —verificar con el viejo y el nuevo, firmar solo con el nuevo— y eso es
código que no enseña nada sobre el reemplazo del mock.

**Se vuelve exigible** ante la primera sospecha de filtración, que es
precisamente el momento en que **no** quieres estar diseñando la rotación. Es la
clase de deuda que conviene pagar antes de necesitarla.

---

## 3. Datos y consistencia

### 💸 `sales` es inmutable por convención, no por permisos

**`be07`, ejercicio 23.** Nada impide que alguien con acceso a la base haga
`DELETE FROM sales`. La inmutabilidad del registro de ventas —sobre el que se
calcula todo el dinero— es un acuerdo, no una restricción.

Se dejó porque hacerla cumplir de verdad requiere separar roles de base de datos:
un rol de aplicación sin `DELETE` ni `UPDATE` sobre esa tabla, y un rol de
migración aparte. Es correcto y es una conversación de operación, no de código.

**Se vuelve exigible** en cuanto el dinero de este sistema sea real, o cuando
haya más de una persona con credenciales de producción. La consulta de auditoría
del ejercicio 22 de `be07` detecta el descuadre **después**; los permisos lo
impiden **antes**.

### 💸 Sin mecanismo de corrección de una liquidación errónea

**`be07`, ejercicio 27.** Si una liquidación queda mal, no hay forma prevista de
arreglarla: la tabla es inmutable y el `UNIQUE (raffle_id)` impide crear otra.

Se dejó porque el diseño correcto —asientos de compensación, como lleva
haciéndose en contabilidad cuatrocientos años— es un modelo de datos entero, y el
curso no tiene el caso de uso.

**Se vuelve exigible** con la primera liquidación errónea. Y llegará: el
ejercicio 28 de `be07` es exactamente ese ticket.

### 💸 Sin comprobación de desbordamiento en el cálculo del recaudo

**`be07`, ejercicio 24.** `soldCount * numberPrice` en `int64` desborda en
silencio: el número da la vuelta y queda negativo, sin excepción y sin aviso.

Se dejó porque con `BIGINT` el margen es enorme —unos 92 mil billones de
centavos— y llegar ahí requiere datos absurdos. Pero *silencio* es la palabra
incómoda: en JavaScript habrías perdido precisión de forma más ruidosa.

**Se vuelve exigible** con datos generados por un faker sin cotas (`bea-10`), o
con cualquier moneda de subdivisión muy pequeña. La comprobación con
`math/bits.Add64` cuesta cuatro líneas.

### 💸 Los *workers* corren en todas las réplicas

**`be05` y `be06`, ejercicio 26 de `be05`.** El que vence reservas y el que cierra
rifas por reloj corren en cada proceso. No rompen nada —los dos son `UPDATE`
idempotentes y la segunda ejecución afecta cero filas— pero es trabajo repetido, y
el patrón sí haría daño en operaciones que no fueran idempotentes.

**Se vuelve exigible** al pasar de una réplica, o el día que alguien agregue un
tercer *worker* sin darse cuenta de que el patrón no protege. La solución es un
`pg_advisory_lock` y son diez líneas.

### 💸 Sin límite de reservas por usuario

**`be05`.** Un solo usuario puede reservar el tablero entero y no comprar nada.
Las reservas vencen solas desde `be05`, así que el daño es temporal, pero durante
la ventana el resto no puede vender.

**Se vuelve exigible** con el primer uso adversarial, o con cualquier rifa donde
la escasez importe.

---

## 4. Operación

### 💸 `sslmode=disable` en desarrollo

**`be02`.** El tráfico a la base va en claro. Es correcto en un laboratorio local
y sería un hallazgo en cualquier otra parte. `be09` §4.3 ya fija `require` para
QA, UAT y producción, así que **la deuda es solo de desarrollo**.

**Se vuelve exigible** en cuanto la base de desarrollo deje de ser `localhost` —
un Postgres compartido en la red de la oficina, por ejemplo.

### 💸 Las migraciones se aplican a mano en desarrollo

**`be02` y `be09`.** En desarrollo se corre `migrate up` cuando toca. `be09`
resolvió la parte que importa —el servidor **no** migra, comprueba la versión y se
niega a arrancar si no coincide— así que lo que queda es incomodidad, no riesgo.

**Se vuelve exigible** con el primer *"a mí me funciona"* causado por una
migración que alguien no corrió. El mensaje de arranque ya lo hace obvio, que es
media solución.

### 💸 Log de texto en vez de estructurado

**`be01`, discutida en `bea-07` §3.** `log.Printf` con el id delante. Es
grepeable y legible en una terminal, y no se puede filtrar por campos ni agregar.

Se dejó por coherencia de época: `log/slog` es de Go 1.21 y este código es de
2022 (`D14`). Y porque una línea legible enseña mejor.

**Se vuelve exigible** en cuanto los logs los lea una máquina —un colector, un
buscador, un panel—. El logger JSON de veinticinco líneas está escrito en
`bea-07` §3: la deuda ya tiene su pago redactado.

### 💸 Sin métrica agregada del desfase de reloj

**`be06`, ejercicio 23.** El desfase cliente-servidor se registra línea por línea,
así que responde *"¿qué pasó con esta petición?"* pero no *"¿cuántos usuarios
tienen el reloj mal?"*.

**Se vuelve exigible** cuando haya que decidir si vale la pena pagar la deuda del
§1, porque ese número es justamente el argumento.

### 💸 Sin `HTTPS`

**`be09`, en la tabla de `bea-08` §7.** El token viaja en claro. Se resuelve
fuera del proceso, en un proxy, y por eso el track no lo trata.

**Se vuelve exigible** con el primer despliegue fuera de `localhost`. **Sin
excepciones**: es la primera de la lista del §8.

---

## 5. Andamiaje del curso

Estas existen **porque esto es un curso**. En un sistema real no serían deuda:
serían un error.

### 💸 `POST /_chaos` en el binario de producción

**`be01` y `be09`, ejercicio 24 de `be09`.** Un endpoint para romper tu propio
sistema, apagado por defecto pero **presente**. `CHAOS_LEVEL=off` no basta: si el
código está en el binario, existe.

Se dejó porque las prácticas de las fases 3 y 7 del track base lo usan tal cual, y
`D22` obliga a conservarlo.

**Se vuelve exigible** en el primer despliegue a un ambiente accesible. La
solución está escrita y es una etiqueta de compilación: `-tags chaos` para el
laboratorio, nada en producción.

### 💸 `server/smoke.sh` ensucia los datos

**`be00`.** La verificación de venta duplicada deja el número `1500` vendido. Hay
que restaurar el `db.json` o reservar un número de pruebas.

**Se vuelve exigible** cuando alguien lo corra contra un ambiente compartido. La
suite de contrato de `be08` ya tiene sus propios datos y su truncado; **portar el
guion a esa disciplina es el pago**.

### 💸 El contenedor de pruebas se levanta a mano

**`be08`.** Un `docker run` desde un guion. `testcontainers-go` lo automatizaría a
cambio de una dependencia y de un arranque más lento por caso.

**Se vuelve exigible** cuando alguien nuevo pierda una tarde porque olvidó
levantarlo. El mensaje de `OpenPostgres` ya nombra el comando, que es media
solución.

### 💸 Sin medición de cobertura en CI, **a propósito**

**`be08`.** Se puede medir con `go test -cover`, pero no hay umbral ni puerta en
el pipeline.

Se dejó **deliberadamente**, y por un argumento que el track defiende: la
cobertura mide líneas ejecutadas, no propiedades verificadas. El `SellNumber` de
`be03` tenía cobertura completa y el bug de la venta duplicada intacto. Un umbral
en CI convierte la cobertura en un objetivo, y un objetivo se cumple escribiendo
pruebas que ejecutan código sin afirmar nada.

**Se vuelve exigible** nunca, en esta forma. Lo que sí valdría la pena es medir
qué **no** ejecuta nadie, o pruebas de mutación (ejercicio 🔥 de `be08`).

### 💸 `GET /stats` no existe

**Pendiente 🔥 de `be09`.** El dashboard de la Fase 9 calcula sus métricas en el
navegador. Ninguna fase depende de este endpoint y el `smoke.sh` no lo exige.

**Se vuelve exigible** cuando el volumen haga inviable calcularlas en el cliente —
con veinte mil ventas ya se nota— o cuando alguien más necesite las mismas cifras.

---

## 6. La que no se puede pagar

### 🪦 El `sold_by` de las ventas históricas

**`be05`.** Al crear la tabla `sales`, las ventas que ya existían se migraron
atribuidas al usuario 1, porque **su autoría real no existe**: se hicieron cuando
el backend no preguntaba quién vendía. Esa era, precisamente, la tercera deuda que
`be04` pagó.

No hay disparador y no hay pago posible. El dato no está en ninguna parte y no se
puede reconstruir. Lo único que se puede hacer —y se hizo— es **no esconderlo**:
está marcado en la migración y está acá.

> 🧠 **Vale la pena que este mapa tenga una entrada así.** No toda deuda se paga;
> algunas solo se documentan para que nadie construya encima creyendo que el dato
> es fiable. Una consulta de auditoría que agrupe ventas por vendedor **mentirá**
> sobre el periodo anterior a `be05`, y quien la escriba tiene derecho a saberlo.

---

## 7. ✅ Las que ya se pagaron

El track no solo declaró deuda: cobró la mitad. Esta lista está acá porque el
ciclo completo —declarar, fechar, pagar— es lo que hace creíble a un mapa de
deuda.

| Deuda | Declarada en | Pagada en |
|---|---|---|
| Contraseñas comparadas en claro | Fase 2 → `be02` | `be04` (`bcrypt`) |
| El token como constante de texto | Fase 2 → `be03` (columna `users.token`) | `be04` (JWT firmado, columna borrada) |
| El cliente decide quién es | Fase 2 | `be04` (`req.Context()`) |
| Transiciones de estado libres | Fase 4 | `be04` (custodiadas en el servicio) |
| El `409` producido por un `if` | Fase 3 → `be03` | `be05` (índice único + transacción) |
| Reservas sin expiración en el servidor | Fase 5 | `be05` (`reserved_until` + *worker*) |
| La hora de cierre la evalúa el navegador | Fase 7 | `be06` (autoridad del servidor) |
| `settledAt` fijado por el cliente | `be03` | `be06` (sellado por el servidor) |
| La aritmética de dinero solo en el frontend | Fase 8 | `be07` (recálculo desde `sales`) |
| `db.json` como almacén | Fase 3 | `be03` 🪦 |
| Configuración con `os.Getenv` sin validar | `be01` | `be03` (`envconfig`) |
| El `X-Request-Id` que nace y muere en el mock | Fase 2 | `be01` (viaja por `context`) |
| `C-05`: el header que no se podía leer | `be00` | `be01` (`Expose-Headers`) |
| `C-01`: la ruta que el frontend llamaba al vacío | `be00` | `be03` |
| `D19`: la cuestión cgo | `be02` | `be09` (etiqueta de compilación) |

---

## 🧩 Cuándo usar qué: el orden si esto fuera a producción

Si mañana hubiera que llevar este backend a un sistema real, **este es el orden**,
y el criterio es riesgo dividido por esfuerzo, no elegancia:

| # | Qué | Por qué primero | Esfuerzo |
|---|---|---|---|
| 1 | **HTTPS** | Sin esto, todo lo demás es decorativo: el token viaja en claro | Un proxy. No toca el código |
| 2 | **Sacar `/_chaos` del binario** | Un endpoint para romperse a sí mismo, expuesto | Una etiqueta de compilación |
| 3 | **Límite de tasa en el login** | Fuerza bruta sin freno | Bajo, con la salvedad del `429` |
| 4 | **Autorización a nivel de objeto** | Cualquiera toca lo de cualquiera | Medio: migración, servicio y **una prueba por operación** |
| 5 | **Permisos sobre `sales`** | El dinero se calcula sobre una tabla que cualquiera puede borrar | Bajo: roles de base |
| 6 | **Rotación de `JWT_SECRET`** | Diseñarla ante una filtración es el peor momento | Medio |
| 7 | **`serverNow` en el frontend** | Ventas legítimas perdidas por relojes desfasados | ~30 líneas, **pero rompe la regla del track** |
| 8 | ***Refresh token*** | Sesiones cortadas a mitad del trabajo | Alto, y toca el frontend |
| 9 | **Log estructurado** | Cuando los lea una máquina | Bajo: ya está escrito en `bea-07` |
| 10 | **Corrección de liquidaciones** | Hasta que haya una mal, no urge | Alto: modelo de datos |

> 🧭 **Fíjate en los tres primeros.** Ninguno toca la lógica de negocio, los tres
> cuestan poco, y los tres son más urgentes que cualquier refactorización. Es lo
> habitual: **la deuda que más riesgo quita casi nunca es la que más incomoda al
> escribir código.**

### Cómo se mantiene este archivo

- **Una deuda nueva se registra acá el día que se declara**, no "cuando haya
  tiempo". Una fase que marque 💸 sin entrada en este mapa deja el mapa
  incompleto, y un mapa incompleto no se consulta.
- **Cuando una deuda se paga, se mueve al §7** con la fase que la pagó. No se
  borra: el historial es lo que hace creíble al inventario.
- **Si un disparador ocurre**, la entrada deja de ser deuda y pasa a ser un bug
  con fecha. Sácala de acá y ponla donde vayan los bugs.
- **Revisa los disparadores, no las entradas.** Leer este archivo entero cada seis
  meses no sirve; preguntarse *"¿ha pasado alguno de los diez disparadores?"*, sí.

---

## 🧪 Ejercicios (6)

1. **🟢** Recorre las diez fases buscando el marcador 💸 y comprueba que cada una tiene su entrada acá. Si falta alguna, agrégala con las cuatro partes.
2. **🟡** Para tres entradas a tu elección, escribe el **test que fijaría el comportamiento actual como esperado**. Después argumenta si ese test convierte la deuda en deliberada o si solo la congela.
3. **🟡 Diagnóstico.** Toma la tabla del §7 y verifica en el código que cada deuda pagada está de verdad pagada. La columna `users.token`, en particular: si sigue existiendo, `be04` no cerró.
4. **🟠** Estima en horas el pago de las diez entradas del §8 y reordénalas por riesgo dividido por esfuerzo. Si tu orden difiere del propuesto, defiende el tuyo.
5. **🟠** Elige un disparador y **provócalo** en el laboratorio: levanta dos réplicas y observa a los dos *workers* haciendo el mismo trabajo, o crea un segundo usuario y edita con él una rifa ajena. Documenta el síntoma exacto.
6. **🔴** Escribe la entrada que falta: encuentra una deuda del backend que ninguna fase declaró, con evidencia, y redáctala con las cuatro partes. Pista: mira los `TODO`, los valores fijos en el código y cualquier `interface{}`.

---

## 📚 Referencias

**Del propio curso**
- `A12-mapa-de-deuda-tecnica.md` — el hermano de este apéndice, con la deuda del frontend. Léelos juntos: varias entradas son la misma deuda vista desde las dos orillas.
- `bea-08` §7 — la lista de lo que este backend no cubre a propósito, que es este mapa desde el ángulo de seguridad.
- `server/VEREDICTO.md` (`be09`) — el cierre honesto del track, donde estas deudas se resumen para alguien que decide si vale la pena.

**Externas**
- https://martinfowler.com/bliki/TechnicalDebtQuadrant.html — los cuatro cuadrantes (deliberada/inadvertida × prudente/imprudente). Casi todo lo de este mapa es deliberada y prudente, y saber nombrarlo ayuda a defenderlo.
- https://martinfowler.com/bliki/TechnicalDebt.html — la metáfora original y sus límites.
- https://www.agilealliance.org/introduction-to-the-technical-debt-concept/ — un resumen corto y sensato.

**Libros**
- *Working Effectively with Legacy Code* (Michael Feathers) — la distinción entre código que funciona y código que se puede cambiar, que es lo que este mapa mide.

> ⚠️ URLs, títulos y ediciones pueden haber cambiado: verifícalos. Las
> referencias a libros son de memoria y pueden ser inexactas.

---

> 🏷️ **Este apéndice no lleva tag.** Es de consulta pura, y es **un documento
> vivo**: se actualiza cada vez que una fase declara o paga una deuda. Los
> commits que lo modifiquen llevan el prefijo de la fase que motivó el cambio
> (`be05: registra la deuda del worker en varias réplicas`), según
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
