> ⚠️ **Reemplazada el 14/10/2026** por `../react-16-legacy-for-backend-devs-20261014-d0dc/verificacion-a-mano-T1-T3.md`: el repo de prueba se rehízo en `d0dc` (revisión de continuidad P1–T3) y esta lista apunta a la historia anterior.

# Verificación a mano de T2 (para el autor)

Necesita navegador y DevTools; no se automatiza en el contenedor. Anota resultado y fecha.

## F03 · la consola con el caos (checkout `fase-03-mock-api-express-caos`)

Terminal 1: `CHAOS_LEVEL=high npm run mock:api`. Terminal 2: `npm start`.

1. Con el caos alto, intenta entrar varias veces. Cada intento termina en uno de estos: entra, mensaje "El servidor tuvo un problema. Intenta de nuevo.", mensaje de contraseña incorrecta, o cuelgue de hasta 5 s. Ninguno debe quedar en "Ingresando…" para siempre.
2. Entra con `ibatista@esclusa.test` / `esclusa123` y recarga (F5): la sesión sigue (pago #1).
3. Cierra sesión y recarga: vuelves a `/login` (la sesión no reaparece).
4. Pago #2: con la sesión abierta, y con el caos alto, una petición protegida que devuelva 401 debe llevarte a `/login` con la consola limpia. En F03 la pantalla no pide datos protegidos: haz una petición protegida a mano desde la consola del navegador; confirma que el log imprime `[auth] 401 recibido (request-id=…)`.
- Resultado: ____ · fecha: ____

## F03 · el giro ingenuo (terminal)

`npm run mock:api` sin caos; `git checkout -- mock/db.json`; `npm run traffic`; `npm run medir`.
- Esperado: premios entre 1.000 y 1.030, claves con dos premios entre 500 y 520, stock excedido entre 0 y 30. (La corrida de la fase: 1.008–1.020 premios.)
- Resultado: ____ · fecha: ____

## F03 · el mock de Google Play (terminal)

`PLAY_PENDING_MS=3000 PLAY_DUPLICATE=1 npm run mock:googleplay`. Crea una compra con `method: "cash"`, consulta su estado (pending), espera 3,5 s y consulta otra vez (confirmed); envía una notificación y mira que el log tenga dos eventos.
- Resultado: ____ · fecha: ____

## Incidente 07 · el cuelgue del login

Rama `incidente/07` (sin timeout): `CHAOS_LEVEL=high npm run mock:api` y `npm start`; intenta entrar hasta que el botón se quede en "Ingresando…". Después, la rama `fase-03-mock-api-express-caos` (con timeout): el botón no se queda pegado.
- Resultado: ____ · fecha: ____

## Incidente 08 · el 401 en la consola

Hasta F04 la pantalla no pide datos protegidos: el síntoma completo de "me saca a login al azar" se reproduce desde F04 en adelante. En F03, confirma con el caos alto que el 401 de una petición protegida te saca a `/login` (es el mismo pago #2 del punto 4).
- Resultado: ____ · fecha: ____
