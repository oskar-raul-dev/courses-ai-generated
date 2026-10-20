import Vue from "vue";
import Router from "vue-router";
import HomeView from "../views/HomeView.vue";
import TicketsView from "../views/TicketsView.vue";
import TicketDetailView from "../views/TicketDetailView.vue";
import NotFoundView from "../views/NotFoundView.vue";

Vue.use(Router);

export default new Router({
  mode: "history",
  routes: [
    { path: "/", name: "home", component: HomeView },
    { path: "/tickets", name: "tickets", component: TicketsView },
    { path: "/tickets/:id", name: "ticket-detail", component: TicketDetailView },
    { path: "*", name: "not-found", component: NotFoundView }
  ]
});
