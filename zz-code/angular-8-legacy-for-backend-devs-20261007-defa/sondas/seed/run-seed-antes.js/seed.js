// seed.js
// Genera un db.json grande a partir del modelo fijado en la Fase 4.
// Se corre a mano cuando hace falta un semillero nuevo, no en cada arranque:
// si lo corres, pierdes lo que hayas creado desde la interfaz.
const fs = require('fs');
const path = require('path');

var FIRST_NAMES = ['Marcela', 'Julian', 'Deisy', 'Andres', 'Paola', 'Ricardo', 'Luz', 'Camilo'];
var LAST_NAMES = ['Rios', 'Prada', 'Cardenas', 'Beltran', 'Osorio', 'Quintero', 'Salazar'];
var TEST_CODES = ['CBC', 'GLU', 'TSH', 'LIP', 'CREA'];
// Los estados del flujo canónico de una orden, tal como los fija el ALCANCE.
// Editado retroactivamente desde la Fase 8 (normalización del flujo) y desde
// la Fase 9 (alta de "delivered"). La versión original sembraba valores sueltos
// (created/processing/reported) que no cruzaban con la máquina de estados de la
// muestra ni con el empuje muestra->orden de la Fase 8. Se normaliza al flujo
// único, con el precedente de la Fase 3.
// "delivered" figura en el arreglo para que el estado EXISTA en la máquina y en
// el MatSelect que la Fase 6 construye, pero NO se siembra ninguna orden ya
// entregada: a "delivered" se
// llega solo entregando el informe en la Fase 9, igual que a "discarded" en
// muestras se llegaba solo descartando en la Fase 7. Sembrar una orden
// delivered haría aparecer el estado final sin la historia que lo produjo, y
// escondería el cruce results->orders que la Fase 9 construye.
var ORDER_STATUSES = ['pending', 'in_process', 'partial_results', 'complete', 'delivered', 'expired'];

// Estados que una orden PUEDE tener recién sembrada. "delivered" y "expired"
// quedan fuera: son terminales a los que se llega por una acción (entregar) o
// por el paso del tiempo (vencer), no por generación. Sembrarlos sin historia
// mentiría sobre como llegaron ahí.
var SEEDABLE_ORDER_STATUSES = ['pending', 'in_process', 'partial_results', 'complete'];

// Generador pseudoaleatorio con semilla fija. Sin esto, cada corrida produce
// datos distintos y un bug reproducible deja de serlo. La semilla es parte
// del contrato del semillero, no un detalle.
var seed = 20190902;
function random() {
  seed = (seed * 9301 + 49297) % 233280;
  return seed / 233280;
}

function pick(list) {
  return list[Math.floor(random() * list.length)];
}

function pad(value, size) {
  var text = String(value);
  while (text.length < size) { text = '0' + text; }
  return text;
}

function buildPatients(count) {
  var patients = [];
  for (var i = 1; i <= count; i++) {
    patients.push({
      id: i,
      documentId: 'HC-10' + pad(Math.floor(random() * 99999999), 8),
      fullName: pick(FIRST_NAMES) + ' ' + pick(LAST_NAMES),
      // Fecha de nacimiento como string ISO corto, igual que la Fase 4.
      // Que llegue como string y no como Date es la causa del ejercicio 18.
      birthDate: (1950 + Math.floor(random() * 55)) + '-' +
                 pad(1 + Math.floor(random() * 12), 2) + '-' +
                 pad(1 + Math.floor(random() * 28), 2),
      // Uno de cada seis sin correo: caso borde heredado de la Fase 4.
      email: random() > 0.17 ? 'paciente' + i + '@example.com' : null,
      // Campo nuevo de esta fase. Ver 5.2.
      active: true
    });
  }
  return patients;
}

function buildOrders(patients, count) {
  var orders = [];
  for (var i = 0; i < count; i++) {
    var patient = pick(patients);
    var createdAt = '2019-' + pad(1 + Math.floor(random() * 9), 2) + '-' +
                    pad(1 + Math.floor(random() * 28), 2) + 'T08:15:00-05:00';
    orders.push({
      id: 101 + i,
      patientId: patient.id,
      // Sorteo acotado: nunca nace una orden ya "delivered" ni "expired".
      // Ver SEEDABLE_ORDER_STATUSES arriba.
      status: pick(SEEDABLE_ORDER_STATUSES),
      createdAt: createdAt,
      dueAt: createdAt,          // Simplificación deliberada; la Fase 8 la corrige.
      testCodes: [pick(TEST_CODES)],
      active: true
    });
  }
  return orders;
}

var patients = buildPatients(25);
var orders = buildOrders(patients, 40);

// Las colecciones que esta fase no toca se conservan tal como las dejó la
// Fase 4: se leen del archivo actual y se vuelven a escribir sin cambios.
var current = JSON.parse(fs.readFileSync(path.join(__dirname, 'db.json'), 'utf8'));

var next = {
  patients: patients,
  orders: orders,
  samples: current.samples,
  results: current.results,
  referenceRanges: current.referenceRanges
};

fs.writeFileSync(path.join(__dirname, 'db.json'), JSON.stringify(next, null, 2));
console.log('[seed] ' + patients.length + ' pacientes, ' + orders.length + ' ordenes');
