import { Component } from '@angular/core';
import { Observable } from 'rxjs';

import { DashboardMetricsService } from '../../../core/dashboard/dashboard-metrics.service';
import { DashboardMetrics } from '../../../core/domain/dashboard-metrics';

// Componente HEREDADO. Se toca lo mínimo y en su estilo: `constructor`, sin
// `OnPush`, declarado en el módulo. Pasa de placeholder a cascarón del panel y
// ni una línea más.
@Component({
  selector: 'cc-dashboard-home',
  templateUrl: './dashboard-home.component.html',
  styleUrls: ['./dashboard-home.component.scss'],
})
export class DashboardHomeComponent {
  readonly metrics$: Observable<DashboardMetrics>;

  // Constructor y no `inject()`. El archivo es de 2021 y modernizarlo mientras
  // le añades una línea es exactamente cómo se rompen otras tres cosas.
  constructor(private readonly dashboardMetrics: DashboardMetricsService) {
    this.metrics$ = this.dashboardMetrics.metrics$;
  }
}
