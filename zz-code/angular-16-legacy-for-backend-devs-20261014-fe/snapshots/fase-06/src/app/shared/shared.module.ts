import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';
import { ReactiveFormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatListModule } from '@angular/material/list';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatSidenavModule } from '@angular/material/sidenav';
import { MatToolbarModule } from '@angular/material/toolbar';

import { NotFoundComponent } from './not-found/not-found.component';

/**
 * 💸 DEUDA DE LA FASE 1, PAGADA A MEDIAS Y RECLASIFICADA
 *
 * Salen los tres que nadie usa (tabla, diálogo y snackbar). Vuelven en la Fase 6,
 * importados por el componente standalone que los use, así que viajarán en su
 * chunk y no en el inicial.
 *
 * Lo que NO se paga: los nueve que quedan siguen viajando enteros a los módulos
 * heredados que importan este archivo, y ninguno usa más de cinco. Saldarlo
 * exige tocar esos módulos, y eso es una migración — precisamente lo que este
 * curso decidió no hacer. La deuda queda declarada, medida y viva.
 */
const MATERIAL_MODULES = [
  MatButtonModule,
  MatCardModule,
  MatFormFieldModule,
  MatIconModule,
  MatInputModule,
  MatListModule,
  MatProgressSpinnerModule,
  MatSidenavModule,
  MatToolbarModule,
];

@NgModule({
  declarations: [NotFoundComponent],
  imports: [CommonModule, ReactiveFormsModule, ...MATERIAL_MODULES],
  // Sin `exports`, todo lo de arriba sería privado y este módulo no le
  // serviría a nadie. Un SharedModule sin exports es el error más silencioso
  // de la fase: compila, se importa, y no aporta nada.
  exports: [CommonModule, ReactiveFormsModule, ...MATERIAL_MODULES, NotFoundComponent],
})
export class SharedModule {}
