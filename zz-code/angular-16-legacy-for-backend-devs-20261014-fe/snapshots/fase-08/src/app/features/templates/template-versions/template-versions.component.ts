import { AsyncPipe, NgFor, NgIf } from '@angular/common';
import { ChangeDetectionStrategy, Component, OnInit, inject } from '@angular/core';
import { FormControl, ReactiveFormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { Observable, combineLatest, startWith, switchMap } from 'rxjs';

import { TemplateResolution } from '../../../core/domain/resolve-template-version';
import { TemplateFamily } from '../../../core/domain/template-family';
import { TemplateStateService } from '../../../core/state/template-state.service';
import { BusinessDay, isBusinessDay, todayInBusinessZone } from '../../../core/time/business-day';
import { EmptyStateComponent } from '../../../shared/empty-state/empty-state.component';

@Component({
  selector: 'cc-template-versions',
  standalone: true,
  imports: [
    AsyncPipe,
    NgFor,
    NgIf,
    ReactiveFormsModule,
    RouterLink,
    MatButtonModule,
    MatFormFieldModule,
    MatIconModule,
    MatInputModule,
    EmptyStateComponent,
  ],
  templateUrl: './template-versions.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class TemplateVersionsComponent implements OnInit {
  private readonly route = inject(ActivatedRoute);
  private readonly templateState = inject(TemplateStateService);

  readonly templateId = this.route.snapshot.paramMap.get('templateId') ?? '';

  /**
   * El día que se está probando. Arranca en hoy y el usuario puede cambiarlo:
   * es la pregunta "¿qué versión regía el 2 de agosto de 2023?" convertida en
   * un campo de texto. nonNullable porque siempre hay un día en la caja.
   */
  readonly dayControl = new FormControl<BusinessDay>(todayInBusinessZone(), {
    nonNullable: true,
  });

  readonly family$: Observable<TemplateFamily | null> = this.templateState.selectedFamily$;

  readonly resolution$: Observable<TemplateResolution> = combineLatest([
    // valueChanges NO emite el valor inicial: sin el startWith, el probador se
    // quedaría en blanco hasta la primera tecla aunque ya tenga la fecha de hoy
    // escrita. Ponerlo aquí —y no con un BehaviorSubject aparte— mantiene una
    // sola fuente para el día.
    this.dayControl.valueChanges.pipe(startWith(this.dayControl.value)),
    // La familia entra en el combineLatest para que el resultado se recalcule
    // cuando el estado se recarga, por ejemplo al volver de publicar.
    this.family$,
  ]).pipe(
    // switchMap porque esto es una LECTURA: si el usuario sigue escribiendo, la
    // resolución anterior sobra.
    switchMap(([day]) => this.templateState.resolveForDay(this.templateId, day)),
  );

  ngOnInit(): void {
    this.templateState.selectFamily(this.templateId);
    this.templateState.load();
  }

  /** Para el `*ngIf` del formulario: un día mal escrito no se resuelve, se avisa. */
  isValidDay(day: string): boolean {
    return isBusinessDay(day);
  }
}
