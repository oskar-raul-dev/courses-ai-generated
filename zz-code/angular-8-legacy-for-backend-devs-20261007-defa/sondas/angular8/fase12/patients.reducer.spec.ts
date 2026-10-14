// src/app/patients/store/patients.reducer.spec.ts
import { patientsReducer, initialState, PatientsState } from './patients.reducer';
import * as PatientsActions from './patients.actions';

// Un reducer es una función pura: no hay TestBed, no hay que doblar nada.
// Se importa la función, se la llama, se compara la salida. Esto es lo más
// barato que vas a testear en todo el curso; aprovéchalo.
describe('patientsReducer', function () {

  it('deja el estado intacto ante una acción desconocida', function () {
    // El "default" del switch. Un reducer NUNCA debe romperse ante una acción
    // que no reconoce: devuelve el estado tal cual.
    var unknownAction = { type: '[Otro] Algo' } as any;
    var result = patientsReducer(initialState, unknownAction);
    expect(result).toBe(initialState); // misma referencia: no se tocó nada
  });

  it('loadPatients pone loading en true y limpia el error', function () {
    var previousState: PatientsState = { ...initialState, error: 'algo viejo' };
    var action = PatientsActions.loadPatients();
    var result = patientsReducer(previousState, action);
    expect(result.loading).toBe(true);
    expect(result.error).toBeNull();
  });

  it('loadPatientsSuccess apaga loading y guarda los items', function () {
    var previousState: PatientsState = { ...initialState, loading: true };
    // Datos anclados al dominio: pacientes, no foo/bar.
    var list = [{ id: 1, fullName: 'Ana Ruiz', documentId: 'HC-1001', active: true }];
    var action = PatientsActions.loadPatientsSuccess({ patients: list });
    var result = patientsReducer(previousState, action);
    expect(result.loading).toBe(false);
    expect(result.items).toBe(list);
  });

  // Los tres verbos de escritura comparten el mismo "case" caído en el switch
  // (create/update/delete -> saving: true). Un solo test que recorre los tres
  // asegura que la caída sigue en pie. Si alguien mete un "return" de más entre
  // ellos, este test lo caza.
  it('create, update y delete ponen saving en true', function () {
    var actions = [
      PatientsActions.createPatient({ patient: { fullName: 'X' } as any }),
      PatientsActions.updatePatient({ patient: { id: 1 } as any }),
      PatientsActions.deletePatient({ patientId: 1 })
    ];
    actions.forEach(function (action) {
      var result = patientsReducer(initialState, action as any);
      expect(result.saving).toBe(true);
      expect(result.saveError).toBeNull();
    });
  });

  // El test que protege la deuda 💸 de la Fase 5: createPatientSuccess NO
  // inserta el paciente en items. Apaga "saving" y nada más, porque el effect
  // va a recargar la lista entera. Si alguien "arregla" esto insertando en
  // items (que sería lo correcto hoy), este test se pone rojo y obliga a leer
  // la deuda antes de tocarla.
  it('createPatientSuccess apaga saving pero NO agrega a items', function () {
    var previousState: PatientsState = {
      ...initialState,
      saving: true,
      items: [{ id: 1, fullName: 'Ana Ruiz' } as any]
    };
    var created = { id: 2, fullName: 'Beto Diaz', documentId: 'HC-1002', active: true };
    var action = PatientsActions.createPatientSuccess({ patient: created });
    var result = patientsReducer(previousState, action);
    expect(result.saving).toBe(false);
    // La aserción clave: items quedó con UN solo elemento, el de antes.
    expect(result.items.length).toBe(1);
  });

  it('createPatientFailure apaga saving y guarda saveError', function () {
    var previousState: PatientsState = { ...initialState, saving: true };
    var action = PatientsActions.createPatientFailure({ error: 'boom' });
    var result = patientsReducer(previousState, action);
    expect(result.saving).toBe(false);
    expect(result.saveError).toBe('boom');
  });
});
