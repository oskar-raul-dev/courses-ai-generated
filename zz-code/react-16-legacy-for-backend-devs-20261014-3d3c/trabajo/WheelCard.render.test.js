// Prueba de humo de F00, solo en la copia de zz-code (no va al curso).
import React from "react";
import ReactDOMServer from "react-dom/server";
import App from "./App";

test("la rueda de F00 renderiza con su nombre, estado y segmentos", () => {
  const html = ReactDOMServer.renderToStaticMarkup(<App />);
  expect(html).toContain("Esclusa de Oro");
  expect(html).toContain("En vivo");
  expect(html).toContain("Segmentos: 8");
  expect(html).toContain("wheel-card");
});
