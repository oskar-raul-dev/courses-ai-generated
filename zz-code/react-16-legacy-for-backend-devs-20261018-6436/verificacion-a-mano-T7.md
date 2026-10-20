# Verificación a mano de T7 (para el autor)

Lo mismo que en las de T4–T6: lo que solo se ve en un navegador con DevTools, en `esclusa-app/` de este directorio. Lo
que sí corrió en contenedor está en el README §7. Login con `mdegracia@esclusa.test` / `esclusa123`. Para Go en el
`3001`: Postgres arriba, `cd server`, `DATABASE_URL=… go run ./cmd/seed -file ../mock/db.json` y `go run ./cmd/api`
(desde be04, también `JWT_SECRET`). Anota la fecha y el resultado al lado.

## be00 — el HAR del recorrido

`git checkout fase-be00-el-contrato-auditoria-del-mock`, `npm run mock:all`, `npm start`. DevTools → Network con
*Preserve log*; recorrer login, ruedas (alta, edición, borrado), jugadores con búsqueda, asistente de envíos, compras,
conciliación y tablero. *Save all as HAR*.

1. Las rutas del HAR coinciden con `server/evidence/inventario-medido.txt` (el medido con Cypress; el HAR sintético de
   la corrida está en `salidas/har-sintetico.json`).
2. Anotar si aparece alguna ruta que el inventario no tenga.
- Resultado: ____ · fecha: ____

## be01 — `X-Request-Id` desde el navegador (incidente be-01)

Go en el `3011` desde `fase-be01-go-y-la-forma-del-monolito`; en la consola del navegador, con la página en `:3000`:
`fetch("http://localhost:3011/health").then(r => console.log(r.headers.get("X-Request-Id")))`.

1. En la fase imprime el id; en Network la respuesta trae `Access-Control-Expose-Headers: X-Request-Id`.
2. `git checkout incidente/be-01` y repetir: imprime `null`, aunque Network **sí** muestra la cabecera en la respuesta.
- Resultado: ____ · fecha: ____

## be-03 — el asistente con el handler roto

`incidente/be-03`, Go en el `3001`, consola arriba. Abrir el asistente de envíos sin escribir nada en la búsqueda.

1. Network: la petición a `/players` sale como `(failed)` / `net::ERR_EMPTY_RESPONSE`; la consola del navegador dice
   `TypeError: Failed to fetch` o el error de red de axios.
2. El proceso de Go sigue vivo: otra pantalla carga.
- Resultado: ____ · fecha: ____

## be-02 y be-06 — el tablero

Con Go en el `3001` desde `incidente/be-06`: la tarjeta de la Rueda de fin de mes dice *10000 gratis · 0 pagos*, sin
errores en consola. En `fase-be03-crud-y-el-reemplazo`, *7566 gratis · 2434 pagos*.
- Resultado: ____ · fecha: ____

## be04 — el login y la sesión

`fase-be04-identidad-real-jwt-y-un-cve`, Go en el `3001`.

1. Login: Network muestra `POST /login` con el cuerpo `{email, password}` y la respuesta con `token`; ya no hay
   `GET /users?email&password`.
2. Application → Local Storage: la sesión guarda el token; pegar su parte central en un decodificador base64 muestra
   `sub`, `iat` y `exp` (12 h).
3. Las peticiones siguientes llevan `Authorization: Bearer …`.
- Resultado: ____ · fecha: ____

## be-08 — la sesión que vence

`incidente/be-08`, `JWT_TTL=3m go run ./cmd/api`. Entrar, abrir el asistente, escribir algo, esperar más de tres
minutos y hacer clic.

1. La consola termina en `/login` y lo escrito se pierde; Local Storage sin sesión.
2. Network: un `401` con `{"error":"Token inválido o expirado"}`.
- Resultado: ____ · fecha: ____
