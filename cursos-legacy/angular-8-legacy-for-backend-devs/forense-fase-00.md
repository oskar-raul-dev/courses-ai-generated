# 🕵️ Forense Fase 00 — "No se pudo registrar el paciente" (y el servidor nunca habló)

> Pieza forense de la [**Fase 0 — Setup + hola mundo**](./00-setup-hola-mundo.md) · Recorrido: ~30 min · [Índice del track](./forense-master.md)
> Herramientas: la consola · la pestaña Network · el log de json-server
> Síntoma que cubre: un mensaje de error que suena a "el servidor dijo que no" y que significa otra cosa.

La primera pieza del track y la que instala el reflejo del que viven las otras catorce: **la pantalla te cuenta lo que un programador decidió contarte**, y esa decisión casi siempre se tomó un día en que nadie pensaba en depurar. El estado real de la petición está en Network; el error original está en la consola. Ir de una cosa a la otra es todo lo que hace esta fase, y es lo que vas a repetir el resto del curso con herramientas más caras.

---

## 🎫 El ticket

> *"Registro un paciente y me dice que no se pudo. Así, sin más. Lo intenté tres veces con los mismos datos."*

**Reportado por:** una auxiliar de recepción
**Ambiente:** desarrollo

Un mensaje genérico, ninguna pista y tres intentos idénticos. Eso último importa: tres intentos con el mismo resultado descartan que sea intermitente, y por lo tanto descartan media docena de causas antes de empezar.

---

## 🧭 La ruta

Cinco pasos. Los tres primeros son la lección entera y cuestan menos de dos minutos juntos: leer la consola, leer una fila de Network, leer una terminal. El código no se abre hasta el paso 4, y en la mayoría de los casos no hace falta abrirlo nunca.

### Paso 1 — Lo que dice la pantalla, y por qué no sirve

```
No se pudo registrar el paciente.
```

Esa frase está escrita a mano en el `subscribe` del componente, en la función de error, y es **la misma para todas las causas posibles**: servidor caído, puerto equivocado, CORS, un `500`, un `404`, un cuerpo rechazado. Seis diagnósticos distintos condensados en una cadena de texto que alguien escribió en cinco segundos.

**Qué descarta.** Nada. Y ése es el punto del paso: reconocer un mensaje que no descarta nada es lo que te impide quedarte mirándolo. Sigue.

### Paso 2 — La consola: el error de verdad

DevTools → **Console**. El componente hace `console.error` con el error completo, y ese objeto es el primer dato real del recorrido.

```
[PatientIntake] fallo el POST
HttpErrorResponse {headers: HttpHeaders, status: 0, statusText: "Unknown Error",
url: "http://localhost:3001/patients", ok: false, …}
```

**Qué descarta.** Dos campos y el diagnóstico ya está encaminado:

- **`status: 0`** → la petición **nunca llegó a un servidor**. Es la firma que vas a reconocer el resto del curso: conexión rechazada, DNS, o CORS bloqueando antes de salir. El servidor no dijo que no; el servidor no dijo nada.
- **`url`** → contra qué se intentó hablar. Léela entera, incluido el puerto. Aquí dice `3001` y el mock escucha en `3000`.

Con un `status` distinto de cero la investigación sería otra: `404` es una ruta que no existe (y ojo con el singular: `/patient` en vez de `/patients`), `500` es un servidor que falló admitiéndolo, `401` es autenticación —y eso todavía no existe en esta fase—.

> ⚠️ **Si la consola está limpia, no celebres.** Significa que nadie escribió el `console.error`, o que el `subscribe` no tiene función de error. Cuando el `subscribe` sólo lleva un callback, el fallo desaparece por completo: la petición falló, la pantalla se quedó esperando, y no hay rastro en ninguna parte. "Se queda cargando" es casi siempre eso.

### Paso 3 — Network: la fila, y las dos columnas que importan

DevTools → **Network** → filtro `XHR` → repite el envío.

```
Name       Status    Type  Size  Time
patients   (failed)  xhr   0 B   3 ms
```

`(failed)` sin número, no un código de error. **Qué descarta.** Confirma el `status: 0` desde la otra herramienta y añade lo que la consola no da: el tiempo. Tres milisegundos significa **rechazo inmediato**, no espera: nadie escuchaba en ese puerto. Un fallo por timeout tardaría segundos; uno por CORS tendría además una fila `OPTIONS` y un mensaje explícito en la consola nombrando la política.

Abre la petición y mira **Headers → General**:

```
Request URL: http://localhost:3001/patients
Request Method: POST
Status Code: (failed) net::ERR_CONNECTION_REFUSED
```

Con `ERR_CONNECTION_REFUSED` el diagnóstico está cerrado del lado del navegador: la máquina contestó "acá no hay nadie". Queda comprobarlo del otro lado.

### Paso 4 — El log de json-server: ¿el servidor se enteró?

Cámbiate a la terminal donde corre el mock. json-server imprime sus rutas al arrancar y una línea por petición atendida:

```
  Resources
  http://localhost:3000/patients

  Home
  http://localhost:3000
```

**Qué descarta.** Compara ese puerto con la URL del paso 2 y el caso queda cerrado: **la aplicación habla al 3001 y el servidor escucha en el 3000**. Y si el puerto coincidiera pero no apareciera ninguna línea de la petición, el diagnóstico sería otro y también quedaría cerrado: la petición no llegó, y con el puerto correcto eso apunta a CORS o a un proceso que no es el que crees.

Este paso es el que separa "el navegador dice que falló" de "el servidor no lo vio", y es el mismo movimiento que la Fase 4 formaliza con el `request-id`: **un viaje HTTP tiene dos mitades y cada una tiene su propio testigo.**

### Paso 5 — Dónde está escrita esa URL

Sólo ahora se abre un archivo:

```bash
grep -rn "localhost:300" src/
# src/app/patient-intake/patient-intake.component.ts:41:    this.http.post('http://localhost:3001/patients', this.patient)
```

**Qué descarta.** Una sola línea de salida, y con ella la ruta termina: la URL está escrita a mano dentro del componente. El fix es cambiar el puerto; el hallazgo de verdad es **por qué eso pudo pasar**, que es que la dirección del backend vive en el componente y no en un solo sitio.

Esa deuda tiene fecha de pago escrita: la Fase 1 la mueve a `environment.ts`, y la Fase 13 la saca de ahí porque `environment` se hornea en tiempo de compilación y no se puede cambiar sin recompilar. Esta línea de `grep` es el primer eslabón de la tesis del curso.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Qué significa | Dónde miras |
|---|---|---|
| `status: 0` y `(failed)` en 3 ms | nadie escuchaba: puerto o proceso caído | la `url` del error, con su puerto |
| `status: 0` y un mensaje de CORS en consola | el servidor contestó y el navegador lo descartó | si hay línea en el log del mock: la hay |
| `status: 0` tras varios segundos | no hubo respuesta: red o servidor colgado | la columna Time de Network |
| `404` sobre `/patient` | la colección va en plural | la URL, letra por letra |
| `404` con la URL correcta | el mock no tiene esa colección en `db.json` | las rutas que json-server imprime al arrancar |
| `201` y `db.json` sin cambios | estás mirando otro archivo o otra instancia | el `--watch` con el que arrancaste el mock |
| "Paciente registrado con id undefined" | respondió algo que no tiene `id` | el cuerpo de la respuesta, no la pantalla |
| La consola limpia y la pantalla congelada | `subscribe` sin callback de error | el segundo argumento del `subscribe` |
| `ERR_OSSL_EVP_UNSUPPORTED` al arrancar | Node 17 o superior con el Webpack del CLI 8 | `node -v`, y [**A03**](./a03-node-npm.md) |
| El `<input matInput>` se ve como un input pelado | falta el módulo de esa directiva | los `imports` del `AppModule` |
| Los botones cambiaron de tamaño al instalar Bootstrap | Reboot redefinió `box-sizing` y `line-height` | el inspector: la regla y su archivo de origen |

---

## ⚰️ Los callejones

**"El servidor rechazó los datos."** Es lo que sugiere el mensaje de la pantalla, y es falso en cuanto ves `status: 0`. Un rechazo de datos es un `400` con un cuerpo que explica qué está mal. Ningún servidor rechaza nada guardando silencio; el silencio significa que no hubo servidor.

**"Es CORS."** Se dice mucho porque es la respuesta que siempre cabe. Se descarta o se confirma en diez segundos: CORS produce un mensaje explícito en la consola nombrando la política y el origen, y deja **línea en el log del servidor**, porque la petición llegó y volvió. Un `ERR_CONNECTION_REFUSED` no deja línea en ninguna parte.

**"Hay que ponerle un try/catch."** Un error de red en `HttpClient` no lanza una excepción síncrona: emite por el canal de error del observable. Un `try/catch` alrededor del `.post()` no atrapa absolutamente nada y sólo añade ruido — y peor, deja la impresión de que el caso está cubierto.

**"El formulario está mandando mal los datos."** Comprobable en un vistazo, y por eso conviene tumbarlo pronto: **Network → la petición → Payload**. Si el cuerpo está bien formado y el status es `0`, el formulario está fuera de la discusión. Si ni siquiera hay petición en Network, entonces sí es del lado del cliente — y casi siempre es la validación del propio componente, que corta antes con "Documento y nombre son obligatorios".

---

## 🧨 Deshacer

Si cambiaste la URL a un puerto muerto para reproducir el síntoma —que es el 🧨 de la fase—, devuélvela:

```bash
git checkout -- src/app/patient-intake/patient-intake.component.ts
```

Y comprueba que quedó bien por donde se comprueba de verdad, que no es el editor: envía el formulario y confirma un `201` en Network más una línea nueva en `db.json`. Si tocaste el archivo de datos probando, la Fase 5 traerá un `npm run seed`; en esta fase todavía se arregla a mano, y conviene mirarlo antes de que el desorden crezca.

---

## 🧠 El patrón transferible

> **La pantalla te cuenta lo que alguien decidió contarte; Network te cuenta lo que pasó.** Un mensaje de interfaz es una traducción escrita con prisa, y traduce seis causas distintas a la misma frase. El primer movimiento ante cualquier "no se pudo" no es leer código: es abrir la consola y Network y averiguar cuál de las seis fue.

Y el segundo, que es el que más lejos llega: **`status: 0` significa que el servidor nunca habló.** No que dijo que no. Distinguir "me rechazaron" de "no llegué" reordena la investigación entera —una mira el servidor, la otra mira la red, el puerto y el navegador— y es el reflejo que en la Fase 4 te va a dejar separar seis modos de fallo que llegan al usuario como la misma frase.

**Incidentes del cuaderno que usan esta ruta:** el **01** —*"guardé el paciente y la pantalla dice que no se pudo"*— y el **02** —*"en la máquina de al lado funciona y en la mía no"*—, que son esta misma ruta con la causa un poco más escondida.
**Amplía:** el [**Apéndice A03**](./a03-node-npm.md) para las versiones de Node y el error de OpenSSL, y [`forense-fase-04.md`](./forense-fase-04.md) para cuando el servidor sí conteste y el que mienta sea el `200`.
