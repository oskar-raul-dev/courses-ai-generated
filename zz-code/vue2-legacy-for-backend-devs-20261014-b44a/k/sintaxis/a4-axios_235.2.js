var __o = {
// 2) En el servicio (services/attachmentService.js):


function upload(ticketId, file, onProgress) {
  var formData = new FormData();          // el sobre multipart
  formData.append("ticketId", ticketId);  // campos de texto: igual que un form
  formData.append("file", file);          // el File del input: axios detecta el binario

  return apiClient
    .post("/attachments", formData, {
      // ⚠️ NO pongas Content-Type a mano. Ver la trampa del boundary abajo.
      onUploadProgress: function (event) {
        if (event.lengthComputable && onProgress) {
          onProgress(Math.round((event.loaded / event.total) * 100));
        }
      }
    })
    .then(function (res) { return res.data; });
}
module.exports = { upload: upload };
};