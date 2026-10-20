function __f(){
app.get("/boom", async function (req, res) { throw new Error("sin captura"); });
}