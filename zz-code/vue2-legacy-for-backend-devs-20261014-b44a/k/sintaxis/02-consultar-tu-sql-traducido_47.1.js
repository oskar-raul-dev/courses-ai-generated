function __f(){
db.tickets.find(
  { status: "open", priority: "high" },   // 1.º filtro (el WHERE)
  { title: 1, createdAt: 1 }              // 2.º proyección (la lista del SELECT)
)
}