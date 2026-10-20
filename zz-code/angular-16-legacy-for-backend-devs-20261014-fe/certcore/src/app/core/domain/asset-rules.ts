import { Asset, AssetType } from '../models/asset.model';

/**
 * Qué familia de plantilla le corresponde a cada tipo de activo. Venía de la
 * Fase 8, donde vivía dentro de `InspectionStartComponent`. Desde esta fase la
 * usan la pantalla de empezar y el servicio de plantillas.
 *
 * Record TOTAL sobre `AssetType`: añadir un tipo de activo rompe la
 * compilación aquí, que es exactamente donde tiene que romperse.
 */
const TEMPLATE_BY_ASSET_TYPE: Readonly<Record<AssetType, string>> = {
  elevator: 'elevator-annual',
  boiler: 'boiler-annual',
  tank: 'tank-annual',
  fire_system: 'fire-system-annual',
};

export function templateIdForAssetType(type: AssetType): string {
  return TEMPLATE_BY_ASSET_TYPE[type];
}

/**
 * 🪦 LA DEUDA DE LA FASE 6, PAGADA — primera mitad.
 *
 * "Un activo no puede cambiar de cliente" era, hasta hoy, un
 * `this.form.controls.clientId.disable()` dentro de `AssetFormComponent`.
 * Ahora es una función que cualquiera puede llamar.
 *
 * Devuelve un booleano y no lanza: decidir si esto es un error, un aviso o un
 * control deshabilitado es de quien llama. La regla sólo sabe de negocio.
 */
export function changesClient(current: Asset, next: Asset): boolean {
  return current.clientId !== next.clientId;
}
