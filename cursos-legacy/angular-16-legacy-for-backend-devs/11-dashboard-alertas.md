# 📊 Fase 11 — Dashboard y alertas

> Tutorial Angular 16 — Inspecciones y certificaciones · Fase 11 de 14 · **6 horas**
> Depende de: Fase 10 (certificados y vigencia) · Habilita: Fase 12
> Apéndices de apoyo: [A06 (RxJS 7)](a06-rxjs.md) · [A07 (Estado con servicios)](a07-estado-servicios.md)
> [Incidentes asociados](cuaderno-incidentes.md): 16
> Estilo de esta fase: **nuevo**, con una costura 🧬 hacia el `DashboardModule` heredado — y esta vez el heredado es el **padre**

---

## 🎯 1. Propósito

Diez fases construyendo pantallas donde alguien mira **una** cosa: una inspección, una plantilla, un certificado. Hoy llega la pantalla de quien mira **todas a la vez**, que es una persona distinta con una pregunta distinta: no *"¿cómo está esta inspección?"* sino *"¿qué se me está incendiando?"*.

Esa diferencia tiene una consecuencia técnica inmediata. Hasta ahora, cada pantalla pedía lo suyo y lo pintaba. El panel no pide nada nuevo: **deriva** de lo que los cuatro servicios de estado ya tienen en memoria. No hay un `DashboardStateService`, no hay una colección de KPI en el mock, no hay nada que se guarde. Es la última prueba de que el patrón de la Fase 4 aguantó — y es donde por primera vez el costo de recalcular deja de ser gratis.

Y trae la pregunta que este curso ha estado esquivando: **¿cuándo hay que culpar a `ChangeDetectionStrategy`?** La respuesta corta es "casi nunca", y la larga ocupa la sección 6. Porque cuando un panel va lento, el `OnPush` es lo primero que todo el mundo toca y casi nunca es el culpable: el culpable suele ser una suscripción que no murió, un gráfico que se redibuja entero, o doscientas iteraciones que se rehacen sesenta veces por minuto sin que nadie lo pidiera.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `npm run seed:demo` genera un `db.json` con volumen y **fechas relativas a hoy**, y `git status` muestra que `mock/db.seed.json` **no cambió ni un byte**.
- [ ] `/dashboard` pinta cuatro tarjetas de KPI, el panel de certificados por vencer a 30/60/90 días, la lista de activos sin cobertura, y dos gráficos.
- [ ] Los hallazgos del panel **coinciden** con los que muestra el detalle de cada inspección. Si no coinciden, alguien leyó la colección `findings` en vez de derivarlos.
- [ ] Con doscientas inspecciones, el panel hace **cinco** peticiones al abrirse y cinco por minuto — no cuatrocientas. Lo compruebas en Network.
- [ ] Sales del panel a `/clients`, esperas cinco minutos, y en Network **no sale nada**. Si sigue pidiendo, tienes el incidente 16.
- [ ] `DEMO_INSPECTIONS=2000 npm run seed:demo` y el panel se arrastra. Sabes decir con un número **dónde** se arrastra, y no es en la detección de cambios.
- [ ] Tienes en `deuda.md` tres cifras nuevas: el peso de Chart.js en el bundle inicial, el tiempo de `buildMetrics` con 200 y con 2000 registros, y el peso de un autosave de la Fase 8 con una plantilla larga.
- [ ] `git tag` lista `fase-11`.

---

## 🚫 3. Qué NO entra todavía

- **BI de verdad** —cubos, dimensiones, drill-down, comparativas entre periodos— → fuera de alcance. Esto es un panel operativo: cuatro preguntas y un enlace a la pantalla donde se resuelven.
- **Exportación a Excel** → fuera de alcance, y es la ampliación más pedida de cualquier dashboard. El ejercicio 🔥 la diseña; la regla que hereda es la de la Fase 10 —*todo lo que sale del sistema se reconstruye desde la fuente*— y por eso no es tan barata como parece.
- **Filtros persistidos por usuario** → fuera de alcance. Sin trazabilidad ni preferencias en el modelo, persistir un filtro es inventar una entidad nueva.
- **Alertas por correo o notificaciones** → fuera de alcance desde la Fase 9, y por la misma razón: exigen un canal que CertCore no tiene. Aquí "alerta" significa que el número está en rojo en la pantalla.
- **El comparador de dos versiones de plantilla** → se queda donde está, como ejercicio 🔥 de la **Fase 7**. Es una pantalla de plantillas, no un panel, y meterla aquí sería inflar la fase con material de otra.
- **Agregar en el servidor** → es la 💸 de esta fase y **no se paga**, porque json-server no agrega. Lo que sí entra es el número que dice a partir de cuándo eso deja de ser aceptable.

---

## 🧠 4. Concepto mínimo

### El problema, antes que la herramienta

El panel necesita cuatro respuestas: cuántos certificados vencen en los próximos treinta, sesenta y noventa días; qué inspector acumula más rechazos; qué ítem del checklist genera más hallazgos; y qué activos están sin cobertura vigente.

Ninguna de las cuatro existe en el backend. No hay `/dashboard`, no hay `/stats`, no hay una colección `metrics`. Y no la va a haber: json-server sirve colecciones y ya. Así que las cuatro respuestas se calculan **en el cliente**, sobre lo que ya está cargado.

Eso no es un apaño del curso: es lo que hace la mitad de los paneles internos del mundo, y funciona perfectamente hasta un volumen concreto. Lo que separa a quien lo hace bien de quien produce el ticket *"el panel va lento"* es saber **cuál es ese volumen**, y haberlo medido antes de que lo mida un usuario.

### 🩻 Esto sí funciona igual que en tu backend

Si vienes de escribir consultas, buena parte de esto te va a resultar familiar y conviene decir dónde el paralelo aguanta.

Agrupar por inspector es un `GROUP BY`. Contar hallazgos por ítem es un `GROUP BY` con `COUNT`. Filtrar certificados por ventana de vencimiento es un `WHERE` con aritmética de fechas. Todo eso lo escribes en TypeScript con `Map`, `filter` y `reduce`, y el razonamiento es el mismo que llevas años haciendo.

Donde el paralelo se rompe es en dos sitios. El primero: **tu base de datos tiene índices y tú no**. Un `GROUP BY` sobre doscientas mil filas es instantáneo en Postgres y es imposible en el navegador, porque en el navegador ni siquiera caben. El segundo, y es el que produce bugs: **tu consulta corre una vez y esto corre cada vez que algo emite**. Un `combineLatest` de cinco fuentes recalcula el panel entero cuando cualquiera de las cinco cambia, y si una de ellas emite por cada tecla que alguien pulsa en otra pantalla, acabas de escribir un `GROUP BY` dentro de un bucle.

> 🧭 **Regla del proyecto: en el cliente, agregar es barato y agregar seguido es caro.** El número que importa no es cuánto tarda el cálculo, es cuántas veces por minuto ocurre.

### Derivar sin duplicar, por cuarta vez

Este curso lleva tres fases repitiendo la misma decisión y ésta es la cuarta, así que ya se puede enunciar como regla:

- La Fase 7 no guardó `resolveForDay()`: la versión vigente se calcula, no se almacena.
- La Fase 9 no guardó los hallazgos derivados: la severidad se calcula desde la respuesta y la plantilla congelada.
- La Fase 10 dejó de leer el `status` del certificado: el estado se calcula contra el reloj.
- La Fase 11 no guarda ni un KPI.

En los cuatro casos la tentación era la misma —*"lo guardo y así no hay que recalcularlo"*— y en los cuatro el precio habría sido el mismo: dos fuentes de verdad para el mismo dato, desincronizándose en silencio. Aquí es especialmente evidente porque un KPI guardado **no tiene ninguna forma de saber cuándo caducó**: nada lo invalida, nada lo recalcula, y el número sigue ahí, redondo y falso.

Por eso el servicio de esta fase se llama `DashboardMetricsService` y **no** `DashboardStateService`. La convención de nombres de la guía dice que el sufijo `StateService` es para lo que *guarda*, y esto no guarda nada. No es una preferencia estética: es lo que evita que alguien meta un `BehaviorSubject` ahí dentro dentro de tres meses porque "así carga más rápido".

### El atajo barato que produce dos verdades

Hay una tentación específica de esta fase y merece verse antes de escribir código, porque en un proyecto real la comete alguien con buenas intenciones.

El panel necesita contar hallazgos. En `db.json` hay una colección `findings` con cuatro filas y una petición la trae entera. Derivarlos, en cambio, exige tener las plantillas y recorrer todas las respuestas. **Leer la colección es diez veces más simple y está mal**, porque la Fase 9 dejó decidido que el `severity` guardado es historia: dos de las cuatro filas de la semilla ya no coinciden con lo que la derivación calcula hoy.

Un panel que lee la tabla y un detalle que deriva producen **dos verdades sobre la misma inspección**, y el ticket que sale de ahí —*"el panel dice tres críticos y la inspección dice dos"*— es de los que se tardan dos días en cerrar, porque los dos números son correctos según quien los mire.

La salida no es elegir entre "barato" y "correcto". Es darse cuenta de que **derivar puede ser barato si se hace bien**: `deriveFindings` es una función pura que recibe una plantilla, así que si cargas las plantillas **una vez** y las indexas en un `Map`, doscientas inspecciones se derivan en memoria sin una sola petición extra. Dos peticiones en vez de cuatrocientas, y la verdad intacta. Eso es exactamente lo que el 5.3 hace, y es el pago de haber escrito todo puro desde la Fase 7.

### `OnPush` y a quién culpar

`ChangeDetectionStrategy.OnPush` le dice a Angular que un componente sólo hace falta revisarlo cuando cambia una de sus `@Input()` por referencia, cuando emite un evento desde su plantilla, o cuando un `async` pipe suyo recibe algo. Con `Default`, se revisa en cada ciclo, y un ciclo se dispara con cada clic, cada petición HTTP que termina y cada `setTimeout`.

Aquí hay una restricción que este proyecto no puede esquivar y conviene decirla ya: **`DashboardHomeComponent` es heredado** —lo declaró la Fase 1, la Fase 5 lo congeló *"ni hoy ni en el resto del curso"*— así que es `Default`, y va a ser el **padre** de todo lo que escribas hoy.

Eso importa menos de lo que parece, y merece entenderse bien porque es la fuente de la mitad de las supersticiones sobre `OnPush`. Que el padre sea `Default` significa que **el padre** se revisa en cada ciclo. No significa que los hijos también: un hijo `OnPush` se salta la revisión aunque su padre se revise, siempre que sus entradas no hayan cambiado por referencia. El árbol no se "contagia" hacia abajo.

Lo que sí se contagia —y es lo que confunde a todo el mundo— va hacia arriba: si un hijo `OnPush` se marca a sí mismo para revisión, Angular marca también a todos sus ancestros hasta la raíz. Por eso un panel con quince hijos `OnPush` colgando de un padre `Default` sigue siendo mucho más barato que el mismo panel todo en `Default`, y por eso `OnPush` casi nunca es la causa de que algo vaya lento.

> 🧭 **Antes de tocar `ChangeDetectionStrategy`, mide.** El culpable de un panel lento es, por orden de frecuencia: una suscripción que no murió, un array nuevo en cada emisión donde bastaba el mismo, un gráfico que se redibuja entero, y sólo entonces la detección de cambios. Cambiar a `OnPush` un componente cuyo problema es una fuga es cómo se pierde una tarde.

> 📝 **Nota de migración.** `OnPush` es de Angular 2 y no ha cambiado desde entonces, pero lo que lo rodea sí: el `async` pipe, que es lo que lo hace usable, marca el componente automáticamente al emitir, y sin él habría que llamar a `ChangeDetectorRef.markForCheck()` a mano — que es lo que hace el código de 2021 de este mismo sistema en dos sitios. Y a partir de Angular 17 aparece la alternativa de verdad, las signals, donde la granularidad deja de ser el componente y pasa a ser el valor. CertCore no las usa: en la 16 son experimentales, se leen y no se escriben. La **Fase 12** las mira de cerca y **A11** las proyecta.

---

## 💻 5. Código mínimo con comentarios

### 5.1 El volumen, sin tocar la semilla

Hay un problema práctico antes de escribir una línea de Angular: con dos certificados —los dos vencidos desde la Fase 10— el panel de "por vencer a 30/60/90 días" no tiene absolutamente nada que enseñar.

La tentación es ampliar `db.seed.json`. **No se hace**, y por dos razones que ya están escritas en el curso. La primera: ocho fases construyeron encima de esas filas, y mover el escenario canónico rompe enunciados de ejercicios, pruebas de fuego y los fixtures que la Fase 12 va a reclamar. La segunda: si añades certificados con fechas fijas, se pudren —el 📌 de la Fase 10 lo dejó dicho— y si las pones relativas a hoy, pierdes lo que el ejercicio 23 de la Fase 3 te hizo argumentar: reproducibilidad, `git diff` legible y enunciados que sigan teniendo sentido dentro de seis meses.

La salida es separar las dos cosas que estábamos metiendo en un solo archivo: **el escenario canónico es fijo, versionado y pequeño; el volumen de demostración es relativo, desechable y generado.**

```json
// package.json — el script que se añade
{
  "scripts": {
    "seed": "node mock/seed.js",
    "seed:demo": "node mock/demo.js"
  }
}
```

```js
// mock/demo.js
const fs = require('fs');
const path = require('path');

// Cuántas inspecciones se generan. Doscientas es donde el panel se ve bien;
// `DEMO_INSPECTIONS=2000 npm run seed:demo` es donde empieza a doler, y esa
// diferencia es el incidente 16.
const INSPECTION_COUNT = Number(process.env['DEMO_INSPECTIONS'] ?? 200);

// La zona del negocio, la misma de `business-day.ts`. Aquí es un literal y no
// un import porque esto es Node y aquello es la aplicación: son dos procesos
// distintos y no comparten módulos. Es la única duplicación aceptable de este
// valor en todo el proyecto, y va comentada para que nadie la "arregle"
// borrando la de la aplicación.
const OFFSET = '-05:00';

/**
 * Generador pseudoaleatorio con semilla fija. Es deliberado: dos ejecuciones
 * del mismo día producen exactamente los mismos datos, así que "en mi máquina
 * tarda 40 ms y en la tuya 300" es una diferencia de máquina y no de datos.
 * Un Math.random() haría irreproducible cualquier medición de esta fase.
 */
let state = 42;
const nextRandom = () => {
  state = (state * 1103515245 + 12345) % 2147483648;
  return state / 2147483648;
};

const pick = (values) => values[Math.floor(nextRandom() * values.length)];

/** Un día de calendario desplazado desde hoy. Negativo = pasado. */
const dayFromToday = (delta) => {
  const today = new Date();
  const shifted = new Date(
    Date.UTC(today.getUTCFullYear(), today.getUTCMonth(), today.getUTCDate() + delta),
  );

  return shifted.toISOString().slice(0, 10);
};

const seed = JSON.parse(fs.readFileSync(path.join(__dirname, 'db.seed.json'), 'utf8'));

// Los activos generados usan tipos que SÍ tienen plantilla y tipos que NO.
// Los segundos producen activos que nunca se certificaron, que es uno de los
// tres casos de la lista de cobertura y el más fácil de olvidar al sembrar.
const demoAssets = Array.from({ length: 40 }, (_, index) => ({
  id: `DEMO-${String(index + 1).padStart(3, '0')}`,
  clientId: pick([1, 2, 3]),
  type: pick(['elevator', 'elevator', 'boiler', 'tank', 'fire_system']),
  description: `Activo de demostración ${index + 1}`,
  installedAt: dayFromToday(-pick([400, 900, 1800, 3000])),
}));

const demoInspections = [];
const demoCertificates = [];

for (let index = 0; index < INSPECTION_COUNT; index += 1) {
  // Los ids arrancan en 600 para no chocar con las inspecciones canónicas
  // 500-504, que se quedan exactamente como estaban.
  const id = 600 + index;
  const asset = pick(demoAssets.filter((candidate) => candidate.type !== 'tank'));
  const templateId = asset.type === 'boiler' ? 'boiler-annual' : 'elevator-annual';
  const startedDay = dayFromToday(-Math.floor(nextRandom() * 500));
  const status = pick(['approved', 'approved', 'approved', 'rejected', 'completed', 'in_progress']);
  const template = seed.templates.find(
    (candidate) => candidate.templateId === templateId && candidate.validFrom <= startedDay,
  );

  demoInspections.push({
    id,
    assetId: asset.id,
    inspectorId: pick(['INS-15', 'INS-22', 'INS-31', 'INS-44']),
    templateId,
    templateVersion: template.version,
    status,
    startedAt: `${startedDay}T09:00:00${OFFSET}`,
    completedAt: status === 'in_progress' ? null : `${startedDay}T12:00:00${OFFSET}`,
    // Las respuestas se reparten entre los criterios del ítem, así que los
    // hallazgos DERIVADOS salen solos y con severidades variadas. No se
    // generan filas en `findings`: la Fase 9 decidió que la severidad se
    // deriva, y sembrar hallazgos aquí sería volver a tener dos verdades.
    answers: template.items.map((item) => ({
      itemId: item.id,
      answer: pick(item.criteria),
      evidenceUrl: item.photoRequired ? `assets/evidence/${id}-${item.id}.jpg` : null,
      note: null,
    })),
  });

  // Sólo las aprobadas tienen certificado, y sus vigencias se reparten a
  // propósito entre las cuatro ventanas del panel: vencidas, dentro de 30,
  // dentro de 60-90, y más allá. Relativas a HOY, así que el panel enseña algo
  // el día que corras esto y también dentro de dos años.
  if (status === 'approved') {
    const validUntilDay = dayFromToday(pick([-200, -40, 12, 25, 45, 75, 200, 320]));

    demoCertificates.push({
      id: `CERT-${startedDay.slice(0, 4)}-${String(id).padStart(6, '0')}`,
      inspectionId: id,
      issuedAt: `${startedDay}T15:00:00${OFFSET}`,
      validUntil: `${validUntilDay}T23:59:59${OFFSET}`,
      // El campo almacenado que la Fase 10 dejó de leer. Se escribe 'issued'
      // en todos a propósito: si el panel alguna vez volviera a leerlo, se
      // vería tan mal que no habría duda.
      status: 'issued',
      revokedAt: null,
    });
  }
}

const demo = {
  ...seed,
  assets: [...seed.assets, ...demoAssets],
  inspections: [...seed.inspections, ...demoInspections],
  certificates: [...seed.certificates, ...demoCertificates],
};

fs.writeFileSync(path.join(__dirname, 'db.json'), `${JSON.stringify(demo, null, 2)}\n`);

console.log(
  `db.json generado con ${demo.inspections.length} inspecciones y ${demo.certificates.length} certificados.`,
);
```

**Detalles con intención**

- **`db.seed.json` no se toca, y `git status` es la prueba.** Es el ejercicio 2 y no es ceremonia: el día que alguien amplíe la semilla "sólo un poco", el enunciado del incidente 08 de la Fase 7 deja de tener sentido.
- **La semilla se lee y se extiende, no se sustituye.** Las inspecciones 500-504 y sus hallazgos siguen ahí, con los mismos ids, así que todo lo que las nueve fases anteriores te hicieron comprobar sigue comprobándose igual sobre un `db.json` con volumen.
- **No se generan filas en `findings`.** Es la decisión de la Fase 9 llevada hasta el final: sembrar hallazgos con severidad escrita sería reintroducir la segunda verdad que esta fase tiene que evitar. Las cuatro filas canónicas se quedan porque son historia, y su divergencia con lo derivado es material del ejercicio 9.
- **La semilla del generador es fija.** Sin eso, medir el rendimiento en dos ejecuciones no significa nada.

**Prueba de fuego**

Corre `npm run seed:demo` y comprueba tres cosas: `git status` no menciona `mock/db.seed.json`; `db.json` sigue teniendo las inspecciones 500 a 504 con sus respuestas exactas; y `/certificates` muestra certificados en las cuatro ventanas. Ahora corre `npm run seed` a secas y comprueba que vuelves al escenario canónico de cinco inspecciones. Los dos comandos coexisten y hacen cosas distintas a propósito.

### 5.2 Las cuatro agregaciones, puras

```ts
// src/app/core/domain/dashboard-metrics.ts
import { Asset } from '../models/asset.model';
import { Certificate } from '../models/certificate.model';
import { ChecklistTemplate } from '../models/checklist-template.model';
import { Inspection } from '../models/inspection.model';
import { BusinessInstant, toBusinessDay } from '../time/business-day';
import {
  CERTIFICATE_EXPIRING_DAYS,
  certificateStatus,
  daysUntilExpiry,
} from './certificate-status';
import { InspectionFinding } from './inspection-findings';

/**
 * Las ventanas del panel. Ojo con lo que NO es: sólo `in30` coincide con un
 * estado del dominio —el `expiring` que la Fase 10 definió con
 * CERTIFICATE_EXPIRING_DAYS—. Las de 60 y 90 son ventanas de REPORTE: un
 * certificado a 75 días está `valid` y el panel lo agrupa aparte porque a
 * alguien le sirve verlo, no porque el sistema lo considere distinto.
 *
 * Confundir las dos cosas produce tres constantes de umbral en tres archivos y
 * un día en que sólo se cambia una. Por eso aquí hay UNA constante importada y
 * dos multiplicadores locales, y no tres números sueltos.
 */
export type ExpiryWindow = 'revoked' | 'expired' | 'in30' | 'in60' | 'in90' | 'later';

export type ExpiryBuckets = Readonly<Record<ExpiryWindow, readonly Certificate[]>>;

export function bucketCertificates(
  certificates: readonly Certificate[],
  now: BusinessInstant,
): ExpiryBuckets {
  const buckets: Record<ExpiryWindow, Certificate[]> = {
    revoked: [],
    expired: [],
    in30: [],
    in60: [],
    in90: [],
    later: [],
  };

  for (const certificate of certificates) {
    // El estado se calcula, nunca se lee del campo. Fase 10.
    const status = certificateStatus(certificate, now);

    if (status === 'revoked' || status === 'expired') {
      buckets[status].push(certificate);
      continue;
    }

    const days = daysUntilExpiry(certificate, now);

    // Los límites son INCLUSIVE por arriba: un certificado a treinta días
    // clavados está en la ventana de treinta, no en la de sesenta. Es la misma
    // decisión que tomó `appliesOn` de la Fase 7 con las fechas de plantilla, y
    // se toma igual por la misma razón: quien lee "vence en 30 días" espera
    // verlo ahí, no en el cajón siguiente.
    if (days <= CERTIFICATE_EXPIRING_DAYS) {
      buckets.in30.push(certificate);
    } else if (days <= CERTIFICATE_EXPIRING_DAYS * 2) {
      buckets.in60.push(certificate);
    } else if (days <= CERTIFICATE_EXPIRING_DAYS * 3) {
      buckets.in90.push(certificate);
    } else {
      buckets.later.push(certificate);
    }
  }

  return buckets;
}

/**
 * Tasa de rechazo por inspector.
 *
 * `rate` es `number | null` y el `null` no es pereza: significa "este inspector
 * no tiene ninguna inspección decidida todavía", que es distinto de "su tasa es
 * cero". Es la misma distinción de la Fase 9, y aquí tiene consecuencias
 * visibles: un inspector nuevo con cero decisiones NO puede aparecer con un
 * 0 % impecable en el panel que su jefe mira.
 */
export interface InspectorRate {
  readonly inspectorId: string;
  /** Aprobadas + rechazadas. Las que siguen en curso no cuentan. */
  readonly decided: number;
  readonly rejected: number;
  /** Entre 0 y 1, o `null` si `decided` es 0. */
  readonly rate: number | null;
}

export function rejectionByInspector(
  inspections: readonly Inspection[],
): readonly InspectorRate[] {
  const counters = new Map<string, { decided: number; rejected: number }>();

  for (const inspection of inspections) {
    if (inspection.status !== 'approved' && inspection.status !== 'rejected') {
      continue;
    }

    const current = counters.get(inspection.inspectorId) ?? { decided: 0, rejected: 0 };

    counters.set(inspection.inspectorId, {
      decided: current.decided + 1,
      rejected: current.rejected + (inspection.status === 'rejected' ? 1 : 0),
    });
  }

  return [...counters.entries()]
    .map(([inspectorId, { decided, rejected }]) => ({
      inspectorId,
      decided,
      rejected,
      rate: decided === 0 ? null : rejected / decided,
    }))
    // Se ordena por tasa descendente, pero con el denominador a la vista: un
    // 100 % sobre una sola inspección arriba del todo es el error de panel más
    // común que existe, y la pantalla lo desactiva mostrando `decided`.
    .sort((a, b) => (b.rate ?? -1) - (a.rate ?? -1));
}

/** Los ítems del checklist que más hallazgos generan. */
export interface FindingCount {
  readonly itemId: string;
  readonly title: string;
  readonly total: number;
  readonly critical: number;
}

export function topFindingItems(
  findings: readonly InspectionFinding[],
  templates: readonly ChecklistTemplate[],
  limit: number,
): readonly FindingCount[] {
  // Los títulos salen de cualquier versión que tenga ese ítem: para contar,
  // "cable principal" es el mismo ítem en la v1 y en la v2 aunque el título
  // cambiara. Es la única lectura del panel que cruza versiones a propósito, y
  // por eso lleva este comentario: no contradice el invariante de la Fase 7,
  // porque no está renderizando una inspección, está agrupando un conteo.
  const titleByItemId = new Map<string, string>();

  for (const template of templates) {
    for (const item of template.items) {
      titleByItemId.set(item.id, item.title);
    }
  }

  const counters = new Map<string, { total: number; critical: number }>();

  for (const finding of findings) {
    const current = counters.get(finding.itemId) ?? { total: 0, critical: 0 };

    counters.set(finding.itemId, {
      total: current.total + 1,
      // La unión discriminada de la Fase 9 vuelve a pagar: los hallazgos sin
      // severidad —ítem retirado, criterio desconocido— cuentan en `total` y
      // no en `critical`, sin un solo `?? 'minor'` de por medio.
      critical: current.critical + (finding.kind === 'item' && finding.severity === 'critical' ? 1 : 0),
    });
  }

  return [...counters.entries()]
    .map(([itemId, { total, critical }]) => ({
      itemId,
      title: titleByItemId.get(itemId) ?? itemId,
      total,
      critical,
    }))
    .sort((a, b) => b.critical - a.critical || b.total - a.total)
    .slice(0, limit);
}

/**
 * Activos sin cobertura vigente. Tres casos y no un booleano, porque "nunca se
 * certificó" y "se le venció en marzo" son dos conversaciones distintas con el
 * cliente, y la lista tiene que poder tenerlas las dos.
 */
export type AssetCoverage =
  | { readonly kind: 'never-certified'; readonly asset: Asset }
  | {
      readonly kind: 'expired';
      readonly asset: Asset;
      readonly certificate: Certificate;
      readonly daysOverdue: number;
    }
  | { readonly kind: 'revoked'; readonly asset: Asset; readonly certificate: Certificate };

export function assetsWithoutCoverage(
  assets: readonly Asset[],
  inspections: readonly Inspection[],
  certificates: readonly Certificate[],
  now: BusinessInstant,
): readonly AssetCoverage[] {
  // Un certificado apunta a una inspección, no a un activo: el puente lo pone
  // la inspección. Es la única forma de saber de qué activo es un certificado,
  // y por eso este parámetro está aquí aunque el resultado no lo mencione.
  const assetIdByInspectionId = new Map(
    inspections.map((inspection) => [inspection.id, inspection.assetId]),
  );

  const latestByAssetId = new Map<string, Certificate>();

  for (const certificate of certificates) {
    const assetId = assetIdByInspectionId.get(certificate.inspectionId);

    if (assetId === undefined) {
      // Un certificado cuya inspección no existe es un dato roto, no un activo
      // sin cobertura. Se ignora aquí y se cuenta aparte en el ejercicio 22.
      continue;
    }

    const current = latestByAssetId.get(assetId);

    if (current === undefined || current.validUntil < certificate.validUntil) {
      // Comparación de cadenas ISO: con offset fijo y el mismo formato, el
      // orden lexicográfico coincide con el cronológico. Con offsets mezclados
      // no coincidiría, y ése es el ejercicio 24.
      latestByAssetId.set(assetId, certificate);
    }
  }

  const result: AssetCoverage[] = [];

  for (const asset of assets) {
    const latest = latestByAssetId.get(asset.id);

    if (latest === undefined) {
      result.push({ kind: 'never-certified', asset });
      continue;
    }

    const status = certificateStatus(latest, now);

    if (status === 'revoked') {
      result.push({ kind: 'revoked', asset, certificate: latest });
    } else if (status === 'expired') {
      result.push({
        kind: 'expired',
        asset,
        certificate: latest,
        // Negativo al revés: `daysUntilExpiry` de un vencido es negativo, y lo
        // que la pantalla quiere decir es "lleva 40 días vencido".
        daysOverdue: -daysUntilExpiry(latest, now),
      });
    }
  }

  return result;
}

/** Todo lo que el panel necesita, en un solo objeto y sin un Observable dentro. */
export interface DashboardMetrics {
  readonly generatedAt: BusinessInstant;
  readonly buckets: ExpiryBuckets;
  readonly inspectorRates: readonly InspectorRate[];
  readonly topFindings: readonly FindingCount[];
  readonly coverage: readonly AssetCoverage[];
  readonly openCriticalCount: number;
  readonly inProgressCount: number;
}
```

**Detalles con intención**

- **Las cuatro funciones reciben el `now` en vez de leer el reloj**, igual que `certificateStatus` de la Fase 10. Es lo que permite que la Fase 12 las teste con una tabla y que el ejercicio 26 no necesite congelar el tiempo.
- **`CERTIFICATE_EXPIRING_DAYS * 2` y `* 3` en vez de `60` y `90`.** Si mañana el negocio pasa a avisar con quince días, las tres ventanas se mueven juntas. Escribir los tres números sueltos es cómo nace la constante duplicada que el propio prompt de esta fase avisaba de evitar.
- **`rate: number | null`, y el `null` sube arriba con un `-1` en el `sort`.** Un inspector sin decisiones no encabeza la lista de rechazos; el `?? -1` lo manda al final a propósito.

**El patrón a memorizar**

> Un KPI es una función pura de una colección y un instante. En cuanto necesita inyectar algo, pedirlo o recordar lo de antes, deja de poderse probar y empieza a discrepar de la pantalla de detalle.

### 5.3 ⭐ Dos peticiones en vez de cuatrocientas

```ts
// src/app/core/domain/derive-all-findings.ts
import { buildTemplateRowId } from '../api/template-api.service';
import { ChecklistTemplate } from '../models/checklist-template.model';
import { Finding } from '../models/finding.model';
import { Inspection } from '../models/inspection.model';
import { InspectionFinding, deriveFindings } from './inspection-findings';

/**
 * ⭐ La pieza que hace posible el panel.
 *
 * `InspectionStateService.findingsOf()` —de la Fase 9— hace DOS peticiones por
 * inspección: una para la versión de plantilla congelada y otra para los
 * hallazgos guardados. Para una pantalla de detalle es perfecto. Para un panel
 * con doscientas inspecciones son cuatrocientas peticiones y un backend
 * llorando.
 *
 * Aquí se hace lo mismo sin una sola petición extra: las plantillas ya están
 * cargadas en `TemplateStateService` desde la Fase 7, los hallazgos guardados
 * se piden una vez, y `deriveFindings` es PURA — así que llamarla doscientas
 * veces es un bucle, no una tormenta de red.
 *
 * Ése es el pago de haber escrito el dominio sin inyecciones desde la Fase 7.
 * Una `deriveFindings` que hubiera inyectado el `HttpClient` "para conseguir la
 * plantilla ella misma" haría este archivo imposible.
 */
export interface InspectionWithFindings {
  readonly inspection: Inspection;
  readonly findings: readonly InspectionFinding[];
}

export function deriveAllFindings(
  inspections: readonly Inspection[],
  versions: readonly ChecklistTemplate[],
  stored: readonly Finding[],
): readonly InspectionWithFindings[] {
  // La clave del Map es el `id` compuesto de la fila —"elevator-annual-v2"— y
  // se construye con `buildTemplateRowId`, que la Fase 7 escribió justo para
  // que nadie la teclee. Una segunda función que concatenara lo mismo sería el
  // primer paso hacia dos formatos de clave.
  const templateByRowId = new Map(versions.map((version) => [version.id, version]));

  const storedByInspectionId = new Map<number, Finding[]>();

  for (const finding of stored) {
    const group = storedByInspectionId.get(finding.inspectionId);

    if (group === undefined) {
      storedByInspectionId.set(finding.inspectionId, [finding]);
    } else {
      group.push(finding);
    }
  }

  const result: InspectionWithFindings[] = [];

  for (const inspection of inspections) {
    const template = templateByRowId.get(
      // 🧭 Quinta y última aparición de esta línea en el curso: la versión que
      // la inspección GUARDÓ. Que aquí sea una búsqueda en un Map en vez de una
      // petición no cambia nada del invariante — cambia el costo.
      buildTemplateRowId(inspection.templateId, inspection.templateVersion),
    );

    if (template === undefined) {
      // Una inspección que apunta a una versión que no existe es un dato roto.
      // NO se deriva con la versión más cercana, ni con la vigente, ni se
      // inventa nada: se deja fuera y se cuenta. Rellenar aquí sería el
      // incidente 08 de la Fase 7 disfrazado de robustez.
      continue;
    }

    result.push({
      inspection,
      findings: deriveFindings(template, inspection, storedByInspectionId.get(inspection.id) ?? []),
    });
  }

  return result;
}

/** Aplana los hallazgos de todas las inspecciones. Lo que cuentan los KPI. */
export function flattenFindings(
  derived: readonly InspectionWithFindings[],
): readonly InspectionFinding[] {
  return derived.flatMap((entry) => entry.findings);
}
```

**Prueba de fuego**

Con `npm run seed:demo` puesto, abre el panel con Network filtrado en `Fetch/XHR` y cuenta: **cinco** peticiones —inspecciones, plantillas, certificados, activos y hallazgos— y ni una más. Ahora abre el detalle de cualquier inspección y comprueba que el número de hallazgos que muestra coincide exactamente con el que el panel contó para ella. Si no coincide, alguien leyó la colección `findings` en algún sitio.

### 5.4 El servicio que deriva y no guarda

```ts
// src/app/core/dashboard/dashboard-metrics.service.ts
import { Injectable, inject } from '@angular/core';
import { Observable, combineLatest, map, shareReplay, switchMap, tap, timer } from 'rxjs';

import { FindingApiService } from '../api/finding-api.service';
import {
  DashboardMetrics,
  assetsWithoutCoverage,
  bucketCertificates,
  rejectionByInspector,
  topFindingItems,
} from '../domain/dashboard-metrics';
import { deriveAllFindings, flattenFindings } from '../domain/derive-all-findings';
import { AssetStateService } from '../state/asset-state.service';
import { CertificateStateService } from '../state/certificate-state.service';
import { InspectionStateService } from '../state/inspection-state.service';
import { TemplateStateService } from '../state/template-state.service';

/**
 * Cada cuánto se refresca el panel. Constante exportada por la misma razón que
 * `AUTOSAVE_DEBOUNCE_MS` de la Fase 8: la Fase 12 lo va a testear con
 * `fakeAsync` y `tick`, y un número mágico dentro de un `pipe` no se puede
 * testear sin copiarlo.
 *
 * Un minuto y no cinco segundos: los datos de este panel cambian a ritmo de
 * jornada laboral, no de bolsa de valores. Refrescar más seguido no informa
 * mejor, sólo multiplica peticiones y hace que el gráfico parpadee.
 */
export const DASHBOARD_REFRESH_MS = 60_000;

/** Cuántos ítems entran en el ranking de hallazgos. Diez cabe en pantalla. */
const TOP_FINDINGS_LIMIT = 10;

/**
 * ⚠️ Se llama `MetricsService` y NO `MetricsStateService`, y la diferencia no
 * es de gusto. La convención de la guía §5.3 reserva el sufijo `StateService`
 * para lo que GUARDA estado; esto no guarda nada: deriva de los cuatro
 * servicios que sí lo hacen. No hay ni un `BehaviorSubject` en este archivo, y
 * el nombre es lo que impide que aparezca uno dentro de tres meses porque "así
 * carga más rápido".
 */
@Injectable({ providedIn: 'root' })
export class DashboardMetricsService {
  private readonly inspectionState = inject(InspectionStateService);
  private readonly templateState = inject(TemplateStateService);
  private readonly certificateState = inject(CertificateStateService);
  private readonly assetState = inject(AssetStateService);
  private readonly findingApi = inject(FindingApiService);

  /**
   * El latido. Recarga las cuatro colecciones y trae los hallazgos guardados,
   * que son los únicos que no tienen servicio de estado — y no lo tienen a
   * propósito: la Fase 9 decidió que los hallazgos se derivan, así que guardar
   * un estado de hallazgos sería exactamente lo que aquella fase evitó.
   */
  private readonly heartbeat$ = timer(0, DASHBOARD_REFRESH_MS).pipe(
    tap(() => {
      // Los `load()` son efectos: cada servicio actualiza su propio sujeto y
      // sus Observables emiten solos. Este servicio no espera respuestas ni
      // las encadena; sólo dice "es hora de refrescar".
      this.inspectionState.load();
      this.templateState.load();
      this.certificateState.load();
      this.assetState.load();
    }),
    switchMap(() => this.findingApi.getAll()),
  );

  readonly metrics$: Observable<DashboardMetrics> = combineLatest([
    this.heartbeat$,
    this.inspectionState.inspections$,
    // `TemplateState` no es `FeatureState<T>` —la Fase 7 rompió el molde a
    // propósito— así que las versiones se sacan de su `state$`. Se mapea aquí
    // en vez de añadir un `versions$` a aquel servicio: el panel es el único
    // que las quiere planas, y una API pública nueva por un solo consumidor es
    // deuda barata de crear y cara de quitar.
    this.templateState.state$.pipe(map((state) => state.versions)),
    this.certificateState.certificates$,
    this.assetState.assets$,
  ]).pipe(
    map(([stored, inspections, versions, certificates, assets]) => {
      // El instante se toma UNA vez por cálculo y se pasa a las cuatro
      // funciones puras. Si cada una llamara a `new Date()` por su cuenta, dos
      // KPI del mismo panel podrían estar calculados con relojes distintos —
      // improbable, y suficiente para que a las 23:59:59 una tarjeta diga hoy
      // y la de al lado diga mañana.
      const now = new Date().toISOString();
      const derived = deriveAllFindings(inspections, versions, stored);
      const findings = flattenFindings(derived);

      return {
        generatedAt: now,
        buckets: bucketCertificates(certificates, now),
        inspectorRates: rejectionByInspector(inspections),
        topFindings: topFindingItems(findings, versions, TOP_FINDINGS_LIMIT),
        coverage: assetsWithoutCoverage(assets, inspections, certificates, now),
        openCriticalCount: findings.filter(
          (finding) =>
            finding.kind === 'item' && finding.severity === 'critical' && finding.resolvedAt === null,
        ).length,
        inProgressCount: inspections.filter((inspection) => inspection.status === 'in_progress')
          .length,
      };
    }),
    /**
     * ⚠️ `refCount: true`, Y ES LA LÍNEA MÁS IMPORTANTE DEL ARCHIVO.
     *
     * `shareReplay` sirve para que los ocho suscriptores de la plantilla
     * compartan un solo cálculo en vez de hacer ocho. Sin `refCount`, la
     * suscripción interna NUNCA muere: el `timer` de `heartbeat$` sigue
     * disparando cada minuto para siempre, aunque el usuario se haya ido del
     * panel hace cuatro horas. Cinco peticiones por minuto durante una jornada
     * son dos mil cuatrocientas peticiones que nadie mira.
     *
     * Con `refCount`, cuando el último suscriptor se va —el `async` pipe se
     * desuscribe al destruirse el componente— la fuente se cancela y el timer
     * muere con ella. Es el incidente 16, y es la lección de la Fase 4 con
     * consecuencias medibles en la pestaña de red.
     */
    shareReplay({ bufferSize: 1, refCount: true }),
  );
}
```

```ts
// src/app/core/api/finding-api.service.ts — el método que se añade
  /**
   * Todos los hallazgos guardados, de una vez. Lo usa el panel, que necesita
   * la parte humana —descripción y fecha de resolución— de todas las
   * inspecciones a la vez y no de una.
   */
  getAll(): Observable<readonly Finding[]> {
    return this.http
      .get<readonly Finding[]>(this.baseUrl)
      .pipe(map((rows) => rows.map(normalizeFinding)), catchError(toApiError));
  }
```

**Detalles con intención**

- **`combineLatest` y no `forkJoin`.** `forkJoin` espera a que todas completen y emite una vez; los `state$` de los servicios son `BehaviorSubject` y no completan nunca, así que `forkJoin` se quedaría esperando para siempre. Es el error más común al montar un panel y no da ningún síntoma: sólo una pantalla en blanco.
- **`switchMap` en el latido.** Si un refresco tarda más de un minuto, el siguiente cancela al anterior. Es una **lectura**, así que cancelar es lo correcto — regla de la Fase 6.
- **El `map` que calcula todo corre en cada emisión de cualquiera de las cinco fuentes.** Con cinco fuentes emitiendo al refrescar, eso son hasta cinco recálculos por minuto en vez de uno. Es visible con doscientas inspecciones y molesto con dos mil, y es exactamente el ejercicio 18. La solución no es memorizar a ciegas: es medir primero.

```
💸 DEUDA TÉCNICA INTENCIONAL — los KPI se calculan en el cliente
Las cuatro agregaciones recorren la colección COMPLETA en el navegador, en cada
emisión. Lo correcto es que el servidor devuelva los números ya agregados: una
petición, cuatro cifras, y el trabajo donde están los índices.
NO SE PAGA, y el motivo no es de tiempo sino de herramienta: json-server sirve
colecciones y no agrega nada. Escribir el endpoint significa escribir backend,
que es trabajo que no enseña ni una línea de Angular — la misma razón por la que
la Fase 8 no pagó su PATCH por respuesta.
Lo que sí entra es EL NÚMERO. El ejercicio 18 mide `buildMetrics` con 200 y con
2000 inspecciones y busca el volumen en que el cálculo pasa de 16 ms, que es lo
que dura un fotograma a 60 fps: a partir de ahí, cada recálculo tira un
fotograma y el panel se siente pegajoso aunque nada falle. Ese número —el tuyo,
medido en tu máquina— es lo que se lleva a la reunión donde se decide si vale la
pena el endpoint. El ejercicio 25 lo diseña para que la decisión tenga las dos
mitades.
```

### 5.5 Las tarjetas y las listas

```ts
// src/app/features/dashboard/kpi-card/kpi-card.component.ts
import { NgIf } from '@angular/common';
import { ChangeDetectionStrategy, Component, Input } from '@angular/core';
import { MatIconModule } from '@angular/material/icon';

/**
 * Una tarjeta tonta: recibe un número y lo pinta. No inyecta nada, no sabe de
 * dónde salió el dato, y por eso es el componente más fácil de testear del
 * curso entero.
 *
 * `@Input({ required: true })` es de Angular 16.0 y es lo que convierte
 * "olvidé pasarle el valor" en un error de compilación de plantilla en vez de
 * en una tarjeta que dice "undefined" en producción. Antes de la 16 esto se
 * comprobaba en `ngOnInit` con un `throw`, que es lo que hacen dos componentes
 * de 2021 de este mismo sistema.
 */
@Component({
  selector: 'cc-kpi-card',
  standalone: true,
  imports: [NgIf, MatIconModule],
  template: `
    <article class="kpi-card" [class.kpi-card-alert]="alert">
      <mat-icon>{{ icon }}</mat-icon>
      <p class="kpi-card-value">{{ value }}</p>
      <p class="kpi-card-label">{{ label }}</p>
      <p class="kpi-card-hint" *ngIf="hint !== null">{{ hint }}</p>
    </article>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class KpiCardComponent {
  @Input({ required: true }) label = '';
  @Input({ required: true }) value = 0;
  @Input({ required: true }) icon = '';
  /** `null` = sin aclaración. No es lo mismo que la cadena vacía. */
  @Input() hint: string | null = null;
  /** Pinta la tarjeta en rojo. Es la única "alerta" que este curso construye. */
  @Input() alert = false;
}
```

```html
<!-- src/app/features/dashboard/expiry-panel/expiry-panel.component.html -->
<section class="expiry-panel">
  <h3>Certificados por vencer</h3>

  <!-- El número siempre; el gráfico sólo cuando la forma importa. Aquí la
       forma importa —la distribución entre ventanas se lee de un vistazo— así
       que hay las dos cosas: cuatro cifras y una barra. -->
  <ul class="expiry-windows">
    <li><strong>{{ buckets.in30.length }}</strong> en 30 días</li>
    <li><strong>{{ buckets.in60.length }}</strong> en 60 días</li>
    <li><strong>{{ buckets.in90.length }}</strong> en 90 días</li>
    <li class="expiry-expired"><strong>{{ buckets.expired.length }}</strong> vencidos</li>
  </ul>

  <h3>Activos sin cobertura vigente ({{ coverage.length }})</h3>

  <!-- ⭐ trackBy. Sin él, cada refresco de un minuto crea objetos nuevos y
       Angular destruye y recrea las cuarenta filas enteras: cuarenta nodos
       fuera del DOM y cuarenta dentro, cada minuto, para mostrar exactamente
       lo mismo. Con él, compara por `asset.id` y no toca nada si nada cambió.
       Se nota poco con cuarenta filas y muchísimo con dos mil (ejercicio 15). -->
  <ul class="coverage-list">
    <li *ngFor="let entry of coverage; trackBy: trackByAssetId">
      <a [routerLink]="['/assets', entry.asset.id]">{{ entry.asset.id }}</a>
      <span>{{ entry.asset.description }}</span>

      <!-- Los tres casos se dicen distinto a propósito: "nunca se certificó" y
           "se le venció hace 40 días" son dos conversaciones diferentes. -->
      <em *ngIf="entry.kind === 'never-certified'">Sin certificado</em>
      <em *ngIf="entry.kind === 'expired'">Vencido hace {{ entry.daysOverdue }} días</em>
      <em *ngIf="entry.kind === 'revoked'">Certificado revocado</em>
    </li>
  </ul>
</section>
```

```ts
// src/app/features/dashboard/expiry-panel/expiry-panel.component.ts — lo esencial
export class ExpiryPanelComponent {
  @Input({ required: true }) buckets!: ExpiryBuckets;
  @Input({ required: true }) coverage: readonly AssetCoverage[] = [];

  /**
   * La función de `trackBy` es un método y no una arrow guardada en un campo,
   * porque Angular la llama con el `this` de la plantilla y aquí no necesita
   * ninguno. Lo que sí importa: devuelve el `id` del activo, que es estable
   * entre refrescos. Devolver el índice sería equivalente a no poner nada en
   * cuanto la lista se reordene.
   */
  trackByAssetId(_index: number, entry: AssetCoverage): string {
    return entry.asset.id;
  }
}
```

**Prueba de fuego**

Abre Angular DevTools, pestaña Profiler, y graba un minuto entero con el panel quieto. Cuando salte el refresco, mira el árbol: las tarjetas `OnPush` cuyo número no cambió **no** aparecen en el ciclo. Ahora quita el `trackBy` de la lista de cobertura y repite: cuarenta filas destruidas y recreadas para mostrar lo mismo. Ésa es la diferencia entre "el panel se refresca" y "el panel parpadea".

### 5.6 🧬 El heredado que esta vez es el padre

Ésta es la quinta costura del curso y la primera de su clase. En las Fases 6, 7, 8 y 10, el NgModule heredado **alojaba** componentes standalone que el router pintaba: eran hermanos, no parientes. Aquí no. `DashboardHomeComponent` lo declaró la Fase 1, la Fase 5 lo congeló junto a los otros ocho módulos —*"no se convierten, ni hoy ni en el resto del curso"*— y hoy tiene que pintar en su propia plantilla seis componentes escritos en 2025.

```ts
// src/app/features/dashboard/dashboard.module.ts
@NgModule({
  declarations: [DashboardHomeComponent],
  imports: [
    SharedModule,
    DashboardRoutingModule,
    // 🧬 Seis componentes standalone importados por un NgModule de 2021 para
    // que su propio componente declarado pueda usarlos en la plantilla. Es la
    // misma línea de siempre y significa algo distinto: aquí el heredado no
    // aloja al nuevo, lo CONTIENE.
    KpiCardComponent,
    ExpiryPanelComponent,
    InspectorRatesComponent,
    FindingsChartComponent,
    ExpiryChartComponent,
    EmptyStateComponent,
  ],
})
export class DashboardModule {}
```

```ts
// src/app/features/dashboard/dashboard-home/dashboard-home.component.ts
// Componente HEREDADO. Se toca lo mínimo y en su estilo: `constructor`, sin
// `OnPush`, declarado en el módulo. Pasa de placeholder a cascarón del panel y
// ni una línea más.
@Component({
  selector: 'cc-dashboard-home',
  templateUrl: './dashboard-home.component.html',
  styleUrls: ['./dashboard-home.component.scss'],
})
export class DashboardHomeComponent {
  readonly metrics$: Observable<DashboardMetrics>;

  // Constructor y no `inject()`. El archivo es de 2021 y modernizarlo mientras
  // le añades una línea es exactamente cómo se rompen otras tres cosas.
  constructor(private readonly dashboardMetrics: DashboardMetricsService) {
    this.metrics$ = this.dashboardMetrics.metrics$;
  }
}
```

```html
<!-- src/app/features/dashboard/dashboard-home/dashboard-home.component.html -->
<ng-container *ngIf="metrics$ | async as metrics; else loading">
  <section class="kpi-row">
    <cc-kpi-card
      label="Certificados por vencer (30 días)"
      icon="schedule"
      [value]="metrics.buckets.in30.length"
      [alert]="metrics.buckets.in30.length > 0"
    />
    <cc-kpi-card
      label="Certificados vencidos"
      icon="error"
      [value]="metrics.buckets.expired.length"
      [alert]="metrics.buckets.expired.length > 0"
    />
    <cc-kpi-card
      label="Hallazgos críticos abiertos"
      icon="warning"
      [value]="metrics.openCriticalCount"
      hint="Bloquean la emisión de su certificado"
      [alert]="metrics.openCriticalCount > 0"
    />
    <cc-kpi-card
      label="Inspecciones en curso"
      icon="assignment"
      [value]="metrics.inProgressCount"
    />
  </section>

  <cc-expiry-panel [buckets]="metrics.buckets" [coverage]="metrics.coverage" />
  <cc-inspector-rates [rates]="metrics.inspectorRates" />
  <cc-expiry-chart [buckets]="metrics.buckets" />
  <cc-findings-chart [items]="metrics.topFindings" />

  <p class="dashboard-generated">Actualizado: {{ metrics.generatedAt }}</p>
</ng-container>

<ng-template #loading>
  <cc-empty-state message="Cargando el panel…" />
</ng-template>
```

**Detalles con intención**

- **Un solo `async` pipe para todo el panel.** Con seis `metrics$ | async` repartidos habría seis suscripciones, y con `refCount` puesto eso está bien —comparten el cálculo— pero el `generatedAt` de cada bloque podría ser distinto por milisegundos. Un panel donde dos tarjetas se calcularon en instantes distintos es la clase de inconsistencia que nadie ve y todo el mundo sufre cuando llega el ticket.
- **El padre es `Default` y sus hijos son `OnPush`, y eso está bien.** El padre se revisa en cada ciclo; los hijos, sólo cuando sus `@Input()` cambian por referencia. El beneficio es real y es menor de lo que el lector espera, y decirlo es más útil que esconderlo. El ejercicio 21 lo mide.
- **La sintaxis de etiqueta autocerrada `<cc-kpi-card … />` funciona desde Angular 15.1**, y aquí se usa porque estos componentes no tienen contenido proyectado. En un archivo de 2021 no la verás.

### 5.7 El gráfico, y por qué parpadeaba

```ts
// src/app/features/dashboard/findings-chart/findings-chart.component.ts
import { ChangeDetectionStrategy, Component, Input, OnChanges } from '@angular/core';
import { NgChartsModule } from 'ng2-charts';
import { ChartConfiguration } from 'chart.js';

import { FindingCount } from '../../../core/domain/dashboard-metrics';

/**
 * ⚠️ ng2-charts **4.1.1** con Chart.js **4.4.x**, que es lo que fija
 * `alcance-del-proyecto.md` §9. En la 4.x se importa `NgChartsModule` y el
 * gráfico se declara con la directiva `baseChart`. La 5.x —que es lo que vas a
 * encontrar en casi todo lo que busques— cambió a `provideCharts()` y a una
 * directiva standalone, así que un ejemplo copiado de un artículo reciente no
 * va a compilar aquí. Es la advertencia de versión más rentable de esta fase.
 *
 * 🧬 Y fíjate en el `imports`: un componente standalone de 2025 importando un
 * NgModule de una librería. No es una costura del proyecto —es de la librería—
 * pero se lee igual, y es la prueba de que standalone no significa "sin
 * NgModules": significa que el componente declara lo que usa.
 */
@Component({
  selector: 'cc-findings-chart',
  standalone: true,
  imports: [NgChartsModule],
  template: `
    <section class="chart-block">
      <h3>Ítems con más hallazgos</h3>
      <canvas baseChart type="bar" [data]="data" [options]="options"></canvas>
    </section>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class FindingsChartComponent implements OnChanges {
  @Input({ required: true }) items: readonly FindingCount[] = [];

  data: ChartConfiguration<'bar'>['data'] = { labels: [], datasets: [] };

  readonly options: ChartConfiguration<'bar'>['options'] = {
    indexAxis: 'y',
    responsive: true,
    maintainAspectRatio: false,
    /**
     * ⭐ La animación apagada, y no es una preferencia estética.
     *
     * Con el refresco de un minuto, cada emisión trae un array NUEVO aunque
     * los números sean idénticos. Chart.js ve datos nuevos y anima las barras
     * desde cero: el panel entero "salta" una vez por minuto delante de alguien
     * que está leyendo un número. Con la animación apagada, un refresco que no
     * cambia nada no se ve.
     *
     * Apagarla es el fix correcto y no un parche: en un panel que se refresca
     * solo, la animación no comunica nada — el usuario no provocó el cambio, así
     * que no hay transición que explicarle.
     */
    animation: false,
    plugins: { legend: { display: false } },
  };

  ngOnChanges(): void {
    // El array se reconstruye sólo cuando cambian los `@Input()`, que con
    // `OnPush` es cuando cambian por referencia. Reconstruirlo en un getter de
    // la plantilla lo haría en cada ciclo de detección, que es el error de
    // rendimiento más caro que se puede cometer con un gráfico.
    this.data = {
      labels: this.items.map((item) => item.title),
      datasets: [
        { label: 'Críticos', data: this.items.map((item) => item.critical) },
        { label: 'Total', data: this.items.map((item) => item.total) },
      ],
    };
  }
}
```

**Detalles con intención**

- **`ngOnChanges` y no un getter.** `[data]="buildData()"` en la plantilla se ejecuta en cada ciclo de detección de cambios, devuelve un objeto nuevo cada vez, y Chart.js redibuja. Es la forma más rápida de conseguir un panel que consume CPU sin hacer nada.
- **`maintainAspectRatio: false` con una altura fija en el CSS.** Sin eso, Chart.js recalcula el tamaño en cada `resize` y en algunos casos entra en un bucle de crecimiento que hace scroll infinito. Es un clásico y está en A06 con su detalle.
- **Chart.js viaja en el bundle inicial y jsPDF no**, y eso no es incoherente con la Fase 10. La regla es la misma en los dos casos: se difiere lo que **quizá** no se use. El gráfico se ve al abrir la pantalla a la que redirige `/`; el PDF sólo si alguien pulsa un botón. El ejercicio 17 te hace medir las dos cifras antes de creerte el argumento.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Síntoma:** el panel dice tres hallazgos críticos y la pantalla de la inspección dice dos.
**Causa:** el panel está contando la colección `findings` en vez de derivarlos.
**Fix mínimo:** usar `deriveAllFindings`, como en 5.3.
**Lo que importa:** es el atajo que la sección 4 anticipa y el que un proyecto real comete de verdad, porque leer la tabla es una petición y derivar parece caro. Los dos números son correctos según quien los mire, y ése es el peor tipo de bug: el que no se puede cerrar demostrando que uno de los dos está mal.

**Síntoma:** la pestaña sigue haciendo peticiones media hora después de que el usuario se fuera del panel.
**Causa:** `shareReplay()` sin `refCount`. La suscripción interna nunca muere y el `timer` sigue disparando.
**Fix mínimo:** `shareReplay({ bufferSize: 1, refCount: true })`.
**Lo que importa:** es el **incidente 16**, y no da ni un error. Lo delata Network con el panel cerrado, no la consola. Es la misma fuga que la Fase 4 enseñó a cazar y la misma opción que la Fase 8 puso en su `view$`; la diferencia es que aquí el costo es visible en el servidor de otra persona.

**Síntoma:** el panel "salta" una vez por minuto y las barras crecen desde cero aunque los números no hayan cambiado.
**Causa:** cada refresco produce un array nuevo y Chart.js anima cualquier dato nuevo.
**Fix mínimo:** `animation: false`.
**Lo que importa:** la primera reacción de todo el mundo es culpar a la detección de cambios y poner `OnPush` en todas partes. El componente **ya era** `OnPush`: el gráfico se redibujaba porque sus datos cambiaban de identidad, que es precisamente lo que `OnPush` mira. Poner `OnPush` para arreglar esto es como cerrar la puerta que ya estaba cerrada.

**Síntoma:** con dos mil inspecciones, escribir en el buscador de clientes hace que el panel se congele.
**Causa:** el panel sigue suscrito porque está en otra pestaña del navegador, o porque el `refCount` no está, y `combineLatest` recalcula las cuatro agregaciones cada vez que **cualquiera** de las cinco fuentes emite.
**Fix mínimo:** ninguno rápido; hay que decidir. Memorizar el cálculo, filtrar las emisiones que no cambian nada con `distinctUntilChanged`, o aceptar el costo con el número medido.
**Lo que importa:** es la misma decisión que la Fase 8 dejó abierta con el progreso recalculado en cada `valueChanges`. Conviene resolverla **una vez y con el mismo criterio en los dos sitios** —lo hace el ejercicio 23— porque dos criterios distintos para el mismo problema es cómo un proyecto acumula tres estrategias de caché incompatibles.

### Pieza forense de esta fase

**El panel va lento. ¿A quién culpas?**

El ticket llega así: *"desde ayer el panel tarda un montón en cargar y el ventilador se dispara."* Hay cuatro sospechosos y el orden en que los descartas es lo que separa media hora de media tarde.

**Sospechoso 1 — Una suscripción que no murió.** Es el más frecuente y el más fácil de descartar. Abre Network, filtra por `Fetch/XHR`, **sal del panel** y espera dos minutos. Si sigue saliendo tráfico, ya lo tienes y no hace falta abrir el código. Ese tráfico también te dice cuántas fugas hay: cinco peticiones por minuto es una; quince, tres.

**Sospechoso 2 — El cálculo.** Rodea el `map` de 5.4 con `performance.mark` o, más simple, con `console.time`:

```js
// En el `map` de metrics$, temporalmente.
console.time('buildMetrics');
// …el cálculo…
console.timeEnd('buildMetrics');
```

Si el número está por debajo de 16 ms, el cálculo no es el problema aunque lo parezca: 16 ms es lo que dura un fotograma a 60 fps, así que por debajo de eso el usuario no lo puede percibir. Si está por encima, mira **cuántas veces sale** en un minuto: un cálculo de 40 ms una vez por minuto es invisible; el mismo cálculo cinco veces por segundo es una pantalla congelada.

**Sospechoso 3 — El gráfico.** Con el panel abierto y quieto, abre la pestaña Performance de Chrome y graba treinta segundos. Si ves picos regulares de `requestAnimationFrame` sin que nadie toque nada, es una animación corriendo en bucle. Chart.js redibuja cuando la identidad de sus datos cambia, no cuando cambian los valores.

**Sospechoso 4 — Y sólo ahora, la detección de cambios.** Angular DevTools, pestaña Profiler, graba una interacción. La columna que importa no es cuántos componentes se revisaron: es cuánto duró el ciclo. Un ciclo de 3 ms con doscientos componentes revisados **no es un problema**. Uno de 200 ms con cuatro componentes sí lo es, y entonces el culpable es lo que hay dentro de esos cuatro —un getter que calcula, un `*ngFor` sin `trackBy` sobre dos mil filas— y no la estrategia.

> 🧭 **La regla que se lleva el estudiante:** `ChangeDetectionStrategy` es el último sospechoso, no el primero. Cambiarla es barato de escribir y caro de depurar, porque un componente `OnPush` mal puesto no va lento: va **mal**, deja de pintarse, y el bug que produce no se parece en nada al que intentabas arreglar.

> 📄 El recorrido completo, con el ticket literal y la salida de cada paso, en `forense-fase-11.md`.

**🧨 Rompe a propósito**

Tres roturas, y la tercera es la que enseña algo que no esperas.

1. **Quita el `refCount` del `shareReplay`.** Abre el panel, vete a `/clients`, y deja Network abierto diez minutos. Cuenta las peticiones. Después vuelve al panel y vuelve a salir tres veces más: comprueba si el número de peticiones por minuto sube o se queda igual, y explica por qué. La respuesta —**se queda igual, porque la fuente compartida es una sola**— es más interesante que la que casi todo el mundo predice, y entender por qué es entender qué comparte `shareReplay` exactamente.

2. **Mueve el `timer` al `ngOnInit` del componente, sin `takeUntilDestroyed`.** Ahora sí: entra y sal del panel cinco veces y cuenta. Cinco temporizadores vivos, veinticinco peticiones por minuto, y creciendo. Ésta es la versión multiplicativa de la misma fuga y es la que de verdad tumba un servidor.

3. **Sustituye `deriveAllFindings` por una lectura directa de la colección `findings`.** El panel carga más rápido, se ve mejor, y miente: los hallazgos de las inspecciones 500 y 501 no coinciden con lo que dice su pantalla de detalle, porque las filas 902 y 903 de la semilla divergen de la derivación desde la Fase 9. Guarda las dos capturas: es el mejor ejemplo del curso de que "más rápido" y "correcto" son ejes distintos.

---

## 🧪 7. Ejercicios (26)

**🟢 Fácil (1–7)**

1. Escribe `mock/demo.js` y el script `seed:demo`. Corre los dos comandos —`npm run seed` y `npm run seed:demo`— y entrega el número de inspecciones y certificados que deja cada uno.
2. **Diagnóstico.** Después de correr `npm run seed:demo`, ejecuta `git status`. Comprueba que `mock/db.seed.json` **no** aparece y explica en tres frases por qué eso importa para el enunciado del incidente 08 de la Fase 7.
3. Implementa `bucketCertificates` y entrega una tabla de seis filas: ventana, cuántos certificados, y un id de ejemplo de cada una.
4. **Diagnóstico.** Edita a mano el `validUntil` de un certificado para que venza en exactamente 30 días, y después en 31. Anota en qué ventana cae cada uno y explica por qué los límites son inclusive por arriba.
5. Implementa `rejectionByInspector` y córrela sobre el escenario canónico —cinco inspecciones, dos inspectores—. Explica en cinco líneas por qué mostrar la tasa sin el denominador sería mentir, con los números de la semilla delante.
6. Escribe `deriveAllFindings` usando `buildTemplateRowId` de la Fase 7. Comprueba con un `Ctrl+Shift+F` que **no** escribiste una segunda función que concatene `templateId` y versión.
7. **Diagnóstico.** Añade `getAll()` a `FindingApiService` y pídelo con `curl`. Cuenta las filas que devuelve y compáralas con el número de hallazgos que el panel calcula. Explica la diferencia.

**🟡 Intermedio (8–15)**

8. Implementa `topFindingItems` y `assetsWithoutCoverage`, y comprueba que los tres casos de cobertura aparecen: un activo sin certificado, uno vencido y uno revocado. Si te falta alguno, provócalo.
9. **Diagnóstico.** Haz el 🧨 número 3: cuenta hallazgos leyendo la colección `findings` y compáralo con lo derivado. Entrega las dos cifras para la inspección `501` y explica cuál es la verdad de hoy, apoyándote en lo que decidió la Fase 9.
10. Monta `DashboardMetricsService` completo con `combineLatest` y el `timer`. Comprueba que el panel se refresca solo y que `generatedAt` cambia cada minuto.
11. **Diagnóstico.** Con el panel abierto y quieto, cuenta las peticiones por minuto en Network. Deben ser cinco. Si son más, di cuál sobra y de dónde sale.
12. 🧬 **Estilo.** Ticket: *"el panel debería mostrar arriba del todo cuántas inspecciones llevo yo hoy"*. El archivo es `DashboardHomeComponent`, heredado de la Fase 1. Escribe el fix y justifica en cinco líneas por qué no lo convertiste a standalone, no le pusiste `OnPush` y no le cambiaste el `constructor` por `inject()` aunque tocaste doce líneas.
13. Escribe `KpiCardComponent` con `@Input({ required: true })`. Después quita el `required` de uno, olvida pasarle el valor a propósito, y compara los dos errores: el de compilación y el de la tarjeta que dice `undefined`. Entrega los dos mensajes.
14. Implementa la lista de cobertura con `trackBy` y grábala con el Profiler de Angular DevTools durante un refresco. Anota cuántos componentes se recrean.
15. **Diagnóstico.** Quita el `trackBy` y repite la medición con `DEMO_INSPECTIONS=2000`. Entrega las dos cifras y el tiempo de cada ciclo.

**🟠 Difícil (16–21)**

16. **Diagnóstico.** Haz el 🧨 número 1: quita el `refCount`, sal del panel y mide diez minutos de tráfico. Después haz el 🧨 número 2 y mide otra vez. Explica por qué el primero **no** se multiplica al entrar y salir y el segundo sí, y qué comparte exactamente `shareReplay`.
17. Monta los dos gráficos con ng2-charts 4.1.1. Después mide el bundle inicial con y sin Chart.js (`ng build --named-chunks --stats-json`), anota las dos cifras en `deuda.md`, y argumenta en cinco líneas por qué aquí no se difiere y en la Fase 10 sí. Si al medir te convence lo contrario, cámbialo y defiéndelo.
18. 💸 **El número de la deuda.** Instrumenta el `map` de `metrics$` con `console.time` y mídelo con `DEMO_INSPECTIONS` a 200, 500, 1000 y 2000. Entrega los cuatro números y **el volumen en el que el cálculo pasa de 16 ms**. Después mide cuántas veces por minuto se ejecuta de verdad y di si el problema es el cálculo o su frecuencia.
19. 💸 **La otra deuda, la de la Fase 8.** Con una plantilla de sesenta ítems, mide el peso del cuerpo de un `PATCH` del autosave y multiplícalo por las pulsaciones de una jornada de ocho horas. Compáralo con lo que costaría el `PATCH` por respuesta que el ejercicio 31 de la Fase 8 dejó diseñado, y decide con el número delante si lo escribirías. Anota la cifra en `deuda.md`.
20. 🧬 **Estilo.** Ticket: *"desde el panel quiero llegar a la lista de inspecciones ya filtrada por el inspector que pinché"*. Decide en qué archivo va —`InspectorRatesComponent` es standalone, `InspectionListComponent` es heredado— y escríbelo en los dos, en el estilo de cada uno. Justifica cuál entregarías si sólo pudieras hacer uno.
21. **Diagnóstico.** Mide el efecto real del `OnPush` de los hijos con un padre `Default`: graba un ciclo con Angular DevTools, después cambia los seis hijos a `Default`, y graba otra vez. Entrega las dos cifras de duración de ciclo y explica por qué la diferencia es menor de lo que esperabas y por qué aun así vale la pena.

**🔴 Muy difícil (22–26)**

22. Escribe el post-mortem completo de ocho puntos del incidente **16** siguiendo `formato-cuaderno-incidentes.md`, con su par de tags `inc/16/<slug>-roto` / `-fix`. El punto 3 —evidencia observable— es el interesante: la consola no dice nada y el síntoma sólo existe **después** de salir de la pantalla. Describe qué mirar y en qué orden. En el punto 7, añade la prevención que impediría la clase entera de fuga, no sólo ésta.
23. Resuelve de una vez el problema de recálculo que aparece **dos veces** en el curso: el progreso de la Fase 8 en cada `valueChanges` y las agregaciones de esta fase en cada emisión. Elige un criterio —memorizar, `distinctUntilChanged` sobre una clave serializada, o recalcular y medir—, aplícalo a los dos sitios, y justifica por qué no elegiste dos criterios distintos. Entrega las mediciones de antes y después en los dos.
24. **Diagnóstico.** `assetsWithoutCoverage` compara `validUntil` como cadenas para quedarse con el certificado más reciente. Rompe esa comparación: mete a mano un certificado con offset `+02:00` en `db.json` y comprueba qué activo cambia de estado. Explica por qué el orden lexicográfico deja de coincidir con el cronológico, y arréglalo sin dejar de comparar cadenas si puedes.
25. Diseña el endpoint de agregación que la 💸 no paga: qué devolvería, cómo cambiarían las cuatro funciones de 5.2, qué se ganaría y qué se perdería —incluida la pregunta incómoda de si el servidor podría derivar los hallazgos igual que el cliente, o si tendría que leer la colección `findings` y volver a tener dos verdades—. Impleméntalo en un Express aparte si quieres el número de verdad, y decide con las dos mediciones delante.
26. Escribe los tests puros de `bucketCertificates`, `rejectionByInspector`, `topFindingItems`, `assetsWithoutCoverage` y `deriveAllFindings` —sin `TestBed`, como los de las Fases 8, 9 y 10—. La tabla de bordes tiene que cubrir: el certificado a 30 días clavados, el inspector sin decisiones (`rate: null`), el hallazgo sin severidad, el activo sin certificado, y la inspección que apunta a una versión de plantilla inexistente. Guárdalos: la Fase 12 los va a reclamar.

**🔥 Opcionales**

- 🔥 **Exportar el panel a Excel.** Diseña —y si quieres, implementa con una librería que fijes con su versión exacta— la exportación de la lista de cobertura. Aplica la regla de la Fase 10: lo que sale del sistema se reconstruye desde la fuente. Después mide cuánto pesa la librería en el bundle y decide si va diferida.
- 🔥 **El comparador de versiones de plantilla**, que la Fase 7 dejó pendiente: qué ítems se añadieron, cuáles cambiaron de título o de severidad, y cuáles desaparecieron entre dos versiones. Con `groupIntoFamilies` y `TemplateFamily` ya escritos cuesta poco, y es lo primero que pide quien audita un cambio normativo. Va en la pantalla de plantillas, no en el panel.
- 🔥 **Refresco inteligente.** Sustituye el `timer` fijo por uno que se pause cuando la pestaña no está visible (`document.visibilityState`) y se reanude al volver. Mide cuántas peticiones ahorra en una jornada real y decide si la complejidad vale la pena.

---

## 📚 8. Referencias

**Documentación oficial**

- https://v16.angular.io/api/core/ChangeDetectionStrategy — la definición, que cabe en un párrafo. Lo que no está ahí es cuándo culparla, y eso es la sección 6.
- https://v16.angular.io/api/common/NgForOf#ngForTrackBy — `trackBy`, con la firma exacta que espera Angular.
- https://v16.angular.io/api/core/Input — `@Input({ required: true })`, que llegó en la 16.0 y es de lo poco que esta versión estrena y este curso usa de verdad.
- https://rxjs.dev/api/index/function/combineLatest — y su nota sobre que **no emite hasta que todas las fuentes han emitido al menos una vez**, que es el motivo de la mitad de los paneles en blanco.
- https://rxjs.dev/api/index/function/timer y https://rxjs.dev/api/operators/shareReplay — las dos piezas de 5.4. La página de `shareReplay` explica `refCount` en tres líneas que conviene leer despacio.
- https://github.com/valor-software/ng2-charts — ng2-charts. ⚠️ **Importante:** el README y la web describen la **5.x**, con `provideCharts()` y directiva standalone. Este curso usa la **4.1.1**, con `NgChartsModule` y la directiva `baseChart` declarada en él. Un ejemplo copiado de cualquier artículo posterior a 2023 no compila aquí, y el error que da no apunta a la versión.
- https://www.chartjs.org/docs/latest/ — Chart.js 4. Las opciones que usa esta fase son `indexAxis`, `responsive`, `maintainAspectRatio`, `animation` y `plugins.legend`.
- https://developer.chrome.com/docs/devtools/performance/ — la pestaña Performance, que es el sospechoso 3 de la pieza forense.
- https://angular.io/guide/devtools — Angular DevTools y su Profiler, el sospechoso 4. ⚠️ La URL apunta a la documentación actual porque la extensión no se versiona con Angular; la interfaz que verás puede diferir de las capturas de cualquier tutorial.

**Orden de lectura sugerido:** la nota de `combineLatest` sobre la primera emisión **antes** de escribir 5.4, o vas a perder veinte minutos con una pantalla en blanco. `shareReplay` y su `refCount` **después** de provocar el 🧨 número 1, no antes: leído en frío es un parámetro más, leído con Network llenándose solo se entiende de una vez. Y **A06** para los cuatro operadores de esta fase juntos, y **A07** para revisar por qué este servicio no guarda nada.

---

## 🚀 9. Cierre y conexión con la siguiente fase

CertCore ya se puede mirar entero. Cuatro números arriba, las ventanas de vencimiento, los activos que nadie certificó y los ítems que más se rompen. Y ni un dato nuevo en el backend: todo sale de lo que las diez fases anteriores ya guardaban.

Debajo hay tres cosas que valen fuera de este proyecto. La primera es la que este curso lleva cuatro fases repitiendo y aquí queda cerrada: **lo derivado no se guarda**, ni una versión de plantilla, ni una severidad, ni un estado de certificado, ni un KPI — y funciona porque las entradas de esos cálculos son inmutables. La segunda: **derivar puede ser barato si el dominio es puro**. `deriveFindings` no inyecta nada, y por eso doscientas inspecciones se derivan en un bucle en vez de en cuatrocientas peticiones; si aquella función hubiera "resuelto ella misma" la plantilla, este panel no existiría. Y la tercera, la que más se transfiere: **el orden en que se buscan los culpables de la lentitud**. Suscripción viva, identidad de los datos, redibujado, y sólo entonces la detección de cambios.

Lo que te llevas: en una SPA, el rendimiento casi nunca es el costo de una operación. Es su **frecuencia**. Un cálculo de cuarenta milisegundos es invisible una vez por minuto y es una pantalla congelada cinco veces por segundo, y el mismo código produce los dos resultados. Antes de optimizar qué hace tu aplicación, mira cuántas veces lo hace.

La **Fase 12** hace la pregunta que este curso ha estado aplazando once fases: **¿cómo sabes que esto funciona?** Monta Jasmine, Karma y TestBed desde cero —CertCore no tiene ni un spec, decisión cerrada desde el principio— y va a reclamar todo lo que estas cinco fases dejaron escrito puro: `resolveTemplateVersion`, `buildAnswerForm`, `computeProgress`, `deriveSeverity`, `certificateStatus`, `bucketCertificates`. Se van a testear sin `TestBed` y en tres líneas cada uno, y ése es el momento en que se entiende por qué llevan cinco fases sin inyectar nada. Después llegan los componentes, que son otra historia, y el coverage medible. Y de paso, el guiño a las signals: lo único de Angular 17 que este curso mira de cerca.

> **La señal de que quedó bien:** cuando el coordinador abre el panel a las ocho de la mañana, mira cuatro números, y sabe a quién llamar antes de terminar el café — y cuando tú puedes decir, con una cifra medida, hasta cuántos registros eso va a seguir siendo verdad.

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-11 -m "F11 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`fase 11: …`) y los de ejercicio su
> número (`fase 11 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f11/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva el cuaderno. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
>
> Esta fase estrena una herramienta y conviene decirlo en el mensaje del tag:
> `mock/demo.js` y `npm run seed:demo` se versionan, pero el `db.json` que
> generan **no tiene por qué**, porque cambia cada día que lo corras. Decide
> antes de etiquetar si commiteas un `db.json` de demostración —útil para que
> el enunciado del incidente 16 sea reproducible— o lo dejas fuera y confías en
> la semilla fija del generador, que produce los mismos datos el mismo día.
> Y las tres mediciones de esta fase —Chart.js en el bundle, `buildMetrics` con
> dos volúmenes, y el peso del autosave de la Fase 8— van a `deuda.md` junto a
> las de las Fases 5, 6 y 10: ese archivo es lo único del curso que crece
> monótonamente, y a estas alturas ya vale más que varias de las pantallas.

---

## 📌 Pendientes sugeridos

- **`db.seed.json` sigue intacto, y ésa fue la decisión de esta fase.** El prompt sugería ampliarla; en su lugar se escribió `mock/demo.js`, porque ampliar la semilla con fechas fijas se pudre —📌 de la Fase 10— y con fechas relativas contradice la conclusión del ejercicio 23 de la Fase 3. El escenario canónico es fijo, pequeño y versionado; el volumen es relativo, desechable y generado. → **Aviso para el chat de la Fase 12**: tus fixtures no cambiaron, las cinco inspecciones y los cuatro hallazgos siguen exactamente donde estaban.
- **`FindingApiService` gana un `getAll()` que la Fase 9 no escribió.** Es un método y no rompe nada, pero conviene que esté anotado: es la única API de una fase anterior que esta fase amplía. → **Nota de coherencia**, sin acción.
- **El comparador de versiones de plantilla sigue sin dueño.** La Fase 7 lo dejó como 🔥, esta fase lo descartó por alcance —es una pantalla de plantillas, no un panel— y sigue siendo lo primero que pide quien audita un cambio normativo. Con `groupIntoFamilies` ya escrito cuesta una tarde. → **Decisión de proyecto**: o entra como pantalla en una segunda pasada de la Fase 7, o se queda como 🔥 para siempre.
- **La 💸 de la Fase 8 queda medida y sin decidir, a propósito.** El ejercicio 19 pone el número; qué hacer con él es del lector. Si el curso hace una segunda pasada, el resultado de ese ejercicio debería subir al texto de la Fase 8 como cifra concreta en vez de como promesa. → **Pendiente de revisión editorial.**
- **El problema de recálculo aparece dos veces y el ejercicio 23 lo resuelve una sola vez.** Si el criterio que elija el lector acaba siendo memorizar, hay que volver a la Fase 8 y aplicarlo también allí, o el curso queda enseñando dos estrategias para el mismo problema. → **Aviso para una segunda pasada sobre la Fase 8.**
- **Las alertas no alertan.** "Alerta" aquí significa un número en rojo en una pantalla que alguien tiene que abrir. Un sistema de certificaciones de verdad avisa por correo cuando quedan treinta días, y eso exige un canal, una plantilla de mensaje y trazabilidad de a quién se avisó — las tres fuera de alcance, y la tercera es la cuarta vez que este curso tropieza con la misma ausencia. → **Decisión de proyecto**, junto con la auditoría que las Fases 6, 9 y 10 ya reclamaron.
- **`document.visibilityState` es el arreglo obvio del refresco y no está en el cuerpo.** Un panel que sigue pidiendo con la pestaña oculta es dinero de otro. Está como 🔥 porque no enseña nada nuevo sobre Angular, pero es lo primero que haría en un proyecto real. → **Ejercicio 🔥 ya escrito.**
- 🔥 **Un diagrama del árbol de detección de cambios** —padre `Default` con hijos `OnPush`, con las flechas de "se revisa" hacia abajo y las de "se marca" hacia arriba— explicaría §4 mejor que sus cuatro párrafos, y es lo que casi nadie tiene claro. Es el noveno pendiente de ilustración del curso. Pendiente de dibujo, no de contenido.

### Reservas para el cuaderno de incidentes

Los enunciados ya están escritos en el índice de [`cuaderno-incidentes.md`](cuaderno-incidentes.md), que es donde viven; acá queda constancia de qué fase los produce. **El ID no se reasigna nunca.**

| ID | Título | Categoría | Dif. |
|---|---|---|---|
| 16 | "Cerré el panel hace media hora y el servidor sigue recibiendo peticiones mías" | Performance | 🟠 |
