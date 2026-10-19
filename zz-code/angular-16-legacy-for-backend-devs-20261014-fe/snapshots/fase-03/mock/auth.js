// mock/auth.js
const express = require('express');
const jwt = require('jsonwebtoken');

const JWT_SECRET = 'certcore-dev-secret';
const TOKEN_TTL_SECONDS = 3600;

const USERS = [
  { email: 'inspector@certcore.co', password: 'certcore123',
    sub: 'INS-15', name: 'Ana Restrepo', role: 'inspector' },
  { email: 'supervisor@certcore.co', password: 'certcore123',
    sub: 'SUP-02', name: 'Diego Marín', role: 'supervisor' },
];

function createAuthRouter(chaos) {
  const router = express.Router();

  router.post('/auth/login', (request, response) => {
    const { email, password } = request.body;
    const user = USERS.find((candidate) => candidate.email === email && candidate.password === password);

    if (!user) {
      return response.status(401).json({ message: 'Credenciales inválidas' });
    }

    // El único fallo de caos que actúa dentro del login: firma un token que ya
    // nació vencido. Todo lo demás deja el login en paz a propósito — si no
    // puedes entrar, no puedes diagnosticar nada.
    const ttl = chaos.faults.includes('expired') ? -60 : TOKEN_TTL_SECONDS;

    const accessToken = jwt.sign(
      { sub: user.sub, name: user.name, role: user.role },
      JWT_SECRET,
      { expiresIn: ttl },
    );

    response.json({ accessToken, expiresIn: ttl });
  });

  return router;
}

function requireToken(request, response, next) {
  const header = request.headers.authorization;

  if (typeof header !== 'string' || !header.startsWith('Bearer ')) {
    return response.status(401).json({ message: 'Falta el token de acceso' });
  }

  try {
    request.user = jwt.verify(header.slice('Bearer '.length), JWT_SECRET);
    next();
  } catch (error) {
    response.status(401).json({ message: 'Token inválido o expirado' });
  }
}

module.exports = { createAuthRouter, requireToken };
