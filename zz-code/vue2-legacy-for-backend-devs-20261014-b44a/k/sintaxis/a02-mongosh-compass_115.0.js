// ~/.mongoshrc.js — tus helpers de guardia, siempre a mano
prompt = function () {
  return db.getName() + " [" + (db.serverStatus().host || "?") + "] > ";
};

// Atajos que usarás toda la vida
globalThis.lentas = function (ms) {
  return db.system.profile.find({ millis: { $gt: ms || 100 } })
    .sort({ ts: -1 }).limit(10).toArray()
    .map(o => ({ ms: o.millis, ns: o.ns, plan: o.planSummary }));
};

globalThis.colscans = function () {          // ⬅️ el detector de la F7/F14
  return db.system.profile.find({ planSummary: "COLLSCAN" })
    .sort({ ts: -1 }).limit(10).toArray().map(o => o.command);
};

globalThis.idx = function (col) {
  return db[col].getIndexes().map(i => ({ name: i.name, key: i.key }));
};