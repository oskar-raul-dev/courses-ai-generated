export type AssetType = 'elevator' | 'boiler' | 'tank' | 'fire_system';

export interface Asset {
  /** Identificador operativo, el que está pintado en el equipo: "ASC-CENTRAL-03". */
  readonly id: string;
  readonly clientId: number;
  readonly type: AssetType;
  readonly description: string;
  /** Fecha de instalación, sin hora: es un día de calendario, no un instante. */
  readonly installedAt: string;
}
