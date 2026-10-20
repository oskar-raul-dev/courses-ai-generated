# 💸 Apéndice bea-09 — Mapa de deuda del track BE

> Tutorial React 16 — La Esclusa, la consola de Jewel Locks · **Track BE opcional 🔥** · Consulta rápida · ~2 horas
> Lo referencia `be09`; **cualquier fase que declare una deuda 💸 la registra acá**

---

Este es el hermano de `A12`. Misma estructura, mismo criterio, otra capa: allá la
deuda de la consola, acá la del backend.

Cada entrada tiene las mismas cuatro partes, y **la tercera es la que importa**:

- **Qué se hizo en su lugar** — lo que está en el código hoy.
- **Por qué se dejó** — el razonamiento de quien decidió. Sin esto la entrada es
  inútil: dentro de un año nadie recordará si fue criterio o pereza.
- **Qué la vuelve exigible** — el **disparador**. La condición concreta que
  convierte esta deuda en un bug con fecha.
- **Fase** — dónde está documentada en detalle.

> 🧭 **El trabajo no es pagar todo: es vigilar los disparadores.** Mientras el
> disparador no ocurra, pagar la deuda es trabajo sin retorno —peor, es *riesgo*
> sin retorno, porque estás tocando código que funciona—.

Y el tono, que en este apéndice importa tanto como el contenido: **una deuda
declarada y medida es una decisión de ingeniería; una deuda oculta es un
problema.** Nada de lo que sigue es un descuido, y nada merece autoflagelación.

Este mapa es, además, una de las entradas de la decisión de 2028 (historia §3,
*Hoy*): qué deudas se pagan solas si la consola se decomisiona, y cuáles exigen
migrarla (`be09` §5.6).

---

## 🧭 Índice de salto rápido

1. [Las dos que el track decide NO pagar](#1-las-dos-que-el-track-decide-no-pagar)
2. [Identidad y seguridad](#2-identidad-y-seguridad)
3. [Datos y consistencia](#3-datos-y-consistencia)
4. [Operación](#4-operación)
5. [Andamiaje del curso](#5-andamiaje-del-curso)
6. [Las que no se pueden pagar](#6-las-que-no-se-pueden-pagar)
7. [✅ Las que ya se pagaron](#7--las-que-ya-se-pagaron)
8. [🧩 Cuándo usar qué: el orden si esto fuera a producción](#-cuándo-usar-qué-el-orden-si-esto-fuera-a-producción)

---

## 1. Las dos que el track decide NO pagar

Van juntas y aparte del resto, porque **tienen la misma causa** y separarlas
oscurecería lo único interesante de las dos: no se dejaron por falta de tiempo,
se dejaron por una regla.

> 🧭 **La regla que ordena el track:** la consola heredada no se toca. La única
> excepción está negociada, escrita y acotada a un archivo (`D27`). Estas dos
> deudas se pagarían tocando la consola, y ampliar la excepción una segunda vez
> la convertiría en una licencia general.

### 💸 Sin *refresh token*: el JWT vence y la operadora cae al login

**`be04`.** El token tiene vida larga en el laboratorio (`JWT_TTL`, 12 h) y corta
en UAT y producción (1 h). Cuando vence, el interceptor de la Fase 2 recibe un
`401`, dispara el logout global, y la operadora pierde lo que estuviera haciendo.
Es el incidente `be-08`.

Se dejó porque implementar renovación exige que **el cliente** llame a un
endpoint nuevo: tocar `apiClient.js`, sus dos interceptores y probablemente
`authSlice.js`. Eso es media capa de red de la consola, no un archivo.

**Se vuelve exigible** en cuanto Yariela trabaje sesiones largas con el TTL de
producción —una noche de evento dura más de una hora— o el día que se pueda tocar
la consola. El diseño está en el ejercicio 31 de `be04`; `bea-04` §5 explica por
qué un JWT no se puede revocar y qué cuesta cada alternativa.

### 💸 La consola se pinta con el reloj del navegador

**`be06`.** El servidor ya es la autoridad temporal: el giro comprueba el cierre
dentro de su transacción, el envío de un giro de una rueda cerrada da `409`, y
toda respuesta trae `X-Server-Time`. Pero la consola sigue calculando
`isWheelClosed` contra `Date.now()`, o sea contra el reloj de la operadora.

Consecuencia medida en el incidente `be-11`, y no es simétrica: con el reloj
**adelantado**, la consola marca `(cerrada)` una rueda abierta y no deja mandar un
giro legítimo; con el reloj **atrasado**, ofrece el giro y el servidor responde
`409`: mensaje confuso, **datos correctos**.

Se dejó por la misma razón que la anterior, y se hizo **la mitad barata**: el
header ya viaja y está expuesto a CORS. Pagar la otra mitad es un interceptor que
guarde el desfase y una función `serverNow()` que lo aplique, en `apiClient.js` y
`closing.js`. El ejercicio 26 de `be06` pide medirlo.

**Se vuelve exigible** con el primer reporte de *"me sale cerrada y no lo está"*
que no sea un error del servidor.

> 🧠 **Y lo que estas dos enseñan, que vale más que su solución:** decidir **no**
> pagar una deuda y escribir por qué es una forma respetable de administrarla.
> Muy superior a pagarla a escondidas, saltándose la regla que el equipo acordó.
> Y, para 2028: **las dos se pagan solas si la consola se decomisiona**, y las dos
> exigen trabajo si se migra.

---

## 2. Identidad y seguridad

### 💸 El juego no se autentica, y la notificación de la tienda no está firmada

**`be05`, `be06` y `be07`; en `bea-08` §5 y §7.** `POST /players/:id/spins`,
`/free-spins`, `/purchases` y `POST /purchases/notifications` son públicas:
cualquiera que conozca la ruta gira, reclama o avisa una compra. La compra se
verifica contra la tienda antes de acreditar, así que una notificación inventada
no acredita nada; un giro sí sale, si el jugador tiene saldo.

Se dejó porque la autenticación del juego es del equipo de Unity —un token del
dispositivo, o el servicio de identidad de la tienda— y la firma de la
notificación depende de cómo la tienda la entregue (Cloud Pub/Sub, en Google
Play). Ninguna de las dos enseñaba algo sobre reemplazar un mock.

**Se vuelve exigible** con el primer despliegue fuera de una red de confianza.
Antes que nada, porque es la puerta del dinero.

### 💸 Sin autorización a nivel de objeto, ni roles

**`be04`, detallada en `bea-08` §2.** Cualquier operador autenticado puede editar
cualquier rueda y mandar cualquier premio. No hay roles: Marisol podría armar una
rueda. Lo único que existe es el `sent_by` de cada envío.

Se dejó porque la consola no tiene el concepto —la Fase 4 crea ruedas sin autor— e
inventarlo habría cambiado el contrato de `be00`.

**Se vuelve exigible** el primer día que haya un requisito del tipo *"que soporte
no pueda tocar las ruedas"*. La defensa está en `bea-08` §2, cuesta una migración
y una comprobación en el servicio, y **exige una prueba por operación sensible**:
este fallo no produce ningún síntoma hasta que alguien lo aprovecha.

### 💸 Los pesos de una rueda que no está en vivo se leen del cuerpo

**`bea-08` §3.** El CRUD de la Fase 4 manda la rueda entera en cada `PUT`. Una
rueda `live` está protegida —cambiar sus pesos da `409`, y en las demás un cambio
publica una versión nueva—, pero cualquier operador puede cambiar los pesos de una
rueda `draft` o `scheduled`.

**Se vuelve exigible** junto con los roles.

### 💸 Sin límite de intentos en `POST /login`

**`be04`, detallada en `bea-08` §5.** Se pueden probar contraseñas
indefinidamente. `bcrypt` con costo 10 hace cada intento lento, lo que también
significa que un atacante paralelo consume tu CPU.

**Se vuelve exigible** con el primer despliegue accesible desde fuera de una red
de confianza. ⚠️ Antes hay que resolver una trampa: la consola heredada **no sabe
manejar un `429`** y lo mostraría como error genérico.

### 💸 El token vive en `localStorage`

**Heredada de la Fase 2, y no se puede pagar desde acá.** Un XSS se lleva la
sesión. La alternativa —una cookie `HttpOnly`— cambia el vector y **exige tocar la
consola**. Está también en `A12`, desde la otra orilla; el análisis es el
ejercicio 30 de `be04`.

### 💸 `JWT_SECRET` sin rotación

**`be09`.** El secreto se inyecta por variable de entorno y no rota nunca: rotarlo
invalida **todas** las sesiones de golpe. Rotar en caliente exige aceptar dos
secretos durante una ventana.

**Se vuelve exigible** ante la primera sospecha de filtración, que es justo el
momento en que **no** quieres estar diseñándola.

---

## 3. Datos y consistencia

### 💸 Los giros pagos no dicen de qué compra salieron

**`be07` §5.8.** `spin_log.purchase_token` sigue nulo en los giros nuevos. El
prorrateo de la Fase 8 —el precio de un paquete repartido entre sus giros— solo
funciona sobre la bitácora sembrada.

Se dejó porque pagarlo exige consumir las compras de cada jugador en orden, con la
fila de la compra bloqueada mientras se descuenta, y una carrera más en
`race_test.go`. No entraba en las 6 horas de `be07`.

**Se vuelve exigible** la primera vez que Marisol tenga que prorratear un paquete
comprado después de `be07`, o con el primer reembolso, que necesita saber qué
giros salieron de esa compra. El diseño es el ejercicio 26 de `be07`.

### 💸 Sin reembolsos

**`be07`, ejercicio 27.** Google Play avisa también cuando una compra se
reembolsa, y el backend no lo procesa. Un hecho no se borra: se compensa con
otro, y ese modelo no existe.

**Se vuelve exigible** con el primer reembolso real, y depende de la deuda
anterior.

### 💸 Una conciliación mal guardada no se puede corregir

**`be07`, y el incidente `be-13`.** La tabla de conciliaciones tiene una fila por
rueda y la rueda queda en `reconciled`. Si una conciliación se guardó con datos
viejos —lo que `be07` ya impide—, no hay forma prevista de anotar la corregida.

**Se vuelve exigible** con la primera conciliación que Marisol necesite rehacer.
El diseño correcto es la conciliación como hecho, con fecha, y la anterior como
historia.

### 💸 El saldo de giros pagos es un `INTEGER`

**`be02`, medido en `be07` §5.7.** `players.paid_spins` desborda en 2.147.483.647:
la prueba de todo o nada lo usa para hacer fallar la acreditación a propósito. En
Postgres el desborde es un error (`integer out of range`), no un número que da la
vuelta, así que el daño es un `500`, no un saldo falso.

**Se vuelve exigible** nunca con los paquetes de hoy (500 giros como mucho), salvo
datos generados sin cotas (`bea-10`).

### 💸 Los barridos corren en todas las réplicas

**`be05` y `be06`.** El que cierra los giros en proceso y el que cierra ruedas por
reloj corren en cada proceso. No rompen nada —los dos escriben con una condición
en el `WHERE` y la segunda pasada afecta cero filas—, pero es trabajo repetido, y
el patrón sí haría daño en una operación que no fuera idempotente.

**Se vuelve exigible** al pasar de una réplica, o el día que alguien agregue un
tercer barrido sin notar que el patrón no protege. La solución es un
`pg_advisory_lock`.

---

## 4. Operación

### 💸 La base de zonas depende de la imagen

**`be06` §4.2.** `golang:1.19.13` trae la base de zonas 2023c, y para Asunción da
una hora distinta de la de `postgres:13` (2025b), porque Paraguay dejó el horario
de verano en 2024. Hoy no cambia ninguna decisión: el servidor compara instantes y
no carga zonas.

**Se vuelve exigible** el día que el backend convierta un instante a la hora local
de un jugador para **decidir** algo. Entonces la versión se fija como cualquier
dependencia (`import _ "time/tzdata"` y una versión de Go conocida).

### 💸 `sslmode=disable` en desarrollo

**`be02`.** El tráfico a la base va en claro. Correcto en un laboratorio local;
`be09` §4.3 ya fija `require` para los demás ambientes.

**Se vuelve exigible** en cuanto la base de desarrollo deje de ser `localhost`.

### 💸 Log de texto en vez de estructurado

**`be01`, discutida en `bea-07` §3.** `log.Printf` con el id delante: se puede
buscar con `grep` y se lee en una terminal, pero no se puede filtrar por campos.
`log/slog` es de Go 1.21 y este código es de 2022 (`D14`).

**Se vuelve exigible** en cuanto los logs los lea una máquina. El logger JSON está
escrito en `bea-07` §3.

### 💸 Sin métrica agregada del desfase de reloj

**`be06`, ejercicio 23.** El desfase se ve petición por petición, no *"¿cuántas
consolas tienen el reloj mal?"*.

**Se vuelve exigible** cuando haya que decidir si vale la pena pagar la deuda del
§1: ese número es el argumento.

### 💸 Sin `HTTPS`

**`be09`, en la tabla de `bea-08` §7.** El token viaja en claro. Se resuelve fuera
del proceso, en un proxy.

**Se vuelve exigible** con el primer despliegue fuera de `localhost`. **Sin
excepciones**: es la primera de la lista del §8.

---

## 5. Andamiaje del curso

Estas existen **porque esto es un curso**. En un sistema real no serían deuda:
serían un error.

### 💸 `POST /_chaos` en el binario de producción

**`be01` y `be09`, ejercicio 24 de `be09`.** Un endpoint para romper tu propio
sistema, apagado por defecto pero **presente**. Se dejó porque las prácticas de las
Fases 3 y 7 lo usan, y `D22` obliga a conservarlo.

**Se vuelve exigible** en el primer despliegue a un ambiente accesible. La solución
es la misma de SQLite en `be09`: una etiqueta de compilación.

### 💸 Los `thresholds` de latencia dependen de la máquina

**`be08` §5.6.** El nivel de carga falla en la máquina del autor con el código
correcto y 200 jugadores a la vez (p95 de 581,98 ms contra un umbral de 500). Las
invariantes, en cambio, no dependen de la máquina.

**Se vuelve exigible** el día que el nivel de carga corra en CI: ahí un umbral que
depende del runner es una prueba intermitente.

### 💸 Sin medición de cobertura en CI, **a propósito**

**`be08`.** Se puede medir con `go test -cover`, pero no hay umbral ni puerta. La
cobertura mide líneas ejecutadas, no propiedades verificadas: el giro de 2019
tenía cobertura y entregaba Esclusas de más. Un umbral en CI se cumple escribiendo
pruebas que ejecutan código sin afirmar nada.

**Se vuelve exigible** nunca, en esta forma.

### 💸 `GET /stats` no existe

**Pendiente 🔥 de `be09`.** El tablero de la Fase 9 calcula sus métricas en el
navegador, y con la Semana del Canal sembrada (180.000 giros) ya lo nota.

**Se vuelve exigible** cuando el volumen haga inviable calcular en el cliente, o
cuando alguien más necesite las mismas cifras.

---

## 6. Las que no se pueden pagar

### 🪦 Quién mandó los envíos anteriores a `be04`

**`be04`.** `grants.sent_by` es nulo en los envíos de antes de la autenticación
real: se hicieron cuando el backend no preguntaba quién era. El dato no está en
ninguna parte y no se puede reconstruir.

### 🪦 La bitácora de 2019 no dice con qué pesos giró

**`be02` y `be07`.** Las filas que vienen del mock no traen `wheel_version`, ni los
segmentos elegibles. La auditoría por versión de `be07` las cuenta como de la
versión 1, la única que tuvieron esas ruedas; para una rueda que hubiera cambiado
de pesos antes de `be02`, esa atribución **mentiría**.

### 🪦 A quién se le acreditaron las compras anteriores a `be07`

**`be07`.** `purchases.player_id` es nulo en las compras sembradas: el mock no lo
sabía.

> 🧠 **Vale la pena que este mapa tenga entradas así.** No toda deuda se paga;
> algunas solo se documentan para que nadie construya encima creyendo que el dato
> es fiable. Una consulta que agrupe envíos por operador, o compras por jugador,
> **mentirá** sobre el periodo anterior, y quien la escriba tiene derecho a saberlo.

---

## 7. ✅ Las que ya se pagaron

El track no solo declaró deuda: cobró la mitad. El ciclo completo —declarar,
fechar, pagar— es lo que hace creíble a un mapa de deuda.

| Deuda | Declarada en | Pagada en |
|---|---|---|
| Contraseñas comparadas en claro | Fase 2 → `be02` | `be04` (`bcrypt`) |
| El token como constante de texto | Fase 2 → `be03` (columna `users.token`) | `be04` (JWT firmado, columna borrada) |
| El cliente decide quién es | Fase 2 | `be04` (identidad del contexto) |
| Transiciones de estado libres | Fase 4 | `be04` (custodiadas en el servicio) |
| El giro de 2019: la misma clave, el saldo y el stock | Fase 3 → `be03` | `be05` (el giro como hecho, en una transacción) |
| El `409` del envío producido por un `if` | Fase 5 → `be03` | `be05` (`UNIQUE (player_id, case_id)`) |
| La bitácora editable | `be02` | `be05` (disparador de solo inserción, `D35`) |
| La hora de cierre la evalúa el navegador | Fase 7 | `be06` (el cierre dentro del giro) |
| La zona de la sesión en una línea del DSN | `be03` | `be06` (`storage.Open`, `D29`) |
| La compra acreditada dos veces | Fase 8 | `be07` (índice único parcial) |
| La conciliación calculada por el navegador | Fase 8 → `be00` (`C-07`) | `be07` (recalculada en el servidor) |
| La rueda que se acomoda | historia §5, incidente 21 | `be07` (protección con sustituto, `D34`) |
| Las pruebas que se saltaban sin Postgres | `be05` | `be08` (`MustPostgres`) |
| `db.json` como almacén | Fase 3 | `be03` 🪦 |
| Configuración con `os.Getenv` sin validar | `be01` | `be03` (`envconfig`) |
| El `X-Request-Id` que nace y muere en el mock | Fase 2 | `be01` (viaja por `context`) |
| `C-05`: el header que no se podía leer | `be00` | `be01` (`Expose-Headers`) |
| `C-01`: la ruta que el juego llamaba sin garantías | `be00` | `be05` |
| `D19`: la cuestión cgo | `be02` | `be09` (etiqueta de compilación) |
| Las migraciones a mano en el despliegue | `be02` | `be09` (`cmd/migrate` y la comprobación al arrancar) |

---

## 🧩 Cuándo usar qué: el orden si esto fuera a producción

Si mañana hubiera que llevar este backend a un sistema real, **este es el orden**,
y el criterio es riesgo dividido por esfuerzo, no elegancia:

| # | Qué | Por qué primero | Esfuerzo |
|---|---|---|---|
| 1 | **HTTPS** | Sin esto, todo lo demás es decorativo | Un proxy. No toca el código |
| 2 | **Autenticar al juego y la notificación** | Son la puerta del dinero y de los premios | Medio, y depende del equipo de Unity |
| 3 | **Sacar `/_chaos` del binario** | Un endpoint para romperse a sí mismo | Una etiqueta de compilación |
| 4 | **Límite de tasa en el login** | Fuerza bruta sin freno | Bajo, con la salvedad del `429` |
| 5 | **Roles y autorización a nivel de objeto** | Cualquier operador toca todo | Medio: migración, servicio y **una prueba por operación** |
| 6 | **`purchase_token` en los giros pagos** | Sin eso no hay reembolsos ni prorrateo | Medio: un bloqueo más y su carrera |
| 7 | **Rotación de `JWT_SECRET`** | Diseñarla ante una filtración es el peor momento | Medio |
| 8 | **`serverNow` en la consola** | Giros legítimos que no se mandan | Bajo, **pero rompe la regla del track** |
| 9 | ***Refresh token*** | Sesiones cortadas a mitad del trabajo | Alto, y toca la consola |
| 10 | **Log estructurado** | Cuando los lea una máquina | Bajo: ya está escrito en `bea-07` |

> 🧭 **Fíjate en los tres primeros.** Ninguno toca la lógica de negocio que el
> track construyó, y los tres son más urgentes que cualquier refactorización. Es
> lo habitual: **la deuda que más riesgo quita casi nunca es la que más incomoda
> al escribir código.**

### Cómo se mantiene este archivo

- **Una deuda nueva se registra acá el día que se declara**, no "cuando haya
  tiempo". Una fase que marque 💸 sin entrada en este mapa deja el mapa
  incompleto, y un mapa incompleto no se consulta.
- **Cuando una deuda se paga, se mueve al §7** con la fase que la pagó. No se
  borra: el historial es lo que hace creíble al inventario.
- **Si un disparador ocurre**, la entrada deja de ser deuda y pasa a ser un bug
  con fecha.
- **Revisa los disparadores, no las entradas.** Preguntarse *"¿pasó alguno de los
  disparadores?"* sirve; leer el archivo entero cada seis meses, no.

---

## 🧪 Ejercicios (6)

1. **🟢** Recorre las diez fases buscando el marcador 💸 y comprueba que cada una tiene su entrada acá. Si falta alguna, agrégala con las cuatro partes.
2. **🟡** Para tres entradas a tu elección, escribe el **test que fijaría el comportamiento actual como esperado**. Después argumenta si ese test convierte la deuda en deliberada o si solo la congela.
3. **🟡 Diagnóstico.** Toma la tabla del §7 y verifica en el código que cada deuda pagada está de verdad pagada. La columna `users.token`, en particular: si sigue existiendo, `be04` no cerró.
4. **🟠** Estima en horas el pago de las diez entradas del §8 y reordénalas por riesgo dividido por esfuerzo. Si tu orden difiere del propuesto, defiéndelo.
5. **🟠** Elige un disparador y **provócalo** en el laboratorio: levanta dos réplicas y observa a los dos barridos haciendo el mismo trabajo, o manda una notificación de compra con `curl` y explica por qué no acredita. Documenta el síntoma exacto.
6. **🔴** Clasifica cada entrada de este mapa según la decisión de 2028: cuáles se pagan solas si la consola se decomisiona, cuáles exigen migrarla, y cuáles quedan igual en los dos caminos. Ese cuadro es una fila más para el veredicto de `be09`.

---

## 📚 Referencias

**Del propio curso**
- `A12-mapa-de-deuda-tecnica.md` — el hermano de este apéndice, con la deuda de la consola. Léelos juntos: varias entradas son la misma deuda vista desde las dos orillas.
- `bea-08` §7 — lo que este backend no cubre a propósito, este mapa desde el ángulo de seguridad.
- `server/VEREDICTO.md` (`be09`) — el cierre del track, donde estas deudas se resumen para quien decide.

**Externas**
- https://martinfowler.com/bliki/TechnicalDebtQuadrant.html — los cuatro cuadrantes (deliberada/inadvertida × prudente/imprudente). Casi todo lo de este mapa es deliberada y prudente.
- https://martinfowler.com/bliki/TechnicalDebt.html — la metáfora original y sus límites.

**Libros**
- *Working Effectively with Legacy Code* (Michael Feathers) — la distinción entre código que funciona y código que se puede cambiar, que es lo que este mapa mide.

> ⚠️ URLs, títulos y ediciones pueden haber cambiado: verifícalos. Las
> referencias a libros son de memoria y pueden ser inexactas.

---

> 🏷️ **Este apéndice no lleva tag.** Es de consulta pura y es **un documento
> vivo**: se actualiza cada vez que una fase declara o paga una deuda. Los commits
> que lo modifiquen llevan el prefijo de la fase que motivó el cambio
> (`be07: registra la deuda del purchase_token`), según
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
