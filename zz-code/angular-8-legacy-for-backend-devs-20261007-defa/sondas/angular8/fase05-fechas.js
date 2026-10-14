// Fase 05: what happens to birthDate '1984-03-12' through the edit dialog, per host zone.
// load: the form does `new Date(patient.birthDate)` (05-pacientes ~1050)
// save: save() rebuilds 'yyyy-MM-dd' with local getters (05-pacientes ~1104)
// alt:  what toISOString().slice(0, 10) would give instead (the claim in ~1106 and ~1293)
function saveLocal(birth) {
  return birth.getFullYear() + '-' + ('0' + (birth.getMonth() + 1)).slice(-2) + '-' + ('0' + birth.getDate()).slice(-2);
}
const stored = '1984-03-12';
const loaded = new Date(stored);                 // what the datepicker receives on edit
const picked = new Date(1984, 2, 12);            // what MatNativeDateModule gives when the user picks the 12th
console.log('TZ', process.env.TZ);
console.log('  edit without touching: shows day', loaded.getDate(), '-> saves', saveLocal(loaded));
console.log('  user picks the 12th : saves', saveLocal(picked), '| toISOString would save', picked.toISOString().slice(0, 10));
