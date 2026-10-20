function __f(){
// AppHeader.vue


data: function () {
  return { live: false };
},
mounted: function () {
  var self = this;
  // sondeo barato del estado; los eventos connect/disconnect finos son el ej. 9
  this.liveTimer = setInterval(function () {
    self.live = socketService.isConnected();
  }, 2000);
},
beforeDestroy: function () {
  clearInterval(this.liveTimer);
}
}