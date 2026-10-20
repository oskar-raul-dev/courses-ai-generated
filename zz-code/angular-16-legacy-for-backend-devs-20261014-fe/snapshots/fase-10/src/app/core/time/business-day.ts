/**
 * Un día de calendario en ISO: 'YYYY-MM-DD'. NO es un instante y no lleva hora
 * ni huso. Es lo que significan `validFrom` y `validUntil` de una plantilla, y
 * dos días de éstos se comparan con < y > como cadenas, sin construir un Date.
 *
 * Es un alias de `string` y no un tipo nominal: en TypeScript, un tipo de
 * marca daría más seguridad y costaría un `as` en cada frontera con el
 * backend, que es donde los `as` hacen daño. La disciplina la sostiene el
 * nombre y la revisión, no el compilador. Ejercicio 🔥.
 */
export type BusinessDay = string;

/**
 * La zona horaria de referencia del negocio. CertCore opera desde Bogotá,
 * Lima y Quito, las tres en UTC-5 y sin horario de verano, así que un
 * desplazamiento fijo es correcto y no hace falta Intl para esto.
 *
 * ⚠️ Si algún día un activo está en otra zona, o en una CON horario de verano,
 * este archivo entero cambia: haría falta `Intl.DateTimeFormat` con `timeZone`,
 * no un número. Está escrito aquí para que ese día se cambie UN archivo.
 *
 * 🧭 Ésta es la única definición de zona horaria del proyecto. La Fase 10, que
 * calcula la vigencia de los certificados, la reutiliza. Una segunda constante
 * en otro archivo sería el bug de zona horaria más caro y más difícil de ver.
 */
export const CERTCORE_TIME_ZONE_OFFSET = '-05:00';

/** El desplazamiento de arriba, en minutos. Se calcula una vez. */
const OFFSET_MINUTES = parseOffsetMinutes(CERTCORE_TIME_ZONE_OFFSET);

/**
 * Convierte un instante con offset —como los `startedAt` del mock— en el día
 * de calendario que ve el negocio.
 *
 * Éste es el ÚNICO sitio del proyecto donde un instante se convierte en día.
 * Si aparece un segundo, aparecerá también el primer bug de zona horaria.
 */
export function toBusinessDay(instant: string): BusinessDay {
  const parsed = new Date(instant);

  if (Number.isNaN(parsed.getTime())) {
    throw new Error(`No es un instante válido: "${instant}".`);
  }

  // Se desplaza el instante a la zona de referencia y se lee la parte de fecha
  // en UTC. Leerla con getFullYear() usaría el huso del NAVEGADOR, que es
  // justamente lo que este archivo existe para evitar.
  const shifted = new Date(parsed.getTime() + OFFSET_MINUTES * 60_000);

  return shifted.toISOString().slice(0, 10);
}

/** Hoy, en la zona del negocio. El único `new Date()` sin argumentos del proyecto. */
export function todayInBusinessZone(): BusinessDay {
  return toBusinessDay(new Date().toISOString());
}

/**
 * Suma (o resta) días a un día de calendario. Se usa al publicar, para cerrar
 * la versión anterior el día antes de que empiece la nueva.
 */
export function addDays(day: BusinessDay, delta: number): BusinessDay {
  // Date.UTC evita el huso local por completo: aquí sólo se hace aritmética de
  // calendario, y hacerla en UTC es lo que la vuelve predecible.
  const [year, month, dayOfMonth] = day.split('-').map(Number);
  const shifted = new Date(Date.UTC(year, month - 1, dayOfMonth + delta));

  return shifted.toISOString().slice(0, 10);
}

/** Estrecha un valor desconocido —un parámetro de ruta, por ejemplo— a día válido. */
export function isBusinessDay(value: unknown): value is BusinessDay {
  return typeof value === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(value);
}

/**
 * Un punto en la línea del tiempo, en ISO 8601 y SIEMPRE con offset o con `Z`:
 * '2025-02-10T23:59:59-05:00'. Es lo que significan `issuedAt`, `validUntil`,
 * `resolvedAt` y `startedAt`.
 *
 * ⚠️ Dos `BusinessDay` se comparan con `<` como cadenas y funciona. Dos
 * `Instant` NO: el mismo momento escrito con dos offsets distintos ordena al
 * revés como texto. Para comparar instantes se usa `isPast`.
 */
export type Instant = string;

/**
 * El último instante de un día de calendario, en la zona del negocio.
 *
 * ⭐ Ésta es la función que contesta "¿a qué hora vence algo?", y su respuesta
 * es "al final del día, donde se hace el trabajo".
 *
 * Se construye con concatenación de texto y no con un `Date`: pasar por un
 * objeto Date para volver a una cadena es exactamente donde se pierde el offset.
 */
export function endOfBusinessDay(day: BusinessDay): Instant {
  return `${day}T23:59:59${CERTCORE_TIME_ZONE_OFFSET}`;
}

/** Ahora mismo. El segundo y último `new Date()` sin argumentos del proyecto. */
export function nowInstant(): Instant {
  return new Date().toISOString();
}

/**
 * ¿Este instante ya pasó, comparado con este otro?
 *
 * `now` se recibe por parámetro en vez de llamar a `nowInstant()` dentro: así la
 * Fase 12 puede probar todo el cálculo de vigencia sin tocar el reloj del sistema.
 */
export function isPast(instant: Instant, now: Instant): boolean {
  return new Date(instant).getTime() < new Date(now).getTime();
}

/**
 * Días de calendario entre dos días de negocio. Negativo si `to` es anterior.
 *
 * Aritmética en UTC y sobre las tres piezas de la fecha, igual que `addDays`:
 * dividir la diferencia de dos instantes entre 86.400.000 parece equivalente y
 * no lo es en cuanto aparece un cambio de hora.
 */
export function daysBetween(from: BusinessDay, to: BusinessDay): number {
  const [fromYear, fromMonth, fromDay] = from.split('-').map(Number);
  const [toYear, toMonth, toDay] = to.split('-').map(Number);
  const millis = Date.UTC(toYear, toMonth - 1, toDay) - Date.UTC(fromYear, fromMonth - 1, fromDay);

  return Math.round(millis / 86_400_000);
}

function parseOffsetMinutes(offset: string): number {
  const match = /^([+-])(\d{2}):(\d{2})$/.exec(offset);

  if (match === null) {
    throw new Error(`Offset de zona horaria mal formado: "${offset}".`);
  }

  const [, sign, hours, minutes] = match;
  const total = Number(hours) * 60 + Number(minutes);

  return sign === '-' ? -total : total;
}
