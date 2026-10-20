import React from "react";
import { useLocation, Link } from "react-router-dom";

function NotFoundPage() {
  // useLocation nos dice qué URL intentó el usuario. Útil para el forense:
  // si alguien reporta "me da 404", esto muestra exactamente qué ruta falló.
  const location = useLocation();

  return (
    <div className="text-center mt-5">
      <h1 className="display-4">404</h1>
      <p className="lead">
        No hay nada en <code>{location.pathname}</code>
      </p>
      <Link to="/wheels" className="btn btn-primary">
        Ir al listado de ruedas
      </Link>
    </div>
  );
}

export default NotFoundPage;
