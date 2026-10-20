import { AsyncPipe, DatePipe, NgFor, NgIf } from '@angular/common';
import { ChangeDetectionStrategy, Component, OnInit, inject } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { RouterLink } from '@angular/router';

import { CertificateView, certificateStatusLabel } from '../../../core/domain/certificate-status';
import { CertificateStateService } from '../../../core/state/certificate-state.service';

/**
 * 🧬 Reemplaza al placeholder que la Fase 1 generó dentro de `CertificatesModule`.
 * Conserva el nombre y cambia el estilo: llenar un stub es escribir código
 * nuevo, no modificar código heredado.
 */
@Component({
  selector: 'cc-certificate-list',
  standalone: true,
  imports: [AsyncPipe, DatePipe, NgFor, NgIf, MatButtonModule, MatIconModule, RouterLink],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './certificate-list.component.html',
  styleUrls: ['./certificate-list.component.scss'],
})
export class CertificateListComponent implements OnInit {
  private readonly certificateState = inject(CertificateStateService);

  readonly views$ = this.certificateState.views$;
  readonly state$ = this.certificateState.state$;

  // Se expone la función para que la plantilla no tenga que conocer el Record.
  readonly statusLabel = certificateStatusLabel;

  ngOnInit(): void {
    this.certificateState.load();
  }

  /** La clase CSS del chip sale del estado DERIVADO, nunca del guardado. */
  chipClass(view: CertificateView): string {
    return `chip chip--${view.status}`;
  }
}
