// Incidente 20 (copia de zz-code): la prueba de MetricCard de la Fase 10, sin tocar. Se corre con TZ=UTC.
import React from "react";
import { render, screen } from "@testing-library/react";
import MetricCard from "../features/dashboard/MetricCard";

// El 20 de diciembre a las 21:00 en Panamá: en UTC ya es el 21.
const EVENING = Date.parse("2026-12-20T21:00:00-05:00");

describe("MetricCard", () => {
  // El reloj de la máquina se congela en ese instante: si el componente lo consultara,
  // vería el mismo momento que le llega por props. Lo que no se congela es la zona horaria.
  beforeEach(() => {
    jest.useFakeTimers("modern");
    jest.setSystemTime(EVENING);
  });
  afterEach(() => jest.useRealTimers());

  test("muestra título, valor y pista", () => {
    render(<MetricCard title="Giros" value="10000" hint="7566 gratis · 2434 pagos" />);
    expect(screen.getByText("Giros")).toBeInTheDocument();
    expect(screen.getByText("10000")).toBeInTheDocument();
    expect(screen.getByText("7566 gratis · 2434 pagos")).toBeInTheDocument();
  });

  test("muestra el instante de los datos en hora de Panamá, en cualquier máquina", () => {
    render(<MetricCard title="Giros" value="10000" updatedAt={EVENING} />);
    expect(screen.getByText("Actualizado: 20/12 21:00")).toBeInTheDocument();
  });
});
