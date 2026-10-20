# Verificación a mano de T5 (para el autor)

Lo mismo que en `verificacion-a-mano-T4.md`: navegador y DevTools, en `esclusa-app/` de este directorio. Lo que sí
corrió en contenedor está en el README §7. Anota la fecha y el resultado al lado.

## F08 — conciliación

`git checkout fase-08-conciliacion`. Con los mocks parados, `npm run seed:reconciliation`; después `npm run mock:all` y
`npm start`. Login con `mdegracia@esclusa.test` / `esclusa123`.

1. **Navbar.** Aparece «Conciliación»; en `/reconciliation`, el select ofrece «Rueda de fin de mes (terminada)» y
   «Rueda de la costa (conciliada)».
2. **Probabilidades.** Al elegir la Rueda de fin de mes: «Probabilidades: 10000 giros», la tabla sin filas en rojo,
   observados 3017 · 1962 · 1515 · 1483 · 1040 · 784 · 142 · 57, y «χ² = 4.49 … sin alarmas.».
3. **Network.** Cinco peticiones al elegir la rueda: cuatro al `3001` (`/segments`, `/spinLog`, `/purchases`,
   `/packages`) y una al `3002` (`/earnings`).
4. **Compras.** «Cobrado US$159,60 · comisión de la tienda US$24,00 · neto US$135,60 · 39 cobros con su acreditación»,
   y en rojo `tok-ago-31` (sin acreditar) y `tok-ago-17` (acreditada dos veces).
5. **Prorrateo.** «Prorrateo del paquete tok-ago-05», con 691 · 380 · 284 · 296 · 228 · 152 · 52 · 16 centavos, y
   «Suma de las filas US$20,99 · precio del paquete US$20,99».
6. **Conciliar.** «Conciliar rueda» → la rueda pasa a `reconciled` en Redux DevTools, el botón desaparece y aparece
   «Esta operación no tiene vuelta atrás.». Recargar la página: la rueda figura «(conciliada)».
7. **La regla vieja.** Mocks parados, `node mock/seed-reconciliation.js --accommodating`, mocks arriba: seis filas en
   rojo y χ² = 808,35. Al terminar, vuelve a sembrar sin la bandera (o `git checkout -- mock/db.json mock/googlePlay/earnings.json`).
- Resultado: ____ · fecha: ____

## Incidente 18

`git checkout incidente/18`, la misma siembra, mocks y consola: el prorrateo de `tok-ago-05` dice «Suma de las filas
US$21,00 · precio del paquete US$20,99», con 621 · 399 · 298 · 311 · 239 · 160 · 55 · 17.
- Resultado: ____ · fecha: ____
