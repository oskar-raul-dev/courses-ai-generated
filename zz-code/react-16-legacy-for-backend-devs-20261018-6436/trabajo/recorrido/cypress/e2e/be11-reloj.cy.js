// be-11: el reloj del navegador, una hora adelante. La rueda 1 cierra en 30 minutos (lo fija el script con psql).
// La consola la marca cerrada y no deja mandar el giro; el servidor, con su reloj, lo acepta.
describe("be-11: el reloj adelantado", () => {
  it("la consola cierra antes; el servidor no", () => {
    cy.clock(Date.now() + 60 * 60 * 1000, ["Date"]); // solo Date: los temporizadores siguen corriendo
    cy.visit("/login");
    cy.get("#email").type("ibatista@esclusa.test");
    cy.get("#password").type("esclusa123");
    cy.contains("button", "Iniciar sesión").click();
    cy.location("pathname").should("eq", "/wheels");
    cy.contains("a", "Envíos").click();
    cy.get("#prize option[value='spin:1']").should("be.disabled").and("contain.text", "(cerrada)");

    // El mismo envío, directo al servidor: su reloj dice que faltan 30 minutos.
    cy.request("POST", "http://localhost:3001/login", { email: "ibatista@esclusa.test", password: "esclusa123" })
      .then(({ body }) =>
        cy.request({
          method: "POST", url: "http://localhost:3001/players/42/grants",
          headers: { Authorization: `Bearer ${body.token}` },
          body: { grantId: "g-be11", caseId: "C-BE11", prize: "spin:1", reason: "be-11" },
        }))
      .then((res) => {
        cy.log(`servidor: ${res.status} · X-Server-Time ${res.headers["x-server-time"]}`);
        expect(res.status).to.eq(201);
        cy.window().then((win) => cy.writeFile("salida/be11.json", { status: res.status,
          serverTime: res.headers["x-server-time"], consoleNow: new win.Date().toISOString() }));
      });
  });
});
