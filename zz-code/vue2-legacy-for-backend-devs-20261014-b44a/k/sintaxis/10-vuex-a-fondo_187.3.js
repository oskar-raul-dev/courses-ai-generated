var __a = [
function myPlugin(store) {
  // corre UNA vez al crear el store
  store.subscribe(function (mutation, state) {
    // espía cada mutation (logging, persistencia...)
  });
  // o commitear por eventos externos (sockets 👀)
}
];