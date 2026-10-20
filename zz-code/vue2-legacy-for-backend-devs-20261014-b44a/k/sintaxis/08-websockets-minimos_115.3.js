var __a = [
watch: {
  isAuthenticated: {
    immediate: true, // evalúa YA al montar, no solo en futuros cambios
    handler: function (isAuth) {
      if (isAuth) socketService.connect();
      else socketService.disconnect();
    }
  }
}
];