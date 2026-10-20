function __f(){
await col.updateOne(filtro, cambio, { writeConcern: { w: "majority", j: true } });
}