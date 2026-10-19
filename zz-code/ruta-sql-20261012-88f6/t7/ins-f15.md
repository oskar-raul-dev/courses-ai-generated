<!-- fila: | 15 | III · La concurrencia | "un nivel alto protege la regla" | [Fase 15](15-aislamiento-comparado.md) | -->
### 15 · "Un nivel alto protege la regla"

- **El instinto, en tu voz:** *"Si los técnicos corren en `REPEATABLE READ`, ninguno ve lo que el otro está haciendo, así que
  no pueden tomar la misma muestra; y en `SERIALIZABLE`, menos."*
- **Por qué es razonable:** el nivel promete que la transacción no ve cambios ajenos, y casi todas las anomalías de los libros son
  de lectura.
- **Dónde se rompe:** la regla "una muestra, un técnico" vive en una fila que todavía no existe. `REPEATABLE READ` la deja pasar
  en los dos motores; `SERIALIZABLE` la protege en Postgres con un error que la aplicación tiene que reintentar, y en MySQL con
  esperas y *deadlocks*. Sin el bucle, tres de cada cuatro tomas se pierden.
- **La medición:** [M-27](bitacora-de-medicion.md#m-27--f15--la-muestra-tomada-dos-veces-en-cuatro-niveles-y-dos-motores):
  dos tomas en `REPEATABLE READ`; 284–301 de 400 tomas perdidas en `SERIALIZABLE` sin bucle; 0 con `UNIQUE`.
- **La pregunta que lo habría anticipado:** *¿dónde está la frontera transaccional?*
  ([Fase 02](02-las-cinco-preguntas-desde-el-otro-lado.md#42-dónde-está-la-frontera-transaccional)): la regla cruza dos
  transacciones, y lo que cruza transacciones se escribe en la base o se vigila.
