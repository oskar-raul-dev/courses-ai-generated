function __f(){
db.users.createIndex({ username: 1 }, { unique: true })
// ⚠️ dos documentos SIN el campo violan el unique (null cuenta como valor).
// La salida de la época ↓
}