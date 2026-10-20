function __f(){
module.exports = {
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

}