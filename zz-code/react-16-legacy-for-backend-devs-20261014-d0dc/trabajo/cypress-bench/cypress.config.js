// Harness de medición del tablero de envíos (F05). No va al curso: vive en el repo de prueba.
const { defineConfig } = require("cypress");

module.exports = defineConfig({
  e2e: {
    baseUrl: "http://localhost:3000",
    specPattern: "cypress-bench/e2e/**/*.cy.js",
    supportFile: false,
    video: false,
    screenshotOnRunFailure: false,
    defaultCommandTimeout: 60000,
  },
});
