
// STUB DE PRUEBA, no es del curso: la clase con la firma de F07 que usa el PDF.
// correr-t3.sh pega esto DEBAJO de la cabecera real del bloque de F07.
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';

import { ChecklistTemplate } from '../models/checklist-template.model';

@Injectable({ providedIn: 'root' })
export class TemplateApiService {
  getByVersion(templateId: string, version: number): Observable<ChecklistTemplate> { throw new Error(`stub ${templateId} ${version}`); }
}
