var __a = [
db.setProfilingLevel(2)
// …carga la pantalla…
db.system.profile.find({ ns: /tiquetera/ }).count()
db.setProfilingLevel(0)
];