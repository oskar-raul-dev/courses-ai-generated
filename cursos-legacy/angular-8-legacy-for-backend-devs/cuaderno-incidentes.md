# 📓 Cuaderno de incidentes

> Tutorial Angular 8 — Laboratorio clínico · Documento vivo · **14 horas** repartidas en el mes
> Se trabaja solo. El changelog es `git log -- cuaderno-incidentes.md`.

Este es el único archivo de incidentes del curso: acá están los enunciados, las
pistas, las soluciones y tu registro de cómo llegaste a cada una. Los veintiún
incidentes vienen escritos de antemano; lo que vas agregando tú es la parte de
abajo de cada entrada — tu reproducción, tus hipótesis, tu fix.

**El curso asume que lo haces sin instructor.** Por eso cada incidente trae su
solución adentro, colapsada. Ese es el trato: la solución está a un clic de
distancia y aun así abrirla antes de tiempo solo te perjudica a ti. El músculo
que este curso entrena —recibir un ticket vago y encontrar la capa culpable— no
se desarrolla leyendo respuestas correctas, igual que nadie aprendió a depurar
mirando a otro depurar.

---

## 🧭 Cómo se trabaja un incidente

> 🕵️ **Si no sabes por dónde empezar, no empieces por el editor.** El índice de
> síntomas transversal —el que cruza *"esto es lo que veo"* con *"empieza acá"*— está
> en [`forense-master.md`](forense-master.md) §3, y cada fase tiene su recorrido
> completo en `forense-fase-NN.md`. El cuaderno te da el ticket; el track forense te
> da el método para atacarlo.

Lees el ticket, reproduces, investigas, escribes tu diagnóstico en el bloque
"Tu investigación", y **recién entonces** abres la solución para compararla.
Si tu causa raíz coincide, perfecto. Si no coincide pero tu fix funciona,
también es información valiosa: anótalo, porque en producción va a pasar seguido.

Las pistas están escalonadas: la 💡 primera te dice dónde mirar, la segunda qué
mirar, la tercera casi te lo cuenta. Ábrelas en orden y solo cuando estés
realmente trabado — trabado quiere decir veinte minutos sin una idea nueva, no
cinco minutos de incomodidad.

### Cómo llega el sistema roto a tu máquina

Cada incidente dice en su «🔧 Preparación» cómo ponerse en el estado que hay que
diagnosticar, y hay exactamente tres formas. El orden no es casual: **se usa
siempre la más barata que sirva**, porque una preparación complicada es una excusa
para saltarse el incidente.

**1. Un flag del inyector de caos** (Fase 4), cuando el fallo es de red o de
respuesta. Es la preferida: no toca tu código, no toca tus datos, y se apaga
sola cuando reinicias el mock. `CHAOS=malformed npm run mock` y ya estás dentro
del incidente 06.

**2. Un `db.json` alterno**, cuando el bug está en el dato y no en el código —una
muestra con la custodia imposible, un resultado validado sin norma detrás—. Se
llaman `db.incidente-NN.json`, viven junto al `db.json`, y se activan copiando:
`cp db.incidente-11.json db.json`. Guarda el tuyo antes, o corre `npm run seed`
después para volver.

**3. Una rama de git**, y solo cuando haya que romper código. Se llaman
`incidente/NN`, salen del commit donde terminaste la fase correspondiente, y
traen el cambio mínimo que produce el síntoma: una línea movida, un operador
cambiado, un selector mal escrito. `git checkout incidente/03`. Ese commit de
partida es justamente el que etiquetaste al cerrar la fase, así que la rama se
crea sin buscar nada: `git checkout -b incidente/03 fase-01-estructura-base-ngrx`.

> 🧭 **La regla, y sirve más allá de este cuaderno:** cuando alguien te pida
> reproducir un bug, la primera pregunta es *"¿esto se reproduce con un flag, con
> un dato, o hace falta otro código?"*. Las tres respuestas llevan a
> investigaciones distintas, y averiguar cuál es te ahorra la mitad del camino
> antes de haber leído una línea.

Regla del archivo: se **agrega**, no se corrige. Una hipótesis que resultó falsa
no se borra, se marca como descartada con la evidencia que la tumbó. Dentro de
tres semanas, releer tus descartes es la mejor forma de ver cómo cambió tu
criterio.

### Convención de commits

El asunto del commit sigue este formato, para que `git log --oneline` se lea como
la línea de tiempo de tu investigación:

```
incidente(07): abre — resultados críticos sin alerta el sábado
incidente(07): repro — falla con TZ del navegador en UTC-5
incidente(07): hipótesis descartada — no es el effect, la acción sí se despacha
incidente(07): causa — comparación de fecha sin zona horaria en el selector
incidente(07): fix — normaliza a la TZ de la aplicación antes de comparar
incidente(07): cierre — test de regresión y post-mortem
```

Los verbos son fijos: `abre`, `repro`, `hipótesis`, `hipótesis descartada`,
`causa`, `fix`, `cierre`.

Commitea también los callejones sin salida. Un `git log` que muestra seis
commits de investigación y uno de fix es un registro honesto; uno que muestra
solo el fix no le sirve a nadie, y menos a ti dentro de seis meses.

Y como el fix de casi todos estos incidentes es de una o dos líneas, conviene
marcarlo además con el par de tags de
[`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md):
`inc/07/alerta-del-sabado-roto` con el síntoma reproducido y la regresión en
rojo, `inc/07/alerta-del-sabado-fix` con la causa raíz y el fix en verde. El
`git diff` entre los dos **es** el punto 5 del post-mortem, aislado del ruido de
la fase, y `git tag -n99 -l 'inc/*'` te devuelve el cuaderno entero sin abrir un
archivo. El ID es el que ya tiene reservado el índice de acá abajo, nunca uno
inventado.

> 💡 Para releer la historia de un incidente:
> `git log --oneline --grep "incidente(07)" -- cuaderno-incidentes.md`
> Para ver el archivo como estaba al cerrar la Fase 8:
> `git show <sha>:cuaderno-incidentes.md`

### Estados

| Estado | Significado |
|---|---|
| ⬜ Sin empezar | Todavía no lo tocaste |
| 🔴 Abierto | Leído, sin reproducir |
| 🟡 En análisis | Reproducido, causa raíz sin confirmar |
| 🟢 Cerrado | Fix aplicado y test de regresión pasando |
| ⚪ Descartado | No se reproduce, y está documentado por qué |

---

## 📋 Índice

Lo actualizas en el mismo commit que abre o cierra un incidente.

Los veintiún IDs quedaron reservados por las fases que los producen; el título es
el que va a llegar en el ticket, en palabras del usuario y no en lenguaje técnico.
**Los veintiún enunciados están escritos abajo**, cada uno con su preparación, sus
tres pistas plegadas y su solución de referencia. La columna de estado es tuya: un
⬜ quiere decir que todavía no lo tocaste, y el ID **nunca** se reasigna aunque un
incidente se retire.

| ID | Fase | Título | Categoría | Dif. | Estado |
|---|---|---|---|---|---|
| 01 | 0 | Guardé el paciente y la pantalla dice que no se pudo | Despliegue | 🟢 | ⬜ |
| 02 | 0 | En la máquina de al lado funciona y en la mía no | Integración | 🟢 | ⬜ |
| 03 | 1 | Cambié el paciente y la lista no se entera | Estado (store) | 🟡 | ⬜ |
| 04 | 2 | Cambié a francés y la fecha sigue en español | i18n | 🟡 | ⬜ |
| 05 | 3 | Cerré sesión en una pestaña y en la otra sigo adentro | UI | 🟡 | ⬜ |
| 06 | 4 | La pantalla de pacientes sale vacía y no dice nada | Integración | 🟡 | ⬜ |
| 07 | 8 | Los resultados críticos no avisan el fin de semana | Tiempo | 🟠 | ⬜ |
| 08 | 4 | A veces no carga | Integración | 🟡 | ⬜ |
| 09 | 5 | El paciente que di de baja sigue saliendo en la lista | Estado (store) | 🟡 | ⬜ |
| 10 | 5 | Guardo y a veces no se guarda | Concurrencia | 🟠 | ⬜ |
| 11 | 7 | La muestra figura procesada pero nunca se recibió | Máquina de estados | 🟠 | ⬜ |
| 12 | 8 | El resultado quedó validado pero sin norma detrás | Normativo | 🟡 | ⬜ |
| 13 | 8 | Dos analistas firmaron el mismo resultado | Concurrencia | 🟠 | ⬜ |
| 14 | 9 | El informe salió con un resultado que ya había cambiado | Estado (store) | 🟠 | ⬜ |
| 15 | 9 | Los acentos del informe en francés salen como símbolos raros | i18n | 🟡 | ⬜ |
| 16 | 10 | El dashboard se arrastra al final del turno | Performance | 🟠 | ⬜ |
| 17 | 11 | El log dice que yo validé ese resultado y yo no estaba ese día | Trazabilidad | 🟠 | ⬜ |
| 18 | 12 | El test pasa en mi máquina y falla en la de al lado | Testing | 🔴 | ⬜ |
| 19 | 13 | Desplegamos a PROD y le sigue hablando a UAT | Despliegue | 🔴 | ⬜ |
| 20 | 13 | Si recargo la página en cualquier pantalla, me da 404 | Despliegue | 🟠 | ⬜ |
| 21 | 7 | La lista no cambia al cambiar de orden | Estado (store) | 🟠 | ⬜ |

**Categorías:** máquina de estados · concurrencia · tiempo · normativo ·
trazabilidad · integración · performance · UI · estado (store) · i18n ·
despliegue · testing.

**Dificultad:** 🟢 fácil · 🟡 intermedio · 🟠 difícil · 🔴 muy difícil.

---

# 🧪 Incidentes

Ordenados por ID, que es también el orden sugerido: cada uno se puede resolver
con lo que sabes al terminar la fase indicada. Adelantarte a un incidente de la
Fase 11 estando en la 4 no es imposible, pero vas a pelear con herramientas que
todavía no conoces.

El ID nunca se reasigna.

---

## Incidente 01 — Guardé el paciente y la pantalla dice que no se pudo

> **Fase:** 0 · **Categoría:** Despliegue · **Dificultad:** 🟢
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 20-30 min · **Ruta forense:** [`forense-fase-00.md`](./forense-fase-00.md)

### 🎫 El ticket

> *"Registro un paciente y me dice que no se pudo. Así, sin más. Lo intenté tres
> veces con los mismos datos y las tres igual. Ayer funcionaba."*

**Reportado por:** auxiliar de recepción
**Ambiente:** desarrollo

### 🎯 Qué se te pide

Reproducir, decir **en qué mitad del viaje HTTP** está el problema —navegador o
servidor— antes de abrir un solo archivo, y aplicar el hotfix mínimo. Y contestar
la pregunta que el ticket no hace: por qué el mensaje de la pantalla no sirvió
para nada.

### 🔧 Preparación

Rama de git: hay que romper código, porque la causa vive en una línea del
componente. Sale del tag con el que cerraste la Fase 0.

```bash
git checkout -b incidente/01 fase-00-setup-hola-mundo
```

La rama trae un solo cambio de una línea. No la mires con `git diff` antes de
reproducir — eso es abrir la solución por la puerta de atrás.

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

El mensaje de la pantalla lo escribió una persona; el estado real de la petición
lo escribe el navegador. Empieza por la consola y por la pestaña Network, en ese
orden, y no abras el editor todavía.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

En el objeto de error de la consola hay dos campos que deciden la investigación
entera: uno dice si hubo respuesta y el otro dice contra qué se intentó hablar.
Lee el segundo **completo**, incluido el puerto.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿En qué puerto está escuchando el mock, según lo que imprime al arrancar? ¿Y
contra qué puerto está hablando la aplicación?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

La URL del `POST` está escrita a mano dentro del componente y apunta a un puerto
donde no hay nadie:

```
src/app/patient-intake/patient-intake.component.ts:41
  this.http.post('http://localhost:3001/patients', this.patient)
```

El mock escucha en el **3000**. La evidencia que lo cierra son dos campos del
`HttpErrorResponse` que imprime la consola:

```
[PatientIntake] falló el POST
HttpErrorResponse {status: 0, statusText: "Unknown Error",
url: "http://localhost:3001/patients", ok: false, …}
```

`status: 0` significa que **la petición nunca llegó a un servidor**. No que el
servidor la rechazara: que no hubo servidor. Network lo confirma desde la otra
herramienta, con `(failed)` sin código y un tiempo de 3 ms —rechazo inmediato, no
espera— y con `net::ERR_CONNECTION_REFUSED` en Headers → General. Y la terminal
del mock lo remata: **no hay ninguna línea de esa petición**, porque nunca llegó.

**Parche mínimo**

```typescript
// Un dígito. El viernes a las seis, esto es todo lo que se toca.
this.http.post('http://localhost:3000/patients', this.patient)
```

**La refactorización correcta** (que en Track A 💸 no se paga)

La dirección del backend no debería vivir en un componente. La **Fase 1** la mueve
a `environment.ts`, y la **Fase 13** la saca incluso de ahí, porque `environment`
se hornea en tiempo de compilación y no se puede cambiar sin recompilar —que es
la tesis del curso entera y el origen del incidente **19**. Este bug de una línea
es el primer eslabón de esa cadena: no ocurrió porque alguien escribiera mal un
número, ocurrió porque había un sitio donde escribirlo mal.

**Prueba de regresión**

Un test de componente no caza esto: el bug está en una constante, no en una
rama de código. Lo que sí lo caza es una verificación del propio ambiente, y en
esta fase se escribe como un spec del servicio que se añade en la **Fase 12**:

```typescript
// src/app/patients/patients.service.spec.ts (Fase 12)
it('apunta al puerto del mock declarado en el ambiente', function () {
  service.getPatients().subscribe();
  // La URL sale de environment, no de una cadena escrita a mano.
  var req = httpMock.expectOne(environment.apiUrl + '/patients');
  expect(req.request.method).toBe('GET');
  req.flush([]);
});
```

Mientras la URL viva en el componente, la única regresión posible es humana: la
**Prueba de fuego** de la Fase 0 —enviar el formulario y confirmar un `201` en
Network más una línea nueva en `db.json`—.

**Prevención**

Una sola fuente para la URL base. No es una mejora estética: cuando la dirección
está en un archivo, el error se comete una vez y se corrige una vez; cuando está
en cada componente, se comete tantas veces como componentes haya y no hay `grep`
que te avise de cuál falta.

**Por qué llegó a producción**

Porque el componente hacía exactamente lo que se le pidió el día que se escribió:
hablar con un mock local, un martes, para ver una pantalla funcionando. Nadie
tomó la decisión de acoplar la dirección del servidor al componente — simplemente
no tomó ninguna. Y el mensaje de error genérico hizo el resto: seis causas
distintas condensadas en una frase escrita en cinco segundos, que no descarta
ninguna. El sistema no falló al fallar; falló al **contar** el fallo.

**Si tu causa fue distinta a esta**

- Si concluiste **"el servidor rechazó los datos"**, el síntoma encaja —la
  pantalla lo sugiere— pero `status: 0` lo tumba: un rechazo es un `400` con
  cuerpo. Ningún servidor rechaza callando.
- Si concluiste **"es CORS"**, casi: CORS también da `status: 0`. Lo separa que
  CORS deja un mensaje explícito en consola nombrando la política **y deja línea
  en el log del mock**, porque la petición llegó. Acá no hay línea. Esa diferencia
  es el incidente **02**.
- Si lo arreglaste **arrancando el mock en el 3001**, funciona y es una respuesta
  legítima el viernes… hasta que llegue el siguiente que arranque el mock como
  dice el README. Anota por qué preferiste mover el servidor antes que el
  cliente: casi siempre significa que no estabas seguro de cuál de los dos era el
  equivocado.

</details>

---

## Incidente 02 — En la máquina de al lado funciona y en la mía no

> **Fase:** 0 · **Categoría:** Integración · **Dificultad:** 🟢
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 25-40 min · **Ruta forense:** [`forense-fase-00.md`](./forense-fase-00.md)

### 🎫 El ticket

> *"Estoy con el mismo código que Marcela, bajado del mismo repositorio, y a ella
> el alta de pacientes le funciona y a mí no. Me sale 'no se pudo registrar el
> paciente'. Ya borré `node_modules` dos veces."*

**Reportado por:** un dev del equipo, en su primera semana
**Ambiente:** desarrollo, dos máquinas

### 🎯 Qué se te pide

Reproducir, y sobre todo **explicar la diferencia entre las dos máquinas**. El
entregable no es el fix: es la frase que le dirías a quien reportó para que la
próxima vez lo diagnostique solo. El fix, si lo hay, cabe en una línea.

### 🔧 Preparación

Rama de git. La causa no está en tu código de aplicación sino en cómo arranca el
mock, y eso también es código.

```bash
git checkout -b incidente/02 fase-00-setup-hola-mundo
npx json-server --watch db.json --port 3000 --middlewares mock/cors-origin.js
```

La rama trae un archivo nuevo, `mock/cors-origin.js` —alguien del equipo lo agregó
"para que esto se parezca más a producción"— y la línea de arranque que lo carga.
Con el mock levantado así, **abre la aplicación en `http://127.0.0.1:4200`**, que es
como la tenía en favoritos quien reportó. Tu compañera la abre en
`http://localhost:4200`.

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Empieza igual que en el incidente **01**: consola y Network. Vas a encontrar el
mismo `status: 0`, así que la primera pregunta es qué **distingue** este caso de
aquel. Hay una herramienta que en el 01 estaba muda y acá no lo está.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Mira la terminal del mock mientras envías el formulario, y lee el mensaje
completo de la consola del navegador — el largo, el que nombra una política y dos
direcciones. Después compara esas dos direcciones carácter por carácter con la
barra de direcciones de tu navegador y con la de tu compañera.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Para un navegador, ¿`http://localhost:4200` y `http://127.0.0.1:4200` son el mismo
origen?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

El middleware que la rama agregó al mock sólo autoriza un origen, escrito a mano:

```javascript
// mock/cors-origin.js — el que trae la rama
module.exports = function (req, res, next) {
  // "Como en producción": un único origen permitido, escrito a mano.
  res.header('Access-Control-Allow-Origin', 'http://localhost:4200');
  next();
};
```

Y `http://127.0.0.1:4200` **no es** `http://localhost:4200`. Para la política del
mismo origen, un origen es la terna esquema + host + puerto comparada como texto:
`localhost` y `127.0.0.1` resuelven a la misma máquina y son orígenes distintos.
La máquina de al lado no tiene nada especial: tiene otra cosa escrita en la barra
de direcciones.

Las dos evidencias que lo separan del incidente **01**, y que son la lección de
este:

```
Access to XMLHttpRequest at 'http://localhost:3000/patients' from origin
'http://127.0.0.1:4200' has been blocked by CORS policy: The
'Access-Control-Allow-Origin' header has a value 'http://localhost:4200' that is
not equal to the supplied origin.
```

```
POST /patients 201 4.512 ms - 128
```

La consola nombra la política y los dos orígenes. Y **el mock registró la
petición con un `201`**: llegó, se atendió, y hasta guardó el paciente. Lo que no
ocurrió fue que el navegador te dejara leer la respuesta. En el incidente 01 el
log del mock estaba vacío; acá está lleno. Esa es toda la diferencia entre "no
llegué" y "llegué y no me dejaron volver".

> ⚠️ Y sí, has leído bien: **el paciente quedó guardado**. Míralo en `db.json`. Un
> bloqueo de CORS no impide la escritura, impide la lectura de la respuesta. Es la
> razón de que un usuario reporte "no se guardó" y en la base haya tres copias.

**Parche mínimo**

Ninguno en el código: abre la aplicación por `http://localhost:4200`, que es la
dirección que el equipo tiene documentada. Y si de verdad hay que tocar algo
porque medio equipo entra por IP, es una línea del middleware del mock:

```javascript
// El mock es herramienta de desarrollo, no un backend. Acá el comodín es
// la respuesta correcta, y la restringida era la que sobraba.
res.header('Access-Control-Allow-Origin', '*');
```

**La refactorización correcta** (que en Track A 💸 no se paga)

Endurecer CORS en un mock local no protege de nada —el mock sirve datos
inventados en tu portátil— y sí produce esta clase de tarde perdida. Si el equipo
quiere ensayar la política real de producción, el sitio es el nginx de la
**Fase 13**, con los orígenes viniendo de configuración y no escritos a mano. La
regla general: **una restricción de seguridad que no protege nada sólo puede
costarte tiempo.**

**Prueba de regresión**

No hay spec de Karma que cace esto: el bloqueo lo hace el navegador, no la
aplicación. La regresión se escribe como una comprobación del ambiente, y es la
misma forma que la Fase 13 convierte en `smoke.sh`:

```bash
# ¿El mock autoriza el origen desde el que realmente abres la aplicación?
curl -s -D - -o /dev/null \
  -H "Origin: http://127.0.0.1:4200" \
  http://localhost:3000/patients | grep -i "access-control-allow-origin"
# Tiene que salir '*' o tu propio origen. Si sale otro, ya sabes qué tarde te espera.
```

**Prevención**

Una línea en el README con la dirección exacta con la que se abre la aplicación,
y el mock permisivo por defecto. Las dos cuestan un minuto y evitan el bug entero.

**Por qué llegó a producción**

Porque "parecerse más a producción" suena siempre a buena idea, y en las
herramientas de desarrollo casi nunca lo es. Quien agregó el middleware lo probó
en su máquina, donde funcionaba —él escribía `localhost`—, y la diferencia con el
resto del equipo era invisible desde su escritorio. Es el patrón que este curso
repite en todas las escalas: **el ambiente forma parte del sistema**, y la mitad
de los bugs de esta profesión son diferencias de ambiente que nadie escribió en
ninguna parte.

**Si tu causa fue distinta a esta**

- Si dijiste **"es la versión de Node"**, es la hipótesis correcta para otro
  síntoma: Node 17+ con el CLI 8 falla al **arrancar**, con
  `ERR_OSSL_EVP_UNSUPPORTED`, y no llega nunca a enviar un formulario. Está en el
  [**Apéndice A03**](./a03-node-npm.md).
- Si dijiste **"le falta borrar `node_modules`"** —que es lo que ya había
  intentado dos veces quien reportó—, fíjate en lo que eso dice del método: es el
  ritual al que se recurre cuando no se tiene una hipótesis. Borrar
  `node_modules` resuelve una familia de problemas muy concreta, y está descrita
  en [**A03 §9**](./a03-node-npm.md); ninguno de ellos produce un `status: 0`.
- Si lo arreglaste **apagando la seguridad del navegador** con un flag de Chrome,
  funciona y es exactamente lo que no queremos que aprendas: apagar el testigo
  para no oír la alarma. Anótalo igual — es un buen material para la
  retrospectiva.

</details>

---

## Incidente 03 — Cambié el paciente y la lista no se entera

> **Fase:** 1 · **Categoría:** Estado (store) · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 40-60 min · **Ruta forense:** [`forense-fase-01.md`](./forense-fase-01.md)

### 🎫 El ticket

> *"Le corregí el apellido a una paciente desde la otra pantalla, volví a la
> lista, le di a recargar y sigue saliendo el apellido viejo. Le di dos veces por
> si acaso. Después recargué la página con F5 y ahí sí salió bien. No sale ningún
> error."*

**Reportado por:** auxiliar de recepción
**Ambiente:** desarrollo

### 🎯 Qué se te pide

Reproducir y localizar la capa responsable. **No termina en fix**: termina cuando
puedas decir, con evidencia, por qué el dato correcto estaba en el store y la
pantalla mostraba otro. Si además aplicas el parche, mejor — pero el entregable
es el diagnóstico.

### 🔧 Preparación

Rama de git: la causa es una línea de código y hay que traerla rota.

```bash
git checkout -b incidente/03 fase-01-estructura-base-ngrx
```

Para reproducir hace falta cambiar un dato **por fuera de la aplicación**, que es
lo que hizo quien reportó: edita el `fullName` de un paciente directamente en
`db.json` (json-server lo recoge solo, por el `--watch`) y pulsa el botón de
recargar de la lista sin refrescar el navegador.

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

No abras el editor. Abre Redux DevTools y contesta dos preguntas en este orden:
¿llegó la acción?, y ¿el estado cambió? El panel **Diff** contesta la segunda más
rápido que el estado completo.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

El Diff te va a mostrar el apellido nuevo dentro del estado. O sea: el servidor,
el effect y el reducer hicieron su trabajo, y aun así la pantalla no cambió.
Arrastra el deslizador una acción hacia atrás y vuelve a soltarlo hacia adelante,
y anota qué pasa con la pantalla. Ese resultado parte la investigación en dos.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

`selectAllPatients` devuelve `state.items` tal cual, a propósito, y `createSelector`
memoiza **comparando referencias**. Con eso en la mano: después de la recarga,
¿`state.items` es un arreglo nuevo, o es el mismo arreglo con otro contenido?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

`src/app/patients/store/patients.reducer.ts`, el caso de éxito de la carga:

```typescript
case PatientsActions.loadPatientsSuccess.type:
  // Vacía el arreglo y lo vuelve a llenar: el contenido cambia, la REFERENCIA no.
  state.items.length = 0;
  action.patients.forEach(function (p) { state.items.push(p); });
  return { ...state, loading: false, error: null };
```

Y acá está lo que hace este incidente distinto del 🧨 de la Fase 1, donde la
mutación era descarada (`return state;`): **este reducer sí devuelve un objeto
raíz nuevo.** Pasa la comprobación refleja —"¿devuelve un objeto nuevo?"— y por
eso sobrevivió a la revisión de código. El bug está un nivel más abajo.

La cadena, en orden:

1. La raíz es nueva → `selectPatientsState` emite.
2. `selectAllPatients` ejecuta su proyector y devuelve `state.items`… que es **el
   mismo arreglo de antes**.
3. `createSelector` compara el resultado con el anterior por referencia, los
   encuentra iguales y **no emite**.
4. El `.subscribe()` del componente nunca corre, `this.patients` conserva los
   objetos viejos, y la plantilla pinta lo de siempre.

Por eso `loading` sí se apagó —ese sale de otro selector, sobre un valor que sí
cambió— y la lista no se movió: dos verdades simultáneas en la misma pantalla.
Por eso F5 lo arregla: un store recién nacido emite la primera vez sin comparar
nada. Y por eso el deslizador también lo arregla: al reponer el estado, Angular
vuelve a pintar la vista entera.

**Parche mínimo**

```typescript
case PatientsActions.loadPatientsSuccess.type:
  // Arreglo NUEVO. Es lo único que el selector memoizado sabe mirar.
  return { ...state, items: action.patients, loading: false, error: null };
```

**La refactorización correcta** (que en Track A 💸 no se paga)

Ninguna: mutar el estado es un bug, no un estilo, y acá no hay dos opciones
defendibles. Lo que sí es una decisión de proyecto —y por eso no entra en un
hotfix— es encender la red que lo habría convertido en una excepción con nombre y
línea en vez de en un silencio:

```typescript
// app.module.ts — decisión de proyecto, NO de hotfix
StoreModule.forRoot({}, { runtimeChecks: { strictStateImmutability: true } })
```

Sobre siete slices escritos por gente distinta, encenderlo va a hacer fallar el
arranque en algún sitio que nadie ha tocado en meses. Eso es un ticket con fecha,
no una línea que se cuela un viernes. El catálogo está en
[**A06 §9.4**](./a06-ngrx.md).

**Prueba de regresión**

```typescript
// src/app/patients/store/patients.reducer.spec.ts
it('loadPatientsSuccess entrega un arreglo NUEVO, no el mismo relleno', function () {
  var previousState: PatientsState = {
    ...initialState,
    loading: true,
    items: [{ id: 1, fullName: 'Ana Ruiz' } as any]
  };
  var previousItems = previousState.items;
  var action = PatientsActions.loadPatientsSuccess({
    patients: [{ id: 1, fullName: 'Ana Ruiz Pardo' } as any]
  });

  var result = patientsReducer(previousState, action);

  // La aserción que importa no es el contenido: es la identidad. Si esto pasa
  // a ser toBe, el selector memoizado deja de emitir y vuelve el incidente 03.
  expect(result.items).not.toBe(previousItems);
  expect(result.items[0].fullName).toBe('Ana Ruiz Pardo');
});
```

**Prevención**

Ese `not.toBe` en el spec de cada `case` que toca `items`, y la nota en el
propio reducer diciendo por qué. El comentario importa tanto como el test: el que
venga dentro de seis meses va a ver un `push` y le va a parecer más eficiente.

**Por qué llegó a producción**

Por una optimización que no lo era. Reusar el arreglo "para no crear basura" es un
reflejo razonable en un programador que viene de otro paradigma, y en un store
inmutable es exactamente lo contrario de lo que el sistema necesita: la
identidad del objeto **es** el mecanismo de notificación. Nadie escribió un bug;
alguien aplicó una intuición correcta en el sitio equivocado. Y la revisión de
código la dejó pasar porque el `return` de la última línea tenía la forma buena.

**Si tu causa fue distinta a esta**

- Si dijiste **"el mock devolvió mal los datos"**, el Diff lo tumba: el apellido
  nuevo estaba dentro del estado. Y el propio ticket lo decía —"con F5 salió
  bien"—, que es cómo un usuario te cuenta que el servidor nunca fue el problema.
- Si dijiste **"falta `OnPush`" o "sobra `OnPush`"**, es la respuesta refleja a
  todo "no se actualiza la pantalla" y en este curso casi nunca es la causa. La
  detección de cambios entra en la conversación cuando el selector **sí** emitió y
  el DOM no se movió; eso es la Fase 10.
- Si tu fix fue **suscribirte a `selectPatientsState` en vez de a
  `selectAllPatients`**, funciona —esa referencia sí cambia— y tapaste el síntoma
  una capa más arriba: el reducer sigue mutando y el siguiente selector que se
  construya sobre `items` volverá a quedarse mudo. Es el caso de manual del "tu
  fix funciona y tu causa no coincide".

</details>

---

## Incidente 04 — Cambié a francés y la fecha sigue en español

> **Fase:** 2 · **Categoría:** i18n · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 40-60 min · **Ruta forense:** [`forense-fase-02.md`](./forense-fase-02.md), ruta 2

### 🎫 El ticket

> *"Puse la aplicación en francés para la doctora que viene los martes. Los
> títulos y los botones cambiaron bien, pero las fechas de las órdenes siguen
> saliendo en español: dice '2 septiembre 2019' en medio de una pantalla que está
> toda en francés. Se ve descuidado."*

**Reportado por:** coordinadora del laboratorio
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducir, localizar **la línea exacta** que decide en qué idioma se formatea una
fecha, y —esto es lo importante— llegar a la reunión con **las dos salidas
costeadas**. Este incidente **no termina en fix**: termina en un diagnóstico y en
una decisión que no es tuya.

### 🔧 Preparación

Ninguna de las tres formas. Este bug **ya está en tu código**: es una deuda 💸
declarada en la Fase 2 y vive en el proyecto desde que la escribiste. Basta con
ponerte en francés y mirar una tarjeta de paciente entera.

```bash
npm run mock      # en una terminal
ng serve          # en otra, y cambia el idioma desde el toolbar
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Antes de abrir nada, haz un inventario: en una sola tarjeta, apunta **qué cambió
de idioma y qué no**. La línea divisoria es exacta y no pasa por el azar.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Todo lo que pasa por el pipe `translate` cambia. Nada de lo que pasa por los
pipes de `@angular/common` —`date`, `decimal`, `currency`— cambia. Son dos
sistemas distintos: uno lee un diccionario que tú cargas, el otro lee un token de
Angular que se resuelve **una sola vez, al arrancar**.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

En la consola, `translate.currentLang` dice `"fr"`. ¿Quién le dijo al pipe `date`
que el idioma es `'es'`, y en qué momento de la vida de la aplicación se lo dijo?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

`src/app/core/i18n/i18n.module.ts`, el provider de `LOCALE_ID` con un valor fijo.

En la aplicación conviven **dos sistemas de internacionalización que nadie
conectó**, y hacen exactamente lo que se les configuró:

- `@ngx-translate` resuelve las **cadenas**. Cambia de idioma en caliente porque
  para eso está: carga otro diccionario y avisa a quien lo escuche.
- `LOCALE_ID` gobierna los **datos locales** —fechas, números, moneda— a través de
  los pipes de `@angular/common`. Es un token de inyección, se resuelve **una vez
  al arrancar la aplicación**, y los pipes leen ese valor y nada más. No conocen
  `@ngx-translate` y no tienen por qué.

La evidencia son dos verdades simultáneas y contradictorias:

```js
translate.currentLang
// "fr"
```

```
Patients
Document: CC-1032456789
1 commande en attente
Dernière commande: 2 septiembre 2019, 8:15:00
```

Toda la tarjeta en francés menos el mes. Eso no es "las fechas se ven raras": es
que una parte de la pantalla escucha al selector de idioma y la otra no, y la
línea divisoria es el pipe que atraviesa cada valor.

**Parche mínimo**

**No hay.** Y ese es el resultado del incidente, no un fracaso: `LOCALE_ID` es
estático por diseño en Angular 8. Las dos únicas salidas reales son:

1. **Recargar la aplicación al cambiar de idioma**, reinyectando el token con el
   nuevo valor. Es un hotfix de una tarde. El costo: el usuario pierde el estado
   de la pantalla en cada cambio —un formulario a medias, un filtro, la posición
   del scroll—.
2. **Dejar de usar los pipes nativos** y formatear contra el idioma activo. Es
   tocar todas las plantillas que muestren una fecha o un número, y es un cambio
   transversal con pruebas, no un parche.

Cuál se elige depende de cuántos usuarios francófonos hay y de cuántas veces al
día cambian de idioma. Eso es **una conversación de producto**, no de código. Lo
que sí es de tu incumbencia es llegar a ella con el diagnóstico hecho y las dos
opciones costeadas.

> ⚠️ Y la trampa que hay que nombrar antes de que alguien la pise: "arreglarlo"
> poniendo `LOCALE_ID` en `'fr'` sin llamar a `registerLocaleData(localeFr, 'fr')`
> no produce un error claro, produce `Missing locale data for the locale "fr"` —o
> peor, según el pipe, una fecha en inglés que nadie pidió y que parece un tercer
> bug—. En esta fase los tres idiomas ya están registrados; el día que entre un
> cuarto, esto vuelve.

**La refactorización correcta** (que en Track A 💸 no se paga)

La opción 2, con un pipe propio del proyecto que lea el idioma activo y formatee
contra él. Se hace con calma, con pruebas y tocando cada plantilla; no se hace un
viernes ni se cuela en el commit de otra cosa. La deuda está declarada en la
**Fase 2 §4**, que es donde se eligió i18n por runtime y se escribió el precio de
esa decisión.

**Prueba de regresión**

Lo que se puede blindar hoy no es el idioma de la fecha: es que nadie cambie el
token por descuido y se lleve por delante a los tres idiomas.

```typescript
// src/app/core/i18n/i18n.module.spec.ts
it('LOCALE_ID es estático y vale es: la deuda declarada de la Fase 2', function () {
  TestBed.configureTestingModule({ imports: [I18nModule] });
  // Si alguien lo cambia, este test cae y obliga a leer el post-mortem del
  // incidente 04 antes de tocar nada.
  expect(TestBed.get(LOCALE_ID)).toBe('es');
});

it('los tres idiomas tienen datos de locale registrados', function () {
  // Sin esto, mover el token produce "Missing locale data" en vez de una fecha.
  ['es', 'en', 'fr'].forEach(function (lang) {
    expect(function () { return formatDate(new Date(), 'longDate', lang); }).not.toThrow();
  });
});
```

**Prevención**

Un comentario en el provider explicando por qué el valor es fijo y qué cuesta
moverlo, con el enlace a este incidente. Es la clase de deuda que no se previene
con un test sino con **una nota que impida que el siguiente crea que es un olvido**.

**Por qué llegó a producción**

Porque en 2019 se eligió i18n por runtime —la decisión correcta para LabCore, y
la Fase 2 §4 la defiende con números— y esa elección resuelve las cadenas pero no
toca los datos locales. Nadie decidió que las fechas se quedaran en español:
nadie se dio cuenta de que eran un sistema aparte. Y el bug tardó años en
reportarse porque sólo se ve cuando alguien cambia de idioma, que es exactamente
lo que casi nadie hace hasta que llega la doctora de los martes.

**Si tu causa fue distinta a esta**

- Si dijiste **"falta la traducción al francés"**, es lo que sugiere la pantalla y
  acá es falso: la fecha está bien calculada, el formato es válido y la zona
  horaria es la que se le pasó. Lo único equivocado es el idioma del mes.
- Si dijiste **"las fechas están mal calculadas"**, ese bug existe en el curso y
  es otro: es el borde de vigencia de la Fase 8, donde la comparación se resbala a
  UTC. Es el incidente **07**.
- Si tu fix fue **traducir los meses a mano** con un diccionario propio en la
  plantilla, funciona para las fechas que tocaste y deja fuera los números, la
  moneda y las fechas de las otras nueve pantallas. Anótalo: es el ejemplo
  perfecto de un fix que escala peor que el bug.

</details>

---

## Incidente 05 — Cerré sesión en una pestaña y en la otra sigo adentro

> **Fase:** 3 · **Categoría:** UI · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 40-60 min · **Ruta forense:** [`forense-fase-03.md`](./forense-fase-03.md), paso 5

### 🎫 El ticket

> *"Comparto el computador de recepción con Julián. Terminé mi turno, cerré
> sesión y me fui. Él llegó, vio que en la otra pestaña seguía abierta la pantalla
> de pacientes con mi sesión y **registró tres pacientes desde ahí** antes de
> darse cuenta. Se guardaron los tres. ¿Quedaron a mi nombre?"*

**Reportado por:** analista de turno de la mañana
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducir, explicar **por qué la segunda pestaña siguió funcionando** —que no es
lo que casi todo el mundo supone— y decir qué garantía de sesión da hoy el
sistema y cuál no. El fix mínimo existe y cabe en pocas líneas, pero antes hay que
contestar la pregunta de la analista, que es de auditoría y no de interfaz.

### 🔧 Preparación

Ninguna rama: el comportamiento está en el código tal como lo escribiste en la
Fase 3. Se reproduce con dos pestañas.

```bash
# 1. Abre la aplicación en dos pestañas y entra con analista1 en las dos.
# 2. En la pestaña A, pulsa el botón de logout.
# 3. Vuelve a la pestaña B SIN recargarla y sigue trabajando: registra un paciente.
```

El paso 3 es el incidente. Si quieres verlo sin la segunda pestaña, es el 🧨 de la
propia Fase 3: borra `lab_clinico_token` a mano en Application → Local Storage y
sigue en la misma pantalla.

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

La pregunta no es "por qué la pestaña B sigue logueada". Es **quién tendría que
haberse enterado, y cuándo le toca mirar**. Haz la lista de todos los sitios del
código que consultan el storage y anota junto a cada uno con qué frecuencia corre.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Con la pestaña B, después del logout en A: mira Network mientras registras el
paciente, y en concreto los **Request Headers** de esa petición. Después mira el
código de respuesta. Las dos cosas juntas explican el incidente entero.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

El guard consulta el storage en **cada navegación**. En la pestaña B, ¿cuántas
navegaciones hubo entre el logout de A y el registro del paciente? ¿Y quién le
preguntó algo al servidor sobre esa sesión?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

No hay una línea culpable: hay **tres decisiones que se suman**, y ninguna es un
error por sí sola. Esa es la lección del incidente.

1. **`logout()` es local a la pestaña que lo ejecuta.** Borra la clave del
   storage y navega al login *en esa pestaña*:

   ```typescript
   logout() {
     localStorage.removeItem(TOKEN_KEY);
     this.router.navigate(['/login']);
   }
   ```

   El `localStorage` **sí** es compartido entre pestañas del mismo origen: la
   clave desapareció también para la pestaña B. Lo que no se comparte es el aviso.

2. **Nadie escucha el evento `storage`.** El navegador lo emite en las otras
   pestañas justo para esto, y en el código de LabCore no hay un solo
   `addEventListener('storage', …)`. La pestaña B no tenía forma de enterarse.

3. **Quien consulta el storage sólo corre en cada navegación.** `isAuthenticated()`
   lee la clave de verdad —no una copia en memoria, y eso está bien hecho—, pero
   el único que lo llama es el guard, y un guard corre **cuando cambias de ruta**.
   La pestaña B se quedó en `/patients` y nadie preguntó nada.

Y ahora la parte que contesta a la analista, que es la que importa:

```
Request URL: http://localhost:3000/patients
Request Method: POST
Status Code: 201 Created
```

En Request Headers **no hay `Authorization`**. El interceptor hace lo correcto:
`getToken()` devolvió `null`, así que no agregó la cabecera —no manda el clásico
`Bearer null`—. Y el mock guardó el paciente igual, porque **el mock no valida el
token en las rutas de datos**: sólo lo firma en `/login`. Los tres pacientes de
Julián se registraron **sin ninguna sesión**, ni la de ella ni la de él.

> 🧬 Así que la respuesta a *"¿quedaron a mi nombre?"* es peor que un sí: **no
> quedaron a nombre de nadie.** Cuál es el rastro que sí queda —y por qué el
> `actor` del audit log lo pone el navegador, que es la deuda 💸 de la Fase 11— es
> el incidente **17**. Los dos son la misma historia contada desde dos capas.

**Parche mínimo**

Cerrar sesión en todas las pestañas, que es una suscripción al evento del
navegador:

```typescript
// auth.service.ts — en el constructor del servicio, que es singleton.
// Otra pestaña borró la clave de sesión: acá nos enteramos y nos vamos.
window.addEventListener('storage', function (this: AuthService, event: StorageEvent) {
  if (event.key === TOKEN_KEY && event.newValue === null) {
    this.router.navigate(['/login']);
  }
}.bind(this));
```

Cinco líneas, sin tocar el guard ni el interceptor, y sin meter la sesión en NgRx
—que es la otra propuesta que va a salir en la reunión y que la Fase 3 ya
descartó con su razón escrita—.

**La refactorización correcta** (que en Track A 💸 no se paga)

Que el servidor valide el token en cada ruta de datos. Es lo que convierte "no
hay sesión" en un `401` y hace que el interceptor reaccione **sin depender de que
el navegador se porte bien**. En el track base no se hace porque el backend no es
nuestro; el track 🔥 BE lo construye en `be01`, y ahí se ve que el mock de este
curso era más permisivo que el LabCore real. Mientras tanto, la garantía honesta
que da el sistema hoy es esta: **la sesión es una comodidad de la interfaz, no un
control de acceso.** Un guard corre en el navegador y el usuario puede saltárselo.

**Prueba de regresión**

```typescript
// src/app/core/auth/auth.service.spec.ts
it('se va al login cuando otra pestaña borra el token', function () {
  var router = TestBed.get(Router);
  spyOn(router, 'navigate');

  // El navegador emite esto en LAS OTRAS pestañas, nunca en la que borró.
  window.dispatchEvent(new StorageEvent('storage', {
    key: 'lab_clinico_token',
    newValue: null
  }));

  expect(router.navigate).toHaveBeenCalledWith(['/login']);
});

it('ignora los cambios de otras claves del storage', function () {
  var router = TestBed.get(Router);
  spyOn(router, 'navigate');
  window.dispatchEvent(new StorageEvent('storage', { key: 'lab.language', newValue: 'fr' }));
  // Cambiar de idioma en otra pestaña NO puede sacarte de la sesión.
  expect(router.navigate).not.toHaveBeenCalled();
});
```

El segundo test no es adorno: sin el `event.key === TOKEN_KEY`, el selector de
idioma de la Fase 2 —que también escribe en `localStorage`— desloguearía a todo
el mundo cada vez que alguien cambia de idioma en otra pestaña. Es un bug mejor
que el original.

**Prevención**

Además del test, la pregunta en la revisión de código: *"esto que guardo en el
storage, ¿quién más lo lee, y cada cuánto?"*. El `localStorage` es estado
compartido entre pestañas sin ningún mecanismo de notificación puesto por
defecto; tratarlo como si fuera memoria del componente es el origen de esta
familia entera de bugs.

**Por qué llegó a producción**

Porque en 2019 nadie imaginó dos pestañas: se pensó en *un* usuario, con *una*
ventana, cerrando sesión al final del turno. En un laboratorio con computadores
compartidos por turnos, esa suposición es falsa todos los días a las dos de la
tarde. Y el bug no se ve nunca en desarrollo, donde uno cierra sesión y mira la
pantalla que acaba de cerrar — precisamente la única en la que el logout sí
funcionó.

**Si tu causa fue distinta a esta**

- Si dijiste **"el token quedó cacheado en memoria"**, es la hipótesis más común y
  es falsa: `getToken()` lee el storage cada vez. Compruébalo en la consola de la
  pestaña B después del logout —`localStorage.getItem('lab_clinico_token')` da
  `null`— y verás que el problema no es que quede un token, sino que nadie
  pregunta.
- Si dijiste **"falta refresh token"** o **"hay que meter la sesión en NgRx"**,
  son rediseños que no diagnostican nada: con los dos, la pestaña B sigue sin
  enterarse de que la A cerró sesión.
- Si tu fix fue **un `setInterval` que revise el storage cada N segundos**,
  funciona y es la versión cara de la misma idea: el navegador ya te avisa gratis
  con el evento `storage`. Anota cuántos segundos pusiste y qué pasa en esos
  segundos — porque esa ventana es exactamente el bug, más pequeño.

</details>

---

## Incidente 06 — La pantalla de pacientes sale vacía y no dice nada

> **Fase:** 4 · **Categoría:** Integración · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 40-60 min · **Ruta forense:** [`forense-fase-04.md`](./forense-fase-04.md)

### 🎫 El ticket

> *"Entro a pacientes y me dice que no hay ninguno registrado. Y hay como
> cuatrocientos. No sale ningún error, no sale nada en rojo, la pantalla se ve
> perfecta. Simplemente dice que no hay nadie."*

**Reportado por:** auxiliar de recepción
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducir y localizar la capa responsable. **No hay fix en el frontend**, y
averiguar por qué no lo hay es la mitad del ejercicio: tienes que poder decir, con
la evidencia delante, por qué el reducer, el effect y el interceptor están los
tres correctos.

### 🔧 Preparación

Un flag del inyector de caos, que es la forma más barata: no toca tu código, no
toca tus datos, y se apaga sola al reiniciar el mock.

```bash
CHAOS=malformed npm run mock
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Esta pantalla sabe pintar cuatro estados distintos: cargando, error, vacío y con
datos. Antes de nada, decide **cuál de los cuatro** te está mostrando. No es una
pregunta retórica: cada uno abre una investigación diferente.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Abre el log de acciones y mira qué despachó el store. Si lo que ves es un
`Success`, para y piénsalo un segundo: la aplicación **cree que la carga salió
bien**. Eso descarta de golpe la red, el servidor caído y el token vencido, y
deja un solo sitio donde mirar.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

En Network, abre la petición a `/patients` y ve a la pestaña **Response** — no a
Preview, que ya interpreta. ¿Qué forma tiene lo que llegó, y qué forma esperaba
`items`?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

El servidor respondió `200 OK` con un cuerpo **con la forma equivocada**. No hay
ningún archivo culpable del lado del cliente.

La cadena completa, y lo incómodo es que cada eslabón hizo bien su trabajo:

```
[Patients] Load Patients
[Patients] Load Patients Success        ← el store cree que salió bien
```

```json
{"data":{"items":"no-soy-un-arreglo"},"total":null}
```

El effect recibió un `200`, así que despachó `Success` —es lo que le pidieron—.
El reducer guardó `items: action.patients` —es lo que le pidieron—. Y la
plantilla evaluó `patients.length`, que sobre un objeto sin `length` es
`undefined`, que el `*ngIf` trata como falso, y pintó con toda tranquilidad el
estado vacío que tenía preparado desde la Fase 1.

**Tres capas mintieron y ninguna tuvo la culpa:** la pantalla dijo que no hay
pacientes, el store dijo que la carga salió bien, y el `200` verde dijo que todo
estaba en orden. La única capa que no interpreta nada es el cuerpo de la
respuesta, y llegar hasta ella exige haber desconfiado de las otras tres en ese
orden.

**Parche mínimo**

Ninguno en el frontend, y decirlo con seguridad **es** el entregable. Lo que
corresponde es un ticket al equipo del backend con las tres líneas de evidencia:
endpoint, código de estado y cuerpo literal. Un `200` con la forma equivocada es
un incumplimiento de contrato, no un bug de la aplicación que lo consume.

Lo que sí cabe en un hotfix es **dejar de mentirle al usuario** mientras el
contrato se arregla: que la pantalla distinga "no hay pacientes" de "no entendí
la respuesta".

```typescript
// patients.effects.ts — dentro del map del éxito, antes de despachar.
// El mock puede devolver 200 con cualquier cosa; un arreglo es lo único
// que este slice sabe guardar. 💸 Esto es una tirita: lo correcto es que
// el contrato se valide de verdad (ver abajo).
map(function (patients: any) {
  if (!Array.isArray(patients)) {
    return PatientsActions.loadPatientsFailure({
      error: { code: 'BAD_SHAPE', status: 200, messageKey: 'errors.badResponse' }
    });
  }
  return PatientsActions.loadPatientsSuccess({ patients: patients });
})
```

**La refactorización correcta** (que en Track A 💸 no se paga)

Validar la forma de la respuesta en el borde, una sola vez, para todos los
slices — y no repitiendo este `if` en cada effect, que es como se acaba con siete
validaciones distintas. Lo que lo haría casi gratis es tener tipos de verdad:
con `strict: true` y un modelo real de `Patient`, un `any` que atraviesa tres
capas deja de ser posible. Ese es el ejercicio 🔥 de la Fase 4 y la conversación
del [**Apéndice A11 §5**](./a11-migracion-9-16.md), y no se hace en la misma
tanda que un hotfix: encender `strict` en un TS-0 produce cientos de errores en
código que nadie ha tocado en meses.

**Prueba de regresión**

```typescript
// src/app/patients/store/patients.effects.spec.ts
it('un 200 con la forma equivocada NO se despacha como Success', function (done) {
  actions$ = of(PatientsActions.loadPatients());
  spyOn(service, 'getPatients').and.returnValue(
    of({ data: { items: 'no-soy-un-arreglo' }, total: null } as any)
  );

  effects.loadPatients$.subscribe(function (action) {
    // Antes del fix esto era loadPatientsSuccess y el test pasaba en verde
    // mientras la pantalla decía que no hay pacientes.
    expect(action.type).toBe(PatientsActions.loadPatientsFailure.type);
    done();
  });
});
```

**Prevención**

La comprobación de forma en el borde, y el reflejo que la acompaña: **un test que
sólo prueba el camino feliz no prueba nada de esta familia**. El único modo de que
este bug se cace solo es que exista un caso con una respuesta deforme, y eso hay
que escribirlo a propósito porque ningún mock lo genera por accidente.

**Por qué llegó a producción**

Porque nadie contrató nunca la forma de la respuesta. En 2019 el frontend y el
backend se pusieron de acuerdo hablando, el primer `200` llegó con la forma
correcta y desde entonces se asumió que siempre sería así. Y el semáforo verde
hizo el resto: mientras el status diga `200`, nadie mira el cuerpo. La diferencia
entre este incidente y el mismo fallo servido como `500` no es la gravedad —es
que un `500` se diagnostica en dos minutos porque **el servidor tuvo la decencia
de admitir que falló**.

**Si tu causa fue distinta a esta**

- Si dijiste **"el reducer está mal"**, es la hipótesis más razonable y más
  equivocada del recorrido: el reducer guardó exactamente lo que le dieron. Una
  función pura no puede validar lo que no sabe que existe.
- Si dijiste **"falta un `catchError`"**, no se ejecutó porque **no hubo error**:
  hubo un `200`. Para RxJS, un objeto es un valor perfectamente válido.
- Si dijiste **"es CORS"** o **"el servidor está caído"**, el `Success` del log de
  acciones los tumba a los dos: con cualquiera de ellos habría un `Failure`.
- Si tu fix fue **poner un `|| []` en la plantilla**, la pantalla deja de decir
  "no hay pacientes"… y pasa a no decir nada en absoluto. Tapaste el síntoma una
  capa más arriba y perdiste la única señal que tenías.

</details>

---

## Incidente 07 — Los resultados críticos no avisan el fin de semana

> **Fase:** 8 · **Categoría:** Tiempo · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 60-90 min · **Ruta forense:** [`forense-fase-08.md`](./forense-fase-08.md), ruta 1

### 🎫 El ticket

> *"Un potasio de 6.8 de un paciente de urgencias entró el sábado por la noche y
> nadie se enteró hasta el lunes a las siete. Eso es un valor crítico, tendría que
> haber saltado una alarma. Y cuando por fin lo abrimos, la pantalla lo mostraba
> en amarillo, no en rojo. Necesito saber si el sistema lo detectó o no."*

**Reportado por:** coordinadora del laboratorio
**Ambiente:** PROD

### 🎯 Qué se te pide

Contestar la pregunta de la coordinadora —*¿el sistema lo detectó?*— con un sí o
un no defendible, y **separar los dos hallazgos que hay debajo**, porque son dos y
tienen destinos distintos: uno es una funcionalidad que no existe, el otro es un
bug de verdad.

Este incidente **no termina en fix**. Termina en un documento que alguien de
dirección tiene que leer.

### 🔧 Preparación

Un `db.json` alterno: hace falta un resultado crítico tomado en el borde exacto
de una ventana de vigencia, un sábado por la noche. Es un dato, no un código.

```bash
cp db.json db.json.mio
cp db.incidente-07.json db.json
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Separa el ticket en dos preguntas antes de investigar nada: *(a)* ¿existe en el
sistema algo que avise?, y *(b)* ¿el veredicto que calculó era el correcto? La
primera se contesta con un `grep` y la segunda con aritmética.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Para la segunda pregunta: mira la hora exacta de `collectedAt` de esa muestra —no
el día, la hora— y las dos ventanas de `effectiveFrom`/`effectiveTo` del analito.
Después convierte esa hora a UTC a mano, con lápiz.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

En `America/Bogota` (UTC-5), cualquier hora local a partir de las 19:00 **ya es el
día siguiente en UTC**. La comparación de vigencia usa `.getTime()`, que compara
instantes absolutos. ¿De qué lado del borde cae un sábado a las 20:00?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

Son **dos**, y confundirlas es lo que hace que este ticket se cierre mal.

---

**Hallazgo 1 — La alarma no existe. Nunca existió.**

```bash
grep -rn "critical" src/ | grep -v ".spec.ts"
# src/app/results/store/reference-range.selector.ts:  var critical = value <= range.criticalLow …
# src/app/results/result-list/result-list.component.html:  <span class="badge-critical" …
```

Dos apariciones: una que **calcula** y otra que **pinta**. No hay ninguna que
notifique. El sistema marca el resultado crítico en rojo en una pantalla, y eso es
todo lo que hace. Si nadie abre esa pantalla, nadie se entera — y el sábado a las
nueve de la noche no hay nadie abriendo pantallas.

La respuesta a la coordinadora, entonces, es: **sí lo detectó, y no tenía forma de
avisar**. No es un fallo del sistema, es un hueco de alcance que lleva ahí desde
2019 y que nadie declaró nunca por escrito. Es la clase de hallazgo que un
post-mortem tiene que subir, porque la solución no es de mantenimiento: es de
producto y cuesta dinero.

---

**Hallazgo 2 — Y además el veredicto estaba mal calculado.**

Esa es la parte del ticket que parecía un detalle —*"lo mostraba en amarillo, no
en rojo"*— y es un bug real.

```bash
curl -s "http://localhost:3000/samples/612" | grep collectedAt
# "collectedAt": "2019-05-31T20:15:00-05:00"      ← sábado, 8:15 de la noche
```

```
2019-05-31T20:15:00-05:00   ==   2019-06-01T01:15:00Z
                                 └─ ya es junio en UTC
```

La muestra se tomó el 31 de mayo por la noche en Bogotá, que **es el 1 de junio en
UTC**, y la ventana de la v2 abre el 1 de junio. `selectActiveRange` compara con
`.getTime()`, o sea instantes absolutos, mientras que el borde de vigencia se
definió en hora local. Resultado: se aplicó la norma que todavía no regía.

Confirmado sin depurador, sobre la función pura:

```js
selectActiveRange(ranges, 'potassium', '2019-05-31T20:15:00-05:00').version
// 2      ← debería ser 1
selectActiveRange(ranges, 'potassium', '2019-05-31T12:15:00-05:00').version
// 1      ← la misma fecha, de día, elige bien
```

**La hora, y no el día, decide el veredicto.** Y eso explica la parte del ticket
que sonaba a superstición: falla **de noche**, y en el borde. En el 95% de los días
da igual porque la fecha cae lejos de un límite; los días que no da igual son los
bordes, y los bordes caen en fin de semana tantas veces como en cualquier otro
día — sólo que en fin de semana nadie está mirando.

> 🧬 Y el hallazgo que hay que anotar aparte, porque es peor: el `atDate` de uno de
> los llamadores cae a `new Date().toISOString()` cuando la muestra no tiene
> `collectedAt`. O sea, **"hoy" según el reloj del navegador**. Eso no rompe un
> veredicto: rompe la reproducibilidad, porque el mismo resultado juzgado dos días
> distintos puede aplicar normas distintas. Cuéntalos antes de cerrar:
> `curl -s http://localhost:3000/samples | grep -c '"collectedAt": null'`.

**Parche mínimo**

Para el hallazgo 2, forzar que los dos lados de la comparación lleven el offset
explícito de la aplicación:

```typescript
// reference-range.selector.ts — tapa el caso reportado, no la clase entera.
// El borde de vigencia se definió en hora LOCAL; comparar instantes UTC hace
// que una muestra del 31 por la noche caiga del lado de junio.
var atLocal = new Date(atDate).toLocaleString('sv-SE', { timeZone: environment.timeZone });
```

Para el hallazgo 1 **no hay parche**, y proponer uno sería el error: una alarma
que avise de verdad —un canal, un turno de guardia, un acuse de recibo— es un
subsistema, no una línea.

**La refactorización correcta** (que en Track A 💸 no se paga)

Normalizar **los dos lados** a `America/Bogotá` con una librería con soporte de
zona (Luxon, `date-fns-tz`), como dice la deuda 💸 declarada en la **Fase 8 §5.3**.
Eso arregla la clase entera, no el caso.

Y encima de eso hay una tercera pregunta, que no es de código y que hay que hacer
antes de escribir nada: **¿a qué hora, exactamente, entra en vigor una norma
clínica?** Mientras nadie la conteste, cualquier implementación está adivinando —
que es la razón por la que un "bug de fechas" casi nunca es un bug de fechas.

**Prueba de regresión**

```typescript
// src/app/results/store/reference-range.selector.spec.ts
it('una muestra del 31 de mayo por la noche aplica la v1, no la v2', function () {
  var ranges = [
    { version: 1, analyte: 'potassium', low: 3.5, high: 5.5, criticalHigh: 6.5,
      effectiveFrom: '2019-01-01T00:00:00-05:00', effectiveTo: '2019-05-31T23:59:59-05:00' },
    { version: 2, analyte: 'potassium', low: 3.5, high: 5.1, criticalHigh: 6.0,
      effectiveFrom: '2019-06-01T00:00:00-05:00', effectiveTo: null }
  ];

  // 20:15 local del 31 de mayo = 01:15Z del 1 de junio. Antes del fix
  // esto devolvía la 2, y un potasio de 6.8 cambiaba de veredicto.
  var range = selectActiveRange(ranges, 'potassium', '2019-05-31T20:15:00-05:00');

  expect(range.version).toBe(1);
});

it('el veredicto de un crítico no depende de la hora del día', function () {
  var deNoche = selectActiveRange(ranges, 'potassium', '2019-05-31T20:15:00-05:00');
  var deDia = selectActiveRange(ranges, 'potassium', '2019-05-31T12:15:00-05:00');
  // El mismo día tiene que elegir la misma norma, sean las 12 o las 20.
  expect(deNoche.version).toBe(deDia.version);
});
```

**Prevención**

Tres cosas, en orden de lo que cuestan:

1. **Un test por cada borde de vigencia que exista en los datos**, con la hora
   puesta a propósito en la franja de las 19:00 a las 23:59. Es el único horario
   en el que este bug vive.
2. **Un detector**: recorrer los resultados validados y recalcular qué versión
   les tocaba. Los que no coincidan con su `rangeVersionApplied` son la lista de
   veredictos que hay que revisar a mano.
3. **La decisión escrita** de a qué hora entra en vigor una norma, firmada por
   quien la emite y no por quien la programa.

**Por qué llegó a producción**

Por dos razones que no se parecen en nada, y ésa es la lección del incidente.

La alarma no existe porque en 2019 se construyó lo que se pidió: *marcar* los
críticos. Marcar y avisar suenan parecido en una reunión y son sistemas
completamente distintos —uno es un `<span>` con una clase, el otro es un canal,
una guardia y un acuse de recibo—. Nadie mintió; nadie preguntó.

El bug de zona horaria llegó porque en 2019 no había en el proyecto ninguna
librería de zonas, `Date` de JavaScript parecía suficiente y la comparación de
instantes **es** la forma correcta de comparar instantes. El error no está en la
comparación: está en que uno de los dos lados no era un instante, era una fecha de
calendario escrita en hora local. Es el bug más difícil de ver de todo el curso
porque el código se lee bien.

**Si tu causa fue distinta a esta**

- Si dijiste **"el umbral crítico está mal configurado"**, compruébalo y descarta:
  los `criticalLow`/`criticalHigh` están en el rango y son correctos en las dos
  versiones. Lo que cambió no fue el umbral, fue cuál de los dos se aplicó.
- Si dijiste **"el resultado entró mal desde el analizador"**, es una hipótesis
  legítima y se tumba mirando el `value`: 6.8 es 6.8 en los dos casos. Lo que
  cambia es el juicio, no el dato.
- Si te quedaste **sólo con el hallazgo 2**, arreglaste el veredicto y la
  coordinadora sigue sin enterarse el sábado que viene. Si te quedaste **sólo con
  el hallazgo 1**, escalaste un problema de producto y dejaste un bug de cálculo
  suelto en un dominio clínico. Este incidente se aprueba con los dos.

</details>

---

## Incidente 08 — A veces no carga

> **Fase:** 4 · **Categoría:** Integración · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 40-60 min · **Ruta forense:** [`forense-fase-04.md`](./forense-fase-04.md)

### 🎫 El ticket

> *"A veces no carga. Le doy otra vez y ya. Pasa varias veces al día, siempre en
> pacientes, pero no sabría decirte cuándo. A mi compañera también le pasa."*

**Reportado por:** auxiliar de recepción
**Ambiente:** UAT

Siete palabras de reporte y ninguna pista. Es el ticket más frecuente de
cualquier sistema en mantenimiento y el que peor se trabaja: la reacción normal es
pedirle al usuario "los pasos exactos", que es justo lo que un intermitente no
tiene.

### 🎯 Qué se te pide

**Convertir un "a veces" en un número.** El entregable es una frase de esta
forma: *"falla el N% de las veces, siempre con el mismo código, y acá está el
mecanismo"*. Sin el número no hay diagnóstico, sólo una anécdota — y con el número
el diagnóstico sale prácticamente solo.

### 🔧 Preparación

Un flag del inyector de caos. Este es el modo que existe precisamente para esto:

```bash
CHAOS=fail=500@30 npm run mock
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

No persigas el fallo: **provócalo muchas veces y cuéntalo**. Un intermitente que
ocurre "a veces" es un intermitente que ocurre con una frecuencia, y una
frecuencia se mide. Diez recargas y un papel bastan.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Cuando falle, mira dos cosas y anótalas: el código que muestra la pantalla y la
línea correspondiente en la terminal del mock. Cuando funcione, mira si en esa
terminal hay alguna diferencia. La comparación entre las veces que falla y las que
no es donde está la respuesta.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si de diez intentos fallan tres, y de veinte fallan seis… ¿de dónde puede salir un
porcentaje tan estable? Ningún servidor caído falla el 30% de las veces. Las cosas
que fallan con un porcentaje exacto están **configuradas** para hacerlo.

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

El mock está arrancado con `CHAOS=fail=500@30`: falla a propósito el 30% de las
peticiones, con un `500` honesto. Y en este incidente **la causa importa menos que
el método**, porque el método es el que se transfiere.

El diagnóstico se cierra con tres observaciones, en este orden:

1. **El fallo está admitido.** El store dice `Failure` y la pantalla muestra el
   código, no un vacío silencioso. O sea: no es el incidente **06**, es su
   contrario amable. Alguien —el servidor— dijo la verdad.

   ```json
   { "error": { "code": "HTTP_500", "status": 500, "messageKey": "errors.loadFailed" } }
   ```

2. **El porcentaje es estable.** Diez recargas, tres fallos; veinte, seis. Un
   servidor sobrecargado no se comporta así: falla en ráfagas, correlacionado con
   la carga, y a las tres de la mañana no falla. **Una tasa constante e
   independiente de la hora no es un síntoma de infraestructura: es un parámetro.**

3. **El servidor lo está anunciando.** En su primera línea, y en cada petición:

   ```
   [mock] escuchando en http://localhost:3000
   [mock] caos global activo: fail=500@30
   [mock] GET /patients | chaos: fail=500@30
   ```

Y con eso llegamos a la parte incómoda, que es la lección de verdad de este
incidente: **más de un "bug" de esta clase es un modo de caos que alguien dejó
encendido hace una hora.** El paso 5 de la pieza forense existe por esto. Antes de
abrir una investigación sobre un intermitente, la pregunta de treinta segundos es
*¿qué tenía yo encendido?*.

**Parche mínimo**

```bash
# Para el mock y arráncalo limpio. Y comprueba por donde se comprueba:
# la primera línea del arranque NO puede decir "caos global activo".
npm run mock
```

Si el intermitente fuera real —un servidor que de verdad falla el 30%— el parche
de cliente no sería este. Sería **reintento con espera creciente** para los
fallos idempotentes, y es una decisión de proyecto con su ticket, no un hotfix: un
reintento automático sobre una escritura no idempotente convierte un fallo visible
en dos pacientes registrados, que es el incidente **10**.

**La refactorización correcta** (que en Track A 💸 no se paga)

Que el caos sea **visible desde la aplicación** y no sólo desde la terminal del
servidor. Hoy se configura por variable de entorno o por header y no hay ningún
sitio donde el desarrollador vea qué tiene puesto sin cambiarse de ventana. Un
indicador en la interfaz, detrás de un flag y excluido del build de producción, es
el pendiente 📌 que la propia Fase 4 dejó anotado.

**Prueba de regresión**

Un intermitente no se prueba con un test que corre una vez: se prueba
**midiéndolo**. Y lo que se blinda no es la tasa de fallo del mock —eso es el
ambiente— sino que la aplicación trate cada fallo igual, sin acumular estado
sucio entre uno y otro:

```typescript
// src/app/patients/store/patients.effects.spec.ts
it('sobrevive a una racha de fallos y sigue pudiendo cargar', function (done) {
  var attempts = 0;
  spyOn(service, 'getPatients').and.callFake(function () {
    attempts++;
    // Falla las tres primeras, responde bien la cuarta.
    return attempts <= 3
      ? throwError({ status: 500 })
      : of([{ id: 1, fullName: 'Ana Ruiz' } as any]);
  });

  var seen: string[] = [];
  effects.loadPatients$.subscribe(function (action) {
    seen.push(action.type);
    if (seen.length === 4) {
      // Tres fallos y un éxito. Lo que este test protege es que el cuarto
      // intento llegue: un effect muerto no despacharía nada más.
      expect(seen[3]).toBe(PatientsActions.loadPatientsSuccess.type);
      done();
    }
  });

  [1, 2, 3, 4].forEach(function () { actions$.next(PatientsActions.loadPatients()); });
});
```

**Prevención**

Dos cosas, y las dos son de proceso más que de código. La primera: que el mock
grite lo que tiene encendido —ya lo hace, y por eso este incidente se cierra en
veinte minutos en vez de en dos horas—. La segunda, la que te llevas al trabajo
real: **ante un intermitente, mide antes de investigar.** Un porcentaje estable
apunta a configuración; una ráfaga correlacionada con la hora apunta a carga; un
fallo que sólo le pasa a una persona apunta a su ambiente. Son tres
investigaciones distintas y el número te dice cuál.

**Por qué llegó a producción**

En el caso del curso, porque alguien dejó una variable de entorno puesta. En un
sistema real, este ticket es el que más veces se cierra como *"no reproducible"*:
el usuario no puede dar pasos exactos, el desarrollador lo intenta tres veces, le
funciona las tres, y el ticket se archiva. El fallo no se arregla porque nadie lo
mide — y seis meses después vuelve a entrar el mismo ticket escrito por otra
persona.

**Si tu causa fue distinta a esta**

- Si dijiste **"el servidor se está cayendo"**, el porcentaje estable lo tumba, y
  el log del mock lo remata: hay línea de cada petición, incluidas las que
  fallaron.
- Si dijiste **"es la red del laboratorio"**, un problema de red daría `status: 0`
  con `code: NETWORK`, no un `500` con cuerpo. El `code` que normaliza el effect
  está justamente para que no tengas que adivinar esto.
- Si notaste además que **el botón de reintentar deja de funcionar** después del
  primer fallo, has encontrado un segundo bug de verdad y no es el caos: es un
  `catchError` colocado fuera del `switchMap`, que completa el observable de
  acciones y mata el effect para siempre. Está en la tabla de
  [`forense-fase-01.md`](./forense-fase-01.md) y en el
  [**Apéndice A05**](./a05-rxjs.md). Anótalo aparte: dos bugs en un mismo ticket
  es exactamente lo que un intermitente esconde mejor.

</details>

---

## Incidente 09 — El paciente que di de baja sigue saliendo en la lista

> **Fase:** 5 · **Categoría:** Estado (store) · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 30-45 min · **Ruta forense:** [`forense-fase-05.md`](./forense-fase-05.md)

### 🎫 El ticket

> *"Di de baja a un paciente duplicado el lunes. La tabla ya no lo muestra, pero
> el lunes siguiente volvió a aparecer. Le di de baja otra vez. ¿Se está
> reactivando solo?"*

**Reportado por:** auxiliar de recepción
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducir, contestar con evidencia la pregunta que hace el ticket —*¿se está
reactivando solo?*— y localizar el consumidor responsable. El fix es de una
palabra; lo que se evalúa es que sepas decir **por qué el dato estaba bien todo el
tiempo**.

### 🔧 Preparación

Rama de git. Alguien "ordenó" el componente de la lista la semana pasada y dejó
un selector distinto del que había.

```bash
git checkout -b incidente/09 fase-05-pacientes
npm run seed     # parte de la semilla, para que los números cuadren
```

Reproduce como quien reportó: da de baja a un paciente desde la tabla, y fíjate
en qué pantallas sigue apareciendo y en cuáles no.

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Antes de mirar el código: comprueba el dato. ¿Qué dice `db.json` del paciente que
diste de baja? Si el dato es correcto, el bug no está en la escritura y toda la
investigación se mueve a la lectura.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Haz el inventario que el ticket insinúa sin querer: recorre las pantallas donde
aparece un paciente y anota en cuáles sale el dado de baja y en cuáles no. Dos
pantallas que muestran lo mismo y no coinciden no leen del mismo sitio.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

`grep -rn "selectAllPatients\|selectActivePatients\|selectFilteredPatients" src/`.
¿Cuántos selectores devuelven pacientes, qué devuelve cada uno, y quién consume
cada uno?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

Nadie se reactiva. La baja funcionó perfectamente y el dato lleva ahí desde el
lunes:

```bash
grep -A3 '"documentId": "CC-1032456789"' db.json
#   "fullName": "Ana Ruiz",
#   "active": false,
```

Lo que falla es la **lectura**. En el slice conviven tres selectores que devuelven
pacientes y **no devuelven lo mismo**:

```typescript
selectAllPatients        // todos, incluidos los dados de baja. Existe desde la Fase 1.
selectActivePatients     // filtra por active !== false
selectFilteredPatients   // sobre los activos, aplica además el texto del filtro
```

Y la rama cambió el consumidor de la lista por el primero:

```typescript
// patient-list.component.ts — lo que trae la rama
this.store.select(PatientsSelectors.selectAllPatients).subscribe(…)
```

El nombre es el problema, y por eso este incidente es 🟡 y no 🟢: **`selectAllPatients`
no miente, pero tampoco avisa.** "Todos los pacientes" es exactamente lo que
alguien quiere en una lista de pacientes; que "todos" incluya a los dados de baja
es información que sólo está en la implementación del selector, a dos archivos de
distancia del componente que lo usa.

> 🧬 Y la pregunta del método contestada del lado tranquilo: **no lo escribió el
> sistema**. El dato nunca estuvo mal. Si la baja hubiera fallado de verdad,
> `active` seguiría en `true` y estaríamos en otra investigación — la de por qué un
> `PATCH` con `201` no cambió nada.

**Parche mínimo**

```typescript
// Una palabra. La tabla muestra pacientes con los que se puede trabajar,
// y un paciente dado de baja no es uno de ellos.
this.store.select(PatientsSelectors.selectFilteredPatients).subscribe(…)
```

**La refactorización correcta** (que en Track A 💸 no se paga)

Que el nombre no admita el malentendido: `selectAllPatients` →
`selectAllPatientsIncludingInactive`. Es un renombrado mecánico y aun así **no es
un hotfix**: toca todos los consumidores del curso —la Fase 6, la 7, la 9 y la
11 lo usan— y un renombrado transversal el viernes a las seis es cómo se rompen
tres pantallas para arreglar una. Va con su ticket y con sus pruebas.

> ⚠️ Y hay una consecuencia de este mismo diseño **que sigue viva en el proyecto**,
> a propósito: el selector de paciente del formulario de órdenes de la **Fase 6**
> consume `selectAllPatients`, así que un paciente dado de baja se puede elegir
> para una orden nueva. Está declarado como deuda 💸 en esa fase. Si tu
> investigación llegó ahí, no encontraste otro bug: encontraste el mismo, en el
> consumidor que nadie cambió.

**Prueba de regresión**

```typescript
// src/app/patients/store/patients.selectors.spec.ts
it('selectActivePatients deja fuera al dado de baja y conserva al dato viejo', function () {
  var items = [
    { id: 1, fullName: 'Ana Ruiz', active: true } as any,
    { id: 2, fullName: 'Beto Diaz', active: false } as any,
    { id: 3, fullName: 'Cielo Mora' } as any            // sin campo: dato anterior a la baja lógica
  ];

  var result = PatientsSelectors.selectActivePatients.projector(items);

  var ids = result.map(function (p) { return p.id; });
  expect(ids).toContain(1);
  expect(ids).not.toContain(2);
  // La defensa de datos viejos: 'active !== false', no 'active === true'.
  expect(ids).toContain(3);
});
```

**Prevención**

Un test por consumidor que fije **qué selector le toca a cada pantalla**, y un
comentario en `selectAllPatients` que diga para qué existe. La regla general, que
vale más allá de NgRx: **cuando dos funciones devuelven "lo mismo" y una filtra,
el nombre de la que no filtra tiene que decirlo.** Si el nombre sólo es honesto
para quien escribió la implementación, el bug es cuestión de tiempo.

**Por qué llegó a producción**

Porque la baja lógica llegó después. En la Fase 1 había un solo selector y "todos
los pacientes" quería decir todos los pacientes, sin ambigüedad posible. El día
que se añadió `active`, el significado de esa palabra cambió en el dominio pero no
en el código, y nadie revisó los consumidores que ya existían. Es el patrón más
común de este curso: **un concepto nuevo del negocio que no se propaga a los
nombres viejos**, y el sistema queda diciendo la verdad de antes.

**Si tu causa fue distinta a esta**

- Si dijiste **"el PATCH no guardó"**, el `db.json` lo tumba en diez segundos, y
  el log del mock también: hay línea, hay `200`, y el campo cambió.
- Si dijiste **"el seed lo está reactivando"**, es una hipótesis excelente y hay
  que darle crédito: `npm run seed` regenera los datos y devolvería al paciente a
  `active: true`. Compruébalo mirando si el resto de tus cambios también
  desaparecieron. Si sólo volvió ese paciente, no fue el seed.
- Si tu fix fue **cambiar el selector para que filtre por dentro**, o sea hacer
  que `selectAllPatients` deje de devolver todos: funciona para esta pantalla y
  rompe las otras cuatro que lo usan **queriendo** a los inactivos —el histórico de
  una orden antigua tiene que poder mostrar el nombre de un paciente dado de
  baja—. Es el ejemplo perfecto de un fix que arregla el síntoma en el sitio
  equivocado.

</details>

---

## Incidente 10 — Guardo y a veces no se guarda

> **Fase:** 5 · **Categoría:** Concurrencia · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 60-90 min · **Ruta forense:** [`forense-fase-05.md`](./forense-fase-05.md)

### 🎫 El ticket

> *"Registro un paciente, la ventana se cierra, y a veces no queda guardado. No
> sale ningún error, la pantalla se ve normal. Me pasa sobre todo a primera hora,
> cuando estoy dando de alta a varios seguidos. Ya perdí dos esta semana."*

**Reportado por:** auxiliar de recepción
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducir el alta que desaparece —a voluntad, no esperando a que pase—, y
explicar **por qué no hay ningún error en ninguna parte**. El fix es de una
palabra y tiene dos candidatas: hay que elegir una y defenderla.

### 🔧 Preparación

Dos cosas, porque hacen falta las dos: una rama con el código roto y un flag que
abra la ventana de tiempo. La latencia no es el fallo — es el instrumento que lo
hace visible.

```bash
git checkout -b incidente/10 fase-05-pacientes
CHAOS=latency=3000 npm run mock
npm run seed     # para que el "antes" y el "después" se puedan contar
```

Reproduce lo que hace la auxiliar a primera hora: da de alta a un paciente y,
**sin esperar**, abre el formulario y da de alta al siguiente.

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Cuenta antes de buscar. ¿Cuántas altas pediste, cuántas acciones hay en el log,
cuántas peticiones salieron en Network y cuántos registros hay en `db.json`? Si
esos cuatro números no coinciden, el que falta te dice dónde se perdió.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

En Network, mira la columna Status de las dos peticiones de alta. Una de ellas no
tiene un código: tiene una palabra. Y en el log de acciones, cuenta cuántas
acciones de éxito y cuántas de fallo hay respecto de las altas que pediste.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Una cancelación de RxJS **no es un error**: el observable no emite fallo, se
completa. Con eso: ¿qué operador de aplanado, puesto en `createPatient$`, cancela
la petición anterior cuando llega una nueva?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

`src/app/patients/store/patients.effects.ts`, el operador de aplanado de
`createPatient$`:

```typescript
// Lo que trae la rama
switchMap(function (action) {
  return this.patientsService.createPatient(action.patient).pipe(…);
}.bind(this))
```

`switchMap` **cancela** el observable anterior cuando llega un valor nuevo. En una
lectura eso es exactamente lo que quieres —la búsqueda vieja ya no importa—. En
una escritura significa que la segunda alta aborta la primera **a mitad del
viaje**, y como una cancelación de RxJS no es un error, no hay `Failure`, no hay
`catchError`, no hay nada. El alta desaparece en silencio.

Los cuatro números del recorrido, que es como se ve:

```
Altas que pidió el usuario ............ 2
Acciones [Patients] Create Patient .... 2
Peticiones POST en Network ............ 2   ← una de ellas: (canceled)
Registros nuevos en db.json ........... 1
```

```
Name        Status      Type  Time
patients    (canceled)  xhr   1.2 s
patients    201         xhr   3.0 s
```

Y en el log de acciones, la firma que lo cierra: **dos `Create Patient` y un solo
`Create Patient Success`**. Ni un `Failure`. El sistema hizo lo que se le pidió;
lo que se le pidió estaba mal escrito.

La latencia no causa nada: sólo ensancha la ventana. Con el mock normal la
respuesta vuelve en veinte milisegundos y la segunda alta llega cuando la primera
ya terminó. "Pasa a primera hora" no es folclore — es la línea compartida con el
respaldo nocturno, o sea, latencia.

**Parche mínimo**

```typescript
// Las escrituras NO se cancelan. mergeMap las deja correr en paralelo, que es
// el caso normal del laboratorio: dos recepcionistas dando de alta a dos
// pacientes distintos al mismo tiempo.
mergeMap(function (action) {
  return this.patientsService.createPatient(action.patient).pipe(…);
}.bind(this))
```

Y la segunda candidata, que hay que nombrar para descartarla a conciencia:
`exhaustMap` **ignora** cualquier alta que llegue mientras hay una en curso. Cura
el síntoma —nada se pierde a medias— y rompe el caso normal: la segunda
recepcionista pulsa Guardar, no pasa absolutamente nada, y no hay ni error ni
registro. Cambia un alta perdida por un alta ignorada.

> 🧭 **Un operador de aplanado es una decisión de negocio escrita como una palabra
> de siete letras.** `switchMap` dice "sólo importa la última", `mergeMap` dice
> "todas importan", `concatMap` dice "todas, en orden", `exhaustMap` dice "la
> primera manda". Antes de elegir uno, di la frase en voz alta con el dominio
> puesto: *"de dos altas de pacientes distintos, sólo importa la última"* se cae
> sola.

**La refactorización correcta** (que en Track A 💸 no se paga)

Lo que hace que este bug sea invisible no es el operador: es que **el sistema no
le cuenta al usuario que está trabajando**. El estado ya lo sabe —`saving: true`
está en el reducer y `selectPatientsSaving` está exportado— y ninguna plantilla lo
consume:

```bash
grep -rn "selectPatientsSaving" src/
# src/app/patients/store/patients.selectors.ts:  export const selectPatientsSaving = ...
```

Una sola línea de salida: el selector existe y nadie lo usa. Conectarlo —dejar el
diálogo abierto hasta el éxito, o deshabilitar la apertura del siguiente
formulario mientras hay una escritura en vuelo— es lo que cierra la ventana de
verdad, y es un cambio de comportamiento de la pantalla con su ticket. La deuda
está declarada en la **Fase 5 §5.8**, junto con su hermana: `reloadAfterWrite$`
recarga la lista entera después de cada escritura y **duplica** esa ventana de
confusión, de tres segundos a seis.

**Prueba de regresión**

```typescript
// src/app/patients/store/patients.effects.spec.ts
it('dos altas seguidas producen dos éxitos: ninguna se cancela', function (done) {
  var completed: string[] = [];
  spyOn(service, 'createPatient').and.callFake(function (patient: any) {
    // La primera tarda más que la segunda: es la condición que switchMap pierde.
    return timer(patient.fullName === 'Ana Ruiz' ? 50 : 10).pipe(map(function () { return patient; }));
  });

  effects.createPatient$.subscribe(function (action) {
    completed.push(action.type);
    if (completed.length === 2) {
      // Con switchMap acá sólo llega UNO, y el test se cuelga hasta el timeout.
      expect(completed.filter(function (t) {
        return t === PatientsActions.createPatientSuccess.type;
      }).length).toBe(2);
      done();
    }
  });

  actions$.next(PatientsActions.createPatient({ patient: { fullName: 'Ana Ruiz' } as any }));
  actions$.next(PatientsActions.createPatient({ patient: { fullName: 'Beto Diaz' } as any }));
});
```

**Prevención**

La regla escrita en el propio archivo de effects, arriba del todo: **lecturas con
`switchMap`, escrituras con `mergeMap` o `concatMap`, y nunca `switchMap` sobre
algo que cambie datos.** Es una línea de comentario y evita la familia entera. El
detalle de cada operador está en el [**Apéndice A05**](./a05-rxjs.md), con la
tabla de cuándo usar cuál.

**Por qué llegó a producción**

Porque `switchMap` es el operador que todo el mundo aprende primero y el que
aparece en todos los ejemplos de NgRx —que son, casi sin excepción, ejemplos de
**carga**—. Copiado a una escritura, sigue compilando, sigue pasando los tests del
camino feliz y sólo falla cuando dos operaciones se solapan, cosa que en
desarrollo no ocurre nunca porque el servidor está en la misma máquina. El bug
necesita latencia para existir, y la latencia es justo lo que no hay donde se
escribe el código.

**Si tu causa fue distinta a esta**

- Si dijiste **"el usuario pulsó dos veces el botón"**, es el hermano de este
  incidente y es otra historia: ahí hay **dos** altas del mismo paciente y el
  problema es que nada las impide. Se diagnostica con el mismo cronómetro y está
  entera en [`forense-fase-05.md`](./forense-fase-05.md).
- Si dijiste **"el validador de documento duplicado falló"**, ese validador existe
  y funciona; lo que no puede es validar contra un dato que todavía no llegó al
  servidor, y su `catchError` devuelve `of(null)` a propósito: ante la duda, deja
  pasar.
- Si dijiste **"el reducer no inserta el paciente"**, tienes razón y no es un bug:
  `createPatientSuccess` sólo apaga `saving`, y la tabla se repuebla con la
  recarga completa. Está blindado con un test en la Fase 12 precisamente para que
  nadie lo "arregle".
- Si tu fix fue **`exhaustMap`**, funciona y tienes que poder defenderlo delante de
  alguien que te pregunte qué pasa cuando dos recepcionistas guardan a la vez. Si
  no puedes, no era el fix: era el primero que hizo desaparecer el síntoma.

</details>

---

## Incidente 11 — La muestra figura procesada pero nunca se recibió

> **Fase:** 7 · **Categoría:** Máquina de estados · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 60-90 min · **Ruta forense:** [`forense-fase-07.md`](./forense-fase-07.md) ⭐

### 🎫 El ticket

> *"Hay una muestra que figura como procesada pero el analista de la tarde jura
> que nunca la recibió. Dice que él no la tuvo en la mano. La orden ya salió con
> resultado y la firmó él."*

**Reportado por:** coordinadora del turno de la tarde
**Ambiente:** UAT
**Dato duro que trae el ticket:** ninguno. Ni el id de la muestra, ni la hora.

### 🎯 Qué se te pide

Contestar **una sola pregunta**, y contestarla con evidencia: 🧬 *¿esto lo
escribió el sistema, o llegó ya roto en el dato?* De la respuesta dependen dos
investigaciones que no comparten ni una herramienta. Y después, la pregunta
incómoda que viene detrás: **¿cuántas más hay?**

Este incidente **no termina en fix de código**. Termina en un diagnóstico, un
recuento y una recomendación.

### 🔧 Preparación

Un `db.json` alterno: el bug está en el dato, no en el código. Guarda el tuyo
antes o vuelve con `npm run seed` al terminar.

```bash
cp db.json db.json.mio
cp db.incidente-11.json db.json
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Empieza por la pantalla, treinta segundos: abre la orden y mira la línea de
custodia de la muestra. La línea no dibuja estados, dibuja **eventos que dejaron
firma**. Si falta uno, la pregunta es por qué falta la firma, no por qué falta el
dibujo.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Con la aplicación abierta y el log de acciones a la vista, busca **cualquier
intento de transición** sobre esa muestra. Que no haya éxito es un dato; que no
haya ni siquiera intento es un dato completamente distinto, y manda la
investigación a otro sitio.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Corre `npm run seed` y vuelve a mirar la muestra. Si el estado imposible
**reaparece** sobre datos recién generados, ¿puede haberlo escrito la aplicación
alguna vez?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

**El sistema no escribió nada.** La muestra llegó rota.

La cadena de evidencia, en el orden en que hay que producirla:

1. **El hueco es real y está en el dato**, no en la plantilla:

   ```
   Muestra 501 — estado actual: processed

     Recogida    analista1    2019-09-02 10:05
     Procesada   analista1    2019-09-02 16:40
   ```

   `custodyEvents()` sólo empuja un evento si el campo `*By` tiene valor. Falta
   "Recibida" porque falta `receivedBy` en el registro.

   ```bash
   grep -n -A6 '"id": 501' db.json
   #   "status": "processed",
   #   "collectedBy": "analista1",
   #   "processedBy": "analista1",
   #   "processedAt": "2019-09-02T16:40:12.418-05:00"
   #   ← no hay receivedBy, no hay receivedAt
   ```

2. **No hay intento en el log.** Ni `[Samples] Transition Sample`, ni éxito, ni
   fallo. La guarda del reducer no rechazó nada porque nadie le pidió nada.

3. **El estado imposible sobrevive a un `seed` limpio**, que es la prueba que
   cierra el caso:

   ```bash
   npm run seed && grep -n -A6 '"id": 501' db.json
   # sigue ahí, idéntico
   ```

Si el registro inconsistente nace de un semillero determinista, **ninguna
ejecución de la aplicación pudo haberlo producido**. La aplicación queda
descartada por completo, y con ella el reducer, el effect, el mapa de
transiciones y cualquier hipótesis de concurrencia.

> 🧬 Esa es la bifurcación que esta pieza estrena, y equivocarla cuesta medio día:
> quien empieza leyendo `sample.transitions.ts` puede pasarse la mañana entendiendo
> a la perfección un código que en este incidente **nunca corrió**.

**De dónde salió, entonces.** Las cuatro procedencias posibles, y el sistema de
hoy **no puede distinguirlas**: una migración de datos, un `PATCH` suelto hecho
con `curl` para "arreglar" algo, una carga desde el analizador externo, o alguien
editando el archivo a mano. Eso —no poder saberlo— es el hallazgo de verdad del
incidente, y es exactamente el hueco que la **Fase 11** viene a tapar con el
`auditLog`, que guarda el `before`/`after` de cada mutación.

**Parche mínimo**

Para esta muestra, un `PATCH` que registre lo que se pueda sostener con evidencia
física —el libro de recepción en papel, si existe— y **nunca** una firma
inventada:

```bash
# NO se rellena receivedBy con el nombre del que procesó. Eso es fabricar
# una firma, y en un dominio con custodia regulada es peor que el hueco.
curl -X PATCH http://localhost:3000/samples/501 \
  -H "Content-Type: application/json" \
  -d '{"custodyNote":"receivedBy no reconstruible; ver incidente 11"}'
```

Y el recuento, que es la otra mitad del entregable:

```bash
# ¿Cuántas más tienen processedBy sin receivedBy? El patrón se busca entero.
grep -c '"processedBy"' db.json
grep -c '"receivedBy"' db.json
```

Si los dos números no coinciden, la diferencia es el tamaño del problema. Un
ticket que dice *"hay una muestra rara"* y un post-mortem que dice *"hay catorce,
todas de la misma semana de 2019, y ninguna la escribió esta aplicación"* son dos
documentos con destinos distintos: el segundo va a Calidad.

**La refactorización correcta** (que en Track A 💸 no se paga)

Que el estado imposible **no pueda entrar**, ni por la aplicación ni por fuera de
ella. Eso es una validación del lado del servidor, y en el track base el servidor
no es nuestro: json-server escribe lo que le manden. El track 🔥 BE lo construye
—es literalmente su fase `be05`, la cadena de custodia y la transacción que no
existe— y ahí se ve el precio real: sin una transacción, la mutación y su asiento
de auditoría pueden quedar separados.

Lo que sí cabe dentro del track base es un **detector**: un guion que recorra los
datos buscando el patrón y avise. No arregla nada; convierte un hallazgo por
casualidad en una revisión periódica, que es toda la diferencia.

**Prueba de regresión**

No hay test de Karma que cace esto —el dato no nace en la aplicación—, así que la
regresión se escribe donde el dato entra. Lo que sí se blinda es que **la
aplicación nunca lo produzca**:

```typescript
// src/app/samples/store/samples.reducer.spec.ts
it('rechaza processed desde scheduled y deja el estado intacto', function () {
  var previousState: SamplesState = {
    ...initialState,
    items: [{ id: 501, status: 'scheduled' } as any]
  };
  var action = SamplesActions.transitionSample({ sampleId: 501, toStatus: 'processed' });

  var result = samplesReducer(previousState, action);

  // Misma referencia: la guarda cortó antes de construir nada.
  expect(result).toBe(previousState);
});

it('el detector encuentra una muestra procesada sin recibir', function () {
  var samples = [
    { id: 500, status: 'processed', collectedBy: 'a', receivedBy: 'b', processedBy: 'c' } as any,
    { id: 501, status: 'processed', collectedBy: 'a', processedBy: 'c' } as any
  ];
  // Es el guion de arriba, escrito como función y probado.
  expect(findBrokenCustody(samples).map(function (s) { return s.id; })).toEqual([501]);
});
```

**Prevención**

El detector corriendo periódicamente, y la regla que se lleva al trabajo real:
**en un dominio con reglas, la integridad se comprueba sobre los datos, no sólo
sobre el código.** Un sistema puede tener el mejor reducer del mundo y estar lleno
de registros que entraron por otra puerta.

**Por qué llegó a producción**

Porque durante seis años hubo más de una puerta de escritura y sólo una de ellas
—la aplicación— tenía las reglas. El `db.json` de LabCore equivale a una base a la
que también llegaron migraciones, cargas del analizador y correcciones manuales de
madrugada, y ninguna de esas rutas conocía la máquina de estados. Nadie decidió
saltarse la custodia: se decidió, muchas veces y con buenas razones cada vez,
escribir directamente en la base porque la aplicación no ofrecía la operación que
hacía falta esa noche.

**Si tu causa fue distinta a esta**

- Si concluiste que **alguien editó `SAMPLE_TRANSITIONS`**, es una de las tres
  causas reales de la otra rama y se descarta en diez segundos con
  `git diff HEAD -- src/app/samples/store/sample.transitions.ts`. Vale la pena
  hacerlo igual: es el primer sitio donde mirar cuando **sí** hay intento en el
  log.
- Si concluiste que **se validó contra un estado viejo** (dos transiciones
  solapadas), tendrías que ver dos intentos antes del primer éxito en el log. Con
  cero intentos no hay carrera posible: el reducer es puro y síncrono.
- Si dijiste **"el servidor lo cambió por su cuenta"**, json-server no tiene
  lógica: escribe lo que le mandan. Es la hipótesis que más gente propone en una
  reunión y la que menos cuesta tumbar.
- Si tu "fix" fue **rellenar `receivedBy` con el analista que procesó**, para y
  anótalo en el post-mortem: acabas de fabricar una firma de custodia. El hueco es
  incómodo y es la verdad; taparlo convierte un problema de datos en un problema
  de auditoría.

</details>

---

## Incidente 12 — El resultado quedó validado pero sin norma detrás

> **Fase:** 8 · **Categoría:** Normativo · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 40-60 min · **Ruta forense:** [`forense-fase-08.md`](./forense-fase-08.md)

### 🎫 El ticket

> *"Auditoría nos pidió, para una muestra de 2019, contra qué límites se validó
> ese resultado. Abrí el registro y el campo de la versión de norma está vacío.
> Pero el resultado dice 'validado' y tiene mi nombre. ¿Cómo lo validé sin norma?"*

**Reportado por:** analista de resultados
**Ambiente:** PROD

### 🎯 Qué se te pide

Contestar si esos registros los produjo la aplicación o llegaron así, **contar
cuántos hay**, y decir qué se puede reconstruir y qué no. Como en el **11**, el
entregable es un recuento y una declaración, no un parche.

### 🔧 Preparación

Ninguna de las tres formas: este dato lo genera tu propio semillero, a propósito,
desde la Fase 8.

```bash
npm run seed
curl -s "http://localhost:3000/results?status=validated" | grep -c '"rangeVersionApplied": null'
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Antes de buscar culpables, pregúntate qué **tendría** que haber en ese campo y
quién lo escribe. No es el reducer: búscalo en el effect, en el momento exacto en
que un resultado pasa a validado.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Valida tú un resultado ahora mismo, con la aplicación, y mira el cuerpo del PATCH
en Network. Compara los campos que estampa con los que tiene el registro del
ticket. La diferencia entre los dos es el diagnóstico.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si la aplicación **siempre** estampa la versión al validar, un registro validado
sin versión no pudo salir de ella. ¿De dónde salen los resultados que ya estaban
en `validated` la primera vez que arrancaste el sistema?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

Los registros **nacieron así**. Los siembra `seed.js` y ninguna ejecución de la
aplicación los tocó nunca.

La comparación que lo demuestra, y que cuesta dos minutos. Esto es lo que estampa
el effect al validar de verdad:

```json
{
  "status": "validated",
  "validatedBy": "analista1",
  "validatedAt": "2019-09-02T16:40:12.418-05:00",
  "rangeVersionApplied": 2,
  "outOfRange": false,
  "critical": false
}
```

Y esto es lo que tiene el registro del ticket:

```json
{
  "status": "validated",
  "validatedBy": "analista1",
  "validatedAt": "2019-06-14T09:12:00-05:00",
  "rangeVersionApplied": null
}
```

Mismo estado, misma firma, **y sin la norma**. La aplicación no puede producir eso:
`rangeVersionApplied` se congela en el effect, en el mismo `patch` que pone
`status: 'validated'`, y los dos viajan en la misma petición. O están los dos, o no
está ninguno.

> 🧬 La pregunta del método, contestada del lado del dato: **no lo escribió el
> sistema.** Y es el mismo hallazgo del incidente **11** con otra ropa — un estado
> imposible según las reglas del dominio, aceptado sin una sola queja, porque
> ninguna de las dos reglas vive donde el dato entra.

**Por qué es un dato imposible**, dicho para quien no conoce el dominio: un
resultado validado es un **veredicto oficial**. Decir "este potasio está dentro de
lo normal" sin poder decir contra qué límites se comparó es como firmar un
certificado sin citar la norma. Y no es recuperable a posteriori: los rangos están
versionados precisamente porque cambian, así que "recalcularlo hoy" daría el
veredicto de **hoy**, no el que se emitió aquel día. La información no está
perdida en el sentido de "hay que buscarla": **no existe**.

**Parche mínimo**

Ninguno sobre los datos. Y esto es lo importante del incidente: **la tentación es
rellenar el campo**, y rellenarlo es peor que el hueco.

```javascript
// ❌ LO QUE NO SE HACE. Recalcula con las normas de HOY y estampa un número
//    que nadie aplicó nunca. Convierte un hueco honesto en un dato falso.
db.results.filter(validatedSinNorma).forEach(function (r) {
  r.rangeVersionApplied = selectActiveRange(ranges, r.analyte, r.validatedAt).version;
});
```

Lo que sí se hace es el recuento y la marca:

```bash
# ¿Cuántos son, y de qué periodo?
curl -s "http://localhost:3000/results?status=validated" \
  | grep -c '"rangeVersionApplied": null'
```

Y un campo nuevo que diga la verdad —`rangeVersionApplied: null` más una nota de
que es irreconstruible— para que el siguiente que abra el registro no repita esta
investigación desde cero.

**La refactorización correcta** (que en Track A 💸 no se paga)

Que el estado imposible no pueda entrar, y eso sólo se consigue donde el dato
entra: en el servidor. En el track base el servidor es json-server y escribe lo
que le manden. El track 🔥 BE lo construye y llega exactamente a este registro: es
su fase `be06`, *"los rangos versionados y la historia que se sobrescribió"*, y
ahí el veredicto es aún más incómodo —hay 37 resultados cuyo juicio no se puede
reproducir y el entregable del track es **declararlos irrecuperables por
escrito**—.

Del lado del cliente, lo único que cabe es una guarda en el reducer que rechace
un `validated` sin `rangeVersionApplied`. Protege de un bug futuro y no arregla
ni uno de los registros que ya están.

**Prueba de regresión**

```typescript
// src/app/results/store/results.reducer.spec.ts
it('rechaza validar un resultado sin la versión de norma aplicada', function () {
  var previousState: ResultsState = {
    ...initialState,
    currentSample: { id: 501, status: 'processed' } as any,
    items: [{ id: 900, sampleId: 501, status: 'preliminary' } as any]
  };
  var action = ResultsActions.validateResult({
    resultId: 900,
    patch: { status: 'validated', validatedBy: 'analista1', rangeVersionApplied: null } as any
  });

  var result = resultsReducer(previousState, action);

  // Un veredicto oficial sin norma detrás no es un veredicto: es una firma
  // en blanco. Misma referencia = la guarda cortó.
  expect(result).toBe(previousState);
});

it('el detector encuentra los validados sin norma', function () {
  var results = [
    { id: 900, status: 'validated', rangeVersionApplied: 2 } as any,
    { id: 901, status: 'validated', rangeVersionApplied: null } as any,
    { id: 902, status: 'preliminary', rangeVersionApplied: null } as any  // correcto: aún no se juzgó
  ];
  expect(findValidatedWithoutRange(results).map(function (r) { return r.id; })).toEqual([901]);
});
```

El tercer caso del segundo test es el que hay que leer despacio: un `preliminary`
sin versión **es correcto**, porque todavía no se emitió ningún veredicto. Un
detector que no distinga los dos casos produce una lista inútil de mil registros.

**Prevención**

El detector corriendo periódicamente y la guarda en el reducer. Y la regla
general, que vale para cualquier dominio con normativa: **cuando un registro
representa un juicio, la norma con la que se juzgó es parte del registro, no un
dato que se pueda recalcular después.** Si se puede recalcular, no era un juicio:
era una consulta.

**Por qué llegó a producción**

Porque el versionado de rangos llegó después de que ya hubiera resultados
validados. Cuando se añadió `rangeVersionApplied`, los registros anteriores se
quedaron en `null` —que es lo que hace cualquier migración que añade una columna—
y nadie decidió qué hacer con ellos. No hubo una decisión mala: hubo una decisión
que nadie tomó, y el `null` quedó significando dos cosas a la vez: "todavía no se
juzgó" y "se juzgó antes de que empezáramos a anotarlo". Un mismo valor con dos
significados es cómo se pierde una historia clínica sin que nadie borre nada.

**Si tu causa fue distinta a esta**

- Si dijiste **"el effect no está estampando la versión"**, compruébalo validando
  uno ahora: el PATCH lleva los seis campos. Si en tu proyecto **no** los lleva,
  no has encontrado este incidente: has encontrado la nota de continuidad de la
  **Fase 8 §5.4**, y te falta el circuito de `referenceRanges` en el store. Con él
  vacío, `selectActiveRange` no tiene contra qué comparar y **todos** los
  validados quedan sin norma — que es un bug universal, no una inconsistencia
  sembrada.
- Si dijiste **"alguien editó el registro a mano"**, es posible y no se puede
  demostrar: hoy el sistema no distingue una escritura de la aplicación de una
  escritura por fuera. Ese hueco es el que la **Fase 11** viene a tapar, y su
  incidente es el **17**.
- Si tu fix fue **rellenar el campo recalculando**, para y anótalo en el
  post-mortem. Es exactamente lo que este incidente entrena a no hacer: la
  diferencia entre un dato ausente y un dato inventado no se ve en la pantalla, y
  sólo aparece el día que alguien de auditoría pregunta de dónde salió.

</details>

---

## Incidente 13 — Dos analistas firmaron el mismo resultado

> **Fase:** 8 · **Categoría:** Concurrencia · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 60-90 min · **Ruta forense:** [`forense-fase-08.md`](./forense-fase-08.md)

### 🎫 El ticket

> *"El resultado de la orden 4021 aparece validado por Julián, y yo lo validé. Me
> acuerdo perfectamente porque lo revisé dos veces. Los dos estábamos cerrando el
> turno a la vez. ¿Puede quedar firmado por quien no lo firmó?"*

**Reportado por:** analista de la mañana
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducirlo **a voluntad** —no esperando a que dos analistas coincidan—, explicar
por qué la doble guarda del reducer, que existe justo para esto, no lo impidió, y
decir qué firma quedó en el registro y por qué. El fix del lado del cliente no
existe: averiguar eso es el ejercicio.

### 🔧 Preparación

Una rama no hace falta: el código está bien. Hace falta **abrir la ventana de
tiempo**, que es un flag, y dos sesiones.

```bash
CHAOS=latency=3000 npm run mock
```

Abre dos ventanas del navegador con sesiones distintas —una normal y una de
incógnito— y entra con `analista1` en una y `analista2` en la otra. Pon las dos en
el mismo resultado preliminar y pulsa Validar en las dos **dentro de la misma
ventana de tres segundos**.

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

La guarda del reducer comprueba que la transición sea legal. Pregúntate contra qué
copia del estado lo comprueba, y quién actualiza esa copia.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Mira las dos peticiones `PATCH` en Network de las dos ventanas: sus horas, sus
cuerpos y sus respuestas. Las dos salieron y las dos devolvieron `200`. Ahora mira
qué quedó guardado.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

En el instante en que el analista 2 pulsa Validar, ¿qué `status` tiene el
resultado **en su store**? ¿Y cuál tiene en el servidor?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

La guarda del reducer funciona perfectamente y **valida contra el store del
navegador que la ejecuta**, que es una copia local de un dato compartido.

La secuencia, con los tres segundos de latencia puestos:

```
t=0.0s  [analista1] store dice preliminary  → la guarda deja pasar → PATCH sale
t=0.5s  [analista2] store dice preliminary  → la guarda deja pasar → PATCH sale
t=3.0s  PATCH de analista1 → 200. El servidor guarda validatedBy: "analista1"
t=3.5s  PATCH de analista2 → 200. El servidor guarda validatedBy: "analista2"
```

Los dos stores decían la verdad **en el momento en que miraron**. Ninguno de los
dos podía saber que el otro existía: un store de NgRx es memoria de una pestaña,
no un candado distribuido. Y el último PATCH gana, sin pelea y sin error, porque
json-server aplica lo que le llega y no compara nada.

Lo que queda en el registro, y es lo que hay que contestarle a la analista:

```json
{
  "status": "validated",
  "validatedBy": "analista2",
  "validatedAt": "2019-09-02T16:40:15.902-05:00",
  "rangeVersionApplied": 2
}
```

**Una sola firma, la del segundo, y ninguna huella de la primera.** No es que
quedara firmado por quien no lo firmó: es que lo firmaron los dos y el sistema
sólo tiene sitio para uno. La validación de la analista de la mañana ocurrió,
respondió `200`, y desapareció.

> ⚠️ Y el agravante que hay que decir en el post-mortem: la irreversibilidad que
> esta fase defiende —un resultado validado no se revalida— **se sostiene sobre la
> misma copia local**. Lo que impide revalidar es una comprobación en memoria del
> navegador. En una sola pestaña funciona; entre dos, no existe.

**Parche mínimo**

**No hay parche de cliente que resuelva esto, y decirlo con seguridad es el
entregable.** Cualquier cosa que se escriba en Angular vuelve a ser una
comprobación contra una copia local: reduce la ventana, no la cierra. Lo que sí
cabe hoy, y es honesto, es **hacer visible el choque cuando ya ocurrió**:

```typescript
// results.effects.ts — después del PATCH, con lo que devolvió el servidor.
// No previene nada: avisa. Si el servidor devuelve una firma distinta de la
// que acabamos de mandar, alguien más validó en el intervalo.
map(function (saved: any) {
  if (saved.validatedBy !== this.authService.getCurrentUser()) {
    return ResultsActions.validateResultConflict({ resultId: saved.id, winner: saved.validatedBy });
  }
  return ResultsActions.validateResultSuccess({ result: saved });
}.bind(this))
```

Con eso, la analista de la mañana ve un mensaje en vez de irse a su casa creyendo
que firmó algo que quedó a nombre de otro. Es lo máximo que da el cliente.

**La refactorización correcta** (que en Track A 💸 no se paga)

La cierra el **servidor**, y sólo el servidor, de una de estas dos formas:

- **Escritura condicional**: el PATCH lleva el estado esperado (`preliminary`) y
  el servidor rechaza con un `409 Conflict` si ya no es ése. Es el patrón de
  *compare-and-swap* de toda la vida, y es lo que un backend con una base de datos
  de verdad hace con una cláusula `WHERE status = 'preliminary'` y mirando cuántas
  filas cambió.
- **Bloqueo optimista con versión**: el registro lleva un contador, el cliente
  manda el que leyó, y el servidor rechaza si no coincide.

Las dos exigen un servidor que compare antes de escribir, y json-server no
compara: escribe. Por eso en el track base esto queda declarado y no arreglado. El
track 🔥 BE lo recoge entero —es su fase `be05`, la cadena de custodia y la
transacción que no existe— y ahí aparece la vuelta de tuerca que este incidente
no puede ver: **el backend real de LabCore corre sobre un `mongod` suelto, sin
replica set, así que ni siquiera puede envolver la comprobación y la escritura en
una transacción.**

**Prueba de regresión**

Lo que se puede probar del lado del cliente no es la carrera —no ocurre en un
test de una sola pestaña— sino que el choque **se detecte** cuando el servidor
devuelva una firma ajena:

```typescript
// src/app/results/store/results.effects.spec.ts
it('avisa cuando el servidor devuelve una firma distinta de la nuestra', function (done) {
  spyOn(authService, 'getCurrentUser').and.returnValue('analista1');
  spyOn(service, 'validate').and.returnValue(
    // Lo que devuelve el servidor: ganó el otro.
    of({ id: 900, status: 'validated', validatedBy: 'analista2' } as any)
  );
  actions$ = of(ResultsActions.validateResult({ resultId: 900, patch: {} as any }));

  effects.validateResult$.subscribe(function (action) {
    // Antes del fix esto era un Success y la analista no se enteraba de nada.
    expect(action.type).toBe(ResultsActions.validateResultConflict.type);
    done();
  });
});

it('la doble guarda rechaza revalidar sobre el estado que YA tiene el store', function () {
  var previousState: ResultsState = {
    ...initialState,
    currentSample: { id: 501, status: 'processed' } as any,
    items: [{ id: 900, sampleId: 501, status: 'validated' } as any]
  };
  var result = resultsReducer(previousState, ResultsActions.validateResult({
    resultId: 900, patch: { status: 'validated' } as any
  }));
  // Esto sí lo protege el cliente: dentro de una misma pestaña, la
  // irreversibilidad se sostiene. Entre dos pestañas, no.
  expect(result).toBe(previousState);
});
```

**Prevención**

Del lado del cliente, el aviso. Del lado del proceso, lo que de verdad reduce la
frecuencia: que dos analistas no estén cerrando el mismo turno sobre los mismos
resultados, que es una decisión de operación y no de software. Y la regla que se
lleva a cualquier sistema: **una comprobación previa a una escritura sólo vale si
la comprobación y la escritura son la misma operación.** Separadas por una
petición de red, no son una guarda: son una sugerencia.

**Por qué llegó a producción**

Porque en desarrollo hay un solo navegador. El bug necesita dos sesiones
simultáneas sobre el mismo registro y una ventana de red de unos segundos, y esas
tres condiciones no se dan nunca en la máquina de quien escribe el código. La
doble guarda del reducer se escribió bien, se probó bien y protege exactamente lo
que puede protegerse desde el navegador — el problema es que en 2019 se asumió que
eso era suficiente, y esa suposición no se escribió en ninguna parte. Nadie la
cuestionó porque no estaba a la vista.

**Si tu causa fue distinta a esta**

- Si dijiste **"la guarda del reducer está mal"**, compruébala: dentro de una
  misma pestaña rechaza el segundo intento sin dudar. El segundo test de arriba lo
  fija. Está bien escrita; lo que no puede es ver otra pestaña.
- Si dijiste **"el servidor tendría que haber devuelto un error"**, tienes toda la
  razón y ése es exactamente el fix correcto. Anótalo: has llegado al diagnóstico
  bueno por el camino de lo que *falta*, que es más difícil que el camino de lo
  que sobra.
- Si dijiste **"hay que bloquear el registro mientras alguien lo edita"**, es una
  solución real —bloqueo pesimista— y trae su propio problema, que conviene tener
  presente antes de proponerlo en la reunión: alguien abre un resultado, se va a
  almorzar, y nadie más puede validarlo. Un bloqueo sin tiempo de expiración
  cambia un incidente por otro.
- Si tu fix fue **deshabilitar el botón de validar mientras la petición viaja**,
  cierra la ventana dentro de una pestaña y no toca la de dos analistas. Es el
  mismo fix que el incidente **10** necesitaba, aplicado a un problema que no es
  ése.

</details>

---

## Incidente 14 — El informe salió con un resultado que ya había cambiado

> **Fase:** 9 · **Categoría:** Estado (store) · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45-60 min · **Ruta forense:** [`forense-fase-09.md`](./forense-fase-09.md)

### 🎫 El ticket

> *"Corregimos el valor de un resultado y volvimos a bajar el informe. El PDF
> sigue trayendo el número viejo. En la pantalla se ve el nuevo. Ya lo bajé tres
> veces, siempre igual. El informe se lo mandamos al paciente."*

**Reportado por:** analista de resultados
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducir —que tiene truco: **en el orden natural no ocurre**— y localizar el
dato equivocado. No está en ninguna de las capas que llevas ocho fases mirando, y
señalar dónde sí está es el ejercicio.

### 🔧 Preparación

Ninguna rama: el comportamiento es el de tu código tal como lo escribiste. Lo que
hace falta es reproducir **en el orden correcto**, que es el que nadie usa.

```
1. Abre la vista de informe de un resultado validado (/reports/9002).
   NO generes el PDF todavía.
2. Sin salir de la vista y sin recargar, cambia el valor del resultado:
   despacha enterResult desde el Dispatcher de Redux DevTools, con ese
   resultId y un value bien distinto (de 105 a 250, para que cambie hasta
   el veredicto).
3. Ahora sí, genera el PDF.
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

La frase clave del ticket es *"en la pantalla se ve el nuevo"*. Eso descarta el
servidor, el store y la carga de datos de un golpe: si estuvieran mal, la pantalla
también lo estaría. Lo que queda es que la pantalla y el PDF **no están leyendo lo
mismo**.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

`grep -n "reportSnapshot" src/app/reports/report/report.component.ts`. Lee las
cinco líneas que salen y pregúntate, para cada una, en qué momento de la vida del
componente se ejecuta.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

La suscripción al store **está viva** y el callback corre con cada emisión nueva.
Entonces, ¿qué hace exactamente la primera línea de ese callback cuando ya hay una
foto tomada?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

`src/app/reports/report/report.component.ts:220`. El PDF no lee del store: lee de
una **propiedad local del componente** que se llena una sola vez y no se refresca
nunca.

```typescript
if (!resultsState || this.reportSnapshot) {
  return;                    // ya hay foto: no se refresca nunca más
}
```

Y acá está la crueldad del diseño, que hay que leer despacio: **la suscripción
está viva**. No hay `take(1)`. El store sigue emitiendo valores frescos y el
callback sigue ejecutándose con cada uno — y ese `return` los descarta todos. Un
lector apurado ve una suscripción abierta y asume datos frescos. La mentira no
está en la suscripción: está en el `return`.

La evidencia definitiva, con un breakpoint en la línea de `generate(...)` y la
ejecución detenida:

```js
this.reportSnapshot.value
// 105

// Y al mismo tiempo, el panel State de Redux DevTools:
// results.items[0].value  ->  250
```

Dos verdades simultáneas en la misma pantalla, y ninguna herramienta las enfrenta
por ti: el store aparece en Redux DevTools, la propiedad del componente **no
aparece en ningún sitio**. Por eso este bug sobrevive tanto tiempo — no está en
ninguna de las capas que se inspeccionan.

> 🧭 Por eso el orden de los actos importa para reproducirlo. En el orden natural
> —cambiar el dato y *después* abrir el informe— el componente se construye
> **después** del cambio, la foto sale correcta y no hay bug. El bug sólo existe
> para quien deja la vista abierta, que es exactamente lo que hace alguien que
> corrige un valor y vuelve a bajar el informe sin cerrar nada.

**Parche mínimo**

```typescript
// El informe se arma con lo que el store dice AHORA, no con lo que decía
// cuando se abrió la pantalla. El snapshot se recalcula en cada emisión.
if (!resultsState) {
  return;
}
this.reportSnapshot = { … };     // sin la guarda del "ya hay foto"
```

**La refactorización correcta** (que en Track A 💸 no se paga)

Que el PDF se arme **en el momento de generarlo**, leyendo el store una sola vez
en ese instante, en vez de mantener una copia viva a medias:

```typescript
onGenerate() {
  this.store.select(selectReportData(this.resultId)).pipe(take(1))
    .subscribe(function (this: ReportComponent, data) {
      this.reportService.generate(data);
    }.bind(this));
}
```

Es el patrón correcto —un `take(1)` **en el momento del acto**, no al abrir la
pantalla— y aun así no es un hotfix: cambia de dónde saca los datos el generador
de informes, o sea el contrato entre el componente y el `ReportService`, y eso se
toca con pruebas. La deuda está declarada en la **Fase 9**.

> ⚠️ Y una advertencia para la reunión: alguien va a proponer "congelar el informe
> a propósito, porque un informe entregado no debe cambiar". Esa idea es **buena**
> y es otra cosa: congelar al **entregar**, guardando la foto en el registro de
> entrega, no congelar al **abrir la pantalla**. La diferencia entre las dos es
> todo el incidente.

**Prueba de regresión**

```typescript
// src/app/reports/report/report.component.spec.ts
it('el informe usa el valor actual del store, no el de cuando se abrió', function () {
  var store = TestBed.get(MockStore);
  store.setState(stateConResultado(9002, 105));
  fixture.detectChanges();                       // se abre la vista: foto con 105

  // El valor cambia mientras la vista sigue abierta.
  store.setState(stateConResultado(9002, 250));
  fixture.detectChanges();

  var reportService = TestBed.get(ReportService);
  spyOn(reportService, 'generate');
  component.onGenerate();

  // Antes del fix, acá llegaba 105 y el test pasaba a rojo sólo si alguien
  // se acordaba de cambiar el estado DESPUÉS de abrir la vista.
  expect(reportService.generate).toHaveBeenCalledWith(
    jasmine.objectContaining({ value: 250 })
  );
});
```

Ese `detectChanges()` del medio es el test entero. Sin él —abriendo la vista con
el estado ya actualizado— el test pasa con el bug puesto y no prueba nada.

**Prevención**

La regla, que vale mucho más allá de los PDF: **una copia local de un dato
compartido es un dato que va a envejecer, y nadie va a poder verlo envejecer.**
Si un componente guarda algo en una propiedad, la pregunta obligatoria en la
revisión es *"¿qué pasa si esto cambia mientras la pantalla está abierta?"*. La
respuesta legítima puede ser "nada, y es a propósito" — pero entonces se escribe
en un comentario, con el porqué.

**Por qué llegó a producción**

Por una intención razonable mal colocada. El `reportSnapshot` existe para que el
`ReportService` no dependa del store —una separación limpia, defendible, y de la
que el propio código está orgulloso: *"a partir de acá el ReportService no
necesita el store para nada"*—. El problema no es la foto: es **cuándo** se toma.
Tomarla al abrir la pantalla parecía equivalente a tomarla al generar, porque en
la cabeza de quien lo escribió esas dos cosas ocurrían con un segundo de
diferencia. En la vida real pasan cuarenta minutos, y en medio alguien corrige un
valor.

**Si tu causa fue distinta a esta**

- Si dijiste **"el store tiene el dato viejo"**, el panel State lo tumba en diez
  segundos: tiene el nuevo, y la pantalla lo está pintando.
- Si dijiste **"hay que recargar antes de generar"**, es un procedimiento, no un
  fix: le pasa el problema al usuario y depende de que se acuerde. Funciona hasta
  el día que no.
- Si el PDF además **te salió con los acentos rotos**, no es este incidente:
  es el **15**, y no comparte ni una línea de causa.
- Si tu fix fue **añadir `take(1)` a la suscripción del `ngOnInit`**, para y
  piénsalo otra vez: eso hace explícito el congelado en vez de quitarlo. El
  código pasa a ser honesto —ya no finge estar escuchando— y el bug del ticket
  sigue exactamente igual. Es una mejora de legibilidad disfrazada de fix, y de
  las más difíciles de detectar en una revisión.

</details>

---

## Incidente 15 — Los acentos del informe en francés salen como símbolos raros

> **Fase:** 9 · **Categoría:** i18n · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 40-60 min · **Ruta forense:** [`forense-fase-09.md`](./forense-fase-09.md), paso 5

### 🎫 El ticket

> *"Los informes en francés salen con símbolos raros donde van los acentos, pero
> sólo arriba: el título y la cabecera. El resto del documento se ve bien. En
> pantalla todo está perfecto, es sólo el PDF. Y en español no pasa."*

**Reportado por:** coordinadora del laboratorio
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducir, localizar la línea, y contestar las dos preguntas que el ticket
plantea sin querer: **¿por qué sólo arriba?** y **¿por qué sólo en francés?** La
segunda tiene truco y es la más importante de las dos.

### 🔧 Preparación

Rama de git. Alguien reordenó el servicio de informes la semana pasada "para que
se leyera mejor".

```bash
git checkout -b incidente/15 fase-09-entrega-pdf
```

Pon la aplicación en francés, abre un informe y bájalo. **Ábrelo con los ojos**:
este bug no lo detecta ningún test que compare cadenas.

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

No busques dos bugs. Un PDF donde **una parte** sale bien y **otra** mal casi
nunca son dos problemas: es una sola llamada que quedó en el lugar equivocado del
orden.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

En jsPDF, el documento es un lápiz con estado. Todo lo que configura el lápiz
—la fuente, el tamaño, el color— afecta **sólo a lo que se dibuja después**. Con
eso en la mano, abre el servicio y mira el orden de las llamadas.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿En qué línea se registra la fuente con acentos, y en qué línea está el primer
`doc.text(...)`?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

`src/app/reports/report.service.ts`: el registro de la fuente quedó **después**
del primer `doc.text(...)`.

```typescript
// Lo que trae la rama
var doc = new (jsPDF as any)();
var t = this.translate;

doc.setFontSize(16);
doc.text(t.instant('report.title'), 20, 20);   // ← dibuja con Helvetica
registerLatinFont(doc);                        // ← llega tarde
doc.text(t.instant('report.validatedBy') + ': ' + snapshot.validatedBy, 20, 40);
```

En jsPDF no existe "aplicar al documento": hay un lápiz con estado que va
cambiando mientras dibujas. El encabezado se dibujó cuando la fuente embebida
todavía no estaba registrada, así que salió con una fuente estándar del PDF — y
esas **no se direccionan por Unicode**: se direccionan por una tabla de un byte
por carácter. jsPDF 1.x escribe la cadena sin traducir a esa tabla, y todo lo que
esté por encima del ASCII de siete bits queda a merced de cómo interprete el
lector cada byte. Un `é` sale como dos símbolos, como uno equivocado o como nada.

Lo que ve el usuario, y que es el árbol de descarte hecho evidencia:

```
Résultat        ← con símbolos raros: se dibujó antes del registro
Référence       ← bien: se dibujó después
```

**Y ahora la pregunta buena: ¿por qué sólo en francés?**

No es sólo en francés. **El español rompe igual** — `Órdenes`, `Número`, `día`
están todos por encima del ASCII. Lo que pasa es que la densidad de diacríticos es
distinta: casi todas las etiquetas francesas del informe llevan uno (`Résultat`,
`Référence`, `Validé par`), mientras que en español hay pantallas enteras sin
ninguno. Y hay una segunda razón, menos técnica y más incómoda: **el español
tolera peor la queja**. Alguien ve `Ordenes` sin tilde y lo reporta como cosmética,
no como bug de codificación.

> 🧭 Si un informe en español te sale limpio, **es suerte del vocabulario**, no que
> el problema no esté. Ésa es la frase que hay que llevar a la reunión, porque de
> ella depende que el arreglo se priorice o se quede en "es sólo el francés".

**Parche mínimo**

```typescript
// El registro de la fuente va ANTES del primer text(). Siempre.
var doc = new (jsPDF as any)();
registerLatinFont(doc);

var t = this.translate;
doc.setFontSize(16);
doc.text(t.instant('report.title'), 20, 20);
```

**La refactorización correcta** (que en Track A 💸 no se paga)

Que el orden no dependa de que alguien se acuerde: una función `createDocument()`
que devuelva el documento **ya** con la fuente registrada y el lápiz puesto, y que
sea el único sitio del proyecto donde se llama a `new jsPDF(...)`. Un orden
correcto que depende de la disciplina de quien edita el archivo es un bug con
fecha, no una solución.

> ⚠️ Y las salidas que hay que descartar explícitamente, porque son las que
> aparecen al buscar el error en internet: reemplazar los acentos, pasar la cadena
> por `unescape(encodeURIComponent(...))` o normalizar a la forma descompuesta.
> Las tres cambian el síntoma en algunos lectores de PDF y lo empeoran en otros.
> **La única solución estable es embeber una fuente con esos glifos**, que es lo
> que este proyecto ya hace — sólo que lo hacía tarde.

**Prueba de regresión**

Y acá está lo incómodo: **no hay test que compare cadenas que cace esto.** El
texto que le pasaste a `doc.text()` es perfecto; lo que está mal es el dibujo. Lo
que sí se puede blindar es el **orden**, que es la causa:

```typescript
// src/app/reports/report.service.spec.ts
it('registra la fuente antes de dibujar el primer texto', function () {
  var calls: string[] = [];
  var docSpy = {
    addFileToVFS: function () { calls.push('registerFont'); },
    addFont: function () { calls.push('registerFont'); },
    setFont: function () { calls.push('setFont'); },
    setFontSize: function () { calls.push('setFontSize'); },
    text: function () { calls.push('text'); },
    save: function () { calls.push('save'); }
  };
  spyOn(service as any, 'createDocument').and.returnValue(docSpy);

  service.generate(snapshotDeEjemplo);

  // La aserción es sobre el ORDEN, no sobre el contenido: el primer text()
  // tiene que venir después del registro de la fuente.
  expect(calls.indexOf('registerFont')).toBeLessThan(calls.indexOf('text'));
});
```

Y la otra mitad de la regresión no es un test: es la **Prueba de fuego** de la
Fase 9, que pide abrir el PDF y mirarlo. Hay bugs que sólo se ven con los ojos, y
pretender lo contrario es cómo este llegó a producción.

**Prevención**

Además del test de orden, una línea en el servicio que diga por qué el registro va
primero. Es la clase de restricción que se rompe sola en cuanto alguien "ordena"
el archivo: el registro de una fuente parece código de preparación que da igual
dónde esté, y no lo es.

**Por qué llegó a producción**

Porque el cambio que lo rompió **mejoró la legibilidad del archivo**. Mover las
llamadas de configuración hacia abajo, agrupadas, es lo que cualquiera haría en
una revisión de código — y en un API con estado implícito como el de jsPDF, mover
una línea de sitio cambia el resultado sin cambiar ni un carácter del contenido.
El diff se lee inocente: no hay ninguna cadena modificada, ningún dato distinto,
sólo dos líneas que cambiaron de lugar.

Y sobrevivió porque los informes se revisan en español, donde el vocabulario del
encabezado (`Informe`, `Paciente`, `Resultado`) no lleva ni un acento.

**Si tu causa fue distinta a esta**

- Si dijiste **"falta la fuente en el bundle"**, es la causa del caso vecino y se
  distingue en un vistazo: cuando el `.ttf` no viaja, se rompen **todos** los
  acentos, no sólo los de arriba. El árbol de tres preguntas está en el
  [**Apéndice A08 §4**](./a08-pdf-cliente.md).
- Si dijiste **"es la codificación del archivo de traducciones"**, compruébalo en
  la pantalla: si el `fr.json` estuviera mal, los acentos se verían rotos también
  en la interfaz. El ticket dice que no.
- Si sólo se te rompió **la negrita**, es la tercera rama del mismo árbol: la
  variante `bold` no se registró y cayó a Helvetica.
- Si además el informe **sale entero en rojo a partir de un valor crítico**, has
  encontrado el otro bug de estado del lápiz de esta familia: `setTextColor` no se
  revierte solo. Está en [**A08 §2**](./a08-pdf-cliente.md) y es un incidente que
  este cuaderno no tiene — buen candidato para el **22**.

</details>

---

## Incidente 16 — El dashboard se arrastra al final del turno

> **Fase:** 10 · **Categoría:** Performance · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 60-90 min · **Ruta forense:** [`forense-fase-10.md`](./forense-fase-10.md)

### 🎫 El ticket

> *"El dashboard se pone lentísimo al final del turno. Por la mañana va bien. Si
> cierro el navegador y lo vuelvo a abrir, funciona otra vez un rato. El portátil
> se calienta y el ventilador no para."*

**Reportado por:** coordinador de turno
**Ambiente:** PROD

### 🎯 Qué se te pide

**Cuantificar** antes de arreglar. El entregable es un número —cuántos canales se
acumulan por cada visita— y la identificación de cuál de los tres sospechosos de
"va lento" es éste. Los tres tienen fixes distintos y **no son intercambiables**:
elegir el equivocado deja el bug intacto y añade complejidad.

### 🔧 Preparación

Ninguna rama: la deuda está en el código desde que escribiste la fase. El
componente se suscribe y no se desuscribe, tal como lo hace LabCore.

```bash
npm run mock
ng serve
```

Lo único que hace falta es **usar la aplicación como el coordinador**: entrar y
salir del dashboard varias veces sin recargar nunca.

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

La frase *"cerrar y reabrir lo cura"* es el dato más valioso del ticket. Descarta
el servidor, los datos y la red de un golpe —ninguno se arregla cerrando una
pestaña— y apunta a algo que **se acumula en la memoria del navegador**.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

No abras el panel Memory. Pon un `console.count` en dos sitios —dentro del cuerpo
del selector del KPI y en el `ngOnInit` del dashboard—, entra y sal cinco veces, y
después provoca un cambio en otro slice **estando fuera del dashboard**. Mira qué
contador se mueve.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si el contador del KPI sube cuando el dashboard **no está en pantalla**, ¿quién
está ejecutando ese código?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

`src/app/dashboard/dashboard.component.ts`: cuatro `.subscribe()` en `ngOnInit` y
ningún `ngOnDestroy`. Cada visita al dashboard deja cuatro canales abiertos que
siguen ejecutándose sobre una instancia que ya no está en pantalla.

La evidencia barata, que resuelve el caso en dos minutos:

```
dashboard ngOnInit: 1
dashboard ngOnInit: 2
dashboard ngOnInit: 3
dashboard ngOnInit: 4
dashboard ngOnInit: 5
KPI orders: 5          ← una por entrada… y sigue subiendo con el dashboard cerrado
KPI orders: 6
KPI orders: 7
```

**Cinco entradas, cuatro canales cada una, veinte callbacks ejecutándose sobre
instancias muertas.** Y cada uno recalcula sus KPI, arma los datos de su gráfico y
los guarda en propiedades de un componente que nadie va a volver a pintar. El
trabajo es real; el resultado no lo mira nadie.

La prueba dura, para el post-mortem, con el panel Memory —que es el paso caro y
va **al final**, no al principio—:

```
Constructor              # New   # Deleted   # Delta
DashboardComponent          5          0         +5
Subscriber                 20          0        +20
```

Cinco componentes retenidos después de haber salido cinco veces. No se liberan
porque el store los referencia a través de sus suscriptores.

> 🧭 **Por qué `console.count` va antes que el heap snapshot.** Un snapshot cuesta
> minutos, produce un árbol que hay que saber leer y contesta *"cuánta memoria hay
> retenida"*. `console.count` cuesta una línea y contesta *"cuántas veces se está
> ejecutando esto"*, que es la pregunta que de verdad tenías. La herramienta más
> impresionante es casi siempre la última que hace falta.

**El sospechoso correcto, de tres.** "Va lento" en este stack es una de tres cosas:

| Firma | Qué se acumula | Cómo se ve |
|---|---|---|
| Recomputación | nada; se recalcula de más | lento desde el primer minuto, siempre igual |
| Re-render | nada; se redibuja de más | parpadeo al escribir en otra parte |
| **Suscripción huérfana** | canales abiertos | **empeora con el uso**, se cura cerrando la pestaña |

El ticket describe la tercera. Meter `OnPush` para arreglar un leak, o cerrar
suscripciones para arreglar un re-render, es el error de diagnóstico que esta fase
entrena a no cometer.

**Parche mínimo**

```typescript
// dashboard.component.ts
private destroy$ = new Subject<void>();

ngOnInit() {
  this.store.select(selectOrdersByStatusCount)
    .pipe(takeUntil(this.destroy$))
    .subscribe(function (this: DashboardComponent, counts) {
      this.ordersByStatus = counts;
    }.bind(this));
  // … los otros tres, igual
}

// Un componente que abre canales tiene que cerrarlos. No es opcional
// aunque el compilador no diga nada.
ngOnDestroy() {
  this.destroy$.next();
  this.destroy$.complete();
}
```

**La refactorización correcta** (que en Track A 💸 no se paga)

El `async` pipe: que la plantilla se suscriba y Angular gestione el ciclo de vida,
sin `ngOnDestroy` que alguien pueda olvidar. Es lo correcto y **toca la plantilla
entera** del dashboard, además de cambiar cómo se arman los datos de los gráficos.
Va con su ticket.

Y hay una deuda hermana que conviene nombrar en el mismo post-mortem: **este
componente no es el único que se suscribe sin desuscribirse.** El patrón está en
todo el curso, desde la Fase 1, por fidelidad a LabCore. Acá muerde porque el
dashboard se visita muchas veces por turno; en una pantalla que se abre dos veces
al día, el mismo código no produce ningún síntoma. Un `grep -rn "\.subscribe(" src/`
te da el tamaño real del asunto, y es material de un ticket de proyecto, no de un
hotfix.

**Prueba de regresión**

```typescript
// src/app/dashboard/dashboard.component.spec.ts
it('deja de escuchar al store cuando el componente se destruye', function () {
  var store = TestBed.get(MockStore);
  var fixture = TestBed.createComponent(DashboardComponent);
  var component = fixture.componentInstance;
  fixture.detectChanges();                       // ngOnInit: se suscribe

  var received = 0;
  spyOnProperty(component, 'ordersByStatus', 'set').and.callFake(function () { received++; });

  store.setState(estadoConOrdenes(3));
  expect(received).toBe(1);

  fixture.destroy();                             // ngOnDestroy
  store.setState(estadoConOrdenes(7));

  // Antes del fix esto valía 2: el callback seguía corriendo sobre un
  // componente destruido. Es el leak, escrito como aserción.
  expect(received).toBe(1);
});
```

**Prevención**

El test de arriba, replicado en cada componente que se suscriba a mano. Y la regla
en la revisión de código, que es más barata que cualquier herramienta: **si ves un
`.subscribe(` en un componente, busca el `ngOnDestroy` antes de seguir leyendo.**
Si no está, no hace falta medir nada: ya sabes que hay un canal que no se cierra.
Medir sirve para saber si duele.

**Por qué llegó a producción**

Porque un leak no se ve nunca en desarrollo. Quien escribe el código entra al
dashboard, mira lo que cambió, y recarga — y recargar destruye todo. Hace falta un
turno de ocho horas, con la misma pestaña abierta y veinte visitas al dashboard,
para que veinte canales se vuelvan ochenta y el ventilador empiece a sonar. El
ciclo de vida del desarrollador es de segundos; el del usuario, de un turno
completo. Casi todos los bugs de acumulación viven en esa diferencia.

**Si tu causa fue distinta a esta**

- Si dijiste **"los gráficos se redibujan de más"**, es el segundo sospechoso y
  puede convivir con éste: si el `[data]` del gráfico sale de un **método** de la
  plantilla en vez de una propiedad, devuelve una referencia nueva en cada ciclo
  de detección y el gráfico parpadea. Compruébalo — pero eso no empeora con las
  horas, y el ticket dice que empeora.
- Si dijiste **"hay que poner `OnPush`"**, es la respuesta refleja a cualquier "va
  lento" y acá no arregla nada: los callbacks huérfanos no son ciclos de detección
  de cambios, son suscripciones vivas. Con `OnPush` puesto, el contador del KPI
  sigue subiendo con el dashboard cerrado.
- Si dijiste **"es el servidor, que va lento al final del turno"**, el ticket lo
  tumba solo: ningún servidor se arregla cerrando una pestaña.
- Si abriste **primero el heap snapshot** y llegaste igual al diagnóstico,
  perfecto — pero anota cuánto te costó. La diferencia entre veinte minutos y una
  tarde no está en el resultado: está en el orden.

</details>

---

## Incidente 17 — El log dice que yo validé ese resultado y yo no estaba ese día

> **Fase:** 11 · **Categoría:** Trazabilidad · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 60-90 min · **Ruta forense:** [`forense-fase-11.md`](./forense-fase-11.md), paso 4

### 🎫 El ticket

> *"Calidad me mandó la bitácora de la orden 4021 y dice que yo validé un
> resultado el sábado a las nueve de la noche. Yo no trabajo los sábados y ese día
> estaba fuera de la ciudad. Necesito que quede claro que no fui yo, porque esto
> va a un informe de auditoría."*

**Reportado por:** analista de resultados
**Ambiente:** PROD

### 🎯 Qué se te pide

Esto no es un bug de pantalla: es una acusación contra una persona, sostenida por
un registro del sistema. El entregable es una **declaración sobre qué prueba y qué
no prueba la bitácora de LabCore**, respaldada con evidencia. Y hay que
escribirla sabiendo que la va a leer alguien de Calidad.

No termina en fix.

### 🔧 Preparación

Un `db.json` alterno con la bitácora del caso: los asientos ya están escritos y lo
que hay que hacer es leerlos.

```bash
cp db.json db.json.mio
cp db.incidente-17.json db.json
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Antes de creerle al asiento o de desmentirlo, pregunta de dónde sale cada uno de
sus campos. Dos de ellos —quién y cuándo— no los escribe el servidor.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Busca en el código el sitio exacto donde se arma el asiento. Mira de qué función
sale el `actor` y de qué función sale el `timestamp`, y en qué máquina se ejecutan
esas dos funciones.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si el `actor` sale del token que hay en el navegador y el `timestamp` sale del
reloj de ese mismo navegador, ¿qué es exactamente lo que la bitácora está
registrando?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

La bitácora de LabCore **la escribe el navegador**, y por lo tanto registra *lo
que el cliente dice que pasó*, no lo que pasó. Es la deuda 💸 central de la
**Fase 11**, declarada en voz alta en tres comentarios del código:

```typescript
// audit.effects.ts
// 💸 El actor sale del token en el NAVEGADOR. Es "quien dice el cliente
//    que es", no quien el servidor verificó.
actor: this.authService.getCurrentUser(),

// 💸 timestamp del reloj del cliente. Arrastra la deuda de zona horaria
//    de la Fase 8.
timestamp: new Date().toISOString(),
```

De ahí salen **tres** afirmaciones que la bitácora no puede sostener, y las tres
hay que escribirlas:

1. **El `actor` no está verificado por nadie.** Sale de decodificar el JWT en el
   navegador, sin comprobar la firma —esa comprobación la haría el servidor, y el
   mock no la hace en las rutas de datos—. Cualquiera con la consola abierta puede
   despachar la acción con el token que quiera, y el asiento sale con ese nombre.
2. **El `timestamp` es el reloj del cliente.** No el del servidor. Un portátil con
   el reloj corrido, o en otra zona horaria, produce asientos fechados en otro
   momento — y en un ticket que empieza con *"el sábado"*, eso deja de ser un
   detalle. Compara el `timestamp` del asiento con el `validatedAt` del dato: si
   difieren en horas, hay dos relojes en juego.
3. **Y el asiento se escribe después de la mutación, en otra petición.** Si el
   `PATCH` sale bien y el `POST /auditLog` falla, la cosa cambió y no quedó
   registrada. La bitácora tiene un hueco y nada en el sistema lo señala.

La evidencia del caso concreto, que es lo que hay que poner en la declaración:

```bash
curl -s "http://localhost:3000/auditLog?entityId=9003&_sort=timestamp"
```

```json
[{ "actor": "analista1",
   "action": "[Results] Validate Result Success",
   "timestamp": "2019-09-07T21:04:11.002-05:00",
   "after": { "id": 9003, "status": "validated", "validatedBy": "analista1" } }]
```

```bash
curl -s "http://localhost:3000/results/9003" | grep validatedAt
# "validatedAt": "2019-09-07T21:04:10.887-05:00"
```

El dato y el asiento coinciden — **y coinciden porque los escribió la misma
máquina, con el mismo reloj y el mismo token.** Que dos campos rellenados por la
misma fuente digan lo mismo no confirma nada: es un solo testigo declarando dos
veces.

> 🧬 Lo que sí se puede afirmar con certeza: **alguien usó una sesión emitida a
> nombre de `analista1` a esa hora.** Lo que el sistema **no** puede afirmar: que
> esa persona estuviera delante del teclado. Y eso, dicho así, es exactamente lo
> que hay que escribir — porque es la verdad y porque protege a la analista.

**Parche mínimo**

**Ninguno**, y proponer uno sería el error. Cualquier cosa que se escriba en
Angular sigue siendo el cliente contándose la historia a sí mismo. Lo único que
cabe hoy es **documentar el alcance de la bitácora** donde se consulta: una nota
en la pantalla de trazabilidad diciendo que el actor y la hora son declarados por
el cliente y no verificados.

Una nota, no un fix. Pero es la diferencia entre un registro que se usa como
prueba y un registro que se usa como indicio, y esa diferencia le importa a una
persona.

**La refactorización correcta** (que en Track A 💸 no se paga)

Que el asiento lo escriba **el servidor**, en la misma transacción que la
mutación, con el actor sacado del token **verificado** y el timestamp del reloj
del servidor. Eso es un backend, y en el track base no lo tenemos.

El track 🔥 BE lo construye entero y es literalmente su fase `be04` —*"el audit log
que escribía el navegador"*—; su incidente `be-07` es el hermano de éste visto
desde el otro lado del cable: *"el informe firmado a las 14:47 por alguien que
salió a las 14:00"*. Y ahí aparece la vuelta de tuerca que desde acá no se ve: aun
escribiéndolo el servidor, sin una transacción la mutación y su asiento pueden
separarse — que es la fase `be05`.

**Prueba de regresión**

Lo que se puede blindar desde el cliente no es la veracidad del asiento —eso es
imposible desde acá— sino que **el hueco se note**:

```typescript
// src/app/audit/store/audit.effects.spec.ts
it('deja rastro cuando el asiento no se pudo escribir', function (done) {
  spyOn(service, 'record').and.returnValue(throwError({ status: 500 }));
  actions$ = of(ResultsActions.validateResultSuccess({ result: { id: 9003 } as any }));

  effects.recordAudit$.subscribe(function (action) {
    // Antes: el error se tragaba en silencio y la mutación quedaba sin asiento.
    // Ahora al menos hay una acción que alguien puede ver y contar.
    expect(action.type).toBe(AuditActions.recordEntryFailure.type);
    done();
  });
});

it('nunca escribe un asiento sin actor', function () {
  spyOn(authService, 'getCurrentUser').and.returnValue(null);
  var entry = buildEntry(ResultsActions.validateResultSuccess({ result: { id: 9003 } as any }), null);
  // 'system' es explícito y auditable; undefined es un agujero silencioso.
  expect(entry.actor).toBe('system');
});
```

Ese segundo test protege de la variante fea del mismo bug: un `actor: undefined`
que en la pantalla de trazabilidad se ve como una celda vacía y que nadie
interpreta como "no sabemos quién fue".

**Prevención**

El detector: un guion que compare, para cada mutación de los datos, que exista su
asiento. No arregla nada; convierte un hueco invisible en una lista. Y la regla
que se lleva al trabajo real: **un registro de auditoría escrito por la parte
auditada no es auditoría.** Sirve para reconstruir lo que pasó cuando todo el
mundo actúa de buena fe, y no sirve para nada en el único escenario para el que se
construyó una auditoría.

**Por qué llegó a producción**

Porque en 2019 el equipo de frontend necesitaba una bitácora, el backend no la
ofrecía, y escribirla desde el cliente **funcionaba**. La decisión fue correcta
para el problema que se tenía —tener algo era mejor que no tener nada— y nadie
escribió sus límites en ninguna parte. Siete años después, ese registro se cita en
un informe de auditoría como si fuera prueba, y la distancia entre lo que es y lo
que se cree que es recae sobre una analista que tiene que demostrar dónde estaba
un sábado.

El post-mortem de este incidente no se cierra en el equipo de desarrollo. Se sube.

**Si tu causa fue distinta a esta**

- Si dijiste **"alguien usó la sesión de la analista"**, es una de las
  posibilidades y no se puede confirmar ni descartar con lo que hay. Escríbela
  como lo que es —una hipótesis compatible con la evidencia— y no como conclusión.
- Si dijiste **"el reloj del portátil estaba mal"**, es comprobable en parte:
  compara el `timestamp` del asiento con el `validatedAt` del dato y con otros
  asientos de la misma sesión. Si toda la sesión está corrida en bloque, tienes un
  reloj; si sólo lo está ese asiento, no.
- Si encontraste asientos con **`actor: "system"`**, no es un error: es lo que
  `buildEntry` escribe cuando `getCurrentUser()` devuelve `null`, o sea cuando la
  mutación se disparó sin sesión activa. Eso es el incidente **05** visto desde la
  bitácora, dos fases más tarde.
- Si tu conclusión fue **"la bitácora está bien, la analista se equivoca"**, vuelve
  a leer de dónde salen los dos campos. Es exactamente el error que este incidente
  entrena a no cometer, y el único del cuaderno que tiene nombre y apellido del
  otro lado.

</details>

---

## Incidente 18 — El test pasa en mi máquina y falla en la de al lado

> **Fase:** 12 · **Categoría:** Testing · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 90-120 min · **Ruta forense:** [`forense-fase-12.md`](./forense-fase-12.md)

### 🎫 El ticket

> *"La suite me pasa entera en local y en la máquina de Julián falla el mismo
> test, `selectFilteredPatients filtra por texto sobre los activos`. Él borró
> `node_modules` y le sigue fallando. A mí me pasó una vez y no volvió. Llevamos
> dos días sin poder mergear."*

**Reportado por:** un dev del equipo
**Ambiente:** desarrollo, dos máquinas

### 🎯 Qué se te pide

**Hacer que el fallo sea determinista**, que es el 90% del trabajo. Un test que
falla "a veces" no se arregla: se convierte primero en un test que falla
**siempre**, y sólo entonces se arregla. Después, identificar cuál de las cuatro
fuentes de no-determinismo es —orden, reloj, azar o DOM sucio— y eliminarla.

Este es el incidente más difícil del cuaderno y el que más se parece al trabajo
real: el sospechoso es tu propio código de pruebas.

### 🔧 Preparación

Rama de git: la suite rota viene con ella.

```bash
git checkout -b incidente/18 fase-12-testing-coverage
npx ng test --watch=false
```

Puede que te pase a la primera. Puede que no. Esa es exactamente la dificultad.

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

No empieces por el test que falla: empieza por hacer que falle **siempre**. Karma
tiene una opción para fijar el orden de ejecución, y Jasmine tiene otra para
aleatorizarlo con una semilla concreta. Búscalas antes de leer una línea del spec.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Corre **sólo** el test que falla, aislado con `fit`. Si aislado pasa siempre,
el problema no está en él: está en algo que otro test dejó sucio antes. Busca qué
se comparte entre specs: una variable declarada fuera del `beforeEach`, un
`localStorage`, un espía global.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿Dónde está declarado el arreglo de pacientes que usan los tests de selectores?
¿Dentro del `beforeEach`, o fuera? Y si está fuera, ¿algún test lo modifica?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

`src/app/patients/store/patients.selectors.spec.ts`: el estado de prueba está
declarado **fuera** del `beforeEach`, así que las once specs del archivo comparten
el mismo objeto — y una de ellas lo modifica.

```typescript
// Lo que trae la rama: un solo estado, compartido por todo el describe.
var state: PatientsState = {
  items: [
    { id: 1, fullName: 'Ana Ruiz', active: true } as any,
    { id: 2, fullName: 'Beto Diaz', active: false } as any,
    { id: 3, fullName: 'Cielo Mora' } as any
  ],
  …
};

it('ordena la lista por nombre', function () {
  // .sort() ordena EN SU SITIO: acaba de reordenar el arreglo para
  // todos los tests que corran después.
  var ordered = state.items.sort(byFullName);
  expect(ordered[0].fullName).toBe('Ana Ruiz');
});
```

Y el test que falla no es el culpable: es la **víctima**. Espera encontrar a Ana
en la primera posición y la encuentra o no según qué haya corrido antes.

**Por qué depende de la máquina.** Por dos razones que se suman:

1. **Jasmine puede aleatorizar el orden de los tests.** Si `random: true` está
   activo en `karma.conf.js` —y en muchas plantillas lo está—, cada corrida usa
   una semilla distinta. El orden cambia entre máquinas, entre corridas y entre
   ramas.
2. **Un `describe` que no comparte nada es inmune al orden.** Este lo comparte, así
   que el resultado depende de la semilla. No falla "por la máquina": falla por el
   número que Jasmine imprimió en la primera línea del reporte y que nadie lee.

```
Randomized with seed 41287
Chrome 8x.x.x: Executed 48 of 48 (1 FAILED)
```

**Ese número es la reproducción.** Con él, el fallo deja de ser intermitente:

En el CLI 8 la semilla no se pasa por línea de comandos: se fija en la
configuración de Karma, que es donde vive el cliente de Jasmine.

```javascript
// karma.conf.js — temporal, sólo mientras investigas.
client: {
  clearContext: false,
  // Misma semilla = mismo orden = mismo fallo, siempre.
  jasmine: { random: true, seed: '41287' }
}
```

```bash
npx ng test --watch=false
```

> 🧭 **Convertir un "a veces" en un "siempre" es la mitad del trabajo**, y es la
> misma lección del incidente **08** aplicada a la suite: lo que parece azar suele
> ser un parámetro que alguien está imprimiendo y nadie está leyendo.

**Las cuatro fuentes**, para reconocer la próxima:

| Fuente | Firma | Cómo se caza |
|---|---|---|
| **Orden** | pasa aislado, falla en suite | `fit` para aislar; la semilla para reproducir |
| **Reloj** | falla a ciertas horas o cerca de medianoche | busca `new Date()` sin inyectar |
| **Azar** | falla ~1 de cada N corridas, sin patrón | busca `Math.random` en el spec o en el código |
| **DOM sucio** | falla el segundo test de componente | falta `fixture.destroy()`, o el body conserva nodos |

**Parche mínimo**

```typescript
// El estado se construye de cero en CADA test. Es la única forma de que un
// spec no pueda contaminar al siguiente.
var state: PatientsState;

beforeEach(function () {
  state = {
    items: [
      { id: 1, fullName: 'Ana Ruiz', active: true } as any,
      { id: 2, fullName: 'Beto Diaz', active: false } as any,
      { id: 3, fullName: 'Cielo Mora' } as any
    ],
    …
  };
});
```

Y en el test que ordenaba, no mutar el original:

```typescript
// slice() primero: el sort de JavaScript ordena en su sitio.
var ordered = state.items.slice().sort(byFullName);
```

**La refactorización correcta** (que en Track A 💸 no se paga)

Una factoría de datos de prueba —`buildPatientsState(overrides)`— que devuelva un
objeto nuevo cada vez y que use el resto de la suite. Quita la tentación de
compartir y de paso hace los specs más cortos. Es media tarde de trabajo sobre
cuarenta y ocho tests, con su ticket.

> ⚠️ Y la salida que **no** hay que tomar, porque es la que aparece primero en
> cualquier búsqueda: poner `random: false` en `karma.conf.js`. Eso no arregla el
> test: **esconde la única herramienta que te avisó de que estaba mal.** Un orden
> fijo hace que la suite pase siempre… hasta el día que alguien inserta un test
> nuevo en el medio y el orden cambia solo. La aleatorización no es el problema;
> es el detector.

**Prueba de regresión**

La regresión de un test es… otro test, y suena raro hasta que lo ves:

```typescript
// src/app/patients/store/patients.selectors.spec.ts
it('el estado de prueba llega intacto a cada spec', function () {
  // Si un test anterior mutó el arreglo compartido, este orden ya no es
  // el de la declaración y la aserción cae. Es el canario de la suite.
  expect(state.items.map(function (p) { return p.id; })).toEqual([1, 2, 3]);
});
```

Y la de verdad, la que se corre en CI y que no es un spec:

```bash
# La suite tiene que pasar con CUALQUIER orden. Tres semillas distintas,
# y si una falla, hay estado compartido en alguna parte. Se corre con tres
# copias de la config, que es lo que el CLI 8 permite sin inventar nada.
for seed in 1 41287 99999; do
  sed "s/SEED_PLACEHOLDER/$seed/" karma.seed.conf.js > karma.run.conf.js
  npx ng test --watch=false --karma-config=karma.run.conf.js \
    || echo "FALLA con semilla $seed"
done
```

**Prevención**

Las tres semillas en CI, y la regla en la revisión de código: **todo lo que un
test necesita se construye dentro del `beforeEach`.** Una variable declarada en el
`describe` y asignada una sola vez es estado compartido, aunque parezca una
constante — y en JavaScript, un arreglo declarado con `var` y ordenado con
`.sort()` es exactamente eso.

**Por qué llegó a producción**

Porque compartir el estado de prueba **es lo cómodo y parece lo limpio**: evita
repetir veinte líneas en cada test y hace el archivo más corto. Nadie escribió un
bug; alguien evitó una repetición. Y el test que ordenaba se escribió después,
meses más tarde, por otra persona que no tenía forma de saber que ese arreglo lo
leían otros diez specs.

El coste real no fue el test: fueron **dos días sin poder mergear** y dos
desarrolladores convencidos de que el problema era la máquina del otro. Esa es la
factura de un test no determinista, y es la razón por la que un test que falla a
veces es peor que no tener test: envenena la confianza en toda la suite.

**Si tu causa fue distinta a esta**

- Si dijiste **"es la versión de Node o el navegador"**, es la primera hipótesis
  de todo el mundo y se descarta fijando la semilla: si con la misma semilla falla
  en las dos máquinas, el ambiente no tiene nada que ver.
- Si dijiste **"hay que poner `random: false`"**, funciona y es tapar el
  detector. Anótalo igual: es el fix que más veces se aplica de verdad en los
  equipos, y saber por qué es malo vale más que saber el bueno.
- Si tu test fallaba con **`ExpressionChangedAfterItHasBeenCheckedError`**, no es
  este incidente: es un componente que cambia un valor durante la detección de
  cambios, y en producción es un síntoma real, no ruido de test.
- Si encontraste además un test que **pasa sin probar nada** —un `expect` dentro
  de un `subscribe` que nunca emitió—, has encontrado el otro bug de la familia y
  es el recorrido entero de [`forense-fase-12.md`](./forense-fase-12.md). Son
  primos: uno falla sin motivo y el otro aprueba sin mérito, y los dos destruyen la
  confianza en la suite por caminos opuestos.

</details>

---

## Incidente 19 — Desplegamos a PROD y le sigue hablando a UAT

> **Fase:** 13 · **Categoría:** Despliegue · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 90-120 min · **Ruta forense:** [`forense-fase-13.md`](./forense-fase-13.md)

### 🎫 El ticket

> *"Desplegamos ayer. En UAT todo bien. En PROD la pantalla de pacientes queda
> cargando y después dice que no se pudo. El backend de PROD está arriba, lo
> acabamos de comprobar. Son las siete de la tarde y mañana a las seis entra el
> turno de la mañana."*

**Reportado por:** el líder del despliegue
**Ambiente:** PROD
**Presión:** alta, y eso es parte del ejercicio.

### 🎯 Qué se te pide

Dos entregables, y en este orden: **primero contener, después diagnosticar.** A
las siete de la tarde de un despliegue roto, lo que se evalúa es que sepas cuál de
las dos cosas va primero y por qué — y que el diagnóstico llegue igual, con todas
las letras, para el post-mortem del día siguiente.

### 🔧 Preparación

Ninguna rama hace falta: el código es correcto. Lo que hay que reproducir es
**el arranque**, y para eso basta con levantar la imagen con las variables
equivocadas — que es exactamente lo que pasó.

```bash
docker build -t lab-frontend:inc19 .
# El comando con el que "se desplegó a PROD" ese día. Cópialo tal cual,
# sin leerlo con lupa: leerlo con lupa es el final de la investigación.
docker run -d --name lab-frontend-prod -p 8080:80 \
  -e API_URL=http://uat.interno:3000 \
  -e ENVIRONMENT_NAME=uat \
  -e APP_TIME_ZONE=America/Bogota \
  -e FEATURE_DELIVERY_PDF=true \
  lab-frontend:inc19
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

No abras la consola buscando un error: no lo hay. La aplicación está haciendo lo
correcto con los datos equivocados. La primera petición que hace antes de mostrar
nada te dice con quién cree que está hablando.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

En Network, busca `config.json` y abre su pestaña **Response**. Ese archivo no
está en el repositorio: lo escribe el contenedor al arrancar. Léelo entero, no
sólo la URL.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si el `config.json` trae la configuración del otro ambiente, la pregunta deja de
ser sobre la aplicación y pasa a ser sobre el arranque. ¿Qué variables de entorno
recibió ese contenedor, y qué dijo su entrypoint en la primera línea del log?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

El contenedor de PROD se levantó con las variables de entorno de UAT. La imagen es
la correcta, el código es el correcto, el backend de PROD está arriba — y nadie le
está hablando.

La cadena, en tres comandos y sin ambigüedad:

```json
// Network -> config.json -> Response
{"apiUrl":"http://uat.interno:3000","environmentName":"uat",
 "timeZone":"America/Bogota","features":{"deliveryPdfEnabled":true}}
```

```bash
docker logs lab-frontend-prod | head -3
# [entrypoint] config generada para ambiente: uat -> http://uat.interno:3000
```

```bash
docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' lab-frontend-prod
# API_URL=http://uat.interno:3000
# ENVIRONMENT_NAME=uat
```

El `environmentName` lo confirma sin margen de interpretación. **No es un bug de
la aplicación, ni de la imagen, ni del build: es el comando de arranque.**

Y esa primera línea del log existe exactamente para este momento. Cuando algo
falla en un despliegue, la primera pregunta siempre es *"¿a qué ambiente arrancó
esto?"*, y tenerla escrita ahorra media hora — media hora que a las siete de la
tarde no es media hora, es el turno de la mañana.

> 🧭 **Por qué "¿qué cambió en el código?" no tiene respuesta útil acá.** No cambió
> nada: la imagen de UAT y la de PROD son la misma. Ésa es la tesis de la Fase 13
> —una imagen, dos configuraciones— y su consecuencia directa es que el diff
> relevante no está en git. Está entre dos comandos de arranque, que no se
> versionan en el mismo sitio y que casi nadie revisa.

**Parche mínimo**

Y acá el orden importa más que el contenido. **Primero se contiene**, porque hay
usuarios:

```bash
# Relevantar el contenedor con las variables correctas. Nada que compilar,
# nada que desplegar: es exactamente la misma imagen.
docker rm -f lab-frontend-prod
docker run -d --name lab-frontend-prod -p 8080:80 \
  -e API_URL=http://prod.interno:3000 \
  -e ENVIRONMENT_NAME=prod \
  -e APP_TIME_ZONE=America/Bogota \
  -e FEATURE_DELIVERY_PDF=true \
  lab-frontend:inc19

docker logs lab-frontend-prod | head -1
# [entrypoint] config generada para ambiente: prod -> http://prod.interno:3000
```

Un minuto, y con la comprobación por donde se comprueba: **la primera línea del
log y el `config.json` en Network**, no "parece que ya funciona".

**La refactorización correcta** (que en Track A 💸 no se paga)

Que un arranque con el ambiente equivocado **no sea posible en silencio**. Tres
opciones, de la más barata a la más cara:

1. **Que el entrypoint falle si `ENVIRONMENT_NAME` no coincide con el esperado
   para ese host.** Diez líneas de shell. Convierte un despliegue silenciosamente
   malo en un contenedor que no arranca, que es infinitamente mejor.
2. **Que el nombre del ambiente sea visible en la interfaz** —una franja de color
   en UAT—. El día que alguien vea la franja amarilla en producción, el incidente
   dura diez segundos.
3. **Que los comandos de arranque vivan en el repositorio**, versionados y
   revisados como código. Es lo correcto y es un proyecto, no un hotfix.

**Prueba de regresión**

No hay spec de Karma que cace esto: el bug vive fuera de la aplicación. La
regresión es un guion de humo, y es el mismo movimiento que la Fase 13 ya hace con
el contrato:

```bash
#!/usr/bin/env bash
# smoke-deploy.sh — se corre DESPUÉS de cada despliegue, contra la URL real.
set -eu
BASE="$1"          # http://prod.interno:8080
EXPECTED="$2"      # prod

CONFIG=$(curl -fsS "$BASE/assets/config.json")
ACTUAL=$(echo "$CONFIG" | sed -n 's/.*"environmentName":"\([^"]*\)".*/\1/p')

if [ "$ACTUAL" != "$EXPECTED" ]; then
  echo "FALLA: $BASE arrancó como '$ACTUAL', se esperaba '$EXPECTED'"
  echo "$CONFIG"
  exit 1
fi

# Y que no quede ningún marcador sin expandir, que es el otro fallo de la familia.
case "$CONFIG" in
  *'${'*) echo "FALLA: hay variables sin expandir en config.json"; exit 1 ;;
esac

echo "ok: $BASE = $EXPECTED"
```

Treinta segundos de guion que convierten este incidente en imposible. Es el
entregable que de verdad hay que defender en el post-mortem.

**Prevención**

El guion de arriba en el pipeline, después del despliegue y antes de avisar de que
terminó. Y la regla que se lleva al trabajo real: **lo primero que hace un sistema
desplegado debería ser decir en voz alta quién cree que es.** El entrypoint de
esta fase lo hace en una línea, y esa línea es la diferencia entre un incidente de
un minuto y uno de dos horas.

**Por qué llegó a producción**

Porque el comando de arranque no es código para casi nadie. Vive en un
`docker-compose.yml` de un servidor, o en un panel, o en la memoria de quien
despliega; no pasa por revisión, no tiene pruebas, y se copia de un ambiente a
otro cambiando a mano lo que hay que cambiar — que es exactamente el momento en
que se olvida una línea. El despliegue "salió bien": el contenedor arrancó, nginx
respondió, la pantalla de login se veía. Todo lo que se comprobó, se comprobó
correctamente. Nadie comprobó lo único que importaba.

Y hay un agravante que conviene anotar: **en UAT todo estaba bien**, así que
durante media hora la hipótesis del equipo fue que el problema era de PROD —red,
firewall, el backend—. Cuando dos ambientes corren el mismo artefacto y uno falla,
la tentación es buscar la diferencia en la infraestructura. La diferencia estaba
en una variable.

**Si tu causa fue distinta a esta**

- Si el `config.json` te salió **con la URL correcta** y la aplicación igual hablaba
  a otro sitio, has encontrado el otro bug de la fase y es peor: hay servicios que
  siguen leyendo de `environment` en vez del `AppConfigService`. `grep -rn
  "environment.apiUrl" src/` te da la lista, y el rezagado que más se escapa es
  `environment.timeZone`.
- Si te salió un **`${FEATURE_DELIVERY_PDF}` literal** dentro del JSON, es la
  variante de `envsubst`: sustituye sólo las variables que se le listan, y alguien
  añadió una clave a la plantilla sin añadirla a la lista. El `JSON.parse` revienta
  con un mensaje que no menciona ni al entrypoint ni a la plantilla.
- Si el `config.json` te dio **404**, el entrypoint murió antes del `exec nginx`:
  corre con `set -e` y cualquier fallo previo lo mata. `docker logs --tail 20` te
  dice qué dijo antes de morir.
- Si los **hashes de los bundles** de UAT y PROD no coinciden, para todo lo demás:
  no estás comparando dos configuraciones del mismo artefacto, estás comparando
  dos builds. La investigación se muda al pipeline.
- Si arreglaste **desplegando otra vez desde cero** y funcionó: funcionó, y no
  sabes por qué. Anótalo tal cual. Un despliegue que arregla un problema sin
  diagnóstico es un problema que vuelve, y la próxima vez será a las siete de la
  tarde de un viernes.

</details>

---

## Incidente 20 — Si recargo la página en cualquier pantalla, me da 404

> **Fase:** 13 · **Categoría:** Despliegue · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45-60 min · **Ruta forense:** [`forense-fase-13.md`](./forense-fase-13.md)

### 🎫 El ticket

> *"Entro a la aplicación, navego a las órdenes de un paciente y funciona todo. Si
> le doy a recargar estando ahí, se cae: sale una pantalla blanca de nginx que
> dice 404. Si vuelvo a entrar por la dirección principal, funciona otra vez.
> Tengo esa pantalla en favoritos y ya no me sirve el enlace."*

**Reportado por:** analista de resultados
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducir, explicar **por qué funciona navegando y no recargando** —que es la
parte conceptual y la que de verdad se evalúa—, y aplicar el fix. Es de una línea,
y el reto no es encontrarla sino saber decir qué hace.

### 🔧 Preparación

Rama de git: hay que romper la configuración de nginx, que también es código.

```bash
git checkout -b incidente/20 fase-13-build-despliegue
docker build -t lab-frontend:inc20 .
docker run -p 8080:80 -e API_URL=http://localhost:3000 lab-frontend:inc20
```

Abre `http://localhost:8080`, navega hasta una ruta profunda —`/patients/42/orders`—
y pulsa F5.

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Compara las dos situaciones en la pestaña Network: cuando navegas por el menú y
cuando recargas. Cuenta **cuántas peticiones le llegan al servidor** en cada caso.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

El 404 no lo devuelve Angular: lo devuelve nginx, antes de que Angular exista.
Mira qué archivo le está pidiendo el navegador y pregúntate si ese archivo existe
en el disco del contenedor.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

`docker exec <contenedor> ls /usr/share/nginx/html`. ¿Hay algo que se llame
`orders`? ¿Y qué debería servir nginx cuando le piden algo que no está?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

`nginx.conf`: falta la línea `try_files`.

La explicación entera cabe en una frase, y hay que poder decirla sin leerla:
**una SPA tiene dos routers y sólo uno de ellos existe cuando recargas.**

- **Navegando por el menú**, el router de Angular vive en el navegador y cambia la
  URL sin pedirle nada al servidor. En Network no aparece **ninguna** petición de
  documento: sólo las de datos. Nginx ni se entera de que estás en `/orders`.
- **Recargando**, el navegador sí le pide `/patients/42/orders` a nginx. Y nginx
  hace lo único que sabe hacer: buscar en el disco un archivo con ese nombre. No
  existe —en el disco sólo hay `index.html`, los bundles y los assets— y devuelve
  un 404 perfectamente correcto.

```bash
docker exec lab-frontend ls /usr/share/nginx/html
# index.html  main.8a1f2c.js  polyfills.*.js  styles.*.css  assets/
# ← no hay ningún "patients", ningún "orders". Nunca los hubo.
```

```
Name                    Status  Type      Initiator
patients/42/orders      404     document  Other
```

`Type: document` es la firma: no es una petición de datos, es el navegador
pidiendo una página. Y `404` de nginx, no de la aplicación — la aplicación **no
llegó a arrancar**.

> 🧭 Por eso el enlace de favoritos tampoco funciona, y eso es lo que convierte un
> bug técnico en uno de negocio: cualquier URL compartida por correo, cualquier
> enlace guardado, cualquier recarga, entra por la puerta del servidor y no por la
> del router.

**Parche mínimo**

```nginx
location / {
  # Busca el archivo pedido; si no existe, busca el directorio; si tampoco,
  # sirve index.html. Angular arranca, el router lee la URL y monta la ruta.
  try_files $uri $uri/ /index.html;
}
```

Una línea, y hay que reconstruir la imagen para que entre —el `nginx.conf` viaja
dentro—. Comprueba por donde se comprueba: recarga en `/patients/42/orders` y
confirma que la aplicación se vuelve a montar **en esa pantalla**, no en el
inicio.

**La refactorización correcta** (que en Track A 💸 no se paga)

No hay ninguna: `try_files` **es** la solución correcta para una SPA servida por
nginx, no un rodeo. Es de los pocos casos del curso donde el fix del viernes a las
seis y el que harías con un mes de calma son exactamente la misma línea.

Lo que sí conviene mirar, porque es la otra mitad del asunto y **el proyecto ya
lo trae resuelto**, es hasta dónde llega ese comodín:

```nginx
# Los diccionarios de i18n NO caen en el comodín. Si pides un idioma que no
# existe, tiene que salir un 404 honesto y no un index.html disfrazado de
# JSON, que revienta el JSON.parse con un error que no menciona el idioma.
location /assets/i18n/ {
  try_files $uri =404;
}
```

Ese bloque está en el `nginx.conf` de la Fase 13 desde que lo escribiste, y ahora
sabes por qué: un `try_files` demasiado generoso convierte cualquier error de ruta
en una pantalla en blanco con un mensaje incomprensible, que es peor que un 404.
La rama de este incidente quita el `location /`, no ése.

**Prueba de regresión**

No hay spec de Karma: el bug está en la configuración del servidor. La regresión
es de humo y se corre contra el contenedor ya levantado:

```bash
#!/usr/bin/env bash
# smoke-routing.sh — después de construir la imagen, antes de dar por bueno nada.
set -eu
BASE="${1:-http://localhost:8080}"

# 1. Una ruta profunda tiene que devolver 200 y el index.
code=$(curl -s -o /dev/null -w '%{http_code}' "$BASE/patients/42/orders")
[ "$code" = "200" ] || { echo "FALLA: ruta profunda devolvió $code"; exit 1; }

# 2. Y un diccionario que no existe tiene que devolver 404 de verdad,
#    no un index.html disfrazado. Es la otra mitad del fix.
code=$(curl -s -o /dev/null -w '%{http_code}' "$BASE/assets/i18n/xx.json")
[ "$code" = "404" ] || { echo "FALLA: i18n inexistente devolvió $code"; exit 1; }

echo "ok: routing de SPA y assets"
```

El segundo caso es el que nadie escribe y el que caza la regresión de verdad: el
día que alguien "arregle" algo ampliando el comodín, este guion se pone rojo.

**Prevención**

El guion en el pipeline, junto al del incidente **19**. Los dos comprueban lo
mismo desde ángulos distintos: que la imagen desplegada **se comporte** como se
espera, no que se haya construido sin errores. Un `docker build` exitoso no dice
nada sobre si la aplicación funciona.

**Por qué llegó a producción**

Porque en desarrollo esto no pasa nunca. `ng serve` trae su propio servidor, que
ya hace el equivalente de `try_files` por defecto: cualquier ruta desconocida cae
en el `index.html` sin que nadie lo configure ni lo sepa. El comportamiento
correcto viene de fábrica en la herramienta de desarrollo y **no** viene de fábrica
en nginx, así que el bug nace exactamente en el momento en que el proyecto pasa de
una a otro — y ese momento ocurre una sola vez en la vida del proyecto, el día del
primer despliegue, cuando todo el mundo está mirando otras cosas.

Y sobrevivió porque, navegando, la aplicación funciona perfectamente. Hay que
recargar estando adentro para verlo, y quien despliega abre la aplicación por la
dirección principal.

**Si tu causa fue distinta a esta**

- Si dijiste **"falta configurar el `base href`"**, es un bug vecino y distinto:
  produce que **no cargue nada**, ni siquiera desde la raíz, porque las rutas de
  los bundles salen mal. Acá la raíz funciona.
- Si dijiste **"hay que usar `useHash: true` en el router"**, funciona: con
  `/#/patients/42/orders`, nginx sólo ve `/` y nunca falla. Es la solución de 2014,
  ensucia todas las URL y las hace inútiles para compartir. Antes de proponerla,
  comprueba si el equipo la descartó ya — y por qué.
- Si tu fix fue **`error_page 404 /index.html`**, funciona para este caso y es peor
  de lo que parece: convierte **cualquier** 404 en un index, incluido el de un
  diccionario de i18n que no existe, y entonces el `JSON.parse` del navegador
  revienta con un error que no menciona ni el idioma ni el archivo. Cambias un 404
  claro por una pantalla en blanco.
- Si además, al recargar, la aplicación **sí monta pero le habla al backend
  equivocado**, tienes dos incidentes en la misma pantalla: éste y el **19**.

</details>

---

## Incidente 21 — La lista no cambia al cambiar de orden

> **Fase:** 7 · **Categoría:** Estado (store) · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45-60 min · **Ruta forense:** [`forense-fase-07.md`](./forense-fase-07.md)

### 🎫 El ticket

> *"Estoy revisando las órdenes del día. Abro la 101 y veo sus muestras bien.
> Vuelvo atrás, abro la 102 y me sigue mostrando las de la 101. Si recargo la
> página con F5 ya me muestra las correctas. Casi le pongo el resultado a la
> muestra equivocada."*

**Reportado por:** analista de la mañana
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducir, localizar la línea, y —esto es lo que separa este incidente del
**10**, con el que se confunde— explicar por qué **no es un problema del store**
aunque el síntoma sea idéntico: "no pasó lo que pedí".

### 🔧 Preparación

Rama de git: una línea cambiada en el componente.

```bash
git checkout -b incidente/21 fase-07-muestras-custodia
```

Reproduce navegando **por la aplicación**, nunca con el botón de recargar: de
`/orders/101/samples` a la lista, y de ahí a `/orders/102/samples`.

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Tres cosas que mirar a la vez, y la gracia está en que no coinciden: qué dice la
URL, qué pinta la pantalla, y qué `orderId` viajó en el último `GET` de Network.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Pon un `console.log` en el `ngOnInit` del componente de la línea de muestras y
navega entre las dos órdenes. Cuenta cuántas veces se imprime. Ese número es el
diagnóstico entero.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Cuando dos rutas sólo difieren en un parámetro, el router **reusa** el componente
en vez de construirlo otra vez. Con eso: ¿qué pasa con algo que se leyó **una
sola vez** al construirlo?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

`src/app/samples/sample-timeline/sample-timeline.component.ts`, en `ngOnInit`:

```typescript
// Lo que trae la rama
var orderId = this.route.snapshot.paramMap.get('orderId');
this.store.dispatch(SamplesActions.loadSamples({ orderId: Number(orderId) }));
```

`snapshot` es **una foto del momento en que se construyó el componente**. Y al
navegar entre dos rutas que sólo se diferencian en un parámetro, el router de
Angular **reusa la instancia**: no la destruye, no la vuelve a construir y, por
lo tanto, `ngOnInit` no corre otra vez. El `snapshot` sigue diciendo `101` para
siempre.

Las tres evidencias, que no coinciden entre sí y por eso el bug se ve:

```
URL del navegador ............. /orders/102/samples     ← el router sí navegó
Último GET en Network ......... /samples?orderId=101    ← si es que hubo alguno
ngOnInit ejecutado ............ 1 vez, en la primera entrada
```

Y por eso F5 lo arregla: una recarga completa destruye y reconstruye el
componente, y el `snapshot` se toma de nuevo — con el valor correcto.

> 🧭 **Este incidente y el 10 comparten la frase del usuario y no comparten nada
> más.** El 10 es un `switchMap` que cancela una escritura en vuelo; este es una
> foto de la ruta que nadie volvió a tomar. Lo que comparten es la **sensación**
> —"no pasó lo que pedí"—, que es justamente lo que un ticket transmite y lo que un
> diagnóstico tiene que separar. Si los metieras en un mismo post-mortem, tendrías
> que escribir dos causas raíz en la casilla de una.

**Parche mínimo**

```typescript
// paramMap es un observable: emite en cada navegación, incluso cuando el
// router reusa el componente. Es el patrón correcto, no un rodeo.
this.route.paramMap.subscribe(function (this: SampleTimelineComponent, params) {
  var orderId = Number(params.get('orderId'));
  this.store.dispatch(SamplesActions.loadSamples({ orderId: orderId }));
}.bind(this));
```

**La refactorización correcta** (que en Track A 💸 no se paga)

**No existe, y decirlo es parte de la respuesta.** Suscribirse a `paramMap` no es
un parche: es directamente el patrón correcto para un componente que el router
reusa. No hay una versión "con calma y pruebas" que sea distinta de la versión del
viernes a las seis. Es de los pocos casos del curso en que el fix mínimo y el fix
correcto son la misma línea.

Lo que sí queda pendiente, y es de otra naturaleza, es la deuda declarada de la
fase: este componente se suscribe y **no se desuscribe**. Cada navegación deja una
suscripción viva más. No muerde acá porque el componente se reusa; muerde en el
dashboard de la **Fase 10**, y ahí se mide — es el incidente **16**.

**Prueba de regresión**

```typescript
// src/app/samples/sample-timeline/sample-timeline.component.spec.ts
it('recarga las muestras cuando cambia el parámetro de la ruta', function () {
  var params = new BehaviorSubject(convertToParamMap({ orderId: '101' }));
  TestBed.configureTestingModule({
    declarations: [SampleTimelineComponent],
    providers: [
      provideMockStore({ initialState: initialState }),
      { provide: ActivatedRoute, useValue: { paramMap: params } }
    ]
  });
  var fixture = TestBed.createComponent(SampleTimelineComponent);
  var store = TestBed.get(Store);
  spyOn(store, 'dispatch');
  fixture.detectChanges();   // ngOnInit, una sola vez en toda la prueba

  // El router NO reconstruye el componente: sólo emite el parámetro nuevo.
  params.next(convertToParamMap({ orderId: '102' }));

  // Con snapshot, este dispatch no ocurre y el test se pone rojo.
  expect(store.dispatch).toHaveBeenCalledWith(
    SamplesActions.loadSamples({ orderId: 102 })
  );
});
```

Ese test es el que hay que leer despacio: **no vuelve a crear el componente**. Si
lo recreara, pasaría con `snapshot` y con `paramMap` por igual, y no probaría
nada. La mitad de los tests que no cazan este bug fallan exactamente ahí.

**Prevención**

La regla, escrita donde se vea: **si la ruta lleva un parámetro que decide qué
muestra la pantalla, se lee del observable, nunca del `snapshot`.** El `snapshot`
es legítimo para lo que se lee una vez y no cambia —un modo, un tipo de vista, un
token de una ruta de entrada—, y en todo lo demás es una trampa que sólo se
dispara cuando alguien navega de la forma que en desarrollo nadie prueba: sin
recargar.

**Por qué llegó a producción**

Porque en desarrollo se navega recargando. Se abre `/orders/101/samples`, se mira,
se cambia el código, se recarga. La ruta que el usuario recorre de verdad —lista,
orden, atrás, otra orden, todo sin tocar F5— no es la ruta que recorre quien
escribe el código, y el bug vive exactamente en esa diferencia. Es de los más
comunes de la época y por eso la Fase 7 lo deja escrito en sus **Detalles con
intención**: el `paramMap` está ahí a propósito, con su comentario, para que el
día que alguien lo "simplifique" haya una nota que lo desmienta.

Y el agravante, que es lo que convierte un bug de interfaz en un incidente de un
laboratorio clínico: la analista estuvo a punto de cargarle el resultado a la
muestra de otro paciente. El síntoma es de navegación; la consecuencia es
clínica.

**Si tu causa fue distinta a esta**

- Si dijiste **"el effect no se dispara"**, es casi correcto y le falta un paso:
  el effect no se dispara porque **nadie despachó la acción**. La diferencia
  importa, porque un effect que no escucha y una acción que no se despacha se
  arreglan en archivos distintos.
- Si dijiste **"el store tiene las muestras de la 101 cacheadas"**, es verdad y no
  es el bug: el store tiene lo último que cargó, que es lo que le toca. Nadie le
  pidió otra cosa.
- Si tu fix fue **`onSameUrlNavigation: 'reload'` o un `runGuardsAndResolvers`**,
  funciona, es una configuración global del router, y afecta a todas las rutas de
  la aplicación para arreglar un componente. Anótalo: es el ejemplo perfecto de
  arreglar en la capa más ancha lo que se arreglaba en la más estrecha.

</details>

---

# 🪞 Retrospectiva del mes

Se llena al terminar, de una sola vez, releyendo tu propio `git log`.

- **Cuántos abriste, cuántos cerraste, cuántos quedaron ⚪.**
- **Cuántas veces tu causa raíz coincidió con la de referencia**, y en cuáles
  no. El patrón importa más que el número.
- **En qué capa te costó más**: plantilla, componente, store, effect,
  interceptor, mock, build.
- **Qué pista abriste antes de tiempo y por qué**. Sin culpa; es un dato sobre
  dónde te falta confianza, no sobre tu disciplina.
- **Tu checklist de hotfix**, la de una página, reescrita con lo que aprendiste
  acá. Es lo único de este archivo que te llevas al trabajo real.

---

# 📌 Pendientes que salieron de los incidentes

Lo que apareció investigando y no cabía en el fix, con el ID que lo originó. La
lista arranca con lo que salió al redactar los enunciados; **lo que encuentres tú
se agrega abajo**, con el mismo formato y en el commit del incidente que lo
produjo.

- **[02]** La dirección exacta con la que se abre la aplicación no está escrita en
  ningún sitio, y media tarde se perdió por eso → una línea en el README del
  proyecto.
- **[05]** El mock no valida el token en las rutas de datos, así que una sesión
  cerrada sigue pudiendo escribir. En el track base no se arregla —el servidor no
  es nuestro— → lo construye el 🔥 **track BE**, fase `be01`.
- **[07]** La **alerta activa** de resultado crítico —notificar, un canal, un turno
  de guardia, un acuse de recibo— no existe y no es de mantenimiento → decisión de
  producto, fuera del alcance del curso. Se escala con números, no se improvisa.
- **[07]** *¿A qué hora exactamente entra en vigor una norma clínica?* Mientras
  nadie lo conteste, cualquier implementación del borde de vigencia está
  adivinando → decisión de negocio, y va firmada por quien emite la norma.
- **[08]** El modo de caos activo sólo se ve en la terminal del mock; no hay nada
  en la interfaz que lo muestre → ejercicio 🔥 o pendiente ya anotado por la
  **Fase 4**.
- **[10]** `selectPatientsSaving` existe, está exportado y **ninguna plantilla lo
  consume**. Conectarlo cierra la ventana de confusión de las escrituras → deuda
  💸 declarada en la **Fase 5 §5.8**; es un cambio de comportamiento de pantalla,
  con su ticket.
- **[11] [12]** Los dos detectores —custodia rota y validados sin norma— son
  guiones cortos que convierten un hallazgo por casualidad en una revisión
  periódica → ejercicio 🔥 de las Fases 7 y 8, o un apéndice propio si el equipo
  decide correrlos en serio.
- **[15]** `setTextColor` no se revierte solo: a partir del primer valor crítico,
  la firma y la fecha del informe también salen en rojo. Mismo mecanismo que este
  incidente, otro estado del lápiz → buen candidato al **22**, que sigue sin dar
  de alta.
- **[16]** El patrón de suscribirse sin `ngOnDestroy` está en todo el curso, no
  sólo en el dashboard. `grep -rn "\.subscribe(" src/` da el tamaño real →
  ticket de proyecto, no hotfix.
- **[17]** La pantalla de trazabilidad no dice en ninguna parte que el actor y la
  hora los declara el cliente y no los verifica nadie → una nota en la propia
  pantalla; es lo único que cabe hoy y le importa a una persona.
- **[18]** Una factoría de datos de prueba —`buildPatientsState(overrides)`— que
  quite la tentación de compartir estado entre specs → media tarde sobre la suite
  de la **Fase 12**.
- **[19] [20]** Los dos guiones de humo —`smoke-deploy.sh` y `smoke-routing.sh`—
  deberían correr solos después de cada despliegue → el pipeline de CI/CD está
  **fuera del alcance del curso**, así que hoy se corren a mano y se anota quién.

---

## 🔥 El cuaderno hermano del track de backend

Este archivo es el cuaderno del **track base**, y sus IDs no cambian nunca.

El track opcional de backend tiene el suyo, **`cuaderno-incidentes-be.md`**, con
doce incidentes numerados `be-01` … `be-12` y un rango de IDs **independiente**:
los dos cuadernos no se cruzan ni se renumeran el uno al otro.

La separación es deliberada. Quien haga solo el track base no tiene por qué
recibir incidentes de Java 8 + Spring Boot 2.1 + MongoDB mezclados con los suyos, y quien haga los dos sabe
en todo momento de qué capa es el ticket que está leyendo — que es justamente el
músculo que los dos cursos entrenan.

⚠️ Los incidentes del track BE tienen además una particularidad: **uno de ellos no
tiene par `-roto` / `-fix`**, porque su causa no está en ningún commit. Está
explicado en `00-convencion-de-git-y-tags.md`.
