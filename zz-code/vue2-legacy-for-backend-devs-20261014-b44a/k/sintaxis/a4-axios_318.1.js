function __f(){
// responseType: "blob" → el binario llega como Blob, no como texto corrompido
apiClient.get("/attachments/" + id + "/download", { responseType: "blob" })
  .then(function (res) {
    var url = window.URL.createObjectURL(res.data);
    var link = document.createElement("a");
    link.href = url;
    link.download = "adjunto.pdf";
    link.click();
    window.URL.revokeObjectURL(url); // liberar: si no, el Blob vive en memoria
  });
}