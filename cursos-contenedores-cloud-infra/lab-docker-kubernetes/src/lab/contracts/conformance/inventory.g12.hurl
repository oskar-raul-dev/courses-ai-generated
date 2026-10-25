# Suite de conformidad · inventory y replenish · paso G12 (Fase 25)
# Con un bus encendido (task bus:on -- valkey|nats), el aviso de la venta es un evento: la orden de
# replenish llega con el eventId que la originó. Sin bus no aplica: el aviso sigue siendo un POST, y la
# orden llega sin sourceEventId. Usa DRO-025, que nadie más toca.

PUT {{pricing}}/prices/SKU-0002
{"store": "DRO-025", "price": 15000}
HTTP 200

POST {{inventory}}/stock/DRO-025/SKU-0002/movements
{"type": "COUNT", "quantity": 10, "reference": "conteo-suite-g12"}
HTTP 201

PATCH {{inventory}}/stock/DRO-025/SKU-0002
Content-Type: application/merge-patch+json
{"reorderThreshold": 9}
HTTP 200

# Una orden pedida a mano, sin evento: la de la venta queda después de ella. Así el filtro de abajo
# siempre encuentra dos o más (con una sola, Hurl devuelve el valor suelto y `last` falla), y la
# diferencia queda a la vista: esta llega sin sourceEventId.
POST {{replenish}}/replenishment-orders
{"sku": "SKU-0002", "destinationStore": "DRO-025", "quantity": 1}
HTTP 201
[Asserts]
jsonpath "$.sourceEventId" == null

POST {{inventory}}/sales
{"store": "DRO-025", "sku": "SKU-0002", "quantity": 2}
HTTP 201
[Asserts]
jsonpath "$.replenishmentRequested" == true

# La orden más reciente de DRO-025, creada por el evento y no por una petición.
GET {{replenish}}/replenishment-orders
[Options]
retry: 10
retry-interval: 500
HTTP 200
[Asserts]
jsonpath "$[?(@.destinationStore == 'DRO-025')].sourceEventId" last isString
