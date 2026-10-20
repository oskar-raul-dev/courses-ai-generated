import React from "react";
import { useParams, useHistory } from "react-router-dom";
import { findWheel } from "../mock/wheels";
import { statusLabel } from "../components/WheelCard"; // el mapeo estado→etiqueta de Fase 0

function WheelDetailPage() {
  // useParams devuelve los :params de la URL, SIEMPRE como strings.
  const { id } = useParams();
  const history = useHistory();

  // findWheel convierte el string a número internamente.
  const wheel = findWheel(id);

  if (!wheel) {
    // La rueda no existe (id inválido o inexistente). No es un 404 de ruta:
    // la ruta /wheels/:id matcheó, pero el dato no está.
    return (
      <div className="alert alert-warning">
        No existe la rueda #{id}.{" "}
        <button className="btn btn-link p-0" onClick={() => history.push("/wheels")}>
          Volver al listado
        </button>
      </div>
    );
  }

  return (
    <div>
      <button className="btn btn-outline-secondary btn-sm mb-3" onClick={() => history.goBack()}>
        ← Volver
      </button>
      <h1>{wheel.name}</h1>
      <dl className="row">
        <dt className="col-sm-3">Estado</dt>
        {/* statusLabel traduce el valor interno ('live') a la etiqueta en español ('En vivo') */}
        <dd className="col-sm-9">{statusLabel(wheel.status)}</dd>
        <dt className="col-sm-3">Cierre</dt>
        <dd className="col-sm-9">{wheel.closesAt}</dd>
        <dt className="col-sm-3">Zona horaria</dt>
        <dd className="col-sm-9">{wheel.timezone}</dd>
        <dt className="col-sm-3">Segmentos</dt>
        <dd className="col-sm-9">{wheel.segments.length}</dd>
      </dl>
      {/* Los envíos y el resultado llegan en Fases 5-7. */}
      <p className="text-muted">
        <em>Los envíos de premios se habilitan en fases posteriores.</em>
      </p>
    </div>
  );
}

export default WheelDetailPage;
