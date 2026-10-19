<!-- fila: | 18 | III · La concurrencia | "un ALTER rápido no bloquea a nadie" | [Fase 18](18-bloqueos-deadlocks-y-ddl.md) | -->
### 18 · "Un `ALTER` rápido no bloquea a nadie"

- **El instinto, en tu voz:** *"Agregar una columna con un valor constante no toca las filas: tarda dos milisegundos, y dos
  milisegundos no los nota nadie."*
- **Por qué es razonable:** el `ALTER` en sí tarda eso, medido.
- **Dónde se rompe:** antes de trabajar, el `ALTER` espera su bloqueo, y mientras espera, todo pedido nuevo sobre la tabla se pone en
  la fila detrás de él. Con una transacción abierta desde la noche, la tabla queda cerrada hasta que esa transacción termine.
- **La medición:** [M-33](bitacora-de-medicion.md#m-33--f18--la-cola-detrás-de-un-alter-de-dos-milisegundos): 30 de 30 lecturas
  en la cola mientras duró la exportación; 0 de 30 con `lock_timeout`.
- **La pregunta que lo habría anticipado:** *¿dónde está la frontera transaccional?*
  ([Fase 02](02-las-cinco-preguntas-desde-el-otro-lado.md#42-dónde-está-la-frontera-transaccional)): el `ALTER` necesita que no
  haya ninguna transacción abierta sobre la tabla, y eso depende de transacciones que no son suyas.
