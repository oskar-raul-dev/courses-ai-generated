function __f(){
{ $group: { _id: "status",  … } }    // el LITERAL de cuatro letras
{ $group: { _id: "$status", … } }    // el VALOR del campo
}