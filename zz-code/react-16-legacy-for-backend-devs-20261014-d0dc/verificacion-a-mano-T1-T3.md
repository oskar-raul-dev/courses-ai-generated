# Verificación a mano de T1–T3 (para el autor)

Estas comprobaciones necesitan un navegador y DevTools; no se automatizan en el contenedor (plan §2.4, punto 4).
Todas se hacen en el repo de prueba vigente, `esclusa-app/` de este directorio, que tiene la historia rehecha en la
revisión de continuidad del 14/10/2026. Cada punto dice dónde ponerse, qué mirar y qué debe pasar. Anota la fecha y el
resultado al lado.

Para levantar la app desde tu máquina hace falta `npm ci` en cada etiqueta (el `node_modules` del repo es el de la
última fase). Con Docker, sin instalar nada: `docker run --rm -it -p 127.0.0.1::3000 -v "$PWD":/app -w /app node:14.21.3 sh -c "npm ci && npm start"`
y el puerto con `docker port`.

## T1 · F00 — la app arranca (opcional, en tu plataforma)

1. `git checkout fase-00-setup-hola-mundo-cra`, luego `nvm use && npm ci && npm start`.
2. Abre `localhost:3000`: "La Esclusa" y la tarjeta de la Esclusa de Oro con borde azul arriba, "En vivo" y "Segmentos: 8".
3. Prueba de fuego: `Ctrl+C`, recarga; la página muere. Vuelve a levantar; vuelve.
- Resultado: ____ · fecha: ____

## T1 · F01 — navegación sin recarga

`git checkout fase-01-estructura-base-router-5`, `npm start`.

1. `/` redirige a `/wheels`; ves 3 tarjetas.
2. Clic en una tarjeta: va a `/wheels/1`. Con **Network y "Preserve log"**, al navegar no aparece ninguna petición de tipo `document`.
3. "← Volver" te lleva al listado. `/wheels/999` dice "No existe la rueda #999". `/cualquier-cosa` cae en el 404 con la ruta.
4. Clic en "Jugadores": cambia el contenido, el navbar no parpadea y "Jugadores" queda resaltado.
- Resultado: ____ · fecha: ____

## T1 · F02 — Redux DevTools y Network

`git checkout fase-02-autenticacion-minima`, `npm run mock:api` en una terminal y `npm start` en otra.

1. Login con `ibatista@esclusa.test` / `esclusa123`: `auth/login/pending` → `auth/login/fulfilled`, y `user` sin `password`.
2. Contraseña mala: `auth/login/rejected`, `error` = "Email o contraseña incorrectos", `token` = null.
3. Tras loguear, la consola imprime `[req-id …]`, y la petición `GET /users?…` trae `X-Request-Id` en Response Headers, con el mismo id.
- Resultado: ____ · fecha: ____

## T1 · Incidentes 02 y 06

- **06** (`incidente/06`, `npm run mock:api`, `npm start`, sin sesión, entra a `/login`): con el bug la pestaña se queda redirigiendo; en `fase-02` la pantalla de login se queda quieta.
- **02** (`incidente/02`, dos máquinas o una máquina y un contenedor): `npm install` con Python 3 solamente en un Mac arm64 falla en `node-gyp`; copiar `node_modules` entre arquitecturas falla al compilar Sass.
- **01** (`incidente/01`, con Node 20): `npm start` da `ERR_OSSL_EVP_UNSUPPORTED`; con `nvm use` (14.21.3) compila. *(Las ramas 01 y 02 se rehicieron en la revisión y no se volvieron a ejecutar: el cambio es el mismo que verificó T1.)*
- Resultado: ____ · fecha: ____

## T2 · F03 — la consola con el caos

`git checkout fase-03-mock-api-express-caos`. Terminal 1: `CHAOS_LEVEL=high npm run mock:api`. Terminal 2: `npm start`.

1. Intenta entrar varias veces. Cada intento termina en uno de estos: entra, "El servidor tuvo un problema. Intenta de nuevo.", contraseña incorrecta, o un cuelgue de hasta 5 s. Ninguno se queda en "Ingresando…" para siempre.
2. Entra y recarga (F5): la sesión sigue (pago #1). Cierra sesión y recarga: vuelves a `/login`.
3. Con la sesión abierta y el caos alto, una petición protegida que devuelva 401 te lleva a `/login` y el log imprime `[auth] 401 recibido (request-id=…)`.
- Resultado: ____ · fecha: ____

## T2 · F03 — el giro ingenuo y los dos mocks (terminal)

1. `npm run mock:all`: deben arrancar los dos mocks (`mock API en 3001` y `mock Google Play en 3002`).
2. Con el mock sin caos: `git checkout -- mock/db.json`, `npm run traffic`, `npm run measure`. Esperado: entre 1.000 y 1.047 premios, claves con dos premios entre 500 y 523, stock excedido entre 0 y 47 (seis corridas del 14/10/2026; en una el stock no se excedió).
3. `PLAY_PENDING_MS=3000 PLAY_DUPLICATE=1 npm run mock:googleplay`: crea una compra con `method: "cash"`, consulta su estado (`pending`), espera 3,5 s y consulta otra vez (`confirmed`); manda una notificación y mira que haya dos eventos.
- Resultado: ____ · fecha: ____

## T2 · Incidentes 07 y 08

- **07**: `incidente/07` (sin timeout), `CHAOS_LEVEL=high npm run mock:api`, `npm start`: intenta entrar hasta que el botón se quede en "Ingresando…". En `fase-03` el botón nunca se queda pegado.
- **08**: en `fase-03`, con el caos alto, una petición protegida con 401 te saca a `/login` (es el pago #2). El síntoma completo, "me saca al azar mientras trabajo", se ve desde F04, con la lista de ruedas pidiéndose al API.
- Resultado: ____ · fecha: ____

## T3 · F04 — el CRUD de ruedas

`git checkout fase-04-ruedas-crud`. Terminal 1: `npm run mock:api` (sin caos). Terminal 2: `npm start`. Entra con `ibatista@esclusa.test`.

1. `/wheels` muestra la tabla con tres ruedas. En Redux DevTools: `wheels/fetch/pending` → `wheels/fetch/fulfilled`, y el Diff de `fulfilled` llena `items` y apaga `loadingList`.
2. Crea una rueda con nombre y cierre: aparece en la tabla; el Diff de `wheels/create/pending` prende `loadingMutation`.
3. Edita la Semana del Canal: baja un peso en uno. La suma dice 9999, aparece "Los pesos suman 9999 y deben sumar 10000." y "Guardar cambios" se apaga. Compensa con otro peso y guarda: vuelve al modo "Nueva rueda".
4. Edita la Esclusa de Oro: los pesos están deshabilitados y aparece "En vivo: los pesos no se cambian…".
5. Elimina la rueda que creaste (con el `confirm`). El link de detalle de una rueda creada en la sesión dice que no existe: es la deuda declarada (§5.8).
6. **Time-travel**: en Redux DevTools, salta a la acción anterior a la eliminación; la tabla vuelve a mostrar la rueda borrada. Vuelve a la última.
7. Con `CHAOS_LEVEL=high`, recarga varias veces: aparecen, cada uno con su texto, "El servidor tuvo un problema. Intenta de nuevo." con "Reintentar", "El servidor tardó demasiado. Reintenta." y "La respuesta de ruedas vino con forma inesperada.".
- Resultado: ____ · fecha: ____

## T3 · F05 — envíos, ventana de deshacer y tablero

`git checkout fase-05-envios-manuales`. Terminal 1: `npm run mock:api`. Terminal 2: `npm start`.

1. `/grants`: marca a Juan P., caso `C-2210`, motivo "caída", "Compensar". La fila dice "En cola (se puede deshacer)". "Deshacer" antes de diez segundos: queda "Deshecho" y en Network no sale ninguna petición.
2. Compensa otra vez y espera: a los 10 s sale solo; la fila pasa por "Enviado (sin confirmar)" y en menos de un segundo dice "Enviado". En DevTools: `grants/grantQueued`, `grants/send/pending`, `grants/grantSent`, `grants/send/fulfilled`.
3. Marca a Juan y a María, mismo caso, "Compensar", y "Enviar todos ahora": el de Juan dice "Falló" con "Ese caso ya fue compensado para este jugador."; el de María, "Enviado"; el primero de Juan sigue "Enviado".
4. Doble clic rápido en «Enviar ahora» sobre un envío en cola (sube `GRANT_DELIVERY_MS=3000` para tener margen): `curl -s "http://localhost:3001/grants?caseId=<el caso>"` devuelve un solo registro.
5. `/grants/board?n=10000&memo=0` y `?memo=1`: con "Cambiar la fila 1", la variante con memo responde sensiblemente más rápido. En la consola del navegador, `window.__lastRender` después de cada clic: cerca de 235 ms sin memo y de 58 ms con memo en la máquina de la medición (cambia con el equipo; la diferencia se mantiene).
- Resultado: ____ · fecha: ____

## T3 · Incidentes 09–12

- **09** (`incidente/09`): crea una rueda; la página se recarga y la barra de direcciones muestra `/wheels?name=…&weight-sin-premio=…`. En `fase-04`, no.
- **10** (`incidente/10`): con `CHAOS_LEVEL=off`, la lista carga siempre; con `high`, tras un `503` la pantalla se queda en "Cargando ruedas…" y DevTools muestra `wheels/fetch/rejected` con `loadingList` en `true`.
- **11** (`incidente/11`, `GRANT_DELIVERY_MS=3000 npm run mock:api`): doble clic en «Enviar ahora»; DevTools muestra dos `grants/send/pending` y dos `grants/grantSent` para el mismo envío, y `GET /grants?caseId=C-2210` devuelve dos registros.
- **12** (`incidente/12`): el paso 3 de F05 deja el envío individual de Juan en "Falló" y el del masivo en "Enviado (sin confirmar)"; el `grants/rollbackGrant` lleva el id del masivo y el Diff muestra que cambió el individual.
- Resultado: ____ · fecha: ____

## T3 · A5 y A6

Los ejemplos de A5 §7, A6 §6 (el `createSlice` reducido) y A6 §11 (la receta) se extrajeron del `.md` y corren en
contenedor (`trabajo/apendices*.test.*`, 3/3). A mano solo queda leerlos contra F05: los nombres (`grantQueued`,
`rollbackGrant`, `GrantList`) tienen que ser los de la fase.
- Resultado: ____ · fecha: ____
