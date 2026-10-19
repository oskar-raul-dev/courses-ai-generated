import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

import { DashboardHomeComponent } from './dashboard-home/dashboard-home.component';

// path: '' porque el prefijo 'dashboard' ya lo puso la ruta padre. Repetirlo
// aquí produciría /dashboard/dashboard, que es el segundo error más común del día.
const routes: Routes = [{ path: '', component: DashboardHomeComponent }];

@NgModule({
  // forChild() en los módulos de feature: se cuelga del router que ya existe
  // en vez de crear uno nuevo.
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class DashboardRoutingModule {}
