# F13 §6.6 (el despiece) y la sección Neo4j de a03, tal como corrieron (desde src/)
CS="docker compose -f lab/compose.yaml exec -T grafos cypher-shell -u neo4j -p condor-mro"
echo "SHOW DATABASES YIELD name, currentStatus;" | $CS
echo "CALL db.labels() YIELD label RETURN collect(label) AS labels;" | $CS
echo "MATCH (x:Assembly)-[:MOUNTED_ON]->(a:Aircraft {registration: 'HC-4039'}) OPTIONAL MATCH (p:Part)-[:PART_OF]->(x) RETURN x.position AS conjunto, collect(p.category) AS piezas ORDER BY conjunto;" | $CS
echo "PROFILE MATCH (x:Assembly)-[:MOUNTED_ON]->(a:Aircraft {registration: 'HC-4039'}) OPTIONAL MATCH (p:Part)-[:PART_OF]->(x) RETURN count(p) AS piezas;" | $CS --format verbose | tail -25
echo "CREATE (:Part {serialNumber: 'SN-PRUEBA', lotNumber: 'LOT-PRUEBA'}); MATCH (p:Part {lotNumber: 'LOT-PRUEBA'}) RETURN count(p) AS n; MATCH (p:Part {serialNumber: 'SN-PRUEBA'}) DELETE p;" | $CS
