// dump/generate-dump.js
// Genera el volcado sintético "de producción" de be02: siete años de deriva
// de esquema, fabricados a propósito y reproducibles byte a byte.
//
// Se corre con el Node del track base (12 o 14, ver A03):
//   node dump/generate-dump.js
//
// Escribe dump/patients.json, orders.json, samples.json, results.json y
// referenceRanges.json, listos para mongoimport --jsonArray.
'use strict';

var fs = require('fs');
var path = require('path');

// ---------------------------------------------------------------------------
// LA SEMILLA. Es lo más importante del archivo y por eso está arriba del todo.
//
// Mismo generador congruencial que el seed.js del track base, con la misma
// semilla: 20190902, la fecha de puesta en producción de LabCore. Cambiarla
// cambia TODOS los números de be02, be05 y be06, y con ellos media docena de
// tablas del material. Si alguna vez hay que tocarla, hay que rehacer las
// mediciones y las tablas a la vez.
// ---------------------------------------------------------------------------
var seed = 20190902;
function random() {
  seed = (seed * 9301 + 49297) % 233280;
  return seed / 233280;
}
function pick(list) { return list[Math.floor(random() * list.length)]; }
function pad(v, n) { var s = String(v); while (s.length < n) { s = '0' + s; } return s; }

// Las cinco poblaciones, con su recuento exacto. Estas cinco líneas SON el
// contrato del volcado: cualquier medición del track se deriva de aquí.
var SHAPES = [
  { id: 'A', n: 2379 },   // la actual
  { id: 'B', n:  747 },   // 2019, sin "active"
  { id: 'C', n:  718 },   // importación de 2020: "name", sin correo
  { id: 'D', n:  912 },   // 2021: correo en "contact", birthDate como Date
  { id: 'E', n:   64 }    // el intento previo, con "phone" arriba
];

// De los que SÍ tienen la clave "email" (formas A, B y E = 3190), estos son
// los dos tipos de vacío. El resto lleva un correo de verdad.
var EMAIL_NULL = 906;     // el campo existe y vale null
var EMAIL_EMPTY = 247;    // el campo existe y vale ""

var FIRST_NAMES = ['Marcela', 'Julian', 'Deisy', 'Andres', 'Paola', 'Ricardo', 'Luz', 'Camilo'];
var LAST_NAMES = ['Rios', 'Prada', 'Cardenas', 'Beltran', 'Osorio', 'Quintero', 'Salazar'];

function randomFullName() { return pick(FIRST_NAMES) + ' ' + pick(LAST_NAMES); }

function randomBirthDate() {
  return (1950 + Math.floor(random() * 55)) + '-' +
         pad(1 + Math.floor(random() * 12), 2) + '-' +
         pad(1 + Math.floor(random() * 28), 2);
}

function buildPatients() {
  var patients = [];
  var legacyId = 1;

  // Se decide de antemano a QUIÉN le toca cada tipo de vacío, en vez de
  // sortearlo documento a documento. Sorteando, el recuento final saldría
  // "aproximadamente 906" y la medición de be02 dejaría de ser exacta.
  var withEmail = SHAPES[0].n + SHAPES[1].n + SHAPES[4].n;   // A + B + E = 3190
  var emptyKinds = {};
  for (var k = 0; k < EMAIL_NULL; k++)  { emptyKinds[k] = null; }
  for (var k2 = EMAIL_NULL; k2 < EMAIL_NULL + EMAIL_EMPTY; k2++) { emptyKinds[k2] = ''; }
  var emailIndex = 0;

  SHAPES.forEach(function (shape) {
    for (var i = 0; i < shape.n; i++) {
      var base = {
        legacyId: legacyId++,
        documentId: 'HC-10' + pad(Math.floor(random() * 99999999), 8)
      };

      // --- Forma C: la importación de 2020 -------------------------------
      // "name" en vez de "fullName" porque el sistema de origen lo llamaba
      // así y nadie tradujo el campo. Y SIN correo: el sistema de origen no
      // lo capturaba. Son los dos hallazgos que be02 encuentra primero.
      if (shape.id === 'C') {
        base.name = randomFullName();
        base.birthDate = randomBirthDate();
        base._source = 'legacy-import';
        patients.push(base);
        continue;
      }

      base.fullName = randomFullName();

      // --- Forma D: el cambio de 2021 ------------------------------------
      // Dos cosas a la vez y solo una declarada: el correo baja a un
      // subdocumento, y birthDate pasa a guardarse como BSON Date. La
      // notación {"$date": ...} es JSON extendido y mongoimport la entiende.
      if (shape.id === 'D') {
        base.birthDate = { '$date': randomBirthDate() + 'T00:00:00Z' };
        base.contact = { email: 'paciente' + base.legacyId + '@example.com', phone: null };
        base.active = true;
        patients.push(base);
        continue;
      }

      base.birthDate = randomBirthDate();

      // --- Formas A, B y E: las que tienen "email" al nivel superior -----
      var emptyKind = emptyKinds[emailIndex++];
      if (emptyKind === null) {
        base.email = null;
      } else if (emptyKind === '') {
        base.email = '';
      } else {
        base.email = 'paciente' + base.legacyId + '@example.com';
      }

      if (shape.id === 'E') { base.phone = '30' + pad(Math.floor(random() * 99999999), 8); }
      if (shape.id !== 'B') { base.active = true; }   // la B es anterior a la baja lógica

      patients.push(base);
    }
  });

  return patients;
}
