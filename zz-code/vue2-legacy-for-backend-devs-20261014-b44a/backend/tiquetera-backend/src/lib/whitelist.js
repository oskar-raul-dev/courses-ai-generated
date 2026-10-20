// src/lib/whitelist.js — solo pasan los campos que el cliente PUEDE decidir
function whitelist(obj, keys) {
  var out = {};
  keys.forEach(function (k) { if (obj[k] !== undefined) out[k] = obj[k]; });
  return out;
}

module.exports = { whitelist };
