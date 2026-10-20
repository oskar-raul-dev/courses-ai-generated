export type CertificateStatus = 'issued' | 'valid' | 'expiring' | 'expired' | 'revoked';

export interface Certificate {
  readonly id: string;
  readonly inspectionId: number;
  readonly issuedAt: string;
  /** Con hora y offset: "¿vence hoy?" depende de dónde esté parado quien pregunta. */
  readonly validUntil: string;
  /**
   * ⚠️ Viene almacenado y debería ser derivado de `validUntil` contra el reloj.
   * Se deja así porque así está el dato real; la Fase 10 lo convierte en
   * calculado y explica por qué un estado guardado empieza a mentir mañana.
   */
  readonly status: CertificateStatus;
  readonly revokedAt: string | null;
}
