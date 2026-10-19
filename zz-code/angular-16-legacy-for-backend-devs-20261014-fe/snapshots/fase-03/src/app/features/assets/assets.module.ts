import { NgModule } from '@angular/core';

import { SharedModule } from '../../shared/shared.module';
import { AssetListComponent } from './asset-list/asset-list.component';
import { AssetsRoutingModule } from './assets-routing.module';

@NgModule({
  declarations: [AssetListComponent],
  // SharedModule trae CommonModule y los doce de Material 💸.
  imports: [SharedModule, AssetsRoutingModule],
})
export class AssetsModule {}
