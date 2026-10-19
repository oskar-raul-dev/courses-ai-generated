// mock/server.js
const path = require('path');
const express = require('express');
const jsonServer = require('json-server');

const { createAuthRouter, requireToken } = require('./auth');
const { readChaosConfig, createChaosMiddleware } = require('./chaos');

const chaos = readChaosConfig(process.env);
const app = express();

app.use(express.json());

// ── 1. CORS ────────────────────────────────────────────────────────────────
// Va primero para que hasta una respuesta de error lleve sus cabeceras. Si no,
// un 500 llega al navegador sin Access-Control-Allow-Origin y lo que ves es un
// problema de CORS que no existe, tapando el error de verdad.
const breakCors = chaos.faults.includes('cors');

app.use((request, response, next) => {
  const isAuthRequest = request.path.startsWith('/auth/');

  if (!breakCors || isAuthRequest) {
    response.header('Access-Control-Allow-Origin', 'http://localhost:4200');
    response.header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Correlation-Id');
    response.header('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
  }

  if (request.method === 'OPTIONS') {
    return response.sendStatus(204);
  }

  next();
});

// ── 2. Caos ────────────────────────────────────────────────────────────────
app.use(createChaosMiddleware(chaos));

// ── 3. Autenticación ───────────────────────────────────────────────────────
app.use(createAuthRouter(chaos));
// A partir de aquí, todo exige token. El authInterceptor de la Fase 2 lo pone.
app.use(requireToken);

// ── 4. Datos ───────────────────────────────────────────────────────────────
app.use(jsonServer.router(path.join(__dirname, 'db.json')));

app.listen(3000, () => {
  const active = chaos.faults.length === 0 ? 'ninguno' : chaos.faults.join(', ');
  console.log(`Mock de CertCore en http://localhost:3000 · caos: ${active}`);
});
