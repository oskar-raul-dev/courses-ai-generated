import { NgIf } from '@angular/common';
import { ChangeDetectionStrategy, Component, DestroyRef, OnInit, inject } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';

import { ApiError } from '../../../core/api/api-error';
import { ClientApiService } from '../../../core/api/client-api.service';
import { ClientStateService } from '../../../core/state/client-state.service';
import { uniqueTaxIdValidator } from '../unique-tax-id.validator';

/**
 * El tipo del formulario, con la nulabilidad decidida: los dos campos SIEMPRE
 * tienen un valor, aunque sea la cadena vacía. Compáralo con el LoginForm de
 * la Fase 2, que arrastra un `| null` de la migración de Angular 14 y paga por
 * él una guarda que nunca se ejecuta.
 */
interface ClientForm {
  legalName: FormControl<string>;
  taxId: FormControl<string>;
}

@Component({
  selector: 'cc-client-form',
  standalone: true,
  imports: [
    NgIf,
    ReactiveFormsModule,
    RouterLink,
    MatButtonModule,
    MatFormFieldModule,
    MatInputModule,
    // Por el servicio, no por sus directivas. Ver el comentario del listado.
    MatSnackBarModule,
  ],
  templateUrl: './client-form.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ClientFormComponent implements OnInit {
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  private readonly clientApi = inject(ClientApiService);
  private readonly clientState = inject(ClientStateService);
  private readonly snackBar = inject(MatSnackBar);
  private readonly destroyRef = inject(DestroyRef);

  /** `null` en alta, el id del cliente en edición. Decide todo lo demás. */
  private readonly clientId: number | null = this.readClientId();

  readonly isEdit = this.clientId !== null;

  submitting = false;

  readonly form = new FormGroup<ClientForm>({
    legalName: new FormControl('', {
      nonNullable: true,
      validators: [Validators.required, Validators.minLength(3)],
    }),
    taxId: new FormControl('', {
      nonNullable: true,
      validators: [Validators.required, Validators.pattern(/^\d{9,10}$/)],
      // El validador asíncrono va en su propio parámetro, no mezclado con los
      // síncronos. Angular corre los síncronos primero y sólo llama al
      // asíncrono si aquéllos pasaron: no se pregunta al servidor por un NIT
      // que ni siquiera tiene nueve dígitos.
      asyncValidators: [uniqueTaxIdValidator(this.clientApi, this.clientId)],
    }),
  });

  ngOnInit(): void {
    if (this.clientId === null) {
      return;
    }

    this.clientApi
      .getById(this.clientId)
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe({
        // setValue y no patchValue: el formulario tiene exactamente estos dos
        // campos, y setValue falla en compilación si mañana se añade un
        // tercero y alguien olvida rellenarlo. patchValue lo dejaría vacío
        // en silencio.
        next: (client) => this.form.setValue({ legalName: client.legalName, taxId: client.taxId }),
        error: () => {
          this.snackBar.open('No se pudo cargar el cliente.', 'Cerrar', { duration: 6000 });
          void this.router.navigate(['/clients']);
        },
      });
  }

  submit(): void {
    // `pending` es el estado mientras el validador asíncrono está en vuelo, y
    // durante ese rato `invalid` es false. Sin esta comprobación, pulsar
    // rápido guarda un NIT repetido. Es el bug más caro de esta pantalla.
    if (this.form.invalid || this.form.pending) {
      this.form.markAllAsTouched();
      return;
    }

    // Sin guarda de null. Ésa es toda la ganancia de `nonNullable`, y se ve
    // mejor comparándola con el submit() del login de la Fase 2.
    const { legalName, taxId } = this.form.getRawValue();

    this.submitting = true;

    const request$ =
      this.clientId === null
        ? this.clientState.create({ legalName, taxId })
        : this.clientState.update({ id: this.clientId, legalName, taxId });

    request$.pipe(takeUntilDestroyed(this.destroyRef)).subscribe({
      next: () => {
        this.snackBar.open(
          this.isEdit ? 'Cliente actualizado.' : 'Cliente creado.',
          'Cerrar',
          { duration: 4000 },
        );
        void this.router.navigate(['/clients']);
      },
      error: (error: unknown) => {
        this.submitting = false;
        this.snackBar.open(
          error instanceof ApiError ? error.message : 'No se pudo guardar el cliente.',
          'Cerrar',
          { duration: 6000 },
        );
      },
    });
  }

  /**
   * El parámetro de ruta llega como `string | null` y el modelo pide `number`.
   * La conversión se hace UNA vez, aquí, en vez de en cada uso.
   */
  private readClientId(): number | null {
    const raw = this.route.snapshot.paramMap.get('id');

    if (raw === null) {
      return null;
    }

    const parsed = Number(raw);

    // Number('abc') es NaN, y NaN pasaría como number sin que strict se queje.
    // Es el hueco clásico del sistema de tipos: el tipo dice number y el valor
    // no sirve para nada.
    return Number.isInteger(parsed) ? parsed : null;
  }
}
