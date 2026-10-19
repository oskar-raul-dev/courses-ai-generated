// mock/server.js
const express = require('express');
const jwt = require('jsonwebtoken');

const app = express();
app.use(express.json());

// Secreto de juguete, en claro y versionado a propósito: esto es un mock de
// desarrollo. Un secreto de verdad no vive en el repositorio, y la Fase 13
// vuelve sobre eso cuando hablemos de configuración en tiempo de arranque.
const JWT_SECRET = 'certcore-dev-secret';
const TOKEN_TTL_SECONDS = 3600;

const USERS = [
  {
    email: 'inspector@certcore.co',
    password: 'certcore123',
    sub: 'INS-15',
    name: 'Ana Restrepo',
    role: 'inspector',
  },
  {
    email: 'supervisor@certcore.co',
    password: 'certcore123',
    sub: 'SUP-02',
    name: 'Diego Marín',
    role: 'supervisor',
  },
];

// CORS a mano. Fíjate en Allow-Headers: si X-Correlation-Id no está en esa
// lista, el navegador rechaza la petición antes de enviarla y el error que
// verás no menciona la cabecera. La Fase 3 hace de esto un fallo provocable.
app.use((request, response, next) => {
  response.header('Access-Control-Allow-Origin', 'http://localhost:4200');
  response.header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Correlation-Id');
  response.header('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
  if (request.method === 'OPTIONS') {
    return response.sendStatus(204);
  }
  next();
});

app.post('/auth/login', (request, response) => {
  const { email, password } = request.body;
  const user = USERS.find((candidate) => candidate.email === email && candidate.password === password);

  if (!user) {
    // 401 con cuerpo: el cliente necesita algo que mostrar, y "Unauthorized"
    // a secas no le dice nada a un inspector en campo.
    return response.status(401).json({ message: 'Credenciales inválidas' });
  }

  const accessToken = jwt.sign(
    { sub: user.sub, name: user.name, role: user.role },
    JWT_SECRET,
    { expiresIn: TOKEN_TTL_SECONDS },
  );

  response.json({ accessToken, expiresIn: TOKEN_TTL_SECONDS });
});

// Middleware de autorización. Es lo que convierte al guard del navegador en un
// adorno y a esto en la protección de verdad.
const requireToken = (request, response, next) => {
  const header = request.headers.authorization;

  if (typeof header !== 'string' || !header.startsWith('Bearer ')) {
    return response.status(401).json({ message: 'Falta el token de acceso' });
  }

  try {
    request.user = jwt.verify(header.slice('Bearer '.length), JWT_SECRET);
    next();
  } catch (error) {
    // jwt.verify lanza tanto si la firma no cuadra como si el token expiró.
    response.status(401).json({ message: 'Token inválido o expirado' });
  }
};

// Un endpoint protegido, vacío, sólo para tener dónde probar el interceptor.
// La Fase 3 lo reemplaza por json-server con el db.json del dominio.
app.get('/inspections', requireToken, (request, response) => {
  response.json([]);
});

app.listen(3000, () => {
  console.log('Mock de CertCore escuchando en http://localhost:3000');
});
