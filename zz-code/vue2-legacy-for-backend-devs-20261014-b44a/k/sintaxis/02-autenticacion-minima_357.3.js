var __a = [


// baseURL apunta a json-server (llega oficialmente en la Fase 3).
// El Stubby de la Fase 0 (puerto 8888) queda retirado desde aquí.
var apiClient = axios.create({
  baseURL: "http://localhost:3000"
});

apiClient.interceptors.request.use(function (config) {
  var token = localStorage.getItem("token");
  if (token) {
    config.headers.Authorization = "Bearer " + token;
  }
  return config;
});
module.exports = apiClient;
];