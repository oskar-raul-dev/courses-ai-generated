import { Component, OnInit } from '@angular/core';
import { Observable } from 'rxjs';

import { Asset } from '../../../core/models/asset.model';
import { AssetStateService } from '../../../core/state/asset-state.service';
import { FeatureState } from '../../../core/state/feature-state.model';

// Componente de 2021: constructor, sin OnPush, declarado en AssetsModule. Sólo
// cambia la plantilla, que pasa de un texto de espera a la tabla.
@Component({
  selector: 'cc-asset-list',
  templateUrl: './asset-list.component.html',
})
export class AssetListComponent implements OnInit {
  readonly displayedColumns: readonly string[] = ['id', 'type', 'description', 'actions'];

  readonly state$: Observable<FeatureState<Asset>>;

  constructor(private readonly assetState: AssetStateService) {
    this.state$ = assetState.state$;
  }

  ngOnInit(): void {
    this.assetState.load();
  }
}
