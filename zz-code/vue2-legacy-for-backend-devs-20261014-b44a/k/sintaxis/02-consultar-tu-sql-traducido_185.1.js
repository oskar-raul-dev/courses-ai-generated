function __f(){
// mongosh te deja creer que find() "devuelve datos"
db.tickets.find({ status: "open" })

// La verdad con la que vivirás desde la Fase 10:
const cursor = db.collection("tickets").find({ status: "open" });
const docs = await cursor.toArray();          // o for await...of para streams
}