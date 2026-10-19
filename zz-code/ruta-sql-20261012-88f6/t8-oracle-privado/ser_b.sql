SET ECHO ON
UPDATE mvcc_counter SET last_number = 23 WHERE point_of_sale = 1;
COMMIT;
EXIT
