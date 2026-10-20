import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';

/** Lo que hay que darle al abrirlo. Tipado: nada de pasarle un objeto suelto. */
export interface ConfirmDialogData {
  readonly title: string;
  readonly message: string;
  readonly confirmLabel: string;
}

/**
 * Vive en shared/ y no está declarado en SharedModule, igual que
 * EmptyStateComponent: lo importa quien lo usa. Fase 5 §5.5.
 */
@Component({
  selector: 'cc-confirm-dialog',
  standalone: true,
  imports: [MatButtonModule, MatDialogModule],
  template: `
    <h2 mat-dialog-title>{{ data.title }}</h2>
    <mat-dialog-content>{{ data.message }}</mat-dialog-content>
    <mat-dialog-actions align="end">
      <button mat-button (click)="dialogRef.close(false)">Cancelar</button>
      <button mat-raised-button color="warn" (click)="dialogRef.close(true)">
        {{ data.confirmLabel }}
      </button>
    </mat-dialog-actions>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ConfirmDialogComponent {
  // inject() con genérico explícito: MAT_DIALOG_DATA es un token sin tipo, y
  // sin el genérico esto sería `any` entrando por la puerta grande.
  readonly data = inject<ConfirmDialogData>(MAT_DIALOG_DATA);

  readonly dialogRef = inject<MatDialogRef<ConfirmDialogComponent, boolean>>(MatDialogRef);
}
