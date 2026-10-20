import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

import { inspectionEditableGuard } from '../../core/guards/inspection-editable.guard';
import { unsavedChangesGuard } from '../../core/guards/unsaved-changes.guard';
import { InspectionFindingsComponent } from './inspection-findings/inspection-findings.component';
import { InspectionFormComponent } from './inspection-form/inspection-form.component';
import { InspectionListComponent } from './inspection-list/inspection-list.component';
import { InspectionStartComponent } from './inspection-start/inspection-start.component';

// 🧬 RouterModule.forChild() de 2021, componentes standalone de 2025, y dos
// guards funcionales en la misma ruta. Es la cuarta vez que aparece este patrón.
const routes: Routes = [
  { path: '', component: InspectionListComponent },
  // 'start' va ANTES de ':id': si no, "start" se leería como id de inspección.
  { path: 'start', component: InspectionStartComponent },
  {
    path: ':id',
    component: InspectionFormComponent,
    // canActivate corre ANTES de construir el componente; canDeactivate, al
    // salir. Los dos son funcionales y ninguno sabe del otro.
    canActivate: [inspectionEditableGuard],
    canDeactivate: [unsavedChangesGuard],
  },
  // Sin guard: los hallazgos de una inspección aprobada se leen siempre.
  { path: ':id/findings', component: InspectionFindingsComponent },
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class InspectionsRoutingModule {}
