import { NgModule } from '@angular/core';

import { SharedModule } from '../../shared/shared.module';
import { TemplateEditorComponent } from './template-editor/template-editor.component';
import { TemplateListComponent } from './template-list/template-list.component';
import { TemplateVersionsComponent } from './template-versions/template-versions.component';
import { TemplatesRoutingModule } from './templates-routing.module';

@NgModule({
  declarations: [TemplateListComponent],
  imports: [
    SharedModule,
    TemplatesRoutingModule,
    // 🧬 Dos pantallas de 2025 alojadas por un módulo de 2021. Van en `imports`
    // porque son standalone; en `declarations` no compilaría, y el mensaje de
    // error te lo diría — es el ejercicio 6 de la Fase 5.
    TemplateVersionsComponent,
    TemplateEditorComponent,
  ],
})
export class TemplatesModule {}
