<!-- components/metrics/ScoreBoard.vue -->
<template>
  <div class="card">
    <div class="card-body">
      <h6 class="card-title text-muted">🕹️ Tabla de puntajes</h6>
      <table class="table table-sm mb-0">
        <thead>
          <tr>
            <th>#</th>
            <th>Agente</th>
            <th class="text-right">Resueltos</th>
            <th class="text-right">Puntos</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, index) in rows" :key="row.initials">
            <td>{{ index + 1 }}</td>
            <td class="text-monospace">{{ row.initials }}</td>
            <td class="text-right">{{ row.solved }}</td>
            <td class="text-right font-weight-bold">{{ row.points }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: "ScoreBoard",
  props: {
    rows: { type: Array, required: true }
  }
};
</script>
