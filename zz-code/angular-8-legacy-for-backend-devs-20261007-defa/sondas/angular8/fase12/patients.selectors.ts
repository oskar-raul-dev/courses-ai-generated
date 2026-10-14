// src/app/patients/store/patients.selectors.ts
import { createFeatureSelector, createSelector } from '@ngrx/store';
import { PatientsState } from './patients.reducer';

export const selectPatientsState = createFeatureSelector<PatientsState>('patients');

// Ojo: devuelve TODO, incluidos los dados de baja. Casi ningun consumidor
// debería usar este selector directamente, pero existe desde la Fase 1 y
// hay código que lo usa. Ver sección 6.
export const selectAllPatients = createSelector(
  selectPatientsState,
  function (state) { return state.items; }
);

export const selectPatientsLoading = createSelector(
  selectPatientsState,
  function (state) { return state.loading; }
);

export const selectPatientsSaving = createSelector(
  selectPatientsState,
  function (state) { return state.saving; }
);

export const selectPatientsError = createSelector(
  selectPatientsState,
  function (state) { return state.error; }
);

export const selectPatientsFilter = createSelector(
  selectPatientsState,
  function (state) { return state.filter; }
);

// El único selector que debería consumir la pantalla: activos solamente.
export const selectActivePatients = createSelector(
  selectAllPatients,
  function (patients) {
    return patients.filter(function (p) { return p.active !== false; });
  }
);

// Filtrado por texto, memoizado sobre el anterior. Si el filtro no cambio y
// la lista no cambió, esta función no se ejecuta y devuelve la referencia
// anterior. Sin memoización, cada detección de cambios recorrería 25 items
// y devolvería un array nuevo, y con 25 no se nota — con 4000 si, y eso es
// lo que mide la Fase 10.
export const selectFilteredPatients = createSelector(
  selectActivePatients,
  selectPatientsFilter,
  function (patients, filter) {
    if (!filter) { return patients; }
    var needle = filter.toLowerCase();
    return patients.filter(function (p) {
      // "any" otra vez: si fullName llega null desde el mock, esto revienta.
      // El ejercicio 19 lo provoca a propósito.
      return p.fullName.toLowerCase().indexOf(needle) >= 0 ||
             p.documentId.toLowerCase().indexOf(needle) >= 0;
    });
  }
);

export const selectSelectedPatient = createSelector(
  selectAllPatients,
  selectPatientsState,
  function (patients, state) {
    return patients.find(function (p) { return p.id === state.selectedId; }) || null;
  }
);
