
/**
 * Solicitud de inspección: lo que un cliente pide antes de que exista la
 * inspección propiamente dicha. Es la antesala del estado `requested` de la
 * máquina de estados (Fase 6 en adelante).
 */
export interface InspectionRequest {
  /** Identificador del activo, tal como lo usa el negocio: "ASC-CENTRAL-03". */
  readonly assetId: string;

  /**
   * Fecha deseada, ISO 8601 CON offset explícito (-05:00), nunca con Z ni
   * suelta. Media docena de tickets de CertCore nacieron de una fecha sin
   * offset; la regla se aplica desde el primer archivo.
   */
  readonly requestedFor: string;

  /**
   * `null` significa "el cliente no dejó nota". Es una ausencia real y
   * declarada, no un campo que nadie se molestó en decidir — por eso es
   * `string | null` y no `note?: string`.
   */
  readonly note: string | null;
}

/** Lo que devuelve el servidor: lo mismo, más el id que él asigna. */
export interface CreatedInspectionRequest extends InspectionRequest {
  readonly id: number;
}
