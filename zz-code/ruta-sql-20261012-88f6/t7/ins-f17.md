<!-- fila: | 17 | III · La concurrencia | "una lectura larga infla la tabla que se escribe" | [Fase 17](17-mvcc-y-su-factura.md) | -->
### 17 · "Una lectura larga infla la tabla que se escribe"

- **El instinto, en tu voz:** *"La exportación lee resultados toda la noche y el laboratorio los corrige a la mañana: la tabla de
  resultados se va a inflar."*
- **Por qué es razonable:** en un motor con versiones, cada corrección deja una versión vieja que la exportación todavía puede ver.
- **Dónde se rompe:** dos veces. La tabla de resultados casi no crece (1,10 veces la del día en la peor media hora, nada la tabla
  entera): se escribe poco en proporción a su tamaño. Y la que sí infla es otra, que la exportación ni lee: el contador de
  comprobantes, de 1 a 45 páginas cada diez mil, porque la foto retiene versiones de toda la base.
- **La medición:** [M-31](bitacora-de-medicion.md#m-31--f17--la-lectura-abierta-y-la-media-hora-más-cargada-de-la-caja).
- **La pregunta que lo habría anticipado:** *¿cuál es la unidad de lectura?*
  ([Fase 02](02-las-cinco-preguntas-desde-el-otro-lado.md#44-cuál-es-la-unidad-de-lectura)), al revés: la de escritura. Lo que
  infla es cuántas veces se reescribe cada fila, no cuánto se escribe.
