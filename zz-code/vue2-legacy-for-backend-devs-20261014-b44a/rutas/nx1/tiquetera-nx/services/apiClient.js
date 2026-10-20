import axios from "axios";

// baseURL apunta a json-server (llega oficialmente en la Fase 3).
var apiClient = axios.create({
  baseURL: "http://localhost:3000"
});

// El interceptor de F2 se fue a plugins/axios-auth.js (NX2): aquí leía localStorage,
// y en Nuxt este archivo también corre en el servidor.

export default apiClient;
