// 💸 Deuda declarada: esto se aterriza en la Fase 2 (interceptor)
// y se conecta a json-server en la Fase 3.
import axios from "axios";

var apiClient = axios.create({
  baseURL: "http://localhost:3000"
});

export default apiClient;
