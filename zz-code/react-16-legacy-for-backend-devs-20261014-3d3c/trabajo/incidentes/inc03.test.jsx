// Prueba de regresión del incidente 03 (copia de zz-code; no va al curso).
import React from "react";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { MemoryRouter, Route } from "react-router-dom";
import Navbar from "../components/Navbar";

test("el menú navega sin recargar el documento", () => {
  let currentPath = null;
  render(
    <MemoryRouter initialEntries={["/"]}>
      <Navbar />
      <Route path="*" render={({ location }) => { currentPath = location.pathname; return null; }} />
    </MemoryRouter>
  );
  userEvent.click(screen.getByText("Ruedas"));
  expect(currentPath).toBe("/wheels");
});
