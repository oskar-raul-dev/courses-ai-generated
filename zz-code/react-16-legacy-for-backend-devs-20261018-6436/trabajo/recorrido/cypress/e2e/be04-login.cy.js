// be04: el login fallido (401 por el interceptor global) y el correcto, con el authService nuevo.
describe("login contra el backend real", () => {
  it("contraseña mal, después bien", () => {
    const out = {};
    cy.intercept("POST", "**/login").as("login");
    cy.visit("/login");
    cy.get("#email").type("ibatista@esclusa.test");
    cy.get("#password").type("equivocada");
    cy.contains("button", "Iniciar sesión").click();
    cy.wait("@login").its("response.statusCode").then((c) => (out.primerLogin = c));
    cy.wait(500);
    cy.location("pathname").then((p) => (out.pantallaTrasError = p));
    cy.get("body").invoke("text").then((t) => (out.mensaje = (t.match(/Email o contraseña incorrectos/) || ["(no aparece)"])[0]));
    cy.get("#password").clear().type("esclusa123");
    cy.contains("button", "Iniciar sesión").click();
    cy.wait("@login").then((i) => {
      out.segundoLogin = i.response.statusCode;
      out.partesDelToken = i.response.body.token.split(".").length;
    });
    cy.location("pathname").should("eq", "/wheels");
    cy.contains("td", "Esclusa de Oro").then(() => cy.writeFile(Cypress.env("OUT"), out));
  });
});
