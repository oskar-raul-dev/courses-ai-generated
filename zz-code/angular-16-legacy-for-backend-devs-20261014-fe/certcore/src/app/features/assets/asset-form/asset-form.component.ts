import { AsyncPipe, NgFor, NgIf } from '@angular/common';
import { ChangeDetectionStrategy, Component, DestroyRef, OnInit, inject } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { Observable } from 'rxjs';

import { ApiError } from '../../../core/api/api-error';
import { AssetApiService } from '../../../core/api/asset-api.service';
import { ClientApiService } from '../../../core/api/client-api.service';
import { Asset, AssetType } from '../../../core/models/asset.model';
import { Client } from '../../../core/models/client.model';
import { AssetStateService } from '../../../core/state/asset-state.service';

/**
 * El tipo del formulario, con la misma disciplina de 5.7: ningún `| null`
 * heredado. `installedAt` es un día de calendario y viaja como string,
 * igual que en el modelo de la Fase 3.
 */
interface AssetForm {
  id: FormControl<string>;
  clientId: FormControl<number>;
  type: FormControl<AssetType>;
  description: FormControl<string>;
  installedAt: FormControl<string>;
}

@Component({
  selector: 'cc-asset-form',
  standalone: true,
  imports: [
    AsyncPipe,
    NgFor,
    NgIf,
    ReactiveFormsModule,
    RouterLink,
    MatButtonModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    MatSnackBarModule,
  ],
  templateUrl: './asset-form.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class AssetFormComponent implements OnInit {
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  private readonly assetApi = inject(AssetApiService);
  private readonly clientApi = inject(ClientApiService);
  private readonly assetState = inject(AssetStateService);
  private readonly snackBar = inject(MatSnackBar);
  private readonly destroyRef = inject(DestroyRef);

  /** `null` en alta; el identificador operativo del activo en edición. */
  private readonly assetId: string | null = this.route.snapshot.paramMap.get('id');

  readonly isEdit = this.assetId !== null;

  readonly assetTypes: readonly AssetType[] = ['elevator', 'boiler', 'tank', 'fire_system'];

  /**
   * Opciones del selector de cliente. Va contra ClientApiService y no contra
   * ClientStateService: el estado del listado lleva un buscador, y el selector
   * no debe heredar un criterio de búsqueda que el usuario escribió en otra pantalla.
   */
  readonly clients$: Observable<readonly Client[]> = this.clientApi.getAll();

  submitting = false;

  readonly form = new FormGroup<AssetForm>({
    id: new FormControl('', {
      nonNullable: true,
      validators: [Validators.required, Validators.pattern(/^[A-Z]{3}-[A-Z]+-\d{2}$/)],
    }),
    clientId: new FormControl(0, { nonNullable: true, validators: [Validators.required] }),
    type: new FormControl<AssetType>('elevator', { nonNullable: true }),
    description: new FormControl('', { nonNullable: true, validators: [Validators.required] }),
    installedAt: new FormControl('', { nonNullable: true, validators: [Validators.required] }),
  });

  ngOnInit(): void {
    if (this.assetId !== null) {
      this.assetApi
        .getById(this.assetId)
        .pipe(takeUntilDestroyed(this.destroyRef))
        .subscribe({
          next: (asset) => this.form.setValue({
            id: asset.id,
            clientId: asset.clientId,
            type: asset.type,
            description: asset.description,
            installedAt: asset.installedAt,
          }),
          error: () => {
            this.snackBar.open('No se pudo cargar el activo.', 'Cerrar', { duration: 6000 });
            void this.router.navigate(['/assets']);
          },
        });

      // El identificador es la clave de negocio ("ASC-CENTRAL-03", pintado en el
      // equipo): en edición no se cambia, y deshabilitarlo deja claro por qué.
      this.form.controls.id.disable();

      /**
       * 💸 DEUDA TÉCNICA INTENCIONAL
       * "Un activo no puede cambiar de cliente" es una REGLA DE NEGOCIO y está
       * escrita aquí, en un componente, en forma de un control deshabilitado.
       * Funciona: la pantalla no deja hacerlo. Y falla en todo lo demás — un
       * alta por lote, un import de CSV o la pantalla que la Fase 9 va a
       * escribir pueden saltársela sin enterarse, porque la regla no existe
       * fuera de este archivo.
       * Lo correcto es que viva en AssetStateService, junto a la de "no se borra
       * un cliente con activos" de la Fase 6, que sí está en su sitio.
       * SE PAGA EN LA FASE 9, cuando esta misma clase de regla aparezca por
       * tercera vez y el argumento de la prisa ya no se sostenga.
       */
      this.form.controls.clientId.disable();
    }
  }

  submit(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    // ⚠️ getRawValue() y NO value: `value` OMITE los controles deshabilitados,
    // así que en edición devolvería un objeto sin clientId y el PUT dejaría el
    // activo huérfano. Con el formulario tipado el error se ve en compilación;
    // sin tipar, se ve en producción. Es el segundo síntoma de la sección 6.
    const asset: Asset = this.form.getRawValue();

    this.submitting = true;

    const request$ = this.isEdit
      ? this.assetState.update(asset)
      : this.assetState.create(asset);

    request$.pipe(takeUntilDestroyed(this.destroyRef)).subscribe({
      next: () => {
        this.snackBar.open(this.isEdit ? 'Activo actualizado.' : 'Activo creado.', 'Cerrar', {
          duration: 4000,
        });
        void this.router.navigate(['/assets']);
      },
      error: (error: unknown) => {
        this.submitting = false;
        this.snackBar.open(
          error instanceof ApiError ? error.message : 'No se pudo guardar el activo.',
          'Cerrar',
          { duration: 6000 },
        );
      },
    });
  }
}
