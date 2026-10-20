const fs = require('fs');
const path = require('path');

// Cuántas inspecciones se generan. Doscientas es donde el panel se ve bien;
// `DEMO_INSPECTIONS=2000 npm run seed:demo` es donde empieza a doler, y esa
// diferencia es el incidente 16.
const INSPECTION_COUNT = Number(process.env['DEMO_INSPECTIONS'] ?? 200);

// La zona del negocio, la misma de `business-day.ts`. Aquí es un literal y no
// un import porque esto es Node y aquello es la aplicación: son dos procesos
// distintos y no comparten módulos. Es la única duplicación aceptable de este
// valor en todo el proyecto, y va comentada para que nadie la "arregle"
// borrando la de la aplicación.
const OFFSET = '-05:00';

/**
 * Generador pseudoaleatorio con semilla fija. Es deliberado: dos ejecuciones
 * del mismo día producen exactamente los mismos datos, así que "en mi máquina
 * tarda 40 ms y en la tuya 300" es una diferencia de máquina y no de datos.
 * Un Math.random() haría irreproducible cualquier medición de esta fase.
 */
let state = 42;
const nextRandom = () => {
  state = (state * 1103515245 + 12345) % 2147483648;
  return state / 2147483648;
};

const pick = (values) => values[Math.floor(nextRandom() * values.length)];

/** Un día de calendario desplazado desde hoy. Negativo = pasado. */
const dayFromToday = (delta) => {
  const today = new Date();
  const shifted = new Date(
    Date.UTC(today.getUTCFullYear(), today.getUTCMonth(), today.getUTCDate() + delta),
  );

  return shifted.toISOString().slice(0, 10);
};

/** El mismo día de calendario, un año antes: la vigencia de doce meses de la Fase 10. */
const dayYearBefore = (day) => {
  const [year, month, dayOfMonth] = day.split('-').map(Number);

  return new Date(Date.UTC(year - 1, month - 1, dayOfMonth)).toISOString().slice(0, 10);
};

const seed = JSON.parse(fs.readFileSync(path.join(__dirname, 'db.seed.json'), 'utf8'));

// Los activos generados usan tipos que SÍ tienen plantilla y tipos que NO.
// Los segundos producen activos que nunca se certificaron, que es uno de los
// tres casos de la lista de cobertura y el más fácil de olvidar al sembrar.
const demoAssets = Array.from({ length: 40 }, (_, index) => ({
  id: `DEMO-${String(index + 1).padStart(3, '0')}`,
  clientId: pick([1, 2, 3]),
  type: pick(['elevator', 'elevator', 'boiler', 'tank', 'fire_system']),
  description: `Activo de demostración ${index + 1}`,
  installedAt: dayFromToday(-pick([400, 900, 1800, 3000])),
}));

const demoInspections = [];
const demoCertificates = [];

for (let index = 0; index < INSPECTION_COUNT; index += 1) {
  // Los ids arrancan en 600 para no chocar con las inspecciones canónicas
  // 500-504, que se quedan exactamente como estaban.
  const id = 600 + index;
  // Sólo ascensores y calderas tienen plantilla en la semilla: tanques y
  // sistemas contra incendio quedan sin inspeccionar a propósito.
  const asset = pick(
    demoAssets.filter((candidate) => candidate.type === 'elevator' || candidate.type === 'boiler'),
  );
  const templateId = asset.type === 'boiler' ? 'boiler-annual' : 'elevator-annual';
  const status = pick(['approved', 'approved', 'approved', 'rejected', 'completed', 'in_progress']);
  // Sólo las aprobadas tienen certificado, y sus vigencias se reparten a
  // propósito entre las cuatro ventanas del panel: vencidas, dentro de 30,
  // dentro de 60-90, y más allá. Relativas a HOY, así que el panel enseña algo
  // el día que corras esto y también dentro de dos años.
  const validUntilDay =
    status === 'approved' ? dayFromToday(pick([-200, -40, 12, 25, 45, 75, 200, 320])) : null;
  // La fecha de una aprobada sale de su vencimiento y no al revés: el
  // certificado vale doce meses (Fase 10), así que se emitió un año antes. Al
  // revés saldrían certificados que vencen antes de emitirse.
  const startedDay =
    validUntilDay === null ? dayFromToday(-Math.floor(nextRandom() * 500)) : dayYearBefore(validUntilDay);
  // La versión que regía ESE día, con las dos puntas: buscar sólo por
  // `validFrom` devuelve la v1 para siempre, porque es la primera fila que
  // empezó antes. Es el incidente 08 de la Fase 7 escrito en el generador.
  const template = seed.templates.find(
    (candidate) =>
      candidate.templateId === templateId &&
      candidate.validFrom <= startedDay &&
      (candidate.validUntil === null || startedDay <= candidate.validUntil),
  );

  demoInspections.push({
    id,
    assetId: asset.id,
    inspectorId: pick(['INS-15', 'INS-22', 'INS-31', 'INS-44']),
    templateId,
    templateVersion: template.version,
    status,
    startedAt: `${startedDay}T09:00:00${OFFSET}`,
    completedAt: status === 'in_progress' ? null : `${startedDay}T12:00:00${OFFSET}`,
    // Las respuestas se reparten entre los criterios del ítem, así que los
    // hallazgos DERIVADOS salen solos y con severidades variadas. No se
    // generan filas en `findings`: la Fase 9 decidió que la severidad se
    // deriva, y sembrar hallazgos aquí sería volver a tener dos verdades.
    answers: template.items.map((item) => ({
      itemId: item.id,
      // Una aprobada no puede tener un crítico abierto —la Fase 9 niega la
      // aprobación—, así que en ellas el peor criterio de un ítem crítico no sale.
      answer: pick(
        status === 'approved' && item.nonComplianceSeverity === 'critical'
          ? item.criteria.slice(0, -1)
          : item.criteria,
      ),
      evidenceUrl: item.photoRequired ? `assets/evidence/${id}-${item.id}.jpg` : null,
      note: null,
    })),
  });

  if (validUntilDay !== null) {
    demoCertificates.push({
      id: `CERT-${startedDay.slice(0, 4)}-${String(id).padStart(6, '0')}`,
      inspectionId: id,
      issuedAt: `${startedDay}T15:00:00${OFFSET}`,
      validUntil: `${validUntilDay}T23:59:59${OFFSET}`,
      // El campo almacenado que la Fase 10 dejó de leer. Se escribe 'issued'
      // en todos a propósito: si el panel alguna vez volviera a leerlo, se
      // vería tan mal que no habría duda.
      status: 'issued',
      revokedAt: null,
    });
  }
}

const demo = {
  ...seed,
  assets: [...seed.assets, ...demoAssets],
  inspections: [...seed.inspections, ...demoInspections],
  certificates: [...seed.certificates, ...demoCertificates],
};

fs.writeFileSync(path.join(__dirname, 'db.json'), `${JSON.stringify(demo, null, 2)}\n`);

console.log(
  `db.json generado con ${demo.inspections.length} inspecciones y ${demo.certificates.length} certificados.`,
);
