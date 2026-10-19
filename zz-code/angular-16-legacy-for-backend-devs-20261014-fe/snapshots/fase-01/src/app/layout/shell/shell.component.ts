import { Component } from '@angular/core';

import { environment } from '../../../environments/environment';

interface NavigationItem {
  readonly path: string;
  readonly label: string;
  readonly icon: string;
}

@Component({
  selector: 'cc-shell',
  templateUrl: './shell.component.html',
  styleUrls: ['./shell.component.scss'],
})
export class ShellComponent {
  // Los enlaces del menú, en el orden en que el negocio piensa el trabajo:
  // primero el panel, luego a quién se le inspecciona, luego con qué, y al
  // final lo que se emite.
  readonly navigationItems: readonly NavigationItem[] = [
    { path: '/dashboard', label: 'Panel', icon: 'dashboard' },
    { path: '/clients', label: 'Clientes', icon: 'business' },
    { path: '/assets', label: 'Activos', icon: 'elevator' },
    { path: '/templates', label: 'Plantillas', icon: 'checklist' },
    { path: '/inspections', label: 'Inspecciones', icon: 'fact_check' },
    { path: '/certificates', label: 'Certificados', icon: 'verified' },
  ];

  // Se lee del archivo de entorno, que el build sustituye. Ver 5.11.
  readonly environmentName = environment.environmentName;
}
