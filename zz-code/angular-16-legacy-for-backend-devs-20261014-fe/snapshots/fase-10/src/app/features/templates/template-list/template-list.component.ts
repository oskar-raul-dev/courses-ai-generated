import { Component, OnInit } from '@angular/core';
import { Observable } from 'rxjs';

import { TemplateFamily } from '../../../core/domain/template-family';
import { TemplateStateService } from '../../../core/state/template-state.service';

// Componente de 2021: inyección por constructor y detección por defecto.
// Cambiar la FORMA del estado obliga a tocarlo —el `state$` que consumía ya
// no tiene `items`—, y se toca sólo para eso. Modernizar de paso es cómo se
// rompen otras tres cosas.
@Component({
  selector: 'cc-template-list',
  templateUrl: './template-list.component.html',
})
export class TemplateListComponent implements OnInit {
  readonly families$: Observable<readonly TemplateFamily[]>;

  constructor(private readonly templateState: TemplateStateService) {
    this.families$ = templateState.families$;
  }

  ngOnInit(): void {
    this.templateState.load();
  }
}
