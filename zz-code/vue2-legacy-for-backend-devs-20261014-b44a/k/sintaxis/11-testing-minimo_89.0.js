it("cuenta los tickets por estado", function () {
  // ARRANGE: prepara el mundo
  var tickets = [
    { status: "open" }, { status: "open" }, { status: "resolved" }
  ];

  // ACT: ejecuta LO ÚNICO que estás probando
  var result = countByStatus(tickets);

  // ASSERT: verifica
  expect(result).toEqual({ open: 2, resolved: 1 });
});