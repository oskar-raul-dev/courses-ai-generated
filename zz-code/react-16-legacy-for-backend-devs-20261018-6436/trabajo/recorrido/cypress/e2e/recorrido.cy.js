// El recorrido de be00, paso por paso. Cada petición de la consola queda en `log`:
// método, puerto, ruta, las claves de la query, las claves del cuerpo y el status.
const log = [];
const OUT = Cypress.env("OUT") || "salida/recorrido.json";

describe("Recorrido completo de la consola", () => {
  it("login, ruedas, envíos, compras, conciliación, tablero y logout", () => {
    cy.intercept({ url: /localhost:300[12]/ }, (req) => {
      const url = new URL(req.url);
      const entry = {
        method: req.method,
        port: url.port,
        path: url.pathname,
        query: [...url.searchParams.keys()].sort().join(","),
        body: req.body && typeof req.body === "object" ? Object.keys(req.body).sort().join(",") : "",
        auth: Boolean(req.headers.authorization),
      };
      req.on("response", (res) => {
        entry.status = res.statusCode;
        entry.requestId = res.headers["x-request-id"] || "";
        entry.expose = res.headers["access-control-expose-headers"] || "";
        log.push(entry);
      });
    });

    // 1. Login
    cy.visit("/login");
    cy.get("#email").type("ibatista@esclusa.test");
    cy.get("#password").type("esclusa123");
    cy.contains("button", "Iniciar sesión").click();
    cy.location("pathname").should("eq", "/wheels");
    cy.contains("td", "Esclusa de Oro");

    // 2. Ruedas: crear, editar, borrar
    cy.get("#name").type("Rueda del recorrido");
    cy.get("#closesAt").type("2030-12-20T20:00:00-05:00");
    cy.contains("button", "Crear rueda").click();
    cy.contains("td", "Rueda del recorrido").parents("tr").within(() => cy.contains("button", "Editar").click());
    cy.get("#name").clear().type("Rueda del recorrido (editada)");
    cy.contains("button", "Guardar cambios").click();
    cy.contains("td", "Rueda del recorrido (editada)").parents("tr").within(() => cy.contains("button", "Eliminar").click());
    cy.contains("td", "Rueda del recorrido (editada)").should("not.exist");

    // 3. Envíos: buscar, compensar, mandar; y el mismo caso otra vez (el 409)
    cy.contains("a", "Envíos").click();
    cy.wait(800); // al abrir, el asistente pide todos los jugadores (GET /players sin name_like)
    cy.get("#playerSearch").type("ju");
    cy.get("#player-42").check();
    cy.get("#caseId").type("C-9001");
    cy.get("#reason").type("Recorrido de be00");
    cy.contains("button", "Compensar").click();
    cy.contains("button", "Enviar ahora").click();
    cy.contains("td", "C-9001").parents("tr").should("contain", "Enviado").and("not.contain", "sin confirmar");
    cy.contains("button", "Compensar").click();
    cy.get("tbody tr").last().within(() => cy.contains("button", "Enviar ahora").click());
    cy.contains("Ese caso ya fue compensado");

    // 4. Compras pendientes (el 3002)
    cy.contains("a", "Compras").click();
    cy.get("#purchaseToken").clear().type("tok-efecty-1");
    cy.contains("button", "Consultar").click();
    cy.wait(2500);

    // 5. Conciliación de la Rueda de fin de mes
    cy.contains("a", "Conciliación").click();
    cy.get("#wheel").select("4");
    cy.contains("h4", "Probabilidades");
    cy.contains("button", "Conciliar rueda").click();
    cy.contains("Rueda conciliada");

    // 6. Tablero
    cy.contains("a", "Dashboard").click();
    cy.get("#dashboardWheel").select("Rueda de fin de mes");
    cy.get('[data-testid="metric-card"]').should("have.length", 4);

    // 7. Logout
    cy.contains("button", "Cerrar sesión").click();
    cy.location("pathname").should("eq", "/login");
    cy.wait(1000).then(() => cy.writeFile(OUT, log));
  });
});
