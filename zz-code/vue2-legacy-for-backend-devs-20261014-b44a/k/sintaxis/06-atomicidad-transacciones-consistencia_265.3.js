var __a = [
await col.updateOne(filtro, cambio, { writeConcern: { w: "majority", j: true } });
];