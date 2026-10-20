// scripts/reconcile-assignee-names.js — el fsck de tus copias
// por cada user: countDocuments({assignee: u.username, assigneeName: {$ne: u.name}})
// si > 0: updateMany + log. Idempotente, medible, aburrido. Perfecto.