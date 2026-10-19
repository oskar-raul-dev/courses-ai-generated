SET ECHO ON
BEGIN
  FOR i IN 1 .. 20000 LOOP
    UPDATE mvcc_counter SET last_number = last_number + 1, pad = RPAD(TO_CHAR(i), 1000, 'y') WHERE point_of_sale = MOD(i, 6) + 1;
    COMMIT;
  END LOOP;
END;
/
EXIT
