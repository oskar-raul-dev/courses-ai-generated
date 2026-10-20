const { ObjectId } = require("mongodb");

// ":id" del URL → ObjectId. Un id malformado ("abc") NO es un error 500:
// es un recurso que no existe → 404, como json-server habría respondido.
function toObjectId(id) {
  return ObjectId.isValid(id) ? new ObjectId(id) : null;
}

module.exports = { toObjectId };
