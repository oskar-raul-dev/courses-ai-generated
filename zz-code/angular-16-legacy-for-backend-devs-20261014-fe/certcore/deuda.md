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
