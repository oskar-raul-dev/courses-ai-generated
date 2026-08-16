# 🕵️ Forense Fase 04 — "A veces no carga" y el `200` que miente

> Pieza forense de la [**Fase 4 — Mock API + caos**](./04-mock-api-caos.md) · Recorrido: ~45 min · [Índice del track](./forense-master.md)
> Herramientas: el log de acciones · Network (status y **cuerpo**) · el log del mock · los seis modos del caos
> Síntoma que cubre: seis fallos distintos que llegan al usuario como la misma frase.

Un `500` en Network es un dato que se pierde cuando cierras la pestaña. `[Patients] Load Patients Failure` con su carga útil es un dato que **queda**, ordenado respecto de todo lo demás que pasó. Esta pieza es el recorrido que convierte una frase de usuario en uno de seis diagnósticos con nombre, y el orden de descarte —**pantalla, store, red**— es toda la lección.

---

## 🎫 El ticket

> *"La pantalla de pacientes a veces no carga. Y a veces carga pero sale vacía, como si no hubiera nadie registrado. No sé si es lo mismo o son dos cosas."*

**Reportado por:** una auxiliar de recepción
**Ambiente:** UAT

La última frase del ticket es la buena. **No, no es lo mismo**, y distinguirlo es el trabajo. Un fallo de red y un cuerpo malformado producen pantallas casi idénticas y no comparten ni una sola línea de causa.

---

## 🧭 La ruta

Cinco pasos, del más barato al más caro: la pantalla cuesta cero, el log de acciones cuesta diez segundos, el cuerpo de la respuesta cuesta un minuto, y el log del servidor cuesta cambiarse de ventana. Ninguno abre un archivo del proyecto.

### Paso 1 — ¿Qué de los cuatro estados está pintando la pantalla?

Cargando, error, vacío y con datos son cuatro estados, y esta pantalla sabe pintar los cuatro desde esta fase. Mira cuál te está mostrando, literalmente:

```
Pacientes
No hay pacientes registrados.        ← estado "vacio"
```

o bien

```
Pacientes
No se pudo cargar la lista.          ← estado "error"
HTTP_500
[ Reintentar ]
```

**Qué descarta.** Muchísimo, y gratis. Si ves el **error con su código**, el fallo fue admitido: alguien lo convirtió en acción y sabes ya de qué familia es (paso 3). Si ves el **vacío**, la aplicación cree que todo salió bien, y ahí es donde empieza la investigación cara (paso 2). Y si ves el **spinner para siempre**, no hay ni éxito ni fallo: nadie contestó nunca, que es el modo `timeout` visto desde la pantalla.

> ⚠️ Antes de seguir, una pregunta de treinta segundos que ahorra tardes enteras: **¿qué tenías tú encendido?** El caos se configura por variable de entorno o por header y no hay panel que lo muestre. Más de un "bug" de esta fase es un `CHAOS=` que alguien dejó puesto hace una hora. El paso 5 lo comprueba.

### Paso 2 — El log de acciones: ¿el store cree que salió bien?

Redux DevTools → **Actions**, con la lista vacía en pantalla:

```
[Patients] Load Patients
[Patients] Load Patients Success
```

**Qué descarta.** Un `Success` con la pantalla vacía es el hallazgo más incómodo del curso: **el store cree que la carga salió bien**. Muere la hipótesis de red, muere la de servidor caído, muere la de token vencido — todas habrían producido un `Failure`. Lo que queda es que la respuesta llegó con un `200` y con la forma equivocada, y eso sólo se ve en el cuerpo. Paso 3.

Selecciona esa acción y mira su carga útil, que es donde está la prueba:

```json
{
  "patients": {
    "data": { "items": "no-soy-un-arreglo" },
    "total": null
  }
}
```

Un objeto donde el estado espera un arreglo. `patients.length` es `undefined`, el `*ngIf` del vacío lo trata como falso, y la pantalla dice con toda tranquilidad que no hay pacientes registrados.

Si en cambio ves `[Patients] Load Patients Failure`, salta al paso 4: el fallo está admitido y tiene nombre.

### Paso 3 — El cuerpo, que es la única capa que no interpreta

Network → filtro `XHR` → la petición a `/patients` → pestaña **Response**. No **Preview**, que ya interpreta; **Response**, que es el texto tal cual llegó:

```
Name        Status  Type  Size    Time
patients    200     xhr   64 B    22 ms
```

```json
{"data":{"items":"no-soy-un-arreglo"},"total":null}
```

**Qué descarta.** Con eso el diagnóstico está cerrado y es del servidor, no del cliente: `200 OK` con la forma equivocada. Ni el interceptor, ni el effect, ni el reducer hicieron nada mal — cada uno hizo exactamente lo que le pidieron con lo que le llegó.

**Y acá está la lección de la fase, dicha entera:** la pantalla te mintió diciendo que no hay pacientes; el store te mintió diciendo que la carga salió bien; el `200` verde te mintió diciendo que todo estaba en orden. La única capa que no miente es el cuerpo, y llegar hasta ella exige haber descartado antes las otras tres, en ese orden y con esa desconfianza.

> 🧭 **Compáralo con `CHAOS=fail=500@100`**, que produce el mismo ticket y se diagnostica en dos minutos: ahí el store dice `Failure`, la pantalla dice el código y todo el mundo dice la verdad. La diferencia entre dos minutos y dos horas no es la gravedad del fallo: es que el servidor tuvo la decencia de admitir que falló.

### Paso 4 — Si hubo `Failure`: cuál de los cuatro códigos

El effect normaliza cualquier fallo a un objeto de tres campos antes de despacharlo. Ese objeto **es** el diagnóstico, y se lee en la carga útil de la acción:

```json
{ "error": { "code": "HTTP_500", "status": 500, "messageKey": "errors.loadFailed" } }
```

**Qué descarta.** Cada código apunta a una investigación distinta y las cuatro son excluyentes:

| Lo que dice el objeto | Qué pasó de verdad | Y entonces |
|---|---|---|
| `HTTP_500` / `status: 500` | el servidor contestó y admitió el fallo | mira el log del mock: hay una línea |
| `NETWORK` / `status: 0` | la petición **nunca llegó** a un servidor | puerto, servidor caído o CORS — indistinguibles desde acá |
| `TIMEOUT` / `status: 0` | el cliente se cansó; el servidor sigue tan tranquilo | el corte lo dio `timeout(REQUEST_TIMEOUT_MS)`, no la red |
| `UNAUTHORIZED` / `status: 401` | token vencido o ausente | el interceptor ya te devolvió al login — Fase 3 |

Dos observaciones que valen el paso entero. La primera: `NETWORK` y `TIMEOUT` comparten `status: 0` y son cosas opuestas —una es "nadie contestó", la otra es "yo dejé de esperar"—; lo que las separa es el `code`, y por eso el effect lo normaliza. La segunda: `status: 0` **es indistinguible** entre servidor caído, puerto equivocado y CORS bloqueando. Ninguna herramienta del navegador te lo va a decir, por diseño del propio navegador. Para separarlos hay que salir del navegador, que es el paso 5.

### Paso 5 — El log del mock: ¿el servidor se enteró?

Cámbiate a la terminal donde corre el mock. Imprime una línea por petición, y trae el modo de caos activo:

```
[mock] escuchando en http://localhost:3000
[mock] caos global activo: malformed
[mock] GET /patients | chaos: malformed
```

**Qué descarta.** Esta salida cierra dos preguntas de un golpe:

- **Hay línea de la petición** → el servidor la vio. Si el cliente reportó `status: 0`, el problema está en el viaje de vuelta: casi siempre CORS. La respuesta salió bien formada y el navegador la descartó, que es exactamente lo que hace confuso al modo `nocors`.
- **No hay línea** → la petición nunca llegó. Puerto equivocado, proceso caído, o un preflight `OPTIONS` rechazado antes.
- **La línea dice `chaos: <algo>`** → el "bug" lo encendiste tú. Pasa más de lo que nadie admite, y es la razón por la que este paso existe.

Con `CHAOS=timeout` verás la línea de la petición y **ninguna respuesta jamás**: el middleware hace `return` sin responder y sin llamar a `next()`, y el socket se queda abierto. Del lado del servidor no queda constancia de que esa petición terminara nunca; del lado del cliente, el único que corta es el operador `timeout` del effect. Si ese operador no estuviera, el spinner giraría hasta que alguien cierre la pestaña — y no habría ni una sola acción en el store.

---

## 🩺 Diagnóstico por síntoma

Los seis modos y su firma. Es la tabla que se consulta seis meses después, cuando ya no recuerdas nada de esta fase.

| Lo que ves | Modo | Firma que lo identifica |
|---|---|---|
| Error con código `HTTP_500` y botón de reintentar | `fail=500@100` | `500` rojo en Network, y línea en el log del mock |
| A veces sí y a veces no, mismo click | `fail=500@30` | el porcentaje: reintenta diez veces y cuenta |
| Lista vacía, cero errores, `Success` en el log | `malformed` | `200` con el cuerpo con otra forma |
| Spinner eterno, ninguna acción nueva | `timeout` | petición en `pending`, sin respuesta, para siempre |
| Corte limpio a los diez segundos exactos | `timeout` + el operador | `code: TIMEOUT`, y el número está en una constante |
| Vuelta al login sin explicación | `expired` | `401` y el interceptor de la Fase 3 haciendo su trabajo |
| `(failed)` sin status, consola hablando de CORS | `nocors` | **hay línea en el log del mock**: el servidor sí contestó |
| `(failed)` sin status, sin línea en el log del mock | servidor caído o puerto equivocado | ninguna herramienta del navegador los distingue |
| Enciendes un modo y no pasa nada | orden del middleware, o modo mal escrito | el log imprime `chaos: …`, así que el modo se leyó |
| El modo se ignora sin avisar | `latencia=2000` en vez de `latency=2000` | `parseChaos` ignora lo desconocido en silencio |
| Sólo fallan las peticiones con `Authorization` | preflight | un `GET` simple no dispara `OPTIONS`; uno con header sí |

---

## ⚰️ Los callejones

**"El reducer está mal, porque el estado queda mal."** Es la hipótesis más razonable y más equivocada del recorrido. Con `malformed`, el reducer guardó **exactamente** lo que le pidieron: `items: action.patients`, y `action.patients` era ese objeto. Un reducer es una función pura: no puede validar lo que no sabe que existe. El argumento de dos líneas que convence a un compañero es éste, y es el ejercicio 20 de la fase.

**"Hay que meter un `catchError` mejor."** `catchError` no se ejecutó porque **no hubo error**: hubo un `200`. Ningún operador de RxJS va a detectar que el cuerpo tiene la forma equivocada, porque para RxJS un objeto es un valor perfectamente válido. Lo que faltaría es una validación de forma antes de despachar el éxito —y eso es lo que un tipo real y `strict` harían gratis, que es la tesis del ejercicio 🔥 de la fase.

**"Es CORS."** Se dice mucho y casi nunca se comprueba. El log del mock lo resuelve: si el servidor imprimió la línea, la petición salió, llegó y volvió — y lo que la descartó fue el navegador, del lado del cliente. Si no imprimió nada, no es CORS: es que nadie estaba escuchando.

**"El servidor se cayó a los diez segundos."** Un corte exacto y repetible en un número redondo no es un servidor: es una constante. `REQUEST_TIMEOUT_MS` está escrito a mano en el effect. Cuando alguien reporte "se cae siempre a los N segundos", busca el número en el código antes que en la infraestructura.

---

## 🧨 Deshacer

Nada de este recorrido toca el código del proyecto, y aun así deja dos cosas encendidas:

```bash
# 1. El caos global. Es lo que más veces se olvida puesto.
#    Para el mock (Ctrl+C) y arrancalo sin la variable:
npm run mock

# 2. El header X-Chaos, si lo mandaste desde la consola del navegador,
#    muere con la petición. No hay nada que apagar.
```

Comprueba que quedó limpio por donde se comprueba de verdad: la primera línea del arranque. Si dice `caos global activo: …`, todavía lo tienes puesto.

---

## 🧠 El patrón transferible

> **Desconfía en orden de costo: pantalla, store, red.** La pantalla te cuenta lo que un programador decidió contarte; el store te cuenta lo que el effect creyó entender; el cuerpo de la respuesta no interpreta nada. Descartar en ese orden es lo que separa dos minutos de dos horas, y funciona igual en un sistema que no tenga store: pantalla, capa de aplicación, dato crudo.

Y el segundo, que es el que más se transfiere fuera de este curso: **un `200` no significa que el servidor hizo lo que crees, sólo que contestó.** Cualquier sistema que confíe en el código de estado para decidir si algo salió bien tiene esta clase de bug esperando; y cuando aparece, el semáforo verde es justo lo que impide que alguien mire el cuerpo.

**Incidentes del cuaderno que usan esta ruta:** el **06** —*"la pantalla de pacientes sale vacía y no dice nada"*, que es el `malformed` llegando como ticket— y el **08** —*"a veces no carga"*, que es el intermitente con porcentaje.
**Amplía:** la [**Fase 3**](./03-autenticacion.md) para el `request-id` con el que se correlacionan las dos mitades del viaje, el [**Apéndice A05**](./a05-rxjs.md) para dónde va el operador `timeout` y por qué, y [`forense-fase-05.md`](./forense-fase-05.md) para el uso de `CHAOS=latency` como herramienta de reproducción y no como fallo.
