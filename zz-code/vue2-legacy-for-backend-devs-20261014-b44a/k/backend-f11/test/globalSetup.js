// test/globalSetup.js — UN memory-server para toda la corrida
const { MongoMemoryServer } = require("mongodb-memory-server");

module.exports = async function () {
  const mongod = await MongoMemoryServer.create({
    binary: { version: "4.4.18" }          // ← el motor del curso, no "latest"
  });
  process.env.MONGO_URL = await mongod.getUri();   // [V7: en la v6, getUri() es una promesa]
  process.env.MONGO_URI = process.env.MONGO_URL.replace(/\/[^/]*$/, "");
  global.__MONGOD__ = mongod;
};
