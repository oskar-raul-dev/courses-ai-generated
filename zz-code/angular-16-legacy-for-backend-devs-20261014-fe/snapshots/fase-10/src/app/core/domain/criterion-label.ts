/**
 * 💸 DEUDA TÉCNICA INTENCIONAL
 * Los `criteria` de la plantilla son códigos del dominio en inglés
 * ('no_wear', 'light_wear'…) y esta tabla los traduce para la pantalla. Lo
 * correcto es que cada criterio traiga su etiqueta en el propio dato de la
 * plantilla —`{ code: 'no_wear', label: 'Sin desgaste' }`—, porque quien añade
 * un criterio en la Fase 7 es quien sabe cómo se llama.
 * NO SE PAGA, y el motivo es de costo: cambiar la forma de `criteria` obliga a
 * tocar `db.seed.json`, el editor de la Fase 7 y el modelo de la Fase 3, con
 * ocho fases construidas encima. El ejercicio 🔥 lo hace en una rama para que
 * midas cuánto cuesta de verdad.
 * El `?? code` del final es deliberado: un criterio nuevo se ve feo, pero se ve.
 */
const CRITERION_LABELS: Readonly<Record<string, string>> = {
  no_wear: 'Sin desgaste',
  light_wear: 'Desgaste leve',
  critical_wear: 'Desgaste crítico',
  ok: 'Conforme',
  needs_adjustment: 'Requiere ajuste',
  intermittent: 'Intermitente',
  failed: 'Falla',
  partial: 'Parcial',
  leaking: 'Con fuga',
  blocked: 'Obstruida',
  within_range: 'Dentro de rango',
  out_of_range: 'Fuera de rango',
};

export function criterionLabel(code: string): string {
  return CRITERION_LABELS[code] ?? code;
}
