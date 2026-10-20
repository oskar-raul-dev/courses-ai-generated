// plugins/filters.js — el filtro global que en F4 vivía en main.js
import Vue from "vue";

Vue.filter("formatDate", function (value) {
  if (!value) return "";
  var d = new Date(value);
  return d.toLocaleDateString("es-CO", {
    year: "numeric", month: "short", day: "numeric"
  });
});
