router.beforeEach(function (to, from, next) {
  var token = localStorage.getItem("token");
  // …
  if (requiresAuth && !token) {
    next("/login");
    return;
  }