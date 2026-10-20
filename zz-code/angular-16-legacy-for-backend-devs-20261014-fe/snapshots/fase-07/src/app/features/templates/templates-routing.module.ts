import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

import { TemplateEditorComponent } from './template-editor/template-editor.component';
import { TemplateListComponent } from './template-list/template-list.component';
import { TemplateVersionsComponent } from './template-versions/template-versions.component';

// 🧬 RouterModule.forChild() heredado apuntando a componentes standalone.
// `component:` y no `loadComponent:`: los tres viajan ya en el chunk de este
// módulo, así que diferirlos otra vez no ahorraría nada.
const routes: Routes = [
  { path: '', component: TemplateListComponent },
  { path: ':templateId', component: TemplateVersionsComponent },
  { path: ':templateId/new-version', component: TemplateEditorComponent },
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class TemplatesRoutingModule {}
