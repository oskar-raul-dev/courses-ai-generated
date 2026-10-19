-- postgres
-- 🏆 "Un martes" · tu migración. El arnés la corre como superusuario, después de 00_base.sql y antes de
-- evaluar. Es el lugar de lo que la base nueva todavía no tiene y la facturación necesita: una columna,
-- un relleno, un cambio al aplicador del CDC de la Fase 25.
--
-- El punto de partida no agrega nada.
SELECT 'el punto de partida no migra nada' AS "01_setup";
