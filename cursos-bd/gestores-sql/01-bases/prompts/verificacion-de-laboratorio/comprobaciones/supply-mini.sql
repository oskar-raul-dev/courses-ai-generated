-- Base mínima de prueba para P8: una variante STRICT y otra sin STRICT.
CREATE TABLE supplier (
  supplier_id INTEGER PRIMARY KEY,
  name        TEXT NOT NULL,
  status      INTEGER,
  city        TEXT
) STRICT;
CREATE TABLE part (
  part_id INTEGER PRIMARY KEY,
  name    TEXT NOT NULL,
  color   TEXT,
  weight  REAL,
  city    TEXT
) STRICT;
CREATE TABLE shipment (
  supplier_id INTEGER NOT NULL REFERENCES supplier,
  part_id     INTEGER NOT NULL REFERENCES part,
  qty         INTEGER NOT NULL,
  PRIMARY KEY (supplier_id, part_id)
) STRICT;
INSERT INTO supplier VALUES (1,'Smith',20,'London'),(2,'Jones',10,'Paris'),
  (3,'Blake',30,'Paris'),(4,'Clark',20,'London'),(5,'Adams',NULL,'Athens');
INSERT INTO part VALUES (1,'Nut','Red',12.0,'London'),(2,'Bolt','Green',17.0,'Paris'),
  (3,'Screw','Blue',17.0,'Oslo'),(4,'Screw','Red',14.0,'London'),
  (5,'Cam','Blue',12.0,'Paris'),(6,'Cog','Red',19.0,'London');
INSERT INTO shipment VALUES (1,1,300),(1,2,200),(1,3,400),(1,4,200),(1,5,100),(1,6,100),
  (2,1,300),(2,2,400),(3,2,200),(4,2,200),(4,4,300),(4,5,400);
