// services/activityService.js
import apiClient from "./apiClient"; // el mismo patrón del tronco

function getByTicket(ticketId) {
  // json-server filtra por query string: /activity?ticketId=1&_sort=at&_order=desc
  return apiClient
    .get("/activity", { params: { ticketId: ticketId, _sort: "at", _order: "desc" } })
    .then(function (res) { return res.data; });
}

export default {
  getByTicket: getByTicket
};
