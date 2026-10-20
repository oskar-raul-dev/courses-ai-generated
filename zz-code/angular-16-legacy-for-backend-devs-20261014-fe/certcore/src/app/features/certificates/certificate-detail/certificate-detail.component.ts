import { AsyncPipe, DatePipe, NgIf } from '@angular/common';
import { ChangeDetectionStrategy, Component, DestroyRef, OnInit, inject } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { MatButtonModule } from '@angular/material/button';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { Observable, Subject, combineLatest, filter, map, startWith, switchMap } from 'rxjs';

import { ApiError } from '../../../core/api/api-error';
import { CertificateView, certificateStatusLabel } from '../../../core/domain/certificate-status';
import { BusinessRuleError } from '../../../core/domain/inspection-rules';
import { CertificateStateService } from '../../../core/state/certificate-state.service';
import { CertificatePdfService } from '../certificate-pdf.service';

@Component({
  selector: 'cc-certificate-detail',
  standalone: true,
  imports: [AsyncPipe, DatePipe, NgIf, MatButtonModule, MatSnackBarModule, RouterLink],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './certificate-detail.component.html',
})
export class CertificateDetailComponent implements OnInit {
  private readonly route = inject(ActivatedRoute);
  private readonly certificateState = inject(CertificateStateService);
  private readonly certificatePdf = inject(CertificatePdfService);
  private readonly snackBar = inject(MatSnackBar);
  private readonly destroyRef = inject(DestroyRef);

  readonly statusLabel = certificateStatusLabel;

  private readonly reload$ = new Subject<void>();

  /**
   * viewOf() busca dentro de la lista del estado, y la lista sólo la carga quien
   * la pide. Sin esta línea, entrar directo a /certificates/CERT-… (un enlace en un
   * correo, una recarga) pinta «No existe un certificado» con el certificado ahí.
   */
  ngOnInit(): void {
    this.certificateState.load();
  }

  readonly view$: Observable<CertificateView | undefined> = combineLatest([
    this.route.paramMap.pipe(
      map((params) => String(params.get('id'))),
      filter((id) => id !== ''),
    ),
    this.reload$.pipe(startWith(undefined)),
  ]).pipe(
    switchMap(([id]) => this.certificateState.viewOf(id)),
  );

  /**
   * ⭐ El botón que produce el documento. NO recibe el `view` de la pantalla:
   * recibe el id, y el servicio vuelve a pedir todo lo que necesita.
   */
  download(certificateId: string): void {
    this.certificatePdf
      .download(certificateId)
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe({ error: (error: unknown) => this.report(error) });
  }

  revoke(view: CertificateView): void {
    this.certificateState
      .revoke(view.certificate)
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe({
        next: () => this.reload$.next(),
        error: (error: unknown) => this.report(error),
      });
  }

  /** "Falló" y "la respuesta es no" no se pintan igual. */
  private report(error: unknown): void {
    if (error instanceof BusinessRuleError) {
      this.snackBar.open(error.message, 'Entendido', { duration: 8000 });

      return;
    }

    this.snackBar.open(
      error instanceof ApiError ? error.message : 'No se pudo completar la operación. Reintenta.',
      'Reintentar',
      { duration: 5000 },
    );
  }
}
