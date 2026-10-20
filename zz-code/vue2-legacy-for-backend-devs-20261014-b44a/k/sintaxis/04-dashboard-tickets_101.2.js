var __o = {
// main.js — filtro global
Vue.filter("formatDate", function (value) {
  if (!value) return "";
  var d = new Date(value);
  return d.toLocaleDateString("es-CO", {
    year: "numeric", month: "short", day: "numeric"
  });
});
};