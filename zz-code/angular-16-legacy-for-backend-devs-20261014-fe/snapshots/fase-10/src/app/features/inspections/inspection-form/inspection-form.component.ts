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
import { criterionLabel } from '../../../core/domain/criterion-label';
import { BusinessRuleError } from '../../../core/domain/inspection-rules';
import { InspectionStateService } from '../../../core/state/inspection-state.service';
import { ChecklistTemplate } from '../../../core/models/checklist-template.model';
import { Inspection, InspectionAnswer } from '../../../core/models/inspection.model';
import { CanLeave } from '../../../core/guards/unsaved-changes.guard';
import {
  ConfirmDialogComponent,
  ConfirmDialogData,
} from '../../../shared/confirm-dialog/confirm-dialog.component';

/** Cada cuánto se guarda solo. Ver el porqué en el comentario de abajo. */
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
  private readonly inspectionState = inject(InspectionStateService);
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

  private startAutosave(): void {
    this.view$
      .pipe(
        // switchMap aquí cambia de TUBERÍA, no cancela un guardado en vuelo:
        // al navegar a otra inspección, el debounce pendiente de la anterior se
        // descarta. Eso sería una pérdida de datos silenciosa… si no fuera
        // porque el guard de canLeave() fuerza el guardado ANTES de que la
        // navegación ocurra. Las dos piezas se sostienen mutuamente.
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

      // Corrección respecto de la lección: el mensaje dice CUÁLES faltan, no
      // cuántas. Un número sin nombres obliga a buscar el ítem a ciegas.
      const missing = [...progress.unanswered, ...progress.missingEvidence];
      const titles = view.template.items
        .filter((item) => missing.includes(item.id))
        .map((item) => item.title)
        .join(', ');

      this.snackBar.open(`Falta completar: ${titles}.`, 'Cerrar', { duration: 6000 });
      return;
    }

    // La regla de cierre vive en el servicio (fase 9): la pantalla sólo la pide.
    this.inspectionState
      .complete(view.inspection, toAnswers(view.form))
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe({
        next: () => {
          this.snackBar.open('Inspección completada.', 'Cerrar', { duration: 4000 });
          void this.router.navigate(['/inspections']);
        },
        error: (error: unknown) =>
          this.snackBar.open(
            error instanceof ApiError || error instanceof BusinessRuleError
              ? error.message
              : 'No se pudo completar la inspección.',
            'Cerrar',
            { duration: 8000 },
          ),
      });
  }

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
}
