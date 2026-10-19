SET ECHO ON
UPDATE mvcc_counter SET pad = 'a' WHERE point_of_sale = 1;
EXEC DBMS_SESSION.SLEEP(2)
UPDATE mvcc_counter SET pad = 'a' WHERE point_of_sale = 2;
EXEC DBMS_SESSION.SLEEP(8)
ROLLBACK;
EXIT
