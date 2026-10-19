// Servidor de la verificación previa P7: el giro ingenuo (MODO=ingenuo) y el
// giro transaccional (MODO=transaccional), sobre Express y PostgreSQL 13.
// Lo escribe la sesión para medir; no es código del curso.
const express = require("express");
const { Pool } = require("pg");

const MODO = process.env.MODO || "ingenuo";
const pool = new Pool({ connectionString: process.env.DATABASE_URL, max: 20 });
const app = express();
app.use(express.json());

// Giro ingenuo: lee el stock, decide y escribe en pasos separados, sin clave de
// idempotencia. Es la forma de 2019 que el mock imita.
async function giroIngenuo(req, res) {
  const { key } = req.body;
  const { rows } = await pool.query(
    "SELECT remaining FROM stock WHERE segment_id = 'esclusa-de-oro'"
  );
  if (rows[0].remaining <= 0) return res.status(409).json({ error: "agotado" });
  await pool.query(
    "UPDATE stock SET remaining = remaining - 1 WHERE segment_id = 'esclusa-de-oro'"
  );
  await pool.query(
    "INSERT INTO spin_log (player_id, key, landed_segment) VALUES ($1, $2, 'esclusa-de-oro')",
    [req.params.id, key]
  );
  res.status(200).json({ landed: "esclusa-de-oro" });
}

// Giro transaccional: clave de idempotencia única y descuento condicional en la
// misma transacción. Un reintento con la misma clave no acredita dos veces.
async function giroTransaccional(req, res) {
  const { key } = req.body;
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const upd = await client.query(
      "UPDATE stock SET remaining = remaining - 1 WHERE segment_id = 'esclusa-de-oro' AND remaining > 0"
    );
    if (upd.rowCount === 0) {
      await client.query("ROLLBACK");
      return res.status(409).json({ error: "agotado" });
    }
    try {
      // La restricción UNIQUE (key) es la que decide: dos inserciones con la misma
      // clave no pueden ganar las dos, aunque lleguen a la vez.
      await client.query(
        "INSERT INTO spin_log (player_id, key, landed_segment) VALUES ($1, $2, 'esclusa-de-oro')",
        [req.params.id, key]
      );
    } catch (e) {
      await client.query("ROLLBACK");
      if (e.code === "23505") return res.status(409).json({ error: "duplicado" });
      throw e;
    }
    await client.query("COMMIT");
    res.status(200).json({ landed: "esclusa-de-oro" });
  } catch (e) {
    await client.query("ROLLBACK");
    res.status(500).json({ error: String(e.message) });
  } finally {
    client.release();
  }
}

app.post("/players/:id/spins", (req, res) =>
  (MODO === "transaccional" ? giroTransaccional : giroIngenuo)(req, res).catch((e) =>
    res.status(500).json({ error: String(e.message) })
  )
);
app.get("/health", (_req, res) => res.send("ok"));

app.listen(3000, () => console.log(`modo=${MODO} escuchando en 3000`));
