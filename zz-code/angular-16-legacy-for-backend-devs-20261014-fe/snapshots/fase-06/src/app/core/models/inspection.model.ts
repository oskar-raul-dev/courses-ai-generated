export type InspectionStatus =
  | 'requested'
  | 'scheduled'
  | 'in_progress'
  | 'completed'
  | 'approved'
  | 'rejected';

export interface InspectionAnswer {
  readonly itemId: string;
  /** Uno de los `criteria` del ítem. Se valida contra la plantilla, no aquí. */
  readonly answer: string;
  /** `null` cuando el ítem no exigía foto o el inspector no la subió todavía. */
  readonly evidenceUrl: string | null;
  readonly note: string | null;
}

export interface Inspection {
  readonly id: number;
  readonly assetId: string;
  readonly inspectorId: string;
  readonly templateId: string;
  /**
   * La versión con la que se EJECUTÓ. Es el campo más importante del sistema:
   * una inspección se lee siempre con ésta, nunca con la vigente. Fase 7 ⭐.
   */
  readonly templateVersion: number;
  readonly status: InspectionStatus;
  readonly startedAt: string;
  /** `null` mientras no se haya cerrado. */
  readonly completedAt: string | null;
  readonly answers: readonly InspectionAnswer[];
}
