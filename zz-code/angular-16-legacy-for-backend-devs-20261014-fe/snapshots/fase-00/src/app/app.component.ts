import { ChangeDetectionStrategy, Component } from '@angular/core';

import { InspectionRequestFormComponent } from './inspection-request-form.component';

@Component({
  selector: 'cc-root',
  // Standalone: el componente declara lo que usa, en vez de esperar que un
  // módulo se lo provea. Es el cambio conceptual más grande de Angular 15-16.
  standalone: true,
  imports: [InspectionRequestFormComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <header>
      <h1>CertCore</h1>
      <p>Inspecciones y certificaciones</p>
    </header>

    <main>
      <cc-inspection-request-form />
    </main>
  `,
})
export class AppComponent {}
