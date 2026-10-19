\timing on
SELECT count(*) FROM staging.portal_order;
SELECT count(*) FROM (SELECT * FROM staging.portal_order ORDER BY ordered_on DESC, lab_order_id DESC OFFSET 899980 LIMIT 20) p45000;
SELECT count(*) FROM (SELECT * FROM staging.portal_order ORDER BY ordered_on DESC, lab_order_id DESC OFFSET 999980 LIMIT 20) p50000;
SELECT count(*) FROM (SELECT * FROM staging.portal_order ORDER BY ordered_on DESC, lab_order_id DESC OFFSET 1199980 LIMIT 20) p60000;
SELECT count(*) FROM (SELECT * FROM staging.portal_order ORDER BY ordered_on DESC, lab_order_id DESC OFFSET 1327600 LIMIT 20) p66381;
SELECT count(*) FROM (SELECT * FROM staging.portal_order ORDER BY ordered_on DESC, lab_order_id DESC OFFSET 999980 LIMIT 20) p50000;
SELECT count(*) FROM (SELECT * FROM staging.portal_order ORDER BY ordered_on DESC, lab_order_id DESC OFFSET 1327600 LIMIT 20) p66381;
EXPLAIN (COSTS OFF) SELECT * FROM staging.portal_order ORDER BY ordered_on DESC, lab_order_id DESC OFFSET 1327600 LIMIT 20;
