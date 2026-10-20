import { NgModule } from '@angular/core';

import { EmptyStateComponent } from '../../shared/empty-state/empty-state.component';
import { SharedModule } from '../../shared/shared.module';
import { DashboardHomeComponent } from './dashboard-home/dashboard-home.component';
import { DashboardRoutingModule } from './dashboard-routing.module';
import { ExpiryChartComponent } from './expiry-chart/expiry-chart.component';
import { ExpiryPanelComponent } from './expiry-panel/expiry-panel.component';
import { FindingsChartComponent } from './findings-chart/findings-chart.component';
import { InspectorRatesComponent } from './inspector-rates/inspector-rates.component';
import { KpiCardComponent } from './kpi-card/kpi-card.component';

@NgModule({
  declarations: [DashboardHomeComponent],
  imports: [
    SharedModule,
    DashboardRoutingModule,
    // 🧬 Seis componentes standalone importados por un NgModule de 2021 para
    // que su propio componente declarado pueda usarlos en la plantilla. Es la
    // misma línea de siempre y significa algo distinto: aquí el heredado no
    // aloja al nuevo, lo CONTIENE.
    KpiCardComponent,
    ExpiryPanelComponent,
    InspectorRatesComponent,
    FindingsChartComponent,
    ExpiryChartComponent,
    EmptyStateComponent,
  ],
})
export class DashboardModule {}
