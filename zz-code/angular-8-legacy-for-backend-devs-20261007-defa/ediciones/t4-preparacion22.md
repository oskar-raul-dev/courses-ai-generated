### `db.incidente-22.json` — la toma de Gatineau que llega después de su recepción

**Lo que cambia:** cuatro muestras de la semana del cambio de hora de marzo de 2021.
Tres son de Gatineau, con la toma copiada por la interfaz de la agenda (`-05:00`
pegado a la hora de la pared); una es de Ottawa, estampada por el navegador, como
control. Las recepciones son todas del navegador, en `Z`.

```jsonc
// samples — viernes 12: Gatineau, en invierno. El -05:00 es verdad.
{ "id": 7201, "orderId": 4301, "status": "received",
  "collectedBy": "agenda-gatineau", "collectedAt": "2021-03-12T09:00:00-05:00",  // 09:00 en Ottawa
  "receivedBy": "analista2",        "receivedAt":  "2021-03-12T14:41:00.000Z" }  // 09:41

// lunes 15: Gatineau, ya en horario de verano. La del ticket.
{ "id": 7202, "orderId": 4302, "status": "received",
  "collectedBy": "agenda-gatineau", "collectedAt": "2021-03-15T09:00:00-05:00",  // ← la pantalla dice 10:00
  "receivedBy": "analista2",        "receivedAt":  "2021-03-15T13:38:00.000Z" }  // 09:38: "antes" de la toma

// lunes 15: Gatineau, corrida igual, pero llegó con margen y el orden se conserva.
{ "id": 7203, "orderId": 4303, "status": "received",
  "collectedBy": "agenda-gatineau", "collectedAt": "2021-03-15T11:30:00-05:00",  // la pantalla dice 12:30
  "receivedBy": "analista2",        "receivedAt":  "2021-03-15T16:52:00.000Z" }  // 12:52

// lunes 15: Ottawa, todo del navegador. El control.
{ "id": 7210, "orderId": 4310, "status": "received",
  "collectedBy": "analista1",       "collectedAt": "2021-03-15T13:05:00.000Z",   // 09:05
  "receivedBy": "analista2",        "receivedAt":  "2021-03-15T13:50:00.000Z" }  // 09:50
```

Las cuatro órdenes (`4301`–`4303` y `4310`) se agregan con el mismo `createdAt` que
la toma de su muestra y `status: "in_process"`; no intervienen en el diagnóstico.

**El mecanismo:** `2021-03-15T09:00:00-05:00` es el instante `14:00Z`, que en Ottawa
—en `-04:00` desde el domingo 14— son las 10:00. La recepción de las 09:38 queda
22 minutos antes. La 7201 tiene el mismo formato y está bien porque el viernes 12
Ottawa todavía estaba en `-05:00`; la 7203 está corrida una hora y no se invierte
porque llegó con más de una hora de margen.

**Queda bien si:** la línea de custodia de la 7202 muestra *Recogida — agenda-gatineau
— 15/3/21 10:00* y *Recibida — analista2 — 15/3/21 9:38*; la de la 7201 muestra 9:00
y 9:41; y `offsetDoesNotMatchZone(collectedAt, 'America/Toronto')` da `true` para
la 7202 y la 7203 y `false` para la 7201 y la 7210.

