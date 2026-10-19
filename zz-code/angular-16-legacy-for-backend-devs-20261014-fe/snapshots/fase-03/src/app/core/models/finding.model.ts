export type FindingSeverity = 'critical' | 'major' | 'minor';

export interface Finding {
  readonly id: number;
  readonly inspectionId: number;
  readonly itemId: string;
  readonly severity: FindingSeverity;
  readonly description: string;
  /** `null` = sin resolver. Un `critical` sin resolver bloquea el certificado. */
  readonly resolvedAt: string | null;
}
