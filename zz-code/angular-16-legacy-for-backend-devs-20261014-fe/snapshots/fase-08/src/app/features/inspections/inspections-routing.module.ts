import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

import { unsavedChangesGuard } from '../../core/guards/unsaved-changes.guard';
import { InspectionFormComponent } from './inspection-form/inspection-form.component';
import { InspectionListComponent } from './inspection-list/inspection-list.component';
import { InspectionStartComponent } from './inspection-start/inspection-start.component';

// 🧬 RouterModule.forChild() heredado apuntando a componentes standalone.
// El guard de salida va en la ruta del formulario: es la única pantalla con
// cambios que pueden perderse al navegar.
const routes: Routes = [
  { path: '', component: InspectionListComponent },
  // 'start' va ANTES de ':id': si no, "start" se leería como id de inspección.
  { path: 'start', component: InspectionStartComponent },
  { path: ':id', component: InspectionFormComponent, canDeactivate: [unsavedChangesGuard] },
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class InspectionsRoutingModule {}
