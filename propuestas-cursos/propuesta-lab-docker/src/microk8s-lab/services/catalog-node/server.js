// catalog-node — microservicio de catálogo (Node + Express)
//
// Simple a propósito: expone un catálogo de productos vía REST.
// Es el primer servicio que desplegamos (Fase 1) porque es el más
// fácil de razonar. Otros servicios lo consultan por su nombre DNS
// interno de Kubernetes: http://catalog-node:3000

const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

// Catálogo en memoria (en un caso real vendría de una DB)
const products = [
  { id: 'p1', name: 'Teclado mecánico', price: 89.9, stock: 12 },
  { id: 'p2', name: 'Monitor 27"',      price: 249.0, stock: 5  },
  { id: 'p3', name: 'Mouse ergonómico', price: 45.5, stock: 30 },
];

// Healthcheck — Kubernetes lo usa para liveness/readiness probes.
// Si esto no responde 200, K8s reinicia o saca el pod del balanceo.
app.get('/healthz', (_req, res) => res.json({ status: 'ok' }));

// Listar todo el catálogo
app.get('/products', (_req, res) => res.json(products));

// Consultar un producto (lo usará orders-java al crear un pedido)
app.get('/products/:id', (req, res) => {
  const p = products.find(x => x.id === req.params.id);
  if (!p) return res.status(404).json({ error: 'not found' });
  res.json(p);
});

app.listen(PORT, () => {
  console.log(`catalog-node escuchando en :${PORT}`);
});
