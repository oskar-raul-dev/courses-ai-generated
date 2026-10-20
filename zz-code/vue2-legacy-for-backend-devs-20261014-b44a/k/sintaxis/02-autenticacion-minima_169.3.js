var __a = [








Vue.use(Router);

var router = new Router({
  mode: "history",
  routes: [
    { path: "/login", name: "login", component: LoginView },
    { path: "/", name: "home", component: HomeView, meta: { requiresAuth: true } },
    { path: "/tickets", name: "tickets", component: TicketsView, meta: { requiresAuth: true } },
    { path: "/tickets/:id", name: "ticket-detail", component: TicketDetailView, meta: { requiresAuth: true } },
    { path: "*", name: "not-found", component: NotFoundView }
  ]
});

router.beforeEach(function (to, from, next) {
  var token = localStorage.getItem("token");
  var requiresAuth = to.matched.some(function (record) {
    return record.meta.requiresAuth;
  });

  if (requiresAuth && !token) {
    next("/login");
    return;
  }

  if (to.path === "/login" && token) {
    next("/");
    return;
  }

  next();
});
module.exports = router;
];