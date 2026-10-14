\pset pager off
SELECT site_code, count(*) FILTER (WHERE ordered_on >= '2026-01-01') AS y2026, count(*) FROM alameda.lab_order GROUP BY 1 ORDER BY 1;
SELECT site_code, count(*) FROM alameda.lab_order WHERE ordered_on >= '2026-09-01' GROUP BY 1 ORDER BY 1;
