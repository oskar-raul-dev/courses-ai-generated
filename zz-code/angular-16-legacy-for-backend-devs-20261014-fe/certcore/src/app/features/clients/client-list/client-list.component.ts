import { NgIf } from '@angular/common';
import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatTableModule } from '@angular/material/table';

import { Client } from '../../../core/models/client.model';
import { EmptyStateComponent } from '../../../shared/empty-state/empty-state.component';
import { CLIENT_LIST_PAGE_SIZE } from '../client-list-page-size.token';

@Component({
  selector: 'cc-client-list',
  standalone: true,
  /**
   * Cinco entradas, y ni una más. Compara esta lista con lo que este mismo
   * componente recibía ayer a través de SharedModule: doce módulos de Material,
   * CommonModule entero y ReactiveFormsModule, de los cuales usaba tres.
   *
   * NgIf va suelto y no CommonModule: importar la directiva concreta es más
   * barato y, sobre todo, es documentación. Quien lea este decorador sabe que
   * la plantilla tiene un condicional y no tiene bucles ni pipes de formato.
   */
  imports: [NgIf, MatButtonModule, MatIconModule, MatTableModule, EmptyStateComponent],
  templateUrl: './client-list.component.html',
  // OnPush por defecto en todo lo nuevo. Con el estado de la Fase 4 —que
  // reemplaza el objeto en vez de retocarlo— es gratis y correcto.
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ClientListComponent {
  /**
   * Cuántas filas por página. NO viene de `providedIn: 'root'`: lo provee la
   * ruta de clientes, en 5.3. Si este componente se monta fuera de esa ruta,
   * revienta — y ese error es la pieza forense de hoy.
   */
  readonly pageSize = inject(CLIENT_LIST_PAGE_SIZE);

  /** Las columnas de la tabla, en el orden en que se leen. */
  readonly displayedColumns: readonly string[] = ['legalName', 'taxId'];

  /**
   * Vacío a propósito y sin pedir nada a nadie. El listado real llega en la
   * Fase 6 con ClientStateService y su `clients$ | async`; hoy lo que se
   * convierte es la estructura del módulo, no el contenido de la pantalla.
   */
  readonly clients: readonly Client[] = [];
}
