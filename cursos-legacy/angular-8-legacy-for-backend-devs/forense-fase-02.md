# 🕵️ Forense Fase 02 — La clave en crudo y la fecha que no cambia de idioma

> Pieza forense de la [**Fase 2 — Internacionalización**](./02-i18n.md) · Recorrido: ~40 min · [Índice del track](./forense-master.md)
> Herramientas: Network (filtro `i18n`) · el **cuerpo** de la respuesta · la consola · `LOCALE_ID`
> Síntoma que cubre: dos fallos que se ven parecidos, se reportan igual, y no comparten ni una línea de causa.

Dos tickets, dos rutas. El primero **se ve roto** y tiene cuatro causas posibles: el trabajo es descartarlas en el orden correcto, porque hacerlo al revés cuesta dos horas. El segundo **no se ve roto en absoluto** —la fecha se muestra, tiene formato válido, es la fecha correcta— y por eso llega como el peor ticket posible.

---

## 🎫 Los tickets

> **T-1:** *"Puse la aplicación en francés y en una tarjeta sale escrito `patients.pendingOrders_zero`. Como un código."*
>
> **T-2:** *"Las fechas se ven raras."*

**Reportados por:** una analista que trabaja con la interfaz en francés
**Ambiente:** UAT

T-2 es lo más cerca de inútil que puede estar un ticket, y aun así es correcto: la analista no tiene el vocabulario para decir *"el mes está en español mientras el resto de la tarjeta está en francés"*. Traducirlo es parte del trabajo.

---

## 🧭 Ruta 1 — La clave que sale cruda

Cuatro pasos y cuatro causas, en el orden en que cuestan. **El orden es toda la lección de esta ruta**, porque las cuatro producen exactamente la misma pantalla y sólo la primera es obvia.

### Paso 1 — ¿Llegó el archivo?

Network → filtro `i18n` → recarga con la caché deshabilitada.

```
Name       Status  Type  Size    Time
fr.json    200     xhr   1.1 kB  8 ms
```

**Qué descarta.** Un `200` mata la causa más común y la más barata: el archivo existe, la ruta del `TranslateHttpLoader` es correcta y llegó a tiempo. Si en cambio ves un **404**, ahí terminó la investigación: la ruta de `./assets/i18n/` no coincide con dónde está el archivo, o el archivo no se copió al build —y eso último sólo se ve en producción, nunca en `ng serve`.

Y si no ves **ninguna** petición de `i18n`, mira `es.json` en la lista: puede que el idioma activo no sea el que crees, que es el paso 4. No hagas ese paso todavía; es más caro que los dos siguientes.

> ⚠️ **Un 404 de diccionario no rompe la aplicación, y eso es peor.** El `catch` de `initialize()` deja que la promesa resuelva igual, así que la aplicación arranca con todo en crudo en vez de quedarse en blanco. Es la decisión correcta y hace que el fallo se reporte como "salen códigos raros" en vez de "no abre".

### Paso 2 — ¿Está la rama, en **la respuesta**?

Ésta es la trampa de la ruta, y es donde se pierden las dos horas. No abras `src/assets/i18n/fr.json` en el editor: abre **la pestaña Response de esa petición**. En desarrollo suelen ser el mismo archivo; en producción son dos cosas distintas —el del repositorio y el que el servidor está sirviendo—, y el bug vive justo en esa diferencia.

```json
{"shell":{…},"patients":{"title":"Patients","documentId":"Document","lastOrder":"Dernière commande","pendingOrders_one":"1 commande en attente","pendingOrders_other":"{{count}} commandes en attente","empty":"Aucun patient enregistré","retry":"Réessayer"}}
```

Busca la clave exacta del síntoma. `pendingOrders_one` está, `pendingOrders_other` está, y `pendingOrders_zero` **no está**.

**Qué descarta.** Con eso la causa está localizada y es de dato, no de código: la clave falta en el diccionario servido. Muere la hipótesis del typo en la plantilla —la clave que la plantilla pide es la que estás buscando y las otras dos hermanas sí funcionan— y muere la del idioma equivocado, porque este archivo es el francés y se está usando.

### Paso 3 — Si la rama sí está: el typo

Si la clave aparece en la respuesta y aun así sale cruda, entonces la plantilla está pidiendo otra cosa. No hay compilador que valide una cadena de traducción, así que la única forma es comparar las dos:

```bash
grep -rn "pendingOrders" src/app/
# src/app/patients/patient-list/patient-list.component.ts:  return 'patients.pendingOrders_zero';
```

**Qué descarta.** Un guion bajo de más, un plural, una mayúscula: la cadena de la plantilla y la del diccionario tienen que ser idénticas hasta el último carácter. Es el mismo patrón que la `createFeatureSelector('patients')` de la Fase 1 y que el `patientForm.get('documentID')` de la Fase 5, y no es coincidencia: **en el Angular de esta época, todo identificador que es un `string` es una bomba sin validación**.

### Paso 4 — El idioma activo, que puede no ser el que crees

El más caro de los cuatro porque exige la consola, y por eso va último. Con la aplicación abierta y el idioma en francés:

```js
// En la consola, sobre la instancia de TranslateService que tengas a mano.
translate.currentLang
// "fr"
```

**Qué descarta.** Si devuelve `'fr'`, el idioma activo es el correcto y la causa está en los pasos 1 a 3. Si devuelve `'es'` o `undefined` mientras el selector del toolbar muestra francés, tienes **dos verdades simultáneas** y el bug es otro completamente distinto: o `setLanguage` rechazó el idioma en silencio —lo hace, a propósito, cuando no está en `SUPPORTED_LANGUAGES`—, o hay un módulo con su propia instancia del servicio.

Ese último caso tiene una firma inconfundible y vale la pena reconocerla: **el toolbar cambia de idioma y la pantalla no**. Es `TranslateModule.forChild()` sin `isolate: false` en un módulo diferido, que se lleva su propia instancia con su propio idioma activo. Se ve navegando entre dos rutas, nunca en una sola.

### Paso 5 — Por qué el fallback no lo tapó

Legítimo preguntarlo: `setDefaultLang('es')` existe precisamente para cubrir claves ausentes, y aquí no cubrió nada. La razón es de las que sólo se aprenden habiéndolas sufrido: **el fallback resuelve contra el árbol por defecto sólo si ese árbol ya está cargado en memoria**, y en una sesión que arrancó directamente en francés, `es.json` nunca se pidió.

Compruébalo en el mismo Network del paso 1: si sólo aparece `fr.json`, el español no está cargado y no hay contra qué caer. Cambia a español y vuelve a francés sin recargar, y verás que la clave **deja de salir en crudo** — porque ahora sí hay árbol de respaldo. Ése es el detalle que hace que el bug parezca intermitente: depende de por dónde entró el usuario.

---

## 🧭 Ruta 2 — La fecha que no cambia de idioma

Tres pasos, y el primero es traducir el ticket.

### Paso 1 — Qué está en francés y qué no, en la misma tarjeta

Pon la interfaz en francés y lee una tarjeta de paciente entera, campo por campo:

```
Patients
Document: CC-1032456789
1 commande en attente
Dernière commande: 2 septiembre 2019, 8:15:00
```

Todo en francés menos el mes. **Qué descarta.** Eso no es "las fechas se ven raras": es que **una parte de la pantalla escucha al selector de idioma y otra no**. Y la línea divisoria es exacta: lo que pasa por el pipe `translate` cambia; lo que pasa por los pipes de `@angular/common` —`date`, `decimal`, `currency`— no.

### Paso 2 — Las dos verdades, en la consola

```js
translate.currentLang
// "fr"
```

Y al mismo tiempo, el pipe `date` está formateando en español. **Qué descarta.** Ninguna de las dos está rota: las dos hacen exactamente lo que se les configuró. `LOCALE_ID` se resolvió **una sola vez, al arrancar**, con el valor fijo `'es'` que el `i18n.module.ts` le provee, y los pipes de `@angular/common` leen ese token y nada más. No conocen `@ngx-translate` y no tienen por qué: son dos sistemas distintos que nadie conectó.

Dos verdades simultáneas y contradictorias, que es la forma exacta de este bug.

### Paso 3 — Que el locale exista, que es lo otro que puede fallar

Antes de proponer cualquier fix, confirma que el idioma tiene datos de locale registrados. Si alguien "arregla" esto poniendo `LOCALE_ID` en `'fr'` sin haber llamado a `registerLocaleData(localeFr, 'fr')`, el resultado no es un error claro:

```
ERROR Error: Missing locale data for the locale "fr".
```

O peor, según el pipe: una fecha en inglés, que nadie pidió y que parece un tercer bug.

**Qué descarta.** Con `registerLocaleData` en su sitio —y en esta fase lo está, para los tres idiomas— el token es lo único que queda por mover. La ruta termina acá: sabes dónde está el bug y sabes que **no tiene un fix barato**.

### Y por qué el fix no es trivial

Esto no es parte de la ruta, pero es lo que van a preguntarte apenas termines de diagnosticar. `LOCALE_ID` es estático por diseño en Angular 8. Sólo hay dos salidas reales:

- **Recargar la aplicación al cambiar de idioma**, reinyectando el token con el nuevo valor. Es un hotfix de una tarde y el usuario pierde el estado de la pantalla en cada cambio.
- **Dejar de usar los pipes nativos** y formatear contra el idioma activo. Es tocar todas las plantillas que muestren una fecha o un número.

Cuál elegir depende de cuántos usuarios franceses hay, y eso es una conversación de producto, no de código. Lo que sí es de tu incumbencia es llegar a esa conversación con el diagnóstico hecho y las dos opciones costeadas.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Causa | Dónde miras |
|---|---|---|
| Una clave en crudo, `200` en Network | la rama falta en el JSON **servido** | la pestaña Response, no el archivo del repo |
| Una clave en crudo, `404` en Network | ruta del loader, o el archivo no se copió al build | `dist/assets/i18n/` en producción |
| Todas las claves en crudo | ningún diccionario cargó; la aplicación arrancó degradada | el `catch` de `initialize()` hizo su trabajo |
| Una clave en crudo y sus hermanas bien | typo entre plantilla y diccionario | `grep` de la clave en `src/` |
| La clave sale cruda sólo si entras directo en ese idioma | el árbol de respaldo nunca se cargó | Network: ¿está `es.json`? |
| Parpadeo de claves crudas al arrancar | los componentes pintaron antes de que llegara el JSON | `APP_INITIALIZER`, y las rutas que cargan después |
| El toolbar cambia de idioma y la pantalla no | `forChild()` sin `isolate: false` | los `imports` del módulo diferido |
| El pipe `translate` no existe en una pantalla | falta `TranslateModule.forChild()` en ese módulo | los `imports` del feature module |
| Todo en francés menos la fecha | `LOCALE_ID` fijo; los pipes nativos no escuchan | el provider del `i18n.module.ts` |
| `Missing locale data for the locale "fr"` | falta `registerLocaleData` para ese idioma | el arranque del módulo de i18n |
| Cambias de idioma y no pasa absolutamente nada | idioma fuera de `SUPPORTED_LANGUAGES`: rechazo silencioso | `setLanguage`, que devuelve sin avisar |
| `ng serve` compila y `ng build --prod` falla con un metadato | `useFactory` como arrow anónima: el AOT no la serializa | `httpLoaderFactory`, que por eso es `export function` |

---

## ⚰️ Los callejones

**"Falta la traducción al francés."** Es lo que dice la pantalla y es cierto sólo en uno de los cuatro casos. Las otras tres veces la traducción existe: lo que falla es qué archivo se sirvió, cómo se escribió la clave, o qué idioma está activo de verdad. Aceptar el diagnóstico que propone el síntoma es exactamente lo que esta ruta entrena a no hacer.

**"El archivo del repositorio tiene la clave, así que está bien."** El archivo del repositorio no es el archivo servido. En `ng serve` casi siempre coinciden; en un contenedor con una imagen construida hace tres semanas, no. Mira la respuesta, siempre.

**"Hay que poner un `MissingTranslationHandler`."** Buena idea, y no es el diagnóstico. `@ngx-translate` no registra las claves que no encuentra: devuelve la clave y sigue, tan tranquilo. Un handler haría visible el problema en la consola —que es una mejora real y es material de ejercicio—, pero no cambia por qué falta la clave.

**"Las fechas están mal calculadas."** No lo están: la fecha es la correcta, el formato es válido y la zona horaria es la que se le pasó explícitamente al pipe. Lo único equivocado es el idioma en el que se escribe el mes. Un bug de **cálculo** de fechas sí existe en este curso, y es otro: es el borde de vigencia de la Fase 8, donde la comparación se resbala a UTC.

---

## 🧨 Deshacer

El recorrido es de lectura y no cambia nada del proyecto, con dos salvedades:

- Si agregaste `pendingOrders_zero` a `fr.json` para comprobar la teoría, decide si se queda. Añadirla es correcto y es el ejercicio 4 de la fase — pero entonces el síntoma deja de reproducirse y el resto de la ruta ya no se puede recorrer. Si quieres conservarla, guarda el archivo roto aparte antes.
- Si tocaste el provider de `LOCALE_ID` para ver qué pasaba, revierte: `git checkout -- src/app/core/i18n/i18n.module.ts`. Ese token es la deuda declarada de la fase y cambiarlo sin decidir la conversación de producto deja el proyecto en un estado que ninguna fase posterior asume.

También conviene limpiar el idioma persistido, que sobrevive a las recargas y va a confundirte en la siguiente investigación:

```js
localStorage.removeItem('lab.language');
```

---

## 🧠 El patrón transferible

> **Un texto que sale mal y un formato que sale mal son dos sistemas distintos.** En cualquier aplicación internacionalizada conviven al menos dos: el de las cadenas y el de los datos locales (fechas, números, moneda). Se configuran aparte, se cargan aparte, y fallan aparte. Antes de buscar la causa, decide de cuál de los dos es el síntoma — y la forma de decidirlo es mirar qué cambió y qué no dentro de la **misma** pantalla.

Y el segundo, que vale mucho más allá de la i18n: **el archivo del repositorio no es el archivo servido.** Cuando un dato de configuración —un diccionario, un `config.json`, un `.env`— parezca correcto en el editor y equivocado en pantalla, mira la respuesta HTTP antes que el editor. Es el mismo reflejo que la Fase 13 convierte en la tesis del curso.

**Incidentes del cuaderno que usan esta ruta:** el **04** —*"cambié a francés y la fecha sigue en español"*, que es la ruta 2 llegando como ticket.
**Amplía:** el [**Apéndice A07**](./a07-i18n.md) para el detalle de `@ngx-translate` 11, la pluralización y el `MissingTranslationHandler`, y la [**Fase 9**](./09-entrega-pdf.md) para cuando el mismo problema de acentos y locales llegue al PDF, donde no hay navegador que lo tape.
