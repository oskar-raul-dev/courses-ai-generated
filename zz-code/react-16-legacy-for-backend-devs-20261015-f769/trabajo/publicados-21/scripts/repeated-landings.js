// scripts/repeated-landings.js — ¿a cuántos jugadores les salió dos veces el mismo segmento?
// Lee la bitácora del db.json del mock. Uso: node scripts/repeated-landings.js 4 avatar-comun
const db = require("../mock/db.json");

const wheelId = Number(process.argv[2]);
const segmentId = process.argv[3];
const perPlayer = new Map();
for (const row of db.spinLog) {
  if (row.wheelId === wheelId && row.landedSegment === segmentId) {
    perPlayer.set(row.playerId, (perPlayer.get(row.playerId) || 0) + 1);
  }
}
const landings = [...perPlayer.values()].reduce((sum, n) => sum + n, 0);
const repeated = [...perPlayer.values()].filter((n) => n >= 2).length;
console.log(`${segmentId}: ${landings} veces, en ${perPlayer.size} jugadores; ${repeated} jugadores lo sacaron dos o más veces`);
