// be-02: después de giros del juego en la Esclusa de Oro, ¿qué muestra el tablero de esa rueda?
describe("be-02 en el tablero", () => {
  it("lee las tarjetas de la Esclusa de Oro", () => {
    cy.visit("/login");
    cy.get("#email").type("ibatista@esclusa.test");
    cy.get("#password").type("esclusa123");
    cy.contains("button", "Iniciar sesión").click();
    cy.contains("a", "Dashboard").click();
    cy.get("#dashboardWheel").select("Esclusa de Oro");
    cy.get('[data-testid="metric-card"]').should("have.length", 4);
    cy.wait(500);
    cy.get('[data-testid="metric-card"]').then((cards) => {
      const text = [...cards].map((c) => c.innerText.replace(/\s+/g, " ").trim());
      cy.writeFile(Cypress.env("OUT"), text);
    });
  });
});
