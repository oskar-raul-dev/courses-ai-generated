/**
 * La forma del estado de cualquier feature de CertCore. Genérica en el tipo de
 * la entidad, y sin clase base a propósito: una AbstractStateService<T> ahorra
 * treinta líneas por servicio y mete herencia justo donde peor envejece. Cada
 * *StateService se escribe explícito. El ejercicio 30 te hace probar la otra
 * opción antes de creerte ésta.
 */
export interface FeatureState<T> {
  /**
   * 🪦 LA DEUDA DE LA FASE 4, PAGADA
   * `readonly items: readonly T[]` cierra la casa entera: los *ApiService ya
   * devolvían `readonly T[]` desde la Fase 3, y ahora el dato sigue siendo
   * inmutable de la puerta para adentro. El compilador rechaza push, splice y
   * sort, que son las tres formas de romper OnPush sin darse cuenta.
   *
   * `readonly` en la propiedad además de en el array: lo primero impide
   * reasignar `state.items = otra`, lo segundo impide mutar la que hay. Faltando
   * cualquiera de los dos, la puerta queda entornada.
   */
  readonly items: readonly T[];

  /** La entidad sobre la que está trabajando el usuario, o `null` si ninguna. */
  readonly selected: T | null;

  /** Hay una carga en vuelo. Un booleano, y en el ejercicio 23 verás su límite. */
  readonly loading: boolean;

  /**
   * El mensaje de error, ya traducido por `toApiError`, o `null` si no hay.
   * Vive en el estado y no se propaga como excepción: el dashboard de la Fase
   * 11 necesita pintarlo, y un error que sólo existe en un `catch` local no se
   * puede pintar en otra pantalla.
   */
  readonly error: string | null;
}

/**
 * Ojo con esto: es una FUNCIÓN, no una constante. Si fuera
 * `export const INITIAL_STATE = { items: [], ... }`, todas las features
 * compartirían el mismo objeto y el mismo array, y el primer push de cualquiera
 * aparecería en las demás. El ejercicio 1 te hace comprobarlo.
 */
export function createInitialState<T>(): FeatureState<T> {
  return { items: [], selected: null, loading: false, error: null };
}
