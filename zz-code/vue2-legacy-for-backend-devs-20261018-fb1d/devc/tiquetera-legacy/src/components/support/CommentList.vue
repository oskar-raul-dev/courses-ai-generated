<template>
  <div>
    <div v-if="comments.length === 0" class="text-muted small py-2">
      Sin comentarios todavía. Sé el primero. 🎤
    </div>
    <div v-for="c in comments" :key="c.id" class="border-bottom py-2">
      <div class="d-flex justify-content-between">
        <strong class="small">{{ c.author }}</strong>
        <span class="text-muted small">{{ c.createdAt | formatDate }}</span>
      </div>
      <div class="small" style="white-space: pre-line;">{{ c.body }}</div>
    </div>
  </div>
</template>

<script>
export default {
  name: "CommentList",
  props: {
    comments: { type: Array, required: true }
  }
};
</script>
