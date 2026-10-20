// ejercicio 2 de F11, para la prueba: contraseña = username + "123"
const { MongoClient } = require("mongodb");
const bcrypt = require("bcryptjs");
async function main() {
  const client = await MongoClient.connect(process.env.MONGO_URL, { useUnifiedTopology: true });
  const users = client.db("tiquetera").collection("users");
  for (const u of await users.find({ passwordHash: { $exists: false } }).toArray()) {
    await users.updateOne({ _id: u._id }, { $set: { passwordHash: await bcrypt.hash(u.username + "123", 10) } });
  }
  console.log("con passwordHash:", await users.countDocuments({ passwordHash: { $exists: true } }));
  await client.close();
}
main();
