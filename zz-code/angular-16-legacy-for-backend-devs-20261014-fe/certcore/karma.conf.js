// karma.conf.js
// Generado con `ng generate config karma` y editado. Comentarios en español,
// como todo el código del proyecto — esto también es código.
module.exports = function (config) {
  config.set({
    basePath: '',
    frameworks: ['jasmine', '@angular-devkit/build-angular'],
    plugins: [
      require('karma-jasmine'),
      require('karma-chrome-launcher'),
      require('karma-jasmine-html-reporter'),
      require('karma-coverage'),
      require('@angular-devkit/build-angular/plugins/karma'),
    ],
    client: {
      jasmine: {
        // El orden aleatorio es el DEFECTO de Jasmine desde la 3, y se deja
        // puesto a propósito. Es lo único que delata que dos tests dependen
        // uno del otro por culpa de un servicio `providedIn: 'root'` que
        // sobrevive entre specs. Apagarlo esconde el incidente 17 en vez de
        // arreglarlo.
        random: true,
        // Para repetir un orden concreto: JASMINE_SEED=83104 npm run test:ci.
        // `ng test` no tiene `--seed` en la 16 —"Unknown argument: seed"—, así
        // que la semilla entra por aquí. Sin la variable, Jasmine sortea una.
        seed: process.env['JASMINE_SEED'],
      },
      // La consola del navegador NO se limpia entre ejecuciones: cuando un
      // test falla por un error que nadie capturó, el mensaje sigue ahí.
      clearContext: false,
    },
    reporters: ['progress', 'kjhtml'],
    browsers: ['Chrome'],
    customLaunchers: {
      // Chrome sin ventana. `--no-sandbox` hace falta dentro de un contenedor
      // —donde no hay usuario ni namespaces— y es inofensivo fuera. La Fase 13
      // te va a agradecer que ya esté escrito.
      ChromeHeadlessCI: {
        base: 'ChromeHeadless',
        flags: ['--no-sandbox', '--disable-gpu'],
      },
    },
    coverageReporter: {
      dir: require('path').join(__dirname, './coverage/certcore'),
      subdir: '.',
      reporters: [{ type: 'html' }, { type: 'text-summary' }, { type: 'lcovonly' }],
      /**
       * ⭐ Los dos umbrales, y el segundo es el que de verdad muerde.
       *
       * `global` es el número que se lleva a una reunión y el que miente: con
       * treinta funciones puras cubiertas, el 80 % global se alcanza SIN
       * testear ni un componente. Es el incidente 20.
       *
       * `each` es por archivo, y es el que impide el agujero: ningún archivo
       * puede quedarse por debajo del 50 %, así que no se puede compensar un
       * servicio sin probar con un módulo de constantes al 100 %.
       *
       * Las ramas van más bajas que las sentencias a propósito: un `if` de
       * guarda que nunca se cumple en producción tampoco se cumple en un test,
       * y perseguirlo produce tests que inventan situaciones imposibles.
       */
      check: {
        global: { statements: 80, branches: 70, functions: 80, lines: 80 },
        each: { statements: 50, branches: 40, functions: 50, lines: 50 },
      },
    },
    restartOnFileChange: true,
  });
};
