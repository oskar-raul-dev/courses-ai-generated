import { NgModule } from '@angular/core';
import { MatTableModule } from '@angular/material/table';

import { EmptyStateComponent } from '../../shared/empty-state/empty-state.component';
import { SharedModule } from '../../shared/shared.module';
import { InspectionFindingsComponent } from './inspection-findings/inspection-findings.component';
import { InspectionFormComponent } from './inspection-form/inspection-form.component';
import { InspectionListComponent } from './inspection-list/inspection-list.component';
import { InspectionStartComponent } from './inspection-start/inspection-start.component';
import { InspectionsRoutingModule } from './inspections-routing.module';

@NgModule({
  declarations: [InspectionListComponent],
  imports: [
    SharedModule,
    InspectionsRoutingModule,
    EmptyStateComponent,
    // 🧬 Las tres pantallas standalone alojadas por el mismo NgModule heredado.
    InspectionFormComponent,
    InspectionStartComponent,
    InspectionFindingsComponent,
    MatTableModule,
  ],
})
export class InspectionsModule {}
