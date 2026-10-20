var __o = {
var CancelToken = axios.CancelToken;
var cancel;

apiClient.get("/tickets", {
  cancelToken: new CancelToken(function (c) { cancel = c; })
});

// al disparar una búsqueda nueva:
if (cancel) cancel("obsoleto");

// y en el catch, distinguir cancelación de error real:
if (axios.isCancel(error)) return; // silencio: fue a propósito
};