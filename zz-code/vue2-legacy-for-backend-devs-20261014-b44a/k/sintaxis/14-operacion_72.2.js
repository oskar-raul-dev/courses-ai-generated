var __o = {
// Míralo con tus ojos (mongosh):
use local
db.oplog.rs.find().sort({ $natural: -1 }).limit(3)   // tus últimas escrituras
db.oplog.rs.stats().maxSize                           // es capped: se recicla
};