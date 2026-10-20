var __o = {
// REQUEST: se ejecuta ANTES de salir cada request (F2: el token)
apiClient.interceptors.request.use(function (config) {
  var token = localStorage.getItem("token");
  if (token) config.headers.Authorization = "Bearer " + token;
  return config;   // ⚠️ SIEMPRE devolver config — olvidarlo mata el request
});

// RESPONSE: se ejecuta al volver — dos manejadores: éxito y error
apiClient.interceptors.response.use(
  function (response) { return response; },       // pasa de largo
  function (error) {
    if (error.response && error.response.status === 401) {
      // limpiar sesión + redirigir (F2 ej. 23 / F3 ej. 24)
    }
    return Promise.reject(error);  // ⚠️ re-rechazar: si no, los .catch de
  }                                //    los servicios ven un ÉXITO undefined 💀
);
};