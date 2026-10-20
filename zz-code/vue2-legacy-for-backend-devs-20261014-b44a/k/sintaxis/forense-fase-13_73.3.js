var __a = [
// test/globalSetup.js
module.exports = async function () {
  var server = await MongoMemoryServer.create({
    binary: { version: "4.4.18" }        // ← esto es lo que faltaba
  });
  …
};
];