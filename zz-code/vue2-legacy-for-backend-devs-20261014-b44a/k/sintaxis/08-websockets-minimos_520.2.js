var __o = {
.then(function (created) {
  socketService.emit("ticket:created", created); // 📣 anunciar a los demás
  self.$router.push("/tickets/" + created.id);
})
};