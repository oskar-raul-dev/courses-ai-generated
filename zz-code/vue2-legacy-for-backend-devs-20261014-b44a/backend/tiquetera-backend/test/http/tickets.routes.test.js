// test/http/tickets.routes.test.js
const request = require("supertest");
const app = require("../../src/app");              // [V7: el snippet lo da por hecho]
const { connect, close } = require("../../src/db");
beforeAll(function () { return connect(); });
afterAll(close);   // [K6: F13 lo pedía y db.js de F10 no exportaba close]
const { mintToken } = require("../helpers/auth");   // acuña JWT de utilería (F11)

test("GET /tickets/:id inexistente → 404 real (manía del contrato)", async function () {
  const res = await request(app)
    .get("/tickets/5f8a1b2c3d4e5f6a7b8c9d0e")
    .set("Authorization", "Bearer " + mintToken({ username: "lmcano", role: "agent" }));
  expect(res.status).toBe(404);
});


