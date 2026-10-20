realtime.emit("ticket:created", doc);        // ⚠️ antes
var result = await tickets.insertOne(doc);