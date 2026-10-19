import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

import { CertificateListComponent } from './certificate-list/certificate-list.component';

// path: '' porque el prefijo 'certificates' ya lo puso la ruta padre. Repetirlo
// aquí produciría /certificates/certificates, que es el segundo error más común del día.
const routes: Routes = [{ path: '', component: CertificateListComponent }];

@NgModule({
  // forChild() en los módulos de feature: se cuelga del router que ya existe
  // en vez de crear uno nuevo.
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class CertificatesRoutingModule {}
