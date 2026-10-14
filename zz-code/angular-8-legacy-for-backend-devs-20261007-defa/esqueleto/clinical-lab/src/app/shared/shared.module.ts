// src/app/shared/shared.module.ts
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';

import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatTableModule } from '@angular/material/table';
import { MatPaginatorModule } from '@angular/material/paginator';
import { MatSortModule } from '@angular/material/sort';
import { MatDialogModule } from '@angular/material/dialog';
import { MatSnackBarModule } from '@angular/material/snack-bar';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatIconModule } from '@angular/material/icon';
// MatNativeDateModule no es un módulo de UI: es el adaptador de fechas.
// Sin el, el datepicker compila y explota al abrirse con un error que
// habla de DateAdapter y no de fechas. Ver sección 6.
import { MatDatepickerModule } from '@angular/material/datepicker';
import { MatNativeDateModule } from '@angular/material/core';

import { TranslateModule } from '@ngx-translate/core';

import { AppDatePipe } from './app-date.pipe';

var SHARED_MODULES = [
  CommonModule,
  FormsModule,
  ReactiveFormsModule,
  TranslateModule,
  MatButtonModule,
  MatCardModule,
  MatProgressSpinnerModule,
  MatTableModule,
  MatPaginatorModule,
  MatSortModule,
  MatDialogModule,
  MatSnackBarModule,
  MatFormFieldModule,
  MatInputModule,
  // MatSelectModule no lo usa ninguna pantalla de esta fase: entra acá porque
  // el desplegable de estado de la Fase 6 lo va a necesitar y el SharedModule
  // se importa una sola vez. Es la clase de import que en LabCore nadie sabe
  // ya quién metió.
  MatSelectModule,
  MatIconModule,
  MatDatepickerModule,
  MatNativeDateModule
];

@NgModule({
  declarations: [AppDatePipe],
  imports: SHARED_MODULES,
  exports: [...SHARED_MODULES, AppDatePipe]
})
export class SharedModule { }
