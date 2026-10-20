var __a = [
// La pirámide: puro → service (memory-server) → HTTP (supertest) → contrato
// Regla: mockea fronteras caras/ajenas (HTTP externo, reloj, emits) — NO el motor gratis

MongoMemoryServer.create({ binary: { version: "4.4.18" } })  // el motor DEL CURSO
db único por suite ("test_" + unique)   // aislamiento por espacio, no por limpieza
makeService(db)                          // la costura: inyecta, no importes singletons

// concurrencia en tests: Promise.all + aserción de invariante (1 ganador, N rondas)
// auth en tests: mintToken(claims) — utilería, mismo verify real
// sockets: socket.io-client@2.4 conectado al server de test + done/promesa por evento
// coverage: se MIDE (--coverage), no se persigue
];