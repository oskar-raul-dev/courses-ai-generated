function __f(){
// test/helpers/db.js — cada suite, su base virgen
const { MongoClient } = require("mongodb");
let client;

async function connect() {
  client = await MongoClient.connect(process.env.MONGO_URL,
    { useUnifiedTopology: true });
  // nombre único por suite: aislamiento sin limpiar nada
  return client.db("test_" + Date.now() + "_" + Math.random().toString(36).slice(2));
}
async function close() { if (client) await client.close(); }
module.exports = { connect, close };
}