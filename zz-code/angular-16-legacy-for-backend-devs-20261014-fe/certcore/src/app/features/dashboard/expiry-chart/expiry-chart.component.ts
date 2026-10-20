import { ChangeDetectionStrategy, Component, Input, OnChanges } from '@angular/core';
import { ChartConfiguration } from 'chart.js';
import { NgChartsModule } from 'ng2-charts';

import { ExpiryBuckets } from '../../../core/domain/dashboard-metrics';

@Component({
  selector: 'cc-expiry-chart',
  standalone: true,
  imports: [NgChartsModule],
  template: `
    <section class="chart-block">
      <h3>Vencimientos por ventana</h3>
      <canvas baseChart type="bar" [data]="data" [options]="options"></canvas>
    </section>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ExpiryChartComponent implements OnChanges {
  @Input({ required: true }) buckets: ExpiryBuckets = {
    revoked: [],
    expired: [],
    in30: [],
    in60: [],
    in90: [],
    later: [],
  };

  data: ChartConfiguration<'bar'>['data'] = { labels: [], datasets: [] };

  readonly options: ChartConfiguration<'bar'>['options'] = {
    responsive: true,
    maintainAspectRatio: false,
    animation: false,
    plugins: { legend: { display: false } },
  };

  ngOnChanges(): void {
    this.data = {
      labels: ['Vencidos', '30 días', '60 días', '90 días', 'Más adelante'],
      datasets: [
        {
          label: 'Certificados',
          data: [
            this.buckets.expired.length,
            this.buckets.in30.length,
            this.buckets.in60.length,
            this.buckets.in90.length,
            this.buckets.later.length,
          ],
        },
      ],
    };
  }
}
