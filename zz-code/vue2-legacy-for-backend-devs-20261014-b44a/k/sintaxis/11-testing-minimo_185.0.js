it("carga tickets", function () {
  ticketService.getTickets.mockResolvedValue([{ id: 1 }]);

  return actions.fetchTickets(context).then(function () { // ← el return ES el test
    expect(context.commit).toHaveBeenCalledWith("SET_TICKETS", [{ id: 1 }]);
  });
});