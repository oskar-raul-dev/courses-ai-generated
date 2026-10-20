import { DecimalPipe, NgFor } from '@angular/common';
import { ChangeDetectionStrategy, Component, Input } from '@angular/core';

import { InspectorRate } from '../../../core/domain/dashboard-metrics';

@Component({
  selector: 'cc-inspector-rates',
  standalone: true,
  imports: [NgFor, DecimalPipe],
  template: `
    <section class="inspector-rates">
      <h3>Rechazos por inspector</h3>
      <table>
        <tr><th>Inspector</th><th>Rechazadas</th><th>Decididas</th><th>Tasa</th></tr>
        <tr *ngFor="let row of rates; trackBy: trackByInspector">
          <td>{{ row.inspectorId }}</td>
          <td>{{ row.rejected }}</td>
          <td>{{ row.decided }}</td>
          <td>{{ row.rate === null ? '—' : (row.rate * 100 | number: '1.0-0') + ' %' }}</td>
        </tr>
      </table>
    </section>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class InspectorRatesComponent {
  @Input({ required: true }) rates: readonly InspectorRate[] = [];

  trackByInspector(_index: number, row: InspectorRate): string {
    return row.inspectorId;
  }
}
