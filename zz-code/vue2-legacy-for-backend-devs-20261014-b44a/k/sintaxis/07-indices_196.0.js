// Sesiones/eventos que expiran solos a los 30 días
db.events.createIndex({ createdAt: 1 }, { expireAfterSeconds: 2592000 })