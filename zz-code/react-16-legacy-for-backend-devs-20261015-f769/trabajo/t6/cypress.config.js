// Captura del tablero de F09 en Electron (no va al curso): jsdom no pinta canvas.
const { defineConfig } = require("cypress");
module.exports = defineConfig({
  e2e: { baseUrl: "http://localhost:3000", specPattern: "t6/cypress/e2e/**/*.cy.js", supportFile: false, video: false, screenshotsFolder: "t6/capturas", viewportWidth: 1280, viewportHeight: 900 },
});
