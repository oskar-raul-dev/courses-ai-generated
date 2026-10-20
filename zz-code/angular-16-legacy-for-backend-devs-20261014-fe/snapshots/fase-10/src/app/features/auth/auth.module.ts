import { NgModule } from '@angular/core';

import { SharedModule } from '../../shared/shared.module';
import { AuthRoutingModule } from './auth-routing.module';
import { LoginComponent } from './login/login.component';

@NgModule({
  declarations: [LoginComponent],
  // SharedModule trae ReactiveFormsModule y los doce de Material 💸 de la Fase 1.
  imports: [SharedModule, AuthRoutingModule],
})
export class AuthModule {}
