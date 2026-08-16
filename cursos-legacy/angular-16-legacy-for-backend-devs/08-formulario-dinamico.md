# 📝 Fase 08 — Formulario dinámico desde plantilla ⭐

> Tutorial Angular 16 — Inspecciones y certificaciones · Fase 8 de 14 · **12 horas**
> Depende de: Fase 7 (plantillas versionadas) · Habilita: Fases 9 a 11
> Apéndices de apoyo: [A05 (Formularios reactivos tipados)](a05-formularios-tipados.md) · [A06 (RxJS 7)](a06-rxjs.md)
> [Incidentes asociados](cuaderno-incidentes.md): 10, 11
> Estilo de esta fase: **nuevo**, con dos costuras 🧬 hacia el `InspectionsModule` heredado

---

## 🎯 1. Propósito

La Fase 7 dejó la plantilla convertida en dato: una familia de versiones, cada una con sus ítems, sus criterios y su ventana de vigencia. Hoy ese dato se convierte en pantalla.

Vas a construir el formulario de una inspección **en tiempo de ejecución**, a partir de los `items[]` de la versión que esa inspección guardó. No hay un HTML con cuatro campos escritos a mano: hay un `FormRecord` que se arma leyendo un array, con los validadores derivados de `photoRequired` y de `criteria`, y con una regla que no se negocia — **la plantilla decide la forma del formulario, y la plantilla es la que la inspección tiene escrita en su `templateVersion`**.

Y encima de eso, lo que hace que la pantalla sea usable en campo: un autosave que guarda solo mientras el inspector trabaja, un indicador que dice si se guardó, y un guard que no te deja salir con algo pendiente.

Es la fase donde más fácil es escribir un bucle infinito sin darse cuenta. El ciclo es `valueChanges` → guardar → parchear el formulario → `valueChanges`, y cierra tan bien que la aplicación se arrastra sin dar un solo error. Vas a montarlo a propósito para verlo, y después vas a saber reconocerlo en cualquier proyecto.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `/inspections/501` pinta **tres** ítems con los títulos de la v1, y `/inspections/500` pinta **cuatro** con los de la v2. Ninguna pantalla decide eso: lo decide el `templateVersion` de cada inspección.
- [ ] El formulario se construye desde `template.items` y sus controles llevan el `itemId` como clave. Añadir un ítem a la plantilla añade un control sin tocar una línea del componente.
- [ ] Escribes una nota, esperas segundo y medio, y en Network sale **un** `PATCH` — no uno por letra. El indicador pasa por "pendiente", "guardando" y "guardado a las HH:MM".
- [ ] Navegas de la inspección 500 a la 501 desde el listado sin recargar la página, y **no queda ni un control de la anterior**.
- [ ] Intentas salir con un cambio sin guardar y la aplicación lo guarda antes de dejarte ir; si el guardado falla, te pregunta.
- [ ] "Completar" está bloqueado mientras falte una respuesta o falte la foto de un ítem con `photoRequired`, y el mensaje dice **cuál** falta.
- [ ] Provocaste el bucle de `valueChanges` y lo viste en Network; provocaste el `NG0100` y comprobaste que en producción no aparece.
- [ ] `git tag` lista `fase-08`.

---

## 🚫 3. Qué NO entra todavía

- **La subida de evidencia real** —cámara, archivos, almacenamiento— → fuera de alcance. `evidenceUrl` es un campo de texto con la ruta, exactamente como está en la semilla desde la Fase 3.
- **El trabajo sin conexión** → fuera de alcance, y conviene decirlo con cuidado. El `alcance-del-proyecto.md` §5 cuenta que el inspector de CertCore trabaja en campo con conexión intermitente y que las respuestas se sincronizan; **eso el curso no lo construye**. Es historia del sistema, no código que puedas abrir. El ejercicio 30 te hace diseñarlo —incluida la pregunta incómoda de qué le pasa al invariante de versión mientras estuviste desconectado— sin implementarlo.
- **El cálculo de severidad y los hallazgos** → Fase 9. Aquí se guarda `answer: 'critical_wear'` y nadie deduce todavía nada de eso.
- **Las transiciones `approved` y `rejected`** → Fase 9, porque dependen de los hallazgos. Esta fase implementa dos: `scheduled → in_progress` en el primer guardado y `in_progress → completed` al cerrar.
- **El `PATCH` por respuesta** → es la 💸 de 5.1, se mide en la Fase 11 y se explica por qué no se paga entera.
- **Signals y control flow nuevo** → Fase 12 y **A11**.

---

## 🧠 4. Concepto mínimo

### El problema, antes que la herramienta

Todos los formularios que llevas escritos tienen algo en común: **sabías cuántos campos tenían al escribirlos**. El login tenía dos, el cliente dos, el activo cinco. Los declaraste en una interfaz, el compilador los verificó, y el HTML los pintó uno por uno.

Este no. Este tiene los campos que diga la plantilla: tres para la v1 de ascensores, cuatro para la v2, dos para calderas, y los que traiga la v5 que alguien publique el año que viene. No puedes escribir la interfaz porque no sabes las claves; no puedes escribir el HTML porque no sabes cuántos bloques repetir.

Lo que sí sabes —y es lo que salva la situación— es que **todos los campos tienen la misma forma**. Cada ítem del checklist se responde igual: una respuesta elegida entre sus criterios, una evidencia opcional, una nota opcional. Las claves son desconocidas; el tipo de cada valor, no.

Eso es exactamente lo que `FormRecord` modela.

### `FormRecord`, y por qué la clave es el `itemId`

`FormRecord<T>` es un `FormGroup` cuyas claves se conocen en runtime y cuyos controles son **todos del mismo tipo**. Tiene `addControl`, `removeControl` y `contains`, y su `getRawValue()` devuelve un `Record<string, …>` tipado por ese `T`. En nuestro caso `T` es un `FormGroup<AnswerForm>`, así que el compilador sabe que dentro de cada clave hay una respuesta, una evidencia y una nota, aunque no sepa qué claves habrá.

La alternativa sería `FormArray<FormGroup<AnswerForm>>`, indexado por posición, y funciona. Pero indexar por posición ata las respuestas al **orden** de los ítems, y el orden de una plantilla es dato editable: la Fase 7 puso dos botones para reordenar. Con `FormArray`, mover el segundo ítem al primer puesto en una v3 desplazaría las respuestas de todo el mundo. Con el `itemId` como clave, no hay nada que desplazar.

> 🧭 **Regla del proyecto: una respuesta se casa con su ítem por `itemId`, nunca por posición.** El orden es presentación; el `itemId` es identidad. Es la misma distinción que hace que `templateVersion` sea un campo y no una fecha calculada.

Hay un regalo escondido en esa decisión: si una inspección trae una respuesta cuyo `itemId` **no está** en la plantilla —un ítem retirado en una versión posterior—, la diferencia entre las claves de las respuestas y las de los ítems la delata en una línea. La Fase 7 ya decidió qué hacer con ella: no se borra, se muestra como perteneciente a un ítem retirado.

### El ciclo que se muerde la cola

Antes de escribir el autosave conviene dibujar el bucle, porque escribirlo mal es lo natural y verlo después cuesta horas:

1. El inspector escribe una letra. `valueChanges` emite.
2. Pasa el debounce, sale el `PATCH`, el servidor responde con la inspección guardada.
3. *"Para que quede sincronizado"*, alguien parchea el formulario con la respuesta del servidor.
4. `patchValue` dispara `valueChanges`. **Vuelve al paso 2.**

Cierra perfecto y no da ningún error. Lo que se ve es la aplicación arrastrándose, la pestaña de Network llenándose sola y el ventilador del portátil. Es el **incidente 11**.

Hay dos formas de romperlo y sólo una es correcta. La que parece obvia es `patchValue(value, { emitEvent: false })`, que apaga la emisión. Funciona, y sigue siendo mala idea: estás pisando lo que el inspector tenía escrito con lo que el servidor te devolvió, y si escribió algo durante el viaje de red, se pierde.

La correcta es más simple: **después de guardar, el formulario no se toca**. El servidor confirma; no dicta. El único `patchValue` de esta pantalla es el de la carga inicial, y ése no hace falta —el formulario se construye ya con los valores dentro—.

### Dos niveles de validación, y esto no es un detalle

Un inspector pasa una hora con el checklist a medias. Durante esa hora el formulario está **inválido** —le faltan respuestas— y aun así hay que guardar, porque perder cuarenta minutos de trabajo por una tablet que se apagó es exactamente lo que la aplicación existe para evitar.

Por eso hay dos niveles y no se mezclan:

**El autosave ignora `invalid`.** Guarda lo que haya, cuando haya. Un borrador incompleto es el estado normal de una inspección en curso, no un error.

**Completar exige válido.** La transición a `completed` comprueba que cada ítem tiene respuesta y que cada ítem con `photoRequired: true` tiene su `evidenceUrl`. Es el único momento en que la validación bloquea algo.

Los validadores están puestos desde el principio y sirven todo el rato: marcan en rojo, informan, y alimentan el "3 de 4 respondidos". Lo que no hacen es impedir guardar.

> 📝 **Nota de migración.** `FormRecord` llegó con Angular **14**, junto con los formularios genéricos, y es la respuesta oficial a un problema que antes se resolvía con un `FormGroup` y un `any` mal disimulado —o con `FormBuilder.group({})` y controles añadidos a mano sin ningún tipo—. CertCore nació en 2021 sobre Angular 12: si esta pantalla se hubiera escrito entonces, tendría un `FormGroup` sin genérico y un `[key: string]: AbstractControl` en algún sitio. Se escribe hoy, con la 16 puesta, así que se escribe tipada. Es de las pocas cosas del sistema que están mejor que en su primera versión precisamente **porque** se hicieron tarde.

---

## 💻 5. Código mínimo con comentarios

### 5.1 `InspectionApiService`, y la 💸 del guardado completo

```ts
// src/app/core/api/inspection-api.service.ts
import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, catchError } from 'rxjs';

import { environment } from '../../../environments/environment';
import { Finding } from '../models/finding.model';
import { Inspection, InspectionAnswer } from '../models/inspection.model';
import { toApiError } from './api-error';

/** Lo que hace falta para crear una inspección. El resto lo pone el servicio. */
export interface NewInspection {
  readonly assetId: string;
  readonly inspectorId: string;
  readonly templateId: string;
  /** La versión resuelta al empezar. A partir de aquí es inmutable. Fase 7. */
  readonly templateVersion: number;
  readonly startedAt: string;
}

@Injectable({ providedIn: 'root' })
export class InspectionApiService {
  private readonly http = inject(HttpClient);

  private readonly baseUrl = `${environment.apiBaseUrl}/inspections`;

  getAll(): Observable<readonly Inspection[]> {
    return this.http.get<readonly Inspection[]>(this.baseUrl).pipe(catchError(toApiError));
  }

  getById(id: number): Observable<Inspection> {
    return this.http.get<Inspection>(`${this.baseUrl}/${id}`).pipe(catchError(toApiError));
  }

  /** La Fase 9 vive de esto; aquí sólo se deja escrito el endpoint. */
  getFindings(inspectionId: number): Observable<readonly Finding[]> {
    return this.http
      .get<readonly Finding[]>(`${this.baseUrl}/${inspectionId}/findings`)
      .pipe(catchError(toApiError));
  }

  create(draft: NewInspection): Observable<Inspection> {
    const created = {
      ...draft,
      // Nace agendada y sin respuestas. El primer guardado la pasa a
      // in_progress: el estado lo mueve el trabajo, no un botón aparte.
      status: 'scheduled' as const,
      completedAt: null,
      answers: [],
    };

    return this.http.post<Inspection>(this.baseUrl, created).pipe(catchError(toApiError));
  }

  /**
   * 💸 DEUDA TÉCNICA INTENCIONAL
   * Cada guardado manda el array `answers` ENTERO, aunque haya cambiado una
   * letra de una nota. Con cuatro ítems son dos kilobytes; con los sesenta de
   * una plantilla de subestación eléctrica, cada tecla mueve treinta.
   * Lo correcto es un PATCH por respuesta: `PATCH /inspections/500/answers/main-cable`.
   * SE PAGA A MEDIAS EN LA FASE 11, midiendo el costo con el volumen del
   * dashboard delante. Entera no se paga, y el motivo es de alcance: las
   * respuestas son un array anidado dentro de la inspección, no una colección
   * propia, así que un endpoint por respuesta hay que escribirlo en el mock —
   * trabajo de backend que no enseña ni una línea de Angular. El ejercicio 31
   * lo diseña y mide el ahorro para que la decisión sea tuya y no mía.
   */
  saveAnswers(
    id: number,
    answers: readonly InspectionAnswer[],
    status: Inspection['status'],
  ): Observable<Inspection> {
    // PATCH y no PUT: mandamos dos campos de la inspección, no la entidad
    // entera. json-server los mezcla con lo que ya hay, así que `startedAt` y
    // `templateVersion` no pueden perderse por accidente — y eso último
    // importa más de lo que parece, porque `templateVersion` es el invariante.
    return this.http
      .patch<Inspection>(`${this.baseUrl}/${id}`, { answers, status })
      .pipe(catchError(toApiError));
  }

  complete(
    id: number,
    answers: readonly InspectionAnswer[],
    completedAt: string,
  ): Observable<Inspection> {
    return this.http
      .patch<Inspection>(`${this.baseUrl}/${id}`, { answers, status: 'completed', completedAt })
      .pipe(catchError(toApiError));
  }
}
```

### 5.2 El estado, que esta vez sí encaja en el molde

```ts
// src/app/core/state/inspection-state.service.ts — lo esencial
@Injectable({ providedIn: 'root' })
export class InspectionStateService {
  private readonly inspectionApi = inject(InspectionApiService);
  private readonly authService = inject(AuthService);

  private readonly stateSubject = new BehaviorSubject<FeatureState<Inspection>>(
    createInitialState<Inspection>(),
  );

  readonly state$: Observable<FeatureState<Inspection>> = this.stateSubject.asObservable();
  readonly inspections$ = this.state$.pipe(map((state) => state.items), distinctUntilChanged());
  readonly loading$ = this.state$.pipe(map((state) => state.loading), distinctUntilChanged());
  readonly error$ = this.state$.pipe(map((state) => state.error), distinctUntilChanged());

  constructor() {
    this.authService.currentUser$
      .pipe(filter((user) => user === null))
      .subscribe(() => this.reset());
  }

  load(): void {
    /* …el molde de la Fase 4, sin una sola variación… */
  }

  reset(): void {
    this.stateSubject.next(createInitialState<Inspection>());
  }
}
```

**Detalles con intención**

- **Aquí el molde de la Fase 4 se usa tal cual, y decirlo importa.** Después de que la Fase 7 lo rompiera con `TemplateState`, la tentación es romperlo cada vez. El criterio es el mismo de siempre: el listado de inspecciones **es** "cargar una lista", así que `FeatureState<Inspection>` le va bien. Un patrón que se abandona a la primera excepción nunca fue un patrón.
- **El borrador que se está editando NO vive aquí.** Podría, y sería un error caro: un servicio `providedIn: 'root'` sobrevive a la navegación, así que el borrador de la inspección 500 seguiría en memoria al abrir la 501 y habría que acordarse de limpiarlo. El borrador tiene un dueño natural —la pantalla que lo edita— y muere con ella. Es la otra cara de la lección de la Fase 4: el estado compartido es para lo que de verdad se comparte.

### 5.3 ⭐ El formulario construido desde datos

Esta función es el corazón de la fase y es **pura**: recibe una plantilla y unas respuestas, y devuelve un formulario. No inyecta nada, no pide nada, no sabe qué pantalla la llamó. La Fase 12 la va a testear sin `TestBed`.

```ts
// src/app/core/domain/inspection-form.ts
import {
  AbstractControl,
  FormControl,
  FormGroup,
  FormRecord,
  ValidationErrors,
  ValidatorFn,
  Validators,
} from '@angular/forms';

import { ChecklistItem, ChecklistTemplate } from '../models/checklist-template.model';
import { InspectionAnswer } from '../models/inspection.model';

/**
 * La forma de UNA respuesta. Las claves del formulario no se conocen en
 * compilación —las decide la plantilla—, pero el tipo de cada valor sí, y eso
 * es exactamente lo que FormRecord modela.
 */
export interface AnswerForm {
  /** Uno de los `criteria` del ítem. '' significa "sin responder todavía". */
  answer: FormControl<string>;
  /** `null` = sin evidencia. No es lo mismo que la cadena vacía. */
  evidenceUrl: FormControl<string | null>;
  note: FormControl<string | null>;
}

export type InspectionForm = FormRecord<FormGroup<AnswerForm>>;

/**
 * Construye el formulario de una inspección a partir de la plantilla con la
 * que se ejecutó y de las respuestas que ya tiene guardadas.
 *
 * ⚠️ `template` tiene que ser la versión que la inspección guardó, obtenida con
 * `getByVersion(inspection.templateId, inspection.templateVersion)`. Si le
 * pasas la vigente, esta función construye un formulario perfectamente válido
 * con la plantilla equivocada y nadie se entera. Es el incidente 08 de la
 * Fase 7, visto desde aquí.
 */
export function buildAnswerForm(
  template: ChecklistTemplate,
  answers: readonly InspectionAnswer[],
): InspectionForm {
  const form: InspectionForm = new FormRecord<FormGroup<AnswerForm>>({});
  const answerByItemId = new Map(answers.map((answer) => [answer.itemId, answer]));

  // El orden de inserción es el orden de la plantilla, y `getRawValue()` lo
  // respeta. Aun así, la pantalla pinta recorriendo `template.items` y no las
  // claves del formulario: el orden es de la plantilla, no del formulario.
  for (const item of template.items) {
    form.addControl(item.id, buildItemGroup(item, answerByItemId.get(item.id) ?? null));
  }

  return form;
}

function buildItemGroup(
  item: ChecklistItem,
  answer: InspectionAnswer | null,
): FormGroup<AnswerForm> {
  return new FormGroup<AnswerForm>({
    answer: new FormControl(answer?.answer ?? '', {
      nonNullable: true,
      // Los dos validadores salen del DATO, no de una decisión de pantalla:
      // el ítem dice qué respuestas admite y esto lo hace cumplir.
      validators: [Validators.required, oneOfValidator(item.criteria)],
    }),
    evidenceUrl: new FormControl<string | null>(answer?.evidenceUrl ?? null, {
      // `photoRequired` es un campo de la plantilla y aquí se vuelve un
      // validador. Cambiar ese booleano en una v3 cambia la validación de la
      // pantalla sin tocar una línea de este archivo. Eso es lo que significa
      // "derivado de la plantilla".
      validators: item.photoRequired ? [Validators.required] : [],
    }),
    note: new FormControl<string | null>(answer?.note ?? null),
  });
}

/** La respuesta tiene que ser uno de los criterios del ítem. */
export function oneOfValidator(allowed: readonly string[]): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    // El valor de un AbstractControl llega sin tipar: `unknown` y estrechar,
    // que es la regla del proyecto desde la Fase 6.
    const value: unknown = control.value;

    if (typeof value !== 'string' || value === '') {
      // Vacío no es inválido por este validador: de eso se ocupa `required`.
      // Un control con dos errores a la vez confunde el mensaje al usuario.
      return null;
    }

    return allowed.includes(value) ? null : { notAllowed: { value, allowed } };
  };
}

/**
 * El camino de vuelta: del formulario al modelo del dominio.
 *
 * Los ítems sin responder NO viajan. `answers` guarda lo respondido, no un
 * hueco por cada ítem: así una inspección a medias se distingue de una
 * inspección respondida con vacíos, y la 500 de la semilla —una respuesta de
 * cuatro ítems— es exactamente eso.
 */
export function toAnswers(form: InspectionForm): readonly InspectionAnswer[] {
  return Object.entries(form.getRawValue())
    .filter(([, value]) => value.answer !== '')
    .map(([itemId, value]) => ({
      itemId,
      answer: value.answer,
      evidenceUrl: value.evidenceUrl,
      note: value.note,
    }));
}

/**
 * Comparador barato para `distinctUntilChanged`: si el JSON es el mismo, no
 * hay nada que guardar. Es O(n) sobre un array de decenas de elementos y se
 * ejecuta como mucho una vez cada segundo y medio; una comparación profunda
 * hecha a mano sería más rápida y bastante más fácil de romper.
 */
export function serializeAnswers(answers: readonly InspectionAnswer[]): string {
  return JSON.stringify(answers);
}
```

**Detalles con intención**

- **`answer: ''` y no `answer: string | null`.** "Sin responder" es un estado del formulario, no del dominio: en cuanto se guarda, el ítem sin responder simplemente no aparece en `answers`. Meter un `null` obligaría a distinguir tres estados —vacío, nulo y ausente— donde el negocio sólo tiene dos.
- **`evidenceUrl: string | null` sí lleva null**, porque en el modelo de la Fase 3 significa algo: "el ítem no exigía foto, o el inspector no la subió todavía".
- **El validador `oneOf` no se queja de lo vacío.** Dos errores simultáneos en un control producen dos mensajes en pantalla, y el usuario lee el que no le sirve.

**El patrón a memorizar**

> Un formulario dinámico bien hecho es una **función pura** de sus datos: misma plantilla y mismas respuestas, mismo formulario. En cuanto necesita saber en qué pantalla está o qué había antes, deja de poderse testear y empieza a acumular bugs de estado.

### 5.4 Progreso, y las respuestas huérfanas

```ts
// src/app/core/domain/inspection-progress.ts
import { ChecklistTemplate } from '../models/checklist-template.model';
import { InspectionAnswer } from '../models/inspection.model';

export interface InspectionProgress {
  readonly answered: number;
  readonly total: number;
  /** Ítems con `photoRequired` respondidos pero sin evidencia. */
  readonly missingEvidence: readonly string[];
  /** ¿Se puede cerrar? Es la ÚNICA regla que bloquea algo en esta fase. */
  readonly canComplete: boolean;
}

export function computeProgress(
  template: ChecklistTemplate,
  answers: readonly InspectionAnswer[],
): InspectionProgress {
  const answerByItemId = new Map(answers.map((answer) => [answer.itemId, answer]));

  const missingEvidence = template.items
    .filter((item) => {
      const answer = answerByItemId.get(item.id);

      return item.photoRequired && answer !== undefined && answer.evidenceUrl === null;
    })
    .map((item) => item.id);

  // Sólo cuentan las respuestas de ítems que la plantilla tiene. Una respuesta
  // huérfana no suma progreso: no pertenece a este checklist.
  const answered = template.items.filter((item) => answerByItemId.has(item.id)).length;

  return {
    answered,
    total: template.items.length,
    missingEvidence,
    canComplete: answered === template.items.length && missingEvidence.length === 0,
  };
}

/**
 * Respuestas que no corresponden a ningún ítem de esta plantilla. Ocurre
 * cuando un ítem se retiró en una versión posterior y alguien movió la
 * inspección a esa versión, o cuando alguien editó a mano una versión
 * publicada.
 *
 * La decisión la tomó la Fase 7 y aquí se cumple: NO se borran. Se muestran
 * aparte, en sólo lectura, marcadas como pertenecientes a un ítem retirado.
 * Borrarlas sería destruir el trabajo de un inspector para que la pantalla
 * quede limpia.
 */
export function findOrphanAnswers(
  template: ChecklistTemplate,
  answers: readonly InspectionAnswer[],
): readonly InspectionAnswer[] {
  const itemIds = new Set(template.items.map((item) => item.id));

  return answers.filter((answer) => !itemIds.has(answer.itemId));
}
```

### 5.5 La pantalla: el formulario se **deriva** de la ruta

Aquí está la decisión que evita el incidente 10, y es de diseño, no de código defensivo: **el formulario no es un campo que alguien rellena; es parte de la vista que se calcula desde el parámetro de ruta.** Si cambia el `:id`, se calcula otro formulario. No hay nada que limpiar porque no hay nada que se reutilice.

```ts
// src/app/features/inspections/inspection-form/inspection-form.component.ts
import { AsyncPipe, NgFor, NgIf } from '@angular/common';
import { ChangeDetectionStrategy, Component, DestroyRef, inject } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { ReactiveFormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatDialog } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatRadioModule } from '@angular/material/radio';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { ActivatedRoute, Router } from '@angular/router';
import {
  BehaviorSubject,
  Observable,
  catchError,
  concatMap,
  debounceTime,
  distinctUntilChanged,
  filter,
  map,
  of,
  shareReplay,
  startWith,
  switchMap,
  tap,
} from 'rxjs';

import { ApiError } from '../../../core/api/api-error';
import { InspectionApiService } from '../../../core/api/inspection-api.service';
import { TemplateApiService } from '../../../core/api/template-api.service';
import {
  InspectionForm,
  buildAnswerForm,
  serializeAnswers,
  toAnswers,
} from '../../../core/domain/inspection-form';
import {
  InspectionProgress,
  computeProgress,
  findOrphanAnswers,
} from '../../../core/domain/inspection-progress';
import { ChecklistTemplate } from '../../../core/models/checklist-template.model';
import { Inspection, InspectionAnswer } from '../../../core/models/inspection.model';
import { criterionLabel } from '../../../core/domain/criterion-label';
import { CanLeave } from '../../../core/guards/unsaved-changes.guard';
import {
  ConfirmDialogComponent,
  ConfirmDialogData,
} from '../../../shared/confirm-dialog/confirm-dialog.component';

/** Cada cuánto se guarda solo. Ver 5.6 para el porqué del número. */
export const AUTOSAVE_DEBOUNCE_MS = 1500;

/** Lo que la pantalla necesita, ya construido. El formulario es parte de esto. */
interface InspectionFormView {
  readonly inspection: Inspection;
  readonly template: ChecklistTemplate;
  readonly form: InspectionForm;
  readonly orphans: readonly InspectionAnswer[];
}

type AutosaveState =
  | { readonly status: 'idle' }
  | { readonly status: 'pending' }
  | { readonly status: 'saving' }
  | { readonly status: 'saved'; readonly at: string }
  | { readonly status: 'failed'; readonly message: string };

@Component({
  selector: 'cc-inspection-form',
  standalone: true,
  imports: [
    AsyncPipe,
    NgFor,
    NgIf,
    ReactiveFormsModule,
    MatButtonModule,
    MatFormFieldModule,
    MatIconModule,
    MatInputModule,
    MatRadioModule,
    MatSnackBarModule,
  ],
  templateUrl: './inspection-form.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class InspectionFormComponent implements CanLeave {
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  private readonly inspectionApi = inject(InspectionApiService);
  private readonly templateApi = inject(TemplateApiService);
  private readonly dialog = inject(MatDialog);
  private readonly snackBar = inject(MatSnackBar);
  private readonly destroyRef = inject(DestroyRef);

  readonly criterionLabel = criterionLabel;

  private readonly autosaveSubject = new BehaviorSubject<AutosaveState>({ status: 'idle' });
  readonly autosave$ = this.autosaveSubject.asObservable();

  /** La última vista emitida, para que el guard pueda forzar un guardado. */
  private currentView: InspectionFormView | null = null;

  /**
   * ⭐ El formulario se DERIVA de la ruta. Cambiar de inspección emite una vista
   * nueva con un FormRecord nuevo, así que es imposible que sobreviva un
   * control de la anterior — no porque nadie lo limpie, sino porque no hay
   * nada que limpiar. Ésa es la defensa contra el incidente 10, y es de
   * diseño: parchear un formulario existente sería la versión que falla.
   */
  readonly view$: Observable<InspectionFormView> = this.route.paramMap.pipe(
    map((params) => Number(params.get('id'))),
    filter((id) => Number.isInteger(id)),
    // switchMap porque esto es una LECTURA: si el usuario navega otra vez, la
    // inspección anterior ya no interesa.
    switchMap((id) => this.inspectionApi.getById(id)),
    switchMap((inspection) =>
      // 🧭 LA LÍNEA QUE SOSTIENE EL SISTEMA: se pide la versión que la
      // inspección GUARDÓ. Nunca la vigente, nunca resolviendo por fecha, ni
      // siquiera por su fecha de ejecución. Fase 7 §5.9.
      this.templateApi
        .getByVersion(inspection.templateId, inspection.templateVersion)
        .pipe(map((template) => ({ inspection, template }))),
    ),
    map(({ inspection, template }) => ({
      inspection,
      template,
      form: buildAnswerForm(template, inspection.answers),
      orphans: findOrphanAnswers(template, inspection.answers),
    })),
    tap((view) => {
      this.currentView = view;
      this.autosaveSubject.next({ status: 'idle' });
    }),
    // Una sola construcción por navegación aunque la plantilla tenga dos
    // suscriptores. refCount para que la suscripción muera con la vista.
    shareReplay({ bufferSize: 1, refCount: true }),
  );

  readonly progress$: Observable<InspectionProgress> = this.view$.pipe(
    switchMap((view) =>
      view.form.valueChanges.pipe(
        map(() => computeProgress(view.template, toAnswers(view.form))),
        // valueChanges no emite al construirse, así que sin este startWith el
        // contador estaría en blanco hasta el primer clic. Es el mismo detalle
        // del probador de fechas de la Fase 7, y se olvida igual de fácil.
        startWith(computeProgress(view.template, toAnswers(view.form))),
      ),
    ),
  );

  constructor() {
    this.startAutosave();
  }

  // …completar(), canLeave() y el autosave van en 5.6 y 5.7…
}
```

**Detalles con intención**

- **`filter((id) => Number.isInteger(id))` antes del `switchMap`.** `Number('abc')` es `NaN`, que pasa como `number` sin que `strict` diga nada. Es el mismo hueco del sistema de tipos que apareció en el formulario de clientes de la Fase 6, y se tapa igual.
- **`shareReplay({ refCount: true })`.** Sin `refCount`, la suscripción interna sobrevive a la pantalla y tienes la fuga que la Fase 4 enseñó a cazar. Con dos suscriptores en la plantilla —`view$` y `progress$`— y sin `shareReplay`, tendrías dos peticiones y dos formularios distintos, que es peor.
- **`currentView` es un campo mutable y está bien.** Es la única forma de que el guard de 5.7, que se llama desde fuera del flujo, sepa sobre qué inspección está trabajando.

### 5.6 ⭐ El autosave, y por qué después de guardar no se toca nada

```ts
// …dentro de InspectionFormComponent…

  private startAutosave(): void {
    this.view$
      .pipe(
        // switchMap aquí cambia de TUBERÍA, no cancela un guardado en vuelo:
        // al navegar a otra inspección, el debounce pendiente de la anterior se
        // descarta. Eso sería una pérdida de datos silenciosa… si no fuera
        // porque el guard de 5.7 fuerza el guardado ANTES de que la navegación
        // ocurra. Las dos piezas se sostienen mutuamente, y el ejercicio 29 te
        // hace comprobar qué se pierde cuando quitas una de las dos.
        switchMap((view) =>
          view.form.valueChanges.pipe(
            // 'pendiente' se marca de inmediato, antes del debounce: el
            // inspector tiene que ver que su cambio está reconocido aunque
            // todavía no haya salido nada a la red.
            tap(() => this.autosaveSubject.next({ status: 'pending' })),
            debounceTime(AUTOSAVE_DEBOUNCE_MS),
            map(() => toAnswers(view.form)),
            // Mover el foco entre campos emite sin cambiar nada. Sin esto, cada
            // tabulación es un PATCH.
            distinctUntilChanged(
              (previous, current) => serializeAnswers(previous) === serializeAnswers(current),
            ),
            // concatMap y NO switchMap: esto es una ESCRITURA. Cancelar un
            // PATCH que ya salió no lo deshace en el servidor, sólo te deja sin
            // saber si llegó. Regla de la Fase 6, y aquí además garantiza el
            // orden: dos guardados seguidos llegan en el orden en que se
            // pidieron.
            concatMap((answers) => this.persist(view.inspection, answers)),
          ),
        ),
        takeUntilDestroyed(this.destroyRef),
      )
      .subscribe();
  }

  /**
   * El guardado de verdad. Devuelve un observable que NUNCA falla hacia fuera:
   * un error de red no puede matar la tubería del autosave, o el inspector se
   * quedaría sin guardado automático justo después del primer túnel.
   * Es la misma lección del buscador de la Fase 6, con más consecuencias.
   */
  private persist(
    inspection: Inspection,
    answers: readonly InspectionAnswer[],
  ): Observable<Inspection | null> {
    this.autosaveSubject.next({ status: 'saving' });

    // El primer guardado mueve la inspección de agendada a en curso. El estado
    // lo mueve el TRABAJO, no un botón de "empezar" que alguien olvida pulsar.
    const nextStatus: Inspection['status'] =
      inspection.status === 'scheduled' ? 'in_progress' : inspection.status;

    return this.inspectionApi.saveAnswers(inspection.id, answers, nextStatus).pipe(
      tap(() => {
        // ⚠️ AQUÍ NO SE PARCHEA EL FORMULARIO. Ni con la respuesta del
        // servidor, ni con emitEvent: false, ni "por si acaso". El servidor
        // confirma; no dicta. Parchear aquí es el bucle infinito del incidente
        // 11, y hacerlo con emitEvent: false lo convierte en algo peor: pisa
        // lo que el inspector escribió durante el viaje de red.
        this.autosaveSubject.next({
          status: 'saved',
          at: new Date().toLocaleTimeString('es-CO'),
        });
      }),
      catchError((error: unknown) => {
        this.autosaveSubject.next({
          status: 'failed',
          message:
            error instanceof ApiError
              ? error.message
              : 'No se pudo guardar. Tus respuestas siguen en pantalla.',
        });

        // `of(null)` y no throwError: el error ya está contado en el estado, y
        // dejarlo salir mataría la suscripción de arriba para siempre.
        return of(null);
      }),
    );
  }

  complete(view: InspectionFormView, progress: InspectionProgress): void {
    if (!progress.canComplete) {
      // Los validadores existían desde el principio; sólo ahora bloquean algo.
      view.form.markAllAsTouched();
      this.snackBar.open(
        `Faltan ${view.template.items.length - progress.answered} respuestas o alguna evidencia.`,
        'Cerrar',
        { duration: 6000 },
      );
      return;
    }

    this.inspectionApi
      .complete(view.inspection.id, toAnswers(view.form), new Date().toISOString())
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe({
        next: () => {
          this.snackBar.open('Inspección completada.', 'Cerrar', { duration: 4000 });
          void this.router.navigate(['/inspections']);
        },
        error: (error: unknown) =>
          this.snackBar.open(
            error instanceof ApiError ? error.message : 'No se pudo completar la inspección.',
            'Cerrar',
            { duration: 8000 },
          ),
      });
  }
```

**El número del debounce, y su porqué**

`AUTOSAVE_DEBOUNCE_MS = 1500`. Con 300 ms se guarda casi por letra y una nota de dos frases produce quince peticiones. Con 3000 ms, salir de la pantalla justo después de escribir pierde media frase — y aunque el guard la rescate, el inspector ve un parpadeo raro. Segundo y medio agrupa una frase corta escrita con guantes en una tablet y deja la ventana de pérdida por debajo de lo que nadie percibe. **El número está en una constante exportada porque la Fase 12 lo va a testear**, y un número mágico dentro de un `pipe` no se puede testear sin copiarlo.

**Prueba de fuego**

Abre Network, filtra por `Fetch/XHR`, y escribe una nota de diez palabras seguidas. Tiene que salir **un** `PATCH`, al terminar. Ahora escribe una palabra, espera dos segundos, escribe otra: salen **dos**. Y por último, pulsa Tab entre tres campos sin escribir nada: no sale **ninguno** — ése es el `distinctUntilChanged`, y es el que separa un autosave de un ataque de denegación de servicio contra tu propio backend.

### 5.7 El guard de salida, que es la otra mitad del autosave

```ts
// src/app/core/guards/unsaved-changes.guard.ts
import { CanDeactivateFn } from '@angular/router';
import { Observable } from 'rxjs';

/**
 * El contrato que un componente cumple para poder ser protegido. Se tipa así
 * —y no con el componente concreto— para que la Fase 9 pueda reutilizar el
 * guard en su pantalla sin tocarlo.
 */
export interface CanLeave {
  canLeave(): Observable<boolean>;
}

/**
 * Guard funcional, como los de la Fase 2. No hace nada por su cuenta: pregunta
 * al componente, que es el único que sabe si tiene algo pendiente.
 */
export const unsavedChangesGuard: CanDeactivateFn<CanLeave> = (component) => component.canLeave();
```

```ts
// …dentro de InspectionFormComponent…

  canLeave(): Observable<boolean> {
    const state = this.autosaveSubject.value;
    const view = this.currentView;

    if (view === null || state.status === 'idle' || state.status === 'saved') {
      return of(true);
    }

    if (state.status === 'pending' || state.status === 'saving') {
      // Hay un cambio dentro de la ventana del debounce. No se le pregunta
      // nada al usuario: se guarda y se sale. Preguntar "¿quieres guardar?"
      // cuando la respuesta es siempre que sí es un diálogo que la gente
      // aprende a cerrar sin leer.
      return this.persist(view.inspection, toAnswers(view.form)).pipe(
        concatMap((saved) =>
          // persist() nunca falla hacia fuera: devuelve null cuando falló. Si
          // falló, entonces sí hay que preguntar, porque salir pierde datos.
          saved === null ? this.confirmDiscard() : of(true),
        ),
      );
    }

    return this.confirmDiscard();
  }

  private confirmDiscard(): Observable<boolean> {
    const data: ConfirmDialogData = {
      title: 'Hay cambios sin guardar',
      message:
        'El último guardado falló. Si sales ahora, las respuestas que escribiste después no se conservan.',
      confirmLabel: 'Salir sin guardar',
    };

    return this.dialog
      .open<ConfirmDialogComponent, ConfirmDialogData, boolean>(ConfirmDialogComponent, { data })
      .afterClosed()
      .pipe(map((confirmed) => confirmed === true));
  }
```

**Detalles con intención**

- **Se reutiliza el `ConfirmDialogComponent` de la Fase 6 sin tocarlo.** Aquella fase lo escribió devolviendo `boolean` y sin saber nada del dominio, precisamente para esto. Un diálogo que supiera borrar clientes no habría servido hoy.
- **El guard no pregunta cuando puede resolver.** La única pregunta que se le hace al usuario es la que él puede contestar mejor que el programa: *"el guardado falló, ¿sales igual?"*.

### 5.8 El HTML de un formulario que no sabes cuántos campos tiene

```html
<!-- src/app/features/inspections/inspection-form/inspection-form.component.html -->
<ng-container *ngIf="view$ | async as view">
  <header class="inspection-header">
    <h2>Inspección {{ view.inspection.id }} · {{ view.inspection.assetId }}</h2>
    <!-- Que la versión esté SIEMPRE a la vista no es decoración: es lo primero
         que se pregunta cualquiera que abra un ticket sobre esta pantalla. -->
    <p>
      Plantilla {{ view.template.templateId }}
      <strong>v{{ view.template.version }}</strong>
      · iniciada el {{ view.inspection.startedAt }}
    </p>

    <ng-container *ngIf="autosave$ | async as autosave">
      <!-- Cuatro *ngIf y no un ngSwitch: NgSwitch son tres directivas más que
           importar en el decorador para ahorrar dos líneas. En un standalone,
           cada import se paga. -->
      <span class="autosave" [class.autosave-failed]="autosave.status === 'failed'">
        <span *ngIf="autosave.status === 'pending'">Cambios sin guardar…</span>
        <span *ngIf="autosave.status === 'saving'">Guardando…</span>
        <span *ngIf="autosave.status === 'saved'">Guardado a las {{ autosave.at }}</span>
        <span *ngIf="autosave.status === 'failed'">{{ autosave.message }}</span>
      </span>
    </ng-container>
  </header>

  <!-- El formulario entero es el FormRecord. Cada bloque se ata a su control
       por el itemId, que es el mismo que la clave. -->
  <form [formGroup]="view.form">
    <section class="checklist-item" *ngFor="let item of view.template.items">
      <!-- formGroupName con un valor dinámico: la clave la trae el dato. Es
           exactamente lo que un FormGroup escrito a mano no puede hacer. -->
      <fieldset [formGroupName]="item.id">
        <legend>
          {{ item.title }}
          <span *ngIf="item.photoRequired" class="checklist-item-photo">· requiere evidencia</span>
        </legend>

        <mat-radio-group formControlName="answer">
          <mat-radio-button *ngFor="let criterion of item.criteria" [value]="criterion">
            {{ criterionLabel(criterion) }}
          </mat-radio-button>
        </mat-radio-group>

        <mat-form-field appearance="outline">
          <mat-label>Evidencia (ruta del archivo)</mat-label>
          <input matInput formControlName="evidenceUrl" placeholder="assets/evidence/…" />
          <mat-error *ngIf="view.form.get([item.id, 'evidenceUrl'])?.hasError('required')">
            Este ítem exige evidencia fotográfica.
          </mat-error>
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Observación</mat-label>
          <textarea matInput formControlName="note" rows="2"></textarea>
        </mat-form-field>
      </fieldset>
    </section>
  </form>

  <!-- Las respuestas huérfanas, aparte y en sólo lectura. No se borran: la
       decisión es de la Fase 7 y aquí se cumple. -->
  <section class="orphan-answers" *ngIf="view.orphans.length > 0">
    <h3>Respuestas de ítems retirados</h3>
    <p>
      Estas respuestas se registraron con un ítem que ya no forma parte de esta
      versión de la plantilla. Se conservan como evidencia y no se pueden editar.
    </p>
    <ul>
      <li *ngFor="let orphan of view.orphans">
        <strong>{{ orphan.itemId }}</strong> · {{ criterionLabel(orphan.answer) }}
      </li>
    </ul>
  </section>

  <footer *ngIf="progress$ | async as progress">
    <span>{{ progress.answered }} de {{ progress.total }} ítems respondidos</span>
    <button
      mat-raised-button
      color="primary"
      [disabled]="!progress.canComplete"
      (click)="complete(view, progress)"
    >
      Completar inspección
    </button>
  </footer>
</ng-container>
```

```ts
// src/app/core/domain/criterion-label.ts

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
```

**Prueba de fuego**

Abre `/inspections/501` —la aprobada de agosto de 2023, ejecutada con la v1— y cuenta: **tres** bloques, y el primero se titula "Estado del cable principal". Ahora abre `/inspections/500`, que es v2: **cuatro** bloques, y el primero dice "Estado y tensión del cable principal". Ni una línea del componente sabe nada de eso. Si la 501 te muestra cuatro ítems, no tienes un bug de esta fase: tienes el incidente 08 de la Fase 7, y la URL de la petición te lo va a confirmar antes que el código.

### 5.9 Empezar una inspección: aquí sí se resuelve por fecha

La pantalla más pequeña de la fase y la que cierra el argumento de la Fase 7. Es el **único** sitio del sistema donde se resuelve una plantilla por fecha.

```ts
// src/app/features/inspections/inspection-start/inspection-start.component.ts — lo esencial
export class InspectionStartComponent {
  private readonly assetState = inject(AssetStateService);
  private readonly templateState = inject(TemplateStateService);
  private readonly inspectionApi = inject(InspectionApiService);
  private readonly authService = inject(AuthService);
  private readonly router = inject(Router);
  private readonly destroyRef = inject(DestroyRef);

  readonly assetControl = new FormControl<string>('', { nonNullable: true });

  /** El día del negocio, no el del navegador. Fase 7 §5.1. */
  readonly today = todayInBusinessZone();

  readonly resolution$: Observable<TemplateResolution | null> = combineLatest([
    this.assetControl.valueChanges.pipe(startWith(this.assetControl.value)),
    this.assetState.assets$,
  ]).pipe(
    switchMap(([assetId, assets]) => {
      const asset = assets.find((candidate) => candidate.id === assetId);

      if (asset === undefined) {
        return of(null);
      }

      // El tipo del activo decide la familia de plantilla: un ascensor se
      // inspecciona con `elevator-annual`, una caldera con `boiler-annual`.
      // Es la única regla de negocio de esta pantalla y vive aquí porque es
      // una decisión de pantalla; si mañana la comparte otra, se muda.
      return this.templateState.resolveForDay(templateIdForAssetType(asset.type), this.today);
      //   const TEMPLATE_BY_ASSET_TYPE: Readonly<Record<AssetType, string>> = {
      //     elevator: 'elevator-annual',
      //     boiler: 'boiler-annual',
      //     tank: 'tank-annual',
      //     fire_system: 'fire-system-annual',
      //   };
      //   function templateIdForAssetType(type: AssetType): string {
      //     return TEMPLATE_BY_ASSET_TYPE[type];
      //   }
      // Ojo: la semilla sólo trae plantillas de ascensor y de caldera, así que
      // elegir un tanque da `none` — y ver ese caso con datos reales vale más
      // que leerlo en la tabla de bordes de la Fase 7.
    }),
  );

  start(resolution: TemplateResolution): void {
    if (resolution.status !== 'resolved') {
      // Ni con hueco ni con solape se empieza una inspección. Que el sistema
      // se niegue a elegir es la razón de que la unión discriminada de la
      // Fase 7 tenga tres casos y no dos.
      return;
    }

    const user = this.authService.getCurrentUser();

    if (user === null) {
      return;
    }

    this.inspectionApi
      .create({
        assetId: this.assetControl.value,
        inspectorId: user.sub,
        templateId: resolution.template.templateId,
        // 🧭 Se congela AQUÍ, y para siempre. A partir de este POST, esta
        // inspección se lee con esta versión aunque mañana salgan cinco más.
        templateVersion: resolution.template.version,
        startedAt: new Date().toISOString(),
      })
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe((created) => void this.router.navigate(['/inspections', created.id]));
  }
}
```

**Detalles con intención**

- **Los tres estados de la resolución se pintan y sólo uno deja continuar.** Con `none` el mensaje dice que no hay plantilla vigente para hoy y que hay que revisar las fechas; con `ambiguous`, que hay dos y que el sistema no elige. Ninguno de los dos deja pulsar "Empezar".
- **`templateVersion` se copia en el momento de crear.** Es la única escritura de ese campo en todo el sistema: ni el formulario ni el autosave lo tocan, y el `PATCH` de 5.1 sólo manda `answers` y `status` precisamente para que no pueda perderse.

### 5.10 🧬 Las dos costuras con el módulo heredado

```ts
// src/app/features/inspections/inspections.module.ts
@NgModule({
  declarations: [InspectionListComponent],
  imports: [
    SharedModule,
    InspectionsRoutingModule,
    EmptyStateComponent,
    // 🧬 Las dos pantallas de esta fase, standalone, alojadas por un NgModule
    // de 2021. Tercera vez que aparece este patrón —activos, plantillas y
    // ahora inspecciones— y ya no hace falta explicarlo: es la regla.
    InspectionFormComponent,
    InspectionStartComponent,
  ],
})
export class InspectionsModule {}
```

```ts
// src/app/features/inspections/inspections-routing.module.ts
// 🧬 RouterModule.forChild() heredado, componentes standalone, y un guard
// FUNCIONAL en canDeactivate. Los guards funcionales existen desde la Fase 2 y
// nunca les ha importado desde qué generación se les registra.
const routes: Routes = [
  { path: '', component: InspectionListComponent },
  // ⚠️ 'new' ANTES que ':id'. Al revés, /inspections/new intentaría cargar la
  // inspección con id "new", el Number('new') daría NaN, y el filter del
  // componente descartaría la emisión: pantalla en blanco y ni un error. La
  // Fase 6 avisó de esto cuando todavía no importaba; aquí sí importa.
  { path: 'new', component: InspectionStartComponent },
  {
    path: ':id',
    component: InspectionFormComponent,
    canDeactivate: [unsavedChangesGuard],
  },
];
```

`InspectionListComponent` se toca lo mínimo y en su estilo: sigue con `constructor`, sigue sin `OnPush`, y pasa de placeholder a listar las inspecciones con su estado, su activo y su versión de plantilla.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Síntoma:** la aplicación se arrastra, el ventilador se acelera y Network no para de recibir `PATCH` aunque nadie escriba.
**Causa:** el formulario se parchea con la respuesta del servidor después de guardar. `patchValue` dispara `valueChanges`, que dispara el guardado, que dispara `patchValue`.
**Fix mínimo:** borrar el `patchValue`. No hace falta nada más.
**Lo que importa:** es el **incidente 11**, y no da ni un error. Un bucle infinito con una petición de red por vuelta se parece muchísimo a "la aplicación va lenta", que es el ticket más inútil que existe. Lo que lo delata es Network, no la consola.

**Síntoma:** cambias de la inspección 500 a la 501 desde el listado y aparecen cuatro ítems donde debería haber tres, con el último vacío.
**Causa:** el formulario se parcheó en vez de reconstruirse. Angular reutiliza el componente cuando sólo cambia el parámetro de ruta —`ngOnInit` no vuelve a correr— y los controles de la inspección anterior siguen ahí.
**Fix mínimo:** derivar el formulario de `paramMap`, como en 5.5.
**Lo que importa:** es el **incidente 10**, y es la trampa favorita de las rutas con parámetro. La versión defensiva —limpiar los controles antes de parchear— también funciona y envejece peor: hay que acordarse cada vez. Derivarlo de la ruta hace el bug imposible en vez de improbable.

**Síntoma:** `NG0100: ExpressionChangedAfterItHasBeenCheckedError` en la consola, señalando el contador de progreso.
**Causa:** el valor se escribe desde `ngAfterViewInit` o desde una suscripción que emite de forma síncrona después de que la vista ya fue revisada.
**Fix mínimo:** calcularlo como observable y pintarlo con `async`, que es lo que hace 5.5.
**Lo que importa:** y esto es lo que hay que memorizar — **este error sólo existe en desarrollo**. Angular hace la doble comprobación únicamente en modo dev; en el build de producción no se lanza, y la pantalla se queda mostrando un valor viejo sin decir nada. Es el único error del curso que empeora al desplegarlo.

**Síntoma:** al completar, el botón sigue deshabilitado aunque parezca que está todo respondido.
**Causa:** algún ítem con `photoRequired: true` tiene respuesta pero no `evidenceUrl`.
**Fix mínimo:** ninguno; el mensaje tiene que decir cuál.
**Lo que importa:** un botón deshabilitado sin explicación es la versión moderna de "no me deja guardar y no dice por qué", que es la pieza forense de la Fase 6. El `missingEvidence` de 5.4 existe para que el mensaje pueda nombrar el ítem.

### Pieza forense de esta fase

Tres investigaciones, y las tres se resuelven mirando fuera del código.

**El bucle de `valueChanges`.** Network con el filtro en `Fetch/XHR` y la aplicación quieta, sin tocar nada. Si siguen saliendo peticiones, hay un bucle. Para ubicarlo sin leer el archivo entero: pon un `console.count('valueChanges')` en la suscripción y otro en el `next` del guardado. Si los dos crecen a la vez y sin parar, el ciclo pasa por la red; si sólo crece el primero, el bucle es interno —un `valueChanges` que escribe en el mismo formulario— y no hace falta ni abrir Network.

**El control huérfano.** Con la pantalla abierta, selecciona el `<form>` en el inspector y en la consola:

```js
const component = ng.getComponent($0);
// Las claves del formulario tienen que ser EXACTAMENTE los itemId de la
// plantilla que la inspección guardó.
Object.keys(component.currentView.form.controls);
Object.keys(component.currentView.template.items.map((item) => item.id));
```

Si la primera lista tiene claves que la segunda no, ahí está el huérfano — y su nombre te dice de dónde vino: si es un `itemId` de otra plantilla, es el incidente 10; si es un ítem retirado de la misma familia, es la respuesta huérfana de 5.4 y es correcto.

**`NG0100` y su desaparición.** Provócalo en desarrollo, míralo, y después corre `ng build --configuration production`, sirve el `dist/` y repite el gesto. El error no aparece. Lo que aparece —o mejor dicho, lo que no aparece— es el valor actualizado. Guarda esa sensación: en la Fase 13 vas a ver la versión general del mismo problema, cuando el stack trace minificado te oculte otra cosa distinta.

> 📄 El recorrido completo, con los tres tickets literales y la salida de cada paso, en `forense-fase-08.md`.

**🧨 Rompe a propósito**

Dos roturas de una línea, y las dos hay que verlas una vez en la vida.

1. **Añade `view.form.patchValue(saved)` dentro del `tap` de `persist()`**, sin `emitEvent: false`. Escribe una letra y quita las manos del teclado. Network se llena solo, y la única forma de pararlo es recargar. Ahora ponle `{ emitEvent: false }`: el bucle para. Y ahora escribe una nota larga con `CHAOS=latency` puesto — mira cómo, a mitad de frase, lo que escribiste se sustituye por lo que el servidor devolvió hace dos segundos. Eso es lo que "arregla" el `emitEvent: false`.

2. **Añade un `ngAfterViewInit` que escriba `this.progressLabel = …`** y bíndalo en la plantilla. `NG0100` en rojo, inmediato. Compila para producción y repítelo: silencio absoluto, y la etiqueta se queda en el valor de antes.

---

## 🧪 7. Ejercicios (35)

**🟢 Fácil (1–9)**

1. Escribe `InspectionApiService` completo y prueba `saveAnswers` con `curl` contra la inspección **504**, que está agendada y sin respuestas. Comprueba en `db.json` que el `status` pasó a `in_progress` y que `templateVersion` sigue igual.
2. Escribe `buildAnswerForm` y constrúyelo dos veces sin abrir el navegador: para la 501 (v1) y para la 500 (v2). Cuenta los controles de cada uno y explica de dónde sale la diferencia.
3. **Diagnóstico.** Abre `/inspections/501` con Network abierto. Confirma que la petición a `/templates` lleva `version=1` y que la respuesta trae tres ítems. Copia la URL entera.
4. **Diagnóstico.** Abre `/inspections/500`, que tiene una respuesta de cuatro ítems. Anota qué controles vienen rellenos, cuáles vacíos, y qué valor tiene `evidenceUrl` en cada uno.
5. Implementa `oneOfValidator` y provócalo: edita `db.json` y ponle a una respuesta de la 500 el valor `"no_se"`. Describe qué marca el formulario al cargar.
6. Comprueba los validadores derivados: `main-cable` tiene `photoRequired: true` y `emergency-brake` no. Responde los dos sin evidencia y anota cuál queda inválido.
7. **Diagnóstico.** Cambia una nota y mira el cuerpo del `PATCH`. Anota cuántas respuestas viajan y cuántas habían cambiado de verdad. Ése es el número que justifica la 💸 de 5.1.
8. Pinta el "3 de 4 ítems respondidos" con `computeProgress` y comprueba que sube al responder y baja al borrar una respuesta.
9. **Diagnóstico.** Con `CHAOS=latency`, escribe una nota de diez palabras y cuenta los `PATCH` en Network. Después baja `AUTOSAVE_DEBOUNCE_MS` a 300 y repite. Entrega los dos números.

**🟡 Intermedio (10–20)**

10. Monta el autosave completo con los cinco estados de `AutosaveState` pintados en la cabecera. Comprueba que "Cambios sin guardar" aparece **antes** del debounce y no después.
11. **Diagnóstico.** Añade el `patchValue` del 🧨 sin `emitEvent: false` y describe el bucle con datos: cuántas peticiones por minuto, qué dice la consola (nada), y qué habrías mirado tú primero si te llega el ticket "la aplicación va lenta".
12. Repite con `{ emitEvent: false }` y explica en cinco líneas por qué el bucle para y por qué la solución sigue siendo mala. Provoca la pérdida de datos con `CHAOS=latency` para demostrarlo.
13. **Diagnóstico.** Navega de la 500 a la 501 desde el listado, sin recargar. Cuenta los controles del formulario en la consola. Después rompe a propósito la derivación —guarda el formulario en un campo y parchéalo— y vuelve a contar. Entrega los dos números.
14. 🧬 **Estilo.** Ticket: *"en el listado de inspecciones, el estado debería mostrarse en español"*. El archivo es `InspectionListComponent`, heredado. Escribe el fix y justifica por qué no lo convertiste a standalone ni le pusiste `OnPush` de paso.
15. 🧬 **Estilo.** Ticket: *"al completar una inspección, el mensaje debería decir qué ítem falta, no cuántos"*. El archivo es `InspectionFormComponent`, nuevo. Escríbelo en su estilo, usando `missingEvidence` y el progreso, y di dónde **no** debería vivir ese cálculo.
16. Implementa `unsavedChangesGuard` y regístralo. Comprueba los tres caminos: sin cambios sale directo, con cambios pendientes guarda y sale, y con el último guardado fallido pregunta.
17. **Diagnóstico.** Escribe algo y navega inmediatamente, dentro de la ventana del debounce. Comprueba en Network que el `PATCH` sale igual. Después quita el flush del guard y repite: entrega qué se perdió exactamente.
18. Implementa "Completar" con sus dos condiciones y comprueba que la inspección queda en `completed` con `completedAt` puesto.
19. **Diagnóstico.** Intenta completar la 500 tal como viene de la semilla. Anota qué dice el mensaje, cuántos ítems faltan, y qué controles se marcan en rojo al pulsar.
20. Monta la pantalla de empezar sobre `ASC-CENTRAL-04` y comprueba en `db.json` qué `templateVersion` quedó guardado. Explica de dónde salió ese número.

**🟠 Difícil (21–29)**

21. Escribe el post-mortem completo de ocho puntos del incidente **10** siguiendo `formato-cuaderno-incidentes.md` §7, con su par de tags `inc/10/<slug>-roto` / `-fix`. En el punto 7 —prevención— explica por qué la defensa correcta es de diseño y no una comprobación.
22. Escribe el post-mortem completo de ocho puntos del incidente **11** con su par de tags `inc/11/<slug>-roto` / `-fix`. El punto 3 —evidencia observable— es el interesante: describe qué se ve y qué **no** se ve, y por qué la consola no sirve.
23. **Diagnóstico.** Provoca el `NG0100` con el progreso escrito desde `ngAfterViewInit`. Cópialo entero. Después compila para producción, sirve el `dist/` y repite el gesto. Explica en cinco líneas por qué un error que desaparece al desplegar es peor que uno que no.
24. Publica una v3 de `elevator-annual` sin el ítem `cabin-lighting` y cambia a mano el `templateVersion` de la 503 a 3. Abre la pantalla y describe qué pasa con la respuesta de ese ítem. Después argumenta por qué la decisión de la Fase 7 —no borrarla— es la correcta, y qué habría pasado si la pantalla la ignorara en silencio.
25. **Diagnóstico.** Abre la misma inspección en dos pestañas y escribe en las dos. Describe qué queda guardado y por qué el `PATCH` con el array completo empeora el resultado frente a un `PATCH` por respuesta. Es el argumento que faltaba en la 💸 de 5.1.
26. Quita el `distinctUntilChanged` y tabula entre los campos sin escribir nada. Cuenta los `PATCH` redundantes y calcula cuántos serían en un checklist de sesenta ítems en una jornada de ocho horas.
27. **Diagnóstico.** Levanta el mock con `CHAOS=error CHAOS_RATE=1` y escribe. Describe qué ve el inspector, qué pasa con lo que escribió, y si la tubería del autosave sigue viva después. Quita el `catchError` de `persist()` y repite: ahora el autosave muere para siempre. Explica por qué.
28. Añade reintento al autosave con `retry({ count: 2, delay: 1000 })` y decide qué errores merecen reintento y cuáles no. Un 500 sí; un 400 no. Impleméntalo y di cómo distingues los dos con el `ApiError` de la Fase 3.
29. **Diagnóstico.** El `switchMap` externo del autosave descarta el debounce pendiente al cambiar de inspección. Provócalo: escribe en la 500 y navega a la 501 en menos de segundo y medio, **con el guard desactivado**. Mide qué se pierde. Después reactiva el guard y repite. Explica por qué las dos piezas son una sola decisión.

**🔴 Muy difícil (30–35)**

30. Diseña —sin implementar— el trabajo sin conexión que el `alcance-del-proyecto.md` §5 le atribuye a CertCore: dónde se guardarían las respuestas, cómo se encolaría la sincronización, y qué se hace con un conflicto. Y contesta la pregunta incómoda: si estuviste desconectado tres días y mientras tanto se publicó una v3, ¿con qué versión se sincroniza tu inspección? Pista: la respuesta ya está decidida desde la Fase 7 y es de una línea.
31. Diseña el `PATCH` por respuesta que la 💸 de 5.1 descarta: qué endpoint haría falta en el mock, cómo cambiaría `saveAnswers`, y cuántos bytes se ahorran por pulsación en un checklist de sesenta ítems. Impleméntalo en el mock, mídelo, y decide si lo dejarías puesto.
32. Genera una plantilla de **sesenta** ítems en `db.json` y abre una inspección con ella. Mide el tiempo de construcción del `FormRecord` y el de repintado al escribir en el último campo, con el profiler de Angular DevTools. Decide si hace falta `trackBy`, virtual scroll o partir el checklist en secciones, y justifícalo con los números.
33. Escribe los tests de `buildAnswerForm`, `toAnswers` y `computeProgress`: son funciones puras y no necesitan `TestBed`. Cubre al menos el ítem sin responder, el ítem con evidencia obligatoria, y la respuesta huérfana. Guárdalos: la Fase 12 los va a reclamar.
34. Implementa el guardado **optimista** —marcar "guardado" antes de que el servidor responda— y descríbelo con un caso concreto en el que miente. Después decide cuál de los dos elegirías para un inspector en un sótano con dos rayas de señal, y escribe el argumento en cinco líneas.
35. Añade una regla cruzada entre ítems: si `main-cable` se responde `critical_wear`, la nota de ese ítem pasa a ser obligatoria. Decide dónde vive —¿validador del `FormGroup` del ítem, del `FormRecord` entero, o del dominio?—, impleméntala, y explica qué pasa con esa regla cuando la Fase 9 empiece a derivar hallazgos de la misma condición.

**🔥 Opcionales**

- 🔥 Cambia el modelo de `criteria` para que cada criterio traiga su etiqueta (`{ code, label }`) y elimina la 💸 de `criterion-label.ts`. Toca `db.seed.json`, el modelo de la Fase 3 y el editor de la Fase 7: cuenta los archivos y decide si el arreglo vale su precio con ocho fases encima.
- 🔥 Añade un modo de sólo lectura para las inspecciones `approved` y `rejected`: hoy la pantalla deja editar la 501, que está aprobada, y el `alcance-del-proyecto.md` §5 dice que aprobar es irreversible. Decide si el bloqueo va en el guard, en el formulario o en el estado, y si además debería estar en el backend.
- 🔥 Sustituye el `<textarea>` de la nota por un contador de caracteres y un límite, y comprueba qué le hace al autosave un campo que emite en cada tecla frente a uno que emite al perder el foco.

---

## 📚 8. Referencias

**Documentación oficial**

- https://v16.angular.io/api/forms/FormRecord — la API entera cabe en una pantalla: `addControl`, `removeControl`, `contains`.
- https://v16.angular.io/guide/typed-forms — la sección de `FormRecord` explica exactamente el caso de esta fase: claves dinámicas, tipo de valor conocido.
- https://v16.angular.io/api/forms/AbstractControl#valueChanges y https://v16.angular.io/api/forms/FormGroup#patchValue — la opción `emitEvent`, que es donde nace y muere el incidente 11.
- https://v16.angular.io/api/router/CanDeactivateFn — el guard funcional de 5.7.
- https://v16.angular.io/errors/NG0100 — la página oficial del `ExpressionChangedAfterItHasBeenCheckedError`, incluido el detalle de que la comprobación sólo corre en modo desarrollo.
- https://rxjs.dev/api/operators/debounceTime y https://rxjs.dev/api/operators/concatMap — las dos piezas del autosave.
- https://v16.material.angular.io/components/radio/overview — `mat-radio-group` dentro de un formulario reactivo.

> ⚠️ Casi todo lo que encontrarás sobre "dynamic forms in Angular" es anterior a los formularios tipados y usa `FormGroup` sin genéricos, `FormBuilder.group({})` con un `any` implícito, o un `FormArray` indexado por posición. Compila, funciona, y pierde las dos cosas que esta fase busca: el tipo y la identidad por `itemId`. Si el artículo no menciona `FormRecord`, está describiendo cómo se hacía antes de 2022.

**Orden de lectura sugerido:** la guía de formularios tipados —sólo su sección de `FormRecord`— antes de escribir 5.3, y **A05** si el genérico se te resiste. La página de `NG0100` **después** de haberlo provocado, no antes: leída en frío no significa nada y leída con el error en pantalla se entiende de una vez. Y `concatMap` cuando llegues a 5.6, junto con **A06**, que es donde está la comparación con los otros tres operadores de aplanamiento.

---

## 🚀 9. Cierre y conexión con la siguiente fase

CertCore ya se puede usar. Un inspector abre su inspección, ve exactamente los ítems que su versión de plantilla define, responde, escribe notas, y el sistema guarda solo sin que nadie pulse nada. Si se va la señal, se lo dice; si intenta salir con algo pendiente, lo guarda antes; si intenta cerrar sin terminar, le dice qué falta.

Y debajo de esa pantalla hay tres decisiones que se van a notar durante el resto del curso. El formulario es una **función pura de sus datos**, así que se puede testear sin navegador. Se **deriva de la ruta**, así que el control huérfano no es improbable: es imposible. Y después de guardar **no se toca**, así que el bucle no existe.

Lo que te llevas para cualquier proyecto: cuando una pantalla se construye desde datos, la pregunta que ordena todo es *"¿qué es dato y qué es código?"*. El número de campos, las opciones de cada uno y qué es obligatorio son dato — viven en la plantilla y cambian sin desplegar. El cómo se pinta, cómo se guarda y cuándo se bloquea es código. La línea entre las dos cosas es la que decide si añadir un ítem al checklist cuesta un `db.json` o un sprint.

La **Fase 9** toma lo que hoy se guarda y le da consecuencias. `answer: 'critical_wear'` deja de ser una cadena y se convierte en un hallazgo con severidad, derivada del `nonComplianceSeverity` que la plantilla define desde la Fase 3. Y con ella llega la regla que bloquea de verdad: un hallazgo `critical` sin resolver impide emitir el certificado. También es donde se paga la 💸 de la Fase 6 —las reglas de negocio se mudan del componente al servicio— y donde `null` frente a `undefined` bajo `strict` deja de ser una curiosidad de tipos y se convierte en el hallazgo que no bloqueó nada.

> **La señal de que quedó bien:** cuando abres una inspección de hace dos años, cuentas los ítems, coinciden con el papel firmado, y no tienes que comprobar nada más — porque sabes que la pantalla no tenía forma de equivocarse.

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-08 -m "F8 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`fase 08: …`) y los de ejercicio su
> número (`fase 08 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f08/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva el cuaderno. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
>
> Los dos incidentes de esta fase se reproducen con una línea cada uno —el
> `patchValue` de más y el formulario parcheado en vez de derivado—, así que sus
> ramas `inc/10/…-roto` e `inc/11/…-roto` salen de este tag y el `git diff`
> contra su `-fix` cabe en una pantalla. Es la mejor demostración del curso de
> que el tamaño del diff no dice nada del tamaño del bug. Y ojo con el
> `db.json`: esta fase **escribe respuestas** en cada guardado, así que la
> inspección 504 ya no está como la sembró la Fase 3. Decide si lo commiteas o
> lo devuelves con `npm run seed` antes de etiquetar.

---

## 📌 Pendientes sugeridos

- **La 💸 del guardado completo tiene una pagadora a medias y conviene que lo sepa.** El `PATCH` manda el array `answers` entero en cada guardado, y el costo se mide en la **Fase 11**, con el volumen del dashboard delante. Su prompt no lo menciona todavía. → **Aviso para el chat de la Fase 11**: al medir el dashboard, medir también el peso de un autosave con una plantilla larga; el ejercicio 31 de esta fase ya deja el endpoint diseñado.
- **Las inspecciones `approved` y `rejected` se pueden editar, y no deberían.** El `alcance-del-proyecto.md` §5 dice que aprobar es irreversible, y hoy la 501 —aprobada— se abre y se edita como cualquier otra. Es el ejercicio 🔥 de sólo lectura, y es material de la **Fase 9**, que es la que introduce esos dos estados de verdad. → **Aviso para el chat de la Fase 9.**
- **El trabajo sin conexión sigue siendo historia, no código.** Esta fase lo declaró fuera y el ejercicio 30 lo diseña. Si el curso quisiera construirlo alguna vez, no es una fase: es un apéndice 🔥 y toca IndexedDB, colas y resolución de conflictos. → **Decisión de proyecto**, sin urgencia.
- **La regla "el tipo de activo decide la familia de plantilla"** (5.9, `templateIdForAssetType`) es la primera regla de negocio que relaciona dos entidades del dominio y hoy vive en la pantalla de empezar. Es exactamente la clase de regla que la **Fase 9** va a mudar al servicio cuando pague la 💸 de la Fase 6. → **Aviso para el chat de la Fase 9**: son tres reglas a mudar, no dos.
- **`AUTOSAVE_DEBOUNCE_MS` es una constante exportada para que se pueda testear.** La **Fase 12** tiene que testear el número, no reimplementarlo: un test que espere 1500 ms de verdad tarda 1500 ms; el que corresponde usa `fakeAsync` y `tick`. → **Aviso para el chat de la Fase 12.**
- **El progreso se recalcula entero en cada emisión de `valueChanges`.** Con cuatro ítems es gratis y con sesenta ya no (ejercicio 32). Es la misma clase de problema que el dashboard de la **Fase 11** va a tener con las agregaciones, y conviene resolverlo una vez y con el mismo criterio en los dos sitios. → **Aviso para el chat de la Fase 11.**
- 🔥 **Un diagrama del ciclo del autosave** —`valueChanges` → pendiente → debounce → guardando → guardado, con la flecha del bucle marcada en rojo— explicaría §4 mejor que sus cuatro pasos numerados. Es el sexto pendiente de ilustración del curso. Pendiente de dibujo, no de contenido.

### Reservas para el cuaderno de incidentes

Los enunciados ya están escritos en el índice de [`cuaderno-incidentes.md`](cuaderno-incidentes.md), que es donde viven; acá queda constancia de qué fase los produce. **El ID no se reasigna nunca.**

| ID | Título | Categoría | Dif. |
|---|---|---|---|
| 10 | "Cambié de inspección desde el listado y me aparecieron ítems de la otra" | Versionado normativo | 🟠 |
| 11 | "Escribo una letra y la aplicación se queda pegada; el ventilador se dispara" | Formularios dinámicos | 🟠 |
