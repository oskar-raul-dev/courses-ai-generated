// STUB DE PRUEBA, no es del curso: las firmas de F06 §5.10.
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';

import { Asset } from '../models/asset.model';

@Injectable({ providedIn: 'root' })
export class AssetApiService {
  getAll(): Observable<readonly Asset[]> { throw new Error('stub'); }
  getById(id: string): Observable<Asset> { throw new Error(`stub ${id}`); }
}
