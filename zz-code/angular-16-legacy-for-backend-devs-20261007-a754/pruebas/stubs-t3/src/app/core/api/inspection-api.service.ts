// STUB DE PRUEBA, no es del curso: las firmas de F08.
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';

import { Inspection } from '../models/inspection.model';

@Injectable({ providedIn: 'root' })
export class InspectionApiService {
  getAll(): Observable<readonly Inspection[]> { throw new Error('stub'); }
  getById(id: number): Observable<Inspection> { throw new Error(`stub ${id}`); }
}
