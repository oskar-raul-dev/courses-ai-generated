// T3: lo que la prueba de regresión del cuaderno no cubre y el plan pide (§5, T3).
// Corre sobre el árbol fix21 (fase-10 + la solución del 21 aplicada desde el cuaderno).
import { buildCertificateView, deriveCertificateStatus } from '../src/app/core/domain/certificate-status';
import { computeValidity } from '../src/app/core/domain/certificate-validity';
import { Certificate } from '../src/app/core/models/certificate.model';
import { endOfBusinessDay, toBusinessDay, toLocalDay } from '../src/app/core/time/business-day';
import { fix, roto } from './db-21.check';

const CONTINENTE = ['America/Bogota', 'America/Lima', 'America/Guayaquil'];

/** Lo mismo que hace `timeZones$` del fix: certificado → inspección → activo. */
function zonas(db: typeof fix | typeof roto): ReadonlyMap<number, string> {
  const porActivo = new Map<string, string>();
  for (const asset of db.assets) {
    if ('timeZone' in asset && typeof asset.timeZone === 'string') {
      porActivo.set(asset.id, asset.timeZone);
    }
  }
  const porInspeccion = new Map<number, string>();
  for (const inspection of db.inspections) {
    const zona = porActivo.get(inspection.assetId);
    if (zona !== undefined) {
      porInspeccion.set(inspection.id, zona);
    }
  }
  return porInspeccion;
}

function estados(db: typeof fix | typeof roto, now: string): Record<string, string> {
  const z = zonas(db);
  const certificados: readonly Certificate[] = db.certificates;
  return Object.fromEntries(
    certificados.map((c) => [c.id, deriveCertificateStatus(c, now, z.get(c.inspectionId))]),
  );
}

describe('T3 · la pantalla con los datos de la preparación', () => {
  const lasOnceYCuarto = '2026-03-12T23:15:00-06:00';
  const lasOnceMenosCuarto = '2026-03-12T22:45:00-06:00';

  it('con el dato roto (sin timeZone), el Inn sale vencido a las 23:15 y por vencer a las 22:45', () => {
    expect(estados(roto, lasOnceYCuarto)['CERT-2025-000505']).toBe('expired');
    expect(estados(roto, lasOnceMenosCuarto)['CERT-2025-000505']).toBe('expiring');
  });

  it('con el dato del fix, el Inn sale por vencer a las dos horas', () => {
    expect(estados(fix, lasOnceYCuarto)['CERT-2025-000505']).toBe('expiring');
    expect(estados(fix, lasOnceMenosCuarto)['CERT-2025-000505']).toBe('expiring');
  });

  it('los certificados de la semilla no cambian entre las dos horas ni con el fix', () => {
    const semilla = (db: typeof fix | typeof roto, now: string) => {
      const { ['CERT-2025-000505']: _inn, ...resto } = estados(db, now);
      return resto;
    };
    expect(semilla(fix, lasOnceYCuarto)).toEqual(semilla(roto, lasOnceYCuarto));
    expect(semilla(fix, lasOnceYCuarto)).toEqual(semilla(fix, lasOnceMenosCuarto));
  });
});

describe('T3 · el continente no se mueve', () => {
  const instantes = [
    '2025-02-10T00:00:00-05:00', '2025-02-10T23:00:00-05:00', '2025-02-10T23:59:59-05:00',
    '2025-02-11T04:59:59Z', '2025-02-11T05:00:00Z', '2024-03-15T23:30:00-05:00',
    '2024-01-31T23:00:00-05:00', '2024-02-01T04:30:00Z', '2024-12-31T23:59:59-05:00',
  ];

  for (const zona of CONTINENTE) {
    it(`con zona explícita ${zona}, el día y la vigencia son los del offset fijo`, () => {
      for (const instante of instantes) {
        expect(toLocalDay(instante, zona)).toBe(toBusinessDay(instante));
        expect(computeValidity(instante, zona)).toEqual(computeValidity(instante));
      }
    });
  }
});

describe('T3 · los vecinos', () => {
  it('el PDF necesita la zona: un 23:59:59-06:00 leído con el día de Bogotá cae el 13', () => {
    expect(toLocalDay('2026-03-12T23:59:59-06:00', 'Pacific/Galapagos')).toBe('2026-03-12');
    expect(toBusinessDay('2026-03-12T23:59:59-06:00')).toBe('2026-03-13');
  });

  it('be-08 (lado pantalla): un vencimiento a las 00:30 se lee el mismo día en la vista y en el PDF', () => {
    const certificado: Certificate = {
      id: 'CERT-2024-000087', inspectionId: 87, issuedAt: '2024-02-10T10:00:00-05:00',
      validUntil: '2025-02-10T00:30:00-05:00', status: 'valid', revokedAt: null,
    };
    const vista = buildCertificateView(certificado, '2025-02-09T12:00:00-05:00');
    // La vista dice el día con renewalDueOn; el PDF, con formatInstant → toLocalDay sin zona.
    expect(vista.renewalDueOn).toBe(toLocalDay(certificado.validUntil));
    expect(vista.renewalDueOn).toBe('2025-02-10');
  });

  it('endOfBusinessDay sigue siendo la de siempre', () => {
    expect(endOfBusinessDay('2026-03-12')).toBe('2026-03-12T23:59:59-05:00');
  });
});
