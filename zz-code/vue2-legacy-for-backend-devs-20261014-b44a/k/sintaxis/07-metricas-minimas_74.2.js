var __o = {
// chart.js: órdenes, paso a paso
var chart = new Chart(canvasElement, config); // créate
chart.data.datasets[0].data = [5, 3, 2];      // cámbiate
chart.update();                                // repíntate
chart.destroy();                               // muérete
};