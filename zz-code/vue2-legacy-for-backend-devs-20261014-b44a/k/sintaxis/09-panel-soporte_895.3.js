var __a = [
// extensión del guard existente (después del chequeo de token):
var requiredRoles = to.matched.reduce(function (acc, record) {
  return record.meta.roles ? acc.concat(record.meta.roles) : acc;
}, []);

if (requiredRoles.length > 0) {
  var user = JSON.parse(localStorage.getItem("user") || "null");
  var role = user && user.role;
  if (requiredRoles.indexOf(role) === -1) {
    next("/"); // sin drama: a Home (ForbiddenView con mensaje = ejercicio 5)
    return;
  }
}
];