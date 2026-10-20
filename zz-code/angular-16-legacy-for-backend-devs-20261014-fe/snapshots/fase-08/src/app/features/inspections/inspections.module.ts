import { NgModule } from '@angular/core';
import { MatTableModule } from '@angular/material/table';

import { EmptyStateComponent } from '../../shared/empty-state/empty-state.component';
import { SharedModule } from '../../shared/shared.module';
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
    // 🧬 Las dos pantallas de esta fase, standalone, alojadas por un NgModule
    // de 2021. Tercera vez que aparece este patrón —activos, plantillas y
    // ahora inspecciones— y ya no hace falta explicarlo: es la regla.
    InspectionFormComponent,
    InspectionStartComponent,
    MatTableModule,
  ],
})
export class InspectionsModule {}
