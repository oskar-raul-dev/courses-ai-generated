import Vue from 'vue'
import Vuex from 'vuex'
import auth from './modules/auth'
import tickets from './modules/tickets'
import ui from './modules/ui'
import socketPlugin from './plugins/socketPlugin'

Vue.use(Vuex)

// Quasar espera una fábrica, no una instancia: los módulos de F10 entran tal cual
export default function (/* { ssrContext } */) {
  return new Vuex.Store({
    modules: { auth: auth, tickets: tickets, ui: ui },
    plugins: [socketPlugin],
    strict: process.env.DEV
  })
}
