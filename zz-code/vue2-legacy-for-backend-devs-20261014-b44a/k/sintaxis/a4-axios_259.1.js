function __f(){
// 3) En el componente:
data: function () {
  return { file: null, progress: 0, uploading: false, error: "" };
},
methods: {
  onFileSelected: function (event) {
    var files = event.target.files;
    this.file = files.length ? files[0] : null;  // FileList NO es un Array
  },
  submitUpload: function () {
    var self = this;
    if (!this.file) return;

    // validación en cliente: UX, no seguridad (el servidor debe revalidar)
    if (this.file.size > 5 * 1024 * 1024) {
      this.error = "El archivo supera los 5 MB.";
      return;
    }

    this.uploading = true;
    this.progress = 0;

    attachmentService
      .upload(this.ticketId, this.file, function (percent) {
        self.progress = percent;           // ← la barra de progreso, reactiva
      })
      .then(function (created) { self.$emit("uploaded", created); })
      .catch(function () { self.error = "No se pudo subir el archivo."; })
      .finally(function () { self.uploading = false; });
  }
}
}