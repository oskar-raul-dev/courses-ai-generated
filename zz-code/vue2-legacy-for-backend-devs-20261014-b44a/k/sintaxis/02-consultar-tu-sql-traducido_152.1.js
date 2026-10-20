function __f(){
db.tickets.find().sort({ createdAt: -1 })
db.tickets.find().sort({ priority: 1, createdAt: -1 })
db.tickets.find().sort({ createdAt: -1 }).skip(20).limit(10)
}