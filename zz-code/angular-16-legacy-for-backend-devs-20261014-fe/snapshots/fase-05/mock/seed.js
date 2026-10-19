// mock/seed.js
const fs = require('fs');
const path = require('path');

// Un script de Node y no un `cp`: el curso corre en Windows, Linux y macOS, y
// esto se comporta igual en los tres. Copiar a mano es la primera fuente de
// "en mi máquina el ejercicio no arranca".
const seedPath = path.join(__dirname, 'db.seed.json');
const dbPath = path.join(__dirname, 'db.json');

fs.copyFileSync(seedPath, dbPath);

console.log('db.json regenerado desde db.seed.json');
