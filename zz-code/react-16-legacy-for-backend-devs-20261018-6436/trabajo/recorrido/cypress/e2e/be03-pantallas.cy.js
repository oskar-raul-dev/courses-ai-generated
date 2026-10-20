// be-04 y be-06: qué muestran la tabla de ruedas y el tablero de la Rueda de fin de mes.
describe("pantallas contra Go", () => {
  it("lee el cierre de la Esclusa de Oro y las tarjetas del tablero", () => {
    const out = {};
    cy.visit("/login");
    cy.get("#email").type("ibatista@esclusa.test");
    cy.get("#password").type("esclusa123");
    cy.contains("button", "Iniciar sesión").click();
    cy.contains("td", "Esclusa de Oro").parents("tr").find("td").eq(1).invoke("text").then((t) => (out.cierreEnLaTabla = t));
    cy.contains("a", "Dashboard").click();
    cy.get("#dashboardWheel").select("Rueda de fin de mes");
    cy.get('[data-testid="metric-card"]').should("have.length", 4);
    cy.wait(500);
    cy.get('[data-testid="metric-card"]').then((cards) => {
      out.tarjetas = [...cards].slice(0, 3).map((c) => c.innerText.replace(/\s+/g, " ").replace(/Actualizado.*/, "").trim());
      cy.writeFile(Cypress.env("OUT"), out);
    });
  });
});
