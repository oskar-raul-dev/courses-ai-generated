// src/services/activityService.js
import apiClient from "./apiClient";

function getByTicket(ticketId) {
  // json-server: filtro + orden, gratis
  return apiClient
    .get("/activity", {
      params: { ticketId: ticketId, _sort: "at", _order: "desc" }
    })
    .then(function (res) {
      return res.data;
    });
}

function create(activity) {
  return apiClient.post("/activity", activity).then(function (res) {
    return res.data;
  });
}

export default {
  getByTicket: getByTicket,
  create: create
};
