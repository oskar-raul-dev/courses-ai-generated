# 🗺️ Propuesta de fases y alcance — variante de reescritura
## Tutorial React 16 — La Esclusa, la consola de Jewel Locks

> ✏️ **Variante excepcional de la plantilla.** El curso ya existe completo (12 fases, 13 apéndices,
> track BE de 10 + 10 y dos cuadernos con 36 incidentes) y cambia de dominio: de **Rifas y Chances**
> a **la rueda de premios de Jewel Locks** (ver `../00-historia-del-sistema.md`, la historia v2 ya en su nombre). Por eso este
> documento no propone un arco desde cero: hace el **inventario** de qué se queda, qué sale y qué
> entra, fase por fase, para que el plan de tandas (paso 3) sepa cuáles **editan** y cuáles **crean**.
>
> **Precedencia:** debajo de la historia v2 (fuente de verdad narrativa: reglas, cifras, gente) y de
> la guía. **Fecha:** 06/10/2026. **Estado:** cerrada por el autor el 06/10/2026 (DR-01–DR-06, §8).

> 🧭 **La regla que ordena la reescritura:** *cada fase conserva lo que enseña —el concepto, la
> herramienta, la pieza forense, las horas— y cambia el caso.* Si una fase solo puede conservar su
> concepto cambiando el concepto, se dice aquí y se decide antes de escribir.

---

## 1. ✅ Decisiones de forma que no se reabren

**🪦 La estructura se conserva.** 12 fases base, 10 BE, los mismos números, las mismas horas, la
plantilla de nueve secciones, los cuadernos, el caos, el mock en 3001/3002 y el Go en 3001. Ninguna
fase se agrega ni se quita.

**🪦 Versión nueva para los que entran.** Igual que en Vue 2: los devs que ya van en el curso siguen
con la versión de Rifas y Chances (git la conserva); los cambios se aplican en el lugar.

**🪦 El código se renombra.** Mantener `raffle` en una consola de ruedas le mentiría al lector. El
contrato de nombres de §2 manda desde la primera tanda.

**🪦 Los apéndices no cambian de estructura.** Los que tocan el dominio cambian ejemplos, dos cambian
contenido (A10, A12) y entran dos nuevos: **A14** (estadística para auditar la rueda) y **bea-11**
(k6 101), por DR-01 y DR-04.

**🪦 La concurrencia se observa en el frontend y se resuelve en el backend.** El track base la sufre
desde la consola (envíos manuales, datos rancios, feed en vivo); el track BE la resuelve en el giro.
El mock imita el API heredado **con sus defectos**, incluido el giro ingenuo de 2019.

**🪦 Las cifras salen de corridas.** Las mediciones nuevas (duplicados del giro ingenuo, stock
excedido, conciliación de probabilidades) se publican con lo que dio el arnés, nunca de memoria.

---

## 2. 🔤 El contrato de nombres nuevo

| Antes (Rifas y Chances) | Ahora (Jewel Locks) | Código |
|---|---|---|
| rifa | rueda | `wheel`, `wheels` |
| número (de la rifa) | segmento | `segment`, `wheel_segments` |
| peso / precio por número | peso en puntos básicos | `weightBp` (suma 10.000) |
| premio base | premio (vidas, avatar, set de gemas) | `prize`, `prizeType` |
| participante | jugador | `player`, `players` |
| venta de un número | envío manual (consola) · giro (juego) | `grant` · `spin` |
| reserva temporal | ventana de deshacer de un envío | `undoWindow` |
| resultado de la lotería | resultado del giro (lo genera el servidor) | `spinResult` |
| liquidación | conciliación (de compras y de probabilidades) | `reconciliation`, `oddsAudit` |
| — | compra de giros (Google Play) | `purchase`, `purchaseToken` |
| — | saldo de giros (gratis / pagos) | `freeSpins`, `paidSpins` |
| — | inventario del jugador | `inventory` |
| — | bitácora de giros | `spin_log` / `spinLog` |
| — | stock de edición limitada | `stock` |
| vendedor, tesorería, soporte | operación (Itzel), soporte (Yariela), contadora (Marisol) | usuarios `ibatista`, `ypinzon`, `mdegracia` |
| `raffles-app` | `esclusa-app` | repo del alumno |
| `America/Bogota` | `America/Panama` | D29 |
| pesos (COP) | dólares (USD), centavos enteros | — |

Estados de una rueda: `draft → scheduled → live → ended → reconciled` (antes
`draft → open → closed → resolved → settled`). Una rueda en `live` no cambia sus pesos.

---

## 3. 🧭 Grados de cambio

| Grado | Qué significa | Qué hace la tanda |
|---|---|---|
| 🟢 **Renombre** | El texto y el código cambian de nombres; ninguna idea cambia | Edita, con revisión línea por línea (género: *la rifa* → *la rueda* se salva; *el número* → *el segmento/envío* no siempre) |
| 🟡 **Ejemplo nuevo** | El concepto y la sección se quedan; el caso, el código y los ejercicios se reescriben | Edita sección por sección |
| 🔴 **Reescritura de fondo** | El problema que la fase resuelve es otro; se conserva el concepto técnico y las horas | Crea la fase de nuevo sobre su esqueleto |
| ➕ **Nuevo** | Sección, incidente o documento que no existía | Crea |

---

## 4. 🧱 Track base, fase por fase

| Fase | Hoy | Con la rueda | Grado | Se queda | Sale | Entra |
|---|---|---|---|---|---|---|
| **00** Setup CRA | `RaffleCard` | `WheelCard` | 🟢 | Todo el setup (Node 14, CRA 4, dart-sass, arm64) | — | — |
| **01** Estructura + Router 5 | Lista/detalle de rifas hardcodeados | Lista/detalle de ruedas con segmentos; placeholders de *Jugadores* y *Bitácora* | 🟢 | Clase con `withRouter` vs hooks, el 404, la pieza forense | — | Dos rutas placeholder |
| **02** Auth mínima | Usuarios vendedores | Operadores de la consola (`ibatista`, `ypinzon`, `mdegracia`) | 🟢 | Interceptors, `PrivateRoute`, `requestId`, la deuda de persistencia | — | La deuda 💸 "cualquiera con usuario puede enviar giros" (ya en historia §11) |
| **03** Mock + caos | `db.json` de rifas; mock de lotería en 3002 | `db.json` de ruedas, jugadores, inventarios y compras; **el giro ingenuo de 2019** como ruta Express; **mock de Google Play** en 3002 (verificación, compras pendientes, notificación duplicada); **generador de tráfico** | 🔴 | El inyector de caos, los pagos de deuda #1 y #2, la prueba de fuego | La lotería | `POST /players/:id/spins` ingenuo; `scripts/traffic.js` (N jugadores girando) |
| **04** CRUD | Rifas | **Ruedas y segmentos**: validación de pesos enteros que suman 10.000; la regla "en `live` no se editan pesos" | 🟡 | Los errores que el slice maneja, la respuesta malformada, error legible, clase + hooks, time-travel | — | Validación de suma en puntos básicos |
| **05** Concurrencia y UI optimista | Venta de números en la grilla de 10.000, reserva con `setTimeout` | **Envíos manuales**: compensar a un jugador o a una lista de afectados; **ventana de deshacer** de 10 s con `setTimeout` honesto; dos operadores compensan el mismo caso; envío masivo que falla a medias | 🔴 | Máquina de estados (ahora de un envío: `queued → sending → sent / failed → reverted`), optimistic + rollback, el `setTimeout` honesto, corrección mínima vs refactor, la pieza forense de la race en el store | La grilla de 10.000 | El tablero del envío masivo (miles de filas: el problema de render se conserva) |
| **06** redux-observable | Epics de la venta | `undoWindowEpic` (jubila los timers 🪦), `sendGrantEpic` (doble clic, `exhaustMap`), `searchPlayerEpic` (`debounceTime` + `switchMap`), `retryGrantEpic`, `cancelOnLogoutEpic`; el memory leak provocado | 🟡 | Todos los operadores y la pieza forense | — | — |
| **07** Hora dura + polling | Cierre de la rifa + polling de la lotería | **Cierre del evento a hora exacta** (no se envían giros de una rueda `ended`) + **polling de compras pendientes** (Efecty/OXXO, minutos a 48 h) | 🔴 | "El cierre es un instante", polling con `timer`, `switchMap` vs `mergeMap`, `catchError` por tick, la pieza forense | La lotería | `apiStore.js` (instancia del mock de Google Play) |
| **08** Dinero | Liquidación y premio en centavos de peso | **Conciliación**: (1) de compras en USD —precio del paquete prorrateado por giro (20,99/500), comisión de la tienda, el reporte que no cuadra—; (2) ➕ **de probabilidades**: `oddsAudit(counts, weightsBp)` con banda de ±3σ y chi-cuadrado | 🔴 + ➕ | `money.js`, enteros, la transición irreversible (`ended → reconciled`), `prizeShare` (reparto sin perder centavos) | El premio en pesos y su migración | `oddsAudit.js` (función pura, enteros); landed vs entregado; la teoría, en A14 (DR-01) |
| **09** Dashboard | Ventas y margen | Giros gratis / pagos / manuales, ingresos, **observado contra configurado** con la banda por segmento | 🟡 | Derivar en selectores, chart.js 2 sin wrapper, la pieza forense de `useMemo` | — | El gráfico de la banda |
| **10** Testing | Pruebas de `saleSlice`, `dashboardMath`, epics | Las mismas sobre `grantSlice`, `dashboardMath`, epics; ➕ **probar algo aleatorio sin que la prueba sea intermitente** (generador sembrado + tolerancia calculada) sobre `oddsAudit` | 🟡 + ➕ (era 🟢; T6: ninguna prueba sobrevivía al renombre) | Los niveles, marbles, Cypress | — | Sección 5.x nueva |
| **11** Cierre + puente | `RaffleTable` a hooks; RxJS 7; React 17/18 | `WheelTable` a hooks; ➕ **el horizonte de dos años**: decomisionar (editor de Unity) o migrar, con criterios medibles | 🟡 + ➕ (era 🟢; T6) | Todo el concepto de deuda deliberada, hotfix vs refactor | — | El veredicto de los dos años en §9 |

**Resumen del track base:** 4 🔴 (03, 05, 07, 08), 3 🟡 (04, 06, 09), 5 🟢 (00, 01, 02, 10, 11),
con tres secciones ➕ (08, 10, 11).

---

## 5. 🐹 Track BE, fase por fase

| Fase | Hoy | Con la rueda | Grado | Entra |
|---|---|---|---|---|
| **be00** Contrato | Auditoría del mock de rifas | Auditoría del mock de la rueda: el contrato **incluye el giro ingenuo** y sus defectos como hallazgos | 🟡 | Hallazgos nuevos (el giro sin idempotencia, el stock que se descuenta después) |
| **be01** Go y el monolito | — | — | 🟡 (era 🟢; T7: el pánico sin `recover` no tumba el proceso, medido; el caos replica al mock nuevo; `be-01` pasa acá) | — |
| **be02** Costura de datos | Tablas de rifas; "por qué `numbers` se llama `raffle_numbers`" | Tablas `wheels`, `wheel_versions`, `wheel_segments`, `players`, `player_inventory`, `purchases`, `spin_log`; el nombrado nuevo | 🟡 | Versión de pesos como tabla propia |
| **be03** CRUD y reemplazo | CRUD de rifas, siembra, 🪦 el momento | CRUD de ruedas y jugadores; 🪦 el momento igual | 🟡 | — |
| **be04** JWT y CVE | Transiciones de la rifa | Transiciones de la rueda; el operador del envío sale del contexto | 🟢 con una sección 🟡 (T7: transiciones, `sent_by`, la segunda vuelta de `govulncheck`) | — |
| **be05** Concurrencia | La venta concurrente: hecho, `FOR UPDATE`, pesimista vs optimista medido | **El giro concurrente**: (1) idempotencia por clave del cliente, (2) saldo con descuento condicional, (3) **stock de edición limitada** como fila caliente; pesimista vs optimista medido; ➕ **arnés de carga** (k6 o vegeta en contenedor) que reproduce la Semana del Canal a escala | 🔴 + ➕ (T8: medido con k6; el pedido aparte en `spin_requests`, el sustituto por stock agotado y la unicidad del caso del envío entran aquí) | D28 pasa a "el giro se modela como hecho"; la bitácora de solo inserción nace aquí |
| **be06** Hora dura | Cierre por reloj; zona de Bogotá | Cierre del evento por reloj; ➕ **el giro gratis cada 4 h**: el reloj del celular no manda (la trampa de adelantar la hora); zona de Panamá; jugadores con horario de verano (Chile) y una zona que cambió por ley (Paraguay, 2024) | 🟡 + ➕ (T9: el cierre dentro de `decide`, el barrido de cierre, el giro gratis por reclamo con escritura condicional, la zona forzada en el DSN, la base de zonas medida en dos imágenes) | D29 con Panamá |
| **be07** Dinero transaccional | Liquidación: recaudo y reparto como hechos | **Compras**: acreditar giros e ingreso en una transacción, idempotente por `purchaseToken` (la notificación duplicada); ➕ **la conciliación de probabilidades en SQL** (`GROUP BY wheel_version, landed_segment`) y la **protección de duplicados** que reemplaza a la rueda que se acomoda | 🔴 + ➕ (T9: la compra por el juego y por la notificación con `purchase_requests`, índice único parcial sobre el duplicado histórico, conciliación recalculada igual a la de la consola, `GET /wheels/:id/audit`, el arnés de be05 a un giro por jugador; `purchase_token` de los giros pagos, a deuda) | Endpoint de auditoría |
| **be08** Pruebas | Cinco niveles, regla del motor, `-race` | Igual; ➕ prueba estadística con generador sembrado; ➕ nivel de carga con el arnés de be05 | 🟢 + ➕ | — |
| **be09** Empaquetado | Imagen, ambientes, pipeline, veredicto | Igual; el veredicto incorpora el horizonte de dos años | 🟢 | — |

**Resumen del track BE:** 2 🔴 (be05, be07), 4 🟡 (be00, be02, be03, be06), 4 🟢 (be01, be04, be08,
be09), con cinco piezas ➕.

> 💡 **La trampa de Go 1.19 nace en be05 y se descubre en be-17.** Sin `rand.Seed`, el generador global de `math/rand`
> arranca siempre con la misma semilla (Go 1.20 cambió eso). Con la versión congelada del curso, cada
> reinicio repite la secuencia de premios. La conciliación de probabilidades **no lo ve** —las
> frecuencias dan perfectas—, y esa es la lección. Por DR-02 es el incidente be-17; be05 lo reserva.

---

## 6. 📎 Apéndices

Revisados los 23. **Ninguno cambia de estructura y ninguno se quita**; entran dos (abajo). El grado:

| Apéndice | Grado | Qué cambia |
|---|---|---|
| A1 Bootstrap y Sass | 🟢 | Ejemplos con componentes de rueda |
| A2 Mini design system | 🟢 | "Mixins del dominio de rifas" → de la rueda (segmento, premio, estado del envío) |
| A3 Node y npm · A4 CRA por dentro · A9 Entornos · A13 Build de producción | 🟢 | Casi nada (`logo-lottery.png`, nombres de repo) |
| A5 Clases vs hooks · A6 Redux clásico vs Toolkit · A8 Puente a React moderno · A11 Marbles | 🟢 | Ejemplos renombrados (`RaffleTable` → `WheelTable`, `saleSlice` → `grantSlice`) |
| A7 redux-observable épica por épica | 🟡 | Los ejemplos de cada operador siguen a las épicas nuevas de F06 |
| **A10 Aritmética de dinero** | 🟡 | Pesos → dólares; §5 "migrar un sistema que guarda pesos" → "que guardaba dólares en float"; el prorrateo del paquete (4,198 centavos por giro) como caso de §4; micros como unidad de los reportes de anuncios |
| **A12 Mapa de deuda** | 🟡 | Deudas nuevas: la rueda que se acomoda, la consola que no conoce la regla, sin bitácora, el giro sin transacción en el API heredado, la bitácora sin paginación; cada una marcada como *se paga antes del corte / muere con el decomiso / se paga al migrar* |
| bea-01, bea-03, bea-04, bea-07, bea-08 | 🟢 | Renombre |
| bea-02 Receta de imagen | 🟢 | `rifas-pg` → `esclusa-pg`; el *bonus* de `America/Bogota` → `America/Panama` |
| bea-05 Concurrencia en Postgres | 🟡 | "Cuándo usar qué: vender un número" → girar y descontar stock |
| bea-06 Tiempo, zonas y relojes | 🟡 | Panamá; §7 "el reloj del cliente" crece con la trampa del celular |
| bea-09 Mapa de deuda BE | 🟡 | Deudas nuevas del giro y de la bitácora |
| bea-10 Datos de prueba | 🟡 | Faker de jugadores, inventarios y giros; "fijar la semilla" conecta con la trampa de Go 1.19 |

**Los dos ➕ que entran** (DR-01 y DR-04):

| Apéndice | Lo usan | Qué cubre | Horas |
|---|---|---|---|
| **A14 — Estadística mínima para auditar una rueda** | F08, F09, F10 · be07 | Ley de grandes números, binomial, banda de ±3σ, chi-cuadrado sin tabla (el valor crítico se da hecho), por qué conciliar frecuencias no prueba que el aleatorio sea impredecible, y cuánta muestra hace falta para un segmento raro | ~3 |
| **bea-11 — k6 101** | be05, be08 | Instalar nada: k6 en contenedor; el script mínimo; escenarios (`constant-arrival-rate` para el pico de la Semana del Canal); `checks` y `thresholds`; leer el resumen (p95, iteraciones, fallos); los tres errores que dan números falsos (medir el generador, no el servidor; el calentamiento; la red del contenedor) | ~3 |

El aleatorio de Go (`math/rand` contra `crypto/rand`, semillas, sesgo del módulo) **no** lleva
apéndice: vive en be05 §4 y en el incidente be-17 (DR-02).

---

## 7. 📓 Cuadernos de incidentes

Los IDs se conservan; los títulos y los tickets se reescriben con la voz de la gente de la historia
(Yariela, Itzel, Marisol). Los nuevos toman IDs libres al final.

### Track base (20 → 21)

| ID | Hoy | Con la rueda | Grado |
|---|---|---|---|
| 01, 02, 03, 05, 06, 07, 08, 10, 20 | Setup, router, auth, caos, tests | Igual, con nombres nuevos | 🟢 |
| 04 | Entro al detalle de otra rifa y sigo viendo la anterior | …de otra rueda… | 🟢 |
| 09 | Guardo la rifa, se recarga y pierdo todo | Guardo la rueda… | 🟢 |
| 11 ⭐ | Vendimos el número 0347 dos veces | **Compensamos dos veces a la misma jugadora**: en la consola, el doble clic sin guarda de origen; en el servidor, el chequeo del caso no atómico (que con dos operadores tampoco alcanza) | 🔴 |
| 12 | Un número vendido volvió solo a disponible | **Un envío que ya estaba enviado volvió a «falló»** (el rollback del envío masivo, que busca por caso, pisó la confirmación del individual) | 🟡 |
| 13 | Falló una venta y desde entonces no funciona ninguna | Falló un envío y desde entonces no sale ninguno | 🟢 |
| 14 ⭐ | Cerré sesión y el servidor sigue recibiendo peticiones | Igual (el polling de compras pendientes) | 🟢 |
| 15 | Escribo el número rápido y me valida uno viejo | **Busco a la jugadora rápido y me muestra a otra** | 🟡 |
| 16 | La rifa siguió vendiendo después del cierre | **Seguimos enviando giros de una rueda que ya cerró** | 🟡 |
| 17 | El resultado nunca llega y no hay error | **La compra pendiente nunca se confirma y no hay error** | 🟡 |
| 18 | La liquidación da un centavo de diferencia | **La conciliación da un centavo**: el prorrateo del paquete de 500 | 🟡 |
| 19 | El dashboard se arrastra al final del día | …al final de la Semana del Canal; en T6 el mecanismo pasó a los chequeos de desarrollo de Toolkit sobre la bitácora (el `useMemo` quedó como pieza forense de F09) | 🟡 |
| ➕ 21 | — | **"La rueda dice 15 % y el tablero muestra 5 %"**: la rueda que se acomoda, vista en el tablero de F09 (termina en diagnóstico y en una decisión, no en un commit). En T6 el síntoma pasó del 2 % de la Esclusa de Oro —una tabla artificial de P7— al del mecanismo de la historia §5: el avatar común se desploma | ➕ |

### Track BE (16 → 18)

| ID | Hoy | Con la rueda | Grado |
|---|---|---|---|
| be-15 ⭐, be-16 | Regla del motor, imagen | Igual, con nombres nuevos | 🟢 |
| be-01 | La trazabilidad funciona en Network pero no en la consola | Igual, **en be01** (T7): el mock expone el header desde F02; lo olvida el CORS del binario | 🟡 |
| be-03 | El backend se cae solo y vuelve | **A ratos la consola da error de red, y el servidor nunca se cayó** (T7: `net/http` recupera el pánico y corta la conexión; lo dispara el asistente al abrirse) | 🟡 |
| be-05 | Todo funciona hasta que hay gente | Igual; el `Rows` sin cerrar está en el chequeo de caso del envío, sin contexto (T7: la receta de P6 no reproducía); de be02, rama desde be03 | 🟡 |
| be-08 | A algunos los saca de la sesión al mediodía | **A Yariela la saca de la sesión a las ocho de la noche, y a Itzel nunca** | 🟢 |
| be-02 | El número ganador no tiene dueño | **El premio entregado no tiene rueda** (T7: las filas del giro de 2019 sin `wheelId`; el tablero no las ve) | 🟡 |
| be-04 | Las rifas se crean con la hora corrida | **Las ruedas aparecen con la hora corrida** (T7: el `DATABASE_URL` sin la zona de la sesión; de be02, rama desde be03) | 🟢 |
| be-06 | El comprador aparece en blanco | **El tablero dice que nadie compró giros** (T7: `origin` como `sql.NullString`) | 🟡 |
| be-07 | Faltan datos en las liquidaciones de agosto | **Faltan datos en las conciliaciones** (T7: `bandAlarms`, `missingInApi`, `duplicatedInApi`) | 🟡 |
| be-09 ⭐ | Vendimos tres números dos veces, y solo los redondos | **Otra vez más Esclusas de Oro que stock, y el contador dice que sobran** (T8: el `FOR UPDATE` quitado por "optimización" y el valor calculado en Go) | 🔴 |
| be-10 | Un número quedó reservado para siempre | **Un giro quedó "en proceso" para siempre** (T8: el pedido en `spin_requests`, sin fecha límite y sin barrido) | 🟡 |
| be-11 | A los vendedores de la costa se les cierra una hora antes | **A los jugadores de Chile la rueda les cierra una hora antes** (T9: la teoría del ticket es el horario de verano; la causa, el reloj del cliente; diff vacío, con `cy.clock`) | 🟡 |
| be-12 | Vendimos doscientos números después del cierre | Giros anotados después del cierre (medidos: 5 a 108) | 🟢 |
| be-13 | La liquidación dice 340.000 y las ventas 355.000 | La conciliación y el reporte de la tienda no dan lo mismo (T9: el servidor guarda la foto de la consola; `tok-ago-31` acreditada con la pantalla abierta) | 🟡 |
| be-14 | Repartimos el premio dos veces | **Acreditamos la compra dos veces** (T9: la acreditación en pasos sueltos; el `UNIQUE` salta después de sumar los giros: 60 contra 20) | 🟡 |
| ➕ be-17 | — | **Cada vez que reiniciamos, la rueda da los mismos premios** (`math/rand` sin semilla en Go 1.19; T8: el sorteo "simplificado" al generador global) | ➕ |
| ➕ be-18 | — | **Hay jugadores que cobran el giro gratis cada hora** (T9: `X-Client-Now` leído en el reclamo) | ➕ |

---

## 8. ✅ Decisiones cerradas

Cerradas por el autor el 06/10/2026. Se citan por su ID en el plan y en los prompts.

| ID | Decisión | Consecuencia |
|---|---|---|
| **DR-01** | **A14 entra** | La teoría estadística sale de F08; F08 la usa y remite |
| **DR-02** | **La trampa de Go 1.19 es el incidente be-17**, no una sección | be05 usa `math/rand` sembrado de forma explícita (o `crypto/rand`) sin contar por qué; el incidente lo descubre. be05 lo reserva en sus 📌 |
| **DR-03** | **El incidente 21 es del cuaderno base** | Se reserva en F09 (lo ve el dashboard); su arreglo de fondo se nombra como trabajo del backend |
| **DR-04** | **El arnés de carga es k6**, y entra **bea-11 — k6 101** | Imagen oficial `grafana/k6` con versión fijada en la verificación previa; nunca `latest` |
| **DR-05** | **Se renombran archivos y tags** a los nombres correctos | Tabla de §8.1; `00-convencion-de-git-y-tags.md` y todos los enlaces se alinean en la misma tanda que renombra |
| **DR-06** | **No más de 10 horas nuevas en total** | Tabla de §8.2 |

### 8.1 Los renombres de archivo (DR-05)

| Hoy | Nuevo | Tag de cierre |
|---|---|---|
| `04-rifas-crud.md` | `04-ruedas-crud.md` | `fase-04-ruedas-crud` |
| `05-venta-de-numeros.md` | `05-envios-manuales.md` | `fase-05-envios-manuales` |
| `07-cierre-polling-resultado.md` | `07-cierre-polling-compras.md` | `fase-07-cierre-polling-compras` |
| `08-liquidacion-calculo-premio.md` | `08-conciliacion.md` | `fase-08-conciliacion` |
| `be05-venta-concurrente.md` | `be05-giro-concurrente.md` | `fase-be05-giro-concurrente` |
| `be07-liquidacion-dinero-entero-y-transaccional.md` | `be07-compras-y-conciliacion.md` | `fase-be07-compras-y-conciliacion` |
| `00-historia-del-sistema-v2.md` | `00-historia-del-sistema.md` (reemplaza a la vieja) | — |
| — | `A14-estadistica-para-auditar-una-rueda.md` | — |
| — | `bea-11-k6-101.md` | — |

Los demás archivos conservan su nombre. Los tags de las fases que no cambian de archivo conservan el
suyo; los que nombraban el dominio viejo en el slug se corrigen igual (se listan en la tanda que toca
la convención de git). El repo del alumno pasa de `raffles-app` a `esclusa-app`.

### 8.2 Las horas (DR-06)

| Pieza | Antes | Ahora | Δ |
|---|---|---|---|
| F08 Conciliación | 8 h | 10 h | +2 |
| be05 El giro concurrente | 10 h | 12 h | +2 |
| A14 (nuevo) | — | ~3 h | +3 |
| bea-11 k6 101 (nuevo) | — | ~3 h | +3 |
| **Total** | | | **+10** |

El track base pasa de 96 a **98 horas** de fases y el BE de 84 a **86**; los apéndices se cuentan
aparte, como hoy. Ninguna otra fase cambia sus horas: si una reescritura no cabe en las suyas, se
recorta su alcance, no se suben las horas.

---

## 9. 📏 El tamaño, dicho de frente

| Bloque | Líneas hoy | 🔴 | 🟡 | 🟢 | ➕ |
|---|---|---|---|---|---|
| Fases base | ~8.500 | 4 (~3.220) | 3 (~2.150) | 5 (~3.170) | 3 secciones |
| Fases BE | ~9.200 | 2 (~1.640) | 4 (~3.730) | 4 (~3.800) | 5 piezas |
| Apéndices (23 → 25) | ~11.000 | — | 7 | 16 | 2 (A14, bea-11) |
| Cuadernos | ~8.800 | 2 incidentes | 11 | 23 | 3 incidentes |
| Raíz (README, alcance, decisiones, convención de git, historia) | ~1.800 | alcance §5 | decisiones, README | convención de git | historia v2 (hecha) |

Lo 🔴 y lo 🟡 suman cerca de la mitad del corpus, como se había estimado. Lo 🟢 es mecánico pero
**no se hace con buscar y reemplazar**: el género y los ejemplos numéricos (`0347`, `$500.000`) se
revisan a mano.

## 10. 📏 Cifras de referencia de la verificación previa (P7, 14/10/2026)

Lo que P7 midió en contenedor, para que cada fase tenga un punto de comparación. Son
**referencia**, no lo que se publica: cada fase publica las cifras de **su** corrida
(plan §5.1). Detalle y comandos en `zz-code/react-16-legacy-for-backend-devs-20261014-f462/`.

| Fase | Qué se mide | Referencia de P7 |
|---|---|---|
| F03 (y be00, be05) | Giro ingenuo: 1.500 claves, 50 VUs, cada clave enviada dos veces, stock 1.000 | 1.014 premios, 495 claves con dos premios, 14 de stock excedido |
| F03 (y be05) | Giro transaccional, misma carga | 1.000 premios, 0 dobles, 0 excedido, p95 54 ms (el ingenuo, 89 ms) |
| F08 y A14 | `oddsAudit` sobre 20.000 giros, 300 corridas por escenario | Rueda honesta: alarma en 6 % (banda y chi-cuadrado juntos). Rueda que se acomoda: 100 % |
| F08 | Prorrateo de 20,99 USD entre 500 giros, en centavos enteros | 2.099 centavos exactos: base 4, +1 en 99 giros |
| be05 y incidente be-17 | `math/rand` sin semilla, dos arranques | Go 1.19.13 repite la secuencia; Go 1.20.14 no |
| be09 | Pipeline validado con actionlint 1.7.9 | `actions/checkout@v3` es demasiado viejo: usar v4 o superior |

La tasa de falsas alarmas del chi-cuadrado (≈ 5 % por diseño con α = 0,05) es la que A14
debe decir, y la banda sola queda por medir.
