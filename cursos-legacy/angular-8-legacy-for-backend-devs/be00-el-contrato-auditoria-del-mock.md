# 📜 Fase be00 — El contrato: auditoría del mock

> Tutorial Angular 8 — Laboratorio clínico · 🔥 Track BE · Fase be00 de be08 · **6 horas**
> Depende de: **Fase 11 del track base terminada** (`fase-11-trazabilidad-audit-log`)
> Habilita: be01
> Apéndices de apoyo: ninguno todavía · [Incidentes asociados](./cuaderno-incidentes-be.md): ninguno

---

## 🎯 1. Propósito

Vas a apagar un servidor y a poner otro en su lugar sin que la aplicación que lo consume se entere. Esta fase existe para contestar la única pregunta que decide si eso sale bien o sale mal: **¿qué promete exactamente el servidor que voy a apagar?**

No "qué hace". Qué **promete**. Son cosas distintas y la diferencia es el track entero. El mock que escribiste en la Fase 4 hace un montón de cosas que a nadie le importan: soporta `_page`, `_sort`, `_embed`, operadores de rango, búsqueda de texto completo. Nada de eso está en el contrato, porque **nadie lo llama**. Y al revés: hace dos o tres cosas que jamás documentaste, que ninguna línea de código tuyo eligió, y de las que el frontend depende sin saberlo. Esas sí están en el contrato, y si las rompes en `be03`, la pantalla de pacientes sale en blanco y no vas a saber por qué.

> 🧠 **El contrato de una API no es lo que el servidor puede hacer. Es lo que el cliente ya asumió.** Lo primero se lee en el código del servidor; lo segundo solo se ve mirando el tráfico. Por eso esta fase se hace con la pestaña Network abierta y no con el editor.

Seis horas, y no se escribe una sola línea de Java. Salen dos artefactos: `CONTRACT.md`, que es la única documentación que va a existir de este sistema, y `smoke.sh`, que a partir de aquí es **el juez de todas las fases del track**. Cuando en `be03` apagues `npm run mock` y levantes el contenedor, no vas a decidir tú si funcionó: lo va a decidir `smoke.sh`.

---

## ✅ 2. Qué queda listo al terminar

- [ ] Tienes una captura de tráfico real —un `.har` exportado— recorriendo las pantallas de las Fases 5 a 11, y de ella sacaste la lista completa de peticiones que la aplicación emite. Ninguna entrada de esa lista salió de leer el código del mock.
- [ ] `CONTRACT.md` existe en la raíz del proyecto, con una tabla por recurso —método, ruta, parámetros observados, forma de la respuesta y códigos de error vistos— para los cinco recursos de datos, `/auditLog` y `POST /login`.
- [ ] `CONTRACT.md` declara los **cinco modos del inyector de caos** con sus dos vías de activación y su orden de precedencia, tal como se comporta hoy y no como te parece que debería comportarse.
- [ ] `CONTRACT.md` separa **régimen estricto** —lo que el backend nuevo no puede cambiar sin romper la aplicación— de **régimen de crecimiento** —lo que puede añadir sin que nadie se entere—, y cada línea del régimen estricto nombra el archivo del frontend que la exige.
- [ ] `./smoke.sh` corre contra `npm run mock` y termina en verde con código de salida `0`, verificando al menos doce afirmaciones del contrato. Le cambias una expectativa a mano y termina en rojo con código `1`, nombrando cuál falló.
- [ ] Puedes explicar, sin abrir el código, por qué `GET /patients` produce **una** entrada en Network y `GET /patients` con el header `X-Chaos` produce **dos**.
- [ ] Puedes decir en una frase qué pasa hoy si mandas una petición a `/patients` **sin** el header `Authorization`, y por qué esa respuesta es la razón de que arreglar la seguridad en `be03` sea una decisión de producto y no una de ingeniería.

---

## 🚫 3. Qué NO entra todavía

- **Una sola línea de Java.** Esta fase audita y documenta; el `pom.xml` y el primer `@RestController` son de **be01**.
- **MongoDB, en cualquier forma.** Ni el `compose.yaml`, ni un `@Document`, ni una conexión. La base entra en **be03**, y lo que hay guardado de verdad se mide en **be02**.
- **Arreglar lo que la auditoría encuentre.** Vas a descubrir que la autenticación no se verifica en ninguna parte, que el audit log lo escribe el navegador y que no existe paginación de servidor. Hoy se anotan. La identidad y el reloj son de **be04**, la paginación de **be03**, y la conversación completa sobre qué se contiene y qué se declara irrecuperable es de **be08**.
- **Tocar el frontend para que el contrato quede más bonito.** No. El contrato es el que es. Si algo del contrato te parece feo, esa fealdad es un dato de la auditoría, no un ticket.
- **Pruebas automatizadas de verdad.** `smoke.sh` es un guion de `curl` con `grep`, deliberadamente tonto y sin dependencias. La estrategia de pruebas del track se decide, midiendo, en **be08**.

---

## 🧠 4. Concepto mínimo

### 4.1 De dónde salió el backend, y por qué es tuyo

La historia larga está en [`00-historia-del-sistema.md`](./00-historia-del-sistema.md); acá va la parte que hace falta para trabajar.

En 2019, el mismo equipo contratado que escribió el frontend que ya conoces escribió también el otro lado del cable: **Java 8, Spring Boot 2.1 y MongoDB**. Cuando el contrato terminó, ese frente se fue igual que el del frontend, y el backend quedó **congelado y sin dueño**. En los papeles lo heredó Maintenance. O sea, tú.

Esa frase explica las dos deudas más incómodas del track base, y conviene releerlas ahora con ojos de servidor:

- **El audit log lo escribe el frontend** (Fase 11) no porque a nadie se le ocurriera algo mejor, sino porque en 2021 pedirle un endpoint nuevo a un backend congelado y ajeno no era una conversación que se pudiera tener.
- **El timestamp y el "quién" de la cadena de custodia los pone el navegador** (Fase 7), por lo mismo.

> 🧠 **El backend no viene a redimir nada. El backend es la escena del crimen.** Este track no pregunta cómo se hace bien un backend. Pregunta qué haces el lunes cuando lo que está mal es una decisión de arquitectura de hace siete años, el sistema factura, y no hay presupuesto para deshacerla.

### 4.2 Mongo no es el villano, y esto se dice antes de la primera factura

Durante las próximas ocho fases vas a medir cosas incómodas: cinco formas distintas del documento de paciente, referencias rotas que nadie detectó, una transacción que el servidor rechaza, catorce meses de historia de rangos sobrescrita. Es fácil leer eso como *"eligieron mal la base"*. Sería una lectura perezosa y falsa, y hay que desactivarla ahora.

La decisión de 2019 tiene una historia. Venían de un Oracle corporativo con un DBA que tardaba tres semanas en aprobar una columna nueva, y alguien dijo la frase que funda medio sistema: *"con Mongo el esquema lo movemos nosotros"*. **Y tenía razón.** Ese dolor era real y el cambio les compró velocidad de verdad.

Hay más, y es lo que importa: **una parte del dominio de un laboratorio sí es documental**. Abre el `db.json` que ya tienes y míralo con calma. Un hemograma reporta un panel de once analitos con sus banderas; un perfil lipídico reporta cuatro más un índice calculado; un cultivo reporta un texto y una lista de sensibilidades a antibióticos que ni siquiera tiene un número de columnas fijo. Esos tres no comparten forma, y modelarlos en tablas duele: o haces una tabla por examen, o haces una tabla de pares clave-valor y pierdes el tipo, o haces cincuenta columnas nulas. **El panel de resultados *es* un documento**, y el equipo de 2019 vio eso y acertó.

El error interesante vino después, y es un error de rango, no de criterio: **generalizaron desde ahí a todo el sistema**. Pacientes, órdenes, custodias y rangos de referencia —que son entidades relacionales de manual, con integridad referencial que a alguien le importa— se modelaron con la misma herramienta que resolvía el panel. Eso no fue ignorancia: fue una buena intuición aplicada fuera de su rango de validez.

> 🧭 **Guía del repositorio, que gobierna este track:** cada familia gana en algún sitio y pierde en otro. Cualquier capítulo que se lea como *"Mongo es malo"* está mal escrito. En **be08**, cuando toque el veredicto, vas a tener que poner el número de las dos columnas: dónde perdió y dónde ganó de verdad.

### 4.3 Qué significa auditar un contrato que nadie escribió

Un contrato de API normalmente es un documento: un OpenAPI, un `.proto`, una página de Confluence. LabCore no tiene ninguna de las tres. Lo que tiene es un cliente en producción que hace suposiciones, y esas suposiciones **ya son el contrato**, las haya escrito alguien o no.

De ahí salen tres reglas de método para esta fase.

**La primera: se captura, no se lee.** La tentación es abrir `mock-server/server.js` y transcribir lo que hace. No lo hagas, y la razón no es pedagógica sino práctica: el código del servidor te dice el **conjunto de lo posible**, y tú necesitas el **conjunto de lo usado**. json-server 0.16.3 soporta paginación, ordenamiento, operadores de rango y relaciones embebidas; si transcribes el código, `CONTRACT.md` va a listar veinte capacidades y en `be01` vas a intentar reimplementarlas todas. Quince de ellas no las llama nadie. Al revés también falla: hay comportamientos que el frontend consume y que no están escritos en ninguna línea de tu mock, porque son el **valor por defecto de una librería**. Esos no se ven leyendo tu código. Se ven mirando la respuesta.

**La segunda: el contrato incluye la forma del error, no solo la del éxito.** Tu `catchError` depende de que un fallo llegue con `status: 500` y un cuerpo con `message`. Un backend nuevo que devuelva un 500 con la página de error de Spring adentro cumple HTTP y rompe la aplicación igual. En `be01` esto tiene nombre: `@ControllerAdvice`.

**La tercera, y es la que más cuesta: el contrato incluye lo que el servidor *no* verifica.** Un servidor que ignora el header `Authorization` está haciendo una promesa —"te dejo pasar"— exactamente igual que uno que lo valida. Si el reemplazo empieza a validarlo, el reemplazo **rompió el contrato**, aunque lo haya hecho para mejor. Esa frase te va a incomodar, y debe.

> 📝 **Nota de época.** En 2019 esto se hacía así. Hoy, un equipo que va a reemplazar un servicio graba el tráfico de producción y lo reproduce contra el candidato —*traffic shadowing*, *record & replay*— con herramientas dedicadas. Tú no tienes producción a mano ni presupuesto para eso, pero **la idea es exactamente la misma** y la vas a ejecutar a mano: grabar, inventariar, reproducir. Que la herramienta sea la pestaña Network no cambia el método.

### 4.4 Régimen estricto y régimen de crecimiento

No todo el contrato pesa igual, y meterlo todo en el mismo saco es lo que convierte una migración de dos semanas en una de dos meses. Conviene partirlo en dos desde el primer día.

El **régimen estricto** es lo que el cliente ya consume: la ruta, el método, la forma del cuerpo que sabe leer, el tipo del `id`, el código de estado que dispara cada rama de su código. Cambiar cualquier cosa de aquí rompe algo, y como el frontend no se toca, **no hay negociación posible**: el backend se adapta.

El **régimen de crecimiento** es lo que el backend puede añadir sin que nadie se entere: campos nuevos en la respuesta, endpoints nuevos, parámetros de consulta nuevos que el cliente no manda, cabeceras nuevas que el cliente no mira. Un cliente que lee las tres propiedades que le interesan e ignora el resto —un *lector tolerante*— deja crecer el servidor gratis.

La pregunta interesante es: **¿el frontend de LabCore es un lector tolerante?** Y la respuesta es que sí, por accidente y no por diseño. `strict: false` y `any` en todo el store significan que nadie valida la forma de nada; un campo nuevo en la respuesta de `/patients` viaja hasta el reducer, se guarda y no molesta a nadie. Es la misma deuda que en el track base produce el modo `malformed` del inyector de caos, vista desde el otro lado y trabajando a tu favor por una vez.

> 💡 Anota esa ironía en `CONTRACT.md`, porque vas a volver a ella en **be03**: la ausencia de tipos, que en el track base es una deuda, es lo que en el track BE te va a permitir crecer el servidor sin tocar el cliente. Una misma decisión, dos signos distintos según de qué lado del cable la mires.

### 4.5 El dialecto de json-server, que es tu contrato de verdad

Casi todo el régimen estricto de LabCore no lo decidió nadie: lo decidió una librería que alguien arrancó con `npx` en la Fase 0 y que se quedó. Estos son los rasgos que la aplicación consume, y cada uno es una cosa que `be03` tendrá que reproducir exactamente:

- **Filtro por igualdad con el nombre del campo como parámetro.** `GET /orders?patientId=1`. No es `?filter=` ni `?where=`: es el nombre del campo, crudo, y compara por igualdad estricta después de convertir tipos.
- **`id` entero autoincremental**, calculado como el máximo existente más uno. El store del frontend guarda enteros y los concatena en URLs (`'/samples/' + sampleId`). Un `id` con forma de `ObjectId` rompe esto de inmediato.
- **`POST` devuelve `201` con el objeto creado entero**, incluido el `id` recién asignado. El effect de pacientes cuenta con ello.
- **`GET` de un recurso inexistente devuelve `404` con el cuerpo `{}`** —un objeto vacío, no un cuerpo vacío, no un JSON de error.
- **`PATCH` devuelve el documento completo después del cambio**, no el delta ni un `204`. La Fase 7 despacha `transitionSampleSuccess` con lo que responde el `PATCH`, así que si el cuerpo llega incompleto, el store se queda con una muestra a medias.
- **`GET` de colección devuelve el arreglo desnudo**, sin envoltorio, sin `total`, sin metadatos de paginación. No hay `{ data: [...] }` en ninguna parte.

Y un rasgo que no es de json-server sino de tu propio código, y que es el más fácil de olvidar: **el `POST /auditLog` manda el `id` en el cuerpo**, generado por el navegador y con forma de cadena, mientras que el `POST /patients` no manda `id` y recibe un entero del servidor. Dos `POST`, dos contratos de identidad opuestos, en el mismo sistema.

> 📚 json-server 0.16.3 — README con la lista completa de rutas y parámetros: https://github.com/typicode/json-server/tree/v0.16.3 · ⚠️ La rama 1.x que hoy sale primero en las búsquedas cambió el comportamiento por defecto de varias de estas cosas. La que corre en tu proyecto es la **0.16.3**.

---

## 💻 5. Código mínimo con comentarios

Seis piezas: la sesión de captura, el inventario, `CONTRACT.md`, la matriz del caos, la partición de regímenes y `smoke.sh`.

### 5.1 La sesión de captura

Todo el trabajo de esta fase sale de una sola sesión de navegación bien hecha. Levanta el sistema como siempre, en tres terminales:

```bash
npm run seed          # el semillero de las Fases 5 y 7: ~25 pacientes, ~40 órdenes
npm run mock          # el servidor honesto en el 3000, sin caos
npx ng serve          # la aplicación en el 4200
```

Abre DevTools **antes** de entrar a la aplicación, en la pestaña Network, y prepárala:

- Marca **Preserve log**. Sin eso pierdes todo en cada navegación y la sesión no sirve.
- Marca **Disable cache**. Quieres el tráfico real, no el que el navegador se ahorró.
- Deja el filtro en **Fetch/XHR** para no ahogarte en `.js` y `.css`.

Y ahora el recorrido, que tiene un orden obligatorio. **Navega primero a `/orders` y `/samples`**: sus slices son de carga diferida y si no pasas por ahí, media aplicación no pide nada y tu captura sale coja. Ese detalle, que en el track base es el material del ejercicio 17 de la Fase 6, aquí es un requisito metodológico.

El guion mínimo, once pasos:

1. Entra a `/login` y autentícate como `analista1`.
2. Ve a `/patients`. Pasa a la segunda página de la tabla.
3. Abre el formulario de paciente nuevo y **escribe un documento que ya exista** — sin guardar. Eso dispara el validador asíncrono de la Fase 5.
4. Guarda un paciente nuevo de verdad.
5. Da de baja a un paciente.
6. Ve a `/orders`. Abre una orden.
7. Desde la ficha de un paciente, abre el selector de órdenes cruzado.
8. Ve a `/samples` de una orden y transiciona una muestra.
9. Entra a los resultados de esa muestra, escribe un valor y **valida** uno.
10. Entrega una orden completa (la que produce el PDF).
11. Abre la bitácora en `/audit/...` de cualquiera de las entidades que acabas de tocar.

Cuando termines, clic derecho sobre la lista de peticiones → **Save all as HAR with content**, y guarda el archivo como `contract/capture-<fecha>.har` dentro del proyecto.

> ⚠️ **El `.har` lleva tu token adentro.** Un HAR guarda las cabeceras, y ahí va el `Authorization: Bearer …` de la sesión. En este curso el token es de mentira y expira en dos minutos, así que no pasa nada; el reflejo, en cambio, sí importa: un HAR de producción es material sensible y no se pega en un ticket ni se sube a un repositorio compartido sin limpiarlo antes.

### 5.2 Del HAR al inventario

El HAR es un JSON grande y feo. Esto lo convierte en la lista que necesitas:

```bash
# Todas las peticiones únicas de la sesión, con su método, su ruta y el
# código de estado con el que respondió el mock. La ruta se corta en el "?"
# para agrupar, y los parámetros se miran aparte en el paso siguiente.
jq -r '.log.entries[]
       | [ .request.method,
           (.request.url | sub("^http://localhost:3000"; "") | sub("\\?.*$"; "")),
           (.response.status | tostring) ]
       | @tsv' contract/capture-*.har \
  | sort | uniq -c | sort -rn
```

```bash
# Y ahora los parámetros de consulta que la aplicación usa de verdad,
# que es la mitad del contrato y la que nadie documenta.
jq -r '.log.entries[].request.queryString[]?.name' contract/capture-*.har \
  | sort | uniq -c | sort -rn
```

**Detalles con intención**

- El primer comando agrupa por ruta **sin** parámetros y el segundo mira solo los parámetros. Separarlos es a propósito: mezclados, `/orders?patientId=1` y `/orders?patientId=7` parecen dos endpoints distintos y no lo son.
- `sort | uniq -c | sort -rn` te da además **cuántas veces** se llamó cada cosa. Ese número no es decorativo: en `be03` te dice qué endpoint tiene que ser rápido y cuál puede tardar. `GET /auditLog` va a aparecer más veces de las que esperas, y eso es el ejercicio 11 de la Fase 11 pidiendo pista.
- Si no tienes `jq` a mano, el panel de Network exporta la misma lista con **Copy → Copy all as cURL**, y con eso se puede trabajar igual. `jq` solo ahorra tiempo.

**El patrón a memorizar:** el inventario de un contrato se ordena por **frecuencia observada**, no por importancia percibida. Lo que más se llama es lo que más rápido te va a delatar si lo rompes.

### 5.3 `CONTRACT.md` — la única documentación que va a existir

Este archivo vive en la raíz del proyecto, se versiona, y a partir de aquí manda. Cuando en `be03` una pantalla salga en blanco, la conversación no va a ser "¿qué esperaba el frontend?" sino "¿qué dice el contrato?".

El formato es una tabla por recurso más una nota de forma. Así queda el de pacientes, completo, para que copies la estructura:

````markdown
## `/patients`

| Método | Ruta | Parámetros observados | Respuesta | Errores vistos |
|---|---|---|---|---|
| GET | `/patients` | ninguno | `200` · arreglo desnudo de objetos paciente | `500` (caos) |
| GET | `/patients` | `documentId=<string>` | `200` · arreglo de 0 o 1 elementos | — |
| POST | `/patients` | — | `201` · el objeto creado, con `id` entero nuevo | — |
| PUT | `/patients/:id` | — | `200` · el objeto completo tras el reemplazo | `404` con cuerpo `{}` |
| PATCH | `/patients/:id` | — | `200` · el objeto **completo** tras el cambio | `404` con cuerpo `{}` |

**Forma del documento** (observada, no declarada):

```json
{ "id": 1, "documentId": "CC-1032456789", "fullName": "Marcela Ríos",
  "birthDate": "1984-03-12", "email": null, "active": true }
```

**Notas del contrato**

- `email` puede ser `null`. El paciente 3 del semillero lo tiene así a propósito.
- `active` **no está en todos los documentos**: los tres pacientes anteriores al
  `seed.js` no lo traen. El selector del frontend filtra con `p.active !== false`
  justamente por eso (Fase 5 §5.6). Un backend que devuelva `active: true` por
  defecto en esos tres no rompe nada; uno que devuelva `false`, sí.
- La búsqueda por `documentId` es igualdad exacta, **sensible a mayúsculas**, y
  devuelve arreglo aunque el resultado sea único. El validador asíncrono del
  formulario decide "ya existe" mirando `length > 0`.
- El `PATCH` de baja manda `{ "active": false }` y espera el documento entero de
  vuelta. Devolver `204` rompe el store.
````

Repite eso para `/orders`, `/samples`, `/results`, `/referenceRanges`, `/auditLog` y `/login`. Los parámetros que vas a encontrar en la captura, y ninguno más, son estos:

| Recurso | Parámetro observado | Quién lo emite |
|---|---|---|
| `/patients` | `documentId` | el validador asíncrono del formulario (Fase 5) |
| `/orders` | `patientId` | el selector de órdenes de la ficha de paciente (Fase 5 §5.x) |
| `/samples` | `orderId` | `SamplesService.getByOrder` (Fase 7) |
| `/results` | `sampleId` | `ResultsService.getBySample` (Fase 8) |
| `/referenceRanges` | **ninguno** | se traen todos, siempre, y se filtra en memoria (Fase 8) |
| `/auditLog` | **ninguno** | se trae toda la bitácora y se filtra en el navegador (Fase 11) |

> 🧭 **Los dos "ninguno" de esa tabla son el hallazgo más caro de la fase.** No es que el frontend no filtre: es que filtra **en el navegador**, trayéndose la colección entera. Con el semillero del curso eso son unos cientos de documentos y no se nota. En un laboratorio con seis años de operación, `GET /auditLog` es la bitácora completa viajando por el cable cada vez que alguien abre una timeline. Anótalo con esas palabras: es la 💸 3 del track base —paginar, filtrar y ordenar se hace en el cliente porque el servidor nunca lo expuso— y es lo que **be03** viene a cobrar.

Y el hallazgo incómodo, que va en su propia sección del archivo:

````markdown
## 🔓 Autenticación: lo que el servidor NO verifica

`POST /login` firma un JWT real (HS256, TTL de 120 segundos, claims `sub`,
`role`, `fullName`). El interceptor lo adjunta como `Authorization: Bearer …` a
**todas** las peticiones salientes.

**Ningún endpoint de datos lo verifica.** No hay un solo middleware entre el
inyector de caos y `json-server` que mire ese header. Un `curl` a `/patients` sin
`Authorization` responde `200` con todos los pacientes.

- El `401` que la aplicación sabe manejar sale de dos sitios y de ningún otro:
  del `POST /login` con credenciales malas, y del modo `expired` del caos.
- El token expira en **120 segundos** y **no hay refresh**. Hoy eso es inofensivo
  porque nadie valida nada.

⚠️ **Consecuencia para el reemplazo, y es de producto, no de ingeniería:** el día
que el backend empiece a validar el token de verdad, cada sesión muere a los dos
minutos y el usuario vuelve a `/login` en mitad de una validación de resultados.
"Arreglar la seguridad" sin tocar el frontend —que no se toca— significa romper la
aplicación. La decisión se documenta aquí y se toma en `be04`.
````

### 5.4 La matriz del caos

El inyector de caos de la Fase 4 no es andamiaje que se pueda tirar: es parte del contrato, porque las prácticas de diagnóstico del curso lo usan y `be01` tiene que reproducirlo **con paridad exacta**. Documéntalo midiendo, no recordando.

| Modo | Cómo se activa | Qué hace exactamente |
|---|---|---|
| `latency=<ms>` | `CHAOS` o `X-Chaos` | Espera N ms y **después** decide el resto. Envuelve a todos los demás modos |
| `fail=<status>@<pct>` | ídem | Devuelve ese status en ese porcentaje de peticiones. Cuerpo: `{ "message": "Fallo inyectado por el middleware de caos", "chaos": true }`. Sin `@`, 100% |
| `malformed` | ídem | `200 OK` con `{ "data": { "items": "no-soy-un-arreglo" }, "total": null }` |
| `timeout` | ídem | No responde y no cierra. La petición queda *pending* para siempre |
| `expired` | ídem | `401` con `{ "message": "Token expirado" }`, venga el token que venga |
| `nocors` | ídem | Responde bien y **quita** `Access-Control-Allow-Origin`. El navegador la descarta |

Y las tres reglas que gobiernan todo eso, que son lo que de verdad hay que copiar:

1. **Precedencia entre fuentes: el header gana sobre la variable de entorno.** Si `X-Chaos` viene presente, `CHAOS` se ignora por completo para esa petición —no se combinan—. Eso permite tener el servidor sano y romper una sola petición desde la consola.
2. **Precedencia entre modos, dentro de la misma petición:** `expired` → `fail` → `malformed`. La latencia no compite: se aplica antes que todos.
3. **Un modo desconocido se ignora en silencio.** Escribe `latencia=2000` en vez de `latency=2000` y el servidor arranca contento, sin caos y sin avisar. Es una decisión mala a propósito del track base, y `be01` la va a heredar tal cual, porque **el contrato incluye los defectos**.

> 💡 La regla 1 se enuncia igual en la Fase 13 con nginx y las variables de entorno: *cuando una configuración se puede leer de dos lugares, lo primero que se documenta no es el formato sino la precedencia*. La mitad de los incidentes de configuración de cualquier sistema son dos fuentes de verdad sin un orden escrito entre ellas.

### 5.5 La partición: régimen estricto y régimen de crecimiento

La última sección de `CONTRACT.md`, y la que más te va a servir en las ocho fases siguientes. La regla de oro: **cada línea del régimen estricto nombra el archivo del frontend que la exige**. Si no puedes nombrarlo, no es estricto: es una costumbre.

````markdown
## 🔒 Régimen estricto — no se puede cambiar

| Promesa | Quién la exige |
|---|---|
| Puerto `3000`, mismo origen para datos y login | `environment.apiUrl` |
| `id` entero en las cinco colecciones de datos | `patients.reducer.ts`, y toda URL que concatena `'/' + id` |
| `GET` de colección devuelve arreglo desnudo | todos los `*.effects.ts` |
| `POST` devuelve `201` + objeto creado con su `id` | `patients.effects.ts` |
| `PATCH` devuelve el documento completo | `samples.effects.ts`, `results.effects.ts` |
| `404` con cuerpo `{}` | el `catchError` de los servicios |
| `POST /login` → `{ token, expiresIn }` | `auth.service.ts` |
| `401` en cualquier respuesta ⇒ logout | `auth.interceptor.ts` |
| Colección `auditLog`, con `id` **string** enviado en el cuerpo | `audit.service.ts`, `audit.effects.ts` |
| Los seis modos de caos y su precedencia | las prácticas de las Fases 4 a 12 |
| CORS hacia `http://localhost:4200`, `X-Chaos` entre los headers permitidos | el navegador |

## 🌱 Régimen de crecimiento — se puede añadir sin romper nada

- **Campos nuevos en cualquier respuesta.** `strict: false` y `any` en el store:
  nadie valida forma. Un `createdAt` nuevo en `/patients` no molesta a nadie.
- **Endpoints nuevos.** Nadie los llama; existir no cuesta.
- **Parámetros de consulta nuevos** (`_page`, `_limit`, `_sort`): el cliente no
  los manda hoy. Que el servidor los entienda es gratis y es el camino por el que
  `be03` puede exponer paginación de verdad **sin** tocar el frontend.
- **Cabeceras nuevas de respuesta** (`X-Request-Id`, `X-Total-Count`): el cliente
  no las mira.
- **Códigos de estado nuevos para casos que hoy no ocurren.** Cuidado: si el caso
  empieza a ocurrir, el cliente no sabe manejarlo. Anotar, no asumir.
````

### 5.6 `smoke.sh` — el juez

Bash y `curl`. Sin dependencias, sin framework, sin `node_modules`. Tiene que correr igual contra el mock de hoy y contra el contenedor de Java de `be03`, porque esa comparación **es** la prueba de que el reemplazo salió bien.

```bash
#!/usr/bin/env bash
# smoke.sh — El juez del contrato de LabCore.
#
# Corre contra CUALQUIER servidor que diga implementar el contrato: el mock de
# json-server de hoy, o el backend de Java a partir de be03. Si pasa contra los
# dos, el reemplazo fue invisible para el frontend. Ese es todo el criterio.
#
#   uso: ./smoke.sh [base_url]   (por defecto http://localhost:3000)

set -u
BASE="${1:-http://localhost:3000}"
PASS=0
FAIL=0

# --- Ayudantes -------------------------------------------------------------

# Compara el código de estado de una petición contra el esperado.
# El -o /dev/null descarta el cuerpo: aquí solo miramos el número.
expect_status() {
  local label="$1" expected="$2" method="$3" path="$4" body="${5:-}"
  local actual
  if [ -n "$body" ]; then
    actual=$(curl -s -o /dev/null -w '%{http_code}' -X "$method" \
             -H 'Content-Type: application/json' -d "$body" "$BASE$path")
  else
    actual=$(curl -s -o /dev/null -w '%{http_code}' -X "$method" "$BASE$path")
  fi
  if [ "$actual" = "$expected" ]; then
    echo "  ok   $label ($expected)"; PASS=$((PASS+1))
  else
    echo "  FALLA $label — esperaba $expected, llegó $actual"; FAIL=$((FAIL+1))
  fi
}

# Comprueba que el cuerpo de la respuesta case con un patrón. Deliberadamente
# tosco: grep sobre el JSON crudo, sin jq, para que este guion no dependa de
# nada que no esté en cualquier máquina.
expect_body() {
  local label="$1" pattern="$2" method="$3" path="$4" body="${5:-}"
  local out
  if [ -n "$body" ]; then
    out=$(curl -s -X "$method" -H 'Content-Type: application/json' \
          -d "$body" "$BASE$path")
  else
    out=$(curl -s -X "$method" "$BASE$path")
  fi
  if echo "$out" | grep -Eq "$pattern"; then
    echo "  ok   $label"; PASS=$((PASS+1))
  else
    echo "  FALLA $label — el cuerpo no casó con /$pattern/"
    echo "         recibido: $(echo "$out" | head -c 160)"
    FAIL=$((FAIL+1))
  fi
}

echo "== Contrato de LabCore contra $BASE =="

# --- 1. Las cinco colecciones responden y devuelven ARREGLO DESNUDO --------
# El "^\[" es la afirmación importante: sin envoltorio, sin {data:...}.
for c in patients orders samples results referenceRanges; do
  expect_status "GET /$c responde"        200 GET "/$c"
  expect_body   "GET /$c es un arreglo"   '^\[' GET "/$c"
done

# --- 2. Identidad: id entero y recurso individual --------------------------
expect_body "el id de un paciente es entero" '"id"[[:space:]]*:[[:space:]]*[0-9]+' GET "/patients/1"
expect_status "GET /patients/1 existe"       200 GET "/patients/1"

# --- 3. El 404 que el frontend sabe leer -----------------------------------
# Cuerpo {} , no vacío y no un JSON de error. Lo pide el catchError de los
# servicios: si llega otra cosa, el mensaje de error de pantalla cambia.
expect_status "GET /patients/999999 -> 404" 404 GET "/patients/999999"
expect_body   "el 404 trae cuerpo {}"       '^\{[[:space:]]*\}$' GET "/patients/999999"

# --- 4. Filtro por igualdad con el nombre del campo ------------------------
expect_status "GET /orders?patientId=1"  200 GET "/orders?patientId=1"
expect_body   "el filtro devuelve arreglo" '^\[' GET "/samples?orderId=101"

# --- 5. Login: forma exacta del cuerpo -------------------------------------
expect_body "POST /login devuelve token y expiresIn" \
  '"token"[[:space:]]*:.*"expiresIn"[[:space:]]*:[[:space:]]*[0-9]+' \
  POST "/login" '{"username":"analista1","password":"analista1"}'
expect_status "POST /login con clave mala -> 401" \
  401 POST "/login" '{"username":"analista1","password":"nope"}'

# --- 6. Lo que el servidor NO verifica, afirmado a propósito ---------------
# Esto NO es un descuido del guion: es una cláusula del contrato. El día que
# esta línea se ponga en rojo, alguien decidió validar el token, y esa decisión
# tiene consecuencias de producto (ver CONTRACT.md, sección de autenticación).
expect_status "GET /patients SIN Authorization sigue dando 200" 200 GET "/patients"

# --- 7. El audit log, con su id de cadena venido del cliente ---------------
expect_body "POST /auditLog conserva el id que manda el cliente" \
  '"id"[[:space:]]*:[[:space:]]*"smoke-' \
  POST "/auditLog" \
  '{"id":"smoke-0001","timestamp":"2026-09-10T10:00:00.000Z","actor":"smoke","action":"[Smoke] Test","entityType":"patient","entityId":"1","before":null,"after":null}'

# --- Veredicto -------------------------------------------------------------
echo
echo "== $PASS en verde, $FAIL en rojo =="
[ "$FAIL" -eq 0 ] || exit 1
```

**Detalles con intención**

- **La afirmación 6 es la más importante del guion y la más rara.** Está afirmando que el servidor *no* protege los datos. Un `smoke.sh` no está para decir si el sistema es bueno: está para decir si el sistema **sigue siendo el mismo**. El día que esa línea se ponga en rojo habrá sido por una mejora, y la mejora tendrá que discutirse igual.
- El `POST /auditLog` de la prueba deja basura en la base. Es a propósito y está declarado: el guion es de humo, no de integración, y limpiarlo requeriría un `DELETE` que el frontend nunca hace y que por tanto no está en el contrato. En `be08`, cuando se decida la estrategia de pruebas de verdad, esto se revisa.
- `grep` sobre el JSON crudo en vez de `jq` es feo y lo sabe. La razón es que este guion tiene que correr dentro del contenedor de `be01` sin instalar nada. Fealdad con motivo, declarada.
- `set -u` sí, `set -e` **no**: con `-e`, el primer fallo mataría el guion y perderías el resto del diagnóstico. Quieres el informe completo, no el primer error.

> **Prueba de fuego.** Con el mock arriba, `chmod +x smoke.sh && ./smoke.sh` → todo en verde, `echo $?` da `0`. Ahora, sin tocar el guion, levanta el mock con `CHAOS=fail=500@100 npm run mock` y vuelve a correrlo: **todo en rojo**, `echo $?` da `1`. Apágalo y prueba `CHAOS=malformed npm run mock`: los códigos de estado siguen en `200` y en verde, y lo que se cae es la familia de afirmaciones de forma —"es un arreglo"—. Esa asimetría entre las dos corridas es, en una pantalla, la lección entera de la Fase 4 vista desde el servidor: **el status miente antes que el cuerpo, y el cuerpo miente sin que el status se entere**.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Síntoma: `CONTRACT.md` documenta endpoints y parámetros que nadie llama.**
Causa: se auditó leyendo `mock-server/server.js` y el README de json-server en vez de mirando la captura. Fix mínimo: para cada fila de la tabla, busca la petición correspondiente en el `.har`. La que no aparece, se borra o se mueve a régimen de crecimiento con una nota de "soportado, no consumido".

**Síntoma: la captura no tiene peticiones de órdenes ni de muestras.**
Causa: no se navegó a `/orders` y `/samples`, que son módulos de carga diferida. Fix mínimo: repetir la sesión respetando el orden del §5.1. Si te sirve de consuelo: acabas de reproducir, del lado del servidor, el bug que el track base te enseñó del lado del cliente.

**Síntoma: `smoke.sh` pasa contra el mock y nadie sabe si eso significa algo.**
Causa: el guion afirma cosas triviales —que un `200` es un `200`— y ninguna afirmación de forma. Fix mínimo: por cada endpoint, al menos una afirmación de **forma** además de la de estado. La pregunta de control es: *"¿qué escribiría yo en el backend nuevo que pasara esta prueba y aun así rompiera la pantalla?"*. Si se te ocurre algo, falta una afirmación.

**Síntoma: al reproducir una petición con `curl` sale un `401` que en el navegador no sale.**
Causa: pasaron más de 120 segundos desde el login y estás mandando un token vencido. Fix mínimo: volver a pedir token. Y anota el detalle en `CONTRACT.md`, porque revela algo del contrato de hoy: **si el `401` te llega, no viene del endpoint de datos** —que no valida nada—, viene del login o del caos.

### Pieza forense de esta fase

Dos peticiones que jurarías que son la misma. No lo son, y aprender a ver la diferencia es lo único que separa una auditoría de contrato de una lista de deseos.

Esta fase **no tiene archivo `forense-fase-NN.md`**, y es una divergencia declarada del track base: la pieza forense del track BE es una captura, una agregación o un log de servidor, y cabe aquí, junto al código que la produce ([guía de estilo §16.2](./prompts/guia-de-estilo-y-convenciones.md)).

**Par 1 — dos `POST` con contratos de identidad opuestos.**

Busca en tu HAR el `POST /patients` del paso 4 y el `POST /auditLog` del paso 9. En la lista de Network son gemelos: mismo método, mismo tipo de cuerpo, misma respuesta `201`. Ahora abre los dos cuerpos de petición y compáralos campo por campo:

- `POST /patients` va **sin** `id`. El servidor asigna un entero, `max + 1`, y lo devuelve dentro del objeto creado.
- `POST /auditLog` va **con** `id`, una **cadena** que generó el navegador antes de salir, y el servidor la respeta tal cual.

Las preguntas que hay que contestar por escrito, en `CONTRACT.md`:

1. ¿Qué pasa si dos pestañas del navegador escriben un asiento en el mismo milisegundo? (Pista: mira `generateId()` en `audit.effects.ts` y decide si eso es un identificador o una esperanza.)
2. En `be03`, cuando el `id` de las cinco colecciones tenga que seguir siendo un entero mientras `auditLog` acepta una cadena ajena, ¿cuántas estrategias de identidad necesitas? ¿Una con excepciones, o dos?
3. Si el backend nuevo **rechazara** el `id` que manda el cliente y asignara el suyo, ¿qué se rompería exactamente en pantalla? Búscalo en el código del frontend antes de contestar.

**Par 2 — la misma petición, una o dos entradas en Network.**

Manda estas dos desde la consola del navegador, con la aplicación abierta en el 4200:

```javascript
// Petición A — GET simple, sin cabeceras personalizadas.
fetch('http://localhost:3000/patients');

// Petición B — la misma URL, con una cabecera personalizada.
fetch('http://localhost:3000/patients', { headers: { 'X-Chaos': 'latency=1' } });
```

En Network, A produce **una** entrada. B produce **dos**: un `OPTIONS` que responde `204` y luego el `GET`. Es el preflight de CORS, que se dispara por la cabecera personalizada y no por la URL.

Eso, que en el track base era una curiosidad, aquí es una cláusula del contrato con dos consecuencias que van escritas:

- **`be01` tiene que responder el `OPTIONS`**, y responderlo **antes** del inyector de caos. Si el preflight atraviesa un caos con `latency=3000`, cada petición con cabecera personalizada tarda el doble y el síntoma es imposible de explicar. El mock ya resuelve esto cortando el `OPTIONS` en el primer middleware; búscalo y anota por qué está donde está.
- **`X-Chaos` tiene que seguir en `Access-Control-Allow-Headers`.** Si se cae de esa lista, el navegador rechaza toda petición con caos por cabecera y el mensaje de error habla de CORS, no de tu cabecera. Un día entero perdido, garantizado.

🧨 **Rompe a propósito.** Comenta las tres líneas de `res.header(...)` del primer middleware del mock, reinicia y recarga la aplicación. Anota tres cosas: qué dice exactamente la consola del navegador, qué muestra la pestaña Network para esa petición, y qué **no** aparece en el log del servidor. La tercera es la interesante — el servidor respondió perfectamente y no tiene forma de saber que su respuesta se tiró a la basura. Esa asimetría es la razón de que el modo `nocors` exista.

---

## 🧪 7. Ejercicios (26)

**🟢 Fácil (1–7)**

1. Corre la sesión de captura completa del §5.1 y exporta el HAR. Cuenta cuántas peticiones únicas —método + ruta sin parámetros— salieron. Anota el número: es el tamaño real de tu contrato.
2. Con el segundo comando `jq` del §5.2, lista los parámetros de consulta que la aplicación emite. Confirma que son exactamente cuatro y nómbralos.
3. Pide `GET /referenceRanges` con `curl` y cuenta los documentos. Explica en una línea por qué el frontend no manda ningún filtro aunque solo le interese un analito.
4. Escribe la tabla de `CONTRACT.md` para `/samples` mirando solo la captura. Después ábrela contra `07-muestras-custodia.md` §5 y anota las diferencias.
5. Haz `curl -i http://localhost:3000/patients/999999` y copia el cuerpo exacto de la respuesta. Compáralo con lo que devuelve `curl -i http://localhost:3000/noexiste`.
6. Autentícate con `curl` contra `POST /login` y guarda el token. Decodifica el payload en jwt.io y anota los tres claims y el `exp`.
7. Corre `./smoke.sh` con el mock arriba y confirma que termina en verde y con `echo $?` igual a `0`.

**🟡 Intermedio (8–15)**

8. Añade a `smoke.sh` una afirmación de que `GET /orders?patientId=1` devuelve **solo** órdenes de ese paciente. Pista: no necesitas `jq`; te basta con negar la presencia de otro `patientId` en el cuerpo.
9. Documenta la sección `/auditLog` de `CONTRACT.md` incluyendo la forma completa del asiento y el hecho de que `before` es siempre `null`. Explica por qué siempre es `null` citando la fase que lo produce.
10. Mide con `curl -w '%{time_total}'` cuánto tarda `GET /auditLog` con la bitácora vacía y después de generar treinta asientos usando la aplicación. Extrapola a seis años de operación y escribe el número en `CONTRACT.md`.
11. Levanta el mock con `CHAOS=latency=2000` y confirma con `curl -w` que **todas** las respuestas tardan eso, incluido `POST /login`. Explica por qué el login no es inmune, citando la decisión de la Fase 4 §5.3.
12. Con `CHAOS=fail=500@100` arrancado, manda una petición con `X-Chaos: latency=1`. Anota si falla o no, y escribe la regla de precedencia que acabas de comprobar.
13. Escribe la sección de régimen de crecimiento de `CONTRACT.md` y demuestra una de sus afirmaciones: añade a mano un campo `nickname` a un paciente en `db.json`, reinicia el mock, y confirma que la pantalla no cambia ni se rompe.
14. **Diagnóstico.** Un compañero dice que `/patients?documentId=cc-1032456789` "no funciona". Reprodúcelo, di exactamente qué devuelve, y decide si es un bug del contrato o una asunción del cliente. Escribe la línea que corresponda en `CONTRACT.md`.
15. **Diagnóstico.** En la captura hay más peticiones a `/auditLog` de las que esperabas. Localiza qué componente las emite y en qué momento de su ciclo de vida, y explica por qué navegar tres veces a la timeline produce tres peticiones idénticas.

**🟠 Difícil (16–22)**

16. **Diagnóstico.** Ejecuta el par 2 de la pieza forense y explica por qué el `OPTIONS` no aparece en el log del mock con el mismo formato que las demás peticiones. Sigue el rastro hasta la línea que lo corta y justifica si está bien puesta.
17. **Diagnóstico.** Quita `X-Chaos` de `Access-Control-Allow-Headers`, reinicia y manda la petición B del par 2. Anota el mensaje exacto del navegador, y explica por qué ese mensaje apunta al lugar equivocado.
18. Escribe una afirmación en `smoke.sh` que verifique que un `PATCH /samples/:id` devuelve el documento **completo** y no solo los campos cambiados. Después modifica el mock para que devuelva solo el delta y confirma que tu afirmación se pone roja.
19. **Diagnóstico.** Con `CHAOS=malformed`, corre `smoke.sh` y clasifica cada fallo en dos grupos: los que se caen por forma y los que siguen en verde por estado. Explica qué te dice esa partición sobre la calidad de tu guion.
20. Escribe en `CONTRACT.md` la cláusula de identidad de `/auditLog` y contesta por escrito las tres preguntas del par 1 de la pieza forense, cada una con la referencia al archivo del frontend que la sostiene.
21. **Diagnóstico.** Manda `POST /patients` con un `id` explícito de `9999` en el cuerpo. Anota qué hace el mock, y decide si ese comportamiento entra en el régimen estricto o no. Justifica con el criterio de "¿lo consume alguien?".
22. **Diagnóstico.** Levanta el mock con `CHAOS=timeout` y corre `smoke.sh`. Explica por qué el guion se queda colgado en vez de fallar, y arréglalo con un `--max-time` en `curl` que produzca un fallo diagnosticable. Anota qué valor elegiste y por qué ese número y no otro.

**🔴 Muy difícil (23–26)**

23. **Diagnóstico + diseño.** Escribe un segundo guion, `contract-diff.sh`, que corra `smoke.sh` contra dos URLs base distintas y compare las salidas línea por línea. No tiene contra qué correr todavía —el segundo servidor nace en `be01`—, y ese es el punto: escríbelo hoy, contra dos instancias del mismo mock en puertos distintos, y déjalo listo. Documenta qué diferencias tolera y cuáles no.
24. **Diagnóstico.** Reconstruye, solo desde el HAR y sin abrir el código del frontend, la secuencia exacta de peticiones que dispara validar un resultado. Dibuja el orden, di cuáles son secuenciales y cuáles concurrentes, y señala cuál de ellas puede fallar dejando el sistema inconsistente. Esa petición es el material de `be04`.
25. **Adversarial.** Escribe un servidor falso de veinte líneas en Express que **pase entero** tu `smoke.sh` y sirva datos completamente inventados a la aplicación. Levántalo en el 3000 con el mock apagado y mira la aplicación. Después responde: ¿cuántas afirmaciones nuevas necesita tu guion para que ese impostor no pase? Añádelas. Este ejercicio mide la calidad de tu contrato mejor que ningún otro de la fase.
26. **Adversarial y de escritura.** Argumenta por escrito, en una página, la posición contraria a la de esta fase: *"auditar el contrato es trabajo desperdiciado; el backend nuevo debería devolver JSON limpio y bien diseñado, y el frontend adaptarse"*. Hazlo bien, con sus mejores razones. Después refútalo con el costo real, en horas y en riesgo, de tocar los siete slices de NgRx, los effects, los servicios y las plantillas de un sistema sin una sola prueba. Esa página es el borrador del documento que vas a firmar en `be08`.

**🔥 Opcionales**

- 🔥 Convierte `CONTRACT.md` en un `openapi.yaml` de verdad, con las siete rutas y sus esquemas. Después contesta si valió la pena, y si la respuesta cambiaría en un sistema con veinte años por delante en vez de dos.
- 🔥 Escribe un middleware de Express de veinte líneas que valide `Authorization` en todas las rutas de datos. Enchúfalo, usa la aplicación durante tres minutos sin recargar, y anota exactamente qué pasa. Guarda ese experimento: es el punto de partida de la conversación de `be04`.
- 🔥 Genera la captura del §5.1 en Firefox además de en Chrome y compara los dos HAR. Anota qué cabeceras difieren y decide si alguna de esas diferencias entra en el contrato.

---

## 📚 8. Referencias

**Documentación oficial**

- json-server 0.16.3 — README de la versión exacta que corre en tu proyecto: https://github.com/typicode/json-server/tree/v0.16.3 ⚠️ La rama 1.x, que aparece primero en las búsquedas, cambió el comportamiento por defecto de varias rutas.
- HTTP Archive (HAR) 1.2 — especificación del formato que exporta DevTools: http://www.softwareishard.com/blog/har-12-spec/
- Chrome DevTools — referencia de la pestaña Network, incluida la exportación de HAR: https://developer.chrome.com/docs/devtools/network/reference
- MDN — CORS y peticiones con preflight, que es la mitad de la pieza forense: https://developer.mozilla.org/es/docs/Web/HTTP/CORS
- RFC 7231 §6 — semántica de los códigos de estado, para decidir qué promete cada número: https://www.rfc-editor.org/rfc/rfc7231#section-6
- `jq` — manual del filtro que convierte el HAR en una tabla: https://jqlang.github.io/jq/manual/
- `curl` — página de manual de `-w` y sus variables (`%{http_code}`, `%{time_total}`): https://curl.se/docs/manpage.html

**Libros y artículos de referencia**

- Martin Fowler, *TolerantReader*: https://martinfowler.com/bliki/TolerantReader.html — el nombre del patrón que el frontend de LabCore cumple por accidente y que hace posible el régimen de crecimiento.
- Sam Newman, *Building Microservices* (2ª ed., 2021), capítulo 5 — contratos, esquemas y compatibilidad. Lo útil aquí es la distinción entre cambios compatibles e incompatibles; el resto es de sistemas distribuidos y no aplica a un monolito.
- Michael Feathers, *Working Effectively with Legacy Code* (2004), capítulos 6 y 13 — las *characterization tests*, que es exactamente lo que es `smoke.sh`: una prueba que no dice si el sistema está bien, sino qué hace hoy.

**Video y apoyo**

- Charlas sobre *consumer-driven contract testing* y Pact (2018-2021): https://www.youtube.com/results?search_query=consumer+driven+contract+testing — ⚠️ útiles para el concepto, no para la herramienta: Pact necesita cooperación de los dos lados, y aquí uno de los dos lados no se toca.

**Orden de lectura sugerido:** el README de json-server 0.16.3 **antes** de capturar, para saber qué mirar → *TolerantReader* mientras escribes la partición de regímenes → Feathers cap. 6 después de tener `smoke.sh`, que es cuando su argumento se entiende de verdad → el RFC 7231, solo como consulta puntual cuando dudes de un código de estado.

> ⚠️ URLs, títulos y contenidos cambian o desaparecen; verifícalos. Y desconfía por defecto de todo lo publicado después de 2023 sobre json-server o sobre CORS: va a describir versiones y navegadores que no son los tuyos.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Terminas esta fase sin haber escrito una línea de Java y con las dos cosas que hacen posible el resto del track: un documento que dice qué promete el sistema, y un guion que lo comprueba en diez segundos.

El orden importa y conviene decirlo en voz alta. Podrías haber empezado por `be01`, levantando Spring y viendo el primer `GET /health` responder; se siente más productivo. El problema es que sin contrato no hay criterio: `be03` habría terminado con un backend que funciona perfectamente y una aplicación en blanco, y la discusión habría sido de opiniones. Ahora es de `smoke.sh`.

**be01** levanta el monolito de 2019 —`pom.xml`, capas, filtros, apagado ordenado— y lo deja respondiendo en el puerto 3000 con el inyector de caos reimplementado con paridad exacta contra la matriz que acabas de escribir. Sin base de datos todavía: datos fijos. La prueba de que salió bien es del track base, no del track BE: tienes que poder repetir el ejercicio 3 de la Fase 4 —`CHAOS=latency=3000`, spinner de tres segundos medido en Network— contra el servidor nuevo.

> **La señal de que quedó bien:** *"puedo contestar qué promete este sistema sin abrir el código del servidor, y tengo un guion que me lo confirma en diez segundos contra cualquier cosa que se ponga en el puerto 3000."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en verde y `git status` limpio:
>
> ```bash
> git tag -a be-fase-00-el-contrato-auditoria-del-mock -m "be00 cerrada: HAR capturado; CONTRACT.md con 7 recursos, matriz de caos y particion de regimenes; smoke.sh en verde con 12+ afirmaciones; pieza forense de los dos pares documentada"
> ```
>
> Los commits de la fase llevan su prefijo (`be00: …`) y los de ejercicio su número (`be00 ej17: …`). El track BE usa el namespace `be-fase-*` para que `git tag -l 'fase-*'` siga siendo el índice limpio del track base. Todo eso está en [`00-convencion-de-git-y-tags.md`](./00-convencion-de-git-y-tags.md) §10.

---

## 📌 Pendientes sugeridos

- **[A] El formato de `CONTRACT.md` queda cerrado aquí** —tabla por recurso, forma observada, notas, matriz de caos, partición de regímenes— y `be01` a `be08` lo extienden sin reabrirlo. Si una fase necesita una sección nueva, la añade al final y lo declara.
- **[B] `smoke.sh` va a crecer en cada fase y hay que vigilar que no se convierta en una suite de integración.** Criterio propuesto: si una afirmación necesita estado previo que el frontend no crea, no va aquí. Se revisa en `be08`, cuando se decida la estrategia de pruebas de verdad.
- **[C] La basura que `smoke.sh` deja en `/auditLog`** está declarada en §5.6 y no se limpia hoy porque el `DELETE` no está en el contrato. Destino: `be08`, junto con la decisión de Testcontainers contra `mongo:4.0` del compose.
- **[D] La cláusula "el servidor no verifica el token"** es la que más presión va a recibir. Nadie la toca antes de `be04`, y `be04` no la "arregla": la mide y decide con el frontend intacto como restricción.
- **[E] La colección `custodyLinks` no existe** en el sistema de hoy: la custodia vive embebida en el documento de la muestra y el componente de la Fase 7 la reconstruye con `custodyEvents()`. La colección aparte es una **propuesta de `be05`**, no un hallazgo de esta auditoría. Que `CONTRACT.md` no la mencione es correcto.
- **[F] El apéndice `bea-02`** (receta de imagen y compose) tiene que existir antes de que `be01` mande a alguien allí. Si `be01` se escribe primero, deja el enlace y ábrelo como deuda declarada.

### Reservas para el cuaderno de incidentes

**Ninguna.** Esta fase no reserva ningún ID de `cuaderno-incidentes-be.md`, y es deliberado: un incidente necesita un sistema que se pueda romper, y aquí todavía no hay servidor propio. El primer ID, `be-01`, lo reserva `be01`. Los IDs del track BE son independientes de los del cuaderno base y nunca se reasignan.
