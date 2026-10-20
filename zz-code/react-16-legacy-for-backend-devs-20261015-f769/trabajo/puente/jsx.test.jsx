// src/__puente__/jsx.test.jsx — el JSX nuevo, sobre React 16.14 con CRA 4.
// React 16.14.0 ya trae react/jsx-runtime, y CRA 4 lo usa solo si lo encuentra.
// Con DISABLE_NEW_JSX_TRANSFORM=true, CRA 4 vuelve al JSX clásico (React.createElement).
import React from "react";
import { render, screen } from "@testing-library/react";
import WheelBadge from "./WheelBadge";

const classic = process.env.DISABLE_NEW_JSX_TRANSFORM === "true";

test(`React ${React.version}, JSX ${classic ? "clásico" : "automático"}: un componente sin import de React`, () => {
  if (classic) {
    jest.spyOn(console, "error").mockImplementation(() => {});
    expect(() => render(<WheelBadge status="live" />)).toThrow("React is not defined");
  } else {
    render(<WheelBadge status="live" />);
    expect(screen.getByText("En vivo")).toBeInTheDocument();
  }
});
