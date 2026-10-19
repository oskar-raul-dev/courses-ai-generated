-- Fase 21 · la jerarquía de prácticas y la cadena de derivaciones, con WITH RECURSIVE.
--
-- SUPUESTO DECLARADO: la caja no trae la composición de los paneles (`legacy.Practicas` es una lista plana de 75
-- prácticas). Esta fase la declara en staging: qué prácticas forman parte de cuáles, sobre códigos reales de
-- `legacy.Practicas`. La cadena de derivaciones sí es real: una muestra de orina produce un urocultivo, y el
-- urocultivo, un antibiograma (ver las tablas `Orina` y `Urocultivo` de la caja).

DROP TABLE IF EXISTS staging.practice_composition;
CREATE TABLE staging.practice_composition (panel_id integer, component_id integer, PRIMARY KEY (panel_id, component_id));
INSERT INTO staging.practice_composition VALUES
  (21, 22),  -- SEROLOGIA incluye VDRL
  (21, 23),  -- SEROLOGIA incluye CHAGAS
  (21, 27),  -- SEROLOGIA incluye TOXOPLASMOSIS
  (21, 28),  -- SEROLOGIA incluye RUBEOLA
  (21, 25),  -- SEROLOGIA incluye HEPATITISB
  (21, 26),  -- SEROLOGIA incluye HEPATITISC
  (34, 49);  -- PROTEINOGRAMA incluye ELECTROFORESIS

DROP TABLE IF EXISTS staging.practice_derivation;
CREATE TABLE staging.practice_derivation (source_id integer, derived_id integer, PRIMARY KEY (source_id, derived_id));
INSERT INTO staging.practice_derivation VALUES
  (20, 41),   -- ORINA produce UROCULTIVO
  (41, 71);   -- UROCULTIVO produce ANTIBIOGRAMA

-- 1. Hoy: el informe baja cuatro niveles fijos con LEFT JOIN. Con la composición real, alcanza y sobra.
EXPLAIN (ANALYZE, COSTS OFF, TIMING OFF)
SELECT c1.panel_id AS raiz, c1.component_id AS n1, c2.component_id AS n2, c3.component_id AS n3, c4.component_id AS n4
FROM staging.practice_composition c1
LEFT JOIN staging.practice_composition c2 ON c2.panel_id = c1.component_id
LEFT JOIN staging.practice_composition c3 ON c3.panel_id = c2.component_id
LEFT JOIN staging.practice_composition c4 ON c4.panel_id = c3.component_id
WHERE c1.panel_id = 21;

-- 2. La versión recursiva: sin límite de profundidad.
EXPLAIN (ANALYZE, COSTS OFF, TIMING OFF)
WITH RECURSIVE baja AS (
  SELECT panel_id, component_id, 1 AS nivel FROM staging.practice_composition WHERE panel_id = 21
  UNION ALL
  SELECT b.panel_id, c.component_id, b.nivel + 1
  FROM baja b JOIN staging.practice_composition c ON c.panel_id = b.component_id
)
SELECT * FROM baja ORDER BY nivel, component_id;

-- 3. Ahora la realidad cambia: un panel de prueba bajo VDRL, de cuatro niveles, y uno más abajo.
--    Se agregan tres prácticas sintéticas (900, 901, 902 y 903) que solo existen en staging.
INSERT INTO staging.practice_composition VALUES (22, 900), (900, 901), (901, 902), (902, 903);

-- El informe fijo de cuatro niveles ve hasta 902 y no ve 903.
SELECT c4.component_id AS hasta_nivel_4
FROM staging.practice_composition c1
LEFT JOIN staging.practice_composition c2 ON c2.panel_id = c1.component_id
LEFT JOIN staging.practice_composition c3 ON c3.panel_id = c2.component_id
LEFT JOIN staging.practice_composition c4 ON c4.panel_id = c3.component_id
WHERE c1.panel_id = 21 AND c4.component_id = 902;
SELECT count(*) AS nodos_distintos_que_el_informe_fijo_ve FROM (
  SELECT c2.component_id AS nodo FROM staging.practice_composition c1
  LEFT JOIN staging.practice_composition c2 ON c2.panel_id = c1.component_id WHERE c1.panel_id = 21
  UNION SELECT c3.component_id FROM staging.practice_composition c1
  LEFT JOIN staging.practice_composition c2 ON c2.panel_id = c1.component_id
  LEFT JOIN staging.practice_composition c3 ON c3.panel_id = c2.component_id WHERE c1.panel_id = 21
  UNION SELECT c1.component_id FROM staging.practice_composition c1 WHERE c1.panel_id = 21
  UNION SELECT c4.component_id FROM staging.practice_composition c1
  LEFT JOIN staging.practice_composition c2 ON c2.panel_id = c1.component_id
  LEFT JOIN staging.practice_composition c3 ON c3.panel_id = c2.component_id
  LEFT JOIN staging.practice_composition c4 ON c4.panel_id = c3.component_id WHERE c1.panel_id = 21
) x WHERE nodo IS NOT NULL;

WITH RECURSIVE baja AS (
  SELECT panel_id, component_id, 1 AS nivel FROM staging.practice_composition WHERE panel_id = 21
  UNION ALL
  SELECT b.panel_id, c.component_id, b.nivel + 1
  FROM baja b JOIN staging.practice_composition c ON c.panel_id = b.component_id
)
SELECT count(*) AS nodos_que_la_recursiva_ve, max(nivel) AS profundidad_maxima FROM baja;

-- 4. La cadena de derivaciones hacia arriba: de qué muestra sale un antibiograma.
WITH RECURSIVE sube AS (
  SELECT source_id, derived_id, 1 AS nivel FROM staging.practice_derivation WHERE derived_id = 71
  UNION ALL
  SELECT d.source_id, s.derived_id, s.nivel + 1
  FROM sube s JOIN staging.practice_derivation d ON d.derived_id = s.source_id
)
SELECT * FROM sube ORDER BY nivel;

-- Se deshace la prueba para que la composición quede como se declaró.
DELETE FROM staging.practice_composition WHERE component_id IN (900, 901, 902, 903) OR panel_id IN (900, 901, 902);
