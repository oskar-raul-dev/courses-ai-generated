import Vue from "vue";
import Router from "vue-router";
import LoginView from "../views/LoginView.vue";
import HomeView from "../views/HomeView.vue";
import TicketsView from "../views/TicketsView.vue";
import TicketDetailView from "../views/TicketDetailView.vue";
import NotFoundView from "../views/NotFoundView.vue";
import TicketCreateView from "../views/TicketCreateView.vue";
import TicketEditView from "../views/TicketEditView.vue";
import TicketWizardView from "../views/TicketWizardView.vue";
import MetricsView from "../views/MetricsView.vue";
import SupportView from "../views/SupportView.vue";

Vue.use(Router);

var router = new Router({
  mode: "history",
  routes: [
    { path: "/login", name: "login", component: LoginView },
    { path: "/", name: "home", component: HomeView, meta: { requiresAuth: true } },
    { path: "/tickets", name: "tickets", component: TicketsView, meta: { requiresAuth: true } },
    { path: "/tickets/wizard", name: "ticket-wizard", component: TicketWizardView, meta: { requiresAuth: true } },
    { path: "/tickets/new", name: "ticket-create", component: TicketCreateView, meta: { requiresAuth: true } },
    { path: "/tickets/:id", name: "ticket-detail", component: TicketDetailView, meta: { requiresAuth: true } },
    { path: "/tickets/:id/edit", name: "ticket-edit", component: TicketEditView, meta: { requiresAuth: true } },
    { path: "/metrics", name: "metrics", component: MetricsView, meta: { requiresAuth: true } },
    {
      path: "/support",
      name: "support",
      component: SupportView,
      meta: { requiresAuth: true, roles: ["agent"] }
    },
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
});

export default router;
