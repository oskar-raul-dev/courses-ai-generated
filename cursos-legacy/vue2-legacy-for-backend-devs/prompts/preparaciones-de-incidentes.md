# 🔧 Preparaciones de incidentes — Cursos 01 y 02

## Cómo se arma cada incidente del cuaderno, a partir de lo que se corrió

Este documento no es material del curso: es el registro de **cómo se prepara cada incidente** de
`01-vue2-legacy/cuaderno-incidentes.md`, escrito con lo que se ejecutó en la tanda V4 del plan de
edición (15/10/2026). El cuaderno le pide al alumno que arme el sistema roto a partir de la
descripción; aquí queda la versión exacta que se usó para comprobarlo, para que quien revise el
cuaderno la pueda repetir (decisión D7, opción a).

> **Vigencia:** 2026-10-15. Imágenes: `node:14.21.3` (arm64). Plugin de pruebas:
> `@vue/cli-plugin-unit-jest@3.12.1` (Jest 23.6.0). Las pruebas se corrieron con el `@vue/test-utils`
> 1.0.0-beta.29 del plugin y se repitieron en verde con la 1.3.6 que fija la Fase 11 desde V5.

---

## 🧭 Reglas comunes

- **Estado de partida.** Cada incidente parte del estado de su fase. Sin tags en el repo de pruebas,
  el estado sale de la instantánea de la fase (`fase-NN-<slug>.tgz`). Para F4, F5 y F6 se usó el
  estado final de F7, que tiene esas fases sin cambios de lógica en las vistas del incidente.
- **Pruebas antes de la Fase 11.** Los incidentes 02 a 10 se prueban con Jest aunque su fase sea
  anterior. En su estado se instala el plugin de la Fase 11 (`npm install --save-dev
  @vue/cli-plugin-unit-jest@3.12.1` y `vue invoke unit-jest`), y el `example.spec.js` que deja el
  generador no se corre: se le pasa a Jest solo el archivo del incidente.
- **El DOM se repinta después de `$nextTick()`.** Con esta versión de test-utils, toda aserción
  sobre el texto después de `setData` espera al siguiente tick.
- **`toBe` entre instancias de Vue, nunca.** Si falla, Jest intenta imprimir la diferencia de dos
  objetos circulares y se queda sin memoria. Se compara la identidad como booleano.
- **Criterio de cierre.** La prueba de regresión del cuaderno se pone roja con la preparación y verde
  con el arreglo, en el estado de la fase.

---

## 📋 Por incidente

| # | Estado de partida | Preparación aplicada | Resultado |
|---|---|---|---|
| 01 | F0 | `npm install vue-template-compiler@2.6.12 --save-exact --save-dev` | Build: `Vue packages version mismatch` con rutas y dos líneas sobre `vue-loader`. `check:versions`: 1 con el fallo, 0 con el parche |
| 02 | F3 + inyector de caos (sección 🔥 de F3) | `CHAOS=timeout` y `CHAOS=empty` | Sin `timeout`, axios sigue pendiente a los 12 s; con `timeout: 8000`, `ECONNABORTED` a los 8,0 s. Los seis modos del inyector se comportan como dice F3. Prueba: roja sin `loaded` ni la línea vacía, verde con ellas |
| 03 | F2 | Guard exportado como `authGuard` sin cambiar su lógica (paso previo) y `localStorage.removeItem("token")` | Roja: el store conserva `mock-jwt-token-123`. Verde con `CLEAR_SESSION` en el guard. `token` queda en `""`, no en `null` |
| 04 | F4 (estado final de F7) | `filteredTickets` en `data`, watcher sobre `search` y la copia inicial en el `.then` de la carga | Roja con el bug y con el parche de dos watchers; verde solo con el `computed` |
| 05 | F5 (estado final de F7) | Rama `incidente/05` (rediseño del 20/10/2026): columna de etiquetas y botón «🏷️ facturación» en `TicketsTable`, `addBillingTag` con `ticket.tags = saved.tags` en `TicketsView`, y `"tags": ["correo"]` solo en el ticket 2 | Prueba de la vista (interna, con `ticketService` mockeado): el 2 se repinta y el 3 no con la rama; los dos con `$set`; y con la refactorización del cuaderno (`normalizeTicket`, `apiClient` mockeado) el 3 se repinta sin `$set`. Build y lint de la rama en verde. La prueba de regresión del cuaderno (`normalizeTicket`) ya estaba verificada: roja sin normalizar, verde con ella; la reconstrucción campo a campo dejaba fuera `createdAt` y `reporter` |
| 06 | F6 (estado final de F7) | Sin `<keep-alive>` y sin `validate()` en `next()` | Las dos pruebas (`mount` con Vuelidate en `localVue`) verdes con F6, rojas con la preparación |
| 07 | F7 | Chart en `data` y `beforeDestroy` comentado en `StatusDoughnut.vue` | Pruebas con `jest.mock("chart.js")` y la prop `counts`: verdes con F7, rojas con la preparación. Chart.js 2.9.4 no lanza `Canvas is already in use` (ese error es de la 3) |
| 08 | F8 | `off` comentado en `beforeDestroy` de `TicketsView` | Sin `off`: las dos rojas. F8 intacto: la de `off` verde y la de duplicados roja (el handler de F8 no es idempotente). Con la defensa `some(...)`: las dos verdes |
| 09 | F9 | Síntomas 1 y 3: sin romper nada. Síntoma 2: `selectedTicket` como objeto en `data` (F9 ya publica la corrección con `selectedId`) | Prueba con `selectTicket`: verde con F9, roja con el objeto. El relé del servidor de F8 no reenvía `ticket:updated`: con las tres líneas del ejercicio 10 de F8, sí |
| 10 | F11 | `strict: false`, `ui` sin `namespaced`, y `ui` con `loading` y `SET_LOADING` (el indicador global que agregó el legacy) | Las dos pruebas verdes en sano y rojas con la preparación. `toThrow()` no ve el error de `strict`: se recoge con `Vue.config.errorHandler` |
| 11 | F11 | Rotura 1: sin `clearAllMocks` y `context` fuera del `beforeEach` en `store-tickets.spec.js`. Rotura 2: sin `return` en el test de `getTickets` | El archivo completo falla en la prueba de caché, que sola pasa (8 commits heredados). Con el servicio roto, la prueba sin `return` sigue verde |
| 12 | F11 | Build de producción servido con `npx serve -s dist -l 5000` (serve 14.2.6) | El bundle no trae `[Vue warn]` ni el mensaje de `strict`. Con `strict`, la escritura directa ocurre igual: solo se registra el error |
| 13 | F11 | `mock/db.incidente-13.json`, abajo | Con el código de F7: `LMC` 7 resueltos, 1.300 puntos, y `???` con 1. Con el parche: `lmcano` 4 (700), `lmcorrea` 3 (600) y `jpmesa (usuario borrado)` 1 (100). La prueba de regresión: roja antes, verde después |

---

## 🗄️ El `db.json` alterno del incidente 13

Sobre la semilla de la Fase 3, se agrega un usuario y siete tickets. La semilla ya trae un ticket
`resolved` de `lmcano` (el #3), así que se agregan tres para que sumen cuatro, como dice el ticket.

```json
{ "id": 4, "username": "lmcorrea", "name": "Laura Milena Correa", "role": "agent" }
```

```json
[
  { "id": 4, "title": "No abre el cuadre de caja del sábado", "description": "", "status": "resolved", "priority": "high", "assignee": "lmcano", "reporter": "dprios", "createdAt": "2022-06-06T09:00:00Z" },
  { "id": 5, "title": "La factura no sale con el NIT", "description": "", "status": "resolved", "priority": "medium", "assignee": "lmcano", "reporter": "dprios", "createdAt": "2022-06-07T10:00:00Z" },
  { "id": 6, "title": "El datáfono no conecta", "description": "", "status": "resolved", "priority": "low", "assignee": "lmcano", "reporter": "dprios", "createdAt": "2022-06-08T11:00:00Z" },
  { "id": 7, "title": "No llega el correo de la resolución", "description": "", "status": "resolved", "priority": "medium", "assignee": "lmcorrea", "reporter": "dprios", "createdAt": "2022-06-06T14:00:00Z" },
  { "id": 8, "title": "Error al cerrar turno", "description": "", "status": "resolved", "priority": "high", "assignee": "lmcorrea", "reporter": "dprios", "createdAt": "2022-06-07T15:00:00Z" },
  { "id": 9, "title": "Reimprimir factura de ayer", "description": "", "status": "resolved", "priority": "low", "assignee": "lmcorrea", "reporter": "dprios", "createdAt": "2022-06-08T16:00:00Z" },
  { "id": 10, "title": "Cambio de clave del cajero", "description": "", "status": "closed", "priority": "low", "assignee": "jpmesa", "reporter": "dprios", "createdAt": "2022-06-09T08:00:00Z" }
]
```

---

## 📌 Decisión cerrada

- **Incidente 05.** Se quedó en la Fase 5 con una rama de preparación (decisión del autor del
  20/10/2026), en vez de moverlo a la Fase 9 como se había recomendado: la rama trae el etiquetado
  rápido del legacy, que es justo el código que dispara la limitación. Verificado como dice la
  fila 05 de arriba.

---

## 🍃 Curso 02 — `02-complement-mongodb-backend/cuaderno-incidentes.md`

Escrito con lo que se corrió en la tanda V7 (15/10/2026), sobre `mongo:4.4` en contenedor,
Node 14.21.3 y `mongodb@3.6.12`. Los escenarios que el cuaderno nombra como
`seed.incidente-0N.js` se armaron así; el código de la prueba está en
`zz-code/vue2-legacy-for-backend-devs-20261014-b44a/backend/tiquetera-backend/incidentes/cuaderno02.js`.

| # | Preparación aplicada | Resultado |
|---|---|---|
| 01 | Un contenedor ocupando el puerto publicado y `docker compose up -d` | El `up` falla con `Bind for …:27017 failed: port is already allocated`; `ps -a` deja el servicio en `created` y el log de `mongo` vacío (el choque es de Docker, no de `mongod`). La imagen 4.4 no trae `mongosh`: el `doctor.sh` usa `mongo` |
| 02 | 100 tickets de marzo de 2020, la mitad con `createdAt` como string ISO | El rango de marzo cuenta 50 de 100; la prueba de tipos roja; tras migrar con `new Date()`, verde y 100 en marzo |
| 03 | Tres tickets: `assignee` con valor, `null` y sin el campo | `{ assignee: null }` cuenta 2 y `{ $exists: false }` 1 (V6, F2) |
| 04 | 1.000 tickets, 20 con 15.000 entradas de `history` | El grande pesa 1.098.971 bytes; la prueba del techo de 100 KB roja (20 tickets); con el historial en `ticket_events` y los últimos 50 embebidos, verde |
| 05 | `scripts/generate.js --tickets 100000 --comments 400000` | Pantalla de 50 abiertos: 3.351 ms sin índice en `comments.ticketId`, 44 ms con él; con el `$lookup` escrito primero, más de 20 s sin índice y 440 ms con él (4.4 adelanta el `$match`, no el `$sort` ni el `$limit`) |
| 06 | Un ticket libre por ronda, 50 rondas, dos agentes a la vez | `findOne` + `updateOne`: dos ganadores en 50 de 50 rondas; con la condición en el filtro, uno siempre |
| 07 | La base del generador y `{ createdAt: -1, status: 1 }` | `IXSCAN` de 100.000 claves y 100.000 documentos para 17.875 (85 ms); con `{ status: 1, createdAt: -1 }`, 20 y 20 con `limit(20)` |
| 08 | `scripts/seed-antipattern.js` (100.000 tickets en `soporte_v1`) y `scripts/migrate.incidente-08.js`, publicado en el cuaderno, con el mapa de estados corrido y `tickets` antes que `users` (rehecho en K6, 16/10/2026) | El conteo total coincide; cada ticket queda con el estado siguiente y los `closed`, en `null` (59.495), y los 85.411 con agente pierden el `assignee`; la prueba de distribución roja; `fix-08-status.js` con el mapa por clave la deja verde en 23 s, gracias al índice único en `legacyId` |
| 09 | La base del generador | `_id: "status"` agrupa todo en una fila de 100.000; `"$status"` da cuatro |
| 10 | El backend de F10 con y sin serializer, contra json-server | Con el serializer, las 12 llamadas del frontend dan el mismo status y la misma forma (prueba diferencial de V7) |
| 11 | El realtime de F12 emitiendo el documento serializado | El cliente 2.4.0 recibe la misma forma que la API: `id` hex, sin `_id` ni `history` |
| 12 | `new Date("2021-03-01 23:30")` en Bogotá y en UTC | `2021-03-02T04:30:00.000Z` contra `2021-03-01T23:30:00.000Z` |

