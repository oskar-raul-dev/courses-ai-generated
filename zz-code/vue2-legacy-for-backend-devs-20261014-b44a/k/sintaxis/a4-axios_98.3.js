var __a = [
.catch(function (error) {
  if (error.response) {
    // 1) EL SERVIDOR RESPONDIÓ con 4xx/5xx
    error.response.status   // 404, 401, 422, 500...
    error.response.data     // el body del error (mensajes del backend)
  } else if (error.request) {
    // 2) EL REQUEST SALIÓ pero NADIE respondió
    //    servidor caído, red muerta, CORS bloqueó la respuesta, timeout
  } else {
    // 3) NI SIQUIERA SALIÓ: error armando el request (config inválida)
    error.message
  }
});
];