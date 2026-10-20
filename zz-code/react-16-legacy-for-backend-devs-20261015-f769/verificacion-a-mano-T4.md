# Verificación a mano de T4 (para el autor)

Estas comprobaciones necesitan un navegador y DevTools; no se automatizan en el contenedor (plan §2.4, punto 4). Todas
se hacen en `esclusa-app/` de este directorio. Cada punto dice dónde ponerse, qué mirar y qué debe pasar. Anota la
fecha y el resultado al lado. Lo que sí corrió en contenedor está en el README §7.

Para levantar la app sin instalar nada: `docker run --rm -it -p 127.0.0.1::3000 -v "$PWD":/app -w /app node:14.21.3 sh -c "npm ci && npm start"`
y el puerto con `docker port`. Los mocks, igual, con `npm run mock:api` (3001) y `npm run mock:googleplay` (3002). La
consola los busca en `localhost:3001` y `localhost:3002`, así que esos dos sí tienen que publicarse con su número.

## F06 — redux-observable a fondo

`git checkout fase-06-redux-observable-a-fondo`, mock del 3001 y `npm start`. Login con `ibatista@esclusa.test` / `esclusa123`.

1. **Ventana de deshacer.** En `/grants`, encola un envío a Juan. A los diez segundos, sin tocar nada, pasa a
   "Enviando…" y luego a "Enviado". En DevTools: `grants/grantQueued` → (10 s) → `grants/sendGrantRequested` →
   `grants/grantSending` → `grants/grantSent` → `grants/grantConfirmed`.
2. **Deshacer.** Encola otro y toca «Deshacer» antes de los diez segundos: queda "Deshecho" y no sale ninguna petición.
3. **Doble clic.** Encola uno y haz doble clic rápido en «Enviar ahora»: en Network, **un** `POST /players/42/grants`.
4. **Búsqueda.** Escribe `Ana` en «Buscar jugador»: Ana aparece "— suspendido" con la casilla deshabilitada, y Anaís
   habilitada. En Network, una búsqueda por pausa, no una por tecla.
5. **El leak a propósito (§5.8).** En el panel Dispatch: `{ "type": "START_PURCHASES_REFRESH" }`. Network: un
   `GET /purchases?status=pending` cada cinco segundos. Cierra sesión y no toques nada: siguen saliendo, sin
   `Authorization`, y el log del mock cuenta `[3001] sin sesión #N`.
- Resultado: ____ · fecha: ____

## F07 — cierre a hora exacta y polling de compras

`git checkout fase-07-cierre-polling-compras`, los dos mocks y `npm start`.

1. **Rueda cerrada.** En el asistente, el select de premio ofrece "Giro en Rueda de fin de mes (cerrada)" deshabilitado.
2. **Polling.** Crea una compra:
   `curl -s -X POST localhost:3002/purchases -H 'Content-Type: application/json' -d '{"purchaseToken":"tok-oxxo-2","method":"cash"}'`.
   En `/purchases`, consulta `tok-oxxo-2`: "Esperando confirmación · consultando…", un `GET /purchases/tok-oxxo-2` cada
   dos segundos, y a los tres segundos de creada, "Confirmada"; los `GET` paran.
3. **Logout.** Repite con `PLAY_PENDING_MS=600000` en el mock del 3002 y otro token; cierra sesión mientras consulta: los
   `GET` paran y el log del 3002 no cuenta ninguna consulta sin sesión (solo el `POST` del `curl`).
4. **Caos en el 3002.** Con `CHAOS_LEVEL=high npm run mock:googleplay`: algún tick sale en rojo, el aviso aparece
   debajo, y el tick siguiente sale igual y lo borra.
- Resultado: ____ · fecha: ____

## Incidentes 13–17

- **13** (`incidente/13`, `CHAOS_LEVEL=high`): tras el primer "Falló", «Enviar ahora» no produce ninguna petición; las
  acciones se despachan; la búsqueda tampoco responde; la consola del navegador tiene un `Uncaught` con el `503`.
- **14** (`incidente/14`, `PLAY_PENDING_MS=600000`): logout con `/purchases` consultando → Network sigue con
  `GET /purchases/<token>` cada 2 s sin `Authorization`; el log del 3002 sube `[3002] sin sesión #N`.
- **15** (`incidente/15`, `CHAOS_LEVEL=high`): escribiendo `Anaís` a velocidad normal, cada tanto la lista muestra a Ana
  sola o con Anaís; en Network, dos búsquedas vivas y la de `Ana` volviendo última.
- **16** (`incidente/16`): con `TZ=America/Panama npm start`, de día, la Rueda de fin de mes aparece **sin** "(cerrada)".
  Con `TZ=America/Santiago`, entre las 23:00 y las 24:00 de Panamá, la ofrece mientras la de Panamá la niega.
- **17** (`incidente/17`, `CHAOS_LEVEL=high` en el **3002**): tras el primer `500`, los `GET` paran, el aviso rojo queda
  fijo, «Última consulta» se congela y la fila sigue diciendo "consultando…".
- Resultado: ____ · fecha: ____
