// scripts/fix-dates.js
db.tickets.find({ createdAt: { $type: "string" } }).forEach(function (doc) {
  db.tickets.updateOne(
    { _id: doc._id },
    { $set: { createdAt: new Date(doc.createdAt) } }
  );
});
