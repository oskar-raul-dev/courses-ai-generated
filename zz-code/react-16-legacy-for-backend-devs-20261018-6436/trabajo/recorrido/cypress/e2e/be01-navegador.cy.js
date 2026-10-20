// be01 en el navegador: ¿JavaScript puede leer el X-Request-Id del binario (3011) y del mock (3001)?
// ¿Qué ve fetch, y qué ve axios (el mismo 0.21.4 de la consola), ante el pánico sin recover?
const out = {};
describe("be01 visto desde el navegador", () => {
  it("lee headers y provoca errores", () => {
    cy.visit("/login");
    cy.readFile("/axios/axios.min.js").then((src) => cy.window().then((win) => win.eval(src)));
    cy.window().then(async (win) => {
      const read = async (url) => {
        try { const r = await win.fetch(url); return `status=${r.status} x-request-id(js)=${r.headers.get("X-Request-Id")}`; }
        catch (e) { return `fetch lanzó: ${e.name}: ${e.message}`; }
      };
      out.go_health = await read("http://localhost:3011/health");
      out.mock_wheels = await read("http://localhost:3001/wheels");
      out.go_players_sin_filtro = await read("http://localhost:3011/players");
      out.go_players_con_filtro = await read("http://localhost:3011/players?name_like=ju");
      try { await win.axios.get("http://localhost:3011/players"); out.axios = "sin error"; }
      catch (e) { out.axios = `axios: message=${e.message} response=${e.response ? e.response.status : "undefined"}`; }
    }).then(() => cy.writeFile(Cypress.env("OUT"), out));
  });
});
