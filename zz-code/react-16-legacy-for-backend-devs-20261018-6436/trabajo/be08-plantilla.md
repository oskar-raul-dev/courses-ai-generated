# 🧪 Fase be08 — Pruebas por niveles y la regla del motor

> Tutorial React 16 — La Esclusa, la consola de Jewel Locks · **Track BE opcional 🔥** · Fase be08 de be09 · **10 horas**
> Depende de: be07 — el dominio está completo del lado del servidor · Habilita: be09 — Empaquetado y pipeline

---

## 🎯 1. Propósito

*"La suite estaba en verde y producción se rompió. ¿Para qué tenemos suite?"* Juliana lo pregunta sin enojo, con la pregunta que importa. Hasta acá el track agregó comportamiento. Esta fase no agrega ninguno: **demuestra que el que hay es cierto**, con una suite organizada por niveles, cada uno con un trabajo y un costo distintos.

Pero el contenido central no es la suite. Es una regla, y su demostración:

> 🧭 **SQLite vale para pruebas que no tocan concurrencia, bloqueos, zonas horarias ni SQL específico del motor. En cuanto una prueba toca cualquiera de las cuatro, corre contra PostgreSQL o no vale.** (`D18`)

La regla no se enuncia como opinión: se demuestra con **una prueba que pasa en SQLite y falla en Postgres, y otra que hace exactamente lo contrario**. Las dos existen, las dos van al repositorio, y las dos son correctas.

Y el argumento que la fase tiene que dejar clavado:

> 🧠 **Una suite verde contra el motor equivocado es PEOR que no tener suite.** No tener suite te deja desconfiado y prudente. Una suite verde te da **permiso para desplegar**, y ese permiso es justo lo que no tenías derecho a recibir.

Hay una prueba de eso en el repositorio, y es de la fase anterior: con el código de `be07` y sin `TEST_DATABASE_URL`, `go test ./...` dice `ok` en `spin` y en `purchase` **sin haber corrido ninguna de sus pruebas de base**. Se saltaron, y nadie lee los `SKIP` de una salida que termina en `ok`.

La deuda 💸 que cobra: la suite de la Fase 10 del track base —Jest, RTL, marbles— no podía probar nada del servidor, porque el servidor era un `json-server` con un archivo. Y suma dos piezas que `be05` y `be07` dejaron a medias: **la prueba estadística que no falla una de cada veinte veces**, y **el nivel de carga** que mira la base después de k6.

---

## ✅ 2. Qué queda listo al terminar

- [ ] La suite está organizada por niveles —unitario, handler, integración, contrato, concurrencia y carga— y cada uno se corre solo, con un objetivo del `Makefile`.
- [ ] Pruebas unitarias puras —transiciones, el borde del cierre, `OddsAudit`, el cruce de compras, el sorteo— que corren **sin base** en un segundo.
- [ ] Pruebas de handler con `httptest` y un doble del servicio, que fijan la traducción a HTTP: códigos, mensajes y el `404` con `{}` (`C-04`).
- [ ] La **suite de contrato** verifica el régimen estricto de `be00` y los cambios que el track introdujo a propósito, con la aplicación entera contra Postgres.
- [ ] `testsupport.OpenPostgres` y `MustPostgres` **fallan** —no saltan— cuando una prueba que necesita Postgres corre sin él.
- [ ] Las regresiones de los incidentes que aplican a la fase final están en la suite.
- [ ] La prueba estadística está sembrada y da el mismo χ² en cada corrida.
- [ ] Existen las dos pruebas contradictorias, detrás de `-tags regla`, y `server/evidence/regla-del-motor.md` las documenta con la clasificación de la suite por motor.
- [ ] El nivel de carga corre `giro.js` con sus `thresholds` y comprueba las invariantes en SQL después.
- [ ] `go test -race ./...` pasa contra Postgres, y `./server/smoke.sh` sigue entero.

---

## 🚫 3. Qué queda fuera por ahora

- **Las pruebas de extremo a extremo del frontend.** Viven en la Fase 10 del track base, con Cypress. No se duplican: son otra pirámide, con otro dueño.
- **El pipeline** → `be09`. Acá se construye la suite que **puede** correr en CI; hacerla correr allá es la otra fase.
- **El rendimiento.** El nivel de carga de esta fase mide **corrección bajo carga** —las invariantes de `be05` con la forma de la noche—, no cuántos giros por segundo aguanta el sistema. Un umbral de latencia depende de la máquina; una invariante, no (5.6).
- **Mutación, fuzzing y verificación formal.** Se mencionan como comparación 🔥. El *fuzzing* nativo de Go llegó en 1.18 y está disponible, como ejercicio opcional.

---

## 🧠 4. Conceptos mínimos

### 4.1 Los niveles, y qué prueba cada uno

Un nivel se justifica por lo que puede fallar en él **y no en los otros**. Si dos niveles atrapan siempre los mismos bugs, sobra uno.

| Nivel | Qué prueba | Necesita | Cuánto tarda (medido) |
|---|---|---|---|
| Unitario | Transiciones, el borde del cierre, `OddsAudit`, el cruce de compras, el sorteo sembrado | nada | ~1 s con la compilación |
| Handler | La traducción a HTTP: código, mensaje, forma | nada | ms |
| Integración | Que el SQL haga lo que dices que hace | Postgres | s |
| Contrato | Que la consola siga funcionando | Postgres y la aplicación entera | ~1,3 s |
| Concurrencia | Que las garantías se sostengan bajo carrera | Postgres, `-race` | la suite entera: ~30 s |
| Carga | Que las invariantes se sostengan con la forma de la noche | el binario, k6 y Postgres | minutos |

Los dos primeros son gratis, así que vive ahí todo lo que pueda vivir. Y una consecuencia de diseño que conviene decir al revés: **si algo importante solo se puede probar en integración, muchas veces el problema es el diseño y no la prueba**. El borde del cierre es unitario porque `be06` sacó `wheel.IsClosed` a una función pura; `OddsAudit` es unitario porque `be07` lo separó del SQL. Las decisiones de las fases anteriores son las que hacen barata esta.

### 4.2 La regla del motor, y por qué falla en vez de saltar

Correr las pruebas contra SQLite en memoria es tentador y en parte correcto: arranca en milisegundos y no necesita contenedor. Para el store de ruedas es la decisión adecuada, y esa prueba corre en los dos motores desde `be02`.

El problema es que SQLite y PostgreSQL **no son el mismo sistema con distinta velocidad**: tienen garantías distintas. `be02` midió siete divergencias, y `be05` mostró que la concurrencia ni siquiera se puede simular: la carrera del stock dio verde contra SQLite con el código roto de `be-09`. Cuando una prueba cruza una de esas fronteras, no prueba tu código: prueba cómo se comporta en un motor que no vas a desplegar.

Y la asimetría la empeora. Un falso negativo —falla en SQLite, pasaría en Postgres— es molesto: lo investigas. Un **falso positivo** —verde en SQLite, roto en Postgres— no produce ninguna señal. Nadie investiga una prueba que pasa.

> 🧭 **Corolario operativo: `t.Skip` es la forma en que una suite miente.** Las pruebas de `be05` a `be07` se saltaban sin `TEST_DATABASE_URL`. Desde esta fase, **fallan**, y dicen por qué: una prueba que no puede correr donde importa es un error de configuración, no un caso omitido.

### 4.3 Dobles: qué se sustituye y qué no

En Go los dobles casi no necesitan librería: las interfaces implícitas de `be01` hacen que cualquier struct con los métodos correctos sirva. Este track no usa ningún framework de *mocks*. La decisión importante es **qué sustituir**:

- **El reloj: siempre.** `be06` lo hizo inyectable para esto.
- **El servicio, en las pruebas de handler: sí.** Ahí se prueba la traducción HTTP, y por eso el handler del giro depende ahora de una interfaz (`spinService`) y no del tipo concreto.
- **La tienda (`purchase.Play`): sí.** Es un tercero; en la suite de contrato la reemplaza un doble que lee el mismo `earnings.json` que sirve el `3002`.
- **El store, en las pruebas de servicio: casi nunca.** Un servicio cuya lógica está en el SQL —en este backend, mucha—, probado contra un store falso, prueba el doble.
- **La base: nunca.** No hay forma honesta de simular un `FOR UPDATE`.

### 4.4 Aislamiento entre casos

Dos pruebas que comparten datos producen fallos que dependen del orden. Hay tres estrategias, y en este backend la barata no sirve:

**Truncado entre casos.** Un `TRUNCATE … RESTART IDENTITY CASCADE` antes de cada prueba: rápido y simple. Inservible acá:

```text
ERROR:  spin_log solo se agrega: TRUNCATE rechazado
```

Es el disparador de `be05` (`D35`) haciendo su trabajo. Desactivarlo para las pruebas sería probar otra base.

**Transacción revertida por caso.** Inservible también: el código bajo prueba abre sus propias transacciones (`be05`, `be07`).

**Esquema nuevo por caso.** `migrate down` y `migrate up` antes de cada prueba, con la misma herramienta que se usa a mano (`D20`). Cuesta ~120–170 ms por caso, medido. Es la que se usa.

> ⚠️ **La base de pruebas nunca es la de desarrollo.** Cada prueba borra el esquema entero; apuntada a la base equivocada, borra siete fases de trabajo. `OpenPostgres` comprueba el nombre y se niega a correr si no es `esclusa_test`.

---

## 💻 5. Implementación y código comentado

```bash
cd server && go get github.com/stretchr/testify@v1.8.1
```

> 📝 `testify` entra solo por `require`, que ahorra ruido en las aserciones. **No** usamos su paquete de *mocks* (4.3).

### 5.1 La base de las pruebas: `testsupport`

<<<fragmento:server/internal/testsupport/db.go|// MustPostgres es el corazón de la regla del motor|	return open(t, url)
}>>>

<<<fragmento:server/internal/testsupport/db.go|func open(t *testing.T, url string) *storage.DB {|	return db
}>>>

Ese pool aparte no estaba en el primer intento, y lo encontró una prueba. La regresión de `be-05` cuenta las conexiones tomadas al final, y con el helper ingenuo daba *"quedaron 1 conexiones tomadas"* en cada corrida. `postgres.WithInstance` de golang-migrate reserva una conexión del pool para su lock y la retiene hasta que se cierra el migrador. En el pool de la prueba, era una conexión perdida por caso.

Las pruebas de `spin`, `purchase`, `wheel` y las demás abren su base con `testsupport`. Sin `TEST_DATABASE_URL`:

```text
race_test.go:22: TEST_DATABASE_URL no está definida: esta prueba necesita PostgreSQL (D18)
--- FAIL
```

### 5.2 Niveles 1 y 2: lo que no necesita base

<<<archivo:server/internal/wheel/closing_unit_test.go>>>

<<<fragmento:server/internal/reconciliation/audit_test.go|// Nivel 1: los conteos de la bitácora sembrada|	require.InDelta(t, 808.35, a.Chi2, 0.005)
}>>>

Los mismos conteos y el mismo χ² que `oddsAudit.test.js` de la Fase 10 y que el incidente 21: el servidor y la consola, la misma tabla.

<<<fragmento:server/internal/http/handlers_test.go|// Nivel 2: la traducción a HTTP|			}
		})
	}
}>>>

### 5.3 Probar algo aleatorio sin que la prueba sea intermitente

`be07` dejó una simulación que no exige *"sin alarma"*: una rueda honesta da alarma de χ² en una de cada veinte corridas. Para la suite hace falta otra cosa. La Fase 10 lo resolvió en JavaScript con dos técnicas, y en Go son las mismas:

<<<fragmento:server/internal/spin/random.go|// NewDrawerFrom sortea con la fuente|rand.New(src)}
}>>>

<<<fragmento:server/internal/spin/drawer_test.go|// Técnica 1, la semilla|		t.Fatalf("%d alarmas en 1.000: fuera de lo que da una rueda honesta", alarms)
	}
}>>>

```text
drawer_test.go:39: semilla 42 · χ² 5.2493 · banda []
drawer_test.go:56: sin semilla · 42 alarmas de χ² en 1.000 auditorías (4.2 %)
```

Cincuenta corridas de la técnica 1 dieron **cincuenta veces** χ² = 5,2493: es determinista, y por eso puede ir en CI. La técnica 2 dio 3,6 % y 4,2 % de alarmas en dos corridas: la tasa de `D32`, medida. La primera prueba es la que se queda en la suite; la segunda es la que te explica por qué.

### 5.4 Nivel 4: la suite de contrato

Es la traducción a Go del `smoke.sh` de `be00`, y conviene decir por qué existen las dos. `smoke.sh` corre **contra un servidor levantado** —el mock, tu binario, el del compose— sin compilar nada: atrapa *"el ambiente está mal"*. La suite corre **en cada `go test`**, con la aplicación entera —router, middlewares, servicios, base sembrada desde el `db.json`—: atrapa *"el código está mal"*.

<<<fragmento:server/internal/http/contract_test.go|	t.Run("los tipos de una rueda son los del contrato"|		require.Contains(t, string(res.Body), `"error"`)
	})>>>

`map[string]interface{}` y no un struct: deserializar a un tipo propio hace que `"1"` y `1` terminen en el mismo `int64`, y la prueba pasaría con el contrato roto. El navegador no hace eso.

Y los cambios que el track hizo **a propósito** tienen prueba propia: es lo que los distingue de una regresión.

<<<fragmento:server/internal/http/contract_test.go|	t.Run("be07: la conciliación es la del servidor|		require.Equal(t, []string{"tok-ago-17"}, r.Purchases.DuplicatedInAPI)
	})>>>

### 5.5 Nivel 5: concurrencia, `-race` y las regresiones

Las pruebas de carrera de `be05` se quedan como están —con su barrera y su verificación en la base— y suman `MustPostgres`. Y entran a la suite las regresiones de los incidentes que siguen valiendo en la fase final:

| Incidente | Dónde | Qué fija |
|---|---|---|
| `be-01` | `http/cors_test.go` | `X-Request-Id` expuesto a CORS |
| `be-03` | `http/panic_test.go` y la suite de contrato | el pánico como `500` legible; `GET /players` sin filtro |
| `be-05` | `player/pool_test.go` | veinte envíos repetidos no agotan el pool |
| `be-06` | `spin/spin_json_test.go` | `origin` como texto |
| `be-07` | `reconciliation/shape_test.go` | los tres campos de la `000003`, calculados por el servidor |
| `be-09` | `spin/race_test.go` | el stock bajo carrera |
| `be-10` | `spin/processing_test.go` | el giro cortado durante la entrega |
| `be-12` | `spin/clock_test.go` | el cierre dentro del giro |
| `be-13` | `reconciliation/stale_client_test.go` | la conciliación con datos viejos |
| `be-14` | `purchase/service_test.go` | la notificación duplicada |
| `be-17` | `spin/random_test.go` | dos arranques, dos secuencias |
| `be-18` | `http/free_spin_test.go` | el reloj del celular |

Portarlas encontró dos cosas que una regresión vieja suele esconder. La de `be-01` armaba el router sin reloj, y desde `be06` el middleware de `X-Server-Time` revienta con un puntero nulo: `NewRouter` usa ahora el reloj del sistema si no le pasan uno. Y la de `be-07` comprobaba que se guardara lo que mandaba la consola, lo que dejó de ser cierto en `be07`: ahora comprueba que los tres campos salgan del cálculo del servidor. **Una regresión que nadie corre deja de compilar en silencio, o sigue compilando y fija el comportamiento equivocado.**

```bash
TEST_DATABASE_URL="postgres://esclusa:esclusa@localhost:5432/esclusa_test?sslmode=disable" \
  go test -race -count=1 -p 1 ./...
```

```text
ok  	github.com/interoceanic-games/esclusa-api/internal/http	8.015s
ok  	github.com/interoceanic-games/esclusa-api/internal/player	0.316s
ok  	github.com/interoceanic-games/esclusa-api/internal/purchase	0.513s
ok  	github.com/interoceanic-games/esclusa-api/internal/reconciliation	0.312s
ok  	github.com/interoceanic-games/esclusa-api/internal/spin	17.069s
ok  	github.com/interoceanic-games/esclusa-api/internal/wheel	0.984s
```

Unos 30 segundos, la mayoría en `spin`, que recrea el esquema en cada caso y hace mil quinientos giros con `-race`.

> 🧠 **`-race` y las pruebas de carrera prueban cosas distintas.** `-race` detecta carreras **en la memoria del proceso** —el `*rand.Rand` de `be05` sin su mutex—. Las pruebas de carrera detectan carreras **en la base**, donde `-race` no ve nada, porque ahí no hay memoria compartida: hay dos transacciones. Hacen falta las dos.

### 5.6 Nivel 6: la carga, con la base mirando

`giro.js` de `be05` ya traía `thresholds`. Le falta la otra mitad, la que no depende de la máquina:

<<<archivo:server/load/invariantes.sql>>>

Medido con el binario en contenedor, la rueda de medición y k6 1.5.0:

| Corrida | k6 (`thresholds`) | Invariantes |
|---|---|---|
| fase, `pico` a 50 giros por segundo | 0 (p95 11,93 ms) | 0: 1.000 Esclusas |
| fase, 200 jugadores a la vez | **99** (p95 581,98 ms > 500) | 0: 1.000 Esclusas |
| `incidente/be-09`, 50 jugadores a la vez | 0 (p95 110,15 ms) | **3**: 1.500 Esclusas |

Las dos filas que importan son las de abajo. Con el código correcto y 200 jugadores a la vez, el umbral de latencia **falla** en esta máquina —en `be05` el p95 de ese escenario dio entre 333 y 509 ms—: un umbral de latencia es una afirmación sobre una máquina. Y con el código roto de `be-09`, k6 sale con 0 y las invariantes dicen que se entregaron 1.500 Esclusas de un stock de mil. **Una carga en verde no dice nada de la corrección**: por eso el nivel de carga termina en la base.

### 5.7 La suite, por niveles, desde la terminal

<<<archivo:server/Makefile>>>

> ⚠️ **`-count=1` en todos.** Go cachea resultados de pruebas, y una prueba de integración cacheada es una prueba que **no corrió** aunque diga `ok`. El `(cached)` es fácil de pasar por alto: es la segunda forma en que una suite miente.

### 5.8 🩻 El par contradictorio

Acá está el contenido central. Dos pruebas, las dos correctas, que se contradicen según el motor. Van al repositorio, explicadas, y detrás de una etiqueta: no corren en CI.

<<<archivo:server/internal/storage/engine_rule_test.go>>>

```bash
make test-engine TEST_DB="postgres://…/esclusa_test?sslmode=disable"
```

```text
--- SQLite ---
--- PASS: TestA_LastInsertId (0.01s)
    engine_rule_test.go:47: "[]" should have 1 item(s), but has 0
--- FAIL: TestB_InstantComparison (0.01s)
--- Postgres ---
    engine_rule_test.go:30: Received unexpected error: LastInsertId is not supported by this driver
--- FAIL: TestA_LastInsertId (0.13s)
--- PASS: TestB_InstantComparison (0.13s)
```

> 🧭 **Qué se hace con estas dos pruebas.** No se "arreglan": se **clasifican**. La A documenta una trampa —el código usa `RETURNING`, y `be03` explica por qué—. La B es la regla *"¿ya cerró?"* escrita en el `WHERE`, y por eso `be06` la resolvió en Go con `time.Time`. Clasificar cada prueba por el motor que necesita es el trabajo real de esta fase, y `server/evidence/regla-del-motor.md` es donde queda escrito.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. `t.Skip` cuando falta el entorno.** Síntoma: la suite dice `ok` y la concurrencia nunca se probó. Medido en `be07`: `spin` y `purchase` en `ok` sin `TEST_DATABASE_URL`. Fix: `OpenPostgres` y `MustPostgres` fallan.

**2. Truncar una tabla de solo inserción.** Síntoma: el helper de las pruebas revienta con `spin_log solo se agrega: TRUNCATE rechazado`. Causa: el disparador de `D35`. Fix: esquema nuevo por caso; nunca desactivar el disparador para probar.

**3. Migrar sobre el pool de la prueba.** Síntoma: *"quedaron 1 conexiones tomadas"*, o un pool que se agota en la suite larga. Causa: `postgres.WithInstance` retiene una conexión. Fix: migrar con un pool aparte y cerrarlo.

**4. Probar el servicio contra un store falso.** Síntoma: cobertura altísima y bugs en producción. Causa: cuando la lógica está en el SQL, un store falso prueba el doble. Fix: el servicio contra base real; los dobles, para el reloj, la tienda y los handlers.

**5. Una prueba estadística sin semilla en CI.** Síntoma: la suite falla una vez cada veinte corridas y alguien la marca como *"flaky"* y la desactiva. Fix: la semilla para la suite, la tolerancia calculada para entender (5.3).

**6. Prueba de concurrencia sin barrera.** Síntoma: pasa contra el código roto. Fix: el `WaitGroup` de barrera de `be05`. **La prueba de que tu prueba de concurrencia sirve es que falle contra el código vulnerable.**

**7. Aserciones sobre structs en vez de sobre JSON.** Síntoma: el contrato se rompe y la suite no se entera. Fix: en las pruebas de contrato, `map[string]interface{}` o los bytes.

**8. Un umbral de latencia como prueba de corrección.** Síntoma: la carga falla en tu laptop con el código bien, o pasa en el servidor de CI con el código roto. Medido: las dos cosas (5.6). Fix: los `thresholds` vigilan la latencia de una máquina; las invariantes, la corrección.

### 🩻 Pieza forense de esta fase

**El par contradictorio, y la suite que da permiso para desplegar.**

*Paso 1 — la contradicción, medida.* Corre `make test-engine` y pega las dos salidas en `server/evidence/regla-del-motor.md`. Cuatro resultados: A verde y B roja en SQLite; A roja y B verde en Postgres. Escribe al lado de cada una **por qué el motor tiene razón**.

*Paso 2 — la suite que miente, con tus manos.* En una rama descartable, cambia `t.Fatal` por `t.Skip` en `OpenPostgres` —*"para que la suite corra en cualquier máquina"*— y corre `go test ./...` sin `TEST_DATABASE_URL`. Todo `ok`. Ahora corre `go test -v ./internal/spin/ | grep -c SKIP` y cuenta lo que no se probó. Esa es la mitad del incidente `be-15`; la otra mitad es lo que se cuela por ese agujero.

*Paso 3 — la concurrencia, que ni siquiera puede fingirse.* `be05` §6 ya lo midió: la carrera del stock contra SQLite da **1.000 Esclusas y stock en 0** con el código de la fase **y** con el de `be-09`. Contra Postgres, `be-09` entrega 1.500. Escribe en cuatro líneas por qué la propuesta *"quitemos el `FOR UPDATE` para que las pruebas corran en cualquier lado"*, que suena razonable, desmantela `be05` entero.

*Paso 4 — la prueba que se prueba a sí misma.* Corre `TestStockNeverExceeded` contra la rama `incidente/be-09`. **Tiene que fallar**, y falla con *"entregadas 1500, sustitutos 0, stock 919"*. Si pasara, la prueba no serviría.

*Paso 5 — la carga que miente.* Corre el nivel de carga contra la misma rama, con 50 jugadores a la vez: k6 sale con 0, las invariantes con 3. Pega las dos salidas una al lado de la otra. Es la pieza que convence a quien cree que *"lo probamos con k6"* es lo mismo que *"está bien"*.

---

> 📓🔥 De esta fase sale el incidente **be-15** ⭐ de `cuaderno-incidentes-be.md`, hermano del **20** del track base. Los dos enseñan lo mismo desde orillas opuestas: allá la suite está **roja** y dice la verdad; acá lleva tres semanas en **verde** y miente.

---

## 🧪 7. Ejercicios (32)

**🟢 Fácil (1–8)**

1. Crea la base `esclusa_test` en tu Postgres de contenedor y corre `make test-all` con su URL.
2. Corre `make test-unit` y comprueba cuánto tarda la segunda vez, con la caché de compilación caliente.
3. Corre `go test ./...` sin `TEST_DATABASE_URL` y lee el mensaje de cada paquete que falla.
4. Ejecuta `make test-engine` y pega las cuatro salidas.
5. Comprueba que `OpenPostgres` se niega a correr si `TEST_DATABASE_URL` apunta a la base `esclusa`.
6. Corre `go test -race ./...` contra Postgres y confirma que pasa limpio.
7. Corre `make test-handler` y rompe a propósito un mensaje en el handler del giro. Mira qué caso falla.
8. Corre `go test ./...` dos veces seguidas sin `-count=1` y encuentra el `(cached)`.

**🟡 Intermedio (9–19)**

9. Corre la prueba sembrada de 5.3 con `-count=50` y comprueba que el χ² no cambia. Después cambia la semilla y anota el nuevo.
10. **Diagnóstico.** Quita `-count=1` de `test-all`, rompe el código, y comprueba que la suite sigue diciendo `ok`. Explica el mecanismo.
11. Escribe la prueba de contrato que verifica que `GET /spinLog?wheelId=4` devuelve `[` y no `null` para una rueda sin giros.
12. **Diagnóstico.** Escribe la aserción de tipos contra un struct tipado y demuestra que no detecta un `id` que llegue como string.
13. Agrega a la suite de contrato el alta de una rueda (`POST /wheels`) y su `201`. Explica qué incidente habría atrapado.
14. **Diagnóstico.** Vuelve a migrar sobre el pool de la prueba (sin el pool aparte de 5.1) y corre la regresión de `be-05`. Explica el número que da.
15. **Diagnóstico.** Intenta el truncado entre casos de 4.4 y copia el error. Explica por qué no se desactiva el disparador.
16. Corre la suite con `go test -shuffle=on` diez veces y determina si alguna prueba depende del orden.
17. Mide cuánto tarda recrear el esquema por caso en tu máquina y cuántas pruebas lo hacen. Calcula qué parte del tiempo de la suite se va en eso.
18. Agrega una prueba de handler para `claimFreeSpin`, con el doble del servicio: `200`, `404` y el `409` con su `nextFreeSpinAt`.
19. Mide la cobertura con `go test -cover` y anota el número. No lo persigas: úsalo para encontrar un archivo que nadie ejecuta.

**🟠 Difícil (20–27)**

20. **Diagnóstico.** Ejecuta el paso 2 de la pieza forense completo y escribe el informe: cuántas pruebas se saltaron, y en qué paquetes.
21. **Diagnóstico.** Ejecuta los pasos 4 y 5 y explica, con las dos salidas, por qué una prueba de carrera y un nivel de carga no se sustituyen.
22. Completa `regla-del-motor.md` con la clasificación de **cada** prueba de tu suite por el motor que necesita.
23. Encuentra una tercera divergencia de `be02` que se pueda convertir en prueba contradictoria y agrégala al par. Justifica en qué categoría de las cuatro cae.
24. Cambia los `thresholds` de `giro.js` para que el nivel de carga no dependa de la máquina —o argumenta por qué no se puede— con tus mediciones.
25. Escribe la prueba del apagado ordenado de `be01`: una petición en vuelo, un `SIGTERM`, y la respuesta completa.
26. **Diagnóstico.** Introduce a propósito una regresión de contrato en un endpoint y comprueba que la suite la atrapa. Si no, escribe la prueba que faltaba.
27. Mide cuánto tarda cada nivel y decide qué correría en cada momento: al guardar, antes de un commit y en CI.

**🔴 Muy difícil (28–32)**

28. Diseña el mecanismo que impide que alguien agregue una prueba de base sin `testsupport`: una convención verificada por un script o un análisis propio de `go vet`. Impleméntalo.
29. Argumenta si SQLite debería seguir en el proyecto. Defiende primero eliminarlo —una sola verdad, cero falsos positivos— y después conservarlo, y decide con un criterio operativo.
30. **Diagnóstico + regresión.** Ticket: *"la suite lleva tres semanas en verde y ayer se rompió el alta de ruedas en producción"*. Reconstruye las tres hipótesis más probables, di cómo descartas cada una, y escribe la prueba que faltaba.
31. Diseña una prueba basada en propiedades del sistema completo: para cualquier secuencia de giros, compras y reclamos de giro gratis, ningún saldo queda negativo, ninguna clave da dos giros y el stock no se excede. Con generación aleatoria y semilla fija.
32. **Post-mortem.** Escribe el post-mortem de *"la suite verde autorizó un despliegue roto"* según los ocho puntos del post-mortem de `cuaderno-incidentes.md`, con la causa raíz en el motor de pruebas. **Sin culpas**: usar SQLite en las pruebas es una práctica extendida y razonable. La prevención tiene que ser un mecanismo, no una advertencia.

**🔥 Opcionales**

- 🔥 Escribe una prueba de *fuzzing* con `go test -fuzz` sobre `ReconcilePurchases` y sobre el parseo de `closesAt`. Anota qué encontró.
- 🔥 Corre pruebas de mutación sobre `reconciliation/audit.go` y compara el resultado con tu cobertura.
- 🔥 Sustituye el contenedor de pruebas por `testcontainers-go` y compara: menos guion, una dependencia más, arranque más lento.

---

## 📚 8. Referencias

**Documentación oficial**
- https://pkg.go.dev/testing — `T.Helper`, `T.Cleanup`, subpruebas y `-shuffle`.
- https://pkg.go.dev/net/http/httptest — `NewRecorder`, el nivel 2 entero.
- https://go.dev/doc/articles/race_detector — qué detecta `-race` y qué no.
- https://go.dev/blog/subtests — el patrón de tabla con subpruebas que usa toda esta fase.
- https://pkg.go.dev/github.com/stretchr/testify/require — `require` aborta; `assert` continúa.
- https://pkg.go.dev/math/rand#NewSource — la fuente sembrada de 5.3.
- https://www.sqlite.org/quirks.html — la fuente primaria de la regla del motor.
- https://grafana.com/docs/k6/latest/using-k6/thresholds/ — los umbrales de 5.6. La página es de la versión vigente: cambia `latest` por la `v1.5.x` antes de creerle.

**Libros**
- *Unit Testing: Principles, Practices, and Patterns* (Vladimir Khorikov) — su tratamiento de qué sustituir y qué no es exactamente 4.3.
- *Working Effectively with Legacy Code* (Michael Feathers) — una prueba es la que falla cuando el código está mal: el paso 4 de la pieza forense.

**Video / apoyo**
- Busca "table driven tests Go" y alguna charla sobre el detector de carreras de Go.

**Orden de lectura sugerido:** el blog de subpruebas → `httptest` para el nivel 2 → el artículo del detector de carreras antes de correr `-race` en serio → la página de `thresholds` de k6 antes de 5.6 → Khorikov cuando quieras la teoría.

> ⚠️ URLs, títulos y ediciones pueden haber cambiado: verifícalos. Las referencias a libros son de memoria y pueden ser inexactas. Las cifras de esta fase son de las corridas del 20/10/2026 en la máquina del autor. Cualquier discrepancia de versiones la resuelve `00-decisiones-y-versiones.md` §7.

---

## 🚀 9. Cierre y conexión con la siguiente fase

La mitad invisible del sistema quedó cubierta. Seis niveles, cada uno con su trabajo: lo que se puede probar sin base se prueba en un segundo, lo que depende del motor se prueba contra el motor de verdad, lo que depende de la concurrencia se prueba con una barrera, y la carga termina mirando la base. Las pruebas que necesitan Postgres fallan si no lo tienen, y la estadística no falla una de cada veinte veces.

Y quedó demostrada la regla que da nombre a la fase, con dos pruebas que se contradicen y las dos tienen razón.

`be09` cierra el track: la imagen, la decisión entre cgo y Go puro **con su medición**, la configuración por ambiente, las migraciones como paso previo del despliegue, y un workflow que corre esta suite contra Postgres. Con la separación de edades que hay que declarar: la aplicación es de 2022 y el pipeline es de hoy. Y después, el veredicto, con una decisión que no es tuya: la de 2028.

> **La señal de que quedó bien:** *"sé exactamente cuál de mis pruebas me estaría mintiendo si la corriera contra el otro motor, y tengo la salida que lo demuestra."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-be08-pruebas-y-la-regla-del-motor -m "be08 cerrada: \
> suite por niveles (unitario, handler, integración, contrato, concurrencia, carga); \
> MustPostgres falla en vez de saltar; par contradictorio medido en los dos motores; \
> prueba estadística sembrada; regresiones de los incidentes en la suite; \
> nivel de carga con thresholds e invariantes en SQL"
> ```
>
> Los commits de la fase llevan su prefijo (`be08: …`) y los de ejercicio su número (`be08 ej20: …`). Si un ejercicio merece su propio marcador va en `ej/be08/20`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` / `-fix`, con el ID que le reserva `cuaderno-incidentes-be.md`. Todo eso está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

*(Fuera de lo que lee el estudiante.)*

- **`D18` se cumple con un mecanismo**: `OpenPostgres` y `MustPostgres` fallan. **`D32`**: la tasa de alarmas del χ², medida otra vez en Go (3,6 % y 4,2 %). **`D37`**: `NewDrawerFrom` es solo para pruebas; el servidor sigue sembrando desde `crypto/rand`.
- **`be09` hereda la suite tal cual**: su trabajo es hacerla correr en CI, no reorganizarla. Los objetivos del `Makefile` son la interfaz que el workflow usa; `be09` les agrega `-tags sqlite`.
- **El par contradictorio es material de `bea-03`** (el diccionario de divergencias explica qué difiere; estas dos pruebas, qué cuesta) y la B, de `bea-06` §6.
- **El ejercicio 29 (¿sigue SQLite?) entra en el veredicto de `be09`.** La respuesta defendible del track es que sí, pero solo bajo la regla y con `MustPostgres` haciéndola cumplir.
- **La suite de contrato no crea ruedas** (la siembra va directo a la base), y por eso no habría atrapado `be-15`: es el ejercicio 13, y la prevención del incidente.
- **Deudas declaradas:** 💸 el contenedor de pruebas se crea a mano; 💸 no hay cobertura en CI, a propósito; 💸 los `thresholds` de latencia dependen de la máquina (ejercicio 24).
- **Reserva para el cuaderno de incidentes:** `be-15` ⭐ — *la suite lleva tres semanas en verde y ayer se rompió producción* (🔥 contrato, 🔴), hermano del 20 del track base.
