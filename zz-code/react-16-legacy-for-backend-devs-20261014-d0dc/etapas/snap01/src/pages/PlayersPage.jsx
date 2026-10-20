import React from "react";

// Datos hardcodeados otra vez. Se conectan al store en fases posteriores.
const demoPlayers = [
  { id: 42, name: "Juan P.", country: "Colombia" },
  { id: 43, name: "María R.", country: "Chile" },
];

function PlayersPage() {
  return (
    <div>
      <h1 className="mb-3">Jugadores</h1>
      <ul className="list-group">
        {demoPlayers.map((player) => (
          <li key={player.id} className="list-group-item d-flex justify-content-between">
            <span>{player.name}</span>
            <span className="text-muted">{player.country}</span>
          </li>
        ))}
      </ul>
    </div>
  );
}

export default PlayersPage;
