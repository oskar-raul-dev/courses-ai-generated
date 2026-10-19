// STUB DE PRUEBA, no es del curso: las firmas de F10 §5.4, sin cuerpo. Sirve para
// que tsc compile los servicios que el fix del 21 toca sin armar la app entera.
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';

import { Certificate } from '../models/certificate.model';
import { Instant } from '../time/business-day';

@Injectable({ providedIn: 'root' })
export class CertificateApiService {
  getAll(): Observable<readonly Certificate[]> { throw new Error('stub'); }
  getByInspection(inspectionId: number): Observable<readonly Certificate[]> { throw new Error(`stub ${inspectionId}`); }
  issue(certificate: Certificate): Observable<Certificate> { throw new Error(`stub ${certificate.id}`); }
  revoke(id: string, revokedAt: Instant): Observable<Certificate> { throw new Error(`stub ${id} ${revokedAt}`); }
}
