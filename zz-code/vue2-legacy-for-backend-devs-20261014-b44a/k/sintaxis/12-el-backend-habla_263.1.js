function __f(){
// src/services/tickets.service.js (el create de la Fase 10, completado)
const realtime = require("../realtime/io");
const { serializeTicket } = require("../lib/serializers");
// buildTicket: el armado del create de la Fase 11 (whitelist + reporter del token
// + status/createdAt/history) sacado a una función, para que el service lo reuse
const { buildTicket } = require("../lib/tickets");
const { getDb } = require("../db");

async function createTicket(data, user) {
  const doc = buildTicket(data, user);                       // Fase 11: reporter del token
  await getDb().collection("tickets").insertOne(doc);        // 1.º persistir
  const ticket = serializeTicket(doc);                       // 2.º MISMA forma que la API
  realtime.emit("ticket:created", ticket);                   // 3.º y solo entonces, hablar
  return ticket;
}
}