import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';
import { ReactiveFormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatDialogModule } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatListModule } from '@angular/material/list';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatSidenavModule } from '@angular/material/sidenav';
import { MatSnackBarModule } from '@angular/material/snack-bar';
import { MatTableModule } from '@angular/material/table';
import { MatToolbarModule } from '@angular/material/toolbar';

import { NotFoundComponent } from './not-found/not-found.component';

/**
 * 💸 DEUDA TÉCNICA INTENCIONAL
 * Doce módulos de Material reexportados "por comodidad", para que ningún
 * módulo de feature tenga que pensar qué importa. En 2021 ahorró discusiones.
 * Hoy significa que la pantalla de dashboard, que muestra tres tarjetas,
 * arrastra la tabla, el diálogo y el snackbar al mismo bundle.
 * Lo correcto es que cada módulo importe lo que usa y ni una cosa más.
 * SE PAGA EN PARTE EN LA FASE 5, con el tamaño del bundle medido antes y
 * después: salen los módulos que no usa nadie y el código nuevo deja de pasar
 * por aquí. El resto NO SE PAGA EN ESTE CURSO, porque saldarlo entero exige
 * convertir los módulos heredados que importan este archivo —una migración—, y
 * aquí se enseña a mantener. La Fase 5 lo demuestra con el build delante.
 * Hasta entonces no se toca: quiero que lo sufras con números.
 */
const MATERIAL_MODULES = [
  MatButtonModule,
  MatCardModule,
  MatDialogModule,
  MatFormFieldModule,
  MatIconModule,
  MatInputModule,
  MatListModule,
  MatProgressSpinnerModule,
  MatSidenavModule,
  MatSnackBarModule,
  MatTableModule,
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
