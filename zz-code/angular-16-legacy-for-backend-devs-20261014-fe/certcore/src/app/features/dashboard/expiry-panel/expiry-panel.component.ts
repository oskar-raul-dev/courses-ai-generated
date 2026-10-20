import { NgFor, NgIf } from '@angular/common';
import { ChangeDetectionStrategy, Component, Input } from '@angular/core';
import { RouterLink } from '@angular/router';

import { AssetCoverage, ExpiryBuckets } from '../../../core/domain/dashboard-metrics';

@Component({
  selector: 'cc-expiry-panel',
  standalone: true,
  // NgFor de verdad: sin él el build no avisa, la lista sale vacía y la
  // consola dice NG0303 (le pasó al formulario de activos de la Fase 6).
  imports: [NgFor, NgIf, RouterLink],
  templateUrl: './expiry-panel.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ExpiryPanelComponent {
  @Input({ required: true }) buckets: ExpiryBuckets = {
    revoked: [],
    expired: [],
    in30: [],
    in60: [],
    in90: [],
    later: [],
  };
  @Input({ required: true }) coverage: readonly AssetCoverage[] = [];

  trackByAssetId(_index: number, entry: AssetCoverage): string {
    return entry.asset.id;
  }
}
