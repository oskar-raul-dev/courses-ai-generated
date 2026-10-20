var __a = [
// test/fixtures/index.js — datos mínimos, deterministas, con nombre propio
const { ObjectId } = require("mongodb");

const users = {
  agent:    { _id: new ObjectId(), username: "lmcano", name: "Agente Uno",
              role: "agent" },
  reporter: { _id: new ObjectId(), username: "dprios", name: "Usuario Reportador",
              role: "reporter" }
};

function makeTicket(overrides) {
  return Object.assign({
    _id: new ObjectId(), title: "Ticket de prueba", description: "",
    status: "open", priority: "medium", assignee: null,
    reporter: "dprios", createdAt: new Date(), updatedAt: new Date(),
    schemaVersion: 3, history: []
  }, overrides || {});
}

module.exports = { users, makeTicket };
];