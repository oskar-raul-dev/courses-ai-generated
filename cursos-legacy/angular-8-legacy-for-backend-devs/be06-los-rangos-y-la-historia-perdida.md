# 🧬 Fase be06 — Los rangos versionados y la historia que se sobrescribió

> Tutorial Angular 8 — Laboratorio clínico · 🔥 Track BE · Fase be06 de be08 · **10 horas** · **la fase más incómoda del track**
> Depende de: be05 — ya sabes qué garantías te da tu topología y cuáles no
> Habilita: be07
> Apéndices de apoyo: [bea-08 (tiempo, zonas y fechas)](./bea-08-tiempo-zonas-y-fechas-en-mongo.md) · [bea-03 (embeber o referenciar)](./bea-03-modelar-documentos-embeber-o-referenciar.md) · [Incidentes asociados](./cuaderno-incidentes-be.md): be-10

---

## 🎯 1. Propósito

Contestar la pregunta del auditor, descubrir que no se puede, y saber exactamente desde cuándo.

La pregunta es esta, y es trivial:

> *"¿Qué rango de glucosa estaba vigente el 12 de marzo de 2020?"*

Un sistema clínico tiene que poder contestarla. No es una curiosidad: es el fundamento de que un informe firmado en 2020 signifique algo. Un resultado de 105 mg/dL es normal o es una alerta según el rango contra el que se juzgó, y ese rango cambió por norma. Si el sistema no puede decir cuál estaba vigente, entonces **no puede defender ninguno de los veredictos que emitió**.

El sistema de 2019 hacía `$set` sobre el documento del rango cuando la norma cambiaba. Así que el histórico se sobrescribió. No hay copia, no hay diff, no hay bitácora del cambio: hay un documento con los límites de hoy y la fecha de vigencia de ayer.

> 🧠 **Esta es la fase más incómoda del track por una razón concreta: es la primera en la que no hay nada que arreglar.** En `be02` mediste deriva y se puede convivir con ella. En `be05` no había transacciones y se pudo contener. Aquí hay catorce meses de historia que **no existen en ninguna parte**, y el único trabajo posible es delimitar exactamente qué se perdió, demostrar desde cuándo, y dejar de perder más a partir de hoy.

Y hay un giro que salva la fase de ser solo malas noticias. Algo sobrevivió, y sobrevivió en el sitio menos esperado.

---

## ✅ 2. Qué queda listo al terminar

- [ ] Puedes explicar en una frase la diferencia entre **tiempo de vigencia** y **tiempo de registro**, y señalar cuál de los dos tenía LabCore y cuál no.
- [ ] Tienes la evidencia del `$set`: un resultado validado en 2020 cuyo `rangeVersionApplied` apunta a una versión que hoy **no tiene esos límites**.
- [ ] Tienes el inventario de la pérdida, con fechas exactas: qué analitos, qué versiones, qué ventana temporal, y cuántos resultados validados caen dentro.
- [ ] Tienes el número que importa: **cuántos resultados históricos cambian de veredicto** si se releen con los límites de hoy. No cuántos están afectados: cuántos *cambian*.
- [ ] La reconstrucción parcial está hecha y sus límites están escritos: qué se pudo recuperar, de dónde, y qué margen de confianza tiene cada pieza.
- [ ] El corte está implementado: a partir de hoy, un cambio de rango **nace como versión nueva** y ninguna versión se muta jamás. `$set` sobre `referenceRanges` deja de ocurrir.
- [ ] `RANGES-LOSS.md` existe, con el inventario, el método y la declaración de lo irrecuperable en borrador, listo para que `be08` lo firme.
- [ ] `smoke.sh` sigue entero en verde: el frontend sigue leyendo `/referenceRanges` exactamente igual que antes.

---

## 🚫 3. Qué NO entra todavía

- **La declaración formal de lo irrecuperable.** Aquí se produce el inventario; en **be08** se firma, se fecha y se le pone destinatario. Son dos actos distintos y confundirlos abarata el segundo.
- **Reescribir los veredictos históricos.** Ni para corregirlos ni para congelarlos. Un resultado validado en 2020 se queda como está → si algo se hace, es un asiento en el libro de correcciones de `be05`.
- **El modelo bitemporal completo.** Se declara entero y **se implementa la mitad**. La razón está en el §4.4 y es una decisión, no una limitación.
- **Tocar el frontend.** El selector de rango vigente de la Fase 8 sigue comparando fechas en el navegador, con su deuda de zona horaria y todo → sigue sin tocarse.
- **La subida de versión de la base**, que es lo que va a explicar por qué nadie revisó nada de esto en cinco años → **be07**.

---

## 🧠 4. Concepto mínimo

### 4.1 Dos tiempos, no uno

Un dato con historia tiene dos ejes temporales, y confundirlos es el origen de esta fase.

**Tiempo de vigencia** (*valid time*): desde cuándo y hasta cuándo el hecho es cierto **en el mundo**. "El rango de glucosa v2 rige desde el 1 de junio de 2019". Es una propiedad de la norma, no del sistema.

**Tiempo de registro** (*transaction time*): desde cuándo y hasta cuándo **el sistema creyó** ese hecho. "Este documento decía `high: 100` desde que lo escribimos el 28 de mayo de 2019 hasta que alguien lo cambió el 1 de agosto de 2020."

Un modelo que tiene los dos se llama **bitemporal**, y permite contestar dos preguntas distintas que suenan iguales:

| Pregunta | Qué eje necesita |
|---|---|
| *¿Qué rango rige hoy para la glucosa?* | Solo vigencia |
| *¿Qué rango regía el 12 de marzo de 2020?* | Solo vigencia — **si nadie mutó nada** |
| *¿Qué rango creía el sistema que regía el 12 de marzo de 2020?* | **Los dos** |
| *¿Contra qué se juzgó de verdad este resultado?* | **Los dos** |

LabCore tiene el primero y no tiene el segundo. Y aquí está la trampa que hace que el problema pasara desapercibido seis años: **con solo el eje de vigencia, la segunda pregunta parece contestable**. El documento tiene `effectiveFrom` y `effectiveTo`, así que consultas por fecha y sale una respuesta. Sale una respuesta **con los límites de hoy**, y nadie te avisa de que esos límites no son los que había en 2020.

> 🧠 **Un modelo con un solo eje temporal no falla al contestar: contesta mal con toda confianza.** Es peor que no tener historia, porque no tener historia se nota.

> 🪞 **Tu instinto relacional dice "esto se resuelve con una tabla de histórico y un trigger"… y esta vez tiene razón, pero llega tarde.** El patrón es conocido —tablas temporales, *system-versioned tables* en SQL:2011, un `audit table` con triggers— y la parte que hay que llevarse no es cuál era la solución sino **cuándo había que aplicarla**: el día que se escribió el primer rango. Una vez que la historia se sobrescribió, ningún patrón la trae de vuelta. Esta es la única deuda del track que **caducó**.

### 4.2 El anti-patrón: ⚰️ `$set` sobre un documento que representa una versión

La autopsia, con números en las dos columnas.

**Qué se hizo.** En agosto de 2020 llegó una actualización de la norma: el límite superior de glucosa en ayunas bajaba de 100 a 99 mg/dL. Alguien —con buen criterio aparente— pensó: *"la v2 ya existe y sigue vigente, solo cambian los números"*. Y ejecutó:

```javascript
// Agosto de 2020. Una línea. Catorce meses de historia.
db.referenceRanges.updateOne(
  { analyte: 'glucose', version: 2 },
  { $set: { high: 99 } }
);
```

**Por qué parecía correcto.** Porque en la cabeza de quien lo escribió, "la versión 2 del rango" era una entidad con atributos que cambian, igual que un paciente que cambia de correo. Y en esa lectura, `$set` es exactamente lo que se hace.

**Por qué estaba mal.** Porque `referenceRanges` no guarda entidades: guarda **versiones**, o sea hechos fechados. Un hecho fechado es inmutable por definición — si el hecho cambia, es otro hecho. La pista estaba en el nombre de la colección y en el campo `version`, y nadie la vio.

| | Antes del cambio | Después del `$set` |
|---|---|---|
| Versiones de glucosa en la base | 2 (v1, v2) | 2 (v1, v2) |
| Límite superior de la v2 | 100 | 99 |
| Ventana de historia recuperable | completa | **14 meses perdidos** (jun 2019 – ago 2020) |
| Resultados validados en esa ventana | 1.204 | 1.204, ahora ilegibles |
| Resultados que **cambian de veredicto** al releerse | — | **37** |
| Documentos añadidos a la base | — | 0 |
| Bytes que habría costado hacerlo bien | — | ~180 |

**Lo que se debió hacer**, y son tres líneas en vez de una:

```javascript
// Cerrar la vigencia de la v2, sin tocar sus límites.
db.referenceRanges.updateOne(
  { analyte: 'glucose', version: 2 },
  { $set: { effectiveTo: ISODate('2020-07-31T23:59:59Z') } }
);
// Y nacer la v3 con los límites nuevos.
db.referenceRanges.insertOne({
  analyte: 'glucose', version: 3, unit: 'mg/dL',
  low: 70, high: 99, criticalLow: 50, criticalHigh: 250,
  effectiveFrom: ISODate('2020-08-01T00:00:00Z'), effectiveTo: null
});
```

> ⚠️ **Y fíjate en el detalle que hace enseñable la autopsia: escribir un `effectiveTo` en vez de dejarlo abierto es lo único que hace que el `$set` sea legítimo.** Ese `$set` **sí** es correcto, porque cerrar una vigencia no cambia lo que la versión decía: añade información sobre hasta cuándo lo decía. La regla, entonces, no es *"nunca se muta un documento de versión"*: es **"se puede escribir su cierre, y nunca sus valores"**. Esa frase, con esa precisión, es lo que hay que llevarse.

### 4.3 El giro: el frontend salvó lo que el backend perdió

Aquí está la parte que salva la fase, y hay que escribirla con estas palabras porque es la mejor lección del track:

> 🧠 **El frontend salvó lo que el backend perdió.**

La Fase 8 del track base hace algo que en su momento pareció un detalle de implementación: cuando un analista **valida** un resultado, el sistema guarda en el propio resultado el campo `rangeVersionApplied` —el número de versión del rango contra el que se juzgó—. Está ahí porque quien escribió esa fase razonó bien: *el veredicto tiene que quedar congelado aunque más tarde nazca una v3*.

Ese campo es hoy la única prueba superviviente de la historia de los rangos. Está en cada uno de los 1.204 resultados validados de la ventana perdida, y dice: **"este resultado se juzgó contra la v2"**.

Lo que no dice, y ahí está el límite exacto de lo que se puede recuperar: **qué decía la v2 en ese momento**. El puntero sobrevivió; el destino no. Es un enlace a una página que alguien reescribió.

> 🧭 **Y la lección organizacional, que es la que importa fuera de este curso:** los dos equipos tomaron decisiones sobre el mismo problema —cómo congelar un veredicto— sin hablarse. El del frontend guardó el puntero y acertó a medias. El del backend mutó el destino y falló entero. **Ninguno de los dos tenía el problema completo delante**, y esa es la firma de un sistema partido entre equipos que no comparten el modelo. Es la misma raíz que produjo el audit log del navegador en `be04`.

### 4.4 La decisión: se declara el modelo entero y se implementa la mitad

Con lo anterior, la pregunta de diseño es: ¿se implementa el modelo bitemporal completo —los dos ejes, con historia de registro y todo— o solo la parte que este sistema puede sostener?

**Se implementa la mitad, y se declara por qué.** Las tres razones, en orden de peso:

1. **La mitad que falta no recupera nada.** Un eje de tiempo de registro añadido hoy empieza a grabar hoy. Los catorce meses perdidos siguen perdidos con el modelo completo o con medio modelo. **Lo que se gana con el completo es exactamente lo mismo que con la mitad: dejar de perder.**
2. **El sistema tiene dos años de vida.** Un modelo bitemporal completo obliga a que toda consulta de rango lleve dos fechas en vez de una, y esa complejidad se paga en cada lectura, para siempre. Con veinte años por delante, se paga. Con dos, no.
3. **El frontend no se toca.** El selector de la Fase 8 pide rangos y elige por fecha de vigencia. Un modelo con dos ejes tendría que seguir devolviéndole exactamente lo mismo, así que la mitad de la complejidad quedaría sin consumidor — que es una deuda nueva, no una solución.

Lo que sí se implementa, y es lo que de verdad cierra el agujero:

- **Append-only sobre `referenceRanges`.** Un cambio de límites nace como versión nueva. Nunca se mutan valores; solo se escribe el cierre de vigencia.
- **`recordedAt` en cada versión** —cuándo la escribió el sistema—. Es medio eje de tiempo de registro: sabe cuándo empezó a creerlo y, al no mutarse nunca, no necesita saber cuándo dejó de hacerlo.
- **Una guarda que impide el `$set`**, porque una regla que depende de que todo el mundo se acuerde no es una regla.

> 🧭 **Y se escribe la parte que no se implementó, con su razón y su fecha.** *"No se implementa el eje de tiempo de registro completo porque no recupera nada y encarece cada lectura de un sistema con decomisión prevista. Se revisa si la fecha de decomisión se mueve más de un año."* Un modelo a medias **declarado** es una decisión de ingeniería. El mismo modelo a medias sin declarar es la deuda que alguien va a descubrir dentro de tres años sin saber si fue deliberada.

---

## 💻 5. Código mínimo con comentarios

Siete piezas: primero se demuestra la pérdida, después se delimita, después se corta.

### 5.1 La evidencia: un puntero a una página reescrita

```javascript
// Un resultado validado en la ventana perdida, con su puntero intacto.
db.results.findOne(
  { status: 'validated', validatedAt: { $gte: ISODate('2020-03-01'),
                                        $lt:  ISODate('2020-04-01') } },
  { legacyId: 1, analyte: 1, value: 1, validatedAt: 1, rangeVersionApplied: 1 }
);
```

```
{ legacyId: 91204, analyte: "glucose", value: 99.4,
  validatedAt: ISODate("2020-03-12T15:41:00Z"), rangeVersionApplied: 2 }
```

```javascript
// Y la versión 2, hoy.
db.referenceRanges.findOne({ analyte: 'glucose', version: 2 });
```

```
{ analyte: "glucose", version: 2, low: 70, high: 99,
  effectiveFrom: ISODate("2019-06-01T05:00:00Z"), effectiveTo: null }
```

Léelo dos veces. El resultado vale **99,4** y se juzgó contra la v2. Con la v2 de hoy —`high: 99`— ese valor está **fuera de rango**: es una alerta. Con la v2 de marzo de 2020 —`high: 100`— estaba **dentro**: era normal.

El informe que se le entregó a ese paciente dice una cosa. El sistema, hoy, dice la contraria. Y las dos afirmaciones citan la misma versión del mismo rango.

> 🧠 **Ese es el hallazgo completo de la fase en un documento.** No es que falte un dato: es que **el sistema contradice su propio informe firmado, citando la misma fuente**. Ninguna comprobación de integridad lo detectaría, porque el puntero es válido, el documento existe, y todos los campos tienen el tipo correcto.

### 5.2 Delimitar la ventana

Sin bitácora del cambio, la fecha del `$set` hay que inferirla. Tres fuentes, ninguna concluyente por sí sola, y esa es la lección de método:

```javascript
// Fuente 1 — el propio ObjectId del documento. Sus primeros 4 bytes son la
// marca de tiempo de la CREACIÓN. No dice cuándo se modificó, pero acota:
// el cambio ocurrió después de esto.
db.referenceRanges.aggregate([
  { $match: { analyte: 'glucose' } },
  { $project: { version: 1, high: 1, creado: { $toDate: '$_id' } } }
]);
```

```javascript
// Fuente 2 — el último resultado validado que es COHERENTE con los límites
// viejos y el primero que solo lo es con los nuevos. La frontera entre esos
// dos acota la ventana mejor que ninguna otra cosa.
db.results.aggregate([
  { $match: { analyte: 'glucose', status: 'validated', rangeVersionApplied: 2 } },
  { $project: { validatedAt: 1, value: 1,
                soloExplicableConElNuevo: { $and: [
                    { $gt: ['$value', 99] }, { $lte: ['$value', 100] } ] } } },
  { $match: { soloExplicableConElNuevo: true } },
  { $sort: { validatedAt: 1 } },
  { $limit: 1 }
]);
```

**Fuente 3 — el correo.** Sí, el correo. La norma que cambió tiene fecha oficial de entrada en vigor, y esa fecha es un documento público que no vive en tu base de datos. **En un sistema sin bitácora, la mejor fuente de la fecha de un cambio muchas veces está fuera del sistema**: una resolución, un correo, un acta. Búscala, y anota en `RANGES-LOSS.md` de dónde salió cada fecha.

```
Ventana de historia irrecuperable — glucosa v2
  desde: 2019-06-01  (effectiveFrom de la v2, dato fiable)
  hasta: 2020-08-01  (fecha de la resolución; el ObjectId y la frontera de
                      valores son compatibles con ella y no la contradicen)
  duración: 14 meses
  resultados validados en la ventana: 1.204
```

### 5.3 El número que importa: cuántos veredictos cambian

Que 1.204 resultados estén "afectados" es un titular. El número que se lleva a una reunión es otro:

```javascript
// Resultados validados en la ventana cuyo VEREDICTO cambia al releerse con
// los límites de hoy. No los afectados: los que cambian de significado.
//
// Es la diferencia entre "hay 1.204 resultados en la zona del problema" y
// "hay 37 informes cuyo veredicto no podemos reproducir". La segunda frase
// es la que hay que poder defender.
db.results.aggregate([
  { $match: { analyte: 'glucose', status: 'validated',
              rangeVersionApplied: 2,
              validatedAt: { $gte: ISODate('2019-06-01'),
                             $lt:  ISODate('2020-08-01') } } },
  { $project: {
      legacyId: 1, value: 1, validatedAt: 1,
      // 100 era el límite de entonces; 99 es el de hoy.
      veredictoEntonces: { $cond: [ { $gt: ['$value', 100] }, 'alto', 'normal' ] },
      veredictoHoy:      { $cond: [ { $gt: ['$value',  99] }, 'alto', 'normal' ] }
  }},
  { $match: { $expr: { $ne: ['$veredictoEntonces', '$veredictoHoy'] } } },
  { $count: 'veredictosQueCambian' }
]);
```

```
{ "veredictosQueCambian": 37 }
```

**Treinta y siete informes clínicos** cuyo veredicto, releído hoy con la información que el sistema conserva, sale distinto del que se entregó. Ese es el número de `be08`, y es el que un auditor va a querer con nombre y apellido.

> 💡 Ejecuta la misma agregación para cada analito que haya tenido más de una versión. La forma del resultado importa: si el problema está solo en la glucosa, hubo **un** incidente y se puede acotar. Si aparece en tres analitos, hubo **una práctica**, y eso es otra conversación.

### 5.4 La reconstrucción parcial, y sus límites

Lo que se puede recuperar sale de cruzar el puntero superviviente con la aritmética de los valores. Es reconstrucción por inferencia, no por evidencia, y hay que marcarlo en cada línea:

```javascript
// Reconstruir el límite superior que regía: buscar el valor máximo que se
// validó como "normal" en la ventana. El límite de entonces era, como
// mínimo, ese valor.
//
// ⚠️ Esto NO recupera el límite. Recupera una COTA INFERIOR del límite. Si
// nadie tuvo un resultado de 100 en catorce meses, el máximo observado dirá
// 98,7 y no habrá forma de saber si el techo era 99, 100 o 105.
db.results.aggregate([
  { $match: { analyte: 'glucose', status: 'validated', rangeVersionApplied: 2,
              validatedAt: { $lt: ISODate('2020-08-01') },
              outOfRangeReported: { $ne: true } } },
  { $group: { _id: null, maximoValidadoComoNormal: { $max: '$value' } } }
]);
```

```
{ "maximoValidadoComoNormal": 99.8 }
```

Con eso sabes que el techo de entonces era **al menos 99,8**, lo cual es compatible con 100 y descarta 99. Es una prueba débil que apunta en la dirección correcta, y hay que presentarla exactamente así.

> 🧭 **La regla de método de esta sección, y vale para cualquier reconstrucción forense:** *lo inferido y lo medido no se mezclan en la misma tabla.* En `RANGES-LOSS.md` van dos columnas separadas, y cada fila inferida lleva su método y qué la refutaría. Un documento donde una inferencia se cita después como un hecho es exactamente lo que hace que un auditor deje de creerse el resto.

### 5.5 El corte: append-only desde hoy

```java
package com.andina.labcore.service;

// A partir de hoy, un cambio de rango NACE como versión nueva. Los valores
// de una versión existente no se tocan jamás; lo único que se le puede
// escribir es su cierre de vigencia.
//
// Las dos escrituras de este método son, otra vez, el problema de be05:
// cerrar la anterior y crear la nueva son dos documentos sin transacción. La
// diferencia es que aquí el estado intermedio es DETECTABLE y benigno: dos
// versiones con vigencia solapada, que el detector de integridad encuentra
// y que el selector del frontend resuelve quedándose con la primera. Se
// declara, se vigila, y se sigue.
public ReferenceRange newVersion(String analyte, RangeLimits limits, Instant from) {

    ReferenceRange current = repository.findCurrentByAnalyte(analyte);

    // 1. Cerrar la vigencia de la actual. Este $set SÍ es legítimo: no
    //    cambia lo que la versión decía, añade hasta cuándo lo decía.
    if (current != null) {
        current.setEffectiveTo(Date.from(from.minusMillis(1)));
        repository.save(current);
    }

    // 2. Nacer la nueva, con su número siguiente y su marca de registro.
    ReferenceRange next = new ReferenceRange();
    next.setAnalyte(analyte);
    next.setVersion(current == null ? 1 : current.getVersion() + 1);
    next.setLow(limits.getLow());
    next.setHigh(limits.getHigh());
    next.setCriticalLow(limits.getCriticalLow());
    next.setCriticalHigh(limits.getCriticalHigh());
    next.setEffectiveFrom(Date.from(from));
    next.setEffectiveTo(null);

    // El medio eje de tiempo de registro del §4.4: cuándo lo escribió el
    // sistema. Como el documento no se muta nunca, no hace falta guardar
    // cuándo dejó de creerlo — se deduce del recordedAt del siguiente.
    next.setRecordedAt(Date.from(serverClock.now()));
    next.setRecordedBy(RequestContext.getActor());

    return repository.save(next);
}
```

### 5.6 La guarda, porque una regla que depende de la memoria no es una regla

```java
// Un listener de Spring Data que intercepta toda escritura sobre
// referenceRanges y rechaza cualquier modificación de los campos de límites
// en un documento existente.
//
// Se hace en la aplicación y NO en la base con $jsonSchema, por una razón
// que conviene tener escrita: $jsonSchema valida la FORMA de un documento,
// no la relación entre su estado nuevo y el viejo. Lo que hay que prohibir
// aquí es una transición, no una forma. La contención en la base es de be08
// y va a ser distinta: quitarle a la aplicación el permiso de update sobre
// esa colección.
@Component
public class ReferenceRangeImmutabilityListener
        extends AbstractMongoEventListener<ReferenceRange> {

    private static final Set<String> MUTABLES =
            new HashSet<String>(Arrays.asList("effectiveTo"));

    @Override
    public void onBeforeSave(BeforeSaveEvent<ReferenceRange> event) {
        ReferenceRange incoming = event.getSource();
        if (incoming.getId() == null) {
            return;   // documento nuevo: adelante
        }
        ReferenceRange stored = repository.findById(incoming.getId()).orElse(null);
        if (stored == null) {
            return;
        }
        for (String field : changedFields(stored, incoming)) {
            if (!MUTABLES.contains(field)) {
                // Se rechaza y se registra. El rechazo tiene que ser ruidoso:
                // esta excepción es el único punto del sistema donde alguien
                // se va a enterar de que estaba a punto de repetir 2020.
                throw new ImmutableVersionException(
                    "referenceRanges es append-only: solo se puede escribir "
                    + "effectiveTo. Intento de modificar: " + field);
            }
        }
    }
}
```

**Detalles con intención**

- **`effectiveTo` es el único campo mutable**, y esa lista corta es la regla del §4.2 hecha código. Si alguien la amplía, tendrá que escribir por qué, que es exactamente el efecto que se busca.
- La guarda **no cubre el shell**. Un `db.referenceRanges.updateOne(...)` desde `mongo` la esquiva entera. Está declarado como límite y es material de `be08`: la contención de verdad es quitar el permiso, no pedirlo por favor.
- Se lanza una excepción propia y no se registra en silencio. Un `log.warn` aquí sería inútil: el `$set` de 2020 fue una acción deliberada de alguien que creía estar haciendo lo correcto, y a esa persona hay que **interrumpirla**, no anotarla.

### 5.7 `RANGES-LOSS.md`

El entregable escrito, en borrador para que `be08` lo firme. Cuatro secciones y ni una más:

````markdown
# Pérdida de historia en rangos de referencia — inventario

## 1. Qué se perdió
Los límites que tuvo la versión 2 del rango de glucosa entre el 1/06/2019 y
el 1/08/2020. Fueron sobrescritos por una actualización directa, sin crear
una versión nueva y sin dejar registro del cambio.

## 2. Desde cuándo, y cómo lo sabemos
[la tabla de tres fuentes del §5.2, con lo medido y lo inferido separados]

## 3. Qué consecuencia tiene, con números
- 1.204 resultados validados en la ventana.
- **37 cuyo veredicto cambia** al releerse con los límites actuales.
- 0 de esos 37 tienen una alerta clínica registrada en la bitácora.

## 4. Qué se puede afirmar y qué no
- **Se puede afirmar:** contra qué VERSIÓN se juzgó cada resultado
  (`rangeVersionApplied` sobrevivió intacto en los 1.204).
- **No se puede afirmar:** qué límites tenía esa versión en ese momento.
  La cota inferior reconstruida (99,8) es compatible con 100 y descarta 99,
  pero es una inferencia y no una prueba.
- **No se puede afirmar nada** sobre analitos sin resultados validados en la
  ventana: ahí no sobrevivió ni el puntero.
````

> **Prueba de fuego.** Intenta reproducir el desastre: llama a un `$set` sobre los límites de una versión existente a través de la aplicación. La guarda del §5.6 lo rechaza con un mensaje que explica qué hacer en su lugar. Ahora hazlo desde el shell de `mongo` directamente: **funciona**. Anota las dos cosas juntas, porque esa asimetría es el argumento de `be08` sobre permisos. Por último, crea una versión nueva con `newVersion()` y comprueba tres cosas en la base: que la anterior conserva sus límites intactos, que tiene un `effectiveTo` escrito, y que el selector del frontend —sin tocarlo— sigue eligiendo la correcta.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Síntoma: la ventana de la pérdida sale de dos años en vez de catorce meses.**
Causa: se está tomando el `effectiveFrom` de la v1 en vez del de la v2 como inicio. Fix mínimo: la ventana empieza cuando empezó a regir la versión que se mutó, no cuando empezó la historia del analito.

**Síntoma: la reconstrucción "recupera" el límite exacto.**
Causa: se está confundiendo una cota con un valor. El máximo validado como normal es una **cota inferior**, y presentarla como el límite es la clase de error que invalida un informe entero. Fix mínimo: la separación de columnas del §5.4.

**Síntoma: el número de veredictos que cambian sale enorme.**
Causa: se está contando sobre todos los resultados y no solo sobre los `validated` de la ventana con `rangeVersionApplied: 2`. Un preliminar no tiene veredicto oficial, así que no puede cambiar de veredicto. Fix mínimo: los tres filtros del `$match` del §5.3, los tres.

**Síntoma: la guarda de inmutabilidad rechaza el cierre de vigencia legítimo.**
Causa: `effectiveTo` no está en la lista de campos mutables. Fix mínimo: añadirlo — y **solo** ese.

**Síntoma: dos versiones con vigencia solapada después de crear una nueva.**
Causa: la primera de las dos escrituras del §5.5 falló. Es el problema de `be05`, y aquí el estado intermedio es benigno y detectable. Fix mínimo: el detector de integridad lo levanta; la corrección va al libro, no a un `$set` a mano.

### Pieza forense de esta fase

**El puntero que sobrevivió y el destino que no.**

Es el documento del §5.1 y merece recorrerse con el método completo, porque es el caso más difícil de los que has visto: **no hay ningún dato malformado en ninguna parte**.

- **¿Qué se ve?** Un resultado de 99,4 mg/dL, validado el 12 de marzo de 2020, que la pantalla de hoy pinta con la marca de fuera de rango. El informe en PDF que se archivó en 2020 —y que existe, porque la Fase 9 lo generó— lo muestra como normal.
- **¿Qué capa lo produce?** Ninguna capa del sistema actual. Todas están haciendo bien su trabajo: el selector elige la versión correcta por fecha, el comparador compara bien, la pantalla pinta lo que le dicen. **El error ocurrió en 2020 y lo que ves hoy es su consecuencia**, cinco años después, en un sistema que funciona.
- **🧬 ¿Lo escribió el sistema o llegó roto en el dato?** Ninguna de las dos. Lo escribió **una persona**, con una operación válida, sobre un dato correcto, con buena intención. Esta pregunta —la propia del track forense— aquí devuelve una tercera respuesta que no estaba en el menú, y ese es el hallazgo.
- **¿Con qué se demuestra?** Con el PDF de 2020 al lado de la pantalla de hoy. La prueba de que hubo una pérdida de historia **no está en la base de datos**: está en un artefacto que salió del sistema y que nadie modificó porque nadie podía. Búscalo, porque es el único testigo que queda.

> 🧠 **Ese último punto es lo más transferible de toda la fase.** Cuando un sistema pierde su propia historia, la evidencia sobrevive en lo que ese sistema **exportó**: informes, correos, archivos adjuntos, capturas en tickets. En una investigación real, esos artefactos suelen ser la única fuente independiente que queda, y la primera reacción de casi todo el mundo —buscar en la base— es la que no lleva a ninguna parte.

🧨 **Rompe a propósito.** Crea una v3 con límites nuevos y después, desde el shell, hazle un `$set` a la v2 cambiando `low`. Ahora releé un resultado de 2019 validado contra la v2 y observa cómo cambia su veredicto en la pantalla, sin que nada avise, sin que ningún log lo registre y sin que ninguna prueba se ponga en rojo. Cronometra cuánto te ha llevado destruir historia: menos de treinta segundos. Después revierte tu base al estado anterior y anota **cómo** la revertiste — porque si no tenías copia, no has podido, y acabas de aprender la mitad de `be08`.

---

## 🧪 7. Ejercicios (33)

**🟢 Fácil (1–8)**

1. Escribe en `RANGES-LOSS.md` la diferencia entre tiempo de vigencia y tiempo de registro, con un ejemplo de LabCore para cada uno.
2. Encuentra el documento del §5.1 en tu base y reproduce las dos consultas. Anota el valor, la versión y los límites de hoy.
3. Calcula a mano el veredicto de ese resultado con `high: 100` y con `high: 99`. Escribe las dos frases que le dirías al paciente.
4. Lista todos los analitos que tienen más de una versión de rango, con sus ventanas de vigencia.
5. Extrae la fecha de creación de cada documento de `referenceRanges` desde su `ObjectId` con `$toDate`. Anota qué acota y qué no.
6. Cuenta los resultados validados en la ventana de la pérdida. Anota el número.
7. Corre la agregación del §5.3 y anota cuántos veredictos cambian.
8. Implementa `recordedAt` y `recordedBy` en el modelo y comprueba que una versión nueva los guarda.

**🟡 Intermedio (9–18)**

9. Implementa `newVersion()` y crea una v3 de glucosa. Comprueba en la base que la v2 conserva sus límites y gana un `effectiveTo`.
10. Comprueba que el frontend, **sin tocarlo**, sigue eligiendo la versión correcta después de crear la v3. Valida un resultado nuevo y confirma que su `rangeVersionApplied` es 3.
11. Implementa la guarda de inmutabilidad y comprueba que rechaza un cambio de `high` y acepta un cambio de `effectiveTo`.
12. **Diagnóstico.** Esquiva la guarda desde el shell y documenta que se puede. Escribe en dos líneas qué haría falta para impedirlo de verdad.
13. Repite la agregación de veredictos que cambian para **todos** los analitos con más de una versión. Presenta la tabla y decide si hubo un incidente o una práctica.
14. Escribe la reconstrucción por cota inferior del §5.4 y anota el número. Di explícitamente qué valores descarta y cuáles no.
15. **Diagnóstico.** Busca los resultados `validated` con `rangeVersionApplied: null` —el incidente 12 del cuaderno base, ya contado en `be02` ej. 22— y explica por qué esos son *peores* que los 1.204: en ellos ni siquiera sobrevivió el puntero.
16. Redacta las cuatro secciones de `RANGES-LOSS.md`, con lo medido y lo inferido en columnas separadas.
17. **Diagnóstico.** Encuentra en el sistema el PDF de uno de los 37 resultados afectados (Fase 9 del track base) y ponlo al lado de la pantalla de hoy. Captura las dos.
18. Escribe la declaración del §4.4 —qué mitad del modelo no se implementa, por qué, y cuándo se revisa— en `CONTRACT.md`.

**🟠 Difícil (19–26)**

19. **Diagnóstico.** Delimita la ventana con las tres fuentes del §5.2 y escribe cuál de las tres es más fiable y por qué. Si las tres se contradicen, explica cómo resolverías el conflicto.
20. **Diagnóstico.** Toma uno de los 37 y reconstruye su historia completa: cuándo se tomó la muestra, quién validó, contra qué versión, qué decía el PDF, qué dice hoy la pantalla. Una línea de tiempo, con las fuentes de cada dato.
21. **Diseño.** Escribe el modelo bitemporal completo —el que **no** se implementa— con sus dos ejes y las consultas que haría falta reescribir. Estima las horas. Ese documento es el que justifica la decisión del §4.4, y sin él la decisión es una excusa.
22. **Diagnóstico.** El detector de integridad de `be05` no busca versiones solapadas. Añádele esa comprobación y provoca el caso interrumpiendo `newVersion()` entre sus dos escrituras.
23. **Diagnóstico.** Con la v3 creada, comprueba qué hace el selector del frontend si dos versiones tienen vigencia solapada. Anota cuál elige y por qué, leyendo el código de la Fase 8. Decide si ese comportamiento es aceptable como red de seguridad o si es otro problema.
24. Mide el coste de la guarda del §5.6: cronometra cien escrituras de rango con y sin ella. Anota si la lectura extra que hace por cada escritura se nota.
25. **Diagnóstico + escritura.** Los 37 resultados afectados están validados y la validación es irreversible (Fase 8). Escribe qué se hace con ellos: ¿un asiento en el libro de correcciones? ¿una nota en el informe? ¿nada? Justifica con la regla del §4.4 de `be05` y con lo que un laboratorio real haría.
26. **Adversarial.** Alguien propone "restaurar" el límite de 100 en la v2 para que los informes históricos cuadren. Escribe las tres razones por las que eso es peor que el problema original, y la única circunstancia en la que sería defendible.

**🔴 Muy difícil (27–33)**

27. **Diagnóstico.** Busca en el resto del sistema otros documentos que representen **versiones** y que se estén mutando con `$set`. Empieza por los estados de muestra y por el propio `auditLog`. La lista que salga es el alcance real del anti-patrón y va a `be08`.
28. **Adversarial.** Argumenta bien la posición contraria: *"la norma de 2020 bajó el límite porque el criterio clínico cambió; releer un resultado de 2019 con el criterio de hoy es exactamente lo que la medicina hace, así que no hay nada que arreglar"*. Es un argumento fuerte y hay que dárselo entero. Después refútalo con la distinción que lo desmonta: **releer con criterio nuevo es medicina; no poder demostrar con qué criterio se firmó es un problema de registro**. Escribe las dos cosas.
29. **Diseño.** Si el sistema tuviera diez años por delante en vez de dos, ¿implementarías el modelo completo? Escribe la respuesta con el punto de equilibrio: a partir de cuántos años de vida restante el modelo completo se paga. Ese cálculo, con sus supuestos, es el tipo de argumento que `be08` necesita.
30. **Diagnóstico y escritura.** Escribe el post-mortem de ocho puntos del incidente **be-10** con el formato del cuaderno, sin culpabilización. El punto difícil es el de la causa raíz: **la persona que ejecutó el `$set` hizo lo que su modelo mental indicaba**, y el post-mortem tiene que explicar por qué ese modelo mental era razonable.
31. **Escritura.** Redacta el párrafo de `RANGES-LOSS.md` dirigido a Calidad. Tiene que decir que hay 37 informes cuyo veredicto no se puede reproducir, sin alarmar más de lo que corresponde y sin minimizar. Máximo 150 palabras. Es el ejercicio más difícil de escribir de todo el track.
32. **Adversarial.** Un compañero dice: *"el `rangeVersionApplied` nos salvó; deberíamos guardar los límites completos en cada resultado, no solo el número de versión"*. Tiene razón y está proponiendo desnormalizar. Apoyándote en [`bea-03`](./bea-03-modelar-documentos-embeber-o-referenciar.md), escribe qué gana y qué cuesta, decide, e implementa tu decisión para los resultados **nuevos**. Después responde lo que duele: eso no arregla ninguno de los 1.204.
33. **La medición que cierra la fase.** Escribe la página *"Qué historia conserva LabCore y desde cuándo"*, con una fila por tipo de dato histórico —rangos, estados de muestra, auditoría, resultados— diciendo qué se conserva, desde qué fecha, y con qué prueba. Las filas que no puedas llenar son el hallazgo. Es el capítulo más citado del documento de `be08`.

**🔥 Opcionales**

- 🔥 Implementa el modelo bitemporal completo en una rama y mide cuánto crece la consulta de rango vigente. Compara la complejidad con lo que gana. Después bórralo, y guarda la medición.
- 🔥 Busca en la documentación de tu proveedor de base de datos si hay copias de seguridad de 2020 todavía disponibles. Casi seguro que no —la retención típica es de días o semanas— y esa comprobación, con su resultado escrito, es una fila de `RANGES-LOSS.md`.
- 🔥 Escribe la consulta bitemporal que un motor con `SYSTEM VERSIONING` de SQL:2011 resolvería de un solo golpe (`FOR SYSTEM_TIME AS OF`). Compárala con lo que tendrías que escribir aquí. No es una crítica a Mongo: es para saber qué existe y qué se está construyendo a mano.

---

## 📚 8. Referencias

**Documentación oficial**

- MongoDB 4.0 — el patrón oficial de versionado de documentos, que es literalmente la solución que LabCore no aplicó: https://www.mongodb.com/docs/manual/tutorial/model-data-for-schema-versioning/
- `$toDate` sobre un `ObjectId`, que es la fuente 1 del §5.2: https://www.mongodb.com/docs/v4.0/reference/operator/aggregation/toDate/
- `AbstractMongoEventListener` de Spring Data 2.1, para la guarda del §5.6: https://docs.spring.io/spring-data/mongodb/docs/2.1.x/reference/html/#mongodb.mapping-usage.events
- SQL:2011 — tablas con versionado de sistema, para saber qué estás construyendo a mano: https://en.wikipedia.org/wiki/SQL:2011#Temporal_support

**Libros y artículos de referencia**

- Martin Fowler, *Temporal Patterns* — la colección entera, y en particular *Temporal Property*, *Effectivity* y *Snapshot*: https://martinfowler.com/eaaDev/timeNarrative.html — es la teoría completa de esta fase, escrita hace veinte años y todavía la mejor exposición que hay.
- Richard Snodgrass, *Developing Time-Oriented Database Applications in SQL* (1999), disponible libre: https://www2.cs.arizona.edu/~rts/tdbbook.pdf — el libro de referencia sobre bitemporalidad. No hace falta entero: los capítulos 1 a 4 dan el vocabulario preciso.
- Martin Kleppmann, *Designing Data-Intensive Applications* (2017), capítulo 11 §*The Truth Is Derived from the Log* — la idea de que el estado es una vista de los hechos y no al revés, que es exactamente lo que LabCore invirtió.
- Sobre asientos y libros que no se tachan, ver `be05` §4.4: es la misma regla aplicada al otro extremo del sistema.

**Video y apoyo**

- Charlas sobre modelado temporal y *slowly changing dimensions* del mundo del almacén de datos (2015-2021): https://www.youtube.com/results?search_query=slowly+changing+dimension+type+2 — el tipo 2 de SCD es exactamente el append-only del §5.5 con otro nombre y cuarenta años de anterioridad. Verlo así ayuda: el problema no es nuevo y la solución tampoco.

**Orden de lectura sugerido:** Fowler *Effectivity* y *Temporal Property* **antes** de escribir nada, porque dan los dos nombres que ordenan la fase → el patrón oficial de versionado de MongoDB justo después, para ver la solución concreta → Snodgrass caps. 1-4 solo si vas a hacer el ejercicio 21 → Kleppmann cap. 11 al final, cuando quieras entender por qué esto se resolvería solo en un sistema orientado a eventos.

> ⚠️ URLs y contenidos cambian. Con este tema el riesgo es distinto: la mayoría de lo que encuentres sobre "versionado en MongoDB" habla de versionar el **esquema** —el problema de `be02`— y no de versionar el **dato**, que es el de esta fase. Son cosas distintas con el mismo nombre.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Terminas con lo que ninguna fase anterior te dio: **una pérdida definitiva, delimitada**. Catorce meses, 1.204 resultados, 37 veredictos que no se pueden reproducir. Y con el corte hecho, de forma que a partir de hoy la lista no crece.

Lo que se lleva de aquí un mantenedor no es el modelo bitemporal. Son tres frases:

**Un hecho fechado es inmutable; si cambia, es otro hecho.** Y la precisión que la hace útil: se puede escribir su cierre, nunca sus valores.

**Un modelo con un solo eje temporal no falla al contestar, contesta mal con confianza.** Por eso este problema sobrevivió seis años sin un solo ticket.

**Y la que hay que decir con estas palabras: el frontend salvó lo que el backend perdió.** Un campo que alguien puso en la Fase 8 por buen criterio es hoy la única prueba superviviente. Nadie coordinó eso; salió bien por casualidad, y la casualidad no es una estrategia de trazabilidad.

Queda una pregunta que esta fase deja sin contestar y que es la que abre **be07**: si el `$set` de 2020 no dejó rastro en el código, y las cinco formas de `be02` tampoco, ¿qué **más** ha cambiado en este sistema sin que nadie lo decidiera ni lo apuntara? La respuesta es incómoda y está fuera del árbol de fuentes. Entre 2019 y hoy, el proveedor subió la base de datos cuatro versiones mayores —4.0 a 4.4 a 6.0 a 7.0—, cada una en su ventana de mantenimiento y cada una anunciada por un correo que alguien archivó. La aplicación no se movió nunca. En `be07` vas a investigar un incidente cuyo `git log` está vacío, y vas a descubrir que el cambio no está en el repositorio: está en una línea de un archivo que no es código.

> **La señal de que quedó bien:** *"sé exactamente qué historia perdimos, desde cuándo, con qué pruebas, y sé que desde hoy no se pierde ni un día más."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en verde y `git status` limpio:
>
> ```bash
> git tag -a be-fase-06-los-rangos-y-la-historia-perdida -m "be06 cerrada: ventana de 14 meses delimitada con tres fuentes; 1204 resultados afectados y 37 veredictos que cambian; reconstruccion por cota inferior con sus limites; append-only implementado con guarda de inmutabilidad; medio modelo bitemporal declarado; RANGES-LOSS.md en borrador"
> ```
>
> Los commits de la fase llevan su prefijo (`be06: …`) y los de ejercicio su número (`be06 ej20: …`). Todo eso está en [`00-convencion-de-git-y-tags.md`](./00-convencion-de-git-y-tags.md) §10.

---

## 📌 Pendientes sugeridos

- **[A] El medio modelo bitemporal queda cerrado aquí**, con su declaración escrita en `CONTRACT.md`: append-only más `recordedAt`, sin eje de registro completo, con la razón y la condición de revisión. Ninguna fase posterior lo amplía sin rehacer esa justificación.
- **[B] La guarda del §5.6 no cubre el shell.** La contención de verdad —quitar el permiso de `update` sobre `referenceRanges` a la cuenta de la aplicación— es de `be08` y ahí tiene que aparecer con nombre.
- **[C] Los 37 resultados afectados no se tocan.** Qué se hace con ellos se decide en `be08`, y el ejercicio 25 produce la propuesta. Cualquier acción sobre ellos pasa por el libro de correcciones de `be05`.
- **[D] La lista del ejercicio 27** —otros documentos-versión que se están mutando— tiene que llegar a `be08` completa. Hoy solo está medido el caso de los rangos, y sería un error tratarlo como el único.
- **[E] La distinción entre lo medido y lo inferido** en `RANGES-LOSS.md` es innegociable. Si `be08` mezcla las dos columnas al redactar la declaración final, el documento pierde su valor probatorio entero.
- **[F] La comprobación de copias de seguridad** (🔥 segundo) tiene que estar hecha antes de `be08`, aunque el resultado sea "no hay". Un "no comprobamos si había copia" en una declaración firmada es peor que un "comprobamos y no había".

### Reservas para el cuaderno de incidentes

| ID | Título propuesto | Categoría | Dificultad |
|---|---|---|---|
| **be-10** | *"El informe dice normal y la pantalla dice alto"* | Historia sobrescrita / datos temporales | 🔴 |

Llega como una consulta de Calidad, no como un ticket: *"un paciente trajo su informe de 2020 y no coincide con lo que muestra el sistema"*. El primer reflejo —buscar un bug en el comparador de rangos— no lleva a ninguna parte, porque el comparador funciona. El trabajo del incidente es descubrir que la discrepancia no está en el código sino en el dato, que el dato se perdió hace cinco años, y que **el propio informe en papel es la única prueba que queda**. El post-mortem tiene que llegar a las dos conclusiones: que quien ejecutó el `$set` en 2020 hizo lo que su modelo mental indicaba, y que la prevención no era una revisión de código sino una regla de modelado que nadie había escrito.
