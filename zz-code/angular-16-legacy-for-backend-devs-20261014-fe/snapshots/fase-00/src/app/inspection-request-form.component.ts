import { HttpClient } from '@angular/common/http';
import { NgIf } from '@angular/common';
import {
  ChangeDetectionStrategy,
  ChangeDetectorRef,
  Component,
  inject,
} from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';

import {
  CreatedInspectionRequest,
  InspectionRequest,
} from './inspection-request.model';

/**
 * 💸 DEUDA TÉCNICA INTENCIONAL
 * La URL del backend está horneada en el código fuente. Lo correcto es leer la
 * configuración en tiempo de ARRANQUE, no de compilación, para que la misma
 * imagen sirva en UAT y en PROD sin recompilar.
 * SE PAGA EN LA FASE 13, que es la tesis del curso. Hasta entonces convives
 * con ella a propósito: cuando llegue el momento de pagarla vas a tener trece
 * fases de código apuntando a esta constante, que es exactamente el tamaño
 * real del problema en un sistema de verdad.
 */
const API_BASE_URL = 'http://localhost:3000';

/** Estado de la única operación de esta pantalla. */
type SubmissionStatus = 'idle' | 'sending' | 'sent' | 'failed';

@Component({
  selector: 'cc-inspection-request-form',
  standalone: true,
  // Sin ReactiveFormsModule acá, [formGroup] no existe para esta plantilla.
  // Un componente standalone importa lo que usa, y nada más.
  imports: [ReactiveFormsModule, NgIf],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './inspection-request-form.component.html',
})
export class InspectionRequestFormComponent {
  // inject() en vez de constructor: el estilo del código nuevo. La comparación
  // completa con la inyección por constructor está en el apéndice A04.
  private readonly formBuilder = inject(FormBuilder);
  private readonly http = inject(HttpClient);
  private readonly changeDetectorRef = inject(ChangeDetectorRef);

  protected status: SubmissionStatus = 'idle';
  protected createdId: number | null = null;

  /**
   * El tipo del FormGroup se infiere del literal. Los dos primeros controles
   * son nonNullable porque un activo sin identificar o una solicitud sin fecha
   * no significan nada; el tercero sí admite null, porque "sin nota" es un
   * caso legítimo del negocio.
   */
  protected readonly form = this.formBuilder.group({
    assetId: this.formBuilder.control('', {
      nonNullable: true,
      validators: [Validators.required],
    }),
    requestedFor: this.formBuilder.control('', {
      nonNullable: true,
      validators: [Validators.required],
    }),
    note: this.formBuilder.control<string | null>(null),
  });

  protected submit(): void {
    if (this.form.invalid) {
      // Sin esto, los mensajes de error no aparecen: el usuario que le da a
      // "Enviar" sin tocar nada no ha "tocado" ningún campo todavía.
      this.form.markAllAsTouched();
      return;
    }

    // getRawValue() devuelve el objeto tipado y completo. Con controles
    // deshabilitados, value los omitiría y getRawValue no: por eso es el que
    // usamos siempre que armamos un payload.
    // <input type="date"> entrega YYYY-MM-DD, sin hora ni zona. La regla del
    // curso es ISO 8601 con offset, así que el día se fija a medianoche de -05:00.
    const raw = this.form.getRawValue();
    const payload: InspectionRequest = {
      ...raw,
      requestedFor: `${raw.requestedFor}T00:00:00-05:00`,
    };

    this.status = 'sending';

    this.http
      .post<CreatedInspectionRequest>(`${API_BASE_URL}/inspection-requests`, payload)
      .subscribe({
        next: (created) => {
          this.createdId = created.id;
          this.status = 'sent';
          this.form.reset();
          // OnPush no se entera de que estas propiedades cambiaron: el cambio
          // vino de un callback asíncrono, no de un evento de la plantilla.
          // Desde la Fase 4 esto se resuelve con el pipe async; hoy, a mano.
          this.changeDetectorRef.markForCheck();
        },
        error: (error: unknown) => {
          // unknown, no any: acá puede llegar un HttpErrorResponse, un error de
          // red o cualquier cosa. Se estrecha antes de asumir su forma.
          this.status = 'failed';
          this.changeDetectorRef.markForCheck();
          console.error('Falló la solicitud de inspección', error);
        },
      });
  }
}
