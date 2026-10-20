var __a = [
jest.mock("@/services/ticketService"); // auto-mock: todas sus funciones son jest.fn()


// y ahora cada función es programable:
ticketService.getTickets.mockResolvedValue([{ id: 1 }]); // Promise que resuelve
ticketService.getTickets.mockRejectedValue(new Error()); // Promise que rechaza

// y espiable:
expect(ticketService.getTickets).toHaveBeenCalledWith({ _sort: "createdAt", _order: "desc" });
];