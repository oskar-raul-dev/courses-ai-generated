// Mide el render de un cambio de fila en el tablero de previsualización del envío masivo
// (10.000 filas), sin React.memo y con React.memo. Cada variante: 5 cambios seguidos.
// No va al curso: vive en zz-code. Los resultados se escriben en resultados/.
const SESSION = JSON.stringify({ token: "tok_bench", user: { id: 1, email: "bench@esclusa.test", name: "Bench" } });

[0, 1].forEach((memo) => {
  it(`tablero 10.000 filas, memo=${memo}`, () => {
    cy.visit("/login");
    cy.window().then((w) => w.localStorage.setItem("esclusa.auth", SESSION));
    cy.visit(`/grants/board?n=10000&memo=${memo}`);
    cy.get("#toggle-first", { timeout: 120000 }).should("exist");
    const measurements = [];
    for (let i = 0; i < 5; i++) {
      cy.window().then((w) => { w.__lastRender = undefined; });
      cy.get("#toggle-first").click();
      cy.window().its("__lastRender").should("be.a", "number").then((ms) => measurements.push(Math.round(ms)));
    }
    cy.then(() => {
      cy.writeFile(`cypress-bench/resultados/render-memo${memo}.json`, {
        rows: 10000,
        memo: memo === 1,
        measurementsMs: measurements,
        meanMs: Math.round(measurements.reduce((a, b) => a + b, 0) / measurements.length),
        browser: "Electron (Chromium) de cypress/included:10.11.0, headless",
      });
    });
  });
});
