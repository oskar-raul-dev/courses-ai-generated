import { ChangeDetectionStrategy, Component, Input } from '@angular/core';
import { MatIconModule } from '@angular/material/icon';

/**
 * El bloque de "aquí no hay nada todavía", que ya aparece en dos pantallas y va
 * a aparecer en seis. Es standalone y vive en shared/ sin estar declarado en
 * SharedModule: desde hoy, la CARPETA shared y el MÓDULO SharedModule dejan de
 * ser la misma cosa. La carpeta significa "lo usa más de uno"; el módulo
 * significa "lo declara un NgModule", y eso último ya no hace falta.
 */
@Component({
  selector: 'cc-empty-state',
  standalone: true,
  imports: [MatIconModule],
  template: `
    <div class="empty-state">
      <mat-icon class="empty-state-icon">{{ icon }}</mat-icon>
      <p>{{ message }}</p>
    </div>
  `,
  styleUrls: ['./empty-state.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class EmptyStateComponent {
  /**
   * `required: true` es de Angular 16: el compilador exige el atributo en la
   * plantilla y el error llega en el build. Lleva inicializador porque
   * `strictPropertyInitialization` no sabe del `required` del decorador, y
   * porque en CertCore el aserto de no-nulo (`!`) no se usa — regla de la
   * Fase 0.
   */
  @Input({ required: true }) message = '';

  /** Nombre del icono de Material. Opcional, con un valor neutro por defecto. */
  @Input() icon = 'inbox';
}
