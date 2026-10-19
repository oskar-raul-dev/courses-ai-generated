/**
 * La forma del estado de cualquier feature de CertCore. Genérica en el tipo de
 * la entidad, y sin clase base a propósito: una AbstractStateService<T> ahorra
 * treinta líneas por servicio y mete herencia justo donde peor envejece. Cada
 * *StateService se escribe explícito. El ejercicio 30 te hace probar la otra
 * opción antes de creerte ésta.
 */
export interface FeatureState<T> {
  /**
   * 💸 DEUDA TÉCNICA INTENCIONAL
   * `T[]` y no `readonly T[]`. El array que este estado expone es el mismo que
   * guarda el servicio, y cualquier suscriptor puede hacerle push, splice o
   * sort. Cuando eso pasa, la referencia no cambia, nadie emite, y con OnPush
   * la vista no se entera: la lista se queda como estaba aunque el dato ya no.
   * Lo correcto es `readonly items: readonly T[]` hasta la salida y reemplazar
   * en vez de mutar. Fíjate en que el borde HTTP sí está protegido —los
   * *ApiService de la Fase 3 devuelven `readonly T[]`—; lo que queda abierto es
   * de la puerta para adentro.
   * SE PAGA EN LA FASE 6, con la pantalla que deja de repintar delante.
   */
  items: T[];

  /** La entidad sobre la que está trabajando el usuario, o `null` si ninguna. */
  selected: T | null;

  /** Hay una carga en vuelo. Un booleano, y en el ejercicio 23 verás su límite. */
  loading: boolean;

  /**
   * El mensaje de error, ya traducido por `toApiError`, o `null` si no hay.
   * Vive en el estado y no se propaga como excepción: el dashboard de la Fase
   * 11 necesita pintarlo, y un error que sólo existe en un `catch` local no se
   * puede pintar en otra pantalla.
   */
  error: string | null;
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
