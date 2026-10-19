// STUB DE PRUEBA, no es del curso: la firma de F09 §5.6.
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';

import { InspectionFinding } from '../domain/inspection-findings';
import { Inspection } from '../models/inspection.model';

@Injectable({ providedIn: 'root' })
export class InspectionStateService {
  findingsOf(inspection: Inspection): Observable<readonly InspectionFinding[]> { throw new Error(`stub ${inspection.id}`); }
}
