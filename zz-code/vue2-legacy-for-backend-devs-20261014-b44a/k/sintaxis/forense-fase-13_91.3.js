var __a = [
it("corre contra el motor del curso", async function () {
  var info = await db.admin().serverInfo();
  expect(info.version).toMatch(/^4\.4/);
});
];