# HALLAZGOS.md — be03: el reemplazo

> Fase be03. Dos cosas: la consulta que cuenta los certificados que mienten hoy, y los cambios de comportamiento
> que el backend nuevo introduce frente al mock (los que el contrato no recogía).
> Medido el 14/10/2026, con la sesión de PostgreSQL en UTC (`SHOW timezone` → `Etc/UTC`).

---

## 1. Certificados que mienten hoy (lección §5.6)

```sql
SELECT
  status AS estado_guardado,
  CASE
    WHEN revoked_at IS NOT NULL                   THEN 'revoked'
    WHEN valid_until < now()                      THEN 'expired'
    WHEN valid_until < now() + interval '30 days' THEN 'expiring'
    ELSE 'valid'
  END AS estado_real,
  count(*)
FROM certificates
GROUP BY 1, 2
ORDER BY 3 DESC;
```

```
 estado_guardado | estado_real | count
-----------------+-------------+-------
 expired         | expired     |     1
 valid           | expired     |     1
```

**Resultado: 1 de 2 certificados miente.** El `CERT-2024-000502` dice `valid` y su `validUntil` es `2025-02-10T23:59:59-05:00`.
Hoy, 14/10/2026, ya venció. El `CERT-2023-000501` coincide.

Es el mismo dato que el frontend marcó en FE10 como divergencia. Aquí se cuenta y no se arregla: se difiere a be05.

---

## 2. Cambios de comportamiento frente al mock

El contrato (`CONTRACT.md`) describe lo que el frontend necesita. Estos son los puntos en que el backend nuevo **no** hace
lo mismo que el mock, y que `smoke.sh` no comprueba:

| Caso | Mock (json-server) | Backend PHP (be03) | Por qué |
|---|---|---|---|
| `DELETE /clients/:id` con activos | Borra en cascada los activos, **todas las plantillas y las cinco inspecciones** (medido en be00) | `409` con mensaje. PostgreSQL rechaza el borrado por la clave foránea | La cascada es un efecto de json-server, no contrato. Un borrado que se lleva las plantillas es peor que un error. El frontend ya lo impide en la interfaz. |
| `GET /clients?q=` | Busca en todos los campos | Busca en `legal_name` y `tax_id` con `ILIKE` | Equivalente en la práctica. json-server buscaba en todos los campos; aquí, los dos que contienen texto útil. |
| `GET /inspections/:id/findings` | Existe | Existe, aunque el frontend no la llama | Lo exige `smoke.sh`. |
| `expiresIn` y `exp` del token | `3600` | `3600` | Igual. |
| Contraseñas | En claro en `auth.js` | `password_hash` (bcrypt) | Mejora invisible desde fuera: la única que la lección permite en be03. |
| Zona horaria de los instantes | Offset `-05:00` en el JSON | Se guarda en `timestamp` **sin zona** y se vuelve a poner `-05:00` al servir | Deuda 💸 4. Un servidor en otra zona devolvería la misma hora. Se paga en be04. |
| Orden de `/templates` | Orden de inserción del `db.json` | `ORDER BY template_id, version` | El frontend no ordena; el orden ahora es explícito. |

---

## 3. Lo que no hace el backend nuevo, a propósito

- No valida el dominio de `status`, `severity` ni `type`: son `string` libres, igual que en el mock (be03, deuda aceptada en `bea-10`).
- No hay foránea compuesta entre `inspections` y `templates`. La invariante no se sostiene en la base (be05).
- `certificates.status` se guarda y se sirve tal cual (be05).

---

## 4. Verificación

- `smoke.sh` sin modificar contra el backend PHP: `OK: 26/26` (`evidencia-be03-smoke.txt`).
- Paginación: `GET /clients` sin `_page` devuelve 3 y `X-Total-Count: 3`; `?_page=2&_limit=2` devuelve `[3]` con el mismo total.
- Login: el token lleva `sub`, `name`, `role`, `iat`, `exp`. Con `CHAOS=expired`, `expiresIn: -60` y el token vencido responde `401`.
- Siembra: inspecciones `500(in_progress)`, `501(v1, approved)`, `502(approved)`, `503(v2, rejected)`, `504(scheduled)`.

---

## Actualización del 15/10/2026

- **Dos caminos vivos (canon del autor):** el camino nuevo sirve las rutas del frontend; el viejo sigue en
  `GET /legacy/templates` y `POST /legacy/findings`. `POST /findings` del camino nuevo valida y responde `422`.
- **Bug de la clave compuesta, encontrado al reproducir be-01:** `Template::save()` con `$primaryKey = null` actualizaba todas
  las plantillas. Arreglado en el modelo y en be03 §5.2 con `setKeysForSaveQuery()`; lo vigila `TemplateCloseTest`.
- **Mensajes de integridad:** `23505` → `Ya existe un registro con esa clave`; `23503` → `La operación choca con una referencia
  a otro registro`. El detalle de la base va al log del contenedor (`error_log`), no al cliente.
- **Cableado que la lección no traía** y ahora está en be03 («Antes de sembrar»): `withEloquent()`, `config/database.php`,
  `artisan`, comandos de migración y siembra, `classmap` de los seeders, `DatabaseSeeder`, `APP_ENV=local`, rutas protegidas.
