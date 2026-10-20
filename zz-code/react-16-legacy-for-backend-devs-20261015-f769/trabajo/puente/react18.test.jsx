// src/__puente__/react18.test.jsx — corre igual sobre React 16.14, 17.0.2 y 18.2.0 (copias descartables).
import React, { useEffect, useState } from "react";
import ReactDOM from "react-dom";
import { act } from "react-dom/test-utils";

const major = Number(React.version.split(".")[0]);
global.IS_REACT_ACT_ENVIRONMENT = true; // React 18 lo pide para act(); en 16 no hace nada

// Monta como lo hace cada versión: render en 16, createRoot en 18.
function mount(element) {
  const container = document.createElement("div");
  if (major >= 18) {
    const { createRoot } = require("react-dom/client");
    const root = createRoot(container);
    act(() => root.render(element));
    return () => act(() => root.unmount());
  }
  act(() => ReactDOM.render(element, container));
  return () => ReactDOM.unmountComponentAtNode(container);
}

test(`React ${React.version}: dos setState dentro de un setTimeout`, async () => {
  let renders = 0;
  let bump;
  function Counter() {
    const [a, setA] = useState(0);
    const [b, setB] = useState(0);
    renders += 1;
    bump = () => setTimeout(() => { setA(a + 1); setB(b + 1); }, 0);
    return <span>{a + b}</span>;
  }
  const unmount = mount(<Counter />);
  renders = 0;
  await act(async () => {
    bump();
    await new Promise((resolve) => setTimeout(resolve, 10));
  });
  expect(renders).toBe(major >= 18 ? 1 : 2); // 18 agrupa; 16 solo agrupa en sus handlers
  unmount();
});

test(`React ${React.version}: un efecto bajo StrictMode, en desarrollo`, () => {
  let runs = 0;
  function Polling() {
    useEffect(() => {
      runs += 1;
    }, []);
    return null;
  }
  const unmount = mount(<React.StrictMode><Polling /></React.StrictMode>);
  expect(runs).toBe(major >= 18 ? 2 : 1); // 18 monta, desmonta y vuelve a montar en dev
  unmount();
});

test(`React ${React.version}: useTransition`, () => {
  expect(typeof React.useTransition).toBe(major >= 18 ? "function" : "undefined");
});
