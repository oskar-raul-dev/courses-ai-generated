function __f(){
var step = this.$refs.stepComponent;   // instancia del componente hijo
if (step.validate && !step.validate()) return;
}