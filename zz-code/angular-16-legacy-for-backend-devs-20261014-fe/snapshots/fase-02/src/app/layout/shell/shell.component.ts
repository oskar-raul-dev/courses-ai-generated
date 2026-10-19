import { Component } from '@angular/core';
import { Router } from '@angular/router';

import { AuthService } from '../../core/auth.service';
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

  // Se lee del archivo de entorno, que el build sustituye. Ver 5.11 de la Fase 1.
  readonly environmentName = environment.environmentName;

  /**
   * 💸 DEUDA TÉCNICA INTENCIONAL
   * `authService` es público para que la plantilla pueda llamar a
   * isAuthenticated() y getCurrentUser() directamente. Como este componente
   * usa detección de cambios por defecto, esos métodos se ejecutan en CADA
   * ciclo — y cada llamada decodifica el JWT entero: split, base64, JSON.parse.
   * Lo correcto es que el estado de sesión sea un observable y la plantilla lo
   * pinte con el pipe async, calculándose una sola vez por cambio real.
   * SE PAGA EN LA FASE 4, cuando AuthService exponga `currentUser$`.
   * El ejercicio 12 te hace contar las llamadas antes de creerte el número.
   */
  constructor(
    public readonly authService: AuthService,
    private readonly router: Router,
  ) {}

  logout(): void {
    this.authService.logout();
    void this.router.navigate(['/login']);
  }
}
