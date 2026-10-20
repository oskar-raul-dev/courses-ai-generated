// Mide el tiempo de render de un cambio de fila en un tablero de 10.000 filas, sin memo y con memo.
// Cada variante: 5 cambios seguidos. El resultado se escribe en resultados/.
const SESION = JSON.stringify({ token: "tok_bench", user: { id: 1, email: "bench@esclusa.test", name: "Bench" } });

[0, 1].forEach((memo) => {
  it(`tablero 10.000 filas, memo=${memo}`, () => {
    cy.visit("/login");
    cy.window().then((w) => w.localStorage.setItem("esclusa.auth", SESION));
    cy.visit(`/grants/board?n=10000&memo=${memo}`);
    cy.get("#cambiar", { timeout: 120000 }).should("exist");
    const midiciones = [];
    for (let i = 0; i < 5; i++) {
      cy.window().then((w) => { w.__ultimoRender = undefined; });
      cy.get("#cambiar").click();
      cy.window().its("__ultimoRender").should("be.a", "number").then((ms) => midiciones.push(Math.round(ms)));
    }
    cy.then(() => {
      cy.writeFile(`cypress-bench/resultados/render-memo${memo}.json`, {
        filas: 10000,
        memo: memo === 1,
        midicionesMs: midiciones,
        mediaMs: Math.round(midiciones.reduce((a, b) => a + b, 0) / midiciones.length),
        navegador: "Electron (Chromium) de cypress/included:10.11.0, headless",
      });
    });
  });
});
