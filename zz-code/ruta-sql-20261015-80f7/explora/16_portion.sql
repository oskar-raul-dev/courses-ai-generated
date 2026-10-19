select version();
select conname, pg_get_constraintdef(oid) from pg_constraint where conrelid='alameda.billed_practice'::regclass and contype='f';
begin;
update alameda.agreement_price for portion of valid_during from '2026-10-01' to null set amount = amount * 1.04 where payer_code='PAMI' and practice_id=1;
rollback;
