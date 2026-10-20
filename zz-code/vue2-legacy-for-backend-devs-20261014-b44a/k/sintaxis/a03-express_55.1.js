function __f(){
// ⚠️ EL BUG. Este código parece correcto y NO lo es.
router.get("/:id", async function (req, res) {
  const ticket = await service.getById(req.params.id);   // ← si esto REVIENTA...
  res.json(ticket);
});
}