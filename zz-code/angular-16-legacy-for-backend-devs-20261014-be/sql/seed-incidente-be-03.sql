-- be-03: "El listado del panel cambia de orden según el día".
-- No cambia NINGÚN dato visible: sólo fuerza la reescritura física de las filas de
-- ascensores, que es lo que reorganiza el montón y cambia el orden de un SELECT sin
-- ORDER BY (el de /legacy/templates). Con la de calderas no se ve: ya está al final.
UPDATE templates
   SET valid_from = valid_from
 WHERE template_id = 'elevator-annual';

-- Comprobación de la preparación (debe salir boiler-annual primero):
--   SELECT template_id, version FROM templates;
