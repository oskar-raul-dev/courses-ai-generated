import { Routes } from '@angular/router';

import { CLIENT_LIST_PAGE_SIZE } from './client-list-page-size.token';

/**
 * El equivalente de ClientsRoutingModule, sin la ceremonia. No hay NgModule, no
 * hay forChild(): un array exportado, que es lo que RouterModule.forChild()
 * recibía y envolvía.
 */
export const CLIENTS_ROUTES: Routes = [
  {
    path: '',
    /**
     * Providers de ruta: viven mientras /clients esté activa y se van con
     * ella. Es el sitio correcto para la configuración de una pantalla.
     * Compáralo con TemplateStateService, que es `providedIn: 'root'` porque
     * su trabajo es justamente sobrevivir a la navegación.
     */
    providers: [{ provide: CLIENT_LIST_PAGE_SIZE, useValue: 5 }],
    // loadComponent en vez de loadChildren: el destino es un componente, no un
    // módulo. Sigue siendo un import() dinámico, así que sigue siendo un chunk
    // aparte y sigue siendo carga diferida.
    loadComponent: () =>
      import('./client-list/client-list.component').then((m) => m.ClientListComponent),
  },
];
