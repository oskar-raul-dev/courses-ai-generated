// test/globalTeardown.js
module.exports = async function () { await global.__MONGOD__.stop(); };