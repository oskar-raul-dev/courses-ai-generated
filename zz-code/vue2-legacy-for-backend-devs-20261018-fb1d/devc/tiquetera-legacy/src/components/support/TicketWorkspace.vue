<template>
  <div class="card">
    <div class="card-body">
      <div class="d-flex justify-content-between align-items-start">
        <div>
          <h5 class="mb-1">#{{ ticket.id }} — {{ ticket.title }}</h5>
          <ticket-status-badge :status="ticket.status" class="mr-1" />
          <ticket-priority-badge :priority="ticket.priority" />
        </div>
        <router-link
          :to="'/tickets/' + ticket.id + '/edit'"
          class="btn btn-sm btn-outline-secondary"
        >
          ✏️ Editar
        </router-link>
      </div>

      <p class="mt-3" style="white-space: pre-line;">{{ ticket.description }}</p>

      <p class="small text-muted mb-1">
        Reportado por <strong>{{ ticket.reporter }}</strong> ·
        {{ ticket.createdAt | formatDate }} ·
        Asignado a <strong>{{ ticket.assignee || "nadie" }}</strong>
      </p>

      <div v-if="error" class="alert alert-danger py-2 my-2">{{ error }}</div>

      <div class="my-3">
        <button
          v-if="!ticket.assignee"
          class="btn btn-sm btn-primary mr-2"
          :disabled="busy"
          @click="takeTicket"
        >
          🙋 Tomar
        </button>
        <status-actions :status="ticket.status" :busy="busy" @change="changeStatus" />
      </div>

      <hr />

      <h6 class="text-muted">Comentarios</h6>
      <div v-if="loadingComments" class="spinner-border spinner-border-sm text-primary"></div>
      <comment-list v-else :comments="comments" />

      <div class="mt-3">
        <comment-box v-model="newComment" :sending="sendingComment" @submit="addComment" />
      </div>
    </div>
  </div>
</template>

<script>
import TicketStatusBadge from "../tickets/TicketStatusBadge.vue";
import TicketPriorityBadge from "../tickets/TicketPriorityBadge.vue";
import StatusActions from "./StatusActions.vue";
import CommentList from "./CommentList.vue";
import CommentBox from "./CommentBox.vue";
import ticketService from "../../services/ticketService";
import commentService from "../../services/commentService";

export default {
  name: "TicketWorkspace",
  components: { TicketStatusBadge, TicketPriorityBadge, StatusActions, CommentList, CommentBox },
  props: {
    ticket: { type: Object, required: true }
  },
  data: function () {
    return {
      comments: [],
      newComment: "",
      loadingComments: false,
      sendingComment: false,
      busy: false,
      error: ""
    };
  },
  mounted: function () {
    // Corre por CADA ticket seleccionado: el :key del padre nos recrea. 🔑
    this.loadComments();
  },
  methods: {
    loadComments: function () {
      var self = this;
      this.loadingComments = true;

      commentService
        .getByTicket(this.ticket.id)
        .then(function (comments) { self.comments = comments; })
        .catch(function () { self.error = "No se pudieron cargar los comentarios."; })
        .finally(function () { self.loadingComments = false; });
    },
    takeTicket: function () {
      var me = this.$store.getters["auth/currentUser"].username;
      this.patchTicket({ assignee: me, status: "in_progress" });
    },
    changeStatus: function (newStatus) {
      this.patchTicket({ status: newStatus });
    },
    patchTicket: function (changes) {
      var self = this;
      this.busy = true;
      this.error = "";

      ticketService
        .updateTicket(this.ticket.id, changes)
        .then(function (updated) {
          self.$emit("updated", updated); // el padre actualiza la lista maestra
        })
        .catch(function () {
          self.error = "No se pudo actualizar el ticket.";
        })
        .finally(function () {
          self.busy = false;
        });
    },
    addComment: function () {
      var self = this;
      var user = this.$store.getters["auth/currentUser"];
      this.sendingComment = true;

      commentService
        .create({
          ticketId: this.ticket.id,
          author: user.username,
          body: this.newComment.trim(),
          createdAt: new Date().toISOString()
        })
        .then(function (created) {
          self.comments.push(created); // push: método parcheado, reactivo (F8)
          self.newComment = "";        // v-model: limpia el textarea del hijo
        })
        .catch(function () {
          self.error = "No se pudo enviar el comentario.";
        })
        .finally(function () {
          self.sendingComment = false;
        });
    }
  }
};
</script>
