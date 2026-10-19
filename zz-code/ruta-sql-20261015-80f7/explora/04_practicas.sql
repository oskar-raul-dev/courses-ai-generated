select p.practice_id, c.code, p.description, p.ub from alameda.practice p join alameda.practice_code c on c.practice_id=p.practice_id and c.nomenclator_code='NBU2012' order by c.code;
select * from staging.practice_composition limit 20;
select u.* from alameda.biochemical_unit u order by valid_during desc limit 2;
select payer_code, min(amount), max(amount), count(*) from alameda.agreement_price where valid_during @> date '2026-09-30' group by 1;
