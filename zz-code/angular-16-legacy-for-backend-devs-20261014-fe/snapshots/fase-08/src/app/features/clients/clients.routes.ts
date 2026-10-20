import { Routes } from '@angular/router';

import { CLIENT_LIST_PAGE_SIZE } from './client-list-page-size.token';

export const CLIENTS_ROUTES: Routes = [
  {
    path: '',
    providers: [{ provide: CLIENT_LIST_PAGE_SIZE, useValue: 5 }],
    loadComponent: () =>
      import('./client-list/client-list.component').then((m) => m.ClientListComponent),
  },
  // 'new' va ANTES que cualquier ruta con parámetro de un solo segmento. Hoy no
  // hay ninguna, así que da igual; el día que exista `:id` para el detalle,
  // ponerla después haría que /clients/new intentara cargar el cliente "new".
  {
    path: 'new',
    loadComponent: () =>
      import('./client-form/client-form.component').then((m) => m.ClientFormComponent),
  },
  {
    path: ':id/edit',
    loadComponent: () =>
      import('./client-form/client-form.component').then((m) => m.ClientFormComponent),
  },
];
