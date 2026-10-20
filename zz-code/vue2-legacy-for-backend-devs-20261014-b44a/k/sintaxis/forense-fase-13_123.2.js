var __o = {
it("detecta el doble take", async function () {
  await Promise.all([take(id, "ana"), take(id, "beto")]);
  expect(await countAssigned(id)).toBe(1);
});
};