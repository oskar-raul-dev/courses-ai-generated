router.get("/tickets/:id", async function (req, res) {
  var ticket = await service.getById(req.params.id);   // ⚠️ si esto lanza…
  res.json(serialize(ticket));
});