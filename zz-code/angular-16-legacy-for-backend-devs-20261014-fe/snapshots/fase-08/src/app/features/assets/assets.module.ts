import { NgModule } from '@angular/core';
import { MatTableModule } from '@angular/material/table';

import { EmptyStateComponent } from '../../shared/empty-state/empty-state.component';
import { SharedModule } from '../../shared/shared.module';
import { AssetFormComponent } from './asset-form/asset-form.component';
import { AssetListComponent } from './asset-list/asset-list.component';
import { AssetsRoutingModule } from './assets-routing.module';

@NgModule({
  declarations: [AssetListComponent],
  imports: [
    SharedModule,
    AssetsRoutingModule,
    EmptyStateComponent,
    // 🧬 El formulario nuevo entra por `imports` porque es standalone. Y
    // MatTableModule se importa aquí, directamente, porque SharedModule dejó de
    // reexportarlo en la Fase 5: un módulo heredado importando lo que usa es
    // exactamente el arreglo correcto, escrito en el estilo del archivo.
    AssetFormComponent,
    MatTableModule,
  ],
})
export class AssetsModule {}
