import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { Observable } from 'rxjs';

import { AuthService } from '../../core/auth.service';
import { AppConfigService } from '../../core/config/app-config.service';
import { AccessTokenPayload } from '../../core/models/auth.model';

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

  // Desde la Fase 13 se lee de la configuración de arranque, no del build.
  readonly environmentName: string;

  readonly currentUser$: Observable<AccessTokenPayload | null>;

  // authService pasa de `public` a `private` en la Fase 4: la plantilla ya no
  // lo necesita, y eso es la mitad del pago. Un servicio público en un
  // componente casi siempre significa que la plantilla está llamando a métodos.
  constructor(
    private readonly authService: AuthService,
    private readonly router: Router,
    appConfig: AppConfigService,
  ) {
    this.currentUser$ = authService.currentUser$;
    this.environmentName = appConfig.current.environmentName;
  }

  logout(): void {
    this.authService.logout();
    void this.router.navigate(['/login']);
  }
}
