var __a = [
handleSubmit: function () {
  this.$v.$touch();
  if (this.$v.$invalid) {
    return; // los errores ya se pintan solos vía $error
  }
  this.$emit("submit", Object.assign({}, this.form));
}
];