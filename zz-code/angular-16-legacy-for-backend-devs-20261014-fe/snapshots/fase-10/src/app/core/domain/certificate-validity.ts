import { BusinessDay, Instant, endOfBusinessDay, toBusinessDay } from '../time/business-day';

/**
 * Cuánto vale un certificado. Todas las plantillas de CertCore son anuales y los
 * dos certificados de la semilla duran exactamente doce meses.
 *
 * ⚠️ En un sistema real esto NO es una constante: depende de la norma y del tipo
 * de activo. Está aquí, con nombre y en un solo sitio.
 */
export const CERTIFICATE_VALIDITY_MONTHS = 12;

/** La ventana de vigencia. Los dos extremos son instantes, no días. */
export interface CertificateValidity {
  readonly from: Instant;
  readonly until: Instant;
}

/**
 * ⭐ La vigencia de un certificado emitido en este instante.
 *
 * Tres pasos y ninguno es obvio:
 *   1. El instante de emisión se lleva a día de negocio. Emitir a las 23:30 en
 *      Bogotá es emitir el día 10, no el 11, aunque en UTC ya sea 11.
 *   2. Se suman los meses en calendario, no 365 días.
 *   3. El resultado se convierte en el ÚLTIMO instante de ese día.
 */
export function computeValidity(issuedAt: Instant): CertificateValidity {
  const issuedDay = toBusinessDay(issuedAt);

  return {
    from: issuedAt,
    until: endOfBusinessDay(addMonths(issuedDay, CERTIFICATE_VALIDITY_MONTHS)),
  };
}

/** El día en que hay que tener listo el certificado nuevo: el mismo día en que vence el viejo. */
export function renewalDueOn(validUntil: Instant): BusinessDay {
  return toBusinessDay(validUntil);
}

/**
 * Suma meses de calendario a un día, recortando al último día del mes cuando
 * el día de origen no existe en el destino.
 *
 * El caso que obliga a escribirla: un certificado emitido el 29 de febrero de
 * 2024 vence el 28 de febrero de 2025, no el 1 de marzo.
 */
function addMonths(day: BusinessDay, months: number): BusinessDay {
  const [year, month, dayOfMonth] = day.split('-').map(Number);
  // Día 0 del mes SIGUIENTE al destino = último día del mes destino.
  const lastDayOfTarget = new Date(Date.UTC(year, month - 1 + months + 1, 0)).getUTCDate();
  const shifted = new Date(
    Date.UTC(year, month - 1 + months, Math.min(dayOfMonth, lastDayOfTarget)),
  );

  return shifted.toISOString().slice(0, 10);
}
