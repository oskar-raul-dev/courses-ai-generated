import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

import { AssetFormComponent } from './asset-form/asset-form.component';
import { AssetListComponent } from './asset-list/asset-list.component';

// 🧬 RouterModule.forChild() de 2021 apuntando a componentes standalone de
// 2025. `component:` y no `loadComponent:` a propósito: los componentes ya viajan
// en el chunk de este módulo, así que diferirlos otra vez no ahorraría nada.
const routes: Routes = [
  { path: '', component: AssetListComponent },
  { path: 'new', component: AssetFormComponent },
  { path: ':id/edit', component: AssetFormComponent },
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class AssetsRoutingModule {}
