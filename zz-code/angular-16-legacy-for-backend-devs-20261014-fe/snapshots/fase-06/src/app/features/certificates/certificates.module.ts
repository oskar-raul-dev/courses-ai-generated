import { NgModule } from '@angular/core';

import { SharedModule } from '../../shared/shared.module';
import { CertificateListComponent } from './certificate-list/certificate-list.component';
import { CertificatesRoutingModule } from './certificates-routing.module';

@NgModule({
  declarations: [CertificateListComponent],
  // SharedModule trae CommonModule y los doce de Material 💸.
  imports: [SharedModule, CertificatesRoutingModule],
})
export class CertificatesModule {}
