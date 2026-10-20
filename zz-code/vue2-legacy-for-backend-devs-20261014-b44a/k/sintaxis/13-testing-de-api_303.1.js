function __f(){
// test/http/tickets.routes.test.js
const request = require("supertest");
const app = require("../../src/app");               // app.js sin listen: por eso se separó en F10
const { connect } = require("../../src/db");
const { mintToken } = require("../helpers/auth");   // acuña JWT de utilería (F11)

beforeAll(function () { return connect(); });       // el singleton de F10, contra el memory-server
// (y en afterAll, cerrar ese cliente: si no, Jest termina con
//  "A worker process has failed to exit gracefully")

test("GET /tickets/:id inexistente → 404 real (manía del contrato)", async function () {
  const res = await request(app)
    .get("/tickets/5f8a1b2c3d4e5f6a7b8c9d0e")
    .set("Authorization", "Bearer " + mintToken({ username: "lmcano", role: "agent" }));
  expect(res.status).toBe(404);
});

test("PATCH de un tomado → 409 (la extensión pactada)", async function () {
  // ... sembrar tomado, PATCH con otro agente, esperar 409
});
}