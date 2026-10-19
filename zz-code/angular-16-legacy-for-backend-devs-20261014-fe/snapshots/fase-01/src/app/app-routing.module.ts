import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

import { NotFoundComponent } from './shared/not-found/not-found.component';

const routes: Routes = [
  // pathMatch: 'full' es obligatorio en una redirección desde la ruta vacía.
  // Sin él, '' hace prefijo con TODO y ninguna otra ruta llega a evaluarse.
  { path: '', pathMatch: 'full', redirectTo: 'dashboard' },

  {
    path: 'dashboard',
    // La función import() es lo que le dice al compilador "esto va en otro
    // archivo .js y se descarga cuando alguien navegue aquí".
    loadChildren: () =>
      import('./features/dashboard/dashboard.module').then((m) => m.DashboardModule),
  },
  {
    path: 'clients',
    loadChildren: () =>
      import('./features/clients/clients.module').then((m) => m.ClientsModule),
  },
  {
    path: 'assets',
    loadChildren: () =>
      import('./features/assets/assets.module').then((m) => m.AssetsModule),
  },
  {
    path: 'templates',
    loadChildren: () =>
      import('./features/templates/templates.module').then((m) => m.TemplatesModule),
  },
  {
    path: 'inspections',
    loadChildren: () =>
      import('./features/inspections/inspections.module').then((m) => m.InspectionsModule),
  },
  {
    path: 'certificates',
    loadChildren: () =>
      import('./features/certificates/certificates.module').then((m) => m.CertificatesModule),
  },

  // Siempre la última. El router evalúa en orden y ** hace juego con todo.
  { path: '**', component: NotFoundComponent },
];

@NgModule({
  // forRoot() en el módulo raíz, y sólo ahí: es el que crea el servicio Router.
  // Llamarlo dos veces en la misma aplicación produce dos routers peleándose.
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule],
})
export class AppRoutingModule {}
