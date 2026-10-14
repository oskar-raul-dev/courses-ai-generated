# Boss I · La señora que es tres pacientes · solución de referencia

No viaja al repositorio público (D42). Se ejecutó el 14/10/2026 sobre el modelo de
`uv run lab load --profile m --model` (caja M `3e59292e9918…`).

- `solucion.sql`: la fusión (11073 en 678, con `patient_merge`), los dos documentos en la persona, la
  reasignación del protocolo 10197772 de la ficha del nieto (49860) a la señora con
  `alameda.lab_order_reassignment`, y la vista `alameda.patient_result_history` (tablas anchas `Quimica` y
  `HemoglobinaGlicosilada` hasta marzo de 2008, `alameda.result` después, con la fusión resuelta).
- Salidas: `../salidas/boss1-partida.txt` (lo que ve Norma), `../salidas/boss1-solucion.txt` (lo entregado) y
  `../salidas/boss1-measure.txt` (la consulta de la historia con `lab measure`).
- Contra la verdad: 111 protocolos de la persona 200001 en `truth.order_payer`, 111 en el modelo; 0 resultados de
  hemograma del nieto en la historia; glucemia 37 valores de la tabla ancha (36 numéricos) y 74 del modelo (70
  numéricos, 3 muestras observadas).
- Lo que la solución no hace y un alumno podría hacer mejor: la historia lee todas las tablas anchas de química
  cada vez (la vista no tiene índice por paciente); materializarla o indexar `Protocolos."IdPaciente"` en una
  copia de staging es del Bloque II.
