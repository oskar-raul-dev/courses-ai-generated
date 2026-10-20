// Medición del incidente 19 (no va al curso): ms por cambio de origen, con 10.000 y 180.000 giros.
import React from "react";
import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import { Provider } from "react-redux";
import { store } from "../app/store";
import { login } from "../features/auth/authSlice";
import DashboardPage from "../features/dashboard/DashboardPage";

jest.mock("chart.js", () => class { constructor(c, cfg) { this.data = cfg.data; } update() {} destroy() {} });
HTMLCanvasElement.prototype.getContext = () => ({});

test("medir", async () => {
  await store.dispatch(login({ email: "ibatista@esclusa.test", password: "esclusa123" }));
  render(<Provider store={store}><DashboardPage /></Provider>);
  await waitFor(() => expect(screen.getByRole("option", { name: "Semana del Canal" })).toBeInTheDocument());
  for (const [wheel, label] of [["4", "10000"], ["2", "180000"]]) {
    fireEvent.change(screen.getByLabelText("Rueda"), { target: { value: wheel } });
    await waitFor(() => expect(screen.getByText(label)).toBeInTheDocument(), { timeout: 30000 });
    const times = [];
    for (const origin of ["free", "paid", "all", "free", "paid", "all", "free", "paid", "all", "free"]) {
      const t0 = performance.now();
      fireEvent.change(screen.getByLabelText("Origen de los giros"), { target: { value: origin } });
      times.push(performance.now() - t0);
    }
    times.sort((a, b) => a - b);
    console.log(`MEDICION ${label} giros: mediana ${times[5].toFixed(1)} ms, mínimo ${times[0].toFixed(1)}, máximo ${times[9].toFixed(1)}`);
  }
}, 120000);
