var __a = [
// ❌ El bug clásico del legacy que pasó de mock a backend real
try {
  this.$store.dispatch("auth/login", this.form); // devuelve una Promise
  this.$router.push("/"); // 💥 se ejecuta SIEMPRE, antes de saber si el login funcionó
} catch (error) {
  // 💀 nunca entra aquí: el reject ocurre después, fuera del try.
  // Resultado: "Unhandled promise rejection" en consola y un usuario
  // "logueado" que rebota en el guard sin mensaje de error.
  this.error = error.message;
}

// ✅ La Promise lleva su propio canal de error
this.$store.dispatch("auth/login", this.form)
  .then(function () { /* éxito: recién AHORA sabemos que entró */ })
  .catch(function (error) { /* el reject cae aquí, garantizado */ });
];