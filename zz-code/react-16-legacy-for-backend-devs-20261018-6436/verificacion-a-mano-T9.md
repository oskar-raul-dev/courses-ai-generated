# Verificación a mano de T9 (para el autor)

Lo que solo se ve con un navegador o con el reloj de la máquina en la mano. Lo que corrió en contenedor está en el README §7.
Repo: `esclusa-app/` de este directorio. Anota la fecha y el resultado al lado.

## be06 — la hora del servidor, en DevTools

Go en el `3001` desde `fase-be06-hora-dura-y-la-autoridad-del-reloj`, consola arriba, login con `ibatista@esclusa.test` / `esclusa123`.

1. En Network, cualquier respuesta del `3001` trae `X-Server-Time` con milisegundos, y `Access-Control-Expose-Headers`
   lo nombra junto a `X-Request-Id`.
2. En la consola del navegador, con una petición del interceptor a mano o con un `fetch`, `response.headers.get("x-server-time")`
   devuelve el valor (no `null`).
3. Pon una rueda a cerrar en un minuto (`UPDATE wheels SET closes_at = now() + interval '1 minute' WHERE id = 1`) y quédate en
   la tabla de ruedas. Anota si la consola muestra la rueda en `ended` sin recargar, después de la vuelta del barrido (10 s), o
   solo al recargar (el ejercicio 16 de be06 lo pregunta).
- Resultado: ____ · fecha: ____

## be-11 — el reloj de verdad, no el de Cypress

La rueda 1 a cerrar en treinta minutos. Desactiva la sincronización automática del reloj de tu máquina y adelántalo una
hora. Abre la consola y el asistente de envíos: *Giro en Esclusa de Oro (cerrada)*, deshabilitado. Con `curl` desde un
contenedor (con su reloj bien), el mismo envío responde `201`. Vuelve el reloj a automático y la rueda a 2030.
⚠️ Docker Desktop puede arrastrar el reloj de su máquina virtual con el del Mac: mira `X-Server-Time` antes de concluir.
Si el servidor también se adelantó, la prueba no vale así (anótalo), y queda la de Cypress.
- Resultado: ____ · fecha: ____

## be-13 — la conciliación con la pantalla abierta

Go en el `3001` desde `incidente/be-13`, la base sembrada de nuevo. Sesión de Marisol (`mdegracia@esclusa.test`), Conciliación,
Rueda de fin de mes: `tok-ago-31` como faltante. Sin cerrar la pantalla, los dos `curl` de la preparación; después *Conciliar
rueda*. En Network, el cuerpo del `POST` trae `missingInApi: ["tok-ago-31"]`. Repite desde la fase: el `201` devuelve
`missingInApi: []`, y el log del binario tiene la línea *"difiere"* con el `X-Request-Id` que imprimió la consola.
- Resultado: ____ · fecha: ____

## bea-06 — Santiago, con tus manos

En `psql`, las consultas del §5 (abril y septiembre) y el `SET TIME ZONE` del §1 con las tres zonas. Comprueba que los
resultados coinciden con los del apéndice.
- Resultado: ____ · fecha: ____
