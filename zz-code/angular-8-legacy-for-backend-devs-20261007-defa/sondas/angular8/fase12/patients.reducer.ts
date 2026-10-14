// src/app/patients/store/patients.reducer.ts
import * as PatientsActions from './patients.actions';

export interface PatientsState {
  items: any[];
  loading: boolean;
  error: any;
  selectedId: number;
  // Nuevo en Fase 5: la escritura tiene su propia bandera. Si compartiera
  // "loading" con la lectura, guardar pondría la tabla entera en spinner.
  saving: boolean;
  saveError: any;
  // El texto del filtro vive en el store, no en el componente. Así sobrevive
  // a navegar afuera y volver, y aparece en el log cuando reconstruyas un
  // incidente: vas a saber que estaba filtrando el usuario cuando fallo.
  filter: string;
}

export const initialState: PatientsState = {
  items: [],
  loading: false,
  error: null,
  selectedId: null,
  saving: false,
  saveError: null,
  filter: ''
};

export function patientsReducer(state = initialState, action: any): PatientsState {
  switch (action.type) {

    case PatientsActions.loadPatients.type:
      return { ...state, loading: true, error: null };

    case PatientsActions.loadPatientsSuccess.type:
      return { ...state, loading: false, items: action.patients };

    case PatientsActions.loadPatientsFailure.type:
      return { ...state, loading: false, error: action.error };

    case PatientsActions.selectPatient.type:
      return { ...state, selectedId: action.patientId };

    // Los tres verbos de escritura comparten el mismo estado de "guardando".
    // Caer varios "case" juntos sin "break" es intencional y es la forma
    // idiomática en un switch; si te parece un error, mira que no hay
    // "return" hasta el último.
    case PatientsActions.createPatient.type:
    case PatientsActions.updatePatient.type:
    case PatientsActions.deletePatient.type:
      return { ...state, saving: true, saveError: null };

    // Éxito de creación: NO se inserta el paciente en "items". El effect va a
    // despachar loadPatients() y la lista llegara entera desde el servidor.
    // Ver la deuda de 5.9.
    case PatientsActions.createPatientSuccess.type:
    case PatientsActions.updatePatientSuccess.type:
    case PatientsActions.deletePatientSuccess.type:
      return { ...state, saving: false };

    case PatientsActions.createPatientFailure.type:
    case PatientsActions.updatePatientFailure.type:
    case PatientsActions.deletePatientFailure.type:
      return { ...state, saving: false, saveError: action.error };

    case PatientsActions.setPatientsFilter.type:
      return { ...state, filter: action.filter };

    default:
      return state;
  }
}
