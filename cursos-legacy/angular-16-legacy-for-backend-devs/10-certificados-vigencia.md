# 📜 Fase 10 — Certificados, vigencia y PDF

> Tutorial Angular 16 — Inspecciones y certificaciones · Fase 10 de 14 · **8 horas**
> Depende de: Fase 9 (hallazgos y severidad) · Habilita: Fase 11
> Apéndices de apoyo: [A08 (PDF en cliente con jsPDF 2)](a08-pdf-cliente.md)
> [Incidentes asociados](cuaderno-incidentes.md): 14, 15
> Estilo de esta fase: **nuevo**, con una costura 🧬 hacia el `CertificatesModule` heredado

---

## 🎯 1. Propósito

La Fase 9 escribió `canIssueCertificate()` y no la llamó nadie. Hoy se llama, y con eso CertCore emite su primer documento: un papel que afirma que un ascensor es seguro **hasta una fecha**.

Esa fecha es toda la fase. Porque una fecha, en un sistema que certifica, no es un dato: es una decisión que alguien tomó y casi nunca escribió. ¿Vence a medianoche? ¿De qué huso? ¿El certificado que expira "el 10 de febrero" sirve el día 10 o dejó de servir el día 9 a las siete de la tarde, que es cuando el servidor pasó de fecha? El inspector está en Bogotá, el servidor en Virginia y el cliente abre el PDF desde Madrid, y los tres tienen razón.

Y hay una segunda pregunta, más pequeña y con peor fama: **¿de dónde sacas el dato que imprimes?** De lo que hay pintado en la pantalla, que es lo cómodo, o de la fuente, que es lo correcto. Es la tercera vez que este curso hace esa pregunta —la Fase 7 la hizo con la versión de plantilla, la Fase 9 con la severidad— y es la primera vez que la respuesta equivocada acaba en un documento firmado que sale de la empresa.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `/certificates` lista los dos certificados de la semilla y `CERT-2024-000502` **ya no dice "Vigente"**: aparece como vencido, calculado contra tu reloj. El campo `status` de `db.json` no se lee en ninguna parte de la aplicación, y la pantalla muestra al lado lo que la fila guardada sigue afirmando.
- [ ] Emites el certificado de la inspección `502` —aprobada, sin hallazgos— y aparece con vigencia de doce meses y `validUntil` terminado en `23:59:59-05:00`. Intentas emitir el de la `503` y el sistema se niega nombrando `main-cable`.
- [ ] Intentas emitir dos veces sobre la misma inspección y la segunda se niega con un mensaje distinto al de los hallazgos.
- [ ] Cambias la zona horaria de tu sistema operativo a UTC+13, recargas, y **ni un solo certificado cambia de estado**. Antes de `endOfBusinessDay()`, uno de los dos cambiaba durante nueve horas al día.
- [ ] Descargas el PDF de `CERT-2023-000501`: trae los datos del cliente, del activo, la vigencia y una tabla de hallazgos derivada **con la versión de plantilla que la inspección congeló**, con los acentos puestos.
- [ ] Con la pantalla de detalle abierta, resuelves un hallazgo desde otra pestaña y vuelves a descargar el PDF. Trae el dato nuevo. Con la versión de 5.7 traía el viejo, y eso es el incidente **14**.
- [ ] `ng build --named-chunks` deja `jspdf` en un chunk propio y **no** en `main.js`.
- [ ] `git tag` lista `fase-10`.

---

## 🚫 3. Qué NO entra todavía

- **El modelo de coordenadas de jsPDF, las fuentes embebidas, el encabezado y pie repetidos y las imágenes** → **A08**. Aquí se arma el documento del certificado; allí se aprende la librería.
- **La generación del PDF en el servidor** → se nombra como el límite en A08 y no se implementa. CertCore no tiene backend propio (decisión cerrada de la Fase 2).
- **Firma digital real** → fuera de alcance, y el ejercicio 🔥 explica por qué no es "añadir una imagen de una firma".
- **Envío por correo del certificado** → fuera de alcance. No hay servidor que lo mande.
- **El registro nacional de certificaciones** que el `alcance-del-proyecto.md` §5 menciona → fuera de alcance. Es el ejercicio 🔥 de diseño: qué haces cuando el sistema del que dependes responde tarde, mal o no responde.
- **El tablero de "por vencer a 30/60/90 días"** → **Fase 11**. Aquí se fija el estado `expiring` con un umbral; allí se cuentan y se agrupan.
- **Campos nuevos en `db.seed.json`** → ninguno, otra vez. La vigencia completa se calcula sin pedirle nada al backend, y ése es medio argumento de la fase.

---

## 🧠 4. Concepto mínimo

### El problema, antes que la herramienta

Abre `db.json` y mira el certificado `CERT-2024-000502`. Dice `"status": "valid"`. Su `validUntil` es el 10 de febrero de 2025.

Con cualquier reloj posterior a esa fecha, ese certificado **lleva más de un año mintiendo**, y no hay ningún error en ninguna parte: el dato es exactamente el que alguien escribió el día que lo emitió, y era verdad. Un estado que se calcula pero se almacena no empieza a estar mal: **empieza a estar viejo**, que es peor, porque nada falla y nadie se entera.

La Fase 3 lo sembró a propósito y lo dijo. La Fase 9 llegó a la misma bifurcación con la severidad de los hallazgos y eligió derivar. Hoy se cierra el ciclo, y conviene notar que **es la misma decisión con la misma condición**:

> 🧭 **Un derivado sólo se puede recalcular si sus entradas son inmutables.** El estado de un certificado sale de `validUntil` contra el reloj, más `revokedAt`. `validUntil` se escribe una vez, en la emisión, y no se reescribe nunca — igual que el `templateVersion` de una inspección. Por eso derivar es gratis aquí y sería un desastre si la vigencia se pudiera editar.

### Un día no es un instante, y la diferencia cuesta dinero

La Fase 7 fijó `BusinessDay`: `'YYYY-MM-DD'`, sin hora y sin huso, porque la vigencia de una **plantilla** es un día de calendario. Nadie publica una norma "a las tres de la tarde".

La vigencia de un **certificado** sí lleva hora, y la semilla se comprometió con ella desde la Fase 3: `'2025-02-10T23:59:59-05:00'`. Eso es un instante: un punto en la línea del tiempo que todo el mundo, esté donde esté, señala con el mismo dedo aunque lo escriba distinto.

Los dos son cadenas y los dos parecen fechas, y ahí nace el problema. Dos `BusinessDay` se comparan con `<` como cadenas y funciona. Dos instantes **no**: `'2025-02-10T23:59:59-05:00'` y `'2025-02-11T04:00:00Z'` son el mismo momento y ordenados como texto salen al revés. Por eso lo que se añade hoy a `business-day.ts` no son sólo dos funciones: es un tipo con nombre que impide confundirlos.

### La pregunta que ordena la fase: ¿a qué hora vence algo?

Hay tres respuestas posibles y sólo una es defendible.

**Medianoche UTC** (`'2025-02-11T00:00:00Z'`) es la que sale sola cuando alguien escribe `new Date(day).toISOString()`. Significa que en Bogotá el certificado deja de valer a las **siete de la tarde del día anterior**. El inspector que sube una evidencia a las ocho de la noche del día 10 descubre que su certificado venció ayer.

**Medianoche del navegador** es la que sale cuando alguien construye la fecha sin offset. Significa que el certificado vence a horas distintas para personas distintas, y que el mismo usuario ve una cosa en la oficina y otra de viaje. Es el peor de los tres porque es el único que produce respuestas **inconsistentes entre sí**.

**Fin del día de negocio en la zona de negocio** (`'2025-02-10T23:59:59-05:00'`) significa que el certificado vale todo el día 10 en Colombia, que es donde opera CertCore y donde se hacen las inspecciones. Es la única de las tres que se puede defender delante de un cliente, y es la que la semilla ya trae puesta.

> 🧠 **La lección transferible, y vale para cualquier sistema con vencimientos:** el bug nunca está en `Date`. `Date` hace lo que le pides. El bug está en que nadie escribió a qué hora vence algo, así que cada capa lo decidió por su cuenta y todas decidieron distinto.

### ¿Nuevo o heredado? 🧬 — llenar un placeholder no es tocar código heredado

La Fase 1 generó `CertificatesModule` con un `CertificateListComponent` dentro, declarado, con `constructor` y con esta plantilla entera:

```html
<h2>Certificados</h2>
<p>El listado de certificados llega en la Fase 10.</p>
```

La Fase 5 cerró que ese módulo **no se convierte, ni hoy ni en el resto del curso**. Entonces, ¿el listado que escribes hoy va en estilo heredado, para respetar el archivo que existe?

**No, y la razón es lo que distingue la regla de su aplicación mecánica.** La regla del §6.1 dice *"código heredado se toca lo mínimo y en su propio estilo"*, y existe para no romper lo que ya funciona: hay lógica dentro, hay suscripciones, hay una forma de hacer las cosas que el resto del archivo asume. **Aquí no hay nada de eso.** Hay dos etiquetas HTML y una clase vacía. Lo que se escribe hoy es código nuevo que reutiliza un nombre, no una modificación de código existente.

Compáralo con lo que hizo la Fase 9. `InspectionListComponent` sí tenía código real —carga, suscripción, `ngOnDestroy`— y por eso se le añadió una columna **sin** convertirlo, sin `OnPush` y sin `inject()`, aunque se tocaran ocho líneas.

> 🧭 **La regla, afinada:** lo que decide el estilo no es la fecha del archivo, es **cuánto código vivo hay dentro**. Un stub generado por el CLI no es herencia: es un hueco con nombre. Herencia es lo que alguien escribió y hoy funciona.

Lo que **sí** se queda heredado es el módulo que lo aloja y su routing, con `RouterModule.forChild` y `declarations`. Ahí sí hay decisiones vivas de 2021, y ahí va la 🧬.

> 📝 **Nota de migración.** Que el PDF se genere en el navegador no es una decisión de arquitectura: es una decisión de plantilla de personal. Cuando CertCore nació en 2021 sobre Angular 12 no había equipo de backend disponible, y un `jsPDF` en el cliente resolvía en dos días lo que un servicio de documentos resolvía en dos meses. La migración a 16 durante 2024 no tocó esa pieza —no había motivo, y jsPDF 2 funciona igual en las dos versiones—, así que hoy sigue ahí. Lo que sí cambió con la migración es que ahora se puede diferir con un `import()` dinámico sin pelearse con el builder, y eso es 5.9. La versión 2.5.1 que fija el `alcance-del-proyecto.md` §9 es la que quedó del día que se instaló.

---

## 💻 5. Código mínimo con comentarios

### 5.1 El instante, que es lo que le faltaba a `business-day.ts`

⚠️ Este archivo **existe desde la Fase 7**. Lo que sigue se añade a él. No se crea un segundo archivo de tiempo, y sobre todo **no se declara una segunda constante de zona horaria**: si `CERTCORE_TIME_ZONE_OFFSET` aparece en dos sitios, ya tienes el bug más caro y más difícil de ver del curso.

```ts
// src/app/core/time/business-day.ts — lo que se AÑADE

/**
 * Un punto en la línea del tiempo, en ISO 8601 y SIEMPRE con offset o con `Z`:
 * '2025-02-10T23:59:59-05:00'. Es lo que significan `issuedAt`, `validUntil`,
 * `resolvedAt` y `startedAt`.
 *
 * ⚠️ La diferencia con `BusinessDay` no es cosmética. Dos `BusinessDay` se
 * comparan con `<` como cadenas y funciona. Dos `Instant` NO: el mismo momento
 * escrito con dos offsets distintos ordena al revés como texto. Para comparar
 * instantes se usa `isPast`, que los convierte a milisegundos primero.
 *
 * Es un alias de `string`, como `BusinessDay`, y por la misma razón: un tipo de
 * marca costaría un `as` en cada frontera con el backend. La disciplina la
 * sostienen el nombre y la revisión.
 */
export type Instant = string;

/**
 * El último instante de un día de calendario, en la zona del negocio.
 *
 * ⭐ Ésta es la función que contesta "¿a qué hora vence algo?", y su respuesta
 * es "al final del día, donde se hace el trabajo". Las otras dos respuestas
 * posibles —medianoche UTC y medianoche del navegador— están descartadas en la
 * sección 4, y las dos producen el incidente 15.
 *
 * Se construye con concatenación de texto y no con un `Date`: pasar por un
 * objeto Date para volver a una cadena es exactamente donde se pierde el
 * offset. Aquí no hay nada que perder porque nunca se sale del texto.
 */
export function endOfBusinessDay(day: BusinessDay): Instant {
  return `${day}T23:59:59${CERTCORE_TIME_ZONE_OFFSET}`;
}

/**
 * Ahora mismo. El segundo y último `new Date()` sin argumentos del proyecto —
 * el primero está en `todayInBusinessZone()`, cinco líneas más arriba.
 *
 * Devuelve la forma con `Z` porque es lo que produce `toISOString()` y porque
 * para un instante da igual: `Z` y `-05:00` son dos maneras de escribir el
 * mismo momento. Lo que NO da igual es que falte.
 */
export function nowInstant(): Instant {
  return new Date().toISOString();
}

/**
 * ¿Este instante ya pasó, comparado con este otro?
 *
 * `now` se recibe por parámetro en vez de llamar a `nowInstant()` dentro, y esa
 * decisión de tres caracteres es la que permite que la Fase 12 pruebe todo el
 * cálculo de vigencia sin tocar el reloj del sistema ni instalar una librería
 * de fechas falsas. Una función que consulta el reloj por su cuenta es una
 * función que sólo se puede probar esperando.
 */
export function isPast(instant: Instant, now: Instant): boolean {
  return new Date(instant).getTime() < new Date(now).getTime();
}

/**
 * Días de calendario entre dos días de negocio. Negativo si `to` es anterior.
 *
 * Aritmética en UTC y sobre las tres piezas de la fecha, igual que `addDays`:
 * dividir la diferencia de dos instantes entre 86.400.000 parece equivalente y
 * no lo es en cuanto aparece un cambio de hora. Aquí no hay horario de verano
 * y aun así se escribe bien.
 */
export function daysBetween(from: BusinessDay, to: BusinessDay): number {
  const [fromYear, fromMonth, fromDay] = from.split('-').map(Number);
  const [toYear, toMonth, toDay] = to.split('-').map(Number);
  const millis = Date.UTC(toYear, toMonth - 1, toDay) - Date.UTC(fromYear, fromMonth - 1, fromDay);

  return Math.round(millis / 86_400_000);
}
```

**Detalles con intención**

- **`endOfBusinessDay` usa `23:59:59` y no `23:59:59.999`.** Hay un segundo de cada día en el que un certificado no está ni vigente ni vencido si comparas con `<`. Con `isPast` —que compara con `<` estricto contra `validUntil`— ese segundo cuenta como vigente, que es la respuesta amable y la que un juez preferiría. Vale la pena saber que el agujero existe; el ejercicio 22 te hace encontrarlo.
- **`isPast` recibe `now` en vez de consultarlo.** Es la diferencia entre una función que se prueba con una tabla de casos y una que se prueba esperando a mañana.
- **Nada de esto se llama "fecha".** `BusinessDay`, `Instant`, `endOfBusinessDay`, `daysBetween`. En un archivo de tiempo, la palabra *fecha* es la que permite que dos personas crean que hablan de lo mismo durante media hora.

**El patrón a memorizar**

> Un día de calendario y un instante son dos tipos distintos aunque los dos sean cadenas. El día que los mezclas, el bug aparece durante unas horas concretas y desaparece solo — que es la peor forma de bug que existe.

**Prueba de fuego**

`endOfBusinessDay('2025-02-10')` tiene que darte exactamente `'2025-02-10T23:59:59-05:00'`, carácter por carácter igual al `validUntil` de `CERT-2024-000502` en la semilla. Si te sale con `Z`, o sin offset, o con `T00:00:00`, para aquí: todo lo que viene después va a estar corrido entre cinco y diecinueve horas y no lo vas a notar hasta la sección 6.

### 5.2 La vigencia, que son dos instantes y una regla de negocio

```ts
// src/app/core/domain/certificate-validity.ts
import {
  BusinessDay,
  Instant,
  addDays,
  endOfBusinessDay,
  toBusinessDay,
} from '../time/business-day';

/**
 * Cuánto vale un certificado. Todas las plantillas de CertCore son anuales
 * —`elevator-annual`, `boiler-annual`, `tank-annual`— y los dos certificados
 * de la semilla duran exactamente doce meses.
 *
 * ⚠️ En un sistema real esto NO es una constante: depende de la norma y del
 * tipo de activo, y sale de la plantilla o de una tabla de vigencias. Está
 * aquí, con nombre y en un solo sitio, para que el día que deje de ser una
 * constante se cambie un archivo. Es media línea de diseño que ahorra una
 * búsqueda de dos horas.
 */
export const CERTIFICATE_VALIDITY_MONTHS = 12;

/**
 * La ventana de vigencia. Los dos extremos son instantes, no días.
 *
 * `from` NO es un campo de la fila: es `issuedAt`. El modelo del
 * `alcance-del-proyecto.md` §5.1 guarda cuándo se emitió, y desde cuándo vale
 * es la misma cosa dicha de otra manera. Guardar los dos sería guardar dos
 * veces el mismo dato y darle a alguien la oportunidad de que dejen de
 * coincidir.
 */
export interface CertificateValidity {
  readonly from: Instant;
  readonly until: Instant;
}

/**
 * ⭐ La vigencia de un certificado emitido en este instante.
 *
 * Tres pasos y ninguno es obvio:
 *   1. El instante de emisión se lleva a día de negocio. Emitir a las 23:30 en
 *      Bogotá es emitir el día 10, no el 11, aunque en UTC ya sea 11.
 *   2. Se suman los meses en calendario, no 365 días.
 *   3. El resultado se convierte en el ÚLTIMO instante de ese día.
 */
export function computeValidity(issuedAt: Instant): CertificateValidity {
  const issuedDay = toBusinessDay(issuedAt);

  return {
    from: issuedAt,
    until: endOfBusinessDay(addMonths(issuedDay, CERTIFICATE_VALIDITY_MONTHS)),
  };
}

/**
 * El día en que hay que tener listo el certificado nuevo: el mismo día en que
 * vence el viejo. Renovar no es una entidad ni un flujo: es empezar otra
 * inspección a tiempo, y de eso se encarga la pantalla de 5.6.
 */
export function renewalDueOn(validUntil: Instant): BusinessDay {
  return toBusinessDay(validUntil);
}

/**
 * Suma meses de calendario a un día, recortando al último día del mes cuando
 * el día de origen no existe en el destino.
 *
 * El caso que obliga a escribirla: un certificado emitido el 29 de febrero de
 * 2024 vence el 28 de febrero de 2025, no el 1 de marzo. Sin el recorte,
 * `Date` desborda al mes siguiente en silencio y el certificado dura un día de
 * más — que en un año bisiesto y con una auditoría delante es una conversación
 * incómoda.
 */
function addMonths(day: BusinessDay, months: number): BusinessDay {
  const [year, month, dayOfMonth] = day.split('-').map(Number);
  // Día 0 del mes SIGUIENTE al destino = último día del mes destino.
  const lastDayOfTarget = new Date(Date.UTC(year, month - 1 + months + 1, 0)).getUTCDate();
  const shifted = new Date(
    Date.UTC(year, month - 1 + months, Math.min(dayOfMonth, lastDayOfTarget)),
  );

  return shifted.toISOString().slice(0, 10);
}
```

**Detalles con intención**

- **`addMonths` es privada y `addDays` es pública.** La de días la usa la Fase 7 para cerrar la versión anterior de una plantilla; la de meses sólo la usa el cálculo de vigencia. Exportar lo segundo invitaría a que alguien sumara meses a un día de plantilla, que es una operación que este dominio no tiene.
- **`renewalDueOn` devuelve un `BusinessDay` y no un `Instant`.** "Renueva antes del 10 de febrero" es una frase sobre un día; ponerle hora sería precisión falsa.
- **`computeValidity` recibe el instante de emisión en vez de calcularlo.** Misma razón que `isPast`: la Fase 12 va a emitir certificados en 2019 y en 2031 sin tocar el reloj.

**Prueba de fuego**

Cuatro casos, a mano. `computeValidity('2024-02-10T10:00:00-05:00')` tiene que darte `until` igual al `validUntil` de `CERT-2024-000502` en la semilla, exactamente. `computeValidity('2023-08-21T10:00:00-05:00')` tiene que reproducir el de `CERT-2023-000501`. Ahora `'2024-02-29T09:00:00-05:00'` → `2025-02-28`, no `2025-03-01`. Y el que más gente falla: `'2024-03-15T23:30:00-05:00'` → vence el **15** de marzo de 2025, porque en la zona del negocio todavía es día 15 aunque en UTC ya sea 16. Si te da el 16, se te coló un `new Date()` en algún sitio y estás leyendo el día con el huso del navegador.

### 5.3 ⭐ El estado, que deja de estar guardado

```ts
// src/app/core/domain/certificate-status.ts
import { Certificate, CertificateStatus } from '../models/certificate.model';
import { BusinessDay, Instant, daysBetween, isPast, toBusinessDay } from '../time/business-day';
import { CertificateValidity, renewalDueOn } from './certificate-validity';

/**
 * Cuántos días antes del vencimiento un certificado pasa a `expiring`.
 *
 * 🧭 Decisión del proyecto que la FASE 11 hereda: `expiring` es UN estado con
 * UN umbral. El "por vencer a 30/60/90 días" del dashboard son tres cubos de
 * un informe, no tres estados. Un estado con tres variantes no es un estado:
 * es un filtro disfrazado, y acaba en un `if` con tres ramas en cada pantalla.
 */
export const EXPIRING_WINDOW_DAYS = 30;

/**
 * ⭐ Los estados que el cálculo PUEDE producir, que no son los cinco del
 * modelo.
 *
 * `issued` se queda fuera, y no por descuido. Derivando desde `validUntil`
 * contra el reloj, "recién emitido" y "vigente" son el mismo estado: los dos
 * significan ni vencido, ni por vencer, ni revocado. `issued` es el valor que
 * se ESCRIBE al emitir —5.5— porque es cierto en ese instante y no vuelve a
 * serlo nunca; no es un valor que se pueda volver a calcular.
 *
 * Que la unión del modelo tenga un valor que la derivación no alcanza es
 * exactamente lo que te vas a encontrar en cualquier máquina de estados de
 * más de tres años, y `Exclude` lo dice en el tipo en vez de en un comentario
 * que nadie lee.
 */
export type DerivedCertificateStatus = Exclude<CertificateStatus, 'issued'>;

const STATUS_LABELS: Readonly<Record<DerivedCertificateStatus, string>> = {
  valid: 'Vigente',
  expiring: 'Por vencer',
  expired: 'Vencido',
  revoked: 'Revocado',
};

export function certificateStatusLabel(status: DerivedCertificateStatus): string {
  return STATUS_LABELS[status];
}

/**
 * ⭐ La regla de negocio central de la fase, y son cuatro líneas.
 *
 * El orden de las comprobaciones ES la regla, y la primera sorprende:
 * revocado gana sobre vencido. Un certificado que se revocó en marzo y que
 * además habría vencido en agosto sigue siendo un certificado REVOCADO, no uno
 * vencido, porque lo que importa legalmente es por qué dejó de valer. Si
 * inviertes las dos primeras líneas, cada certificado revocado se convierte en
 * uno caducado con normalidad al cabo de unos meses, y el rastro de que alguien
 * lo anuló desaparece de la pantalla sin desaparecer de la base de datos.
 *
 * ⚠️ `now` entra por parámetro. Sin eso, esta función se prueba esperando.
 */
export function deriveCertificateStatus(
  certificate: Certificate,
  now: Instant,
): DerivedCertificateStatus {
  if (certificate.revokedAt !== null) {
    return 'revoked';
  }

  if (isPast(certificate.validUntil, now)) {
    return 'expired';
  }

  const remaining = daysBetween(toBusinessDay(now), toBusinessDay(certificate.validUntil));

  return remaining <= EXPIRING_WINDOW_DAYS ? 'expiring' : 'valid';
}

/**
 * Todo lo que una pantalla necesita saber de un certificado, calculado de una
 * vez. Es el equivalente del `InspectionFinding` de la Fase 9: un objeto de
 * vista que ya trae resueltas las preguntas, para que la plantilla no tenga
 * que llamar a cuatro funciones con `|` y `?` por medio.
 */
export interface CertificateView {
  readonly certificate: Certificate;
  readonly status: DerivedCertificateStatus;
  readonly validity: CertificateValidity;
  /** Negativo si ya venció. Es lo que pinta "quedan 12 días" o "venció hace 400". */
  readonly daysUntilExpiry: number;
  readonly renewalDueOn: BusinessDay;
  /**
   * Lo que la fila guardada sigue afirmando. NO se usa para decidir nada:
   * viaja igual que el `stored` de la Fase 9, para poder pintar la divergencia
   * y diagnosticarla. Un dato que sólo sirve para diagnosticar sigue siendo un
   * dato que vale la pena tener.
   */
  readonly storedStatus: CertificateStatus;
  readonly diverges: boolean;
}

export function buildCertificateView(certificate: Certificate, now: Instant): CertificateView {
  const status = deriveCertificateStatus(certificate, now);

  return {
    certificate,
    status,
    validity: { from: certificate.issuedAt, until: certificate.validUntil },
    daysUntilExpiry: daysBetween(toBusinessDay(now), toBusinessDay(certificate.validUntil)),
    renewalDueOn: renewalDueOn(certificate.validUntil),
    storedStatus: certificate.status,
    // `issued` guardado frente a `valid` derivado no es divergencia: es el
    // mismo estado con dos nombres, y marcarlo llenaría la pantalla de avisos
    // el primer día de cada certificado.
    diverges: certificate.status !== status && !(certificate.status === 'issued' && status === 'valid'),
  };
}
```

**Detalles con intención**

- **`DerivedCertificateStatus` con `Exclude` en vez de escribir los cuatro valores a mano.** Si mañana alguien añade `suspended` a `CertificateStatus`, el `Record` de etiquetas deja de compilar y el compilador te trae hasta aquí — el mismo truco que la Fase 9 usó con `DOWNGRADED`. Escribir los cuatro sueltos rompería ese hilo.
- **`revokedAt !== null` y no `== null`.** Se puede porque `normalizeCertificate` —5.4— cierra el borde HTTP. Es literalmente la línea que produjo el incidente 12 en la Fase 9, y aquí ya está resuelta antes de escribirla.
- **`diverges` tiene una excepción y está justificada en el código.** Es la clase de detalle que, sin comentario, alguien "simplifica" en seis meses y llena la pantalla de avisos falsos.

```
💸 DEUDA TÉCNICA INTENCIONAL — el estado se calcula al pintar, no al pasar el tiempo
`buildCertificateView` recibe un `now` que se toma en el momento de emitir cada
valor del observable. Una pestaña abierta a las 23:59:50 sigue diciendo
"Vigente" a las 00:00:10 hasta que algo la haga recalcular.
NO SE PAGA, y el motivo es de proporción: lo correcto sería un `timer` que
reemita cada minuto, y eso son treinta y siete líneas y una fuga de suscripción
esperando para resolver un problema que dura diez segundos al año por
certificado. Lo que SÍ importa es que el error es de FRESCURA —el dato se pone
viejo en segundos y se arregla recargando— y no de CORRECCIÓN, que era el
problema del `status` guardado: aquél se ponía viejo para siempre y no se
arreglaba con nada. Saber distinguir esas dos cosas es la mitad de esta fase.
El ejercicio 27 te hace implementar el `timer` y decidir si lo dejarías puesto.
```

**El patrón a memorizar**

> Antes de guardar un estado, pregúntate qué lo cambia. Si lo cambia una acción, guárdalo. Si lo cambia **el paso del tiempo**, no lo guardes: no hay ningún momento en el que alguien vaya a ejecutar el `UPDATE`.

**Prueba de fuego**

Con el mock levantado y sin escribir todavía ninguna pantalla, llama a `deriveCertificateStatus` con los dos certificados de la semilla y `nowInstant()`. `CERT-2023-000501` da `expired`, y su fila guardada también dice `expired`: coinciden, y por eso no sirve para nada más que de control. `CERT-2024-000502` da `expired` y su fila dice `valid`. **Esa discrepancia es la fase entera en una línea de consola.**

### 5.4 El borde HTTP, otra vez y sin sorpresa

```ts
// src/app/core/api/certificate-api.service.ts
import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, catchError, map } from 'rxjs';

import { environment } from '../../../environments/environment';
import { Certificate } from '../models/certificate.model';
import { Instant } from '../time/business-day';
import { toApiError } from './api-error';

@Injectable({ providedIn: 'root' })
export class CertificateApiService {
  private readonly http = inject(HttpClient);

  private readonly baseUrl = `${environment.apiBaseUrl}/certificates`;

  getAll(): Observable<readonly Certificate[]> {
    return this.http
      .get<readonly Certificate[]>(this.baseUrl)
      .pipe(map((rows) => rows.map(normalizeCertificate)), catchError(toApiError));
  }

  /**
   * Devuelve un array y no un `Certificate | null`, aunque el negocio diga que
   * hay como mucho uno por inspección. json-server filtra y devuelve lista; el
   * "como mucho uno" es una regla que se hace cumplir en 5.5, no una promesa
   * del transporte. Prometer aquí lo que el backend no garantiza es cómo se
   * escriben los `undefined` que explotan seis meses después.
   */
  getByInspection(inspectionId: number): Observable<readonly Certificate[]> {
    const params = new HttpParams().set('inspectionId', inspectionId);

    return this.http
      .get<readonly Certificate[]>(this.baseUrl, { params })
      .pipe(map((rows) => rows.map(normalizeCertificate)), catchError(toApiError));
  }

  issue(certificate: Certificate): Observable<Certificate> {
    return this.http
      .post<Certificate>(this.baseUrl, certificate)
      .pipe(map(normalizeCertificate), catchError(toApiError));
  }

  /** Revocar es poner una fecha, igual que resolver un hallazgo. */
  revoke(id: string, revokedAt: Instant): Observable<Certificate> {
    return this.http
      .patch<Certificate>(`${this.baseUrl}/${id}`, { revokedAt })
      .pipe(map(normalizeCertificate), catchError(toApiError));
  }
}

/**
 * El mismo `?? null` de `normalizeFinding` en la Fase 9, sobre el campo
 * equivalente. Y que sea el mismo es justo lo que hay que notar: la primera
 * vez fue un incidente que costó una semana; la segunda es una línea que se
 * escribe sin pensar, en el sitio que ya sabemos que es el correcto.
 *
 * Un patrón es un incidente al que le pusiste nombre.
 */
function normalizeCertificate(raw: Certificate): Certificate {
  return { ...raw, revokedAt: raw.revokedAt ?? null };
}
```

### 5.5 La emisión, que es la puerta que la Fase 9 dejó escrita

```ts
// src/app/core/state/certificate-state.service.ts
import { Injectable, inject } from '@angular/core';
import { BehaviorSubject, Observable, concatMap, map, tap, throwError } from 'rxjs';

import { CertificateApiService } from '../api/certificate-api.service';
import { canIssueCertificate, summarizeFindings } from '../domain/inspection-findings';
import { BusinessRuleError } from '../domain/inspection-rules';
import { CertificateView, buildCertificateView } from '../domain/certificate-status';
import { computeValidity } from '../domain/certificate-validity';
import { Certificate } from '../models/certificate.model';
import { Inspection } from '../models/inspection.model';
import { Instant, nowInstant, toBusinessDay } from '../time/business-day';
import { InspectionStateService } from './inspection-state.service';

interface CertificateState {
  readonly items: readonly Certificate[];
  readonly loading: boolean;
  readonly error: string | null;
}

@Injectable({ providedIn: 'root' })
export class CertificateStateService {
  private readonly certificateApi = inject(CertificateApiService);
  private readonly inspectionState = inject(InspectionStateService);

  private readonly stateSubject = new BehaviorSubject<CertificateState>({
    items: [],
    loading: false,
    error: null,
  });

  readonly state$: Observable<CertificateState> = this.stateSubject.asObservable();

  /**
   * Los certificados con su estado ya derivado. `nowInstant()` se llama DENTRO
   * del map, así que cada emisión recalcula: si el estado cambiara por una
   * acción, se vería sin recargar. Que no cambie por el paso del tiempo es la
   * 💸 declarada en 5.3.
   */
  readonly views$: Observable<readonly CertificateView[]> = this.state$.pipe(
    map((state) => {
      const now = nowInstant();

      return state.items.map((certificate) => buildCertificateView(certificate, now));
    }),
  );

  load(): void {
    this.stateSubject.next({ ...this.stateSubject.value, loading: true, error: null });

    this.certificateApi.getAll().subscribe({
      next: (items) => this.stateSubject.next({ items, loading: false, error: null }),
      error: (error: unknown) =>
        this.stateSubject.next({
          items: [],
          loading: false,
          error: error instanceof Error ? error.message : 'No se pudieron cargar los certificados.',
        }),
    });
  }

  /**
   * ⭐ EMITIR. La operación por la que existe esta fase, y la primera línea de
   * negocio que llama a `canIssueCertificate` — que la Fase 9 dejó escrita y
   * sin invocar precisamente para que la llamara ésta.
   *
   * Tres puertas, en este orden y por este motivo:
   *   1. ¿Ya tiene certificado? Es lo más barato de comprobar y lo que más
   *      veces va a pasar (alguien pulsa dos veces).
   *   2. ¿Se puede emitir? Aprobada y sin hallazgos críticos bloqueantes. Ésa
   *      es la regla y vive en `canIssueCertificate`, no aquí.
   *   3. Sólo entonces se calcula la vigencia y se escribe.
   */
  issue(inspection: Inspection): Observable<Certificate> {
    return this.certificateApi.getByInspection(inspection.id).pipe(
      concatMap((existing) => {
        if (existing.length > 0) {
          return throwError(
            () =>
              new BusinessRuleError(
                `La inspección ${inspection.id} ya tiene el certificado ${existing[0].id}. Para reemplazarlo hay que revocarlo primero.`,
              ),
          );
        }

        return this.inspectionState.findingsOf(inspection).pipe(map(summarizeFindings));
      }),
      concatMap((summary) => {
        // Si la rama anterior lanzó, aquí no llega nada. Si llegó, `summary`
        // es un FindingSummary de verdad.
        if (!canIssueCertificate(inspection, summary)) {
          // La FUNCIÓN decide; estas cadenas sólo explican. Duplicar la regla
          // en el `if` del mensaje sería tener dos versiones de la misma
          // condición y que se separen en la primera modificación.
          const reason =
            inspection.status !== 'approved'
              ? `la inspección está ${inspection.status} y sólo se certifica lo aprobado`
              : `hay hallazgos críticos sin resolver en ${summary.blocking.join(', ')}`;

          return throwError(
            () => new BusinessRuleError(`No se puede emitir el certificado: ${reason}.`),
          );
        }

        const issuedAt = nowInstant();
        const validity = computeValidity(issuedAt);

        return this.certificateApi.issue({
          id: buildCertificateId(issuedAt, inspection.id),
          inspectionId: inspection.id,
          issuedAt,
          validUntil: validity.until,
          // Se escribe `issued` porque el modelo lo exige y porque es LO ÚNICO
          // cierto en este instante. A partir del siguiente milisegundo, este
          // campo es historia y nadie de esta aplicación lo vuelve a leer.
          status: 'issued',
          revokedAt: null,
        });
      }),
      tap(() => this.load()),
    );
  }

  /**
   * Revocar. Cierra el bucle que la Fase 9 abrió en su ejercicio 24: cuando
   * aparece un hallazgo crítico en una inspección ya aprobada, la inspección
   * NO se desaprueba —aprobar es irreversible, alcance §5— y el certificado SÍ
   * se revoca. Ésa es la única salida coherente con las dos reglas a la vez.
   */
  revoke(certificate: Certificate): Observable<Certificate> {
    if (certificate.revokedAt !== null) {
      return throwError(
        () => new BusinessRuleError(`El certificado ${certificate.id} ya estaba revocado.`),
      );
    }

    return this.certificateApi.revoke(certificate.id, nowInstant()).pipe(tap(() => this.load()));
  }
}

/**
 * `CERT-2024-000502`: el año del día de negocio de la emisión, más el id de la
 * inspección a seis dígitos. Reproduce el formato de la semilla.
 *
 * ⚠️ En un sistema real el identificador de un documento oficial lo asigna el
 * backend, en una transacción, porque es lo único que garantiza que no haya
 * dos iguales. Aquí lo compone el cliente porque no hay backend, y con dos
 * pestañas abiertas sobre la misma inspección saldrían dos ids idénticos —que
 * json-server aceptaría, porque `id` es la clave y el segundo pisaría al
 * primero—. La regla de "una inspección, un certificado" de `issue()` lo tapa
 * en la práctica; no lo resuelve.
 */
function buildCertificateId(issuedAt: Instant, inspectionId: number): string {
  const year = toBusinessDay(issuedAt).slice(0, 4);

  return `CERT-${year}-${String(inspectionId).padStart(6, '0')}`;
}
```

**Detalles con intención**

- **`concatMap` y no `switchMap`, dos veces.** Detrás hay una escritura, y es la regla que la Fase 6 fijó. Con `switchMap`, dos pulsaciones rápidas cancelan la primera petición **después** de que el `POST` haya salido, y te quedas con un certificado emitido y una pantalla que dice que no pasó nada.
- **La comprobación de "ya tiene certificado" va primero y cuesta una petición.** Podría hacerse con lo que ya hay en `stateSubject`, y sería más rápido y menos correcto: el estado en memoria puede ser de hace diez minutos, y emitir dos veces el mismo documento oficial no es un error que se arregle recargando.
- **`revoke()` no pregunta por qué.** No hay campo de motivo en el modelo y no se inventa uno. Lo que sí queda es la fecha, que es lo que permite reconstruir con qué hallazgo coincidió. La trazabilidad completa sigue sin dueño desde la Fase 6 y esta fase es la cuarta que lo señala.

**Prueba de fuego**

Con el mock levantado: emite sobre la `502` —aprobada, dos respuestas conformes, cero hallazgos— y comprueba en Network que sale **un** `POST` con `validUntil` terminado en `23:59:59-05:00`. Vuelve a pulsar: no sale ningún `POST`, sale el mensaje del certificado ya existente. Ahora prueba sobre la `503`, que está `rejected`: el mensaje habla del estado, no de los hallazgos. Pon la `503` en `completed` en `db.json`, recarga, y prueba otra vez: ahora el mensaje nombra `main-cable`. **Los tres mensajes distintos son el entregable de esta sección**, porque son tres razones distintas y un usuario que lee "no se puede emitir" a secas vuelve a pulsar.

### 5.6 Las pantallas, y el estado que ya no se cree lo que dice el dato

```ts
// src/app/features/certificates/certificate-list/certificate-list.component.ts
import { AsyncPipe, DatePipe, NgFor, NgIf } from '@angular/common';
import { ChangeDetectionStrategy, Component, OnInit, inject } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { RouterLink } from '@angular/router';

import { CertificateView, certificateStatusLabel } from '../../../core/domain/certificate-status';
import { CertificateStateService } from '../../../core/state/certificate-state.service';

/**
 * 🧬 Reemplaza al placeholder que la Fase 1 generó dentro de
 * `CertificatesModule`. Conserva el nombre —§12, nombres estables— y cambia el
 * estilo, porque lo que había dentro eran dos etiquetas de HTML: llenar un
 * stub es escribir código nuevo, no modificar código heredado. El razonamiento
 * completo está en la sección 4, y es distinto del de `InspectionListComponent`
 * en la Fase 9 a propósito.
 */
@Component({
  selector: 'app-certificate-list',
  standalone: true,
  imports: [AsyncPipe, DatePipe, NgFor, NgIf, MatButtonModule, MatIconModule, RouterLink],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './certificate-list.component.html',
  styleUrls: ['./certificate-list.component.scss'],
})
export class CertificateListComponent implements OnInit {
  private readonly certificateState = inject(CertificateStateService);

  readonly views$ = this.certificateState.views$;
  readonly state$ = this.certificateState.state$;

  // Se expone la función para que la plantilla no tenga que conocer el Record.
  readonly statusLabel = certificateStatusLabel;

  ngOnInit(): void {
    this.certificateState.load();
  }

  /** La clase CSS del chip sale del estado DERIVADO, nunca del guardado. */
  chipClass(view: CertificateView): string {
    return `chip chip--${view.status}`;
  }
}
```

```html
<!-- src/app/features/certificates/certificate-list/certificate-list.component.html -->
<h2>Certificados</h2>

<p *ngIf="(state$ | async)?.loading">Cargando certificados…</p>

<ul class="certificate-list" *ngIf="views$ | async as views">
  <li *ngFor="let view of views" class="certificate-list__item">
    <a [routerLink]="['/certificates', view.certificate.id]">{{ view.certificate.id }}</a>

    <span [class]="chipClass(view)">{{ statusLabel(view.status) }}</span>

    <span class="certificate-list__validity">
      Vigente hasta {{ view.validity.until | date: 'dd/MM/yyyy' }}
    </span>

    <!-- "quedan 12 días" o "venció hace 400": el mismo número con dos lecturas. -->
    <span *ngIf="view.daysUntilExpiry >= 0">Quedan {{ view.daysUntilExpiry }} días</span>
    <span *ngIf="view.daysUntilExpiry < 0">Venció hace {{ -view.daysUntilExpiry }} días</span>

    <!--
      El aviso de divergencia NO es para el usuario final: es para ti, y por eso
      dice exactamente qué guarda la fila. En un sistema en producción esto sería
      una alerta de datos, no un texto en pantalla.
    -->
    <span class="certificate-list__diverges" *ngIf="view.diverges">
      ⚠️ La fila guardada dice "{{ view.storedStatus }}" y el cálculo dice
      "{{ view.status }}".
    </span>
  </li>
</ul>
```

```ts
// src/app/features/certificates/certificate-detail/certificate-detail.component.ts — lo esencial
export class CertificateDetailComponent {
  private readonly route = inject(ActivatedRoute);
  private readonly certificateState = inject(CertificateStateService);
  private readonly certificatePdf = inject(CertificatePdfService);
  private readonly snackBar = inject(MatSnackBar);

  private readonly reload$ = new Subject<void>();

  readonly view$: Observable<CertificateView> = combineLatest([
    this.route.paramMap,
    this.reload$.pipe(startWith(undefined)),
  ]).pipe(
    switchMap(([params]) => this.certificateState.viewOf(String(params.get('id')))),
  );

  /**
   * ⭐ El botón que produce el documento. NO recibe el `view` de la pantalla:
   * recibe el id, y el servicio vuelve a pedir todo lo que necesita. La razón
   * está en 5.7 y 5.8, y es la deuda que esta fase paga dentro de sí misma.
   */
  download(certificateId: string): void {
    this.certificatePdf
      .download(certificateId)
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe({ error: (error: unknown) => this.report(error) });
  }

  revoke(certificate: Certificate): void {
    this.certificateState
      .revoke(certificate)
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe({
        next: () => this.reload$.next(),
        error: (error: unknown) => this.report(error),
      });
  }

  /** El mismo `instanceof` de la Fase 9: "falló" y "la respuesta es no" no se pintan igual. */
  private report(error: unknown): void {
    if (error instanceof BusinessRuleError) {
      this.snackBar.open(error.message, 'Entendido', { duration: 8000 });

      return;
    }

    this.snackBar.open('No se pudo completar la operación. Reintenta.', 'Reintentar', {
      duration: 5000,
    });
  }
}
```

La renovación, en la plantilla del detalle, es dos líneas y ninguna entidad nueva:

```html
<!-- Renovar no es un flujo: es empezar otra inspección a tiempo. -->
<p *ngIf="view.status === 'expiring' || view.status === 'expired'">
  Renueva antes del {{ view.renewalDueOn | date: 'dd/MM/yyyy' }}.
  <a [routerLink]="['/inspections', 'new']" [queryParams]="{ assetId: view.assetId }">
    Programar la inspección de renovación
  </a>
</p>
```

**Detalles con intención**

- **La lista pinta el estado derivado y el guardado a la vez.** En una aplicación real sólo se pintaría el derivado; aquí se enseñan los dos durante una fase porque ver la fila mintiendo al lado del cálculo vale más que tres párrafos explicándolo. El ejercicio 8 te hace quitarlo.
- **`viewOf(id)` en el servicio y no `views$ | filtro` en el componente.** Buscar un elemento dentro de una lista en la plantilla es cómodo hasta que la lista no está cargada y el componente pinta un `undefined` durante 300 ms.
- **`chipClass` devuelve una cadena compuesta y no un objeto de clases.** Con cuatro estados y una clase por estado, el `[ngClass]` con objeto son doce líneas para hacer lo mismo.

### 5.7 💸 El PDF que lee la pantalla, que es el incidente 14

Ésta es la versión que **se va a caer**, y se escribe entera porque es la que todo el mundo escribe primero. Tiene toda la información a mano, no hace ni una petición, y es rapidísima.

```ts
// src/app/features/certificates/certificate-pdf.service.ts — LA VERSIÓN QUE FALLA
@Injectable({ providedIn: 'root' })
export class CertificatePdfService {
  /**
   * 💸 DEUDA TÉCNICA INTENCIONAL — el documento se arma desde la vista.
   *
   * `view` es el objeto que el componente ya tiene pintado, y `findings` es la
   * lista que la pantalla cargó cuando se abrió. Todo está aquí, no hace falta
   * pedir nada, y el PDF sale en cincuenta milisegundos.
   *
   * SE PAGA EN ESTA MISMA FASE, en 5.8, en cuanto veas el incidente 14. Un
   * certificado con datos viejos no es una deuda tolerable: es un documento
   * que sale de la empresa afirmando algo falso, y no hay ninguna fase
   * posterior a la que valga la pena diferir eso.
   */
  async download(view: CertificateView, findings: readonly InspectionFinding[]): Promise<void> {
    const { jsPDF } = await import('jspdf');
    const document = new jsPDF();

    document.text(`Certificado ${view.certificate.id}`, 20, 20);
    document.text(`Vigente hasta ${view.validity.until}`, 20, 30);
    // …y la tabla de hallazgos, con lo que la pantalla tenga cargado.

    document.save(`${view.certificate.id}.pdf`);
  }
}
```

**Y así se rompe, en cuatro pasos que un usuario hace sin darse cuenta.** Abre el detalle del certificado de la inspección `501`. Se queda en esa pestaña. En otra pestaña —o un compañero, desde otro equipo— marca como resuelto el hallazgo de `door-sensor`. Vuelve a la primera pestaña, que sigue mostrando lo de hace veinte minutos, y pulsa "Descargar PDF".

El PDF sale perfecto, con acentos, con la tabla bien alineada, y afirma que hay un hallazgo mayor sin resolver. **Nada falló.** No hay error en consola, no hay nada rojo en Network, y el documento ya está en la carpeta de descargas de alguien, camino de un correo.

> ⚠️ **Lo que hace peligrosa a esta deuda no es que el dato esté viejo: es que el PDF es el único artefacto del sistema que sobrevive al sistema.** Una pantalla desactualizada se arregla con F5. Un PDF desactualizado se archiva, se imprime y se adjunta a una respuesta a un requerimiento normativo, y dentro de dos años nadie va a poder decir de qué momento son sus datos.

### 5.8 💸 El pago: el documento se arma desde la fuente

```ts
// src/app/core/pdf/certificate-document.ts
import type { jsPDF } from 'jspdf';

import { Asset } from '../models/asset.model';
import { Certificate } from '../models/certificate.model';
import { ChecklistTemplate } from '../models/checklist-template.model';
import { Client } from '../models/client.model';
import { Inspection } from '../models/inspection.model';
import { CertificateView, certificateStatusLabel } from '../domain/certificate-status';
import { InspectionFinding } from '../domain/inspection-findings';
import { severityLabel } from '../domain/finding-severity';

/**
 * Todo lo que el documento necesita, junto y ya resuelto. Que sea una
 * interfaz explícita y no "lo que tenga el componente" es la mitad del
 * arreglo: aquí se ve de un vistazo que hacen falta seis cosas, y las seis
 * tienen que venir de la fuente.
 */
export interface CertificateDocumentSource {
  readonly certificate: Certificate;
  readonly view: CertificateView;
  readonly inspection: Inspection;
  readonly template: ChecklistTemplate;
  readonly asset: Asset;
  readonly client: Client;
  readonly findings: readonly InspectionFinding[];
}

/**
 * ⭐ Arma el documento. Función pura: recibe datos y un `jsPDF` ya construido,
 * y no sabe nada de Angular, de HTTP ni de pantallas. La Fase 12 la va a
 * probar comprobando el texto que produce, sin `TestBed` y sin navegador.
 *
 * ⚠️ `template` tiene que ser la versión que la inspección GUARDÓ. Es la
 * cuarta vez que aparece esta advertencia en el curso —Fase 7 §5.9, Fase 8
 * §5.5, Fase 9 §5.6— y aquí las consecuencias son las peores de las cuatro:
 * con la plantilla vigente, el certificado no falla, IMPRIME otra cosa.
 */
export function buildCertificateDocument(
  document: jsPDF,
  source: CertificateDocumentSource,
  autoTable: AutoTableFn,
): jsPDF {
  const { certificate, view, inspection, asset, client, findings } = source;

  document.setFontSize(16);
  document.text('Certificado de inspección', 20, 20);

  document.setFontSize(11);
  document.text(`Número: ${certificate.id}`, 20, 32);
  document.text(`Cliente: ${client.legalName} (NIT ${client.taxId})`, 20, 39);
  document.text(`Activo: ${asset.id} — ${asset.description}`, 20, 46);
  document.text(`Inspección: ${inspection.id}`, 20, 53);
  // La versión de plantilla va IMPRESA en el documento, y no es un adorno:
  // es lo que permite, dentro de tres años, saber con qué norma se evaluó.
  document.text(
    `Plantilla: ${inspection.templateId} v${inspection.templateVersion}`,
    20,
    60,
  );
  document.text(`Estado: ${certificateStatusLabel(view.status)}`, 20, 67);
  document.text(
    `Vigencia: del ${formatInstant(view.validity.from)} al ${formatInstant(view.validity.until)}`,
    20,
    74,
  );

  autoTable(document, {
    startY: 84,
    head: [['Ítem', 'Respuesta', 'Severidad', 'Resuelto']],
    body: findings.map((finding) => [
      finding.itemId,
      finding.answer,
      // `severity: null` significa "lo calculé y no hay", y en un documento
      // oficial eso se imprime, no se deja en blanco.
      finding.severity === null ? 'Sin determinar' : severityLabel(finding.severity),
      finding.resolvedAt === null ? 'No' : formatInstant(finding.resolvedAt),
    ]),
  });

  return document;
}

/**
 * La firma mínima de `autoTable` que este archivo usa. Se declara aquí para
 * que la función pura no dependa del tipo de la librería y siga siendo
 * probable sin instalarla — y sin un solo `any`.
 */
export type AutoTableFn = (
  document: jsPDF,
  options: {
    readonly startY: number;
    readonly head: readonly (readonly string[])[];
    readonly body: readonly (readonly string[])[];
  },
) => void;

function formatInstant(instant: string): string {
  // El documento se lee en Colombia: se imprime el día de negocio, no el
  // instante completo, y desde luego no el UTC.
  return toBusinessDay(instant).split('-').reverse().join('/');
}
```

Y el servicio, que ahora **vuelve a pedir todo** en el momento de pulsar:

```ts
// src/app/features/certificates/certificate-pdf.service.ts — LA VERSIÓN QUE PAGA
@Injectable({ providedIn: 'root' })
export class CertificatePdfService {
  private readonly certificateApi = inject(CertificateApiService);
  private readonly inspectionApi = inject(InspectionApiService);
  private readonly inspectionState = inject(InspectionStateService);
  private readonly templateApi = inject(TemplateApiService);
  private readonly assetApi = inject(AssetApiService);
  private readonly clientApi = inject(ClientApiService);

  /**
   * 🪦 LA DEUDA DE 5.7, PAGADA.
   *
   * Recibe un id y no un objeto de vista. Todo lo demás se vuelve a pedir aquí,
   * en el instante en que alguien pulsa el botón. Cuesta seis peticiones y
   * medio segundo, y ése es exactamente el precio de que el documento diga la
   * verdad en el momento en que se genera.
   *
   * 🧭 La regla del proyecto que sale de aquí: un documento se arma desde la
   * fuente, nunca desde lo que hay pintado. Se repite en A08 porque es el
   * error que todo el mundo comete dos veces.
   */
  download(certificateId: string): Observable<void> {
    return this.certificateApi.getAll().pipe(
      map((certificates) => {
        const certificate = certificates.find((row) => row.id === certificateId);

        if (certificate === undefined) {
          throw new BusinessRuleError(`No existe el certificado ${certificateId}.`);
        }

        return certificate;
      }),
      concatMap((certificate) =>
        this.inspectionApi.getById(certificate.inspectionId).pipe(
          concatMap((inspection) =>
            combineLatest({
              certificate: of(certificate),
              inspection: of(inspection),
              // La versión CONGELADA, cuarta aparición de la misma línea.
              template: this.templateApi.getByVersion(
                inspection.templateId,
                inspection.templateVersion,
              ),
              asset: this.assetApi.getById(inspection.assetId),
              findings: this.inspectionState.findingsOf(inspection),
            }),
          ),
        ),
      ),
      concatMap((parts) =>
        this.clientApi.getById(parts.asset.clientId).pipe(
          map((client) => ({
            ...parts,
            client,
            view: buildCertificateView(parts.certificate, nowInstant()),
          })),
        ),
      ),
      concatMap((source) => from(this.render(source))),
    );
  }

  /** La carga diferida vive aquí y sólo aquí. Ver 5.9. */
  private async render(source: CertificateDocumentSource): Promise<void> {
    const { jsPDF } = await import('jspdf');
    const autoTable = (await import('jspdf-autotable')).default;

    const document = buildCertificateDocument(new jsPDF(), source, autoTable);

    document.save(`${source.certificate.id}.pdf`);
  }
}
```

**Detalles con intención**

- **El armado del documento es puro y vive en `core/pdf/`, no en la feature.** La feature sabe pedir datos y disparar una descarga; el documento es dominio. Es la misma frontera que la Fase 9 trazó entre `core/domain/` y las pantallas, y por la misma razón: lo que se puede probar sin navegador se prueba sin navegador.
- **`autoTable` entra por parámetro con un tipo propio y mínimo.** Así `buildCertificateDocument` no importa la librería —sólo su tipo, con `import type`, que desaparece en la compilación— y el archivo puro sigue siendo puro. Sin ese parámetro, la función pura arrastraría 300 KB detrás.
- **Seis peticiones para un PDF, y está bien.** Es una acción explícita del usuario, no un render. El día que sean sesenta, la respuesta es un endpoint que devuelva el certificado completo, no una caché en el cliente.
- **Los acentos.** El texto va en español con tildes y jsPDF los trata según la fuente que tenga puesta. Si en tu PDF salen cuadros o caracteres raros, **la mecánica exacta —qué codifica la fuente por defecto y cuándo hay que embeber una— es A08, sección de fuentes**. Lo único que hace falta saber aquí: esto se verifica **mirando el PDF**, no la consola, porque la consola no se va a quejar.

**El patrón a memorizar**

> Lo que hay en la pantalla es una foto de hace un rato. Está bien para mirar y está mal para imprimir. Cualquier artefacto que sobreviva a la sesión —un PDF, un correo, un export— se arma pidiendo el dato otra vez.

**Prueba de fuego**

Abre el detalle del certificado de la `501`. Sin cerrar esa pestaña, abre otra en `/inspections/501/findings` y marca el hallazgo de `door-sensor` como resuelto. Vuelve a la primera —que sigue mostrando el estado viejo— y descarga el PDF. **La tabla del PDF tiene que traer el hallazgo resuelto aunque la pantalla de detrás diga lo contrario.** Si trae lo mismo que la pantalla, todavía estás en la versión de 5.7.

### 5.9 🧬 La costura, y los 300 KB que no viajan en el arranque

`CertificatesModule` es de 2021, la Fase 5 cerró que no se convierte, y hoy aloja dos componentes standalone. Quinta aparición del patrón, y ya no lleva explicación: lleva marcador.

```ts
// src/app/features/certificates/certificates-routing.module.ts
// 🧬 RouterModule.forChild() de 2021 con componentes standalone de 2025.
const routes: Routes = [
  { path: '', component: CertificateListComponent },
  { path: ':id', component: CertificateDetailComponent },
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class CertificatesRoutingModule {}
```

```ts
// src/app/features/certificates/certificates.module.ts
@NgModule({
  // `declarations` vacío: ya no hay nada que declarar. Se deja el NgModule
  // porque el `loadChildren` de `app-routing.module.ts` lo apunta y cambiarlo
  // significa tocar el routing raíz, que es código heredado de la Fase 1 que
  // hoy no tiene ningún motivo para cambiar.
  imports: [
    SharedModule,
    CertificatesRoutingModule,
    // 🧬 Los dos standalone de esta fase, alojados por el módulo de 2021.
    CertificateListComponent,
    CertificateDetailComponent,
  ],
})
export class CertificatesModule {}
```

**Y ahora el bundle.** jsPDF con `jspdf-autotable` es, con diferencia, la dependencia más pesada que este curso instala: el orden de magnitud es **unos 300 KB** añadidos al bundle. Importarla arriba —en el servicio, en el módulo o en cualquier archivo que se cargue de forma *eager*— la mete en `main.js`, y entonces **todo el mundo la descarga**: el inspector que sólo abre el formulario, el supervisor que sólo mira la lista, y quien entra a `/login` y se equivoca de contraseña.

Con el `await import('jspdf')` de 5.8 dentro de un método privado, el bundler la deja en un chunk propio que no se pide hasta que alguien pulsa "Descargar PDF".

Mídelo, que es lo que hace la Fase 5 y es lo que vas a tener que defender en una revisión:

```bash
# Con el import estático arriba del servicio:
ng build --named-chunks --stats-json
# Anota el "Initial total". Y busca dónde quedó la librería:
grep -o '"name":"[^"]*jspdf[^"]*"' stats.json | sort -u

# Ahora con el import() dinámico de 5.8, y repite las dos órdenes.
```

| | Initial total | ¿Dónde vive `jspdf`? |
|---|---|---|
| `import` estático | ⟨tu número⟩ | `main` |
| `await import()` | ⟨tu número⟩ | chunk propio |

> 🧭 **Anota las dos cifras en `deuda.md`, junto a las de las Fases 4 y 5.** Este curso no publica el número que a ti te salga, porque depende de tu versión exacta de las dependencias y de tu máquina; publica el **método**. La diferencia entre las dos filas es tuya y es la que vale en una discusión.

> 🧠 **El modelo mental, que es el mismo de la Fase 5 visto desde el otro lado.** Allí la pregunta era *"¿qué es eager?"* y la respuesta estaba en quién importaba `SharedModule`. Aquí la pregunta es la misma y la respuesta está en una sola línea: un `import` en la cabecera de un archivo es una promesa de que eso viaja siempre. `await import()` es la misma promesa aplazada hasta que alguien la pida.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Síntoma:** un certificado con vigencia del año pasado aparece como "Vigente" en la lista.
**Causa:** se está leyendo `certificate.status` en vez de `deriveCertificateStatus()`. Es el antipatrón que la Fase 3 sembró y que la fila `CERT-2024-000502` lleva arrastrando desde febrero de 2025.
**Fix mínimo:** llamar a la derivación en el punto donde se pinta.
**Lo que importa:** el fix mínimo tapa **esa pantalla**. Lo correcto es que el campo guardado no se lea en ninguna parte, y por eso `buildCertificateView` lo mueve a `storedStatus` con un nombre que dice lo que es. Un campo que no se debe usar y que se sigue llamando `status` es una trampa para el próximo que llegue.

**Síntoma:** el certificado "vence hoy" para el inspector y "venció ayer" para el sistema, entre las siete de la tarde y la medianoche.
**Causa:** el `validUntil` se construyó con `Z` o sin offset —`new Date(day).toISOString()` es la forma más común—, así que el vencimiento cayó a las 19:00 de Bogotá.
**Fix mínimo:** pasar por `endOfBusinessDay()`.
**Lo que importa:** es el **incidente 15**, y su lección es que un bug de zona horaria no se manifiesta siempre: se manifiesta **durante unas horas concretas de cada día**. Por eso llega como "a veces pasa", por eso nadie lo reproduce en la mañana, y por eso conviene que la decisión de a qué hora vence algo esté escrita en una función con nombre en vez de repartida en tres plantillas.

**Síntoma:** el PDF trae datos distintos a los de la pantalla de hallazgos.
**Causa:** el documento se armó desde el objeto de vista que el componente tenía cargado.
**Fix mínimo:** no hay uno bueno. Recargar antes de generar es tapar el agujero con la esperanza de que nadie tenga dos pestañas.
**Lo que importa:** es el **incidente 14** y es la 💸 que esta fase paga dentro de sí misma. La distinción que hay que llevarse: un dato viejo en pantalla es un problema de **frescura** y se arregla con F5; un dato viejo en un PDF es un problema de **corrección** y no se arregla nunca, porque el archivo ya salió.

**Síntoma:** la aplicación tarda notablemente más en cargar desde que hay certificados, incluso para quien nunca entra a esa sección.
**Causa:** `import { jsPDF } from 'jspdf'` en la cabecera de un archivo que se carga de forma eager.
**Fix mínimo:** moverlo a `await import()` dentro del método que lo usa.
**Lo que importa:** el coste de una dependencia no lo decide su tamaño, lo decide **quién la importa y cuándo**. Es la misma lección de la Fase 5 con `SharedModule`, y que reaparezca cinco fases después con una librería en vez de con un módulo es justo lo que la vuelve transferible.

### Pieza forense de esta fase

**Zona horaria en producción: el certificado que venció ayer para el servidor y hoy para el usuario.**

El ticket llega así, y llega mal: *"a veces el sistema dice que un certificado está vencido y el cliente nos manda una foto del papel donde dice que vence hoy. Pasa sobre todo por la tarde."*

Tres pasos, y el primero descarta la mitad de las hipótesis.

**Paso 1 — El JSON crudo, y sólo el final de la cadena.** Abre la petición a `/certificates` en Network y mira el `validUntil` de la fila que falla. Lo único que importa son los últimos seis caracteres:

- `-05:00` → el dato está bien. El bug está en quien lo lee.
- `Z` o nada → el dato está mal desde que se escribió, y hay que mirar quién lo emitió.

Esa distinción decide si el arreglo va en 5.2 —el cálculo— o en 5.3 —la lectura—, y se toma en diez segundos sin abrir un archivo.

**Paso 2 — La consola, para ver las tres respuestas a la vez.** Con la pantalla abierta:

```js
const validUntil = '2025-02-10T23:59:59-05:00';

new Date(validUntil).toISOString();   // '2025-02-11T04:59:59.000Z' — el MISMO momento
new Date(validUntil).toString();      // el mismo momento, en el huso de TU navegador
toBusinessDay(validUntil);            // '2025-02-10' — el día que ve el negocio
```

Las tres son correctas y las tres dicen cosas distintas, y ahí está todo el bug: alguien eligió una de las tres para decidir, y eligió sin saber que estaba eligiendo.

**Paso 3 — La prueba que lo cierra.** Cambia la zona horaria de tu sistema operativo a **UTC+13** —Auckland— y recarga. Es un experimento de treinta segundos y separa dos mundos:

- Si **ningún** certificado cambia de estado, el cálculo es correcto: la única zona que participa es la del negocio, como manda `business-day.ts`.
- Si alguno cambia, tienes un `new Date()` leyendo con el huso del navegador en algún punto del camino, y el paso 2 te dice en cuál.

> 🧠 **La conclusión que hay que llevarse, y que este curso repite porque es la que se olvida:** nunca es un bug de fechas. `Date` hizo exactamente lo que le pidieron. Es un bug de **no haber decidido a qué hora vence algo**, y por eso el arreglo no es un `+1` ni un `-5`: es una función con nombre, en un archivo, que se llama desde todas partes.

> 📄 El recorrido completo, con los dos tickets literales y la salida de cada paso, en `forense-fase-10.md`.

**🧨 Rompe a propósito**

Dos roturas de una línea.

1. **Cambia `endOfBusinessDay` para que devuelva `` `${day}T23:59:59Z` ``** y recarga la lista. Anota cuál de los dos certificados de la semilla cambia de estado y cuál no, y **calcula durante cuántas horas de cada día la respuesta es incorrecta** —la respuesta es cinco, y saber de dónde salen es haber entendido el archivo—. Después haz el experimento de UTC+13 con esta versión rota y compáralo con el de la versión buena.

2. **Sustituye `view.status` por `view.certificate.status` en la plantilla de la lista.** `CERT-2024-000502` vuelve a decir "Vigente" y no hay ni un error en consola. Deja la pantalla así un minuto y pregúntate cuánto tiempo llevaría alguien mirando esa lista todos los días sin notar nada — y compáralo con el 🧨 de la Fase 9, donde el certificado se emitía indebidamente. Los dos son el mismo error de diseño y sólo uno de los dos se ve.

---

## 🧪 7. Ejercicios (30)

**🟢 Fácil (1–8)**

1. Escribe `endOfBusinessDay` y comprueba que `endOfBusinessDay('2025-02-10')` reproduce carácter por carácter el `validUntil` de `CERT-2024-000502` en la semilla. Después escríbela mal a propósito con `T00:00:00` y anota qué cambia en el estado derivado de ese certificado.
2. Implementa `computeValidity` y córrela contra los dos certificados de la semilla partiendo de sus `issuedAt`. Los dos `validUntil` tienen que salir idénticos a los almacenados. Entrega las dos comparaciones.
3. **Diagnóstico.** Llama a `deriveCertificateStatus` con los dos certificados y `nowInstant()`, y compara con el campo `status` de cada fila. Anota cuál coincide, cuál no, y **en qué fecha exacta empezó a no coincidir**.
4. Implementa `certificateStatusLabel`. Después borra la entrada `expiring` del `Record` y anota el error de compilación exacto. Es el mismo mecanismo que el `severityLabel` de la Fase 9.
5. `computeValidity('2024-02-29T09:00:00-05:00')` tiene que dar el 28 de febrero de 2025. Quita el recorte de `addMonths`, vuelve a correrlo, y explica en dos frases qué hizo `Date` y por qué el certificado duraría un día de más.
6. **Diagnóstico.** Pasa `'2024-03-15T23:30:00-05:00'` por `computeValidity` y anota el día de vencimiento. Después sustituye `toBusinessDay` por `.slice(0, 10)` sobre el instante y vuelve a correrlo. Explica de dónde sale el día de diferencia.
7. Escribe `CertificateApiService` completo y compruébalo con `curl` contra `/certificates`. Confirma que las dos filas traen `revokedAt` y que las dos son `null`.
8. Monta la lista de 5.6 y quita después el aviso de divergencia. Anota qué se pierde: es exactamente lo que un usuario final debería ver y lo que tú, manteniendo el sistema, no.

**🟡 Intermedio (9–17)**

9. Implementa `buildCertificateView` y `views$`, y comprueba que la lista pinta "quedan N días" para uno y "venció hace N días" para el otro. Verifica el signo con `daysBetween` a mano.
10. **Diagnóstico.** Pon `"revokedAt": "2024-06-01T10:00:00-05:00"` en `CERT-2023-000501`, que ya estaba vencido. Anota qué estado deriva. Después invierte las dos primeras comprobaciones de `deriveCertificateStatus`, recarga, y explica en cuatro líneas qué información se pierde en la pantalla y por qué eso importa en una auditoría.
11. Implementa `issue()` y emite el certificado de la inspección `502`. Comprueba en Network que sale un solo `POST`, que el `id` sigue el formato de la semilla y que `validUntil` termina en `-05:00`.
12. **Diagnóstico.** Pulsa "Emitir" dos veces seguidas y rápido sobre la `502`. Describe qué pasa, cuántos `POST` salen y por qué. Después cambia los dos `concatMap` de `issue()` por `switchMap`, repite, y anota la diferencia. Explica cuál de los dos resultados es peor y por qué no es el que parece.
13. **Diagnóstico.** Intenta emitir sobre la `503` tal como viene (`rejected`), después ponla en `completed` y vuelve a intentarlo. Entrega los dos mensajes literales y explica por qué tienen que ser distintos aunque los dos signifiquen "no".
14. 🧬 **Estilo.** Ticket: *"en el listado de inspecciones quiero un enlace al certificado cuando exista"*. El archivo es `InspectionListComponent`, heredado de la Fase 1 y con código vivo dentro. Escribe el fix y justifica en cinco líneas por qué **este** archivo sí se toca en estilo heredado mientras que `CertificateListComponent`, también de la Fase 1, se reemplazó por un standalone. La respuesta no es la fecha del archivo.
15. Implementa `revoke()` y revoca el certificado de la `501`. Comprueba que el estado derivado cambia a `revoked`, que la fila guardada no se toca en su campo `status`, y que intentar revocarlo dos veces da un mensaje de negocio y no un error de red.
16. **Diagnóstico.** Cambia la zona horaria de tu sistema operativo a UTC+13 y recarga con la versión correcta de `endOfBusinessDay`. Anota qué cambia en la pantalla. Después hazlo con la versión rota del 🧨 número 1 y anota qué cambia entonces. Entrega las dos capturas.
17. Escribe `buildCertificateDocument` y genera el PDF del certificado de la `501`. Verifica **mirando el PDF** que los acentos de "Inspección" y "Vigencia" salen bien. Si no salen, anota qué ves exactamente antes de ir a A08 — la forma del defecto es lo que dice qué falta.

**🟠 Difícil (18–24)**

18. **Diagnóstico.** Reproduce el incidente **14** entero con la versión de 5.7: dos pestañas, resolver el hallazgo en una, descargar en la otra. Entrega el PDF viejo y el nuevo, y escribe en cinco líneas por qué este bug no lo detecta ningún test de la pantalla.
19. Paga la deuda: implementa la versión de 5.8 y comprueba que el PDF trae el dato fresco con la pantalla desactualizada detrás. Entrega `git log --oneline` de los dos commits —el que introduce 5.7 y el que lo reemplaza— y explica por qué esta deuda no podía diferirse a la Fase 12.
20. **Diagnóstico.** En `download()`, cambia `getByVersion(inspection.templateId, inspection.templateVersion)` por la plantilla vigente y genera el PDF de la `501`, que es de 2023 y v1. Anota qué cambia en la tabla de hallazgos. Es la cuarta vez que esta línea aparece en el curso: explica por qué aquí el daño es peor que en las tres anteriores.
21. Mide el bundle con `import` estático y con `await import()`, y entrega las dos filas de la tabla de 5.9 más la salida del `grep` sobre `stats.json` en los dos casos. Después escribe la frase con la que rechazarías un pull request que mueve el import a la cabecera.
22. **Diagnóstico.** Encuentra el segundo del día en que un certificado no está ni vigente ni vencido con `endOfBusinessDay` a `23:59:59`. Demuéstralo con una llamada a `isPast` y a `deriveCertificateStatus` con el `now` exacto. Después decide si lo arreglarías con `.999`, con `<=`, o si lo dejarías, y justifica la decisión en cuatro líneas.
23. 🧬 **Estilo.** Llega el ticket *"el certificado debe mostrar el nombre del inspector"*. El dato está en `inspection.inspectorId` y el nombre sólo existe en el token de la Fase 2, que es del usuario conectado y no del que hizo la inspección. Decide qué haces —imprimir el id, no imprimir nada, o inventar un endpoint—, en qué archivo va el cambio y en qué estilo, y escribe la respuesta al ticket. Es un ejercicio de decir que no con argumentos.
24. **Diagnóstico.** Escribe el post-mortem completo de ocho puntos del incidente **15** siguiendo `formato-cuaderno-incidentes.md`, con su par de tags `inc/15/<slug>-roto` / `-fix`. El punto 2 —reproducción— es el difícil: tienes que escribir unos pasos que fallen sólo en una franja horaria concreta, y decir cuál.

**🔴 Muy difícil (25–30)**

25. Escribe el post-mortem completo de ocho puntos del incidente **14**, con su par de tags. El punto 7 —prevención— es el interesante: propón un test que falle con la versión de 5.7 y pase con la de 5.8, y explica por qué tiene que ser un test del servicio y no de la pantalla.
26. Implementa la política completa que la Fase 9 dejó especificada en su ejercicio 24: aparece un hallazgo `critical` en una inspección **ya aprobada**. La inspección no se desaprueba, el certificado se revoca. Impleméntalo de punta a punta —qué lo dispara, qué se le muestra a quien abre esa inspección mañana, y qué le pasa al PDF ya descargado, que es la parte que no tiene solución técnica— y escribe qué le dirías al cliente que tiene el papel viejo en la mano.
27. Implementa la alternativa que la 💸 de 5.3 descarta: un `timer` que reemita `views$` cada minuto para que el estado cambie solo al cruzar la medianoche. Mide qué pasa con `OnPush` y con las suscripciones abiertas, y decide si lo dejarías puesto. Entrega el argumento en cinco líneas, con el número de renders por hora.
28. **Diagnóstico.** Construye el caso completo del `id` duplicado: dos pestañas sobre la misma inspección aprobada, emitir en las dos casi a la vez. Describe qué hace json-server, qué queda en `db.json`, y por qué la comprobación de "ya tiene certificado" de `issue()` no lo impide. Después propón las tres soluciones posibles —cliente, mock, backend real— y di cuál es la única correcta y por qué este curso no la puede implementar.
29. Escribe los tests puros de `computeValidity`, `deriveCertificateStatus` y `buildCertificateDocument` —sin `TestBed`, como los de las Fases 8 y 9—. Cubre al menos: emisión en año bisiesto, emisión a las 23:30 hora local, certificado revocado y vencido a la vez, el borde exacto de `EXPIRING_WINDOW_DAYS`, y un documento con un hallazgo de severidad `null`. Guárdalos: la Fase 12 los va a reclamar.
30. Diseña la vigencia que **no** es una constante: que salga de la plantilla con la que se ejecutó la inspección, para que una norma nueva pueda cambiar la duración sin tocar los certificados ya emitidos. Decide qué campo haría falta, en qué colección, y qué le pasa a los dos certificados de la semilla que se emitieron sin ese campo. Impleméntalo detrás de la misma firma de `computeValidity` —ése es el punto del ejercicio— y explica en cinco líneas por qué el diseño de hoy lo permitía sin romper nada.

**🔥 Opcionales**

- 🔥 **La firma digital, y por qué no es una imagen.** Investiga qué haría falta para que este PDF fuera un documento firmado con validez legal: certificado digital, autoridad certificadora, sellado de tiempo, y dónde tendría que ocurrir eso. Escribe dos párrafos sobre por qué pegar una imagen de una firma es exactamente lo contrario de firmar, y por qué esto no se puede hacer en el navegador.
- 🔥 **El registro nacional que no responde.** El `alcance-del-proyecto.md` §5 menciona un registro nacional simulado que "responde tarde, mal, o no responde". Diseña —sin implementar— qué le pasa a la emisión cuando ese registro no contesta: ¿el certificado se emite y se sincroniza después?, ¿se queda pendiente?, ¿qué ve el usuario? Es la conversación de "consistencia eventual" con un ejemplo que se entiende en treinta segundos.
- 🔥 **Corrige la semilla.** Cambia el `status` de `CERT-2024-000502` a `expired` para que coincida con el cálculo, y cuenta qué se pierde: el ejemplo de divergencia que sostiene los ejercicios 3 y 8 y media sección 6. Después decide si en un sistema real correrías esa migración o dejarías el campo muerto, y por qué.

---

## 📚 8. Referencias

**Documentación oficial**

- https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Date/toISOString — lo que hace y lo que **no**: siempre devuelve UTC, y ahí nace la mitad de los bugs de esta fase.
- https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Date/UTC — la aritmética de calendario de `addMonths` y `daysBetween`.
- https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Intl/DateTimeFormat — lo que haría falta el día que CertCore opere en una zona **con** horario de verano, que es cuando el offset fijo de `business-day.ts` deja de servir. Hoy no hace falta; conviene saber dónde está la puerta.
- https://www.typescriptlang.org/docs/handbook/utility-types.html#excludeuniontype-excludedmembers — el `Exclude` de `DerivedCertificateStatus`. ⚠️ La documentación cubre versiones posteriores a la 5.1.6 del curso; para este tipo no hay diferencia.
- https://v16.angular.io/guide/lazy-loading-ngmodules — el `loadChildren` que la Fase 1 dejó puesto y que hoy carga dos standalone. ⚠️ Cuidado con caer en angular.dev, que documenta el enrutado de la 17 en adelante.
- https://www.typescriptlang.org/docs/handbook/modules/reference.html#import-type — el `import type { jsPDF }` de 5.8, que es lo que permite tipar sin arrastrar la librería.
- https://rxjs.dev/api/index/function/combineLatest y https://rxjs.dev/api/index/function/concatMap — las dos piezas de `download()`.
- https://github.com/parallax/jsPDF — jsPDF 2.5.1. ⚠️ El README cubre la última versión publicada; verifica que los ejemplos que copies existan en la 2.5.
- https://github.com/simonbengtsson/jsPDF-AutoTable — `jspdf-autotable` 3.8.x, la tabla de hallazgos.

**Video / apoyo**

- Cualquier charla sobre *time zones are hard* sirve para la sección 4, y casi todas cuentan los mismos tres chistes. ⚠️ La mayoría se centra en el horario de verano, que es el problema que Colombia **no** tiene; la parte transferible aquí es la otra: decidir a qué hora del día ocurre algo.

**Orden de lectura sugerido:** `toISOString` **antes** de escribir 5.1, si la diferencia entre un instante y un día todavía te suena a lo mismo. El `Exclude` cuando llegues a 5.3 y no antes. jsPDF **sólo cuando el PDF te salga mal**, y entonces por A08, no por el README — y `jspdf-autotable` sólo si la tabla te sale corrida. La página de `Intl.DateTimeFormat` es para después: es la respuesta a una pregunta que este curso no tiene, y leerla antes confunde.

---

## 🚀 9. Cierre y conexión con la siguiente fase

CertCore ya emite documentos, y con eso el sistema cruzó una frontera: hasta hoy todo lo que producía se quedaba dentro y se podía corregir recargando. Un PDF no. Un PDF se descarga, se archiva y se manda por correo, y a partir de ese momento afirma lo que afirmaba el día que se generó, para siempre, sin que nadie pueda actualizarlo.

Debajo de eso hay tres decisiones que la Fase 11 hereda tal cual. **El estado de un certificado se calcula**, y eso es seguro por la misma razón que lo era la severidad de un hallazgo: `validUntil` se escribe una vez y no se reescribe nunca. Con esto, el último dato derivado-pero-guardado que quedaba en la semilla deja de leerse, y `db.json` puede seguir mintiendo tranquilo sin que nadie le haga caso. **La zona horaria vive en un archivo**, `business-day.ts`, que hoy tiene días de calendario e instantes y sigue teniendo una sola constante de offset. Y **un documento se arma desde la fuente**, que costó seis peticiones y media hora de escribir dos veces el mismo servicio.

Lo que te llevas para cualquier proyecto son dos preguntas. Antes de guardar un estado: **¿qué lo cambia?** Si es una acción, guárdalo; si es el paso del tiempo, no lo guardes, porque no hay ningún momento en que alguien vaya a ejecutar el `UPDATE`. Y antes de generar cualquier artefacto que sobreviva a la sesión: **¿de dónde saco el dato?** La pantalla es una foto de hace un rato, y para mirar está bien.

La **Fase 11** toma los estados que hoy quedaron calculados y los cuenta. El dashboard de "por vencer a 30, 60 y 90 días" existe porque `deriveCertificateStatus` existe, y ahí va a aparecer el problema que esta fase deja sembrado y no resuelve: derivar el estado de un certificado cuesta nada, pero derivar los hallazgos de treinta inspecciones cuesta sesenta peticiones —la Fase 9 ya lo avisó— y ahora hay que sumarle un certificado por cada una. La Fase 11 es donde "calcularlo todo cada vez" deja de ser gratis y hay que medirlo.

> **La señal de que quedó bien:** cambias el huso horario de tu máquina, recargas, y no se mueve absolutamente nada en la pantalla.

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-10 -m "F10 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`fase 10: …`) y los de ejercicio su
> número (`fase 10 ej19: …`). Si un ejercicio merece su propio marcador va en
> `ej/f10/19`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva el cuaderno. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
>
> Esta fase es la primera cuya deuda 💸 **nace y muere dentro de ella**, así que
> la factura no se lee entre dos tags: se lee entre dos commits de esta misma
> fase. Haz el commit de 5.7 antes de escribir 5.8 aunque sepas que lo vas a
> reemplazar —`fase 10: PDF armado desde la vista (💸, se paga en el commit
> siguiente)`— y después `git log -p fase-09..fase-10 -- src/app/features/certificates/certificate-pdf.service.ts`
> te enseña el arreglo entero aislado. Es la única forma de que el incidente 14
> tenga dónde reproducirse: su rama `inc/14/…-roto` sale del **primero** de esos
> dos commits, no del tag. Y ojo con `db.json`: esta fase **emite y revoca**, así
> que ya hay filas en `certificates` que la Fase 3 no sembró. Decide si lo
> commiteas o lo devuelves con `npm run seed` antes de etiquetar.

---

## 📌 Pendientes sugeridos

- **`validFrom` no existe como campo y la vigencia se calcula, y eso conviene que quede escrito donde alguien lo busque.** El alcance de esta fase pedía "`validFrom` y `validUntil` con offset"; el modelo congelado del `alcance-del-proyecto.md` §5.1 sólo tiene `issuedAt` y `validUntil`. La salida fue `CertificateValidity.from = issuedAt`, sin tocar la semilla, coherente con la política de la Fase 9 de no añadir campos. → **Decisión de proyecto tomada en este chat**, y candidata a nota en el §5.1 del alcance para que ninguna fase futura vuelva a buscar el campo.
- **`issued` es un estado que la derivación no produce y que sí se escribe.** Está resuelto con `Exclude` y documentado en 5.3 y 5.5, pero el flujo `issued → valid → expiring → expired | revoked` del alcance §5 ya no describe lo que hace el código: describe lo que se guarda. → **Aviso para una eventual segunda pasada del `alcance-del-proyecto.md`**: o el diagrama se anota, o se explica que el primer estado es de escritura y los otros cuatro de lectura.
- **El umbral de `expiring` queda fijado en 30 días y la Fase 11 lo hereda.** La decisión —un estado con un umbral, y 30/60/90 como cubos de informe— está justificada en 5.3, pero si la Fase 11 decide otra cosa hay que volver aquí. → **Aviso para el chat de la Fase 11**, y es la primera constante de este curso que una fase posterior podría querer discutir.
- **El `id` del certificado lo compone el cliente, y con dos pestañas se duplica.** Está marcado con ⚠️ en 5.5 y trabajado en el ejercicio 28, y deliberadamente **no** se marcó como 💸 para no acumular tres deudas en una fase de 8h. La solución correcta es de backend y este curso no lo tiene. → **Decisión de proyecto**: o se acepta como límite conocido del mock, o entra en el apéndice de auditoría que ya piden tres fases.
- **La revocación no registra motivo ni autor.** `revokedAt` guarda cuándo y nada más. Es la cuarta fase que señala que la trazabilidad no tiene dueño —la 6, la 9 dos veces, y ésta—, y ahora ya no es un detalle: hay un documento oficial que alguien anuló y no se sabe quién. → **Decisión de proyecto, y ya urgente**: o entra el apéndice 🔥 de auditoría, o se retira la promesa de "todo lo relevante deja rastro" del alcance §5.
- **El PDF ya descargado no se puede revocar.** El ejercicio 26 lo plantea y no tiene solución técnica: el archivo está en el disco de alguien. Es la mejor conversación de todo el curso sobre los límites de lo que un sistema puede garantizar, y cabe en media página. → **Candidato a párrafo fijo en A08** o a cierre del track forense.
- **Los seis `getById` de `download()` piden datos que casi siempre ya están en memoria.** Es correcto y es lento, y la justificación —"es una acción del usuario, no un render"— aguanta hoy y no aguanta si alguien pide "descargar los 40 certificados del mes". → **Aviso para el chat de la Fase 11**, que es donde el volumen deja de ser hipotético.
- 🔥 **Un diagrama de la línea de tiempo de un certificado** —emisión, ventana de `expiring`, vencimiento, y el punto donde una revocación puede caer en cualquiera de los tres— explicaría 5.3 mejor que sus cuatro líneas de código. Es el octavo pendiente de ilustración del curso. Pendiente de dibujo, no de contenido.

### Reservas para el cuaderno de incidentes

Los enunciados ya están escritos en el índice de [`cuaderno-incidentes.md`](cuaderno-incidentes.md), que es donde viven; acá queda constancia de qué fase los produce. **El ID no se reasigna nunca.**

| ID | Título | Categoría | Dif. |
|---|---|---|---|
| 14 | "Descargué el certificado y la tabla de hallazgos no dice lo mismo que la pantalla" | Trazabilidad | 🟠 |
| 15 | "El certificado venció ayer para el sistema y hoy para el cliente, y sólo pasa por la tarde" | Tiempo | 🔴 |
