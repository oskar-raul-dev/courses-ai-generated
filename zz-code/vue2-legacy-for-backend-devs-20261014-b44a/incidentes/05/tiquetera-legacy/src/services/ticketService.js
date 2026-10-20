import apiClient from "./apiClient";

// lo que un ticket tiene que tener siempre; lo demás que traiga (createdAt, reporter…) se conserva
var TICKET_DEFAULTS = {
  title: "",
  description: "",
  status: "open",
  priority: "medium",
  assignee: null
};

function normalizeTicket(raw) {
  // tags va aparte: un arreglo nuevo por ticket, nunca uno compartido entre todos
  return Object.assign({}, TICKET_DEFAULTS, raw, { tags: raw.tags || [] });
}

function getTickets(params) {
  return apiClient.get("/tickets", { params: params }).then(function (res) {
    return res.data.map(normalizeTicket);
  });
}

function getTicketById(id) {
  return apiClient.get("/tickets/" + id).then(function (res) {
    return res.data;
  });
}

function createTicket(data) {
  return apiClient.post("/tickets", data).then(function (res) {
    return res.data;
  });
}

function updateTicket(id, data) {
  return apiClient.patch("/tickets/" + id, data).then(function (res) {
    return res.data;
  });
}

function deleteTicket(id) {
  return apiClient.delete("/tickets/" + id).then(function (res) {
    return res.data;
  });
}

export default {
  getTickets: getTickets,
  getTicketById: getTicketById,
  createTicket: createTicket,
  updateTicket: updateTicket,
  deleteTicket: deleteTicket
};
