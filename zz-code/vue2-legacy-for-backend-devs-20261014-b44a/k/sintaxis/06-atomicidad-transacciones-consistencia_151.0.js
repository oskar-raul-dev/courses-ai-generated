const result = await col.findOneAndUpdate(
  filtro,                          // puede incluir CONDICIONES (ahora viene lo bueno)
  cambio,
  { returnOriginal: false }        // devuélveme el documento YA modificado
);
// result.value === null  →  ningún documento cumplía el filtro