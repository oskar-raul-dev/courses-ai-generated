

// { open: 5, in_progress: 3, resolved: 8, closed: 2 }
function countByStatus(tickets) {
  return _.countBy(tickets, "status");
}

// [{ agent: "lmcano", count: 4 }, ...] solo tickets activos, ordenado desc
function activeByAgent(tickets) {
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
function resolvedPercent(tickets) {
  if (tickets.length === 0) return 0;
  var done = tickets.filter(function (t) {
    return t.status === "resolved" || t.status === "closed";
  }).length;
  return Math.round((done / tickets.length) * 100);
}