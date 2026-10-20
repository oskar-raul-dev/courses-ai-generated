function __f(){
var schema = db.getCollectionInfos({ name: "tickets" })[0].options.validator.$jsonSchema;
db.ensayo.insertOne({ title: "sin estado" });
schema.required.filter(function (campo) {
  return db.ensayo.countDocuments({ $nor: [{ $jsonSchema: { required: [campo] } }] }) > 0;
});
// [ 'status', 'priority', 'reporter', 'createdAt' ]
db.ensayo.drop();
}