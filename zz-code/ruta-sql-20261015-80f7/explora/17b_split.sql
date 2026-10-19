begin;
with u as (update alameda.agreement_price set valid_during = daterange(lower(valid_during), '2026-10-01')
           where payer_code='PAMI' and practice_id=1 and valid_during @> date '2026-10-01' and lower(valid_during) < '2026-10-01'
           returning payer_code, practice_id, amount)
insert into alameda.agreement_price select payer_code, practice_id, daterange('2026-10-01', null), round(amount*1.04, 2) from u;
select * from alameda.agreement_price where payer_code='PAMI' and practice_id=1 order by valid_during desc limit 2;
rollback;
