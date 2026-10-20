import apiClient from "./apiClient";

function getTickets(params) {
  // params opcional: { status: "open", _sort: "createdAt", _order: "desc" }
  return apiClient.get("/tickets", { params: params }).then(function (res) {
    return res.data;
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
