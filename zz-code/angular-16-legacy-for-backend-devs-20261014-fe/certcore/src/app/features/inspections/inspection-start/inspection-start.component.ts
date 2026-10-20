import { AsyncPipe, NgIf } from '@angular/common';
import { ChangeDetectionStrategy, Component, DestroyRef, OnInit, inject } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { FormControl, ReactiveFormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatSelectModule } from '@angular/material/select';
import { Router, RouterLink } from '@angular/router';
import { Observable, combineLatest, of, startWith, switchMap } from 'rxjs';

import { InspectionApiService } from '../../../core/api/inspection-api.service';
import { AuthService } from '../../../core/auth.service';
import { TemplateResolution } from '../../../core/domain/resolve-template-version';
import { AssetStateService } from '../../../core/state/asset-state.service';
import { TemplateStateService } from '../../../core/state/template-state.service';
import { todayInBusinessZone } from '../../../core/time/business-day';

@Component({
  selector: 'cc-inspection-start',
  standalone: true,
  imports: [
    AsyncPipe,
    NgIf,
    ReactiveFormsModule,
    RouterLink,
    MatButtonModule,
    MatFormFieldModule,
    MatSelectModule,
  ],
  templateUrl: './inspection-start.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class InspectionStartComponent implements OnInit {
  private readonly assetState = inject(AssetStateService);
  private readonly templateState = inject(TemplateStateService);
  private readonly inspectionApi = inject(InspectionApiService);
  private readonly authService = inject(AuthService);
  private readonly router = inject(Router);
  private readonly destroyRef = inject(DestroyRef);

  readonly assets$ = this.assetState.assets$;

  readonly assetControl = new FormControl<string>('', { nonNullable: true });

  /** El día del negocio, no el del navegador. Fase 7 §5.1. */
  readonly today = todayInBusinessZone();

  readonly resolution$: Observable<TemplateResolution | null> = combineLatest([
    this.assetControl.valueChanges.pipe(startWith(this.assetControl.value)),
    this.assets$,
  ]).pipe(
    switchMap(([assetId, assets]) => {
      const asset = assets.find((candidate) => candidate.id === assetId);

      if (asset === undefined) {
        return of(null);
      }

      // El tipo del activo decide la familia de plantilla: la regla vive en
      // asset-rules y la pregunta en el servicio de plantillas.
      return this.templateState.resolveForAsset(asset, this.today);
    }),
  );

  ngOnInit(): void {
    this.assetState.load();
    this.templateState.load();
  }

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
