# 🗺️ Portalón — Alcance del proyecto

> Curso de la Ruta NoSQL — modelo **clave-valor en memoria**, con TTL nativo y
> estructuras de datos. Este documento fija qué construye el curso, qué deja
> fuera a propósito, contra qué mercado real se valida, y cuándo el modelo
> **no** es la respuesta. Es la referencia para no diluir el foco al redactar
> cualquier fase.

---

## ✅ Qué construye el curso

El curso construye **Portalón**, una puerta de entrada (gateway) de API que
se sienta delante de un backend transaccional real y resuelve, con un mismo
motor clave-valor, cuatro problemas de estado **caliente y efímero**:

1. **Rate limiting** — límite de peticiones por IP y por usuario, con
   contador de ventana fija y ventana deslizante.
2. **Sesiones** — autenticación con expiración nativa (TTL) e invalidación
   explícita (logout, "cerrar todas las sesiones").
3. **Cola de trabajos** — encolado de trabajo diferido (envío de email,
   generación de reporte) con lista bloqueante y, como evolución, streams con
   grupos de consumidores.
4. **Leaderboard** — ranking en vivo mantenido con un sorted set, con
   consultas de top-N y de rango individual.

Sobre esa base funcional, el curso construye además el aparato que hace
**medible** cada decisión, y que es tan parte del entregable como el gateway
mismo:

- El **arnés `scripts/vs.ts`**, que corre la misma operación semántica contra
  Valkey, Redis, Dragonfly y —cuando aplica— PostgreSQL, y vuelca latencia
  (p50/p95/p99) y throughput a `BENCHMARKS.md`.
- El **generador de datos** sintéticos (IPs, sesiones, trabajos, jugadores)
  con distribuciones realistas.
- Los **artefactos acumulativos** `INSTINTOS.md` (predicción → medición →
  veredicto de cada instinto relacional puesto a prueba) y `BENCHMARKS.md`
  (todo "vs" medido, nunca narrado).
- La **autopsia medida del villano** — Redis/Valkey usado como base de datos
  primaria en vez de capa caliente — con números de antes y después.
- La **coda multi-lenguaje**: un subsistema representativo (por defecto, el
  rate limiter de ventana deslizante) portado a Java y Go contra los mismos
  tres motores, para demostrar que lo aprendido es un modelo de acceso, no
  un cliente de Node.

El curso también deja al lector con dos decisiones de arquitectura tomadas
con criterio propio, no por costumbre: **qué motor clave-valor elegir en
2026** (Valkey, Redis o Dragonfly, con su trasfondo de licencia y
gobernanza) y **qué familia de cliente adoptar** (idiomático clásico vs
Valkey GLIDE unificado).

---

## 🚫 Qué queda fuera (a propósito)

Nombrar lo que el curso **no** hace es tan importante como nombrar lo que
hace: evita que una fase se infle intentando cubrir un caso que pertenece a
otro curso de la ruta o a otra disciplina.

- **No es un curso de arquitectura de microservicios.** Portalón es un
  gateway de ejemplo suficientemente real para que el patrón de acceso
  aparezca sin forzarlo, no un framework de producción listo para adoptar
  tal cual.
- **No enseña la fuente de verdad del negocio.** El usuario real, el ticket
  real, el pago real viven en el Postgres detrás de Portalón; ese backend es
  atrezzo suficiente para medir, no el objeto de estudio.
- **No es un curso de colas de mensajería durables.** La Fase 3 mide dónde
  está la frontera entre una cola ligera en memoria y una cola seria y
  durable (tipo broker dedicado), pero no construye ni compara brokers de
  mensajería como Kafka o RabbitMQ: eso excede el modelo clave-valor y su
  patrón de acceso.
- **No es un curso de seguridad de gateway.** Autenticación, autorización y
  políticas de acceso aparecen en la medida en que dan forma a la sesión y
  al rate limit; el curso no cubre OAuth, WAF ni gestión de secretos como
  temas propios.
- **No cubre búsqueda de texto completo ni consultas ad-hoc sobre valores.**
  Es, de hecho, parte de lo que el villano pierde: se **nombra y se mide**
  como carencia, no se construye como funcionalidad del curso.
- **No profundiza en el motor de scripting Lua más allá de lo que exige la
  atomicidad del gateway** (Fase 5). Lua como lenguaje general queda fuera.
- **No es un curso de Kubernetes ni de operaciones de clúster a escala
  productiva.** La Fase 9 (escala) cubre el modelo de clustering y
  particionado de cada motor a nivel conceptual y de laboratorio, no el
  despliegue operativo en un orquestador real.
- **La coda no es un tour de lenguajes.** Se porta **un** subsistema
  acotado (propuesta: el rate limiter de ventana deslizante) a Java y Go,
  no los cuatro subsistemas completos; el objetivo es demostrar
  portabilidad del modelo, no enseñar Java o Go desde cero.

> ⚠️ **Frontera con el resto de la ruta.** CouchDB (offline-first) no
> aparece en este curso: vive en el curso 7. Couchbase (rival documental)
> tampoco: vive en el curso 0. Portalón solo compara clave-valor en memoria
> (Valkey/Redis/Dragonfly) contra su rival de control relacional
> (PostgreSQL).

---

## 🏪 Mercado real contra el que se valida (productizable: ✅ Fuerte)

Cada uno de los cuatro subsistemas de Portalón tiene una contraparte
comercial viva, lo que ancla el aprendizaje a una necesidad de negocio real
y no a un ejercicio de laboratorio:

| Subsistema del curso | Categoría de mercado real | Ejemplos de la categoría (no exhaustivo) |
|---|---|---|
| Rate limiting | Gateways de API gestionados y limitadores de tasa como servicio | Kong, AWS API Gateway, Cloudflare rate limiting |
| Sesiones | Session stores y proveedores de identidad gestionados | Servicios de sesión de proveedores cloud, capas de sesión delante de apps monolíticas |
| Cola de trabajos | Colas y brokers ligeros como servicio | Colas gestionadas de proveedores cloud, sistemas de jobs en background de frameworks populares |
| Leaderboard | Plataformas de ranking y gamificación para gaming/social | Servicios de leaderboard gestionado para juegos y apps sociales |

Que ese mercado exista —que haya empresas cobrando por resolver exactamente
estos cuatro problemas— es la prueba de que el patrón de acceso es real y de
que el modelo clave-valor es la respuesta correcta a esa forma, no una
elección estética del curso.

---

## ⚖️ Árbol de decisión: cuándo NO usar clave-valor en memoria

El curso cierra cada frontera de uso con un árbol honesto. Se camina de
arriba hacia abajo; la primera respuesta que aplica marca la salida.

1. **¿El dato es la fuente de verdad del negocio (no derivado, no
   reconstruible)?**
   → **Sí:** no uses clave-valor en memoria como base primaria. Este es
   exactamente el villano del curso. Usa un motor con durabilidad
   transaccional seria.
   → **No:** sigue al punto 2.

2. **¿Vas a necesitar consultas ad-hoc que no anticipaste al modelar
   ("dame todos los X que cumplan Y", sin índice secundario diseñado de
   antemano)?**
   → **Sí:** clave-valor no te lo da sin construir tus propios índices a
   mano. Considera un motor con consultas ad-hoc reales.
   → **No:** sigue al punto 3.

3. **¿El dataset completo, con margen, excede la memoria disponible del
   clúster que estás dispuesto a operar?**
   → **Sí:** no fuerces el dataset entero en RAM; usa clave-valor como capa
   caliente delante de un almacén más grande, no como el todo.
   → **No:** sigue al punto 4.

4. **¿La durabilidad ante caída del proceso es innegociable (no toleras
   perder lo escrito en los últimos segundos)?**
   → **Sí:** revisa qué garantías de persistencia ofrece cada motor (Fase 7)
   antes de comprometerte; si ni el mejor snapshotting/append-only del motor
   te alcanza, no es tu capa de verdad.
   → **No:** sigue al punto 5.

5. **¿La operación es, en esencia, "lee/escribe esta clave, rápido, y
   olvídala sola después de N segundos" (rate limit, sesión, cola ligera,
   ranking en vivo)?**
   → **Sí:** estás en el patrón exacto de Portalón. Clave-valor en memoria
   es la herramienta correcta.
   → **No:** probablemente el dominio pertenece a otro curso de la ruta
   (documental, columnar, grafo, búsqueda) — vuelve al marco de 5 preguntas
   general de la ruta.

> 🩻 El árbol no es exclusivo de "todo o nada": el patrón más común y sano en
> producción es **clave-valor como amortiguador delante de un sistema
> pesado**, no como reemplazo de ese sistema. Portalón es, literalmente, ese
> patrón construido y medido.

---

## 🎼 Alcance específico de la coda (Fase 12)

La coda **no** es alcance adicional del modelo: es la prueba de que el
alcance ya definido (rate limiting con TTL, sorted set, atomicidad) es
portable entre runtimes. Queda:

- **Dentro:** portar el rate limiter de ventana deslizante a Java y Go,
  contra los mismos tres motores en memoria, midiendo con el mismo `vs.ts`
  (o un arnés hermano por lenguaje) y comparando cliente idiomático clásico
  contra Valkey GLIDE.
- **Fuera:** portar los otros tres subsistemas; enseñar Java o Go como
  lenguaje general; comparar frameworks web de Java/Go entre sí.

---

## 🧩 Decisión de alcance pendiente

- [ ] Confirmar si la autopsia del villano (Fase 11) implementa el sistema
  de negocio completo en clave-valor o solo lo suficiente para medir la
  carencia de consultas ad-hoc y la pérdida de memoria/durabilidad (la
  semilla propone: *lo justo para medir*, no un sistema completo — ver
  `01-portalon-semilla.md`).
