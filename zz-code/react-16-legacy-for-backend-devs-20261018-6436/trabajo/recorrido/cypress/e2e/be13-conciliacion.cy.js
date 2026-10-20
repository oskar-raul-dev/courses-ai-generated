// be-13: Marisol abre la conciliación de la Rueda de fin de mes; mientras la tiene abierta, la compra que
// faltaba (tok-ago-31, la de Efecty) se acredita; después concilia con lo que cargó antes.
describe("be-13: la conciliación con datos viejos", () => {
  it("lo guardado contra lo de ahora", () => {
    cy.visit("/login");
    cy.get("#email").type("mdegracia@esclusa.test");
    cy.get("#password").type("esclusa123");
    cy.contains("button", "Iniciar sesión").click();
    cy.location("pathname").should("eq", "/wheels");
    cy.contains("a", "Conciliación").click();
    cy.get("#wheel").select("4");
    cy.contains("tok-ago-31"); // la consola la muestra como faltante

    // Mientras tanto, el pago en efectivo se confirma y el juego avisa.
    cy.request("POST", "http://localhost:3002/purchases", { purchaseToken: "tok-ago-31", method: "card" });
    cy.request("POST", "http://localhost:3001/players/42/purchases", { purchaseToken: "tok-ago-31", productId: "spins-10" })
      .its("body.state").should("eq", "credited");

    cy.contains("button", "Conciliar rueda").click();
    cy.contains("Rueda conciliada");
    cy.request("POST", "http://localhost:3001/login", { email: "mdegracia@esclusa.test", password: "esclusa123" })
      .then(({ body }) => cy.request({ url: "http://localhost:3001/wheels/4/reconciliation",
        headers: { Authorization: `Bearer ${body.token}` } }))
      .then(({ body }) => cy.writeFile("salida/be13.json", body.purchases));
  });
});
