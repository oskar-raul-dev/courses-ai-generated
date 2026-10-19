import { NgModule } from '@angular/core';

import { EmptyStateComponent } from '../../shared/empty-state/empty-state.component';
import { SharedModule } from '../../shared/shared.module';
import { AssetListComponent } from './asset-list/asset-list.component';
import { AssetsRoutingModule } from './assets-routing.module';

@NgModule({
  declarations: [AssetListComponent],
  imports: [
    SharedModule,
    AssetsRoutingModule,
    // 🧬 PUNTO DE CONTACTO ENTRE GENERACIONES
    // Un componente standalone va en `imports`, JAMÁS en `declarations`. La
    // razón es que ya está declarado: se declaró a sí mismo. Ponerlo abajo da
    // un error explícito que vas a provocar en el ejercicio 6.
    EmptyStateComponent,
  ],
})
export class AssetsModule {}
