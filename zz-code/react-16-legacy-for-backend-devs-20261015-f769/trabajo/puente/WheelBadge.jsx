// Sin import de React, a propósito: con el JSX de React 17+ alcanza; en 16, no.
export default function WheelBadge({ status }) {
  return <span className="badge">{status === "live" ? "En vivo" : status}</span>;
}
