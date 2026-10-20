// Incidente 21 (copia de zz-code; no va al curso): el tablero con la regla vieja sembrada (--accommodating).
import React from "react";
import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import { Provider } from "react-redux";
import { store } from "../app/store";
import { login } from "../features/auth/authSlice";
import DashboardPage from "../features/dashboard/DashboardPage";

jest.mock("chart.js", () => class { constructor(c, cfg) { this.data = cfg.data; } update() {} destroy() {} });
HTMLCanvasElement.prototype.getContext = () => ({});

test("el tablero de la Rueda de fin de mes con la regla vieja", async () => {
  await store.dispatch(login({ email: "ibatista@esclusa.test", password: "esclusa123" }));
  render(<Provider store={store}><DashboardPage /></Provider>);
  await waitFor(() => expect(screen.getByRole("option", { name: "Rueda de fin de mes" })).toBeInTheDocument());
  fireEvent.change(screen.getByLabelText("Rueda"), { target: { value: "4" } });
  await waitFor(() => expect(screen.getByText("Con alarma")).toBeInTheDocument(), { timeout: 10000 });
  expect(screen.getByText("χ² = 808.35")).toBeInTheDocument();
  const bands = store.getState().dashboard; // los conteos, para el enunciado
  const { summarizeSpins } = require("../features/dashboard/dashboardMath");
  const counts = summarizeSpins(bands.spinLog, bands.segments).countsByOrigin.all;
  expect(counts).toEqual([3404, 2179, 505, 1704, 1161, 877, 106, 64]);
}, 30000);
