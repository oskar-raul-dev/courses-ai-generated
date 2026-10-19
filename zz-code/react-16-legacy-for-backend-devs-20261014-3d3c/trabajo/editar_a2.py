# Edita A2 al dominio de la Esclusa (mixins de rueda, segmento y envío).
# Uso: python3 editar_a2.py <ruta-a-A2-mini-design-system.md>
import sys
from pathlib import Path

RUTA = Path(sys.argv[1])
s = RUTA.read_text(encoding="utf-8")


def rep(old, new, n=None):
    global s
    hits = s.count(old)
    if n is not None:
        assert hits == n, f"esperaba {n} y hay {hits}: {old[:70]!r}"
    else:
        assert hits >= 1, f"no aparece: {old[:70]!r}"
    s = s.replace(old, new)


rep("Tutorial React 16 — Rifas y chances", "Tutorial React 16 — La Esclusa, la consola de Jewel Locks", 1)
rep("7. [Mixins del dominio de rifas](#7-mixins-del-dominio-de-rifas)",
    "7. [Mixins del dominio de la rueda](#7-mixins-del-dominio-de-la-rueda)", 1)
rep('"vendido" de un número deja de ser rojo `#dc3545` y pasa a ser un gris apagado',
    '"agotado" de un segmento deja de ser rojo `#dc3545` y pasa a ser un gris apagado', 1)
rep("a la tabla de números, al badge del detalle y al dashboard.",
    "a la tabla de segmentos, al badge del detalle y al dashboard.", 1)
rep(".raffle-card {\n  border-top: 4px solid tokens.$primary;",
    ".wheel-card {\n  border-top: 4px solid tokens.$primary;", 1)
rep("// Tokens del mini design system de Rifas y chances.", "// Tokens del mini design system de La Esclusa.", 1)
rep('$success: #28a745;   // verde "abierta / disponible"', '$success: #28a745;   // verde "en vivo / disponible"', 1)
rep('$danger:  #dc3545;   // rojo "cerrada / vendido"', '$danger:  #dc3545;   // rojo "terminada / agotado"', 1)
rep('$muted:   #6c757d;   // gris "resuelta / liquidada / inactivo"', '$muted:   #6c757d;   // gris "conciliada / inactivo"', 1)
rep('$warning: #f0ad4e;   // ámbar "reservado / por vencer"', '$warning: #f0ad4e;   // ámbar "programada / por vencer"', 1)
rep('$font-mono: "SFMono-Regular", "Consolas", monospace; // para los números 0000-9999',
    '$font-mono: "SFMono-Regular", "Consolas", monospace; // para pesos, contadores y IDs', 1)
rep("""> 💡 **Por qué `$font-mono` importa en este dominio.** Los números de rifa son
> `0000`–`9999`, siempre cuatro dígitos con ceros a la izquierda. En una fuente
> proporcional, `1111` es más angosto que `0000` y las columnas de la tabla
> bailan. Monoespaciada, todos los números ocupan lo mismo y la tabla queda
> prolija. Es una decisión de diseño con causa de dominio, no capricho.""",
    """> 💡 **Por qué `$font-mono` importa en este dominio.** Los pesos de los
> segmentos se muestran en puntos básicos (`3000`, `2000`, `50`), y los
> contadores de la bitácora suben de a uno. En una fuente proporcional, `1111`
> es más angosto que `0000` y las columnas de la tabla bailan. Monoespaciada,
> todos los números ocupan lo mismo y la tabla queda prolija. Es una decisión
> de diseño con causa de dominio, no capricho.""", 1)
rep("## 7. Mixins del dominio de rifas", "## 7. Mixins del dominio de la rueda", 1)
rep("""// --- 1) Filete de color arriba de una card, según estado de rifa ---
// El patrón visual "card con borde superior de color" se repite en el
// listado de rifas, el detalle y el dashboard. Un mixin lo centraliza.
@mixin raffle-accent($status) {""",
    """// --- 1) Filete de color arriba de una card, según estado de la rueda ---
// El patrón visual "card con borde superior de color" se repite en el
// listado de ruedas, el detalle y el dashboard. Un mixin lo centraliza.
@mixin wheel-accent($status) {""", 1)
rep("""// --- 2) Celda de número según estado (disponible/reservado/vendido) ---
// La grilla 0000-9999 pinta 10.000 celdas por estado. Este es EL mixin
// más usado de la app de rifas.
@mixin number-state($status) {
  font-family: tokens.$font-mono;   // números alineados
  background: fn.status-color($status);
  color: #fff;
  @if $status == "available" {
    cursor: pointer;                // solo lo disponible es clickeable""",
    """// --- 2) Celda de segmento según su stock (disponible/limitado/agotado) ---
// La tabla de segmentos pinta una celda por segmento y por estado. Este es
// EL mixin más usado de la consola en el listado de segmentos.
@mixin segment-state($status) {
  font-family: tokens.$font-mono;   // pesos alineados
  background: fn.status-color($status);
  color: #fff;
  @if $status == "available" {
    cursor: pointer;                // solo lo disponible es clickeable""", 1)
rep("""// --- 3) Badge de estado de rifa (texto + color de fondo) ---
@mixin status-badge($status) {""",
    """// --- 3) Badge de estado de envío o de rueda (texto + color de fondo) ---
// El mismo badge sirve al estado de un envío (queued, sent…) y al de una rueda.
@mixin status-badge($status) {""", 1)
rep(""".raffle-card {
  @include raffle-accent("open");
}

.number-cell {
  &--available { @include number-state("available"); }
  &--reserved  { @include number-state("reserved"); }
  &--sold      { @include number-state("sold"); }
}

.raffle-status { @include status-badge("closed"); }""",
    """.wheel-card {
  @include wheel-accent("live");
}

.segment-cell {
  &--available { @include segment-state("available"); }
  &--limited   { @include segment-state("limited"); }
  &--soldout   { @include segment-state("soldout"); }
}

.grant-status { @include status-badge("sent"); }""", 1)
rep("""- **Clases, variables, mixins y functions van en inglés.** `.raffle-card`, no
  `.tarjeta-rifa`.""", """- **Clases, variables, mixins y functions van en inglés.** `.wheel-card`, no
  `.tarjeta-rueda`.""", 1)
rep("nombres de dominio claros (`raffle-`, `number-`, `status-`)", "nombres de dominio claros (`wheel-`, `segment-`, `status-`)", 1)
rep("`RaffleForm.scss`", "`WheelForm.scss`", 1)
rep("| Las columnas de números \"bailan\" | Fuente proporcional en la grilla | Aplicar `$font-mono` vía `number-state` |",
    "| Las columnas de pesos \"bailan\" | Fuente proporcional en la tabla | Aplicar `$font-mono` vía `segment-state` |", 1)
rep("color hacia el mixin `raffle-accent`", "color hacia el mixin `wheel-accent`", 1)
rep("un badge de rifa o una celda de número", "un badge de rueda o una celda de segmento", 1)
RUTA.write_text(s, encoding="utf-8")
print("A2 editado")
