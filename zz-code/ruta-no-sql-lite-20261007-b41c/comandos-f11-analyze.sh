# F11 §6.2 y §6.4: lo que hace cada analizador con un texto (desde src/, perfil busqueda arriba)
for t in "Junta tórica del tren" "juntas toricas tren" "oring del tren"; do
  curl -s localhost:19200/part_catalog/_analyze -H 'content-type: application/json' -d "{\"analyzer\":\"description_es\",\"text\":\"$t\"}" | python3 -c "import sys,json; print('description_es        ', '$t', '→', [x['token'] for x in json.load(sys.stdin)['tokens']])"
  curl -s localhost:19200/part_catalog/_analyze -H 'content-type: application/json' -d "{\"analyzer\":\"description_es_search\",\"text\":\"$t\"}" | python3 -c "import sys,json; print('description_es_search ', '$t', '→', [x['token'] for x in json.load(sys.stdin)['tokens']])"
done
for t in "72-829002-27" "72829002-27" "72 829002 27" "72-829002/27"; do
  curl -s localhost:19200/part_catalog/_analyze -H 'content-type: application/json' -d "{\"analyzer\":\"part_number\",\"text\":\"$t\"}" | python3 -c "import sys,json; print('part_number', '$t', '→', [x['token'] for x in json.load(sys.stdin)['tokens']])"
done
curl -s localhost:19200/part_catalog/_mapping | python3 -c "import sys,json; m=json.load(sys.stdin)['part_catalog']['mappings']; print('dynamic:', m['dynamic'], '· campos:', len(m['properties']))"
