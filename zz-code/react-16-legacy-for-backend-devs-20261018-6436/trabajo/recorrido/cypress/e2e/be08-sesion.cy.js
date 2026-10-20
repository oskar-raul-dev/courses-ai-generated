// be-08: con JWT_TTL=3m, la primera petición después de los tres minutos.
describe("el token que vence", () => {
  it("entra, espera 3 min 10 s y pide el tablero", () => {
    const out = {};
    cy.intercept("**/localhost:3001/**").as("api");
    cy.visit("/login");
    cy.get("#email").type("ypinzon@esclusa.test");
    cy.get("#password").type("esclusa123");
    cy.contains("button", "Iniciar sesión").click();
    cy.location("pathname").should("eq", "/wheels");
    cy.wait(190000);
    cy.contains("a", "Dashboard").click();
    cy.wait("@api").then((i) => (out.status = i.response.statusCode));
    cy.wait(1500);
    cy.location("pathname").then((p) => (out.pantalla = p));
    cy.window().then((w) => (out.sesionGuardada = w.localStorage.getItem("esclusa.session") || Object.keys(w.localStorage).join(",") || "(vacío)"));
    cy.then(() => cy.writeFile(Cypress.env("OUT"), out));
  });
});
