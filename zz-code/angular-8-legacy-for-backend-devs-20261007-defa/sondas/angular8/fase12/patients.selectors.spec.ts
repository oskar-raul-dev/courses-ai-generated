// src/app/patients/store/patients.selectors.spec.ts
import * as PatientsSelectors from './patients.selectors';
import { PatientsState } from './patients.reducer';

describe('patients selectors', function () {

  // Un estado de laboratorio armado a mano. Tres pacientes: dos activos y uno
  // dado de baja (active: false), más uno viejo sin el campo "active" para
  // reproducir el dato heredado de la Fase 5.
  var state: PatientsState = {
    items: [
      { id: 1, fullName: 'Ana Ruiz', documentId: 'HC-1001', active: true } as any,
      { id: 2, fullName: 'Beto Diaz', documentId: 'HC-1002', active: false } as any,
      { id: 3, fullName: 'Cielo Mora', documentId: 'HC-1003' } as any // sin "active"
    ],
    loading: false,
    error: null,
    selectedId: null,
    saving: false,
    saveError: null,
    filter: ''
  };

  // selectAllPatients devuelve TODO, incluido el dado de baja. Este selector
  // existe desde la Fase 1 y su convivencia con selectActivePatients es la
  // causa raíz del incidente 09. El test documenta que devuelve los tres.
  it('selectAllPatients devuelve todos, incluido el inactivo', function () {
    // .projector() ejecuta la función del selector con el estado que le doy,
    // saltándome el store y la memoización.
    var result = PatientsSelectors.selectAllPatients.projector(state);
    expect(result.length).toBe(3);
  });

  // selectActivePatients usa "active !== false", así el paciente sin campo
  // (Cielo, el dato viejo) cuenta como activo. Este test blinda esa defensa:
  // si alguien lo cambia a "active === true", Cielo desaparece y el test cae.
  it('selectActivePatients incluye al paciente sin campo active', function () {
    var all = PatientsSelectors.selectAllPatients.projector(state);
    var activePatients = PatientsSelectors.selectActivePatients.projector(all);
    // Ana (true) y Cielo (sin campo) entran; Beto (false) no. Son dos.
    expect(activePatients.length).toBe(2);
    var ids = activePatients.map(function (p) { return p.id; });
    expect(ids).toContain(3);
  });

  it('selectFilteredPatients filtra por texto sobre los activos', function () {
    var all = PatientsSelectors.selectAllPatients.projector(state);
    var activePatients = PatientsSelectors.selectActivePatients.projector(all);
    // El proyector de un selector con dos entradas recibe las dos: la lista
    // ya filtrada por active, y el string del filtro.
    var result = PatientsSelectors.selectFilteredPatients.projector(activePatients, 'ana');
    expect(result.length).toBe(1);
    expect(result[0].fullName).toBe('Ana Ruiz');
  });
});
