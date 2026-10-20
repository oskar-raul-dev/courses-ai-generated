// utils/ticketStats.js (continúa)

// puntos por ticket resuelto: los números de Felipe, estilo arcade
var POINTS_BY_PRIORITY = { low: 100, medium: 200, high: 300 };

// "Laura Marcela Cano" -> "LMC"
function initialsOf(name) {
  return (name || "")
    .split(/\s+/)
    .filter(Boolean)
    .map(function (word) { return word.charAt(0).toUpperCase(); })
    .join("")
    .slice(0, 3);
}

// [{ initials: "LMC", solved: 4, points: 900 }, ...] ordenado por puntos desc
function scoreBoard(tickets, users) {
  var userByUsername = _.keyBy(users, "username");

  var solved = tickets.filter(function (t) {
    return t.assignee && (t.status === "resolved" || t.status === "closed");
  });

  // 💸 DEUDA: la fila se agrupa por las iniciales, no por el username
  var byInitials = _.groupBy(solved, function (t) {
    var user = userByUsername[t.assignee];
    return user ? initialsOf(user.name) : "???";
  });

  return _.orderBy(
    Object.keys(byInitials).map(function (initials) {
      var rows = byInitials[initials];
      return {
        initials: initials,
        solved: rows.length,
        points: _.sumBy(rows, function (t) { return POINTS_BY_PRIORITY[t.priority] || 0; })
      };
    }),
    ["points"], ["desc"]
  );
}