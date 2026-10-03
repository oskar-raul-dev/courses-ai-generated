# 🎭 Propuestas de historia
## Laboratorio de contenedores y Kubernetes local

> **Qué es este documento:** el registro de cómo se eligió la empresa del curso. **Ya no decide
> nada**: la historia vive en [`00-historia-de-la-vecina.md`](../00-historia-de-la-vecina.md), y este
> documento no se cita.
> **Fecha:** 30/09/2026.
>
> ✅ **Decisión (D18, 30/09/2026):** ninguna de las tres candidatas de abajo tal cual. Oskar eligió
> una variante de la B: **una cooperativa de droguistas de Santander** —Bucaramanga, Floridablanca y
> Girón— que creció a Boyacá desde Tunja en 2006, después a Cundinamarca y Bogotá, casada con
> Oracle en el núcleo y con Microsoft en el puesto de trabajo, y cuyo POC para salir del monolito
> es el curso. Se llama **Droguerías La Vecina**. Del camino hasta ahí quedaron estas decisiones: el
> préstamo entre droguerías como transacción distribuida, el arco GlassFish comercial → WebLogic →
> POC, la discusión de nube entre OCI y Azure, el proxy corporativo como incidente y las
> exclusiones del dominio farmacéutico. El criterio de §1 se mantuvo, y la historia lo cumple.

---

## 1. 🧭 Lo que la historia tiene que aguantar

1. **Una transacción distribuida con consecuencia real.** No basta con mover stock: la Parte IV
   necesita una venta que, si falla a la mitad, deja a alguien sin algo que pagó o con algo que no
   existe. Es lo que hace que "deshacer es una operación de negocio" signifique algo.
2. **Cuatro stacks sin tratamiento legacy.** Cada servicio tiene que tener una razón creíble para
   estar escrito en lo que está, y esa razón no puede ser "es viejo". Lo creíble en una empresa
   mediana latinoamericana: equipos distintos, una adquisición reciente, una agencia que entregó una
   parte.
3. **Una razón para un laboratorio local.** Alguien en la empresa necesita aprender la plataforma
   **antes** de migrar, sin romper producción ni pagar un cluster de pruebas. Esa persona o ese
   equipo es la voz que encarga las cosas.
4. **Voces para los encargos.** Los incidentes y las escenas de apertura de cada fase se escriben
   en la voz de alguien con nombre. Hacen falta tres o cuatro personajes, no más, y ninguno puede
   ser el villano (guía §2.1).
5. **Dominio mínimo.** Las siete entidades del contrato (`product`, `category`, `store`,
   `stockLevel`, `stockMovement`, `replenishmentOrder`, `price`) y nada más. La historia no puede
   pedir una octava sin que se decida aquí.
6. **Nada de cifras que el laboratorio no pueda sostener.** Si la historia dice "30.000 ventas por
   hora", la F16 tiene que poder hablar de eso sin mentir sobre un portátil.

---

## 2. 🛒 Candidata A — Una cadena regional de supermercados

**La empresa.** Cuarenta y tantas tiendas en una región de un país andino, un centro de
distribución y una tienda online que creció durante la pandemia y nunca dejó de crecer. **Es la
continuación directa del brief original del laboratorio**, que partió del inventario de
supermercados.

**Por qué cuatro stacks.** El inventario de tiendas lo escribió el equipo interno en Java; el
catálogo de la tienda online lo entregó una agencia en Laravel; la reposición viene de una startup
logística que la empresa compró el año pasado, en Node; y el equipo de plataforma nuevo, de dos
personas, escribió el servicio de precios en Go porque era el primero que les tocó.

**La transacción con consecuencia.** La caja de una tienda y la tienda online compiten por la
última unidad. Si la venta online descuenta stock y la reposición no se dispara, la góndola queda
vacía un fin de semana; si la venta se cobra y el stock no existía, alguien pagó por algo que no
va a recibir.

**La razón del laboratorio.** Todo corre hoy en máquinas virtuales con compose, y la gerencia
anunció la migración a un Kubernetes gestionado. La líder del equipo de plataforma arma el
laboratorio para que los cuatro equipos aprendan en casa lo que van a operar.

**Riesgo.** Es el dominio más visto en tutoriales. Hay que darle textura propia (la góndola, el
fin de mes, el centro de distribución) para que no suene a ejemplo genérico.

## 3. 💊 Candidata B — Una cadena de farmacias

**La empresa.** Una cadena mediana de farmacias con atención extendida, un depósito central y
reparto a domicilio.

**Por qué cuatro stacks.** El mismo patrón de equipos y adquisición que la candidata A.

**La transacción con consecuencia.** La más fuerte de las tres: vender un medicamento que no está
en la sucursal no es una góndola vacía, es un paciente sin tratamiento esa noche. La reposición
urgente entre sucursales tiene una consecuencia que cualquiera entiende.

**Riesgo.** La tentación de dominio es enorme (recetas, lotes, vencimientos, regulación), y el
curso tiene que resistirla en cada fase. Si se elige, la historia dice explícitamente qué no se
modela.

## 4. 🧱 Candidata C — Una cadena de materiales de construcción

**La empresa.** Tiendas de materiales para obra con venta a contratistas: pedidos grandes,
retiros programados y stock reservado por obra.

**La transacción con consecuencia.** Un camión que sale a una obra con un pedido que el depósito
no tenía completo.

**Riesgo.** La reserva de stock por obra empuja hacia un modelo de pedidos más rico que el
contrato actual, y probablemente pediría una octava entidad.

---

## 5. ⚖️ Recomendación

**La candidata A**, por continuidad con el brief original y porque su dominio es el que menos
tienta a crecer. De la B conviene robar la **consecuencia**: que alguien pague por algo que no va a
recibir es tan claro como el medicamento que falta, y cabe en un supermercado.

Lo que P10 tiene que decidir, además de la candidata: el país (que fija el vocabulario del negocio
sin cambiar el tuteo neutro del curso), el nombre de la empresa, los tres o cuatro personajes con
su papel, y las cifras de la historia acotadas a lo que el laboratorio puede sostener (§1.6).
