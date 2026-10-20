import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

import { TemplateListComponent } from './template-list/template-list.component';

// path: '' porque el prefijo 'templates' ya lo puso la ruta padre. Repetirlo
// aquí produciría /templates/templates, que es el segundo error más común del día.
const routes: Routes = [{ path: '', component: TemplateListComponent }];

@NgModule({
  // forChild() en los módulos de feature: se cuelga del router que ya existe
  // en vez de crear uno nuevo.
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class TemplatesRoutingModule {}
