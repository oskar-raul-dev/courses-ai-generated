# 🔗 El encaje con el laboratorio de contenedores

> Propuesta: arquitectura para desarrolladores Java senior
> **Este es el documento que decide si los dos materiales se potencian o se
> estorban.** Todo lo demás depende de que la costura de aquí esté bien puesta.

---

## 1. El riesgo, dicho primero

Dos materiales que comparten dominio, repositorio y servicios tienen dos formas
conocidas de salir mal:

**Se solapan.** Las sagas aparecen en el Anillo 3 del laboratorio y en una fase del
curso, contadas de forma parecida y con conclusiones ligeramente distintas. El
lector no sabe cuál manda y acaba desconfiando de los dos.

**Se acoplan de más.** El curso no puede avanzar porque el laboratorio no llegó a su
Anillo 4, y el laboratorio no puede tocar nada porque el curso asume el sistema en
un estado concreto. Los dos calendarios se bloquean mutuamente.

Lo que sigue está diseñado para evitar las dos cosas.

---

## 2. La costura, en una frase

> 🧭 **El laboratorio enseña a operar el sistema. El curso enseña a decidir cómo
> debería ser el sistema.**

De ahí sale la regla de reparto, que resuelve el 90% de los casos dudosos:

| Si la pregunta es… | Es del… |
|---|---|
| **¿cómo se despliega / se observa / se arregla esto?** | laboratorio |
| **¿debería existir esto, y qué cuesta?** | curso |

Un ejemplo concreto con el tema más disputado, las sagas:

- **Laboratorio (Anillo 3):** cómo se despliega una saga en el cluster, cómo se ven
  sus pasos en Tempo, qué pasa con los reintentos de Kubernetes, cómo se diagnostica
  una compensación que no llegó.
- **Curso:** por qué este proceso necesita una saga y no una transacción, cuál es la
  ventana de inconsistencia que estás aceptando, qué pasa cuando la compensación
  **también** falla, y —la pregunta que el laboratorio no hace— **si el reparto de
  servicios que obliga a esta saga era el correcto**.

Los dos tratan sagas. Ninguno repite al otro.

---

## 3. El reparto, tema por tema

| Tema | Laboratorio | Curso | Nota |
|---|---|---|---|
| Cluster, Helm, kind | **todo** | — | El curso lo usa, no lo enseña |
| Dockerfiles y empaquetado | **todo** | — | |
| Observabilidad: montarla | **todo** | — | Prometheus, Grafana, Loki, Tempo |
| Observabilidad: **qué medir y por qué** | lo básico | **el resto** | Métricas de arquitectura, funciones de aptitud |
| Certificados y TLS: operación | **todo** (C1–C4, lab de incidentes) | — | |
| Seguridad como **diseño** | — | **todo** | Zero trust, superficie, dónde va el límite de confianza |
| Contratos REST | los define | **los versiona y los prueba** | Contract testing, compatibilidad |
| gRPC: desplegarlo, HTTP/2 en k8s | **todo** (Anillo 2) | — | |
| gRPC: **cuándo y a qué precio** | — | **todo** | El eje REST / gRPC / eventos |
| Sagas: desplegarlas y depurarlas | **todo** (Anillos 3–4) | — | |
| Sagas: **diseñarlas y decidirlas** | — | **todo** | Orquestada vs coreografiada, compensaciones |
| Eventos: la infraestructura | **todo** (Anillo 4) | — | Redis pub/sub o NATS |
| Eventos: outbox, idempotencia, entrega | — | **todo** | La garantía, no el transporte |
| Base de datos por servicio | la monta | **la cuestiona** | ¿Era la frontera correcta? |
| Migración Java 17 → 25 | la ejecuta (Anillo 5) | **la planifica** | Expand/contract, reversibilidad |
| GraalVM nativo | lo compila y mide (Anillo 6) | **decide si compensa** | |
| Service mesh y NetworkPolicies | **todo** (Anillo 7) | lo usa como dato | |
| Modelado de dominio, agregados | — | **todo** | No está en el laboratorio |
| Transacciones y consistencia | — | **todo** | Ídem |
| Monolito modular | — | **todo** | **La fase que el laboratorio no puede tener** |
| ADRs, C4, evaluación | — | **todo** | |
| Conway, equipos, coste | — | **todo** | |

### La asimetría que hay que entender

El laboratorio **da por buena la arquitectura** del juguete: cuatro servicios,
base de datos por servicio, REST entre ellos. Tiene que darla por buena, porque su
tema es la infraestructura y necesita un sistema estable sobre el que trabajar.

El curso hace lo contrario: **la primera cosa que hace es auditar esa arquitectura y
encontrarle los defectos.** Y encuentra unos cuantos, porque el plan maestro del
laboratorio los sembró a propósito.

---

## 4. Los defectos sembrados: el regalo del laboratorio

Esto es lo que hace que el encaje funcione de verdad. El laboratorio no construyó un
sistema perfecto: construyó uno **con problemas reales y declarados**, que son
exactamente los casos de estudio del curso.

**1. El fire-and-forget entre `inventory` y `replenish`.**
El plan maestro lo dice con todas las letras: *"la venta no falla si replenish está
caído. Esto siembra la motivación real del Anillo 4 (eventos): ¿qué pasa si esa
llamada se pierde?"*

Para el laboratorio es la motivación de un anillo. **Para el curso es una fase
entera**: una escritura de negocio y una notificación que tienen que ocurrir juntas
o no ocurrir, sin transacción distribuida entre ellas. Es el patrón outbox, y es el
caso canónico de "dos fronteras donde debería haber una".

**2. `replenish` avisa a `inventory` para sumar stock.**
Una llamada de vuelta que cierra un ciclo entre dos servicios. En cuanto hay un
ciclo en el grafo de dependencias, la pregunta *"¿por qué son dos servicios?"* se
vuelve legítima. **Material de la fase de fronteras de servicio.**

**3. `inventory` valida el producto llamando a `catalog` en cada venta.**
Una llamada síncrona en el camino crítico de la operación más frecuente del sistema.
Acopla la disponibilidad de la venta a la de `catalog`. Las opciones —caché,
réplica de solo lectura, validación diferida, o aceptar el acoplamiento— son un
análisis de compromisos completo con números medibles en el cluster.

**4. Base de datos por servicio, estricta.**
El laboratorio la impone como regla. El curso pregunta qué costó: cada consulta que
cruza servicios, cada informe que necesita dos fuentes, cada consistencia que ya no
es transaccional. **Y termina preguntando si tres bases de datos para veinte
productos y tres sucursales eran necesarias.**

**5. Cuatro lenguajes.**
Go, Java, Node y MicroProfile. El laboratorio lo hace para practicar contenedores
políglotas. El curso lo evalúa: qué cuesta en herramienta, en contratación, en
observabilidad uniforme y en el conocimiento que hay que mantener vivo por lenguaje.

> 💡 **Ninguno de los cinco es un error del laboratorio.** Son decisiones razonables
> para su objetivo. Que sean discutibles **para otro objetivo** es exactamente lo
> que los convierte en buen material de arquitectura: en un sistema real, casi todas
> las decisiones dolorosas fueron razonables cuando se tomaron.

---

## 5. La dependencia de calendario

El curso **necesita el Anillo 0 del laboratorio cerrado** para su fase 00. Nada más.

```text
LABORATORIO                          CURSO
Oleada 0  walking skeleton
Oleada 1  DB + un endpoint
Oleada 2  flujo end-to-end
────────── Anillo 0 cerrado ──────►  Fase 00  auditoría del punto de partida
Anillo 0.5 persistencia               Fase 01  fronteras de módulo
Anillo 1  reports                     Fase 02  fronteras de transacción
Anillo 2  gRPC             ◄────────► Fase 05  el eje de comunicación
C1, C2    TLS                         Fase 03  fronteras de dominio
Anillo 3  saga orquestada  ◄────────► Fase 06  consistencia distribuida
Anillo 4  saga coreografiada◄───────► Fase 06
Anillo 7  mesh + mTLS      ◄────────► Fase 10  seguridad como arquitectura
Anillo 5  Java 17 → 25     ◄────────► Fase 12  migración y modernización
Anillo 6  GraalVM          ◄────────► Fase 08  modelo de ejecución y rendimiento
```

**Las flechas dobles son los puntos de encuentro**, y ahí hay una decisión de método
que importa:

> 🧭 **El curso va primero en los puntos de encuentro.** Se diseña y se decide, y
> después el laboratorio despliega lo decidido.
>
> Es lo contrario de cómo suele pasar en la vida real —donde alguien despliega algo
> y después se justifica—, y es justamente el hábito que el curso quiere instalar.

Con la excepción del Anillo 0, que va primero por necesidad: no se puede auditar un
sistema que no existe.

---

## 6. Cómo trabajan sobre el mismo repositorio

**Propuesta: ramas con propósito, no un repositorio aparte.**

```text
main                    el estado del laboratorio, siempre desplegable
  │
  ├── arq/fase-01-modulos        el curso mueve una frontera
  ├── arq/fase-02-transacciones
  ├── arq/experimento-monolito   ← la rama que más enseña de todo el curso
  └── arq/…
```

Tres reglas que lo sostienen:

**1. El curso no rompe `main`.** Cada fase trabaja en su rama. Lo que se demuestra
valioso se fusiona con un ADR que lo justifique; lo que era un experimento se queda
en su rama **y se conserva**, porque una rama con un experimento fallido y su
medición vale tanto como una fusionada.

**2. Cada fusión lleva su ADR.** Es la regla que convierte el repositorio en un
historial de decisiones en vez de en un historial de commits.

**3. Las funciones de aptitud viven en `main`.** Las reglas de ArchUnit, los
límites de acoplamiento, el presupuesto de latencia — se añaden en `main` desde la
fase 01 y a partir de ahí **el laboratorio también las tiene que pasar**. Es la
única dirección en la que el curso impone algo sobre el laboratorio, y es
deliberada: una arquitectura que no se verifica sola se degrada sola.

---

## 7. La rama que más enseña: `arq/experimento-monolito`

Merece su propia sección porque es la idea más fuerte del encaje.

**El experimento:** reunir `inventory`, `replenish` y `catalog` en **un solo
despliegue Java modular** —módulos de Java con fronteras reales verificadas por
ArchUnit, una sola base de datos con esquemas separados, y las llamadas entre
módulos como invocaciones directas en vez de HTTP.

Y después **medirlo contra la versión distribuida**, en el mismo cluster, con la
misma carga y las mismas métricas que el laboratorio ya expone:

| | 4 servicios | Monolito modular |
|---|---|---|
| Latencia p99 de una venta | | |
| Consistencia del flujo venta → reposición | eventual | **transaccional** |
| Pods, memoria total, coste estimado | | |
| Tiempo de despliegue de un cambio en un módulo | | |
| Radio de impacto de un fallo | | |
| Complejidad operativa (piezas que mantener) | | |
| Lo que se pierde: despliegue independiente, escalado por servicio, políglota | — | |

**El resultado previsible —y hay que decirlo antes de medir, como manda la regla—
es que para un sistema de este tamaño el monolito modular gana en casi todo.** Que
el experimento confirme lo que ya sospechas no lo hace menos valioso: lo hace
**defendible**, que es la diferencia.

Y el veredicto honesto tiene que incluir la otra dirección: **qué tendría que ser
verdad de este sistema para que los cuatro servicios fueran la respuesta correcta.**
Equipos independientes, ritmos de despliegue distintos, perfiles de escalado
divergentes, aislamiento de fallo exigido por contrato. Si nada de eso se cumple, la
separación era decoración.

> ⚖️ **Esa es la conversación de arquitectura más valiosa que hay ahora mismo en el
> mercado**, y es la que este encaje permite tener con datos propios en vez de con
> opiniones de conferencia.

---

## 8. Qué pasa si el laboratorio no avanza

El curso no puede quedarse bloqueado esperando anillos. Tres salidas, en orden de
preferencia:

1. **El curso implementa lo que necesita, en su rama.** Si la fase 06 necesita una
   saga y el Anillo 3 no llegó, el curso la escribe —le interesa el diseño, no el
   despliegue— y el laboratorio la recoge después si quiere.
2. **La fase se reordena.** Las fases del bloque de fronteras internas (01–03) no
   dependen de ningún anillo más allá del 0: se pueden adelantar.
3. **La fase se marca como dependiente y se aplaza.** Última opción, y hay que
   declararla en el mapa de fases para que el lector no se encuentre con un hueco.

> ⚠️ **La dependencia inversa no existe.** El laboratorio nunca depende del curso:
> puede recorrerse entero sin que el curso exista. Esa asimetría es intencional y
> hay que mantenerla, porque el laboratorio es el que sostiene el sistema.

---

## 9. Lo que hay que decidir para cerrar este documento

1. **¿Repositorio compartido con ramas, o repositorio propio del curso?**
   *Recomendación: compartido.* Es donde está todo el valor del encaje.

2. **¿El reparto de la tabla de §3 es correcto?** En particular: sagas, gRPC y
   eventos quedan **repartidos** —infraestructura al laboratorio, diseño al curso—.
   Es la decisión que más riesgo de solape tiene.

3. **¿El curso puede imponer funciones de aptitud sobre `main`?** Es la única
   dirección en la que afecta al laboratorio, y conviene que sea explícito.

4. **¿El experimento del monolito modular es una fase del curso o un anillo del
   laboratorio?** *Recomendación: fase del curso.* El laboratorio lo desplegaría;
   el curso es quien tiene que decidirlo y defenderlo.

5. **¿Se escribe una nota en el plan maestro del laboratorio** apuntando a este
   curso, o los dos se mantienen independientes en su documentación? El README de
   propuestas dice que no se debe referenciar un borrador como material disponible,
   así que hasta que alguno se promueva, la respuesta por defecto es **no**.
