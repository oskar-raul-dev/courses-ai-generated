import Vue from "vue";
import Router from "vue-router";
import store from "../store";
import LoginView from "../views/LoginView.vue";
import HomeView from "../views/HomeView.vue";
import TicketsView from "../views/TicketsView.vue";
import TicketDetailView from "../views/TicketDetailView.vue";
import NotFoundView from "../views/NotFoundView.vue";

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

// exportado con nombre para poder probarlo (paso previo al fix, sin cambiar su lógica)
export function authGuard(to, from, next) {
  var token = localStorage.getItem("token");
  var requiresAuth = to.matched.some(function (record) {
    return record.meta.requiresAuth;
  });

  if (requiresAuth && !token) {
    // Antes de expulsar, deja el sistema coherente y di por qué te vas.
    store.commit("auth/CLEAR_SESSION");
    next({ path: "/login", query: { reason: "session-expired" } });
    return;
  }

  if (to.path === "/login" && token) {
    next("/");
    return;
  }

  next();
}

router.beforeEach(authGuard);

export default router;
