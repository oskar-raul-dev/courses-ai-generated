import { Certificate, CertificateStatus } from '../models/certificate.model';
import { BusinessDay, Instant, daysBetween, isPast, toBusinessDay } from '../time/business-day';
import { CertificateValidity, renewalDueOn } from './certificate-validity';

/**
 * Cuántos días antes del vencimiento un certificado pasa a `expiring`.
 *
 * 🧭 `expiring` es UN estado con UN umbral. El "por vencer a 30/60/90 días" del
 * dashboard son tres cubos de un informe, no tres estados.
 */
export const EXPIRING_WINDOW_DAYS = 30;

/**
 * Los estados que el cálculo PUEDE producir. `issued` se queda fuera: derivando
 * desde `validUntil` contra el reloj, "recién emitido" y "vigente" son el mismo
 * estado. `issued` es el valor que se ESCRIBE al emitir, porque es cierto en ese
 * instante y no vuelve a serlo nunca.
 */
export type DerivedCertificateStatus = Exclude<CertificateStatus, 'issued'>;

const STATUS_LABELS: Readonly<Record<DerivedCertificateStatus, string>> = {
  valid: 'Vigente',
  expiring: 'Por vencer',
  expired: 'Vencido',
  revoked: 'Revocado',
};

export function certificateStatusLabel(status: DerivedCertificateStatus): string {
  return STATUS_LABELS[status];
}

/**
 * Días de calendario hasta el vencimiento, contados en días de negocio.
 * Negativo si ya venció, y no se recorta a cero.
 */
export function daysUntilExpiry(certificate: Certificate, now: Instant): number {
  return daysBetween(toBusinessDay(now), toBusinessDay(certificate.validUntil));
}

/**
 * ⭐ La regla de negocio central de la fase, y son cuatro líneas.
 *
 * El orden de las comprobaciones ES la regla: revocado gana sobre vencido. Un
 * certificado revocado en marzo que habría vencido en agosto sigue siendo
 * REVOCADO, porque lo que importa legalmente es por qué dejó de valer.
 *
 * ⚠️ `now` entra por parámetro. Sin eso, esta función se prueba esperando.
 */
export function deriveCertificateStatus(
  certificate: Certificate,
  now: Instant,
): DerivedCertificateStatus {
  if (certificate.revokedAt !== null) {
    return 'revoked';
  }

  if (isPast(certificate.validUntil, now)) {
    return 'expired';
  }

  const remaining = daysUntilExpiry(certificate, now);

  return remaining <= EXPIRING_WINDOW_DAYS ? 'expiring' : 'valid';
}

/**
 * Todo lo que una pantalla necesita saber de un certificado, calculado de una
 * vez. Un objeto de vista que ya trae resueltas las preguntas.
 */
export interface CertificateView {
  readonly certificate: Certificate;
  readonly status: DerivedCertificateStatus;
  readonly validity: CertificateValidity;
  /** Negativo si ya venció. */
  readonly daysUntilExpiry: number;
  readonly renewalDueOn: BusinessDay;
  /**
   * Lo que la fila guardada sigue afirmando. NO se usa para decidir nada: viaja
   * para poder pintar la divergencia y diagnosticarla.
   */
  readonly storedStatus: CertificateStatus;
  readonly diverges: boolean;
}

export function buildCertificateView(certificate: Certificate, now: Instant): CertificateView {
  const status = deriveCertificateStatus(certificate, now);

  return {
    certificate,
    status,
    validity: { from: certificate.issuedAt, until: certificate.validUntil },
    daysUntilExpiry: daysUntilExpiry(certificate, now),
    renewalDueOn: renewalDueOn(certificate.validUntil),
    storedStatus: certificate.status,
    // `issued` guardado frente a `valid` derivado no es divergencia: es el
    // mismo estado con dos nombres.
    diverges: certificate.status !== status && !(certificate.status === 'issued' && status === 'valid'),
  };
}
