var __o = {
// Patrón bucket (para el caso hipotético de auditoría total)
{
  ticketId: ObjectId("..."),
  bucket: 3,                    // tercer cubo de este ticket
  count: 47,                    // eventos en el cubo (se cierra en 100)
  events: [ { at: ISODate(...), user: "lmcano", type: "field_edit", ... } ]
}
};