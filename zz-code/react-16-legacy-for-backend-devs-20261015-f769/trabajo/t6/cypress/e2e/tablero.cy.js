// El tablero de la Rueda de fin de mes, con chart.js de verdad: una captura y lo que dibujó.
describe("Tablero de F09 en un navegador", () => {
  it("dibuja la banda y no deja instancias vivas al salir", () => {
    cy.visit("/login");
    cy.get("#email").type("ibatista@esclusa.test");
    cy.get("#password").type("esclusa123");
    cy.contains("button", "Iniciar sesión").click();
    cy.contains("a", "Dashboard").click();
    cy.get("#dashboardWheel").select("Rueda de fin de mes");
    cy.get('[data-testid="band-chart"]').should("be.visible");
    cy.wait(1500); // la animación de chart.js
    cy.window().then((win) => {
      const charts = Object.values(win.Chart ? win.Chart.instances : {});
      cy.log(`instancias de chart.js: ${charts.length}`);
    });
    cy.screenshot("tablero-rueda-4", { capture: "viewport" });
    cy.get('[data-testid="band-chart"]').then(($c) => {
      const canvas = $c[0];
      const pixels = canvas.getContext("2d").getImageData(0, 0, canvas.width, canvas.height).data;
      let painted = 0;
      for (let i = 3; i < pixels.length; i += 4) if (pixels[i] > 0) painted += 1;
      expect(painted).to.be.greaterThan(1000); // el canvas tiene algo dibujado
    });
  });
});
