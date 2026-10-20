var __a = [







Vue.use(Router);
module.exports = new Router({
  mode: "history",
  routes: [
    { path: "/", name: "home", component: HomeView },
    { path: "/tickets", name: "tickets", component: TicketsView },
    { path: "/tickets/:id", name: "ticket-detail", component: TicketDetailView },
    { path: "*", name: "not-found", component: NotFoundView }
  ]
});
];