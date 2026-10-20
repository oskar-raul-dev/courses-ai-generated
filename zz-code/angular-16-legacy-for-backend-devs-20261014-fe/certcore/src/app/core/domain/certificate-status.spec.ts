// src/app/core/domain/certificate-status.spec.ts
import { Certificate } from '../models/certificate.model';
import { daysUntilExpiry, deriveCertificateStatus } from './certificate-status';

function certificate(validUntil: string, revokedAt: string | null = null): Certificate {
  return {
    id: 'CERT-2024-000502',
    inspectionId: 502,
    issuedAt: '2024-02-10T10:00:00-05:00',
    validUntil,
    // El campo almacenado que la Fase 10 dejó de leer. Se pone MAL a propósito
    // en el fixture: si algún test pasara por leerlo, saltaría al instante.
    status: 'valid',
    revokedAt,
  };
}

describe('deriveCertificateStatus', () => {
  // ⭐ Ni un `jasmine.clock()`, ni un `Date` falseado, ni una variable global.
  // El instante es un PARÁMETRO —decisión de la Fase 10 §5.2— y por eso este
  // archivo entero es aritmética. Compáralo con 5.6, donde una función que
  // pide la hora por su cuenta obliga a montar un andamio.
  const now = '2026-09-06T10:00:00-05:00';

  it('devuelve `valid` cuando falta más del umbral', () => {
    expect(deriveCertificateStatus(certificate('2027-01-01T23:59:59-05:00'), now)).toBe('valid');
  });

  it('devuelve `expiring` en el día exacto del umbral', () => {
    // Treinta días clavados. El límite es inclusive, así que cae en `expiring`
    // y no en `valid`: es el borde que la Fase 10 §5.2 decidió a propósito y
    // el que un refactor rompe sin darse cuenta.
    expect(deriveCertificateStatus(certificate('2026-10-06T23:59:59-05:00'), now)).toBe('expiring');
  });

  it('devuelve `expired` un segundo después de vencer', () => {
    expect(deriveCertificateStatus(certificate('2026-09-06T09:59:59-05:00'), now)).toBe('expired');
  });

  it('devuelve `expiring`, y no `expired`, en el último segundo de vigencia', () => {
    // El mismo día, un segundo antes. Los dos tests de arriba y de abajo son
    // el mismo borde por sus dos lados, y escribir sólo uno de los dos es cómo
    // se cuela un `<` donde iba un `<=`. Y no es `valid`: le quedan cero días,
    // y cero cae dentro del umbral.
    expect(deriveCertificateStatus(certificate('2026-09-06T10:00:01-05:00'), now)).toBe('expiring');
  });

  it('`revoked` gana sobre `expired`', () => {
    // Un certificado revocado en marzo que además venció en agosto es
    // REVOCADO, porque lo que importa es por qué dejó de valer. El orden de
    // los `if` es la regla de negocio, y éste es el test que lo fija.
    const revokedAndExpired = certificate('2026-08-01T23:59:59-05:00', '2026-03-01T10:00:00-05:00');

    expect(deriveCertificateStatus(revokedAndExpired, now)).toBe('revoked');
  });

  it('cuenta días negativos para un certificado vencido', () => {
    // No se recorta a cero: "vencido hace 40 días" es información que la lista
    // de cobertura de la Fase 11 usa.
    expect(daysUntilExpiry(certificate('2026-07-28T23:59:59-05:00'), now)).toBe(-40);
  });
});
