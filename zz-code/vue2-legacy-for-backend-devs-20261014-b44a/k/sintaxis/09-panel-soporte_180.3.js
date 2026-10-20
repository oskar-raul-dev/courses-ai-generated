var __a = [
Promise.all([ticketService.getTickets(params), userService.getUsers()])
  .then(function (results) {
    self.tickets = results[0]; // el orden de results = orden del arreglo
    self.users = results[1];
  })
  .catch(function () { /* si CUALQUIERA falla, cae aquí */ });
];