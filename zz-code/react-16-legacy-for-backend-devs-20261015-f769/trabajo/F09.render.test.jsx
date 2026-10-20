// Render del tablero contra los dos mocks (copia de zz-code; no va al curso). chart.js simulado: jsdom no pinta canvas.
import React from "react";
import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import { Provider } from "react-redux";
import { store } from "../app/store";
import { login } from "../features/auth/authSlice";
import DashboardPage from "../features/dashboard/DashboardPage";
import { selectSpinSummary } from "../features/dashboard/dashboardSelectors";

// Una clase y no jest.fn(): CRA 4 corre con resetMocks, que borraría la implementación.
jest.mock("chart.js", () =>
  class FakeChart {
    constructor(ctx, config) { this.data = config.data; }
    update() {}
    destroy() {}
  }
);
HTMLCanvasElement.prototype.getContext = () => ({});

test("el tablero de la Rueda de fin de mes, y cambiar el origen no recalcula", async () => {
  await store.dispatch(login({ email: "ibatista@esclusa.test", password: "esclusa123" }));
  render(<Provider store={store}><DashboardPage /></Provider>);
  await waitFor(() => expect(screen.getByRole("option", { name: "Rueda de fin de mes" })).toBeInTheDocument());
  fireEvent.change(screen.getByLabelText("Rueda"), { target: { value: "4" } });
  await waitFor(() => expect(screen.getAllByTestId("metric-card")).toHaveLength(4), { timeout: 10000 });
  expect(screen.getByText("10000")).toBeInTheDocument();
  expect(screen.getByText("7566 gratis · 2434 pagos")).toBeInTheDocument();
  expect(screen.getByText("US$135,60")).toBeInTheDocument();
  expect(screen.getByText("Sin alarma")).toBeInTheDocument();
  expect(screen.getByTestId("band-chart")).toBeInTheDocument();
  const passes = selectSpinSummary.recomputations();
  for (const origin of ["free", "paid", "all", "free"]) fireEvent.change(screen.getByLabelText("Origen de los giros"), { target: { value: origin } });
  expect(selectSpinSummary.recomputations()).toBe(passes);
}, 30000);
