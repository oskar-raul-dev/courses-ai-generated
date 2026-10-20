// Incidente 12 (copia de zz-code; la misma prueba que publica el cuaderno). Reducer puro: la secuencia de DevTools.
import reducer, { grantQueued, sendGrant, grantSent, rollbackGrant } from "../features/grants/grantSlice";

test("el rollback del envío masivo no pisa el envío individual ya confirmado", () => {
  const juan = { playerId: 42, playerName: "Juan P.", caseId: "C-2210", prize: "vidas-5", reason: "caída", confirmed: false, error: null };
  let state = reducer(undefined, grantQueued({ ...juan, id: "g-1", status: "queued" }));
  state = reducer(state, sendGrant.pending("req-1", "g-1"));
  state = reducer(state, grantSent({ grantId: "g-1" }));
  state = reducer(state, sendGrant.fulfilled({}, "req-1", "g-1")); // el individual: confirmado
  state = reducer(state, grantQueued({ ...juan, id: "g-7", status: "queued" })); // el masivo, mismo caso
  state = reducer(state, sendGrant.pending("req-7", "g-7"));
  state = reducer(state, grantSent({ grantId: "g-7" }));
  const conflict = { message: "Ese caso ya fue compensado para este jugador.", type: "conflict" };
  state = reducer(state, rollbackGrant({ grantId: "g-7", caseId: "C-2210", playerId: 42, error: conflict }));
  expect(state.byId["g-1"].status).toBe("sent"); // con el bug: "failed"
  expect(state.byId["g-7"].status).toBe("failed");
});
