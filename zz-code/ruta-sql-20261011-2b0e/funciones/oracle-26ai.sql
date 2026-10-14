-- Checks Oracle features the phases rely on (structure only; nothing here is a performance number).
SET LINESIZE 200 FEEDBACK ON
CREATE TABLE p8_patient (patient_id NUMBER PRIMARY KEY, full_name VARCHAR2(100));
CREATE TABLE p8_order (order_id NUMBER PRIMARY KEY, patient_id NUMBER REFERENCES p8_patient, created_on DATE);
CREATE JSON RELATIONAL DUALITY VIEW p8_patient_dv AS
  SELECT JSON {'_id': p.patient_id, 'name': p.full_name,
               'orders': [SELECT JSON {'orderId': o.order_id, 'createdOn': o.created_on} FROM p8_order o WITH INSERT UPDATE DELETE WHERE o.patient_id = p.patient_id]}
  FROM p8_patient p WITH INSERT UPDATE DELETE;
INSERT INTO p8_patient_dv VALUES ('{"_id": 1, "name": "PEREZ PEDRO", "orders": [{"orderId": 10, "createdOn": "2026-10-11T00:00:00"}]}');
SELECT COUNT(*) FROM p8_order;
SELECT JSON_SERIALIZE(data) FROM p8_patient_dv;
CREATE TABLE p8_doc (id NUMBER, doc JSON);
INSERT INTO p8_doc VALUES (1, '{"a":1}');
SELECT uuid() FROM dual;
CREATE TABLE p8_vec (id NUMBER, v VECTOR(3, FLOAT32));
EXPLAIN PLAN FOR SELECT /*+ INDEX(p) */ * FROM p8_patient p WHERE patient_id = 1;
SELECT plan_table_output FROM TABLE(DBMS_XPLAN.DISPLAY(format => 'BASIC'));
SHOW PARAMETER undo_management
DROP VIEW p8_patient_dv; DROP TABLE p8_order PURGE; DROP TABLE p8_patient PURGE; DROP TABLE p8_doc PURGE; DROP TABLE p8_vec PURGE;
EXIT
