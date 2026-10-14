// Runs bea-12's buildPatients() as extracted (generar.js) and checks the identifiers against the Fase 05 regex.
// Writes patients.json for mongoimport. Usage (node:14.21.3): node generar-pacientes.js
const fs = require('fs');
const src = fs.readFileSync('generar.js', 'utf8');
const buildPatients = new Function('require', src + '\nreturn buildPatients;')(require);
const patients = buildPatients();
const re = eval(fs.readFileSync('../angular8/fase12/regex.txt', 'utf8').trim());
const bad = patients.filter(p => !re.test(p.documentId));
const byShape = {};
console.log('pacientes generados:', patients.length, '| documentId que no pasan la regex de la Fase 05:', bad.length, bad.slice(0, 3).map(p => p.documentId));
console.log('ejemplos:', patients.slice(0, 3).map(p => p.documentId).join(', '));
fs.writeFileSync('patients.json', JSON.stringify(patients));
