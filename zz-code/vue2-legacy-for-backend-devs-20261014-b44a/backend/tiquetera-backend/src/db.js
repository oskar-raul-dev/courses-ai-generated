const { MongoClient } = require("mongodb");
const config = require("./config");

let client = null;
let db = null;

async function connect() {
  client = await MongoClient.connect(config.mongoUri, {
    useUnifiedTopology: true
  });
  db = client.db(config.dbName);
  return db;
}

function getDb() {
  if (!db) throw new Error("DB no conectada: llama a connect() al arrancar");
  return db;
}

async function close() {
  if (client) await client.close();
  client = null;
  db = null;
}

module.exports = { connect, getDb, close };
