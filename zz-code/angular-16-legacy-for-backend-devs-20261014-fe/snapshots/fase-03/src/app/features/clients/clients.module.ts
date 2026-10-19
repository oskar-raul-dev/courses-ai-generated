import { NgModule } from '@angular/core';

import { SharedModule } from '../../shared/shared.module';
import { ClientListComponent } from './client-list/client-list.component';
import { ClientsRoutingModule } from './clients-routing.module';

@NgModule({
  declarations: [ClientListComponent],
  // SharedModule trae CommonModule y los doce de Material 💸.
  imports: [SharedModule, ClientsRoutingModule],
})
export class ClientsModule {}
