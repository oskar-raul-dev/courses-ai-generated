// La semilla del orden aleatorio, impresa en la terminal. Con `npm test` se ve
// en la ventana de Chrome; con `test:ci` no sale en ningún sitio si nadie la
// imprime, y sin ella un fallo por orden no se puede repetir.
jasmine.getEnv().addReporter({
  jasmineDone: (result) => console.log(`Semilla de Jasmine: ${result.order.seed}`),
});
