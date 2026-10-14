// $dateToString con timezone (desde MongoDB 3.6). Es la forma correcta de
// agrupar "por día en Ottawa": la conversión se hace en la agregación, no
// guardando hora local, y con el identificador IANA el horario de verano
// sale solo.
db.auditLog.aggregate([
  { $group: {
      _id: { $dateToString: { format: '%Y-%m-%d',
                              date: '$timestamp',
                              timezone: 'America/Toronto' } },
      asientos: { $sum: 1 }
  }},
  { $sort: { _id: 1 } }
]);
