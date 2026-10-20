import { Component, OnInit } from '@angular/core';
import { Observable } from 'rxjs';

import { Inspection } from '../../../core/models/inspection.model';
import { FeatureState } from '../../../core/state/feature-state.model';
import { InspectionStateService } from '../../../core/state/inspection-state.service';

// Componente de 2021: constructor y detección por defecto, declarado en InspectionsModule.
@Component({
  selector: 'cc-inspection-list',
  templateUrl: './inspection-list.component.html',
})
export class InspectionListComponent implements OnInit {
  readonly displayedColumns: readonly string[] = ['id', 'assetId', 'version', 'status', 'actions'];

  readonly state$: Observable<FeatureState<Inspection>>;

  constructor(private readonly inspectionState: InspectionStateService) {
    this.state$ = inspectionState.state$;
  }

  ngOnInit(): void {
    this.inspectionState.load();
  }
}
