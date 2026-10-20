import { ChangeDetectionStrategy, Component, Input, OnChanges } from '@angular/core';
import { NgChartsModule } from 'ng2-charts';
import { ChartConfiguration } from 'chart.js';

import { FindingCount } from '../../../core/domain/dashboard-metrics';

/**
 * ⚠️ ng2-charts **4.1.1** con Chart.js **4.4.x**, que es lo que fija
 * `alcance-del-proyecto.md` §9. En la 4.x se importa `NgChartsModule` y el
 * gráfico se declara con la directiva `baseChart`. La 5.x —que es lo que vas a
 * encontrar en casi todo lo que busques— cambió a `provideCharts()` y a una
 * directiva standalone, así que un ejemplo copiado de un artículo reciente no
 * va a compilar aquí. Es la advertencia de versión más rentable de esta fase.
 *
 * 🧬 Y fíjate en el `imports`: un componente standalone de 2025 importando un
 * NgModule de una librería. No es una costura del proyecto —es de la librería—
 * pero se lee igual, y es la prueba de que standalone no significa "sin
 * NgModules": significa que el componente declara lo que usa.
 */
@Component({
  selector: 'cc-findings-chart',
  standalone: true,
  imports: [NgChartsModule],
  template: `
    <section class="chart-block">
      <h3>Ítems con más hallazgos</h3>
      <canvas baseChart type="bar" [data]="data" [options]="options"></canvas>
    </section>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class FindingsChartComponent implements OnChanges {
  @Input({ required: true }) items: readonly FindingCount[] = [];

  data: ChartConfiguration<'bar'>['data'] = { labels: [], datasets: [] };

  readonly options: ChartConfiguration<'bar'>['options'] = {
    indexAxis: 'y',
    responsive: true,
    maintainAspectRatio: false,
    /**
     * ⭐ La animación apagada, y no es una preferencia estética.
     *
     * Con el refresco de un minuto, cada emisión trae un array NUEVO aunque
     * los números sean idénticos. Chart.js ve datos nuevos y anima las barras
     * desde cero: el panel entero "salta" una vez por minuto delante de alguien
     * que está leyendo un número. Con la animación apagada, un refresco que no
     * cambia nada no se ve.
     *
     * Apagarla es el fix correcto y no un parche: en un panel que se refresca
     * solo, la animación no comunica nada — el usuario no provocó el cambio, así
     * que no hay transición que explicarle.
     */
    animation: false,
    plugins: { legend: { display: false } },
  };

  ngOnChanges(): void {
    // El array se reconstruye sólo cuando cambian los `@Input()`, que con
    // `OnPush` es cuando cambian por referencia. Reconstruirlo en un getter de
    // la plantilla lo haría en cada ciclo de detección, que es el error de
    // rendimiento más caro que se puede cometer con un gráfico.
    this.data = {
      labels: this.items.map((item) => item.title),
      datasets: [
        { label: 'Críticos', data: this.items.map((item) => item.critical) },
        { label: 'Total', data: this.items.map((item) => item.total) },
      ],
    };
  }
}
