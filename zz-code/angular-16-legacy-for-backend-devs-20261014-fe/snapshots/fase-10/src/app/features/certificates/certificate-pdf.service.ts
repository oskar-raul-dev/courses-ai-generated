import { Injectable, inject } from '@angular/core';
import { Observable, combineLatest, concatMap, from, map, of } from 'rxjs';

import { AssetApiService } from '../../core/api/asset-api.service';
import { CertificateApiService } from '../../core/api/certificate-api.service';
import { ClientApiService } from '../../core/api/client-api.service';
import { InspectionApiService } from '../../core/api/inspection-api.service';
import { TemplateApiService } from '../../core/api/template-api.service';
import { AutoTableFn, CertificateDocumentSource, buildCertificateDocument } from '../../core/pdf/certificate-document';
import { buildCertificateView } from '../../core/domain/certificate-status';
import { BusinessRuleError } from '../../core/domain/inspection-rules';
import { InspectionStateService } from '../../core/state/inspection-state.service';
import { nowInstant } from '../../core/time/business-day';

/**
 * 🪦 LA DEUDA DEL PDF, PAGADA.
 *
 * El documento se arma pidiendo todo otra vez en el momento de pulsar el botón,
 * nunca desde la vista pintada. Cuesta unas seis peticiones y es el precio de
 * que el documento diga la verdad en el instante en que se genera.
 *
 * 🧭 Regla del proyecto: un documento se arma desde la fuente, nunca desde lo que
 * hay pintado. Es el error que todo el mundo comete dos veces.
 */
@Injectable({ providedIn: 'root' })
export class CertificatePdfService {
  private readonly certificateApi = inject(CertificateApiService);
  private readonly inspectionApi = inject(InspectionApiService);
  private readonly inspectionState = inject(InspectionStateService);
  private readonly templateApi = inject(TemplateApiService);
  private readonly assetApi = inject(AssetApiService);
  private readonly clientApi = inject(ClientApiService);

  download(certificateId: string): Observable<void> {
    return this.certificateApi.getAll().pipe(
      map((certificates) => {
        const certificate = certificates.find((row) => row.id === certificateId);

        if (certificate === undefined) {
          throw new BusinessRuleError(`No existe el certificado ${certificateId}.`);
        }

        return certificate;
      }),
      concatMap((certificate) =>
        this.inspectionApi.getById(certificate.inspectionId).pipe(
          concatMap((inspection) =>
            combineLatest({
              certificate: of(certificate),
              inspection: of(inspection),
              // La versión CONGELADA: la que la inspección guardó, nunca la vigente.
              template: this.templateApi.getByVersion(
                inspection.templateId,
                inspection.templateVersion,
              ),
              asset: this.assetApi.getById(inspection.assetId),
              findings: this.inspectionState.findingsOf(inspection),
            }),
          ),
        ),
      ),
      concatMap((parts) =>
        this.clientApi.getById(parts.asset.clientId).pipe(
          map((client) => ({
            ...parts,
            client,
            view: buildCertificateView(parts.certificate, nowInstant()),
          })),
        ),
      ),
      concatMap((source) => from(this.render(source))),
    );
  }

  /** La carga diferida vive aquí y sólo aquí: jsPDF no viaja en el arranque. */
  private async render(source: CertificateDocumentSource): Promise<void> {
    const { jsPDF } = await import('jspdf');
    const autoTable = (await import('jspdf-autotable')).default as unknown as AutoTableFn;

    const document = buildCertificateDocument(new jsPDF(), source, autoTable);

    document.save(`${source.certificate.id}.pdf`);
  }
}
