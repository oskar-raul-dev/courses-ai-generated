# 📴 Miniproyecto 09 · Offline-first — Cumbre Roja

> **Familia:** offline-first · **Motor:** CouchDB + PouchDB · **Línea base:** no hay rival
> relacional honesto
> **Cierra:** el minicurso de offline-first (Fases 19–20) · **Empresa:** ☕ Cumbre Roja
> **Estado:** opcional · **No entra a la bitácora de medición**

---

## 🏢 La empresa

Cumbre Roja es la cooperativa cafetera de
[`h-mini-07-vectorial-cumbre-roja.md`](h-mini-07-vectorial-cumbre-roja.md): dos mil trescientos
caficultores, trilladora propia y exportación con marca a cuatro países.

Exportar con marca trae una obligación que vender al intermediario no traía: **hay que poder
demostrar de dónde salió cada grano.** Los compradores especializados y los esquemas de
certificación piden evidencia por finca y por lote —qué se sembró, qué se aplicó, qué área se
cosechó, en qué coordenadas está el lote— y esa evidencia tiene que ser verificable, con fecha y
con ubicación. Si no se puede demostrar, el contenedor no entra.

Quien produce esa evidencia son **catorce extensionistas** que recorren las veredas. Suben el
lunes, visitan entre seis y diez fincas, y bajan el jueves o el viernes.

## ⚰️ El dolor

**La evidencia se escribe el viernes sobre lo que se vio el lunes.**

Arriba no hay señal. Tampoco hay electricidad estable en la mitad de las fincas. Los
extensionistas levantan todo en papel —la ficha de visita, la inspección fitosanitaria, la lista
de verificación de la certificación, las observaciones— y lo transcriben al volver.

La decisión que lo dejó así fue tan razonable que se sigue defendiendo hoy. En 2021 se hizo una
aplicación móvil: un formulario que envía los datos al servidor. Funciona perfecto en la oficina.
El argumento de entonces fue *"sincronizamos cuando vuelva la conexión y ya"*, y nadie lo
discutió porque suena a lo que es: un detalle de implementación.

No lo era. **El conflicto y la desconexión no son casos de error: son el caso normal**, y una
aplicación que supone conexión no se arregla con un reintento. Los formularios se perdían, la
gente dejó de confiar, y en 2022 volvieron al papel sin que nadie tomara la decisión de volver:
simplemente pasó.

**La factura tiene fecha.** En la auditoría de certificación de septiembre de 2025, el auditor
pidió la evidencia de once visitas. Tres tenían la fecha de la transcripción y no la de la
visita —tres días después—, dos no tenían coordenadas porque se anotaron de memoria, y una
describía un lote con un área que ya no correspondía porque se había actualizado en la oficina
esa misma semana. **Quedaron con una no conformidad mayor** y noventa días para cerrarla. La
frase del informe del auditor es la mejor definición del problema que nadie en la cooperativa
había sabido escribir: *"el registro no es contemporáneo al hecho"*.

## 🎯 El encargo

**Lo pide Elkin Restrepo, coordinador de campo.**

> *"Mis muchachos no necesitan internet. Necesitan que lo que escriben arriba quede escrito
> arriba, con la hora y el punto de arriba, y que cuando bajen se suba solo. Y necesito algo
> más, que es lo que nadie me ha sabido resolver: **si yo corrijo el área de una finca en la
> oficina el martes y el técnico está arriba anotando de esa misma finca, no quiero que uno de
> los dos pierda su trabajo.**"*

## 🧩 Lo que se construye

La aplicación del extensionista, local primero, y su servidor de replicación:

- **Escritura siempre local.** La visita se crea y se edita en el dispositivo sin preguntarle
  nada a la red. La validación del formulario ocurre **sin conexión**, contra el esquema de la
  certificación que corresponda.
- **Replicación filtrada:** cada extensionista sincroniza solo las fincas que tiene asignadas, no
  las dos mil trescientas. Es una decisión de modelado, no de red.
- **El conflicto como ciudadano de primera clase.** Detectarlo, mostrarlo y resolverlo — con las
  tres estrategias reales: el último que escribe gana pero honesto y con reloj lógico, la mezcla
  campo a campo, y la intervención humana cuando no hay regla posible.
- **Las fotos como problema aparte del formulario:** la foto de la lesión en la hoja es la
  evidencia, pesa, y se replica distinto que el JSON.

## 📐 Lo que se observa

- **Volumen de sincronización** tras tres días desconectado con diez fincas visitadas: cuánto
  sube de verdad.
- **El tamaño del historial de revisiones** de un documento que se editó veinte veces arriba, y
  qué se lleva la compactación.
- **Cuántos conflictos aparecen** en un escenario provocado con dos clientes editando lo mismo,
  y cuántos requieren una persona.
- **El costo de los adjuntos**: qué pasa cuando la foto se replica y el documento no, o al revés.

## 💥 Dónde se rompe

**La sincronización que no converge.** Provócala: dos dispositivos editando el mismo documento
durante varios ciclos, con una resolución automática que introduce un cambio nuevo cada vez.
Es el punto de rotura de la familia y es de los pocos del curso que no se manifiesta con un
error, sino con algo peor: **funcionando para siempre sin llegar a ninguna parte**.

Y el clásico que hay que tocar con la mano: **el adjunto huérfano.** La foto que quedó sin
documento, o el documento que apunta a una foto que nunca llegó.

## ⚖️ El veredicto que tiene que salir

**Aquí la familia se justifica, y es de los pocos sitios donde eso se puede decir sin matices**:
el trabajo ocurre sin conexión como condición normal, no excepcional, y el registro tiene que
ser contemporáneo al hecho por una obligación externa con consecuencia comercial. No hay forma
honesta de resolver eso con un formulario que envía.

Pero el veredicto de la familia es el más duro del curso y hay que escribirlo igual: **es la
familia con el mayor costo de complejidad por unidad de beneficio de las diez.** Resolución de
conflictos, historial de revisiones, replicación de binarios, compactación, filtros — todo eso
es superficie que alguien tiene que mantener, y Cumbre Roja tiene un ingeniero y medio.

Y el corte honesto que el miniproyecto tiene que hacer: **no todas las fincas están sin señal.**
Alrededor de cuatro de cada diez tienen cobertura suficiente. Construir para el peor caso y
dárselo a todo el mundo tiene un costo, y la alternativa —dos aplicaciones, o una aplicación
que degrada— tiene otro. **Decidir eso con argumento es el entregable real**, más que el código.

## 🧰 El stack

Es la única familia del curso donde **el mismo lenguaje está en los dos lados de la
sincronización**, y eso no es casualidad: es la razón por la que este ecosistema existe.

| Pieza | Qué se usa | Nota |
|---|---|---|
| Entorno | **TypeScript de punta a punta** | Servidor y cliente |
| Servidor | **CouchDB** · perfil `offline` | API HTTP, y Fauxton para mirar documentos y conflictos con los ojos |
| Cliente local | **PouchDB** en el navegador, sobre IndexedDB | La escritura nunca espera a la red |
| Replicación | Bidireccional, **filtrada por extensionista** | Cada dispositivo sincroniza solo sus fincas: es modelado, no configuración de red |
| Validación | `validate_doc_update` en el servidor · **Zod en el cliente, sin conexión** | La última línea que ningún cliente puede saltarse va en el servidor |
| Adjuntos | Attachments de CouchDB con checksum | Las fotos se replican **distinto** que el JSON, y ese es medio miniproyecto |
| Línea base | **No hay rival relacional honesto**, y se declara | Es la única familia del curso sin línea base, y el documento lo dice |
| Medición | `_changes` · `_revs_info` · tamaño de la base local · `_compact` | Volumen sincronizado tras tres días desconectado |
| Datos | Generador del curso | Visitas, inspecciones fitosanitarias, listas de verificación y fotos, con coordenadas y hora del hecho |
| Entregable | `src/h-mini-09-offline-cumbre-roja/` | |

**Qué NO entra:** desarrollo móvil nativo —esto corre en el navegador y no es un curso de
móvil—, notificaciones, ni un clúster de CouchDB. 🔥 Como ampliación: la misma app resuelta con
una librería de CRDT, para comparar convergencia automática contra resolución explícita.

> ⚠️ **Ninguna versión ni digest se escribe aquí.** Viven en `a02` y se fijan ejecutando, en la
> sesión de verificación de laboratorio. Este stack nombra piezas, no números.
>
> 🧭 **Dos reglas del curso que este miniproyecto no puede saltarse.** El **arnés de medida y el
> generador de datos son TypeScript siempre** (alcance §9): son el instrumento, y un instrumento
> con dos implementaciones deja de ser un instrumento. Y **se habla con los motores
> directamente**: nada de ORM, ODM ni cliente de alto nivel (`a06`), porque esas capas esconden
> justo lo que queremos medir.

---

## 🔗 El puente con Cóndor

Es la **Fase 19**: Freddy Manrique subiéndose a una avioneta el lunes con una caja de
herramientas y volviendo el jueves con todo en papel es la misma escena, en otro oficio.

Y el paralelo importante es el de la consecuencia, porque es lo que decide cuánta complejidad se
justifica. En Cumbre Roja, un registro no contemporáneo cuesta una no conformidad de
certificación. En Cóndor, un registro de mantenimiento escrito tres días después sobre lo que se
hizo en una pista sin señal es **lo que un inspector va a firmar**, y detrás de esa firma está
una licencia. La familia es la misma; lo que cambia es cuánto vale que converja bien.

## 📋 Criterios de aceptación

```text
[ ] La visita se crea, se edita y se valida sin conexión, y está demostrado con la red caída
[ ] Cada dispositivo sincroniza solo sus fincas asignadas, por filtro y no por código de cliente
[ ] La fecha y la ubicación son las del hecho, no las de la sincronización
[ ] Está provocado el conflicto con dos clientes y están implementadas las tres estrategias
[ ] Está escrito qué conflicto NO se puede resolver automáticamente y por qué
[ ] Las fotos se replican, y está resuelto el caso del adjunto huérfano
[ ] Está medido el volumen de sincronización tras tres días desconectado
[ ] Está provocada una sincronización que no converge, y está explicado el mecanismo
[ ] Está decidido, con argumento, qué se hace con las fincas que sí tienen señal
```
