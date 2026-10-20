# deuda.md — registro de deuda técnica (FE, zz-code)

Cifras de build de producción (`ng build --named-chunks --stats-json`), tamaño crudo.

## Fase 04 → 05: el SharedModule y la convivencia standalone

| Medida | Antes (fase 04) | Después (fase 05) | Cambio |
|---|---|---|---|
| `main.js` | 705,18 kB | 637,38 kB | −67,80 kB |
| Inicial total | 822,13 kB | 754,43 kB | −67,70 kB |
| `clients` (lazy) | `clients-module` (no medido) | `clients-routes` (583 B) + `client-list` (lazy, standalone) | — |

Lo que salió del arranque: `MatTableModule`, `MatDialogModule` y `MatSnackBarModule`. `MatTableModule`
vuelve con `ClientListComponent`; los otros dos no los usa nadie todavía.

La deuda del `SharedModule` queda reclasificada, no cerrada: los nueve módulos que siguen en
`MATERIAL_MODULES` viajan enteros a los módulos heredados que importan `SharedModule`, y `LayoutModule`
(eager) lo importa desde el arranque.

## Convivencia standalone / NgModule

- Archivo nuevo → standalone, `inject()`, `OnPush`, `imports` propios.
- Archivo heredado → se toca lo mínimo y en su propio estilo.
- Convertir un archivo es una decisión explícita, en un commit que no hace ninguna otra cosa.
- Un componente standalone se consume desde un NgModule por `imports`, nunca por `declarations`.
- Módulos convertidos: `clients` (Fase 5). Pendientes: `core`, `shared`, `layout`, `dashboard`, `assets`,
  `templates`, `inspections`, `certificates` y `auth`, sin fecha y a propósito.

## Fase 11: el panel (medido el 18/10/2026)

Máquina: Apple Silicon (arm64), Chromium 129 headless (Playwright 1.47.2) en contenedor.

| Medida | Cifra |
|---|---|
| Inicial total, con y sin los dos gráficos | 821,31 kB en los dos casos: Chart.js no está en el inicial |
| Chunk lazy del panel con gráficos | 228,26 kB (67,81 kB transferidos) |
| Chunk lazy del panel sin gráficos | 12,38 kB (3,89 kB) → Chart.js + ng2-charts ≈ 216 kB (64 kB) |
| `buildMetrics` con 200 inspecciones | 1–3,5 ms |
| `buildMetrics` con 1.000 | 5–7,5 ms |
| `buildMetrics` con 2.000 | 8–14 ms |
| `buildMetrics` con 5.000 | 14–23 ms (aquí pasa los 16 ms de un fotograma) |
| Recálculos por minuto con el panel quieto | 7 (las peticiones son 5) |
| Cuerpo de un autosave con 60 ítems (Fase 8) | 5.426 B, contra 60 B de un PATCH por respuesta |

## Fase 13: la URL horneada, saldada (medido el 18/10/2026)

| Medida | Cifra |
|---|---|
| Sitios que leían `environment.apiBaseUrl` | 7 (seis `*ApiService` y `AuthService`); el build da 8 errores con `environment.ts` |
| Specs de la Fase 12 que hubo que tocar | 2 (`finding-api` y el invariante de `inspection-state`), con un doble de `AppConfigService` |
| Inicial de producción | 819,78 kB, sin avisos de presupuesto (1 MB / 1,5 MB) |
| Imagen `certcore:fase-13` | 91 MB, 0 `.map`, sin Node ni `node_modules` |

## Fase 14: kind (medido el 18/10/2026, cluster sin hostPort, Kubernetes 1.37.0, ingress-nginx v1.15.1)

| Medida | Cifra |
|---|---|
| Imagen del mock sin `RUN node mock/seed.js` | arranca con `db.json` vacío: `/clients` → 404 |
| Rolling update con `replicas: 2` | 299 peticiones durante el reemplazo, 299 con 200 |
| Rolling update sin el Service del mock | los dos pods viejos terminados; la aplicación sin pods sanos (no hay `readinessProbe`) |
