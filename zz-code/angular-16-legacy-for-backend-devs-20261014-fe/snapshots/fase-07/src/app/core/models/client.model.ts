export interface Client {
  readonly id: number;
  readonly legalName: string;
  /** NIT o identificación tributaria. Siempre presente: es la clave del negocio. */
  readonly taxId: string;
}
