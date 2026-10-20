var __o = {
// Una sola vez, en mongosh:
rs.initiate({ _id: "rs0", members: [{ _id: 0, host: "localhost:27017" }] })
// el prompt cambia a rs0:PRIMARY — ya eres un replica set (de uno)
};