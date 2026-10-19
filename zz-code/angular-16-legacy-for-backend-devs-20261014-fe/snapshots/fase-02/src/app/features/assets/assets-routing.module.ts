import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

import { AssetListComponent } from './asset-list/asset-list.component';

// path: '' porque el prefijo 'assets' ya lo puso la ruta padre. Repetirlo
// aquí produciría /assets/assets, que es el segundo error más común del día.
const routes: Routes = [{ path: '', component: AssetListComponent }];

@NgModule({
  // forChild() en los módulos de feature: se cuelga del router que ya existe
  // en vez de crear uno nuevo.
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class AssetsRoutingModule {}
