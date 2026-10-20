import React from "react";
import ReactDOM from "react-dom";
import "./index.scss"; // el entry de Sass de la Fase 0 (tokens → bootstrap → propios)
import AppRouter from "./AppRouter";

// React 16: ReactDOM.render, NO createRoot (eso es React 18).
ReactDOM.render(<AppRouter />, document.getElementById("root"));
