# 🛒 Guía: comprar hardware de segunda mano en Colombia (y eBay vía courier) sin ser estafado

> Complemento de la ruta de aprendizaje: cómo conseguir las piezas del
> desktop, upgrades de las laptops y equipos ex-corporativos con riesgo mínimo.

---

## 1. Canales locales, en orden de preferencia

1. **Remates/liquidaciones corporativas y tiendas de refurbished**
   Para OptiPlex/EliteDesk/ThinkCentre y ThinkPads ex-empresa.
   Suelen dar **factura y garantía corta (1-3 meses)** — en usado, oro puro.
   En Bogotá: la zona de **Unilago** concentra tiendas de partes nuevas y
   usadas; ir en persona permite *probar antes de pagar* (regla nº 1).

2. **Mercado Libre**
   El mayor volumen. Filtrar: reputación verde alta + años de antigüedad.
   **Pagar SIEMPRE por la plataforma** (retiene el dinero, permite reclamo).
   Jamás "acordar por fuera" aunque ofrezcan descuento — ese descuento ES la estafa.

3. **Facebook Marketplace**
   Mejores precios, mayores riesgos. Reglas absolutas:
   - Encuentro presencial en lugar público (centro comercial con cámaras).
   - Probar el equipo ahí mismo.
   - Pagar al verlo funcionar. Nunca consignación anticipada "para apartar".

## 2. Checklist de prueba presencial (llevar en el teléfono)

**Preparación**: llevar un **USB con Linux live** (¡ya lo tienes por el
proyecto!) con `smartmontools`, `stress`, `lm-sensors`, `memtest`.

**PC / laptop completo**:
```text
[ ] Arranca a BIOS; specs (CPU/RAM) coinciden con lo anunciado
[ ] Bootear el USB Linux live propio y correr:
    [ ] lscpu / free -h        → verificar CPU y RAM reales
    [ ] smartctl -a /dev/sdX   → horas de encendido + sectores reubicados
        (disco con miles de horas: se descuenta o se rechaza)
    [ ] stress -c N (5 min) + sensors → si hay throttling inmediato:
        pasta seca o ventilador muerto
[ ] Todos los puertos USB, video, audio
[ ] Laptops además:
    [ ] upower -i ... → capacidad de batería diseño vs actual
    [ ] Bisagras, teclado completo, que cargue
```

**Piezas sueltas**:
```text
CPU usada    → riesgo bajo (funciona o no funciona)
RAM usada    → memtest desde el mismo USB
GPU usada    → 10 min de FurMark / glmark2 vigilando temperatura
PSU usada    → ❌ NO SE COMPRA. Punto. Una PSU mala se lleva board,
               RAM y SSD en su funeral. Nueva y de marca, siempre.
Board usada  → lotería; solo con prueba en vivo (pines, puertos, POST)
```

**Señales de alarma universales**: precio muy por debajo de mercado,
urgencia ("tengo otro comprador"), negarse a prueba presencial, fotos de
catálogo en vez del ítem real, cuenta nueva sin historial.

## 3. eBay + casillero vía courier

**Cuándo conviene**: lo que localmente escasea o está sobrevalorado
(CPUs específicas, RAM en cantidad, SSDs de marca).

**Mecanismo**: servicios de casillero (Pasarex, Aeropost, casilleros de
couriers locales) dan dirección en Miami; compras en eBay con envío
doméstico US; ellos traen a Colombia.

**La franquicia clave (TLC con EE.UU.)**: envíos courier desde EE.UU. de
**máximo USD 200 de valor declarado** entran **exentos de arancel e IVA**
(ojo: algunos operadores suman el flete al cálculo). Por encima: IVA 19% +
posible arancel sobre el total.
→ Estrategia: compras separadas bajo 200 USD en envíos separados
  (legal mientras no sea volumen comercial).
→ Verificar condiciones vigentes con el casillero al comprar: la
  reglamentación ha tenido ajustes.

**En eBay**:
- Solo vendedores 98%+ con ventas abundantes en la categoría.
- Preferir "Refurbished" o usado con foto del ítem real y política de devolución.
- eBay Money Back Guarantee cubre no-llegada o ítem distinto, PERO la
  devolución internacional desde Colombia es cara → criterio: no comprar
  nada dudoso "porque hay garantía".

**Qué traer vs qué comprar local**:
```text
TRAER (alta densidad valor/kilo, bajo riesgo de tránsito):
  CPU, RAM, SSD/NVMe, periféricos pequeños

COMPRAR LOCAL (peso/volumen matan el flete, o requieren prueba):
  Cajas, monitores, PSU, y la board mejor local CON prueba
  (riesgo de pines/daño en tránsito)
```

## 4. Referencia rápida de precios objetivo (usado, ~2026)

| Pieza | Rango razonable |
|---|---|
| Ryzen 5 3600 usado | 60-80 USD |
| Board B450 usada | 45-60 USD |
| 16 GB DDR4 usada | 30-40 USD |
| NVMe 500GB-1TB nuevo | 35-50 USD |
| PSU 450-550W nueva (marca) | 40-50 USD |
| OptiPlex 7070/3070 SFF (i5-9500) | 120-160 USD |
| RAM DDR3L (para Inspiron 7559) | ~30 USD |
| Jack DC + batería Inspiron 7559 | 40-80 USD total |

Precio muy por debajo de estos rangos sin explicación = bandera roja.
