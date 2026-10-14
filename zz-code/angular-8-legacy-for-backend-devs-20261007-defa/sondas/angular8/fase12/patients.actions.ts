// src/app/patients/store/patients.actions.ts
import { createAction, props } from '@ngrx/store';

// --- Lectura (Fase 1, sin cambios) ---
export const loadPatients = createAction('[Patients] Load Patients');

export const loadPatientsSuccess = createAction(
  '[Patients] Load Patients Success',
  props<{ patients: any[] }>()
);

export const loadPatientsFailure = createAction(
  '[Patients] Load Patients Failure',
  props<{ error: any }>()
);

export const selectPatient = createAction(
  '[Patients] Select Patient',
  props<{ patientId: number }>()
);

// --- Escritura (Fase 5) ---

// El payload es "any" y no "Patient" porque no hay interfaz Patient. TS-0.
// El precio: nada impide despachar createPatient({ patient: 42 }).
export const createPatient = createAction(
  '[Patients] Create Patient',
  props<{ patient: any }>()
);

export const createPatientSuccess = createAction(
  '[Patients] Create Patient Success',
  props<{ patient: any }>()
);

export const createPatientFailure = createAction(
  '[Patients] Create Patient Failure',
  props<{ error: any }>()
);

export const updatePatient = createAction(
  '[Patients] Update Patient',
  props<{ patient: any }>()
);

export const updatePatientSuccess = createAction(
  '[Patients] Update Patient Success',
  props<{ patient: any }>()
);

export const updatePatientFailure = createAction(
  '[Patients] Update Patient Failure',
  props<{ error: any }>()
);

// upsert: el formulario es uno solo y no sabe si está creando o editando.
// Decide por la presencia de "id" y despacha la acción que corresponde.
// No llega al reducer nunca: es una acción que solo escuchan los effects.
export const upsertPatient = createAction(
  '[Patients] Upsert Patient',
  props<{ patient: any }>()
);

// Baja lógica. El nombre dice "delete" porque así lo llama el equipo y así
// aparece en el código real; lo que hace por dentro es un PATCH de "active".
// Esa distancia entre el nombre y el efecto es deuda de nombrado, y es la
// razón por la que alguien va a buscar un DELETE en el log de Express y no
// lo va a encontrar.
export const deletePatient = createAction(
  '[Patients] Delete Patient',
  props<{ patientId: number }>()
);

export const deletePatientSuccess = createAction(
  '[Patients] Delete Patient Success',
  props<{ patientId: number }>()
);

export const deletePatientFailure = createAction(
  '[Patients] Delete Patient Failure',
  props<{ error: any }>()
);

// zz-code: answer to Fase 05 exercise 1, needed for the reducer to compile
export const setPatientsFilter = createAction('[Patients] Set Patients Filter', props<{ filter: string }>());
