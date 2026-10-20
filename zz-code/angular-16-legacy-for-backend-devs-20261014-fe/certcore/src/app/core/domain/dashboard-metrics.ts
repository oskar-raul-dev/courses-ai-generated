import { Asset } from '../models/asset.model';
import { Certificate } from '../models/certificate.model';
import { ChecklistTemplate } from '../models/checklist-template.model';
import { Inspection } from '../models/inspection.model';
import { Instant } from '../time/business-day';
import {
  EXPIRING_WINDOW_DAYS,
  daysUntilExpiry,
  deriveCertificateStatus,
} from './certificate-status';
import { InspectionFinding } from './inspection-findings';

/**
 * Las ventanas del panel. Ojo con lo que NO es: sólo `in30` coincide con un
 * estado del dominio —el `expiring` que la Fase 10 definió con
 * EXPIRING_WINDOW_DAYS—. Las de 60 y 90 son ventanas de REPORTE: un
 * certificado a 75 días está `valid` y el panel lo agrupa aparte porque a
 * alguien le sirve verlo, no porque el sistema lo considere distinto.
 *
 * Confundir las dos cosas produce tres constantes de umbral en tres archivos y
 * un día en que sólo se cambia una. Por eso aquí hay UNA constante importada y
 * dos multiplicadores locales, y no tres números sueltos.
 */
export type ExpiryWindow = 'revoked' | 'expired' | 'in30' | 'in60' | 'in90' | 'later';

export type ExpiryBuckets = Readonly<Record<ExpiryWindow, readonly Certificate[]>>;

export function bucketCertificates(
  certificates: readonly Certificate[],
  now: Instant,
): ExpiryBuckets {
  const buckets: Record<ExpiryWindow, Certificate[]> = {
    revoked: [],
    expired: [],
    in30: [],
    in60: [],
    in90: [],
    later: [],
  };

  for (const certificate of certificates) {
    // El estado se calcula, nunca se lee del campo. Fase 10.
    const status = deriveCertificateStatus(certificate, now);

    if (status === 'revoked' || status === 'expired') {
      buckets[status].push(certificate);
      continue;
    }

    const days = daysUntilExpiry(certificate, now);

    // Los límites son INCLUSIVE por arriba: un certificado a treinta días
    // clavados está en la ventana de treinta, no en la de sesenta. Es la misma
    // decisión que tomó `appliesOn` de la Fase 7 con las fechas de plantilla, y
    // se toma igual por la misma razón: quien lee "vence en 30 días" espera
    // verlo ahí, no en el cajón siguiente.
    if (days <= EXPIRING_WINDOW_DAYS) {
      buckets.in30.push(certificate);
    } else if (days <= EXPIRING_WINDOW_DAYS * 2) {
      buckets.in60.push(certificate);
    } else if (days <= EXPIRING_WINDOW_DAYS * 3) {
      buckets.in90.push(certificate);
    } else {
      buckets.later.push(certificate);
    }
  }

  return buckets;
}

/**
 * Tasa de rechazo por inspector.
 *
 * `rate` es `number | null` y el `null` no es pereza: significa "este inspector
 * no tiene ninguna inspección decidida todavía", que es distinto de "su tasa es
 * cero". Es la misma distinción de la Fase 9, y aquí tiene consecuencias
 * visibles: un inspector nuevo con cero decisiones NO puede aparecer con un
 * 0 % impecable en el panel que su jefe mira.
 */
export interface InspectorRate {
  readonly inspectorId: string;
  /** Aprobadas + rechazadas. Las que siguen en curso no cuentan. */
  readonly decided: number;
  readonly rejected: number;
  /** Entre 0 y 1, o `null` si `decided` es 0. */
  readonly rate: number | null;
}

export function rejectionByInspector(
  inspections: readonly Inspection[],
): readonly InspectorRate[] {
  const counters = new Map<string, { decided: number; rejected: number }>();

  for (const inspection of inspections) {
    if (inspection.status !== 'approved' && inspection.status !== 'rejected') {
      continue;
    }

    const current = counters.get(inspection.inspectorId) ?? { decided: 0, rejected: 0 };

    counters.set(inspection.inspectorId, {
      decided: current.decided + 1,
      rejected: current.rejected + (inspection.status === 'rejected' ? 1 : 0),
    });
  }

  return [...counters.entries()]
    .map(([inspectorId, { decided, rejected }]) => ({
      inspectorId,
      decided,
      rejected,
      rate: decided === 0 ? null : rejected / decided,
    }))
    // Se ordena por tasa descendente, pero con el denominador a la vista: un
    // 100 % sobre una sola inspección arriba del todo es el error de panel más
    // común que existe, y la pantalla lo desactiva mostrando `decided`.
    .sort((a, b) => (b.rate ?? -1) - (a.rate ?? -1));
}

/** Los ítems del checklist que más hallazgos generan. */
export interface FindingCount {
  readonly itemId: string;
  readonly title: string;
  readonly total: number;
  readonly critical: number;
}

export function topFindingItems(
  findings: readonly InspectionFinding[],
  templates: readonly ChecklistTemplate[],
  limit: number,
): readonly FindingCount[] {
  // Los títulos salen de cualquier versión que tenga ese ítem: para contar,
  // "cable principal" es el mismo ítem en la v1 y en la v2 aunque el título
  // cambiara. Es la única lectura del panel que cruza versiones a propósito, y
  // por eso lleva este comentario: no contradice el invariante de la Fase 7,
  // porque no está renderizando una inspección, está agrupando un conteo.
  const titleByItemId = new Map<string, string>();

  for (const template of templates) {
    for (const item of template.items) {
      titleByItemId.set(item.id, item.title);
    }
  }

  const counters = new Map<string, { total: number; critical: number }>();

  for (const finding of findings) {
    const current = counters.get(finding.itemId) ?? { total: 0, critical: 0 };

    counters.set(finding.itemId, {
      total: current.total + 1,
      // La unión discriminada de la Fase 9 vuelve a pagar: los hallazgos sin
      // severidad —ítem retirado, criterio desconocido— cuentan en `total` y
      // no en `critical`, sin un solo `?? 'minor'` de por medio.
      critical: current.critical + (finding.kind === 'item' && finding.severity === 'critical' ? 1 : 0),
    });
  }

  return [...counters.entries()]
    .map(([itemId, { total, critical }]) => ({
      itemId,
      title: titleByItemId.get(itemId) ?? itemId,
      total,
      critical,
    }))
    .sort((a, b) => b.critical - a.critical || b.total - a.total)
    .slice(0, limit);
}

/**
 * Activos sin cobertura vigente. Tres casos y no un booleano, porque "nunca se
 * certificó" y "se le venció en marzo" son dos conversaciones distintas con el
 * cliente, y la lista tiene que poder tenerlas las dos.
 */
export type AssetCoverage =
  | { readonly kind: 'never-certified'; readonly asset: Asset }
  | {
      readonly kind: 'expired';
      readonly asset: Asset;
      readonly certificate: Certificate;
      readonly daysOverdue: number;
    }
  | { readonly kind: 'revoked'; readonly asset: Asset; readonly certificate: Certificate };

export function assetsWithoutCoverage(
  assets: readonly Asset[],
  inspections: readonly Inspection[],
  certificates: readonly Certificate[],
  now: Instant,
): readonly AssetCoverage[] {
  // Un certificado apunta a una inspección, no a un activo: el puente lo pone
  // la inspección. Es la única forma de saber de qué activo es un certificado,
  // y por eso este parámetro está aquí aunque el resultado no lo mencione.
  const assetIdByInspectionId = new Map(
    inspections.map((inspection) => [inspection.id, inspection.assetId]),
  );

  const latestByAssetId = new Map<string, Certificate>();

  for (const certificate of certificates) {
    const assetId = assetIdByInspectionId.get(certificate.inspectionId);

    if (assetId === undefined) {
      // Un certificado cuya inspección no existe es un dato roto, no un activo
      // sin cobertura. Se ignora aquí y se cuenta aparte en el ejercicio 22.
      continue;
    }

    const current = latestByAssetId.get(assetId);

    if (current === undefined || current.validUntil < certificate.validUntil) {
      // Comparación de cadenas ISO: con offset fijo y el mismo formato, el
      // orden lexicográfico coincide con el cronológico. Con offsets mezclados
      // no coincidiría, y ése es el ejercicio 24.
      latestByAssetId.set(assetId, certificate);
    }
  }

  const result: AssetCoverage[] = [];

  for (const asset of assets) {
    const latest = latestByAssetId.get(asset.id);

    if (latest === undefined) {
      result.push({ kind: 'never-certified', asset });
      continue;
    }

    const status = deriveCertificateStatus(latest, now);

    if (status === 'revoked') {
      result.push({ kind: 'revoked', asset, certificate: latest });
    } else if (status === 'expired') {
      result.push({
        kind: 'expired',
        asset,
        certificate: latest,
        // Negativo al revés: `daysUntilExpiry` de un vencido es negativo, y lo
        // que la pantalla quiere decir es "lleva 40 días vencido".
        daysOverdue: -daysUntilExpiry(latest, now),
      });
    }
  }

  return result;
}

/** Todo lo que el panel necesita, en un solo objeto y sin un Observable dentro. */
export interface DashboardMetrics {
  readonly generatedAt: Instant;
  readonly buckets: ExpiryBuckets;
  readonly inspectorRates: readonly InspectorRate[];
  readonly topFindings: readonly FindingCount[];
  readonly coverage: readonly AssetCoverage[];
  readonly openCriticalCount: number;
  readonly inProgressCount: number;
}
