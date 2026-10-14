# Comandos de la sección OpenSearch de a03, tal como corrieron (desde src/)
curl -s 'localhost:19200/_cat/indices/part_catalog?v&h=index,docs.count,store.size'
curl -s -X PUT 'localhost:19200/part_catalog/_doc/99-000001-01?refresh=true' -H 'content-type: application/json' -d '{"partNumber":"99-000001-01","description":"junta tórica de prueba","category":"consumable","ataChapter":20}'; echo
curl -s 'localhost:19200/part_catalog/_count' -H 'content-type: application/json' -d '{"query":{"match":{"description":"prueba"}}}'; echo
curl -s -X DELETE 'localhost:19200/part_catalog/_doc/99-000001-01?refresh=true'; echo
curl -s 'localhost:19200/part_catalog/_search' -H 'content-type: application/json' -d '{"profile":true,"size":0,"query":{"match":{"description":{"query":"juntas toricas tren","operator":"and"}}}}' | python3 -c "import sys,json; p=json.load(sys.stdin)['profile']['shards'][0]['searches'][0]['query'][0]; print(p['type'], p['description'], [c['description'] for c in p.get('children',[])])"
