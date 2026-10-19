# Boss II · El portal de 2018 · solución de referencia

No viaja al repositorio público (D42). Se ejecutó el 14/10/2026 sobre el modelo de
`uv run lab load --profile m --model` (caja M `3e59292e9918…`), después de
`src/14-la-base-no-estaba-lenta/boss/01_portal_2018.sql`.

- `solucion.sql`: `staging.portal_report` con un token `gen_random_uuid()` (v4: el v7 deja ver la fecha, Fase 10) único,
  `staging.portal_expired_link` con los 1.323.713 MD5 distintos de 2018 (los 3.902 `NroProtocolo` repetidos dan hashes
  repetidos: un enlace de 2018 abría dos informes), y el índice `(doctor_id, ordered_on DESC, lab_order_id DESC)` para la
  página del médico con keyset.
- Salidas: `../salidas/boss2-partida.txt` (lo que ve Verónica) y `../salidas/boss2-solucion.txt` (los criterios).
- Contra los criterios publicados:
  - diccionario MD5 de las seis sedes × 0..700.000 (4,2 M) contra los tokens: 0; los cien vecinos de `C-0118696`: 0
    (en el punto de partida, 100 de 100);
  - un informe por su token: 4 bloques (partida: 17.856);
  - página 1 del médico 144: 21 bloques; última (keyset desde la 1.100): 17 (partida: ~17.900 cada una);
  - total del médico: index-only scan, 8 bloques, `Heap Fetches: 0` (después del `VACUUM`);
  - enlaces de 2018: 1.323.713 vencidos, 0 coinciden con un token nuevo; la búsqueda de un vencido, 4 bloques.
- Lo que la solución no hace y un alumno podría hacer mejor: que el médico vea solo sus protocolos lo resuelve la
  aplicación; la seguridad por fila es del Bloque V.
