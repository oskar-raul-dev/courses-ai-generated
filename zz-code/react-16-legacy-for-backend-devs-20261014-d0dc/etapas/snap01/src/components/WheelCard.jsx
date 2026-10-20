import React, { useState } from "react";

/**
 * Traduce el estado interno de la rueda a la etiqueta que ve el usuario.
 * El `case` va en inglés (es el valor de dato); el `return` va en
 * español (es lo que se muestra en pantalla).
 */
export function statusLabel(status) {
  switch (status) {
    case "draft":
      return "Borrador";
    case "scheduled":
      return "Programada";
    case "live":
      return "En vivo";
    case "ended":
      return "Terminada";
    case "reconciled":
      return "Conciliada";
    default:
      return status;
  }
}

/**
 * Tarjeta que muestra una rueda y permite desplegar su detalle.
 * Componente funcional con hooks: es el estilo que usamos para
 * módulos nuevos. (El código legacy tiene clases; las vemos en A5.)
 *
 * @param {Object} props
 * @param {Object} props.wheel - Rueda a mostrar.
 */
function WheelCard({ wheel }) {
  // Estado local: ¿está desplegado el detalle? Arranca cerrado.
  // useState devuelve [valor, setter]; cambiar el valor re-renderiza.
  const [isDetailOpen, setDetailOpen] = useState(false);

  // Elegimos la clase del badge según el estado de la rueda.
  // Nada de lógica de negocio pesada acá: solo presentación.
  const badgeClass = wheel.status === "live" ? "badge-success" : "badge-secondary";

  return (
    <div className="wheel-card card p-3">
      <div className="d-flex justify-content-between align-items-center">
        <h5 className="mb-0">{wheel.name}</h5>
        {/* El valor va en inglés en el dato, pero mostramos la etiqueta
            traducida al español. */}
        <span className={`badge ${badgeClass}`}>
          {statusLabel(wheel.status)}
        </span>
      </div>

      <p className="text-muted mb-2">Segmentos: {wheel.segments.length}</p>

      <button
        className="btn btn-outline-primary btn-sm align-self-start"
        onClick={() => setDetailOpen(!isDetailOpen)}
      >
        {isDetailOpen ? "Ocultar detalle" : "Ver detalle"}
      </button>

      {/* Renderizado condicional: el detalle solo existe en el DOM
          cuando isDetailOpen es true. Es el patrón más común de
          React para mostrar/ocultar. */}
      {isDetailOpen && (
        <div className="mt-3">
          <p className="mb-1">Zona horaria: {wheel.timezone}</p>
          <p className="mb-0">Cierre: {wheel.closesAt}</p>
        </div>
      )}
    </div>
  );
}

export default WheelCard;
