// Pruebas de render de F05 (copia de zz-code; no va al curso). Sin red.
import React from "react";
import { render, screen } from "@testing-library/react";
import { Provider } from "react-redux";
import { configureStore } from "@reduxjs/toolkit";
import grantReducer from "../features/grants/grantSlice";
import GrantList from "../features/grants/GrantList";

const base = { playerId: 42, playerName: "Juan P.", caseId: "C-1", prize: "vidas-5", reason: "r", error: null };
function renderList(grants) {
  const byId = Object.fromEntries(grants.map((g) => [g.id, g]));
  const store = configureStore({ reducer: { grants: grantReducer }, preloadedState: { grants: { byId, order: grants.map((g) => g.id) } } });
  render(<Provider store={store}><GrantList /></Provider>);
}

test("cada estado ofrece lo suyo", () => {
  renderList([
    { ...base, id: "g-1", status: "queued", confirmed: false },
    { ...base, id: "g-2", status: "sent", confirmed: false },
    { ...base, id: "g-3", status: "sent", confirmed: true },
    { ...base, id: "g-4", status: "failed", confirmed: false, error: { message: "Ese caso ya fue compensado para este jugador.", type: "conflict" } },
  ]);
  expect(screen.getByText("En cola (se puede deshacer)")).toBeInTheDocument();
  expect(screen.getByText("Enviado (sin confirmar)")).toBeInTheDocument();
  expect(screen.getByText("Enviado")).toBeInTheDocument();
  expect(screen.getByText("Ese caso ya fue compensado para este jugador.")).toBeInTheDocument();
  expect(screen.getAllByText("Enviar ahora").length).toBe(2); // en cola y sin confirmar
  expect(screen.getAllByText("Deshacer").length).toBe(1);
  expect(screen.getByText("Reintentar")).toBeInTheDocument();
  expect(screen.getByText("Descartar")).toBeInTheDocument();
});
