function __f(){
// eventBus.js
module.exports = new Vue(); // una instancia Vue vacía usada solo como bus

// emisor:               bus.$emit("algo", payload);
// receptor (mounted):   bus.$on("algo", this.handler);
// receptor (beforeDestroy): bus.$off("algo", this.handler);
}