// STUB DE PRUEBA, no es del curso: las firmas de F06.
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';

import { Client } from '../models/client.model';

@Injectable({ providedIn: 'root' })
export class ClientApiService {
  getById(id: number): Observable<Client> { throw new Error(`stub ${id}`); }
}
