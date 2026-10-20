import { NgIf } from '@angular/common';
import { ChangeDetectionStrategy, Component, Input } from '@angular/core';
import { MatIconModule } from '@angular/material/icon';

/**
 * Una tarjeta tonta: recibe un número y lo pinta. No inyecta nada, no sabe de
 * dónde salió el dato, y por eso es el componente más fácil de testear del
 * curso entero.
 *
 * `@Input({ required: true })` es de Angular 16.0 y es lo que convierte
 * "olvidé pasarle el valor" en un error de compilación de plantilla en vez de
 * en una tarjeta que dice "undefined" en producción. Antes de la 16 esto se
 * comprobaba en `ngOnInit` con un `throw`, que es lo que hacen dos componentes
 * de 2021 de este mismo sistema.
 */
@Component({
  selector: 'cc-kpi-card',
  standalone: true,
  imports: [NgIf, MatIconModule],
  template: `
    <article class="kpi-card" [class.kpi-card-alert]="alert">
      <mat-icon>{{ icon }}</mat-icon>
      <p class="kpi-card-value">{{ value }}</p>
      <p class="kpi-card-label">{{ label }}</p>
      <p class="kpi-card-hint" *ngIf="hint !== null">{{ hint }}</p>
    </article>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class KpiCardComponent {
  @Input({ required: true }) label = '';
  @Input({ required: true }) value = 0;
  @Input({ required: true }) icon = '';
  /** `null` = sin aclaración. No es lo mismo que la cadena vacía. */
  @Input() hint: string | null = null;
  /** Pinta la tarjeta en rojo. Es la única "alerta" que este curso construye. */
  @Input() alert = false;
}
