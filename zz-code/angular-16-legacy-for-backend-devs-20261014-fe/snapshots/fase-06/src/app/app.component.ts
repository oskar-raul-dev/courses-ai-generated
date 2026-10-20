import { Component } from '@angular/core';

// Componente heredado: declarado en un NgModule, sin `standalone`, sin OnPush.
// La detección de cambios por defecto es la de 2021, y en la Fase 11 vamos a
// hablar de lo que cuesta.
@Component({
  selector: 'cc-root',
  template: '<cc-shell></cc-shell>',
})
export class AppComponent {}
