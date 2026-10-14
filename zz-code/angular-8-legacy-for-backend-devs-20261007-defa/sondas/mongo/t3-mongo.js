// T3 checks in mongo:4.0 (mongo shell). Loads the blocks extracted from bea-06 and bea-08.
db = db.getSiblingDB('t3');
print('mongod ' + db.version());

// --- bea-06: the $jsonSchema as written, applied with collMod, then used as a query to test the pattern
db.patients.drop();
db.createCollection('patients');
load('/s/bea06-collmod.js');
var schema = db.getCollectionInfos({ name: 'patients' })[0].options.validator;
db.patients.insertMany([
  { documentId: 'HC-1032456789' }, { documentId: 'PP-1122334455' }, { documentId: 'LB-123456' },
  { documentId: 'CC-1032456789' }, { documentId: 'hc-1032456789' }, { documentId: 'HC1032456789' }
]);
var okIds = db.patients.find(schema).map(function (p) { return p.documentId; });
var badIds = db.patients.find({ $nor: [schema] }).map(function (p) { return p.documentId; });
print('bea-06 acepta: ' + okIds.join(', '));
print('bea-06 rechaza: ' + badIds.join(', '));

// --- bea-12: the 4820 generated patients against the same schema
var gen = db.getSiblingDB('t3gen');
print('bea-12: ' + gen.patients.count() + ' importados, ' + gen.patients.find(schema).count() + ' cumplen el $jsonSchema de bea-06');

// --- bea-08: the aggregation as written, over evening entries in winter and summer
db.auditLog.drop();
db.auditLog.insertMany([
  { timestamp: ISODate('2022-01-08T23:30:00Z') },  // 18:30 Ottawa, Jan 8 (winter)
  { timestamp: ISODate('2022-01-09T00:30:00Z') },  // 19:30 Ottawa, Jan 8
  { timestamp: ISODate('2022-01-09T02:04:10.887Z') }, // 21:04 Ottawa, Jan 8 (incident 17)
  { timestamp: ISODate('2021-07-15T23:30:00Z') },  // 19:30 Ottawa, Jul 15 (summer)
  { timestamp: ISODate('2021-07-16T00:30:00Z') },  // 20:30 Ottawa, Jul 15
  { timestamp: ISODate('2021-07-16T04:30:00Z') }   // 00:30 Ottawa, Jul 16 (summer: -05:00 sends it to Jul 15)
]);
print('bea-08 con timezone America/Toronto (el bloque tal como está):');
load('/s/bea08-agg.js');
var res = db.auditLog.aggregate([
  { $group: { _id: { $dateToString: { format: '%Y-%m-%d', date: '$timestamp', timezone: 'America/Toronto' } }, asientos: { $sum: 1 } } },
  { $sort: { _id: 1 } }]).toArray();
printjson(res);
['UTC', '-05:00'].forEach(function (tz) {
  print('el mismo con timezone ' + tz + ':');
  printjson(db.auditLog.aggregate([
    { $group: { _id: { $dateToString: { format: '%Y-%m-%d', date: '$timestamp', timezone: tz } }, asientos: { $sum: 1 } } },
    { $sort: { _id: 1 } }]).toArray());
});
