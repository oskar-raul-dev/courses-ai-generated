<template>
  <q-page padding>
    <div class="row items-center q-mb-md">
      <div class="col">
        <h5 class="q-my-none">Tickets</h5>
      </div>
      <div class="col-auto">
        <q-btn color="primary" icon="add" label="Nuevo ticket" @click="openModal(null)" />
      </div>
    </div>

    <!-- El error de carga de F3/F10, con su reintento: no es de la tabla, es de la vista. -->
    <q-banner v-if="error" class="bg-negative text-white q-mb-md" data-testid="tickets-error">
      {{ error }}
      <template v-slot:action>
        <q-btn flat label="Reintentar" data-testid="tickets-retry" @click="fetchTickets()" />
      </template>
    </q-banner>

    <!-- Las tarjetas resumen de F4: se quedan. Grid de Quasar. -->
    <div class="row q-col-gutter-md q-mb-md">
      <div class="col-6 col-md-3" v-for="card in summaryCards" :key="card.status">
        <q-card flat bordered>
          <q-card-section>
            <div class="text-h4">{{ card.count }}</div>
            <div class="text-caption text-grey">{{ card.label }}</div>
          </q-card-section>
        </q-card>
      </div>
    </div>

    <p class="text-grey-7 q-mb-sm" data-testid="tickets-count">
      Mostrando {{ filteredCount }} de {{ allTickets.length }} tickets
    </p>

    <q-table
      :data="allTickets"
      :columns="columns"
      row-key="id"
      :loading="loading"
      :filter="filter"
      :filter-method="filterTickets"
      :rows-per-page-options="[10, 25, 50]"
      flat
      bordered
      @row-click="goToDetail"
    >
      <template v-slot:top-right>
        <q-input dense v-model="filter.search" placeholder="Buscar…" data-testid="tickets-search">
          <template v-slot:append><q-icon name="search" /></template>
        </q-input>
        <q-select
          dense
          v-model="filter.status"
          :options="statusOptions"
          emit-value
          map-options
          clearable
          label="Estado"
          style="min-width: 150px"
          class="q-ml-sm"
          data-testid="tickets-status-filter"
        />
        <q-btn flat label="Limpiar filtros" class="q-ml-sm" data-testid="tickets-clear-filters" @click="clearFilters" />
      </template>

      <!-- Las anclas de Q0 viajan en las celdas: una por fila, y el título aparte. -->
      <template v-slot:body-cell-id="props">
        <q-td :props="props" :data-testid="'ticket-row-' + props.row.id">{{ props.value }}</q-td>
      </template>

      <template v-slot:body-cell-title="props">
        <q-td :props="props" :data-testid="'ticket-title-' + props.row.id">{{ props.value }}</q-td>
      </template>

      <template v-slot:body-cell-status="props">
        <q-td :props="props">
          <ticket-status-badge :status="props.row.status" />
        </q-td>
      </template>

      <template v-slot:body-cell-priority="props">
        <q-td :props="props">
          <ticket-priority-badge :priority="props.row.priority" />
        </q-td>
      </template>

      <template v-slot:body-cell-actions="props">
        <q-td :props="props">
          <q-btn flat dense round icon="edit" @click.stop="openModal(props.row)" />
        </q-td>
      </template>

      <template v-slot:loading>
        <q-linear-progress indeterminate color="primary" data-testid="tickets-loading" />
      </template>

      <!-- El "no hay resultados" de F4. Slot no-data. -->
      <template v-slot:no-data>
        <div class="full-width row flex-center q-pa-md text-grey" data-testid="tickets-empty">
          🔍 No hay tickets que coincidan con los filtros.
        </div>
      </template>
    </q-table>

    <!-- 🅱️ BOOTSTRAP 4 crudo (jQuery). Aquí. Al lado. Funcionando. -->
    <div class="modal fade" id="ticket-modal" tabindex="-1">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">{{ modalTitle }}</h5>
            <button type="button" class="close" @click="closeModal">&times;</button>
          </div>
          <div class="modal-body">
            <ticket-form
              v-if="modalOpen"
              :key="selected ? selected.id : 'nuevo'"
              :initial-ticket="selected"
              :saving="saving"
              @submit="onSaved"
              @cancel="closeModal"
            />
          </div>
        </div>
      </div>
    </div>
  </q-page>
</template>

<script>
import $ from "jquery";
import { mapGetters, mapState, mapActions } from "vuex";
import TicketStatusBadge from "../components/tickets/TicketStatusBadge.vue";
import TicketPriorityBadge from "../components/tickets/TicketPriorityBadge.vue";
import TicketForm from "../components/tickets/TicketForm.vue";
import ticketService from "../services/ticketService";
import socketService from "../services/socketService";

const COLUMNS = [
  { name: "id",        label: "#",         field: "id",        align: "left",   sortable: true },
  { name: "title",     label: "Título",    field: "title",     align: "left",   sortable: true },
  { name: "status",    label: "Estado",    field: "status",    align: "center", sortable: true },
  { name: "priority",  label: "Prioridad", field: "priority",  align: "center", sortable: true },
  {
    name: "assignee",
    label: "Asignado",
    field: function (row) { return row.assignee || "—"; },
    align: "left",
    sortable: true
  },
  {
    name: "createdAt",
    label: "Creado",
    field: "createdAt",
    align: "right",
    sortable: true,
    format: function (val) { return new Date(val).toLocaleDateString("es-CO"); }
  },
  { name: "actions", label: "", field: "id", align: "right", sortable: false }
];

const STATUS_OPTIONS = [
  { label: "Abierto",     value: "open" },
  { label: "En progreso", value: "in_progress" },
  { label: "Resuelto",    value: "resolved" },
  { label: "Cerrado",     value: "closed" }
];

export default {
  name: "TicketsView",

  components: {
    TicketStatusBadge: TicketStatusBadge,
    TicketPriorityBadge: TicketPriorityBadge,
    TicketForm: TicketForm
  },

  data: function () {
    return {
      columns: COLUMNS,
      statusOptions: STATUS_OPTIONS,
      filter: { search: "", status: null },
      selected: null,
      modalOpen: false,
      saving: false
    };
  },

  computed: Object.assign(
    {},
    mapGetters("tickets", ["allTickets"]),
    mapState("tickets", ["loading", "error"]),
    {
      modalTitle: function () {
        return this.selected ? "Editar ticket #" + this.selected.id : "Nuevo ticket";
      },
      // el contador de F4 reusa el mismo filterTickets que usa la tabla: una sola regla
      filteredCount: function () {
        return this.filterTickets(this.allTickets, this.filter).length;
      },
      summaryCards: function () {
        var items = this.allTickets;
        return STATUS_OPTIONS.map(function (opt) {
          return {
            status: opt.value,
            label: opt.label,
            count: items.filter(function (t) { return t.status === opt.value; }).length
          };
        });
      }
    }
  ),

  mounted: function () {
    this.fetchTickets(); // el caché de la action decide si hay red o no
  },

  methods: Object.assign(
    {},
    mapActions("tickets", ["fetchTickets"]),
    {
      filterTickets: function (rows, terms) {
        var term = (terms.search || "").trim().toLowerCase();
        var status = terms.status;
        return rows.filter(function (t) {
          var matchesText = !term || t.title.toLowerCase().indexOf(term) !== -1;
          var matchesStatus = !status || t.status === status;
          return matchesText && matchesStatus;
        });
      },

      clearFilters: function () {
        this.filter = { search: "", status: null };
      },

      goToDetail: function (evt, row) {
        this.$router.push("/tickets/" + row.id);
      },

      openModal: function (ticket) {
        this.selected = ticket;
        this.modalOpen = true;
        $("#ticket-modal").modal("show"); // 🅱️ Bootstrap 4 + jQuery
      },

      closeModal: function () {
        $("#ticket-modal").modal("hide");
        this.modalOpen = false;
        this.selected = null;
      },

      onSaved: function (formData) {
        var self = this;
        var ticket = this.selected;
        this.saving = true;

        // Lo mismo que hacían TicketCreateView y TicketEditView de F5:
        // crear completa los campos que pone la vista; editar va por la action de F10.
        var request = ticket
          ? this.$store.dispatch("tickets/updateTicket", { id: ticket.id, changes: formData })
          : ticketService.createTicket(Object.assign({}, formData, {
            status: "open",
            reporter: this.$store.getters["auth/currentUser"].username,
            createdAt: new Date().toISOString()
          })).then(function (created) {
            self.$store.commit("tickets/UPSERT_TICKET", created);
            socketService.emit("ticket:created", created); // 📣 anunciar a los demás, como en F8
            return created;
          });

        return request
          .then(function (saved) {
            self.closeModal();
            self.$q.notify({ type: "positive", message: "Ticket #" + saved.id + " guardado" });
          })
          .catch(function () {
            self.$q.notify({ type: "negative", message: "No se pudo guardar el ticket." });
          })
          .finally(function () {
            self.saving = false;
          });
      }
    }
  )
};
</script>
