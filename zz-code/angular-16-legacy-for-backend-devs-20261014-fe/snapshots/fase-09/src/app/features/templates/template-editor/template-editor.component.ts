import { NgFor, NgIf } from '@angular/common';
import { ChangeDetectionStrategy, Component, DestroyRef, OnInit, inject } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import {
  FormArray,
  FormControl,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { filter, first } from 'rxjs';

import { ApiError } from '../../../core/api/api-error';
import { TemplateFamily } from '../../../core/domain/template-family';
import { TemplateStateService } from '../../../core/state/template-state.service';
import { ChecklistItem, ChecklistTemplate } from '../../../core/models/checklist-template.model';
import { FindingSeverity } from '../../../core/models/finding.model';
import { BusinessDay, todayInBusinessZone } from '../../../core/time/business-day';
import { uniqueItemIdsValidator } from '../unique-item-ids.validator';

/**
 * Un ítem del checklist, en forma de formulario. `criteria` es un FormControl
 * de texto con las opciones separadas por comas, y no un FormArray anidado:
 * con cinco criterios de una palabra, un FormArray dentro de otro FormArray
 * multiplica el código sin mejorar la edición. Es una decisión de interfaz y
 * está declarada; el FormArray anidado de verdad es el ejercicio 33, y la
 * Fase 8 construye formularios anidados en runtime, que es donde sí hace falta.
 */
interface ChecklistItemForm {
  id: FormControl<string>;
  title: FormControl<string>;
  criteria: FormControl<string>;
  photoRequired: FormControl<boolean>;
  nonComplianceSeverity: FormControl<FindingSeverity>;
}

interface NewVersionForm {
  validFrom: FormControl<BusinessDay>;
  items: FormArray<FormGroup<ChecklistItemForm>>;
}

@Component({
  selector: 'cc-template-editor',
  standalone: true,
  imports: [
    NgFor,
    NgIf,
    ReactiveFormsModule,
    RouterLink,
    MatButtonModule,
    MatCheckboxModule,
    MatFormFieldModule,
    MatIconModule,
    MatInputModule,
    MatSelectModule,
    MatSnackBarModule,
  ],
  templateUrl: './template-editor.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class TemplateEditorComponent implements OnInit {
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  private readonly templateState = inject(TemplateStateService);
  private readonly snackBar = inject(MatSnackBar);
  private readonly destroyRef = inject(DestroyRef);

  readonly templateId = this.route.snapshot.paramMap.get('templateId') ?? '';
  readonly severities: readonly FindingSeverity[] = ['critical', 'major', 'minor'];

  /**
   * La versión de la que se parte, y la que se va a cerrar al publicar. Se
   * guarda entera —no sólo su número— para que `submit()` no tenga que volver
   * a preguntarle al estado: un `subscribe` dentro de otro `subscribe` es el
   * antipatrón que la guía §6.5 nombra por su nombre.
   */
  previousTemplate: ChecklistTemplate | null = null;
  submitting = false;

  readonly form = new FormGroup<NewVersionForm>({
    validFrom: new FormControl<BusinessDay>(todayInBusinessZone(), {
      nonNullable: true,
      validators: [Validators.required, Validators.pattern(/^\d{4}-\d{2}-\d{2}$/)],
    }),
    items: new FormArray<FormGroup<ChecklistItemForm>>([], {
      // Los ids de ítem son la clave con la que las respuestas se casan con la
      // plantilla. Dos ítems con el mismo id producen una inspección en la que
      // una respuesta pisa a la otra, y eso no se ve hasta la Fase 8.
      validators: [uniqueItemIdsValidator],
    }),
  });

  ngOnInit(): void {
    // Corrección respecto de la lección 07: el editor también fija la familia.
    // Sin esta línea, entrar directo a /templates/:id/new-version deja
    // selectedFamily$ en null y el editor no copia nada ni puede publicar.
    this.templateState.selectFamily(this.templateId);
    this.templateState.load();

    this.templateState.selectedFamily$
      .pipe(
        // El filter con type guard estrecha a TemplateFamily, así que abajo no
        // hace falta comprobar el null otra vez. El first() es lo que hace que
        // la copia se haga UNA vez: sin él, cada recarga del estado pisaría lo
        // que el usuario lleve escrito, que es el bug más frustrante que puede
        // tener un editor.
        filter((family): family is TemplateFamily => family !== null),
        first(),
        takeUntilDestroyed(this.destroyRef),
      )
      .subscribe((family) => {
        this.previousTemplate = family.latest;

        // Aquí está el corazón del versionado, y es aburridísimo a propósito:
        // se COPIAN los ítems de la última versión a controles nuevos. La v2
        // no se toca, no se referencia y no se comparte. Cuando se publique, la
        // v3 tendrá su propia copia completa de todo — la 💸 de la lección.
        for (const item of family.latest.items) {
          this.form.controls.items.push(this.buildItemGroup(item));
        }
      });
  }

  addItem(): void {
    this.form.controls.items.push(
      this.buildItemGroup({
        id: '',
        title: '',
        criteria: [],
        photoRequired: false,
        nonComplianceSeverity: 'minor',
      }),
    );
  }

  removeItem(index: number): void {
    this.form.controls.items.removeAt(index);
  }

  /** Mover un ítem una posición. El orden del array ES el orden del checklist. */
  moveItem(index: number, delta: number): void {
    const target = index + delta;
    const items = this.form.controls.items;

    if (target < 0 || target >= items.length) {
      return;
    }

    const group = items.at(index);
    items.removeAt(index);
    items.insert(target, group);
  }

  submit(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    const previous = this.previousTemplate;

    if (previous === null) {
      // Sin versión de partida no se publica: crear una v1 desde cero es otra
      // operación y no la hace esta pantalla.
      this.snackBar.open('No se pudo determinar la versión anterior.', 'Cerrar', {
        duration: 6000,
      });
      return;
    }

    const raw = this.form.getRawValue();
    const items: readonly ChecklistItem[] = raw.items.map((item) => ({
      id: item.id.trim(),
      title: item.title.trim(),
      criteria: parseCriteria(item.criteria),
      photoRequired: item.photoRequired,
      nonComplianceSeverity: item.nonComplianceSeverity,
    }));

    this.submitting = true;

    // Una sola suscripción, sin anidar: todo lo que hacía falta del estado ya
    // está en `previous`, copiado en ngOnInit.
    this.templateState
      .publishNewVersion(
        {
          templateId: this.templateId,
          version: previous.version + 1,
          validFrom: raw.validFrom,
          items,
        },
        previous,
      )
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe({
        next: (created) => {
          this.snackBar.open(`Publicada la v${created.version}.`, 'Cerrar', { duration: 4000 });
          void this.router.navigate(['/templates', this.templateId]);
        },
        error: (error: unknown) => {
          this.submitting = false;
          this.snackBar.open(
            error instanceof ApiError ? error.message : 'No se pudo publicar la versión.',
            'Cerrar',
            { duration: 8000 },
          );
        },
      });
  }

  private buildItemGroup(item: ChecklistItem): FormGroup<ChecklistItemForm> {
    return new FormGroup<ChecklistItemForm>({
      id: new FormControl(item.id, {
        nonNullable: true,
        validators: [Validators.required, Validators.pattern(/^[a-z][a-z0-9-]*$/)],
      }),
      title: new FormControl(item.title, {
        nonNullable: true,
        validators: [Validators.required],
      }),
      criteria: new FormControl(formatCriteria(item.criteria), {
        nonNullable: true,
        validators: [Validators.required],
      }),
      photoRequired: new FormControl(item.photoRequired, { nonNullable: true }),
      nonComplianceSeverity: new FormControl<FindingSeverity>(item.nonComplianceSeverity, {
        nonNullable: true,
      }),
    });
  }
}

/** 'ok, leaking, blocked' → ['ok', 'leaking', 'blocked']. Sin entradas vacías. */
export function parseCriteria(text: string): readonly string[] {
  return text
    .split(',')
    .map((criterion) => criterion.trim())
    .filter((criterion) => criterion !== '');
}

export function formatCriteria(criteria: readonly string[]): string {
  return criteria.join(', ');
}
