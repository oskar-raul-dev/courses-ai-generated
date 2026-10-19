// T3: hechos de §6 del plan (zonas) y las conversiones literales que cita el incidente 21.
// Corre en node:18.18.2-alpine; imprime la versión de tz para que la salida se pueda fechar.
const zonas = ['Pacific/Galapagos', 'America/Guayaquil', 'America/Lima', 'America/Bogota'];
const offset = (zona, fecha) =>
  new Intl.DateTimeFormat('en-US', { timeZone: zona, timeZoneName: 'longOffset' })
    .formatToParts(fecha).find((p) => p.type === 'timeZoneName').value;

console.log(`node ${process.version} · icu ${process.versions.icu} · tz ${process.versions.tz}`);
for (const zona of zonas) {
  // Cada hora de 2016 a 2026: si el offset cambia alguna vez, hay cambio de hora.
  const vistos = new Set();
  for (let t = Date.UTC(2016, 0, 1); t < Date.UTC(2027, 0, 1); t += 3600e3) vistos.add(offset(zona, new Date(t)));
  console.log(`${zona.padEnd(18)} offsets 2016-2026: ${[...vistos].join(', ')}`);
}
const instante = '2026-03-12T23:59:59-05:00';
for (const zona of ['Pacific/Galapagos', 'America/Guayaquil']) {
  console.log(`new Date('${instante}').toLocaleString('es-EC', { timeZone: '${zona}' })  →  ` +
    JSON.stringify(new Date(instante).toLocaleString('es-EC', { timeZone: zona })));
}
