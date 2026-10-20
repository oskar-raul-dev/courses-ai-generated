// El filtro global de main.js (F3). En Vue 3 esto ya no existe.
import Vue from 'vue'

Vue.filter('formatDate', function (value) {
  if (!value) return ''
  var d = new Date(value)
  return d.toLocaleDateString('es-CO', {
    year: 'numeric', month: 'short', day: 'numeric'
  })
})
