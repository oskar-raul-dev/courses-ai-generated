import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

import { CertificateDetailComponent } from './certificate-detail/certificate-detail.component';
import { CertificateListComponent } from './certificate-list/certificate-list.component';

// 🧬 RouterModule.forChild() de 2021 con componentes standalone de 2025.
const routes: Routes = [
  { path: '', component: CertificateListComponent },
  { path: ':id', component: CertificateDetailComponent },
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class CertificatesRoutingModule {}
