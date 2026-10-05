.echo on
.bail off
-- 1. foreign_keys por defecto
PRAGMA foreign_keys;
INSERT INTO shipment VALUES (99, 1, 10);
SELECT COUNT(*) FROM shipment WHERE supplier_id = 99;
PRAGMA foreign_keys = ON;
INSERT INTO shipment VALUES (98, 1, 10);
-- 2. operadores ALL
SELECT city FROM supplier UNION ALL SELECT city FROM part;
SELECT city FROM supplier INTERSECT ALL SELECT city FROM part;
SELECT city FROM supplier EXCEPT ALL SELECT city FROM part;
-- 3. vistas
CREATE VIEW paris_supplier AS SELECT * FROM supplier WHERE city = 'Paris';
UPDATE paris_supplier SET status = 15 WHERE supplier_id = 2;
CREATE TRIGGER paris_supplier_upd INSTEAD OF UPDATE ON paris_supplier
BEGIN
  UPDATE supplier SET status = NEW.status WHERE supplier_id = OLD.supplier_id;
END;
UPDATE paris_supplier SET status = 15 WHERE supplier_id = 2;
SELECT supplier_id, status FROM supplier WHERE supplier_id = 2;
-- 4. WITH CHECK OPTION
CREATE VIEW london_supplier AS SELECT * FROM supplier WHERE city = 'London' WITH CHECK OPTION;
-- 5. triggers de sentencia
CREATE TRIGGER shipment_stmt AFTER INSERT ON shipment FOR EACH STATEMENT BEGIN SELECT 1; END;
-- 6. dbstat
SELECT name, COUNT(*) AS pages, SUM(pgsize) AS bytes FROM dbstat GROUP BY name ORDER BY name;
-- 7. STRICT
INSERT INTO supplier VALUES (9, 'Xu', 'veinte', 'Lima');
INSERT INTO supplier VALUES (10, 'Yi', '25', 'Lima');
SELECT supplier_id, status, typeof(status) FROM supplier WHERE supplier_id = 10;
