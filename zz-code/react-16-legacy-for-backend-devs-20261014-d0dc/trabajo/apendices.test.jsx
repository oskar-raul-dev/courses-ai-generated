// Ejemplos de A5 §7 y A6 §6, extraídos del .md tal cual (copia de zz-code; no va al curso).
import React from "react";
import { render, screen, fireEvent } from "@testing-library/react";
import { configureStore } from "@reduxjs/toolkit";
import { requestReducer, ResendButton } from "./ejemplos/a5Request";
import reducer, { grantQueued, rollbackGrant } from "./ejemplos/a6GrantSlice";

test("A5 §7: el reducer local ordena las transiciones y el botón se deshabilita al empezar", () => {
  expect(requestReducer({ status: "idle", error: null }, { type: "start" })).toEqual({ status: "loading", error: null });
  expect(requestReducer({ status: "loading", error: null }, { type: "fail", error: "x" })).toEqual({ status: "idle", error: "x" });
  render(<ResendButton playerName="Juan P." />);
  fireEvent.click(screen.getByText("Reenviar a Juan P."));
  expect(screen.getByText("Reenviar a Juan P.")).toBeDisabled();
});

test("A6 §6: el slice reducido arma su type y su rollback respeta lo confirmado", () => {
  expect(grantQueued.type).toBe("grants/grantQueued");
  const store = configureStore({ reducer: { grants: reducer } });
  store.dispatch(grantQueued({ id: "g-1", status: "sent", confirmed: true }));
  store.dispatch(grantQueued({ id: "g-2", status: "sent", confirmed: false }));
  store.dispatch(rollbackGrant({ grantId: "g-1", error: "no" }));
  store.dispatch(rollbackGrant({ grantId: "g-2", error: "conflicto" }));
  expect(store.getState().grants.byId["g-1"].status).toBe("sent");
  expect(store.getState().grants.byId["g-2"]).toMatchObject({ status: "failed", error: "conflicto" });
});
