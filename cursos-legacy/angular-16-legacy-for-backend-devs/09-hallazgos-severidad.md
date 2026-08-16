# ⚠️ Fase 09 — Hallazgos y severidad

> Tutorial Angular 16 — Inspecciones y certificaciones · Fase 9 de 14 · **6 horas**
> Depende de: Fase 8 (formulario dinámico) · Habilita: Fases 10 y 11
> Apéndices de apoyo: [A05 (Formularios reactivos tipados)](a05-formularios-tipados.md) · [A07 (Estado con servicios)](a07-estado-servicios.md)
> [Incidentes asociados](cuaderno-incidentes.md): 12, 13
> Estilo de esta fase: **nuevo**, con una costura 🧬 hacia el `InspectionsModule` heredado

---

## 🎯 1. Propósito

La Fase 8 dejó guardado `answer: 'critical_wear'` y nadie dedujo nada de eso. Hoy esa cadena empieza a tener consecuencias: se convierte en un **hallazgo con severidad**, la severidad se agrega por inspección, y un `critical` sin resolver impide aprobarla — que es la primera vez en todo el curso que una regla de negocio le dice que no a un usuario.

Pero la fase no va realmente de severidades. Va de una pregunta que se repite en todos los sistemas que vas a mantener: **¿esto es un dato que se guarda o un dato que se calcula?** El hallazgo se puede guardar —CertCore lo hace desde 2021, y la colección `findings` está ahí para probarlo— o se puede derivar de la respuesta más la plantilla con la que se ejecutó. Las dos opciones funcionan hasta el día en que dejan de coincidir, y en la semilla de este curso ya no coinciden.

Y va de una tercera cosa, más pequeña y más cara: la diferencia entre `null`, `undefined` y **campo ausente**. Un hallazgo `critical` que no bloqueó nada porque alguien preguntó `resolvedAt === null` a un objeto donde el campo simplemente no venía. `strict` no lo ve, el compilador no se queja, y el certificado se emite.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `/inspections/503` muestra **dos** hallazgos —un `critical` en `main-cable` y un `minor` en `cabin-lighting`— y un banner que dice que la inspección no se puede aprobar. La `502`, con las dos respuestas conformes, no muestra ninguno.
- [ ] La severidad no sale de `db.json`: sale de cruzar la respuesta con los `criteria` del ítem **de la versión que la inspección congeló**. Cambiar `nonComplianceSeverity` en la v2 no toca ni un hallazgo de una inspección v1.
- [ ] La `501` muestra un hallazgo `minor` derivado, mientras la fila `902` de `db.json` dice `major`. Sabes explicar cuál de los dos es la verdad y por qué.
- [ ] Completas la inspección `500` respondiendo sus cuatro ítems y **la puedes aprobar**; vuelves a poner `critical_wear` en `main-cable` y el botón se niega con un mensaje que dice qué ítem lo bloquea.
- [ ] Abres `/inspections/501/edit` —una inspección aprobada— y la aplicación te manda a la vista de sólo lectura. Intentas guardar desde la consola y el servicio también se niega.
- [ ] Las tres reglas de negocio que vivían en pantallas —cliente inmutable, familia de plantilla por tipo de activo, y el cierre de una inspección— viven ahora en servicios, y `git diff fase-06 fase-09 -- src/app/features/assets/` te lo enseña en una pantalla.
- [ ] Borras el campo `resolvedAt` de la fila `902` en `db.json`, recargas, y la aplicación sigue diciendo la verdad. Antes de la normalización del borde HTTP, mentía.
- [ ] `git tag` lista `fase-09`.

---

## 🚫 3. Qué NO entra todavía

- **La emisión del certificado** → Fase 10. Aquí se escribe la **puerta** (`canIssueCertificate`) y se comprueba que `approve()` se niega; quien la abre es la fase siguiente, que además trae `CertificateApiService` y el PDF.
- **La revocación de un certificado** por un hallazgo aparecido después de aprobar → Fase 10. Aquí se decide la política y se escribe; no se implementa.
- **El plan de acción correctiva** —tareas, responsables, plazos— → fuera de alcance. Un hallazgo se marca resuelto con una fecha y nada más.
- **El workflow de aprobación multi-nivel** y las **notificaciones** → fuera de alcance. CertCore no tiene roles que autoricen (decisión cerrada de la Fase 2) y no va a tenerlos: ver el ejercicio 🔥.
- **La severidad subida a mano por un supervisor** → ejercicio 🔴 24 y el incidente **13**. Entra en el cuerpo del curso sólo como decisión razonada, porque implica trazabilidad, y la trazabilidad sigue sin dueño desde la Fase 6.
- **Campos nuevos en `db.seed.json`** → ninguno. La Fase 3 avisó de lo caro que se vuelve tocar la semilla con fases construidas encima, y esta fase demuestra que se puede añadir una capa entera de negocio sin pedirle nada al backend.

---

## 🧠 4. Concepto mínimo

### El problema, antes que la herramienta

Abre `db.json` y mira la colección `findings`. Hay cuatro filas, cada una con su `severity` escrita. Ahora mira la inspección `500`: tiene una respuesta, `main-cable: light_wear`, y el ítem `main-cable` de la v2 declara `nonComplianceSeverity: "critical"`. La fila guardada dice `minor`.

¿Cuál de las dos es la verdad?

No es una pregunta retórica ni un error de la semilla que haya que corregir: es **exactamente** el estado en que vas a encontrar cualquier sistema de más de tres años. Alguien escribió los hallazgos a mano durante dos años, después llegó una norma nueva que cambió las severidades, y desde entonces las filas viejas dicen lo que decían el día que se escribieron. Que la aplicación las siga leyendo es lo que hace que un informe de 2021 se pueda reimprimir igual; que alguien las use para decidir hoy es lo que produce el ticket.

La pregunta que ordena la fase es ésta: **¿el hallazgo es un dato que se guarda o un dato que se calcula?**

### Dato guardado y dato derivado, y cómo se decide

Un dato **guardado** es el que alguien escribió y nadie puede reconstruir: la nota del inspector, la foto, la fecha en que se resolvió el hallazgo. Si lo pierdes, se perdió.

Un dato **derivado** es el que se puede volver a calcular desde otros: la severidad de un hallazgo sale de la respuesta más los `criteria` y el `nonComplianceSeverity` del ítem. Si lo pierdes, lo recalculas.

La tentación de guardar los derivados es enorme y siempre tiene la misma excusa —*"así no hay que recalcularlo"*—, y siempre tiene el mismo final: el dato guardado y el cálculo dejan de coincidir, y nadie sabe cuál mandaba. Lo viste ya en el `status` del certificado, que está almacenado y debería ser calculado, y que la Fase 10 va a desmontar. Aquí llegas antes que el problema.

Pero hay una condición que hace que derivar sea seguro, y sin ella todo esto sería un desastre:

> 🧭 **Un derivado sólo se puede recalcular si sus entradas son inmutables.** La severidad se deriva de la respuesta —que es histórica— y de la plantilla **con la que la inspección se ejecutó** —que la Fase 7 congeló en `templateVersion` y que nadie puede reescribir—. Publicar una v3 con severidades nuevas no mueve ni un hallazgo de una inspección v1. Si el cálculo dependiera de "la plantilla vigente", derivar sería el peor error de este curso.

Ésa es la respuesta a la pregunta que el 💸 de esta fase se hacía: *si la plantilla cambia, ¿el hallazgo histórico cambia?* No, porque el hallazgo no se deriva de "la plantilla", se deriva de **su** versión de la plantilla. El invariante de la Fase 7 no sólo sobrevive: es lo que autoriza el diseño.

### La regla de derivación, que ya estaba escrita y nadie la había leído

El modelo de la Fase 3 documenta `criteria` así: *"las respuestas admisibles, **en orden de mejor a peor**"*. Esa frase, escrita seis fases atrás casi como un comentario de cortesía, es toda la regla de negocio que necesitas:

- **El primer criterio es conformidad.** `no_wear`, `ok`, `within_range`. No hay hallazgo.
- **El último criterio es no conformidad plena.** `critical_wear`, `failed`, `out_of_range`. La severidad es la que el ítem declara en `nonComplianceSeverity`.
- **Los criterios de en medio son no conformidad parcial.** `light_wear`, `intermittent`, `partial`. La severidad **baja un escalón**: `critical` → `major`, `major` → `minor`, y `minor` se queda en `minor` porque no hay nada más leve que no sea "sin hallazgo", y eso ya lo decide el primer criterio.

Con dos criterios —`flue-gas` tiene sólo `within_range` y `out_of_range`— el segundo es a la vez el último, así que no hay degradado: se sale directamente a `major`. Es correcto y conviene verlo una vez.

Esta regla explica dos de los cuatro hallazgos de la semilla y contradice los otros dos. **Eso no es un error: es el material de la fase.** Los dos que no cuadran son los que alguien escribió a mano antes de que la regla existiera, y en la sección 6 los vas a usar para diagnosticar.

### `null`, `undefined` y campo ausente

Aquí es donde `strict` cobra lo que te viene costando desde la Fase 0.

Un hallazgo derivado de un ítem vivo tiene severidad: `FindingSeverity`. Un hallazgo derivado de una respuesta cuyo ítem **ya no está en esta versión de la plantilla** —el ítem retirado de la Fase 7— no tiene severidad y **no puede tenerla**: no hay `nonComplianceSeverity` que consultar. Eso es `null`, y `null` aquí significa algo muy concreto: *"lo miré y no hay"*.

Lo que nunca significa es *"nadie lo miró"*. Ése sería `undefined`, y en TypeScript los dos se escriben distinto precisamente para que no se confundan. El problema es que hay un tercer estado que el sistema de tipos **no ve**: el campo que el backend no mandó.

```ts
// La fila 902 de db.json, tal como la sirve json-server:
{ "id": 902, "inspectionId": 501, "itemId": "door-sensor", "severity": "major",
  "description": "…", "resolvedAt": "2023-08-18T16:00:00-05:00" }

// La misma fila si alguien borra el campo al editar a mano:
{ "id": 902, "inspectionId": 501, "itemId": "door-sensor", "severity": "major",
  "description": "…" }
```

El tipo `Finding` declara `readonly resolvedAt: string | null`. La segunda fila **no cumple ese tipo** y aun así entra en la aplicación sin que nada proteste, porque `http.get<Finding[]>()` es una promesa del programador, no una comprobación. Y entonces `finding.resolvedAt === null` devuelve `false` para un hallazgo que nadie resolvió jamás, el `critical` deja de bloquear, y el certificado sale.

Es el **incidente 12**, y su fix mínimo cabe en un carácter. La corrección correcta es otra, y las dos están en la sección 6.

> 📝 **Nota de migración.** Las **uniones discriminadas** que vas a usar hoy no son de Angular: son de TypeScript, y existen desde la 2.0. Lo que cambió con `strict: true` —que CertCore activó en la migración de 2024, no antes— es que ahora el compilador te obliga a agotar los casos en vez de dejarte olvidar uno. El código de 2021 de este mismo sistema resolvía esto con un `severity: string` y un `if` con tres ramas, de las cuales una nunca se ejecutaba. Compilaba igual. La diferencia entre aquel archivo y éste no es la sintaxis: es que el compilador ahora participa.

---

## 💻 5. Código mínimo con comentarios

### 5.1 La regla de derivación, en once líneas

```ts
// src/app/core/domain/finding-severity.ts
import { ChecklistItem } from '../models/checklist-template.model';
import { FindingSeverity } from '../models/finding.model';

/**
 * Qué severidad queda al bajar un escalón. Es un Record TOTAL sobre la unión:
 * si mañana alguien añade 'blocker' a FindingSeverity, este objeto deja de
 * compilar y el compilador te lleva de la mano hasta aquí.
 *
 * `minor` se mapea a sí mismo a propósito: no existe una severidad más leve.
 * Lo más leve que hay es "no hay hallazgo", y esa decisión la toma
 * `deriveSeverity` con el índice 0, que es otro asunto.
 */
const DOWNGRADED: Readonly<Record<FindingSeverity, FindingSeverity>> = {
  critical: 'major',
  major: 'minor',
  minor: 'minor',
};

/** De más grave a menos. La usa la agregación para ordenar y para decidir el máximo. */
export const SEVERITY_ORDER: readonly FindingSeverity[] = ['critical', 'major', 'minor'];

/**
 * Etiquetas para pantalla. A diferencia del `criterionLabel` de la Fase 8 —que
 * arrastra un 💸 porque los criterios son datos abiertos y su tabla puede
 * quedarse corta—, esto es un Record total sobre una unión cerrada de tres
 * valores: no puede quedarse corto y no necesita un `?? code` de rescate.
 * La diferencia entre las dos tablas no es de estilo: es que una indexa un
 * `string` y la otra una unión.
 */
const SEVERITY_LABELS: Readonly<Record<FindingSeverity, string>> = {
  critical: 'Crítico',
  major: 'Mayor',
  minor: 'Menor',
};

export function severityLabel(severity: FindingSeverity): string {
  return SEVERITY_LABELS[severity];
}

/**
 * El resultado de preguntar "¿esta respuesta genera hallazgo, y de qué
 * gravedad?". Tres casos y no dos, por la misma razón que
 * `TemplateResolution` de la Fase 7 tenía tres: `FindingSeverity | null`
 * metería en la misma bolsa "la respuesta es conforme" —normal y esperado— y
 * "la respuesta no está entre los criterios del ítem" —dato corrupto—, que se
 * diagnostican distinto y se pintan distinto.
 */
export type SeverityDerivation =
  | { readonly status: 'compliant' }
  | { readonly status: 'derived'; readonly severity: FindingSeverity }
  | { readonly status: 'unknown-criterion'; readonly answer: string };

/**
 * ⭐ La regla de negocio central de la fase.
 *
 * `criteria` está documentado desde la Fase 3 como "las respuestas admisibles,
 * en orden de mejor a peor". Ese orden ES la regla: el primero conforma, el
 * último incumple del todo, y los de en medio incumplen a medias.
 *
 * ⚠️ `item` tiene que venir de la versión de plantilla que la inspección
 * GUARDÓ. Con la vigente, esta función devuelve una severidad perfectamente
 * plausible y equivocada, y nadie se entera. Es el incidente 08 de la Fase 7
 * visto desde el otro extremo del sistema.
 */
export function deriveSeverity(item: ChecklistItem, answer: string): SeverityDerivation {
  const index = item.criteria.indexOf(answer);

  if (index === -1) {
    // Ni conforme ni no conforme: es una respuesta que este ítem no admite.
    // Pasa cuando alguien edita db.json a mano, o cuando una respuesta viaja
    // desde otra plantilla. No se inventa una severidad para taparlo.
    return { status: 'unknown-criterion', answer };
  }

  if (index === 0) {
    return { status: 'compliant' };
  }

  // El último criterio es no conformidad plena. Con sólo dos criterios —el
  // `flue-gas` de las calderas— el segundo es también el último, así que no
  // hay degradado y sale la severidad completa del ítem. Es correcto.
  const isFullNonCompliance = index === item.criteria.length - 1;

  return {
    status: 'derived',
    severity: isFullNonCompliance
      ? item.nonComplianceSeverity
      : DOWNGRADED[item.nonComplianceSeverity],
  };
}
```

**Detalles con intención**

- **Pura, sin `Observable` y sin inyecciones.** Recibe un ítem y una cadena. La Fase 12 la va a testear con una tabla de casos y sin `TestBed`, igual que `resolveTemplateVersion` de la Fase 7. Cuando una regla de negocio necesita una petición HTTP para poder probarse, está en el sitio equivocado — y eso es literalmente lo que esta fase viene a arreglar en otros tres sitios.
- **`indexOf` y no un `switch` sobre valores.** Un `switch (answer)` con `'critical_wear'` dentro ataría el código a los criterios de la plantilla de ascensores, y el día que alguien publique una plantilla de tanques habría que volver aquí. El orden del array es el contrato; los valores son datos.
- **El degradado es una tabla, no aritmética sobre un índice.** `SEVERITY_ORDER[index + 1]` funcionaría y se rompería en silencio el día que alguien reordene el array por gusto estético.

**El patrón a memorizar**

> Cuando el dato ya trae un orden, ese orden es una regla de negocio esperando a que alguien la lea. `criteria` estaba ordenado desde la Fase 3 y nadie lo había usado para nada.

**Prueba de fuego**

Cuatro casos, a mano y sin navegador. `main-cable` de la v2 (`critical`, tres criterios): `no_wear` → conforme; `light_wear` → `major`; `critical_wear` → `critical`. Y `flue-gas` de calderas (`major`, dos criterios): `out_of_range` → `major`, sin degradar. Si `light_wear` te da `critical`, se te olvidó el `isFullNonCompliance`; si te da `minor`, estás degradando dos veces.

### 5.2 ⭐ De respuestas a hallazgos, con lo que no se puede derivar aparte

```ts
// src/app/core/domain/inspection-findings.ts
import { ChecklistTemplate } from '../models/checklist-template.model';
import { Finding, FindingSeverity } from '../models/finding.model';
import { Inspection } from '../models/inspection.model';
import { SEVERITY_ORDER, deriveSeverity } from './finding-severity';

/**
 * Un hallazgo tal como lo ve la aplicación: la severidad DERIVADA, más la
 * parte humana que sí está guardada. Los dos casos se distinguen por `kind`,
 * y el compilador se encarga de que nadie lea `severity` esperando un valor
 * donde estructuralmente no puede haberlo.
 */
export type InspectionFinding =
  | {
      readonly kind: 'item';
      readonly itemId: string;
      readonly title: string;
      readonly answer: string;
      /** Derivada. Nunca se lee de la fila guardada. */
      readonly severity: FindingSeverity;
      readonly description: string;
      readonly resolvedAt: string | null;
      /** La fila de `findings`, si existe. Sólo para diagnóstico y para 5.3. */
      readonly stored: Finding | null;
    }
  | {
      readonly kind: 'retired-item' | 'unknown-criterion';
      readonly itemId: string;
      readonly answer: string;
      /**
       * `null` significa "lo calculé y NO HAY severidad", no "no lo miré".
       * En el primer caso porque el ítem ya no está en esta versión de la
       * plantilla; en el segundo porque la respuesta no está entre sus
       * criterios. Las dos veces falta el dato del que saldría la severidad.
       */
      readonly severity: null;
      readonly description: string;
      readonly resolvedAt: string | null;
      readonly stored: Finding | null;
    };

export interface FindingSummary {
  readonly total: number;
  readonly bySeverity: Readonly<Record<FindingSeverity, number>>;
  /** `itemId` de cada `critical` sin resolver. Es lo que bloquea. */
  readonly blocking: readonly string[];
  /** `itemId` de cada hallazgo sin severidad derivable. También bloquea. */
  readonly undetermined: readonly string[];
  readonly canApprove: boolean;
}

/**
 * ⭐ Deriva los hallazgos de una inspección.
 *
 * ⚠️ `template` tiene que ser la versión que la inspección guardó, la que
 * devuelve `getByVersion(inspection.templateId, inspection.templateVersion)`.
 * Es la MISMA advertencia que lleva `buildAnswerForm` de la Fase 8, y por la
 * misma razón: con la plantilla equivocada esta función no falla, miente.
 *
 * `stored` aporta ÚNICAMENTE la parte que no se puede calcular: la
 * descripción que alguien escribió y la fecha en que se resolvió. El campo
 * `severity` de la fila guardada NO se lee nunca. Si difiere de lo derivado,
 * la fila es historia y el cálculo es la verdad de hoy — y saber cuál de las
 * dos estás mirando es media sección 6.
 */
export function deriveFindings(
  template: ChecklistTemplate,
  inspection: Inspection,
  stored: readonly Finding[],
): readonly InspectionFinding[] {
  const itemById = new Map(template.items.map((item) => [item.id, item]));
  // Una fila por ítem: la clave del negocio es (inspectionId, itemId), aunque
  // json-server insista en darle además un `id` numérico propio.
  const storedByItemId = new Map(stored.map((finding) => [finding.itemId, finding]));
  const findings: InspectionFinding[] = [];

  for (const answer of inspection.answers) {
    const item = itemById.get(answer.itemId);
    const row = storedByItemId.get(answer.itemId) ?? null;

    if (item === undefined) {
      // Respuesta huérfana: la Fase 7 decidió que no se borra y la Fase 8 la
      // pinta aparte. Aquí se le da la única lectura honesta posible — hay una
      // no conformidad potencial y el sistema NO sabe de qué gravedad.
      findings.push({
        kind: 'retired-item',
        itemId: answer.itemId,
        answer: answer.answer,
        severity: null,
        description: row?.description ?? 'Respuesta de un ítem retirado en esta versión.',
        resolvedAt: row?.resolvedAt ?? null,
        stored: row,
      });
      continue;
    }

    const derivation = deriveSeverity(item, answer.answer);

    if (derivation.status === 'compliant') {
      continue;
    }

    if (derivation.status === 'unknown-criterion') {
      findings.push({
        kind: 'unknown-criterion',
        itemId: item.id,
        answer: answer.answer,
        severity: null,
        description: `La respuesta "${answer.answer}" no está entre los criterios de "${item.title}".`,
        resolvedAt: row?.resolvedAt ?? null,
        stored: row,
      });
      continue;
    }

    findings.push({
      kind: 'item',
      itemId: item.id,
      title: item.title,
      answer: answer.answer,
      severity: derivation.severity,
      // La descripción sí sale de la fila guardada cuando existe: la escribió
      // una persona y no hay forma de recalcularla. Cuando no existe, se
      // compone una legible en vez de dejar la celda vacía.
      description: row?.description ?? `${item.title}: ${answer.answer}. ${answer.note ?? ''}`.trim(),
      resolvedAt: row?.resolvedAt ?? null,
      stored: row,
    });
  }

  // Lo que bloquea, arriba. Dentro de cada severidad, el orden de la
  // plantilla; los indeterminados, al final, porque son un problema de datos
  // y no de la inspección.
  return [...findings].sort((a, b) => severityRank(a.severity) - severityRank(b.severity));
}

function severityRank(severity: FindingSeverity | null): number {
  return severity === null ? SEVERITY_ORDER.length : SEVERITY_ORDER.indexOf(severity);
}

/**
 * La agregación por inspección, y la única regla que dice que no.
 *
 * Dos cosas bloquean la aprobación, y la segunda sorprende a todo el mundo:
 *
 *   1. Un `critical` sin resolver. Es la regla del `alcance-del-proyecto.md` §5.
 *   2. Un hallazgo cuya severidad NO se pudo derivar. No es celo: certificar
 *      es afirmar que revisaste todo, y aquí hay una respuesta que el sistema
 *      no sabe clasificar. Que decida una persona, no un `?? 'minor'`.
 */
export function summarizeFindings(findings: readonly InspectionFinding[]): FindingSummary {
  const bySeverity: Record<FindingSeverity, number> = { critical: 0, major: 0, minor: 0 };
  const blocking: string[] = [];
  const undetermined: string[] = [];

  for (const finding of findings) {
    if (finding.severity === null) {
      undetermined.push(finding.itemId);
      continue;
    }

    bySeverity[finding.severity] += 1;

    // `=== null` y no `== null`, y esto sólo es seguro porque el borde HTTP de
    // 5.3 normaliza el campo antes de que llegue aquí. Sin esa normalización,
    // esta línea es el incidente 12.
    if (finding.severity === 'critical' && finding.resolvedAt === null) {
      blocking.push(finding.itemId);
    }
  }

  return {
    total: findings.length,
    bySeverity,
    blocking,
    undetermined,
    canApprove: blocking.length === 0 && undetermined.length === 0,
  };
}

/**
 * La puerta que la Fase 10 va a usar para emitir. Se escribe aquí porque la
 * regla es de hallazgos, no de certificados, y porque tenerla escrita permite
 * comprobar hoy que un `critical` bloquea de verdad — sin adelantar una línea
 * de la emisión.
 */
export function canIssueCertificate(
  inspection: Inspection,
  summary: FindingSummary,
): boolean {
  return inspection.status === 'approved' && summary.blocking.length === 0;
}
```

**Detalles con intención**

- **La unión discriminada tiene `severity: FindingSeverity` en una rama y `severity: null` en la otra.** Podría ser un solo tipo con `FindingSeverity | null` y sería peor: la plantilla tendría que preguntar por `null` en cada sitio, y nada impediría escribir un hallazgo de ítem vivo sin severidad. Con dos ramas, ese objeto no se puede construir.
- **`stored` viaja dentro del hallazgo aunque la aplicación no lo use para decidir.** Es lo que permite pintar la divergencia en el ejercicio 3 y diagnosticarla en la sección 6. Un dato que sólo sirve para diagnosticar sigue siendo un dato que vale la pena tener.
- **`undetermined` bloquea, y es una decisión, no una omisión.** La alternativa —dejar pasar lo que no se sabe clasificar— convierte un problema de datos visible en un certificado emitido. El ejercicio 15 te hace vivirlo.

```
💸 DEUDA TÉCNICA INTENCIONAL — los hallazgos se recalculan en cada lectura
Abrir una inspección deriva sus hallazgos otra vez, siempre. No hay caché, no
hay tabla de hallazgos derivados, y la fila de `findings` que sí existe sólo
aporta la descripción y la fecha de resolución.
NO SE PAGA, y por primera vez en el curso eso no es una postergación: es la
decisión correcta y se resuelve aquí mismo. La pregunta que la haría deuda de
verdad —"si la plantilla cambia, ¿cambia el hallazgo histórico?"— tiene
respuesta: NO, porque la derivación usa la versión que la inspección congeló y
ésa no se puede reescribir. Persistir los derivados contradiría el invariante
de la Fase 7 por la puerta de atrás: tendrías dos copias de la misma verdad,
una de ellas escrita con la plantilla de un día concreto, y ninguna forma de
saber cuál mandaba. El ejercicio 25 te hace implementar la alternativa y medir
con dos capturas qué le pasa a una inspección histórica en cada diseño.
Lo que sí cuesta: dos peticiones por inspección. Con treinta inspecciones en el
dashboard son sesenta, y eso es un problema real que la FASE 11 va a medir.
```

**Prueba de fuego**

Deriva la `503` sin abrir el navegador: cuatro respuestas, dos hallazgos. `main-cable: critical_wear` → `critical`; `cabin-lighting: partial` → `minor`; `emergency-brake: ok` y `door-sensor: ok` → nada. `blocking` trae `['main-cable']` y `canApprove` es `false`. Ahora la `502`: dos respuestas, las dos en el primer criterio, cero hallazgos, `canApprove` verdadero. Si la `502` te da algún hallazgo, tienes el `index === 0` mal puesto.

### 5.3 El borde HTTP, donde se arregla el bug antes de que exista

```ts
// src/app/core/api/finding-api.service.ts
import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, catchError, map } from 'rxjs';

import { environment } from '../../../environments/environment';
import { Finding } from '../models/finding.model';
import { toApiError } from './api-error';

@Injectable({ providedIn: 'root' })
export class FindingApiService {
  private readonly http = inject(HttpClient);

  private readonly baseUrl = `${environment.apiBaseUrl}/findings`;

  /**
   * `/findings?inspectionId=503` y no `/inspections/503/findings`: las dos
   * rutas las sirve json-server porque `findings` es colección de primer nivel
   * con `inspectionId` dentro, y la de query param es la que acepta filtros
   * adicionales sin cambiar de forma. La otra sigue existiendo y la usa el
   * `getFindings()` que la Fase 8 dejó escrito en InspectionApiService.
   */
  getByInspection(inspectionId: number): Observable<readonly Finding[]> {
    const params = new HttpParams().set('inspectionId', inspectionId);

    return this.http
      .get<readonly Finding[]>(this.baseUrl, { params })
      .pipe(map((rows) => rows.map(normalizeFinding)), catchError(toApiError));
  }

  /** Marcar resuelto es poner una fecha. No hay más flujo, y es a propósito. */
  resolve(id: number, resolvedAt: string): Observable<Finding> {
    return this.http
      .patch<Finding>(`${this.baseUrl}/${id}`, { resolvedAt })
      .pipe(map(normalizeFinding), catchError(toApiError));
  }

  /** Reabrir es quitarla. `null` explícito, nunca borrar el campo del objeto. */
  reopen(id: number): Observable<Finding> {
    return this.http
      .patch<Finding>(`${this.baseUrl}/${id}`, { resolvedAt: null })
      .pipe(map(normalizeFinding), catchError(toApiError));
  }
}

/**
 * ⭐ EL ARREGLO DEL INCIDENTE 12, Y CABE EN UNA LÍNEA.
 *
 * `http.get<Finding[]>()` no comprueba nada: el genérico es una promesa del
 * programador, no una validación. Si el backend manda una fila SIN el campo
 * `resolvedAt`, entra como `undefined` en un objeto que el tipo declara como
 * `string | null`, y todo compila.
 *
 * A partir de ahí, `resolvedAt === null` devuelve `false` para un hallazgo que
 * nadie resolvió jamás, el `critical` deja de bloquear, y el certificado sale.
 * `strict` no lo ve porque el mentiroso está fuera de TypeScript.
 *
 * La regla del proyecto es la que fijó la Fase 3 con su guarda de forma:
 * las tres posibilidades del borde —valor, `null` y campo ausente— se reducen
 * a DOS aquí, en un solo sitio, y el resto de la aplicación ya sólo distingue
 * `string` de `null`. El `??` es de una línea; el bug que evita costó una
 * semana en el cuaderno.
 */
function normalizeFinding(raw: Finding): Finding {
  return { ...raw, resolvedAt: raw.resolvedAt ?? null };
}
```

**Detalles con intención**

- **La normalización va en el servicio de API y no en el dominio.** El dominio tiene derecho a confiar en sus tipos; el que habla con el mundo exterior, no. Meter un `?? null` defensivo en `summarizeFindings` sería tapar el mismo agujero en el sitio equivocado y en todos los sitios a la vez.
- **`reopen()` manda `null` explícito y no borra la propiedad.** Un `PATCH` con `{}` dejaría el campo como estaba; uno que quitara la clave produciría exactamente la fila corrupta que este archivo existe para tolerar. Se escribe el `null`.

### 5.4 💸 El pago, primera mitad: las reglas se escriben puras

La Fase 6 dejó una deuda con nombre y fecha de cobro: *"un activo no puede cambiar de cliente"* escrita como un control deshabilitado dentro de `AssetFormComponent`. La Fase 8 dejó otras dos en pantallas —qué familia de plantilla corresponde a cada tipo de activo, y cuándo se puede cerrar una inspección—. **Son tres, son la misma clase de regla, y el argumento de la prisa ya no se sostiene.**

Antes de mudarlas conviene ver qué tienen en común, porque no es que estén "en el componente": es que **existen sólo dentro de una pantalla**. Un alta por lote, un import de CSV o la pantalla que escribas el mes que viene se las saltan sin enterarse, porque la regla no está en ningún sitio donde se pueda consultar.

El pago tiene dos mitades y conviene no confundirlas. Primero se **escriben puras**, en `core/domain/`, donde se pueden leer y testear. Después —5.5— alguien las **hace cumplir**, y ése es el servicio. Una regla pura que nadie invoca es documentación; una regla dentro de un `if` de un componente es un accidente esperando.

```ts
// src/app/core/domain/asset-rules.ts
import { Asset, AssetType } from '../models/asset.model';

/**
 * Qué familia de plantilla le corresponde a cada tipo de activo. Venía de la
 * Fase 8, donde vivía dentro de `InspectionStartComponent` con un comentario
 * que decía "si mañana la comparte otra pantalla, se muda". Mañana es hoy: la
 * usan la pantalla de empezar y, desde esta fase, el servicio de plantillas.
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
 * Ahora es una función que cualquiera puede llamar y que la Fase 12 puede
 * testear en tres líneas.
 *
 * Devuelve un booleano y no lanza: decidir si esto es un error, un aviso o un
 * control deshabilitado es de quien llama. La regla sólo sabe de negocio.
 */
export function changesClient(current: Asset, next: Asset): boolean {
  return current.clientId !== next.clientId;
}
```

```ts
// src/app/core/domain/inspection-rules.ts
import { Inspection, InspectionStatus } from '../models/inspection.model';

/**
 * Las dos transiciones que esta fase estrena. `completed` la escribió la Fase
 * 8; `approved` y `rejected` no existían todavía porque dependen de los
 * hallazgos.
 *
 * Se escribe como un mapa de estado → estados alcanzables y no como una
 * cadena de `if`, porque así la máquina de estados del
 * `alcance-del-proyecto.md` §5 se puede LEER en el código, que es media
 * defensa contra que alguien añada una transición por descuido.
 */
const ALLOWED_TRANSITIONS: Readonly<Record<InspectionStatus, readonly InspectionStatus[]>> = {
  requested: ['scheduled'],
  scheduled: ['in_progress'],
  in_progress: ['completed'],
  completed: ['approved', 'rejected'],
  // Los dos finales. Aprobar es irreversible (alcance §5) y rechazar también:
  // una inspección rechazada se repite, no se corrige.
  approved: [],
  rejected: [],
};

export function canTransition(from: InspectionStatus, to: InspectionStatus): boolean {
  return ALLOWED_TRANSITIONS[from].includes(to);
}

/**
 * ⭐ La herencia incómoda de la Fase 8, resuelta. Hoy la inspección 501 —
 * aprobada en agosto de 2023 — se abre y se edita como cualquier otra, y el
 * `alcance-del-proyecto.md` §5 dice que aprobar es irreversible.
 *
 * La regla es de una línea. Lo interesante es dónde se hace cumplir, y la
 * respuesta es "en tres sitios con tres papeles distintos" — 5.5 y 5.8.
 */
export function isEditable(inspection: Inspection): boolean {
  return inspection.status !== 'approved' && inspection.status !== 'rejected';
}

/**
 * Un error de REGLA DE NEGOCIO, que no es un error de red y no debe pintarse
 * como uno. `ApiError` de la Fase 3 significa "el backend falló y quizá
 * reintentando funcione"; esto significa "el sistema funcionó perfectamente y
 * la respuesta es no". Un usuario que ve "Error 500" cuando le faltaba
 * resolver un hallazgo vuelve a pulsar el botón cuatro veces.
 *
 * El mensaje va en español porque va dirigido a una persona, igual que los
 * mensajes de la Fase 1.
 */
export class BusinessRuleError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'BusinessRuleError';
  }
}
```

### 5.5 💸 El pago, segunda mitad: alguien las hace cumplir

```ts
// src/app/core/state/asset-state.service.ts — lo que cambia
  /**
   * 🪦 LA DEUDA DE LA FASE 6, PAGADA — segunda mitad, y la que importa.
   *
   * La regla ya no depende de que la pantalla deshabilite un control. Si
   * mañana llega el import de CSV, pasa por aquí y la regla se cumple sin que
   * nadie se acuerde de ella.
   */
  update(next: Asset): Observable<Asset> {
    const current = this.stateSubject.value.items.find((asset) => asset.id === next.id);

    if (current !== undefined && changesClient(current, next)) {
      // throwError y no un `return of(current)` silencioso: una regla que se
      // salta sin avisar es peor que una que no existe, porque el que la
      // intentó saltar cree que funcionó.
      return throwError(
        () =>
          new BusinessRuleError(
            'Un activo no puede cambiar de cliente. Da de baja el activo y créalo en el cliente nuevo.',
          ),
      );
    }

    return this.assetApi.update(next).pipe(tap(() => this.load()));
  }
```

```ts
// src/app/features/assets/asset-form/asset-form.component.ts — lo que cambia
  ngOnInit(): void {
    // …carga del activo en modo edición…

    // El control sigue deshabilitado, y ahora eso es lo que siempre debió
    // ser: interfaz de usuario. No hay nada que explicar en un comentario
    // porque ya no hay ninguna regla escondida aquí — la regla vive en
    // AssetStateService y este `disable()` sólo evita que alguien intente
    // algo que el servicio le va a negar.
    if (this.isEdit) {
      this.form.controls.clientId.disable();
    }
  }
```

**Y el efecto colateral que la Fase 6 anunció y no arregló:** deshabilitar un control lo saca de `form.value`. El `submit()` ya usaba `getRawValue()` —la Fase 6 lo dejó escrito con su ⚠️ puesta— así que el activo sigue viajando con su `clientId`. Lo que cambia hoy es que **eso ya no es lo que sostiene la regla**: si alguien mañana escribe `this.form.value` por costumbre, el `PUT` sale sin `clientId`, el servicio compara `undefined` con el actual, detecta un cambio de cliente y se niega con un mensaje legible. Antes, el activo se quedaba huérfano en silencio.

```ts
// src/app/core/state/template-state.service.ts — lo que se añade
  /**
   * ¿Qué versión rige HOY para este activo? Es `resolveForDay` con la regla de
   * negocio del tipo de activo delante, y vive aquí porque la pregunta es de
   * plantillas y porque `InspectionStartComponent` ya no es la única que la
   * hace: la Fase 11 va a preguntarla para el dashboard.
   */
  resolveForAsset(asset: Asset, day: BusinessDay): Observable<TemplateResolution> {
    return this.resolveForDay(templateIdForAssetType(asset.type), day);
  }
```

**Detalles con intención**

- **Las tres reglas no acabaron en el mismo archivo.** `changesClient` y `templateIdForAssetType` hablan de activos; `canTransition` e `isEditable` hablan de inspecciones. Juntarlas en un `business-rules.ts` porque "son la misma clase de cosa" produce el archivo de 400 líneas que en dos años nadie se atreve a tocar. La clase es la misma; el dominio, no.
- **La tercera regla —`canComplete`— no se mudó, porque ya estaba pura.** `computeProgress` de la Fase 8 vive en `core/domain/` desde el primer día. Lo que le faltaba era que alguien la **hiciera cumplir** fuera de la pantalla, y eso es 5.6. Es la distinción que ordena toda esta sección: escribir la regla pura y hacerla cumplir son dos trabajos distintos, y una fase que sólo haga el primero no ha pagado nada.
- **`BusinessRuleError` no hereda de `ApiError`.** Son dos cosas distintas y el componente las distingue con `instanceof` para decidir si ofrece "reintentar" o no.

**El patrón a memorizar**

> Una regla de negocio se escribe pura donde se pueda leer, y se hace cumplir donde no se pueda esquivar. Si sólo haces lo primero, tienes documentación; si sólo haces lo segundo, tienes un `if` que nadie puede probar.

### 5.6 La máquina de estados, por fin completa

```ts
// src/app/core/state/inspection-state.service.ts — lo que se añade
  private readonly templateApi = inject(TemplateApiService);
  private readonly findingApi = inject(FindingApiService);

  /**
   * Los hallazgos de una inspección, derivados. Es una CONSULTA y no estado:
   * no se guarda en el BehaviorSubject, igual que `resolveForDay` de la Fase 7
   * no guardaba su resolución. Un derivado dentro del estado es el mismo error
   * que un derivado dentro de la base de datos, sólo que más rápido de cometer.
   */
  findingsOf(inspection: Inspection): Observable<readonly InspectionFinding[]> {
    return combineLatest([
      // 🧭 La versión que la inspección GUARDÓ. Es la tercera vez que esta
      // línea aparece en el curso —Fase 7 §5.9, Fase 8 §5.5, y aquí— y es la
      // misma línea las tres veces. Cuando algo se repite idéntico tres veces
      // sin que nadie lo abstraiga, normalmente es porque abstraerlo lo
      // volvería más fácil de olvidar.
      this.templateApi.getByVersion(inspection.templateId, inspection.templateVersion),
      this.findingApi.getByInspection(inspection.id),
    ]).pipe(map(([template, stored]) => deriveFindings(template, inspection, stored)));
  }

  /**
   * Cerrar la inspección. La condición ya la calculaba `computeProgress` desde
   * la Fase 8; lo nuevo es que ahora se comprueba AQUÍ y no sólo en el
   * `[disabled]` de un botón. Un botón deshabilitado es una cortesía; esto es
   * la regla.
   */
  complete(inspection: Inspection, answers: readonly InspectionAnswer[]): Observable<Inspection> {
    if (!canTransition(inspection.status, 'completed')) {
      return throwError(
        () => new BusinessRuleError(`Una inspección ${inspection.status} no se puede completar.`),
      );
    }

    return this.templateApi
      .getByVersion(inspection.templateId, inspection.templateVersion)
      .pipe(
        // concatMap y no switchMap: detrás viene una ESCRITURA. Regla de la
        // Fase 6, y ya no hace falta justificarla.
        concatMap((template) => {
          const progress = computeProgress(template, answers);

          return progress.canComplete
            ? this.inspectionApi.complete(inspection.id, answers, new Date().toISOString())
            : throwError(
                () =>
                  new BusinessRuleError(
                    `Faltan ${progress.total - progress.answered} respuestas o la evidencia de ${progress.missingEvidence.join(', ')}.`,
                  ),
              );
        }),
        tap(() => this.load()),
      );
  }

  /**
   * ⭐ APROBAR. La operación que esta fase existe para poder negar.
   *
   * Aprobar es irreversible (alcance §5), así que la comprobación no puede
   * vivir en la pantalla: tiene que estar en el camino por el que pasa
   * cualquiera que apruebe, hoy y dentro de dos años.
   */
  approve(inspection: Inspection): Observable<Inspection> {
    return this.decide(inspection, 'approved');
  }

  /** Rechazar. Misma puerta, distinta salida: aquí los hallazgos no bloquean. */
  reject(inspection: Inspection): Observable<Inspection> {
    return this.decide(inspection, 'rejected');
  }

  private decide(inspection: Inspection, to: 'approved' | 'rejected'): Observable<Inspection> {
    if (!canTransition(inspection.status, to)) {
      return throwError(
        () =>
          new BusinessRuleError(
            `Una inspección ${inspection.status} no se puede pasar a ${to}. Sólo se decide sobre inspecciones completadas.`,
          ),
      );
    }

    // Rechazar NO se comprueba contra los hallazgos: se rechaza precisamente
    // porque hay problemas. Comprobar aquí sería impedir rechazar una
    // inspección con un hallazgo crítico, que es la única que hay que rechazar.
    if (to === 'rejected') {
      return this.inspectionApi.setStatus(inspection.id, 'rejected').pipe(tap(() => this.load()));
    }

    return this.findingsOf(inspection).pipe(
      map(summarizeFindings),
      concatMap((summary) => {
        if (summary.blocking.length > 0) {
          return throwError(
            () =>
              new BusinessRuleError(
                `No se puede aprobar: hay hallazgos críticos sin resolver en ${summary.blocking.join(', ')}.`,
              ),
          );
        }

        if (summary.undetermined.length > 0) {
          return throwError(
            () =>
              new BusinessRuleError(
                `No se puede aprobar: el sistema no pudo clasificar las respuestas de ${summary.undetermined.join(', ')}. Revísalas antes de decidir.`,
              ),
          );
        }

        return this.inspectionApi.setStatus(inspection.id, 'approved');
      }),
      tap(() => this.load()),
    );
  }
```

```ts
// src/app/core/api/inspection-api.service.ts — lo que se añade
  /**
   * Un PATCH de un solo campo. Deliberadamente no acepta cualquier estado:
   * el tipo lo limita a los dos que esta fase estrena, y las otras dos
   * transiciones tienen sus propios métodos —`create` nace `scheduled`,
   * `saveAnswers` mueve a `in_progress`, `complete` a `completed`—.
   * Un `setStatus(id, status: InspectionStatus)` genérico sería un método que
   * permite cualquier transición desde cualquier sitio, que es justo lo que
   * `canTransition` existe para impedir.
   */
  setStatus(id: number, status: 'approved' | 'rejected'): Observable<Inspection> {
    return this.http
      .patch<Inspection>(`${this.baseUrl}/${id}`, { status })
      .pipe(catchError(toApiError));
  }
```

**Detalles con intención**

- **`reject()` no mira los hallazgos y `approve()` sí.** Parece una asimetría fea y es la regla correcta: si rechazar exigiera que no hubiera críticos, la única inspección que hay que rechazar sería la única que no se puede rechazar. Vale la pena leerlo dos veces.
- **`decide()` es privado y los dos métodos públicos son de una línea.** El nombre de la operación es lo que se lee desde fuera; el hecho de que compartan tubería es asunto del archivo.
- **La comprobación de `canTransition` va antes que la petición de hallazgos.** Preguntar por los hallazgos de una inspección `scheduled` para después decirle al usuario que no se puede aprobar es dos peticiones de red por un `if` que se podía hacer con lo que ya tienes en memoria.

**Prueba de fuego**

Con el mock levantado, responde los cuatro ítems de la `500` dejando `main-cable` en `light_wear`, complétala y apruébala: pasa. Ahora vuelve a `db.json`, deja la `500` en `completed`, cambia `main-cable` a `critical_wear` y prueba a aprobar: el mensaje nombra `main-cable` y no sale ningún `PATCH` en Network. **Ese `PATCH` que no sale es el entregable de la fase.**

### 5.7 La pantalla de hallazgos

```ts
// src/app/features/inspections/inspection-findings/inspection-findings.component.ts
import { AsyncPipe, NgFor, NgIf } from '@angular/common';
import { ChangeDetectionStrategy, Component, DestroyRef, inject } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { ActivatedRoute } from '@angular/router';
import { Observable, Subject, combineLatest, filter, map, startWith, switchMap } from 'rxjs';

import { ApiError } from '../../../core/api/api-error';
import { InspectionApiService } from '../../../core/api/inspection-api.service';
import { FindingApiService } from '../../../core/api/finding-api.service';
import { severityLabel } from '../../../core/domain/finding-severity';
import { BusinessRuleError, isEditable } from '../../../core/domain/inspection-rules';
import {
  FindingSummary,
  InspectionFinding,
  summarizeFindings,
} from '../../../core/domain/inspection-findings';
import { InspectionStateService } from '../../../core/state/inspection-state.service';
import { Inspection } from '../../../core/models/inspection.model';

interface FindingsView {
  readonly inspection: Inspection;
  readonly findings: readonly InspectionFinding[];
  readonly summary: FindingSummary;
  readonly editable: boolean;
}

@Component({
  selector: 'cc-inspection-findings',
  standalone: true,
  imports: [AsyncPipe, NgFor, NgIf, MatButtonModule, MatIconModule, MatSnackBarModule],
  templateUrl: './inspection-findings.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class InspectionFindingsComponent {
  private readonly route = inject(ActivatedRoute);
  private readonly inspectionApi = inject(InspectionApiService);
  private readonly findingApi = inject(FindingApiService);
  private readonly inspectionState = inject(InspectionStateService);
  private readonly snackBar = inject(MatSnackBar);
  private readonly destroyRef = inject(DestroyRef);

  readonly severityLabel = severityLabel;

  /** Un disparo para recargar después de resolver un hallazgo. */
  private readonly reload = new Subject<void>();

  /**
   * Misma forma que la vista de la Fase 8: se DERIVA de la ruta, así que
   * cambiar de inspección no deja nada de la anterior. La lección del
   * incidente 10 se aplica aunque aquí no haya formulario que corromper.
   */
  readonly view$: Observable<FindingsView> = combineLatest([
    this.route.paramMap.pipe(
      map((params) => Number(params.get('id'))),
      filter((id) => Number.isInteger(id)),
    ),
    this.reload.pipe(startWith(undefined)),
  ]).pipe(
    switchMap(([id]) => this.inspectionApi.getById(id)),
    switchMap((inspection) =>
      this.inspectionState.findingsOf(inspection).pipe(
        map((findings) => ({
          inspection,
          findings,
          summary: summarizeFindings(findings),
          editable: isEditable(inspection),
        })),
      ),
    ),
  );

  resolve(finding: InspectionFinding): void {
    if (finding.stored === null) {
      // Un hallazgo derivado que nunca se guardó no tiene fila que marcar.
      // Crearla aquí sería empezar a persistir derivados por la puerta de
      // atrás; el ejercicio 19 decide qué hacer y por qué es una decisión.
      this.snackBar.open(
        'Este hallazgo se derivó de las respuestas y no tiene registro propio todavía.',
        'Cerrar',
        { duration: 6000 },
      );
      return;
    }

    this.findingApi
      .resolve(finding.stored.id, new Date().toISOString())
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe({
        next: () => this.reload.next(),
        error: (error: unknown) => this.report(error, 'No se pudo marcar el hallazgo.'),
      });
  }

  approve(view: FindingsView): void {
    this.inspectionState
      .approve(view.inspection)
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe({
        next: () => {
          this.snackBar.open('Inspección aprobada.', 'Cerrar', { duration: 4000 });
          this.reload.next();
        },
        error: (error: unknown) => this.report(error, 'No se pudo aprobar la inspección.'),
      });
  }

  reject(view: FindingsView): void {
    this.inspectionState
      .reject(view.inspection)
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe({
        next: () => {
          this.snackBar.open('Inspección rechazada.', 'Cerrar', { duration: 4000 });
          this.reload.next();
        },
        error: (error: unknown) => this.report(error, 'No se pudo rechazar la inspección.'),
      });
  }

  /**
   * Los dos errores no se cuentan igual, y ésta es la razón de que
   * `BusinessRuleError` exista. Una regla que dice que no se muestra el tiempo
   * suficiente para leerla; un error de red se muestra y se puede reintentar.
   */
  private report(error: unknown, fallback: string): void {
    if (error instanceof BusinessRuleError) {
      this.snackBar.open(error.message, 'Entendido', { duration: 10000 });
      return;
    }

    this.snackBar.open(error instanceof ApiError ? error.message : fallback, 'Cerrar', {
      duration: 6000,
    });
  }
}
```

```html
<!-- src/app/features/inspections/inspection-findings/inspection-findings.component.html -->
<ng-container *ngIf="view$ | async as view">
  <header class="findings-header">
    <h2>Hallazgos de la inspección {{ view.inspection.id }}</h2>
    <p>Estado: {{ view.inspection.status }}</p>

    <!-- El banner de bloqueo. Dice QUÉ bloquea, no sólo que algo bloquea: un
         "no se puede aprobar" a secas es el ticket de la Fase 6 otra vez. -->
    <p class="findings-blocked" *ngIf="view.summary.blocking.length > 0">
      Esta inspección no se puede aprobar: hay
      {{ view.summary.blocking.length }} hallazgo(s) crítico(s) sin resolver.
    </p>
    <p class="findings-blocked" *ngIf="view.summary.undetermined.length > 0">
      Hay respuestas que el sistema no pudo clasificar. Revísalas antes de decidir.
    </p>
    <p *ngIf="view.summary.total === 0">Sin hallazgos. Todas las respuestas son conformes.</p>
  </header>

  <ul class="findings-list">
    <li *ngFor="let finding of view.findings" [class.finding-resolved]="finding.resolvedAt !== null">
      <!-- La rama con severidad. El compilador sabe que aquí `severity` no es
           null porque `kind` lo discrimina. -->
      <ng-container *ngIf="finding.kind === 'item'">
        <strong>{{ severityLabel(finding.severity) }}</strong> ·
        {{ finding.title }} — {{ finding.description }}
        <em *ngIf="finding.resolvedAt !== null">Resuelto el {{ finding.resolvedAt }}</em>
        <button
          mat-button
          *ngIf="finding.resolvedAt === null && view.editable"
          (click)="resolve(finding)"
        >
          Marcar resuelto
        </button>
      </ng-container>

      <!-- La rama sin severidad, y se ve distinta a propósito: no es un
           hallazgo leve, es un hallazgo que no se pudo clasificar. -->
      <ng-container *ngIf="finding.kind !== 'item'">
        <strong>Sin clasificar</strong> · {{ finding.itemId }} — {{ finding.description }}
      </ng-container>
    </li>
  </ul>

  <footer *ngIf="view.inspection.status === 'completed'">
    <button
      mat-raised-button
      color="primary"
      [disabled]="!view.summary.canApprove"
      (click)="approve(view)"
    >
      Aprobar
    </button>
    <!-- Rechazar NUNCA está deshabilitado. Es la salida de la inspección que
         no se puede aprobar, y bloquearla dejaría el trabajo en un limbo. -->
    <button mat-stroked-button color="warn" (click)="reject(view)">Rechazar</button>
  </footer>
</ng-container>
```

**Detalles con intención**

- **El botón "Aprobar" está deshabilitado y el servicio también se niega.** Es redundante y es correcto: lo primero es cortesía con el usuario, lo segundo es la regla. Quítale el `[disabled]` y comprueba que sigue sin poder aprobar — es el ejercicio 13.
- **`view.editable` esconde el botón de resolver en una inspección aprobada.** Marcar un hallazgo como resuelto sobre una inspección cerrada cambiaría el pasado, y ésa es la política que el ejercicio 24 te hace escribir entera.

### 5.8 🧬 La costura, y el candado de sólo lectura

```ts
// src/app/core/guards/inspection-editable.guard.ts
import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { map, of, switchMap } from 'rxjs';

import { InspectionApiService } from '../api/inspection-api.service';
import { isEditable } from '../domain/inspection-rules';

/**
 * Guard funcional, como los de la Fase 2. No decide nada por su cuenta: le
 * pregunta a la misma función pura que usa el servicio, y si la respuesta es
 * no, redirige a los hallazgos en vez de dejar la pantalla en blanco.
 *
 * ⚠️ Y esto hay que decirlo aunque duela: **un guard no es seguridad.** Corre
 * en el navegador y cualquiera con las DevTools abiertas lo esquiva. Lo que
 * impide de verdad editar una inspección aprobada es que
 * `InspectionStateService` se niegue, y ni siquiera eso es seguridad — lo
 * sería una comprobación en el backend, que CertCore no tiene y este curso no
 * construye. El guard es experiencia de usuario: evita que alguien escriba
 * veinte minutos en un formulario que no se va a guardar.
 */
export const inspectionEditableGuard: CanActivateFn = (route) => {
  const router = inject(Router);
  const inspectionApi = inject(InspectionApiService);
  const id = Number(route.paramMap.get('id'));

  if (!Number.isInteger(id)) {
    return of(router.createUrlTree(['/inspections']));
  }

  return inspectionApi
    .getById(id)
    .pipe(
      map((inspection) =>
        isEditable(inspection) ? true : router.createUrlTree(['/inspections', id, 'findings']),
      ),
    );
};
```

```ts
// src/app/features/inspections/inspections-routing.module.ts
// 🧬 RouterModule.forChild() de 2021, componentes standalone de 2025, y ahora
// dos guards funcionales en la misma ruta. Es la cuarta vez que aparece este
// patrón en el curso y ya no lleva explicación: lleva marcador.
const routes: Routes = [
  { path: '', component: InspectionListComponent },
  { path: 'new', component: InspectionStartComponent },
  {
    path: ':id',
    component: InspectionFormComponent,
    // canActivate corre ANTES de construir el componente; canDeactivate, al
    // salir. Los dos son funcionales y ninguno sabe del otro.
    canActivate: [inspectionEditableGuard],
    canDeactivate: [unsavedChangesGuard],
  },
  // Sin guard: los hallazgos de una inspección aprobada se leen siempre.
  { path: ':id/findings', component: InspectionFindingsComponent },
];
```

```ts
// src/app/features/inspections/inspections.module.ts
@NgModule({
  declarations: [InspectionListComponent],
  imports: [
    SharedModule,
    InspectionsRoutingModule,
    EmptyStateComponent,
    InspectionFormComponent,
    InspectionStartComponent,
    // 🧬 La tercera pantalla standalone alojada por el mismo NgModule heredado.
    InspectionFindingsComponent,
  ],
})
export class InspectionsModule {}
```

`InspectionListComponent` se toca **lo mínimo y en su estilo**: sigue con `constructor`, sigue sin `OnPush`, sigue declarado. Sólo añade una columna con la severidad máxima de cada inspección y un enlace a sus hallazgos. Sin `inject()`, sin standalone, sin modernizar de paso.

> 🧭 **Regla del proyecto, ya en su cuarta aparición:** el archivo que existía se toca lo mínimo y en su estilo; el que nace hoy nace standalone. Y el punto donde se tocan lleva 🧬 para que la próxima persona sepa que está así a propósito.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Síntoma:** una inspección con un hallazgo `critical` visible en pantalla se aprueba sin protestar.
**Causa:** el `resolvedAt` de esa fila no llegó del backend. `finding.resolvedAt === null` da `false` para `undefined`, así que el hallazgo cuenta como resuelto.
**Fix mínimo:** cambiar `=== null` por `== null`, que cubre los dos. Un carácter.
**Lo que importa:** el fix mínimo funciona y es lo que escribes un viernes; la corrección correcta es el `?? null` del borde HTTP de 5.3, porque tapa el agujero **una vez** en lugar de en cada sitio que lea el campo. Es el **incidente 12**, y su lección es que `strict` protege el interior de la aplicación y no dice ni una palabra de lo que entra por HTTP. La Fase 3 ya lo avisó con su guarda de forma; hoy se paga por no haberla extendido.

**Síntoma:** una inspección de 2023 cambia de hallazgos después de publicar la v3 de la plantilla.
**Causa:** los hallazgos se derivan con la plantilla vigente en vez de con `getByVersion(templateId, templateVersion)`.
**Fix mínimo:** una línea, la misma de la Fase 7 §5.9 y la Fase 8 §5.5.
**Lo que importa:** es el invariante central del curso rompiéndose por tercera vez en tres fases distintas, y siempre por la misma línea. Que derivar sea seguro depende **por completo** de que las entradas sean inmutables: con la plantilla vigente, derivar hallazgos es la peor decisión de arquitectura que este curso podría tomar.

**Síntoma:** el botón "Aprobar" está deshabilitado y nadie sabe por qué; el usuario prueba a recargar tres veces.
**Causa:** el `[disabled]` refleja `canApprove` y la pantalla no dice qué lo bloquea.
**Fix mínimo:** el banner de 5.7, que nombra los `itemId`.
**Lo que importa:** es la pieza forense de la Fase 6 otra vez —*"no me deja guardar y no dice por qué"*— y por eso `FindingSummary` lleva `blocking` y `undetermined` como arrays de `itemId` y no como booleanos. Un booleano no puede escribir un mensaje útil.

**Síntoma:** al intentar aprobar sale un snackbar que dice "Error 500" y el usuario lo reintenta cuatro veces.
**Causa:** el componente trata un `BusinessRuleError` como si fuera un `ApiError`.
**Fix mínimo:** el `instanceof` de `report()` en 5.7.
**Lo que importa:** "el sistema falló" y "el sistema funcionó y la respuesta es no" son mensajes opuestos, y confundirlos entrena al usuario a reintentar cuando lo que tiene que hacer es resolver un hallazgo. Es la clase de bug que ningún test detecta y que todo soporte de primer nivel conoce.

### Pieza forense de esta fase

**`null` frente a `undefined` bajo `strict`: el hallazgo que existía y no bloqueó nada.**

El ticket llega así: *"aprobé la inspección del ascensor de la torre A y el sistema me dejó, pero el cable está para cambiar."* No hay error en consola, no hay nada rojo en Network, y la pantalla de hallazgos muestra el `critical` perfectamente.

Tres pasos, y ninguno pasa por leer el código:

**Paso 1 — Network, no consola.** Abre la petición a `/findings?inspectionId=…` y mira el **JSON crudo de la respuesta**, no lo que pinta la pantalla. Compara las claves de cada fila. Si una no trae `resolvedAt`, ya lo tienes: el tipo `Finding` la declara y el backend no la manda, y entre esas dos afirmaciones no hay nadie comprobando nada.

**Paso 2 — La consola, para confirmar la diferencia.** Con la pantalla abierta, selecciona el `<li>` del hallazgo y en la consola:

```js
const component = ng.getComponent($0);
// Las tres preguntas, y sus tres respuestas distintas:
finding.resolvedAt === null;    // false — y aquí nace el bug
finding.resolvedAt == null;     // true  — cubre null Y undefined
'resolvedAt' in finding;        // false — el campo NO EXISTE
```

Esas tres líneas son toda la fase en tres respuestas. La primera es la que escribiste; la segunda es el fix del viernes; la tercera es la que te dice de dónde vino.

**Paso 3 — Dónde ponerlo.** El `?? null` puede ir en tres sitios: en el componente, en `summarizeFindings`, o en el servicio de API. Los tres funcionan hoy. Sólo uno de los tres sigue funcionando cuando la Fase 10 lea el mismo campo para decidir si emite el certificado, y cuando la Fase 11 lo lea para contar hallazgos abiertos en el dashboard. Ponerlo en el borde no es elegancia: es no tener que acordarte dos fases más adelante.

> 📄 El recorrido completo, con los dos tickets literales y la salida de cada paso, en `forense-fase-09.md`.

**🧨 Rompe a propósito**

Dos roturas de una línea cada una.

1. **Borra el campo `resolvedAt` de la fila `902` en `db.json`** y abre `/inspections/501/findings`. El hallazgo `major` de `door-sensor` aparece como **no resuelto** o como **resuelto** según dónde tengas el `??`. Quita el `normalizeFinding` de 5.3, recarga, y observa que la pantalla dice una cosa y `db.json` dice otra sin que nada falle. Ahora haz lo mismo con la fila `900` —el `critical` de la `503`— pon la inspección en `completed`, y comprueba que se puede aprobar. Ése es el certificado que no debería existir.

2. **Cambia el `getByVersion(inspection.templateId, inspection.templateVersion)` de `findingsOf()` por `latestVersions$`** y abre la `501`, que es de 2023 y v1. El hallazgo de `door-sensor` cambia de severidad porque lo está derivando con la v2. Ni un error, ni una advertencia: sólo un informe de certificación que dice algo distinto a lo que decía ayer. Compara este error con el de la Fase 7 —allí cambiaba el número de ítems, aquí cambia la gravedad— y decide cuál de los dos habrías detectado antes.

---

## 🧪 7. Ejercicios (26)

**🟢 Fácil (1–7)**

1. Escribe `deriveSeverity` y córrela contra los cuatro ítems de `elevator-annual-v2`, con los tres criterios de cada uno. Entrega una tabla de doce filas: ítem, respuesta, resultado. Debe haber exactamente cuatro `compliant`.
2. **Diagnóstico.** Deriva a mano los hallazgos de la inspección `503` y compáralos con las filas `900` y `901` de `db.json`. Anota cuáles coinciden y cuáles no.
3. **Diagnóstico.** Haz lo mismo con la `501` (v1) y la fila `902`, y con la `500` (v2) y la fila `903`. Las dos divergen. Escribe en tres frases cuál de los dos números es la verdad de hoy y por qué la fila guardada no está "mal".
4. Implementa `severityLabel` y pinta las tres etiquetas. Después borra una entrada del `Record` y anota el error de compilación exacto: es la diferencia con el `criterionLabel` de la Fase 8.
5. **Diagnóstico.** Abre `/inspections/500`, que está `in_progress` con una sola respuesta. Anota cuántos hallazgos derivados salen y explica por qué una inspección a medias ya tiene hallazgos y aun así no se puede aprobar.
6. Deriva `flue-gas` de `boiler-annual-v1`, que tiene sólo dos criterios: `out_of_range` da `major` y no `minor`. Explica en dos frases qué línea de `deriveSeverity` produce esa diferencia.
7. Escribe `FindingApiService.getByInspection` y compruébalo con `curl` contra la `503`. Confirma que las dos filas que devuelve traen `resolvedAt` y que una de ellas es `null`.

**🟡 Intermedio (8–15)**

8. Implementa `deriveFindings` y `summarizeFindings`, y monta el banner de 5.7. Comprueba que la `503` bloquea, la `502` no tiene hallazgos, y la `501` tiene uno resuelto que no bloquea.
9. **Diagnóstico.** Borra el campo `resolvedAt` de la fila `902` en `db.json` y recarga con `normalizeFinding` quitado. Describe qué muestra la pantalla, qué dice `db.json`, y qué habrías mirado primero si te llega el ticket *"el hallazgo aparece como pendiente y yo lo cerré en agosto"*.
10. 💸 **El pago, activos.** Mueve `changesClient` a `core/domain/asset-rules.ts` y hazla cumplir en `AssetStateService.update()`. Después, desde la consola, llama al servicio con un `clientId` distinto y comprueba que se niega. Entrega el `git diff fase-06 fase-09 -- src/app/features/assets/`.
11. 🧬 **Estilo.** Ticket: *"en el listado de inspecciones quiero ver de un vistazo cuál tiene hallazgos críticos"*. El archivo es `InspectionListComponent`, heredado de la Fase 1. Escribe el fix, y justifica en cinco líneas por qué no lo convertiste a standalone, no le pusiste `OnPush` y no le cambiaste el `constructor` por `inject()` aunque tocaste ocho líneas.
12. 💸 **El pago, plantillas.** Mueve `templateIdForAssetType` fuera de `InspectionStartComponent` y añade `resolveForAsset` a `TemplateStateService`. Comprueba que la pantalla de empezar sigue funcionando igual y que ahora la regla se puede llamar desde otro sitio.
13. **Diagnóstico.** Pon la `500` en `completed` con `main-cable: critical_wear`, quita el `[disabled]` del botón "Aprobar" en la plantilla, y púlsalo. Describe qué pasa, qué mensaje sale, y cuántas peticiones se ven en Network. Explica por qué la comprobación del servicio no es redundante con la del botón.
14. Implementa `isEditable` y el `inspectionEditableGuard`. Comprueba que `/inspections/501` redirige a sus hallazgos y que `/inspections/500` abre el formulario. Después quita el guard y comprueba que el servicio sigue negándose a guardar.
15. **Diagnóstico.** Publica una v3 de `elevator-annual` sin el ítem `cabin-lighting`, cambia a mano el `templateVersion` de la `503` a `3`, y abre sus hallazgos. Describe qué pasa con la respuesta huérfana, por qué su severidad es `null`, y por qué eso impide aprobar la inspección.

**🟠 Difícil (16–21)**

16. 🧬 **Estilo.** Ticket: *"al editar un activo, si guardo, el sistema dice que no puedo cambiar de cliente y yo no lo cambié"*. Reprodúcelo cambiando `getRawValue()` por `value` en `AssetFormComponent`. Decide en qué archivo va el fix y en qué estilo, y explica por qué el mensaje de error —que es correcto— llegó por el camino equivocado.
17. **Diagnóstico.** Escribe el post-mortem completo de ocho puntos del incidente **12** siguiendo `formato-cuaderno-incidentes.md`, con su par de tags `inc/12/<slug>-roto` / `-fix`. El punto 4 —causa raíz— es el interesante: la línea que falla es correcta, y el error está en un archivo que no aparece en el stack trace.
18. **Diagnóstico.** Pon `"answer": "no_se"` en una respuesta de la `500` y abre sus hallazgos. Describe qué caso de `SeverityDerivation` se produce, cómo se pinta, y por qué impide aprobar en vez de contar como `minor`. Después argumenta en cinco líneas contra la alternativa de `?? 'minor'`.
19. Implementa `resolve()` y `reopen()` completos y comprueba que resolver el hallazgo `900` desbloquea la aprobación de la `503`. Después resuelve el problema que 5.7 esquiva con un snackbar: un hallazgo derivado que **no tiene fila guardada** no se puede marcar como resuelto. Decide si se crea la fila al resolverla —y qué le pasa entonces al 💸 de "no se persisten los derivados"— o si el sistema exige otra cosa. Implementa tu decisión y justifícala.
20. **Diagnóstico.** Provoca el segundo 🧨: deriva los hallazgos con la plantilla vigente en vez de con la versión guardada. Entrega qué cambia en la `501`, qué habría cambiado en la `503`, y en cuál de las dos lo habrías notado antes. Relaciónalo con el incidente 08 de la Fase 7.
21. Distingue `BusinessRuleError` de `ApiError` en las tres pantallas que ya los producen. Provoca los dos con el mock —`CHAOS=error CHAOS_RATE=1` para el segundo— y comprueba que el mensaje, la duración y el botón del snackbar son distintos. Explica qué le enseña al usuario cada uno.

**🔴 Muy difícil (22–26)**

22. Escribe el post-mortem completo de ocho puntos del incidente **13** —*"el supervisor subió la severidad de un hallazgo y al día siguiente había vuelto a bajar"*— con su par de tags. Es un incidente que **sólo existe si implementas el ejercicio 23**, así que el punto 7 —prevención— tiene que argumentar si la funcionalidad debería existir.
23. Diseña e implementa la severidad subida a mano: un campo `severityOverride` en la fila de `findings`, quién puede ponerlo, y qué le pasa cuando la severidad derivada cambia. Contesta las tres preguntas incómodas: ¿se puede bajar además de subir?, ¿el override sobrevive a una corrección de la plantilla?, y ¿cómo sabe alguien dentro de un año que ese `critical` lo puso una persona y no el sistema? Sin trazabilidad —que el curso no construye— el override es un dato sin autor. Decide si lo dejarías puesto.
24. Escribe la política completa de *"aparece un hallazgo `critical` en una inspección ya aprobada"*, que es el ticket más incómodo del curso. Tiene que cubrir: si la inspección se desaprueba (no), si el certificado se revoca (sí, y eso es Fase 10), quién se entera, y qué se le muestra a quien abre esa inspección mañana. Impleméntala hasta donde llegue esta fase —la marca en pantalla— y deja escrito el resto como especificación para la Fase 10.
25. Implementa la alternativa que esta fase descarta: **persistir los hallazgos derivados** en el momento de completar la inspección. Después publica una v3 de `elevator-annual` que cambie `nonComplianceSeverity` de `cabin-lighting` de `minor` a `major`, y demuestra con dos capturas qué le pasa a una inspección v2 histórica en cada uno de los dos diseños. Decide cuál eligirías para un sistema de certificaciones y escribe el argumento en cinco líneas.
26. Escribe los tests puros de `deriveSeverity`, `deriveFindings` y `summarizeFindings` —sin `TestBed`, como los de la Fase 8—. Cubre al menos: criterio conforme, criterio intermedio con las tres severidades de partida, criterio final, ítem de dos criterios, respuesta huérfana, criterio desconocido, `critical` resuelto y `critical` sin resolver. Guárdalos: la Fase 12 los va a reclamar.

**🔥 Opcionales**

- 🔥 **El `role` que no autoriza.** El token de la Fase 2 trae `role`, la toolbar lo muestra y nada lo usa. Añade un `[disabled]` al botón "Aprobar" cuando el rol no sea `supervisor`, y después salta tu propia restricción desde las DevTools en menos de un minuto. Escribe dos párrafos sobre por qué autorizar en el cliente es teatro, y dónde tendría que estar la comprobación de verdad.
- 🔥 **Corrige la semilla.** Cambia las filas `902` y `903` de `db.json` para que coincidan con la derivación, y cuenta qué se pierde: los dos ejemplos de divergencia que sostienen los ejercicios 3, 9 y toda la sección 6. Después decide si en un sistema real corregirías los datos históricos o los dejarías como están, y por qué.
- 🔥 **Notificaciones.** Diseña —sin implementar— qué pasaría si aprobar una inspección con hallazgos `major` abiertos avisara a alguien: a quién, por qué canal, y qué hace el sistema si el aviso falla. Es media fase de trabajo y por eso no está aquí.

---

## 📚 8. Referencias

**Documentación oficial**

- https://www.typescriptlang.org/docs/handbook/2/narrowing.html#discriminated-unions — las uniones discriminadas de 5.2, que son de TypeScript y no de Angular. ⚠️ La documentación cubre versiones posteriores a la 5.1.6 del curso; para este tema no hay diferencia.
- https://www.typescriptlang.org/tsconfig#strictNullChecks — qué comprueba exactamente `strictNullChecks` y, sobre todo, qué **no**: nada de lo que entra por HTTP.
- https://www.typescriptlang.org/docs/handbook/utility-types.html#recordkeys-type — el `Record<FindingSeverity, T>` total de 5.1 y por qué rompe la compilación cuando la unión crece.
- https://v16.angular.io/api/router/CanActivateFn — el guard funcional de 5.8, hermano del `CanDeactivateFn` de la Fase 8.
- https://v16.angular.io/api/router/UrlTree — devolver un `UrlTree` desde un guard para redirigir en vez de bloquear.
- https://v16.angular.io/guide/http-request-data-from-server — el genérico de `http.get<T>()` y la frase que conviene subrayar: es una aserción de tipo, no una validación.
- https://rxjs.dev/api/index/function/combineLatest y https://rxjs.dev/api/index/function/throwError — las dos piezas de 5.6.
- https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Operators/Nullish_coalescing — el `??` de `normalizeFinding`, y su diferencia con `||`, que aquí importaría si `resolvedAt` pudiera ser cadena vacía.

**Video / apoyo**

- Cualquier charla sobre *parse, don't validate* aplicada a TypeScript sirve para el punto de 5.3. ⚠️ El término viene del mundo de Haskell y casi todo el material lo usa en ese contexto; la idea transferible es la de esta fase: se normaliza una vez, en el borde, y el interior confía.

**Orden de lectura sugerido:** las uniones discriminadas **antes** de escribir 5.2, si el `kind` te resulta ajeno. La página de `strictNullChecks` **después** de provocar el 🧨 número 1, no antes: leída en frío parece una opción de compilador, y leída con el certificado emitido en pantalla se entiende de una vez. `CanActivateFn` cuando llegues a 5.8, y **A07** si quieres revisar por qué `findingsOf()` no guarda su resultado en el estado.

---

## 🚀 9. Cierre y conexión con la siguiente fase

CertCore ya sabe decir que no. Es un hito pequeño en líneas de código y grande en lo que significa: hasta hoy la aplicación registraba lo que pasaba, y desde hoy tiene una opinión sobre lo que se puede hacer con eso.

Debajo de esa opinión hay tres decisiones que la Fase 10 va a heredar tal cual. La severidad es **derivada**, y eso es seguro únicamente porque sus entradas —la respuesta y la versión de plantilla congelada— no se pueden reescribir; el invariante de la Fase 7 no es una regla del motor de plantillas, es lo que sostiene el sistema entero. Las reglas de negocio viven **en servicios**, escritas puras y hechas cumplir donde no se pueden esquivar, y las tres que estaban repartidas por pantallas ya no lo están. Y lo que entra por HTTP se **normaliza en el borde**, porque `strict` protege el interior de la aplicación y no tiene ninguna opinión sobre lo que el backend decidió no mandar.

Lo que te llevas para cualquier proyecto: cuando encuentres un dato guardado que también se podría calcular, la pregunta no es cuál de los dos es más rápido. Es **si las entradas del cálculo son inmutables**. Si lo son, derivar es gratis y no se desincroniza nunca. Si no lo son, derivar es un bug con retardo, y guardarlo es un bug con fecha de caducidad. En los dos casos vas a acabar mirando la misma pantalla que has mirado hoy: la que dice una cosa mientras la base de datos dice otra.

La **Fase 10** abre la puerta que hoy quedó escrita. `canIssueCertificate` deja de ser una función que nadie llama y se convierte en la condición de un `POST /certificates`, con su vigencia calculada con zona horaria explícita —la misma `CERTCORE_TIME_ZONE_OFFSET` de la Fase 7, y no una segunda constante— y su PDF generado en el cliente con jsPDF. También es donde se cobra la deuda que el `alcance-del-proyecto.md` §5.1 tiene marcada desde el principio: el `status` del certificado está almacenado y debería ser derivado, exactamente el mismo error que esta fase evitó con la severidad. Vas a llegar allí sabiendo ya por qué duele.

> **La señal de que quedó bien:** cuando el sistema te dice que no, entiendes por qué sin abrir el código, sabes qué ítem lo causa, y no se te ocurre reintentar.

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-09 -m "F9 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`fase 09: …`) y los de ejercicio su
> número (`fase 09 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f09/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva el cuaderno. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
>
> Esta fase paga la 💸 que la Fase 6 declaró, y la factura se lee en un solo
> comando: `git diff fase-06 fase-09 -- src/app/features/assets/ src/app/core/domain/`
> enseña la regla saliendo de un componente y entrando en un servicio, que es
> la clase de diff que conviene mirar entera una vez. El incidente 12 se
> reproduce borrando un campo de `db.json`, así que su rama `inc/12/…-roto`
> sale de este tag y su `-fix` cabe en dos líneas — una para el fix del viernes
> y otra para el correcto. Y ojo con `db.json`: esta fase **escribe estados y
> fechas de resolución**, así que la `500` y la `503` ya no están como las
> sembró la Fase 3. Decide si lo commiteas o lo devuelves con `npm run seed`
> antes de etiquetar.

---

## 📌 Pendientes sugeridos

- **Las dos filas de `findings` que no cuadran con la derivación son material, no error — pero conviene que la Fase 3 lo sepa.** La `902` (`door-sensor: intermittent` → guardada `major`, derivada `minor`) y la `903` (`main-cable: light_wear` → guardada `minor`, derivada `major`) sostienen los ejercicios 3, 9 y media sección 6. Si alguna vez alguien "arregla" la semilla, esta fase se queda sin su mejor ejemplo. → **Aviso para el chat de la Fase 3** y nota en `db.seed.json`: esas dos filas divergen **a propósito**.
- **La regla "un derivado sólo es seguro si sus entradas son inmutables" merece vivir fuera de esta fase.** Aparece aquí con la severidad, en la Fase 10 con el `status` del certificado y en la Fase 11 con las agregaciones del dashboard. Es candidata a párrafo fijo en **A07** o a entrada propia en `INSTINTOS.md` si el curso llega a tener uno. → **Decisión de proyecto.**
- **Aprobar y rechazar no dejan rastro de quién ni de cuándo.** `Inspection` no tiene `approvedBy` ni `approvedAt`, y el `alcance-del-proyecto.md` §5 promete que todo lo relevante deja rastro. Añadir los campos toca `db.seed.json` con nueve fases encima, y la trazabilidad sigue sin dueño desde la Fase 6. Es la tercera fase que lo señala. → **Decisión de proyecto**: o entra como apéndice 🔥 de auditoría, o se retira la promesa del alcance.
- **`canIssueCertificate` queda escrita y sin llamar.** Es deliberado y está dicho en la sección 3, pero una función que nadie invoca es exactamente lo que un `lint` con `noUnusedLocals` no detecta y una revisión de código sí. → **Aviso para el chat de la Fase 10**: es la primera línea que esa fase tiene que usar, y si no la usa, hay que borrarla.
- **La revocación de un certificado por hallazgo posterior está especificada en el ejercicio 24 y no implementada.** La política queda escrita aquí; el `revokedAt` del modelo existe desde la Fase 3. → **Aviso para el chat de la Fase 10.**
- **El dashboard va a querer contar hallazgos de todas las inspecciones a la vez.** `findingsOf()` hace dos peticiones por inspección, así que treinta inspecciones son sesenta peticiones. Con el volumen del curso da igual; con el de un cliente real, no. Es la misma clase de problema que el progreso recalculado de la Fase 8 y conviene resolverlos con el mismo criterio. → **Aviso para el chat de la Fase 11.**
- **La resolución de un hallazgo derivado sin fila guardada queda a medias en 5.7.** El componente lo esquiva con un snackbar y el ejercicio 19 obliga a decidirlo. Es el único punto de la fase donde el diseño de "derivar y no persistir" roza su límite, y merece que la respuesta del ejercicio se consolide en el texto si el curso hace una segunda pasada. → **Pendiente de revisión editorial.**
- 🔥 **Un diagrama de la máquina de estados de la inspección** —los seis estados, las cinco transiciones, y las dos que esta fase estrena marcadas— resolvería `ALLOWED_TRANSITIONS` mejor que su comentario. Es el séptimo pendiente de ilustración del curso. Pendiente de dibujo, no de contenido.

### Reservas para el cuaderno de incidentes

Los enunciados ya están escritos en el índice de [`cuaderno-incidentes.md`](cuaderno-incidentes.md), que es donde viven; acá queda constancia de qué fase los produce. **El ID no se reasigna nunca.**

| ID | Título | Categoría | Dif. |
|---|---|---|---|
| 12 | "Aprobé la inspección y el sistema me dejó, pero el cable está para cambiar" | Tipos (strict) | 🟠 |
| 13 | "El supervisor subió la severidad de un hallazgo y al día siguiente había vuelto a bajar" | Tipos (strict) | 🟠 |
