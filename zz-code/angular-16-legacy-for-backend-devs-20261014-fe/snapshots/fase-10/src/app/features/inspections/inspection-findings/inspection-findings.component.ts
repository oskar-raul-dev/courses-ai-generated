import { AsyncPipe, NgFor, NgIf } from '@angular/common';
import { ChangeDetectionStrategy, Component, DestroyRef, inject } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { ActivatedRoute } from '@angular/router';
import { Observable, combineLatest, filter, map, startWith, Subject, switchMap } from 'rxjs';

import { ApiError } from '../../../core/api/api-error';
import { FindingApiService } from '../../../core/api/finding-api.service';
import { InspectionApiService } from '../../../core/api/inspection-api.service';
import { severityLabel } from '../../../core/domain/finding-severity';
import {
  FindingSummary,
  InspectionFinding,
  summarizeFindings,
} from '../../../core/domain/inspection-findings';
import { BusinessRuleError, isEditable } from '../../../core/domain/inspection-rules';
import { Inspection } from '../../../core/models/inspection.model';
import { CertificateStateService } from '../../../core/state/certificate-state.service';
import { InspectionStateService } from '../../../core/state/inspection-state.service';

interface FindingsView {
  readonly inspection: Inspection;
  readonly findings: readonly InspectionFinding[];
  readonly summary: FindingSummary;
  readonly editable: boolean;
}

@Component({
  selector: 'cc-inspection-findings',
  standalone: true,
  imports: [AsyncPipe, NgFor, NgIf, MatButtonModule, MatIconModule, MatSnackBarModule],
  templateUrl: './inspection-findings.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class InspectionFindingsComponent {
  private readonly route = inject(ActivatedRoute);
  private readonly inspectionApi = inject(InspectionApiService);
  private readonly findingApi = inject(FindingApiService);
  private readonly inspectionState = inject(InspectionStateService);
  private readonly certificateState = inject(CertificateStateService);
  private readonly snackBar = inject(MatSnackBar);
  private readonly destroyRef = inject(DestroyRef);

  readonly severityLabel = severityLabel;

  /** Un disparo para recargar después de resolver un hallazgo. */
  private readonly reload = new Subject<void>();

  /**
   * Misma forma que la vista de la Fase 8: se DERIVA de la ruta, así que
   * cambiar de inspección no deja nada de la anterior.
   */
  readonly view$: Observable<FindingsView> = combineLatest([
    this.route.paramMap.pipe(
      map((params) => Number(params.get('id'))),
      filter((id) => Number.isInteger(id)),
    ),
    this.reload.pipe(startWith(undefined)),
  ]).pipe(
    switchMap(([id]) => this.inspectionApi.getById(id)),
    switchMap((inspection) =>
      this.inspectionState.findingsOf(inspection).pipe(
        map((findings) => ({
          inspection,
          findings,
          summary: summarizeFindings(findings),
          editable: isEditable(inspection),
        })),
      ),
    ),
  );

  resolve(finding: InspectionFinding): void {
    if (finding.stored === null) {
      // Un hallazgo derivado que nunca se guardó no tiene fila que marcar.
      // Crearla aquí sería empezar a persistir derivados por la puerta de atrás.
      this.snackBar.open(
        'Este hallazgo se derivó de las respuestas y no tiene registro propio todavía.',
        'Cerrar',
        { duration: 6000 },
      );
      return;
    }

    this.findingApi
      .resolve(finding.stored.id, new Date().toISOString())
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe({
        next: () => this.reload.next(),
        error: (error: unknown) => this.report(error, 'No se pudo marcar el hallazgo.'),
      });
  }

  approve(view: FindingsView): void {
    this.inspectionState
      .approve(view.inspection)
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe({
        next: () => {
          this.snackBar.open('Inspección aprobada.', 'Cerrar', { duration: 4000 });
          this.reload.next();
        },
        error: (error: unknown) => this.report(error, 'No se pudo aprobar la inspección.'),
      });
  }

  reject(view: FindingsView): void {
    this.inspectionState
      .reject(view.inspection)
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe({
        next: () => {
          this.snackBar.open('Inspección rechazada.', 'Cerrar', { duration: 4000 });
          this.reload.next();
        },
        error: (error: unknown) => this.report(error, 'No se pudo rechazar la inspección.'),
      });
  }

  /** Emitir el certificado. La puerta está en CertificateStateService, no aquí. */
  issueCertificate(view: FindingsView): void {
    this.certificateState
      .issue(view.inspection)
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe({
        next: (certificate) => {
          this.snackBar.open(`Certificado ${certificate.id} emitido.`, 'Cerrar', { duration: 4000 });
        },
        error: (error: unknown) => this.report(error, 'No se pudo emitir el certificado.'),
      });
  }

  /**
   * Los dos errores no se cuentan igual, y ésta es la razón de que
   * `BusinessRuleError` exista. Una regla que dice que no se muestra el tiempo
   * suficiente para leerla; un error de red se muestra y se puede reintentar.
   */
  private report(error: unknown, fallback: string): void {
    if (error instanceof BusinessRuleError) {
      this.snackBar.open(error.message, 'Entendido', { duration: 10000 });
      return;
    }

    this.snackBar.open(error instanceof ApiError ? error.message : fallback, 'Cerrar', {
      duration: 6000,
    });
  }
}
