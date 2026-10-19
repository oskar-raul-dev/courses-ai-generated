# Lista de verificación a mano (DevTools) — P7, para el autor

Lo que no se automatiza (plan §2.4 punto 4). Cada tanda la completa con sus piezas
y el autor lo mira en su navegador contra el contenedor. Puertos: **nunca** los del
curso en el host; cada contenedor publica en `127.0.0.1` con puerto aleatorio, que se
lee con `docker port <contenedor>`. Usuarios de la historia: `ibatista` (operación),
`ypinzon` (soporte), `mdegracia` (contadora). Contraseña de práctica: la que fije la fase.

| Fase | Qué mirar | Dónde | Pasos |
|---|---|---|---|
| F01 | `withRouter` y hooks dan lo mismo; el 404 | React DevTools → Components | Abre `/wheels`, luego `/wheels/1`, luego una ruta inexistente. Compara el árbol de la clase y la de hooks. |
| F02 | El header `Authorization` y el `X-Request-Id` | Network, pestaña Headers | Entra con `ibatista`, abre `/wheels`, mira una petición. Repite tras recargar: la sesión se pierde (deuda, esperado). |
| F03 | Caos: la petición que queda `(pending)` | Network, columna Status | Con `CHAOS_LEVEL=high`, recarga `/wheels` varias veces hasta que una quede en `(pending)`. |
| F04 | Time-travel de los pesos | Redux DevTools → Slider | Edita pesos en una rueda `scheduled`, luego pásala a `live` e intenta editar: no debe dejarte. |
| F05 | Transiciones del envío `queued → sending → sent / failed → reverted` | Redux DevTools → Action list | Envía un premio, espera, deshace. La ventana de deshacer dura 10 s; cronométrala. |
| F05 | Pieza forense: la carrera en el store | Redux DevTools → Diff | Dos pestañas, mismo caso, mira el `Diff` de la última acción. |
| F06 | El memory leak: peticiones tras logout | Network, filtro por `Fetch/XHR` | Abre el tablero, cierra sesión, cuenta las peticiones durante 30 s. Debe ser cero tras la corrección (rama 14). |
| F07 | Polling de compras pendientes | Network, cascada | Crea una compra en efectivo (mock 3002); verifica que las consultas paran al confirmarse. |
| F09 | El gráfico de la banda con chart.js | Pantalla | jsdom no pinta canvas: mira el dashboard en el navegador. |
| F09 | `useMemo` en el dashboard | React DevTools → Profiler | Graba un render con el volumen de `mock/seed-volume.js`; compara con y sin la rama 19. |
| F10 | Cypress en modo interactivo | Ventana de Cypress | Solo si la fase lo pide: la imagen `cypress/included:10.11.0` no instala nada en el host. |
| F11 | Ejemplos de hooks y RxJS 7 del puente | Copia descartable | No en la rama de la fase; en un directorio aparte de `zz-code/`. |

Con la verificación hecha, la tanda escribe la fecha y el nombre de la pieza en la
bitácora del plan, con «verificado a mano».
