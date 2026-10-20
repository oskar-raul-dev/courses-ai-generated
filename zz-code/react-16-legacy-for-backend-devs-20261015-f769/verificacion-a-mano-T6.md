# Verificación a mano de T6 (para el autor)

Lo mismo que en `verificacion-a-mano-T4.md` y `-T5.md`: navegador y DevTools (React y Redux), en `esclusa-app/` de
este directorio. Lo que sí corrió en contenedor está en el README §7; lo de aquí es lo que solo se ve en un navegador.
Login con `mdegracia@esclusa.test` / `esclusa123`. Anota la fecha y el resultado al lado.

## F09 — el tablero

`git checkout fase-09-dashboard`, `npm run seed:reconciliation`, `npm run mock:all` y `npm start`; ir a `/dashboard`.

1. **El gráfico de la banda.** Con la Rueda de fin de mes: barras «Observado» y las dos líneas rojas «Banda (−3σ)» y
   «Banda (+3σ)»; ninguna barra fuera de la banda. Pasar el mouse por una barra muestra su valor.
2. **El filtro de origen.** «Todos», «Gratis» y «Pagos» cambian las cifras y el gráfico sin pedir nada nuevo a la red
   (Network, sin peticiones al cambiar el filtro).
3. **La tarjeta.** «Actualizado: …» en hora de Panamá, aunque la máquina esté en otra zona.
4. **Salir y volver.** Entrar y salir del tablero varias veces: en la pestaña Memory no se acumulan instancias de
   chart.js (el `destroy` de `BandChart`).
- Resultado: ____ · fecha: ____

## F09 — el `useMemo` roto, con el Profiler

Con mocks parados, `node mock/seed-reconciliation.js --event` (la Semana del Canal, 180.000 giros) y mocks arriba.

1. En `fase-09-dashboard`, React DevTools → Profiler: grabar diez cambios de filtro. Los commits deberían durar poco
   (en Jest midió 2,2 ms de mediana; en el navegador el número será otro: anótalo).
2. `git checkout previo-t6/incidente-19-usememo` y repetir: los commits crecen (en Jest, 12,5 ms) y el Profiler dice que
   el cálculo corre en cada cambio de filtro.
3. Al terminar, `git checkout -- mock/db.json mock/googlePlay/earnings.json`.
- Medidas en el navegador: con selector ____ ms · con `useMemo` roto ____ ms · fecha: ____

## Incidente 19 — los chequeos de Toolkit

Con la Semana del Canal sembrada. `git checkout incidente/19`, `npm start` (desarrollo), abrir el tablero del evento.

1. La consola del navegador repite *"SerializableStateInvariantMiddleware took … ms, which is more than the warning
   threshold of 32ms"* en cada acción, y la interfaz se arrastra (deshacer una concesión tarda visiblemente).
2. Anotar si también aparece el aviso de `ImmutableStateInvariantMiddleware`: en Jest no apareció nunca, y el curso
   solo cita el de serialización.
3. `git checkout fase-09-dashboard`: sin avisos y sin arrastre.
4. `npm run build` y `serve -s build` sobre `incidente/19`: en producción no hay avisos ni arrastre (los chequeos son
   solo de desarrollo).
- Resultado: ____ · ¿aviso de inmutabilidad? ____ · fecha: ____

## Incidente 20 — la tarjeta en dos zonas

`git checkout incidente/20`. Abrir el tablero con la máquina en `America/Bogota` y después en UTC (o en otra zona del
sistema operativo): la línea «Actualizado» cambia de hora. En `fase-09-dashboard` muestra la misma hora en las dos.
- Resultado: ____ · fecha: ____

## Incidente 21 — la regla vieja en el tablero

`git checkout fase-09-dashboard`, mocks parados, `node mock/seed-reconciliation.js --accommodating`, mocks arriba: en el
tablero de la Rueda de fin de mes, seis barras fuera de la banda y χ² = 808,35. Volver a sembrar sin la bandera al
terminar.
- Resultado: ____ · fecha: ____

## F11 — el puente (opcional)

En `etapas/puente-r18` (React 18.2.0), `npm start`: la app arranca; con StrictMode, los efectos corren dos veces en
desarrollo (en la consola, los `console.debug` de las peticiones salen duplicados al montar). No hace falta que la app
funcione entera ahí: es una copia descartable.
- Resultado: ____ · fecha: ____

## A13 — el build en DevTools

En `etapas/a13`: `npm run build` y `npx serve -s build`.

1. Sources: con el source map al lado, aparecen los archivos originales (`features/grants/epics/closedWheelGuard.js`).
2. Abrir `/wheels/1` directo en la barra: carga (200). Con `npx serve build` (sin `-s`): 404.
3. Sin el `.map` (moverlo fuera de `build/static/js/`), el error de la rueda cerrada apunta a `main.<hash>.chunk.js:1:…`.
- Resultado: ____ · fecha: ____
