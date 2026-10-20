function __f(){
socket.on("ticket:updated", function (t) { console.log("socket:", t); });
}