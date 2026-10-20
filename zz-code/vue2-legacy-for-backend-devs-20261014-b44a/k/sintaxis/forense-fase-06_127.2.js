var __o = {
await session.withTransaction(async function () {
  await tickets.insertOne(doc, { session });
  await comments.insertOne(comment);      // ⚠️ sin { session }
});
};