# Verificación a mano de T3 (para el autor)

Necesita navegador y DevTools; no se automatiza en el contenedor. Anota resultado y fecha.

## F04 · las ruedas en el store (checkout `fase-04-ruedas-crud`)

Terminal 1: `npm run mock:api` (sin caos). Terminal 2: `npm start`.

1. Entra con `ibatista@esclusa.test` / `esclusa123` y abre `/wheels`. La lista llega desde el API: en Redux DevTools (o en la consola, con `window.__REDUX_DEVTOOLS_EXTENSION__`) aparece `wheels/fetch` seguido de `fulfilled`.
2. Abre una rueda, edita un peso para que la suma sea 9.999 y guarda: el mensaje de validación dice que la suma debe ser 10.000 y no hay petición PUT.
3. Pon pesos enteros que sumen 10.000 y guarda: vuelves a la lista con el valor nuevo.
4. Con la rueda en `live` (en el mock, la de `id: 1`), abre la edición: el formulario no deja cambiar los pesos.
- Resultado: ____ · fecha: ____

## F04 · la línea de tiempo (`time travel` por el mock)

Con el mock sin caos, cambia el `status` de una rueda en `mock/db.json` a `live` mientras la pantalla de edición está abierta, y guarda desde la pantalla. Debe aparecer el mensaje de 409, no un error genérico, y la rueda no debe cambiar en la lista.
- Resultado: ____ · fecha: ____

## F05 · la ventana de deshacer (checkout `fase-05-envios-manuales`)

Terminal 1: `npm run mock:api`. Terminal 2: `npm start`. Abre `/grants/board` (el envío masivo).

1. Encola un envío y pulsa «Deshacer» antes de 10 s: el envío pasa a `reverted` y no sale ninguna petición POST en la pestaña Red.
2. Encola otro y espera más de 10 s sin tocar nada: el envío sale (`queued → sending → sent`) y ya no se puede deshacer.
3. Recarga la página con envíos en `queued`: los temporizadores viven fuera del store, así que esos envíos no se vuelven a disparar solos. Anota lo que ves.
- Resultado: ____ · fecha: ____

## F05 · el render del tablero (medición en Chrome headless)

La cifra publicada sale de `salidas/render-memo0.json` y `salidas/render-memo1.json`, con el arnés de `trabajo/cypress-bench/`. Para repetirla a mano: abre `/grants/board?memo=0` y `?memo=1` con las herramientas de rendimiento del navegador, cinco cambios de fila en cada una, y compara la columna `window.__ultimoRender` con las medias de la tabla de F05.
- Esperado: sin memo, media cerca de 233 ms; con memo, cerca de 74 ms, con el primer cambio de la variante con memo más lento que los siguientes. Un equipo distinto cambia el número; la forma de la diferencia debe mantenerse.
- Resultado: ____ · fecha: ____

## Incidente 09 · la pérdida de lo escrito

Rama `incidente/09` (con el bug): escribe en el formulario de una rueda, envía y recarga. Pierdes el texto. Después, la rama `fase-04-ruedas-crud` (con `preventDefault`): el envío no recarga la página.
- Resultado: ____ · fecha: ____

## Incidente 10 · la lista que no termina de cargar

Rama `incidente/10`: con el API lento (`CHAOS_LEVEL=high npm run mock:api`), entra a `/wheels`. Con el bug, el estado `loading` no se apaga cuando falla la petición. Con la corrección, aparece el mensaje de error y el botón de reintentar.
- Resultado: ____ · fecha: ____

## Incidente 11 ⭐ · la compensación doble

Rama `incidente/11` (sin dedupe por `caseId`): encola dos veces la misma compensación para la misma jugadora y motivo, y mira la pestaña Red. Con el bug salen dos POST. Con la corrección (`fase-05-envios-manuales`), solo sale uno y la segunda vez el servidor responde 409 con el mensaje de duplicado.
- Resultado: ____ · fecha: ____

## Incidente 12 · el envío que vuelve a «falló»

Rama `incidente/12`: envía una compensación que ya quedó `sent` y observa su estado. Con el bug, pasa a `failed`. Con la corrección, la transición no permitida se ignora y el estado se queda en `sent`.
- Resultado: ____ · fecha: ____

## A6 · Redux clásico frente a Toolkit

Abre `A6-redux-clasico-vs-toolkit.md` y copia el ejemplo de `createSlice` en `src/features/grants/` del repo de prueba: debe compilar y su prueba debe pasar. La comparación de líneas es una cuenta sobre el código, no una medida de rendimiento; reconstrúyela a mano si cambias algún bloque.
- Resultado: ____ · fecha: ____
