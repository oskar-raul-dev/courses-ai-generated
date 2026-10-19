// CABECERA DE PRUEBA, no es del curso: los import que el bloque-fragmento de F10 §5.8
// ("LA VERSIÓN QUE PAGA") no trae. correr-t3.sh la antepone al bloque copiado tal cual.
import { Injectable, inject } from '@angular/core';
import { Observable, combineLatest, concatMap, from, map, of } from 'rxjs';

import { AssetApiService } from '../../core/api/asset-api.service';
import { CertificateApiService } from '../../core/api/certificate-api.service';
import { ClientApiService } from '../../core/api/client-api.service';
import { InspectionApiService } from '../../core/api/inspection-api.service';
import { TemplateApiService } from '../../core/api/template-api.service';
import { buildCertificateView } from '../../core/domain/certificate-status';
import { BusinessRuleError } from '../../core/domain/inspection-rules';
import { CertificateDocumentSource, buildCertificateDocument } from '../../core/pdf/certificate-document';
import { InspectionStateService } from '../../core/state/inspection-state.service';
import { nowInstant } from '../../core/time/business-day';

