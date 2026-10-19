import { Component, OnDestroy, OnInit } from '@angular/core';
import { Subscription } from 'rxjs';

import { ApiError } from '../../../core/api/api-error';
import { TemplateApiService } from '../../../core/api/template-api.service';
import { ChecklistTemplate } from '../../../core/models/checklist-template.model';

@Component({
  selector: 'cc-template-list',
  templateUrl: './template-list.component.html',
})
export class TemplateListComponent implements OnInit, OnDestroy {
  templates: readonly ChecklistTemplate[] = [];
  loading = false;
  errorMessage: string | null = null;

  private subscription: Subscription | null = null;

  /**
   * 💸 DEUDA TÉCNICA INTENCIONAL
   * El componente habla con el ApiService directamente y guarda el resultado
   * en un campo suyo. Con una sola pantalla funciona; con cuatro pantallas
   * necesitando la misma lista, cada una pide lo suyo y las cuatro pueden
   * mostrar cosas distintas a la vez.
   * Lo correcto es un servicio de estado con un BehaviorSubject privado y un
   * Observable público, y la vista pintando con el pipe async.
   * SE PAGA EN LA FASE 4, que existe exactamente para esto.
   */
  constructor(private readonly templateApi: TemplateApiService) {}

  ngOnInit(): void {
    this.loading = true;
    this.errorMessage = null;

    this.subscription = this.templateApi.getAll().subscribe({
      next: (templates) => {
        this.templates = templates;
        this.loading = false;
      },
      error: (error: unknown) => {
        this.loading = false;
        // El mensaje ya viene traducido desde toApiError: el componente no
        // sabe nada de status HTTP, y así es como debe ser.
        this.errorMessage =
          error instanceof ApiError
            ? error.message
            : 'Ocurrió un error inesperado al cargar las plantillas.';
      },
    });
  }

  ngOnDestroy(): void {
    // Desuscripción manual: el estilo de 2021. Un observable de HttpClient
    // completa solo, así que esto parece de más — hasta que corres con
    // CHAOS=latency y navegas fuera antes de que responda. Ahí es cuando
    // importa. En el código nuevo esto se escribe con takeUntilDestroyed, y la
    // Fase 4 lo compara con las otras tres formas de cerrar la puerta.
    this.subscription?.unsubscribe();
  }
}
