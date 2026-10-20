import type { jsPDF } from 'jspdf';

import { CertificateView, certificateStatusLabel } from '../domain/certificate-status';
import { severityLabel } from '../domain/finding-severity';
import { InspectionFinding } from '../domain/inspection-findings';
import { Asset } from '../models/asset.model';
import { Certificate } from '../models/certificate.model';
import { ChecklistTemplate } from '../models/checklist-template.model';
import { Client } from '../models/client.model';
import { Inspection } from '../models/inspection.model';
import { toBusinessDay } from '../time/business-day';

/**
 * Todo lo que el documento necesita, junto y ya resuelto. Que sea una interfaz
 * explícita y no "lo que tenga el componente" es la mitad del arreglo.
 */
export interface CertificateDocumentSource {
  readonly certificate: Certificate;
  readonly view: CertificateView;
  readonly inspection: Inspection;
  readonly template: ChecklistTemplate;
  readonly asset: Asset;
  readonly client: Client;
  readonly findings: readonly InspectionFinding[];
}

/**
 * ⭐ Arma el documento. Función pura: recibe datos y un `jsPDF` ya construido, y
 * no sabe nada de Angular, de HTTP ni de pantallas.
 *
 * ⚠️ `source.template` tiene que ser la versión que la inspección GUARDÓ. Con la
 * plantilla vigente, el certificado no falla: IMPRIME otra cosa.
 */
export function buildCertificateDocument(
  document: jsPDF,
  source: CertificateDocumentSource,
  autoTable: AutoTableFn,
): jsPDF {
  const { certificate, view, inspection, asset, client, findings } = source;

  document.setFontSize(16);
  document.text('Certificado de inspección', 20, 20);

  document.setFontSize(11);
  document.text(`Número: ${certificate.id}`, 20, 32);
  document.text(`Cliente: ${client.legalName} (NIT ${client.taxId})`, 20, 39);
  document.text(`Activo: ${asset.id} — ${asset.description}`, 20, 46);
  document.text(`Inspección: ${inspection.id}`, 20, 53);
  // La versión de plantilla va IMPRESA en el documento: es lo que permite, dentro
  // de tres años, saber con qué norma se evaluó.
  document.text(`Plantilla: ${inspection.templateId} v${inspection.templateVersion}`, 20, 60);
  document.text(`Estado: ${certificateStatusLabel(view.status)}`, 20, 67);
  document.text(
    `Vigencia: del ${formatInstant(view.validity.from)} al ${formatInstant(view.validity.until)}`,
    20,
    74,
  );

  autoTable(document, {
    startY: 84,
    head: [['Ítem', 'Respuesta', 'Severidad', 'Resuelto']],
    body: findings.map((finding) => [
      finding.itemId,
      finding.answer,
      // `severity: null` significa "lo calculé y no hay", y en un documento
      // oficial eso se imprime, no se deja en blanco.
      finding.severity === null ? 'Sin determinar' : severityLabel(finding.severity),
      finding.resolvedAt === null ? 'No' : formatInstant(finding.resolvedAt),
    ]),
  });

  return document;
}

/**
 * La firma mínima de `autoTable` que este archivo usa. Se declara aquí para que
 * la función pura no dependa del tipo de la librería y siga siendo probable.
 */
export type AutoTableFn = (
  document: jsPDF,
  options: {
    readonly startY: number;
    readonly head: string[][];
    readonly body: string[][];
  },
) => void;

function formatInstant(instant: string): string {
  // El documento se imprime con el día de negocio, no el instante completo ni el UTC.
  return toBusinessDay(instant).split('-').reverse().join('/');
}
