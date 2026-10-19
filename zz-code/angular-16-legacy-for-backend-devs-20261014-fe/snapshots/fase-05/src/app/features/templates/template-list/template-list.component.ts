import { Component, OnInit } from '@angular/core';
import { Observable } from 'rxjs';

import { FeatureState } from '../../../core/state/feature-state.model';
import { TemplateStateService } from '../../../core/state/template-state.service';
import { ChecklistTemplate } from '../../../core/models/checklist-template.model';

@Component({
  selector: 'cc-template-list',
  templateUrl: './template-list.component.html',
})
export class TemplateListComponent implements OnInit {
  readonly state$: Observable<FeatureState<ChecklistTemplate>>;

  // Sigue siendo un componente de 2021: inyección por constructor, sin OnPush,
  // declarado en TemplatesModule. Pagar una deuda NO es modernizar el archivo.
  // Y el pipe async, que es lo que resuelve esto, existe desde Angular 2: no
  // hay nada anacrónico en usarlo aquí.
  constructor(private readonly templateState: TemplateStateService) {
    // Se asigna en el constructor y no en el campo: un inicializador de campo
    // correría antes de que `templateState` exista. Misma razón que en el
    // formulario de login de la Fase 2.
    this.state$ = templateState.state$;
  }

  ngOnInit(): void {
    this.templateState.load();
  }
}
