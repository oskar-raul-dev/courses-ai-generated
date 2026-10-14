SET FEEDBACK ON
SELECT CASE WHEN '' IS NULL THEN 'la cadena vacía es NULL' ELSE 'la cadena vacía no es NULL' END AS oracle FROM dual;
CREATE TABLE presentacion (obra_social VARCHAR2(255) NOT NULL);
INSERT INTO presentacion VALUES ('PAMI');
INSERT INTO presentacion VALUES ('');
SELECT count(*) FROM presentacion WHERE obra_social = '';
DROP TABLE presentacion PURGE;
EXIT
