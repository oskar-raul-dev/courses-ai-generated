# 🕵️ Forense Fase 08 — El borde de vigencia que se resbala, y el mapa que miente

> Pieza forense de la [**Fase 8 — Resultados y rangos versionados**](./08-resultados-rangos.md) · Recorrido: ~55 min · [Índice del track](./forense-master.md)
> Herramientas: la consola sobre `selectActiveRange` · el bundle de producción · source maps y su hash
> Síntoma que cubre: un veredicto clínico calculado con la norma equivocada, y un depurador que te lleva a la línea inocente.

Dos recorridos que la fase junta a propósito, porque en la práctica llegan juntos: **el bug que sólo aparece en el borde de una ventana de vigencia**, y **la herramienta con la que lo perseguirías en producción, que a veces te miente**. El primero produce un dato clínicamente equivocado sin un solo error; el segundo hace que la investigación se pierda en el archivo que no era.

---

## 🎫 Los tickets

> **T-1:** *"Un resultado de glucosa de 105 salió marcado fuera de rango. El mismo valor, la semana pasada, salía normal. La muestra es del 31 de mayo."*
>
> **T-2:** *"Puse un breakpoint donde dice el stack trace de PROD y no se dispara nunca, pero el error sigue apareciendo."*

**Reportados por:** una analista de resultados (T-1) y un compañero del equipo (T-2)
**Ambiente:** PROD

T-1 trae los tres datos que hacen falta y no lo sabe: **el valor** (105), **la fecha de la muestra** (31 de mayo) y **el contraste** (la semana pasada era normal). Con eso ya se puede sospechar de qué familia es el bug antes de abrir nada: algo que depende de la fecha.

---

## 🧭 Ruta 1 — El veredicto calculado con la norma equivocada

Cuatro pasos. Los dos primeros son aritmética y cuestan un minuto; el tercero es una línea de consola; el cuarto decide qué se toca.

### Paso 1 — Las dos ventanas, escritas una debajo de la otra

Antes de mirar código, mira la norma. Los rangos son datos, y están a una consulta:

```bash
curl -s "http://localhost:3000/referenceRanges?analyte=glucose"
```

```json
[
  { "version":1, "low":70, "high":110, "effectiveFrom":"2019-01-01T00:00:00-05:00",
    "effectiveTo":"2019-05-31T23:59:59-05:00" },
  { "version":2, "low":70, "high":100, "effectiveFrom":"2019-06-01T00:00:00-05:00",
    "effectiveTo":null }
]
```

**Qué descarta.** Con esto el ticket se explica solo **si se eligió la versión equivocada**: 105 está dentro con la v1 (techo 110) y fuera con la v2 (techo 100). No hay tercera posibilidad, y no hace falta leer una línea de TypeScript para saberlo. La pregunta pasa a ser una sola: **¿por qué eligió la v2 una muestra del 31 de mayo?**

### Paso 2 — La aritmética del borde, hecha a mano

Mira la fecha exacta de la muestra, no el día:

```bash
curl -s "http://localhost:3000/samples/501" | grep collectedAt
# "collectedAt": "2019-05-31T20:00:00-05:00"
```

Las ocho de la noche del último día de la v1, hora local. Ahora conviértelo, que es lo que hace `.getTime()`:

```
2019-05-31T20:00:00-05:00   ==   2019-06-01T01:00:00Z
                                 └─ ya es junio en UTC
```

**Qué descarta.** El diagnóstico está prácticamente cerrado y no ha hecho falta ningún depurador: la muestra se tomó el 31 de mayo por la noche en Bogotá, que es el 1 de junio en UTC, y la ventana de la v2 abre el 1 de junio. **La comparación de instantes es correcta; lo que está mal es que los dos lados no viven en la misma zona.**

Y explica la parte del ticket que parecía folclore: esto sólo falla **de noche**, y sólo en el borde. Con UTC-5, cualquier hora local a partir de las 19:00 ya pertenece al día siguiente en UTC. En el 95% de los días eso da igual porque la fecha cae lejos de un borde; los días que no da igual son los bordes, y los peores caen en fin de semana, cuando nadie está mirando.

### Paso 3 — Confirmarlo en la función, sin depurador

Una línea de consola sobre la función pura, que no necesita ni store ni componente:

```js
selectActiveRange(ranges, 'glucose', '2019-05-31T20:00:00-05:00').version
// 2      ← debería ser 1
selectActiveRange(ranges, 'glucose', '2019-05-31T12:00:00-05:00').version
// 1      ← la misma fecha, de día, elige bien
```

**Qué descarta.** Dos llamadas y queda demostrado que la hora —no el día— decide el resultado. Muere cualquier hipótesis sobre el reducer, el effect o el componente: la función pura, aislada de todo, ya elige mal.

> 💡 Si prefieres no tocar la consola, el mismo experimento con un `console.log(activeRange.version)` en el effect antes del PATCH da la misma respuesta y es el 🧨 que propone la fase.

### Paso 4 — El otro extremo del mismo agujero: el `atDate` sin zona

Antes de proponer nada, comprueba de dónde sale la fecha que entra a la función. Hay dos llamadores y los dos tienen la misma caída:

```typescript
var atDate = sample && sample.collectedAt
  ? sample.collectedAt          // trae offset -05:00
  : new Date().toISOString();   // "hoy" del navegador, en UTC
```

**Qué descarta.** Si la muestra no tiene `collectedAt`, la fecha de referencia deja de ser la del evento y pasa a ser **hoy, según el reloj del navegador**. Eso rompe algo peor que un veredicto: rompe la reproducibilidad, porque el mismo resultado juzgado dos días distintos puede aplicar normas distintas. Compruébalo en el dato antes de seguir:

```bash
curl -s "http://localhost:3000/samples" | grep -c '"collectedAt": null'
```

Y ahí la ruta termina, con dos hallazgos y no uno: la comparación pierde la zona, y la fecha de referencia a veces ni siquiera es la del evento.

**El fix mínimo y el correcto, que no son el mismo:** forzar que el `atDate` lleve el offset explícito de la aplicación antes de comparar tapa el caso reportado. Normalizar **los dos lados** a `America/Bogota` con una librería de zona horaria arregla la clase entera. Y hay una tercera pregunta, que no es de código: *¿a qué hora, exactamente, entra en vigor una norma?* Mientras nadie la conteste, cualquier implementación está adivinando — que es la razón por la que un "bug de fechas" casi nunca es un bug de fechas.

---

## 🧭 Ruta 2 — El source map que te lleva a la línea inocente

Tres pasos, y el primero es el que casi nadie da.

### Paso 1 — ¿Hay mapas, y los está usando el navegador?

Sirve el `dist` construido con `--prod` y abre DevTools → **Sources**. Si ves tus `.ts` con nombres de variable de verdad, hay mapas y están enlazados. Si ves una sola línea de 1.2 MB, no los hay:

```jsonc
// angular.json -> architect -> build -> configurations -> production
"sourceMap": true       // el CLI 8 lo genera en false; este proyecto lo pone en true
```

**Qué descarta.** Sin mapas no hay investigación posible sobre PROD y el paso siguiente no aplica: lo que hay que hacer es reconstruir con ellos. Con mapas, sigue.

### Paso 2 — La firma del desfase

El síntoma de T-2 es inconfundible una vez que lo has visto: **un breakpoint que no se dispara sobre código que claramente se está ejecutando**. La causa casi siempre es la misma: se recompiló el JavaScript y se subió el `.map` anterior. El mapa describe un bundle que ya no existe, y traduce coordenadas con una precisión perfecta hacia el archivo equivocado.

Compáralos, que es lo que resuelve el caso:

```bash
# 1. El bundle que sirve producción, y su hash en el nombre.
ls dist/clinical-lab/main.*.js
# dist/clinical-lab/main.8a1f2c.js

# 2. A qué map dice apuntar, en su última línea.
tail -c 120 dist/clinical-lab/main.8a1f2c.js
# //# sourceMappingURL=main.8a1f2c.js.map

# 3. Y que archivos declara cubrir ese map.
head -c 300 dist/clinical-lab/main.8a1f2c.js.map
# {"version":3,"file":"main.8a1f2c.js","sources":["webpack:///./src/app/…
```

**Qué descarta.** Si el `file` del mapa no coincide con el nombre del bundle servido, el desfase está probado y toda la traducción que has estado leyendo es ficción. Si coinciden, el mapa es el correcto y el breakpoint no dispara por otra razón —código que no se ejecuta en esa rama, o un chunk distinto del que crees—.

> ⚠️ **Y el aviso que va con esto:** con `sourceMap: true` sin `hidden`, cualquiera que abra DevTools contra el ambiente desplegado lee el TypeScript completo. Es una decisión defendible para una aplicación interna y está declarada como deuda en [**A04 §6**](./a04-webpack-oculto.md) — pero es una decisión que se toma con el equipo, no en un commit de un martes.

### Paso 3 — Cruzar el stack trace con el bundle real

Con el mapa correcto, un stack trace de un reporte se traduce solo:

```
ERROR TypeError: Cannot read property 'analyte' of undefined
    at main.8a1f2c.js:1:284712
```

DevTools traduce esa coordenada a `reference-range.selector.ts:249` y ahí se lee el bucle que recorre `ranges`. **Qué descarta.** Si el archivo traducido es coherente con lo que hace la aplicación, tienes la línea. Si te lleva a un archivo que no tiene nada que ver con el síntoma —un componente que ni siquiera está en pantalla—, vuelve al paso 2: el mapa está desfasado y te está mintiendo con total seguridad.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Causa | Dónde miras |
|---|---|---|
| Un valor sale fuera de rango y la semana pasada no | se eligió otra versión de la norma | las dos ventanas, y el techo de cada una |
| El veredicto cambia según la **hora** de la muestra | el borde de vigencia se resbala a UTC | la conversión a mano del paso 2 |
| El mismo resultado juzgado dos días distintos aplica normas distintas | el `atDate` cayó a `new Date()` del navegador | `collectedAt` de la muestra: ¿es `null`? |
| `selectActiveRange` devuelve `null` | ninguna ventana cubre esa fecha | y `evaluateResult` lo marca **sin rango**, no "normal" |
| Un resultado `validated` con `rangeVersionApplied: null` | se validó sin norma detrás, o se sembró así | el `seed.js`, y la doble guarda del reducer |
| Un validado viejo cambia de veredicto al nacer una v3 | no debería: `rangeVersionApplied` lo congela | si cambia, alguien está recalculando con el rango vigente |
| Validas y la orden no se mueve | el cruce `results → orders` está como esqueleto | deuda declarada, no bug |
| El botón de validar no aparece y el resultado se valida igual | la cortesía visual no es la guarda | la guarda vive en el reducer, y está bien así |
| Un breakpoint que no dispara sobre código que sí corre | source map desfasado | el `file` del `.map` contra el nombre del bundle |
| Sources muestra una línea de 1.2 MB | no hay mapas en esa build | `sourceMap` en la configuración de producción |
| El stack trace apunta a un archivo sin relación con el síntoma | el mapa traduce hacia un bundle que ya no existe | el hash, en los tres sitios del paso 2 |

---

## ⚰️ Los callejones

**"Es un bug de fechas."** Nunca lo es. Es no haber decidido **a qué hora y en qué zona** entra en vigor una norma. Mientras esa pregunta no tenga respuesta escrita, cualquier implementación —la actual y la que la reemplace— está adivinando, y el siguiente borde volverá a fallar de otra manera.

**"Hay que pasar todo a UTC."** Suena a solución y es la mitad del problema: los bordes de vigencia se **definieron** en hora local porque una norma clínica entra en vigor a la medianoche de un país, no a la medianoche de Greenwich. Convertir todo a UTC sin decidir la zona de referencia mueve el error de sitio en vez de quitarlo.

**"El dato está mal en el `db.json`."** Se descarta en el paso 2: el `collectedAt` trae su offset explícito y es correcto. Lo que se resbala es la comparación, no el dato. Es la pregunta 🧬 del método contestada del lado cómodo, y conviene contestarla igual antes de tocar código.

**"El breakpoint no dispara porque el código no se ejecuta."** Es la conclusión natural de T-2 y es exactamente lo que el mapa desfasado te induce a creer. Un `console.log` crudo en esa misma función —sin depender de mapas ni de breakpoints— lo tumba en diez segundos: si imprime, el código corre y el que está desfasado es el mapa.

---

## 🧨 Deshacer

Este recorrido toca datos y artefactos de build:

```bash
# 1. La muestra, si le cambiaste el collectedAt para provocar el borde.
npm run seed

# 2. El dist con los mapas desfasados. Borralo entero: un stats.json o un
#    .map viejo va a confundirte en la siguiente investigación.
rm -rf dist/
```

Y quita el `console.log(activeRange.version)` del effect si lo pusiste. Un `console.log` olvidado dentro de un `map` de RxJS es, además, una de las causas de "desde ayer va lento" que se persiguen en la Fase 10 — no lo dejes puesto.

---

## 🧠 El patrón transferible

> **Un bug que depende de la hora del día no es intermitente: es un borde.** Cuando un cálculo funciona el 95% de las veces y falla siempre en los mismos momentos, no busques concurrencia ni azar: busca un límite —de una ventana de vigencia, de un día, de un mes— y comprueba en qué zona horaria está escrito cada lado de la comparación. La aritmética se hace a mano en un minuto y ahorra el depurador entero.

Y el segundo, que es de las cosas más útiles que este track enseña: **una herramienta que traduce puede traducir mal con total seguridad.** Un source map desfasado no te da un error: te da una respuesta precisa, plausible y falsa, y no hay nada en la pantalla que lo delate. La firma es siempre la misma —un breakpoint que no dispara sobre código que sí corre— y la comprobación es cruzar hashes, que cuesta treinta segundos. Desconfiar de la herramienta cuando la evidencia no cuadra es tan importante como saber usarla.

**Incidentes del cuaderno que usan esta ruta:** el **07** —*"los resultados críticos no avisan el fin de semana"*, que es esta misma aritmética con otro borde—, el **12** —*"el resultado quedó validado pero sin norma detrás"*, que entra por la fila del `rangeVersionApplied: null`— y el **13** —*"dos analistas firmaron el mismo resultado"*, que es la doble guarda del reducer vista desde la concurrencia.
**Amplía:** el [**Apéndice A04 §6**](./a04-webpack-oculto.md) para las cuatro claves de `sourceMap` y por qué `hidden` existe, y [`forense-fase-13.md`](./forense-fase-13.md) para cuando el artefacto desplegado no sea el que crees, que es la versión grande de este mismo desfase.

**📚 La documentación de source maps**, que es la que la §8 de la fase te manda a buscar acá:

- https://developer.chrome.com/docs/devtools/javascript/source-maps — cómo DevTools resuelve un `.map`, dónde lo busca y qué hace cuando no lo encuentra. ⚠️ Enlace no verificado al cierre; si la ruta cambió, busca *"source maps"* en la documentación de Chrome DevTools.
- https://sourcemaps.info/spec.html — la especificación del formato, para leer el `"file"` y el `"sources"` de un `.map` sabiendo qué significan. Se consulta una vez en la vida y es la que convierte el paso 2 en algo que puedes explicar.
- https://v8.angular.io/cli/build — las opciones de build del CLI 8, incluida `sourceMap`. ⚠️ Enlace no verificado al cierre; si `v8.angular.io` no responde, la alternativa es el `ng build --help` de tu propia instalación, que es la fuente exacta de tu versión.
