// [unión de V7: F13 no lo publica]
const { sign } = require("../../src/lib/auth");
function mintToken(claims) { return sign({ username: claims.username, role: claims.role, name: claims.name || claims.username }); }
module.exports = { mintToken };
