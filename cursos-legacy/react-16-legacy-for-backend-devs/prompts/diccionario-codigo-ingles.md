# 📖 Diccionario de código: español → inglés
## Tutorial React 16 — La Esclusa, la consola de Jewel Locks

Documento operativo, complementario a `prompts/guia-de-estilo-y-convenciones.md`
§4. Úsalo mientras escribes código nuevo o reescribes una fase.
Regla de una línea: **el código en inglés, todo lo demás (comentarios,
narrativa, textos de interfaz) en español.**

> 🧭 **Vigencia: reescritura de 2026.** El contrato de nombres de §2 es el de
> `propuesta-fases-y-alcance.md` §2, adoptado aquí completo (P5). La versión
> anterior, de Rifas y Chances, sigue en git y no se consulta para nombrar nada
> nuevo. Los ejemplos de §5 muestran cómo se ve el código viejo (*antes*) y el
> nuevo (*después*).

---

## 1. Qué se traduce y qué no (referencia rápida)

| Cosa | ¿Traducir a inglés? | Ejemplo |
|---|---|---|
| `function nombreDeFuncion()` | ✅ Sí | `function sendGrant()` |
| `const variable = ...` | ✅ Sí | `const isLoading = false` |
| Propiedad de estado / prop | ✅ Sí | `state.wheels.items`, `<WheelForm initialWheel={...} />` |
| Endpoint / ruta de API | ✅ Sí | `apiClient.get('/wheels')` |
| Nombre de componente / archivo | ✅ Sí | `WheelTable.jsx` |
| Nombre de slice / epic | ✅ Sí | `wheelSlice.js`, `pollingEpic.js` |
| `action type` (Redux clásico) | ✅ Sí | `SEND_GRANT` |
| Valor de enum / status interno | ✅ Sí | `status: 'live'` |
| Clase CSS/Sass propia del proyecto | ✅ Sí | `.wheel-card` |
| `data-testid` | ✅ Sí | `data-testid="segment-landed"` |
| `// comentario explicando el porqué` | ❌ No | se queda en español |
| Texto que ve el usuario (`<button>`, `alert`, `label`) | ❌ No | `"Enviar premio"` |
| Valor de un mensaje de error legible | ❌ No | `{ message: 'No se pudo cargar la rueda' }` — la *key* en inglés, el *valor* en español |
| `case` de un mapeo estado→etiqueta | ⚠️ Parcial | `case 'live': return 'En vivo'` — el `case` en inglés, el `return` (lo que ve el usuario) en español |
| Nombre del dominio en la narrativa/prosa | ❌ No | sigues hablando de "rueda", "segmento", "conciliación" |
| Nombres de fase, archivo `.md`, títulos | ❌ No | siguen en español (`05-envios-manuales.md`) |

---

## 2. Diccionario del dominio (La Esclusa, Jewel Locks)

Los términos siguen la lista de la propuesta §2. Cuando una columna de la
propuesta dice «propuesto», el nombre no está cerrado por el autor: se usa en
la tanda que lo necesita, y se confirma ahí antes de la primera fase que lo
escribe.

### 2.1 Entidades principales

| Español | Inglés (código) | Nota |
|---|---|---|
| rueda / ruedas | `wheel` / `wheels` | sustituye a *rifa* |
| segmento / segmentos | `segment` / `segments` | sustituye a *número* de la rifa |
| peso (de un segmento) | `weightBp` | en puntos básicos; los pesos de una rueda suman 10.000 |
| premio | `prize` / `prizeType` | el tipo: vidas, avatar, set de gemas (propuesto: `lives`, `avatar`, `gemSet`) |
| jugador / jugadores | `player` / `players` | sustituye a *participante* |
| envío manual (consola) | `grant` | sustituye a *venta de un número* en la consola |
| giro (juego) | `spin` | lo genera el servidor |
| ventana de deshacer | `undoWindow` | sustituye a *reserva temporal* |
| resultado del giro | `spinResult` | sustituye a *resultado de la lotería* |
| conciliación | `reconciliation` | sustituye a *liquidación*; de compras y de probabilidades |
| auditoría de probabilidades | `oddsAudit` | función pura, sobre enteros (F08) |
| compra de giros (Google Play) | `purchase` / `purchaseToken` | |
| saldo de giros | `freeSpins` / `paidSpins` | gratis / pagos |
| inventario del jugador | `inventory` | |
| bitácora de giros | `spinLog` / `spin_log` | solo inserción |
| stock de edición limitada | `stock` | propuesto para la tabla de be05 |
| hora de cierre | `closingTime` / `closesAt` | ya usada en fases escritas: se conserva `closesAt` |

### 2.2 Estados

| Español | Inglés (código) | Nota |
|---|---|---|
| borrador | `draft` | estado de la rueda; valor de enum, no de UI |
| programada | `scheduled` | idem |
| en vivo | `live` | idem; una rueda `live` no cambia sus pesos |
| terminada | `ended` | idem; no se envían giros |
| conciliada | `reconciled` | irreversible |
| en cola | `queued` | estado de un envío |
| enviando | `sending` | idem |
| enviado | `sent` | idem |
| fallido | `failed` | idem |
| revertido | `reverted` | idem; sale de la ventana de deshacer |
| en proceso | `processing` | estado de un giro (propuesto; be-10 lo necesita) |
| cayó (el segmento en que se detuvo la rueda) | `landed` (`landedSegment`) | no es lo entregado: con sustituto, lo entregado es `deliveredPrize` (F08, §2.11) |

> ⚠️ La **etiqueta que ve el usuario** ("En vivo", "Terminada") sigue en
> español y vive separada del valor interno, típicamente en una función de
> mapeo: `function statusLabel(status) { switch (status) { case 'live': return 'En vivo'; ... } }`.

### 2.3 Verbos de negocio

| Español | Inglés (código) |
|---|---|
| enviar un premio (manual) | `sendGrant` · `grant` |
| deshacer un envío | `undoGrant` |
| girar | `spin` |
| reservar (ventana) | `openUndoWindow` |
| expirar (ventana) | `expireUndoWindow` |
| terminar una rueda | `endWheel` |
| conciliar | `reconcile` |
| acreditar una compra | `creditPurchase` |
| sortear (el servidor elige segmento) | `landSegment` |
| consultar resultado | `checkSpinResult` / `fetchSpinResult` |

### 2.4 Campos frecuentes

| Español | Inglés (código) |
|---|---|
| nombre | `name` |
| estado | `status` |
| tipo | `type` |
| mensaje | `message` |
| premio / tipo de premio | `prize` / `prizeType` |
| precio de un paquete de giros | `packagePriceCents` (propuesto; dinero en centavos enteros, dólares) |
| prorrateo por giro | `prizeShare` (reparto sin perder centavos) |
| total recaudado | `totalCollected` |
| margen | `margin` |
| hora de cierre | `closesAt` |
| hora de apertura | `opensAt` |
| zona horaria | `timezone` |
| fecha de creación | `createdAt` |
| fecha de actualización | `updatedAt` |
| versión de pesos | `wheelVersion` |
| segmento que salió | `landedSegment` |

### 2.5 Rutas de la API

El cuadro de lo que el frontend llama. Las del backend salen del mismo contrato
(§7bis). Ninguna ruta usa un nombre en español.

| Ruta | Qué hace |
|---|---|
| `/login` | inicio de sesión de los operadores |
| `/wheels` | listado y alta de ruedas |
| `/wheels/:id` | detalle, edición y baja de una rueda con sus segmentos (los pesos no cambian en `live`) |
| `/wheels/:id/segments` | segmentos de una rueda (lectura; la edición va por `/wheels/:id`) |
| `/players/:id/grants` | envíos manuales a un jugador (motivo obligatorio; un caso por jugador) |
| `/players/:id/spins` | giros de un jugador (el ingenuo de 2019 y el transaccional) |
| `/spins` | resultados de giros recientes |
| `/purchases` | compras pendientes y confirmadas (Google Play) |
| `/wheels/:id/reconciliation` | conciliación de una rueda (endpoint de auditoría, be07) |

### 2.6 Slices, epics y componentes

| Nombre | Tipo | Dónde | Fase |
|---|---|---|---|
| `wheelSlice` | slice | `src/features/wheels/` | F04 |
| `grantSlice` | slice | `src/features/grants/` | F05 |
| `undoWindowEpic` | epic | `src/features/grants/epics/` | F06 |
| `sendGrantEpic` | epic | idem | F06 |
| `searchPlayerEpic` | epic | idem | F06 |
| `retryGrantEpic` | epic | idem | F06 |
| `cancelOnLogoutEpic` | epic | `src/app/` | F06 |
| `pollingEpic` | epic | `src/features/purchases/epics/` | F07 |
| `apiStore.js` | instancia HTTP | `src/api/` | F07 (mock de Google Play, 3002) |
| `closedWheelGuard.js` | guarda de epic | `src/features/grants/epics/` | F07 |
| `purchaseSlice` | slice | `src/features/purchases/` | F07 |
| `PurchasesPage` | componente | `src/features/purchases/` | F07 |
| `dashboardSlice` | slice | `src/features/dashboard/` | F09 |
| `DashboardPage`, `BandChart`, `MetricCard` | componentes | `src/features/dashboard/` | F09 |
| `reconciliationSlice` | slice | `src/features/reconciliation/` | F08 |
| `ReconciliationPage` | componente | `src/features/reconciliation/` | F08 |
| `WheelTable` | componente | `src/features/wheels/` | F11 (a hooks) |
| `WheelCard` | componente | `src/components/` | F00 |
| `WheelForm` | componente | `src/features/wheels/` | F04 |
| `GrantWizard` | componente | `src/features/grants/` | F05 |

### 2.7 Personajes como usuarios

Los nombres de la historia son los que se leen en el código de los usuarios.
Son los únicos nombres propios que el código usa; el resto del dominio es
genérico.

| Persona (historia) | Usuario | Rol en el dominio |
|---|---|---|
| Itzel | `ibatista` | operación: envíos y ruedas |
| Yariela | `ypinzon` | soporte: compensaciones |
| Marisol | `mdegracia` | contadora: conciliación |

---

### 2.8 Nombres surgidos al prototipar (P7, 14/10/2026)

Lo que la verificación previa necesitó y que no estaba en §2.1–§2.7. Son propuestas de
P8: se confirman en la tanda que los usa por primera vez.

| Concepto | Inglés (código) | Nota |
|---|---|---|
| clave de idempotencia de un giro | `idempotencyKey` / `idempotency_key` | sustituye a la columna `key` del prototipo; `UNIQUE` solo en el modo transaccional |
| identificador de segmento | `segmentId` en slug kebab: `esclusa-de-oro` | el slug es el id; no es un número |
| segmento que salió en un giro | `landedSegment` / `landed_segment` | ya usado en el SQL de be07 |
| existencias de un segmento limitado | `remaining` (columna de `stock`) | el esquema del curso no lleva `CHECK (remaining >= 0)`: esa ausencia es la que deja exceder el stock en be-09 (ver `preparaciones-de-incidentes-be.md`) |
| resultado de `oddsAudit` | `{ bandAlarms, chi2, chi2Alarm }` | las dos señales por separado (A14) |
| valor crítico de χ² con 7 grados y α = 0,05 | `CHI2_CRITICAL_DF7_05` | `14.067`; constante con nombre, no número suelto |
| script de npm del mock de Google Play | `mock:googleplay` | sustituye a `mock:lottery`; corre `mock/googlePlay/server.js` en el 3002 (D36, T0) |
| pantalla de la bitácora | `SpinLogPage`, ruta `/spin-log` | `AppRouter` y `Navbar` desde F01; la etiqueta visible sigue siendo «Bitácora». Hasta T12 fue `BitacoraPage` y `/bitacora`, contra §4.1 de la guía; se renombró en F01–F07 y en la historia del repo de prueba (R19, 20/10/2026) |

### 2.9 Nombres que fijaron F03–F05 (T2 y T3, 14/10/2026)

Confirmados al escribir y correr las fases; los de §2.8 que aparecen acá quedan confirmados.

| Concepto | Inglés (código) | Dónde · fase |
|---|---|---|
| clave de idempotencia de un giro | `idempotencyKey` | cuerpo de `POST /players/:id/spins` y fila de `spinLog` · F03 (confirma §2.8) |
| pausa entre los pasos del giro de 2019 | `STEP_DELAY_MS` | variable del mock · F03 |
| intentos por clave del generador de tráfico | `ATTEMPTS_PER_KEY` | `scripts/traffic.js` · F03 |
| stock inicial de la medición | `INITIAL_STOCK` | `scripts/measure.js` · F03 |
| scripts de npm de la carga | `traffic`, `measure` | `scripts/traffic.js`, `scripts/measure.js` · F03 |
| error legible | `toReadableError` → `{ message, type }` | `src/api/readableError.js` · F04 (`type`: `timeout`, `http`, `malformed`, `unknown`; `conflict` desde F05) |
| reglas de pesos | `validateWeights`, `sumWeights`, `canEditWeights`, `TOTAL_BP` | `src/features/wheels/weightRules.js` · F04 |
| estado del slice de ruedas | `items`, `loadingList`, `loadingMutation`, `error`, `editingId` | `wheelSlice` · F04 |
| thunks de ruedas | `fetchWheels`, `createWheel`, `updateWheel`, `deleteWheel` | `wheelSlice` · F04 |
| página de ruedas | `WheelsPage` (contiene `WheelForm` y `WheelTable`) | `src/features/wheels/` · F04 (`WheelTable` nace en clase en F04; F11 la pasa a hooks) |
| caso de soporte | `caseId` (texto, p. ej. `C-2210`) | envío y `grants` del mock · F05 |
| id de un envío | `grantId` (`g-1`, `g-2`…) | `grantSlice` y cuerpo de `POST /players/:id/grants` · F05 |
| envío confirmado por el servidor | `confirmed` | `grantSlice` · F05 |
| tabla de transiciones de un envío | `ALLOWED_TRANSITIONS` | `grantSlice` · F05 |
| duración de la ventana de deshacer | `UNDO_WINDOW_MS` | `grantSlice` · F05 |
| cerrar la ventana (cancelar el temporizador) | `closeUndoWindow` | `grantSlice` · F05 (junto a `openUndoWindow` y `expireUndoWindow`, §2.3) |
| encolar un envío | `queueGrant` | `grantSlice` · F05 |
| acciones del slice de envíos | `grantQueued`, `grantSent` (optimista), `rollbackGrant`, `grantReverted`, `discardGrant` | `grantSlice` · F05 |
| enviar todo lo que está en cola | `sendAllQueued` | `grantSlice` · F05 |
| etiqueta de un envío | `grantStatusLabel` | `grantSlice` · F05 |
| componentes de envíos | `GrantWizard`, `GrantList`, `GrantsPage`, `GrantBoard` | `src/features/grants/` · F05 |
| demora del juego al entregar un premio | `GRANT_DELIVERY_MS` | variable del mock · F05 |
| rutas de la consola | `/grants`, `/grants/board` | `AppRouter` · F05 |
| registro de envíos del mock | `grants` (colección), `GET /grants` | `mock/db.json` · F05 |

### 2.10 Nombres que fijaron F06 y F07 (T4, 15/10/2026)

Confirmados al escribir y correr las fases. La Fase 6 **retira** los temporizadores y
los thunks de envío de §2.9 (`openUndoWindow`, `closeUndoWindow`, `expireUndoWindow`,
`queueGrant`, `sendGrant`, `sendAllQueued`, `grantReverted`): sus papeles pasan a las
acciones y los epics de esta tabla, y `undoGrant` pasa de thunk a acción del slice.

| Concepto | Inglés (código) | Dónde · fase |
|---|---|---|
| dependencias de los epics | `{ api, store, now }` (`apiClient`, `apiStore`, `() => Date.now()`) | `createEpicMiddleware({ dependencies })` en `src/app/store.js` · F06 (`store` y `now`, F07) |
| intención de enviar uno | `sendGrantRequested` (`grants/sendGrantRequested`) | `createAction` en `grantSlice` · F06 |
| intención de enviar todo lo que está en cola | `sendAllRequested` | `createAction` en `grantSlice` · F06 |
| acciones del ciclo de un envío | `grantQueued`, `undoGrant`, `grantSending`, `grantSent`, `grantConfirmed`, `rollbackGrant`, `discardGrant` | `grantSlice` · F06 |
| cancelar lo que sigue en cola al cerrar sesión | `grantsReset` (error `type: "cancelled"`) | `grantSlice`, despachada por `cancelOnLogoutEpic` · F06 |
| guarda de origen del envío | `canSend(grant)` (`queued` o `failed`) | `grantSlice` · F06 |
| búsqueda de jugadores del asistente | `playerSearchRequested`, `playerSearchSucceeded` (`{ query, results }`), `playerSearchFailed`, `selectPlayerSearch` | `grantSlice` · F06 |
| espera antes de buscar | `SEARCH_DEBOUNCE_MS` (300) | `searchPlayerEpic` · F06 |
| reintentos y concurrencia del envío masivo | `MAX_RETRIES` (3), `BULK_CONCURRENCY` (4) | `retryGrantEpic` · F06 |
| estado de un jugador | `status`: `active` · `banned` | `players` del mock · F06 |
| refresco de compras con leak (a propósito) | `START_PURCHASES_REFRESH`, `PURCHASES_REFRESHED`, `purchasesRefreshEpic` | `src/features/purchases/epics/` · solo F06; la F07 lo borra |
| contador de peticiones sin sesión | `sessionlessCounter(label)` → `[3001] sin sesión #N` | `mock/sessionlessCounter.js` · F06 (el `3002` lo monta en F07) |
| cierre de una rueda | `isWheelClosed(wheel, now)`, `msUntilClosing`, `spinWheelId(prize)` | `src/features/wheels/closing.js` · F07 |
| premio de giro en una rueda | `spin:<wheelId>` (valor de `prize`) | `GrantWizard` y `closing.js` · F07 |
| rechazo de un giro de rueda cerrada | `closedWheelRejection(grant, state, now)`; error `type: "closed"` | `src/features/grants/epics/closedWheelGuard.js` · F07 |
| instancia HTTP del servicio de compras | `apiStore`, `attachSession(getToken)` | `src/api/apiStore.js` · F07 (confirma §2.6) |
| slice de compras | `purchaseSlice`: `byToken`, `pollingToken`; `startPolling`, `stopPolling`, `purchaseStatusReceived`, `pollingFailed`; `selectPurchases`, `selectPollingToken` | `src/features/purchases/` · F07 |
| estado de una compra | `state`: `unknown` · `pending` · `confirmed`; `checkedAt` | `purchaseSlice` y `GET /purchases/:token` del `3002` · F07 |
| intervalo del polling | `POLLING_INTERVAL_MS` (2000) | `pollingEpic` · F07 |
| pantalla de compras | `PurchasesPage`, ruta `/purchases` | `AppRouter` y `Navbar` · F07 |
| variables del mock de Google Play | `PLAY_PENDING_MS` (demora del pago en efectivo), y su `CHAOS_LEVEL` | `mock/googlePlay/server.js` · F07 (en el script de pruebas, `PLAY_CHAOS_LEVEL`) |
| identificador de una compra | `purchaseToken` (`tok-oxxo-2`, `tok-efecty-1`) | cuerpo de `POST /purchases` del `3002` · F07 |

### 2.11 Nombres que fijó F08 (T5, 16/10/2026)

Confirmados al escribir y correr la fase. Confirman `reconciliation`, `oddsAudit`, `prizeShare`,
`packagePriceCents`, `landedSegment`, `{ bandAlarms, chi2, chi2Alarm }` y `CHI2_CRITICAL_DF7_05` de §2.1–§2.8.

| Concepto | Inglés (código) | Dónde · fase |
|---|---|---|
| frontera del dinero | `toCents`, `formatCents` (`"US$20,99"`) | `src/features/reconciliation/money.js` · F08 |
| conteo por segmento | `countLanded(spinLog, segments)` (cuenta `landedSegment`) | `oddsAudit.js` · F08 |
| premio entregado (con sustituto) | `deliveredPrize` | fila de `spinLog` · F08 (el segmento en que cayó sigue siendo `landedSegment`) |
| origen de un giro | `origin`: `free` · `paid` · `manual` | fila de `spinLog` · F08 |
| sustitutos de los avatares repetidos | `SUBSTITUTES` | `mock/spinLogGenerator.js` · F08 |
| reglas de la bitácora sembrada | `substitute` (la nueva) · `accommodating` (la rueda que se acomoda) | `generateSpinLog({ seed, spins, wheelId, segments, rule })` · F08 |
| generador sembrado | `mulberry32(seed)` | `mock/spinLogGenerator.js` · F08 (solo para simular) |
| siembra de la conciliación | `mock/seed-reconciliation.js`, script `seed:reconciliation`, bandera `--accommodating` | F08 |
| catálogo de la tienda | `packages`: `{ productId, spins, packagePriceCents }`; `spins-10`, `spins-500` | `mock/db.json` · F08 |
| reporte de ganancias de la tienda | `GET /earnings` → `{ purchaseToken, productId, chargedAt, chargedCents, feeCents }` | mock del `3002`, `mock/googlePlay/earnings.json` · F08 |
| comisión de la tienda | `STORE_FEE_BP` (1500), `storeFeeCents(chargedCents)` | `reconciliationMath.js` · F08 |
| prorrateo por segmento | `prorateSpinPrice(packagePriceCents, counts)` (la rota del incidente 18: `prorateSpinPriceBroken`) | `reconciliationMath.js` · F08 |
| cruce de compras | `reconcilePurchases(credited, storeRows)` → `{ matched, missingInApi, duplicatedInApi, missingInStore, totals }` | `reconciliationMath.js` · F08 |
| slice y thunks | `reconciliationSlice`; `fetchReconciliation(wheelId)`, `reconcileWheel()`; `selectReconciliation`; estado `{ wheelId, segments, counts, audit, purchases, packageProration, record }` | `src/features/reconciliation/` · F08 |
| registro de una conciliación | colección `reconciliations`; `POST /wheels/:id/reconciliation` (409 si la rueda no está `ended`), `GET /wheels/:id/reconciliation` | `mock/reconciliationRouter.js` · F08 |
| pantalla | `ReconciliationPage`, ruta `/reconciliation` | `AppRouter` y `Navbar` · F08 |

### 2.12 Nombres que fijaron F09–F11 (T6, 18/10/2026)

| Concepto | Inglés (código) | Dónde · fase |
|---|---|---|
| slice del tablero | `dashboardSlice`: `{ wheelId, segments, spinLog, grants, earnings, loadedAt }`; thunk `fetchDashboard(wheelId)` | `src/features/dashboard/` · F09 |
| cálculos del tablero | `summarizeSpins(spinLog, segments)` → `{ total, free, paid, countsByOrigin }`, `countManualSpins(grants, wheelId)`, `netRevenueCents(earnings)`, `bandRows(counts, weightsBp)` | `dashboardMath.js` · F09 |
| selectores del tablero | `selectSpinSummary`, `selectManualSpins`, `selectNetRevenueCents`, `selectBands` (por origen: `all`, `free`, `paid`) | `dashboardSelectors.js` · F09 |
| gráfico y tarjeta | `BandChart` (observado contra la banda, chart.js 2.9.4), `MetricCard` (`title`, `value`, `hint`, `updatedAt`) | `src/features/dashboard/` · F09 |
| instante de los datos | `loadedAt` (lo pone el thunk; la tarjeta lo formatea en `America/Panama`) | F09 |
| volumen de un evento | bandera `--event` de `seed-reconciliation.js` (la Semana del Canal con 180.000 giros) | F09 |
| ayudante de pruebas | `renderWithStore(ui, { preloadedState })` | `src/test/renderWithStore.jsx` · F10 |
| smoke | `cypress.config.js`, `cypress/e2e/smoke.cy.js` | F10 |
| el estado antes de modernizar | tag `pre-modernizacion` | F11 |
| evidencia del incidente 21 | `scripts/repeated-landings.js <wheelId> <segmentId>` | incidente 21 (lo escribe el lector) |

## 3. Diccionario técnico general (frontend / store / auth)

| Español | Inglés (código) |
|---|---|
| usuario | `user` |
| sesión | `session` |
| iniciar sesión | `login` |
| cerrar sesión | `logout` |
| cargando / carga | `loading` |
| guardando | `saving` |
| formulario | `form` |
| validar | `validate` |
| enviar (submit) | `submit` |
| cancelar | `cancel` |
| reintentar | `retry` |
| obtener / traer | `get` / `fetch` |
| crear | `create` |
| actualizar | `update` |
| eliminar / borrar | `delete` |
| listar | `list` |
| buscar | `search` |
| en edición | `editing` |
| lista vacía | `empty` |

### 3.1 Verbos técnicos habituales para componer nombres

Combina un verbo con el sustantivo del dominio: `get` + `Wheels` →
`getWheels`; `send` + `Grant` → `sendGrant`. Los verbos técnicos más usados en
el curso:

`get`, `fetch`, `create`, `update`, `delete`, `list`, `search`, `select`,
`send`, `spin`, `land`, `open`, `expire`, `end`, `reconcile`, `credit`,
`poll`, `subscribe`, `unsubscribe`, `cancel`, `retry`, `validate`.

---

## 4. Convenciones de nombrado por tipo de artefacto

| Artefacto | Convención | Ejemplo |
|---|---|---|
| Componente (clase o función) | `PascalCase` | `WheelTable`, `WheelForm`, `GrantWizard` |
| Archivo de componente | igual al componente | `WheelTable.jsx` |
| Función / variable | `camelCase` | `sendGrant`, `isWheelLive` |
| Slice | `<dominio>Slice.js` | `wheelSlice.js`, `grantSlice.js` |
| Thunk | verbo + dominio | `fetchWheels`, `createWheel`, `sendGrant` |
| Epic | `<propósito>Epic` | `pollingEpic`, `sendGrantEpic` |
| Action type (Redux clásico) | `SNAKE_CASE` | `SEND_GRANT`, `STOP_POLLING`, `LOGOUT` |
| Selector | `select` + dominio | `selectWheelCount`, `selectLiveWheels` |
| Endpoint REST | sustantivo plural | `/wheels`, `/wheels/:id/segments`, `/spins` |
| Constante de configuración | `SCREAMING_SNAKE_CASE` | `CHAOS_LEVEL`, `POLLING_INTERVAL_MS` |
| `data-testid` | kebab-case descriptivo | `data-testid="segment-landed"` |

**Extensiones de archivo.** Todo archivo que contenga JSX va `.jsx`
(`WheelTable.jsx`, `SegmentCell.jsx`, `DashboardPage.jsx`). Todo archivo que no
lo contenga va `.js` (`wheelSlice.js`, `pollingEpic.js`, `money.js`). Las dos
excepciones son `src/index.js` y `src/App.js`, que llegan así en el template de
CRA 4 y no se renombran: tocar los puntos de entrada para uniformar una
extensión es exactamente la clase de cambio de riesgo sin beneficio que este
curso enseña a no hacer.

**Rutas canónicas del proyecto**, para que dos fases no ubiquen el mismo archivo
en dos sitios:

- `src/api/` — instancias HTTP compartidas: `apiClient.js` (puerto 3001) y
  `apiStore.js` (puerto 3002, el mock de Google Play), y lo que las acompaña
  (`readableError.js`, los servicios).
- `src/app/` — cableado de la aplicación: `store.js`, `rootEpic.js`,
  `history.js`.
- `src/features/<dominio>/` — todo lo de un dominio junto: slice, componentes,
  selectores, funciones puras, y sus epics en `epics/`.
- `src/pages/` — páginas de la era 2019 que todavía no se movieron a `features/`
  (`LoginPage.jsx`, `NotFoundPage.jsx`, …). Que convivan dos organizaciones es
  herencia, no desorden: ver `00-historia-del-sistema.md` §3.
- `src/components/` — componentes compartidos entre dominios (`Navbar.jsx`,
  `AppLayout.jsx`, `WheelCard.jsx`).
- `mock/` — el backend: `server.js`, `chaosMiddleware.js`,
  `wheelsSegmentsRouter.js`, `db.json` y `googlePlay/server.js`.

---

## 5. Ejemplos antes/después (basados en fases de la reescritura)

Estos ejemplos parten de identificadores de las fases 4 y 5 de la reescritura,
para que sirvan de referencia directa al escribirlas. El *antes* es el código
con nombres en español, que el curso no usa: se muestra para reconocerlo.

### ❌ Antes (español)
```javascript
// src/features/ruedas/ruedaSlice.js
const ruedaSlice = createSlice({
  name: 'ruedas',
  initialState: { items: [], loadingList: false, loadingMutation: false, error: null },
  reducers: {},
  extraReducers: (builder) => {
    builder.addCase(fetchRuedas.fulfilled, (state, action) => {
      // guarda el listado ya validado
      state.items = action.payload;
    });
  }
});

export const crearRueda = createAsyncThunk('ruedas/crear', async (rueda) => {
  const response = await apiClient.post('/ruedas', rueda);
  return response.data;
});

function aErrorLegible(error) {
  if (error.code === 'ECONNABORTED') {
    return { mensaje: 'El servidor no respondió a tiempo', tipo: 'timeout' };
  }
  return { mensaje: 'Ocurrió un error inesperado', tipo: 'http' };
}
```

### ✅ Después (inglés en código, español en comentarios y UI)
```javascript
// src/features/wheels/wheelSlice.js
const wheelSlice = createSlice({
  name: 'wheels',
  initialState: { items: [], loadingList: false, loadingMutation: false, error: null },
  reducers: {},
  extraReducers: (builder) => {
    builder.addCase(fetchWheels.fulfilled, (state, action) => {
      // guarda el listado ya validado
      state.items = action.payload;
    });
  }
});

export const createWheel = createAsyncThunk('wheels/create', async (wheel) => {
  const response = await apiClient.post('/wheels', wheel);
  return response.data;
});

function toReadableError(error) {
  if (error.code === 'ECONNABORTED') {
    // el valor del mensaje queda en español: lo lee el usuario final
    return { message: 'El servidor no respondió a tiempo', type: 'timeout' };
  }
  return { message: 'Ocurrió un error inesperado', type: 'http' };
}
```

### ❌ Antes (epic de envío)
```javascript
const enviarPremioEpic = (action$, state$) =>
  action$.pipe(
    ofType(ENVIAR_PREMIO),
    mergeMap((action) =>
      api.post(`/jugadores/${action.payload.jugadorId}/envios`).pipe(
        map((res) => envioExitoso(res)),
        catchError((err) => of(envioFallido(err)))
      )
    )
  );
```

### ✅ Después
```javascript
// La forma que fija la Fase 6 (simplificada: sin la guarda de cierre de la F07).
export const sendGrantEpic = (action$, state$, { api }) =>
  action$.pipe(
    ofType(sendGrantRequested.type),
    groupBy((action) => action.payload),
    mergeMap((byGrant$) =>
      byGrant$.pipe(
        exhaustMap(({ payload: grantId }) => {
          const grant = state$.value.grants.byId[grantId];
          if (!canSend(grant)) return EMPTY;
          return concat(
            of(grantSending(grantId), grantSent({ grantId })),
            from(api.post(`/players/${grant.playerId}/grants`, { grantId /* … */ })).pipe(
              map(() => grantConfirmed(grantId)),
              // el catchError adentro: un envío fallido no mata el epic
              catchError((error) => of(rollbackGrant({ grantId, error: toReadableError(error) })))
            )
          );
        })
      )
    )
  );
```

---

## 6. Matriz de verificación por fase (copiar para ajustar fases existentes)

Las columnas se marcan cuando la fase ya está reescrita **y corrida** (plan §2.4).
Mientras tanto, cada fila dice en qué tanda le toca.

```markdown
| Archivo | Identificadores | Endpoints | Enums/status | Comentarios ✅ | UI ✅ | Estado |
|---|---|---|---|---|---|---|
| 00-setup-hola-mundo-cra.md | ⬜ | — | ⬜ | ✅ | ✅ | Reescribir en T1 (🟢) |
| 01-estructura-base-router-5.md | ⬜ | — | ⬜ | ✅ | ✅ | Reescribir en T1 (🟢) |
| 02-autenticacion-minima.md | ⬜ | ⬜ | ⬜ | ✅ | ✅ | Reescribir en T1 (🟢) |
| 03-mock-api-express-caos.md | ⬜ | ⬜ | ⬜ | ✅ | ✅ | Reescribir en T2 (🔴) |
| 04-ruedas-crud.md | ⬜ | ⬜ | ⬜ | ✅ | ✅ | Reescribir en T3 (🟡) |
| 05-envios-manuales.md | ⬜ | ⬜ | ⬜ | ✅ | ✅ | Reescribir en T3 (🔴) |
| 06-redux-observable-a-fondo.md | ⬜ | ⬜ | ⬜ | ✅ | ✅ | Reescribir en T4 (🟡) |
| 07-cierre-polling-compras.md | ⬜ | ⬜ | ⬜ | ✅ | ✅ | Reescribir en T4 (🔴) |
| 08-conciliacion.md | ⬜ | ⬜ | ⬜ | ✅ | ✅ | Reescribir en T5 (🔴) |
| 09-dashboard.md | ⬜ | ⬜ | ⬜ | ✅ | ✅ | Reescribir en T6 (🟡) |
| 10-testing-minimo.md | ⬜ | ⬜ | ⬜ | ✅ | ✅ | Reescribir en T6 (🟢) |
| 11-cierre-puente-react-moderno.md | ⬜ | ⬜ | ⬜ | ✅ | ✅ | Reescribir en T6 (🟢) |
| A1–A13 | ⬜ | ⬜ | ⬜ | ✅ | ✅ | Según su tanda (plan §5) |
```

Marca ✅ en cada columna cuando confirmes que ese aspecto del archivo ya
está en inglés (o, para las columnas de comentarios/UI, que siguen
intactos en español).

---

## 7. Checklist antes de dar por ajustada una fase

- [ ] Ningún `function`, `const`, `class` o `useState` con nombre en español.
- [ ] Ningún endpoint (`apiClient.get/post/put/delete`) con ruta en español.
- [ ] Ningún valor de `status`/`type`/enum interno en español.
- [ ] Nombres de componente y archivo en `PascalCase` inglés.
- [ ] `action types` en `SCREAMING_SNAKE_CASE` inglés.
- [ ] Comentarios de código 100% en español, explicando el porqué.
- [ ] Textos de interfaz (botones, labels, alertas, placeholders) 100% en español.
- [ ] Narrativa del archivo (títulos, párrafos, ejercicios) sin cambios de contenido, solo referencias de código actualizadas.
- [ ] Consistencia con otras fases ya ajustadas (mismo nombre de thunk/slice/endpoint para el mismo concepto).
- [ ] Ejercicios que mencionan identificadores de código actualizados al nuevo nombre.
- [ ] Ningún término del dominio viejo (`raffle`, `number`, `sale`, `settlement`, `participant`) en el código nuevo.

---

## 7bis. Anexo del track BE 🔥 — el mismo dominio, del otro lado del cable

Este anexo aplica al track opcional de backend (`be00`–`be09`). No cambia
ninguna decisión de arriba: la extiende a Go y a SQL. La regla que lo gobierna
es una sola y no admite excepción:

> 🧭 **`Wheel` significa exactamente lo mismo en el slice de React, en el struct
> de Go y en la tabla de Postgres.** El día que signifiquen cosas distintas, el
> contrato deja de ser verificable y el track pierde su razón de ser.

### 7bis.1 Las entidades en las tres capas

| Concepto | Go (tipo / campo) | SQL (tabla / columna) |
|---|---|---|
| Rueda | `Wheel`, `wheel` | `wheels` |
| Versión de pesos de una rueda | `WheelVersion` | `wheel_versions` |
| Segmento de una rueda | `WheelSegment` | `wheel_segments` |
| Jugador | `Player` | `players` |
| Inventario del jugador | `InventoryItem` | `player_inventory` |
| Compra (Google Play) | `Purchase` | `purchases` |
| Giro (el hecho) | `Spin`, `spinSegment` | `spin_log` (solo inserción) |
| Stock de edición limitada | `Stock` | `stock` (propuesto) |
| Envío manual | `Grant`, `sendGrant` | `grants` (propuesto) |
| Conciliación | `Reconciliation` | consulta sobre `spin_log` (`GROUP BY wheel_version, landed_segment`) |
| Usuario | `User` | `users` |

Los campos siguen §2.4 **con la traducción de convención que cada capa exige, y
nada más**: `closesAt` en JSON y en el struct de Go (`ClosesAt time.Time` con
etiqueta `json:"closesAt"`), `closes_at` en la columna. La etiqueta JSON es la
frontera del contrato: **es la que el frontend ve, y por lo tanto es la que no
se puede cambiar**.

### 7bis.2 Convenciones de nombrado en Go

| Artefacto | Convención | Ejemplo |
|---|---|---|
| Paquete | sustantivo corto, minúscula, singular | `wheel`, `spin`, `auth`, `chaos` |
| Tipo exportado | `PascalCase` | `Wheel`, `SpinRequest` |
| Campo de struct | `PascalCase` + etiqueta JSON en `camelCase` | `ClosesAt` / `json:"closesAt"` |
| Handler HTTP | `<Verbo><Recurso>Handler` | `SpinHandler`, `ListWheelsHandler` |
| Método de servicio | verbo + dominio, igual que el thunk | `SendGrant`, `CreateWheel`, `EndWheel` |
| Interfaz de persistencia | `<Dominio>Store` | `WheelStore`, `UserStore` |
| Implementación concreta, un motor | `<motor><Dominio>Store` | `postgresWheelStore` |
| Implementación concreta, los dos motores | `sqlStore` en el paquete del dominio | `wheel.sqlStore` |
| Error de dominio | `Err<Caso>` | `ErrSegmentSoldOut`, `ErrWheelEnded` |
| Función de aritmética de dinero | el mismo nombre que en `money.js` | `TotalCollected`, `PrizeAmount`, `Margin`, `PrizeShare` |
| Tabla y columna SQL | `snake_case`, tabla en plural | `wheel_segments`, `landed_segment` |
| Archivo de migración | `NNNNNN_verbo_objeto.up.sql` | `000003_add_unique_purchase_token.up.sql` |
| Variable de entorno | `SCREAMING_SNAKE_CASE` | `DATABASE_URL`, `CHAOS_LEVEL`, `JWT_SECRET` |

**La correspondencia que más importa** es la del verbo de negocio: el thunk del
frontend, el método del servicio y el nombre del caso de uso en la narrativa se
llaman igual. `sendGrant` en el slice, `SendGrant` en el service,
`POST /players/:id/grants` en la ruta. Un lector que salta de una capa a otra no
debería tener que traducir nada.

### 7bis.2bis Nombres que fijaron be00–be04 (T7, 19/10/2026)

Confirmados al escribir y correr las fases. Confirman `WheelVersion`/`wheel_versions`, `stock`, `grants`
y `Spin`/`spin_log` de §7bis.1.

| Concepto | Go / SQL | Dónde · fase |
|---|---|---|
| hallazgos del contrato | `C-01` (el juego) … `C-07` (lo que el servidor cree sin comprobar) | `server/CONTRACT.md` · be00 |
| esquema | doce tablas: `users`, `wheels`, `wheel_versions`, `wheel_segments`, `players`, `player_inventory`, `packages`, `purchases`, `stock`, `spin_log`, `grants`, `reconciliations` | `000001_initial_schema` · be02 |
| saldo de giros | `players.free_spins`, `players.paid_spins` (sin `CHECK`) | be02 |
| compra de un giro pago | `spin_log.purchase_token` / `purchaseToken` | be02 (contrato medido en be03) |
| id del envío que ve el contrato | `grants.grant_id` (`json:"id"`), distinto de la clave `grants.id` | be02 |
| operador del envío | `grants.sent_by` / `sentBy` | `000005_grant_operator` · be04 |
| conciliación completa | `band_alarms`, `missing_in_api`, `duplicated_in_api` | `000003_reconciliation_full_shape` · be03 |
| paquetes | `wheel`, `player`, `spin`, `purchase`, `reconciliation`, `auth`, `config`, `seed`, `storage`, `jsontime`, `httpapi` (carpeta `http`) | `server/internal/` · be01–be04 |
| tipos y errores | `wheel.Wheel`, `wheel.Segment`, `wheel.SegmentInput`, `wheel.ValidationError`, `wheel.IllegalTransitionError`, `ErrLiveWeights`; `player.Grant`, `ErrCaseGranted`, `ErrReasonMissing`; `spin.Spin`, `spin.Stock`, `spin.Filter`, `ErrSoldOut`, `ErrMissingKey`; `reconciliation.Reconciliation`, `Totals`, `NotEndedError` | be02–be04 |
| servicios | `wheel.Service` (`Create`, `Update`, `Delete`, `Segments`), `player.Service` (`Search`, `SendGrant`, `Grants`), `spin.Service` (`Log`, `Stock`, `NaiveSpin`), `reconciliation.Service` (`Reconcile`, `Find`), `auth.Service` (`Login`) | be03–be04 |
| instante del contrato con `Z` | `jsontime.ISO` (UTC, milisegundos, como `toISOString()`) | be03 |
| configuración | `config.Load()` (`PORT`, `DATABASE_URL`, `ALLOWED_ORIGIN`, `CHAOS_LEVEL`, `CHAOS_SEED`, `GRANT_DELIVERY_MS`, `JWT_SECRET`, `JWT_TTL`); `config.LoadDatabase()` para la siembra | be03–be04 |
| identidad | `auth.WithUserID`, `auth.UserIDFrom`, `auth.Signer` (`Sign`, `Verify`), `auth.HashPassword`, `auth.Session` | be04 |
| caos | `ChaosController` (`Level`, `SetLevel`, `draw`), `CHAOS_SEED` | be01 |
| rutas propias | `POST /login` (be04), `POST /_chaos` y `GET /health` (crecimiento), `GET /stock` (crecimiento) | be01–be04 |

### 7bis.2ter Nombres que fijó be05 (T8, 19/10/2026)

Confirmados al escribir y correr la fase. `NaiveSpin` de §7bis.2bis desaparece en be05: el giro es `Spin`.

| Concepto | Go / SQL | Dónde · fase |
|---|---|---|
| el giro como hecho | `spin_log_unique_key` (`UNIQUE (idempotency_key)`); disparadores `spin_log_no_update_delete` y `spin_log_no_truncate` con la función `spin_log_append_only()` (en SQLite, `spin_log_no_update` y `spin_log_no_delete`) | `000006_spin_as_fact` · be05 (D28, D35) |
| el pedido de giro | `spin_requests` (`idempotency_key`, `player_id`, `status` `processing`/`landed`, `processing_until`, `created_at`, `landed_at`) | `000006_spin_as_fact` · be05 |
| sustituto de un premio de edición limitada | `wheel_segments.substitute` / `substitute` (crecimiento en `GET /segments`); `seed.publishedSubstitutes` | be05 (D34) |
| unicidad del caso del envío | `grants_unique_case` (`UNIQUE (player_id, case_id)`) | be05 |
| el giro | `spin.Service.Spin` → `decide`, `repeated`, `lockBalance`, `debitSpin`, `takeStock`; `spin.Result` (`landedSegment`, `deliveredPrize`, `origin`, `wheelId`, `wheelVersion`) | be05 |
| estrategia de bloqueo | `spin.Locking`: `Pessimistic` (`pessimistic`), `Optimistic` (`optimistic`; en prosa, *escritura condicional*) | be05 |
| entrega y barrido | `deliver`, `markLanded`, `RunSweeper`, `sweep`, `findResult` | `internal/spin/delivery.go` · be05 |
| el sorteo | `spin.Drawer` (`NewDrawer`, `Draw`), `spin.Segment` | `internal/spin/random.go` · be05 (D37) |
| errores del giro | `ErrPlayerNotFound` (404), `ErrNoSpins` (`sin giros`), `ErrInProgress` (`giro en proceso`), `ErrNoLiveWheel` (`no hay rueda activa`), `ErrSoldOut` (`agotado`, solo sin sustituto) | be05 |
| ayudantes de `storage` | `DB.WithTx`, `DB.ForUpdate` (costura: vacío en SQLite), `IsUniqueViolation`, `IsForeignKeyViolation` | be05 |
| configuración del giro | `SPIN_LOCKING`, `SPIN_DELIVERY_MS`, `SPIN_PROCESSING_TTL`, `SPIN_SWEEP_EVERY` | be05 |
| el arnés | `server/load/giro.js` (escenarios `pico` y `notificacion`), `rueda-de-medicion.sql` (rueda 900, jugadores 10001–10300), `medicion.sql`; `server/evidence/concurrencia.md` | be05, bea-11 |
| pruebas de carrera | `race`, `count`, `openPostgres`, `measurementWheel`; `TestSameKeyGivesOneSpin`, `TestBalanceNeverNegative`, `TestStockNeverExceeded`, `TestSpinLogIsAppendOnly` | `internal/spin/race_test.go` · be05 |
| volumen de prueba | `seed.GenerateVolume`, `seed.FirstVolumeID` (100000); banderas `-volume`, `-players`, `-seed` | `internal/seed/fake.go` · bea-10 |

### 7bis.2quater Nombres que fijó be06 (T9, 19/10/2026)

Confirmados al escribir y correr la fase.

| Concepto | Go / SQL | Dónde · fase |
|---|---|---|
| el reloj | `clock.Clock` (`Now()`), `clock.System`, `clock.Fixed{T}` | `internal/clock/clock.go` · be06 |
| la zona de presentación | `storage.PresentationZone` (`America/Panama`), `withPresentationZone(dsn)` | `internal/storage/storage.go` · be06 (D29) |
| bloqueo compartido de fila | `DB.ForShare()` (costura: vacío en SQLite) | `internal/storage/storage.go` · be06 |
| la rueda del giro | `spin.liveWheel` (la `live` que cierra primero entre las abiertas por reloj) | `internal/spin/service.go` · be06 |
| el cierre | `wheel.IsClosed(status, closesAt, now)`, `wheel.CloseExpired`, `wheel.RunCloser`; log `[cierre]` | `internal/wheel/closing.go` · be06 |
| el giro gratis | `players.next_free_spin_at` / `nextFreeSpinAt`; `spin.ClaimFree`, `spin.FreeSpin`, `spin.NotYetError` (`todavía no`); `POST /players/:id/free-spins` | `000007_server_clock`, `internal/spin/free.go` · be06 |
| envío de una rueda cerrada | `player.ErrWheelClosed` (*"La rueda ya cerró: no se envían giros de ella."*) | `internal/player/player.go` · be06 |
| la hora del servidor | `X-Server-Time` (`serverTimeMiddleware`) | `internal/http/middleware.go` · be06 |
| configuración | `FREE_SPIN_EVERY` (4h), `WHEEL_CLOSE_EVERY` (10s) | `internal/config/config.go` · be06 |
| pruebas | `TestSpinRespectsClosing`, `TestFreeSpinEveryFourHours`, `TestFreeSpinClaimRace`, `TestFreeSpinAcrossChileDST`, `TestCloseExpired` | `clock_test.go`, `closing_test.go` · be06 |

### 7bis.2quinquies Nombres que fijó be07 (T9, 19/10/2026)

Confirmados al escribir y correr la fase.

| Concepto | Go / SQL | Dónde · fase |
|---|---|---|
| la compra, una vez | `purchases.player_id`, `purchases.duplicate_of`, `purchases_unique_token` (`UNIQUE (purchase_token) WHERE duplicate_of IS NULL`) | `000008_purchases_and_protection` · be07 |
| el pedido de la compra | `purchase_requests` (`purchase_token`, `player_id`, `product_id`, `created_at`) | `000008_purchases_and_protection` · be07 |
| la tienda | `purchase.Play` (`State`, `Earnings`), `purchase.HTTPPlay`, `purchase.EarningsRow`; `ErrUnknownPurchase`, `ErrPlayUnavailable` | `internal/purchase/play.go` · be07 (D36) |
| acreditar | `purchase.Service`: `Register` (el juego), `Notify` (Google Play), `settle`, `credit`; `purchase.Credit` (`state`: `pending` · `credited`); `ErrUnknownProduct`, `ErrOtherPlayer`, `ErrNoRequest` | `internal/purchase/service.go` · be07 |
| rutas de la compra | `POST /players/:id/purchases`, `POST /purchases/notifications` | be07 |
| la protección de duplicados | `spin.deliverable` (reclama en `player_inventory` antes del stock); sustitutos de `seed.publishedSubstitutes` | `internal/spin/service.go` · be07 (D34) |
| la conciliación del servidor | `reconciliation.OddsAudit`, `reconciliation.ReconcilePurchases`, `Recalculate`, `Audit` → `VersionAudit` / `SegmentCount`, `differences`; log *"difiere de la del servidor"* | `internal/reconciliation/` · be07 |
| la auditoría por versión | `GET /wheels/:id/audit` | be07 (D33) |
| configuración | `PLAY_URL` (`http://localhost:3002`), `PLAY_TIMEOUT` (3s) | `internal/config/config.go` · be07 |
| pruebas | `TestDuplicateNotificationCreditsOnce`, `TestCreditIsAllOrNothing`, `TestPendingPurchaseWaits`, `TestRepeatedPrizeGetsSubstitute`, `TestProtectionKeepsPublishedOdds` | `purchase/service_test.go`, `spin/protection_test.go` · be07 |

### 7bis.2sexies Nombres que fijaron be08 y be09 (T10, 20/10/2026)

Confirmados al escribir y correr las fases.

| Concepto | Go / archivo | Dónde · fase |
|---|---|---|
| la base de las pruebas | `testsupport.OpenPostgres`, `OpenAny`, `MustPostgres` (fallan, no saltan), `MigrationsDir`, `MockDBJSON` | `internal/testsupport/db.go` · be08 |
| la aplicación entera en una prueba | `testsupport.NewServer` → `Server` (`Do`, `Login`), `Response`; la tienda de la suite, `fileStore` | `internal/testsupport/server.go` · be08 |
| el servicio de giro como interfaz | `spinService` (`Spin`, `ClaimFree`, `Log`, `Stock`) | `internal/http/handlers.go` · be08 |
| el sorteo sembrado | `spin.NewDrawerFrom(rand.Source)` (solo pruebas) | `internal/spin/random.go` · be08 |
| las pruebas por nivel | `TestTransitions`, `TestIsClosed`, `TestOddsAuditMatchesTheConsole`, `TestReconcilePurchases`, `TestDrawerSeededFollowsPublishedOdds`, `TestDrawerUnseededFalseAlarmRate`, `TestSpinHandlerTranslatesErrors`, `TestWritePurchaseCodes`, `TestStrictContract`, `TestDeliberateContractChanges` | be08 |
| el par contradictorio | `TestA_LastInsertId`, `TestB_InstantComparison`, detrás de `//go:build regla` | `internal/storage/engine_rule_test.go` · be08 |
| el nivel de carga | `server/load/invariantes.sql` (`la carga rompió una invariante del giro`) | be08 |
| los niveles, en la terminal | `make test-unit`, `test-handler`, `test-all`, `test-contract`, `test-engine`, `test-load`, `test-sqlite`; `TEST_DB`, `K6_NET`, `BASE_URL` | `server/Makefile` · be08–be09 |
| SQLite fuera del binario | `//go:build sqlite`: `driver_sqlite.go` / `driver_nosqlite.go`, `sqliteEnabled`, `sqliteUnique`, `sqliteForeignKey`; en pruebas, `testsupport/sqlite.go` | `internal/storage/` · be09 (D19) |
| las migraciones como paso previo | `cmd/migrate` (`up`, `version`); `storage.ExpectedSchemaVersion` (8), `DB.CheckSchema` | be09 |
| el empaquetado | `server/Dockerfile`, `server/.dockerignore`, `server/docker-compose.yml` (`db`, `migrate`, `api`), `.github/workflows/ci.yml` (`test`, `image`) | be09 (D31, D38) |

### 7bis.3 Rutas canónicas del backend

- `server/cmd/api/` — el `main.go`: configuración, cableado y arranque.
- `server/internal/http/` — router, middlewares (recuperación, CORS, logging,
  `X-Request-Id`, caos) y handlers.
- `server/internal/<dominio>/` — servicio, tipos y store de un dominio (`wheel`,
  `spin`, `purchase`, `player`).
- `server/internal/storage/` — pool, transacciones y la costura de dialecto.
- `server/migrations/` — los `.up.sql` y `.down.sql` versionados.
- `server/internal/seed/` — siembra desde el `db.json` del alumno, y el faker
  opcional de `bea-10`.
- `server/CONTRACT.md` — el contrato auditado en `be00`: régimen estricto,
  régimen de crecimiento y hallazgos. Criterio de aceptación de `be03`.
- `server/smoke.sh` — el checklist de contrato ejecutable, en `bash` y `curl`.
  Corre igual contra el mock y contra el binario de Go.
- `server/evidence/` — capturas y evidencia de las piezas forenses (el HAR de
  `be00`, los inventarios leído y medido).

---

## 8. Duda frecuente: ¿y si necesito un término que no está acá?

Se agrega **a este archivo**, en la sección que corresponda, y recién después
se usa en una fase. Ese orden importa: un término que se inventa en la Fase 7 y
no se registra acá es el que la Fase 9 va a reinventar distinto, y ahí nacen las
inconsistencias que cuestan una tarde de `grep`.

Vale igual para el track BE: un término nuevo de Go o una columna nueva se
registran en §7bis antes de aparecer en una fase.

Para componerlo, la receta es siempre la misma: un verbo técnico de §3.1 más un
sustantivo del dominio de §2. `settle` + `Wheel` → `reconcileWheel`. Si el
resultado suena raro en inglés, casi siempre es que el concepto está mal
recortado, no que falte vocabulario.

Y si dudas entre dos formas igual de correctas —`closingTime` o `closesAt`,
`packagePriceCents` o `pricePackageCents`—, gana **la que ya esté usada en una
fase escrita**, y se anota acá para cerrar la duda de una vez. La consistencia
vale más que la elegancia: un mantenedor puede vivir con un nombre mediocre,
pero no con dos nombres para la misma cosa.

> 📝 `closesAt` se conserva sobre `closingTime` porque ya era la forma mayoritaria
> en las fases escritas antes de la reescritura. Lo mismo rige para cualquier
> duda futura.
