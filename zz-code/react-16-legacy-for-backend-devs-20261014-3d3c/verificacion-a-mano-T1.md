# Verificación a mano de T1 (para el autor)

Estas comprobaciones necesitan un navegador y DevTools; no se automatizan en el contenedor (plan §2.4, punto 4).
Cada una dice dónde ponerse, qué mirar y qué debe pasar. Anota la fecha y el resultado al lado.

## F00 · la app arranca en tu máquina (opcional, en tu plataforma)

1. `git checkout fase-00-setup-hola-mundo-cra` en `esclusa-app`, luego `nvm use && npm ci && npm start`.
2. Abre `localhost:3000`: debe verse "La Esclusa" y la tarjeta de la rueda con borde azul arriba.
3. Prueba de fuego de F00: `Ctrl+C`, recarga; la página muere. Vuelve a levantar; vuelve.
- Resultado: ____ · fecha: ____

## F01 · navegación sin recarga (checklist de F01 §5, pasos 1–6)

Checkout `fase-01-estructura-base-router-5`, `npm start`.

1. `/` redirige a `/wheels`; ves 3 tarjetas.
2. Clic en una tarjeta: va a `/wheels/1`. **Network con "Preserve log"**: al navegar no debe aparecer ninguna petición de tipo `document`.
3. "← Volver" te lleva al listado.
4. `/wheels/999` → "No existe la rueda #999".
5. `/cualquier-cosa` → 404 con la ruta.
6. Clic en "Jugadores": cambia el contenido, el navbar no parpadea y "Jugadores" queda resaltado.
- Resultado: ____ · fecha: ____

## F02 · Redux DevTools y Network (pieza forense, partes A y B)

Checkout `fase-02-autenticacion-minima`, `npm run mock:api` en una terminal y `npm start` en otra.

Parte A (Redux DevTools):
1. Login correcto con `ibatista@esclusa.test` / `esclusa123`. En la pestaña Redux: `auth/login/pending` → `auth/login/fulfilled`. En `fulfilled`, `user` no debe tener `password`.
2. Login con contraseña mala: `auth/login/rejected`, `error` = "Email o contraseña incorrectos", `token` = null.

Parte B (Network y consola):
3. Tras loguear, la consola imprime `[req-id …]`. En Network, la petición `GET /users?…` tiene `X-Request-Id` en Response Headers, y ese id coincide con el de la consola.
4. Apaga el mock, intenta loguear: el log de error no trae `req-id` (el fallo fue de conexión).
5. Mock arriba, login con contraseña mala: anota el `req-id`.
- Resultado: ____ · fecha: ____

## Incidente 06 · el bug B (la `/login` envuelta en `PrivateRoute`)

Checkout `incidente/06`, `npm run mock:api` y `npm start`, sin sesión, entra a `/login`.
- Esperado con el bug: la pestaña se queda redirigiendo (parpadeo o titileo). Sin el bug (`fase-02`): la pantalla de login se queda quieta.
- Resultado: ____ · fecha: ____

## Incidente 02 · el fenómeno del USB y `node-gyp` (dos máquinas, o una máquina y un contenedor)

1. En `incidente/02`, `node -p process.arch`, luego `npm install` con Python 3 solamente (sin Python 2) en un Mac arm64: debe fallar en `node-gyp`.
2. Copia `node_modules` de una máquina a otra (o de un contenedor a otro): anota qué falla y por qué.
- Resultado: ____ · fecha: ____

## Qué se queda pendiente aunque T1 cierre

- A6 y las pruebas de F04 (`connect()`) no forman parte de T1.
- `eject` de A4 se corre solo en copia descartable (pendiente).
