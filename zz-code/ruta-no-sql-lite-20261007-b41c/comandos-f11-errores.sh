# F11 §9: el mapping como esquema, sus dos errores (desde src/)
curl -s -X POST 'localhost:19200/part_catalog/_doc/PRUEBA-1' -H 'content-type: application/json' -d '{"partNumber":"PRUEBA-1","descripcion":"junta torica"}'; echo
curl -s -X PUT 'localhost:19200/part_catalog/_mapping' -H 'content-type: application/json' -d '{"properties":{"ataChapter":{"type":"keyword"}}}'; echo
