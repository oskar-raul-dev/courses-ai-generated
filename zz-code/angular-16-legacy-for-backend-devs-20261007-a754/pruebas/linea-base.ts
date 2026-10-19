// Línea base de tiempo (T2): lo que el código de F07 + F10, extraído del markdown,
// responde hoy. T3 la usa para probar que el fix del incidente 21 no mueve nada en
// el continente. Sin reloj: cada caso fija su `now`.
import {
  addDays,
  daysBetween,
  endOfBusinessDay,
  toBusinessDay,
} from '../salidas/src-extraido/src/app/core/time/business-day';
import { computeValidity, renewalDueOn } from '../salidas/src-extraido/src/app/core/domain/certificate-validity';
import { deriveCertificateStatus } from '../salidas/src-extraido/src/app/core/domain/certificate-status';
import { Certificate } from '../salidas/src-extraido/src/app/core/models/certificate.model';

// Sin @types/node: lo único que se usa de Node es esto.
declare const process: { readonly version: string; readonly versions: Readonly<Record<string, string>> };

const ZONAS = ['America/Bogota', 'America/Lima', 'America/Guayaquil'] as const;

function diaLocal(instant: string, timeZone: string): string {
  // en-CA formatea como YYYY-MM-DD.
  return new Intl.DateTimeFormat('en-CA', { timeZone, year: 'numeric', month: '2-digit', day: '2-digit' })
    .format(new Date(instant));
}

const INSTANTES = [
  '2025-02-10T00:00:00-05:00',
  '2025-02-10T23:00:00-05:00',
  '2025-02-10T23:59:59-05:00',
  '2025-02-11T04:59:59Z',
  '2025-02-11T05:00:00Z',
  '2024-03-15T23:30:00-05:00',
  '2024-01-31T23:00:00-05:00',
  '2024-02-01T04:30:00Z',
  '2024-02-29T09:00:00-05:00',
  '2024-12-31T23:59:59-05:00',
  '2025-01-01T04:59:59Z',
];

const toBusinessDayCasos = INSTANTES.map((instant) => ({
  instant,
  toBusinessDay: toBusinessDay(instant),
  intl: Object.fromEntries(ZONAS.map((z) => [z, diaLocal(instant, z)])),
}));

const emisiones = [
  '2024-02-10T10:00:00-05:00',
  '2023-08-21T10:00:00-05:00',
  '2024-02-29T09:00:00-05:00',
  '2024-03-15T23:30:00-05:00',
];
const validez = emisiones.map((issuedAt) => {
  const v = computeValidity(issuedAt);
  return { issuedAt, from: v.from, until: v.until, renewalDueOn: renewalDueOn(v.until) };
});

const certificado: Certificate = {
  id: 'CERT-LINEA-BASE',
  inspectionId: 1,
  issuedAt: '2024-02-10T10:00:00-05:00',
  validUntil: endOfBusinessDay('2025-02-10'),
  status: 'issued',
  revokedAt: null,
};
const relojes = [
  '2025-01-10T12:00:00-05:00',
  '2025-01-11T12:00:00-05:00',
  '2025-02-10T22:59:59-05:00',
  '2025-02-10T23:00:00-05:00',
  '2025-02-10T23:30:00-05:00',
  '2025-02-10T23:59:59-05:00',
  '2025-02-11T00:00:00-05:00',
  '2025-02-11T04:30:00Z',
  '2025-02-11T05:00:00Z',
];
const estados = relojes.map((now) => ({ now, status: deriveCertificateStatus(certificado, now) }));

const dias = {
  'addDays(2024-02-28, 1)': addDays('2024-02-28', 1),
  'addDays(2024-12-31, 1)': addDays('2024-12-31', 1),
  'addDays(2025-03-01, -1)': addDays('2025-03-01', -1),
  'daysBetween(2025-01-11, 2025-02-10)': daysBetween('2025-01-11', '2025-02-10'),
  'endOfBusinessDay(2025-02-10)': endOfBusinessDay('2025-02-10'),
};

console.log(
  JSON.stringify(
    { node: process.version, icu: process.versions['icu'], tz: process.versions['tz'], toBusinessDayCasos, validez, estados, dias },
    null,
    2,
  ),
);
