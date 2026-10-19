import { NgModule } from '@angular/core';

import { SharedModule } from '../../shared/shared.module';
import { InspectionListComponent } from './inspection-list/inspection-list.component';
import { InspectionsRoutingModule } from './inspections-routing.module';

@NgModule({
  declarations: [InspectionListComponent],
  // SharedModule trae CommonModule y los doce de Material 💸.
  imports: [SharedModule, InspectionsRoutingModule],
})
export class InspectionsModule {}
