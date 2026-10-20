// src/router/authGuard.js — el guard de F2 (con los roles de F9), en un módulo propio para poder probarlo
export function authGuard(to, from, next) {
  var token = localStorage.getItem("token");
  var requiresAuth = to.matched.some(function (record) {
    return record.meta.requiresAuth;
  });

  if (requiresAuth && !token) {
    next("/login");
    return;
  }

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

  if (to.path === "/login" && token) {
    next("/");
    return;
  }

  next();
}
