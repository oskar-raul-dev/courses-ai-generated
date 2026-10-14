# F11 §6.2: la consulta reescrita en términos y la frecuencia de cada término en el índice (desde src/)
curl -s 'localhost:19200/part_catalog/_validate/query?explain=true' -H 'content-type: application/json' \
  -d '{"query":{"match":{"description":{"query":"oring del tren","operator":"and"}}}}' | python3 -c "import sys,json; print(json.load(sys.stdin)['explanations'][0]['explanation'])"
ID=$(curl -s 'localhost:19200/part_catalog/_search' -H 'content-type: application/json' -d '{"size":1,"_source":false,"query":{"term":{"description.raw":"junta tórica del tren"}}}' | python3 -c "import sys,json; print(json.load(sys.stdin)['hits']['hits'][0]['_id'])")
curl -s "localhost:19200/part_catalog/_termvectors/$ID?fields=description&term_statistics=true&field_statistics=true" | python3 -c "
import sys,json; t=json.load(sys.stdin)['term_vectors']['description']
print('documentos con description:', t['field_statistics']['doc_count'])
for k,v in t['terms'].items(): print(f'  {k:8} aparece en {v[\"doc_freq\"]} documentos')"
docker compose -f lab/compose.yaml exec -T base psql -U postgres -d busqueda_base -c "SELECT count(*) FILTER (WHERE cardinality(alternates) > 0) AS con_alterno, count(*) FILTER (WHERE EXISTS (SELECT 1 FROM unnest(c.alternates) a JOIN part_catalog b ON b.part_number = a WHERE NOT c.part_number = ANY(b.alternates))) AS en_una_direccion FROM part_catalog c"
