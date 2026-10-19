SET ECHO ON
SET TRANSACTION READ ONLY;
SELECT last_number FROM mvcc_counter WHERE point_of_sale = 1;
EXEC DBMS_SESSION.SLEEP(40)
SELECT last_number, LENGTH(pad) FROM mvcc_counter;
COMMIT;
EXIT
