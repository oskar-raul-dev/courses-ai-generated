<template>
  <form @submit.prevent="submit">
    <div class="form-group mb-2">
      <textarea
        :value="value"
        rows="2"
        class="form-control"
        placeholder="Escribe un comentario..."
        @input="$emit('input', $event.target.value)"
      ></textarea>
    </div>
    <button class="btn btn-sm btn-primary" :disabled="!value.trim() || sending">
      {{ sending ? "Enviando..." : "💬 Comentar" }}
    </button>
  </form>
</template>

<script>
export default {
  name: "CommentBox",
  props: {
    value: { type: String, default: "" },   // ← mitad 1 del contrato v-model
    sending: { type: Boolean, default: false }
  },
  methods: {
    submit: function () {
      if (this.value.trim()) this.$emit("submit");
    }
  }
};
</script>
