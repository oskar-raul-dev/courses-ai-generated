// STUB DE PRUEBA, no es del curso: las firmas de F06 §5.3 que usa el formulario.
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';

import { Client } from '../models/client.model';

@Injectable({ providedIn: 'root' })
export class ClientStateService {
  create(draft: Omit<Client, 'id'>): Observable<Client> { throw new Error(`stub ${draft.taxId}`); }
  update(client: Client): Observable<Client> { throw new Error(`stub ${client.id}`); }
}
