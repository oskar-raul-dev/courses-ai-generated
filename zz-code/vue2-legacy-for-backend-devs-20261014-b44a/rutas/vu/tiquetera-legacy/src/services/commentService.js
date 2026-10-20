import apiClient from "./apiClient";

function getByTicket(ticketId) {
  return apiClient
    .get("/comments", { params: { ticketId: ticketId, _sort: "createdAt", _order: "asc" } })
    .then(function (res) { return res.data; });
}

function create(comment) {
  return apiClient.post("/comments", comment).then(function (res) {
    return res.data;
  });
}

export default { getByTicket: getByTicket, create: create };
