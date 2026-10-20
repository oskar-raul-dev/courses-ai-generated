// T12 (R19): la bitácora se abre desde la barra en /spin-log, y la ruta vieja ya no existe (cae al 404).
describe("R19 — la bitácora vive en /spin-log", () => {
  it("la barra lleva a /spin-log y la ruta vieja da 404", () => {
    cy.visit("/login");
    cy.get("#email").type("ibatista@esclusa.test");
    cy.get("#password").type("esclusa123");
    cy.contains("button", "Iniciar sesión").click();
    cy.location("pathname").should("eq", "/wheels");
    cy.contains("a", "Bitácora").click();
    cy.location("pathname").should("eq", "/spin-log");
    cy.contains("h1", "Bitácora").should("be.visible");
    cy.visit("/bitacora");
    cy.contains("404").should("be.visible");
  });
});
