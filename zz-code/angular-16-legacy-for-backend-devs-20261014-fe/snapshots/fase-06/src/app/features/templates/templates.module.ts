import { NgModule } from '@angular/core';

import { SharedModule } from '../../shared/shared.module';
import { TemplateListComponent } from './template-list/template-list.component';
import { TemplatesRoutingModule } from './templates-routing.module';

@NgModule({
  declarations: [TemplateListComponent],
  // SharedModule trae CommonModule y los doce de Material 💸.
  imports: [SharedModule, TemplatesRoutingModule],
})
export class TemplatesModule {}
