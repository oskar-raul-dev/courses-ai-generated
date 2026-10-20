// Incidente 09 (copia de zz-code; la misma prueba que publica el cuaderno). Sin red.
import React from "react";
import { render, screen, fireEvent } from "@testing-library/react";
import { Provider } from "react-redux";
import { configureStore } from "@reduxjs/toolkit";
import wheelReducer from "../features/wheels/wheelSlice";
import WheelForm from "../features/wheels/WheelForm";

test("guardar la rueda no recarga la página: el submit llama a preventDefault", () => {
  const store = configureStore({ reducer: { wheels: wheelReducer } });
  const originalDispatch = store.dispatch;
  store.dispatch = (action) => (typeof action === "function" ? Promise.resolve() : originalDispatch(action));
  render(<Provider store={store}><WheelForm /></Provider>);
  fireEvent.change(screen.getByLabelText("Nombre"), { target: { value: "Semana del Canal 2027" } });
  fireEvent.change(screen.getByLabelText("Cierre (ISO, con offset)"), { target: { value: "2027-08-14T20:00:00-05:00" } });
  const event = new Event("submit", { bubbles: true, cancelable: true });
  screen.getByText("Nueva rueda").closest("form").dispatchEvent(event);
  expect(event.defaultPrevented).toBe(true); // con el bug: false, y el navegador recarga
});
