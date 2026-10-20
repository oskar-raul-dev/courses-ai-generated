import React from "react";
import Navbar from "./Navbar";

// Envuelve el navbar persistente + el área de contenido.
// children es lo que el router mete adentro según la ruta.
function AppLayout({ children }) {
  return (
    <>
      <Navbar />
      <main className="container mt-4">{children}</main>
    </>
  );
}

export default AppLayout;
