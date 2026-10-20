import { NgModule } from '@angular/core';

import { SharedModule } from '../../shared/shared.module';
import { CertificateDetailComponent } from './certificate-detail/certificate-detail.component';
import { CertificateListComponent } from './certificate-list/certificate-list.component';
import { CertificatesRoutingModule } from './certificates-routing.module';

@NgModule({
  // `declarations` vacío: ya no hay nada que declarar. Se deja el NgModule porque
  // el `loadChildren` de app-routing.module.ts lo apunta.
  imports: [
    SharedModule,
    CertificatesRoutingModule,
    // 🧬 Los dos standalone de esta fase, alojados por el módulo de 2021.
    CertificateListComponent,
    CertificateDetailComponent,
  ],
})
export class CertificatesModule {}
