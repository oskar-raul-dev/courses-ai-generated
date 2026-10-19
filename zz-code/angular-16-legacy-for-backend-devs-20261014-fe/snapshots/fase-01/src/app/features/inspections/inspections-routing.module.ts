import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

import { InspectionListComponent } from './inspection-list/inspection-list.component';

// path: '' porque el prefijo 'inspections' ya lo puso la ruta padre. Repetirlo
// aquí produciría /inspections/inspections, que es el segundo error más común del día.
const routes: Routes = [{ path: '', component: InspectionListComponent }];

@NgModule({
  // forChild() en los módulos de feature: se cuelga del router que ya existe
  // en vez de crear uno nuevo.
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class InspectionsRoutingModule {}
