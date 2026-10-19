import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

import { ClientListComponent } from './client-list/client-list.component';

// path: '' porque el prefijo 'clients' ya lo puso la ruta padre. Repetirlo
// aquí produciría /clients/clients, que es el segundo error más común del día.
const routes: Routes = [{ path: '', component: ClientListComponent }];

@NgModule({
  // forChild() en los módulos de feature: se cuelga del router que ya existe
  // en vez de crear uno nuevo.
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class ClientsRoutingModule {}
