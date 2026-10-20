// Incidente 21 (no va al curso): la firma de la regla vieja en la bitácora, por jugador.
const db = require("/app/mock/db.json");
const { generateSpinLog } = require("/app/mock/spinLogGenerator");
const segments = db.segments.filter((s) => s.wheelId === 4);
for (const rule of ["substitute", "accommodating"]) {
  const log = generateSpinLog({ seed: 42, spins: 10000, wheelId: 4, segments, rule });
  const perPlayer = new Map();
  for (const r of log) if (r.landedSegment === "avatar-comun") perPlayer.set(r.playerId, (perPlayer.get(r.playerId) || 0) + 1);
  const twice = [...perPlayer.values()].filter((n) => n >= 2).length;
  const total = [...perPlayer.values()].reduce((a, b) => a + b, 0);
  const players = new Set(log.map((r) => r.playerId)).size;
  console.log(`${rule}: avatar-comun cayó ${total} veces en ${perPlayer.size} jugadores; ${twice} jugadores lo sacaron dos o más veces (de ${players} que giraron)`);
}
