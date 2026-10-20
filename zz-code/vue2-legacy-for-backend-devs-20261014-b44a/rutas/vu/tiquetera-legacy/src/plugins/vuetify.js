// src/plugins/vuetify.js
import Vue from "vue";
import Vuetify from "vuetify";
import "vuetify/dist/vuetify.min.css"; // 🔎 full import: TODO el CSS de Vuetify (~la deuda 💸)
// 🔎 la fuente de iconos MDI llega por CDN, en public/index.html. Solo si contestaste «sí» a
//    «fonts as a dependency», aquí va: import "@mdi/font/css/materialdesignicons.css";

import es from "vuetify/es5/locale/es"; // 🔎 los textos propios de Vuetify, en español

Vue.use(Vuetify); // 🔎 registra Vuetify como plugin de Vue (el mismo Vue.use de siempre)

export default new Vuetify({
  lang: {
    locales: { es: es },
    current: "es" // 🔎 sin esto, el pie de la tabla dice «Rows per page» en una app en español
  },
  icons: {
    iconfont: "mdi" // 🔎 le decimos que use Material Design Icons
  },
  theme: {
    themes: {
      light: {
        primary: "#1976D2",   // 🔎 ESTOS colores son el tema. No están en ningún .scss
        secondary: "#424242",
        accent: "#82B1FF",
        error: "#FF5252",
        info: "#2196F3",
        success: "#4CAF50",
        warning: "#FB8C00"
      }
    }
  }
});
