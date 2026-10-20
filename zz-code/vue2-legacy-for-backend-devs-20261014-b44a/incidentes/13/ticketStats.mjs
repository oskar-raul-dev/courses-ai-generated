import _ from "lodash";

// { open: 5, in_progress: 3, resolved: 8, closed: 2 }
export function countByStatus(tickets) {
  return _.countBy(tickets, "status");
}

// [{ agent: "lmcano", count: 4 }, ...] solo tickets activos, ordenado desc
export function activeByAgent(tickets) {
  var active = tickets.filter(function (t) {
    return t.status === "open" || t.status === "in_progress";
  });

  var grouped = _.countBy(active, function (t) {
    return t.assignee || "(sin asignar)";
  });

  return _.orderBy(
    Object.keys(grouped).map(function (agent) {
      return { agent: agent, count: grouped[agent] };
    }),
    ["count"], ["desc"]
  );
}

export function resolvedPercent(tickets) {
  if (tickets.length === 0) return 0;
  var done = tickets.filter(function (t) {
    return t.status === "resolved" || t.status === "closed";
  }).length;
  return Math.round((done / tickets.length) * 100);
}


// puntos por ticket resuelto: los números de Felipe, estilo arcade
export var POINTS_BY_PRIORITY = { low: 100, medium: 200, high: 300 };

// "Laura Marcela Cano" -> "LMC"
export function initialsOf(name) {
  return (name || "")
    .split(/\s+/)
    .filter(Boolean)
    .map(function (word) { return word.charAt(0).toUpperCase(); })
    .join("")
    .slice(0, 3);
}

// [{ initials: "LMC", solved: 4, points: 900 }, ...] ordenado por puntos desc
export function scoreBoard(tickets, users) {
  var userByUsername = _.keyBy(users, "username");

  var solved = tickets.filter(function (t) {
    return t.assignee && (t.status === "resolved" || t.status === "closed");
  });

  // la fila se agrupa por username; las iniciales solo se pintan
  var byUsername = _.groupBy(solved, "assignee");

  return _.orderBy(
    Object.keys(byUsername).map(function (username) {
      var user = userByUsername[username];
      var rows = byUsername[username];
      return {
        username: username,
        initials: user ? initialsOf(user.name) : "???",
        name: user ? user.name : username + " (usuario borrado)",
        solved: rows.length,
        points: _.sumBy(rows, function (t) { return POINTS_BY_PRIORITY[t.priority] || 0; })
      };
    }),
    ["points"], ["desc"]
  );
}
