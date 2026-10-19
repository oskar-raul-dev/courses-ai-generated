<!-- fila: | 16 | III · La concurrencia | "tomar un número es instantáneo" | [Fase 16](16-el-folio-sin-huecos.md) | -->
### 16 · "Tomar un número es instantáneo"

- **El instinto, en tu voz:** *"El contador se incrementa en un microsegundo; que las cajas lo compartan no puede costar nada."*
- **Por qué es razonable:** el `UPDATE … RETURNING` tarda lo mismo con una caja que con tres.
- **Dónde se rompe:** el número queda tomado hasta el `COMMIT`, y la transacción incluye lo que se haga con él: armar el
  comprobante, esperar al organismo. Cada caja espera eso, entero, por cada una que va delante.
- **La medición:** [M-29](bitacora-de-medicion.md#m-29--f16--la-fila-contador-con-tres-cajas-y-diez-mil-comprobantes): de 5,5
  a 36,0 ms de espera con 0 y 10 ms de armado adentro; 1,2 ms con el armado afuera; 0,21 ms con un punto de venta por caja.
- **La pregunta que lo habría anticipado:** *¿dónde está la frontera transaccional?*
  ([Fase 02](02-las-cinco-preguntas-desde-el-otro-lado.md#42-dónde-está-la-frontera-transaccional)): la del folio incluye al
  organismo, y todo lo que queda adentro lo paga la caja siguiente.
