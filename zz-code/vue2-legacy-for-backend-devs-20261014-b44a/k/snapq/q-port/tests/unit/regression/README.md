# Red de seguridad — NO TOCAR durante la migración

Estos tests describen el comportamiento de la Tiquetera **antes** de Quasar.

Regla: durante Q1–Q4 estos archivos NO se editan.
Si uno se pone rojo, hay exactamente dos respuestas válidas:

1. Rompiste el comportamiento → arregla el CÓDIGO.
2. El test estaba acoplado al DOM viejo → arréglalo, y ANOTA POR QUÉ
   en MIGRATION-CHECKLIST.md. Cada edición aquí es una confesión.

Lo que NO es una respuesta válida: borrarlo, .skip()arlo, o "ajustarlo
hasta que pase".
