// Registra Quasar para Jest, como lo hace quasar.conf.js en la app.
// Lo que una fase migra a componentes de Quasar se agrega aquí.
import Vue from 'vue'
import { Quasar } from 'quasar'

Vue.use(Quasar, { components: {} })
