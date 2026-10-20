// Recorrido de la auditoría de be00: la consola entera, con cada petición al 3001 y al 3002 registrada.
// Es el equivalente automatizable del HAR (el HAR del navegador lo captura el autor a mano).
const { defineConfig } = require("cypress");
module.exports = defineConfig({
  e2e: { baseUrl: "http://localhost:3000", specPattern: "cypress/e2e/**/*.cy.js", supportFile: false,
         video: false, screenshotOnRunFailure: true, defaultCommandTimeout: 15000 },
});
