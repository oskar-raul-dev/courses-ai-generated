it("getTickets pide /tickets con los params y devuelve res.data", function () {
  apiClient.get.mockResolvedValue({ data: [{ id: 1 }], status: 200 });
  ticketService.getTickets({ status: "open" }).then(function (result) {   // ⚠️ sin return
    expect(result).toEqual([{ id: 1 }]);
  });
});