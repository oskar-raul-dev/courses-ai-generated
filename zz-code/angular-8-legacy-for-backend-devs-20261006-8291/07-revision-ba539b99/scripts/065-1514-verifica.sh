# rescatado de la sesión ba539b99, 2026-09-11T15:14:37Z · Extract phase 1 and 5 code
echo "=== F1 reducer loadPatientsSuccess ==="; sed -n '536,556p' 01-estructura-base-ngrx.md
echo; echo "=== F5 patient-list subscribe ==="; sed -n '789,800p' 05-pacientes.md
echo; echo "=== F5 createPatient\$ ==="; grep -n -B4 -A10 "createPatient\$ = createEffect" 05-pacientes.md | head -24
