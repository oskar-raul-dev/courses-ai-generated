# 🧰 Preparaciones de los incidentes
## Tutorial Angular 8 — Laboratorio clínico

Este documento **no lo lee el estudiante**. Es material de autoría, como el bloque
📌 de cada fase: contiene el **estado roto** de cada incidente del cuaderno, o sea
exactamente la respuesta que el estudiante tiene que encontrar por su cuenta.

> ⚠️ **Quien vaya a resolver el cuaderno no abre este archivo.** Abrirlo es peor
> que abrir la pista 3: la pista 3 te deja la pregunta cuya respuesta es la causa;
> esto te deja el `git diff`. Si estás haciendo el curso, cierra la pestaña.

**Por qué existe.** La §5 de
[`formato-cuaderno-incidentes.md`](formato-cuaderno-incidentes.md) define **cómo**
llega el sistema roto a la máquina del estudiante —un flag del caos, un
`db.incidente-NN.json`, o una rama `incidente/NN`—, y los veintiún enunciados usan
ese mecanismo. Lo que no estaba escrito en ninguna parte era **el contenido**: qué
línea rompe cada rama y qué registros lleva cada archivo de datos. Sin eso, trece
de los veintiún incidentes se quedaban en la línea del `git checkout` o del `cp`.

**Quién lo aplica.** El curso se trabaja sin instructor, así que hay dos formas y
las dos son legítimas:

- **El estudiante, antes de empezar el mes.** Prepara las nueve ramas y los tres
  archivos de datos de una sentada, sin leer las secciones "Qué se rompe" más allá
  de lo necesario para aplicarlas, y no vuelve a abrir este archivo. Es menos
  limpio de lo que parece —vas a ver el diff— pero funciona sorprendentemente bien:
  un mes después, en medio de un ticket vago, nadie se acuerda de qué línea movió.
- **Quien coordine el onboarding**, si hay alguien. Deja las ramas y los datos
  listos en el repositorio del equipo y el estudiante sólo hace `git checkout` y
  `cp`. Es la forma buena.

---

## Índice

- [1. Cómo se usa este documento](#1-cómo-se-usa-este-documento)
- [2. Mapa: qué necesita cada incidente](#2-mapa-qué-necesita-cada-incidente)
- [3. Las nueve ramas](#3-las-nueve-ramas)
- [4. Los tres `db.incidente-NN.json`](#4-los-tres-dbincidente-nnjson)
- [5. El que sólo necesita un comando de arranque](#5-el-que-sólo-necesita-un-comando-de-arranque)
- [6. Verificar que la preparación sirve](#6-verificar-que-la-preparación-sirve)
- [⚠️ Advertencias](#️-advertencias)

---

## 1. Cómo se usa este documento

Cada receta trae cuatro cosas y siempre las mismas:

1. **De dónde sale** — el tag de la fase, con el slug completo.
2. **Qué archivo se toca** — la ruta exacta dentro del proyecto.
3. **El cambio** — el antes y el después, en el estilo del archivo que se toca:
   TS-0 heredado, `any` tolerado, reducers en `switch`, `.bind(this)` en
   `subscribe` y arrow dentro de `pipe`.
4. **Cómo comprobar que la preparación quedó bien** — el síntoma que el estudiante
   tiene que ver. Una preparación que no reproduce el síntoma es peor que ninguna:
   manda a alguien a investigar un bug que no está.

El cambio es siempre **el mínimo que produce el síntoma**. Nada de reescribir un
archivo entero ni de sembrar tres bugs a la vez: una línea movida, un operador
cambiado, un selector mal escrito. Si una receta te pide tocar dos sitios, es
porque el síntoma los necesita a los dos, y lo dice.

> 🧭 **El repositorio del estudiante es suyo.** Estas ramas salen de los tags que
> él mismo puso al cerrar cada fase, así que el contenido depende de su código. Si
> alguien resolvió un ejercicio de forma distinta, la línea a tocar puede verse
> diferente — el `grep` de cada receta la encuentra igual.

---

## 2. Mapa: qué necesita cada incidente

| ID | Preparación | Artefacto |
|---|---|---|
| 01 | rama | `incidente/01` |
| 02 | rama | `incidente/02` + `mock/cors-origin.js` |
| 03 | rama | `incidente/03` |
| 04 | **ninguna** | la deuda vive en el código de la Fase 2 |
| 05 | **ninguna** | dos pestañas y el logout |
| 06 | flag de caos | `CHAOS=malformed` |
| 07 | datos | `db.incidente-07.json` |
| 08 | flag de caos | `CHAOS=fail=500@30` |
| 09 | rama | `incidente/09` |
| 10 | rama + flag | `incidente/10` + `CHAOS=latency=3000` |
| 11 | datos | `db.incidente-11.json` |
| 12 | **ninguna** | lo siembra `npm run seed` a propósito |
| 13 | flag + dos sesiones | `CHAOS=latency=3000` |
| 14 | **ninguna** | el orden de los actos es la preparación |
| 15 | rama | `incidente/15` |
| 16 | **ninguna** | la deuda vive en el código de la Fase 10 |
| 17 | datos | `db.incidente-17.json` |
| 18 | rama | `incidente/18` |
| 19 | comando de arranque | `docker run` con las variables de UAT |
| 20 | rama | `incidente/20` |
| 21 | rama | `incidente/21` |

**Nueve ramas, tres archivos de datos, un comando.** Los tres flags de caos no
necesitan preparación —son los que construye la Fase 4— y los seis restantes se
reproducen con el proyecto tal como quedó escrito, que es justamente lo que los
hace incómodos: no hay nada que "poner mal".

---

## 3. Las nueve ramas

### `incidente/01` — el puerto que no escucha nadie

**Sale de:** `fase-00-setup-hola-mundo`
**Archivo:** `src/app/patient-intake/patient-intake.component.ts`

```diff
-    this.http.post('http://localhost:3000/patients', this.patient)
+    this.http.post('http://localhost:3001/patients', this.patient)
```

```bash
grep -n "localhost:300" src/app/patient-intake/patient-intake.component.ts
```

**Queda bien si:** al enviar el formulario, la pantalla dice *"No se pudo registrar
el paciente"*, la consola imprime un `HttpErrorResponse` con `status: 0`, Network
muestra `(failed)` en unos pocos milisegundos, y **la terminal del mock no imprime
ninguna línea**. Esa última es la que separa el 01 del 02.

---

### `incidente/02` — el origen que el mock no autoriza

**Sale de:** `fase-00-setup-hola-mundo`
**Archivos:** uno nuevo, `mock/cors-origin.js`

json-server 0.16.3 pone `Access-Control-Allow-Origin: *` de fábrica, así que para
que haya un bloqueo hay que quitarle esa generosidad. Se hace con un middleware,
que es la forma en que un equipo real lo habría hecho:

```javascript
// mock/cors-origin.js
// "Para que esto se parezca más a producción": un único origen permitido,
// escrito a mano. Quien lo agregó desarrolla escribiendo localhost.
module.exports = function (req, res, next) {
  res.header('Access-Control-Allow-Origin', 'http://localhost:4200');
  res.header('Access-Control-Allow-Headers', 'Content-Type');
  next();
};
```

Y el arranque que lo carga, que es el que va en el enunciado:

```bash
npx json-server --watch db.json --port 3000 --middlewares mock/cors-origin.js
```

> ⚠️ El middleware de json-server corre **antes** que su CORS por defecto, así que
> el header queda con el valor restringido y no con el comodín. Compruébalo con
> `curl -s -D - -o /dev/null -H "Origin: http://127.0.0.1:4200" http://localhost:3000/patients`
> antes de dar la preparación por buena.

**Queda bien si:** abriendo la aplicación en `http://127.0.0.1:4200` el alta falla
con `status: 0`, la consola nombra la política de CORS y los dos orígenes, **y la
terminal del mock sí imprime la línea de la petición con un `201`** — el paciente
queda guardado en `db.json`. Abriendo en `http://localhost:4200`, todo funciona.

---

### `incidente/03` — el arreglo que se rellena en su sitio

**Sale de:** `fase-01-estructura-base-ngrx`
**Archivo:** `src/app/patients/store/patients.reducer.ts`

```diff
     case PatientsActions.loadPatientsSuccess.type:
-      return { ...state, loading: false, items: action.patients };
+      // "Reusar el arreglo para no crear basura": el contenido cambia y la
+      // REFERENCIA no, así que el selector memoizado no emite nunca.
+      state.items.length = 0;
+      action.patients.forEach(function (p: any) { state.items.push(p); });
+      return { ...state, loading: false, error: null };
```

**Queda bien si:** con la aplicación abierta en `/patients`, editas el `fullName`
de un paciente directamente en `db.json`, pulsas el botón de recargar de la lista
**sin refrescar el navegador**, y la tabla sigue mostrando el nombre viejo — pero
el panel Diff de Redux DevTools muestra el nombre nuevo dentro del estado. Con F5,
el nombre nuevo aparece.

> 💡 El detalle que hace este incidente 🟡 y no 🟢 es que el reducer **sigue
> devolviendo un objeto raíz nuevo**. Si al aplicar la receta lo cambias por
> `return state;`, acabas de escribir el 🧨 de la Fase 1 y el incidente pierde su
> gracia.

---

### `incidente/09` — el selector que devuelve todos

**Sale de:** `fase-05-pacientes`
**Archivo:** `src/app/patients/patient-list/patient-list.component.ts`

```diff
   ngOnInit() {
-    this.store.select(PatientsSelectors.selectFilteredPatients).subscribe(function (this: PatientListComponent, patients) {
+    // Alguien "ordenó" el componente y dejó el selector de la Fase 1.
+    this.store.select(PatientsSelectors.selectAllPatients).subscribe(function (this: PatientListComponent, patients) {
       this.dataSource = patients;
```

**Queda bien si:** das de baja a un paciente desde la tabla, el `db.json` muestra
`"active": false` para ese registro, y el paciente **sigue apareciendo en la
tabla** después de recargar la lista. El filtro por texto sigue funcionando sobre
todos, incluidos los inactivos.

---

### `incidente/10` — la escritura que se cancela

**Sale de:** `fase-05-pacientes`
**Archivo:** `src/app/patients/store/patients.effects.ts`

```diff
   createPatient$ = createEffect(function (this: PatientsEffects) {
     return this.actions$.pipe(
       ofType(PatientsActions.createPatient),
-      mergeMap((action: any) => {
+      switchMap((action: any) => {
         return this.patientsService.createPatient(action.patient).pipe(
```

Y el import, que si no el build falla y la preparación se nota antes de tiempo:

```diff
-import { map, mergeMap, catchError, timeout, withLatestFrom } from 'rxjs/operators';
+import { map, mergeMap, switchMap, catchError, timeout, withLatestFrom } from 'rxjs/operators';
```

> 📝 Los comentarios que la Fase 5 dejó encima de ese `mergeMap` —los que explican
> por qué no es `switchMap`— **se dejan tal cual**. Un legacy real está lleno de
> comentarios que contradicen al código de abajo, y encontrarlo es parte de la
> lección.

**Queda bien si:** con `CHAOS=latency=3000`, das de alta a un paciente y sin
esperar das de alta a otro; en Network una de las dos peticiones queda
`(canceled)`, el log de acciones muestra **dos** `Create Patient` y **un solo**
`Create Patient Success` sin ningún `Failure`, y en `db.json` aparece un solo
registro nuevo.

---

### `incidente/15` — la fuente que se registra tarde

**Sale de:** `fase-09-entrega-pdf`
**Archivo:** `src/app/reports/report.service.ts`

```diff
     var doc = new (jsPDF as any)();
-
-    // Registrar la fuente latina ANTES de escribir.
-    registerLatinFont(doc);
-
     var t = this.translate;

     doc.setFontSize(16);
     doc.text(t.instant('report.title'), 20, 20);
+
+    // Movido acá "para agrupar la configuración". Llega tarde.
+    registerLatinFont(doc);
```

**Queda bien si:** con la aplicación en francés, el PDF sale con el **título** con
símbolos raros donde van los acentos y el **cuerpo** bien. Si se rompe todo el
documento, moviste el registro demasiado abajo o lo borraste: el síntoma de este
incidente es el parcial, y el total es otro caso (el del `.ttf` que no viajó).

---

### `incidente/18` — el estado de prueba que se comparte

**Sale de:** `fase-12-testing-coverage`
**Archivo:** `src/app/patients/store/patients.selectors.spec.ts`

Acá **no hay que romper nada**: el `describe` de selectores ya declara su `state`
fuera del `beforeEach`, tal como lo escribió la Fase 12. Lo único que falta es el
test que lo detona, agregado al final del mismo `describe`:

```typescript
  // Agregado "para cubrir el orden alfabético". Ordena EN SU SITIO.
  it('ordena la lista por nombre', function () {
    var ordered = state.items.sort(function (a: any, b: any) {
      return a.fullName < b.fullName ? -1 : 1;
    });
    expect(ordered[0].fullName).toBe('Ana Ruiz');
  });
```

**Queda bien si:** la suite falla **a veces** —no siempre— en
`selectFilteredPatients filtra por texto sobre los activos`, y fijando la semilla
de Jasmine en `karma.conf.js` el fallo se vuelve reproducible. Si te falla en todas
las corridas, el `random` de Jasmine está apagado en tu config y el incidente
pierde la mitad de la lección: enciéndelo (`client: { jasmine: { random: true } }`).

> 💡 Busca una semilla que lo reproduzca y **anótala en la receta de tu equipo**.
> La del enunciado (`41287`) es de ejemplo: el orden depende de cuántos specs tenga
> la suite de cada estudiante.

---

### `incidente/20` — el `try_files` que falta

**Sale de:** `fase-13-build-despliegue`
**Archivo:** `nginx.conf`

```diff
   location / {
-    try_files $uri $uri/ /index.html;
+    # "Simplificado" por alguien que no sabía para qué estaba esa línea.
+    index index.html;
   }
```

Los otros dos `location` —el del `config.json` y el de `assets/i18n/`— **se dejan
intactos**. El del i18n tiene su propio `try_files $uri =404;` y quitarlo también
sembraría un segundo bug que el enunciado no pide.

**Queda bien si:** construyendo la imagen y levantándola, la aplicación carga por
la raíz, navega bien por el menú, y **al recargar en `/patients/42/orders` sale el
404 de nginx**. En Network, la petición fallida tiene `Type: document`.

---

### `incidente/21` — la foto de la ruta

**Sale de:** `fase-07-muestras-custodia`
**Archivo:** `src/app/samples/sample-timeline/sample-timeline.component.ts`

```diff
   ngOnInit() {
-    this.route.paramMap.subscribe(function (this: SampleTimelineComponent, params) {
-      this.orderId = Number(params.get('orderId'));
-      this.store.dispatch(SamplesActions.loadSamples({ orderId: this.orderId }));
-    }.bind(this));
+    // "No hace falta un observable para leer un parámetro."
+    this.orderId = Number(this.route.snapshot.paramMap.get('orderId'));
+    this.store.dispatch(SamplesActions.loadSamples({ orderId: this.orderId }));
```

El comentario de la fase que explica por qué es `paramMap` y no `snapshot` se
borra con la línea: si se queda, la pista 3 sobra.

**Queda bien si:** navegando **por la aplicación** de `/orders/101/samples` a
`/orders/102/samples`, la URL cambia, la lista no, y en Network no sale ningún
`GET` de muestras nuevo. Con F5 sobre la segunda orden, todo correcto.

---

## 4. Los tres `db.incidente-NN.json`

Los tres se construyen igual: se parte de un `db.json` recién sembrado y se cambian
**sólo** los registros que el incidente necesita. Nada de un archivo escrito a
mano desde cero — los números del resto del sistema tienen que seguir cuadrando.

```bash
npm run seed
cp db.json db.incidente-NN.json
# y se editan a mano los registros de abajo
```

> ⚠️ **Los ids son los de tu semilla.** El `seed.js` es determinista, así que los
> ids se repiten entre corridas de la misma fase — pero si un estudiante resolvió
> un ejercicio que cambia la cantidad de muestras, los suyos pueden diferir. Los
> enunciados nombran ids concretos (`501`, `9003`, `4021`); si en tu semilla son
> otros, ajusta el enunciado o ajusta el dato, pero que coincidan.

### `db.incidente-07.json` — el crítico del sábado por la noche

**Lo que cambia:** una muestra tomada en el borde exacto de la vigencia, y su
resultado crítico.

```jsonc
// samples — la muestra 612
{
  "id": 612,
  "orderId": 4102,
  "status": "processed",
  "collectedBy": "analista1",
  "collectedAt": "2019-05-31T20:15:00-05:00",   // ← sábado, 20:15 local = 01:15Z del 1 de junio
  "receivedBy": "analista1",
  "receivedAt": "2019-05-31T20:40:00-05:00",
  "processedBy": "analista1",
  "processedAt": "2019-05-31T21:10:00-05:00"
}

// results — el potasio crítico
{
  "id": 9102,
  "sampleId": 612,
  "analyte": "potassium",
  "value": 6.8,
  "unit": "mmol/L",
  "status": "preliminary",
  "rangeVersionApplied": null
}

// referenceRanges — dos versiones de potasio con el borde en el 1 de junio
{ "id": 31, "analyte": "potassium", "version": 1,
  "low": 3.5, "high": 5.5, "criticalLow": 2.5, "criticalHigh": 7.0,
  "effectiveFrom": "2019-01-01T00:00:00-05:00",
  "effectiveTo":   "2019-05-31T23:59:59-05:00" },
{ "id": 32, "analyte": "potassium", "version": 2,
  "low": 3.5, "high": 5.1, "criticalLow": 2.8, "criticalHigh": 6.5,
  "effectiveFrom": "2019-06-01T00:00:00-05:00",
  "effectiveTo":   null }
```

**El mecanismo:** con la v1 vigente (la que de verdad le tocaba), 6.8 está **por
debajo** del `criticalHigh` de 7.0 → sale fuera de rango pero **no crítico**. Con la
v2, que es la que elige la comparación en UTC, el `criticalHigh` baja a 6.5 y 6.8
**sí** es crítico. Los dos veredictos son defendibles y sólo uno es el correcto,
que es exactamente lo que hace al incidente incómodo.

**Queda bien si:** abriendo el resultado 9102 se ve una marca distinta de la que
daría la norma que le tocaba, y
`selectActiveRange(ranges, 'potassium', '2019-05-31T20:15:00-05:00').version`
devuelve `2`. Con la misma fecha a las 12:15 devuelve `1`.

### `db.incidente-11.json` — la custodia con el hueco

**Lo que cambia:** una sola muestra, a la que se le quitan dos campos.

```jsonc
// samples — la muestra 501
{
  "id": 501,
  "orderId": 4021,
  "status": "processed",
  "collectedBy": "analista1",
  "collectedAt": "2019-09-02T10:05:00-05:00",
  // receivedBy y receivedAt: BORRADOS, no puestos en null.
  "processedBy": "analista1",
  "processedAt": "2019-09-02T16:40:12.418-05:00"
}
```

Y **un par más con el mismo patrón**, para que el recuento del enunciado tenga
sentido: el estudiante tiene que poder contestar *"¿cuántas más hay?"* con un
número mayor que uno. Tres o cuatro es suficiente, todas con `collectedAt` de la
misma semana de 2019 — que es lo que sostiene la hipótesis de la migración.

> 🧭 **Se borran los campos, no se ponen en `null`.** `custodyEvents()` empuja el
> evento si el campo tiene valor, así que las dos formas producen el mismo hueco en
> pantalla; pero un `null` explícito parece una decisión y un campo ausente parece
> un dato que nunca existió. La segunda es la historia que cuenta el incidente.

**Queda bien si:** la línea de custodia de la muestra 501 muestra *Recogida* y
*Procesada* sin *Recibida*; el estado imposible **sobrevive a `npm run seed`**
(porque el estudiante está sobre el `db.incidente-11.json` copiado, no sobre su
semilla); y en el log de acciones **no aparece ningún** `[Samples] Transition
Sample` para esa muestra.

### `db.incidente-17.json` — el asiento del sábado por la noche

**Lo que cambia:** se agregan asientos a `auditLog` y el resultado que citan.

```jsonc
// results — el resultado que aparece firmado
{
  "id": 9003,
  "sampleId": 88,
  "analyte": "glucose",
  "value": 97,
  "unit": "mg/dL",
  "status": "validated",
  "validatedBy": "analista1",
  "validatedAt": "2019-09-07T21:04:10.887-05:00",   // ← sábado, 21:04
  "rangeVersionApplied": 2
}

// auditLog — el asiento que la coordinadora le mandó a la analista
{
  "id": "c4e8b1a2",
  "timestamp": "2019-09-07T21:04:11.002-05:00",
  "actor": "analista1",
  "action": "[Results] Validate Result Success",
  "entityType": "result",
  "entityId": "9003",
  "before": null,
  "after": { "id": 9003, "status": "validated", "validatedBy": "analista1" }
}
```

Conviene sembrar además, en la misma sesión, **dos o tres asientos más de esa
noche** con el mismo actor: refuerzan que no fue un clic suelto y le dan al
estudiante material para la comprobación del reloj (comparar todos los timestamps
de la sesión y ver si están corridos en bloque o sólo uno).

**Queda bien si:** la consulta
`curl "http://localhost:3000/auditLog?entityId=9003&_sort=timestamp"` devuelve el
asiento, y el `validatedAt` del resultado y el `timestamp` del asiento difieren en
milisegundos — porque los escribió la misma máquina, que es el punto entero del
incidente.

---

## 5. El que sólo necesita un comando de arranque

### Incidente 19 — el contenedor con las variables de UAT

No hace falta rama ni datos: el código es correcto y la imagen también. Lo que se
reproduce es **el arranque**, y el comando está en el propio enunciado:

```bash
docker build -t lab-frontend:inc19 .
docker run -d --name lab-frontend-prod -p 8080:80 \
  -e API_URL=http://uat.interno:3000 \
  -e ENVIRONMENT_NAME=uat \
  -e APP_TIME_ZONE=America/Bogota \
  -e FEATURE_DELIVERY_PDF=true \
  lab-frontend:inc19
```

**Queda bien si:** `assets/config.json` se sirve con `"environmentName":"uat"`, la
primera línea de `docker logs` dice `ambiente: uat`, y la pantalla de pacientes
queda cargando y después falla —porque `http://uat.interno:3000` no resuelve desde
la máquina del estudiante, que es justamente el efecto buscado—.

> 💡 Si quieres que falle de forma más parecida a la realidad —un backend que
> responde pero con otros datos— levanta un segundo mock en otro puerto y apunta
> `API_URL` ahí. No es necesario para el diagnóstico y añade quince minutos de
> montaje.

---

## 6. Verificar que la preparación sirve

Antes de dar por lista cualquiera de las trece, la misma comprobación de tres
pasos. Salteársela es cómo se manda a alguien a investigar un bug que no está:

1. **Reproduce el síntoma exactamente como lo describe el ticket.** No "algo
   parecido": el ticket dice qué se ve y dónde. Si no lo ves, la preparación está
   mal aplicada, no el enunciado.
2. **Comprueba que la pista 1 lleva a algún sitio.** Las pistas están escritas
   contra un estado concreto; si la pista 1 dice "mira el log de acciones" y en tu
   preparación no hay acciones que mirar, sobra una o falta la otra.
3. **Vuelve al estado limpio y confirma que el síntoma desaparece.** Es la mitad
   que casi nadie hace, y es la que demuestra que el síntoma lo produce tu cambio y
   no otra cosa que había quedado por ahí.

```bash
# Volver, según la forma de preparación:
git checkout master            # de una rama
npm run seed                   # de un db.incidente-NN.json
npm run mock                   # de un flag de caos (sin la variable)
docker rm -f lab-frontend-prod # del contenedor del 19
```

---

## ⚠️ Advertencias

**Este archivo no se enlaza desde el cuaderno.** A propósito. El cuaderno enlaza
las piezas forenses y los apéndices porque son material de consulta legítimo
durante una investigación; esto es la respuesta, y un enlace a un clic de distancia
es una tentación que no hace falta poner.

**Las trece preparaciones no se aplican todas a la vez.** Se aplica la del
incidente que se va a trabajar y se revierte al terminar. Dos preparaciones
simultáneas producen síntomas que ningún enunciado describe, y el estudiante se
pasa la tarde persiguiendo una interacción que no existe en el material.

**Si una receta ya no encaja con el código, manda el código.** Estas ramas salen
del repositorio del estudiante, que es suyo y que pudo resolver los ejercicios de
otra forma. Cuando el `diff` no aplique limpio, lo que hay que conservar es **el
mecanismo** —qué se rompe y por qué produce ese síntoma—, no las líneas literales.

**Y la regla de oro del que prepara:** si al aplicar una receta el síntoma sale
más escandaloso de lo que dice el ticket —un error en rojo donde el ticket habla de
silencio, o una pantalla rota donde el ticket habla de un dato equivocado—, te
pasaste. Casi todos estos incidentes valen por lo **discretos** que son; un bug que
grita se diagnostica solo y no entrena nada.

---

> 🏷️ **Este documento no lleva tag propio.** Es material de autoría, como el resto
> de `prompts/`, y lo que salga de aplicarlo va en las ramas `incidente/NN` que él
> mismo describe — cuya convención, junto con el par
> `inc/<ID>/<slug>-roto` / `-fix`, está en
> [`00-convencion-de-git-y-tags.md`](../00-convencion-de-git-y-tags.md).
