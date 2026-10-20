import { Component } from '@angular/core';
import { Router } from '@angular/router';

@Component({
  selector: 'cc-not-found',
  templateUrl: './not-found.component.html',
})
export class NotFoundComponent {
  // Inyección por constructor: el estilo heredado. La comparación completa con
  // inject() está en el apéndice A04.
  constructor(private readonly router: Router) {}

  goHome(): void {
    // navigate() devuelve una promesa con el resultado de la navegación.
    // Aquí no nos interesa, y `void` lo dice explícitamente en vez de dejar
    // una promesa suelta que nadie mira.
    void this.router.navigate(['/dashboard']);
  }
}
