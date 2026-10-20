this.tickets.unshift(newTicket); // ✅ la tabla se repinta sola
this.tickets[0] = newTicket;     // ❌ Vue ni se entera