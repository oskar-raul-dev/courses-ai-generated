# Mock de CertCore

    npm run mock     # levanta el servidor en http://localhost:3000
    npm run seed     # regenera db.json desde db.seed.json

## Inyector de caos

    CHAOS=<fallos separados por coma> npm run mock

- `latency`    — retrasa toda respuesta CHAOS_DELAY_MS (por defecto 2500)
- `error`      — devuelve 500 con probabilidad CHAOS_RATE (por defecto 0.3)
- `malformed`  — responde 200 con un cuerpo que no cumple el tipo
- `cors`       — omite la cabecera Access-Control-Allow-Origin
- `expired`    — el login firma un token que ya nació vencido
- `timeout`    — no responde nunca, con probabilidad CHAOS_RATE

Ejemplo: `CHAOS=latency,error CHAOS_RATE=0.5 npm run mock`

El caos no toca /auth/login, salvo `expired`. Si no puedes entrar, no puedes
diagnosticar.
