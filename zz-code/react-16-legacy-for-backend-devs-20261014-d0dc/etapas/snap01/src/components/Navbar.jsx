import React from "react";
import { NavLink } from "react-router-dom";

// Funcional: no necesita estado ni ciclo de vida, solo pinta links.
// NavLink resalta solo el link de la ruta activa vía la clase active.
// Los textos visibles van en español; las rutas (URLs) en inglés, salvo /bitacora.
function Navbar() {
  return (
    <nav className="navbar navbar-expand navbar-dark bg-dark">
      <NavLink className="navbar-brand" to="/wheels">
        🎡 Esclusa
      </NavLink>
      <div className="navbar-nav">
        <NavLink className="nav-item nav-link" to="/wheels">
          Ruedas
        </NavLink>
        <NavLink className="nav-item nav-link" to="/players">
          Jugadores
        </NavLink>
        <NavLink className="nav-item nav-link" to="/bitacora">
          Bitácora
        </NavLink>
        <NavLink className="nav-item nav-link" to="/dashboard">
          Dashboard
        </NavLink>
      </div>
    </nav>
  );
}

export default Navbar;
