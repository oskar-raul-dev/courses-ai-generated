const { MongoClient } = require("mongodb");
const config = require("./config");

let db = null;

async function connect() {
  const client = await MongoClient.connect(config.mongoUri, {
    useUnifiedTopology: true
  });
  db = client.db(config.dbName);
  return db;
}

function getDb() {
  if (!db) throw new Error("DB no conectada: llama a connect() al arrancar");
  return db;
}

module.exports = { connect, getDb };
