import LoginView from '../views/LoginView.vue'
import HomeView from '../views/HomeView.vue'
import TicketsView from '../views/TicketsView.vue'
import TicketDetailView from '../views/TicketDetailView.vue'
import NotFoundView from '../views/NotFoundView.vue'
import TicketCreateView from '../views/TicketCreateView.vue'
import TicketEditView from '../views/TicketEditView.vue'
import TicketWizardView from '../views/TicketWizardView.vue'
import MetricsView from '../views/MetricsView.vue'
import SupportView from '../views/SupportView.vue'

// Las rutas de F1, con el layout de Q1 como padre. El login queda fuera: sin navbar.
const routes = [
  { path: '/login', name: 'login', component: LoginView },
  {
    path: '/',
    component: () => import('layouts/MainLayout.vue'),
    children: [
      { path: '', name: 'home', component: HomeView, meta: { requiresAuth: true } },
      { path: 'tickets', name: 'tickets', component: TicketsView, meta: { requiresAuth: true } },
      { path: 'tickets/wizard', name: 'ticket-wizard', component: TicketWizardView, meta: { requiresAuth: true } },
      { path: 'tickets/new', name: 'ticket-create', component: TicketCreateView, meta: { requiresAuth: true } },
      { path: 'tickets/:id', name: 'ticket-detail', component: TicketDetailView, meta: { requiresAuth: true } },
      { path: 'tickets/:id/edit', name: 'ticket-edit', component: TicketEditView, meta: { requiresAuth: true } },
      { path: 'metrics', name: 'metrics', component: MetricsView, meta: { requiresAuth: true } },
      { path: 'support', name: 'support', component: SupportView, meta: { requiresAuth: true, roles: ['agent'] } }
    ]
  },
  { path: '*', name: 'not-found', component: NotFoundView }
]

export default routes
