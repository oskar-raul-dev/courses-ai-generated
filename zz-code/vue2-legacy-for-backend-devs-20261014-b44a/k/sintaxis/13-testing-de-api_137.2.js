var __o = {
// test/globalSetup.js — UN memory-server para toda la corrida
const { MongoMemoryServer } = require("mongodb-memory-server");

module.exports = async function () {
  const mongod = await MongoMemoryServer.create({
    binary: { version: "4.4.18" }          // ← el motor del curso, no "latest"
  });
  // en la v6, getUri() devuelve una PROMESA: sin el await, MONGO_URL vale
  // "[object Promise]" y cada suite cae con MongoParseError: Invalid connection string
  process.env.MONGO_URL = await mongod.getUri();
  global.__MONGOD__ = mongod;
};
};