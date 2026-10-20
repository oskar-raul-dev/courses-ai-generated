SELECT pg_sleep(0.5);
SELECT remaining FROM demo_stock WHERE segment_id = 'esclusa-de-oro' FOR UPDATE SKIP LOCKED;
SELECT remaining FROM demo_stock WHERE segment_id = 'esclusa-de-oro' FOR UPDATE NOWAIT;
