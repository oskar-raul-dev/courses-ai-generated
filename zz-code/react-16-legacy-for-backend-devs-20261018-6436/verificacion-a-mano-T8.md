# Verificación a mano de T8 (para el autor)

Lo que solo se ve con un navegador o con las manos en tres terminales. Lo que corrió en contenedor está en el README §7.
Repo: `esclusa-app/` de este directorio, en `fase-be05-giro-concurrente`. Anota la fecha y el resultado al lado.

## be05 — la consola contra el giro nuevo

Go en el `3001` desde la fase, consola arriba, login con `mdegracia@esclusa.test` / `esclusa123`.

1. Ruedas: la Esclusa de Oro muestra sus segmentos como siempre; en Network, `GET /segments` trae `substitute` en el
   segmento `esclusa-de-oro` y la consola no lo muestra.
2. Asistente de envíos: mandar el mismo caso dos veces seguidas, rápido. El segundo recibe el `409` del contrato y la
   consola lo muestra como en la Fase 5; en Network, el `409` llega en milisegundos, sin la demora de entrega.
3. Tablero de la Rueda de fin de mes: igual que en be04.
- Resultado: ____ · fecha: ____

## be05 §6 — el bloqueo, con tus ojos

Con la rueda de medición sembrada y `SPIN_DELIVERY_MS=2000`:

1. Terminal 1: `BEGIN; SELECT remaining FROM stock WHERE wheel_id = 900 FOR UPDATE;` (sin `COMMIT`).
2. Terminal 2: `curl -s -X POST -d '{"idempotencyKey":"mano-1"}' localhost:3001/players/10001/spins` — queda colgado.
3. Terminal 3: las dos consultas de §6 paso 2. El giro aparece con `Lock / transactionid` y `pg_blocking_pids` nombra a la
   terminal 1.
4. `COMMIT` en la terminal 1: el `curl` responde a los ~2 s (la entrega).
- Resultado: ____ · fecha: ____

## bea-05 — las escenas, a mano

Las escenas se corrieron con `pg_sleep` para ordenar los pasos. Hacer a mano, alternando en dos `psql` contra una base
`bea05`, al menos el §1 (el stock en `-1`), el §3 (T2 esperando) y el deadlock por la clave foránea del §7, y comprobar que
los mensajes coinciden con los del apéndice.
- Resultado: ____ · fecha: ____

## bea-11 — el resumen de k6

Correr `server/load/giro.js` con `SCENARIO=notificacion -e VUS=200` contra el binario de la fase y leer el resumen con
el orden del §5. Comprobar que `dropped_iterations` no aparece (no corresponde en un modelo cerrado) y que el desglose por
estado está.
- Resultado: ____ · fecha: ____
